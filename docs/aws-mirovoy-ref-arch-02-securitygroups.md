# aws-mirovoy-ref-arch-02-securitygroups
# Description
Mirovoy Reference Architecture - Create Security Groups This template creates the security groups to secure the Mirovoy Reference Architecture.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AppSubnet1Cidr 
Type: String 
Default: 10.0.4.0/22 
Description: CIDR block for App subnet 1 located in Availability Zone 1. NAT instances in Public Availability Zone 1 will accept connections on ports 80 and 443 from this CIDR block. 
### AppSubnet2Cidr 
Type: String 
Default: 10.0.8.0/22 
Description: CIDR block for App subnet 1 located in Availability Zone 1. NAT instances in Public Availability Zone 1 will accept connections on ports 80 and 443 from this CIDR block. 
### CreateMailSecGroup 
Type: String 
Default: True 
Description: Create a security group for use by mail servers 
### CreateWebMailSecGroup 
Type: String 
Default: True 
Description: Create a security group for use by webmail servers 
### SshAccessCidr 
Type: String 
Default: 0.0.0.0/0 
Description: The CIDR IP range that is permitted to SSH to bastion instance. Note - a value of 0.0.0.0/0 will allow access from ANY IP address. 
### Vpc 
Type: AWS::EC2::VPC::Id  
Description: The Vpc Id of an existing Vpc. 

## Resources
The list of resources this template creates:

### BastionSecurityGroup 
Type: AWS::EC2::SecurityGroup  
### phpMyAdminSecurityGroup 
Type: AWS::EC2::SecurityGroup  
### PublicAlbSecurityGroup 
Type: AWS::EC2::SecurityGroup  
### NatSecurityGroup 
Type: AWS::EC2::SecurityGroup  
### NatSecurityGroupIngress2port80 
Type: AWS::EC2::SecurityGroupIngress  
### NatSecurityGroupIngress2port443 
Type: AWS::EC2::SecurityGroupIngress  
### DatabaseSecurityGroup 
Type: AWS::EC2::SecurityGroup  
### DatabaseSecurityGroupIngressApp2 
Type: AWS::EC2::SecurityGroupIngress  
### DatabaseSecurityGroupIngressMail 
Type: AWS::EC2::SecurityGroupIngress  
### MailSecurityGroup 
Type: AWS::EC2::SecurityGroup  
### WebmailSecurityGroup 
Type: AWS::EC2::SecurityGroup  

## Outputs
The list of outputs this template exposes:

### BastionSecurityGroup 
Description: Security group for jump/bastion servers  

### DatabaseSecurityGroup 
Description: Security group for RDS database access  

### MailSecurityGroup 
Description: Security group for MX servers  

### NatSecurityGroup 
Description: Security group for NAT instances  

### phpMyAdminSecurityGroup 
  

### PublicAlbSecurityGroup 
Description: Security group for the public load balancer  

### WebmailSecurityGroup 
Description: Security group for webmail servers  

