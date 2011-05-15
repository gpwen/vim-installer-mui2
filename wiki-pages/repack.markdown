# Repack Official Vim Installer

The following guide shows how to repack the official [[Vim self-installing
executables | http://www.vim.org/download.php#pc]] to generate the new NSIS
installer.  This should be the easiest way to try the new installer.

## Software Requirement

You need to installed the following software to repack the official installer.

*   [[7-Zip|http://www.7-zip.org/]]

    You need [[7-Zip|http://www.7-zip.org/]] to unpack the official Vim
    installer so we can repack it.  It can be downloaded from
    [[here|http://www.7-zip.org/]].  After installation, you should add its
    install path to Windows PATH environment so that `7z` command can be
    accessed from DOS prompt.

    If you have already installed [[cygwin|http://www.cygwin.com/]], you may
    have already installed 7-Zip port as part of it (the `p7zip` package).
    You can check if you can access the `7z` command or not.

*   [[NSIS|http://nsis.sourceforge.net/]]

    You need this to generate the installer.  It can be downloaded from [[here
    | http://nsis.sourceforge.net/]].

    Again, after installation, you should add its install path to Windows PATH
    environment so that "makensis" command can be accessed from DOS prompt.

## Repack Automatically with Shell Script

If you have installed [[cygwin|http://www.cygwin.com/]], you can use the fully
automated shell script to repack Vim installer.  Please verify the following
cygwin packages have been installed before you start:

*   `p7zip`: This is a 7-Zip port, as mentioned above.

*   `wget`: Used to download file.

*   `git`: Used for repository access.

Please follow steps listed below to repack the installer:

1.  Create a new directory for repacking.  I'll refer to it as `repack` in the
    following text.

2.  Download source code for the new NSIS installer, checkout the
    `origin/misc` branch, and copy file `scripts/repack-vim.sh` to the
    `repack` directory:
```ksh
mkdir vim-nsis
cd vim-nsis
git clone git://github.com/gpwen/vim-installer-mui2.git
cd vim-installer-mui2
git co -b temp origin/misc
cp scripts/repack-vim.sh path/to/repack
```

    You may also download the batch file directly from [[ here |
    https://github.com/gpwen/vim-installer-mui2/raw/misc/scripts/repack-vim.sh]]
    and put it in the `repack` directory.

4.  Repack Vim installer with the following command:
```ksh
cd path/to/repack
./repack-vim.sh -d
```

    The script will perform the following steps automatically:
    * Download the official Vim installer from [[here |
      http://www.vim.org/download.php#pc]].
    * Unpack the installer using 7-Zip, restore the original NSIS build
      environment.
    * Download new NSIS install script (git clone).
    * Build the new NSIS installer.

Once done, the new installer can be found at:
```ksh
path/to/repack/vim-repack/vim/nsis/gvim73.exe
```


## Repack Manually with Batch Command

If you do not have shell environment, you can repack the installer manually
using DOS batch file, which could be tedious.

1.  Create a new directory for repacking.  I'll refer to it as `repack` in the
    following text.

2.  Download source code for the new NSIS installer, checkout the
    `origin/misc` branch, and copy file `batch\repack-vim.bat` to the `repack`
    directory.

    You may also download the batch file directly from [[ here |
    https://github.com/gpwen/vim-installer-mui2/raw/misc/batch/repack-vim.bat]]
    and put it in the `repack` directory.

3.  Download [[Vim self-installing executables |
    http://www.vim.org/download.php#pc]], and put it in the `repack`
    directory.

4.  Repack Vim installer with the following command in DOS prompt:
```bat
cd path\to\repack
repack-vim.bat path\to\vim-installer-mui2
```

    The batch file will perform the following steps automatically:
    *   Unpack the official Vim installer using 7-Zip, restore the original
        NSIS build environment.
    *   Copy new NSIS installer script from the git repository (from the path
        you specified on the command line).
    *   Build the new NSIS installer.

Once done, the new installer can be found at:
```bat
repack\vim-repack\vim\nsis\gvim73.exe
```
