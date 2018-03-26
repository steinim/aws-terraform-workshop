# aws-terraform-workshop

**Provisioning AWS Infrastructure for Security and Continuous Delivery with Terraform and Elastic Beanstalk**

In this workshop you will learn how to provision infrastructure in AWS using tools for automating everything. We will cover how to use Terraform for provisioning basic infrastructure on AWS, including VPCs, networking, security groups (firewall'ish) and deployment of applications on Elastic Beanstalk in an autoscaled and load balanced environment. We will also set up a hosted database and a bastion host (jump host) for connecting to servers inside your private subnet. As a bonus you will learn how to handle secrets when working in an environment built for continuous delivery.

Slides: https://steinim.github.io/slides/aws-terraform-workshop/

## Preparations

### Create a free new AWS account

Go to: https://aws.amazon.com/free and sign up for a free account.

**Tip**: If you already have an account and use gmail and want to make a new account for this workshop you can add +<something> before the @ in your email-address. Example: `john.doe+workshop@gmail.com`

### Secure your AWS Account

1. Go to: [https://console.aws.amazon.com/iam/](https://console.aws.amazon.com/iam/) `Users|Add user`
2. Check `Programmatic access` and `AWS Management Console access`
3. Attach `Administrator Access` to the user
4. Sign out of root account and sign in with the newly created user

### Add your ssh-key to you IAM user

Go to: https://console.aws.amazon.com/iam/home?region=eu-west-2#/users

1. Click on your newly created user
2. Go to `Security Credentials` and upload your SSH public key under `SSH keys for AWS CodeCommit`
```
cat ~/.ssh/id_rsa.pub | pbcopy
``` 

### Create your AWS API credentials

Go to: https://console.aws.amazon.com/iam/home?region=eu-west-2#/users

1. Click on your newly created user
2. Go to `Security Credentials` and press `Create access key`
3. Copy your credentials to a file or download the .csv file (**NB!** You will only see your secret key once)

### Install homebrew (OS X users only)
https://brew.sh/
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
```

### Store your AWS credentials and region to your keychain (OS X users only)
```
brew install envchain
envchain --set aws AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION
```

> Note: AWS_DEFAULT_REGION = eu-west-2

https://github.com/sorah/envchain

### Install `gpg`
https://gnupg.org/

```
brew install gpg
```

### Install `pass`
https://www.passwordstore.org/

```
echo 'export PASSWORD_STORE_DIR=~/.password-store' >> ~/.bashrc
. ~/.bashrc
brew install pass
```

#### Configure `pass`
```
gpg --full-generate-key # Accept all defaults
gpg --list-secret-keys --keyid-format LONG
```

From the list of GPG keys, copy the GPG key ID you'd like to use. In this example, the GPG key ID is `3AA5C34371567BD2`:
```
gpg --list-secret-keys --keyid-format LONG

sec   4096R/3AA5C34371567BD2 2016-03-10 [expires: 2017-03-10]
uid                          Hubot
ssb   4096R/42B317FD4BA89E7A 2016-03-10
```

Paste the text below, substituting in the GPG key ID you'd like to use. In this example, the GPG key ID is `3AA5C34371567BD2`:
```
pass init 3AA5C34371567BD2
```

#### Store your keys and region in pass
```
pass add AWS_ACCESS_KEY_ID
pass add AWS_SECRET_ACCESS_KEY
pass add AWS_DEFAULT_REGION
```

#### Test it!
```
pass show AWS_DEFAULT_REGION
```

### Install Terraform
https://www.terraform.io/intro/getting-started/install.html

```
brew install terraform
```

### Install Terraform wrapper
https://github.com/nsbno/cloud-tools

#### Install Go
```
brew install go
```

Add the following to your `.bashrc`

```
export GOPATH=<path-to-your-sourcecode>/go
export GOBIN=$GOPATH/bin
PATH=$GOBIN:$PATH
export PATH
```

> Note: `path-to-your-sourcecode/go` should point to an empty folder you create to store your go code in.

#### Set up developer environment

```
. ~/.bashrc
mkdir -p $GOPATH/{bin,pkg,src/github.com/nsbno,vendor}
go get github.com/nsbno/cloud-tools # Ignore the warning message
cd $GOPATH/src/github.com/nsbno/cloud-tools
./deps.sh
./make.sh
```

### Install additional tools

```
brew install s3cmd
sudo easy_install pip
pip install awscli awsebcli
```

# Task 1
In this task we will initialize the Terraform environment and run our first plan

```
git checkout start
```

1. Go to `infrastructure/test`

2. Create a s3 bucket for you remote state
```
envchain aws s3cmd --region eu-west-2 mb s3://<unique-bucket-name>
```

3. Create the following files
```
# backend.tf
terraform {
  backend "s3" {
    bucket = "<unique-bucket-name>"
    key    = "infrastructure/test/terraform.tfstate"
    region = "eu-west-2"
  }
}
```

```
# main.tf
provider "aws" {
  region = "${var.region}"
}
```

```
# vars.tf
variable "region" { default = "eu-west-2" }
```

4. Initialize the backend
```
envchain aws terraform init
```

(You may have to wait a while for the S3 bucket to become available)

5. Create the following file
```
# cloud-config.yml
vars:
  - name: TF_VAR_env
    value: test
```

6. Plan
```
envchain aws terraform-wrapper plan
```

## Solution:

```
git checkout task1
```

# Task 2
In this task we will create a VPC


