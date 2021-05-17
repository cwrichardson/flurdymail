# aws-mirovoy-ref-arch-04-mail
# Description
Mirovoy Reference Architecture - Create mail servers This template creates a primary mail server that runs courier-postfix for inbound and outbound mail, and a backup MX server in a separate AZ.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AccountEmail 
Type: String  
Description: The email address for submitting to LetsEncrypt. Generally set at account level rather than domain. 
### ADLogLevel 
Type: Number 
Default: 1 
Description: Sets amavisd logging level. When set to 2, it also changes the syslog_priority from "info" to "debug". 
### AdminUser 
Type: String  
Description: An alternate account (unix user) to be created on mail servers with superuser permissions. 
### AdminPubKey 
Type: String  
Description: The public key text to be installed in the authorized_hosts file for the alternate account created above. Will also be installed in authorized_hosts for the default admin user (ec2-user). Probably just cut and paste the contents of your id_rsa.pub file for the user. 
### Banner 
Type: String 
Default: $myhostname ESMTP $mail_name 
Description: What to display when someone connects for SMTP. It should be enough to be useful, but not give away unnecessary information to potential hackers. 
### CertSource 
Type: String 
Default: generate test 
Description: Where to get the SSL certificates. By default, certificates will be obtained from the LetsEncrypt staging server (fake certs, untrusted in the wild). Set to "generate real" to generate real LetsEncrypt certs. 
### DelayWarningTime 
Type: String 
Default: 4h 
Description: How long does mail remain undelivered before sending a warning update to the sender? 
### DisableServices 
Type: String 
Default: 01 none 
Description: To quote Flurdy, "Test early and frequently." If things don't Just Work, you can roll back to just a basic Postfix installation and start from there. Take a good read of http://flurdy.com/docs/postfix/#test. 
### DisableSpamChecks 
Type: String  
Description: Disable all spam checks (sets @bypass_spam_checks_maps = (1)). This can be useful if you're having a hard time just getting amavisd up and running and passing messages back and forth from postfix. 
### DisableVirusChecks 
Type: String  
Description: Disable all virus checks (sets @bypass_virus_checks_maps = (1)). This can be useful if you're having a hard time just getting amavisd up and running and passing messages back and forth from postfix. 
### DNSSleep 
Type: Number 
Default: 180 
Description: Configure the wait time to make sure that DNS route properly propagate. 180 seconds seems to work in most cases, but YMMV. If you're running into failures for issueing the cert, turn on acme debugging, below, and if the problem is with verification of the DNS TXT entry, try upping this. 
### DNSZone 
Type: List<AWS::Route53::HostedZone::Id>  
Description: The Route53 Hosted Zone that includes the mail server. This will be used for automatic authorization during the creation process for the LetsEncrypt SSL certificate, so it should match the domain of the mail server. For example, if you put "mx1.mail.example.com" as the name of the server, then this should be the Hosted Zone ID for the "mail.example.com" zone. 
### OpenDkimDomains 
Type: String  
Description: Domain(s) whose email should be signed by opendkim. A comma separated list without spaces (e.g., example,com,example.co.uk) 
### Subnet 
Type: List<AWS::EC2::Subnet::Id>  
Description: Subnet in which to place the mail server. 
### SAFinalDest 
Type: String 
Default: D_DISCARD 
Description: Sets final_spam_destiny variable. The Debian default is D_BOUNCE; the Ubuntu default is D_DISCARD, which is recommended, as bouncing leads to backscatter and the sender is usually faked anyhow. The package that installs here defaults to D_REJECT. Setting it to D_PASS is useful for testing, as you can still run mail through SpamAssassin, get the headers attached, but not filter the message. 
### SAKillLevelDeflt 
Type: Number 
Default: 8.0 
Description: Triggers spam evasive actions (e.g., blocks mail). Amavisd defaults to 6.9. Flurdy sets it to 8.0. You'll have to play around and see how much spam is getting through, vs. how many false positives you have. 
### ServerName 
Type: String 
Default: mail.example.com 
Description: The fully qualified domain name for the mail server. In addition to being put into /etc/mailname, this will also be used for the creation of a LetsEncrypt certificate, if you use LetsEncrypt, below. 
### SetMyHost 
Type: String  
Description: AmavisD has two variables, myhost and mydomain, which get inserted into mail headers. By default, those values are host.example.com and example.com, respectively. If you set this to true, then those defaults will be changed to the host and domain you configured as the server name, above. 
### SpfTimeLimit 
Type: Number 
Default: 3600 
Description: Timeout for policyd-spf, from Flurdy extras 
### SSLDebug 
Type: String  
Description: Set the --debug flag for acme.sh, which may prove useful if you're having trouble getting an SSL cert. 
### VirtualUID 
Type: Number 
Default: 5000 
Description: The UID to be assigned to the user "virtual" which owns all mailboxes on the system. Note, we can't conveniently assign a GID with CloudFormation, so unlike Flurdy where that is also 5000, the GID for the virtual group will be assigned by the system. 
### DatabaseStackName 
Type: String  
Description: The name of the stack that was used to create the RDS instances 
### EnableOpenDkim 
Type: String 
Default: True 
Description: Enable Open DKIM from Flurdy Extended 
### EnableSpfChecks 
Type: String 
Default: True 
Description: Enable SPF Verification from Flurdy Extended 
### ExternalTestEmail 
Type: String  
Description: If "insert test data" is enabled, mail for test user karl@example.com will be set to forward to the email address you input here. 
### MailAMIID 
Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id> 
Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
Description: AMI ID to use for the mail servers 
### MailDBBackup 
Type: String  
Description: A path/to/a/file under your S3 prefix, defined below. It should not start with a slash, and should include the entire filename. The file should be the output of mysqldump, and will be fed into mysql. 
### MailDBName 
Type: String 
Default: maildb 
Description: The MySQL mail database name. 
### MailDBPassword 
Type: String  
Description: The MySQL password for the mail-database user. 
### MailDBUser 
Type: String 
Default: mail 
Description: The MySQL username to have access to the mail database. 
### MaxUserConnections 
Type: Number 
Default: 25 
Description: The maximum number of IMAP connections allwed for a user from each IP address. Dovecot default is 10, but Jon Jerome's guide says, "Some clients open up more user connections at once than you might think.... If your email client gets random failures to connect during a session, especially a webmail client like Roundcube, try increasing this value." 
### EC2KeyName 
Type: AWS::EC2::KeyPair::KeyName  
Description: Name of an EC2 KeyPair. Your mail instances will launch with this KeyPair. 
### HardErrLimit 
Type: Number 
Default: 20 
Description: smtpd_hard_error_limit The maximal number of errors a remote SMTP client is allowed to make without delivering mail. The Postfix SMTP server disconnects when the limit is exceeded.  Normally the default limit is 20, but it changes under overload to just 1. 
### HeloTimeout 
Type: String 
Default: 60s 
Description: smtp_helo_timeout The Postfix SMTP client time limit for sending the HELO or EHLO command, and for receiving the initial remote SMTP server response. The Postfix default is 300s. Flurdy changes this to 60s. Not sure why, but it seems to work for us. The default time unit is s (seconds). 
### InetProtocols 
Type: String 
Default: ipv4 
Description: Support for IPv4 or IPv6. Postfix default config has "all", but Flurdy sets it to IPv4, to avoid flooding logswith IPv6 errors. We haven't tested anything other than "ipv4". 
### InsertTestData 
Type: String  
Description: Add test users and domains to database. This is useful for testing. The model is similar to the samle data provided at flurdy. Three users are created: xandros@example.com, vivita@example,com, and karl@example.com. example.com and example.net are both created as domains, and all mail for example.net is forwarded to xandros@example.com. All mail for karl@example.com is forwarded to an external email you specify. 
### MailInstanceType 
Type: String 
Default: t3.micro 
Description: The Amazon EC2 instance type for your mail server. This is set to default to t3.micro because that seems to be the minimum to support ClamAV. However, if you're not using ClamAV, you may well be able to turn this down to t3.nano; and if t3.micro works for your primary server than t3.nano is definitely good enough for your backup server. 
### MailSecurityGroup 
Type: AWS::EC2::SecurityGroup::Id  
Description: Select the mail security group. 
### MaxBackoffTime 
Type: String 
Default: 4000s 
Description: maximal_backoff_time The maximal time between attempts to deliver a deferred message. The default time unit is s (seconds). Time units are s (seconds), m (minutes), h (hours), d (days), w (weeks). 
### MaxQueueLifetime 
Type: String 
Default: 5d 
Description: maximal_queue_lifetime How long to keep messages on queue before returning as failed.  Five days is pretty normal, but there's nothing wrong with adjusting it up or down if you have reason (e.g., your serving mail for people who often go away for a week at a time and leave their server off). Specify 0 when mail delivery should be tried only once. Time units are s (seconds), m (minutes), h (hours), d (days), w (weeks). 
### MinBackoffTime 
Type: String 
Default: 300s 
Description: minimal_backoff_time The minimal time between attempts to deliver a deferred message. The default time unit is s (seconds). Time units are s (seconds), m (minutes), h (hours), d (days), w (weeks). 
### MirovoyCFAssetsBucket 
Type: String 
Default: mirovoy-cf-assets 
Description: S3 bucket name for the Mirovoy CloudFormation assets. 
### MYS3KeyPrefix 
Type: String 
Default: mail/ 
Description: S3 key prefix for the Mirovoy CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### Origin 
Type: String 
Default: domain 
Description: myorigin For unix users on this machine posting mail, what to append to the username? The full hostname or the domain name?  Probably the domain name, but keep in mind that this will be weird for root@ 
### PrimaryOrBackup 
Type: String 
Default: primary 
Description: Deploy a primary or a backup mail server 
### RelayHost 
Type: String  
Description: Leave blank if this mail server sends all outbound mail. If you need to relay, e.g., through your ISP's server, enter that here. 
### SkelFileDir 
Type: String 
Default: var/skel/ 
Description: Path under S3 prefix for Banner text to put in the alternate admin user's home dir, via /etc/skel/. Should end in a slash. 
### RecipientLimit 
Type: String 
Default: 50 
Description: smtpd_recipient_limit The maximal number of recipients that the Postfix SMTP server accepts per message delivery request. The actual Postfix default is 1000; Flurdy changes it to 16 because "effective stopper to mass spammers, accidental copy in whole address list", but we find we regularly send to more than 16 recipients in a single message. 
### RootMailRecipient 
Type: String  
Description: The recipient for local root mail. It can be a user on this machine (e.g., the user added as AltAdmin above), in which case you'll need to log into the machine locally and get check your mail periodically. Or, it can be a real email address; or better, a real email distribution list (e.g., sysadmins@example.com) that goes to people who will read such messages. 
### SoftErrLimit 
Type: Number 
Default: 3 
Description: smtpd_soft_error_limit The number of errors a remote SMTP client is allowed to make without delivering mail before the Postfix SMTP server slows down all its responses. The Postfix default is 10, and you may want to set it to that, or even higher, while you're testing your deployment, so you don't get slowed down, but once things are working properly you should definitely come lower it 
### StorageStackName 
Type: String  
Description: The name of the stack that was used to create EBS volumes 
### UnknownLocalErrorCode 
Type: Number 
Default: 550 
Description: What code to send if local lookup on an address fails. Should be 550 (reject mail), but is often worth setting to 450 (try again later) while you make sure your local_recipient_maps settings are OK. 
### UseSwap 
Type: String 
Default: True 
Description: Use a volume created by the storage template for swap 
### VivitaPass 
Type: String  
Description: If insert test data is enabled, this will be the password for test user "vivita". 
### XandrosPass 
Type: String  
Description: If insert test data is enabled, this will be the password for test user "xandros". 

## Resources
The list of resources this template creates:

### MailInstanceRole 
Type: AWS::IAM::Role  
### MailInstancePolicy 
Type: AWS::IAM::Policy  
### MailInstanceProfile 
Type: AWS::IAM::InstanceProfile  
### MailServerInstance 
Type: AWS::EC2::Instance  
### BackupMailServerInstance 
Type: AWS::EC2::Instance  
### SpoolMountPoint 
Type: AWS::EC2::VolumeAttachment  
### BackupSpoolMountPoint 
Type: AWS::EC2::VolumeAttachment  
### SwapMountPoint 
Type: AWS::EC2::VolumeAttachment  
### BackupSwapMountPoint 
Type: AWS::EC2::VolumeAttachment  
### LogMountPoint 
Type: AWS::EC2::VolumeAttachment  
### BackupLogMountPoint 
Type: AWS::EC2::VolumeAttachment  

## Outputs
The list of outputs this template exposes:

### PrimaryMailServerPrivateDNS 
  

