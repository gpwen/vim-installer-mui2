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
!include "StrFunc.nsh"
!include "TextFunc.nsh"
!include "Util.nsh"
!include "WordFunc.nsh"
!include "x64.nsh"

!include "helper_util.nsh"
!include "simple_log.nsh"

# Global variables:
Var vim_install_root
Var vim_bin_path
Var vim_old_ver_keys
Var vim_old_ver_count
Var vim_shell_ext_name
Var vim_has_console
Var vim_batch_exe
Var vim_batch_arg
Var vim_batch_ver_found

# List of alphanumeric:
!define ALPHA_NUMERIC     "abcdefghijklmnopqrstuvwxyz0123456789"

# Version strings:
!define VER_SHORT         "${VER_MAJOR}.${VER_MINOR}"
!define VER_SHORT_NDOT    "${VER_MAJOR}${VER_MINOR}"
!define VIM_PRODUCT_NAME  "Vim ${VER_SHORT}"
!define VIM_BIN_DIR       "vim${VER_SHORT_NDOT}"
!define VIM_LNK_NAME      "gVim ${VER_SHORT}"

# Specification for shortcuts on desktop.  Shortcuts are delimited with
# newline (\n), fields in each shortcut are delimited with "|".  Please note
# fields can NOT be empty, you have to add some whitespaces there even if it's
# empty, otherwise the field cannot be handled correctly.  It's the limitation
# of the macro used to parse such specification.
#    Title (no extension)        | Target   | Arg | Work-dir
!define VIM_DESKTOP_SHORTCUTS \
    "gVim ${VER_SHORT}           | gvim.exe |     | $\n\
     gVim Easy ${VER_SHORT}      | gvim.exe | -y  | $\n\
     gVim Read only ${VER_SHORT} | gvim.exe | -R  | "

# Specification for quick launch shortcuts:
!define VIM_LAUNCH_SHORTCUTS \
    "gVim ${VER_SHORT} | gvim.exe | | "

# Specification for console version startmenu shortcuts:
!define VIM_CONSOLE_STARTMENU \
    "Vim           | vim.exe |    | $\n\
     Vim Read-only | vim.exe | -R | $\n\
     Vim Diff      | vim.exe | -d | "

# Specification for GUI version startmenu shortcuts:
!define VIM_GUI_STARTMENU \
    "gVim           | gvim.exe |    | $\n\
     gVim Easy      | gvim.exe | -y | $\n\
     gVim Read-only | gvim.exe | -R | $\n\
     gVim Diff      | gvim.exe | -d | "

# Specification for miscellaneous startmenu shortcuts:
!define VIM_MISC_STARTMENU \
    "Uninstall | uninstall-gui.exe |      | $vim_bin_path$\n\
     Vim tutor | vimtutor.bat      |      | $vim_bin_path$\n\
     Help      | gvim.exe          | -c h | "

# Specification for batch wrapper of console version:
#    Title    | Target       | Arg
!define VIM_CONSOLE_BATCH \
    "vim      | vim.exe      |   $\n\
     view     | vim.exe      | -R$\n\
     vimdiff  | vim.exe      | -d$\n\
     vimtutor | vimtutor.bat |   "

# Specification for batch wrapper of GUI version:
!define VIM_GUI_BATCH \
    "gvim     | gvim.exe     |   $\n\
     evim     | gvim.exe     | -y$\n\
     gview    | gvim.exe     | -R$\n\
     gvimdiff | gvim.exe     | -d"

# Subdirectories of VIMFILES, delimited by \n:
!define VIM_PLUGIN_SUBDIR \
    "colors$\n\
     compiler$\n\
     doc$\n\
     ftdetect$\n\
     ftplugin$\n\
     indent$\n\
     keymap$\n\
     plugin$\n\
     syntax"

# Uninstall info:
#   Type | Registry Subkey  | Registry Value
!define VIM_UNINSTALL_REG_INFO \
    "STR | DisplayName      | ${VIM_PRODUCT_NAME} (self-installing) $\n\
     STR | UninstallString  | $vim_bin_path\uninstall-gui.exe       $\n\
     STR | InstallLocation  | $vim_bin_path                         $\n\
     STR | DisplayIcon      | $vim_bin_path\gvim.exe,0              $\n\
     STR | HelpLink         | http://www.vim.org/                   $\n\
     STR | URLUpdateInfo    | http://www.vim.org/download.php#pc    $\n\
     STR | DisplayVersion   | ${VER_SHORT}                          $\n\
     DW  | NoModify         | 1                                     $\n\
     DW  | NoRepair         | 1 "

# Registry keys:
!define REG_KEY_WINDOWS   "software\Microsoft\Windows\CurrentVersion"
!define REG_KEY_UNINSTALL "${REG_KEY_WINDOWS}\Uninstall"
!define REG_KEY_SH_EXT    "${REG_KEY_WINDOWS}\Shell Extensions\Approved"
!define REG_KEY_VIM       "Software\Vim"
!define VIM_SH_EXT_NAME   "Vim Shell Extension"
!define VIM_SH_EXT_CLSID  "{51EEE242-AD87-11d3-9C1E-0090278BBD99}"

# List of file extensions to be registered:
!define VIM_FILE_EXT_LIST ".htm|.html|.vim|*"

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
    !define MUI_LANGDLL_REGISTRY_KEY       "${REG_KEY_VIM}"
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
#
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

# ----------------------------------------------------------------------------
# macro VimGetPluginRoot                                                  {{{2
#   Get root directory for plugins (vimfiles directory). $_ENV_STR is the name
#   of the environment string to check for VIM root directory; $_PLUGIN_ROOT
#   is the output plugin root directory.
# ----------------------------------------------------------------------------
!define VimGetPluginRoot "!insertmacro _VimGetPluginRootCall"
!macro _VimGetPluginRootCall _ENV_STR _PLUGIN_ROOT
    Push `${_ENV_STR}`
    ${CallArtificialFunction} _VimGetPluginRoot
    Pop ${_PLUGIN_ROOT}
!macroend
!macro _VimGetPluginRoot
    Exch $R0  # Name of the environment string
    Push $R1

    # Determine root for plugin directory:
    # $R0 - Input environment string name.
    # $R1 - Plugin root.
    # Output stored in $R0
    ReadEnvStr $R1 $R0
    ${If}    "$R1" != ""
    ${AndIf} ${FileExists} "$R1\*.*"
        ${Log} "Get plugin root [$R1] from environment string [$R0]."
        StrCpy $R0 "$R1\vimfiles"
    ${Else}
        ${Log} "Environment [$R0] is invalid, \
                fall back to [$vim_install_root] as plugin root."
        StrCpy $R0 "$vim_install_root\vimfiles"
    ${EndIf}

    # Output:
    Pop  $R1
    Exch $R0
!macroend

# ----------------------------------------------------------------------------
# macro VimRmShortcuts                                                    {{{2
#   Wrapper to call un.VimRmFileSpecFunc to remove shortcuts.
#
#   Parameters:
#     $_SHORTCUT_SPEC : Shortcut specification.
#     $_SHORTCUT_ROOT : Shortcut root.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimRmShortcuts "!insertmacro _VimRmShortcuts"
!macro _VimRmShortcuts _SHORTCUT_SPEC _SHORTCUT_ROOT
    Push `${_SHORTCUT_SPEC}`
    Push `${_SHORTCUT_ROOT}`
    Push 1         # Field index of file title in shortcut specification.
    Push ".lnk"    # File name extension of shortcuts.
    Push ""        # Verification callback
    Call un.VimRmFileSpecFunc
!macroend

# ----------------------------------------------------------------------------
# macro VimRmBatches                                                      {{{2
#   Wrapper to call un.VimRmFileSpecFunc to remove batch files.
#
#   Parameters:
#     $_BATCH_SPEC : Batch file specification.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimRmBatches "!insertmacro _VimRmBatches"
!macro _VimRmBatches _BATCH_SPEC
    Push `${_BATCH_SPEC}`
    Push "$WINDIR" # Root of batch files.
    Push 1         # Field index of file title in batch file specification.
    Push ".bat"    # File name extension of batch files.
    Push $R0
    GetFunctionAddress $R0 "un._VimVerifyBatch"
    Exch $R0       # Verification callback
    Call un.VimRmFileSpecFunc
!macroend

##############################################################################
# Installer Functions                                                     {{{1
##############################################################################

# ----------------------------------------------------------------------------
# Declaration of external functions                                       {{{2
# ----------------------------------------------------------------------------
${DECLARE_LoopMatrix}

# ----------------------------------------------------------------------------
# Function .onInit                                                        {{{2
# ----------------------------------------------------------------------------
Function .onInit
    # Initialize all globals:
    StrCpy $vim_install_root    ""
    StrCpy $vim_bin_path        ""
    StrCpy $vim_old_ver_keys    ""
    StrCpy $vim_old_ver_count   0
    StrCpy $vim_has_console     0
    StrCpy $vim_batch_exe       ""
    StrCpy $vim_batch_arg       ""
    StrCpy $vim_batch_ver_found 0

    # Initialize log:
    !ifdef VIM_LOG_FILE
        ${LogInit} "$TEMP\${VIM_LOG_FILE}" "Vim installer log"
    !endif

    # Use shell folders for "all" user:
    ${Logged1} SetShellVarContext all

    # 64-bit view should be used on Windows x64:
    ${If} ${RunningX64}
        ${Logged1} SetRegView 64
    ${EndIf}

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
    StrCpy $vim_install_root  "$INSTDIR"
    StrCpy $vim_bin_path      "$INSTDIR\${VIM_BIN_DIR}"

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

# ----------------------------------------------------------------------------
# Function VimCreatePluginDir                                             {{{2
#   Create plugin directories.
#
#   Parameters:
#     Environment string to check for plugin root on the top of stack.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
Function VimCreatePluginDir
    Exch $R0  # Name of the environment string for plugin root.
    Push $R1
    Push $R2
    Push $R3

    # Determine plugin root directory.
    # $R0 - Plugin root directory
    ${VimGetPluginRoot} $R0 $R0

    # Create vimfiles:
    ${Logged1} CreateDirectory "$R0"

    # Create all subdirectories:
    # $R1 - Loop index, 1 based
    # $R2 - Number of subdirectories
    # $R3 - Current subdirectory
    ${CountFields} "${VIM_PLUGIN_SUBDIR}" "$\n" $R2
    ${For} $R1 1 $R2
        ${WordFindS} "${VIM_PLUGIN_SUBDIR}" "$\n" "+$R1" $R3
        ${Logged1} CreateDirectory "$R0\$R3"
    ${Next}

    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimCreateShortcuts                                             {{{2
#   Create specified shortcuts.
#
#   Parameters:
#     The following parameters should be pushed onto stack in order.
#     - Shortcut specification.
#     - Shortcut root.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimCreateShortcuts "!insertmacro _VimCreateShortcuts"
!macro _VimCreateShortcuts _SHORTCUT_SPEC _SHORTCUT_ROOT
    # Create shortcut root if necessary:
    ${IfNot} ${FileExists} "${_SHORTCUT_ROOT}\*.*"
        ${Logged1} CreateDirectory "${_SHORTCUT_ROOT}"
    ${EndIf}

    # Create all specified shortcuts:
    ${LoopMatrix} "${_SHORTCUT_SPEC}" "_VimCreateShortcutsFunc" \
        "${_SHORTCUT_ROOT}" ""
!macroend

Function _VimCreateShortcutsFunc
    Exch      $R5     # Arg 2: Ignored
    ${ExchAt} 1 $R4   # Arg 1: Shortcut root path
    ${ExchAt} 2 $R3   # Col 4: Working directory of the shortcut
    ${ExchAt} 3 $R2   # Col 3: Target arguments
    ${ExchAt} 4 $R1   # Col 2: Shortcut target
    ${ExchAt} 5 $R0   # Col 1: Shortcut filename

    # Prefix binary path to the target:
    StrCpy $R1 "$vim_bin_path\$R1"

    # Create the shortcut:
    SetOutPath $R3
    ${Logged5} CreateShortCut "$R4\$R0.lnk" "$R1" "$R2" "$R1" 0

    # Restore the stack:
    Pop $R5
    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimCreateBatches                                               {{{2
#   Create specified batch files.
#
#   Parameters:
#     The following parameters should be pushed onto stack in order.
#     - Batch file specification.
#     - Name of the batch file template (in target environment).
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimCreateBatches "!insertmacro _VimCreateBatches"
!macro _VimCreateBatches _BATCH_SPEC _BATCH_TMPL
    ${LoopMatrix} "${_BATCH_SPEC}" "_VimCreateBatchFunc" \
        "${_BATCH_TMPL}" ""
!macroend

Function _VimCreateBatchFunc
    Exch      $R4     # Arg 2: Ignored
    ${ExchAt} 1 $R3   # Arg 1: Batch file template (in target environment).
    ${ExchAt} 2 $R2   # Col 3: Argument of the target.
    ${ExchAt} 3 $R1   # Col 2: Target of the batch.
    ${ExchAt} 4 $R0   # Col 1: Name of the batch file (sans .bat)

    # Create the batch file:
    StrCpy $R0 "$WINDIR\$R0.bat"
    StrCpy $vim_batch_exe "$R1"
    StrCpy $vim_batch_arg "$R2"
    ${Log} "Create batch file: [$R0], Target=[$R1], Arg=[$R2]"
    ${LineFind} "$R3" "$R0" "" "_VimCreateBatchCallback"

    # Restore the stack:
    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function _VimCreateBatchCallback                                        {{{2
#   Callback function for LineFind to manipulate batch file template.
#
#   This callback function will replace <<BATCH-CONFIG>> space holder in the
#   template file with real environment settings to create the final batch
#   file.  The batch file is in fact a wrapper for Vim executables to makes it
#   easier to launch Vim from DOS prompt.  Environment settings are passed in
#   with the following global variables:
#   $vim_batch_exe : Executable target for the batch file (without path).
#   $vim_batch_arg : Argument for the executable target.
#
#   LineFind will set the following registers upon entrance:
#     $R9 - current line
#     $R8 - current line number
#     $R7 - current line negative number
#     $R6 - current range of lines
#     $R5 - handle of a file opened to read
#     $R4 - handle of a file opened to write ($R4="" if "/NUL")
#
#     you can use any string functions
#     $R0-$R3  are not used (save data in them).
#     ...
#
#   This function should returns one of the following strings on the top of
#   the stack:
#     "StopLineFind" : Exit from function
#     "SkipWrite"    : Skip current line (ignored if "/NUL")
#     Otherwise      : Write the content of $R9 to the output file.
# ----------------------------------------------------------------------------
Function _VimCreateBatchCallback
    # Remove CR and/or LF.  This can also convert the input file to DOS format
    # (the input file could be UNIX format if compiled from source directly):
    ${TrimNewLines} "$R9" $R9

    ${If} "$R9" S== "<<BATCH-CONFIG>>"
        # Replace space holder with real config:
        FileWrite $R4 "set VIM_EXE_NAME=$vim_batch_exe$\r$\n"
        FileWrite $R4 "set VIM_EXE_ARG=$vim_batch_arg$\r$\n"
        FileWrite $R4 "set VIM_VER_NODOT=${VIM_BIN_DIR}$\r$\n"
        FileWrite $R4 "set VIM_EXE_DIR=$vim_install_root\%VIM_VER_NODOT%$\r$\n"
        Push "SkipWrite"
    ${Else}
        # Write the original line, except EOL is changed to DOS format:
        StrCpy $R9 "$R9$\r$\n"
        Push ""
    ${EndIf}
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimRegShellExt                                                 {{{2
#   Register vim shell extension.
#
#   Register view should be set before call this function.
#
#   Parameters:
#     Full path of the shell extension should be put on the top of stack.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
Function VimRegShellExt
    Exch $R0  # Full path of the vim shell extension
    Push $R1
    Push $R2

    # Register inproc server:
    # $R1 - CLSID registry key.
    StrCpy $R1 "CLSID\${VIM_SH_EXT_CLSID}"
    ${Logged4} WriteRegStr HKCR "$R1" "" "${VIM_SH_EXT_NAME}"
    ${Logged4} WriteRegStr HKCR "$R1\InProcServer32" "" "$R0"
    ${Logged4} WriteRegStr HKCR "$R1\InProcServer32" \
        "ThreadingModel" "Apartment"

    # Register shell extension:
    ${Logged4} WriteRegStr HKCR \
        "*\shellex\ContextMenuHandlers\gvim" "" "${VIM_SH_EXT_CLSID}"
    ${Logged4} WriteRegStr SHCTX "${REG_KEY_SH_EXT}" \
        "${VIM_SH_EXT_CLSID}" "${VIM_SH_EXT_NAME}"
    ${Logged4} WriteRegStr SHCTX "${REG_KEY_VIM}\Gvim" \
        "path" "$vim_bin_path\gvim.exe"

    # Register "Open With ..." list entry:
    ${Logged4} WriteRegStr HKCR \
        "Applications\gvim.exe\shell\edit\command" "" \
        '"$vim_bin_path\gvim.exe" "%1"'

    # Register all supported extensions:
    # $R0 - Loop index, 1 based
    # $R1 - Number of file extensions to register
    # $R2 - File extension to register
    ${CountFields} "${VIM_FILE_EXT_LIST}" "|" $R1
    ${For} $R0 1 $R1
        ${WordFindS} "${VIM_FILE_EXT_LIST}" "|" "+$R0" $R2
        ${Logged4} WriteRegStr HKCR "$R2\OpenWithList\gvim.exe" "" ""
    ${Next}

    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimRegUninstallInfoCallback                                    {{{2
#   Callback function for LoopMatrix.  It's used to write uninstall
#   information into windows registry.
# ----------------------------------------------------------------------------
Function VimRegUninstallInfoCallback
    Exch      $R4     # Arg 2: Ignored
    ${ExchAt} 1 $R3   # Arg 1: Ignored
    ${ExchAt} 2 $R2   # Col 3: Registry value
    ${ExchAt} 3 $R1   # Col 2: Registry subkey
    ${ExchAt} 4 $R0   # Col 1: Registry type STR|DW

    # $R3 - Uninstall registry key.
    StrCpy $R3 "${REG_KEY_UNINSTALL}\${VIM_PRODUCT_NAME}"

    ${If}     $R0 S== "STR"
        ${Logged4} WriteRegStr   SHCTX "$R3" "$R1" "$R2"
    ${ElseIf} $R0 S== "DW"
        ${Logged4} WriteRegDWORD SHCTX "$R3" "$R1" "$R2"
    ${Else}
        ${Log} "ERROR: Unknow subkey type : [$R0]!"
    ${EndIf}

    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
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

    # Flags that console version has been installed:
    StrCpy $vim_has_console 1

    ${LogSectionEnd}
SectionEnd

Section $(str_section_batch) id_section_batch
    SectionIn 3

    ${LogSectionStart}

    # Create batch files for the console version if installed:
    ${If} $vim_has_console <> 0
        GetTempFileName $R0
        ${Logged2} File "/oname=$R0" "data\cli_template.bat"
        ${VimCreateBatches} "${VIM_CONSOLE_BATCH}" "$R0"
        ${Logged1} Delete "$R0"
    ${EndIf}

    # Create batch files for the GUI version:
    GetTempFileName $R0
    ${Logged2} File "/oname=$R0" "data\gui_template.bat"
    ${VimCreateBatches} "${VIM_GUI_BATCH}" "$R0"
    ${Logged1} Delete "$R0"

    ${LogSectionEnd}
SectionEnd

Section $(str_section_desktop) id_section_desktop
    SectionIn 1 3

    ${LogSectionStart}
    ${VimCreateShortcuts} "${VIM_DESKTOP_SHORTCUTS}" "$DESKTOP"
    ${LogSectionEnd}
SectionEnd

Section $(str_section_start_menu) id_section_startmenu
    SectionIn 1 3

    ${LogSectionStart}

    # Create shortcuts for the console version if installed:
    ${If} $vim_has_console <> 0
        ${VimCreateShortcuts} "${VIM_CONSOLE_STARTMENU}" \
            "$SMPROGRAMS\${VIM_PRODUCT_NAME}"
    ${EndIf}

    # Create shortcuts for the GUI version:
    ${VimCreateShortcuts} "${VIM_GUI_STARTMENU}"  \
        "$SMPROGRAMS\${VIM_PRODUCT_NAME}"

    # Create misc shortcuts:
    ${VimCreateShortcuts} "${VIM_MISC_STARTMENU}" \
        "$SMPROGRAMS\${VIM_PRODUCT_NAME}"

    # Create URL shortcut to vim online:
    # TODO: Which link should be used for vim online?
    #   http://vim.sf.net/
    #   http://www.vim.org/
    WriteINIStr "$SMPROGRAMS\${VIM_PRODUCT_NAME}\Vim Online.URL" \
        "InternetShortcut" "URL" "http://www.vim.org/"

    ${LogSectionEnd}
SectionEnd

Section $(str_section_quick_launch) id_section_quicklaunch
    SectionIn 1 3

    ${LogSectionStart}

    ${If} $QUICKLAUNCH != $TEMP
        ${VimCreateShortcuts} "${VIM_LAUNCH_SHORTCUTS}" "$QUICKLAUNCH"
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
            "$vim_bin_path\gvimext64.dll" "$vim_bin_path"
        !undef LIBRARY_X64

        StrCpy $vim_shell_ext_name "$vim_bin_path\gvimext64.dll"
    ${Else}
        !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMSRC}\GvimExt\gvimext.dll" \
            "$vim_bin_path\gvimext32.dll" "$vim_bin_path"

        StrCpy $vim_shell_ext_name "$vim_bin_path\gvimext32.dll"
    ${EndIf}

    !undef LIBRARY_SHELL_EXTENSION

    # Register the shell extension:
    ${If} $vim_shell_ext_name != ""
        Push $vim_shell_ext_name
        Call VimRegShellExt
    ${EndIf}

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

    # Create vimfiles directory hierarchy under $HOME or install root:
    Push "HOME"
    Call VimCreatePluginDir

    ${LogSectionEnd}
SectionEnd

Section $(str_section_plugin_vim) id_section_pluginvim
    SectionIn 3

    ${LogSectionStart}

    # Create vimfiles directory hierarchy under $VIM or install root:
    Push "VIM"
    Call VimCreatePluginDir

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

Section -registry_update
    # Register uninstall information:
    ${LoopMatrix} "${VIM_UNINSTALL_REG_INFO}" \
        "VimRegUninstallInfoCallback" "" ""

    # Register Vim with OLE:
    # TODO: Translate
    DetailPrint "Attempting to register Vim with OLE$\r$\n\
                 There is no message whether this works or not."
    ${Logged1} ExecWait '"$vim_bin_path\gvim.exe" -silent -register'
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

    # TODO: Remove language preference.
    #!ifdef HAVE_MULTI_LANG
    #!endif

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

    ${If} ${FileExists} "$INSTDIR\gvimext64.dll"
        !define LIBRARY_X64
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$INSTDIR\gvimext64.dll"
        !undef LIBRARY_X64
    ${EndIf}

    ${If} ${FileExists} "$INSTDIR\gvimext32.dll"
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$INSTDIR\gvimext32.dll"
    ${EndIf}

    !undef LIBRARY_SHELL_EXTENSION

    # Delete quick launch:
    ${VimRmShortcuts} "${VIM_LAUNCH_SHORTCUTS}" "$QUICKLAUNCH"

    # Delete URL shortcut to vim online:
    ${Logged1} Delete "$SMPROGRAMS\${VIM_PRODUCT_NAME}\Vim Online.URL"

    # Delete startmenu shortcuts:
    ${VimRmShortcuts} \
        "${VIM_CONSOLE_STARTMENU}$\n\
         ${VIM_GUI_STARTMENU}$\n\
         ${VIM_MISC_STARTMENU}" \
        "$SMPROGRAMS\${VIM_PRODUCT_NAME}"

    # Delete startmenu folder (now should be empty):
    ${Logged1} RMDir "$SMPROGRAMS\${VIM_PRODUCT_NAME}"
    ${If} ${Errors}
        ${Log} "WARNING: Fail to remove startmenu folder \
                [$SMPROGRAMS\${VIM_PRODUCT_NAME}], \
                directory not empty!"
    ${EndIf}

    # Delete desktop icons, if any:
    ${VimRmShortcuts} "${VIM_DESKTOP_SHORTCUTS}" "$DESKTOP"

    # Delete batch files:
    ${VimRmBatches} "${VIM_CONSOLE_BATCH}$\n${VIM_GUI_BATCH}"

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

    # Remove empty plugin directory hierarchy under $HOME:
    Push "HOME"
    Call un.VimRmPluginDir

    # Remove empty plugin directory hierarchy under $VIM:
    Push "VIM"
    Call un.VimRmPluginDir

    ${LogSectionEnd}
SectionEnd

Section /o "un.$(str_unsection_root)" id_unsection_root
    ${LogSectionStart}

    # Remove all possible config file(s):
    ${Logged1} Delete $vim_install_root\_vimrc
    ${Logged1} Delete $vim_install_root\.vimrc
    ${Logged1} Delete $vim_install_root\vimrc~1

    # Remove install root if it is empty:
    ${Logged1} RMDir $vim_install_root
    ${If} ${Errors}
        ${Log} "WARNING: Cannot remove $vim_install_root, it is not empty!"
    ${EndIf}

    ${LogSectionEnd}
SectionEnd

Section -un.post
    # Remove uninstall information:
    ${LoopMatrix} "${VIM_UNINSTALL_REG_INFO}" \
        "un.VimRmUninstallInfoCallback" "" ""

    ${Logged3} DeleteRegKey /ifempty SHCTX \
        "${REG_KEY_UNINSTALL}\${VIM_PRODUCT_NAME}"

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
# Declaration of external functions                                       {{{2
# ----------------------------------------------------------------------------
${UnStrLoc}              # ${UnStrLoc}
${DECLARE_UnLoopMatrix}  # ${LoopMatrix}

# ----------------------------------------------------------------------------
# Function un.onInit                                                      {{{2
# ----------------------------------------------------------------------------
Function un.onInit
    Push $R0

    # Initialize all globals:
    StrCpy $vim_install_root    ""
    StrCpy $vim_bin_path        ""
    StrCpy $vim_old_ver_keys    ""
    StrCpy $vim_old_ver_count   0
    StrCpy $vim_has_console     0
    StrCpy $vim_batch_exe       ""
    StrCpy $vim_batch_arg       ""
    StrCpy $vim_batch_ver_found 0

    # Initialize log:
    !ifdef VIM_LOG_FILE
        ${LogInit} "$TEMP\${VIM_LOG_FILE}" "Vim uninstaller log"
    !endif

    # Use shell folders for "all" user:
    ${Logged1} SetShellVarContext all

    # 64-bit view should be used on Windows x64:
    ${If} ${RunningX64}
        ${Logged1} SetRegView 64
    ${EndIf}

    # Get root path of the installation:
    ${GetParent} $INSTDIR $vim_install_root

    # Check to make sure this is a valid directory:
    ${VimVerifyRootDir} $vim_install_root $R0
    ${If} $R0 = 0
        ${ShowErr} $(str_msg_invalid_root)
        Pop $R0
        Abort
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
    Push $R0
    Push $R1

    # Get selection status of the exe removal section:
    SectionGetFlags ${id_unsection_exe} $R0

    # Status of the plugin removal section:
    SectionGetFlags ${id_unsection_plugin} $R1
    IntOp $R0 $R0 & $R1

    # Root directory can be removed only if all sub-directories will be removed:
    IntOp $R0 $R0 & ${SF_SELECTED}
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

    Pop $R1
    Pop $R0
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

# ----------------------------------------------------------------------------
# Function un.VimRmPluginDir                                              {{{2
#   Remove plugin directories.
#
#   Parameters:
#     Environment string to check for plugin root on the top of stack.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
Function un.VimRmPluginDir
    Exch $R0  # The name of the environment string for plugin root.
    Push $R1
    Push $R2
    Push $R3
    Push $R4

    # Determine plugin root directory.
    # $R0 - Plugin root directory
    ${VimGetPluginRoot} $R0 $R0

    # Make sure that all plugin subdirectories are empty:
    # $R1 - Loop index, 1 based
    # $R2 - Number of subdirectories
    # $R3 - Current subdirectory
    # $R4 - Directory empty flag 1=not empty, 0/-1=empty/not exist
    StrCpy $R4 0
    ${CountFields} "${VIM_PLUGIN_SUBDIR}" "$\n" $R2
    ${For} $R1 1 $R2
        ${WordFindS} "${VIM_PLUGIN_SUBDIR}" "$\n" "+$R1" $R3
        ${DirState} "$R0\$R3" $R4
        ${IfThen} $R4 > 0 ${|} ${ExitFor} ${|}
    ${Next}

    ${If} $R4 <= 0
        # All plugin subdirectories are empty, now we're safe to remove them:
        ${For} $R1 1 $R2
            ${WordFindS} "${VIM_PLUGIN_SUBDIR}" "$\n" "+$R1" $R3
            ${Logged1} RMDir "$R0\$R3"
        ${Next}

        # Remove vimfiles directory if it is empty:
        ClearErrors
        ${Logged1} RMDir "$R0"
        ${If} ${Errors}
            ${Log} "WARNING: Cannot remove $R0, it is not empty!"
        ${EndIf}
    ${Else}
        ${Log} "WARNING: Cannot remove $R0, $R3 is not empty!"
    ${EndIf}

    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un.VimRmFileSpecFunc                                           {{{2
#   Remove multiple files according to file specification.
#
#   The file specification contains multiple lines (delimited by \n), each
#   line is the specification for one file.  Fields in the specification is
#   delimited by vertical bar (|).  This is used to remove shortcuts/batch
#   files according to their specification.
#
#   Parameters:
#     The following parameters should be pushed onto stack in order.
#     - File specification.
#     - File root.
#     - Field index of the file title in the file specification (1 based).
#     - File name extension (includes dot).
#     - Address for verification callback function.  Full path name of the
#       file to be removed will be put on the top of stack when call the
#       callback function, return code from the callback should be put on the
#       top of the stack.  File won't be removed unless the callback function
#       returns 1.  If no callback function provided, the file will be removed
#       without verification.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
Function un.VimRmFileSpecFunc
    # Incoming parameters has been put on the stack:
    Exch      $R4    # Address of the verification callback
    ${ExchAt} 1 $R3  # File name extension (includes dot).
    ${ExchAt} 2 $R2  # Field index of the file title
    ${ExchAt} 3 $R1  # File root
    ${ExchAt} 4 $R0  # File specification
    Push $R5         # Loop index, 1 based
    Push $R6         # Number of files
    Push $R7         # Specification for the current file
    Push $R8         # Title of the file to be removed
    Push $R9         # Return code from verfication callback

    # Remove all shortcuts one by one:
    ${CountFields} "$R0" "$\n" $R6
    ${For} $R5 1 $R6
        # Specification for the current shortcut (No. $R5):
        ${WordFindS} "$R0" "$\n" "+$R5" $R7

        # Name of the shortcut:
        ${WordFindS} $R7 "|" "+$R2" $R8

        # Trim white space from both ends:
        ${TrimString} $R8 $R8

        # Construct full file name:
        StrCpy $R8 "$R1\$R8$R3"

        # Call verification callback if provided:
        ${If} $R4 == ""
            StrCpy $R9 1
        ${Else}
            Push $R8  # Call with full name of the file to be removed.
            Call $R4  # Call verification callback.
            Pop  $R9  # Return code. 0 - Skip, 1 - OK to remove.
        ${EndIf}

        # Remove the file if the verification function indicates it's OK:
        ${If} $R9 = 1
            ${Logged1} Delete "$R8"
        ${EndIf}
    ${Next}

    # Restore the stack:
    Pop $R9
    Pop $R8
    Pop $R7
    Pop $R6
    Pop $R5
    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un._VimVerifyBatch                                             {{{2
#   Verification callback for batch file removal.
#
#   This function will be called when removing batch files.  It will verify
#   the batch to be removed is created for the version to be removed.
#
#   Parameters:
#     - Full path name of the file to be removed on the top of the stack.
#   Returns:
#     Return code on the top of the stack.
#     0 - Don't remove the file.
#     1 - It's OK to remove the file.
# ----------------------------------------------------------------------------
Function un._VimVerifyBatch
    Exch $R0  # Full path name of the file to be removed.

    ${If} ${FileExists} "$R0"
        # Search version string in the batch file:
        StrCpy $vim_batch_ver_found 0
        ${LineFind} "$R0" "/NUL" "1:-1" "un._VimVerifyBatchCallback"

        ${If} $vim_batch_ver_found <> 1
            ${Log} "WARNING: [$R0] cannot be removed since it is installed \
                    by a different version of Vim."
        ${EndIf}

        StrCpy $R0 $vim_batch_ver_found
    ${Else}
        ${Log} "WARNING: [$R0] has already been removed."
        StrCpy $R0 0
    ${EndIf}

    # Output:
    Exch $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un._VimVerifyBatchCallback                                     {{{2
#   Callback function for LineFind when verify batch file.
#
#   This function will search the content of the batch file to locate version
#   string.  If version string found, global variable $vim_batch_ver_found
#   will be set to 1.
#
#   Parameters/Returns:
#     Refer to _VimCreateBatchCallback for detail.
# ----------------------------------------------------------------------------
Function un._VimVerifyBatchCallback
    Push $R0
    Push $R1

    # Search for version string on the current line, in reverse order.  The
    # search is case-insensitive:
    ${UnStrLoc} $R0 `$R9` "${VIM_BIN_DIR}" "<"

    # If we found the version string, test the character after
    ${If} $R0 != ""
        IntOp $R0 0 - $R0

        # Check the first character after the version string, make sure it is
        # not alphanumeric:
        StrCpy $R0 $R9 1 $R0
        ${If} $R0 != ""
            ${UnStrLoc} $R0 "${ALPHA_NUMERIC}" $R0 >
            ${If} $R0 == ""
                # We found the version string!  Set global flag:
                StrCpy $vim_batch_ver_found 1
            ${EndIf}
        ${EndIf}

        # Stop searching the file:
        StrCpy $R0 "StopLineFind"
    ${EndIf}

    Pop  $R1
    Exch $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un.VimRmUninstallInfoCallback                                  {{{2
#   Callback function for LoopMatrix.  It's used to remove uninstall
#   information from windows registry.
# ----------------------------------------------------------------------------
Function un.VimRmUninstallInfoCallback
    Exch      $R4     # Arg 2: Ignored.
    ${ExchAt} 1 $R3   # Arg 1: Ignored.
    ${ExchAt} 2 $R2   # Col 3: Registry value, ignored.
    ${ExchAt} 3 $R1   # Col 2: Registry subkey.
    ${ExchAt} 4 $R0   # Col 1: Registry type STR|DW, ignored.

    ${Logged3} DeleteRegValue SHCTX \
        "${REG_KEY_UNINSTALL}\${VIM_PRODUCT_NAME}" "$R1"

    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
FunctionEnd
