# Difference in Upgraded Vim NSIS Installer

This document summarized difference in the upgraded Vim NSIS installer as
compared to the official installer.

## Difference in Installed Files

The following installed files are different from what installed by the
official installer:

*   `<vim-bin-path>\install.exe` and `<vim-bin-path>\uninstal.exe`

    These files are no longer installed by the upgraded installer.

*   `<vim-bin-path>\gvimext.dll`

    This file has been split into two files with the upgraded installer:
    `<vim-bin-path>\gvimext32.dll` for 32-bit version and
    `<vim-bin-path>\gvimext64.dll` for 64-bit version.  Please note both files
    could present on 64-bit system depending on install options.

*   `<vim-bin-path>\vim-install.log`

    This install log will only be created by the upgraded installer.

*   `<vim-install-root>\_vimrc`

    This file has been changed to add a few comments.  Its content is static,
    stored directly in [[this file |
    https://github.com/gpwen/vim-installer-mui2/raw/master/nsis/data/mswin_vimrc.vim]].

*   `<windows-path>\*vim*.bat` and `<windows-dir>\*view.bat`

    These batch files are now generated from two templates, one for [[GUI
    version |
    https://github.com/gpwen/vim-installer-mui2/raw/master/nsis/data/gui_template.bat]]
    and one for [[console version |
    https://github.com/gpwen/vim-installer-mui2/raw/master/nsis/data/cli_template.bat]].
    The content of these batch files are modified to make it suitable to be
    generated from templates.  It should function the same as that generated
    by the official installer.

## Difference in Windows Registry Handling

*   More values will be added to Vim uninstall key by the upgraded installer,
    such as `DisplayVersion`, `NoModify`, `NoRepair`, `HelpLink` _etc._

*   gVim will be registered with "Open With ..." context menu of more file
    extensions with the upgraded installer: `.html`

*   The upgraded uninstaller will remove `.vim` file extension if that key is
    empty.  This file extension should be specific to Vim.

## Difference in Uninstaller

*   The official uninstaller will ask user if vim plugin directories and vim
    RC files should be removed or not.

    The upgraded uninstaller will determine that automatically:
    *   Plugin directories will be removed if:
        *   The Vim being removed is the last one on the system; and
        *   No file found under any of those plugin directories.
    *   Vim RC file will be removed if:
        *   The Vim being removed is the last one on the system; and
        *   User choose to remove Vim executables (default behavior); and
        *   `_vimrc` (or its variants) is still the same as the one installed
            (compared against a copy stored in the uninstaller itself).

*   The official uninstaller will try to remove extension DLLs directly.  If
    those DLLs are still in use (which is very likely), the Vim executable
    directory cannot be removed without a reboot.

    The upgraded uninstaller will move those DLLs into a temporary location,
    and remove them from their if they are still in use.  As a result, Vim
    install directory can be removed directly without any reboot.

*   The official uninstaller will try to remove files using wildcards,
    recursive directory removal commands are also used.  This may removes
    extra files installed in Vim directory by user, such as user manual for
    other languages.

    The upgraded uninstaller will remove exactly the same set of files as
    installed by the installer.  In fact, install and uninstall commands are
    generated dynamically from the same config.  Therefore, extra files
    installed by user in Vim directory will be kept intact.
