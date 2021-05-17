# aws-mirovoy-ref-arch-flurdy-mail-master
# Description
Mirovoy Reference Architecture - Flurdy Mail - This is the top level nested stack to deploy a Flurdy-style email server on top of the Mirovoy Reference Architecture infrastructure stack. It will deploy mail storage for spool and log as well as optionally swap, a primary and backup mail server, and a webmail autoscaling group.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AccountEmail 
Type: String  
Description: The email address for submitting to LetsEncrypt. Generally set at account level rather than domain. 
### AdminUser 
Type: String  
Description: An alternate account to be created on bastion instances with superuser permissions. 
### AdminPubKey 
Type: String  
Description: The public key text to be installed in the authorized_hosts file for the admin user. Will also be installed as an accepted key for the default admin user (ec2-user). 
### AllowPasswdChange 
Type: String 
Default: True 
Description: Enable the Roundcube password pluging to allow users to change their password themselves 
### AlternativeIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the server. If left blank, a new role will be created. 
### AlternativeInitializationScript 
Type: String  
Description: Specify an alternative initialization script to run during setup. 
### AMIID 
Type: String 
Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
Description: AMI ID to use for the servers 
### AvailabilityZones 
Type: List<AWS::EC2::AvailabilityZone::Name>  
Description: Pick two availability zones from your region in which to deploy the mail stack. Logical order is preserverd (so, the first selected is where the primary mail server will go). 
### Banner 
Type: String 
Default: $myhostname ESMTP $mail_name 
Description: What to display when someone connects for SMTP. It should be enough to be useful, but not give away unnecessary information to potential hackers. 
### CertSource 
Type: String 
Default: generate test 
Description: Where to get the SSL certificates. By default, certificates will be obtained from the LetsEncrypt staging server (fake certs, untrusted in the wild). Set to "generate real" to generate real LetsEncrypt certs. Set to "S3" to download certificates from the certificate file directory specified under you S3 bucket/prefix. Set to "none" to manually install your certificates later. 
### Cmk 
Type: String  
Description: The Amazon Resource Name (ARN) of an existing AWS KMS Customer Master Key (CMK) to encrypt EBS volumes. 
### DatabaseStackName 
Type: String  
Description: The name of the stack that was used to create the RDS instances 
### DeploymentType 
Type: String 
Default: Primary, backup, webmail 
Description: Which email services to deploy. 
### DNSSleep 
Type: Number 
Default: 180 
Description: Configure the wait time to make sure that DNS route properly propagate. 180 seconds seems to work in most cases, but YMMV. If you're running into failures for issueing the cert, turn on acme debugging, below, and if the problem is with verification of the DNS TXT entry, try upping this. 
### DNSZone 
Type: AWS::Route53::HostedZone::Id  
Description: The ID for Route53 Hosted Zone that includes the mail server. This will be used for automatic authorization during the creation process for the LetsEncrypt SSL certificate, so it should match the domain of the primary mail server. For example, if you put "mx1.mail.example.com" as the name of the primary server, then this should be the Hosted Zone ID for the "mail.example.com" zone. 
### EbsDelPolicy 
Type: String 
Default: Snapshot 
Description: What to do with the spool volumes when the stack is deleted. 
### EC2KeyName 
Type: AWS::EC2::KeyPair::KeyName  
Description: Name of an EC2 KeyPair. Your mail instances will launch with this KeyPair. 
### EnvironmentVariables 
Type: String  
Description: Specify a comma separated list of environment variables for use in bootstrapping by the alternative initialization script. Variables must be in the format KEY=VALUE. VALUE cannot contain commas. 
### ExternalTestEmail 
Type: String  
Description: If "insert test data" is enabled, mail for test user karl@example.com will be set to forward to the email address you input here. 
### Hash 
Type: String 
Default: sha512-crypt 
Description: Hashing algorithm used when users change their password. If you're moving from an existing Flurdy installation, current passwords will be SHA256-CRYPT. Leaving this at SHA512-CRYPT will migrate users to the stronger encryption as they update their passwords. 
### InetProtocols 
Type: String 
Default: ipv4 
Description: Support for IPv4 or IPv6. Postfix default config has "all", but Flurdy sets it to IPv4, to avoid flooding logswith IPv6 errors. We haven''t tested anything other than "ipv4". 
### InsertTestData 
Type: String  
Description: Add test users and domains to database. This is useful for testing. The model is similar to the samle data provided at flurdy. Three users are created: xandros@example.com, vivita@example,com, and karl@example.com. example.com and example.net are both created as domains, and all mail for example.net is forwarded to xandros@example.com. All mail for karl@example.com is forwarded to an external email you specify. 
### InstanceType 
Type: String 
Default: t3.nano 
Description: The Amazon EC2 instance type for your mail and rouncube instances. 
### LogSize 
Type: Number 
Default: 2 
Description: Size (in GB) for device to mount on /var/log 
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
### MailS3KeyPrefix 
Type: String 
Default: mail/ 
Description: S3 key prefix for the Mirovoy CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### MailSecurityGroup 
Type: AWS::EC2::SecurityGroup::Id  
Description: Select the mail security group. 
### MasterLogSnapshot 
Type: String  
Description: The snapshot ID from which to restore /var/log for the master mail server 
### MasterSpoolSnapshot 
Type: String  
Description: The snapshot ID from which to restore /var/spool for the master mail server 
### MirovoyCFAssetsBucket 
Type: String 
Default: mirovoy-cf-assets 
Description: S3 bucket name for the Mirovoy CloudFormation assets. 
### OpenDkimDomains 
Type: String  
Description: Domain(s) whose email should be signed by opendkim. A comma separated list without spaces (e.g., example,com,example.co.uk) 
### Origin 
Type: String 
Default: domain 
Description: myorigin For unix users on this machine posting mail, what to append to the username? The full hostname or the domain name?  Probably the domain name, but keep in mind that this will be weird for root@ 
### ServerNames 
Type: CommaDelimitedList 
Default: mx1.example.com,mx2.example.com,webmail.example.com 
Description: A comma separated list of fully-qualified domain names: <primary mail server>,<backup mail server>,<webmail>. All three values must be provided, but may be empty. For example, if you select "Primary and webmail" as deployment type, you may enter "mail.example.com,,webmail.example.com" (without the quotation marks). 
### PublicAlbListenerArn 
Type: String  
Description: The public application load balancer listener's arn. This is NOT the ARN of the load balancer. Go to EC2 -> Load Balancing -> Load Balancers. Select the desired Load Balancer, and click on the Listeners tab, then copy the Listener ID for HTTPS : 443. 
### RelayHost 
Type: String  
Description: Leave blank if this mail server sends all outbound mail. If you need to relay, e.g., through your ISP's server, enter that here. 
### RootMailRecipient 
Type: String  
Description: The recipient for local root mail. It can be a user on this machine (e.g., the user added as AltAdmin above), in which case you'll need to log into the machine locally and get check your mail periodically. Or, it can be a real email address; or better, a real email distribution list (e.g., sysadmins@example.com) that goes to people who will read such messages. 
### RoundcubeDBName 
Type: String 
Default: roundcube 
Description: The MySQL Roundcube database name. 
### RoundcubeDBPass 
Type: String  
Description: The MySQL password for the roundcube-database user. Must be between 8 and 41 characters, inclusive, in length; and, must be letters (upper or lower), numbers, and these special characters '_'`~!#$%^&*()_+,-" 
### RoundcubeDBUser 
Type: String 
Default: webmail 
Description: The MySQL username to have access to the roundcube database. 
### RoundcubeS3KeyPrefix 
Type: String 
Default: roundcube/ 
Description: S3 key prefix for the Mirovoy CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### RoundcubeSecurityGroup 
Type: String 
Default: default 
Description: If webmail is enabled, do not leave as "default"; instead enter the security group ID of the webmail security group (e.g., sg-0d960aa89192ec08a). Unlike the Mail Security Group, above, we can't have a drop-down here, because things fail badly if this is left blank, so we have to be able to put something if webmail is not enabled. 
### SAFinalDest 
Type: String 
Default: D_DISCARD 
Description: Sets final_spam_destiny variable. The Debian default is D_BOUNCE; the Ubuntu default is D_DISCARD, which is recommended, as bouncing leads to backscatter and the sender is usually faked anyhow. The package that installs here defaults to D_REJECT. Setting it to D_PASS is useful for testing, as you can still run mail through SpamAssassin, get the headers attached, but not filter the message. 
### SetMyHost 
Type: String  
Description: AmavisD has two variables, myhost and mydomain, which get inserted into mail headers. By default, those values are host.example.com and example.com, respectively. If you set this to true, then those defaults will be changed to the host and domain you configured as the primary server name, above. 
### SkelFileDir 
Type: String 
Default: var/skel/ 
Description: Path under S3 prefix for Banner text to put in the alternate admin user's home dir, via /etc/skel/. Should end in a slash. 
### Skin 
Type: String 
Default: larry 
Description: Skin name. Select from folders in roundcube skins/ 
### SpoolSize 
Type: Number 
Default: 10 
Description: Size (in GB) for device to mount on /var/spool 
### SwapSize 
Type: Number 
Default: 2 
Description: Size (in GB) for device to mount on /var/spool. If you do not want to use swap (e.g., because you're using larger instances with more memory), simply set this to zero. 
### UnknownLocalErrorCode 
Type: Number 
Default: 450 
Description: What code to send if local lookup on an address fails. Should be 550 (reject mail), but is often worth setting to 450 (try again later) while you make sure your local_recipient_maps settings are OK. 
### VirtualUID 
Type: Number 
Default: 5000 
Description: The UID to be assigned to the user "virtual" which owns all mailboxes on the system. Note, we can't conveniently assign a GID with CloudFormation, so unlike Flurdy where that is also 5000, the GID for the virtual group will be assigned by the system. 
### VivitaPass 
Type: String  
Description: If insert test data is enabled, this will be the password for test user "vivita@example.com". 
### VpcStackName 
Type: String  
Description: The name of the stack that was used to create the VPC 
### XandrosPass 
Type: String  
Description: If insert test data is enabled, this will be the password for test user "xandros". 

## Resources
The list of resources this template creates:

### mailstorage 
Type: AWS::CloudFormation::Stack  
### backupmailstorage 
Type: AWS::CloudFormation::Stack  
### mail 
Type: AWS::CloudFormation::Stack  
### backupmail 
Type: AWS::CloudFormation::Stack  
### webmail 
Type: AWS::CloudFormation::Stack  

## Outputs
The list of outputs this template exposes:

