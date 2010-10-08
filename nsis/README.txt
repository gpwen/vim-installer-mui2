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
