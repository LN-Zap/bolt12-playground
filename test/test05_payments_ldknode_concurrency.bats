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
    echo "$OFFER"
}

attempt() {
    local result
    result=$($PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer "$OFFER" 5000000)
    if [[ "$result" =~ "Successfully paid for offer!" ]]; then
        echo "success" >> "$BATS_TMPDIR/success_count"
    fi
}

increment_success_count() {
    SUCCESS_COUNT=$(wc -l < "$BATS_TMPDIR/success_count")
}

@test "Concurrent payments to LDK Node (lnd1 -> lnd2 -> ldknode2) x 10" {
    mkdir -p "$BATS_TMPDIR"
    : > "$BATS_TMPDIR/success_count" # Reset file for counting successes

    get_offer
    run print_offer

    for i in $(seq 1 $TEST_COUNT); do
        attempt &
    done

    wait # Wait for all background jobs to finish

    increment_success_count

    run print_success_count
    assert_equal "$SUCCESS_COUNT" "$TEST_COUNT"
}