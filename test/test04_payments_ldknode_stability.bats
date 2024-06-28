#!/usr/bin/env bats

# set -eo pipefail
# set -x

setup() {
    load 'test_helper/common-setup'
    _common_setup

    source "$PROJECT_ROOT/test/functions.sh"

    TEST_COUNT=10
    SUCCESS_COUNT=0
}

increment_success_count() {
    (( ++SUCCESS_COUNT ))
}

print_success_count() {
    echo "$SUCCESS_COUNT"
}

get_offer() {
    OFFER=$(generate_offer_ldknode 'ldknode2')
}

print_offer() {
    echo $OFFER
}

attempt() {
    $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $OFFER 5000000
}

@test "Multiple consecutive payments to LDK Node (lnd1 -> lnd2 -> ldknode2) x 10" {

    get_offer
    run print_offer

    for i in $(seq 1 $TEST_COUNT)
    do
        run attempt
        if [[ "${lines[0]}" =~ "Successfully paid for offer!" ]]; then
            increment_success_count
        fi
    done

    run print_success_count
    assert_equal $SUCCESS_COUNT $TEST_COUNT
}