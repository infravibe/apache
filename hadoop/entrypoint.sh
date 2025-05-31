#!/bin/bash

if [ ! -d /hadoop/dfs/name/current ]; then
  echo "Formatting NameNode..."
  hdfs namenode -format -force -nonInteractive
fi

# Start namenode in the background
echo "Starting NameNode..."
hdfs --daemon start namenode

# Wait until namenode is ready (simple wait or check)
sleep 10

echo "Creating HDFS staging directories for HistoryServer..."

# Create staging directories with proper permissions
hdfs dfs -mkdir -p /tmp/hadoop-yarn/staging/history/done
hdfs dfs -chmod -R 1777 /tmp
hdfs dfs -chown -R hadoop:hadoop /tmp/hadoop-yarn/staging

# Stop the namenode started in background (optional, if you want to restart it properly)
hdfs --daemon stop namenode

# Now start namenode as user hadoop
echo "Starting NameNode as hadoop user..."
su-exec hadoop hdfs namenode
