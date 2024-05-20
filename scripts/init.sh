#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

bitcoind() {
  $DIR/../bin/bitcoin-cli $@
}

lnd1() {
  $DIR/../bin/lncli $@
}

cln1() {
  $DIR/../bin/clncli $@
}

eclair1() {
  $DIR/../bin/eclair-cli $@
}

waitFor() {
  until $@; do
    >&2 echo "$@ unavailable - waiting..."
    sleep 1
  done
}

createBitcoindWallet() {
  $DIR/../bin/bitcoin-cli createwallet default || $DIR/../bin/bitcoin-cli loadwallet default || true
}

mineBlocks() {
  ADDRESS=$1
  AMOUNT=${2:-1}
  echo Mining $AMOUNT blocks to $ADDRESS...
  bitcoind generatetoaddress $AMOUNT $ADDRESS
  sleep 0.5 # waiting for blocks to be propagated
}

initBitcoinChain() {
  # Mine 103 blocks to initliase a bitcoind node.
  mineBlocks $BITCOIN_ADDRESS 103
}

generateAddresses() {
  BITCOIN_ADDRESS=$(bitcoind getnewaddress)
  echo BITCOIN_ADDRESS: $BITCOIN_ADDRESS

  LND1_ADDRESS=$(lnd1 newaddress p2wkh | jq -r .address)
  echo LND1_ADDRESS: $LND1_ADDRESS

  CLN1_ADDRESS=$(cln1 newaddr | jq -r .bech32)
  echo CLN1_ADDRESS: $CLN1_ADDRESS

  ECLAIR1_ADDRESS=$(eclair1 getnewaddress)
  echo ECLAIR1_ADDRESS: $ECLAIR1_ADDRESS
}

getNodeInfo() {
  LND1_NODE_INFO=$(lnd1 getinfo)
  LND1_NODE_URI=$(echo ${LND1_NODE_INFO} | jq -r .uris[0])
  LND1_PUBKEY=$(echo ${LND1_NODE_INFO} | jq -r .identity_pubkey)
  echo LND1_PUBKEY: $LND1_PUBKEY
  echo LND1_NODE_URI: $LND1_NODE_URI


  CLN1_NODE_INFO=$(cln1 getinfo)
  CLN1_PUBKEY=$(echo ${CLN1_NODE_INFO} | jq -r .id)
  CLN1_IP_ADDRESS=$(echo ${CLN1_NODE_INFO} | jq -r '.binding[0].address')
  CLN1_PORT=$(echo ${CLN1_NODE_INFO} | jq -r '.binding[0].port')
  CLN1_NODE_URI="${CLN1_PUBKEY}@${CLN1_IP_ADDRESS}:${CLN1_PORT}"
  echo CLN1_PUBKEY: $CLN1_PUBKEY
  echo CLN1_NODE_URI: $CLN1_NODE_URI

  ECLAIR1_NODE_INFO=$(eclair1 getinfo)
  ECLAIR1_PUBKEY=$(echo ${ECLAIR1_NODE_INFO} | jq -r .nodeId)
  ECLAIR1_PUBLIC_ADDRESS=$(echo ${ECLAIR1_NODE_INFO} | jq -r '.publicAddresses[0]')
  ECLAIR1_NODE_URI="${ECLAIR1_PUBKEY}@${ECLAIR1_PUBLIC_ADDRESS}"
  echo ECLAIR1_PUBKEY: $ECLAIR1_PUBKEY
  echo ECLAIR1_NODE_URI: $ECLAIR1_NODE_URI
}

sendFundingTransaction() {
  echo creating raw tx...
  local addresses=($LND1_ADDRESS $CLN1_ADDRESS $ECLAIR1_ADDRESS)
  local outputs=$(jq -nc --arg amount 1 '$ARGS.positional | reduce .[] as $address ({}; . + {($address) : ($amount | tonumber)})' --args "${addresses[@]}")
  RAW_TX=$(bitcoind createrawtransaction "[]" $outputs)
  echo RAW_TX: $RAW_TX

  echo funding raw tx $RAW_TX...
  FUNDED_RAW_TX=$(bitcoind fundrawtransaction "$RAW_TX" | jq -r .hex)
  echo FUNDED_RAW_TX: $FUNDED_RAW_TX

  echo signing funded tx $FUNDED_RAW_TX...
  SIGNED_TX_HEX=$(bitcoind signrawtransactionwithwallet "$FUNDED_RAW_TX" | jq -r .hex)
  echo SIGNED_TX_HEX: $SIGNED_TX_HEX

  echo sending signed tx $SIGNED_TX_HEX...
  bitcoind sendrawtransaction "$SIGNED_TX_HEX"
}

fundNodes() {
  # Fund with multiple transactions to that we have multiple utxos to spend on each of the lnd nodes.
  sendFundingTransaction
  sendFundingTransaction
  sendFundingTransaction

  # Generate some blocks to confirm the transactions.
  mineBlocks $BITCOIN_ADDRESS 10
}

openChannel() {
  # Open a channel between lnd1 and cln1.
  waitFor lnd1 connect $CLN1_NODE_URI
  waitFor lnd1 openchannel $CLN1_PUBKEY 10000000 5000000

  # Generate some blocks to confirm the channel.
  mineBlocks $BITCOIN_ADDRESS 10

  # Open a channel between lnd1 and eclair1.
  waitFor lnd1 connect $ECLAIR1_NODE_URI
  waitFor lnd1 openchannel $ECLAIR1_PUBKEY 10000000 5000000

  # Generate some blocks to confirm the channel.
  mineBlocks $BITCOIN_ADDRESS 10
}

waitForNodes() {
  waitFor bitcoind getnetworkinfo
  waitFor lnd1 getinfo
  waitFor cln1 getinfo
  waitFor eclair1 getinfo
}

main() {
  createBitcoindWallet
  waitForNodes
  generateAddresses
  getNodeInfo
  initBitcoinChain
  fundNodes
  openChannel
}

main
