import { Duration, Stack, StackProps } from 'aws-cdk-lib';
import * as cdk from 'aws-cdk-lib/core';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as sns from 'aws-cdk-lib/aws-sns';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';
import { Construct } from 'constructs';

export class GolnazResourcesStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create VPC
    const vpc = new ec2.Vpc(this, 'GolnazVPC', {
      cidr: '10.30.0.0/16',
      maxAzs: 3 // Specify the number of availability zones you want to use
    });

    // Create EC2 instance in a public subnet
    const instance = new ec2.Instance(this, 'GolnazEC2', {
      vpc,
      instanceType: ec2.InstanceType.of(ec2.InstanceClass.T2, ec2.InstanceSize.MICRO),
      machineImage: new ec2.AmazonLinuxImage(),
      vpcSubnets: {
        subnetType: ec2.SubnetType.PUBLIC
      }
      // Add other instance configuration as needed
    });

    // Create SQS Queue
    const queue = new sqs.Queue(this, 'GolnazQueue', {
      visibilityTimeout: cdk.Duration.seconds(300) // Adjust as needed
    });

    // Create SNS Topic
    const topic = new sns.Topic(this, 'GolnazTopic');

    // Create AWS Secrets Manager Secret
    const secret = new secretsmanager.Secret(this, 'GolnazSecret', {
      secretName: 'metrodb-secrets',
      generateSecretString: {
        secretStringTemplate: JSON.stringify({ username: '', password: '' }),
        excludePunctuation: true,
        includeSpace: false,
        generateStringKey: 'password',
        passwordLength: 12 // Adjust password length as needed
      }
    });

    // Output the ARNs of created resources
    new cdk.CfnOutput(this, 'VPCId', { value: vpc.vpcId });
    new cdk.CfnOutput(this, 'EC2InstanceId', { value: instance.instanceId });
    new cdk.CfnOutput(this, 'QueueUrl', { value: queue.queueUrl });
    new cdk.CfnOutput(this, 'TopicArn', { value: topic.topicArn });
    new cdk.CfnOutput(this, 'SecretName', { value: secret.secretName });
  }
}
