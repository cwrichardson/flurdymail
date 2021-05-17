# aws-mirovoy-ref-arch-04-php-my-admin
# Description
Mirovoy Reference Architecture - phpMyAdmin Auto-Scaling Group - This template creates a phpMyAdmin auto-scaling group in the Mirovoy VPC application subnets. By default the auto-scaling configuration is desired: 0, min: 0, max:1. Access to the server is via HTTPS through the Application Load Balancer.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AdminUser 
Type: String  
Description: An alternate account to be created on phpMyAdmin instances with superuser permissions. 
### AdminPubKey 
Type: String  
Description: The public key text to be installed in the authorized_hosts file for the admin user. Will also be installed as an accepted key for the default admin user. 
### AlternativeIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the server. If left blank, a new role will be created. 
### AlternativeInitializationScript 
Type: String  
Description: Specify an alternative initialization script to run during setup. 
### BlowfishSecret 
Type: String  
Description: phpmyadmin uses this to encrypt the password stored in the cookie. From the docs: The “cookie” auth_type uses AES algorithm to encrypt the password. If you are using the “cookie” auth_type, enter here a random passphrase of your choice. It will be used internally by the AES algorithm: you won’t be prompted for this passphrase.
The secret should be 32 characters long. Using shorter will lead to weaker security of encrypted cookies, using longer will cause no harm. 
### CFAssetsBucket 
Type: String 
Default: mirovoy-cf-assets 
Description: S3 bucket name for the Mirovoy CloudFormation assets. 
### DnsName 
Type: String  
Description: The fully-qualified domain name for the phpMyAdmin server (e.g., phpmyadmin.example.com).  NB: This should be assigned to the application load balancer manually. It is used here to register as a target for the loadbalancer. 
### EC2KeyName 
Type: AWS::EC2::KeyPair::KeyName  
Description: Name of an EC2 KeyPair. Your phpMyAdmin instances will launch with this KeyPair. 
### EnvironmentVariables 
Type: String  
Description: Specify a comma separated list of environment variables for use in bootstrapping by the alternative initialization script. Variables must be in the format KEY=VALUE. VALUE cannot contain commas. 
### NumberOfSubnets 
Type: String 
Default: 2 
Description: Number of subnets. This must match your selections in the list of subnets below. You should select all Application subnets. 
### phpAMIOS 
Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id> 
Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
Description: AMI ID to use for the mail servers 
### phpInstanceType 
Type: String 
Default: t3.nano 
Description: phpMyAdmin EC2 instance type. 
### phpSecurityGroup 
Type: AWS::EC2::SecurityGroup::Id  
Description: Select the phpMyAdmin security group. 
### PublicAlbListenerArn 
Type: String  
Description: The public application load balancer listener's arn. 
### RDSAddress 
Type: String  
Description: The internal DNS name or IP address of the primary database server. 
### S3KeyPrefix 
Type: String 
Default: phpmyadmin/ 
Description: S3 key prefix for the Mirovoy CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### SkelFileDir 
Type: String 
Default: var/skel/ 
Description: Path under S3 prefix for shell configuration file to put in the alternate admin user's home dir, via /etc/skel/. Should end in a slash. 
### Subnet 
Type: List<AWS::EC2::Subnet::Id>  
Description: Select existing subnets. The number selected must match the number of subnets above. Subnets selected must be in separate AZs. You should select all Application subnets. 
### Vpc 
Type: AWS::EC2::VPC::Id  
Description: The Vpc Id of an existing Vpc. 

## Resources
The list of resources this template creates:

### phpMyAdminAlbTargetGroup 
Type: AWS::ElasticLoadBalancingV2::TargetGroup  
### phpMyAdminAlbListenerRule 
Type: AWS::ElasticLoadBalancingV2::ListenerRule  
### phpAutoScalingGroup 
Type: AWS::AutoScaling::AutoScalingGroup  
### phpHostRole 
Type: AWS::IAM::Role  
### phpHostPolicy 
Type: AWS::IAM::Policy  
### phpHostProfile 
Type: AWS::IAM::InstanceProfile  
### phpLaunchConfiguration 
Type: AWS::AutoScaling::LaunchConfiguration  

## Outputs
The list of outputs this template exposes:

