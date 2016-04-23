# localgit

The localgit script maintains local git branches over sources managed by
another source control system.

## Disclaimer

- This script has not been thoroughly tested so use at your own risk and be
  ready to debug it and manually repair the local git tree.

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
end-users so create a topic branch.  You can create as many topic branches as
you want and switch between them.

    $ git checkout -b mytopic

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

    $ git checkout mytopic
    $ git rebase master

Listing all files in topic branch may be useful for example for preparing a
commit in the other SCM.

    $ lg files
    f1

## Under the hood

`lg import` first creates a commit in the master branch that adds the specified
file, then rebase the current topic branch.

`lg sync` creates a commit in the master branch that updates all files in local
git that have been changed by other SCM.
