#!/usr/bin/env bats

# set -eo pipefail
# set -x

setup() {
    load 'test_helper/common-setup'
    _common_setup

    source "$PROJECT_ROOT/test/functions.sh"
}

@test "Generate bolt12 offer on eclair1 and pay from lndk1 (lnd1 -> eclair1)" {
    run generate_offer_eclair 'eclair1'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 1000
    assert_line --partial 'Successfully paid for offer!'
}

@test "Generate bolt12 offer on eclair2 and pay from lndk1 (lnd1 -> lnd2 -> eclair2)" {
    run generate_offer_eclair 'eclair2'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 1000
    assert_line --partial 'Successfully paid for offer!'
}

@test "Generate bolt12 offer on eclair3 and pay from lndk2 (lnd2 -> eclair2 -> eclair3)" {
    run generate_offer_eclair 'eclair3'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 1000
    assert_line --partial 'Successfully paid for offer!'
}

@test "Generate bolt12 offer on eclair3 and pay from lndk1 (lnd1 -> lnd2 -> eclair2 -> eclair2)" {
    run generate_offer_eclair 'eclair2'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 1000
    assert_line --partial 'Successfully paid for offer!'
}