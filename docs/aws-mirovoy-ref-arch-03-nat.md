# aws-mirovoy-ref-arch-03-nat
# Description
Mirovoy Reference Architecture - NAT - This template creates an autoscaling group of NAT instances. These instances reside in the public subnet(s) and provide address translation for the application subnets, so apps can reach the internet from the otherwise private subnet in which they reside.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### NumberOfAZs 
Type: Number 
Default: 2 
Description: Number of Availability Zones to use from the VPC. You MUST select the same number of subnets in each of Application Subnets and Public Subnets, below, as you select here. Currently, the only valid choice is 2. 
### AdminUser 
Type: String  
Description: An alternate account to be created on NAT instances with superuser permissions. 
### AdminPubKey 
Type: String  
Description: The public key text to be installed in the authorized_hosts file for the admin user. Will also be installed as an accepted key for the default admin user. 
### AlternativeIAMRole 
Type: String  
Description: Specify an existing IAM Role name to attach to the NAT instances.  If left blank, a new role will be created. 
### AlternativeInitializationScript 
Type: String  
Description: URL for an alternative initialization script to run during setup. By default, during startup the instances will look in the S3 configuration below and run .../<prefix/>scripts/nat_bootstrap.sh. This should be the full URL to an alternative script. 
### AppSubnet 
Type: List<AWS::EC2::Subnet::Id>  
Description: Select existing subnets. The number selected must match the number of availability zones above. Subnets selected must be in separate AZs. 
### CFAssetsBucket 
Type: String 
Default: mirovoy-cf-assets 
Description: S3 bucket name for the CloudFormation assets. If you look at an S3 URL, it would be "https://<asset-bucke>.s3-<region>.amazonaws.com". 
### EC2KeyName 
Type: AWS::EC2::KeyPair::KeyName  
Description: Name of an EC2 KeyPair. Your NAT instances will launch with this KeyPair. 
### EnvironmentVariables 
Type: String  
Description: Specify a comma separated list of environment variables for use in bootstrapping. Variables must be in the format KEY=VALUE. VALUE cannot contain commas. 
### NatAMIOS 
Type: AWS::SSM::Parameter::Value<AWS::EC2::Image::Id> 
Default: /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 
Description: AMI ID to use for the NAT instances 
### NatInstanceType 
Type: String 
Default: t3.nano 
Description: NAT EC2 instance type. NB: t3 instances have burstable CPU which is charged at an additional $0.05 per CPU hour. If you are running at max CPU utilization for an entire month, then m3.medium and c5.large are actually more cost effective. Keep an eye on your burst charges and adjust your instance type as necessary. 
### NatSecurityGroup 
Type: AWS::EC2::SecurityGroup::Id  
Description: Select the NAT security group. 
### PublicSubnet 
Type: List<AWS::EC2::Subnet::Id>  
Description: Select existing subnets. The number selected must match the number of availability zones above. Subnets selected must be in separate AZs. 
### S3KeyPrefix 
Type: String 
Default: nat/ 
Description: S3 key prefix for the CloudFormation assets. This should be the top-level directory path inside the bucket, leading to the assets for this template (e.g., scripts directory, etc... are located) 
### SkelFileDir 
Type: String 
Default: var/skel/ 
Description: Path under S3 prefix for shell configuration file to put in the alternate admin user's home dir, via /etc/skel/. Should end in a slash. 

## Resources
The list of resources this template creates:

### NatAutoScalingGroup 
Type: AWS::AutoScaling::AutoScalingGroup  
### NatHostRole 
Type: AWS::IAM::Role  
### NatHostPolicy 
Type: AWS::IAM::Policy  
### NatHostProfile 
Type: AWS::IAM::InstanceProfile  
### NatLaunchConfiguration 
Type: AWS::AutoScaling::LaunchConfiguration  

## Outputs
The list of outputs this template exposes:

