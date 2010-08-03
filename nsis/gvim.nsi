# NSIS file to create a self-installing exe for Vim.
# It requires NSIS version 2.0 or later.
# Last change:	2004 May 02

# WARNING: if you make changes to this script, look out for $0 to be valid,
# because uninstall deletes most files in $0.

# Location of gvim_ole.exe, vimd32.exe, GvimExt/*, etc.
!define VIMSRC "..\src"

# Location of runtime files
!define VIMRT ".."

# Location of extra tools: diff.exe
!define VIMTOOLS ..\..

# Comment the next line if you don't have UPX.
# Get it at http://upx.sourceforge.net
!define HAVE_UPX

# comment the next line if you do not want to add Native Language Support
!define HAVE_NLS

!define VER_MAJOR 7
!define VER_MINOR 3b

# ----------- No configurable settings below this line -----------

!include MUI2.nsh
!include UpgradeDLL.nsh		# for VisVim.dll
!include LogicLib.nsh
!include x64.nsh

Name "Vim ${VER_MAJOR}.${VER_MINOR}"
OutFile gvim${VER_MAJOR}${VER_MINOR}.exe
CRCCheck force
SetCompressor lzma
SetDatablockOptimize on
BrandingText " "
RequestExecutionLevel highest

!define MUI_ICON "icons\vim_16c.ico"
# NSIS2 uses a different strategy with six diferent images in a strip...
#EnabledBitmap icons\enabled.bmp
#DisabledBitmap icons\disabled.bmp
!define MUI_UNICON "icons\vim_uninst_16c.ico"

# On NSIS 2 using the BGGradient causes trouble on Windows 98, in combination
# with the BringToFront.
# BGGradient 004000 008200 FFFFFF
!define MUI_COMPONENTSPAGE_TEXT_TOP "This will install Vim ${VER_MAJOR}.${VER_MINOR} on your computer."
!define MUI_DIRECTORYPAGE_TEXT_TOP  "Choose a directory to install Vim (must end in 'vim')"
!define MUI_LICENSEPAGE_TEXT_TOP    "You should read the following before installing:"
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_FINISHPAGE_RUN "$0\gvim.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Show REDAME after I finish"
!define MUI_FINISHPAGE_RUN_PARAMETERS "-R $\"$0\README.txt$\""
#!define MUI_FINISHPAGE_REBOOTLATER_DEFAULT
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!define MUI_UNFINISHPAGE_NOREBOOTSUPPORT

!define MUI_UNCONFIRMPAGE_TEXT_TOP "This will uninstall Vim ${VER_MAJOR}.${VER_MINOR} from your system."

!ifdef HAVE_UPX
  !packhdr temp.dat "upx --best --compress-icons=1 temp.dat"
!endif

# This adds '\vim' to the user choice automagically.  The actual value is
# obtained below with ReadINIStr.
InstallDir "$PROGRAMFILES\Vim"

# Types of installs we can perform:
InstType Typical
InstType Minimal
InstType Full

SilentInstall normal

##########################################################
# Installer pages
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "${VIMRT}\doc\uganda.nsis.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckInstallDir
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  # Uninstaller pages:
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_COMPONENTS
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

##########################################################
# Languages
  !insertmacro MUI_LANGUAGE "English"
  !insertmacro MUI_LANGUAGE "SimpChinese"

##########################################################
# Functions

Function .onInit
  MessageBox MB_YESNO|MB_ICONQUESTION \
	"This will install Vim ${VER_MAJOR}.${VER_MINOR} on your computer.$\n Continue?" \
	IDYES NoAbort
	    Abort ; causes installer to quit.
	NoAbort:

  # run the install program to check for already installed versions
  SetOutPath $TEMP
  File /oname=install.exe ${VIMSRC}\installw32.exe
  ExecWait "$TEMP\install.exe -uninstall-check"
  Delete $TEMP\install.exe

  # We may have been put to the background when uninstall did something.
  BringToFront

  # Install will have created a file for us that contains the directory where
  # we should install.  This is $VIM if it's set.  This appears to be the only
  # way to get the value of $VIM here!?
  ReadINIStr $INSTDIR $TEMP\vimini.ini vimini dir
  Delete $TEMP\vimini.ini

  # If ReadINIStr failed or did not find a path: use the default dir.
  StrCmp $INSTDIR "" 0 IniOK
  StrCpy $INSTDIR "$PROGRAMFILES\Vim"
  IniOK:

  # Should check for the value of $VIM and use it.  Unfortunately I don't know
  # how to obtain the value of $VIM
  # IfFileExists "$VIM" 0 No_Vim
  #   StrCpy $INSTDIR "$VIM"
  # No_Vim:

  # User variables:
  # $0 - holds the directory the executables are installed to
  # $1 - holds the parameters to be passed to install.exe.  Starts with OLE
  #      registration (since a non-OLE gvim will not complain, and we want to
  #      always register an OLE gvim).
  # $2 - holds the names to create batch files for
  StrCpy $0 "$INSTDIR\vim${VER_MAJOR}${VER_MINOR}"
  StrCpy $1 "-register-OLE"
  StrCpy $2 "gvim evim gview gvimdiff vimtutor"

FunctionEnd

#Function .onUserAbort
#  MessageBox MB_YESNO|MB_ICONQUESTION "Abort install?" IDYES NoCancelAbort
#    Abort ; causes installer to not quit.
#  NoCancelAbort:
#FunctionEnd

# We only accept the directory if it ends in "vim".  Using .onVerifyInstDir has
# the disadvantage that the browse dialog is difficult to use.
Function CheckInstallDir
  StrCpy $0 $INSTDIR 3 -3
  StrCmp $0 "vim" PathGood
    MessageBox MB_OK "The path must end in 'vim'."
    Abort
  PathGood:
FunctionEnd

Function .onInstSuccess
  WriteUninstaller vim${VER_MAJOR}${VER_MINOR}\uninstall-gui.exe
FunctionEnd

Function .onInstFailed
  MessageBox MB_OK|MB_ICONEXCLAMATION "Installation failed. Better luck next time."
FunctionEnd

Function un.GetParent
  Exch $0 ; old $0 is on top of stack
  Push $1
  Push $2
  StrCpy $1 -1
  loop:
    StrCpy $2 $0 1 $1
    StrCmp $2 "" exit
    StrCmp $2 "\" exit
    IntOp $1 $1 - 1
  Goto loop
  exit:
    StrCpy $0 $0 $1
    Pop $2
    Pop $1
    Exch $0 ; put $0 on top of stack, restore $0 to original value
FunctionEnd

##########################################################
Section "Vim executables and runtime files"
	SectionIn 1 2 3 RO

	# we need also this here if the user changes the instdir
	StrCpy $0 "$INSTDIR\vim${VER_MAJOR}${VER_MINOR}"

	SetOutPath $0
	File /oname=gvim.exe ${VIMSRC}\gvim_ole.exe
	File /oname=install.exe ${VIMSRC}\installw32.exe
	File /oname=uninstal.exe ${VIMSRC}\uninstalw32.exe
	File ${VIMSRC}\vimrun.exe
	File /oname=xxd.exe ${VIMSRC}\xxdw32.exe
	File ${VIMTOOLS}\diff.exe
	File ${VIMRT}\vimtutor.bat
	File ${VIMRT}\README.txt
	File ..\uninstal.txt
	File ${VIMRT}\*.vim
	File ${VIMRT}\rgb.txt

	SetOutPath $0\colors
	File ${VIMRT}\colors\*.*

	SetOutPath $0\compiler
	File ${VIMRT}\compiler\*.*

	SetOutPath $0\doc
	File ${VIMRT}\doc\*.txt
	File ${VIMRT}\doc\tags

	SetOutPath $0\ftplugin
	File ${VIMRT}\ftplugin\*.*

	SetOutPath $0\indent
	File ${VIMRT}\indent\*.*

	SetOutPath $0\macros
	File ${VIMRT}\macros\*.*

	SetOutPath $0\plugin
	File ${VIMRT}\plugin\*.*

	SetOutPath $0\autoload
	File ${VIMRT}\autoload\*.*

	SetOutPath $0\autoload\xml
	File ${VIMRT}\autoload\xml\*.*

	SetOutPath $0\syntax
	File ${VIMRT}\syntax\*.*

	SetOutPath $0\spell
	File ${VIMRT}\spell\*.txt
	File ${VIMRT}\spell\*.vim
	File ${VIMRT}\spell\*.spl
	File ${VIMRT}\spell\*.sug

	SetOutPath $0\tools
	File ${VIMRT}\tools\*.*

	SetOutPath $0\tutor
	File ${VIMRT}\tutor\*.*
SectionEnd

##########################################################
Section "Vim console program (vim.exe)"
	SectionIn 1 3

	SetOutPath $0
	ReadRegStr $R0 HKLM \
	   "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
	${If} ${Errors}
	    # Windows 95/98/ME
	    File /oname=vim.exe ${VIMSRC}\vimd32.exe
	${Else}
	    # Windows NT/2000/XT
	    File /oname=vim.exe ${VIMSRC}\vimw32.exe
	${EndIf}
	StrCpy $2 "$2 vim view vimdiff"
SectionEnd

##########################################################
Section "Create .bat files for command line use"
	SectionIn 3

	StrCpy $1 "$1 -create-batfiles $2"
SectionEnd

##########################################################
Section "Create icons on the Desktop"
	SectionIn 1 3

	StrCpy $1 "$1 -install-icons"
SectionEnd

##########################################################
Section "Add Vim to the Start Menu"
	SectionIn 1 3

	StrCpy $1 "$1 -add-start-menu"
SectionEnd

##########################################################
Section "Add an Edit-with-Vim context menu entry"
	SectionIn 1 3

	# Be aware of this sequence of events:
	# - user uninstalls Vim, gvimext.dll can't be removed (it's in use) and
	#   is scheduled to be removed at next reboot.
	# - user installs Vim in same directory, gvimext.dll still exists.
	# If we now skip installing gvimext.dll, it will disappear at the next
	# reboot.  Thus when copying gvimext.dll fails always schedule it to be
	# installed at the next reboot.  Can't use UpgradeDLL!
	# We don't ask the user to reboot, the old dll will keep on working.
	SetOutPath $0
	ClearErrors
	SetOverwrite try
	${If} ${RunningX64}
	  File /oname=gvimext.dll ${VIMSRC}\GvimExt\gvimext64.dll
	${Else}
	  File /oname=gvimext.dll ${VIMSRC}\GvimExt\gvimext.dll
	${EndIf}

        ${If} ${Errors}
          # Can't copy gvimext.dll, create it under another name and rename it
          # on next reboot.
          GetTempFileName $3 $0
          ${If} ${RunningX64}
            File /oname=$3 ${VIMSRC}\GvimExt\gvimext64.dll
          ${Else}
            File /oname=$3 ${VIMSRC}\GvimExt\gvimext.dll
          ${EndIf}
          Rename /REBOOTOK $3 $0\gvimext.dll
        ${EndIf}

	SetOverwrite lastused

	# We don't have a separate entry for the "Open With..." menu, assume
	# the user wants either both or none.
	StrCpy $1 "$1 -install-popup -install-openwith"
SectionEnd

##########################################################
Section "Create a _vimrc if it doesn't exist"
	SectionIn 1 3

	StrCpy $1 "$1 -create-vimrc"
SectionEnd

##########################################################
Section "Create plugin directories in HOME or VIM"
	SectionIn 1 3

	StrCpy $1 "$1 -create-directories home"
SectionEnd

##########################################################
Section "Create plugin directories in VIM"
	SectionIn 3

	StrCpy $1 "$1 -create-directories vim"
SectionEnd

##########################################################
# Section "VisVim Extension for MS Visual Studio"
# 	SectionIn 3
#
# 	SetOutPath $0
# 	!insertmacro UpgradeDLL "${VIMSRC}\VisVim\VisVim.dll" "$0\VisVim.dll" "$0"
# 	File ${VIMSRC}\VisVim\README_VisVim.txt
# SectionEnd

##########################################################
!ifdef HAVE_NLS
	Section "Native Language Support"
		SectionIn 1 3

		SetOutPath $0\lang
		File /r ${VIMRT}\lang\*.*
		SetOutPath $0\keymap
		File ${VIMRT}\keymap\README.txt
		File ${VIMRT}\keymap\*.vim
		SetOutPath $0
		File ${VIMRT}\libintl.dll
		File ${VIMRT}\iconv.dll
	SectionEnd
!endif

##########################################################
Section -call_install_exe
	SetOutPath $0
	ExecWait "$0\install.exe $1"
SectionEnd

##########################################################
Section -post
	BringToFront
SectionEnd

##########################################################
Section "un.Remove gvim"
	# Apparently $INSTDIR is set to the directory where the uninstaller is
	# created.  Thus the "vim61" directory is included in it.
	StrCpy $0 "$INSTDIR"

	# If VisVim was installed, unregister the DLL.
	${If} ${FileExists} "$0\VisVim.dll"
	  ExecWait "regsvr32.exe /u /s $0\VisVim.dll"
        ${EndIf}

	# delete the context menu entry and batch files
	ExecWait "$0\uninstal.exe -nsis"

	# We may have been put to the background when uninstall did something.
	BringToFront

SectionEnd

Section "un.Remove VIM Excutables/Runtime Files"
  # It contains the Vim executables and runtime files.

  Delete /REBOOTOK $0\*.dll
  ClearErrors

  # Remove everything but *.dll files.  Avoids that
  # a lot remains when gvimext.dll cannot be deleted.
  RMDir /r $0\autoload
  RMDir /r $0\colors
  RMDir /r $0\compiler
  RMDir /r $0\doc
  RMDir /r $0\ftplugin
  RMDir /r $0\indent
  RMDir /r $0\macros
  RMDir /r $0\plugin
  RMDir /r $0\spell
  RMDir /r $0\syntax
  RMDir /r $0\tools
  RMDir /r $0\tutor
  RMDir /r $0\VisVim
  RMDir /r $0\lang
  RMDir /r $0\keymap
  Delete $0\*.exe
  Delete $0\*.bat
  Delete $0\*.vim
  Delete $0\*.txt

  ${If} ${Errors}
    MessageBox MB_OK|MB_ICONEXCLAMATION \
      "Some files in $0 have not been deleted!$\nYou must do it manually."
  ${EndIf}

  # No error message if the "vim62" directory can't be removed, the
  # gvimext.dll may still be there.
  RMDir /r /REBOOTOK $0

SectionEnd

Section "un.Remove VIM Plugin Directory (vimfiles)"
  # get the parent dir of the installation
  Push $INSTDIR
  Call un.GetParent
  Pop $0
  StrCpy $1 $0

  # if a plugin dir was created at installation ask the user to remove it
  # first look in the root of the installation then in HOME
  IfFileExists $1\vimfiles AskRemove 0
      ReadEnvStr $1 "HOME"
      StrCmp $1 "" NoRemove 0

      IfFileExists $1\vimfiles 0 NoRemove

    AskRemove:
      # If you have created something there that you want to keep, click No
      RMDir /r /REBOOTOK $1\vimfiles
    NoRemove:
SectionEnd

Section "un.Remove VIM Root Directory ($0)"
  Push $INSTDIR
  Call un.GetParent
  Pop $0
  StrCpy $1 $0

  # It contains your Vim configuration files!" IDNO NoDelete
  RMDir /r /REBOOTOK $0 ; skipped if no
SectionEnd
