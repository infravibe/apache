#!/bin/bash

# Hadoop Docker Cluster Deployment Script for EC2
# Author: Production Configuration
# Description: Automated deployment script for Hadoop cluster on EC2

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
HADOOP_VERSION="3.3.6"
DOCKER_IMAGE="infravibe/hadoop:${HADOOP_VERSION}"
NETWORK_NAME="hadoop_network"
COMPOSE_FILE="docker-compose.yaml"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi

    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi

    # Check if Docker daemon is running
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker daemon is not running. Please start Docker service."
        exit 1
    fi

    # Check available memory
    AVAILABLE_MEMORY=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    if [ "$AVAILABLE_MEMORY" -lt 6144 ]; then
        print_warning "Available memory is ${AVAILABLE_MEMORY}MB. Recommended minimum is 6GB for optimal performance."
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    print_success "Prerequisites check completed"
}

# Create directory structure
create_directory_structure() {
    print_status "Creating directory structure..."

    mkdir -p config
    mkdir -p logs
    chmod 755 config logs

    print_success "Directory structure created"
}

# Pull Docker images
pull_docker_images() {
    print_status "Pulling Docker images..."

    docker pull "${DOCKER_IMAGE}" || {
        print_error "Failed to pull Docker image: ${DOCKER_IMAGE}"
        exit 1
    }

    print_success "Docker images pulled successfully"
}

# Create or update Docker network
setup_network() {
    print_status "Setting up Docker network..."

    if docker network ls | grep -q "${NETWORK_NAME}"; then
        print_warning "Network ${NETWORK_NAME} already exists"
    else
        docker network create --driver bridge \
            --subnet=172.20.0.0/16 \
            "${NETWORK_NAME}" || {
            print_error "Failed to create Docker network"
            exit 1
        }
        print_success "Docker network ${NETWORK_NAME} created"
    fi
}

# Check if cluster is running
is_cluster_running() {
    docker-compose ps -q | wc -l | grep -q "^[1-9]"
}

# Stop existing cluster
stop_cluster() {
    if is_cluster_running; then
        print_status "Stopping existing Hadoop cluster..."
        docker-compose down
        print_success "Existing cluster stopped"
    fi
}

# Start Hadoop cluster
start_cluster() {
    print_status "Starting Hadoop cluster..."

    # Start services in order
    docker-compose up -d namenode
    print_status "NameNode started, waiting for initialization..."
    sleep 30

    docker-compose up -d datanode1 datanode2
    print_status "DataNodes started, waiting for registration..."
    sleep 20

    docker-compose up -d resourcemanager
    print_status "ResourceManager started..."
    sleep 15

    docker-compose up -d nodemanager1 nodemanager2
    print_status "NodeManagers started..."
    sleep 10

    docker-compose up -d historyserver
    print_status "HistoryServer started..."
    sleep 10

    print_success "Hadoop cluster started successfully"
}

# Wait for services to be healthy
wait_for_services() {
    print_status "Waiting for services to become healthy..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        local healthy_services=0

        # Check NameNode
        if curl -sf http://localhost:9870/ >/dev/null 2>&1; then
            ((healthy_services++))
        fi

        # Check ResourceManager
        if curl -sf http://localhost:8088/ >/dev/null 2>&1; then
            ((healthy_services++))
        fi

        # Check DataNodes
        if curl -sf http://localhost:9864/ >/dev/null 2>&1; then
            ((healthy_services++))
        fi

        if curl -sf http://localhost:9865/ >/dev/null 2>&1; then
            ((healthy_services++))
        fi

        if [ $healthy_services -eq 4 ]; then
            print_success "All core services are healthy"
            return 0
        fi

        print_status "Attempt $attempt/$max_attempts: $healthy_services/4 services healthy"
        sleep 10
        ((attempt++))
    done

    print_warning "Some services may not be fully ready. Please check logs if issues persist."
}

# Display cluster status
show_cluster_status() {
    print_status "Cluster Status:"
    echo
    docker-compose ps
    echo

    print_status "Service Endpoints:"
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│                        Hadoop Cluster URLs                      │"
    echo "├─────────────────────────────────────────────────────────────────┤"
    echo "│ NameNode Web UI:      http://$(curl -s ifconfig.me):9870        │"
    echo "│ ResourceManager UI:   http://$(curl -s ifconfig.me):8088        │"
    echo "│ DataNode 1 UI:        http://$(curl -s ifconfig.me):9864        │"
    echo "│ DataNode 2 UI:        http://$(curl -s ifconfig.me):9865        │"
    echo "│ NodeManager 1 UI:     http://$(curl -s ifconfig.me):8042        │"
    echo "│ NodeManager 2 UI:     http://$(curl -s ifconfig.me):8043        │"
    echo "│ History Server UI:    http://$(curl -s ifconfig.me):19888       │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo
}

# Run basic health checks
run_health_checks() {
    print_status "Running health checks..."

    # Check HDFS
    print_status "Checking HDFS status..."
    docker exec namenode hdfs dfsadmin -report | grep -E "Live datanodes|Dead datanodes" || true

    # Check YARN
    print_status "Checking YARN status..."
    docker exec resourcemanager yarn node -list || true

    # Create test directory
    print_status "Creating test directory in HDFS..."
    docker exec namenode hdfs dfs -mkdir -p /user/test || true
    docker exec namenode hdfs dfs -ls / || true

    print_success "Health checks completed"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up..."
    docker-compose logs > hadoop-cluster-logs.txt 2>&1
    print_status "Logs saved to hadoop-cluster-logs.txt"
}

# Display help
show_help() {
    echo "Hadoop Docker Cluster Deployment Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start     Start the Hadoop cluster"
    echo "  stop      Stop the Hadoop cluster"
    echo "  restart   Restart the Hadoop cluster"
    echo "  status    Show cluster status"
    echo "  logs      Show cluster logs"
    echo "  clean     Clean up all containers and volumes"
    echo "  help      Show this help message"
    echo
}

# Main deployment function
deploy_cluster() {
    print_status "Starting Hadoop cluster deployment on EC2..."

    check_prerequisites
    create_directory_structure
    pull_docker_images
    setup_network
    stop_cluster
    start_cluster
    wait_for_services
    show_cluster_status
    run_health_checks

    print_success "Hadoop cluster deployment completed successfully!"
    echo
    print_status "To monitor the cluster:"
    echo "  docker-compose logs -f [service_name]"
    echo
    print_status "To access HDFS:"
    echo "  docker exec -it namenode hdfs dfs -ls /"
    echo
    print_status "To submit a MapReduce job:"
    echo "  docker exec -it resourcemanager yarn jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-${HADOOP_VERSION}.jar wordcount /input /output"
}

# Handle script arguments
case "${1:-deploy}" in
    "start"|"deploy")
        deploy_cluster
        ;;
    "stop")
        print_status "Stopping Hadoop cluster..."
        docker-compose down
        print_success "Cluster stopped"
        ;;
    "restart")
        print_status "Restarting Hadoop cluster..."
        docker-compose down
        sleep 5
        deploy_cluster
        ;;
    "status")
        show_cluster_status
        ;;
    "logs")
        docker-compose logs "${2:-}"
        ;;
    "clean")
        print_warning "This will remove all containers and volumes. Data will be lost!"
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker-compose down -v
            docker network rm "${NETWORK_NAME}" 2>/dev/null || true
            print_success "Cleanup completed"
        fi
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

# Set trap for cleanup on script exit
trap cleanup EXIT