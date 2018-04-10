#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

env=${1}

# remove files on script exit
trap 'rm -f application.jar config.properties' EXIT

# package the app
./package.sh ${env}

envchain aws eb deploy ${env}-helloworld
