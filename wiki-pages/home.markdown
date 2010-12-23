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

Features of the new installer can be found on the [[features page | feature]],
and screenshots of the new installer can be found on the [[screenshots page |
screenshots]].  Files installed by the new installer has a few difference than
that installed by the official installer, you can find detailed information on
the [[difference page | difference]].

You're more than welcomed to test the new installer and report any problems
found.  I've included some test cases on the [[test case page | testcases]]
for your reference.

## Multiple Language Support

The new installer supports multiple language.  You can find the current
language support status on the [[language page | language]].  You can help to
add more languages to the installer by translating the language file, please
find instruction on that page.  Your help are highly appreciated.

## Silent Mode Support

The new installer has full support for [[silent mode|
http://nsis.sourceforge.net/Docs/Chapter4.html#4.12]].  When run in such
mode, no user interface will be shown.  It's useful for unattended
installation/uninstallation over large number of computers.  Please refer
to dynamically generated [[user manual |
https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/gen/vim73_install_manual.txt]]
for detail.  In order to support such mode, all install options have been
made available on command line.

## Branches

All branches in this repository are listed below:

* [[master|https://github.com/gpwen/vim-installer-mui2]]:
  NSIS scripts for the new installer.

* [[vim-official|https://github.com/gpwen/vim-installer-mui2/tree/vim-official]]:
  NSIS scripts from the [[official mercurial repository of
  Vim|http://www.vim.org/mercurial.php]].  It's used to track the official
  code (manually).

* [[misc|https://github.com/gpwen/vim-installer-mui2/tree/misc]]:
  This branch contains some files to support the NSIS installer, but not
  necessarily part of the installer.  It's used as a catchall place for
  miscellaneous files to avoid cluttering of the
  [[master|https://github.com/gpwen/vim-installer-mui2]] branch.

* [[wiki-files|https://github.com/gpwen/vim-installer-mui2/tree/wiki-files]]:
  Files to be used on Wiki pages.  It used to make it easier to upload images
  to github.  You should ignore this branch.

## Build Instruction

There are two possible ways to build the new NSIS installer:

1.  Patch Vim source code, and build NSIS installer as normal.  You can find
    detailed instruction on the [[build page | build]].

2.  Repack the official Vim installer.  This method is much simpler, it's the
    recommended method to try and test the new installer.  Please find
    detailed instruction on the [[repack page | repack]].

## Downloads

I have repacked Vim official installer using the new NSIS script, you can find
the repacked installer on the [[download page |
https://github.com/gpwen/vim-installer-mui2/downloads]], it has two difference
flavors:

* `gvim73_46-en-v#.#.exe`: This is English only version.  It's a strict
  repacking of the official installer, no file changed.

* `gvim73_46-int-v#.#.exe`: International version.  Same as above except
  multiple language support has been enabled.
