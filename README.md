# CI/CD Pipeline Demo

Complete CI/CD pipeline implementation with Jenkins, Docker, and automated health checks.

## Project Structure

```
.
├── app/                    # Demo Node.js application
│   ├── server.js          # Express server with health endpoint
│   ├── server.test.js     # Unit tests
│   └── package.json       # Node dependencies
├── jenkins-docker/        # Jenkins Docker configuration
│   └── Dockerfile         # Jenkins with Docker-in-Docker
├── Dockerfile             # Application container definition
├── docker-compose.yml     # Application deployment config
├── docker-compose.jenkins.yml  # Jenkins deployment config
├── Jenkinsfile           # Declarative CI/CD pipeline
├── healthcheck.sh        # Health verification script
└── run-pipeline.sh       # Quick start script
```

## Features

- **Node.js Demo App**: Express server with health endpoint
- **Unit Tests**: Jest test suite with coverage
- **Dockerized**: Multi-stage Docker build
- **CI/CD Pipeline**: Complete Jenkins pipeline with stages:
  - Checkout
  - Install Dependencies
  - Run Tests
  - Build Docker Image
  - Deploy with Docker Compose
  - Health Check
  - Verify Deployment
- **Health Monitoring**: Automated health checks with retry logic
- **Docker-in-Docker**: Jenkins runs with Docker capabilities

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- Git (optional, for version control)
- 4GB+ free RAM recommended

### Option 1: Run Pipeline Manually (Fastest)

```bash
# Run the automated pipeline script
./run-pipeline.sh

# Select option 1 for manual execution
# This will build, test, package, deploy, and verify the app
```

### Option 2: Run with Jenkins (Full CI/CD)

```bash
# Run the automated pipeline script
./run-pipeline.sh

# Select option 2 for Jenkins setup
# This will set up Jenkins and run the pipeline
```

### Option 3: Manual Commands

```bash
# 1. Install dependencies and run tests
cd app && npm ci && npm test && cd ..

# 2. Build Docker image
docker build -t demo-app:latest .

# 3. Deploy with Docker Compose
docker-compose up -d

# 4. Verify health
./healthcheck.sh
```

## Access Points

- **Application**: http://localhost:3000
- **Health Check**: http://localhost:3000/health
- **Jenkins** (if using Option 2): http://localhost:8080

## API Endpoints

- `GET /` - Returns welcome message with timestamp
- `GET /health` - Returns health status, uptime, and service info

## Jenkins Pipeline Stages

1. **Checkout**: Clone repository
2. **Install Dependencies**: npm ci
3. **Run Tests**: Execute Jest test suite
4. **Build Docker Image**: Create container image
5. **Deploy**: Start application with docker-compose
6. **Health Check**: Verify application health with retries
7. **Verify Deployment**: Display status and logs

## Testing

```bash
# Run tests locally
cd app && npm test

# Run tests with coverage
cd app && npm test -- --coverage
```

## Cleanup

```bash
# Stop application
docker-compose down

# Stop Jenkins (if running)
docker-compose -f docker-compose.jenkins.yml down

# Remove all containers and images
docker system prune -a
```

## Pipeline Success Indicators

✅ All tests pass (3 test suites)
✅ Docker image builds successfully
✅ Container deploys and starts
✅ Health endpoint returns HTTP 200
✅ Application responds on port 3000

## Troubleshooting

- **Port 3000 in use**: Stop existing service or change PORT in docker-compose.yml
- **Jenkins not starting**: Ensure Docker has 4GB+ memory allocated
- **Health check fails**: Run `docker logs demo-app-container` for details
- **Permission denied**: Run `chmod +x *.sh` to make scripts executable

## Security Notes

- Jenkins runs without setup wizard for demo purposes
- Production deployments should use proper authentication
- Container runs as non-root user for security
- Health checks use internal Docker networking