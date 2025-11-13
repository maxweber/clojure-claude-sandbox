# Stage 1: Build parinfer-rust (use Debian for build, we only copy the binary)
FROM rust:slim AS parinfer-builder
RUN apt-get update && apt-get install -y \
    git \
    libclang-dev \
    && git clone --depth 1 --branch v0.4.3 https://github.com/eraserhd/parinfer-rust.git /tmp/parinfer-rust \
    && cd /tmp/parinfer-rust \
    && cargo build --release \
    && strip /tmp/parinfer-rust/target/release/parinfer-rust

# Stage 2: Node.js + npm (for Claude Code)
FROM node:18-alpine AS node-builder
RUN npm install -g @anthropic-ai/claude-code

# Stage 3: Get Babashka
FROM babashka/babashka:latest AS babashka

# Stage 4: Final image
FROM eclipse-temurin:21-jdk-alpine

# Install Clojure CLI tools and glibc compatibility
ENV CLOJURE_VERSION=1.11.1.1435
RUN apk add --no-cache \
    bash \
    curl \
    git \
    ca-certificates \
    rlwrap \
    gcompat \
    && curl -L -O https://github.com/clojure/brew-install/releases/latest/download/linux-install.sh \
    && chmod +x linux-install.sh \
    && ./linux-install.sh \
    && rm linux-install.sh

# Copy Node.js and npm from node image
COPY --from=node-builder /usr/local/bin/node /usr/local/bin/node
COPY --from=node-builder /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-builder /opt/yarn-* /opt/
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# Copy claude binary from node-builder
COPY --from=node-builder /usr/local/bin/claude /usr/local/bin/claude

# Copy Babashka from official image (needs gcompat for glibc compatibility)
COPY --from=babashka /usr/local/bin/bb /usr/local/bin/bb

# Install bbin and configure environment
RUN curl -sLO https://raw.githubusercontent.com/babashka/bbin/main/bbin \
    && chmod +x bbin \
    && mv bbin /usr/local/bin/ \
    && mkdir -p /root/.local/bin \
    && echo 'export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"' >> /root/.profile \
    && echo 'export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"' >> /root/.bashrc \
    && echo 'alias ccode="claude --dangerously-disable-permissions"' >> /root/.bashrc

# Copy parinfer-rust from builder stage
COPY --from=parinfer-builder /tmp/parinfer-rust/target/release/parinfer-rust /usr/local/bin/parinfer-rust

# Install cljfmt via bbin
ENV PATH="/usr/local/bin:/root/.local/bin:${PATH}"
RUN bb /usr/local/bin/bbin install io.github.weavejester/cljfmt --as cljfmt

# Install clojure-mcp-light tools
RUN bb /usr/local/bin/bbin install https://github.com/bhauman/clojure-mcp-light.git --tag v0.1.1 && \
    bb /usr/local/bin/bbin install https://github.com/bhauman/clojure-mcp-light.git --tag v0.1.1 \
      --as clj-nrepl-eval --main-opts '["-m" "clojure-mcp-light.nrepl-eval"]'

# Add Claude setup script and resources
COPY scripts/claude-setup-clojure /usr/local/bin/claude-setup-clojure
COPY scripts/resources/.cljfmt.edn /usr/local/share/claude-clojure/.cljfmt.edn
RUN chmod +x /usr/local/bin/claude-setup-clojure \
    && mkdir -p /usr/local/share/claude-clojure

# Verification
RUN node --version && \
    npm --version && \
    clojure --version && \
    bb --version && \
    bbin --version && \
    ls -la /usr/local/bin/parinfer-rust && \
    ls -la /root/.local/bin/cljfmt && \
    ls -la /root/.local/bin/clj-paren-repair-claude-hook && \
    ls -la /root/.local/bin/clj-nrepl-eval && \
    ls -la /usr/local/bin/claude && \
    /usr/local/bin/claude-setup-clojure --help

# Default command
CMD ["/bin/bash"]
