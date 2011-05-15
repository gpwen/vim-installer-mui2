# Screenshots

## Installer Pages

Installer has 7 to 8 pages.

### Language selection dialog

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/install/p1.png]]

This dialog will be shown *only if* multiple language support has been
enabled.  It determines the language used in the following pages.

User selected language (as Windows LCID) will be written to the Windows
registry:
`HKLM\SOFTWARE\Vim\Installer Language`

Global variable `$LANGUAGE` will also be set to that LCID.

### Page 1 : Welcome page

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/install/p2.png]]

This serves as the old installation confirmation dialog.

### Page 2 : License Agreement

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/install/p3.png]]

This is the pristine license page of NSIS, which makes it pretty clear what's
been shown is a license agreement and user must agree to it.

### Page 3 : Components

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/install/p4.png]]

This page let user choose components to install.  Detailed description of each
component will be shown here.

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/install/p4-expanded.png]]

The installer will find all version(s) of Vim that has been installed on the
system, and create a dynamic uninstall component for each version found, as
shown in the above screenshot (with the "Uninstall Existing Version(s)" group
expanded).  User can choose to keep some versions, in which case uninstaller
of those versions will not be launched at all.  However, user cannot keep the
same version as the one been installed for obvious reason.

Currently the installer supports 5 old versions at most.  The number can be
increased, but *who needs more than 5 different versions of Vim installed in
parallel?*

Once installation starts, the installer will launch uninstaller for each of
those selected versions, wait until they complete.  All these will be done
"natively" with NSIS script, no external executable will be used, so no "black
window" will be shown as compared to the official installer.

### Page 4 : Destination Path

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/install/p5.png]]

Let user choose destination path to install Vim.

Once user pressed "install", the following check will be performed:

* No running Vim instance should exist;

* The destination path must end with "vim" (case-insensitive).

The installer won't continue until all above conditions have been satisfied.

### Page 5 : Installation

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/install/p6.png]]

### Page 6 : Finish

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/install/p7.png]]

User can determine whether README.txt should be shown or not on this page.

## Uninstaller Pages

Uninstaller has 4 pages.

### Page 1: Confirmation.

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/uninstall/u1.png]]

### Page 2: Components

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/uninstall/u2.png]]

If the version to be removed is the last one on the system, user can choose
whether to remove the default Vim config file `_vimrc` or not.  The config
file won't be removed by default.  When uninstalling the last Vim from the
system:

*   `vimfiles` directory hierarchy (under Vim install path and user home) will
    be removed automatically *if they are empty*.  Non-empty `vimfiles` will
    be left intact.

*   Vim install root will be removed automatically *if it's empty*.  If fact,
    if no files has been changed under that directory, and user choose to
    remove defalt config file, that directory will be empty.

Uninstaller will check for running instances of Vim once user press "Uninstall".

### Page 3: Uninstallation

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/uninstall/u3.png]]

### Page 4: Finish

[[https://github.com/gpwen/vim-installer-mui2/raw/wiki-files/screenshots/uninstall/u4.png]]
