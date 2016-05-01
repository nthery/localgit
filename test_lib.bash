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
    eval "$cmd" || error "FAILURE: $test_name: command [$cmd] returned $?"
}

# Execute test functions matching specified regex.
#
# When there is no argument, execute all functions starting with "test_" and
# containing only lowercase characters, digits and underscores.
#
# Creates "test" subdirectory and run test functions there.  The "test"
# subdirectory is deleted on success but left on failure for debugging.
run_tests()
{
    local opt
    while getopts ":x" opt; do
        case $opt in
            x) set -x ;;
            *) error "bad option: $OPTARG" ;;
        esac
    done
    shift $(( OPTIND - 1 ))

    local  test_re="$1"
    [[ -z "$test_re" ]] && test_re='^test_[a-z0-9_]*()$'

    local -r test_root="$(pwd)/test"

    rm -rf "$test_root" || true
    mkdir "$test_root"

    pushd "$test_root"

    grep "$test_re" "$fullprogname" | while read -r test_fn; do
        export test_name="${test_fn/()}"
        start_test "$test_name"
        eval "$test_name"
        end_test "$test_name"
    done

    popd # "$test_root"

    log "SUCCESS :-)"
    rm -rf "$test_root"
}
