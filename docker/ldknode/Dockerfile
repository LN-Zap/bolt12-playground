#################
# Builder image #
#################
FROM rust:1.78-bookworm AS builder

# References for lndk
ARG LDK_NODE_REF=e6ff79a6f1d3b6e182baa86a110e75854189dc94

# Add utils
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    protobuf-compiler \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the Docker image
WORKDIR /usr/src

# Grab and install the latest version of lndk
RUN git clone https://github.com/tnull/ldk-node-offers-receive-test.git . \
    && git reset --hard ${LDK_NODE_REF} \
    && cargo build --release

# Copy the compiled binaries to /bin/
RUN cp ./target/release/ldk-node-offers-receive-test /bin/

###############
# final image #
###############
FROM debian:bookworm-slim AS final

# Add utils
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bash \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the compiled binaries from the builder image
COPY --from=builder /bin/ldk-node-offers-receive-test /usr/local/bin/

ENTRYPOINT ["ldk-node-offers-receive-test"]