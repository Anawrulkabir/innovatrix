
Create a complete CI/CD pipeline that:

Builds a small demo application (can be a simple script or “Hello World” web app).
Runs unit tests (mock test OK).
Packages the app as a Docker image.
Deploys the container locally using Docker Compose.
Displays the application health status (e.g., /health endpoint or script check).
Requirements:

Use a Declarative Jenkinsfile for the pipeline.
Use a Dockerfile and docker-compose.yml to build and deploy.
Add a stage to verify the container is running and healthy.
Bonus:

 Run Jenkins inside Docker (Docker-in-Docker setup) to execute the entire pipeline locally.
Deliverables: 

Git repo that contains - 

Jenkinsfile — Declarative pipeline with stages for build, test, package, deploy, and health-check.
Dockerfile — Defines how the demo app container is built.
docker-compose.yml — Spins up the application
app/ — Simple source code for the demo app 
healthcheck.sh — Verifies the app container’s health endpoint. (if needed separately)
Screenshot and console output of a successful pipeline run showing build → deploy → health OK. (MUST)