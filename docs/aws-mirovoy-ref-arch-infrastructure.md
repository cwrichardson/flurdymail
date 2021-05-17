# aws-mirovoy-ref-arch-infrastructure
# Description
Mirovoy Reference Architecture - Infrastructure - Stack to deploy the core infrastructure for the Mirovoy Reference Architecture. This is a nested stack which will launch stacks for VPC, Security Groups, Bastion Autoscaling Group, NAT Instance Auto Scaling Group, Application Load Balancer, and MySQL RDS.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AdminUser 
Type: String  
Description: An alternate account to be created on bastion instances with superuser permissions. 
### AdminPubKey 
Type: String  
Description: The public key text to be installed in the authorized_hosts file for the admin user. Will also be installed as an accepted key for the default admin user (e.g., ec2-user@). You can probably just cut and paste from ~/.ssh/id_rsa.pub 
### AlternativeBastionIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the bastion. If left blank, a new role will be created. 
### AlternativeBastionInitializationScript 
Type: String  
Description: URL for an alternative initialization script to run during setup. By default, during startup the instances will look in the S3 configuration below and run .../<prefix/>scripts/bastion_bootstrap.sh. This should be the full URL to an alternative script. 
### AlternativeNatIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the NAT instances.  If left blank, a new role will be created. 
### AlternativeNatInitializationScript 
Type: String  
Description: URL for an alternative initialization script to run during setup. By default, during startup the instances will look in the S3 configuration below and run .../<prefix/>scripts/nat_bootstrap.sh. This should be the full URL to an alternative script. 
### AlternativePhpIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the phpmyadmin instances.  If left blank, a new role will be created. 
### AlternativePhpInitializationScript 
Type: String  
Description: URL for an alternative initialization script to run during setup. By default, during startup the instances will look in the S3 configuration below and run .../<prefix/>scripts/php_bootstrap.sh. This should be the full URL to an alternative script. 
### AMIOS 
Type: String 
Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
Description: AMI ID to use for EC2 instances 
### AppSubnet1Cidr 
Type: String 
Default: 10.0.4.0/22 
Description: CIDR block for App subnet 1 located in Availability Zone 1 
### AppSubnet2Cidr 
Type: String 
Default: 10.0.8.0/22 
Description: CIDR block for App subnet 2 located in Availability Zone 2 
### AvailabilityZones 
Type: List<AWS::EC2::AvailabilityZone::Name>  
Description: List of Availability Zones to use for the subnets in the VPC. Note: The logical order is preserved (i.e., "master" resources will go in the first one selected, "backup" in the second). Currently, exactly two must be selected. 
### BastionBanner 
Type: String 
Default: var/banner_message.txt 
Description: Path and file under S3 prefix for Banner text to display upon login. Should not start with a "/". 
### BastionEnvironmentVariables 
Type: String  
Description: Specify a comma separated list of environment variables for use in bootstrapping by the alternative initialization script. Variables must be in the format KEY=VALUE. VALUE cannot contain commas. 
### BastionInstanceType 
Type: String 
Default: t3.nano 
Description: Bastion EC2 instance type. 
### CFAssetsBucket 
Type: String 
Default: mirovoy-cf-assets 
Description: S3 bucket name for the CloudFormation assets. If you look at an S3 URL, it would be "https://<bucket-name>.s3-<region>.amazonaws.com". 
### CreateMailSecGroup 
Type: String 
Default: False 
Description: If you are using this template and later intend to run the aws-mirovoy-ref-arch-flurdy-mail-master on top of it, set this to true; otherwise, the required security groups will need to be manually configured. 
### CreateWebMailSecGroup 
Type: String 
Default: False 
Description: If you are using this template and later intend to run the aws-mirovoy-ref-arch-flurdy-mail-master on top of it with webmail enabled, set this to true; otherwise, the required security groups will need to be manually configured. 
### CreateReplica 
Type: String  
Description: Whether or not to create a read-replica instance of the database. 
### DatabaseEncryptedBoolean 
Type: String  
Description: Indicates whether the DB instances in the cluster are encrypted. NOTE: if you select t2.micro as the instance type, then this must be set to 'false', as encryption at rest is unsupported for that instance type. 
### DatabaseCmk 
Type: String  
Description: The ARN of the AWS KMS Customer Master Key (CMK) to encrypt the database cluster. 
### DatabaseInstanceType 
Type: String 
Default: db.t2.micro 
Description: The Amazon RDS database instance class. Note, t2.small is the smallest instance type that supports encryption at rest. If you switch to t2.micro, you'll need to set encryption to "false" below. 
### DatabaseMasterUsername 
Type: String 
Default: root 
Description: The "root" user to configure for the Amazon RDS database. 
### DatabaseMasterPassword 
Type: String  
Description: The Amazon RDS "root" user password. If you wish to use a username other than "root", it can be configured below under AWS MySQL RDS Parameters. Must be between 8 and 41 characters, inclusive, in length; and, must be letters (upper or lower), numbers, and these special characters '_'`~!#$%^&*()_+,-" 
### DatabaseRestoreSnapshot 
Type: String  
Description: The snapshot name to restore from. 
### DataSubnet1Cidr 
Type: String 
Default: 10.0.100.0/24 
Description: CIDR block for data subnet 1 located in Availability Zone 1 
### DataSubnet2Cidr 
Type: String 
Default: 10.0.101.0/24 
Description: CIDR block for data subnet 2 located in Availability Zone 2 
### EC2KeyName 
Type: AWS::EC2::KeyPair::KeyName  
Description: Name of an EC2 KeyPair. Your bastion instances will launch with this KeyPair. 
### EnableBanner 
Type: String 
Default: true 
Description: To include a banner to be displayed when connecting via SSH to the bastion, set this parameter to true. 
### EnablePhpMyAdmin 
Type: String 
Default: False 
Description: Deploy an autoscaling group for phpMyAdmin database manager 
### NatEnvironmentVariables 
Type: String  
Description: Specify a comma separated list of environment variables for use in bootstrapping by the alternative initialization script. Variables must be in the format KEY=VALUE. VALUE cannot contain commas. 
### NatInstanceType 
Type: String 
Default: t3.nano 
Description: NAT EC2 instance type. NB: t3 instances have burstable CPU which is charged at an additional $0.05 per CPU hour. If you are running at max CPU utilization for an entire month, then m3.medium and c5.large are actually more cost effective. Keep an eye on your burst charges and adjust your instance type as necessary. 
### NumberOfAZs 
Type: Number 
Default: 2 
Description: Number of Availability Zones to use in the VPC. Currently must be exactly 2. 
### phpDnsName 
Type: String  
Description: The fully-qualified domain name for the phpMyAdmin server (e.g., phpmyadmin.example.com).  NB: This should be assigned to the application load balancer manually. It is used here to register as a target for the loadbalancer. 
### phpEnvironmentVariables 
Type: String  
Description: Specify a comma separated list of environment variables for use in bootstrapping by the alternative initialization script. Variables must be in the format KEY=VALUE. VALUE cannot contain commas. 
### phpInstanceType 
Type: String 
Default: t3.nano 
Description: phpMyAdmin EC2 instance type. 
### PublicAlbAcmCertificate 
Type: String  
Description: The AWS Certification Manager certificate ARN for the ALB certificate. This is only required if you enable either phpMyAdmin or Roundcube. This certificate should be created in the region you wish to run the ALB and must reference the domain names you wish to load balance. If you're using phpMyAdmin and www, for example, it should include both of those fully qualified domains. It is not used for termination of mail TLS connections. 
### PublicSubnet1Cidr 
Type: String 
Default: 10.0.200.0/24 
Description: CIDR block for Public subnet 1 located in Availability Zone 1 
### PublicSubnet2Cidr 
Type: String 
Default: 10.0.201.0/24 
Description: CIDR block for Public subnet 2 located in Availability Zone 2 
### S3BastionKeyPrefix 
Type: String 
Default: bastion/ 
Description: S3 key prefix for the Mirovoy CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### S3NatKeyPrefix 
Type: String 
Default: nat/ 
Description: S3 key prefix for the CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### S3PhpKeyPrefix 
Type: String 
Default: phpmyadmin/ 
Description: S3 key prefix for the CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### SshAccessCidr 
Type: String 
Default: 0.0.0.0/0 
Description: The CIDR IP range that is permitted to SSH to bastion instance. Note - a value of 0.0.0.0/0 will allow access from ANY IP address. 
### SkelFileDir 
Type: String 
Default: var/skel/ 
Description: Path under S3 prefix for shell configuration file to put in the alternate admin user's home dir, via /etc/skel/. Should end in a slash. 
### VpcCidr 
Type: String 
Default: 10.0.0.0/16 
Description: CIDR block for the VPC 
### VpcTenancy 
Type: String 
Default: default 
Description: The allowed tenancy of instances launched into the VPC 

## Resources
The list of resources this template creates:

### myvpc 
Type: AWS::CloudFormation::Stack  
### bastion 
Type: AWS::CloudFormation::Stack  
### nat 
Type: AWS::CloudFormation::Stack  
### phpmyadmin 
Type: AWS::CloudFormation::Stack  
### publicalb 
Type: AWS::CloudFormation::Stack  
### rds 
Type: AWS::CloudFormation::Stack  
### securitygroups 
Type: AWS::CloudFormation::Stack  

## Outputs
The list of outputs this template exposes:

### DatabaseStackName 
  

### MailSecurityGroup 
  

### PublicAlbListenerArn 
  

### StackName 
  

### VpcStackName 
  

### WebmailSecurityGroup 
  

