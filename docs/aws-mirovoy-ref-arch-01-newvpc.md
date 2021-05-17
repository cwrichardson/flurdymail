# aws-mirovoy-ref-arch-01-newvpc
# Description
Mirovoy Reference Architecture — VPC — This template creates three subnets in each of two availability zones, in accordance with the Mirovoy Reference Architecture. Each AZ will have two private subnets — one for applications and one for data — and a public AZ.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AvailabilityZones 
Type: List<AWS::EC2::AvailabilityZone::Name>  
Description: List of Availability Zones to use for the subnets in the VPC. Note: The logical order is preserved. 
### NumberOfAZs 
Type: Number 
Default: 2 
Description: Number of Availability Zones to use in the VPC. Currently must be exactly 2. 
### VpcCidr 
Type: String 
Default: 10.0.0.0/16 
Description: CIDR block for the VPC 
### VpcTenancy 
Type: String 
Default: default 
Description: The allowed tenancy of instances launched into the VPC 
### DataSubnet1Cidr 
Type: String 
Default: 10.0.100.0/24 
Description: CIDR block for data subnet 1 located in Availability Zone 1 
### DataSubnet2Cidr 
Type: String 
Default: 10.0.101.0/24 
Description: CIDR block for data subnet 2 located in Availability Zone 2 
### PublicSubnet1Cidr 
Type: String 
Default: 10.0.200.0/24 
Description: CIDR block for Public subnet 1 located in Availability Zone 1 
### PublicSubnet2Cidr 
Type: String 
Default: 10.0.201.0/24 
Description: CIDR block for Public subnet 2 located in Availability Zone 2 
### AppSubnet1Cidr 
Type: String 
Default: 10.0.4.0/22 
Description: CIDR block for App subnet 1 located in Availability Zone 1 
### AppSubnet2Cidr 
Type: String 
Default: 10.0.8.0/22 
Description: CIDR block for App subnet 2 located in Availability Zone 2 

## Resources
The list of resources this template creates:

### AppSubnet1 
Type: AWS::EC2::Subnet  
### AppSubnet2 
Type: AWS::EC2::Subnet  
### AppSubnetRouteTableAssociation1 
Type: AWS::EC2::SubnetRouteTableAssociation  
### AppSubnetRouteTableAssociation2 
Type: AWS::EC2::SubnetRouteTableAssociation  
### NatRouteTable1 
Type: AWS::EC2::RouteTable  
### NatRouteTable2 
Type: AWS::EC2::RouteTable  
### DataSubnet1 
Type: AWS::EC2::Subnet  
### DataSubnet2 
Type: AWS::EC2::Subnet  
### InternetGateway 
Type: AWS::EC2::InternetGateway  
### AttachInternetGateway 
Type: AWS::EC2::VPCGatewayAttachment  
### PublicRoute 
Type: AWS::EC2::Route  
### PublicRouteTable 
Type: AWS::EC2::RouteTable  
### PublicRouteTableAssociation1 
Type: AWS::EC2::SubnetRouteTableAssociation  
### PublicRouteTableAssociation2 
Type: AWS::EC2::SubnetRouteTableAssociation  
### PublicSubnet1 
Type: AWS::EC2::Subnet  
### PublicSubnet2 
Type: AWS::EC2::Subnet  
### Vpc 
Type: AWS::EC2::VPC  
### VpcFlowLog 
Type: AWS::EC2::FlowLog  
### VpcFlowLogsLogGroup 
Type: AWS::Logs::LogGroup  
### VpcFlowLogsRole 
Type: AWS::IAM::Role  

## Outputs
The list of outputs this template exposes:

### AppSubnet 
 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'AppSubnet']]}  

### AppSubnet1 
  

### AppSubnet1Cidr 
Description: CIDR block for Application Subnet 1, for use in security groups 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'AppSubnet1Cidr']]}  

### AppSubnet2 
  

### AppSubnet2Cidr 
Description: CIDR block for Application Subnet 2, for use in security groups 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'AppSubnet2Cidr']]}  

### DataSubnet 
  

### DataSubnet1 
  

### DataSubnet2 
  

### DefaultSecGroup 
Description: Default security group for the VPC 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'DefaultSecGroup']]}  

### PublicSubnet 
  

### PublicSubnet1 
 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'PublicSubnet1']]}  

### PublicSubnet2 
 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'PublicSubnet2']]}  

### StackName 
  

### Vpc 
 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'Vpc']]}  

### VpcCidr 
  

