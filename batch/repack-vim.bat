@ECHO OFF

REM This batch file is used to repack Vim executable installer.
REM
REM Please note 7-Zip should be installed to use this script.  7-zip can be
REM downloaded from here:
REM     http://www.7-zip.org/
REM The install path of 7-Zip should be added to your PATH environment so your
REM can access "7z" command from the DOS prompt.
REM
REM If you need to rebuild the installer, you need to install NSIS:
REM     http://nsis.sourceforge.net/
REM The install path of NSIS should be added to your PATH environment so your
REM can access "makensis" command from the DOS prompt.
REM
REM Synopsis:
REM   repack-vim.bat [<vim-nsis-git>]
REM Where <vim-nsis-git> is an optional parameter specifies the full path name
REM of Vim nsis git.  If provided, the command will try to copy nsis scripts
REM from that directory and build a new NSIS installer.
REM
REM The new NSIS installer, if built, can be found in:
REM   vim-repack\vim\nsis
REM
REM Author: Guopeng Wen

REM Name of the latest official VIM installer:
SET VIM_INSTALLER=gvim73_46.exe

IF NOT EXIST "vim-repack" GOTO chk_installer
@ECHO ERROR : "vim-repack" already exist under the current directory,
@ECHO Please remove it before continue.
GOTO eof

:chk_installer
IF EXIST %VIM_INSTALLER% GOTO do_unpack
@ECHO ERROR : Cannot find official vim installer (%VIM_INSTALLER%)!
@ECHO You should run this command from the directory where you put that file.
GOTO eof

REM Unpack the installer, auto-rename duplicated files:
:do_unpack
MKDIR vim-repack
CD vim-repack
@ECHO u | 7z x ..\%VIM_INSTALLER%
IF %ERRORLEVEL% LEQ 1 GOTO do_rename
CD ..
@echo ERROR : Fail to unpack vim installer!
GOTO eof

REM Rename unpacked files:
:do_rename
MOVE  "$0" vim
XCOPY /E /H "$_OUTDIR\*" vim\lang
RMDIR /S /Q "$_OUTDIR"

CD    vim

REM lang\nb is an alias for lang\no, files under those directories are exactly
REM the same, it seems 7z cannot handle such case, lang\no has to be recovered
REM manually:
XCOPY /E /H /I lang\nb lang\no

REM $3* are exactly the same as gvimext*.dll:
DEL   /Q  "$3*"

MKDIR src
MOVE  gvim.exe          src\gvim_ole.exe
MOVE  install.exe       src\installw32.exe
MOVE  uninstal.exe      src\uninstalw32.exe
MOVE  vimrun.exe        src
MOVE  xxd.exe           src\xxdw32.exe
MOVE  diff.exe          ..

MOVE  vim.exe           src\vimd32.exe
MOVE  vim_1.exe         src\vimw32.exe

MKDIR src\GvimExt
MOVE  gvimext.dll       src\GvimExt\gvimext64.dll
MOVE  gvimext_1.dll     src\GvimExt\gvimext.dll

MKDIR src\VisVim
MOVE  "$R0"             src/VisVim/VisVim.dll
MOVE  README_VisVim.txt src/VisVim

RMDIR /S /Q "$R2" "$PLUGINSDIR"

IF NOT .%1==. GOTO copy_nsis_chk
CD ..\..
@ECHO Vim installer has been successfully unpacked into "vim-repack".
@ECHO You can now copy
@ECHO     "vim-git"\nsis
@ECHO to
@ECHO     vim-repack\vim
@ECHO and run "makensis gvim.nsi" from:
@ECHO     vim-repack\vim\nsis
GOTO eof

:copy_nsis_chk
IF EXIST "%1\nsis" GOTO copy_nsis
CD ..\..
@ECHO ERROR: %1 is not a valid vim-nsis git repository.
GOTO eof

:copy_nsis
RMDIR /S /Q nsis
MKDIR nsis
XCOPY /E /H "%1\nsis\*" nsis
CD nsis
makensis gvim.nsi
IF %ERRORLEVEL% LEQ 1 GOTO make_nsis_ok
@ECHO ERROR: Fail to run makensis!

:make_nsis_ok
CD ..\..\..
@ECHO Vim installer has been successfully repacked as:
@ECHO   vim-repack\vim\nsis\gvim73.exe

:eof
REM Clear working environment strings:
set VIM_INSTALLER=
