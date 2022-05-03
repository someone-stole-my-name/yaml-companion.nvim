FROM alpine:latest

ENV HADOLINT_VERSION=2.10.0
ARG NEOVIM_VERSION=0.7.0

WORKDIR /tmp/nvim

RUN apk --no-cache add \
  autoconf \
  automake \
  bash \
  build-base \
  cargo \
  cmake \
  coreutils \
  curl \
  gettext-tiny-dev \
  git \
  libarchive-tools \
  libtool \
  make \
  npm \
  pkgconf \
  rust \
  unzip

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN git clone --depth 1 --branch v${NEOVIM_VERSION} https://github.com/neovim/neovim && \
  cd neovim && \
  make CMAKE_BUILD_TYPE=Release && \
  make install

RUN npm install -g yaml-language-server

RUN cargo install stylua
ENV PATH "$PATH:/root/.cargo/bin"

RUN curl -L -o /usr/bin/hadolint \
  https://github.com/hadolint/hadolint/releases/download/v${HADOLINT_VERSION}/hadolint-Linux-x86_64 && \
  chmod +x /usr/bin/hadolint

WORKDIR /
