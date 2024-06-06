#!/bin/sh

# output script content for easier debugging.
#set -x
# exit from script if error was raised.
set -eo pipefail

trap exit SIGINT

RPC_ADDR="http://user:pass@bitcoind:43782/"

function GenerateBlock {
	NEW_ADDR_RSP=$(curl -sL \
	  --data-binary '{"jsonrpc": "1.0", "id":"1", "method": "getnewaddress", "params": [] }' \
	  -H 'content-type: text/plain;' $RPC_ADDR)

	#echo $NEW_ADDR_RSP
	NEW_ADDR=$(echo $NEW_ADDR_RSP | jq -r '.result')
	ERR_ADDR=$(echo $NEW_ADDR_RSP | jq -r '.error.code')

	if [ "$ERR_ADDR" != "null" ]
	then
	  echo "RPC error: $NEW_ADDR_RSP"
	  return
	fi;

	echo "Generating block to: $NEW_ADDR"
	NEW_BLOCK_RSP=$(curl -sL --data-binary "{\"jsonrpc\":\"1.0\",\"id\":\"2\",\"method\":\"generatetoaddress\",\"params\":[1,\"$NEW_ADDR\"]}" -H 'content-type: text/plain;' $RPC_ADDR)
	#echo $NEW_BLOCK_RSP

	BLOCK_HASH=$(echo $NEW_BLOCK_RSP | jq -r '.result[0]')
	echo "New block hash: $BLOCK_HASH"
}

while true
do
	GenerateBlock
	echo "Sleeping for 30 seconds until next block generation..."
	sleep 30
done;