# aws-mirovoy-ref-arch-05-roundcube
# Description
Mirovoy Reference Architecture - Roundcube Auto-Scaling Group - This template creates a Roundcube auto-scaling group in the Mirovoy VPC application subnets. By default the auto-scaling configuration is desired: 1, min: 0, max:1. Access to the server is via HTTPS through the Application Load Balancer.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AdminUser 
Type: String  
Description: An alternate account to be created on Roundcube instances with superuser permissions. 
### AdminPubKey 
Type: String  
Description: The public key text to be installed in the authorized_hosts file for the admin user. Will also be installed as an accepted key for the default admin user. 
### AllowFakeCert 
Type: String  
Description: Add the LetsEncrypt root and intermediate certificates for fake LetsEncrypt to the trusted CAs 
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
### CFAssetsBucket 
Type: String 
Default: mirovoy-cf-assets 
Description: S3 bucket name for the Mirovoy CloudFormation assets. 
### DatabaseStackName 
Type: String  
Description: The name of the stack that was used to create the RDS instances 
### DnsName 
Type: String  
Description: The fully-qualified domain name for the Roundcube server (e.g., webmail.example.com).  NB: This should be assigned to the application load balancer manually. It is used here to register as a target for the loadbalancer. 
### EC2KeyName 
Type: AWS::EC2::KeyPair::KeyName  
Description: Name of an EC2 KeyPair. Your Roundcube instances will launch with this KeyPair. 
### EnableDebug 
Type: String  
Description: Turn on verbose Roundcube debugging to syslog (goes to /var/log/messages). 
### EnvironmentVariables 
Type: String  
Description: Specify a comma separated list of environment variables for use in bootstrapping by the alternative initialization script. Variables must be in the format KEY=VALUE. VALUE cannot contain commas. 
### Hash 
Type: String 
Default: sha512-crypt 
Description: Hashing algorithm used when users change their password. If you're moving from an existing Flurdy installation, current passwords will be SHA256-CRYPT. Leaving this at SHA512-CRYPT will migrate users to the stronger encryption as they update their passwords. 
### MailDBName 
Type: String  
Description: The name of the mail database. Used to grant additional privileges on the mail database for the Roundcube usere, if password modification is enabled. 
### MailServerPrivateDNS 
Type: String  
Description: The _internal_ fully-qualified domain name for the primary mail server (e.g., ip-10-0-1-1.eu-central-1.compute.internal) 
### NumberOfSubnets 
Type: String 
Default: 2 
Description: Number of subnets. This must match your selections in the list of subnets below. You should select all Application subnets. 
### RoundcubeAMIOS 
Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id> 
Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
Description: AMI ID to use for the mail servers 
### RoundcubeDBUser 
Type: String 
Default: webmail 
Description: The MySQL username to have access to the roundcube database. 
### RoundcubeDBPass 
Type: String  
Description: The MySQL password for the roundcube-database user. 
### RoundcubeDBName 
Type: String 
Default: roundcube 
Description: The MySQL Roundcube database name. 
### RoundcubeInstanceType 
Type: String 
Default: t3.nano 
Description: Roundcube EC2 instance type. 
### RoundcubeSecurityGroup 
Type: AWS::EC2::SecurityGroup::Id  
Description: Select the Roundcube security group. 
### PublicAlbListenerArn 
Type: String  
Description: The public application load balancer listener's arn. 
### S3KeyPrefix 
Type: String 
Default: roundcube/ 
Description: S3 key prefix for the Mirovoy CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### SkelFileDir 
Type: String 
Default: var/skel/ 
Description: Path under S3 prefix for shell configuration file to put in the alternate admin user's home dir, via /etc/skel/. Should end in a slash. 
### Subnet 
Type: List<AWS::EC2::Subnet::Id>  
Description: Select existing subnets. The number selected must match the number of subnets above. Subnets selected must be in separate AZs. You should select all Application subnets. 
### UseLDAP 
Type: String  
Description: Use LDAP address books. Not yet working. 
### Vpc 
Type: AWS::EC2::VPC::Id  
Description: The Vpc Id of an existing Vpc. 

## Resources
The list of resources this template creates:

### RoundcubeAlbTargetGroup 
Type: AWS::ElasticLoadBalancingV2::TargetGroup  
### RoundcubeAlbListenerRule 
Type: AWS::ElasticLoadBalancingV2::ListenerRule  
### RoundcubeAutoScalingGroup 
Type: AWS::AutoScaling::AutoScalingGroup  
### RoundcubeHostRole 
Type: AWS::IAM::Role  
### RoundcubeHostPolicy 
Type: AWS::IAM::Policy  
### RoundcubeHostProfile 
Type: AWS::IAM::InstanceProfile  
### RoundcubeLaunchConfiguration 
Type: AWS::AutoScaling::LaunchConfiguration  

## Outputs
The list of outputs this template exposes:

