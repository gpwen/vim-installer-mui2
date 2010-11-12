                                 USER MANUAL

Vim self-installing executable gvim##.exe is a Windows installer created using
NSIS.  It installs the following components of Vim:
    - GUI version of Vim with many features and OLE support;
    - A console version of Vim;
    - All the runtime files;
    - File explorer integration;
    - Native language support files etc.

It works well on MS-Windows 95/98/ME/NT/2000/XP/Vista/7.  Use this if you have
enough disk space and memory.  It's the simplest way to start using Vim on the
PC.  The installer allows you to skip the components you don't want.

The installer (and the associated uninstaller) has two modes:
    - Normal mode.  The installer runs in this mode by default.  It behaves as
      a normal Windows GUI installer.  A wizard like interface is used to let
      user set install options.
    - Silent mode.  Silent mode can be invoked with "/S" command line switch
      (case-sensitive).  When running in such mode, no user intervention is
      required and no user interface will be shown, all parameters can be
      specified on command line.  This is useful for unattended
      installation/uninstallation over large number of computers.  It is also
      useful for embedding Vim installer in another installer.  You can check
      NSIS document for detail:
        http://nsis.sourceforge.net/Docs/Chapter4.html#4.12

In the remaining part of this manual, we'll describe silent mode of the Vim
installer/uninstaller in detail.

1.  Exit Code and Install Log File

    Once started in silent mode, the installer will not produce any output
    (neither GUI nor console).  This is expected behavior of the NSIS
    installer.  You must check exit code of the installer to know whether the
    installation has succeeded or not.  A zero exit code means the
    installation went well; Non-zero exit code means some errors has occurred.

    A install log file will be created under Windows temporary directory (as
    specified by the TEMP environment string) by the installer:
        %TEMP%\vim-install.log
    The log file contains detailed log for all actions taken by the installer.
    If installation failed, the log file will be left under the temporary
    directory.  You can inspect that file for detailed error message.

    If installation succeeded, that log file will be moved into the binary
    subdirectory under Vim installation directory:
        <vim>\vim##

    Exit code for uninstaller is a little bit complex as the uninstaller will
    run itself automatically if it is started in default mode.  You can find
    detailed information here:
        http://nsis.sourceforge.net/Docs/AppendixD.html#D.1

    Uninstaller will also create a log file with the same name under the
    temporary directory.  The log file will be left in that directory if
    uninstaller is invoked directly.

2.  Uninstall Existing Vim Automatically

    It does not make too much sense for end user to install multiple versions
    of Vim on the same system.  The installer has to make system wide change
    for file explorer integration.  However, the installer does not prohibit
    such use.

    Once started, the installer will detect existing Vim versions on the
    system, and let user decide whether to keep them or not.  The installer
    can invoke appropriate uninstaller automatically once user decide to
    remove a version.  One exception is: if the same version as the one to be
    installed is detected on the system, it must be removed.

    However, automatic uninstallation could be complex in silent mode.  It's
    not easy to let user specify which version to keep since existing versions
    are detected dynamically.  Therefore, the installer will simply abort if
    any existing Vim found on the system, unless user specifies all old
    version should be removed with the /RMOLD command line switch.

    Another catch is: all uninstaller invoked by a silent installer should
    also run in silent mode.  Therefore, the installer will also check whether
    all involved uninstallers support silent mode or not.  If not, the
    installer will simply abort even if user allow uninstallation of those
    versions.  If you really want to use silent mode, those Vim versions have
    to be removed manually using GUI uninstaller first.

3.  Automatic Install Path Detection

    The installer determines install path with the following steps:
    - Install path specifies on command line with "/D=<dir>" has the highest
      priority.
    - If no install path specifies on command line, or the specified install
      path is invalid, the parent directory of the last installed Vim version,
      if any, will be used as root directory to construct the install path;
    - If that failed, the VIMRUNTIME environment string will be considered.
      The parent directory of the specified directory will be taken as root
      directory to construct install path if valid.
    - If that failed, VIM environment string will be checked next, and the
      specified directory will be used as install path directly if valid.
    - If that failed, the default instal path <program-files>\Vim will be
      used.

    In silent mode, automatic install path detection is disabled by default.
    The installer assumes user will specify a install path on the command
    line.  It will abort unless user specifies install path explicitly or
    enable automatic install path detection with "/DD" command line switch.
    The reason is NSIS will silently ignore the specified install path if it's
    invalid.  If automatic install path detection has been enabled, Vim will
    be installed into a different directory silently.  That could be an
    unpleasant surprise for the user.

4.  Components Selection from Command Line

    You can select components to install from command line.  Two types of
    command line switches can be used for such purpose:
    - /TYPE={FULL|TYPICAL|MIN} command line switch can be used to specify the
      installation type as "full", "typical" or "minimum", with "typical" as
      the default.
    - Command line switches like /CONSOLE, /BATCH can be used to select each
      component individually.

    The order of those command line switches is not important.  The installer
    will process install type switch first, and then component selection
    switches.

5.  Installer Command Line Switches

    All command line switches supported by the Vim installer are listed below:

        gvim##.exe [/TYPE={FULL|TYPICAL|MIN}] [/<OPTION>[{+|-}]]
                   [/S] [/NCRC] [/D=<dir>]

    Please note all command line switches can only be specified once,
    duplicated command line switches are considered as syntax error.

    The following command line switches are supported by NSIS natively, all of
    them are case-sensitive.  You can check NSIS document for detail:
        http://nsis.sourceforge.net/Docs/Chapter3.html#3.2

        /NCRC    Disables the CRC check, unless CRCCheck force was used in the
                 script.
        /S       Runs the installer silently.
        /D=<dir> Sets the default installation directory.  If specified, it must
                 be the last parameter used in the command line and must not
                 contain any quotes, even if the path contains spaces.  Only
                 absolute paths are supported.  Invalid path name will be ignored
                 silently!

    Install type can be selected with the following command line switch:
        /TYPE={FULL|TYPICAL|MIN}
                 Sets install type as full/typical/minimum.  The default is
                 typical.

    The remaining command line switches are used to fine tune install options,
    all of them are case-insensitive and follow the same syntax:
        /<OPTION>[{+|-}]
    It can be used like this:
        /<OPTION>+ or /<OPTION> to enable an option.
        /<OPTION>- to disable an option.

    The following options are used to tune installer behavior:
        DD         Allow automatic install directory detection under silent
                   mode.
        RMOLD      Allow uninstallation of existing Vim under silent mode.
        RMEXE      Remove executables when uninstall existing Vim.  This
                   option is enabled by default.
        RMRC       Remove config file when uninstall existing Vim.

    The following options are used to fine tune which component should be
    installed, after applying user specified installation type.
        CONSOLE    Install console version.
        BATCH      Install batch wrappers for Vim.
        DESKTOP    Add Vim shortcuts on the desktop.
        STARTMENU  Add Vim shortcuts in the start menu.
        QLAUNCH    Add Vim shortcut in the quick launch bar.
        SHEXT32    Add Vim to the "Open With..." context menu list for 32-bit
                   applications.
        SHEXT64    Add Vim to the "Open With..." context menu list for 64-bit
                   applications.
        VIMRC      Create a default config file (_vimrc) if one does not
                   already exist.
        PLUGINHOME Create plugin directories in HOME (if defined) or Vim
                   install directory.
        PLUGINCOM  Create plugin directories in Vim install directory, it is
                   used for everybody on the system.
        VISVIM     Install VisVim extension for Microsoft Visual Studio
                   integration.  Available only if the extension has been
                   included in the installer.
        NLS        Install files for native language support.  Available only
                   if the extension has been included in the installer.

6.  Uninstaller Command Line Switches

    Here's the list of all command line switches supported by the associated
    Vim uninstaller:

        uninstall-gui.exe [/<OPTION>[{+|-}]] [/S] [/NCRC] [/D=<dir>]

    Options /S, /NCRC and /D=<dir> is the same as the installer.  All of the
    command line switches specific to Vim un-installer follows the same syntax
    as the install options:
        /<OPTION>[{+|-}]

    The following options are supported:
        RMEXE Remove executables when uninstall Vim.  This option is enabled
              by default.
        RMRC  Remove config file when uninstall Vim.

7.  Caveats

    When specifies command line switches with arguments, like:
        /D=<dir>
    You should better avoid white spaces around the equal sign.  If you must
    add some white spaces, add them after the equal sign, never before it.
    Otherwise the command line parser can not recognize the switch.

8.  Examples

    The following are some examples for silent mode.  Please note the "/S"
    switch must be specified if you need the installer run in silent.

    - Typical install of Vim, detect install path automatically.  This command
      will succeed only if no Vim has been installed on the system:
        gvim##.exe /S /DD

    - Typical install of Vim under "C"\Vim", uninstall all existing versions.
      Please note install path must be specified as the last command line
      switch.
        gvim##.exe /S /RMOLD /D=C:\Vim

    - Full install of Vim under "C"\Vim", uninstall all existing versions:
        gvim##.exe /S /RMOLD /TYPE=FULL /D=C:\Vim

    - Full install of Vim under "C"\Vim", sans console version, and uninstall
      all existing versions:
        gvim##.exe /S /RMOLD /CONSOLE- /TYPE=FULL /D=C:\Vim

    - Typical install of Vim, don't care where it installed, and uninstall all
      existing versions as well as the config file:
        gvim##.exe /S /RMOLD /RMRC /DD

------------------------------------------------------------------------------

                               DEVELOPER MANUAL

Files in this directory are used to build the Vim self-installing executable
(NSIS installer) for Windows with Nullsoft Scriptable Install System (NSIS).
The following guide shows how to build the installer.

1.  Software requirement:

    - NSIS (2.46 or above).  This is required to build the installer.  It's
      available at:
        http://nsis.sourceforge.net/
      The NSIS install directory should be added to the PATH environment.

    - UPX.  This is required if you want a compressed installer.  It's
      available at:
        http://upx.sourceforge.net/
      The UPX install directory should be added to the PATH environment.

    - Build environment for Vim.

2.  Prepare Vim source code for DOS/Windows build

    To build the Windows installer, the source tree of Vim needs to be
    rearranged, and also some EOL conversion needs to be performed.

    You can simply download the following two prepared source archives from
    Vim online (http://www.vim.org/download.php#pc):
	PC sources    (vim##src.zip)
	Runtime files (vim##rt.zip)
    and unpack them to your build directory.

    You can also generated those archives yourself from the latest Vim source
    code, see the Makefile in the top directory for detail.  You need a
    UNIX-like environment for such purpose, those archives can be generated
    with the following make commands:
        make dossrc
        make dosrt

3.  Go to the src\ directory and build Windows 95/98/ME console version of
    Vim.  Rename the output vim.exe as vimd32.exe and store it elsewhere.

4.  Go to the src\ directory and build Windows NT/2000/XP console version of
    Vim.  Rename the output vim.exe as vimw32.exe and store it elsewhere.

5.  Go to the src\ directory and build the GUI version of Vim, with OLE
    support enabled.  After build complete, you should rename the following
    outputs:
	src\gvim.exe    -> src\gvim_ole.exe
	src\xxd\xxd.exe -> src\xxdw32.exe

6.  Copy those renamed executables created in steps 3 and 4 back into the src\
    directory.

7.  Go to the src\GvimExt\ directory and
    - Build 32-bit version of gvimext.dll, rename it to gvimext32.dll;
    - Build 64-bit version of gvimext.dll, rename it to gvimext64.dll.
    You may install the official release of Vim from here:
        http://www.vim.org/download.php#pc
    and copy them from the binary directory.

8.  Go to the src\VisVim\ directory and build VisVim.dll (or get it from
    installed Vim).

9.  Get a "diff.exe" program (for example, from installed Vim) and put it in
    the "..\.." directory (above the "vim##" directory, it's the same for all
    Vim versions).

10. Go to src\nsis\ to build the installer with:
	makensis gvim.nsi
