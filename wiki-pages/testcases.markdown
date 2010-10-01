# Test Cases for the Upgraded Vim NSIS Installer

This document summarized some test cases for the upgraded Vim NSIS installer.
You're more than welcomed to run these cases, and report any problem you
found.  When you report problem found, please include the install log file
(vim-install.log) in your report.  The log file can be found in the Vim binary
directory (if the installer terminated normally) or in Windows temporary
directory (if the installer aborted, or you uninstalled Vim only).

## Installer Test

### I-1. Test Files Installed

1.  Compare files installed by the official installer and [[repacked official
    installer | repack]], they should be the same except those mentioned on
    the [[difference page | difference]].  Various install type should be
    tested.

2.  On 32-bit system, verify that only `gvimext32.dll` (32-bit version of Vim
    shell extension) is allowed to be installed, and will be installed
    correctly under Vim binary path.

3.  On 64-bit system, verify that both `gvimext32.dll` and `gvimext64.dll` can
    be installed correctly according to user selection under the Vim binary
    path.

4.  Verify that shell extension DLL(s) won't be removed by old uninstaller
    upon reboot:
    * Install Vim using the official installer.
    * Use "Edit With Vim" context menu to open at least one file to make sure
      the shell extension DLL has been loaded by the file explorer.
    * Install Vim again using the upgraded installer, let the installer
      uninstall the version installed above.  When asked, remove executables
      of the old version.  You should find the Vim binary directory can not be
      removed as the shell extension DLL (`gvimext.dll`) is still in use by
      the file explorer.
    * After upgraded installer finished, reboot the PC.
    * Now check `gvimext*.dll` under Vim binary directory.  `gvimext.dll`
      should be removed, while `gvimext32.dll` and/or `gvimext64.dll` should
      still be there.

### I-2. Test Icons

1.  Don't install desktop icons, verify that no icon has been added on your
    desktop.

2.  Install desktop icons, the following 3 icons should be added on the
    desktop:
    * `gVim 7.3`
    * `gVim Easy 7.3`
    * `gVim Read only 7.3`

    Verify that these icons function correctly.

3.  Don't installed start menu icons, verify that nothing has been added to
    the "Programs" folder of the start menu.

4.  Install start menu icons, verify that `Vim 7.3` folder has been added to
    the `Programs` folder of the start menu, and all items in that folder
    function correctly, especially the "Vim Online" shortcut.

5.  Don't install the console version, verify that shortcuts for console
    versions does not present in the start menu.

6.  Install console version, verify that shortcuts for console versions has
    been added in the start menu.

7.  Don't install quick launch bar icon, verify that nothing has been added
    to the quick launch bar.

8.  Install quick launch bar icon, verify that one Vim icon has been installed
    on the quick launch bar and functioned correctly.  Please note this won't
    work with Windows Vista and Windows 7 (there is no quick lanuch bar).

### I-3. Test Batch Files

1.  Install batch files, and verify the following commands work in DOS prompt:
    * `evim`
    * `gvim`
    * `view`
    * `vimdiff`
    * `gview`
    * `gvimdiff`
    * `vim`
    * `vimtutor`

    Test with various command line parameters, make sure they work as
    expected.

2.  Install Vim under a path with white spaces in name, run the above test
    again.

### I-4. Test Plugin Directory

1.  Don't define `HOME` environment string, the installer should only create
    `vimfiles` directory hierarchy under Vim install root directory.

2.  Define a `HOME` environment string and let the installer create the
    private plugin directory, verify that `vimfiles` directory hierarchy has
    been created under `$HOME`.

### I-5. Test Registry Change

1.  Install Vim context menu, verify that "gvim" has been listed in the
    "Recommended Programs" section of the "Open With &rarr; Choose Program
    ..." dialog for the following file types:
    * `.htm`
    * `.html`
    * `.vim`

    Also verify that "gvim" has been listed in the "Other Programs" section of
    the above dialog for all other file types.

2.  Install Vim context menu, verify that "Edit With Vim" item present on the
    context menu for all files.

3.  Open "Add or Remove Program" from control panel, verify that:
    * "Vim 7.3 (self-installing)" has been listed as currently installed
      programs.
    * The above item only supports "Remove" option.
    * The "Support Info" of the above items includes:
      * Version (7.3);
      * URL for Vim online;
      * URL for downloading the PC installer.

### I-6. Test OLE Registration

1.  Perform a clean install, verify that gvim will NOT show the OLE
    regitration warning (meaning that the OLE server has been register
    correctly) on the first lanuch.

## Uninstaller Test

### U-1. Test Files Removal

1.  Make sure you install only one version of Vim on your system, and no file
    has bee installed in the `vimfiles` directory.  Run the uninstaller, let
    it remove the config file, verify that vim install directory can be
    removed.

2.  Same as above, but put some file in the `vimfiles` directory, verify that
    the entire `vimfiles` directory hierarchy will be kept intact.

    Run the test for shared `vimfiles` directory and `vimfiles` directory
    under `$HOME`.

3.  Verify that vim batch files under Windows directory has been removed by
    the uninstaller.

4.  Change setting of the version string (`VIM_VER_NODOT` environment string)
    in some of those vim batch files under Windows directory, verify that
    unintaller does not remove those batch files.

    You can change the major, minor version number, or append some
    alphanumerics to the version number.

### U-3. Test Registry Change

1.  Verify that uninstall entry has been removed.

2.  Verify that "Open With ..." context menu items has been removed.

3.  Verify that "Edit With Vim" context menu item has been removed.
