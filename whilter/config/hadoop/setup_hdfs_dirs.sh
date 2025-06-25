#!/bin/bash

# Exit on any error
set -e

echo "Creating /hbase directory..."
hdfs dfs -mkdir -p /hbase
hdfs dfs -chown hbase:hadoop /hbase

echo "Setting up directories for Hive..."
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -mkdir -p /tmp/hive
hdfs dfs -chown -R hive:hadoop /tmp/hive /user/hive
hdfs dfs -chmod 777 /tmp/hive

echo "Setting up directories for Ranger audits..."
hdfs dfs -mkdir -p /ranger/audit/hdfs
hdfs dfs -mkdir -p /ranger/audit/yarn
hdfs dfs -mkdir -p /ranger/audit/hbaseMaster
hdfs dfs -mkdir -p /ranger/audit/hbaseRegional
hdfs dfs -mkdir -p /ranger/audit/kafka
hdfs dfs -mkdir -p /ranger/audit/hiveServer2
hdfs dfs -mkdir -p /ranger/audit/knox

hdfs dfs -chown hdfs:hadoop  /ranger/audit/hdfs
hdfs dfs -chown yarn:hadoop  /ranger/audit/yarn
hdfs dfs -chown hbase:hadoop /ranger/audit/hbaseMaster
hdfs dfs -chown hbase:hadoop /ranger/audit/hbaseRegional
hdfs dfs -chown kafka:hadoop /ranger/audit/kafka
hdfs dfs -chown hive:hadoop  /ranger/audit/hiveServer2
hdfs dfs -chown knox:hadoop  /ranger/audit/knox

echo "Granting user 'akash' rwx access on all relevant directories..."
hdfs dfs -setfacl -R -m user:akash:rwx /hbase
hdfs dfs -setfacl -R -m user:akash:rwx /user/hive
hdfs dfs -setfacl -R -m user:akash:rwx /tmp/hive
hdfs dfs -setfacl -R -m user:akash:rwx /ranger/audit

echo "All directories created, permissions and ACLs set successfully."


# chmod +x setup_hdfs_dirs.sh