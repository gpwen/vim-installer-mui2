# Patch and Build Vim NSIS Installer

The following guide shows how to patch official Vim source code to build the
new NSIS installer.  I assume you already knew how to build Vim NSIS
installer.

## Software Requirement

In addition to all those softwares required to access Vim source repository,
build Vim binary and the NSIS installer, you also need
[[git|http://git-scm.com/]] to access the repository for the new installer,
and [[GNU patch|http://savannah.gnu.org/projects/patch/]] to patch Vim source.

You may perform all the following steps on Linux, or simply install
[[cygwin|http://www.cygwin.com/]] on Windows, which gives you access to all
required tools.

## Patch and Build New Vim NSIS Installer

Please follow steps listed below to patch and build the new installer:

1.  Download source code for the new NSIS installer
```ksh
mkdir vim-nsis
cd vim-nsis
git clone git://github.com/gpwen/vim-installer-mui2.git
```

2.  Generate patch for Vim official code (the latest revision on the default
    branch of the [[official mercurial repository of
    Vim|http://www.vim.org/mercurial.php]]):
```ksh
cd path/to/vim-installer-mui2
git diff -p origin/vim-official origin/master > path/to/nsis.patch
```

3.  Applies the patch to the official Vim code:
```ksh
cd path/to/vim
patch -p1 < path/to/nsis.patch
```

4.  You can now build the NSIS installer as normal.
