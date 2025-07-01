#!/bin/bash

# Set up base directory
BASE_DIR="$(pwd)"

# Ensure 'conf' folder exists
if [ ! -d "$BASE_DIR/conf" ]; then
  echo "Error: 'conf' directory not found in project root."
  exit 1
fi

# Create required folders
echo "Creating aws, hadoop and postgres folder in conf."
mkdir -p conf/hadoop conf/postgres conf/aws

# Download Hadoop dependency
echo "Downloading hadoop-aws:3.3.4 JAR."
mvn dependency:get -Dartifact=org.apache.hadoop:hadoop-aws:3.3.4
mvn dependency:copy -Dartifact=org.apache.hadoop:hadoop-aws:3.3.4 -DoutputDirectory=conf/hadoop

# Download PostgreSQL dependency
echo "Downloading postgresql:42.7.4 JAR."
mvn dependency:get -Dartifact=org.postgresql:postgresql:42.7.4
mvn dependency:copy -Dartifact=org.postgresql:postgresql:42.7.4 -DoutputDirectory=conf/postgres

# Download AWS SDK Bundle dependency
echo "Downloading aws-java-sdk-bundle:1.12.262 JAR."
mvn dependency:get -Dartifact=com.amazonaws:aws-java-sdk-bundle:1.12.262
mvn dependency:copy -Dartifact=com.amazonaws:aws-java-sdk-bundle:1.12.262 -DoutputDirectory=conf/aws

echo "Download complete. JARs saved in respective folders."

