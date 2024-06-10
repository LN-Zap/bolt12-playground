#!/bin/bash

# Usage:
#   wait-for-bitcoind.sh <cln-args>
#
# Arguments:
#   cln-args  The arguments to be passed to the lightningd command.
#
# This script is used to delay the startup of cln nodes until bitcoind is ready.
# It uses the bitcoin-cli command to check the status of bitcoind.
# Once bitcoind is ready, it starts the cln nodes with the provided arguments.

# Function to check if bitcoind is ready
is_bitcoind_ready() {
  bitcoin-cli -rpcconnect=bitcoind -rpcport=43782 -rpcuser=user -rpcpassword=pass -conf=/root/.lightning/bitcoin/bitcoin.conf getblockchaininfo &> /dev/null
  return $?
}

# Wait for bitcoind to be ready
# The until loop will keep looping as long as the is_bitcoind_ready function returns a non-zero value (i.e., bitcoind is not ready).
until is_bitcoind_ready; do
  echo "Waiting for bitcoind to be ready..."
  # The sleep command is used to pause the script for 5 seconds between each check.
  sleep 5
done

# Start cln
# The exec command is used to replace the current shell process with the lightningd command.
# The "$@" part is used to pass all arguments to the lightningd command.
exec lightningd "$@"