#!/bin/bash

env=${1}
private_subnet_ids=
public_subnet_ids=
security_group_ids=

# remove files on script exit
trap 'rm -f app.zip' EXIT

cat <<EOF
Variables:

  env: ${env}
  vpc.private_subnets: ${private_subnet_ids}
  vpc:public_subnets: ${public_subnet_ids}
  vpc.security_groups: ${security_group_ids}

Press ENTER to continue
EOF

./package.sh ${env}

envchain aws2 eb create ${env}-helloworld \
  --keyname ${env} \
  --vpc.id ${env} \
  --vpc.dbsubnets ${private_subnet_ids} \
  --vpc.ec2subnets ${private_subnet_ids}  \
  --vpc.elbpublic \
  --vpc.elbsubnets ${public_subnet_ids} \
  --vpc.securitygroups ${security_group_id} \
  --instance_type t2.micro \
  --platform java-8 \
  --cname ${env}-helloworld \
  --scale 2 \
