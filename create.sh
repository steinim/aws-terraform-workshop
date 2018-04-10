#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

env=${1}
vpc_id=$(envchain aws2 aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${env}_vpc" --query 'Vpcs[*].[VpcId]' --output text)

private_subnet_ids=$(envchain aws2 aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc_id},Name=tag:Name,Values=${env}_private_subnet*" --query 'Subnets[*].[SubnetId]' --output text | tr '\n' ',' | sed 's/,$//')
public_subnet_ids=$(envchain aws2 aws ec2 describe-subnets --filters "Name=vpc-id,Values=${vpc_id},Name=tag:Name,Values=${env}_public_subnet*" --query 'Subnets[*].[SubnetId]' --output text | tr '\n' ',' | sed 's/,$//')
security_group_ids=$(envchain aws2 aws ec2 describe-security-groups --filters "Name=group-name,Values=${env}_hello_app_sg" --query 'SecurityGroups[*].[GroupId]' --output text | tr '\n' ',' | sed 's/,$//')

# remove files on script exit
trap 'rm -f application.jar config.properties' EXIT

cat <<EOF
Variables:

  env: ${env}
  vpc.id: ${vpc_id}
  vpc.private_subnets: ${private_subnet_ids}
  vpc:public_subnets: ${public_subnet_ids}
  vpc.security_groups: ${security_group_ids}

Press ENTER to continue
EOF

read

./package.sh ${env}

envchain aws2 eb create ${env}-helloworld \
  --keyname ${env} \
  --vpc.id ${vpc_id} \
  --vpc.dbsubnets ${private_subnet_ids} \
  --vpc.ec2subnets ${private_subnet_ids}  \
  --vpc.elbpublic \
  --vpc.elbsubnets ${public_subnet_ids} \
  --vpc.securitygroups ${security_group_ids} \
  --instance_type t2.micro \
  --platform java-8 \
  --cname ${env}-helloworld \
  --scale 2 \
