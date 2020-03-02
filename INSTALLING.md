# ForgeRock with EKS / AWS

Documentation available here:
<https://backstage.forgerock.com/docs/forgeops/6.5/eks-cookbook/>

## Infrastructure

This starts at Section ***2.5 Creating the Cluster***.
The installation of the plugin is not covered in the ForgeRock documentation:

```
$ pulumi plugin install resource aws v1.18.0
[resource plugin aws-1.18.0] installing
Downloading plugin: 59.41 MiB / 59.41 MiB [========================] 100.00% 38s
Moving plugin... done.
```

Bring up infrastructure. This does not include CloudFormation, EC2 instances or any stacks, it's mainly the VPCs, load balancers, etc.:

```
$ cd ~/Source/forgeops/cluster/pulumi/aws/infra
$ pulumi stack init aws-infra
Created stack 'aws-infra'
$ pulumi config set aws:region eu-west-1
$ pulumi up
Previewing update (aws-infra):
     Type                                    Name                                   Plan       
 +   pulumi:pulumi:Stack                     aws-infra-aws-infra                    create     
 +   ├─ awsx:lb:NetworkLoadBalancer          ExtIngressLB                           create     
 +   │  ├─ awsx:lb:NetworkTargetGroup        ExtIngressLBTCP80                      create     
 +   │  │  ├─ awsx:lb:NetworkListener        listener1                              create     
 +   │  │  │  └─ aws:lb:Listener             listener1                              create     
 +   │  │  └─ aws:lb:TargetGroup             ExtIngressLBTCP80                      create     
 +   │  ├─ awsx:lb:NetworkTargetGroup        ExtIngressLBTCP443                     create     
 +   │  │  ├─ awsx:lb:NetworkListener        listener2                              create     
 +   │  │  │  └─ aws:lb:Listener             listener2                              create     
 +   │  │  └─ aws:lb:TargetGroup             ExtIngressLBTCP443                     create     
 +   │  └─ aws:lb:LoadBalancer               ExtIngressLB                           create     
 +   ├─ aws:s3:Bucket                        eks-cdm                                create     
 +   ├─ awsx:x:ec2:Vpc                       eks-cdm                                create     
 +   │  ├─ awsx:x:ec2:NatGateway             eks-cdm-0                              create     
 +   │  │  ├─ aws:ec2:Eip                    eks-cdm-0                              create     
 +   │  │  └─ aws:ec2:NatGateway             eks-cdm-0                              create     
 +   │  ├─ awsx:x:ec2:NatGateway             eks-cdm-1                              create     
 +   │  │  ├─ aws:ec2:Eip                    eks-cdm-1                              create     
 +   │  │  └─ aws:ec2:NatGateway             eks-cdm-1                              create     
 +   │  ├─ awsx:x:ec2:NatGateway             eks-cdm-2                              create     
 +   │  │  ├─ aws:ec2:Eip                    eks-cdm-2                              create     
 +   │  │  └─ aws:ec2:NatGateway             eks-cdm-2                              create     
 +   │  ├─ awsx:x:ec2:InternetGateway        eks-cdm                                create     
 +   │  │  └─ aws:ec2:InternetGateway        eks-cdm                                create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-publicSubnet-public-0          create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-publicSubnet-public-0          create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-publicSubnet-public-0          create     
 +   │  │  ├─ aws:ec2:RouteTableAssociation  eks-cdm-publicSubnet-public-0          create     
 +   │  │  └─ aws:ec2:Route                  eks-cdm-publicSubnet-public-0-ig       create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-publicSubnet-public-1          create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-publicSubnet-public-1          create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-publicSubnet-public-1          create     
 +   │  │  ├─ aws:ec2:RouteTableAssociation  eks-cdm-publicSubnet-public-1          create     
 +   │  │  └─ aws:ec2:Route                  eks-cdm-publicSubnet-public-1-ig       create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-publicSubnet-public-2          create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-publicSubnet-public-2          create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-publicSubnet-public-2          create     
 +   │  │  ├─ aws:ec2:Route                  eks-cdm-publicSubnet-public-2-ig       create     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-publicSubnet-public-2          create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-privateSubnet-private-0        create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-privateSubnet-private-0        create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-privateSubnet-private-0        create     
 +   │  │  ├─ aws:ec2:RouteTableAssociation  eks-cdm-privateSubnet-private-0        create     
 +   │  │  └─ aws:ec2:Route                  eks-cdm-privateSubnet-private-0-nat-0  create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-privateSubnet-private-1        create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-privateSubnet-private-1        create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-privateSubnet-private-1        create     
 +   │  │  ├─ aws:ec2:RouteTableAssociation  eks-cdm-privateSubnet-private-1        create     
 +   │  │  └─ aws:ec2:Route                  eks-cdm-privateSubnet-private-1-nat-1  create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-privateSubnet-private-2        create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-privateSubnet-private-2        create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-privateSubnet-private-2        create     
 +   │  │  ├─ aws:ec2:RouteTableAssociation  eks-cdm-privateSubnet-private-2        create     
 +   │  │  └─ aws:ec2:Route                  eks-cdm-privateSubnet-private-2-nat-2  create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-0      create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-isolatedSubnet-isolated-0      create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-0      create     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-isolatedSubnet-isolated-0      create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-1      create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-1      create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-isolatedSubnet-isolated-1      create     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-isolatedSubnet-isolated-1      create     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-2      create     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-isolatedSubnet-isolated-2      create     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-2      create     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-isolatedSubnet-isolated-2      create     
 +   │  └─ aws:ec2:Vpc                       eks-cdm                                create     
 +   ├─ aws:iam:Role                         clusterAdministratorRole               create     
 +   └─ aws:s3:BucketPublicAccessBlock       blockPublicAccess                      create     
 
Resources:
    + 69 to create

Do you want to perform this update? details
+ pulumi:pulumi:Stack: (create)
    [urn=urn:pulumi:aws-infra::aws-infra::pulumi:pulumi:Stack::aws-infra-aws-infra]
    + awsx:lb:NetworkLoadBalancer: (create)
        [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer::ExtIngressLB]
    + aws:s3/bucket:Bucket: (create)
        [urn=urn:pulumi:aws-infra::aws-infra::aws:s3/bucket:Bucket::eks-cdm]
        [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
        acl         : "private"
        bucket      : "eks-cdm"
        forceDestroy: true
        versioning  : {
            enabled   : true
            mfaDelete : false
        }
    + awsx:x:ec2:Vpc: (create)
        [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc::eks-cdm]
    + aws:iam/role:Role: (create)
        [urn=urn:pulumi:aws-infra::aws-infra::aws:iam/role:Role::clusterAdministratorRole]
        [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
        assumeRolePolicy   : "{\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::693146231573:root\"},\"Sid\":\"AllowAssumeRole\"}],\"Version\":\"2012-10-17\"}"
        forceDetachPolicies: false
        maxSessionDuration : 3600
        name               : "clusterAdministratorRole-035455b"
        path               : "/"
        + awsx:lb:NetworkTargetGroup: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$awsx:lb:NetworkTargetGroup::ExtIngressLBTCP80]
        + awsx:lb:NetworkTargetGroup: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$awsx:lb:NetworkTargetGroup::ExtIngressLBTCP443]
        + awsx:x:ec2:NatGateway: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway::eks-cdm-0]
        + awsx:x:ec2:NatGateway: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway::eks-cdm-1]
        + awsx:x:ec2:NatGateway: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway::eks-cdm-2]
        + awsx:x:ec2:InternetGateway: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:InternetGateway::eks-cdm]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-publicSubnet-public-0]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-publicSubnet-public-1]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-publicSubnet-public-2]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-privateSubnet-private-0]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-privateSubnet-private-1]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-privateSubnet-private-2]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-isolatedSubnet-isolated-0]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-isolatedSubnet-isolated-1]
        + awsx:x:ec2:Subnet: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet::eks-cdm-isolatedSubnet-isolated-2]
        + aws:ec2/vpc:Vpc: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$aws:ec2/vpc:Vpc::eks-cdm]
            [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
            assignGeneratedIpv6CidrBlock: false
            cidrBlock                   : "192.168.0.0/16"
            enableDnsHostnames          : true
            enableDnsSupport            : true
            instanceTenancy             : "default"
            tags                        : {
                CreatedBy : "process.env.USER"
                Name      : "eks-cdm"
            }
    + aws:s3/bucketPublicAccessBlock:BucketPublicAccessBlock: (create)
        [urn=urn:pulumi:aws-infra::aws-infra::aws:s3/bucketPublicAccessBlock:BucketPublicAccessBlock::blockPublicAccess]
        [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
        blockPublicAcls      : true
        blockPublicPolicy    : true
        bucket               : output<string>
        ignorePublicAcls     : true
        restrictPublicBuckets: true
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-publicSubnet-public-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-isolatedSubnet-isolated-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1b"
                cidrBlock                  : "192.168.112.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : false
                tags                       : {
                    Name      : "eks-cdm-isolatedSubnet-isolated-1"
                    type      : "isolated"
                }
                vpcId                      : output<string>
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-privateSubnet-private-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1a"
                cidrBlock                  : "192.168.48.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : false
                tags                       : {
                    Name      : "eks-cdm-privateSubnet-private-0"
                    type      : "private"
                }
                vpcId                      : output<string>
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-privateSubnet-private-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + awsx:lb:NetworkListener: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$awsx:lb:NetworkTargetGroup$awsx:lb:NetworkListener::listener1]
            + aws:ec2/internetGateway:InternetGateway: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:InternetGateway$aws:ec2/internetGateway:InternetGateway::eks-cdm]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + aws:lb/targetGroup:TargetGroup: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$awsx:lb:NetworkTargetGroup$aws:lb/targetGroup:TargetGroup::ExtIngressLBTCP80]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                deregistrationDelay           : 300
                lambdaMultiValueHeadersEnabled: false
                name                          : "ExtIngressLBTCP80-022ed87"
                port                          : 30080
                protocol                      : "TCP"
                proxyProtocolV2               : false
                slowStart                     : 0
                tags                          : {
                    Name      : "ExtIngressLBTCP80"
                }
                targetType                    : "instance"
                vpcId                         : output<string>
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-privateSubnet-private-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-publicSubnet-public-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + awsx:lb:NetworkListener: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$awsx:lb:NetworkTargetGroup$awsx:lb:NetworkListener::listener2]
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-privateSubnet-private-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-publicSubnet-public-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-isolatedSubnet-isolated-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-publicSubnet-public-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1c"
                cidrBlock                  : "192.168.32.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : true
                tags                       : {
                    Name      : "eks-cdm-publicSubnet-public-2"
                    type      : "public"
                }
                vpcId                      : output<string>
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-privateSubnet-private-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1c"
                cidrBlock                  : "192.168.80.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : false
                tags                       : {
                    Name      : "eks-cdm-privateSubnet-private-2"
                    type      : "private"
                }
                vpcId                      : output<string>
            + aws:lb/targetGroup:TargetGroup: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$awsx:lb:NetworkTargetGroup$aws:lb/targetGroup:TargetGroup::ExtIngressLBTCP443]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                deregistrationDelay           : 300
                lambdaMultiValueHeadersEnabled: false
                name                          : "ExtIngressLBTCP443-6789155"
                port                          : 30443
                protocol                      : "TCP"
                proxyProtocolV2               : false
                slowStart                     : 0
                tags                          : {
                    Name      : "ExtIngressLBTCP443"
                }
                targetType                    : "instance"
                vpcId                         : output<string>
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-isolatedSubnet-isolated-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + aws:ec2/eip:Eip: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway$aws:ec2/eip:Eip::eks-cdm-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                tags      : {
                    Name      : "eks-cdm-0"
                }
                vpc       : true
            + aws:ec2/routeTable:RouteTable: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTable:RouteTable::eks-cdm-isolatedSubnet-isolated-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                vpcId     : output<string>
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-publicSubnet-public-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1a"
                cidrBlock                  : "192.168.0.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : true
                tags                       : {
                    Name      : "eks-cdm-publicSubnet-public-0"
                    type      : "public"
                }
                vpcId                      : output<string>
            + aws:ec2/eip:Eip: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway$aws:ec2/eip:Eip::eks-cdm-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                tags      : {
                    Name      : "eks-cdm-1"
                }
                vpc       : true
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-publicSubnet-public-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1b"
                cidrBlock                  : "192.168.16.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : true
                tags                       : {
                    Name      : "eks-cdm-publicSubnet-public-1"
                    type      : "public"
                }
                vpcId                      : output<string>
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-privateSubnet-private-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1b"
                cidrBlock                  : "192.168.64.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : false
                tags                       : {
                    Name      : "eks-cdm-privateSubnet-private-1"
                    type      : "private"
                }
                vpcId                      : output<string>
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-isolatedSubnet-isolated-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1c"
                cidrBlock                  : "192.168.128.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : false
                tags                       : {
                    Name      : "eks-cdm-isolatedSubnet-isolated-2"
                    type      : "isolated"
                }
                vpcId                      : output<string>
            + aws:ec2/eip:Eip: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway$aws:ec2/eip:Eip::eks-cdm-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                tags      : {
                    Name      : "eks-cdm-2"
                }
                vpc       : true
            + aws:ec2/subnet:Subnet: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/subnet:Subnet::eks-cdm-isolatedSubnet-isolated-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                assignIpv6AddressOnCreation: false
                availabilityZone           : "eu-west-1a"
                cidrBlock                  : "192.168.96.0/20"
                ipv6CidrBlock              : output<string>
                mapPublicIpOnLaunch        : false
                tags                       : {
                    Name      : "eks-cdm-isolatedSubnet-isolated-0"
                    type      : "isolated"
                }
                vpcId                      : output<string>
            + aws:ec2/route:Route: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/route:Route::eks-cdm-publicSubnet-public-2-ig]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                destinationCidrBlock: "0.0.0.0/0"
                gatewayId           : output<string>
                routeTableId        : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-privateSubnet-private-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-publicSubnet-public-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-publicSubnet-public-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/route:Route: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/route:Route::eks-cdm-publicSubnet-public-0-ig]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                destinationCidrBlock: "0.0.0.0/0"
                gatewayId           : output<string>
                routeTableId        : output<string>
            + aws:ec2/route:Route: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/route:Route::eks-cdm-publicSubnet-public-1-ig]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                destinationCidrBlock: "0.0.0.0/0"
                gatewayId           : output<string>
                routeTableId        : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-publicSubnet-public-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-privateSubnet-private-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-isolatedSubnet-isolated-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-isolatedSubnet-isolated-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-isolatedSubnet-isolated-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/routeTableAssociation:RouteTableAssociation: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/routeTableAssociation:RouteTableAssociation::eks-cdm-privateSubnet-private-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                routeTableId: output<string>
                subnetId    : output<string>
            + aws:ec2/natGateway:NatGateway: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway$aws:ec2/natGateway:NatGateway::eks-cdm-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                allocationId: output<string>
                subnetId    : output<string>
        + aws:lb/loadBalancer:LoadBalancer: (create)
            [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$aws:lb/loadBalancer:LoadBalancer::ExtIngressLB]
            [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
            enableCrossZoneLoadBalancing: true
            enableDeletionProtection    : false
            enableHttp2                 : true
            idleTimeout                 : 60
            internal                    : false
            loadBalancerType            : "network"
            name                        : "ExtIngressLB-8100f85"
            subnets                     : [
                [0]: output<string>
                [1]: output<string>
                [2]: output<string>
            ]
            tags                        : {
                Name      : "ExtIngressLB"
            }
            + aws:ec2/natGateway:NatGateway: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway$aws:ec2/natGateway:NatGateway::eks-cdm-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                allocationId: output<string>
                subnetId    : output<string>
            + aws:ec2/natGateway:NatGateway: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:NatGateway$aws:ec2/natGateway:NatGateway::eks-cdm-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                allocationId: output<string>
                subnetId    : output<string>
            + aws:ec2/route:Route: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/route:Route::eks-cdm-privateSubnet-private-1-nat-1]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                destinationCidrBlock: "0.0.0.0/0"
                natGatewayId        : output<string>
                routeTableId        : output<string>
            + aws:ec2/route:Route: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/route:Route::eks-cdm-privateSubnet-private-0-nat-0]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                destinationCidrBlock: "0.0.0.0/0"
                natGatewayId        : output<string>
                routeTableId        : output<string>
            + aws:ec2/route:Route: (create)
                [urn=urn:pulumi:aws-infra::aws-infra::awsx:x:ec2:Vpc$awsx:x:ec2:Subnet$aws:ec2/route:Route::eks-cdm-privateSubnet-private-2-nat-2]
                [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                destinationCidrBlock: "0.0.0.0/0"
                natGatewayId        : output<string>
                routeTableId        : output<string>
                + aws:lb/listener:Listener: (create)
                    [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$awsx:lb:NetworkTargetGroup$awsx:lb:NetworkListener$aws:lb/listener:Listener::listener1]
                    [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                    defaultActions : [
                        [0]: {
                            targetGroupArn: output<string>
                            type          : "forward"
                        }
                    ]
                    loadBalancerArn: output<string>
                    port           : 80
                    protocol       : "TCP"
                + aws:lb/listener:Listener: (create)
                    [urn=urn:pulumi:aws-infra::aws-infra::awsx:lb:NetworkLoadBalancer$awsx:lb:NetworkTargetGroup$awsx:lb:NetworkListener$aws:lb/listener:Listener::listener2]
                    [provider=urn:pulumi:aws-infra::aws-infra::pulumi:providers:aws::default_1_18_0::04da6b54-80e4-46f7-96ec-b56ff0331ba9]
                    defaultActions : [
                        [0]: {
                            targetGroupArn: output<string>
                            type          : "forward"
                        }
                    ]
                    loadBalancerArn: output<string>
                    port           : 443
                    protocol       : "TCP"

Do you want to perform this update? yes
Updating (aws-infra):
     Type                                    Name                                   Status      
 +   pulumi:pulumi:Stack                     aws-infra-aws-infra                    created     
 +   ├─ awsx:x:ec2:Vpc                       eks-cdm                                created     
 +   │  ├─ awsx:x:ec2:InternetGateway        eks-cdm                                created     
 +   │  │  └─ aws:ec2:InternetGateway        eks-cdm                                created     
 +   │  ├─ awsx:x:ec2:NatGateway             eks-cdm-2                              created     
 +   │  │  ├─ aws:ec2:Eip                    eks-cdm-2                              created     
 +   │  │  └─ aws:ec2:NatGateway             eks-cdm-2                              created     
 +   │  ├─ awsx:x:ec2:NatGateway             eks-cdm-1                              created     
 +   │  │  ├─ aws:ec2:Eip                    eks-cdm-1                              created     
 +   │  │  └─ aws:ec2:NatGateway             eks-cdm-1                              created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-2      created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-2      created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-isolatedSubnet-isolated-2      created     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-isolatedSubnet-isolated-2      created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-privateSubnet-private-0        created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-privateSubnet-private-0        created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-privateSubnet-private-0        created     
 +   │  │  ├─ aws:ec2:RouteTableAssociation  eks-cdm-privateSubnet-private-0        created     
 +   │  │  └─ aws:ec2:Route                  eks-cdm-privateSubnet-private-0-nat-0  created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-privateSubnet-private-1        created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-privateSubnet-private-1        created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-privateSubnet-private-1        created     
 +   │  │  ├─ aws:ec2:RouteTableAssociation  eks-cdm-privateSubnet-private-1        created     
 +   │  │  └─ aws:ec2:Route                  eks-cdm-privateSubnet-private-1-nat-1  created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-publicSubnet-public-1          created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-publicSubnet-public-1          created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-publicSubnet-public-1          created     
 +   │  │  ├─ aws:ec2:Route                  eks-cdm-publicSubnet-public-1-ig       created     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-publicSubnet-public-1          created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-publicSubnet-public-2          created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-publicSubnet-public-2          created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-publicSubnet-public-2          created     
 +   │  │  ├─ aws:ec2:Route                  eks-cdm-publicSubnet-public-2-ig       created     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-publicSubnet-public-2          created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-publicSubnet-public-0          created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-publicSubnet-public-0          created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-publicSubnet-public-0          created     
 +   │  │  ├─ aws:ec2:Route                  eks-cdm-publicSubnet-public-0-ig       created     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-publicSubnet-public-0          created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-privateSubnet-private-2        created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-privateSubnet-private-2        created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-privateSubnet-private-2        created     
 +   │  │  ├─ aws:ec2:RouteTableAssociation  eks-cdm-privateSubnet-private-2        created     
 +   │  │  └─ aws:ec2:Route                  eks-cdm-privateSubnet-private-2-nat-2  created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-0      created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-isolatedSubnet-isolated-0      created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-0      created     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-isolatedSubnet-isolated-0      created     
 +   │  ├─ awsx:x:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-1      created     
 +   │  │  ├─ aws:ec2:Subnet                 eks-cdm-isolatedSubnet-isolated-1      created     
 +   │  │  ├─ aws:ec2:RouteTable             eks-cdm-isolatedSubnet-isolated-1      created     
 +   │  │  └─ aws:ec2:RouteTableAssociation  eks-cdm-isolatedSubnet-isolated-1      created     
 +   │  ├─ awsx:x:ec2:NatGateway             eks-cdm-0                              created     
 +   │  │  ├─ aws:ec2:Eip                    eks-cdm-0                              created     
 +   │  │  └─ aws:ec2:NatGateway             eks-cdm-0                              created     
 +   │  └─ aws:ec2:Vpc                       eks-cdm                                created     
 +   ├─ aws:s3:Bucket                        eks-cdm                                created     
 +   ├─ awsx:lb:NetworkLoadBalancer          ExtIngressLB                           created     
 +   │  ├─ awsx:lb:NetworkTargetGroup        ExtIngressLBTCP80                      created     
 +   │  │  ├─ awsx:lb:NetworkListener        listener1                              created     
 +   │  │  │  └─ aws:lb:Listener             listener1                              created     
 +   │  │  └─ aws:lb:TargetGroup             ExtIngressLBTCP80                      created     
 +   │  ├─ awsx:lb:NetworkTargetGroup        ExtIngressLBTCP443                     created     
 +   │  │  ├─ awsx:lb:NetworkListener        listener2                              created     
 +   │  │  │  └─ aws:lb:Listener             listener2                              created     
 +   │  │  └─ aws:lb:TargetGroup             ExtIngressLBTCP443                     created     
 +   │  └─ aws:lb:LoadBalancer               ExtIngressLB                           created     
 +   ├─ aws:iam:Role                         clusterAdministratorRole               created     
 +   └─ aws:s3:BucketPublicAccessBlock       blockPublicAccess                      created     
 
Outputs:
    bastionEnable             : false
    bastionPublicIp           : "undefined"
    bastionSgId               : "undefined"
    clusterAdministratorRoleID: "clusterAdministratorRole-f7da254"
    extIngresstg443arn        : "arn:aws:elasticloadbalancing:eu-west-1:693146231573:targetgroup/ExtIngressLBTCP443-2619024/001a3c871a4912ef"
    extIngresstg80arn         : "arn:aws:elasticloadbalancing:eu-west-1:693146231573:targetgroup/ExtIngressLBTCP80-d1ce387/95263d1ccaadd6f9"
    highAvailability          : true
    loadBalancerDnsName       : "ExtIngressLB-725f50e-3d3646fd7cf18142.elb.eu-west-1.amazonaws.com"
    vpcAllSubnets             : [
        [0]: "subnet-0bf203e946d44a7f6"
        [1]: "subnet-09ad9f6fbc095f41d"
        [2]: "subnet-043b1bde8a0e7dab3"
        [3]: "subnet-06796690b9c9d67c8"
        [4]: "subnet-0d51b2f2e8c393a1e"
        [5]: "subnet-043d060a0e5869dc2"
        [6]: "subnet-05a7aacd41de6b063"
        [7]: "subnet-0f4404e3289dda870"
        [8]: "subnet-06828795086e81ddc"
    ]
    vpcCIDR                   : "192.168.0.0/16"
    vpcIsolatedSubnetsIds     : [
        [0]: "subnet-05a7aacd41de6b063"
        [1]: "subnet-0f4404e3289dda870"
        [2]: "subnet-06828795086e81ddc"
    ]
    vpcPrivateSubnetsIds      : [
        [0]: "subnet-0bf203e946d44a7f6"
        [1]: "subnet-09ad9f6fbc095f41d"
        [2]: "subnet-043b1bde8a0e7dab3"
    ]
    vpcPublicSubnetsIds       : [
        [0]: "subnet-06796690b9c9d67c8"
        [1]: "subnet-0d51b2f2e8c393a1e"
        [2]: "subnet-043d060a0e5869dc2"
    ]
    vpcid                     : "vpc-0953e9134958752e6"

Resources:
    + 69 created

Duration: 3m3s

Permalink: file:///home/martyn/.pulumi/stacks/aws-infra.json
```

## EKS clusters

Create small EKS cluster:

```
$ cd ~/Source/forgeops/cluster/pulumi/aws/eks
$ pulumi stack init eks-small
Created stack 'eks-small'
```

Add RSA key we generated as secret to access CDM:

```
$ pulumi config set --secret eks:pubKey < ~/.ssh/cdm-id-rsa.pub
```

Set AMIs to use for our region:

```
$ pulumi config set aws:region eu-west-1
$ pulumi config set dsnodes:ami ami-080af0c6edf8a81d7
$ pulumi config set frontendnodes:ami ami-080af0c6edf8a81d7
$ pulumi config set primarynodes:ami ami-080af0c6edf8a81d7
```

Make sure Kubernetes Pulumi plugin is installed before installing the EKS steps next:

```
$ npm install @pulumi/kubernetes

> @pulumi/kubernetes@1.5.6 install /home/martyn/Source/forgeops/cluster/pulumi/node_modules/@pulumi/kubernetes
> node scripts/install-pulumi-plugin.js resource kubernetes v1.5.6

[resource plugin kubernetes-1.5.6] installing
Downloading plugin: 19.92 MiB / 19.92 MiB [========================] 100.00% 15s
Moving plugin... done.
npm WARN typescript@ No repository field.
npm WARN typescript@ No license field.

+ @pulumi/kubernetes@1.5.6
added 1 package, updated 1 package and audited 4548 packages in 28.87s

14 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities
```

Bring EKS cluster up:

```
$ pulumi up
Previewing update (eks-small):
     Type                                                        Name                                                  Plan       
 +   pulumi:pulumi:Stack                                         eks-eks-small                                         create     
 +   ├─ aws:iam:Role                                             primarynodesRole                                      create     
 +   ├─ aws:iam:Role                                             dsnodesRole                                           create     
 +   ├─ eks:index:Cluster                                        eks-small                                             create     
 +   │  ├─ eks:index:ServiceRole                                 eks-small-eksRole                                     create     
 +   │  │  ├─ aws:iam:Role                                       eks-small-eksRole-role                                create     
 +   │  │  ├─ aws:iam:RolePolicyAttachment                       eks-small-eksRole-4b490823                            create     
 +   │  │  └─ aws:iam:RolePolicyAttachment                       eks-small-eksRole-90eb1c99                            create     
 +   │  ├─ aws:ec2:SecurityGroup                                 eks-small-eksClusterSecurityGroup                     create     
 +   │  ├─ aws:eks:Cluster                                       eks-small-eksCluster                                  create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksClusterInternetEgressRule                create     
 +   │  ├─ pulumi:providers:kubernetes                           eks-small-provider                                    create     
 +   │  ├─ pulumi:providers:kubernetes                           eks-small-eks-k8s                                     create     
 +   │  ├─ aws:ec2:SecurityGroup                                 eks-small-nodeSecurityGroup                           create     
 +   │  ├─ kubernetes:core:ConfigMap                             eks-small-nodeAccess                                  create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksNodeClusterIngressRule                   create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksExtApiServerClusterIngressRule           create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksNodeIngressRule                          create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksNodeInternetEgressRule                   create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksClusterIngressRule                       create     
 +   │  └─ pulumi-nodejs:dynamic:Resource                        eks-small-vpc-cni                                     create     
 +   ├─ aws:iam:RolePolicyAttachment                             primarynodesRole-policy-0                             create     
 +   ├─ aws:iam:InstanceProfile                                  primarynodesProfile                                   create     
 +   ├─ aws:iam:RolePolicyAttachment                             primarynodesRole-policy-2                             create     
 +   ├─ aws:iam:RolePolicyAttachment                             primarynodesRole-policy-1                             create     
 +   ├─ aws:iam:InstanceProfile                                  dsnodesProfile                                        create     
 +   ├─ aws:iam:RolePolicyAttachment                             dsnodesRole-policy-0                                  create     
 +   ├─ aws:iam:RolePolicyAttachment                             dsnodesRole-policy-1                                  create     
 +   ├─ aws:iam:RolePolicyAttachment                             dsnodesRole-policy-2                                  create     
 +   ├─ aws:iam:RolePolicyAttachment                             dsnodes-s3-policy                                     create     
 +   ├─ kubernetes:rbac.authorization.k8s.io:ClusterRole         clusterAdminRole                                      create     
 +   ├─ kubernetes:storage.k8s.io:StorageClass                   sc-nfs                                                create     
 +   ├─ kubernetes:rbac.authorization.k8s.io:ClusterRoleBinding  cluster-admin-binding                                 create     
 +   ├─ kubernetes:storage.k8s.io:StorageClass                   sc-fast10                                             create     
 +   ├─ kubernetes:storage.k8s.io:StorageClass                   sc-standard                                           create     
 +   ├─ kubernetes:storage.k8s.io:StorageClass                   sc-fast                                               create     
 +   ├─ eks:index:NodeGroup                                      dsnodesWorker                                         create     
 +   │  ├─ aws:ec2:SecurityGroup                                 dsnodesWorker-nodeSecurityGroup                       create     
 +   │  ├─ pulumi-nodejs:dynamic:Resource                        dsnodesWorker-cfnStackName                            create     
 +   │  ├─ aws:ec2:KeyPair                                       dsnodesWorker-keyPair                                 create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksNodeIngressRule                      create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksExtApiServerClusterIngressRule       create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksClusterIngressRule                   create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksNodeInternetEgressRule               create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksNodeClusterIngressRule               create     
 +   │  ├─ aws:ec2:LaunchConfiguration                           dsnodesWorker-nodeLaunchConfiguration                 create     
 +   │  └─ aws:cloudformation:Stack                              dsnodesWorker-nodes                                   create     
 +   ├─ kubernetes:core:Namespace                                prodNamespace                                         create     
 +   ├─ eks:index:NodeGroup                                      primarynodesWorker                                    create     
 +   │  ├─ pulumi-nodejs:dynamic:Resource                        primarynodesWorker-cfnStackName                       create     
 +   │  ├─ aws:ec2:KeyPair                                       primarynodesWorker-keyPair                            create     
 +   │  ├─ aws:ec2:SecurityGroup                                 primarynodesWorker-nodeSecurityGroup                  create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksNodeClusterIngressRule          create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksNodeIngressRule                 create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksExtApiServerClusterIngressRule  create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksNodeInternetEgressRule          create     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksClusterIngressRule              create     
 +   │  ├─ aws:ec2:LaunchConfiguration                           primarynodesWorker-nodeLaunchConfiguration            create     
 +   │  └─ aws:cloudformation:Stack                              primarynodesWorker-nodes                              create     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-ldaps                                              create     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-admin                                              create     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-https                                              create     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-All-Traffic                                        create     
 +   ├─ aws:ec2:SecurityGroupRule                                primarynodes30080                                     create     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-ldap                                               create     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-http                                               create     
 +   └─ aws:ec2:SecurityGroupRule                                primarynodes30443                                     create     
 
Resources:
    + 67 to create

Do you want to perform this update? yes
Updating (eks-small):
     Type                                                        Name                                                  Status      
 +   pulumi:pulumi:Stack                                         eks-eks-small                                         created     
 +   ├─ aws:iam:Role                                             primarynodesRole                                      created     
 +   ├─ aws:iam:Role                                             dsnodesRole                                           created     
 +   ├─ aws:iam:RolePolicyAttachment                             dsnodesRole-policy-2                                  created     
 +   ├─ aws:iam:RolePolicyAttachment                             dsnodesRole-policy-1                                  created     
 +   ├─ aws:iam:RolePolicyAttachment                             dsnodesRole-policy-0                                  created     
 +   ├─ aws:iam:InstanceProfile                                  dsnodesProfile                                        created     
 +   ├─ eks:index:Cluster                                        eks-small                                             created     
 +   │  ├─ eks:index:ServiceRole                                 eks-small-eksRole                                     created     
 +   │  │  ├─ aws:iam:Role                                       eks-small-eksRole-role                                created     
 +   │  │  ├─ aws:iam:RolePolicyAttachment                       eks-small-eksRole-90eb1c99                            created     
 +   │  │  └─ aws:iam:RolePolicyAttachment                       eks-small-eksRole-4b490823                            created     
 +   │  ├─ aws:ec2:SecurityGroup                                 eks-small-eksClusterSecurityGroup                     created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksClusterInternetEgressRule                created     
 +   │  ├─ aws:eks:Cluster                                       eks-small-eksCluster                                  created     
 +   │  ├─ aws:ec2:SecurityGroup                                 eks-small-nodeSecurityGroup                           created     
 +   │  ├─ pulumi:providers:kubernetes                           eks-small-eks-k8s                                     created     
 +   │  ├─ pulumi:providers:kubernetes                           eks-small-provider                                    created     
 +   │  ├─ kubernetes:core:ConfigMap                             eks-small-nodeAccess                                  created     
 +   │  ├─ pulumi-nodejs:dynamic:Resource                        eks-small-vpc-cni                                     created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksNodeIngressRule                          created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksNodeClusterIngressRule                   created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksExtApiServerClusterIngressRule           created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             eks-small-eksClusterIngressRule                       created     
 +   │  └─ aws:ec2:SecurityGroupRule                             eks-small-eksNodeInternetEgressRule                   created     
 +   ├─ aws:iam:InstanceProfile                                  primarynodesProfile                                   created     
 +   ├─ aws:iam:RolePolicyAttachment                             primarynodesRole-policy-2                             created     
 +   ├─ aws:iam:RolePolicyAttachment                             primarynodesRole-policy-1                             created     
 +   ├─ aws:iam:RolePolicyAttachment                             primarynodesRole-policy-0                             created     
 +   ├─ aws:iam:RolePolicyAttachment                             dsnodes-s3-policy                                     created     
 +   ├─ kubernetes:rbac.authorization.k8s.io:ClusterRoleBinding  cluster-admin-binding                                 created     
 +   ├─ kubernetes:storage.k8s.io:StorageClass                   sc-nfs                                                created     
 +   ├─ kubernetes:storage.k8s.io:StorageClass                   sc-standard                                           created     
 +   ├─ kubernetes:storage.k8s.io:StorageClass                   sc-fast                                               created     
 +   ├─ kubernetes:storage.k8s.io:StorageClass                   sc-fast10                                             created     
 +   ├─ kubernetes:rbac.authorization.k8s.io:ClusterRole         clusterAdminRole                                      created     
 +   ├─ eks:index:NodeGroup                                      primarynodesWorker                                    created     
 +   │  ├─ pulumi-nodejs:dynamic:Resource                        primarynodesWorker-cfnStackName                       created     
 +   │  ├─ aws:ec2:SecurityGroup                                 primarynodesWorker-nodeSecurityGroup                  created     
 +   │  ├─ aws:ec2:KeyPair                                       primarynodesWorker-keyPair                            created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksClusterIngressRule              created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksNodeInternetEgressRule          created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksExtApiServerClusterIngressRule  created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksNodeIngressRule                 created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             primarynodesWorker-eksNodeClusterIngressRule          created     
 +   │  ├─ aws:ec2:LaunchConfiguration                           primarynodesWorker-nodeLaunchConfiguration            created     
 +   │  └─ aws:cloudformation:Stack                              primarynodesWorker-nodes                              created     
 +   ├─ eks:index:NodeGroup                                      dsnodesWorker                                         created     
 +   │  ├─ pulumi-nodejs:dynamic:Resource                        dsnodesWorker-cfnStackName                            created     
 +   │  ├─ aws:ec2:KeyPair                                       dsnodesWorker-keyPair                                 created     
 +   │  ├─ aws:ec2:SecurityGroup                                 dsnodesWorker-nodeSecurityGroup                       created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksExtApiServerClusterIngressRule       created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksNodeIngressRule                      created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksNodeClusterIngressRule               created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksNodeInternetEgressRule               created     
 +   │  ├─ aws:ec2:SecurityGroupRule                             dsnodesWorker-eksClusterIngressRule                   created     
 +   │  ├─ aws:ec2:LaunchConfiguration                           dsnodesWorker-nodeLaunchConfiguration                 created     
 +   │  └─ aws:cloudformation:Stack                              dsnodesWorker-nodes                                   created     
 +   ├─ kubernetes:core:Namespace                                prodNamespace                                         created     
 +   ├─ aws:ec2:SecurityGroupRule                                primarynodes30443                                     created     
 +   ├─ aws:ec2:SecurityGroupRule                                primarynodes30080                                     created     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-ldap                                               created     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-https                                              created     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-admin                                              created     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-ldaps                                              created     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-http                                               created     
 +   ├─ aws:ec2:SecurityGroupRule                                DS-All-Traffic                                        created     
 +   ├─ aws:autoscaling:Attachment                               asgAttachment0                                        created     
 +   └─ aws:autoscaling:Attachment                               asgAttachment1                                        created     
 
Outputs:
    kubeconfig: {
        apiVersion     : "v1"
        clusters       : [
            [0]: {
                cluster: {
                    certificate-authority-data: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJd01ETXdNakUzTVRBeE5Wb1hEVE13TURJeU9ERTNNVEF4TlZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTlJDClIyRzVCNUZCT3czTFN0S1l6RXFXWEprbWVpazJqODY2U2FXaGhQK2NrWDlMTzBLWkJyNEphNXdBZERjY0JFUHoKcUhsTWVPMUVPcjNvRXRGaURxYVJzbUFQdmxIYUpXRmVZU1ZsZkM0cWtTQW9Nc0N0SEwxYUJPbVNLUmpKTmdmUwo3TDYyRU5GZlNjKzFkV1grS0VjQjZ5anZYVGRXSkN2UXZJSEh0azFvZ2d4NDNEZGF4b2JvcXV0WEVRbTR5ZDljCjBORDVMMHVvMHBGakJ6TFJ2bmpGTTh4b3RjNkxYTDBIVkJMV0g1bEh0TVh6VjJXbDYvb3U0eEFSMHA5VEdIaHMKdlR5RjUxUkhFTFc2eHpXcEpwR0xhc0lTZStDNW03bC9md29wSTlQYit5YzQvZlJSRlVleDB5VEhZQ3BtZE9nWQorNHNiVzdWNGd3bDRtQ0FsQ2c4Q0F3RUFBYU1qTUNFd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQkFLQ0hLUHFuMVN1OGlGZ1FNQ0txZjBSRDRLd1YKRE1hZ1pjcFFzMC9SUHR0RzFCblpxYXpLSkdqL2ZyVW81S0xJM0o0NHNHazRNTFRtV09ldkFWbDhTMUpqNWpaTgo5TFpJdXVKVGI0eDhPbTdLQ0poenpzaW1xdFVaWHgyZTdUYVJrUEpFbzhUc0lTSU1wbXdXRjVPQjVLelNqNm5WCi9URmxJV2ZIKzFLeUlCYS9aYTRKeDhCTlNBempIUWdJRUo4d2xSbWN1K2xKdjBZWWZ0Wlk3TUNCQlYrcHU0MXkKL002WW0xVUJrV0FQS3duWlczbGxMNnFYazVFVGFqdm9INS80OUJTd1lrelFPUVV6TmEwb1NCOGNuQytlSXFzOAozMHpMaUprWEJ4Q1JzRk44RUUxTWdpL096M0dPZWZoQ2FWWXdvSkxSS1RIZnR3dCtaQjEya0lXSXNoND0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
                    server                    : "https://2838F71FF1B46B30BF2C53D40B0CFE02.gr7.eu-west-1.eks.amazonaws.com"
                }
                name   : "kubernetes"
            }
        ]
        contexts       : [
            [0]: {
                context: {
                    cluster: "kubernetes"
                    user   : "aws"
                }
                name   : "aws"
            }
        ]
        current-context: "aws"
        kind           : "Config"
        users          : [
            [0]: {
                name: "aws"
                user: {
                    exec: {
                        apiVersion: "client.authentication.k8s.io/v1alpha1"
                        args      : [
                            [0]: "token"
                            [1]: "-i"
                            [2]: "eks-small-eksCluster-d0c8706"
                        ]
                        command   : "aws-iam-authenticator"
                    }
                }
            }
        ]
    }

Resources:
    + 69 created

Duration: 15m12s

Permalink: file:///home/martyn/.pulumi/stacks/eks-small.jso
```

Create Kubernetes config:

```
$ pulumi stack output kubeconfig > kubeconfig
$ export KUBECONFIG=$PWD/kubeconfig:$HOME/.kube/config
$ kubectx 
aws
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-48k8c             1/1     Running   0          58m
kube-system   aws-node-6v6c6             1/1     Running   0          58m
kube-system   aws-node-9j6g7             1/1     Running   0          58m
kube-system   aws-node-mfbhp             1/1     Running   0          58m
kube-system   aws-node-rtlzh             1/1     Running   0          58m
kube-system   aws-node-x6zgl             1/1     Running   0          58m
kube-system   coredns-5fd8748bdd-g9l99   1/1     Running   0          63m
kube-system   coredns-5fd8748bdd-h9skq   1/1     Running   0          63m
kube-system   kube-proxy-fz2qr           1/1     Running   0          58m
kube-system   kube-proxy-g5nlx           1/1     Running   0          58m
kube-system   kube-proxy-hw9z5           1/1     Running   0          58m
kube-system   kube-proxy-jxqlk           1/1     Running   0          58m
kube-system   kube-proxy-m6rq5           1/1     Running   0          58m
kube-system   kube-proxy-xgnqz           1/1     Running   0          58m
```
Now ready for deployment.

## Deployment

### Deploy ingress controller

Add repository:

```
$ helm repo list
Error: no repositories to show

$ helm repo add stable https://kubernetes-charts.storage.googleapis.com
"stable" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "stable" chart repository
Update Complete. ⎈ Happy Helming!⎈ 
```

Deploy controller:

```
$ ../../../../bin/ingress-controller-deploy.sh -e
namespace/nginx created
Release "nginx-ingress" does not exist. Installing it now.
NAME: nginx-ingress
LAST DEPLOYED: Wed Mar  4 09:26:56 2020
NAMESPACE: nginx
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace nginx get services -o wide -w nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls
```

Verify it's set up correctly:

```
$ kubectl get pods --namespace nginx
NAME                                             READY   STATUS    RESTARTS   AGE
nginx-ingress-controller-7gx88                   0/1     Running   0          13s
nginx-ingress-controller-jkthv                   0/1     Running   0          13s
nginx-ingress-controller-zmvkr                   0/1     Running   0          13s
nginx-ingress-default-backend-6b8dc9d88f-w4r8b   1/1     Running   0          13s

$ aws elbv2 describe-load-balancers | grep DNSName
            "DNSName": "ExtIngressLB-64cc68f-ffefcc91decc5df6.elb.eu-west-1.amazonaws.com", 
$ host ExtIngressLB-64cc68f-ffefcc91decc5df6.elb.eu-west-1.amazonaws.com
ExtIngressLB-64cc68f-ffefcc91decc5df6.elb.eu-west-1.amazonaws.com has address 52.49.31.214
ExtIngressLB-64cc68f-ffefcc91decc5df6.elb.eu-west-1.amazonaws.com has address 34.252.153.96
ExtIngressLB-64cc68f-ffefcc91decc5df6.elb.eu-west-1.amazonaws.com has address 52.16.159.163
```

### Deploy certificate manager

```
$ ../../../../bin/certmanager-deploy.sh
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created
namespace/cert-manager created
serviceaccount/cert-manager-cainjector created
serviceaccount/cert-manager created
serviceaccount/cert-manager-webhook created
clusterrole.rbac.authorization.k8s.io/cert-manager-cainjector created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-cainjector created
role.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-webhook:auth-delegator created
rolebinding.rbac.authorization.k8s.io/cert-manager-webhook:webhook-authentication-reader created
clusterrole.rbac.authorization.k8s.io/cert-manager-webhook:webhook-requester created
role.rbac.authorization.k8s.io/cert-manager:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager:leaderelection created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-issuers created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-certificates created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-orders created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-challenges created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-issuers created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-certificates created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-orders created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-challenges created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim created
clusterrole.rbac.authorization.k8s.io/cert-manager-view created
clusterrole.rbac.authorization.k8s.io/cert-manager-edit created
service/cert-manager created
service/cert-manager-webhook created
deployment.apps/cert-manager-cainjector created
deployment.apps/cert-manager created
deployment.apps/cert-manager-webhook created
mutatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
validatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
deployment.extensions/cert-manager-webhook condition met
clusterissuer.cert-manager.io/default-issuer created
secret/certmanager-ca-secret created
```

Verify it's set up correctly:

```
$ kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-5655447474-cdts2              1/1     Running   0          63s
cert-manager-cainjector-59c9dfd4f7-pl2zn   1/1     Running   0          63s
cert-manager-webhook-865b8fb666-z5krs      1/1     Running   0          63s
```

### Deploy monitoring tools 

```
$ ../../../../bin/prometheus-deploy.sh
namespace/monitoring created
"stable" has been added to your repositories
Release "prometheus-operator" does not exist. Installing it now.
manifest_sorter.go:175: info: skipping unknown hook: "crd-install"
manifest_sorter.go:175: info: skipping unknown hook: "crd-install"
manifest_sorter.go:175: info: skipping unknown hook: "crd-install"
manifest_sorter.go:175: info: skipping unknown hook: "crd-install"
manifest_sorter.go:175: info: skipping unknown hook: "crd-install"
manifest_sorter.go:175: info: skipping unknown hook: "crd-install"
NAME: prometheus-operator
LAST DEPLOYED: Wed Mar  4 09:30:31 2020
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus-operator"

Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com condition met
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com condition met
Release "forgerock-metrics" does not exist. Installing it now.
NAME: forgerock-metrics
LAST DEPLOYED: Wed Mar  4 09:31:28 2020
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Verify it's set up correctly:

```
$ kubectl get pods --namespace monitoring
NAME                                                      READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-operator-alertmanager-0           2/2     Running   0          42s
prometheus-operator-grafana-7487f4d545-jqbcc              2/2     Running   0          51s
prometheus-operator-kube-state-metrics-5549484497-q6jc4   1/1     Running   0          51s
prometheus-operator-operator-8cb9c6765-b25m2              2/2     Running   0          51s
prometheus-operator-prometheus-node-exporter-f5jrd        1/1     Running   0          51s
prometheus-operator-prometheus-node-exporter-f88d7        1/1     Running   0          51s
prometheus-operator-prometheus-node-exporter-fz8sn        1/1     Running   0          51s
prometheus-operator-prometheus-node-exporter-jpm67        1/1     Running   0          51s
prometheus-operator-prometheus-node-exporter-kwz4n        1/1     Running   0          51s
prometheus-operator-prometheus-node-exporter-srpck        1/1     Running   0          51s
prometheus-prometheus-operator-prometheus-0               3/3     Running   1          32s
```

### Set up local computer to push Docker Images

```
$ aws ecr get-login-password | docker login --username AWS --password-stdin 693146231573.dkr.ecr.eu-west-1.amazonaws.com
WARNING! Your password will be stored unencrypted in /home/martyn/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store
```

### Set up Skaffold

```
$ skaffold config set default-repo 693146231573.dkr.ecr.eu-west-1.amazonaws.com -k aws
set value default-repo to 693146231573.dkr.ecr.eu-west-1.amazonaws.com for context aws
```

### Deploying the CDM

#### Set Skaffold config

```
$ cd ~/Source/forgeops/bin/
$ ./config.sh init --profile cdk --version 6.5

removing idm configs from docker/6.5
cp -r config/6.5/cdk/idm docker/6.5

removing ig configs from docker/6.5
cp -r config/6.5/cdk/ig docker/6.5

removing amster configs from docker/6.5
cp -r config/6.5/cdk/amster docker/6.5
cp config/6.5/cdk/secrets/config/* docker/forgeops-secrets/forgeops-secrets-image/config

$ cd ..
```

#### Create ECR repos (if not already available)

**IMPORTANT:*** This is not covered in the Forgeops documentation but it's essential to guarantee the next steps work!

```
$ aws ecr create-repository --repository-name amster --region eu-west-1
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:eu-west-1:693146231573:repository/amster",
        "registryId": "693146231573",
        "repositoryName": "amster",
        "repositoryUri": "693146231573.dkr.ecr.eu-west-1.amazonaws.com/amster",
        "createdAt": "2020-03-05T12:00:43+00:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        }
    }
}

$ aws ecr create-repository --repository-name idm --region eu-west-1
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:eu-west-1:693146231573:repository/idm",
        "registryId": "693146231573",
        "repositoryName": "idm",
        "repositoryUri": "693146231573.dkr.ecr.eu-west-1.amazonaws.com/idm",
        "createdAt": "2020-03-05T12:01:16+00:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        }
    }
}

$ aws ecr create-repository --repository-name ds-cts --region eu-west-1
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:eu-west-1:693146231573:repository/ds-cts",
        "registryId": "693146231573",
        "repositoryName": "ds-cts",
        "repositoryUri": "693146231573.dkr.ecr.eu-west-1.amazonaws.com/ds-cts",
        "createdAt": "2020-03-05T12:01:29+00:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        }
    }
}

$ aws ecr create-repository --repository-name ds-idrepo --region eu-west-1
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:eu-west-1:693146231573:repository/ds-idrepo",
        "registryId": "693146231573",
        "repositoryName": "ds-idrepo",
        "repositoryUri": "693146231573.dkr.ecr.eu-west-1.amazonaws.com/ds-idrepo",
        "createdAt": "2020-03-05T12:01:37+00:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        }
    }
}

$ aws ecr create-repository --repository-name ig --region eu-west-1
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:eu-west-1:693146231573:repository/ig",
        "registryId": "693146231573",
        "repositoryName": "ig",
        "repositoryUri": "693146231573.dkr.ecr.eu-west-1.amazonaws.com/ig",
        "createdAt": "2020-03-05T12:01:47+00:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        }
    }
}

$ aws ecr create-repository --repository-name forgeops-secrets --region eu-west-1
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:eu-west-1:693146231573:repository/forgeops-secrets",
        "registryId": "693146231573",
        "repositoryName": "forgeops-secrets",
        "repositoryUri": "693146231573.dkr.ecr.eu-west-1.amazonaws.com/forgeops-secrets",
        "createdAt": "2020-03-05T12:02:03+00:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        }
    }
}
```

#### Run Skaffold

...

### Benchmarks

Get on DS for idrepo:

```
$ kubectl exec ds-idrepo-1 -it /bin/bash
```

Run searchrate test:

```
forgerock@ds-idrepo-1:~$ scripts/ds-bench.sh srch 60 localhost 10000000

Starting searchrate on ou=identities with a range of 10000000 random users...
Warming up for 10 seconds...
--------------------------------------------------------------------------------------------
|     Throughput    |                 Response Time                |       Additional      | 
|    (ops/second)   |                (milliseconds)                |       Statistics      | 
|   recent  average |   recent  average    99.9%   99.99%  99.999% |  err/sec Entries/Srch | 
--------------------------------------------------------------------------------------------
|  30940.0  30940.0 |   16.496   16.496   165.68   360.71   408.94 |      0.0          1.0 | 
|  10731.2  20835.6 |   47.726   24.539   149.95   358.61   408.94 |      0.0          1.0 | 
|   9947.0  17206.1 |   51.417   29.718   140.51   356.52   408.94 |      0.0          1.0 | 
|   9513.2  15282.9 |   53.814   33.468   127.93   354.42   402.65 |      0.0          1.0 | 
|   9459.6  14118.2 |   54.139   36.238   119.54   354.42   402.65 |      0.0          1.0 | 
|   9552.6  13357.3 |   53.583   38.305   119.01   352.32   400.56 |      0.0          1.0 | 
|   9656.2  12828.5 |   53.001   39.886   118.49   350.22   400.56 |      0.0          1.0 | 
|   9773.8  12446.7 |   52.400   41.114   120.59   350.22   400.56 |      0.0          1.0 | 
|   9892.2  12162.9 |   51.741   42.074   121.11   343.93   400.56 |      0.0          1.0 | 
|   9802.6  11926.8 |   52.242   42.910   131.60   333.45   400.56 |      0.0          1.0 | 
|   8434.8  11923.6 |   50.109   42.915   131.60   333.45   400.56 |      0.0          1.0 | 
```

Run modrate test:

```
forgerock@ds-idrepo-1:~$ scripts/ds-bench.sh mod 60 localhost 10000000
Starting modrate on ou=identities with a range of 10000000 random users...
-------------------------------------------------------------------------------
|     Throughput    |                 Response Time                |          | 
|    (ops/second)   |                (milliseconds)                |          | 
|   recent  average |   recent  average    99.9%   99.99%  99.999% |  err/sec | 
-------------------------------------------------------------------------------
|   2432.4   2432.4 |    3.214    3.214    20.84   113.25   113.77 |      0.0 | 
|   3449.6   2941.0 |    2.303    2.679    19.01   112.72   113.77 |      0.0 | 
|   4042.2   3308.1 |    1.966    2.389    18.87   147.85   161.48 |      0.0 | 
|   4727.6   3663.0 |    1.680    2.160    17.30   146.80   149.95 |      0.0 | 
|   5498.2   4030.0 |    1.442    1.964    17.04   146.80   149.95 |      0.0 | 
|   6244.6   4399.1 |    1.270    1.800    16.65   143.65   149.95 |      0.0 | 
|   6560.6   4707.9 |    1.209    1.682    16.91   143.65   149.95 |      0.0 | 
|   6469.6   4928.1 |    1.205    1.604    16.32   141.56   149.95 |      0.0 | 
|   4712.2   4904.1 |    1.715    1.616    16.12   143.65  1526.73 |      0.0 | 
|   6679.4   5081.6 |    1.184    1.559    15.73   143.65  1526.73 |      0.0 | 
|   6810.0   5238.8 |    1.167    1.513    15.47   139.46  1526.73 |      0.0 | 
|   6979.4   5383.8 |    1.135    1.472    15.01   138.41  1526.73 |      0.0 | 
|    666.7   5383.6 |    1.420    1.472    15.01   138.41  1526.73 |      0.0 | 
```

Run addrate test:

```
forgerock@ds-idrepo-1:~$ scripts/ds-bench.sh add 60 localhost 10000000
Generating userstore template...

Starting addrate on ou=identities...
--------------------------------------------------------------------------------------
|     Throughput    |                 Response Time                |    Additional   | 
|    (ops/second)   |                (milliseconds)                |    Statistics   | 
|   recent  average |   recent  average    99.9%   99.99%  99.999% |  err/sec   Add% | 
--------------------------------------------------------------------------------------
|     95.6     95.6 |   82.437   82.437   161.48   161.48   161.48 |      0.0 100.00 | 
|    130.8    113.2 |   60.649   69.849   161.48   161.48   161.48 |      0.0 100.00 | 
|    173.4    133.3 |   46.328   59.648   157.29   161.48   161.48 |      0.0 100.00 | 
|    211.6    152.9 |   37.812   52.091   153.09   161.48   161.48 |      0.0 100.00 | 
|    265.6    175.4 |   30.074   45.423   150.99   161.48   161.48 |      0.0 100.00 | 
|    258.8    189.3 |   30.835   42.099   268.44   293.60   293.60 |      0.0 100.00 | 
|    329.4    209.3 |   24.218   38.079   212.86   293.60   293.60 |      0.0 100.00 | 
|    222.0    210.9 |   35.974   37.802   293.60  1593.84  1602.22 |      0.0 100.00 | 
|    394.4    231.3 |   20.238   34.474   285.21  1593.84  1602.22 |      0.0 100.00 | 
|    420.4    250.2 |   18.902   31.858   281.02  1593.84  1602.22 |      0.0 100.00 | 
|    443.0    267.7 |   18.085   29.786   212.86  1593.84  1602.22 |      0.0 100.00 | 
|    480.8    285.5 |   16.619   27.938   174.06  1593.84  1602.22 |      0.0 100.00 | 
|    486.5    285.6 |   15.504   27.925   174.06  1593.84  1602.22 |      0.0 100.00 | 
Purge phase...
Purge in progress:  2980/17147 entries deleted (595.8 ops/sec). ETA 00:00:23
Purge in progress:  5514/17147 entries deleted (588.7 ops/sec). ETA 00:00:19
Purge in progress:  8609/17147 entries deleted (591.1 ops/sec). ETA 00:00:14
Purge in progress: 12219/17147 entries deleted (601.5 ops/sec). ETA 00:00:08
Purge in progress: 15921/17147 entries deleted (612.7 ops/sec). ETA 00:00:02
```
