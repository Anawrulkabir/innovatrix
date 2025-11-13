#!/bin/bash

# Script to run the entire CI/CD pipeline locally

echo "======================================"
echo "CI/CD Pipeline Runner"
echo "======================================"
echo ""

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo "Error: Docker is not running. Please start Docker first."
        exit 1
    fi
    echo "✓ Docker is running"
}

# Function to build and run Jenkins
setup_jenkins() {
    echo ""
    echo "Setting up Jenkins in Docker..."
    echo "--------------------------------------"
    
    # Stop any existing Jenkins containers
    docker-compose -f docker-compose.jenkins.yml down 2>/dev/null
    
    # Build and start Jenkins
    docker-compose -f docker-compose.jenkins.yml up -d --build
    
    echo "Waiting for Jenkins to start (this may take a few minutes)..."
    sleep 30
    
    # Check if Jenkins is running
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|403"; then
        echo "✓ Jenkins is running at http://localhost:8080"
    else
        echo "✗ Jenkins failed to start"
        docker-compose -f docker-compose.jenkins.yml logs
        exit 1
    fi
}

# Function to run the pipeline manually (without Jenkins)
run_pipeline_manual() {
    echo ""
    echo "Running pipeline stages manually..."
    echo "--------------------------------------"
    
    # Stage 1: Install Dependencies
    echo ""
    echo "[1/6] Installing Dependencies..."
    cd app && npm ci && cd ..
    
    # Stage 2: Run Tests
    echo ""
    echo "[2/6] Running Tests..."
    cd app && npm test && cd ..
    
    # Stage 3: Build Docker Image
    echo ""
    echo "[3/6] Building Docker Image..."
    docker build -t demo-app:latest .
    
    # Stage 4: Deploy with Docker Compose
    echo ""
    echo "[4/6] Deploying with Docker Compose..."
    docker-compose down 2>/dev/null
    docker-compose up -d
    
    # Wait for application to start
    echo "Waiting for application to start..."
    sleep 10
    
    # Stage 5: Health Check
    echo ""
    echo "[5/6] Running Health Check..."
    ./healthcheck.sh
    
    # Stage 6: Display Status
    echo ""
    echo "[6/6] Application Status..."
    echo "--------------------------------------"
    curl -s http://localhost:3000/ | jq . 2>/dev/null || curl -s http://localhost:3000/
    echo ""
    curl -s http://localhost:3000/health | jq . 2>/dev/null || curl -s http://localhost:3000/health
}

# Function to display instructions
display_instructions() {
    echo ""
    echo "======================================"
    echo "✓ Pipeline Execution Complete!"
    echo "======================================"
    echo ""
    echo "Access Points:"
    echo "- Application: http://localhost:3000"
    echo "- Health Check: http://localhost:3000/health"
    if [ "$1" == "jenkins" ]; then
        echo "- Jenkins UI: http://localhost:8080"
        echo ""
        echo "To create a Jenkins job:"
        echo "1. Open http://localhost:8080"
        echo "2. Click 'New Item'"
        echo "3. Choose 'Pipeline'"
        echo "4. In Pipeline section, choose 'Pipeline script from SCM'"
        echo "5. Set SCM to 'Git' and repository to '/workspace'"
        echo "6. Save and click 'Build Now'"
    fi
    echo ""
    echo "To stop all services:"
    echo "  docker-compose down"
    if [ "$1" == "jenkins" ]; then
        echo "  docker-compose -f docker-compose.jenkins.yml down"
    fi
}

# Main execution
main() {
    check_docker
    
    echo ""
    echo "Select execution mode:"
    echo "1) Run pipeline manually (recommended for quick testing)"
    echo "2) Set up Jenkins and run in Jenkins (full CI/CD setup)"
    echo ""
    read -p "Enter choice (1 or 2): " choice
    
    case $choice in
        1)
            run_pipeline_manual
            display_instructions "manual"
            ;;
        2)
            setup_jenkins
            echo ""
            echo "Jenkins is ready! Now running pipeline manually to demonstrate..."
            run_pipeline_manual
            display_instructions "jenkins"
            ;;
        *)
            echo "Invalid choice. Please run the script again and select 1 or 2."
            exit 1
            ;;
    esac
}

# Run main function
main