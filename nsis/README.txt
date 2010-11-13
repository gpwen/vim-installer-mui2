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

User manual of the installer can be found here:
    nsis/data/install_manual.txt
