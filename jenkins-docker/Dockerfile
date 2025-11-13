FROM jenkins/jenkins:lts-alpine

USER root

# Install minimal dependencies using Alpine packages
RUN apk add --no-cache \
    docker-cli \
    docker-cli-compose \
    nodejs \
    npm \
    curl \
    jq

# Create docker group and add jenkins user to it
RUN addgroup -S docker || true && adduser jenkins docker

USER jenkins

# Skip initial setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# Install only essential plugins
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    git \
    pipeline-stage-view