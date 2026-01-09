#!/bin/bash

# Deployment Script for Order Management API
# Usage: ./deploy.sh [dev|qa|staging|prod]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if environment argument is provided
if [ $# -eq 0 ]; then
    print_error "No environment specified!"
    echo "Usage: ./deploy.sh [dev|qa|staging|prod]"
    exit 1
fi

ENVIRONMENT=$1
DOCKER_COMPOSE_FILE=""
DOCKERFILE=""
PORT=""

# Set environment-specific variables
case $ENVIRONMENT in
    dev)
        DOCKER_COMPOSE_FILE="docker-compose.dev.yml"
        DOCKERFILE="Dockerfile.dev"
        PORT="8081"
        BRANCH="develop"
        ;;
    qa)
        DOCKER_COMPOSE_FILE="docker-compose.qa.yml"
        DOCKERFILE="Dockerfile.qa"
        PORT="8082"
        BRANCH="qa"
        ;;
    staging)
        DOCKER_COMPOSE_FILE="docker-compose.staging.yml"
        DOCKERFILE="Dockerfile.staging"
        PORT="8083"
        BRANCH="staging"
        ;;
    prod)
        DOCKER_COMPOSE_FILE="docker-compose.prod.yml"
        DOCKERFILE="Dockerfile.prod"
        PORT="8080"
        BRANCH="main"
        print_warning "Deploying to PRODUCTION environment!"
        read -p "Are you sure you want to continue? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            print_info "Deployment cancelled."
            exit 0
        fi
        ;;
    *)
        print_error "Invalid environment: $ENVIRONMENT"
        echo "Valid options: dev, qa, staging, prod"
        exit 1
        ;;
esac

print_info "==================================="
print_info "Deploying to: $ENVIRONMENT"
print_info "Docker Compose: $DOCKER_COMPOSE_FILE"
print_info "Port: $PORT"
print_info "==================================="

# Check if we're on the correct branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    print_warning "Current branch is '$CURRENT_BRANCH', expected '$BRANCH'"
    read -p "Switch to $BRANCH branch? (yes/no): " switch
    if [ "$switch" = "yes" ]; then
        print_info "Switching to $BRANCH branch..."
        git checkout $BRANCH
        git pull origin $BRANCH
    fi
fi

# Navigate to API directory
cd OrderManagement.API

# Check if .env file exists for the environment
ENV_FILE=".env.$ENVIRONMENT"
if [ ! -f "$ENV_FILE" ]; then
    print_warning ".env file not found: $ENV_FILE"
    print_info "Creating from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example $ENV_FILE
        print_warning "Please update $ENV_FILE with actual values!"
        exit 1
    fi
fi

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    export $(grep -v '^#' $ENV_FILE | xargs)
    print_info "Loaded environment variables from $ENV_FILE"
fi

# Stop existing containers
print_info "Stopping existing containers..."
docker-compose -f $DOCKER_COMPOSE_FILE down

# Build and start containers
print_info "Building and starting containers..."
docker-compose -f $DOCKER_COMPOSE_FILE up --build -d

# Wait for API to be ready
print_info "Waiting for API to be ready..."
sleep 10

# Check if API is running
if docker ps | grep -q "${ENVIRONMENT}-order-api"; then
    print_info "✓ API container is running"
else
    print_error "✗ API container failed to start"
    docker-compose -f $DOCKER_COMPOSE_FILE logs api
    exit 1
fi

# Check if database is running
if docker ps | grep -q "${ENVIRONMENT}-postgres-db"; then
    print_info "✓ Database container is running"
else
    print_error "✗ Database container failed to start"
    docker-compose -f $DOCKER_COMPOSE_FILE logs postgres-db
    exit 1
fi

# Run database migrations
print_info "Running database migrations..."
docker exec ${ENVIRONMENT}-order-api dotnet ef database update || true

# Health check
print_info "Performing health check..."
HEALTH_URL="http://localhost:$PORT/health"
if curl -f -s $HEALTH_URL > /dev/null; then
    print_info "✓ Health check passed"
else
    print_warning "✗ Health check failed"
fi

print_info "==================================="
print_info "Deployment completed successfully!"
print_info "==================================="
print_info "API URL: http://localhost:$PORT"
if [ "$ENVIRONMENT" != "prod" ]; then
    print_info "Swagger: http://localhost:$PORT/swagger"
fi
print_info "Health: http://localhost:$PORT/health"
print_info ""
print_info "View logs: docker-compose -f $DOCKER_COMPOSE_FILE logs -f api"
print_info "Stop: docker-compose -f $DOCKER_COMPOSE_FILE down"
