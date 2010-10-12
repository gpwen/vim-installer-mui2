# Features of the Upgraded Vim NSIS Installer

New features introduced by the upgraded Vim NSIS installer includes:

* Upgraded to Modern UI (MUI) 2.0.  Now NSIS 2.34 is the minimum
  requirement.

* Installation/uninstallation are now performed natively with NSIS script,
  external "install.exe" and "uninstal.exe" are no longer necessary.  This
  eliminates all (ugly) DOS command windows in installer/uninstaller.

* It's now possible to install both 32-bit and 64-bit version of the shell
  extension on 64-bit systems.  This make it possible for 32-bit file
  explorer-like applications continue to use Vim context menu on 64-bit
  systems.  This feature is suggested and tested by Leonardo Valeri Manera.

* Multiple language support (disabled by default).

* Install log.  A detailed install log (`vim-install.log`) will be created for
  debug purpose.

* User can choose whether to remove or keep existing Vim version(s) using the
  component list directly.

* Uninstaller are executed from NSIS script directly.

* Better way to uninstall/upgrade shell extension DLL (using Library.nsh).
  Now the DLL will be move to Windows temporary directory before deletion.
  This makes it possible to remove Vim install directory even if the DLL
  cannot be removed without a reboot.  It also solves the problem where newly
  installed DLL could be removed unintentionally after reboot.

* Detailed description for each component.

  MUI makes it possible to add detailed description for each
  component to be installed/removed.  If you hover the mouse pointer
  over the component list, detailed description of those components
  will be shown.  Such description is also used to explain the
  impact of component removal.

* Eliminated all pop-up message boxes used to ask for user input.

* Do not make any real change until all running instances of Vim have been
  closed.

* New artwork for installer.

# Features to be Added Soon (TODO List)

* (TODO) Silent install mode.
* (TODO) Translation for more languages.
