#!/usr/bin/env bats

# set -eo pipefail
# set -x

setup() {
    error_occurred=0
}

teardown() {
    if [ $error_occurred -eq 1 ]; then
        fail "An error occurred during the test"
    fi
}

# Single hop payments
@test "Generate bolt12 offer on eclair1 and pay from lndk1 (lnd1 -> eclair1)" {
    run generate_offer_eclair 'eclair1'
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
    offer=$output
    run pay_offer 'lndk1' $offer 1000
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
}

@test "Generate bolt12 offer on cln1 and pay from lndk1 (lnd1 -> cln1)" {
    run generate_offer_cln 'cln1'
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
    offer=$output
    run pay_offer 'lndk1' $offer 1000
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
}

# Multi-hop payments (eclair)
@test "Generate bolt12 offer on eclair2 and pay from lndk1 (lnd1 -> lnd2 -> eclair2)" {
    run generate_offer_eclair 'eclair2'
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
    offer=$output
    run pay_offer 'lndk1' $offer 1000
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
}

@test "Generate bolt12 offer on eclair3 and pay from lndk2 (lnd2 -> eclair2 -> eclair3)" {
    run generate_offer_eclair 'eclair3'
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
    offer=$output
    run pay_offer 'lndk2' $offer 1000
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
}

@test "Generate bolt12 offer on eclair3 and pay from lndk1 (lnd1 -> lnd2 -> eclair2 -> eclair3)" {
    run generate_offer_eclair 'eclair3'
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
    offer=$output
    run pay_offer 'lndk1' $offer 1000
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
}

# Multi-hop payments (cln)
@test "Generate bolt12 offer on cln2 and pay from lndk1 (lnd1 -> lnd2 -> cln2)" {
    run generate_offer_eclair 'cln2'
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
    offer=$output
    run pay_offer 'lndk1' $offer 1000
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
}

@test "Generate bolt12 offer on cln3 and pay from lndk2 (lnd2 -> cln2 -> cln3)" {
    run generate_offer_eclair 'cln3'
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
    offer=$output
    run pay_offer 'lndk2' $offer 1000
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
}

@test "Generate bolt12 offer on cln3 and pay from lndk1 (lnd1 -> lnd2 -> cln2 -> cln3)" {
    run generate_offer_eclair 'cln3'
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
    offer=$output
    run pay_offer 'lndk1' $offer 1000
    [ "$status" -eq 0 ] || { echo "Error: $output"; false; }
}


generate_offer_eclair() {
    local generate_node=$1
    local offer=$(./bin/eclair-cli $generate_node tipjarshowoffer)
    if [ $? -ne 0 ]; then
        echo "Failed to generate bolt12 offer on $generate_node"
        return 1
    fi
    echo $offer
}

generate_offer_cln() {
    local generate_node=$1
    local output=$(./bin/lightning-cli $generate_node offer 1000 "test offer from $generate_node")
    if [ $? -ne 0 ]; then
        echo "Failed to generate bolt12 offer on $generate_node"
        return 1
    fi
    local offer=$(echo $output | awk -F'"bolt12": "' '{print $2}' | awk -F'"' '{print $1}')
    echo $offer
}

pay_offer() {
    local pay_node=$1
    local offer=$2
    local amount=$3
    tmpfile=$(mktemp)
    ./bin/lndk-cli $pay_node pay-offer $offer $amount > $tmpfile 2>&1
    status=$?
    output=$(< $tmpfile)
    rm $tmpfile
    if [ $status -ne 0 ]; then
        echo "Failed to pay bolt12 offer from $pay_node: $output"
        return 1
    fi
    echo "Successfully paid bolt12 offer from $pay_node"
}
