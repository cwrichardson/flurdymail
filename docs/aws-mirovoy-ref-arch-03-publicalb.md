# aws-mirovoy-ref-arch-03-publicalb
# Description
Mirovoy Reference Architecture - Public ALB - This template creates a public-facing application load balancer. in accordance with the Mirovoy Reference Architecture.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### NumberOfSubnets 
Type: String 
Default: 2 
Description: Number of subnets. This must match your selections in the list of subnets below. 
### PublicAlbAcmCertificate 
Type: String  
Description: [Optional] The AWS Certification Manager certificate ARN for the ALB certificate - this certificate should be created in the region you wish to run the ALB and must reference the domain names you wish to load balance. If you're using phpMyAdmin and www, for example, it should include both of those fully qualified domains. It is not used for termination of mail TLS connections. 
### PublicAlbSecurityGroup 
Type: AWS::EC2::SecurityGroup::Id  
Description: Select the ALB security group. 
### Subnet 
Type: List<AWS::EC2::Subnet::Id>  
Description: Select existing subnets. The number selected must match the number of subnets above. Subnets selected must be in separate AZs. 
### Vpc 
Type: AWS::EC2::VPC::Id  
Description: Select an existing Vpc 

## Resources
The list of resources this template creates:

### PublicAlbListenerNoSslCertificate 
Type: AWS::ElasticLoadBalancingV2::Listener  
### PublicAlbListenerHttpRedirect 
Type: AWS::ElasticLoadBalancingV2::Listener  
### PublicAlbListenerSslCertificate 
Type: AWS::ElasticLoadBalancingV2::Listener  
### PublicApplicationLoadBalancer 
Type: AWS::ElasticLoadBalancingV2::LoadBalancer  
### PublicAlbTargetGroup 
Type: AWS::ElasticLoadBalancingV2::TargetGroup  

## Outputs
The list of outputs this template exposes:

### PublicAlbHttpListenerNoSslCertificate 
  

### PublicAlbHttpsListener 
  

### PublicAlbTargetGroupArn 
  

### PublicAlbCanonicalHostedZoneId 
  

### PublicAlbDnsName 
  

### PublicAlbFullName 
  

### PublicAlbHostname 
  

### SslCertificate 
  

