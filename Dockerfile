# Inspired by https://github.com/mumoshu/dcind
FROM golang:1.13
MAINTAINER Francesco Farina <rockerg991@gmail.com>

ENV DOCKER_VERSION=17.12.0~ce-0~debian \
    DOCKER_COMPOSE_VERSION=1.18.0 \
    ENTRYKIT_VERSION=0.4.0

WORKDIR /root

# Install Docker dependencies
RUN apt-get update && \
    apt-get install -y zip dmsetup python-pip iptables apt-transport-https ca-certificates curl gnupg2 software-properties-common

# Install Docker, Docker Compose, dep and golangci-lint
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(dpkg --status tzdata|grep Provides|cut -f2 -d'-') stable"

RUN apt-get update && apt-cache policy docker-ce && apt-get install -y docker-ce=${DOCKER_VERSION} --allow-unauthenticated && \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION}

RUN (cd /usr/local; wget -O - -q https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s latest)

# Install entrykit
RUN curl -L https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz | tar zx && \
    chmod +x entrykit && \
    mv entrykit /bin/entrykit && \
    entrykit --symlink

# Include useful functions to start/stop docker daemon in garden-runc containers in Concourse CI.
# Example: source /docker-lib.sh && start_docker
COPY docker-lib.sh /docker-lib.sh

ENTRYPOINT [ \
    "switch", \
    "shell=/bin/sh", "--", \
    "codep", \
    "/usr/bin/dockerd" \
    ]
