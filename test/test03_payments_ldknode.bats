#!/usr/bin/env bats

# set -eo pipefail
# set -x

setup() {
    load 'test_helper/common-setup'
    _common_setup

    source "$PROJECT_ROOT/test/functions.sh"
}

@test "Generate bolt12 offer on ldknode1 and pay from lndk1 (lnd1 -> ldknode1)" {
    run generate_offer_ldknode 'ldknode1'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 5000000
    assert_line --partial 'Successfully paid for offer!'
}

@test "Generate bolt12 offer on ldknode2 and pay from lndk1 (lnd1 -> ldknode2)" {
    run generate_offer_ldknode 'ldknode2'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 5000000
    assert_line --partial 'Successfully paid for offer!'
}