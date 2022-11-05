FROM ghcr.io/someone-stole-my-name/docker-nvim:latest

ARG HADOLINT_VERSION=2.10.0

RUN npm install -g yaml-language-server

RUN cargo install stylua
ENV PATH "$PATH:/root/.cargo/bin"

RUN curl -L -o /usr/bin/hadolint \
  https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64 && \
  chmod +x /usr/bin/hadolint

WORKDIR /
