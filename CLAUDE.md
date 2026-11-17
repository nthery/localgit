# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is localgit?

A bash script (`localgit`, invoked as `lg`) that maintains local git branches over sources managed by another SCM (primarily Perforce). It creates a hidden git repo inside an existing workspace, using a `main` branch to track the foreign SCM baseline and topic branches for local edits.

## Running tests

```sh
./localgit_test          # run all tests
./localgit_test -x       # run all tests with shell tracing
```

Tests use a homegrown framework in `test_lib.bash`. Each test function must match `^test_[a-z0-9_]*()$`. Tests run in an ephemeral `test/` directory that is cleaned up on success and left on failure for debugging.

To run a subset of tests, pass a regex to `run_tests` at the bottom of `localgit_test`.

## Linting

```sh
shellcheck localgit localgit_test test_lib.bash
```

## Architecture

All code lives in three files:

- **`localgit`** — the main script. Commands are implemented as `lg_<cmd>()` functions dispatched by a `case` block at the bottom. The `commands` variable accumulates help strings.
- **`localgit_test`** — test suite. Each `test_*()` function sets up a temporary git repo, runs `lg` commands, and asserts results. Perforce interaction is tested via a mock `p4` script (`setup_mock_p4`/`teardown_mock_p4`) controlled by `LG_P4_CMD`.
- **`test_lib.bash`** — minimal test framework providing `assert` and `run_tests`.

## Key conventions

- The script runs with `set -e`. Use `set +e` / `set -e` around commands expected to fail.
- `tron()`/`troff()` toggle `set -x` tracing when `debug=1`.
- `detect_main_branch()` handles repos created before the `master` → `main` rename.
- `git_rebase()` wraps `git rebase` to tolerate NFS cleanup failures.
- `LG_GIT_DIR_PREFIX` env var stores the `.git` directory outside the workspace.
