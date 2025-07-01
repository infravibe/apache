#!/bin/bash

# Set Hive configuration directory
export HIVE_CONF_DIR=${HIVE_CONF_DIR:-$HIVE_HOME/conf}

# Set JAVA_HOME if not already set
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-11-openjdk}

# Set Hadoop home directory if not set
export HADOOP_HOME=${HADOOP_HOME:-/opt/hadoop}

# Set Hadoop configuration directory
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-$HADOOP_HOME/etc/hadoop}

# Set Hive Auxiliary JARs path to include Atlas Hive Hook jars
export HIVE_AUX_JARS_PATH=${HIVE_AUX_JARS_PATH:-/opt/atlas/hook/hive}

# Enable remote debugging (optional)
# export HIVE_OPTS="$HIVE_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
