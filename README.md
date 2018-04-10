# aws-terraform-workshop

**Provisioning AWS Infrastructure for Security and Continuous Delivery with Terraform and Elastic Beanstalk**

In this workshop you will learn how to provision infrastructure in AWS using tools for automating everything. We will cover how to use Terraform for provisioning basic infrastructure on AWS, including VPCs, networking, security groups (firewall'ish) and deployment of applications on Elastic Beanstalk in an autoscaled and load balanced environment. We will also set up a hosted database and a bastion host (jump host) for connecting to servers inside your private subnet. As a bonus you will learn how to handle secrets when working in an environment built for continuous delivery.

Slides: https://steinim.github.io/slides/aws-terraform-workshop/

## Preparations

### Required
Mac OSX (preferable) or Linux. If you have a Windows machine, please set up a Linux virtual machine. You can use [Vagrant](https://www.vagrantup.com/) for this.

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
# OSX. Others see: https://gnupg.org/download/
brew install gpg
```

### Install `pass`
https://www.passwordstore.org/

```
echo 'export PASSWORD_STORE_DIR=~/.password-store' >> ~/.bashrc
. ~/.bashrc

# OSX. Others see: https://www.passwordstore.org/
brew install pass
echo "source /usr/local/etc/bash_completion.d/pass" >> ~/.bashrc
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
# OSX. Others see: https://www.terraform.io/intro/getting-started/install.html
brew install terraform
```

### Install Terraform wrapper
https://github.com/nsbno/cloud-tools

#### Install Go
```
# OSX. Others see: https://golang.org/doc/install#install
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
brew install s3cmd # OSX. Others see: https://tecadmin.net/install-s3cmd-manage-amazon-s3-buckets/
sudo easy_install pip # You may have to install Python, easy_install and pip
pip install awscli awsebcli
```

# Task 1 - Getting started
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
variable "region" {}
variable "env" {}
```

4. Initialize the backend
```
envchain aws terraform init # OSX
../../env.sh terraform init # Linux
```

(You may have to wait a while for the S3 bucket to become available)

5. Create the following file
```
# cloud-config.yml
vars:
  - name: TF_VAR_env
    value: test
  - name: TF_VAR_region
    value: eu-west-2
```

6. Plan
```
envchain aws terraform-wrapper plan # OSX
../../env.sh terraform-wrapper plan # Linux
```

## Solution:

```
git checkout task1
```

# Task 2 - VPC
In this task we will create a VPC, an internet gateway and grant the VPC internet access on its main route table.

<p>
<details>
<summary><strong>VPC module</strong> `infrastructure/modules/vpc/`</summary>

```
# main.tf
resource "aws_vpc" "vpc" {
    cidr_block           = "${var.vpc_cidr}"
    enable_dns_hostnames = "${var.enable_dns_hostnames}"
    tags { Name = "${var.vpc_name}" }
}

# Create an internet gateway
resource "aws_internet_gateway" "ig" {
    vpc_id = "${aws_vpc.vpc.id}"
    tags { Name = "${var.ig_name}" }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access_route" {
  route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "${var.route_destination_cidr_block}"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

---

# vars.tf
variable "aws_region" {}
variable "vpc_name" {}
variable "enable_dns_hostnames" { default = "true" }
variable "ig_name" {}
variable "vpc_cidr" {}
variable "route_destination_cidr_block" { default = "0.0.0.0/0" }

```
</details>
</p>

<p>
<details>
<summary><strong>VPC project</strong> `infrastructure/test/`</summary>

```
# main.tf
---
module "vpc" {
  source     = "../modules/vpc"
  aws_region = "${var.region}"
  vpc_name   = "${var.env}_vpc"
  vpc_cidr   = "10.0.0.0/16"
  ig_name    = "${var.env}_ig"
}
```
</details>
</p>

## Update modules
```
envchain aws terraform get --update # OSX
../../env.sh terraform get --update # Linux

```
## Plan and apply

```
# OSX
envchain aws terraform-wrapper plan
envchain aws terraform-wrapper apply
# Linux
../../env.sh terraform-wrapper plan
../../env.sh terraform-wrapper apply

```

## Solution:

```
git checkout task2
```

# Task 3 - Networking
In this task we will set up software defined networking (SDN) with subnets, route tables, internet gateway and NAT.

## Modules

<p>
<details>
<summary><strong>Subnets</strong> `infrastructure/modules/subnet/`</summary>
  
```
# main.tf
resource "aws_subnet" "subnet" {
  vpc_id                  = "${var.vpc_id}"
  count                   = "${var.number_of_subnets}"
  cidr_block              = "${lookup(var.cidr_blocks, "zone_${count.index}")}"
  availability_zone       = "${lookup(var.zones, "zone_${count.index}")}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags { Name = "${var.name}_subnet_${lookup(var.zones, "zone_${count.index}")}" }
}

---

# vars.tf

variable "vpc_id" {}
variable "number_of_subnets" { default = 2 }
variable "cidr_blocks" { type = "map" }
variable "map_public_ip_on_launch" {}
variable "name" {}
variable "zones" {
  default = {
    zone_0 = "eu-west-2a"
    zone_1 = "eu-west-2b"
  }
}

---

# outputs.tf
output "subnet_ids" {
  value = ["${aws_subnet.subnet.*.id}"]
}
```

</details>
</p>

<p>
<details>
<summary><strong>Route table for VPC default internet gateway</strong> `infrastructure/modules/ig-route-table/`</summary>
  
```
# main.tf
resource "aws_route_table" "internet_gateway_route_table" {
    vpc_id      = "${var.vpc_id}"
    route {
        cidr_block     = "${var.cidr_block}"
        gateway_id = "${var.internet_gateway_id}"
    }
    tags { Name = "${var.env}_internet_gateway_route_table" }
}

---

# vars.tf
variable "vpc_id" {}
variable "env" {}
variable "internet_gateway_id" {}
variable "cidr_block" { default = "0.0.0.0/0" }

---

# outputs.tf
output "internet_gateway_route_table_id" {
  value = "${aws_route_table.internet_gateway_route_table.id}"
}
```

</details>
</p>

<p>
<details>
<summary><strong>Route table association</strong> `infrastructure/modules/route-table-association/`</summary>
  
```
# main.tf
resource "aws_route_table_association" "route-table-association" {
    count          = "${var.number_of_subnets}"
    subnet_id      = "${element(var.subnet_ids, count.index)}"
    route_table_id = "${var.route_table_id}"
}

---

# vars.tf
variable "number_of_subnets" { default = 2 }
variable "subnet_ids" { type = "list" }
variable "route_table_id" {}

```

</details>
</p>

<p>
<details>
<summary><strong>NAT gateway</strong> `infrastructure/modules/nat/`</summary>

```
# main.tf
resource "aws_nat_gateway" "nat" {
  count         = "1"
  allocation_id = "${var.nat_eip_allocation_id}"
  subnet_id     = "${var.public_subnet_ids[0]}"
}

---

# vars.tf
variable "nat_gateway_enabled" {
    description = "set to 1 to create nat gateway instances for private subnets"
    default = 0
}
variable "public_subnet_ids" { type = "list" }
variable "nat_eip_allocation_id" {}

---

# outputs.tf
output "nat_id" {
  value = "${aws_nat_gateway.nat.id}"
}

output "public_ip" {
  value = "${aws_nat_gateway.nat.public_ip}"
}

```

</details>
</p>

First add an elastic ip to your account. Go to https://eu-west-2.console.aws.amazon.com/vpc/home and click 'Allocate new address'

<p>
<details>
<summary><strong>NAT route table</strong> `infrastructure/modules/nat-route-table/`</summary>
  
```
# main.tf
resource "aws_route_table" "nat_route_table" {
    vpc_id      = "${var.vpc_id}"
    tags { Name = "${var.env}_nat_gateway_route_table" }
}

resource "aws_route" "default_route" {
  route_table_id            = "${aws_route_table.nat_route_table.id}"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = "${var.nat_id}"
}

---

# vars.tf
variable "vpc_id" {}
variable "nat_id" {}
variable "env" {}

---

# outputs.tf
output "nat_route_table_id" {
  value = "${aws_route_table.nat_route_table.id}"
}

```

</details>
</p>

## Main project

<p>
<details>
<summary><strong>Main project</strong> `infrastructure/test/`</summary>
  
```
# main.tf

...

module "public_subnets" {
  source                  = "../modules/subnet"
  vpc_id                  = "${module.vpc.vpc_id}"
  cidr_blocks             = "${var.public_subnets_cidr_blocks}"
  name                    = "${var.env}_public"
  map_public_ip_on_launch = "true"
}

module "public_ig_route_table" {
  source              = "../modules/ig-route-table"
  internet_gateway_id = "${module.vpc.internet_gateway_id}"
  vpc_id              = "${module.vpc.vpc_id}"
  env                 = "${var.env}"
}

module "public_route_table_association" {
  source         = "../modules/route-table-association"
  subnet_ids     = ["${module.public_subnets.subnet_ids}"]
  route_table_id = "${module.public_ig_route_table.internet_gateway_route_table_id}"
}

module "private_subnets" {
  source                  = "../modules/subnet"
  vpc_id                  = "${module.vpc.vpc_id}"
  cidr_blocks             = "${var.private_subnets_cidr_blocks}"
  name                    = "${var.env}_private"
  map_public_ip_on_launch = "false"
}

module "nat" {
  source                = "../modules/nat"
  nat_eip_allocation_id = "${var.nat_eip_allocation_id}"
  public_subnet_ids     = ["${module.public_subnets.subnet_ids}"]
}

module "private_nat_route_table" {
  source = "../modules/nat-route-table"
  nat_id = "${module.nat.nat_id}"
  vpc_id = "${module.vpc.vpc_id}"
  env    = "${var.env}"
}

module "private_route_table_association" {
  source         = "../modules/route-table-association"
  subnet_ids     = ["${module.private_subnets.subnet_ids}"]
  route_table_id = "${module.private_nat_route_table.nat_route_table_id}"

---

# vars.tf

...

variable "public_subnets_cidr_blocks" {
  default = {
    zone_0 = "10.0.1.0/24"
    zone_1 = "10.0.2.0/24"
  }
}
variable "private_subnets_cidr_blocks" {
  default = {
    zone_0 = "10.0.3.0/24"
    zone_1 = "10.0.4.0/24"
  }
}
variable "nat_eip_allocation_id" { default = "eipalloc-XXXXXXXXXXXXX" } # Substitute with your own eip-id

```

</details>
</p>

## Update modules

```
envchain aws terraform get --update # OSX
../../env.sh terraform get --update # Linux

```
## Plan and apply

```
# OSX
envchain aws terraform-wrapper plan
envchain aws terraform-wrapper apply
# Linux
../../env.sh terraform-wrapper plan
../../env.sh terraform-wrapper apply

```

## Solution:

```
git checkout task3
```

# Task 4 - Bastion host

In this task we will set up a bastion host and a security group allowing ssh access

## Modules

<p>
<details>
<summary><strong>Security group</strong> `infrastructure/modules/security-groups/`</summary>
  
```
# main.tf
resource "aws_security_group" "bastion_sg" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.env}_bastion_sg"
  tags { Name = "${var.env}_bastion_sg" }
}

resource "aws_security_group_rule" "ssh_ingress_rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.cidr_block}"]
  security_group_id = "${aws_security_group.bastion_sg.id}"
}

---

# vars.tf

variable "vpc_id" {}
variable "env" {}
variable "cidr_block" {}

---

# outputs.tf
output "bastion_sg_id" {
    value = "${aws_security_group.bastion_sg.id}"
}
```

</details>
</p>

<p>
<details>
<summary><strong>SSH key pair</strong> `infrastructure/modules/key-pair/`</summary>
  
```
# main.tf
resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

---

# vars.tf

variable "key_name" {}
variable "public_key" {}

---

# outputs.tf
output "id" {
  value = "${aws_key_pair.auth.id}"
}
```
</details>
</p>

<p>
<details>
<summary><strong>Bastion host</strong> `infrastructure/modules/instance/`</summary>
  
```
# main.tf
resource "aws_instance" "instance" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_pair_id}"
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  source_dest_check           = "${var.source_dest_check}"
  vpc_security_group_ids      = [ "${var.security_group_id}" ]
}

---

# vars.tf
variable "name" {}
variable "ami" {}
variable "instance_type" { default = "t2.micro" }
variable "key_pair_id" {}
variable "subnet_id" {}
variable "associate_public_ip_address" { default = false }
variable "source_dest_check" { default = true }
variable "security_group_id" {}

---

# outputs.tf
output "public_ip" {
  value = "${aws_instance.instance.public_ip}"
}

```

</details>
</p>

## Main project

<p>
<details>
<summary><strong>Main project</strong> `infrastructure/test/`</summary>
  
```
# main.tf
...
module "security_groups" {
  source     = "../modules/security-groups"
  vpc_id     = "${module.vpc.vpc_id}"
  env        = "${var.env}"
  cidr_block = "0.0.0.0/0"
}

module "key_pair" {
  source     = "../modules/key-pair"
  key_name   = "${var.env}"
  public_key = "${var.public_key}"
}

module "bastion" {
  source                      = "../modules/instance"
  name                        = "${var.env}_bastion"
  ami                         = "${var.bastion_ami}"
  instance_type               = "t2.nano"
  key_pair_id                 = "${module.key_pair.id}"
  subnet_id                   = "${element(module.public_subnets.subnet_ids, 0)}"
  associate_public_ip_address = "${var.bastion_associate_public_ip_address}"
  security_group_id           = "${module.security_groups.bastion_sg_id}"
  source_dest_check           = "false"
}

---

# vars.tf
variable "bastion_associate_public_ip_address" { default = true }
variable "bastion_ami" { default = "ami-dff017b8" }
variable "public_key" {}

---

# cloud-config.yml
vars:
  - name: TF_VAR_env
    value: test
  - name: TF_VAR_region
    value: eu-west-2
  - name: TF_VAR_public_key
    value: "<publik key>"
    
```

</details>
</p>


## Update modules

```
envchain aws terraform get --update # OSX
../../env.sh terraform get --update # Linux

```
## Plan and apply

```
# OSX
envchain aws terraform-wrapper plan
envchain aws terraform-wrapper apply
# Linux
../../env.sh terraform-wrapper plan
../../env.sh terraform-wrapper apply

```

## Log on to the bastion host

`ssh ec2-user@$(envchain aws terraform output --module=bastion public_ip)`


## Solution:

```
git checkout task4
```

# Task 5 - Database

In this task we will set up a hosted database.

### Generate a database password

`pass generate --no-symbols hello/test/db_password`

## Modules

<p>
<details>
<summary><strong>Database subnet group</strong> `infrastructure/modules/db-subnet-group/`</summary>
  
```
# main.tf
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${var.db_subnet_group_name}"
  description = "${var.db_subnet_group_name}"
  subnet_ids  = ["${var.private_subnet_ids}"]
}

---

# vars.tf
variable "db_subnet_group_name" {}
variable "private_subnet_ids" { type = "list" }

---

# outputs.tf
output "db_subnet_group_id" {
  value = "${aws_db_subnet_group.db_subnet_group.id}"
}

```

</details>
</p>

<p>
<details>
<summary><strong>Main project</strong> `infrastructure/test/`</summary>
  
```
# main.tf
...
module "db_subnet_group" {
  source               = "../modules/db-subnet-group"
  db_subnet_group_name = "${var.env}_db_subnet_group"
  private_subnet_ids   = ["${module.private_subnets.subnet_ids}"]
}

```

</details>
</p>

#### Update modules

```
envchain aws terraform get --update # OSX
../../env.sh terraform get --update # Linux

```
#### Plan and apply

```
# OSX
envchain aws terraform-wrapper plan
envchain aws terraform-wrapper apply
# Linux
../../env.sh terraform-wrapper plan
../../env.sh terraform-wrapper apply

```

‼️ We are now moving to the `app-infrastructure` folder structure.

### Create a backend for storing state

```
# backend.tf
terraform {
  backend "s3" {
    bucket = "<unique-bucket-name>"
    key    = "infrastructure/test/hello/terraform.tfstate"
    region = "eu-west-2"
  }
}
```

### Create a new `cloud-config.yml`:

```
secret-vars:
  - name: TF_VAR_db_password
    key: hello/test/db_password

vars:
  - name: TF_VAR_env
    value: test
  - name: AWS_DEFAULT_REGION
    value: eu-west-2
```


### Initialize the backend

`envchain aws terraform init`


<p>
<details>
<summary><strong>Database</strong> `app-infrastructure/modules/rds/`</summary>
  
```
# main.tf
data "aws_vpc" "vpc" {
  tags { Name = "${var.env}_vpc" }
}
resource "aws_db_instance" "db" {
  name                      = "${var.db_name}"
  identifier                = "${var.db_identifier}"
  engine                    = "${var.db_engine}"
  engine_version            = "${var.db_engine_version}"
  instance_class            = "${var.db_instance_class}"
  username                  = "${var.db_username}"
  password                  = "${var.db_password}"
  vpc_security_group_ids    = ["${aws_security_group.db_sg.id}"]
  db_subnet_group_name      = "${var.db_subnet_group_id}"
  backup_retention_period   = "${var.backup_retention_period}"
  availability_zone         = "${var.availability_zone}"
  multi_az                  = "${var.multi_az}"
  backup_window             = "${var.backup_window}"
  maintenance_window        = "${var.maintenance_window}"
  allocated_storage         = "${var.allocated_storage}"
  storage_type              = "${var.storage_type}"
  apply_immediately         = "${var.apply_immediately}"
  skip_final_snapshot       = "${var.skip_final_snapshot}"
  license_model             = "${var.license_model}"
  tags {
    Name = "${var.db_name_tag}"
  }
}

resource "aws_security_group" "db_sg" {
    vpc_id      = "${data.aws_vpc.vpc.id}"
    name        = "${var.db_sg_name}"
    description = "${var.db_sg_name}"
    tags { Name = "${var.db_sg_name}" }
}

---

# vars.tf
variable "env" {}
variable "db_name" {}
variable "db_name_tag" { default = "" }
variable "db_subnet_group_id" {}
variable "db_identifier" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_username" {}
variable "db_password" {}
variable "db_sg_name" {}
variable "backup_retention_period" { default = "0" }
variable "availability_zone" { default = "eu-west-2a" }
variable "multi_az" { default = "false" }
variable "backup_window" {}
variable "maintenance_window" { default =  "Wed:03:55-Wed:04:25" }
variable "allocated_storage" {}
variable "storage_type" {}
variable "apply_immediately" {}
variable "skip_final_snapshot" { default = "true" }
variable "license_model" { default = "" }

---

# outputs.tf

output "db_security_group_id" {
    value = "${aws_security_group.db_sg.id}"
}

output "address" {
    value = "${aws_db_instance.db.address}"
}

```

</details>
</p>

<p>
<details>
<summary><strong>Main project</strong> `app-infrastructure/test/`</summary>
  
```
# main.tf
module "db" {
  source                  = "../modules/rds"
  env                     = "${var.env}"
  db_name                 = "${var.env}_${var.appname}"
  db_identifier           = "${var.env}-${var.appname}-rds"
  db_sg_name              = "${var.env}_${var.appname}_db_sg"
  db_engine               = "mysql"
  db_engine_version       = "5.7.21"
  db_instance_class       = "${var.db_instance_class}"
  db_username             = "root"
  db_password             = "${var.db_password}"
  db_subnet_group_id      = "${var.env}_db_subnet_group"
  backup_retention_period = "${var.backup_retention_period}"
  multi_az                = "${var.multi_az}"
  backup_window           = "${var.backup_window}"
  maintenance_window      = "${var.maintenance_window}"
  allocated_storage       = "${var.allocated_storage}"
  storage_type            = "${var.storage_type}"
  apply_immediately       = "${var.apply_immediately}"
}

---

# vars.tf
variable "env" {}
variable "appname" { default = "hello" }
variable "db_password" {}
variable "backup_retention_period" { default = "0" }
variable "multi_az" { default = "false" }
variable "backup_window" { default = "02:17-02:47" }
variable "maintenance_window" { default = "Wed:03:55-Wed:04:25" }
variable "allocated_storage" { default = 10 }
variable "db_instance_class" { default = "db.t2.micro" }
variable "storage_type" { default = "gp2" }
variable "apply_immediately" { default = "true" }

```

</details>
</p>

## Update modules

```
envchain aws terraform get --update # OSX
../../env.sh terraform get --update # Linux

```
## Plan and apply

```
# OSX
envchain aws terraform-wrapper plan
envchain aws terraform-wrapper apply
# Linux
../../env.sh terraform-wrapper plan
../../env.sh terraform-wrapper apply

```


## Solution:

```
git checkout task5
```

# Task 6 - Security groups

In this task we will set up security groups between the bastion host and apps, and between apps and the database.

## Modules

<p>
<details>
<summary><strong>Security groups</strong> `app-infrastructure/modules/security-groups/`</summary>
  
```
# main.tf
data "aws_vpc" "vpc" {
  tags { Name = "${var.env}_vpc" }
}

data "aws_security_group" "bastion_security_group" {
  name = "${var.env}_bastion_sg"
}

resource "aws_security_group" "app_security_group" {
  vpc_id      = "${data.aws_vpc.vpc.id}"
  name        = "${var.app_security_group_name}"
  description = "${var.app_security_group_name}"
  tags { Name = "${var.app_security_group_name}" }
}

# Bastion -> App
resource "aws_security_group_rule" "from_bastion_to_app_egress_security_rule" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${data.aws_security_group.bastion_security_group.id}"
  source_security_group_id = "${aws_security_group.app_security_group.id}"
}

resource "aws_security_group_rule" "from_bastion_to_app_ingress_security_rule" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app_security_group.id}"
  source_security_group_id = "${data.aws_security_group.bastion_security_group.id}"
}

# App -> DB
resource "aws_security_group_rule" "from_app_to_db_ingress_security_rule" {
  type                     = "ingress"
  from_port                = "${var.db_port}"
  to_port                  = "${var.db_port}"
  protocol                 = "tcp"
  security_group_id        = "${var.db_security_group_id}"
  source_security_group_id = "${aws_security_group.app_security_group.id}"
}

# App -> DB
resource "aws_security_group_rule" "from_app_to_db_egress_security_rule" {
  type                     = "egress"
  from_port                = "${var.db_port}"
  to_port                  = "${var.db_port}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.app_security_group.id}"
  source_security_group_id = "${var.db_security_group_id}"
}

---

# vars.tf
variable "env" {}
variable "app_security_group_name" {}
variable "db_security_group_id" {}
variable "db_port" {}

```

</details>
</p>

<p>
<details>
<summary><strong>Main project</strong> `app-infrastructure/test/`</summary>
  
```
# main.tf
module "security-groups" {
  source                  = "../modules/security-groups"
  env                     = "${var.env}"
  app_security_group_name = "${var.env}_${var.appname}_app_sg"
  db_security_group_id    = "${module.db.db_security_group_id}"
  db_port                 = "3306"
}

```

</details>
</p>

## Update modules

```
envchain aws terraform get --update # OSX
../../env.sh terraform get --update # Linux

```
## Plan and apply

```
# OSX
envchain aws terraform-wrapper plan
envchain aws terraform-wrapper apply
# Linux
../../env.sh terraform-wrapper plan
../../env.sh terraform-wrapper apply

```

## Solution:

```
git checkout task6
```

# Task 7 - Elastic Beanstalk Application

In this task we will configure an Elastic Beanstalk project and deploy an application.

### Initialize th project

1. Go to the root of the project folder

2. Type `envchain aws eb init`

3. Answer the questions
* `16) eu-west-2 : EU (London)`
* `Application Name: helloworld`
* `11) Java`
* `1) Java 8`
* `CodeCommit? (y/N) (default is n): N`
* `SSH: Y`
* `Keypair 1) test`
   
4. Add a file called `.ebignore` with the following contents:

```
*
.*
!/app.zip
```
   
5. Build the Java app: `cd app && mvn clean install && cd -`

6. 
