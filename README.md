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

The master branch is used internally by `localgit` and should never be used by
end-users so `lg init` creates a topic branch named `dev`:

    $ git branch
      master
    * dev

Before modifying a file, import it in `localgit`.

    $ lg import f1
    $ vim f1
    $ git commit -m 'my local change' f1

Import, hack, rince and repeat.  You can use all git commands in your topic
branches (`git rebase -i`, `git diff`...).

Before pulling new changes from the other SCM into your working copy, you must
switch back the the master branch first.

    $ git checkout master
    $ ... pull update from other SCM ...

After pulling from other SCM, report pulled changes into the master branch
(ignoring files absent from local git):

    $ lg sync

Then rebase your topic branches:

    $ git checkout dev
    $ git rebase master

Listing all files in topic branch may be useful for example for preparing a
commit in the other SCM.

    $ lg files
    edit f1

After checking out a new workspace from the other SCM, you can clone an
existing local git repo in this new workspace.

    $ pwd
    my/workspace/managed/by/another/scm
    $ ... check out new workspace in another/workspace
    $ cd another/workspace
    $ lg clone my/workspace/managed/by/another/scm/.git

`lg clone` leaves local modifications unchanged.  They can be integrated with
`lg sync`.

## Under the hood

`lg import` first creates a commit in the master branch that adds the specified
file, then rebase the current topic branch.

`lg sync` creates a commit in the master branch that updates all files in local
git that have been changed by other SCM.
