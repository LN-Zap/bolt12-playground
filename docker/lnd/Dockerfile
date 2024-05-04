#################
# Builder image #
#################
FROM golang:1.21.4-bookworm AS builder

# References for lnd
ARG LNDE_REF=v0.18.0-beta.rc1

# Set the working directory in the Docker image
WORKDIR /usr/src

# # Grab and install the latest version of lnd
RUN git clone https://github.com/lightningnetwork/lnd.git . \
  && git reset --hard ${LNDE_REF} \
  && make build tags="invoicesrpc routerrpc peersrpc signrpc walletrpc dev"

# Copy the compiled binaries to /bin/
RUN cp lnd-debug /bin/lnd
RUN cp lncli-debug /bin/lncli

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
COPY --from=builder /bin/lncli /usr/local/bin/
COPY --from=builder /bin/lnd /usr/local/bin/

VOLUME ["/root/.lnd"]

# Expose p2p port
EXPOSE 9735

# Expose grpc port
EXPOSE 10009

ENTRYPOINT ["lnd"]
