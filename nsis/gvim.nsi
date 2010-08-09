# vi:set ts=8 sts=4 sw=4 fdm=marker:
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

# Uncomment the following line to enable debug log:
!define VIM_LOG_FILE "$TEMP\vim-install-debug.log"

# Maximum number of old Vim installation to support on GUI
!define VIM_MAX_OLD_VER 5

!define VER_MAJOR 7
!define VER_MINOR 3d

# ---------------- No configurable settings below this line ------------------

!include MUI2.nsh
!include UpgradeDLL.nsh  # For VisVim.dll
!include Sections.nsh    # For section control
!include LogicLib.nsh
!include FileFunc.nsh
!include WordFunc.nsh
!include x64.nsh

# Global variables:
Var vim_install_root
Var vim_plugin_path
Var vim_old_ver_keys
Var vim_old_ver_count
Var fh_log

# Uninstallation registry key:
!define VER_SHORT         "${VER_MAJOR}.${VER_MINOR}"
!define REG_KEY_UNINSTALL "software\Microsoft\Windows\CurrentVersion\Uninstall"
!define VIM_PRODUCT_NAME  "Vim ${VER_SHORT}"
!define VIM_LNK_NAME      "gVim ${VER_SHORT}"

Name                  "${VIM_PRODUCT_NAME}"
OutFile               gvim${VER_SHORT}.exe
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
# MUI Settings                                                            {{{1
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
# Languages Files                                                         {{{1
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
# Macros                                                                  {{{1
##############################################################################

!define LogInit "!insertmacro _LogInit"
!macro _LogInit _LOG_FILE
    ${If} ${FileExists} "${_LOG_FILE}"
        FileOpen $fh_log "${_LOG_FILE}" w
    ${Else}
        SetFileAttributes "${_LOG_FILE}" NORMAL
        FileOpen $fh_log "${_LOG_FILE}" a
        FileSeek $fh_log 0 END
    ${EndIf}
!macroend

!define LogClose "!insertmacro _LogClose"
!macro _LogClose
    ${If} $fh_log != ""
        FileClose $fh_log
        StrCpy $fh_log ""
        # SetFileAttributes "${_LOG_FILE}" READONLY|SYSTEM|HIDDEN
    ${EndIf}
!macroend

!define Log "!insertmacro _Log"
!macro _Log _LOG_MSG
    ${If} $fh_log != ""
        FileWrite $fh_log `${_LOG_MSG}$\r$\n`
    ${EndIf}
!macroend

!define LogPrint "!insertmacro _LogPrint"
!macro _LogPrint _LOG_MSG
    ${Log} `${_LOG_MSG}`
    DetailPrint `${_LOG_MSG}`
!macroend

!define Logged0 "!insertmacro _Logged0"
!macro _Logged0 _CMD
    ${Log} `${_CMD}`
    `${_CMD}`
!macroend

!define Logged1 "!insertmacro _Logged1"
!macro _Logged1 _CMD _PARAM1
    ${Log} `${_CMD} ${_PARAM1}`
    `${_CMD}` `${_PARAM1}`
!macroend

!define Logged2 "!insertmacro _Logged2"
!macro _Logged2 _CMD _PARAM1 _PARAM2
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}`
!macroend

!define Logged3 "!insertmacro _Logged3"
!macro _Logged3 _CMD _PARAM1 _PARAM2 _PARAM3
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2} ${_PARAM3}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}` `${_PARAM3}`
!macroend

!define Logged4 "!insertmacro _Logged4"
!macro _Logged4 _CMD _PARAM1 _PARAM2 _PARAM3 _PARAM4
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2} ${_PARAM3} ${_PARAM4}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}` `${_PARAM3}` `${_PARAM4}`
!macroend

!define LogSectionStart "!insertmacro _LogSectionStart"
!macro _LogSectionStart
    !ifdef __SECTION__
        ${Log} "$\r$\nEnter section ${__SECTION__}"
    !endif
!macroend

!define LogSectionEnd "!insertmacro _LogSectionEnd"
!macro _LogSectionEnd
    !ifdef __SECTION__
        ${Log} "Leave section ${__SECTION__}"
    !endif
!macroend

# Verify VIM install path $_INPUT_DIR.  If the input path is a valid VIM
# install path (ends with "vim"), $_VALID will be set to 1; Otherwise $_VALID
# will be set to 0.
!define VerifyInstDir "!insertmacro _VerifyInstDir"
!macro _VerifyInstDir _INPUT_DIR _VALID
    push $R0
    StrCpy $R0 ${_INPUT_DIR} 3 -3
    ${If} $R0 != "vim"
        StrCpy $R0 0
    ${Else}
        StrCpy $R0 1
    ${EndIf}
    Exch $R0
    Pop ${_VALID}
!macroend

# Extract different version of vim console executable based on detected
# Windows version.  The output path is whatever has already been set before
# this macro.
!define ExtractVimConsole "!insertmacro _ExtractVimConsole"
!macro _ExtractVimConsole
    ReadRegStr $R0 HKLM \
        "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
    ${If} ${Errors}
        # Windows 95/98/ME
        ${Logged2} File /oname=vim.exe ${VIMSRC}\vimd32.exe
    ${Else}
        # Windows NT/2000/XT
        ${Logged2} File /oname=vim.exe ${VIMSRC}\vimw32.exe
    ${EndIf}
!macroend

# Detect whether an instance of Vim is running or not.  The console version of
# Vim will be executed (silently) to list Vim servers.  If found, there must
# be some instances of Vim running.
# $_VIM_CONSOLE_PATH - Input, path to Vim console (vim.exe)
# $_IS_RUNNING       - Output. 1 if some instances running, 0 if not.
!define DetectRunningVim "!insertmacro _DetectRunningVim"
!macro _DetectRunningVim _VIM_CONSOLE_PATH _IS_RUNNING
    Push $R0
    Push $R1

    ${Logged1} nsExec::ExecToStack '"${_VIM_CONSOLE_PATH}\vim.exe" --serverlist'
    Pop $R0  # Execution status
    Pop $R1  # Output string (server list)

    # Debug log:
    ${Log} "Detect running Vim: status=$R0, server list=[$R1]"

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
    Exch $R0            # Restore R0 and put result on stack
    Pop  ${_IS_RUNNING} # Assign result
!macroend

# Show error message.  Error dialog will be shown only if we're currently not
# in slient install mode.
!define ShowErrMsg "!insertmacro _ShowErrMsg"
!macro _ShowErrMsg _ERR_MSG
    # Show message box only if we're not in silent install mode:
    ${IfNot} ${Silent}
        MessageBox MB_OK|MB_ICONEXCLAMATION "${_ERR_MSG}" /SD IDOK
    ${EndIf}

    # Send error message to debug log:
    ${Log} "ERROR: ${_ERR_MSG}"

    # Also send error message to debug log.  Might not work if the log window
    # has not been created yet.
    DetailPrint "${_ERR_MSG}"
!macroend

!define GetOldVerSectionID "!insertmacro _GetOldVerSectionID"
!macro _GetOldVerSectionID _INDEX _ID
    Push ${_INDEX}
    Call GetOldVerSectionIDFunc
    Pop  ${_ID}
!macroend

!define VimGetOldVerKey "!insertmacro _VimGetOldVerKey"
!macro _VimGetOldVerKey _INDEX _KEY
    Push ${_INDEX}
    Call VimGetOldVerKeyFunc
    Pop  ${_KEY}
!macroend

##############################################################################
# Installer Functions                                                     {{{1
##############################################################################

Function .onInit

    # Initialize all globals:
    StrCpy $vim_install_root  ""
    StrCpy $vim_plugin_path   ""
    StrCpy $vim_old_ver_keys  ""
    StrCpy $vim_old_ver_count 0
    StrCpy $fh_log            ""

    # Initialize log:
    ${LogInit} ${VIM_LOG_FILE}

    # Read all Vim uninstall keys from registry.  Please note we only support
    # limited number of old version.  Extra version will be ignored!
    Call LoadVimUninstallKeys
    ${If} $vim_old_ver_count > ${VIM_MAX_OLD_VER}
        # TODO: Change to error and abort!
        ${Log} "WARNING: $vim_old_ver_count versions found, \
                exceeds upper limit ${VIM_MAX_OLD_VER}. \
                Extra versions ignored!"
        StrCpy $vim_old_ver_count ${VIM_MAX_OLD_VER}
    ${EndIf}

    # Determine default install path:
    Call SetInstallPath

    # Config sections for removal of old version:
    Call ConfigOldVerSections

    # Initialize user variables:
    # $0 - holds the directory the executables are installed to
    # $1 - holds the parameters to be passed to install.exe.  Starts with OLE
    #      registration (since a non-OLE gvim will not complain, and we want
    #      to always register an OLE gvim).
    # $2 - holds the names to create batch files for
    # TODO: Log
    # TODO: User user var instead
    StrCpy $0 "$INSTDIR\vim${VER_MAJOR}${VER_MINOR}"
    StrCpy $1 "-register-OLE"
    StrCpy $2 "gvim evim gview gvimdiff vimtutor"

    # TODO: Shouldn't we move this to the beginning?
    #
    # Show language selection dialog:  User selected language will be
    # represented by Local ID (LCID) and assigned to $LANGUAGE.  If registry
    # key defined, the LCID will also be stored in Windows registry.  For list
    # of LCID, check "Locale IDs Assigned by Microsoft":
    #   http://msdn.microsoft.com/en-us/goglobal/bb964664.aspx
    !ifdef HAVE_MULTI_LANG
        !insertmacro MUI_LANGDLL_DISPLAY
    !endif
FunctionEnd

Function LoadVimUninstallKeys
    Push $R0
    Push $R1
    Push $R2

    ClearErrors
    StrCpy $R0 0    # Sub-key index
    StrCpy $R1 ""   # Sub-key
    StrCpy $vim_old_ver_keys  ""
    StrCpy $vim_old_ver_count 0
    ${Do}
        # Eumerate the sub-key:
        EnumRegKey $R1 HKLM ${REG_KEY_UNINSTALL} $R0

        # Stop if no more sub-key:
        ${If}   ${Errors}
        ${OrIf} $R1 == ""
            ${ExitDo}
        ${EndIf}

        # Move to the next sub-key:
        IntOp $R0 $R0 + 1

        # Check if the key is Vim uninstall key or not:
        StrCpy $R2 $R1 4
        ${IfThen} $R2 S!= "Vim " ${|} ${Continue} ${|}

        # Verifies required sub-keys:
        ReadRegStr $R2 HKLM "${REG_KEY_UNINSTALL}\$R1" "DisplayName"
        ${If}   ${Errors}
        ${OrIf} $R2 == ""
            ${Log} "WARNING: Skip uninstall key [$R1]: \
                    Cannot find sub-key 'DisplayName'!"
            ${Continue}
        ${EndIf}

        ReadRegStr $R2 HKLM "${REG_KEY_UNINSTALL}\$R1" "UninstallString"
        ${If}   ${Errors}
        ${OrIf} $R2 == ""
            ${Log} "WARNING: Skip uninstall key [$R1]: \
                    Cannot find sub-key 'UninstallString'!"
            ${Continue}
        ${EndIf}

        ${IfNot} ${FileExists} $R2
            ${Log} "WARNING: Skip uninstall key [$R1]: \
                    Cannot access uninstall executable [$R2]"
            ${Continue}
        ${EndIf}

        # Store the found sub-key:
        IntOp  $vim_old_ver_count $vim_old_ver_count + 1
        StrCpy $vim_old_ver_keys "$vim_old_ver_keys$R1$\r$\n"
        ${Log} "Found Vim uninstall key No.$vim_old_ver_count: [$R1]"
    ${Loop}

    ${Log} "Found $vim_old_ver_count uninstall keys:$\r$\n\
            $vim_old_ver_keys"
    ClearErrors

    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

Function ConfigOldVerSections
    Push $R0
    Push $R1
    Push $R2

    StrCpy $R0 0
    ${DoWhile} $R0 < $vim_old_ver_count
        ${GetOldVerSectionID} $R0 $R1
        ${VimGetOldVerKey}    $R0 $R2
        ${Log} "Old ver section No.$R0, ID=$R1, Key=[$R2]"

        !insertmacro SelectSection $R1

        # If the same version installed, we must remove it:
        ${If} $R2 S== "${VIM_PRODUCT_NAME}"
            !insertmacro SetSectionFlag   $R1 ${SF_RO}
        ${EndIf}

        # Set section title to readable form:
        ReadRegStr $R2 HKLM "${REG_KEY_UNINSTALL}\$R2" "DisplayName"
        SectionSetText $R1 'Uninstall $R2'

        IntOp $R0 $R0 + 1
    ${Loop}

    ${DoWhile} $R0 < ${VIM_MAX_OLD_VER}
        ${GetOldVerSectionID} $R0 $R1
        ${Log} "Disable old ver section No.$R0, ID=$R1"
        !insertmacro UnselectSection  $R1
        !insertmacro SetSectionFlag   $R1 ${SF_RO}
        SectionSetText $R1 ""

        IntOp $R0 $R0 + 1
    ${Loop}

    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

Function SetInstallPath
    Push $R0
    Push $R1
    Push $R2  # Valid flag

    # Initialize to invalid:
    StrCpy $R2 0

    # First try VIMRUNTIME environment string, use its parent directory as
    # install path if valid.
    ReadEnvStr $R0 "VIMRUNTIME"
    ${IfThen} $R0 != "" ${|} ${GetParent} $R0 $R0 ${|}
    ${If} $R0 != ""
        ${VerifyInstDir} $R0 $R2
        ${If} $R2 = 1
            ${Log} "Set install path per VIMRUNTIME: $R0"
            StrCpy $INSTDIR $R0
        ${EndIf}
    ${EndIf}

    # Then try VIM environment, use it as install path directly if valid.
    ${If} $R2 = 0
        ReadEnvStr $R0 "VIM"
        ${If} $R0 != ""
            ${VerifyInstDir} $R0 $R2
            ${If} $R2 = 1
                ${Log} "Set install path per VIM env: $R0"
                StrCpy $INSTDIR $R0
            ${EndIf}
        ${EndIf}
    ${EndIf}

    # Next try previously installed version.  If any, derive the install path
    # from the uninstall key of the last installed version:
    ${If} $vim_old_ver_count > 0
        # Find the uninstall key for the last installed version ($R1):
        IntOp $R0 $vim_old_ver_count - 1
        ${VimGetOldVerKey} $R0 $R1

        # Read path of the unintaller for registry ($R0):
        ${IfNot} ${Errors}
        ${AndIf} $R1 != ""
            ReadRegStr $R0 HKLM "${REG_KEY_UNINSTALL}\$R1" "UninstallString"
        ${Else}
            StrCpy $R0 ""
        ${EndIf}

        # Derive install path from unintaller path name:
        ${GetParent} $R0 $R0
        ${GetParent} $R0 $R0
        ${VerifyInstDir} $R0 $R2
        ${If} $R2 = 1
            ${Log} "Set install path per registry key [$R1]: $R0"
            StrCpy $INSTDIR $R0
        ${EndIf}
    ${EndIf}

    # If all of the above failed, set default install path:
    ${If} $R2 = 0
        StrCpy $INSTDIR "$PROGRAMFILES\Vim"
        ${Log} "Set default install path to: $INSTDIR"
    ${EndIf}

    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# Unintalls the n-th old Vim version found on the system.
#
# This function will be called by dynamic "old version" sections to remove the
# specified old vim version found on the system.  The index (ID) of the old
# vim version will be put on the top of the stack.  This function does not
# provide any output.
Function VimRmOldVer
    Exch $R0  # ID of the Vim version to remove.

    # Silently ignore out of bound IDs:
    ${If}   $R0 >= $vim_old_ver_count
    ${OrIf} $R0 < 0
        ${Log} "Skip non-exist old ver No. $R0"
        Pop $R0
        Return
    ${EndIf}

    Push $R1
    Push $R2
    Push $R3

    # Get (cached) registry key for the specified old version:
    ${VimGetOldVerKey} $R0 $R1
    ${If} $R1 == ""
        ${ShowErrMsg} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_no_rm_key)"
        Abort
    ${EndIf}

    StrCpy $R0 $R1
    ${LogPrint} "$(str_msg_rm_start) $R0 ..."

    # Read path of the unintaller from registry ($R1):
    ReadRegStr $R1 HKLM "${REG_KEY_UNINSTALL}\$R0" "UninstallString"
    ${If}   ${Errors}
    ${OrIf} $R1 == ""
        ${ShowErrMsg} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_no_rm_reg)"
        Abort
    ${EndIf}

    ${IfNot} ${FileExists} $R1
        ${ShowErrMsg} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_no_rm_exe)"
        Abort
    ${EndIf}

    # Path of uninstaller ($R2) and name of uninstaller($R3):
    ${GetParent}   $R1 $R2
    ${GetFileName} $R1 $R3

    # Copy unintall to temporary path:
    ${Logged4} CopyFiles /SILENT /FILESONLY $R1 $TEMP
    ${If}      ${Errors}
    ${OrIfNot} ${FileExists} "$TEMP\$R3"
        ${ShowErrMsg} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_rm_copy_fail)"
        Abort
    ${EndIf}

    # Execute the uninstaller in TEMP, exit code stores in $R2:
    ${Logged2} ExecWait '"$TEMP\$R3" _?=$R2' $R2
    ${If} ${Errors}
        ${Logged1} Delete "$TEMP\$R3"
        ${ShowErrMsg} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_rm_run_fail)"
        Abort
    ${EndIf}

    ${Logged1} Delete "$TEMP\$R3"

    ${Log} "Uninstaller exit code: $R2"

    # If this is the uninstaller for the same version we're trying to
    # installer, it's not possible to continue with installation:
    ${If}    $R2 <> 0
    ${AndIf} $R0 S== "${VIM_PRODUCT_NAME}"
        ${ShowErrMsg} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_abort_install)"
        Abort
    ${EndIf}

    # We may have been put to the background when uninstall did something:
    BringToFront

    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# Check if there're running Vim instances or not before any change has been
# made.  Refuse to install if Vim is still running.
Function CheckRunningVim
    Push $R0

    SetOutPath $TEMP
    ${ExtractVimConsole}
    ${DetectRunningVim} $TEMP $R0
    Delete $TEMP\vim.exe
    ${If} $R0 <> 0
        ${ShowErrMsg} $(str_msg_vim_running)
        Pop $R0
        Abort
    ${EndIf}

    Pop $R0
FunctionEnd

# We only accept the directory if it ends in "vim":
Function .onVerifyInstDir
    Push $R0

    ${VerifyInstDir} $INSTDIR $R0
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
    ${ShowErrMsg} $(str_msg_install_fail)
FunctionEnd

Function GetOldVerSectionIDFunc
    Exch $R0  # Index of the section
    Push $R1
    Push $R2

    # Push all section ID onto the stack in reverse order, so the first
    # seciton ID should be the one on the top of the stack:
    Call PushOldVerSectionIDs

    # Pop out the required one:
    StrCpy $R1 0
    ${While} $R1 <= $R0
        Pop $R2
        IntOp $R1 $R1 + 1
    ${EndWhile}

    # Store result in $R0:
    StrCpy $R0 $R2

    ${While} $R1 < ${VIM_MAX_OLD_VER}
        Pop $R2
        IntOp $R1 $R1 + 1
    ${EndWhile}

    Pop  $R2
    Pop  $R1
    Exch $R0
FunctionEnd

Function VimGetOldVerKeyFunc
    Exch $R0  # Index of the uninstall key

    ${If} $R0 >= $vim_old_ver_count
        StrCpy $R0 ""
    ${Else}
        # WordFind uses 1 based index:
        IntOp $R0 $R0 + 1
        ${WordFind} $vim_old_ver_keys "$\r$\n" "+$R0" $R0
    ${EndIf}

    Exch $R0
FunctionEnd


##############################################################################
# Dynamic sections to support removal of old versions                     {{{1
##############################################################################

!define OldVerSection "!insertmacro _OldVerSection"
!macro _OldVerSection _ID
    Section "Uninstall exising version ${_ID}" `id_section_old_install_${_ID}`
        SectionIn 1 2 3

        ${Log} "$\r$\nEnter old ver section ${_ID}"
        Push ${_ID}
        Call VimRmOldVer
        ${Log} "Leave old ver section ${_ID}"
    SectionEnd
!macroend

${OldVerSection} 0
${OldVerSection} 1
${OldVerSection} 2
${OldVerSection} 3
${OldVerSection} 4

# Push section ID of all above sections onto stack.
Function PushOldVerSectionIDs
    Push ${id_section_old_install_4}
    Push ${id_section_old_install_3}
    Push ${id_section_old_install_2}
    Push ${id_section_old_install_1}
    Push ${id_section_old_install_0}
FunctionEnd


##############################################################################
# Installer Sections                                                      {{{1
##############################################################################

Section $(str_section_exe) id_section_exe
    SectionIn 1 2 3 RO

    ${LogSectionStart}

    # we need also this here if the user changes the instdir
    StrCpy $0 "$INSTDIR\vim${VER_MAJOR}${VER_MINOR}"

    ${Logged1} SetOutPath $0
    ${Logged2} File /oname=gvim.exe     ${VIMSRC}\gvim_ole.exe
    ${Logged2} File /oname=install.exe  ${VIMSRC}\installw32.exe
    ${Logged2} File /oname=uninstal.exe ${VIMSRC}\uninstalw32.exe
    ${Logged1} File ${VIMSRC}\vimrun.exe
    ${Logged2} File /oname=xxd.exe      ${VIMSRC}\xxdw32.exe
    ${Logged1} File ${VIMTOOLS}\diff.exe
    ${Logged1} File ${VIMRT}\vimtutor.bat
    ${Logged1} File ${VIMRT}\README.txt
    ${Logged1} File ..\uninstal.txt
    ${Logged1} File ${VIMRT}\*.vim
    ${Logged1} File ${VIMRT}\rgb.txt

    ${Logged1} SetOutPath $0\colors
    ${Logged1} File ${VIMRT}\colors\*.*

    ${Logged1} SetOutPath $0\compiler
    ${Logged1} File ${VIMRT}\compiler\*.*

    ${Logged1} SetOutPath $0\doc
    ${Logged1} File ${VIMRT}\doc\*.txt
    ${Logged1} File ${VIMRT}\doc\tags

    ${Logged1} SetOutPath $0\ftplugin
    ${Logged1} File ${VIMRT}\ftplugin\*.*

    ${Logged1} SetOutPath $0\indent
    ${Logged1} File ${VIMRT}\indent\*.*

    ${Logged1} SetOutPath $0\macros
    ${Logged1} File ${VIMRT}\macros\*.*

    ${Logged1} SetOutPath $0\plugin
    ${Logged1} File ${VIMRT}\plugin\*.*

    ${Logged1} SetOutPath $0\autoload
    ${Logged1} File ${VIMRT}\autoload\*.*

    ${Logged1} SetOutPath $0\autoload\xml
    ${Logged1} File ${VIMRT}\autoload\xml\*.*

    ${Logged1} SetOutPath $0\syntax
    ${Logged1} File ${VIMRT}\syntax\*.*

    ${Logged1} SetOutPath $0\spell
    ${Logged1} File ${VIMRT}\spell\*.txt
    ${Logged1} File ${VIMRT}\spell\*.vim
    ${Logged1} File ${VIMRT}\spell\*.spl
    ${Logged1} File ${VIMRT}\spell\*.sug

    ${Logged1} SetOutPath $0\tools
    ${Logged1} File ${VIMRT}\tools\*.*

    ${Logged1} SetOutPath $0\tutor
    ${Logged1} File ${VIMRT}\tutor\*.*

    ${LogSectionEnd}
SectionEnd

Section $(str_section_console) id_section_console
    SectionIn 1 3

    ${LogSectionStart}

    ${Logged1} SetOutPath $0
    ${ExtractVimConsole}
    StrCpy $2 "$2 vim view vimdiff"

    ${LogSectionEnd}
SectionEnd

Section $(str_section_batch) id_section_batch
    SectionIn 3

    ${LogSectionStart}
    StrCpy $1 "$1 -create-batfiles $2"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_desktop) id_section_desktop
    SectionIn 1 3

    ${LogSectionStart}
    StrCpy $1 "$1 -install-icons"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_start_menu) id_section_startmenu
    SectionIn 1 3

    ${LogSectionStart}
    StrCpy $1 "$1 -add-start-menu"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_quick_launch) id_section_quicklaunch
    SectionIn 1 3

    ${LogSectionStart}

    ${If} $QUICKLAUNCH != $TEMP
        SetOutPath ""
        CreateShortCut "$QUICKLAUNCH\${VIM_LNK_NAME}.lnk" \
            "$0\gvim.exe" "" "$0\gvim.exe" 0
    ${EndIf}

    ${LogSectionEnd}
SectionEnd

Section $(str_section_edit_with) id_section_editwith
    SectionIn 1 3

    ${LogSectionStart}

    # Be aware of this sequence of events:
    # - user uninstalls Vim, gvimext.dll can't be removed (it's in use) and is
    #   scheduled to be removed at next reboot.
    # - user installs Vim in same directory, gvimext.dll still exists.
    # If we now skip installing gvimext.dll, it will disappear at the next
    # reboot.  Thus when copying gvimext.dll fails always schedule it to be
    # installed at the next reboot.  Can't use UpgradeDLL!  We don't ask the
    # user to reboot, the old dll will keep on working.
    ${Logged1} SetOutPath $0
    ClearErrors
    SetOverwrite try
    ${If} ${RunningX64}
        ${Logged2} File /oname=gvimext.dll ${VIMSRC}\GvimExt\gvimext64.dll
    ${Else}
        ${Logged2} File /oname=gvimext.dll ${VIMSRC}\GvimExt\gvimext.dll
    ${EndIf}

    ${If} ${Errors}
        # Can't copy gvimext.dll, create it under another name and rename it
        # on next reboot.
        GetTempFileName $3 $0
        ${If} ${RunningX64}
            ${Logged2} File /oname=$3 ${VIMSRC}\GvimExt\gvimext64.dll
        ${Else}
            ${Logged2} File /oname=$3 ${VIMSRC}\GvimExt\gvimext.dll
        ${EndIf}
        ${Logged3} Rename /REBOOTOK $3 $0\gvimext.dll
    ${EndIf}

    SetOverwrite lastused

    # We don't have a separate entry for the "Open With..." menu, assume
    # the user wants either both or none.
    StrCpy $1 "$1 -install-popup -install-openwith"

    ${LogSectionEnd}
SectionEnd

Section $(str_section_vim_rc) id_section_vimrc
    SectionIn 1 3

    ${LogSectionStart}
    StrCpy $1 "$1 -create-vimrc"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_plugin_home) id_section_pluginhome
    SectionIn 1 3

    ${LogSectionStart}
    StrCpy $1 "$1 -create-directories home"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_plugin_vim) id_section_pluginvim
    SectionIn 3

    ${LogSectionStart}
    StrCpy $1 "$1 -create-directories vim"
    ${LogSectionEnd}
SectionEnd

!ifdef HAVE_VIS_VIM
    Section $(str_section_vis_vim) id_section_visvim
        SectionIn 3

        ${LogSectionStart}

        ${Logged1} SetOutPath $0
        !insertmacro UpgradeDLL "${VIMSRC}\VisVim\VisVim.dll" "$0\VisVim.dll" "$0"
        ${Logged1} File ${VIMSRC}\VisVim\README_VisVim.txt

        ${LogSectionEnd}
    SectionEnd
!endif

!ifdef HAVE_NLS
    Section $(str_section_nls) id_section_nls
        SectionIn 1 3

        ${LogSectionStart}

        SetOutPath $0\lang
        File /r ${VIMRT}\lang\*.*
        SetOutPath $0\keymap
        File ${VIMRT}\keymap\README.txt
        File ${VIMRT}\keymap\*.vim
        SetOutPath $0
        File ${VIMRT}\libintl.dll

        ${LogSectionEnd}
    SectionEnd
!endif

Section -call_install_exe
    ${Logged1} SetOutPath $0
    ${Logged1} nsExec::ExecToLog '"$0\install.exe" $1'

    # TODO: Check return value:
    Exch $R0
    ${Log} "install.exe exit code - $R0"
    Pop $R0
SectionEnd

Section -post
    BringToFront

    # Close log:
    ${LogClose}
SectionEnd


##############################################################################
# Description for Installer Sections                                      {{{1
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
# Uninstaller Sections                                                    {{{1
##############################################################################

Section "un.$(str_unsection_register)" id_unsection_register
    # Do not allow user to keep this section:
    SectionIn RO

    ${LogSectionStart}

    # Apparently $INSTDIR is set to the directory where the uninstaller is
    # created.  Thus the "vim61" directory is included in it.
    StrCpy $0 "$INSTDIR"

    # If VisVim was installed, unregister the DLL.
    ${If} ${FileExists} "$0\VisVim.dll"
        ${Logged1} ExecWait "regsvr32.exe /u /s $0\VisVim.dll"
    ${EndIf}

    # Delete the context menu entry and batch files:
    ${Logged1} nsExec::ExecToLog '"$0\uninstal.exe" -nsis'
    # TODO: Check return value:
    Exch $R0
    ${Log} "uninstall.exe exit code - $R0"
    Pop $R0

    # Delete quick launch:
    ${Logged1} Delete "$QUICKLAUNCH\${VIM_LNK_NAME}.lnk"

    # We may have been put to the background when uninstall did something.
    BringToFront

    ${LogSectionEnd}
SectionEnd

Section "un.$(str_unsection_exe)" id_unsection_exe
    ${LogSectionStart}

    # It contains the Vim executables and runtime files.
    StrCpy $0 "$INSTDIR"
    ${Logged2} Delete /REBOOTOK $0\*.dll
    ClearErrors

    # Remove everything but *.dll files.  Avoids that
    # a lot remains when gvimext.dll cannot be deleted.
    ${Logged2} RMDir /r $0\autoload
    ${Logged2} RMDir /r $0\colors
    ${Logged2} RMDir /r $0\compiler
    ${Logged2} RMDir /r $0\doc
    ${Logged2} RMDir /r $0\ftplugin
    ${Logged2} RMDir /r $0\indent
    ${Logged2} RMDir /r $0\macros
    ${Logged2} RMDir /r $0\plugin
    ${Logged2} RMDir /r $0\spell
    ${Logged2} RMDir /r $0\syntax
    ${Logged2} RMDir /r $0\tools
    ${Logged2} RMDir /r $0\tutor
    ${Logged2} RMDir /r $0\VisVim
    ${Logged2} RMDir /r $0\lang
    ${Logged2} RMDir /r $0\keymap
    ${Logged1} Delete $0\*.exe
    ${Logged1} Delete $0\*.bat
    ${Logged1} Delete $0\*.vim
    ${Logged1} Delete $0\*.txt

    ${If} ${Errors}
        ${ShowErrMsg} $(str_msg_rm_exe_fail)
    ${EndIf}

    # No error message if the "vim62" directory can't be removed, the
    # gvimext.dll may still be there.
    ${Logged3} RMDir /r /REBOOTOK $0

    ${LogSectionEnd}
SectionEnd

Section /o "un.$(str_unsection_plugin)" id_unsection_plugin
    ${LogSectionStart}
    ${Logged3} RMDir /r /REBOOTOK $vim_plugin_path
    ${LogSectionEnd}
SectionEnd

Section /o "un.$(str_unsection_root)" id_unsection_root
    ${LogSectionStart}
    ${Logged3} RMDir /r /REBOOTOK $vim_install_root
    ${LogSectionEnd}
SectionEnd

Section -un.post
    # Close log:
    ${LogClose}
SectionEnd


##############################################################################
# Description for Uninstaller Sections                                    {{{1
##############################################################################
!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_register}  $(str_desc_unregister)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_exe}       $(str_desc_rm_exe)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_plugin}    $(str_desc_rm_plugin)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_root}      $(str_desc_rm_root)
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END


##############################################################################
# Uninstaller Functions                                                   {{{1
##############################################################################

Function un.onInit
    Push $R0

    # Initialize log:
    ${LogInit} ${VIM_LOG_FILE}

    # Get root path of the installation:
    ${GetParent} $INSTDIR $vim_install_root

    # Check to make sure this is a valid directory:
    ${VerifyInstDir} $vim_install_root $R0
    ${If} $R0 = 0
        ${ShowErrMsg} $(str_msg_invalid_root)
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
        # Valid plugin path found, allow the directory to be removed:
        !insertmacro ClearSectionFlag ${id_unsection_plugin} ${SF_RO}
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

    ${DetectRunningVim} $INSTDIR $R0
    ${If} $R0 <> 0
        ${ShowErrMsg} $(str_msg_vim_running)
        Pop $R0
        Abort
    ${EndIf}

    Pop $R0
FunctionEnd
