# aws-mirovoy-ref-arch-master
# Description
Mirovoy Reference Architecture - Master - Stack to deploy a Flurdy mail environment on top of the Mirovoy Reference Architecture.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AccountEmail 
Type: String  
Description: The email address for submitting to LetsEncrypt. Generally set at account level rather than domain. 
### AdminInstanceType 
Type: String 
Default: t3.nano 
Description: EC2 instance type for bastion and phpmyamin servers. 
### AdminPubKey 
Type: String  
Description: The public key text to be installed in the authorized_hosts file for the admin user. Will also be installed as an accepted key for the default admin user (e.g., ec2-user@). You can probably just cut and paste from ~/.ssh/id_rsa.pub 
### AdminUser 
Type: String  
Description: An alternate account to be created on all instances, with superuser permissions. 
### AllowPasswdChange 
Type: String 
Default: True 
Description: Enable the Roundcube password pluging to allow users to change their password themselves 
### AlternativeBastionIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the bastion. If left blank, a new role will be created. 
### AlternativeNatIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the NAT instances.  If left blank, a new role will be created. 
### AlternativePhpIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the phpmyadmin instances.  If left blank, a new role will be created. 
### AlternativeWebmailIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the server. If left blank, a new role will be created. 
### AMIOS 
Type: String 
Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
Description: AMI ID to use for EC2 instances 
### AvailabilityZones 
Type: List<AWS::EC2::AvailabilityZone::Name>  
Description: List of Availability Zones to use for the subnets in the VPC. Note: The logical order is preserved (i.e., "master" resources will go in the first one selected, "backup" in the second). Currently, exactly two must be selected. 
### Banner 
Type: String 
Default: $myhostname ESMTP $mail_name 
Description: What to display when someone connects for SMTP. It should be enough to be useful, but not give away unnecessary information to potential hackers. 
### CertSource 
Type: String 
Default: generate test 
Description: Where to get the SSL certificates. By default, certificates will be obtained from the LetsEncrypt staging server (fake certs, untrusted in the wild). Set to "generate real" to generate real LetsEncrypt certs. 
### CFAssetsBucket 
Type: String 
Default: mirovoy-cf-assets 
Description: S3 bucket name for the CloudFormation assets. If you look at an S3 URL, it would be "https://<asset-bucket>.s3-<region>.amazonaws.com".  This is where you should put the files from mirovoy-cf-assets from the source repository. 
### DatabaseInstanceType 
Type: String 
Default: db.t2.micro 
Description: The Amazon RDS database instance class. 
### DatabaseMasterUsername 
Type: String 
Default: root 
Description: The "root" user to configure for the Amazon RDS database. 
### DatabaseMasterPassword 
Type: String  
Description: The Amazon RDS "root" user password. If you wish to use a username other than "root", it can be configured below under AWS MySQL RDS Parameters. Must be between 8 and 41 characters in length, inclusiv; and must be letters (upper or lower), numbers, and these special characters \'_\'`~!#$%^&*()_+,- 
### DatabaseRestoreSnapshot 
Type: String  
Description: The snapshot name to restore from. 
### DeploymentType 
Type: String 
Default: Primary, backup, webmail, phpMyAdmin 
Description: Which services to deploy. 
### DNSZone 
Type: List<AWS::Route53::HostedZone::Id>  
Description: The Route53 Hosted Zone that includes the mail server. This will be used for automatic authorization during the creation process for the LetsEncrypt SSL certificate, so it should match the domain of the primary mail server. For example, if you put "mx1.mail.example.com" as the name of the primary server, then this should be the Hosted Zone ID for the "mail.example.com" zone. 
### EbsDelPolicy 
Type: String 
Default: Snapshot 
Description: What to do with the spool volumes when the stack is deleted. 
### EC2KeyName 
Type: AWS::EC2::KeyPair::KeyName  
Description: Name of an EC2 KeyPair. All instances will launch with this KeyPair. 
### ExternalTestEmail 
Type: String  
Description: If "insert test data" is enabled, mail for test user karl@example.com will be set to forward to the email address you input here. 
### InsertTestData 
Type: String  
Description: Add test users and domains to database. This is useful for testing. The model is similar to the samle data provided at flurdy. Three users are created: xandros@example.com, vivita@example,com, and karl@example.com. example.com and example.net are both created as domains, and all mail for example.net is forwarded to xandros@example.com. All mail for karl@example.com is forwarded to an external email you specify. 
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
Description: The MySQL password for the mail-database user. Must be between 8 and 41 characters, inclusive, in length; and, must be letters (upper or lower), numbers, and these special characters '_'`~!#$%^&*()_+,-" 
### MailDBUser 
Type: String 
Default: mail 
Description: The MySQL username to have access to the mail database. 
### MailInstanceType 
Type: String 
Default: t3.nano 
Description: primary MX, backup MX, and RoundCube EC2 instance type. 
### MailStorageCmk 
Type: String  
Description: The Amazon Resource Name (ARN) of an existing AWS KMS Customer Master Key (CMK) to encrypt EBS volumes. If left blank, the volumes will not be encrypted. 
### MasterLogSnapshot 
Type: String  
Description: The snapshot ID from which to restore /var/log for the master mail server 
### MasterSpoolSnapshot 
Type: String  
Description: The snapshot ID from which to restore /var/spool for the master mail server 
### NatInstanceType 
Type: String 
Default: t3.nano 
Description: NAT EC2 instance type. NB: t3 instances have burstable CPU which is charged at an additional $0.05 per CPU hour. If you are running at max CPU utilization for an entire month, then m3.medium and c5.large are actually more cost effective. Keep an eye on your burst charges and adjust your instance type as necessary. 
### NumberOfAZs 
Type: Number 
Default: 2 
Description: Number of Availability Zones to use in the VPC. Currently must be exactly 2. 
### OpenDkimDomains 
Type: String  
Description: Domain(s) whose email should be signed by opendkim. A comma separated list without spaces (e.g., example,com,example.co.uk) 
### Origin 
Type: String 
Default: domain 
Description: myorigin For unix users on this machine posting mail, what to append to the username? The full hostname or the domain name?  Probably the domain name, but keep in mind that this will be weird for root@ 
### PublicAlbAcmCertificate 
Type: String  
Description: The AWS Certification Manager certificate ARN for the ALB certificate. This is only required if you enable either phpMyAdmin or Roundcube. This certificate should be created in the region you wish to run the ALB and must reference the domain names you wish to load balance. If you're using phpMyAdmin and www, for example, it should include both of those fully qualified domains. It is not used for termination of mail TLS connections. 
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
Description: The MySQL password for the roundcube-database user. 
### RoundcubeDBUser 
Type: String 
Default: webmail 
Description: The MySQL username to have access to the roundcube database. 
### SAFinalDest 
Type: String 
Default: D_DISCARD 
Description: Sets final_spam_destiny variable. The Debian default is D_BOUNCE; the Ubuntu default is D_DISCARD, which is recommended, as bouncing leads to backscatter and the sender is usually faked anyhow. The package that installs here defaults to D_REJECT. Setting it to D_PASS is useful for testing, as you can still run mail through SpamAssassin, get the headers attached, but not filter the message. 
### SetMyHost 
Type: String  
Description: AmavisD has two variables, myhost and mydomain, which get inserted into mail headers. By default, those values are host.example.com and example.com, respectively. If you set this to true, then those defaults will be changed to the host and domain you configured as the primary server name, above. 
### ServerNames 
Type: CommaDelimitedList  
Description: A comma separated list of fully-qualified domain names, for the services specified above in "Deployment Type". Order matters, but values can be left blank. The order is <primary mail server>, <backup mail server>,<webmail>,<phpMyAdmin>. So, for example, if you selected "Primary and Webmail" in Deployment Type, you would put something like "mx1.example.com,,webmail.example.com", leaving the space for <backup mail server> empty. 
### SpoolSize 
Type: Number 
Default: 10 
Description: Size (in GB) for device to mount on /var/spool 
### SshAccessCidr 
Type: String 
Default: 0.0.0.0/0 
Description: The CIDR IP range that is permitted to SSH to bastion instance. Note - a value of 0.0.0.0/0 will allow access from ANY IP address. 
### SwapSize 
Type: Number 
Default: 2 
Description: Size (in GB) for device to mount on /var/spool. If you do not want to use swap (e.g., because you're using larger instances with more memory), simply set this to zero. 
### TestUserPass 
Type: String  
Description: If insert test data is enabled, this will be the password for test users ("vivita@example.com", and "xandrso@example.com"). 
### UnknownLocalErrorCode 
Type: Number 
Default: 450 
Description: What code to send if local lookup on an address fails. Should be 550 (reject mail), but is often worth setting to 450 (try again later) while you make sure your local_recipient_maps settings are OK. 
### VirtualUID 
Type: Number 
Default: 5000 
Description: The UID to be assigned to the user "virtual" which owns all mailboxes on the system. Note, we can't conveniently assign a GID with CloudFormation, so unlike Flurdy where that is also 5000, the GID for the virtual group will be assigned by the system. 

## Resources
The list of resources this template creates:

### infrastructure 
Type: AWS::CloudFormation::Stack  
### mail 
Type: AWS::CloudFormation::Stack  

## Outputs
The list of outputs this template exposes:

