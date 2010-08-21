# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# NSIS file to create a self-installing exe for Vim.
# It requires NSIS version 2.34 or later (for Modern UI 2.0).
# Last Change:	2010 Jul 30

##############################################################################
# Configurable Settings                                                   {{{1
##############################################################################

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

# Uncomment the following line if you have newer version of gettext that uses
# iconv.dll for encoding conversion.  Please note you should rename "intl.dll"
# from "gettext-win32" archive to "libintl.dll".
#!define HAVE_ICONV

# Uncomment the following line so that the installer/uninstaller would not
# jump to the finish page automatically, this allows the user to check the
# detailed log.  It's used for debug purpose.
#!define MUI_FINISHPAGE_NOAUTOCLOSE
#!define MUI_UNFINISHPAGE_NOAUTOCLOSE

# Uncomment the following line to enable debug log:
!define VIM_LOG_FILE "vim-install.log"

# Maximum number of old Vim versions to support on GUI:
!define VIM_MAX_OLD_VER 5

!define VER_MAJOR 7
!define VER_MINOR 3

# ---------------- No configurable settings below this line ------------------

##############################################################################
# Headers & Global Settings                                               {{{1
##############################################################################

!include "FileFunc.nsh"
!include "Library.nsh"     # For DLL install
!include "LogicLib.nsh"
!include "MUI2.nsh"
!include "Sections.nsh"    # For section control
!include "Util.nsh"
!include "WordFunc.nsh"
!include "x64.nsh"
!include "simple_log.nsh"

# Global variables:
Var vim_install_root
Var vim_bin_path
Var vim_plugin_path
Var vim_old_ver_keys
Var vim_old_ver_count
Var vim_install_param
Var vim_batch_names

# Version strings:
!define VER_SHORT         "${VER_MAJOR}.${VER_MINOR}"
!define VER_SHORT_NDOT    "${VER_MAJOR}${VER_MINOR}"
!define VIM_PRODUCT_NAME  "Vim ${VER_SHORT}"
!define VIM_BIN_DIR       "vim${VER_SHORT_NDOT}"
!define VIM_LNK_NAME      "gVim ${VER_SHORT}"

# Registry keys:
!define REG_KEY_WINDOWS   "software\Microsoft\Windows\CurrentVersion"
!define REG_KEY_UNINSTALL "${REG_KEY_WINDOWS}\Uninstall"

Name                      "${VIM_PRODUCT_NAME}"
OutFile                   gvim${VER_SHORT_NDOT}.exe
CRCCheck                  force
SetCompressor             lzma
SetDatablockOptimize      on
BrandingText              " "
RequestExecutionLevel     highest
InstallDir                "$PROGRAMFILES\Vim"

# Types of installs we can perform:
InstType                  $(str_type_typical)
InstType                  $(str_type_minimal)
InstType                  $(str_type_full)

SilentInstall             normal

##############################################################################
# MUI Settings                                                            {{{1
##############################################################################
!define MUI_ICON   "icons\vim_16c.ico"
!define MUI_UNICON "icons\vim_uninst_16c.ico"

# Show all languages, despite user's codepage:
!define MUI_LANGDLL_ALLLANGUAGES

!define MUI_DIRECTORYPAGE_TEXT_DESTINATION $(str_dest_folder)
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_FINISHPAGE_RUN                 "$vim_bin_path\gvim.exe"
!define MUI_FINISHPAGE_RUN_TEXT            $(str_show_readme)
!define MUI_FINISHPAGE_RUN_PARAMETERS      "-R $\"$vim_bin_path\README.txt$\""
!define MUI_FINISHPAGE_REBOOTLATER_DEFAULT
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!ifdef HAVE_UPX
    !packhdr temp.dat "upx --best --compress-icons=1 temp.dat"
!endif

# Registry key to save installer language selection.  It will be removed by
# the uninstaller:
!ifdef HAVE_MULTI_LANG
    !define MUI_LANGDLL_REGISTRY_ROOT      "SHCTX"
    !define MUI_LANGDLL_REGISTRY_KEY       "SOFTWARE\Vim"
    !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
!endif

# Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${VIMRT}\doc\uganda.nsis.txt"
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE VimFinalCheck
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

# Uninstaller pages:
!insertmacro MUI_UNPAGE_CONFIRM
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE un.VimCheckRunning
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

##############################################################################
# Languages Files                                                         {{{1
##############################################################################
# Please note English language file should be listed first as the first one
# will be used as the default.
!insertmacro MUI_RESERVEFILE_LANGDLL
!include "lang\english.nsi"

# Include support for other languages:
!ifdef HAVE_MULTI_LANG
    !include "lang\simpchinese.nsi"
    !include "lang\tradchinese.nsi"
!endif

##############################################################################
# Macros                                                                  {{{1
##############################################################################

# ----------------------------------------------------------------------------
# macro VimVerifyRootDir                                                  {{{2
#   Verify VIM install path $_INPUT_DIR.  If the input path is a valid VIM
#   install path (ends with "vim"), $_VALID will be set to 1; Otherwise
#   $_VALID will be set to 0.
# ----------------------------------------------------------------------------
!define VimVerifyRootDir "!insertmacro _VimVerifyRootDir"
!macro _VimVerifyRootDir _INPUT_DIR _VALID
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

# ----------------------------------------------------------------------------
# macro VimExtractConsoleExe                                              {{{2
#   Extract different version of vim console executable based on detected
#   Windows version.  The output path is whatever has already been set before
#   this macro.
# ----------------------------------------------------------------------------
!define VimExtractConsoleExe "!insertmacro _VimExtractConsoleExe"
!macro _VimExtractConsoleExe
    ReadRegStr $R0 HKLM \
        "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
    ${If} ${Errors}
        # Windows 95/98/ME
        ${Logged2} File /oname=vim.exe ${VIMSRC}\vimd32.exe
    ${Else}
        # Windows NT/2000/XT
        ${Logged2} File /oname=vim.exe ${VIMSRC}\vimw32.exe
    ${EndIf}
!macroend

# ----------------------------------------------------------------------------
# macro VimIsRuning                                                       {{{2
#   Detect whether an instance of Vim is running or not.  The console version
#   of Vim will be executed (silently) to list Vim servers.  If found, there
#   must be some instances of Vim running.
#   Parameters:
#     $_VIM_CONSOLE_PATH : Path to Vim console (vim.exe)
#   Returns:
#     $_IS_RUNNING       : 1 if some instances running, 0 if not.
# ----------------------------------------------------------------------------
!define VimIsRuning "!insertmacro _VimIsRuningCall"
!macro _VimIsRuningCall _VIM_CONSOLE_PATH _IS_RUNNING
    Push `${_VIM_CONSOLE_PATH}`
    ${CallArtificialFunction} _VimIsRuning
    Pop ${_IS_RUNNING}
!macroend
!macro _VimIsRuning
    Exch $R0 # Parameter: _VIM_CONSOLE_PATH
    Push $R1

    ${Logged1} nsExec::ExecToStack '"$R0\vim.exe" --serverlist'
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

    # Restore stack:
    Pop  $R1
    Exch $R0 # Restore R0 and put result on stack
!macroend

# ----------------------------------------------------------------------------
# macro VimGetOldVerSecID                                                 {{{2
#   Get ID of the specified old version section.  This is a wrapper for
#   function VimGetOldVerSecIDFunc.
# ----------------------------------------------------------------------------
!define VimGetOldVerSecID "!insertmacro _VimGetOldVerSecID"
!macro _VimGetOldVerSecID _INDEX _ID
    Push ${_INDEX}
    Call VimGetOldVerSecIDFunc
    Pop  ${_ID}
!macroend

# ----------------------------------------------------------------------------
# macro VimGetOldVerKey                                                   {{{2
#   Get the uninstall registry key for the specified old version.  This is a
#   wrapper for function VimGetOldVerKeyFunc.
# ----------------------------------------------------------------------------
!define VimGetOldVerKey "!insertmacro _VimGetOldVerKey"
!macro _VimGetOldVerKey _INDEX _KEY
    Push ${_INDEX}
    Call VimGetOldVerKeyFunc
    Pop  ${_KEY}
!macroend

##############################################################################
# Installer Functions                                                     {{{1
##############################################################################

# ----------------------------------------------------------------------------
# Function .onInit                                                        {{{2
# ----------------------------------------------------------------------------
Function .onInit
    # Initialize all globals:
    StrCpy $vim_install_root  ""
    StrCpy $vim_bin_path      ""
    StrCpy $vim_plugin_path   ""
    StrCpy $vim_old_ver_keys  ""
    StrCpy $vim_old_ver_count 0
    StrCpy $vim_install_param ""
    StrCpy $vim_batch_names   ""

    # Initialize log:
    !ifdef VIM_LOG_FILE
        ${LogInit} "$TEMP\${VIM_LOG_FILE}" "Vim installer log"
    !endif

    # Use shell folders for "all" user:
    ${Logged1} SetShellVarContext all

    # 64-bit view should be used on Windows x64:
    ${Logged1} SetRegView 64

    # Read all Vim uninstall keys from registry.  Please note we only support
    # limited number of old version.  Extra version will be ignored!
    Call VimLoadUninstallKeys
    ${If} $vim_old_ver_count > ${VIM_MAX_OLD_VER}
        # TODO: Change to error and abort!
        ${Log} "WARNING: $vim_old_ver_count versions found, \
                exceeds upper limit ${VIM_MAX_OLD_VER}. \
                Extra versions ignored!"
        StrCpy $vim_old_ver_count ${VIM_MAX_OLD_VER}
    ${EndIf}

    # Determine default install path:
    Call VimSetDefRootPath

    # Config sections for removal of old version:
    Call VimCfgOldVerSections

    # Initialize user variables:
    # $vim_bin_path
    #   Holds the directory the executables are installed to.
    # $vim_install_param
    #   Holds the parameters to be passed to install.exe.  Starts with OLE
    #   registration (since a non-OLE gvim will not complain, and we want to
    #   always register an OLE gvim).
    # $vim_batch_names
    #   Holds the names to create batch files for.
    StrCpy $vim_install_root  "$INSTDIR"
    StrCpy $vim_bin_path      "$INSTDIR\${VIM_BIN_DIR}"
    StrCpy $vim_install_param ""
    StrCpy $vim_batch_names   "gvim evim gview gvimdiff vimtutor"

    ${Log} "Default install path: $vim_install_root"

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

# ----------------------------------------------------------------------------
# Function .onInstSuccess                                                 {{{2
# ----------------------------------------------------------------------------
Function .onInstSuccess
    WriteUninstaller ${VIM_BIN_DIR}\uninstall-gui.exe

    # Close log:
    !ifdef VIM_LOG_FILE
        ${LogClose}

        # Move log to install directory:
        Rename "$TEMP\${VIM_LOG_FILE}" "$vim_bin_path\${VIM_LOG_FILE}"
    !endif
FunctionEnd

# ----------------------------------------------------------------------------
# Function .onInstFailed                                                  {{{2
# ----------------------------------------------------------------------------
Function .onInstFailed
    ${ShowErr} $(str_msg_install_fail)

    # Close log:
    !ifdef VIM_LOG_FILE
        ${LogClose}
    !endif
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimLoadUninstallKeys                                           {{{2
#   Load all uninstall keys from Windows registry.
#
#   All uninstall keys will be concatenate as a single string (delimited by
#   CR/LF).  This is a workaround since NSIS does not support array.
#
#   Parameters : None
#   Returns    : None
#   Globals    :
#     The following globals will be changed by this functions:
#     - $vim_old_ver_keys  : Concatenated of all uninstall keys found.
#     - $vim_old_ver_count : Number of uninstall keys found.
# ----------------------------------------------------------------------------
Function VimLoadUninstallKeys
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
        EnumRegKey $R1 SHCTX ${REG_KEY_UNINSTALL} $R0

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
        ReadRegStr $R2 SHCTX "${REG_KEY_UNINSTALL}\$R1" "DisplayName"
        ${If}   ${Errors}
        ${OrIf} $R2 == ""
            ${Log} "WARNING: Skip uninstall key [$R1]: \
                    Cannot find sub-key 'DisplayName'!"
            ${Continue}
        ${EndIf}

        ReadRegStr $R2 SHCTX "${REG_KEY_UNINSTALL}\$R1" "UninstallString"
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

        # Store the sub-key found.  If the old version is the same as the
        # version currently been installed, its key will always be put at
        # front to make sure it will be included in the uninstall list as the
        # first item:
        IntOp  $vim_old_ver_count $vim_old_ver_count + 1
        ${If} $R1 S== "${VIM_PRODUCT_NAME}"
            StrCpy $vim_old_ver_keys "$R1$\r$\n$vim_old_ver_keys"
        ${Else}
            StrCpy $vim_old_ver_keys "$vim_old_ver_keys$R1$\r$\n"
        ${EndIf}

        ${Log} "Found Vim uninstall key No.$vim_old_ver_count: [$R1]"
    ${Loop}

    ${Log} "Found $vim_old_ver_count uninstall keys:$\r$\n\
            $vim_old_ver_keys"
    ClearErrors

    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimCfgOldVerSections                                           {{{2
#   Create/config dynamic sections to uninstall old Vim versions on the system.
#
#   All old versions will be uninstalled by default.  User is allowed to keep
#   some old versions as long as it's not the same version as the one being
#   installed.
#
#   Parameters : None
#   Returns    : None
# ----------------------------------------------------------------------------
Function VimCfgOldVerSections
    Push $R0
    Push $R1
    Push $R2

    StrCpy $R0 0
    ${DoWhile} $R0 < $vim_old_ver_count
        ${VimGetOldVerSecID} $R0 $R1
        ${VimGetOldVerKey}   $R0 $R2
        ${Log} "Old ver section No.$R0, ID=$R1, Key=[$R2]"

        !insertmacro SelectSection $R1

        # If the same version installed, we must remove it:
        ${If} $R2 S== "${VIM_PRODUCT_NAME}"
            !insertmacro SetSectionFlag $R1 ${SF_RO}
        ${EndIf}

        # Set section title to readable form:
        ReadRegStr $R2 SHCTX "${REG_KEY_UNINSTALL}\$R2" "DisplayName"
        SectionSetText $R1 '$(str_section_old_ver) $R2'

        IntOp $R0 $R0 + 1
    ${Loop}

    ${DoWhile} $R0 < ${VIM_MAX_OLD_VER}
        ${VimGetOldVerSecID} $R0 $R1
        ${Log} "Disable old ver section No.$R0, ID=$R1"
        !insertmacro UnselectSection $R1
        !insertmacro SetSectionFlag  $R1 ${SF_RO}
        SectionSetInstTypes $R1 0
        SectionSetText      $R1 ""

        IntOp $R0 $R0 + 1
    ${Loop}

    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimSetDefRootPath                                              {{{2
#   Set default install path.
#
#   Default install path will be determined in the following order:
#   - VIMRUNTIME environment string:
#     If set and its parent directory is a valid Vim install directory, its
#     parent directory will be used as default install path.
#   - VIM environment string:
#     If set and valid, its value will be used as default install path
#     directly.
#   - Install path of old versions found on the system.
#   - "Program Files/Vim" if all above fails.
#
#   Parameters : None
#   Returns    : None
#   Globals    :
#     $INSTDIR will be set to the default install path by this function.
# ----------------------------------------------------------------------------
Function VimSetDefRootPath
    Push $R0
    Push $R1
    Push $R2  # Install path valid flag

    # Initialize to invalid:
    StrCpy $R2 0

    # First try VIMRUNTIME environment string, use its parent directory as
    # install path if valid.
    ReadEnvStr $R0 "VIMRUNTIME"
    ${IfThen} $R0 != "" ${|} ${GetParent} $R0 $R0 ${|}
    ${If} $R0 != ""
        ${VimVerifyRootDir} $R0 $R2
        ${If} $R2 = 1
            ${Log} "Set install path per VIMRUNTIME: $R0"
            StrCpy $INSTDIR $R0
        ${EndIf}
    ${EndIf}

    # Then try VIM environment, use it as install path directly if valid.
    ${If} $R2 = 0
        ReadEnvStr $R0 "VIM"
        ${If} $R0 != ""
            ${VimVerifyRootDir} $R0 $R2
            ${If} $R2 = 1
                ${Log} "Set install path per VIM env: $R0"
                StrCpy $INSTDIR $R0
            ${EndIf}
        ${EndIf}
    ${EndIf}

    # Next try previously installed versions if any.  The install path will be
    # derived from the un-install key of the last installed version:
    ${If} $vim_old_ver_count > 0
        # Find the uninstall key for the last installed version ($R1):
        IntOp $R0 $vim_old_ver_count - 1
        ${VimGetOldVerKey} $R0 $R1

        # Read path of the un-installer for registry ($R0):
        ${If} $R1 != ""
            ReadRegStr $R0 SHCTX "${REG_KEY_UNINSTALL}\$R1" "UninstallString"
        ${Else}
            StrCpy $R0 ""
        ${EndIf}

        # Derive install path from uninstaller path name:
        ${GetParent} $R0 $R0
        ${GetParent} $R0 $R0
        ${VimVerifyRootDir} $R0 $R2
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

# ----------------------------------------------------------------------------
# Function VimRmOldVer                                                    {{{2
#   Unintalls the n-th old Vim version found on the system.
#
#   This function will be called by dynamic "old version" sections to remove
#   the specified old vim version found on the system.  Abort on error.
#   Parameters:
#     The index (ID) of the old vim version will be put on the top of the
#     stack.
#   Returns:
#     None
# ----------------------------------------------------------------------------
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
        ${ShowErr} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_no_rm_key)"
        Abort
    ${EndIf}

    StrCpy $R0 $R1
    ${LogPrint} "$(str_msg_rm_start) $R0 ..."

    # Read path of the uninstaller from registry ($R1):
    ReadRegStr $R1 SHCTX "${REG_KEY_UNINSTALL}\$R0" "UninstallString"
    ${If}   ${Errors}
    ${OrIf} $R1 == ""
        ${ShowErr} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_no_rm_reg)"
        Abort
    ${EndIf}

    ${IfNot} ${FileExists} $R1
        ${ShowErr} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_no_rm_exe)"
        Abort
    ${EndIf}

    # Path of uninstaller ($R2) and name of uninstaller($R3):
    ${GetParent}   $R1 $R2
    ${GetFileName} $R1 $R3

    # Copy unintall to temporary path:
    ${Logged4} CopyFiles /SILENT /FILESONLY $R1 $TEMP
    ${If}      ${Errors}
    ${OrIfNot} ${FileExists} "$TEMP\$R3"
        ${ShowErr} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_rm_copy_fail)"
        Abort
    ${EndIf}

    # Execute the uninstaller in TEMP, exit code stores in $R2.  Log is closed
    # before launch and reopened after that, so that uninstaller can write to
    # the same log file.
    ${Logged2Reopen} ExecWait '"$TEMP\$R3" _?=$R2' $R2
    ${If} ${Errors}
        ${Logged1} Delete "$TEMP\$R3"
        ${ShowErr} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_rm_run_fail)"
        Abort
    ${EndIf}

    ${Logged1} Delete "$TEMP\$R3"

    ${Log} "Uninstaller exit code: $R2"

    # If this is the uninstaller for the same version we're trying to
    # installer, it's not possible to continue with installation:
    ${If}    $R2 <> 0
    ${AndIf} $R0 S== "${VIM_PRODUCT_NAME}"
        ${ShowErr} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_abort_install)"
        Abort
    ${EndIf}

    # We may have been put to the background when uninstall did something:
    BringToFront

    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimFinalCheck                                                  {{{2
#   Final check before install.
#
#   This function is the exit callback of the directory page, it performs last
#   minute check before any changes have been made:
#   - Check to make sure install path is valid.
#   - Check to make sure there is no running instances of Vim.
#   Refuse to install if the check fails.
# ----------------------------------------------------------------------------
Function VimFinalCheck
    Push $R0

    # Check install path:
    StrCpy $vim_install_root "$INSTDIR"
    ${VimVerifyRootDir} $vim_install_root $R0
    ${If} $R0 = 0
        ${ShowErr} $(str_msg_invalid_root)
        Pop $R0
        Abort
    ${EndIf}

    # Check running instances of Vim:
    SetOutPath $TEMP
    ${VimExtractConsoleExe}
    ${VimIsRuning} $TEMP $R0
    Delete "$TEMP\vim.exe"
    ${If} $R0 <> 0
        ${ShowErr} $(str_msg_vim_running)
        Pop $R0
        Abort
    ${EndIf}

    # Update other path:
    StrCpy $vim_bin_path "$INSTDIR\${VIM_BIN_DIR}"

    ${Log} "Final install path: $vim_install_root"
    ${Log} "Final binary  path: $vim_bin_path"

    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimGetOldVerSecIDFunc                                          {{{2
#   Get ID of the n-th dynamically generated old version section.
#
#   As NSIS does not support array, it's not straightforward to get ID of
#   dynamically generated sections from its index.  Here we'll call a special
#   function to push IDs of all dynamically generated sections on to stack in
#   order, the retrieve the required ID from stack.
#
#   This function should better be called using the wrapper macro
#   VimGetOldVerSecID.
#
#   Parameters:
#     Index of the section should be put on the top of stack.
#   Returns:
#     ID of the corresponding old version section on the top of the stack.
# ----------------------------------------------------------------------------
Function VimGetOldVerSecIDFunc
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

# ----------------------------------------------------------------------------
# Function VimGetOldVerKeyFunc                                            {{{2
#   Get the un-installer key for n-th old Vim version installed on the system.
#
#   All un-installer keys found on the system will be stored in a string,
#   delimited by CR/LF.  This function will retrieve specified key from that
#   string.  This is a workaround since NSIS does not support array.
#
#   This function should better be called using the wrapper macro
#   VimGetOldVerKey
#
#   Parameters:
#     Index of the key to retrieve should be put on the top of stack.
#   Returns:
#     Required key on the top of the stack.
# ----------------------------------------------------------------------------
Function VimGetOldVerKeyFunc
    Exch $R0  # Index of the un-install key

    ${If} $R0 >= $vim_old_ver_count
        StrCpy $R0 ""
    ${Else}
        # WordFindS uses 1 based index:
        IntOp $R0 $R0 + 1
        ${WordFindS} $vim_old_ver_keys "$\r$\n" "+$R0" $R0
    ${EndIf}

    Exch $R0
FunctionEnd


##############################################################################
# Dynamic sections to support removal of old versions                     {{{1
##############################################################################

!define OldVerSection "!insertmacro _OldVerSection"
!macro _OldVerSection _ID
    Section "Uninstall existing version ${_ID}" `id_section_old_ver_${_ID}`
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
    Push ${id_section_old_ver_4}
    Push ${id_section_old_ver_3}
    Push ${id_section_old_ver_2}
    Push ${id_section_old_ver_1}
    Push ${id_section_old_ver_0}
FunctionEnd


##############################################################################
# Installer Sections                                                      {{{1
##############################################################################

Section $(str_section_exe) id_section_exe
    SectionIn 1 2 3 RO

    ${LogSectionStart}

    ${Logged1} SetOutPath $vim_bin_path
    ${Logged2} File /oname=gvim.exe     ${VIMSRC}\gvim_ole.exe
    ${Logged2} File /oname=install.exe  ${VIMSRC}\installw32.exe
    ${Logged2} File /oname=uninstal.exe ${VIMSRC}\uninstalw32.exe
    ${Logged1} File ${VIMSRC}\vimrun.exe
    ${Logged2} File /oname=xxd.exe      ${VIMSRC}\xxdw32.exe
    ${Logged1} File ${VIMTOOLS}\diff.exe
    ${Logged1} File ${VIMRT}\vimtutor.bat
    ${Logged1} File ${VIMRT}\README.txt
    ${Logged1} File ${VIMRT}\uninstal.txt
    ${Logged1} File ${VIMRT}\*.vim
    ${Logged1} File ${VIMRT}\rgb.txt

    ${Logged1} SetOutPath $vim_bin_path\colors
    ${Logged1} File ${VIMRT}\colors\*.*

    ${Logged1} SetOutPath $vim_bin_path\compiler
    ${Logged1} File ${VIMRT}\compiler\*.*

    ${Logged1} SetOutPath $vim_bin_path\doc
    ${Logged1} File ${VIMRT}\doc\*.txt
    ${Logged1} File ${VIMRT}\doc\tags

    ${Logged1} SetOutPath $vim_bin_path\ftplugin
    ${Logged1} File ${VIMRT}\ftplugin\*.*

    ${Logged1} SetOutPath $vim_bin_path\indent
    ${Logged1} File ${VIMRT}\indent\*.*

    ${Logged1} SetOutPath $vim_bin_path\macros
    ${Logged1} File ${VIMRT}\macros\*.*

    ${Logged1} SetOutPath $vim_bin_path\plugin
    ${Logged1} File ${VIMRT}\plugin\*.*

    ${Logged1} SetOutPath $vim_bin_path\autoload
    ${Logged1} File ${VIMRT}\autoload\*.*

    ${Logged1} SetOutPath $vim_bin_path\autoload\xml
    ${Logged1} File ${VIMRT}\autoload\xml\*.*

    ${Logged1} SetOutPath $vim_bin_path\syntax
    ${Logged1} File ${VIMRT}\syntax\*.*

    ${Logged1} SetOutPath $vim_bin_path\spell
    ${Logged1} File ${VIMRT}\spell\*.txt
    ${Logged1} File ${VIMRT}\spell\*.vim
    ${Logged1} File ${VIMRT}\spell\*.spl
    ${Logged1} File ${VIMRT}\spell\*.sug

    ${Logged1} SetOutPath $vim_bin_path\tools
    ${Logged1} File ${VIMRT}\tools\*.*

    ${Logged1} SetOutPath $vim_bin_path\tutor
    ${Logged1} File ${VIMRT}\tutor\*.*

    ${LogSectionEnd}
SectionEnd

Section $(str_section_console) id_section_console
    SectionIn 1 3

    ${LogSectionStart}

    ${Logged1} SetOutPath $vim_bin_path
    ${VimExtractConsoleExe}
    StrCpy $vim_batch_names "$vim_batch_names vim view vimdiff"

    ${LogSectionEnd}
SectionEnd

Section $(str_section_batch) id_section_batch
    SectionIn 3

    ${LogSectionStart}
    StrCpy $vim_install_param \
          "$vim_install_param -create-batfiles $vim_batch_names"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_desktop) id_section_desktop
    SectionIn 1 3

    ${LogSectionStart}
    StrCpy $vim_install_param "$vim_install_param -install-icons"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_start_menu) id_section_startmenu
    SectionIn 1 3

    ${LogSectionStart}
    StrCpy $vim_install_param "$vim_install_param -add-start-menu"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_quick_launch) id_section_quicklaunch
    SectionIn 1 3

    ${LogSectionStart}

    ${If} $QUICKLAUNCH != $TEMP
        SetOutPath ""
        CreateShortCut "$QUICKLAUNCH\${VIM_LNK_NAME}.lnk" \
            "$vim_bin_path\gvim.exe" "" "$vim_bin_path\gvim.exe" 0
    ${EndIf}

    ${LogSectionEnd}
SectionEnd

Section $(str_section_edit_with) id_section_editwith
    SectionIn 1 3

    ${LogSectionStart}

    # Install/Upgrade gvimext.dll:
    !define LIBRARY_SHELL_EXTENSION

    ${If} ${RunningX64}
        !define LIBRARY_X64
        !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMSRC}\GvimExt\gvimext64.dll" \
            "$vim_bin_path\gvimext.dll" "$vim_bin_path"
        !undef LIBRARY_X64
    ${Else}
        !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMSRC}\GvimExt\gvimext.dll" \
            "$vim_bin_path\gvimext.dll" "$vim_bin_path"
    ${EndIf}

    !undef LIBRARY_SHELL_EXTENSION

    # We don't have a separate entry for the "Open With..." menu, assume
    # the user wants either both or none.
    StrCpy $vim_install_param \
          "$vim_install_param -install-popup -install-openwith"

    ${LogSectionEnd}
SectionEnd

Section $(str_section_vim_rc) id_section_vimrc
    SectionIn 1 3

    ${LogSectionStart}

    # Write default _vimrc only if the file does not exist.  We'll test for
    # .vimrc (and its short version) and _vimrc:
    SetOutPath $vim_install_root
    ${IfNot}    ${FileExists} "$vim_install_root\_vimrc"
    ${AndIfNot} ${FileExists} "$vim_install_root\.vimrc"
    ${AndIfNot} ${FileExists} "$vim_install_root\vimrc~1"
        ${Logged2} File /oname=_vimrc data\mswin_vimrc.vim
    ${EndIf}

    ${LogSectionEnd}
SectionEnd

Section $(str_section_plugin_home) id_section_pluginhome
    SectionIn 1 3

    ${LogSectionStart}
    StrCpy $vim_install_param "$vim_install_param -create-directories home"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_plugin_vim) id_section_pluginvim
    SectionIn 3

    ${LogSectionStart}
    StrCpy $vim_install_param "$vim_install_param -create-directories vim"
    ${LogSectionEnd}
SectionEnd

!ifdef HAVE_VIS_VIM
    Section $(str_section_vis_vim) id_section_visvim
        SectionIn 3

        ${LogSectionStart}

        # TODO: Check if this works on x64 or not.
        !insertmacro InstallLib REGDLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMSRC}\VisVim\VisVim.dll" \
            "$vim_bin_path\VisVim.dll" "$vim_bin_path"

        ${Logged1} SetOutPath $vim_bin_path
        ${Logged1} File ${VIMSRC}\VisVim\README_VisVim.txt

        ${LogSectionEnd}
    SectionEnd
!endif

!ifdef HAVE_NLS
    Section $(str_section_nls) id_section_nls
        SectionIn 1 3

        ${LogSectionStart}

        SetOutPath $vim_bin_path\lang
        File /r ${VIMRT}\lang\*.*
        SetOutPath $vim_bin_path\keymap
        File ${VIMRT}\keymap\README.txt
        File ${VIMRT}\keymap\*.vim

        # Install NLS support DLLs:
        SetOutPath $vim_bin_path
        !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMRT}\libintl.dll" \
            "$vim_bin_path\libintl.dll" "$vim_bin_path"

        !ifdef HAVE_ICONV
            !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
                "${VIMRT}\iconv.dll" \
                "$vim_bin_path\iconv.dll" "$vim_bin_path"
        !endif

        ${LogSectionEnd}
    SectionEnd
!endif

Section -call_install_exe
    ${Logged1} SetOutPath $vim_bin_path
    ${Logged1} nsExec::ExecToLog \
        '"$vim_bin_path\install.exe" $vim_install_param'

    # TODO: Check return value:
    Exch $R0
    ${Log} "install.exe exit code - $R0"
    Pop $R0
SectionEnd

Section -post
    BringToFront
SectionEnd


##############################################################################
# Description for Installer Sections                                      {{{1
##############################################################################
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_0}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_1}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_2}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_3}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_4}   $(str_desc_old_ver)
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

    # Please note $INSTDIR is set to the directory where the uninstaller is
    # created.  Thus the "vim61" directory is included in it.

    # Delete the context menu entry and batch files:
    ${Logged1} nsExec::ExecToLog '"$INSTDIR\uninstal.exe" -nsis'
    # TODO: Check return value:
    Exch $R0
    ${Log} "uninstall.exe exit code - $R0"
    Pop $R0

    # Uninstall VisVim if it was included.
    # TODO: Any special handling on x64?
    !ifdef HAVE_VIS_VIM
        !insertmacro UninstallLib REGDLL NOTSHARED REBOOT_NOTPROTECTED \
            "$INSTDIR\VisVim.dll"
    !endif

    # Remove gvimext.dll:
    !define LIBRARY_SHELL_EXTENSION

    ${If} ${RunningX64}
        !define LIBRARY_X64
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$INSTDIR\gvimext.dll"
        !undef LIBRARY_X64
    ${Else}
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$INSTDIR\gvimext.dll"
    ${EndIf}

    !undef LIBRARY_SHELL_EXTENSION

    # Delete quick launch:
    ${Logged1} Delete "$QUICKLAUNCH\${VIM_LNK_NAME}.lnk"

    # Delete log file:
    !ifdef VIM_LOG_FILE
        ${Logged1} Delete "$INSTDIR\${VIM_LOG_FILE}"
    !endif

    # We may have been put to the background when uninstall did something.
    BringToFront

    ${LogSectionEnd}
SectionEnd

Section "un.$(str_unsection_exe)" id_unsection_exe
    ${LogSectionStart}

    # Remove NLS support DLLs.  This is overkill.
    !ifdef HAVE_NLS
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$INSTDIR\libintl.dll"

        !ifdef HAVE_ICONV
            !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
                "$INSTDIR\iconv.dll"
        !endif
    !endif

    # Remove everything but *.dll files.  Avoids that a lot remains when
    # gvimext.dll cannot be deleted.
    ClearErrors
    ${Logged2} RMDir /r "$INSTDIR\VisVim"   # TODO: Does this exist?
    ${Logged2} RMDir /r "$INSTDIR\autoload"
    ${Logged2} RMDir /r "$INSTDIR\colors"
    ${Logged2} RMDir /r "$INSTDIR\compiler"
    ${Logged2} RMDir /r "$INSTDIR\doc"
    ${Logged2} RMDir /r "$INSTDIR\ftplugin"
    ${Logged2} RMDir /r "$INSTDIR\indent"
    ${Logged2} RMDir /r "$INSTDIR\keymap"
    ${Logged2} RMDir /r "$INSTDIR\lang"
    ${Logged2} RMDir /r "$INSTDIR\macros"
    ${Logged2} RMDir /r "$INSTDIR\plugin"
    ${Logged2} RMDir /r "$INSTDIR\spell"
    ${Logged2} RMDir /r "$INSTDIR\syntax"
    ${Logged2} RMDir /r "$INSTDIR\tools"
    ${Logged2} RMDir /r "$INSTDIR\tutor"
    ${Logged1} Delete "$INSTDIR\*.bat"
    ${Logged1} Delete "$INSTDIR\*.exe"
    ${Logged1} Delete "$INSTDIR\*.txt"
    ${Logged1} Delete "$INSTDIR\*.vim"

    ${If} ${Errors}
        ${ShowErr} $(str_msg_rm_exe_fail)
    ${EndIf}

    # No error message if the "vim62" directory can't be removed, the
    # gvimext.dll may still be there.
    ${Logged1} RMDir "$INSTDIR"

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
    !ifdef VIM_LOG_FILE
        ${LogClose}
    !endif
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

# ----------------------------------------------------------------------------
# Function un.onInit                                                      {{{2
# ----------------------------------------------------------------------------
Function un.onInit
    Push $R0

    # Initialize log:
    !ifdef VIM_LOG_FILE
        ${LogInit} "$TEMP\${VIM_LOG_FILE}" "Vim uninstaller log"
    !endif

    # Use shell folders for "all" user:
    ${Logged1} SetShellVarContext all

    # 64-bit view should be used on Windows x64:
    ${Logged1} SetRegView 64

    # Get root path of the installation:
    ${GetParent} $INSTDIR $vim_install_root

    # Check to make sure this is a valid directory:
    ${VimVerifyRootDir} $vim_install_root $R0
    ${If} $R0 = 0
        ${ShowErr} $(str_msg_invalid_root)
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

# ----------------------------------------------------------------------------
# Function un.onSelChange                                                 {{{2
# ----------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------
# Function un.VimCheckRunning                                             {{{2
#   Check if there're running Vim instances or not before any change has been
#   made.  Refuse to uninstall if Vim is still running.
# ----------------------------------------------------------------------------
Function un.VimCheckRunning
    Push $R0

    ${VimIsRuning} $INSTDIR $R0
    ${If} $R0 <> 0
        ${ShowErr} $(str_msg_vim_running)
        Pop $R0
        Abort
    ${EndIf}

    Pop $R0
FunctionEnd
