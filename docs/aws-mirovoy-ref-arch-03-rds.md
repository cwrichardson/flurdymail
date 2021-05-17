# aws-mirovoy-ref-arch-03-rds
# Description
Mirovoy Reference Architecture - Launch RDS This template creates a MySQL database, and optionally a read-replica copy in an alternative availability zone.

## Contents
- [Parameters](#parameters)
- [Resources](#resources)
- [Outputs](#outputs)

## Parameters
The list of parameters for this template:

### DatabaseEncryptedBoolean 
Type: String 
Default: True 
Description: Indicates whether the DB instances in the cluster are encrypted. NOTE: if you select t2.micro as the instance type, then this must be set to 'false', as encryption at rest is unsupported for that instance type. 
### DatabaseCmk 
Type: String  
Description: AWS KMS Customer Master Key (CMK) to encrypt database cluster 
### DatabaseInstanceType 
Type: String 
Default: db.t2.medium 
Description: The Amazon RDS database instance class. 
### DatabaseMasterUsername 
Type: String 
Default: root 
Description: The "root" user to configure for the Amazon RDS database. 
### DatabaseMasterPassword 
Type: String  
Description: The Amazon RDS "root" user password 
### DatabaseRestoreSnapshot 
Type: String  
Description: The snapshot name to restore from. 
### DatabaseSecurityGroup 
Type: AWS::EC2::SecurityGroup::Id  
Description: Select the database security group. 
### CreateReplica 
Type: String 
Default: True 
Description: Whether or not to create a read-replica instance of the database. 
### NumberOfSubnets 
Type: String 
Default: 2 
Description: Number of subnets. This must match your selections in the list of subnets below. Currently the only valid choice is 2. 
### Subnet 
Type: List<AWS::EC2::Subnet::Id>  
Description: Select existing subnets. The number selected must match the number of subnets above. Subnets selected must be in separate AZs. 

## Resources
The list of resources this template creates:

### MasterDB 
Type: AWS::RDS::DBInstance  
### ReadReplicaDB 
Type: AWS::RDS::DBInstance  
### DataSubnetGroup 
Type: AWS::RDS::DBSubnetGroup  
### DataSecretStrings 
Type: AWS::SecretsManager::Secret  

## Outputs
The list of outputs this template exposes:

### DatabaseInstance0 
  

### DatabaseInstance1 
  

### DataSubnetGroup 
  

### MasterDatabaseEndpointAddress 
 
Export name: {'Fn::Sub': '${AWS::StackName}-MasterDBEndpoint'}  

### ReadReplicaEndpointAddress 
 
Export name: {'Fn::Sub': '${AWS::StackName}-ReplicaDBEndpoint'}  

### StackName 
  

