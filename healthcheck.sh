#!/bin/bash

# Health check script for demo application
# This script verifies the application is running and healthy

HEALTH_URL="http://localhost:3000/health"
ROOT_URL="http://localhost:3000"
MAX_RETRIES=10
RETRY_DELAY=3

echo "======================================"
echo "Health Check Script for Demo App"
echo "======================================"
echo ""

# Function to check endpoint
check_endpoint() {
    local url=$1
    local name=$2
    
    echo "Checking $name endpoint: $url"
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$url")
    http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d':' -f2)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_status" = "200" ]; then
        echo "✓ $name endpoint is responding (HTTP $http_status)"
        echo "Response: $body"
        return 0
    else
        echo "✗ $name endpoint failed (HTTP $http_status)"
        return 1
    fi
    echo ""
}

# Function to check container status
check_container() {
    echo "Checking Docker container status..."
    if docker ps | grep -q "demo-app-container"; then
        echo "✓ Container 'demo-app-container' is running"
        docker ps | grep "demo-app-container"
        return 0
    else
        echo "✗ Container 'demo-app-container' is not running"
        return 1
    fi
    echo ""
}

# Main health check logic
main() {
    local retry_count=0
    local health_ok=false
    
    # Check if container is running
    if ! check_container; then
        echo "Container not found. Attempting to start..."
        docker-compose up -d
        sleep 5
    fi
    
    # Retry health check
    while [ $retry_count -lt $MAX_RETRIES ] && [ "$health_ok" = false ]; do
        echo "Health check attempt $((retry_count + 1)) of $MAX_RETRIES"
        echo "--------------------------------------"
        
        if check_endpoint "$HEALTH_URL" "Health"; then
            health_ok=true
            echo ""
            check_endpoint "$ROOT_URL" "Root"
            echo ""
            echo "======================================"
            echo "✓ APPLICATION IS HEALTHY!"
            echo "======================================"
            
            # Display container logs
            echo ""
            echo "Recent container logs:"
            docker logs demo-app-container --tail 10
            
            exit 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $MAX_RETRIES ]; then
                echo "Retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            fi
        fi
        echo ""
    done
    
    # Health check failed
    echo "======================================"
    echo "✗ HEALTH CHECK FAILED!"
    echo "======================================"
    echo "Application did not respond after $MAX_RETRIES attempts"
    
    # Show diagnostic information
    echo ""
    echo "Diagnostic information:"
    echo "----------------------"
    echo "Container status:"
    docker ps -a | grep "demo-app" || echo "No demo-app containers found"
    echo ""
    echo "Container logs:"
    docker logs demo-app-container --tail 20 2>&1 || echo "Could not fetch logs"
    
    exit 1
}

# Run main function
main