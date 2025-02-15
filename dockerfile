FROM ubuntu:20.04

ARG RUNNER_VERSION="2.322.0"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN sed -i 's/ports.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

RUN apt update -y && apt upgrade -y && useradd -m docker
RUN apt install -y --no-install-recommends \
  curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip docker-buildx \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
  ARCH="x64"; \
  elif [ "$TARGETARCH" = "arm64" ]; then \
  ARCH="arm64"; \
  else \
  echo "Unsupported architecture: $TARGETARCH" && exit 1; \
  fi  && \
  cd /home/docker && mkdir actions-runner && cd actions-runner \
  && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz \
  && tar xzf ./actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz

RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh

# make the script executable
RUN chmod +x start.sh

# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker

ENTRYPOINT ["./start.sh"]
