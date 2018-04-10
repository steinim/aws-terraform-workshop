#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

env=${1}

# prepare jar file
cp app/target/helloworld-java-app-1.0-SNAPSHOT-jar-with-dependencies.jar ./application.jar

# create property file
./create_property_file.sh config.properties ${env}-hello-rds

