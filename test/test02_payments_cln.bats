#!/usr/bin/env bats

# set -eo pipefail
# set -x

setup() {
    load 'test_helper/common-setup'
    _common_setup

    source "$PROJECT_ROOT/test/functions.sh"
}

@test "Generate bolt12 offer on cln1 and pay from lndk1 (lnd1 -> cln1)" {
    run generate_offer_cln 'cln1'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 10000
    assert_line --partial 'Successfully paid for offer!'
}

@test "Generate bolt12 offer on cln2 and pay from lndk1 (lnd1 -> lnd2 -> cln2)" {
    run generate_offer_cln 'cln2'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 10000
    assert_line --partial 'Successfully paid for offer!'
}

@test "Generate bolt12 offer on cln3 and pay from lndk2 (lnd2 -> cln2 -> cln3)" {
    run generate_offer_cln 'cln3'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk2 pay-offer $output 10000
    assert_line --partial 'Successfully paid for offer!'
}

@test "Generate bolt12 offer on cln3 and pay from lndk1 (lnd1 -> lnd2 -> cln2 -> cln3)" {
    run generate_offer_cln 'cln3'
    assert_line --partial 'lno'

    run $PROJECT_ROOT/bin/lndk-cli lndk1 pay-offer $output 10000
    assert_line --partial 'Successfully paid for offer!'
}