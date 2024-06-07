#!/bin/bash

# Function to check if bitcoind is ready
is_bitcoind_ready() {
  bitcoin-cli -rpcconnect=bitcoind -rpcport=43782 -rpcuser=user -rpcpassword=pass -conf=/root/.lightning/bitcoin/bitcoin.conf getblockchaininfo &> /dev/null
  return $?
}

# Wait for bitcoind to be ready
until is_bitcoind_ready; do
  echo "Waiting for bitcoind to be ready..."
  sleep 5
done

# Start cln
exec lightningd "$@"