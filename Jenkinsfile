pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'demo-app'
        DOCKER_TAG = "${env.BUILD_NUMBER}"
        HEALTH_CHECK_RETRIES = '10'
        HEALTH_CHECK_DELAY = '5'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                sh 'pwd && ls -la'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                dir('/workspace/app') {
                    sh 'npm install'
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                echo 'Running unit tests...'
                dir('/workspace/app') {
                    sh 'npm test'
                }
            }
            post {
                always {
                    echo 'Test stage completed'
                }
                success {
                    echo 'All tests passed!'
                }
                failure {
                    error 'Tests failed!'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh "cd /workspace && docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                }
            }
        }
        
        stage('Deploy with Docker Compose') {
            steps {
                echo 'Deploying application with Docker Compose...'
                script {
                    sh 'cd /workspace && docker-compose down || true'
                    sh 'cd /workspace && docker-compose up -d'
                    sh 'sleep 10'
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Performing health check...'
                script {
                    def healthy = false
                    def retries = 0
                    def maxRetries = env.HEALTH_CHECK_RETRIES.toInteger()
                    
                    while (!healthy && retries < maxRetries) {
                        try {
                            sh '''
                                response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health)
                                if [ "$response" = "200" ]; then
                                    echo "Health check passed!"
                                    exit 0
                                else
                                    echo "Health check failed with status: $response"
                                    exit 1
                                fi
                            '''
                            healthy = true
                            echo "Application is healthy!"
                        } catch (Exception e) {
                            retries++
                            if (retries >= maxRetries) {
                                error "Health check failed after ${maxRetries} attempts"
                            }
                            echo "Health check attempt ${retries} failed, retrying in ${env.HEALTH_CHECK_DELAY} seconds..."
                            sleep(env.HEALTH_CHECK_DELAY.toInteger())
                        }
                    }
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    sh '''
                        echo "=== Application Status ==="
                        curl -s http://localhost:3000/ | jq .
                        echo ""
                        echo "=== Health Status ==="
                        curl -s http://localhost:3000/health | jq .
                        echo ""
                        echo "=== Container Status ==="
                        docker ps | grep demo-app
                        echo ""
                        echo "=== Container Logs ==="
                        docker logs demo-app-container --tail 20
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed'
            sh '''
                echo "=== Final Status ==="
                docker ps -a | grep demo-app || true
                echo ""
                echo "=== Docker Images ==="
                docker images | grep demo-app || true
            '''
        }
        success {
            echo 'Pipeline succeeded! Application deployed and healthy.'
        }
        failure {
            echo 'Pipeline failed! Check the logs for details.'
            sh 'cd /workspace && docker-compose logs --tail 50'
            sh 'cd /workspace && docker-compose down || true'
        }
    }
}