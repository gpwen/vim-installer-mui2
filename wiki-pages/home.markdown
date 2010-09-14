# Modern UI 2.0 upgrade for Vim NSIS installer

## Introduction

This repository contains [[NSIS | http://nsis.sourceforge.net/]] scripts to
build [[Vim self-installing executables | http://www.vim.org/download.php#pc]]
for MS-Windows (*a.k.a.*, Windows installer).  The installer is upgraded to
use [[NSIS Modern User Interface 2.0 |
http://nsis.sourceforge.net/Docs/Modern%20UI%202/Readme.html]], which provides
a user interface for NSIS installers with a modern wizard style, similar to
the wizards of recent Windows versions.  You can check the above link for
detailed description and screenshots.

Please note code in this repository is a subset of Vim codebase, it won't
build by itself.  This repository is primarily aimed for those who build their
own Vim NSIS installer.

Screenshots of the new installer can be found [[screenshots page |
http://wiki.github.com/gpwen/vim-installer-mui2/screenshots]].

## Branches

All branches in this repository are listed below:

* [[master|http://github.com/gpwen/vim-installer-mui2]]:
  NSIS scripts for the new installer.

* [[vim-official|http://github.com/gpwen/vim-installer-mui2/tree/vim-official]]:
  NSIS scripts from the [[official mercurial repository of
  Vim|http://www.vim.org/mercurial.php]].  It's used to track the official
  code (manually).

* [[misc|http://github.com/gpwen/vim-installer-mui2/tree/misc]]:
  This branch contains some files to support the NSIS installer, but not
  necessarily part of the installer.  It's used as a catchall place for
  miscellaneous files to avoid cluttering of the
  [[master|http://github.com/gpwen/vim-installer-mui2]] branch.

* [[wiki-files|http://github.com/gpwen/vim-installer-mui2/tree/wiki-files]]:
  Files to be used on Wiki pages.  It used to make it easier to upload images
  to github.  You should ignore this branch.

## Build Instruction

There are two possible ways to build the new NSIS installer:

1.  Patch Vim source code, and build NSIS installer as normal.  You can find
    detailed instruction on the [[build page |
    http://wiki.github.com/gpwen/vim-installer-mui2/build]].

2.  Repack the official Vim installer.  This method is much simpler, it's the
    recommended method to try and test the new installer.  Please find
    detailed instruction on the [[repack page |
    http://wiki.github.com/gpwen/vim-installer-mui2/repack]].
