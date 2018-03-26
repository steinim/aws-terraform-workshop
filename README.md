# aws-terraform-workshop

Provisioning AWS Infrastructure for Security and Continuous Delivery with Terraform and Elastic Beanstalk

In this workshop you will learn how to provision infrastructure in AWS using tools for automating everything. We will cover how to use Terraform for provisioning basic infrastructure on AWS, including VPCs, networking, security groups (firewall’ish) and deployment of applications on Elastic Beanstalk in an autoscaled and load balanced environment. We will also set up a hosted database and a bastion host (jump host) for connecting to servers inside your private subnet. As a bonus you will learn how to handle secrets when working in an environment built for continuous delivery.

Slides: https://steinim.github.io/slides/aws-terraform-workshop/

## Preparations

### Create a free new AWS account

Go to: https://aws.amazon.com/free and sign up for a free account.

Tip: If you already have an account and use gmail and want to make a new account for this workshop you can add +<something> before the @ in your email-address. Example: `john.doe+workshop@gmail.com`

### Secure your AWS Account

1. Go to: [https://console.aws.amazon.com/iam/](https://console.aws.amazon.com/iam/) `Users|Add user`
2. Check `Programmatic access` and `AWS Management Console access`
3. Attach `Administrator Access` to the user
4. Sign out of root account and sign in with the newly created user

### Add your ssh-key to you IAM user

Go to: https://console.aws.amazon.com/iam/home?region=eu-west-2#/users

1. Click on your newly created user
2. Go to Security Credentials and upload your SSH public key under **SSH keys for AWS CodeCommit** ```cat ~/.ssh/id_rsa.pub | pbcopy``` 

### Create you AWS API credentials

Go to: https://console.aws.amazon.com/iam/home?region=eu-west-2#/users

1. Click on your newly created user
2. Go to Security Credentials and press **Create access key**
3. Copy your credentials to a file or download the .csv file (NB! You will see your secret key only once)

### Install homebrew (OS X users only)
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
```
https://brew.sh/

### Store your AWS credentials and region to your keychain (OS X users only)
```bash
brew install envchain
envchain --set aws AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION
```

> Note: AWS_DEFAULT_REGION = eu-central-1

https://github.com/sorah/envchain

### Install `pass`
```bash
brew install pass
```
https://www.passwordstore.org/

#### Store your keys and region in pass
```bash
pass add AWS_ACCESS_KEY_ID
pass add AWS_SECRET_ACCESS_KEY
pass add AWS_DEFAULT_REGION
```

### Install Terraform
```bash
brew install terraform
```
https://www.terraform.io/intro/getting-started/install.html

### Install Terraform wrapper
https://github.com/nsbno/cloud-tools

#### Install Go

```bash
brew install go
```

Add the following to your `.bashrc`

```bash
export GOPATH=<path-to-your-sourcecode>/go
export GOBIN=$GOPATH/bin
PATH=$GOBIN:$PATH
export PATH
```

> Note: `path-to-your-sourcecode/go` should point to an empty folder you create to store your go code in.

#### Set up developer environment

```bash
source ~/.bashrc
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
pip install awscli awsebcli ansible
```

### Test it!

Run the following commands in a terraform base directory to check if it works.

```
envchain aws terraform get --update
envchain aws terraform init
envchain aws terraform-wrapper plan
```

