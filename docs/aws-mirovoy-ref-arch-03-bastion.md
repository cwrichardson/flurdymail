# aws-mirovoy-ref-arch-03-bastion
# Description
Mirovoy Reference Architecture - Bastion Auto-Scaling Group This template creates a bastion auto-scaling group in the Mirovoy VPC public subnets. By default the auto-scaling configuration is desired: 0, min: 0, max:1. Cross reference with the security groups configuraiton which controls access to the bastion hosts.

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
Description: The public key text to be installed in the authorized_hosts file for the admin user. Will also be installed as an accepted key for the default admin user. 
### AlternativeIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the bastion. If left blank, a new role will be created. 
### AlternativeInitializationScript 
Type: String  
Description: Specify an alternative initialization script to run during setup. 
### BastionBanner 
Type: String 
Default: var/banner_message.txt 
Description: Path and file under S3 prefix for Banner text to display upon login. Should not start with a "/". 
### BastionSecurityGroup 
Type: AWS::EC2::SecurityGroup::Id  
Description: Select the bastion security group. 
### BastionAMIOS 
Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id> 
Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
Description: AMI ID to use for the mail servers 
### BastionInstanceType 
Type: String 
Default: t3.nano 
Description: Bastion EC2 instance type. 
### CFAssetsBucket 
Type: String 
Default: mirovoy-cf-assets 
Description: S3 bucket name for the Mirovoy CloudFormation assets. 
### EC2KeyName 
Type: AWS::EC2::KeyPair::KeyName  
Description: Name of an EC2 KeyPair. Your bastion instances will launch with this KeyPair. 
### EnableBanner 
Type: String 
Default: false 
Description: To include a banner to be displayed when connecting via SSH to the bastion, set this parameter to true. 
### EnvironmentVariables 
Type: String  
Description: Specify a comma separated list of environment variables for use in bootstrapping by the alternative initialization script. Variables must be in the format KEY=VALUE. VALUE cannot contain commas. 
### NumberOfSubnets 
Type: String 
Default: 2 
Description: Number of subnets. This must match your selections in the list of subnets below. You should select all Public subnets. 
### S3KeyPrefix 
Type: String 
Default: bastion/ 
Description: S3 key prefix for the Mirovoy CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### SkelFileDir 
Type: String 
Default: var/skel/ 
Description: Path under S3 prefix for shell configuration file to put in the alternate admin user's home dir, via /etc/skel/. Should end in a slash. 
### Subnet 
Type: List<AWS::EC2::Subnet::Id>  
Description: Select existing subnets. The number selected must match the number of subnets above. Subnets selected must be in separate AZs. You should select all Public subnets. 

## Resources
The list of resources this template creates:

### BastionAutoScalingGroup 
Type: AWS::AutoScaling::AutoScalingGroup  
### BastionHostRole 
Type: AWS::IAM::Role  
### BastionHostPolicy 
Type: AWS::IAM::Policy  
### BastionHostProfile 
Type: AWS::IAM::InstanceProfile  
### BastionLaunchConfiguration 
Type: AWS::AutoScaling::LaunchConfiguration  

## Outputs
The list of outputs this template exposes:

