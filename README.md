# experts-demo

DevOps CI/CD Demo

- VPC Setup with Terraform (S3 and DynamoDB Backend for State Management)
- Jenkins AMI Creation with Packer
- Jenkins Master EC2 Instance Creation

# Architecture

![JenkinsArchitecture](readme_images/jenkins-architecture.png)

# Prerequisite

[Configuring the AWS CLI - AWS Command Line Interface](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

# Creating Setup

```bash
./setup.sh
```

# Destroying Setup

```bash
./destroy.sh
```

# Jenkins AMI

```
...
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "Tool": "Packer"
    amazon-ebs: Adding tag: "Author": "nchotai"
...
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-west-1: ami-0fc1d54f3e6867f97
```
