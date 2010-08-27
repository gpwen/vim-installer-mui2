@echo off
rem -- Run Vim --

rem The following lines specify global settings to run vim/gvim:
rem VIM_EXE_NAME  : Name of the executable to run (no path).
rem VIM_EXE_ARG   : Arguments for the executable.
rem VIM_VER_NODOT : Vim version, without dot.
rem VIM_EXE_DIR   : Vim install path.
<<BATCH-CONFIG>>

if exist "%VIM%\%VIM_VER_NODOT%\%VIM_EXE_NAME%" set VIM_EXE_DIR=%VIM%\%VIM_VER_NODOT%
if exist "%VIMRUNTIME%\%VIM_EXE_NAME%" set VIM_EXE_DIR=%VIMRUNTIME%

if exist "%VIM_EXE_DIR%\%VIM_EXE_NAME%" goto havevim
echo "%VIM_EXE_DIR%\%VIM_EXE_NAME%" not found
goto eof

:havevim
rem collect the arguments in VIMARGS for Win95
set VIMARGS=
set VIMNOFORK=
:loopstart
if .%1==. goto loopend
if NOT .%1==.-f goto noforkarg
set VIMNOFORK=1
:noforkarg
set VIMARGS=%VIMARGS% %1
shift
goto loopstart
:loopend

if .%OS%==.Windows_NT goto ntaction

if .%VIMNOFORK%==.1 goto nofork
start "%VIM_EXE_DIR%\%VIM_EXE_NAME%" %VIM_EXE_ARG% %VIMARGS%
goto eof

:nofork
start /w "%VIM_EXE_DIR%\%VIM_EXE_NAME%" %VIM_EXE_ARG% %VIMARGS%
goto eof

:ntaction
rem for WinNT we can use %*
if .%VIMNOFORK%==.1 goto noforknt
start "dummy" /b "%VIM_EXE_DIR%\%VIM_EXE_NAME%" %VIM_EXE_ARG% %*
goto eof

:noforknt
start "dummy" /b /wait "%VIM_EXE_DIR%\%VIM_EXE_NAME%" %VIM_EXE_ARG% %*

:eof

rem Clear all environment strings we use:
set VIM_EXE_NAME=
set VIM_EXE_ARG=
set VIM_VER_NODOT=
set VIM_EXE_DIR=
set VIMARGS=
set VIMNOFORK=
