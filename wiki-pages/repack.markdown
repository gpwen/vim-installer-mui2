# Repack Official Vim Installer

The following guide shows how to repack the official [[Vim self-installing
executables | http://www.vim.org/download.php#pc]] to generate the new NSIS
installer.  This should be the easiest way to try the new installer.

## Software Requirement

You need to installed the following software to repack the official installer.

* [[7-Zip|http://www.7-zip.org/]]

  You need [[7-Zip|http://www.7-zip.org/]] to unpack the official Vim
  installer so we can repack it.  It can be downloaded from
  [[here|http://www.7-zip.org/]].

  If you have already installed [[cygwin|http://www.cygwin.com/]], you may
  have already installed 7-Zip as part of it.  You can check if you can access
  the `7z` command or not.

* [[NSIS|http://nsis.sourceforge.net/]]

  You need this to generate the installer.  It can be downloaded from [[here |
  http://nsis.sourceforge.net/]].

## Repack Automatically with Shell Script

If you have installed [[cygwin|http://www.cygwin.com/]], you can use the fully
automated shell script to repack Vim installer.

1.  Download source code for the new NSIS installer
```ksh
mkdir vim-nsis
cd vim-nsis
git clone http://github.com/gpwen/vim-installer-mui2
```

2.  Create a new directory for repacking, and copy the repacking shell script
    into that directory.  The shell script can be found on the
    [[misc|http://github.com/gpwen/vim-installer-mui2/tree/misc]] branch.
```ksh
mkdir repack
cd path/to/vim-installer-mui2
git co misc
cp scripts/repack-vim.sh path/to/repack
```

    You may also download the shell script directly from [[ here |
    http://github.com/gpwen/vim-installer-mui2/tree/misc/scripts/repack-vim.sh]]

3.  Check out master branch in the git repository, the script need to access
    code on that branch.
```ksh
cd path/to/vim-installer-mui2
git co master
```

4.  Repack Vim installer with the following command:
```ksh
cd path/to/repack
./repack-vim.sh -ds path/to/vim-installer-mui2
```

    The script will perform the following steps automatically:
    * Download the official Vim installer from [[here |
      http://www.vim.org/download.php#pc]].
    * Unpack the installer using 7-Zip, restore the original NSIS build
      environment.
    * Copy new NSIS installer script from the git repository (from the path
      you specified on the command line).
    * Build the new NSIS installer.

Once done, the new installer can be found at:
```ksh
path/to/repack/vim-repack/vim/nsis/gvim73.exe
```


## Repack Manually with Batch Command

If you do not have shell environment, you can repack the installer manually
using DOS batch file, which could be tedious.

1.  Create a new directory for repacking (I'll refer to it as `repack` in the
    following text).

2.  Download source code for the new NSIS installer, checkout the `misc`
    branch, and copy file `batch\repack-vim.bat` to the `repack` directory.

    You may also download the batch file directly from [[ here |
    http://github.com/gpwen/vim-installer-mui2/tree/misc/batch/repack-vim.bat]]
    and put it in the `repack` directory.

3.  The path to 7-Zip command line is hardcoded in the batch file as:
```batchfile
SET EXE_7Z="C:\Program Files\7-Zip\7z"
```

    If that's not the location where you install 7-Zip, please edit that line
    manually.

4.  Download [[Vim self-installing executables |
    http://www.vim.org/download.php#pc]] from [[here |
    ftp://ftp.vim.org/pub/vim/pc/gvim73.exe]], and put it in the `repack`
    directory.

5.  Repack Vim installer with the following command in DOS prompt:
```bat
cd path\to\repack
repack-vim.bat path\to\vim-installer-mui2
```

    The batch file will perform the following steps automatically:
    * Unpack the official Vim installer using 7-Zip, restore the original NSIS
      build environment.
    * Copy new NSIS installer script from the git repository (from the path
      you specified on the command line).
    * Build the new NSIS installer.

Once done, the new installer can be found at:
```bat
repack\vim-repack\vim\nsis\gvim73.exe
```
