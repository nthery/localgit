# Copyright (c) 2016, Nicolas Thery (nthery@gmail.com)
# vim: ts=8 sts=4 sw=4 et ft=sh

#
# Very basic bash test framework
#
# See "public interface" section below for usage.
#

readonly progname=$(basename "$0")
readonly fullprogname="$(pwd)/$progname"

##############################################################################
# INTERNALS
##############################################################################

log()
{
    echo "$progname: $*"
}

error()
{
    echo 1>&2 "$progname: $*"
    exit 1
}

start_test()
{
    log "=============================================================================="
    log " starting $1"
    mkdir "$1"
    pushd "$1"
}

end_test()
{
    popd
    log "completed $1"
}

##############################################################################
# PUBLIC INTERFACE
##############################################################################

# Evaluate command passed as parameter and fail test if it returns non-zero.
assert()
{
    local -r cmd="$1"
    eval "$cmd" || error "FAILURE: command [$cmd] returned $?"

}

# Execute all test functions in "test" subdirectory.
# 
# The "test" subdirectory is deleted on success but left on failure for
# debugging.
#
# A test function is a bash function defined with "test_foo_bar()".  It must
# start with "test_" and contain only lowercase characters, digits and
# underscores.
run_all_tests()
{
    local -r test_root="$(pwd)/test"

    rm -rf "$test_root" || true
    mkdir "$test_root"

    pushd "$test_root"

    grep '^test_[a-z0-9_]*()$' "$fullprogname" | while read -r test_fn; do
        test_name="${test_fn/()}"
        start_test "$test_name"
        eval "$test_name"
        end_test "$test_name"
    done

    popd # "$test_root"

    log "SUCCESS :-)"
    rm -rf "$test_root"
}
