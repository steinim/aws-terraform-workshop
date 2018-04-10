#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

filename=${1}
dbname=${2}
echo "db.url=$(envchain aws aws rds describe-db-instances --query 'DBInstances[*].[Endpoint.Address]' --output text)" | grep ${dbname} > ${filename}
echo "db.password=$(pass show hello/test/db_password)" >> ${filename}
