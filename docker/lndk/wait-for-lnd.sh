#!/bin/bash

# Usage:
#   wait-for-lnd.sh <host> <delay> <lndk-args>
#
# Arguments:
#   host       The host of the lnd's gRPC service.
#   delay      The delay (in seconds) for the startup of lndk nodes after lnd's gRPC port is ready.
#   lndk-args  The arguments to be passed to the lndk command.

is_lnd_ready() {
  macaroon=$(base64 /root/.lnd/data/chain/bitcoin/regtest/readonly.macaroon | tr -d '\n')
  response=$(curl --cacert /root/.lnd/tls.cert -Ss -H "Grpc-Metadata-macaroon: $macaroon" "https://$1:8080/v1/state")
  if [ $? -ne 0 ]; then
    echo "Error: curl command failed"
    echo "Response from curl: $response"
    return 1
  fi
  if echo "$response" | grep -q '"state":"SERVER_ACTIVE"'; then
    return 0
  else
    echo "Error: lnd node state is not SERVER_ACTIVE"
    echo "Response from lnd: $response"
    return 1
  fi
}
# Wait for lnd to be ready
# The until loop will keep looping as long as the is_lnd_ready function returns a non-zero value (i.e., the port is not open).
until is_lnd_ready $1; do
  echo "Waiting for lnd to be ready..."
  sleep 2
done

# Delay startup of lndk nodes
# The sleep command is used to pause the script for a specified number of seconds before starting lndk.
# The number of seconds is specified by the second parameter to the script.
echo "Waiting for another $2 seconds before starting lndk..."
sleep "$2"

# Start lndk
# The exec command is used to replace the current shell process with the lndk command.
# The "${@:3}" part is used to pass all arguments starting from the third one to the lndk command.
exec lndk "${@:3}"