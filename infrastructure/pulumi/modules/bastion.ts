import * as aws from "@pulumi/aws";
import * as pulumi from "@pulumi/pulumi";

export function createBastion(
  nodeConfig: any,
  region: string,
  account_id: string,
  amis: any,
  cidr_block: string,
  vpc: pulumi.Output<string>,
  subnet: pulumi.Output<string>,
  security_groups: any,
  user_data?: string,
  tags?: object
) {
  // Security Groups
  const bastionSecurityGroup = new aws.ec2.SecurityGroup(
    "bastionSecurityGroup",
    {
      description: "Allow SSH Ingress",
      vpcId: vpc,
      tags: Object.assign({}, tags, {
        Name: nodeConfig.name,
      }),
    }
  );

  // Bastion Security Group Stuffs
  for (let k of security_groups["ingress"]) {
    // Define expected values
    let cidrBlocks: string[] = [""];
    let fromPort: number = 0;
    let toPort: number = 0;

    // Check Port Logic
    if (!k.port) {
      fromPort = k.port_start;
      toPort = k.port_end;
    } else {
      fromPort = k.port;
      toPort = k.port;
    }

    // Check CIDR Block Logic
    if (!k.cidr_blocks) {
      cidrBlocks = [cidr_block];
    } else {
      cidrBlocks = k.cidr_blocks;
    }

    // Create and associate the Security Group Rules
    new aws.ec2.SecurityGroupRule(`bastion-${k.description}`, {
      type: "ingress",
      fromPort: fromPort,
      toPort: toPort,
      protocol: k.protocol,
      cidrBlocks: cidrBlocks,
      securityGroupId: bastionSecurityGroup.id,
    });
  }

  // Egress Security Group Rules
  for (let k of security_groups["egress"]) {
    // Create and associate the Security Group Rules
    new aws.ec2.SecurityGroupRule(`bastion-${k.description}`, {
      type: "egress",
      fromPort: k.port,
      toPort: k.port,
      protocol: k.protocol,
      cidrBlocks: k.cidr_blocks,
      securityGroupId: bastionSecurityGroup.id,
    });
  }

  const bastionNodePolicy = new aws.iam.Policy("bastionNodePolicy", {
    path: "/",
    description: "Policy for Bastion",
    policy: JSON.stringify({
      Version: "2012-10-17",
      Statement: [
        {
          Sid: "VisualEditor0",
          Effect: "Allow",
          Action: "ecr:GetAuthorizationToken",
          Resource: "*",
        },
        {
          Sid: "VisualEditor1",
          Effect: "Allow",
          Action: [
            "ecr:ListImages",
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer",
          ],
          Resource: [
            `arn:aws:ecr:${region}:${account_id}:repository/homelab-provisioning`,
          ],
        },
        {
          Sid: "VisualEditor2",
          Effect: "Allow",
          Action: [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey",
            "kms:GenerateDataKeyWithoutPlaintext",
            "kms:DescribeKey",
          ],
          Resource: [
            `arn:aws:kms:${region}:${account_id}:key/7e829b85-6fed-4598-b675-8ebeea105c4c`,
          ],
        },
      ],
    }),
  });

  // Create Bastion IAM Role
  const bastionNodeRole = new aws.iam.Role("bastionNodeRole", {
    assumeRolePolicy: JSON.stringify({
      Version: "2012-10-17",
      Statement: [
        {
          Action: "sts:AssumeRole",
          Effect: "Allow",
          Sid: "",
          Principal: {
            Service: "ec2.amazonaws.com",
          },
        },
      ],
    }),
    tags: Object.assign({}, tags, { Name: "bastion-node-role" }),
  });

  // Associcate Bastion IAM to Role
  new aws.iam.RolePolicyAttachment("bastionPolicyAttachment", {
    role: bastionNodeRole.name,
    policyArn: bastionNodePolicy.arn,
  });

  // Create the IAM Instance Profile
  const bastionIamInstanceProfile = new aws.iam.InstanceProfile(
    "bastionInstanceProfile",
    { role: bastionNodeRole.name }
  );

  // Bastion Compute Node
  const bastion = new aws.ec2.Instance("bastion", {
    ami: amis[region][`bastion_${nodeConfig.arch}`],
    instanceType: nodeConfig.instance_size,

    // Networking
    subnetId: subnet,
    sourceDestCheck: false,
    privateIp: nodeConfig.privateIp,
    vpcSecurityGroupIds: [bastionSecurityGroup.id],
    privateDnsNameOptions: {
      enableResourceNameDnsARecord: true,
      hostnameType: "resource-name",
    },

    // Storage
    rootBlockDevice: {
      deleteOnTermination: true,
      volumeType: nodeConfig.root_volume_type,
      volumeSize: nodeConfig.root_volume_size,
    },

    // IAM Instance Profile
    iamInstanceProfile: bastionIamInstanceProfile.name,

    // Cloud-Init - SSH Load
    userData: user_data,

    // Instance Metadata
    metadataOptions: {
      httpPutResponseHopLimit: 4,
      httpEndpoint: "enabled",
    },

    // Tags
    tags: Object.assign({}, tags, {
      Name: nodeConfig.name,
    }),
    volumeTags: Object.assign({}, tags, {
      Name: nodeConfig.name,
    }),
  });

  return {
    publicIp: bastion.publicIp,
    privateIp: bastion.privateIp,
  };
}
