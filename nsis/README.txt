                                 USER MANUAL

Files in this directory are used to build the Vim self-installing executable
for Windows, which can be downloaded from:
    http://www.vim.org/download.php#pc

The installer is created using NSIS (Nullsoft Scriptable Install System).  You
can run it as a normal Windows GUI installer (click and run); You can also run
it from command line, in which case you have the ability to fine tune
installation parameters using command line switches.

This installer (and the associated uninstaller) also supports silent mode,
which can enabled with "/S" command line switch.  When running in such mode,
no user intervention is required and no user interface will be shown, all
parameters can/should be specified on command line.  This is useful for
unattended installation/uninstallation over large number of computers.  It is
also useful for embedding Vim installer in another installer.  You can check
NSIS document for detail:
    http://nsis.sourceforge.net/Docs/Chapter4.html#4.12

Here's the list of all command line switches supported by the Vim installer:
    gvim##.exe [/TYPE={FULL|TYPICAL|MIN}] [/<OPTION>[{+|-}]]
               [/S] [/NCRC] [/D=<dir>]

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

You can set install type with the following command line switch:
    /TYPE={FULL|TYPICAL|MIN} Sets install type as full/typical/minimum.

All of the command line switches listed below are specific to Vim installer,
they all follows the same syntax and are case-insensitive:
    /<OPTION>[{+|-}]
It can be used like this:
    /<OPTION>+ or /<OPTION> to enable an option.
    /<OPTION>- to disable an option.

The following options are used to tune installer behavior:
    DD         Allow automatic install directory detection under silent mode.
    RMOLD      Allow uninstallation of existing Vim under silent mode.
    RMEXE      Remove executables when uninstall existing Vim.  This option is
               enabled by default.
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
    VIMRC      Create a default config file (_vimrc) if one does not already
               exist.
    PLUGINHOME Create plugin directories in HOME (if you defined one) or Vim
               install directory.
    PLUGINCOM  Create plugin directories in Vim install directory, it is used
               for everybody on the system.
    VISVIM     Install VisVim extension for Microsoft Visual Studio
               integration.  Available only if the extension has been included
               in the installer.
    NLS        Install files for native language support.  Available only if
               the extension has been included in the installer.

Here's the list of all command line switches supported by the associated Vim
uninstaller:
    uninstall-gui.exe [/<OPTION>[{+|-}]] [/S] [/NCRC] [/D=<dir>]

Options /S, /NCRC and /D=<dir> is the same as the installer.  All of the
command line switches specific to Vim un-installer follows the same syntax as
the installer:
    /<OPTION>[{+|-}]

The following options are supported:
    RMEXE Remove exectuables when uninstall Vim.  This option is enabled by
          default.
    RMRC  Remove config file when uninstall Vim.

------------------------------------------------------------------------------

                               DEVELOPER MANUAL

This builds a one-click install for Vim for Win32 using the Nullsoft
Installation System (NSIS).

To build the installable .exe:

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

2.  Unpack the following two archives:
	PC sources (vim##src.zip)
	PC runtime (vim##rt.zip)
    You can generate these from the Unix sources and runtime plus the extra
    archive (see the Makefile in the top directory).

3.  Go to the src directory and build:
	gvim.exe (the OLE version),
	vimrun.exe,
	xxd/xxd.exe

4.  Go to the GvimExt directory and build gvimext32.dll (32-bit version) as
    well as gvimext64.dll (64-bit version).  You may get them from a binary
    archive.

5.  Go to the VisVim directory and build VisVim.dll (or get it from a binary
    archive).

6.  Get a "diff.exe" program and put it in the "../.." directory (above the
    "vim61" directory, it's the same for all Vim versions).
    You can find one in previous Vim versions or in this archive:
		http://www.mossbayeng.com/~ron/vim/diffutils.tar.gz

To build then, enter:

	makensis gvim.nsi
