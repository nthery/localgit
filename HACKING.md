# Hacking on localgit

## File layout

| File | Role |
|------|------|
| `localgit` | Main script (bash). All commands live here. |
| `localgit_test` | Test suite (bash). Sources `test_lib.bash`. |
| `test_lib.bash` | Minimal bash test framework (`assert`, `run_tests`). |
| `test/` | Ephemeral directory created (and cleaned up) by the test suite. |

## Script internals

The script is structured as a series of command implementations dispatched by a
`case` block at the bottom.  Each command has a `lg_<cmd>` function.  The
`commands` variable accumulates help strings for `usage()`.

### Notable helpers

- `detect_main_branch()` — supports repos created before the `master` → `main`
  rename.
- `expect_topic()` / `expect_main()` — guard functions that error out if on the
  wrong branch.
- `all_files()` — lists all files in the repo (excludes the `.lg` marker).
- `start/complete_non_local_git_root_creation()` — support for storing the
  `.git` directory outside the workspace via `LG_GIT_DIR_PREFIX`.
- `tron()` / `troff()` — enable/disable `set -x` tracing when `debug=1`.

## Test suite

### Framework (`test_lib.bash`)

A tiny homegrown framework:

- **`assert "cmd"`** — evaluates `cmd` via `eval`; aborts with `FAILURE` on
  non-zero exit.
- **`run_tests [regex]`** — discovers test functions by grepping the test script
  for functions matching `^test_[a-z0-9_]*()$` (or a user-supplied regex),
  creates a `test/` sandbox directory, runs each test in its own subdirectory,
  and cleans up on success.

### Running tests

```sh
./localgit_test        # run all tests
./localgit_test -x     # run all tests with shell tracing
```

A regex can be passed to `run_tests` to select specific tests (the framework
greps function definitions in the test file).
