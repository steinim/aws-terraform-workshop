#!/bin/bash

env=${1}

# remove files on script exit
trap 'rm -f app.zip' EXIT

# package the app
./package.sh ${env}

envchain aws eb deploy ${env}-helloworld
