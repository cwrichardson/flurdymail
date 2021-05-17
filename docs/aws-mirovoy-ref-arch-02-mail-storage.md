# aws-mirovoy-ref-arch-02-mail-storage
# Description
Mirovoy Reference Architecture - Create mail storage This template creates EBS storage for the mail servers. it creates 2 volumes: one for /var/spool (actual mail) and one for /var/log. Optionally also creates volumes for swap, which we use as we don't have enough mail to justify a higher-end server.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### AvailabilityZone 
Type: List<AWS::EC2::AvailabilityZone::Name>  
Description: Availability Zone in which to place the EBS volumes 
### Cmk 
Type: String  
Description: The Amazon Resource Name (ARN) of an existing AWS KMS Customer Master Key (CMK) to encrypt EBS volumes. 
### CreateSwap 
Type: String 
Default: True 
Description: Create an encrypted Amazon EBS Volume 
### EncryptedBoolean 
Type: String 
Default: True 
Description: Create an encrypted Amazon EBS Volume 
### LogSize 
Type: Number 
Default: 2 
Description: Size (in GB) for device to mount on /var/log 
### LogSnapshot 
Type: String  
Description: The snapshot name from which to restore /var/log 
### LogDelPolicy 
Type: String 
Default: Delete 
Description: What to do with the log volumes when the stack is deleted. 
### SpoolDelPolicy 
Type: String 
Default: Retain 
Description: What to do with the spool volumes when the stack is deleted. 
### SpoolSize 
Type: Number 
Default: 10 
Description: Size (in GB) for device to mount on /var/spool 
### SpoolSnapshot 
Type: String  
Description: The snapshot name from which to restore /var/spool 
### SwapSize 
Type: Number 
Default: 2 
Description: Size (in GB) for device to mount on /var/spool 

## Resources
The list of resources this template creates:

### SpoolEBS 
Type: AWS::EC2::Volume  
### KeepSpoolEBS 
Type: AWS::EC2::Volume  
### DelSpoolEBS 
Type: AWS::EC2::Volume  
### LogEBS 
Type: AWS::EC2::Volume  
### KeepLogEBS 
Type: AWS::EC2::Volume  
### DelLogEBS 
Type: AWS::EC2::Volume  
### SwapEBS 
Type: AWS::EC2::Volume  

## Outputs
The list of outputs this template exposes:

### FormatSpool 
Description: Whether to reformat /var/spool when attaching to mail 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'FormatSpool']]}  

### FormatLog 
Description: Whether to reformat /var/log when attaching to mail 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'FormatLog']]}  

### StackName 
Description: The name of the stack 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'StackName']]}  

### SwapVolumesBoolean 
Description: Whether swap EBS volumes were created 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'SwapOn']]}  

### SpoolEBS 
Description: EBS Volume for mail files 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'SpoolEBS']]}  

### DelSpoolEBS 
Description: EBS Volume for mail files 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'SpoolEBS']]}  

### KeepSpoolEBS 
Description: EBS Volume for mail files 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'SpoolEBS']]}  

### LogEBS 
Description: EBS Volume for log files 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'LogEBS']]}  

### DelLogEBS 
Description: EBS Volume for log files 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'LogEBS']]}  

### KeepLogEBS 
Description: EBS Volume for log files 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'LogEBS']]}  

### Swap 
Description: EBS Volume for swap 
Export name: {'Fn::Join': [':', [{'Ref': 'AWS::StackName'}, 'SwapEBS']]}  

