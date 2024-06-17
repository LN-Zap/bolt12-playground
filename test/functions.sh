#!/usr/bin/env bash

generate_offer_eclair() {
    local generate_node=$1

    run $PROJECT_ROOT/bin/eclair-cli $generate_node tipjarshowoffer
    echo $output
}

generate_offer_cln() {
    local generate_node=$1

    run $PROJECT_ROOT/bin/lightning-cli $generate_node offer 1000 "test offer from $generate_node"
    echo "$output" | awk -F'"bolt12": "' '{print $2}' | awk -F'"' '{print $1}'
}

generate_offer_ldknode() {
    local generate_node=$1

    run $PROJECT_ROOT/bin/ldknode-cli $generate_node offer
    echo "$output"
}