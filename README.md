# experts-demo

DevOps CI/CD Demo

- VPC Setup with Terraform (S3 and DynamoDB Backend for State Management)
- Bastion AMI Creation with Packer
- Bastion Creation with ASG and ELB
- Jenkins Master AMI Creation with Packer
- Jenkins Slave AMI Creation with Packer
- Jenkins Master EC2 Instance Creation behind ELB
- Jenkins Slave ASG Creation


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

# Jenkins Master AMI

- Create a Jenkins admin user.
- Create a SSH, GitHub and Docker registry credentials.
- Install all needed plugins (Pipeline, Git plugin, Multi-branch Project, etc).
- Disable remote CLI, JNLP and unnecessary protocols.
- Enable CSRF (Cross Site Request Forgery) protection.
- Install Telegraf agent for collecting resource and Docker metrics.

```
...
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "Tool": "Packer"
    amazon-ebs: Adding tag: "Author": "nchotai"
...
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-west-1: ami-02f0ab57de408ad58
```

# Jenkins Slave AMI

```
...
==> amazon-ebs: Creating AMI tags
    amazon-ebs: Adding tag: "Tool": "Packer"
    amazon-ebs: Adding tag: "Author": "nchotai"
...
==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
eu-west-1: ami-0e5c63056e6299d31
```