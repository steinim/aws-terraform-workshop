#!/bin/bash

env=${1}

# prepare jar file
cp app/target/helloworld-java-app-1.0-SNAPSHOT-jar-with-dependencies.jar ./app.jar

# remove files on exit
trap 'rm -f app.jar config.properties' EXIT

# create property file
./create_property_file.sh config.properties ${env}-hello-rds

# pack everything neatly
zip -r app.zip app.jar Procfile config.properties

