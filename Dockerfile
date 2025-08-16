FROM alpine:3.22.1

# Install system dependencies and performance tools
RUN apk update && apk add --no-cache \
    nodejs \
    npm \
    curl \
    bash \
    python3 \
    py3-pip \
    ca-certificates \
    gnupg \
    strace \
    tcpdump \
    wireshark-common \
    tshark

# Install Claude Code CLI
#RUN npm install -g @anthropic-ai/claude-code

# Install Google Cloud CLI to /opt (accessible to all users)
RUN curl -sSL https://sdk.cloud.google.com > /tmp/install_gcloud.sh && \
    bash /tmp/install_gcloud.sh --install-dir=/opt && \
    rm /tmp/install_gcloud.sh
ENV PATH=$PATH:/opt/google-cloud-sdk/bin

# Create arista user
#RUN addgroup -g 1000 arista && \
#    adduser -u 1000 -G arista -s /bin/bash -D arista

# Add gcloud to PATH for arista user's profile
RUN echo 'export PATH=$PATH:/opt/google-cloud-sdk/bin' >> /root/.bashrc

# Set working directory
WORKDIR /workspace

# Copy google auth library source and test files
COPY google-auth-library-nodejs /workspace/google-auth-library-nodejs
COPY test.sh /workspace/test.sh
COPY auth-test.cjs /workspace/auth-test.cjs
COPY auth-test-with-project.cjs /workspace/auth-test-with-project.cjs

# Build and install google auth library from source
WORKDIR /workspace/google-auth-library-nodejs
RUN npm install && npm run compile

# Pack the library and install it locally in workspace
RUN npm pack
WORKDIR /workspace
RUN npm install /workspace/google-auth-library-nodejs/google-auth-library-*.tgz
#RUN chown -R arista:arista /workspace
RUN chmod +x /workspace/test.sh


# Default command
CMD ["/workspace/test.sh"]
