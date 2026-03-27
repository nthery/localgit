# localgit

The localgit script maintains local git branches over sources managed by
another source control system.

## Disclaimer

- There are undocumented options.  Use the source Luke!

## Installation

    $ cd somewhere
    $ git clone https://github.com/nthery/localgit.git
    $ ln -s somewhere/localgit/localgit ~/bin/lg

## Tutorial

First, create local git repo in source tree managed by another SCM.  This repo
does not contain any file initially.

    $ cd my/workspace/managed/by/another/scm
    $ lg init
    $ ls
    f1 f2 f3

The `main` branch is used internally by `localgit` and should never be used by
end-users so `lg init` creates a topic branch named `dev`:

    $ git branch
      main
    * dev

Before modifying a file, import it in `localgit`.

    $ lg import f1
    $ vim f1
    $ git commit -m 'my local change' f1

Import, hack, rince and repeat.  You can use all git commands in your topic
branches (`git rebase -i`, `git diff`...).

Before pulling new changes from the other SCM into your working copy, you must
switch back the the `main` branch first.

    $ git checkout main
    $ ... pull update from other SCM ...

After pulling from other SCM, report pulled changes into the `main` branch
(ignoring files absent from local git):

    $ lg sync

Then rebase your topic branches:

    $ git checkout dev
    $ git rebase main

Listing all files in topic branch may be useful for example to prepare a
commit in the other SCM.

    $ lg files
    edit f1

If using Perforce you add all changes to the default changelist.
As this is experimental you may want first to display what commands would be emitted:

    $ lg p4 dry-export
    p4 edit f1

Then if satisfied run the actual commands:

    $ lg p4 export
    ...

After checking out a new workspace from the other SCM, you can clone an
existing local git repo in this new workspace.

    $ pwd
    my/workspace/managed/by/another/scm
    $ ... check out new workspace in another/workspace
    $ cd another/workspace
    $ lg clone my/workspace/managed/by/another/scm/.git

`lg clone` leaves local modifications unchanged.  They can be integrated with
`lg sync`.

## Command reference

| Command | Description |
|---------|-------------|
| `init` | Create a local git repo with a `dev` topic branch. |
| `import` / `i` | Add file(s) to the local git.  `-a` rebases all topic branches. |
| `sync` | After pulling from the foreign SCM (while on `main`), commit all modified tracked files. |
| `clone` | Clone an existing localgit repo into another workspace. |
| `apply` / `a` | Apply a patch, automatically importing files as needed. |
| `files` / `f` | List files changed in the topic branch vs `main` (`edit`/`add`/`delete`). |
| `log` | Show commits in the topic branch only. |
| `status` / `s` | Show status of tracked files. |
| `p4 export` | Reflect topic-branch changes into the Perforce default changelist. |
| `p4 dry-export` | Print `p4` commands that `export` would run. |
| `help` | Print usage. |

## Environment variables

- `LG_GIT_DIR_PREFIX` — when set, `init` and `clone` store the actual `.git`
  directory under this prefix (e.g. `$LG_GIT_DIR_PREFIX/<name>.git`) instead of
  in the workspace.  A `.git` *file* containing a `gitdir:` line is left in the
  workspace as a git-level symbolic link pointing to the real location.  This is
  useful to keep the workspace clean for the foreign SCM.

## Under the hood

`localgit` uses two kinds of git branches:

- **`main`** — tracks the baseline state of files as they exist in the foreign
  SCM.  Users should never commit directly to this branch.  Only `lg import`
  and `lg sync` modify it.
- **Topic branches** (e.g. `dev`, created by `lg init`) — where local changes
  live.  These branches are periodically rebased onto `main` so that local
  edits stay on top of the foreign SCM baseline.

The typical lifecycle looks like this:

1. `lg import` checks out `main`, commits the new file there, then switches
   back to the topic branch and rebases it onto `main`.
2. The user edits and commits on the topic branch using regular git commands.
3. When the foreign SCM is updated, the user checks out `main` and runs
   `lg sync`, which commits all modified tracked files to `main`.
4. The user then rebases topic branches onto the updated `main`
   (`git rebase main`).
