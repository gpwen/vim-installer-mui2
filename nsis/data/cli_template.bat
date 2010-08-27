@echo off
rem -- Run Vim --

rem The following lines specify global settings to run vim/gvim:
rem VIM_EXE_NAME  : Name of the executable to run (no path).
rem VIM_EXE_ARG   : Arguments for the executable.
rem VIM_VER_NODOT : Vim version, without dot.
<<BATCH-CONFIG>>

if exist "%VIM%\%VIM_VER_NODOT%\%VIM_EXE_NAME%" set VIM_EXE_DIR=%VIM%\%VIM_VER_NODOT%
if exist "%VIMRUNTIME%\%VIM_EXE_NAME%" set VIM_EXE_DIR=%VIMRUNTIME%

if exist "%VIM_EXE_DIR%\%VIM_EXE_NAME%" goto havevim
echo "%VIM_EXE_DIR%\%VIM_EXE_NAME%" not found
goto eof

:havevim
rem collect the arguments in VIMARGS for Win95
set VIMARGS=
:loopstart
if .%1==. goto loopend
set VIMARGS=%VIMARGS% %1
shift
goto loopstart
:loopend

if .%OS%==.Windows_NT goto ntaction

"%VIM_EXE_DIR%\%VIM_EXE_NAME%" %VIM_EXE_ARG% %VIMARGS%
goto eof

:ntaction
rem for WinNT we can use %*
"%VIM_EXE_DIR%\%VIM_EXE_NAME%" %VIM_EXE_ARG% %*
goto eof


:eof

rem Clear all environment strings we used:
set VIM_EXE_NAME=
set VIM_EXE_ARG=
set VIM_VER_NODOT=
set VIM_EXE_DIR=
set VIMARGS=
set VIMNOFORK=
