#!/bin/bash

filename=${1}
dbname=${2}
echo "db.url=$(envchain aws2 aws rds describe-db-instances --query 'DBInstances[*].[Endpoint.Address]' --output text)" | grep ${dbname} > ${filename}
echo "db.password=$(pass show hello/test/db_password)" >> ${filename}
