#################
# Builder image #
#################
FROM rust:1.78-bookworm AS builder

# References for lndk
# https://github.com/lndk-org/lndk/pull/121
ARG LNDK_REF=ae7832730f36ab497ccf5ce5c3d949e42ad9b91c

# Add utils
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    protobuf-compiler \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the Docker image
WORKDIR /usr/src

# Grab and install the latest version of lndk
RUN git clone https://github.com/orbitalturtle/lndk.git . \
    && git reset --hard ${LNDK_REF} \
    && cargo build --release

# Copy the compiled binaries to /bin/
RUN cp ./target/release/lndk /bin/
RUN cp ./target/release/lndk-cli /bin/

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
COPY --from=builder /bin/lndk /usr/local/bin/
COPY --from=builder /bin/lndk-cli /usr/local/bin/

# Expose grpc port
EXPOSE 7000

ENTRYPOINT ["lndk"]