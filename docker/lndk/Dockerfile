#################
# Builder image #
#################
FROM rust:1.78-bookworm AS builder

# References for lndk
ARG LNDK_REF=b2586d77ad527b7469c680823da31ae55c489a43

# Add utils
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    protobuf-compiler \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the Docker image
WORKDIR /usr/src

# Grab and install the latest version of lndk
RUN git clone https://github.com/lndk-org/lndk.git . \
    && git reset --hard ${LNDK_REF} \
    # Setup git user to ensure we can cherry-pick
    && git config --global user.email "tom@strike.me" \
    && git config --global user.name "Tom Kirkpatrick" \
    # Add the orbitalturtle remote
    && git remote add orbitalturtle https://github.com/orbitalturtle/lndk.git \
    && git fetch --all \
    # https://github.com/lndk-org/lndk/pull/115
    && git cherry-pick d84344b27a022bc97b658222e185556d7a71d563 \
        af227ee2d66710aa4e4b3f4f1c31b6d79fa88271 \
        4a367e92321a07ae62712ed651430e55075740cc \
        c7244b153aee227166d1bb4236597cc49caad267 \
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