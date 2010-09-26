# Test Cases for the New Vim NSIS Installer

This document summarized some test cases for the new Vim NSIS installer.
You're more than welcomed to run these cases, and report any problem you
found.

## Installer Test

### I-1. Test Files Installed

1.  Compare files installed by the official installer and
    [[repacked official installer |
    http://wiki.github.com/gpwen/vim-installer-mui2/repack]], they should be
    the same except those mentioned on the
    [[difference page |
    http://wiki.github.com/gpwen/vim-installer-mui2/difference]].  Various
    install type should be tested.

2.  On 32-bit system, verifies that only `gvimext32.dll` (32-bit version of
    Vim shell extension) is allowed to be installed, and will be installed
    correctly under Vim binary path.

3.  On 64-bit system, verifies that `gvimext32.dll` and `gvimext64.dll` will
    be installed correctly according to user selection under Vim binary path.

4.  Make sure shell extension DLL(s) won't be removed unexpected by old
    uninstaller upon reboot:
    * Install Vim using the official installer.
    * Use "Edit With Vim" context menu to open at least one file to make sure
      the shell extension DLL has been loaded by the file explorer.
    * Install Vim again using the new installer, let the installer uninstall
      the version installed above.  When asked, remove executables of the old
      version.  You should find the Vim binary directory can not be removed as
      the shell extension DLL (`gvimext.dll`) is still in use by file
      explorer.
    * After new installer finished, reboot the PC.
    * Now check `gvimext*.dll` under Vim binary directory.  `gvimext.dll`
      should be removed, while `gvimext32.dll` and/or `gvimext64.dll` should
      still be there.

### I-2. Test Icons

1.  Don't install desktop icons, make sure no icon will be added on your
    desktop.

2.  Install desktop icons, the following 3 icons should be installed on the
    desktop:
    * gVim 7.3
    * gVim Easy 7.3
    * gVim Read only 7.3

    Check to make sure they functioned correctly.

3.  Don't installed start menu icons, make sure nothing has been added to the
    "Programs" folder of the start menu.

4.  Installed start menu icons, make sure "Vim 7.3" folder will be added to
    the "Programs" folder of the start menu, and all items in that fold
    functioned correctly, especially the "Vim Online" shortcut.

5.  Install/don't install console version, make sure shortcuts for console
    versions will/will not present in the start menu.

6.  Install Vim menu on quick launch bar, make sure it's installed and
    functioned correctly.  Please note this won't work with Windows Vista and
    Windows 7 (there is no quick lanuch bar).

### I-3. Test Batch Files

1.  Install batch files, and verify the following commands work in DOS prompt:
    * evim
    * gvim
    * view
    * vimdiff
    * gview
    * gvimdiff
    * vim
    * vimtutor

    Test with various command line parameters, make sure they work as
    expected.

2.  Also run the above test with Vim installed under folders with white spaces
    in name.

### I-4. Test Plugin Directory

### I-5. Test Registry Change

### I-6. Test OLE Registration

## Uninstaller Test

### U-1. Test Files Removal

1.  Removal of install root.

2.  Removal of batch files.

### U-2. Test Plugin Directory Removal

### U-3. Test Registry Change
