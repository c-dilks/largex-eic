Dependencies
============

Dependencies are maintained in subdirectories of this directory. Many of them
are mirrored here, using [git subrepo](https://github.com/ingydotnet/git-subrepo),
while the others must be downloaded separately.

### Separate Download
- `delphes`, from [delphes/delphes](https://github.com/delphes/delphes):
  Fast simulation framework; run `deps/install_delphes.sh` to download and build

### Mirrors (subrepo, unless otherwise indicated)
- `delphes_EIC`, from [eic/delphes_EIC](https://github.com/eic/delphes_EIC/tree/master):
  Delphes configuration cards for the EIC
- `mstwpdf`, interpolation for MSTW PDFs, not a subrepo
- `adage`, from [c-dilks/adage](https://github.com/c-dilks/adage):
  analysis framework for multi-dimensional binning

Notice
======

These dependencies (subdirectories) may have a different license than
`sidis-eic` itself. The license and copyright used by `sidis-eic` does not
apply to these subdirectories. Since they are git subrepos, they have been
copied as is from their original source. Changes to any code in these
dependencies must be accepted in the corresponding public Git repositories
before being mirrored here.

Subrepo Maintenance
===================

Each subrepo directory contains the file `.gitrepo`, which contains details
about the subrepo configuration. Use `git subrepo` commands when making changes
to any subrepos; run them from the top-level directory (`../`).

### Subrepo Updates
Pull subrepo updates, and push them to `sidis-eic` remote:
```bash
git checkout -b <new-branch-name>  # make a new sidis-eic branch

# pull subrepo updates with either of:
git subrepo pull deps/<subrepo>  # pull updates from a particular <subrepo>
git subrepo pull --all           # pull updates from all subrepos

git push -u origin <new-branch-name>  # push the new sidis-eic branch (which already has the subrepo pull commit(s))
```
Then open a pull request for `<new-branch-name> -> main`

### Subrepo Contributions
If you have `push` access to a `subrepo` remote, you can make your changes here. If you do not
have `push` access, you will need to fork and make your changes separately (or reconfigure subrepo remotes here).

At any time, use `git subrepo status` to print the configuration of each subrepo. Actions such as `git subrepo push`
or `git subrepo pull` will create commits on `sidis-eic`, be sure to push them to remote.

Assuming you have `push` access to the subrepo `<subrepo>`, and you have already made your changes to `<subrepo>`
and you're ready to push them to the `<subrepo>` remote:
```bash
# check `sidis-eic` git status
git status
```
Commit and push all changes to `sidis-eic` (preferably in a new branch, and new PR); the
changes can be both local to `sidis-eic` or local to `<subrepo>`, they do not have to be separate commits.

Create a new branch (e.g., `<my-feature>`) for `<subrepo>` remote, and push the changes we made to it:
```bash
git subrepo push deps/<subrepo> -b <my-feature> -u
git push   # to push changes to `deps/<subrepo>/.gitrepo
```
The commit that you made above will be "copied" and pushed, in the sense that
only the changes relevant to `<subrepo>` will be pushed to `<subrepo>` remote.
- The `-b` option sets the branch name
- The `-u` option updates the `.gitrepo` file, telling it to track `<my-feature>`

Make more changes as needed; push them to both `sidis-eic` and `subrepo` remotes:
```bash
git commit ...
git push ... # to `sidis-eic`
git subrepo push deps/<subrepo>  # no need for -b or -u, we are tracking `<my-feature>` already
git push  # (for .gitrepo)
```

When `<my-feature>` is merged to the `<subrepo>` main branch, we can revert the
subrepo tracking branch and pull the update. Assuming the `<subrepo>` main
branch is `main`:
```bash
git subrepo fetch deps/<subrepo> -b main            # fetch changes from <subrepo> remote
git subrepo pull deps/<subrepo> -b main -u --force  # pull changes (--force is needed if remote deleted <my-feature>)
git push
```
