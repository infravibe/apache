# Hadoop Docker Cluster Setup

A complete Hadoop 3.3.6 cluster setup using Docker containers with HDFS, YARN, and MapReduce services.

## Architecture Overview

This setup creates a multi-node Hadoop cluster with the following components:

- **NameNode**: HDFS metadata management and web UI
- **DataNodes**: Data storage nodes (2 instances)
- **ResourceManager**: YARN resource management
- **NodeManagers**: YARN compute nodes (2 instances)
- **HistoryServer**: MapReduce job history tracking

## Prerequisites

- Docker and Docker Compose installed
- Minimum 8GB RAM available for containers
- Docker network named `apache` (created automatically)

## Quick Start

### 1. Create Docker Network

```bash
docker network create --driver=bridge apache
```

### 2. Start the Cluster

```bash
docker-compose up -d
```

### 3. Verify Cluster Status

Check if all services are running:

```bash
docker-compose ps
```

## Service Endpoints

Once the cluster is running, you can access the following web interfaces:

| Service | URL | Description |
|---------|-----|-------------|
| NameNode Web UI | http://localhost:9870 | HDFS status and file browser |
| ResourceManager Web UI | http://localhost:8088 | YARN applications and cluster resources |
| DataNode 1 Web UI | http://localhost:9864 | DataNode status and logs |
| DataNode 2 Web UI | http://localhost:9865 | DataNode status and logs |
| NodeManager 1 Web UI | http://localhost:8042 | NodeManager status and containers |
| NodeManager 2 Web UI | http://localhost:8043 | NodeManager status and containers |
| History Server Web UI | http://localhost:8188 | MapReduce job history |
| JobHistory Web UI | http://localhost:19888 | Detailed job history interface |

## Configuration Details

### Core Configuration

The cluster uses the following key configurations:

- **HDFS Replication Factor**: 1 (suitable for development)
- **Default Filesystem**: `hdfs://namenode:9820`
- **WebHDFS**: Enabled for REST API access
- **YARN Framework**: Configured for MapReduce jobs

### Storage Locations

- **NameNode Data**: `/hadoop/dfs/name` (persistent volume)
- **DataNode Data**: `/hadoop/dfs/data` (persistent volumes)
- **Configuration**: `./config` directory mounted to containers

## Common Operations

### HDFS Operations

Access HDFS from any container:

```bash
# List files in HDFS
docker exec -it namenode hdfs dfs -ls /

# Create a directory
docker exec -it namenode hdfs dfs -mkdir /user

# Upload a file
docker exec -it namenode hdfs dfs -put /opt/hadoop/README.txt /user/

# Download a file
docker exec -it namenode hdfs dfs -get /user/README.txt /tmp/
```

### YARN Operations

Submit a MapReduce job:

```bash
# Run the included wordcount example
docker exec -it resourcemanager yarn jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount /input /output
```

Check YARN applications:

```bash
docker exec -it resourcemanager yarn application -list
```

### Monitoring and Logs

View container logs:

```bash
# NameNode logs
docker logs namenode

# ResourceManager logs
docker logs resourcemanager

# Follow logs in real-time
docker logs -f datanode1
```

## Directory Structure

```
hadoop/
├── config/                 # Hadoop configuration files
│   ├── capacity-scheduler.xml
│   ├── core-site.xml
│   ├── hdfs-site.xml
│   ├── mapred-site.xml
│   └── yarn-site.xml
├── docker-compose.yaml     # Docker Compose configuration
├── Dockerfile             # Custom Hadoop image with patches
└── README.md              # This file
```

## Troubleshooting

### Common Issues

1. **NameNode Format Required**
    - The NameNode automatically formats on first startup
    - To reformat: `docker exec -it namenode hdfs namenode -format -force`

2. **Services Not Starting**
    - Check logs: `docker logs <container_name>`
    - Ensure sufficient memory is available
    - Verify network connectivity between containers

3. **Web UIs Not Accessible**
    - Confirm ports are not blocked by firewall
    - Check if containers are running: `docker-compose ps`
    - Verify port mappings in docker-compose.yaml

4. **HDFS Safe Mode**
    - Check safe mode status: `docker exec -it namenode hdfs dfsadmin -safemode get`
    - Leave safe mode: `docker exec -it namenode hdfs dfsadmin -safemode leave`

### Scaling the Cluster

To add more DataNodes or NodeManagers:

1. Copy the existing datanode/nodemanager service definition
2. Change the hostname and container name
3. Update port mappings to avoid conflicts
4. Restart the cluster: `docker-compose up -d`

## Performance Tuning

For production environments, consider:

- Increasing JVM heap sizes in hadoop-env.sh
- Adjusting YARN memory and CPU allocations
- Setting appropriate HDFS block size
- Configuring compression for MapReduce jobs

## Security Notes

**Important**: This setup uses permissive security settings suitable for development only:

- All users have full access to HDFS (`*` ACLs)
- No authentication or authorization enabled
- Root user access enabled for simplicity

For production deployment, implement proper security measures including:
- Kerberos authentication
- HDFS permissions and ACLs
- YARN queue ACLs
- Network security and encryption

## Cleanup

To stop and remove all containers:

```bash
docker-compose down
```

To remove persistent volumes (⚠️ This will delete all data):

```bash
docker-compose down -v
```

## Support

For issues or questions:
- Check the official [Apache Hadoop documentation](https://hadoop.apache.org/docs/r3.3.6/)
- Review container logs for error messages
- Ensure all prerequisites are met

## License

This configuration is based on Apache Hadoop 3.3.6 and follows the Apache License 2.0.