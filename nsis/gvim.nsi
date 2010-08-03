# vi:set ts=8 sts=4 sw=4:
#
# NSIS file to create a self-installing exe for Vim.
# It requires NSIS version 2.34 or later (for Modern UI 2.0).
# Last Change:	2010 Jul 30

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

# Comment the next line if you do not want to add Native Language Support
!define HAVE_NLS

# Commend the next line if you do not want to include VisVim extension:
!define HAVE_VIS_VIM

# Uncomment the following line to create a multilanguage installer:
#!define HAVE_MULTI_LANG

# Uncomment the following line so that the uninstaller would not jump to the
# finish page automatically, this allows the user to check the uninstall log.
# It's used for debug purpose.
#!define MUI_FINISHPAGE_NOAUTOCLOSE
#!define MUI_UNFINISHPAGE_NOAUTOCLOSE

!define VER_MAJOR 7
!define VER_MINOR 3d

# ---------------- No configurable settings below this line ------------------

!include MUI2.nsh
!include UpgradeDLL.nsh  # For VisVim.dll
!include Sections.nsh    # For section control
!include LogicLib.nsh
!include x64.nsh

# Global variables:
Var vim_install_root
Var vim_plugin_path

!define VIM_LNK_NAME  "gVim ${VER_MAJOR}.${VER_MINOR}"

Name                  "Vim ${VER_MAJOR}.${VER_MINOR}"
OutFile               gvim${VER_MAJOR}${VER_MINOR}.exe
CRCCheck              force
SetCompressor         lzma
SetDatablockOptimize  on
BrandingText          " "
RequestExecutionLevel highest

# This adds '\vim' to the user choice automagically.  The actual value is
# obtained below with ReadINIStr.
InstallDir            "$PROGRAMFILES\Vim"

# Types of installs we can perform:
InstType              $(str_type_typical)
InstType              $(str_type_minimal)
InstType              $(str_type_full)

SilentInstall         normal

# On NSIS 2 using the BGGradient causes trouble on Windows 98, in combination
# with the BringToFront.
# BGGradient 004000 008200 FFFFFF

##############################################################################
# MUI Settings
##############################################################################
!define MUI_ICON   "icons\vim_16c.ico"
!define MUI_UNICON "icons\vim_uninst_16c.ico"

# Show all languages, despite user's codepage:
!define MUI_LANGDLL_ALLLANGUAGES

!define MUI_DIRECTORYPAGE_TEXT_DESTINATION $(str_dest_folder)
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_FINISHPAGE_RUN                 "$0\gvim.exe"
!define MUI_FINISHPAGE_RUN_TEXT            $(str_show_readme)
!define MUI_FINISHPAGE_RUN_PARAMETERS      "-R $\"$0\README.txt$\""
!define MUI_FINISHPAGE_REBOOTLATER_DEFAULT
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!ifdef HAVE_UPX
    !packhdr temp.dat "upx --best --compress-icons=1 temp.dat"
!endif

# Registry key to save installer language selection.  It will be removed by
# the uninstaller:
!ifdef HAVE_MULTI_LANG
    !define MUI_LANGDLL_REGISTRY_ROOT      "HKLM"
    !define MUI_LANGDLL_REGISTRY_KEY       "SOFTWARE\Vim"
    !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
!endif

# Installer pages
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE UninstallOldVer
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${VIMRT}\doc\uganda.nsis.txt"
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CheckRunningVim
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

# Uninstaller pages:
!insertmacro MUI_UNPAGE_CONFIRM
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE un.CheckRunningVim
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

##############################################################################
# Languages Files
##############################################################################
# Please note English language file should be listed first as the first one
# will be used as the default.
!insertmacro MUI_RESERVEFILE_LANGDLL
!include lang-english.nsi

# Include support for other languages:
!ifdef HAVE_MULTI_LANG
    !include lang-simpchinese.nsi
    !include lang-tradchinese.nsi
!endif

##############################################################################
# Macros
##############################################################################

# Verify VIM install path $INPUT_DIR.  If the input path is a valid VIM
# install path (ends with "vim"), $VALID will be set to 1; Otherwise $VALID
# will be set to 0.
!macro VerifyInstDir INPUT_DIR VALID
    StrCpy ${VALID} ${INPUT_DIR} 3 -3
    ${If} ${VALID} != "vim"
        StrCpy ${VALID} 0
    ${Else}
        StrCpy ${VALID} 1
    ${EndIf}
!macroend

# Extract different version of vim console executable based on detected
# Windows version.  The output path is whatever has already been set before
# this marcro.
!macro ExtractVimConsole
    ReadRegStr $R0 HKLM \
        "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
    ${If} ${Errors}
        # Windows 95/98/ME
        File /oname=vim.exe ${VIMSRC}\vimd32.exe
    ${Else}
        # Windows NT/2000/XT
        File /oname=vim.exe ${VIMSRC}\vimw32.exe
    ${EndIf}
!macroend

# Detect whether an instance of Vim is running or not.  The console version of
# Vim will be executed (silently) to list Vim servers.  If found, there must
# be some instances of Vim running.
# $VIM_CONSOLE_PATH - Input, path to Vim console (vim.exe)
# $IS_RUNNING       - Output. 1 if some instances running, 0 if not.
!macro DetectRunningVim VIM_CONSOLE_PATH IS_RUNNING
    Push $R0
    Push $R1

    nsExec::ExecToStack '"${VIM_CONSOLE_PATH}\vim.exe" --serverlist'
    Pop $R0  # Execution status
    Pop $R1  # Output string (server list)

    # If no execution error found and server list is empty, there must be some
    # vim instances running.  The result will hold by $R0.
    ${If} $R0 == "0"
    ${AndIf} $R1 != ""
        # vim.exe executed sucessfully and the server list contains something,
        # there must be an instance of Vim running:
        StrCpy $R0 1
    ${Else}
        # No Vim instance running:
        StrCpy $R0 0
    ${EndIf}

    Pop  $R1
    Exch $R0           # Restore R0 and put result on stack
    Pop  ${IS_RUNNING} # Assign result
!macroend

# The following function needs to be in both installer an uninstaller, so a
# macro is created to avoid code duplication.
!macro GetParent un
    Function ${un}GetParent
        Exch $0 ; old $0 is on top of stack
        Push $1
        Push $2
        StrCpy $1 -1

        ${Do}
            StrCpy $2 $0 1 $1
            ${If}   $2 == ""
            ${OrIf} $2 == "\"
                ${ExitDo}
            ${EndIf}
            IntOp $1 $1 - 1
        ${Loop}

        StrCpy $0 $0 $1
        Pop $2
        Pop $1
        Exch $0 ; put $0 on top of stack, restore $0 to original value
    FunctionEnd
!macroend

# Show error message.  Error dialog will be shown only if we're currently not
# in slient install mode.
!macro ShowErrMsg ERR_MSG
    # Show message box only if we're not in silent install mode:
    ${IfNot} ${Silent}
        MessageBox MB_OK|MB_ICONEXCLAMATION ${ERR_MSG} /SD IDOK
    ${EndIf}

    # Also send error message to detail log.  Might not work if the log window
    # has not been created yet.
    # TODO: A better choice should be sent it to external log file.
    DetailPrint ${ERR_MSG}
!macroend


##############################################################################
# Installer Functions
##############################################################################

!insertmacro GetParent ""

Function .onInit
    Push $R0
    Push $R1

    # If VIM environment string contains a valid VIM install path, use that as
    # install path:
    ReadEnvStr $R0 "VIM"
    ${If}    $R0 != ""
    ${AndIf} ${FileExists} "$R0"
        Push $R0
        Call GetParent
        Pop $R0

        !insertmacro VerifyInstDir $R0 $R1
        ${IfThen} $R1 = 0 ${|} StrCpy $INSTDIR $R0 ${|}
    ${EndIf}

    # Default install path:
    !insertmacro VerifyInstDir $INSTDIR $R0
    ${IfThen} $R0 = 0 ${|} StrCpy $INSTDIR "$PROGRAMFILES\Vim" ${|}

    # Initialize user variables:
    # $0 - holds the directory the executables are installed to
    # $1 - holds the parameters to be passed to install.exe.  Starts with OLE
    #      registration (since a non-OLE gvim will not complain, and we want
    #      to always register an OLE gvim).
    # $2 - holds the names to create batch files for
    StrCpy $0 "$INSTDIR\vim${VER_MAJOR}${VER_MINOR}"
    StrCpy $1 "-register-OLE"
    StrCpy $2 "gvim evim gview gvimdiff vimtutor"

    Pop $R1
    Pop $R0

    # Show language selection dialog:  User selected language will be
    # represented by Local ID (LCID) and assigned to $LANGUAGE.  If registry
    # key defined, the LCID will also be stored in Windows registry.  For list
    # of LCID, check "Locale IDs Assigned by Microsoft":
    #   http://msdn.microsoft.com/en-us/goglobal/bb964664.aspx
    !ifdef HAVE_MULTI_LANG
        !insertmacro MUI_LANGDLL_DISPLAY
    !endif
FunctionEnd

# Unintall existing Vim if found.  The install path of the existing Vim will
# be used as the default install path.
Function UninstallOldVer
    # We're going to call the uninstaller below to make change, make sure Vim
    # is not running:
    Call CheckRunningVim

    # Run the install program to check for already installed versions:
    SetOutPath $TEMP
    File /oname=install.exe ${VIMSRC}\installw32.exe
    ExecWait "$TEMP\install.exe -uninstall-check"
    Delete $TEMP\install.exe

    # We may have been put to the background when uninstall did something:
    BringToFront

    # Install will have created a file for us that contains the directory where
    # we should install.  This is $VIM if it's set.  This appears to be the only
    # way to get the value of $VIM here!?
    Push $R0
    Push $R1
    ${If} ${FileExists} "$TEMP\vimini.ini"
        ReadINIStr $R0 $TEMP\vimini.ini vimini dir
        Delete $TEMP\vimini.ini

        # Make sure the loaded path name is valid:
        !insertmacro VerifyInstDir $R0 $R1
        ${IfThen} $R1 = 0 ${|} StrCpy $R0 "" ${|}
    ${Else}
        StrCpy $R0 ""
    ${EndIf}

    # If ReadINIStr find a valid path: use it as the default dir:
    ${If} $R0 != ""
        StrCpy $INSTDIR $R0
        StrCpy $0 "$R0\vim${VER_MAJOR}${VER_MINOR}"
    ${EndIf}

    Pop $R1
    Pop $R0
FunctionEnd

# Check if there're running Vim instances or not before any change has been
# made.  Refuse to install if Vim is still running.
Function CheckRunningVim
    Push $R0

    SetOutPath $TEMP
    !insertmacro ExtractVimConsole
    !insertmacro DetectRunningVim $TEMP $R0
    Delete $TEMP\vim.exe
    ${If} $R0 <> 0
        !insertmacro ShowErrMsg $(str_msg_vim_running)
        Pop $R0
        Abort
    ${EndIf}

    Pop $R0
FunctionEnd

# We only accept the directory if it ends in "vim":
Function .onVerifyInstDir
    Push $R0

    !insertmacro VerifyInstDir $INSTDIR $R0
    ${If} $R0 = 0
        Pop $R0
        Abort
    ${EndIf}

    Pop $R0
FunctionEnd

Function .onInstSuccess
    WriteUninstaller vim${VER_MAJOR}${VER_MINOR}\uninstall-gui.exe
FunctionEnd

Function .onInstFailed
    !insertmacro ShowErrMsg $(str_msg_install_fail)
FunctionEnd


##############################################################################
# Installer Sections
##############################################################################

Section $(str_section_exe) id_section_exe
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

Section $(str_section_console) id_section_console
    SectionIn 1 3

    SetOutPath $0
    !insertmacro ExtractVimConsole
    StrCpy $2 "$2 vim view vimdiff"
SectionEnd

Section $(str_section_batch) id_section_batch
    SectionIn 3

    StrCpy $1 "$1 -create-batfiles $2"
SectionEnd

Section $(str_section_desktop) id_section_desktop
    SectionIn 1 3

    StrCpy $1 "$1 -install-icons"
SectionEnd

Section $(str_section_start_menu) id_section_startmenu
    SectionIn 1 3

    StrCpy $1 "$1 -add-start-menu"
SectionEnd

Section $(str_section_quick_launch) id_section_quicklaunch
    SectionIn 1 3

    ${If} $QUICKLAUNCH != $TEMP
        SetOutPath ""
        CreateShortCut "$QUICKLAUNCH\${VIM_LNK_NAME}.lnk" \
            "$0\gvim.exe" "" "$0\gvim.exe" 0
    ${EndIf}
SectionEnd

Section $(str_section_edit_with) id_section_editwith
    SectionIn 1 3

    # Be aware of this sequence of events:
    # - user uninstalls Vim, gvimext.dll can't be removed (it's in use) and is
    #   scheduled to be removed at next reboot.
    # - user installs Vim in same directory, gvimext.dll still exists.
    # If we now skip installing gvimext.dll, it will disappear at the next
    # reboot.  Thus when copying gvimext.dll fails always schedule it to be
    # installed at the next reboot.  Can't use UpgradeDLL!  We don't ask the
    # user to reboot, the old dll will keep on working.
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

Section $(str_section_vim_rc) id_section_vimrc
    SectionIn 1 3

    StrCpy $1 "$1 -create-vimrc"
SectionEnd

Section $(str_section_plugin_home) id_section_pluginhome
    SectionIn 1 3

    StrCpy $1 "$1 -create-directories home"
SectionEnd

Section $(str_section_plugin_vim) id_section_pluginvim
    SectionIn 3

    StrCpy $1 "$1 -create-directories vim"
SectionEnd

!ifdef HAVE_VIS_VIM
    Section $(str_section_vis_vim) id_section_visvim
        SectionIn 3

        SetOutPath $0
        !insertmacro UpgradeDLL "${VIMSRC}\VisVim\VisVim.dll" "$0\VisVim.dll" "$0"
        File ${VIMSRC}\VisVim\README_VisVim.txt
    SectionEnd
!endif

!ifdef HAVE_NLS
    Section $(str_section_nls) id_section_nls
        SectionIn 1 3

        SetOutPath $0\lang
        File /r ${VIMRT}\lang\*.*
        SetOutPath $0\keymap
        File ${VIMRT}\keymap\README.txt
        File ${VIMRT}\keymap\*.vim
        SetOutPath $0
        File ${VIMRT}\libintl.dll
    SectionEnd
!endif

Section -call_install_exe
    SetOutPath $0
    nsExec::ExecToLog '"$0\install.exe" $1'

    # TODO: Check return value:
    Exch $R0
    DetailPrint "install.exe exit code - $R0"
    Pop $R0
SectionEnd

Section -post
    BringToFront
SectionEnd


##############################################################################
# Description for Installer Sections
##############################################################################
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_exe}         $(str_desc_exe)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_console}     $(str_desc_console)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_batch}       $(str_desc_batch)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_desktop}     $(str_desc_desktop)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_startmenu}   $(str_desc_start_menu)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_quicklaunch} $(str_desc_quick_launch)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_editwith}    $(str_desc_edit_with)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_vimrc}       $(str_desc_vim_rc)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_pluginhome}  $(str_desc_plugin_home)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_pluginvim}   $(str_desc_plugin_vim)

!ifdef HAVE_VIS_VIM
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_visvim}      $(str_desc_vis_vim)
!endif

!ifdef HAVE_NLS
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_nls}         $(str_desc_nls)
!endif
!insertmacro MUI_FUNCTION_DESCRIPTION_END


##############################################################################
# Uninstaller Sections
##############################################################################

Section "un.$(str_unsection_register)" id_unsection_register
    # Do not allow user to keep this section:
    SectionIn RO

    DetailPrint $(str_msg_unregister)

    # Apparently $INSTDIR is set to the directory where the uninstaller is
    # created.  Thus the "vim61" directory is included in it.
    StrCpy $0 "$INSTDIR"

    # If VisVim was installed, unregister the DLL.
    ${If} ${FileExists} "$0\VisVim.dll"
        ExecWait "regsvr32.exe /u /s $0\VisVim.dll"
    ${EndIf}

    # Delete the context menu entry and batch files:
    nsExec::ExecToLog '"$0\uninstal.exe" -nsis'
    # TODO: Check return value:
    Exch $R0
    DetailPrint "uninstall.exe exit code - $R0"
    Pop $R0

    # Delete quick launch:
    Delete "$QUICKLAUNCH\${VIM_LNK_NAME}.lnk"

    # We may have been put to the background when uninstall did something.
    BringToFront
SectionEnd

Section "un.$(str_unsection_exe)" id_unsection_exe
    DetailPrint $(str_msg_rm_exe)

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
        !insertmacro ShowErrMsg $(str_msg_rm_exe_fail)
    ${EndIf}

    # No error message if the "vim62" directory can't be removed, the
    # gvimext.dll may still be there.
    RMDir /r /REBOOTOK $0
SectionEnd

Section /o "un.$(str_unsection_plugin)" id_unsection_plugin
    DetailPrint $(str_msg_rm_plugin)
    RMDir /r /REBOOTOK $vim_plugin_path
SectionEnd

Section /o "un.$(str_unsection_root)" id_unsection_root
    DetailPrint $(str_msg_rm_root)
    RMDir /r /REBOOTOK $vim_install_root
SectionEnd


##############################################################################
# Description for Uninstaller Sections
##############################################################################
!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_register}  $(str_desc_unregister)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_exe}       $(str_desc_rm_exe)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_plugin}    $(str_desc_rm_plugin)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_root}      $(str_desc_rm_root)
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END


##############################################################################
# Uninstaller Functions
##############################################################################

!insertmacro GetParent "un."

Function un.onInit
    Push $R0

    # Get root path of the installation:
    Push $INSTDIR
    Call un.GetParent
    Pop $vim_install_root

    # Check to make sure this is a valid directory:
    !insertmacro VerifyInstDir $vim_install_root $R0
    ${If} $R0 = 0
        !insertmacro ShowErrMsg $(str_msg_invalid_root)
        Pop $R0
        Abort
    ${EndIf}

    # Determines vim plugin path.  Try plugin path under vim install root
    # first, and then plugin path under user's HOME directory.
    StrCpy $vim_plugin_path "$vim_install_root\vimfiles"
    ${IfNot} ${FileExists} "$vim_plugin_path"
        ReadEnvStr $R0 "HOME"
        ${If}    $R0 != ""
        ${AndIf} ${FileExists} "$R0\vimfiles"
            StrCpy $vim_plugin_path "$R0\vimfiles"
        ${Else}
            StrCpy $vim_plugin_path ""
        ${EndIf}
    ${EndIf}

    # Update status of the vim plugin uninstall section:
    ${If} $vim_plugin_path == ""
        # We don't know how to remove vim plugin as no valid plugin path
        # found:
        !insertmacro UnSelectSection ${id_unsection_plugin}
        !insertmacro SetSectionFlag  ${id_unsection_plugin} ${SF_RO}
    ${Else}
        # Valid plugin path found, remove it by default:
        !insertmacro ClearSectionFlag ${id_unsection_plugin} ${SF_RO}
        !insertmacro SelectSection    ${id_unsection_plugin}
    ${EndIf}

    Pop $R0

    # Get stored language preference:
    !ifdef HAVE_MULTI_LANG
        !insertmacro MUI_UNGETLANGUAGE
    !endif
FunctionEnd

Function un.onSelChange
    # Get selection status of the exe removal section:
    SectionGetFlags ${id_unsection_exe} $R0

    # Status of the plugin removal section is considered only if valid plugin
    # path has been found:
    ${If} $vim_plugin_path != ""
        SectionGetFlags ${id_unsection_plugin} $R1
        IntOp $R0 $R0 & $R1
    ${EndIf}

    IntOp $R0 $R0 & ${SF_SELECTED}

    # Root directory can be removed only if all sub-directories will be removed:
    ${If} $R0 = ${SF_SELECTED}
        # All sub-directories will be removed, so user is allowed to remove
        # the root directory:
        !insertmacro ClearSectionFlag ${id_unsection_root} ${SF_RO}
    ${Else}
        # Some sub-directories will not be removed, disable removal of the
        # root directory:
        !insertmacro UnSelectSection ${id_unsection_root}
        !insertmacro SetSectionFlag  ${id_unsection_root} ${SF_RO}
    ${EndIf}
FunctionEnd

# Check if there're running Vim instances or not before any change has been
# made.  Refuse to uninstall if Vim is still running.
Function un.CheckRunningVim
    Push $R0

    !insertmacro DetectRunningVim $INSTDIR $R0
    ${If} $R0 <> 0
        !insertmacro ShowErrMsg $(str_msg_vim_running)
        Pop $R0
        Abort
    ${EndIf}

    Pop $R0
FunctionEnd
