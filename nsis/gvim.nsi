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

# URL for vim online:
!define VIM_ONLINE_URL "http://www.vim.org"

# Comment the next line if you don't have UPX.
# Get it at http://upx.sourceforge.net
!define HAVE_UPX

# Comment the next line if you do not want to add Native Language Support
!define HAVE_NLS

# Uncomment the following line if you have newer version of gettext that uses
# iconv.dll for encoding conversion.  Please note you should rename "intl.dll"
# from "gettext-win32" archive to "libintl.dll".
#!define HAVE_ICONV

# Comment the next line if you do not want to include VisVim extension:
!define HAVE_VIS_VIM

# Uncomment the following line if you have built support for XPM and need to
# include XPM DLL in the installer.  XPM is ibrary for X PixMap images, it can
# be downloaded from:
#   http://gnuwin32.sourceforge.net/packages/xpm.htm
#!define HAVE_XPM

# Uncomment the following line to create a multilanguage installer:
#!define HAVE_MULTI_LANG

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
Var vim_cmd_params        # Command line parameters
Var vim_silent_auto_dir   # Silent mode flag: Install dir auto-detection
Var vim_silent_rm_old     # Silent mode flag: Allow uninstall
Var vim_silent_rm_exe     # Silent mode flag: Uninstall executable
Var vim_silent_rm_rc      # Silent mode flag: Uninstall config file
Var vim_install_root      # Vim install root directory
Var vim_bin_path          # Vim binary directory
Var vim_old_ver_keys      # List of registry keys for old versions
Var vim_old_ver_count     # Count of old versions
Var vim_loud_ver_count    # Count of old versions without silent mode
Var vim_has_console       # Flag: Console programs should be installed
Var vim_batch_exe         # Working variable: target of batch wrapper
Var vim_batch_arg         # Working variable: parameter for target
Var vim_batch_ver_found   # Working variable: version found in batch file
Var vim_last_copy         # Flag: Is this the last Vim on the system?
Var vim_rm_common         # Flag: Should we remove common files?

# List of alphanumeric:
!define ALPHA_NUMERIC     "abcdefghijklmnopqrstuvwxyz0123456789"

# Version strings:
!define VER_SHORT         "${VER_MAJOR}.${VER_MINOR}"
!define VER_SHORT_NDOT    "${VER_MAJOR}${VER_MINOR}"
!define VIM_PRODUCT_NAME  "Vim ${VER_SHORT}"
!define VIM_BIN_DIR       "vim${VER_SHORT_NDOT}"
!define VIM_LNK_NAME      "gVim ${VER_SHORT}"

# Registry keys:
!define REG_KEY_WINDOWS   "software\Microsoft\Windows\CurrentVersion"
!define REG_KEY_UNINSTALL "${REG_KEY_WINDOWS}\Uninstall"
!define REG_KEY_SILENT    "AllowSilent"
!define REG_KEY_SH_EXT    "${REG_KEY_WINDOWS}\Shell Extensions\Approved"
!define REG_KEY_VIM       "Software\Vim"
!define VIM_SH_EXT_NAME   "Vim Shell Extension"
!define VIM_SH_EXT_CLSID  "{51EEE242-AD87-11d3-9C1E-0090278BBD99}"

# Specification for shortcuts on desktop.  Shortcuts are delimited with
# newline (\n), fields in each shortcut are delimited with "|".  Please note
# fields can NOT be empty, you have to add some whitespaces there even if it's
# empty, otherwise the field cannot be handled correctly.  It's the limitation
# of the macro used to parse such specification.
#    Title                           | Target   | Arg | Work-dir
!define VIM_DESKTOP_SHORTCUTS \
    "gVim ${VER_SHORT}.lnk           | gvim.exe |     | $\n\
     gVim Easy ${VER_SHORT}.lnk      | gvim.exe | -y  | $\n\
     gVim Read only ${VER_SHORT}.lnk | gvim.exe | -R  | "

# Specification for quick launch shortcuts:
!define VIM_LAUNCH_SHORTCUTS \
    "gVim ${VER_SHORT}.lnk | gvim.exe | | "

# Specification for console version startmenu shortcuts:
!define VIM_CONSOLE_STARTMENU \
    "Vim.lnk           | vim.exe |    | $\n\
     Vim Read-only.lnk | vim.exe | -R | $\n\
     Vim Diff.lnk      | vim.exe | -d | "

# Specification for GUI version startmenu shortcuts:
!define VIM_GUI_STARTMENU \
    "gVim.lnk           | gvim.exe |    | $\n\
     gVim Easy.lnk      | gvim.exe | -y | $\n\
     gVim Read-only.lnk | gvim.exe | -R | $\n\
     gVim Diff.lnk      | gvim.exe | -d | "

# Specification for miscellaneous startmenu shortcuts:
!define VIM_MISC_STARTMENU \
    "Uninstall.lnk | uninstall-gui.exe |      | $vim_bin_path$\n\
     Vim tutor.lnk | vimtutor.bat      |      | $vim_bin_path$\n\
     Help.lnk      | gvim.exe          | -c h | "

# Specification for batch wrapper of console version:
#    Title    | Target       | Arg
!define VIM_CONSOLE_BATCH \
    "vim.bat      | vim.exe      |   $\n\
     view.bat     | vim.exe      | -R$\n\
     vimdiff.bat  | vim.exe      | -d$\n\
     vimtutor.bat | vimtutor.bat |   "

# Specification for batch wrapper of GUI version:
!define VIM_GUI_BATCH \
    "gvim.bat     | gvim.exe     |   $\n\
     evim.bat     | gvim.exe     | -y$\n\
     gview.bat    | gvim.exe     | -R$\n\
     gvimdiff.bat | gvim.exe     | -d"

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
    "STR | DisplayName       | ${VIM_PRODUCT_NAME} (self-installing) $\n\
     STR | UninstallString   | $vim_bin_path\uninstall-gui.exe       $\n\
     STR | InstallLocation   | $vim_bin_path                         $\n\
     STR | DisplayIcon       | $vim_bin_path\gvim.exe,0              $\n\
     STR | HelpLink          | ${VIM_ONLINE_URL}/                    $\n\
     STR | URLUpdateInfo     | ${VIM_ONLINE_URL}/download.php#pc     $\n\
     STR | DisplayVersion    | ${VER_SHORT}                          $\n\
     DW  | NoModify          | 1 $\n\
     DW  | NoRepair          | 1 $\n\
     DW  | ${REG_KEY_SILENT} | 1 "

# List of install types:
!define VIM_INSTALL_TYPES \
    "TYPICAL | 0 $\n\
     MIN     | 1 $\n\
     FULL    | 2"

# List of file extensions to be registered:
!define VIM_FILE_EXT_LIST ".htm $\n .html $\n .vim $\n *"

Name                      "${VIM_PRODUCT_NAME}"
OutFile                   gvim${VER_SHORT_NDOT}.exe
CRCCheck                  force
SetCompressor             lzma
SetDatablockOptimize      on
BrandingText              "${VIM_PRODUCT_NAME}"
RequestExecutionLevel     highest
InstallDir                ""

# Types of installs we can perform.  Please also update install type list if
# you have updated this:
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

!define MUI_WELCOMEFINISHPAGE_BITMAP       "icons\welcome.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP     "icons\uninstall.bmp"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP             "icons\header.bmp"
!define MUI_HEADERIMAGE_UNBITMAP           "icons\un_header.bmp"

!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION $(str_dest_folder)
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_FINISHPAGE_RUN                 "$vim_bin_path\gvim.exe"
!define MUI_FINISHPAGE_RUN_TEXT            $(str_show_readme)
!define MUI_FINISHPAGE_RUN_PARAMETERS      "-R $\"$vim_bin_path\README.txt$\""

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
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!insertmacro MUI_PAGE_FINISH

# Uninstaller pages:
!insertmacro MUI_UNPAGE_CONFIRM
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE un.VimCheckRunning
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
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
    !include "lang\german.nsi"
    !include "lang\simpchinese.nsi"
    !include "lang\tradchinese.nsi"
!endif

##############################################################################
# Macros                                                                  {{{1
##############################################################################

# ----------------------------------------------------------------------------
# macro VimFetchCmdParam[S] $_SW_STR $_FOUND $_VALUE                      {{{2
#   Get command line parameter and remove it if found.
#
#   VimFetchCmdParam is the case-insensitive, VimFetchCmdParamS is the
#   case-sensitive version.
#
#   The command line parameter found is removed so that we can detect
#   erroneous command line options.
#
#   Globals:
#       $vim_cmd_params : Global command line parameter.  It will be modified
#                         directly when removing command line option.
#   Parameters:
#       $_SW_STR        : Command line switch for the parameter.
#   Returns:
#       $_FOUND         : 1 if the specified parameter found; 0 if not.
#       $_VALUE         : Value of the parameter if found.
# ----------------------------------------------------------------------------
!define VimFetchCmdParam  "!insertmacro _VimFetchCmdParam 0"
!define VimFetchCmdParamS "!insertmacro _VimFetchCmdParam 1"
!macro _VimFetchCmdParam _CASE_SENSITIVE _SW_STR _FOUND _VALUE
    push $R0  # Found flag
    push $R1  # Parameter value

    !if ${_CASE_SENSITIVE}
        # Handle case-sensitive command line switch:
        ${GetOptionsS} $vim_cmd_params "${_SW_STR}" $R1
    !else
        # Handle case-insensitive command line switch:
        ${GetOptions}  $vim_cmd_params "${_SW_STR}" $R1
    !endif

    ${If} ${Errors}
        # Nothing found:
        StrCpy $R0 0
        StrCpy $R1 ""
    ${Else}
        # Found the required command line switch:
        StrCpy $R0 1

        # Remove the command line switch found.  Please note the parameter
        # name and value could be specified as one or two DOS command line
        # switches, we should handle both cases:
        !if ${_CASE_SENSITIVE}
            # Case-sensitive command line switch:
            ${WordReplaceS} $vim_cmd_params "${_SW_STR}$R1" \
                "/@@" "+" $vim_cmd_params
            ${WordReplaceS} $vim_cmd_params "${_SW_STR} $R1" \
                "/@@" "+" $vim_cmd_params
        !else
            # Case-insensitive command line switch:
            ${WordReplace} $vim_cmd_params "${_SW_STR}$R1" \
                "/@@" "+" $vim_cmd_params
            ${WordReplace} $vim_cmd_params "${_SW_STR} $R1" \
                "/@@" "+" $vim_cmd_params
        !endif
    ${EndIf}

    Exch        $R1
    ${ExchAt} 1 $R0
    Pop ${_VALUE}
    Pop ${_FOUND}
!macroend

# ----------------------------------------------------------------------------
# macro _VimCmdLineParse _SW_STR _PARAM_NAME _SEC_ID_OR_FLAG              {{{2
#   Parse command line option for section selection or option enable/disable.
#
#   This macro can be used to parse the following type of command line switch:
#     /<OPTION>[{+|-}]
#   where + (set) is the default.  Such type of command line switch can be
#   used for section selection or flag setting:
#   - /<OPTION>+ or /<OPTION> to select a section or set a control flag to 1.
#   - /<OPTION>- to unselect a section or set a control flag to 0.
#
#   Two categories of wrappers have been created for this macro:
#   - VimCmdLineSelSec* are used for section manipulation.
#   - VimCmdLineGetOpt* are used for setting control flag.
#
#   Each category has two different types of wrapper, which differs only in
#   error handling:
#   - *W only shows a warning message if syntax error found;
#   - *E will report error and abort if syntax error found.
#
#   If the specified command line switch has not been found, no section will
#   be touched, and the value of the control flag won't be changed.
#
#   Globals:
#       $vim_cmd_params  : Global command line parameter.  It will be modified
#                          directly when removing the command line switch
#                          found.
#   Parameters:
#       $_ABORT_ON_ERR   : 1 to abort on syntax error.
#       $_IS_SECTION     : 1 if the command line switch should be used to
#                          control section selection; 0 if it should be used
#                          to set a control flag to 0/1.
#       $_SW_STR         : Command line switch for the parameter.
#       $_PARAM_NAME     : Name of the section to manipulate or the option to
#                          enable/disable.
#       $_SEC_ID_OR_FLAG : ID of the section to manipulate (select/unselect),
#                          or output variable to hold the control flag.
#   Returns:
#       N/A
# ----------------------------------------------------------------------------
!define VimCmdLineSelSecW "!insertmacro _VimCmdLineParse 0 1"
!define VimCmdLineSelSecE "!insertmacro _VimCmdLineParse 1 1"
!define VimCmdLineGetOptW "!insertmacro _VimCmdLineParse 0 0"
!define VimCmdLineGetOptE "!insertmacro _VimCmdLineParse 1 0"

!macro _VimCmdLineParse _ABORT_ON_ERR _IS_SECTION \
                        _SW_STR _PARAM_NAME _SEC_ID_OR_FLAG
    push $R0  # Parameter found flag/Control flag
    push $R1  # Parameter value

    # Get command line option:
    ${VimFetchCmdParam} ${_SW_STR} $R0 $R1
    ${If} $R0 <> 0
        ${If}   $R1 == "+"
        ${OrIf} $R1 == ""
            !if ${_IS_SECTION}
                # Select the section:
                ${Log} "Command line: Select section [${_PARAM_NAME}], \
                        ID=${_SEC_ID_OR_FLAG}"
                !insertmacro SelectSection ${_SEC_ID_OR_FLAG}
            !else
                # Set the control flag:
                ${Log} "Command line: Set flag [${_PARAM_NAME}]"
                StrCpy $R0 1
            !endif
        ${ElseIf} $R1 == "-"
            !if ${_IS_SECTION}
                # Unselect the section:
                ${Log} "Command line: Unselect section [${_PARAM_NAME}], \
                        ID=${_SEC_ID_OR_FLAG}"
                !insertmacro UnselectSection ${_SEC_ID_OR_FLAG}
            !else
                # Clear the control flag:
                ${Log} "Command line: Clear flag [${_PARAM_NAME}]"
                StrCpy $R0 0
            !endif
        ${Else}
            # Syntax error found.  Log the error first:
            !if ${_ABORT_ON_ERR}
                StrCpy $R0 "ERROR: Invalid"
            !else
                StrCpy $R0 "WARNING: Ignore invalid"
            !endif

            !if ${_IS_SECTION}
                ${Log} "$R0 selection command [$R1] for section [${_PARAM_NAME}]!"
            !else
                ${Log} "$R0 set command [$R1] for flag [${_PARAM_NAME}]!"

                # Don't change value of the control flag:
                StrCpy $R0 ${_SEC_ID_OR_FLAG}
            !endif

            # Abort if required:
            !if ${_ABORT_ON_ERR}
                Abort
            !endif
        ${EndIf}
    ${Else}
        !if ! ${_IS_SECTION}
            # The specified option has not been found, so don't change the
            # value of the control flag:
            StrCpy $R0 ${_SEC_ID_OR_FLAG}
        !endif
    ${EndIf}

    # Restore stack and output result:
    Pop $R1
    !if ${_IS_SECTION}
        Pop  $R0
    !else
        # We need to output control flag:
        Exch $R0
        Pop  ${_SEC_ID_OR_FLAG}
    !endif
!macroend

# ----------------------------------------------------------------------------
# macro VimCheckCmdLine $_SYNTAX_ERR                                      {{{2
#   Check command line for syntax error.
#
#   This macro should be called after all valid command line options has
#   already been fetched.  It will remove those command line options that will
#   be processed (but not removed) by NSIS.  If there's still anything left,
#   syntax error will be reported.
#
#   Globals:
#       $vim_cmd_params : Global command line parameter.  It will be modified
#                         directly when removing command line option.
#   Parameters:
#       N/A
#   Returns:
#       $_SYNTAX_ERR    : 0 if syntax OK; 1 if syntax error found.
# ----------------------------------------------------------------------------
!define VimCheckCmdLine "!insertmacro _VimCheckCmdLine"
!macro _VimCheckCmdLine _SYNTAX_ERR
    push $R0  # Syntax error flag (1 = error).

    # Remove those parameters that have been processed but not removed by NSIS
    # (Note: /D=<install-dir> will be processed AND removed by NSIS).  Please
    # note NSIS handle command line options are case-sensitive:
    ${VimFetchCmdParamS} "/S"    $R0 $R1
    ${VimFetchCmdParamS} "/NCRC" $R0 $R1

    # Detect command line syntax errors:
    ${WordReplace} $vim_cmd_params "/@@" " " "+"  $vim_cmd_params
    ${WordReplace} $vim_cmd_params " "   " " "+*" $vim_cmd_params
    StrCpy $R0 0
    ${If} $vim_cmd_params != " "
        ${Log} "ERROR: Fail to parse the following \
                part of the command line:$\r$\n\
                [$vim_cmd_params]"
        StrCpy $R0 1
    ${EndIf}

    Exch $R0
    Pop  ${_SYNTAX_ERR}
!macroend

# ----------------------------------------------------------------------------
# macro VimSelectRegView                                                  {{{2
#   Select registry view.  Select 32-bit view on 32-bit systems, and 64-bit
#   view on 64-bit systems.
#
#   Parameters: N/A
#   Returns:    N/A
# ----------------------------------------------------------------------------
!define VimSelectRegView "!insertmacro _VimSelectRegView"
!macro _VimSelectRegView
    ${If} ${RunningX64}
        ${Logged1} SetRegView 64
    ${Else}
        ${Logged1} SetRegView 32
    ${EndIf}
!macroend

# ----------------------------------------------------------------------------
# macro VimLoadUninstallKeys                                              {{{2
#   Load all uninstall keys from Windows registry.
#
#   All uninstall keys will be concatenate as a single string (delimited by
#   CR/LF).  This is a workaround since NSIS does not support array.
#
#   Parameters : None
#   Returns    : None
#   Globals    :
#     The following globals will be changed by this functions:
#     - $vim_old_ver_keys   : Concatenation of all uninstall keys found.
#     - $vim_old_ver_count  : Number of uninstall keys found.
#     - $vim_loud_ver_count : Count of old versions without silent mode.
# ----------------------------------------------------------------------------
!define VimLoadUninstallKeys "!insertmacro _VimLoadUninstallKeysCall"
!macro _VimLoadUninstallKeysCall
    ${CallArtificialFunction} _VimLoadUninstallKeys
!macroend
!macro _VimLoadUninstallKeys
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
        IntOp $vim_old_ver_count $vim_old_ver_count + 1
        ${If} $R1 S== "${VIM_PRODUCT_NAME}"
            StrCpy $vim_old_ver_keys "$R1$\r$\n$vim_old_ver_keys"
        ${Else}
            StrCpy $vim_old_ver_keys "$vim_old_ver_keys$R1$\r$\n"
        ${EndIf}

        ${Log} "Found Vim uninstall key No.$vim_old_ver_count: [$R1]"

        # Detect whether the old version support silent mode or not:
        ReadRegDWORD $R2 SHCTX "${REG_KEY_UNINSTALL}\$R1" "${REG_KEY_SILENT}"
        ${If}   ${Errors}
        ${OrIf} $R2 <> 1
            ${Log} "WARNING: Old version [$R1] \
                    does not support silent mode."
            IntOp $vim_loud_ver_count $vim_loud_ver_count + 1
        ${EndIf}
    ${Loop}

    ${Log} "Found $vim_old_ver_count uninstall keys:$\r$\n\
            $vim_old_ver_keys"
    ${Log} "$vim_loud_ver_count of the above versions \
            do not support silent uninstallation."
    ClearErrors

    Pop $R2
    Pop $R1
    Pop $R0
!macroend

# ----------------------------------------------------------------------------
# macro VimVerifyRootDir $_INPUT_DIR $_VALID                              {{{2
#   Verify VIM install path $_INPUT_DIR.
#
#   Parameters:
#     $_INPUT_DIR : The directory to be verified.
#   Returns:
#     $_VALID     : 1 if the input path is a valid VIM install path (ends with
#                   "vim"); 0 otherwise.
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
    Pop  ${_VALID}
!macroend

# ----------------------------------------------------------------------------
# macro VimExtractConsoleExe                                              {{{2
#   Extract different version of vim console executable based on detected
#   Windows version.  The output path is whatever has already been set before
#   this macro.
#
#   Parameters: N/A
#   Returns:    N/A
# ----------------------------------------------------------------------------
!define VimExtractConsoleExe "!insertmacro _VimExtractConsoleExe"
!macro _VimExtractConsoleExe
    ReadRegStr $R0 HKLM \
        "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
    ${If} ${Errors}
        # Windows 95/98/ME
        ${Logged2} File /oname=vim.exe "${VIMSRC}\vimd32.exe"
    ${Else}
        # Windows NT/2000/XT
        ${Logged2} File /oname=vim.exe "${VIMSRC}\vimw32.exe"
    ${EndIf}
!macroend

# ----------------------------------------------------------------------------
# macro VimIsRuning $_VIM_CONSOLE_PATH $_IS_RUNNING                       {{{2
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
    Exch $R0 # Parameter: $_VIM_CONSOLE_PATH
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
# macro VimOldVerSection                                                  {{{2
#   Insert a section to uninstall old version of Vim.
#
#   This is used to create dynamic sections to uninstall existing version(s)
#   of Vim on the system.
#
#   Parameters:
#     $_INDEX : Index of the old version section (zero based).
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimOldVerSection "!insertmacro _VimOldVerSection"
!macro _VimOldVerSection _INDEX
    Section "Uninstall existing version ${_INDEX}" `id_section_old_ver_${_INDEX}`
        SectionIn 1 2 3

        ${Log} "$\r$\nEnter old ver section ${_INDEX}"
        Push ${_INDEX}
        Call VimRmOldVer
        ${Log} "Leave old ver section ${_INDEX}"
    SectionEnd
!macroend

# ----------------------------------------------------------------------------
# macro VimGetOldVerSecID $_INDEX $_ID                                    {{{2
#   Get ID of the specified old version section.
#
#   Parameters:
#     $_INDEX : Index of the old version section (zero based).
#   Returns:
#     $_ID    : ID of the corresponding old version section.
# ----------------------------------------------------------------------------
!define VimGetOldVerSecID "!insertmacro _VimGetOldVerSecID"
!macro _VimGetOldVerSecID _INDEX _ID
    ${If} ${_INDEX} <= ${VIM_MAX_OLD_VER}
        IntOp ${_ID} ${_INDEX} + ${id_section_old_ver_0}
    ${Else}
        StrCpy ${_ID} -1
    ${EndIf}
!macroend

# ----------------------------------------------------------------------------
# macro VimGetOldVerKey $_INDEX $_KEY                                     {{{2
#   Get the uninstall registry key for the specified old version.  This is a
#   wrapper for function _VimGetOldVerKeyFunc.
#
#   Parameters:
#     $_INDEX : Index of the key to be retrieved (zero based).
#   Returns:
#     $_ID    : The corresponding uninstall registry key.
# ----------------------------------------------------------------------------
!define VimGetOldVerKey "!insertmacro _VimGetOldVerKey"
!macro _VimGetOldVerKey _INDEX _KEY
    Push ${_INDEX}
    Call _VimGetOldVerKeyFunc
    Pop  ${_KEY}
!macroend

# ----------------------------------------------------------------------------
# macro VimGetPluginRoot $_ENV_STR $_PLUGIN_ROOT                          {{{2
#   Get root directory for plugins (vimfiles directory).
#
#   Parameters:
#     $_ENV_STR     : The name of the environment string to check for VIM root
#                     directory.
#   Returns:
#     $_PLUGIN_ROOT : The output plugin root directory.
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
# macro VimCreateShortcuts $_SHORTCUT_SPEC $_SHORTCUT_ROOT                {{{2
#   Create specified shortcuts.
#
#   Parameters:
#     $_SHORTCUT_SPEC : Shortcut specification.
#     $_SHORTCUT_ROOT : Shortcut root.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimCreateShortcuts "!insertmacro _VimCreateShortcuts"
!macro _VimCreateShortcuts _SHORTCUT_SPEC _SHORTCUT_ROOT
    # Create shortcut root if necessary:
    ${IfNot} ${FileExists} "${_SHORTCUT_ROOT}\*.*"
        ${Logged1} CreateDirectory "${_SHORTCUT_ROOT}"
    ${EndIf}

    # Create all specified shortcuts, ignore return code.
    Push $R0
    ${LoopMatrix} "${_SHORTCUT_SPEC}" "_VimCreateShortcutsFunc" "" \
        "${_SHORTCUT_ROOT}" "" $R0
    Pop $R0
!macroend

# ----------------------------------------------------------------------------
# macro VimCreateBatches $_BATCH_SPEC $_BATCH_TMPL                        {{{2
#   Create specified batch files.
#
#   Parameters:
#     The following parameters should be pushed onto stack in order.
#     $_BATCH_SPEC : Batch file specification.
#     $_BATCH_TMPL : Name of the batch file template (in target environment).
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimCreateBatches "!insertmacro _VimCreateBatches"
!macro _VimCreateBatches _BATCH_SPEC _BATCH_TMPL
    # Create all specified batch files and ignore the return code:
    Push $R0
    ${LoopMatrix} "${_BATCH_SPEC}" "_VimCreateBatchFunc" "" \
        "${_BATCH_TMPL}" "" $R0
    Pop $R0
!macroend

# ----------------------------------------------------------------------------
# macro VimRmShortcuts $_SHORTCUT_SPEC $_SHORTCUT_ROOT                    {{{2
#   Macro to remove shortcuts.
#
#   Parameters:
#     $_SHORTCUT_SPEC : Shortcut specification.
#     $_SHORTCUT_ROOT : Shortcut root.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimRmShortcuts "!insertmacro _VimRmShortcuts"
!macro _VimRmShortcuts _SHORTCUT_SPEC _SHORTCUT_ROOT
    Push $R0
    ${LoopMatrix} "${_SHORTCUT_SPEC}" "un._VimRmFileCallback" \
        1 "${_SHORTCUT_ROOT}" "" $R0
    Pop $R0
!macroend

# ----------------------------------------------------------------------------
# macro VimRmBatches $_BATCH_SPEC                                         {{{2
#   Wrapper to call un.VimRmFileSpecFunc to remove batch files.
#
#   Parameters:
#     $_BATCH_SPEC : Batch file specification.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
!define VimRmBatches "!insertmacro _VimRmBatches"
!macro _VimRmBatches _BATCH_SPEC
    Push $R0
    GetFunctionAddress $R0 "un._VimVerifyBatch"
    ${LoopMatrix} "${_BATCH_SPEC}" "un._VimRmFileCallback" \
        1 "$WINDIR" "$R0" $R0
    Pop  $R0
!macroend


##############################################################################
# Installer Sections                                                      {{{1
##############################################################################

# ----------------------------------------------------------------------------
# Section: Log status                                                     {{{2
# ----------------------------------------------------------------------------
Section -log_status
    Push $R0

    # Log install path etc.:
    ${Log} "Final install path : $vim_install_root"
    ${Log} "Final binary  path : $vim_bin_path"
    ${Log} "Language ID        : $LANGUAGE"

    GetCurInstType $R0
    ${Log} "Install Type       : $R0"

    # Detect install mode:
    StrCpy $R0 "Normal"
    ${IfThen} ${Silent} ${|} StrCpy $R0 "Silent" ${|}
    ${Log} "Install Mode       : $R0"

    ${Log} "Silent install dir : $vim_silent_auto_dir"
    ${Log} "Silent uninstall   : $vim_silent_rm_old"
    ${Log} "Uninstall exe.     : $vim_silent_rm_exe"
    ${Log} "Uninstall rc file  : $vim_silent_rm_rc"

    # Log status for all sections:
    ${LogSectionStatus} 100

    Pop $R0
SectionEnd

# ----------------------------------------------------------------------------
# Dynamic sections to support removal of old versions                     {{{2
# ----------------------------------------------------------------------------
SectionGroup $(str_group_old_ver) id_group_old_ver
    ${VimOldVerSection} 0
    ${VimOldVerSection} 1
    ${VimOldVerSection} 2
    ${VimOldVerSection} 3
    ${VimOldVerSection} 4
SectionGroupEnd

# ----------------------------------------------------------------------------
# Section: Install GUI executables & runtime files                        {{{2
# ----------------------------------------------------------------------------
Section $(str_section_exe) id_section_exe
    SectionIn 1 2 3 RO

    # ??? TODO: Debug:
    ${IfThen} ${Silent} ${|} Abort ${|}

    ${LogSectionStart}

    ${Logged1} SetOutPath "$vim_bin_path"
    ${Logged2} File /oname=gvim.exe "${VIMSRC}\gvim_ole.exe"
    ${Logged2} File /oname=xxd.exe  "${VIMSRC}\xxdw32.exe"
    ${Logged1} File "${VIMSRC}\vimrun.exe"
    ${Logged1} File "${VIMTOOLS}\diff.exe"
    ${Logged1} File "${VIMRT}\vimtutor.bat"
    ${Logged1} File "${VIMRT}\README.txt"
    ${Logged1} File "${VIMRT}\uninstal.txt"
    ${Logged1} File "${VIMRT}\*.vim"
    ${Logged1} File "${VIMRT}\rgb.txt"

    # Install XPM DLL:
    !ifdef HAVE_XPM
        ${Log} "Install $vim_bin_path\xpm4.dll"
        !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMRT}\xpm4.dll" "$vim_bin_path\xpm4.dll" "$vim_bin_path"
    !endif

    ${Logged1} SetOutPath "$vim_bin_path\colors"
    ${Logged1} File "${VIMRT}\colors\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\compiler"
    ${Logged1} File "${VIMRT}\compiler\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\doc"
    ${Logged1} File "${VIMRT}\doc\*.txt"
    ${Logged1} File "${VIMRT}\doc\tags"

    ${Logged1} SetOutPath "$vim_bin_path\ftplugin"
    ${Logged1} File "${VIMRT}\ftplugin\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\indent"
    ${Logged1} File "${VIMRT}\indent\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\macros"
    ${Logged1} File "${VIMRT}\macros\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\plugin"
    ${Logged1} File "${VIMRT}\plugin\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\autoload"
    ${Logged1} File "${VIMRT}\autoload\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\autoload\xml"
    ${Logged1} File "${VIMRT}\autoload\xml\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\syntax"
    ${Logged1} File "${VIMRT}\syntax\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\spell"
    ${Logged1} File "${VIMRT}\spell\*.txt"
    ${Logged1} File "${VIMRT}\spell\*.vim"
    ${Logged1} File "${VIMRT}\spell\*.spl"
    ${Logged1} File "${VIMRT}\spell\*.sug"

    ${Logged1} SetOutPath "$vim_bin_path\tools"
    ${Logged1} File "${VIMRT}\tools\*.*"

    ${Logged1} SetOutPath "$vim_bin_path\tutor"
    ${Logged1} File "${VIMRT}\tutor\*.*"

    ${LogSectionEnd}
SectionEnd

# ----------------------------------------------------------------------------
# Section: Install console executables                                    {{{2
# ----------------------------------------------------------------------------
Section $(str_section_console) id_section_console
    SectionIn 1 3

    ${LogSectionStart}

    ${Logged1} SetOutPath "$vim_bin_path"
    ${VimExtractConsoleExe}

    # Flags that console version has been installed:
    StrCpy $vim_has_console 1

    ${LogSectionEnd}
SectionEnd

# ----------------------------------------------------------------------------
# Section: Install batch files                                            {{{2
# ----------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------
# Group: Install icons (desktop/start menu/quick launch)                  {{{2
# ----------------------------------------------------------------------------
SectionGroup $(str_group_icons) id_group_icons
    # Desktop:
    Section $(str_section_desktop) id_section_desktop
        SectionIn 1 3

        ${LogSectionStart}
        ${VimCreateShortcuts} "${VIM_DESKTOP_SHORTCUTS}" "$DESKTOP"
        ${LogSectionEnd}
    SectionEnd

    # Start menu:
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
        WriteINIStr "$SMPROGRAMS\${VIM_PRODUCT_NAME}\Vim Online.URL" \
            "InternetShortcut" "URL" "${VIM_ONLINE_URL}/"

        ${LogSectionEnd}
    SectionEnd

    # Quick launch bar:
    Section $(str_section_quick_launch) id_section_quicklaunch
        SectionIn 1 3

        ${LogSectionStart}

        ${If} $QUICKLAUNCH != $TEMP
            ${VimCreateShortcuts} "${VIM_LAUNCH_SHORTCUTS}" "$QUICKLAUNCH"
        ${EndIf}

        ${LogSectionEnd}
    SectionEnd
SectionGroupEnd

# ----------------------------------------------------------------------------
# Group: Install shell extension                                          {{{2
# ----------------------------------------------------------------------------
SectionGroup $(str_group_edit_with) id_group_editwith

    # Install/Upgrade 32-bit gvimext.dll:
    Section $(str_section_edit_with32) id_section_editwith32
        SectionIn 1 3

        ${LogSectionStart}

        ${Log} "Install $vim_bin_path\gvimext32.dll"
        ${Logged1} SetRegView 32
        !define LIBRARY_SHELL_EXTENSION
        !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMSRC}\GvimExt\gvimext.dll" \
            "$vim_bin_path\gvimext32.dll" "$vim_bin_path"
        !undef LIBRARY_SHELL_EXTENSION

        ${Logged1} SetRegView 32
        Push "$vim_bin_path\gvimext32.dll"
        Call VimRegShellExt

        # Restore registry view:
        ${VimSelectRegView}

        ${LogSectionEnd}
    SectionEnd

    # Install/Upgrade 64-bit gvimext.dll:
    Section $(str_section_edit_with64) id_section_editwith64
        SectionIn 1 3

        ${LogSectionStart}

        ${If} ${RunningX64}
            ${Log} "Install $vim_bin_path\gvimext64.dll"
            ${Logged1} SetRegView 64
            !define LIBRARY_SHELL_EXTENSION
            !define LIBRARY_X64
            !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
                "${VIMSRC}\GvimExt\gvimext64.dll" \
                "$vim_bin_path\gvimext64.dll" "$vim_bin_path"
            !undef LIBRARY_X64
            !undef LIBRARY_SHELL_EXTENSION

            ${Logged1} SetRegView 64
            Push "$vim_bin_path\gvimext64.dll"
            Call VimRegShellExt
        ${EndIf}

        # Restore registry view:
        ${VimSelectRegView}

        ${LogSectionEnd}
    SectionEnd
SectionGroupEnd

# ----------------------------------------------------------------------------
# Section: Install vimrc                                                  {{{2
# ----------------------------------------------------------------------------
Section $(str_section_vim_rc) id_section_vimrc
    SectionIn 1 3

    ${LogSectionStart}

    # Write default _vimrc only if the file does not exist.  We'll test for
    # .vimrc (and its short version) and _vimrc:
    SetOutPath "$vim_install_root"
    ${IfNot}    ${FileExists} "$vim_install_root\_vimrc"
    ${AndIfNot} ${FileExists} "$vim_install_root\.vimrc"
    ${AndIfNot} ${FileExists} "$vim_install_root\vimrc~1"
        ${Logged2} File /oname=_vimrc "data\mswin_vimrc.vim"
    ${EndIf}

    ${LogSectionEnd}
SectionEnd

# ----------------------------------------------------------------------------
# Group: Create vimfiles                                                  {{{2
# ----------------------------------------------------------------------------
SectionGroup $(str_group_plugin) id_group_plugin
    # Under $HOME:
    Section $(str_section_plugin_home) id_section_pluginhome
        SectionIn 1 3

        ${LogSectionStart}

        # Create vimfiles directory hierarchy under $HOME or install root:
        Push "HOME"
        Call VimCreatePluginDir

        ${LogSectionEnd}
    SectionEnd

    # Under $VIM:
    Section $(str_section_plugin_vim) id_section_pluginvim
        SectionIn 3

        ${LogSectionStart}

        # Create vimfiles directory hierarchy under $VIM or install root:
        Push "VIM"
        Call VimCreatePluginDir

        ${LogSectionEnd}
    SectionEnd
SectionGroupEnd

# ----------------------------------------------------------------------------
# Section: Install VisVim                                                 {{{2
# ----------------------------------------------------------------------------
!ifdef HAVE_VIS_VIM
    Section $(str_section_vis_vim) id_section_visvim
        SectionIn 3

        ${LogSectionStart}

        # TODO: Check if this works on x64 or not.
        ${Log} "Install $vim_bin_path\VisVim.dll"
        !insertmacro InstallLib REGDLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMSRC}\VisVim\VisVim.dll" \
            "$vim_bin_path\VisVim.dll" "$vim_bin_path"

        ${Logged1} SetOutPath "$vim_bin_path"
        ${Logged1} File "${VIMSRC}\VisVim\README_VisVim.txt"

        ${LogSectionEnd}
    SectionEnd
!endif

# ----------------------------------------------------------------------------
# Section: Install NLS files                                              {{{2
# ----------------------------------------------------------------------------
!ifdef HAVE_NLS
    Section $(str_section_nls) id_section_nls
        SectionIn 1 3

        ${LogSectionStart}

        SetOutPath "$vim_bin_path\lang"
        File /r "${VIMRT}\lang\*.*"
        SetOutPath "$vim_bin_path\keymap"
        File "${VIMRT}\keymap\README.txt"
        File "${VIMRT}\keymap\*.vim"

        # Install NLS support DLLs:
        ${Log} "Install $vim_bin_path\libintl.dll"
        SetOutPath "$vim_bin_path"
        !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "${VIMRT}\libintl.dll" \
            "$vim_bin_path\libintl.dll" "$vim_bin_path"

        !ifdef HAVE_ICONV
            ${Log} "Install $vim_bin_path\iconv.dll"
            !insertmacro InstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
                "${VIMRT}\iconv.dll" \
                "$vim_bin_path\iconv.dll" "$vim_bin_path"
        !endif

        ${LogSectionEnd}
    SectionEnd
!endif

# ----------------------------------------------------------------------------
# Section: Final touch                                                    {{{2
# ----------------------------------------------------------------------------
Section -registry_update
    # Register uninstall information:
    Push $R0
    ${LoopMatrix} "${VIM_UNINSTALL_REG_INFO}" \
        "VimRegUninstallInfoCallback" "" "" "" $R0
    Pop $R0

    # Register Vim with OLE:
    ${LogPrint} "$(str_msg_register_ole)"
    ${Logged1} ExecWait '"$vim_bin_path\gvim.exe" -silent -register'
SectionEnd

Section -post
    ${IfNotThen} ${Silent} ${|} BringToFront ${|}
SectionEnd

##############################################################################
# Section Dependent Settings                                              {{{1
##############################################################################

# List of all installer sections (for command line processing):
!ifdef HAVE_VIS_VIM
    !define VIM_INSTALL_SECS_VIS_VIM \
        "$\n VISVIM | ${id_section_visvim}"
!else
    !define VIM_INSTALL_SECS_VIS_VIM ""
!endif

!ifdef HAVE_NLS
    !define VIM_INSTALL_SECS_NLS \
        "$\n NLS | ${id_section_nls}"
!else
    !define VIM_INSTALL_SECS_NLS ""
!endif

!define VIM_INSTALL_SECS \
    "CONSOLE    | ${id_section_console}     $\n\
     BATCH      | ${id_section_batch}       $\n\
     DESKTOP    | ${id_section_desktop}     $\n\
     STARTMENU  | ${id_section_startmenu}   $\n\
     QLAUNCH    | ${id_section_quicklaunch} $\n\
     SHEXT32    | ${id_section_editwith32}  $\n\
     SHEXT64    | ${id_section_editwith64}  $\n\
     VIMRC      | ${id_section_vimrc}       $\n\
     PLUGINHOME | ${id_section_pluginhome}  $\n\
     PLUGINCOM  | ${id_section_pluginvim} \
     ${VIM_INSTALL_SECS_VIS_VIM} \
     ${VIM_INSTALL_SECS_NLS}"

##############################################################################
# Installer Functions                                                     {{{1
##############################################################################

# ----------------------------------------------------------------------------
# Declaration of external functions                                       {{{2
# ----------------------------------------------------------------------------
${DECLARE_LoopArray}           # ${LoopArray}
${DECLARE_LoopMatrix}          # ${LoopMatrix}
${DECLARE_SimpleLogFunctions}  # Declare all functions for simple log

# ----------------------------------------------------------------------------
# Function .onInit                                                        {{{2
# ----------------------------------------------------------------------------
Function .onInit
    # Initialize all globals:
    StrCpy $vim_cmd_params      ""
    StrCpy $vim_silent_auto_dir 0
    StrCpy $vim_silent_rm_old   0
    StrCpy $vim_silent_rm_exe   1
    StrCpy $vim_silent_rm_rc    0
    StrCpy $vim_install_root    ""
    StrCpy $vim_bin_path        ""
    StrCpy $vim_old_ver_keys    ""
    StrCpy $vim_old_ver_count   0
    StrCpy $vim_loud_ver_count  0
    StrCpy $vim_has_console     0
    StrCpy $vim_batch_exe       ""
    StrCpy $vim_batch_arg       ""
    StrCpy $vim_batch_ver_found 0
    StrCpy $vim_last_copy       0
    StrCpy $vim_rm_common       0

    # Initialize log:
    !ifdef VIM_LOG_FILE
        ${LogInit} "$TEMP\${VIM_LOG_FILE}" "Vim installer log"
    !endif

    # Process command line parameters:
    Call VimProcessCmdParams

    # Use shell folders for "all" user:
    ${Logged1} SetShellVarContext all

    # Set correct registry view:
    ${VimSelectRegView}

    # Show language selection dialog:  User selected language will be
    # represented by Local ID (LCID) and assigned to $LANGUAGE.  If registry
    # key defined, the LCID will also be stored in Windows registry.  For list
    # of LCID, check "Locale IDs Assigned by Microsoft":
    #   http://msdn.microsoft.com/en-us/goglobal/bb964664.aspx
    !ifdef HAVE_MULTI_LANG
        !insertmacro MUI_LANGDLL_DISPLAY
    !endif

    # Read all Vim uninstall keys from registry.  Please note we only support
    # limited number of old version.
    ${VimLoadUninstallKeys}
    ${If} $vim_old_ver_count > ${VIM_MAX_OLD_VER}
        ${ShowErr} "$(str_msg_too_many_ver)"
        Abort
    ${EndIf}

    # Do not start uninstaller by default in silent mode:
    ${If}    $vim_old_ver_count > 0
    ${AndIf} ${Silent}
        # Found old version(s) in silent mode, abort unless uninstallation has
        # been enabled:
        ${If} $vim_silent_rm_old <> 1
            ${Log} "ERROR: Previous installation(s) of Vim found, but$\r$\n\
                    uninstallation has not been enabled in silent mode."
            ${Log} 'Uninstallation in silent mode could be enabled$\r$\n\
                    with "/RMOLD" command line option.'
            Abort
        ${EndIf}

        # Abort unless all of those old versions support silent
        # uninstallation:
        ${If} $vim_loud_ver_count > 0
            ${Log} "ERROR: Some of the previous installation(s) of Vim$\r$\n\
                    on the system do not support silent uninstallation!$\r$\n\
                    Please remove all of them manually and try again."
            Abort
        ${EndIf}
    ${EndIf}

    # Determine default install path:
    Call VimSetDefRootPath

    # Config sections for removal of old version:
    Call VimCfgOldVerSections

    # Config sections for shell extension:
    ${IfNot} ${RunningX64}
        ${Log} "Disable 64-bit shell extension."
        !insertmacro UnselectSection ${id_section_editwith64}
        !insertmacro SetSectionFlag  ${id_section_editwith64} ${SF_RO}
        SectionSetInstTypes ${id_section_editwith64} 0
        #SectionSetText      ${id_section_editwith64} ""
    ${EndIf}

    # Initialize user variables:
    # $vim_bin_path
    #   Holds the directory the executables are installed to.
    StrCpy $vim_install_root  "$INSTDIR"
    StrCpy $vim_bin_path      "$INSTDIR\${VIM_BIN_DIR}"

    ${Log} "Default install path: $vim_install_root"
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
# Function VimProcessCmdParams                                            {{{2
#   Processing command line parameters.
#
#   Parameters : None
#   Returns    : None
# ----------------------------------------------------------------------------
Function VimProcessCmdParams
    # Get command line parameters:
    ${GetParameters} $vim_cmd_params
    ${Log} "Command line params: [$vim_cmd_params]"

    # Bail out if no command line parameter specified:
    ${IfThen} $vim_cmd_params S== "" ${|} Return ${|}

    Push $R0   # Parameter found flag
    Push $R1   # Parameter value

    # Set install type: /TYPE={TYPICAL|MIN|FULL}
    ${VimFetchCmdParam} "/TYPE=" $R0 $R1
    ${If} $R0 <> 0
        ${LoopMatrix} "${VIM_INSTALL_TYPES}" \
            "_VimSetInstTypeFunc" "" "$R1" "" $R0
        ${If} $R0 == ""
            ${Log} "ERROR: Unknown install type [$R1]"
            Pop $R1
            Pop $R0
            Abort
        ${EndIf}
    ${EndIf}

    # Is it allowed to detect(determine) install directory automatically in
    # silent mode?  Please note this can be dangerous as you might not know
    # which directory will be used before installation.  Even if you set
    # install path explicitly on command line, NSIS might ignore it SILENTLY
    # if it's invalid.  This command line option make it a little bit safer to
    # specify install directory on the command line.
    ${VimCmdLineGetOptE} "/DD"    "AutoDir" $vim_silent_auto_dir

    # Is it allowed to call uninstaller in silent mode?
    ${VimCmdLineGetOptE} "/RMOLD" "RmOld" $vim_silent_rm_old

    # Set $vim_silent_rm_exe flag, set by default, unset with the /RMEXE-
    # command line switch.  It determines whether executables should be
    # removed or not when uninstall old versions silently (in both normal and
    # silent mode).
    ${VimCmdLineGetOptE} "/RMEXE" "RmExe" $vim_silent_rm_exe

    # Set $vim_silent_rm_rc flag, unset by default, set with the /RMRC command
    # line switch.  It determines whether executables should be removed or not
    # when uninstall old versions silently (in both normal and silent mode).
    ${VimCmdLineGetOptE} "/RMRC"  "RmRc"  $vim_silent_rm_rc

    # Set language: This does not work!
    # TODO: Need verification here!
    #${VimFetchCmdParam} "/LANG=" $R0 $R1
    #${If} $R0 <> 0
    #    ${Log} "Command line: Set language to [$R1]"
    #    StrCpy $LANGUAGE $R1
    #${EndIf}
    #ReadRegStr $vim_old_language \
    #    "${MUI_LANGDLL_REGISTRY_ROOT}" \
    #    "${MUI_LANGDLL_REGISTRY_KEY}"  \
    #    "${MUI_LANGDLL_REGISTRY_VALUENAME}"

    # Process section select options (/<SECTON>{+/-}):
    ${LoopMatrix} "${VIM_INSTALL_SECS}" "_VimSecSelectFunc" "" "" "" $R0

    # Check command line syntax errors:
    ${VimCheckCmdLine} $R0
    ${If} $R0 <> 0
        Pop $R1
        Pop $R0
        Abort
    ${EndIf}

    Pop $R1
    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function _VimSetInstTypeFunc                                            {{{2
#   Callback function for LoopMatrix to set install type (command line
#   processing).
# ----------------------------------------------------------------------------
Function _VimSetInstTypeFunc
    Exch      $3     # Arg 2: Ignored
    ${ExchAt} 1 $2   # Arg 1: User specified install type.
    ${ExchAt} 2 $1   # Col 2: Install type ID.
    ${ExchAt} 3 $0   # Col 1: Install type name.

    # Set install type if user specified the correct install type:
    ${If} $0 == $2
        ${Log} "Command line: Set install type to [$0], ID=$1"
        SetCurInstType $1
    ${Else}
        StrCpy $0 ""
    ${EndIf}

    # Restore the stack:
    Pop  $3
    Pop  $2
    Pop  $1
    Exch $0
FunctionEnd

# ----------------------------------------------------------------------------
# Function _VimSecSelectFunc                                              {{{2
#   Callback function for LoopMatrix to select sections (command line
#   processing).
# ----------------------------------------------------------------------------
Function _VimSecSelectFunc
    ${ExchAt} 2 $1   # Col 2: Current section ID
    ${ExchAt} 3 $0   # Col 1: Current section name

    # Process section select/unselect option on the command line:
    ${VimCmdLineSelSecE} "/$0" "$0" $1

    # Exit value:
    StrCpy $0 ""

    # Restore the stack:
    Pop  $1  # Ignored item callback arg 2
    Pop  $1  # Ignored item callback arg 1
    Pop  $1
    Exch $0
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

    # Initialize old version section index:
    StrCpy $R0 0

    ${If} $vim_old_ver_count > 0
        # Create sections to uninstall old versions if we found any:
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
            SectionSetText $R1 '$R2'

            IntOp $R0 $R0 + 1
        ${Loop}

        # Create a new group end section after all old version sections to
        # dynamically shrink the section group:
        ${If} $R0 < ${VIM_MAX_OLD_VER}
            ${VimGetOldVerSecID} $R0 $R1

            ${Log} "Create new old ver section group end at section $R1"
            !insertmacro UnselectSection $R1
            SectionSetFlags     $R1 ${SF_SECGRPEND}
            SectionSetInstTypes $R1 0
            SectionSetText      $R1 "-"

            # Move to the next section:
            IntOp $R0 $R0 + 1
        ${EndIf}
    ${Else}
        # No old version found, convert the original group head section to a
        # normal inactive section (to hide the group):
        ${Log} "Disable old ver section group"
        !insertmacro ClearSectionFlag ${id_group_old_ver} ${SF_SECGRP}
        !insertmacro UnselectSection  ${id_group_old_ver}
        !insertmacro SetSectionFlag   ${id_group_old_ver} ${SF_RO}
        SectionSetInstTypes ${id_group_old_ver} 0
        SectionSetText      ${id_group_old_ver} ""
    ${EndIf}

    # Disable all remaining old version sections:
    ${DoWhile} $R0 < ${VIM_MAX_OLD_VER}
        ${VimGetOldVerSecID} $R0 $R1
        ${Log} "Disable old ver section No.$R0, ID=$R1"
        !insertmacro UnselectSection $R1
        !insertmacro SetSectionFlag  $R1 ${SF_RO}
        SectionSetInstTypes $R1 0
        SectionSetText      $R1 ""

        IntOp $R0 $R0 + 1
    ${Loop}

    # Convert the original group end section to a normal inactive section if
    # we have not used all old version sections:
    ${If} $vim_old_ver_count < ${VIM_MAX_OLD_VER}
        ${Log} "Disable the original group end for the old ver section group"
        ${VimGetOldVerSecID} ${VIM_MAX_OLD_VER} $R1
        !insertmacro ClearSectionFlag $R1 ${SF_SECGRPEND}
        !insertmacro SetSectionFlag   $R1 ${SF_RO}
        SectionSetText $R1 ""
    ${EndIf}

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

    # Log initial install path for debug purpose:
    ${Log} "Initial install path: [$INSTDIR]"

    # First check the default install directory has been set or not.  The
    # default install directory has been initialized to empty.  If it's
    # non-empty now, user must have specified it explicitly on the command
    # line, we should use that setting:
    ${If} "$INSTDIR" != ""
        ${VimVerifyRootDir} $INSTDIR $R2
        ${If} $R2 = 1
            ${Log} "Set install path per command line: $INSTDIR"
        ${ElseIf} ${Silent}
            # Abort if user supplied install path is invalid and we're in
            # silent mode.  Otherwise, give user a chance to fix the problem
            # on the directory page:
            ${Log} "ERROR: Invalid install path: $INSTDIR"
            Pop $R2
            Pop $R1
            Pop $R0
            Abort
        ${EndIf}
    ${ElseIf} ${Silent}
    ${AndIf}  $vim_silent_auto_dir = 0
        # User has not specified install path in silent mode and has not allow
        # auto-detection of install path explicitly.  Instead of making some
        # stealthy change, we should simply abort:
        ${Log} "ERROR: No install path specified in silent mode!"
        ${Log} 'You should either specify the install path with the \
                "/D=<path>" command line$\r$\n\
                option directly, or allow auto-detection of install \
                path explicitly with the$\r$\n\
                "/DD" command line option.'
        Pop $R2
        Pop $R1
        Pop $R0
        Abort
    ${EndIf}

    # Then try VIMRUNTIME environment string, use its parent directory as
    # install path if valid.
    ${If} $R2 = 0
        ReadEnvStr $R0 "VIMRUNTIME"
        ${IfThen} $R0 != "" ${|} ${GetParent} $R0 $R0 ${|}
        ${If} $R0 != ""
            ${VimVerifyRootDir} $R0 $R2
            ${If} $R2 = 1
                ${Log} "Set install path per VIMRUNTIME: $R0"
                StrCpy $INSTDIR $R0
            ${EndIf}
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
    ${If}    $R2 = 0
    ${AndIf} $vim_old_ver_count > 0
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
    Exch $R0  # ID/key of the Vim version to remove.

    # Silently ignore out of bound IDs:
    ${If}   $R0 >= $vim_old_ver_count
    ${OrIf} $R0 < 0
        ${Log} "Skip non-exist old ver No. $R0"
        Pop $R0
        Return
    ${EndIf}

    Push $R1  # Full name of the uninstaller
    Push $R2  # Path of the uninstaller
    Push $R3  # Name of the uninstaller
    Push $R4  # Silent flag of the uninstaller

    # Get (cached) registry key for the specified old version:
    ${VimGetOldVerKey} $R0 $R1
    ${If} $R1 == ""
        ${ShowErr} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_no_rm_key)"
        Abort
    ${EndIf}

    StrCpy $R0 $R1
    ${LogPrint} "$(str_msg_rm_start) $R0 ..."

    # Determine whether the uninstaller support silent mode or not, run the
    # uninstaller in silent mode if it supports that.
    StrCpy $R4 ""
    ReadRegDWORD $R1 SHCTX "${REG_KEY_UNINSTALL}\$R0" "${REG_KEY_SILENT}"
    ${IfNot} ${Errors}
    ${AndIf} $R1 = 1
        # Construct command line switches for silent mode.  Should we remove
        # executables when uninstall?
        StrCpy $R4 "/S /RMEXE"
        ${IfNotThen} $vim_silent_rm_exe <> 0 ${|} StrCpy $R4 "$R4-" ${|}

        # Should we remove config files?
        StrCpy $R4 "$R4 /RMRC"
        ${IfNotThen} $vim_silent_rm_rc <> 0  ${|} StrCpy $R4 "$R4-" ${|}
    ${ElseIf} ${Silent}
        # This is not possible: We're in silent mode but the uninstaller does
        # not support silent mode!
        ${ShowErr} "Uninstaller for [$R0] does not support silent mode!"
        Abort
    ${EndIf}

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

    # Path ($R2) and name ($R3) of the uninstaller:
    ${GetParent}   $R1 $R2
    ${GetFileName} $R1 $R3

    # Copy uninstaller to the temporary path:
    ${Logged4} CopyFiles /SILENT /FILESONLY $R1 $TEMP
    ${If}      ${Errors}
    ${OrIfNot} ${FileExists} "$TEMP\$R3"
        ${ShowErr} "$(str_msg_rm_fail) $R0$\r$\n$(str_msg_rm_copy_fail)"
        Abort
    ${EndIf}

    # Execute the uninstaller in TEMP, exit code stores in $R2.  Log is closed
    # before launch and reopened after that, so that uninstaller can write to
    # the same log file.
    ${Logged2Reopen} ExecWait '"$TEMP\$R3" $R4 _?=$R2' $R2
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
    ${IfNotThen} ${Silent} ${|} BringToFront ${|}

    Pop $R4
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
    ${VimVerifyRootDir} "$vim_install_root" $R0
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

    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function _VimGetOldVerKeyFunc                                           {{{2
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
Function _VimGetOldVerKeyFunc
    Exch $0  # Index of the un-install key

    ${If} $0 >= $vim_old_ver_count
        StrCpy $0 ""
    ${Else}
        # WordFindS uses 1 based index:
        IntOp $0 $0 + 1
        ${WordFindS} $vim_old_ver_keys "$\r$\n" "+$0" $0
    ${EndIf}

    Exch $0
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
    Exch $0  # Name of the environment string for plugin root.

    # Determine plugin root directory.
    # $0 - Plugin root directory
    ${VimGetPluginRoot} $0 $0

    # Create plugin root directory (vimfiles):
    ${Logged1} CreateDirectory "$0"

    # Create all subdirectories:
    ${LoopArray} "${VIM_PLUGIN_SUBDIR}" "_VimCreatePluginDirCallback" \
        "$0" "" $0

    Pop $0
FunctionEnd

# ----------------------------------------------------------------------------
# Function _VimCreatePluginDirCallback                                    {{{2
#   Callback function for LoopArray.  It's used to create one plugin
#   subdirectory.
# ----------------------------------------------------------------------------
Function _VimCreatePluginDirCallback
    ${ExchAt} 1 $1  # Item callback arg 1: Plugin root
    ${ExchAt} 2 $0  # Array item.

    ${Logged1} CreateDirectory "$1\$0"

    Pop $1  # Ignored item callback arg 2
    Pop $1  # Restore stack

    # Empty return code:
    StrCpy $0 ""
    Exch   $0
FunctionEnd

# ----------------------------------------------------------------------------
# Function _VimCreateShortcutsFunc                                        {{{2
#   Callback function for LoopMatrix to create one shortcut.
#
#   LoopMatrix will provide content of all columns on the current row of the
#   shortcut specification, this function will create one shortcut according
#   to that specification.
# ----------------------------------------------------------------------------
Function _VimCreateShortcutsFunc
    Exch      $5     # Arg 2: Ignored
    ${ExchAt} 1 $4   # Arg 1: Shortcut root path
    ${ExchAt} 2 $3   # Col 4: Working directory of the shortcut
    ${ExchAt} 3 $2   # Col 3: Target arguments
    ${ExchAt} 4 $1   # Col 2: Shortcut target
    ${ExchAt} 5 $0   # Col 1: Shortcut filename

    # Prefix binary path to the target:
    StrCpy $1 "$vim_bin_path\$1"

    # Create the shortcut:
    SetOutPath $3
    ${Logged5} CreateShortCut "$4\$0" "$1" "$2" "$1" 0

    # Restore the stack:
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1

    # Empty return code:
    StrCpy $0 ""
    Exch   $0
FunctionEnd

# ----------------------------------------------------------------------------
# Function _VimCreateBatchFunc                                            {{{2
#   Callback function for LoopMatrix to create one batch file.
#
#   LoopMatrix will provide content of all columns on the current row of the
#   batch file specification, this function will create one batch file
#   according to that specification.
# ----------------------------------------------------------------------------
Function _VimCreateBatchFunc
    Exch      $4     # Arg 2: Ignored
    ${ExchAt} 1 $3   # Arg 1: Batch file template (in target environment).
    ${ExchAt} 2 $2   # Col 3: Argument of the target.
    ${ExchAt} 3 $1   # Col 2: Target of the batch.
    ${ExchAt} 4 $0   # Col 1: Name of the batch file.

    # Create the batch file:
    StrCpy $0 "$WINDIR\$0"
    StrCpy $vim_batch_exe "$1"
    StrCpy $vim_batch_arg "$2"
    ${Log} "Create batch file: [$0], Target=[$1], Arg=[$2]"
    ${LineFind} "$3" "$0" "" "_VimCreateBatchCallback"

    # Restore the stack:
    Pop $4
    Pop $3
    Pop $2
    Pop $1

    # Empty return code:
    StrCpy $0 ""
    Exch   $0
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
    Exch $0   # Full path of the vim shell extension
    Push $R0

    # Register inproc server:
    # $R0 - CLSID registry key.
    StrCpy $R0 "CLSID\${VIM_SH_EXT_CLSID}"
    ${Logged4} WriteRegStr HKCR "$R0" "" "${VIM_SH_EXT_NAME}"
    ${Logged4} WriteRegStr HKCR "$R0\InProcServer32" "" "$0"
    ${Logged4} WriteRegStr HKCR "$R0\InProcServer32" \
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

    # Register all supported file extensions:
    ${LoopArray} "${VIM_FILE_EXT_LIST}" "_VimRegFileExtCallback" "" "" $R0

    Pop $R0
    Pop $0
FunctionEnd

# ----------------------------------------------------------------------------
# Function _VimRegFileExtCallback                                         {{{2
#   Callback function for LoopArray.  It's used to register one file extension
#   supported by Vim.
# ----------------------------------------------------------------------------
Function _VimRegFileExtCallback
    ${ExchAt} 2 $0  # Array item.

    # Register supported file extension:
    ${Logged4} WriteRegStr HKCR "$0\OpenWithList\gvim.exe" "" ""

    Pop $0  # Ignored item callback arg 2
    Pop $0  # Ignored item callback arg 1

    # Empty return code:
    StrCpy $0 ""
    Exch   $0
FunctionEnd

# ----------------------------------------------------------------------------
# Function VimRegUninstallInfoCallback                                    {{{2
#   Callback function for LoopMatrix.  It's used to write uninstall
#   information into windows registry.
# ----------------------------------------------------------------------------
Function VimRegUninstallInfoCallback
    Exch      $4     # Arg 2: Ignored
    ${ExchAt} 1 $3   # Arg 1: Ignored
    ${ExchAt} 2 $2   # Col 3: Registry value
    ${ExchAt} 3 $1   # Col 2: Registry subkey
    ${ExchAt} 4 $0   # Col 1: Registry type STR|DW

    # $3 - Uninstall registry key.
    StrCpy $3 "${REG_KEY_UNINSTALL}\${VIM_PRODUCT_NAME}"

    ${If}     $0 S== "STR"
        ${Logged4} WriteRegStr   SHCTX "$3" "$1" "$2"
    ${ElseIf} $0 S== "DW"
        ${Logged4} WriteRegDWORD SHCTX "$3" "$1" "$2"
    ${Else}
        ${Log} "ERROR: Unknow subkey type : [$0]!"
    ${EndIf}

    Pop $4
    Pop $3
    Pop $2
    Pop $1

    # Empty return code:
    StrCpy $0 ""
    Exch   $0
FunctionEnd


##############################################################################
# Description for Installer Sections                                      {{{1
##############################################################################
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${id_group_old_ver}       $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_0}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_1}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_2}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_3}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_old_ver_4}   $(str_desc_old_ver)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_exe}         $(str_desc_exe)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_console}     $(str_desc_console)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_batch}       $(str_desc_batch)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_group_icons}         $(str_desc_icons)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_desktop}     $(str_desc_desktop)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_startmenu}   $(str_desc_start_menu)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_quicklaunch} $(str_desc_quick_launch)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_group_editwith}      $(str_desc_edit_with)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_editwith32}  $(str_desc_edit_with32)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_editwith64}  $(str_desc_edit_with64)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_section_vimrc}       $(str_desc_vim_rc)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_group_plugin}        $(str_desc_plugin)
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

# ----------------------------------------------------------------------------
# Section: Log status                                                     {{{2
# ----------------------------------------------------------------------------
Section -un.log_status
    Push $R0

    # Log install path etc.:
    ${Log} "Vim install root : $vim_install_root"
    ${Log} "Vim binary  path : $vim_bin_path"

    # Detect install mode:
    StrCpy $R0 "Normal"
    ${IfThen} ${Silent} ${|} StrCpy $R0 "Silent" ${|}
    ${Log} "Uninstall Mode   : $R0"

    # Log status for all sections:
    ${LogSectionStatus} 100

    Pop $R0
SectionEnd

# ----------------------------------------------------------------------------
# Section: Unregister Vim                                                 {{{2
# ----------------------------------------------------------------------------
Section "un.$(str_unsection_register)" id_unsection_register
    # Do not allow user to keep this section:
    SectionIn RO

    ${LogSectionStart}

    # Uninstall VisVim if it was included.
    # TODO: Any special handling on x64?
    !ifdef HAVE_VIS_VIM
        ${Log} "Remove $vim_bin_path\VisVim.dll"
        !insertmacro UninstallLib REGDLL NOTSHARED REBOOT_NOTPROTECTED \
            "$vim_bin_path\VisVim.dll"
    !endif

    # Remove gvimext.dll:
    !define LIBRARY_SHELL_EXTENSION

    ${If} ${FileExists} "$vim_bin_path\gvimext64.dll"
        # Remove 64-bit shell extension:
        ${Log} "Remove $vim_bin_path\gvimext64.dll"
        ${Logged1} SetRegView 64
        !define LIBRARY_X64
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$vim_bin_path\gvimext64.dll"
        !undef LIBRARY_X64

        ${Logged1} SetRegView 64
        Call un.VimUnregShellExt
    ${EndIf}

    ${If} ${FileExists} "$vim_bin_path\gvimext32.dll"
        # Remove 32-bit shell extension:
        ${Log} "Remove $vim_bin_path\gvimext32.dll"
        ${Logged1} SetRegView 32
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$vim_bin_path\gvimext32.dll"

        ${Logged1} SetRegView 32
        Call un.VimUnregShellExt
    ${EndIf}

    !undef LIBRARY_SHELL_EXTENSION

    # Restore registry view:
    ${VimSelectRegView}

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

    # Delete install log:
    !ifdef VIM_LOG_FILE
        ${Logged1} Delete "$vim_bin_path\${VIM_LOG_FILE}"
    !endif

    # Unregister gvim with OLE:
    ${LogPrint} "$(str_msg_unreg_ole)"
    ${Logged1} ExecWait '"$vim_bin_path\gvim.exe" -silent -unregister'

    # Remove uninstall information:
    ${Logged3} DeleteRegKey /ifempty SHCTX \
        "${REG_KEY_UNINSTALL}\${VIM_PRODUCT_NAME}"

    # We may have been put to the background when uninstall did something.
    ${IfNotThen} ${Silent} ${|} BringToFront ${|}

    ${LogSectionEnd}
SectionEnd

# ----------------------------------------------------------------------------
# Section: Remove executables                                             {{{2
# ----------------------------------------------------------------------------
Section "un.$(str_unsection_exe)" id_unsection_exe
    ${LogSectionStart}

    # Remove NLS support DLLs.  This is overkill.
    !ifdef HAVE_NLS
        ${Log} "Remove $vim_bin_path\libintl.dll"
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$vim_bin_path\libintl.dll"

        !ifdef HAVE_ICONV
            ${Log} "Remove $vim_bin_path\iconv.dll"
            !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
                "$vim_bin_path\iconv.dll"
        !endif
    !endif

    # Remove XPM:
    !ifdef HAVE_XPM
        ${Log} "Remove $vim_bin_path\xpm4.dll"
        !insertmacro UninstallLib DLL NOTSHARED REBOOT_NOTPROTECTED \
            "$vim_bin_path\xpm4.dll"
    !endif

    # Remove everything but *.dll files.  Avoids that a lot remains when
    # gvimext.dll cannot be deleted.
    ClearErrors
    ${Logged2} RMDir /r "$vim_bin_path\VisVim"
    ${Logged2} RMDir /r "$vim_bin_path\autoload"
    ${Logged2} RMDir /r "$vim_bin_path\colors"
    ${Logged2} RMDir /r "$vim_bin_path\compiler"
    ${Logged2} RMDir /r "$vim_bin_path\doc"
    ${Logged2} RMDir /r "$vim_bin_path\ftplugin"
    ${Logged2} RMDir /r "$vim_bin_path\indent"
    ${Logged2} RMDir /r "$vim_bin_path\keymap"
    ${Logged2} RMDir /r "$vim_bin_path\lang"
    ${Logged2} RMDir /r "$vim_bin_path\macros"
    ${Logged2} RMDir /r "$vim_bin_path\plugin"
    ${Logged2} RMDir /r "$vim_bin_path\spell"
    ${Logged2} RMDir /r "$vim_bin_path\syntax"
    ${Logged2} RMDir /r "$vim_bin_path\tools"
    ${Logged2} RMDir /r "$vim_bin_path\tutor"
    ${Logged1} Delete "$vim_bin_path\*.bat"
    ${Logged1} Delete "$vim_bin_path\*.exe"
    ${Logged1} Delete "$vim_bin_path\*.txt"
    ${Logged1} Delete "$vim_bin_path\*.vim"

    ${If} ${Errors}
        ${ShowErr} $(str_msg_rm_exe_fail)
    ${EndIf}

    # No error message if the "vim62" directory can't be removed, the
    # gvimext.dll may still be there.
    ${Logged1} RMDir "$vim_bin_path"

    # Also remove common files if this is the last Vim:
    StrCpy $vim_rm_common $vim_last_copy

    ${LogSectionEnd}
SectionEnd

# ----------------------------------------------------------------------------
# Section: Remove $VIM/_vimrc                                             {{{2
# ----------------------------------------------------------------------------
Section /o "un.$(str_unsection_rc)" id_unsection_rc
    # Do not allow user to remove this section initially:
    SectionIn RO

    ${LogSectionStart}

    # Remove all possible config file(s) if this is the last Vim:
    ${If} $vim_rm_common = 1
        ${Logged1} Delete "$vim_install_root\_vimrc"
        ${Logged1} Delete "$vim_install_root\.vimrc"
        ${Logged1} Delete "$vim_install_root\vimrc~1"
    ${EndIf}

    ${LogSectionEnd}
SectionEnd

# ----------------------------------------------------------------------------
# Section: Final touch                                                    {{{2
# ----------------------------------------------------------------------------
Section -un.post
    # Remove unchanged common components when remove the last Vim:
    ${If} $vim_rm_common = 1
        # Remove empty plugin directory hierarchy under $HOME:
        Push "HOME"
        Call un.VimRmPluginDir

        # Remove empty plugin directory hierarchy under $VIM:
        Push "VIM"
        Call un.VimRmPluginDir

        # Remove install root if it is empty:
        ${Logged1} RMDir "$vim_install_root"
        ${If} ${Errors}
            ${LogPrint} "$(str_msg_rm_root_fail)"
        ${EndIf}
    ${EndIf}

    # Close log:
    !ifdef VIM_LOG_FILE
        ${LogClose}
    !endif
SectionEnd


##############################################################################
# Description for Uninstaller Sections                                    {{{1
##############################################################################
!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_register} $(str_desc_unregister)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_exe}      $(str_desc_rm_exe)
    !insertmacro MUI_DESCRIPTION_TEXT ${id_unsection_rc}       $(str_desc_rm_rc)
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END


##############################################################################
# Uninstaller Functions                                                   {{{1
##############################################################################

# ----------------------------------------------------------------------------
# Declaration of external functions                                       {{{2
# ----------------------------------------------------------------------------
${UnStrLoc}              # ${UnStrLoc}
${DECLARE_UnLoopArray}   # ${LoopArray}
${DECLARE_UnLoopMatrix}  # ${LoopMatrix}

# ----------------------------------------------------------------------------
# Function un.onInit                                                      {{{2
# ----------------------------------------------------------------------------
Function un.onInit
    Push $R0

    # Initialize all globals:
    StrCpy $vim_cmd_params      ""
    StrCpy $vim_silent_auto_dir 0
    StrCpy $vim_silent_rm_old   0
    StrCpy $vim_silent_rm_exe   0
    StrCpy $vim_silent_rm_rc    0
    StrCpy $vim_install_root    ""
    StrCpy $vim_bin_path        ""
    StrCpy $vim_old_ver_keys    ""
    StrCpy $vim_old_ver_count   0
    StrCpy $vim_loud_ver_count  0
    StrCpy $vim_has_console     0
    StrCpy $vim_batch_exe       ""
    StrCpy $vim_batch_arg       ""
    StrCpy $vim_batch_ver_found 0
    StrCpy $vim_last_copy       0
    StrCpy $vim_rm_common       0

    # Initialize log:
    !ifdef VIM_LOG_FILE
        ${LogInit} "$TEMP\${VIM_LOG_FILE}" "Vim uninstaller log"
    !endif

    # Use shell folders for "all" user:
    ${Logged1} SetShellVarContext all

    # Set correct registry view:
    ${VimSelectRegView}

    # Get stored language preference:
    !ifdef HAVE_MULTI_LANG
        !insertmacro MUI_UNGETLANGUAGE
    !endif

    # Please note $INSTDIR is set to the directory where the uninstaller is
    # created, i.e., the binary path.  Thus the "vim73" is included in it.
    # The root path of the installation is it's parent path:
    ${GetParent} "$INSTDIR" $vim_install_root

    # Check to make sure this is a valid directory:
    ${VimVerifyRootDir} "$vim_install_root" $R0
    ${If} $R0 = 0
        ${ShowErr} $(str_msg_invalid_root)
        Pop $R0
        Abort
    ${EndIf}

    # Construct and check the binary path.  It must be the same as the
    # $INSTDIR, otherwise something must be wrong:
    StrCpy $vim_bin_path "$vim_install_root\${VIM_BIN_DIR}"
    ${If} "$vim_bin_path" S!= "$INSTDIR"
        ${ShowErr} "$(str_msg_bin_mismatch)"
        Pop $R0
        Abort
    ${EndIf}

    # Count all Vim version installed on this system.  If only one version
    # found, and it's the version we are about to uninstall, we're free to
    # remove common components:
    ${VimLoadUninstallKeys}
    ${TrimString} "$vim_old_ver_keys" $vim_old_ver_keys

    ${If}    $vim_old_ver_count = 1
    ${AndIf} $vim_old_ver_keys  S== "${VIM_PRODUCT_NAME}"
        ${Log} "About to remove the last Vim version."
        StrCpy $vim_last_copy 1

        # Allow user to remove config file:
        !insertmacro ClearSectionFlag ${id_unsection_rc} ${SF_RO}
    ${Else}
        ${Log} "This is not the last Vim version."
        StrCpy $vim_last_copy 0

        # Config file should not be removed:
        !insertmacro UnSelectSection ${id_unsection_rc}
        !insertmacro SetSectionFlag  ${id_unsection_rc} ${SF_RO}
    ${EndIf}

    # Process command line parameters:
    Call un.VimProcessCmdParams

    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un.onSelChange                                                 {{{2
# ----------------------------------------------------------------------------
Function un.onSelChange
    Push $R0

    # Get selection status of the exe removal section:
    SectionGetFlags ${id_unsection_exe} $R0

    # Config file should not be removed unless executables will be removed,
    # and this is the last Vim on the system.
    IntOp $R0 $R0 & ${SF_SELECTED}
    ${If}    $R0 = ${SF_SELECTED}
    ${AndIf} $vim_last_copy = 1
        # Allow user to remove config file:
        !insertmacro ClearSectionFlag ${id_unsection_rc} ${SF_RO}
    ${Else}
        # Config file should not be removed:
        !insertmacro UnSelectSection ${id_unsection_rc}
        !insertmacro SetSectionFlag  ${id_unsection_rc} ${SF_RO}
    ${EndIf}

    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un.VimProcessCmdParams                                         {{{2
#   Processing command line parameters for uninstaller.
#
#   Parameters : None
#   Returns    : None
# ----------------------------------------------------------------------------
Function un.VimProcessCmdParams
    # Get command line parameters:
    ${GetParameters} $vim_cmd_params
    ${Log} "Command line params: [$vim_cmd_params]"

    # Bail out if no command line parameter specified:
    ${IfThen} $vim_cmd_params S== "" ${|} Return ${|}

    Push $R0

    # Should we remove executables? (/RMEXE[{+/-}]
    ${VimCmdLineSelSecE} "/RMEXE" "RMEXE" ${id_unsection_exe}
    Call un.onSelChange

    # Should we remove config files? (/RMRC[{+/-}]
    ${VimCmdLineSelSecE} "/RMRC" "RMRC" ${id_unsection_rc}
    Call un.onSelChange

    # Check command line syntax errors:
    ${VimCheckCmdLine} $R0
    ${If} $R0 <> 0
        Pop $R0
        Abort
    ${EndIf}

    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un.VimCheckRunning                                             {{{2
#   Check if there're running Vim instances or not before any change has been
#   made.  Refuse to uninstall if Vim is still running.
# ----------------------------------------------------------------------------
Function un.VimCheckRunning
    Push $R0

    ${VimIsRuning} "$vim_bin_path" $R0
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
    Exch $0   # The name of the environment string for plugin root.
    Push $R0

    # Determine plugin root directory.
    # $0 - Plugin root directory
    ${VimGetPluginRoot} $0 $0

    # Make sure that all plugin subdirectories are empty:
    ${LoopArray} "${VIM_PLUGIN_SUBDIR}" "un._VimCheckPluginDirCallback" \
        "$0" "" $R0

    ${If} $R0 == ""
        # All plugin subdirectories are empty, now we're safe to remove them:
        ${LoopArray} "${VIM_PLUGIN_SUBDIR}" "un._VimRmPluginDirCallback" \
            "$0" "" $R0

        # Remove vimfiles directory if it is empty:
        ClearErrors
        ${Logged1} RMDir "$0"
        ${If} ${Errors}
            ${Log} "WARNING: Cannot remove $0, it is not empty!"
        ${EndIf}
    ${Else}
        ${Log} "WARNING: Cannot remove non-empty $0!"
    ${EndIf}

    Pop $R0
    Pop $0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un._VimCheckPluginDirCallback                                  {{{2
#   Callback function for LoopArray.  It's used to check whether one plugin
#   subdirectory is empty or not.  Return non-empty return code on stack if
#   the subdirectory is not empty.
# ----------------------------------------------------------------------------
Function un._VimCheckPluginDirCallback
    Exch      $2    # Item callback arg 1: Ignored
    ${ExchAt} 1 $1  # Item callback arg 1: Plugin root
    ${ExchAt} 2 $0  # Array item.

    # Check directory status.  Returns non-empty return code (+1) if the
    # directory exists and is not empty:
    ${DirState} "$1\$0" $0
    ${If} $0 <= 0
        StrCpy $0 ""
    ${EndIf}

    Pop  $2  # Ignored item callback arg 2
    Pop  $1
    Exch $0  # Return code
FunctionEnd

# ----------------------------------------------------------------------------
# Function un._VimRmPluginDirCallback                                     {{{2
#   Callback function for LoopArray.  It's used to remove one plugin
#   subdirectory.
# ----------------------------------------------------------------------------
Function un._VimRmPluginDirCallback
    ${ExchAt} 1 $1  # Item callback arg 1: Plugin root
    ${ExchAt} 2 $0  # Array item.

    ${Logged1} RMDir "$1\$0"

    Pop $1  # Ignored item callback arg 2
    Pop $1  # Restore stack

    # Empty return code:
    StrCpy $0 ""
    Exch   $0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un._VimRmFileCallback                                          {{{2
#   Callback function for LoopMatrix to remove files.
#
#   Parameters:
#     The following parameters will be put on stack by LoopMatrix in order.
#     - Name of the file to be removed (no path).
#     - File root.
#     - Address for verification callback function.  Full path name of the
#       file to be removed will be put on the top of stack when call the
#       callback function, return code from the callback should be put on the
#       top of the stack.  File won't be removed unless the callback function
#       returns 1.  If no callback function provided, the file will be removed
#       without verification.
#   Returns:
#     N/A
# ----------------------------------------------------------------------------
Function un._VimRmFileCallback
    # Incoming parameters has been put on the stack:
    Exch      $2     # Arg 2: Addr of the verification callback if non-empty.
    ${ExchAt} 1 $1   # Arg 1: File root.
    ${ExchAt} 2 $0   # Name of the file to be removed.

    # Construct full file name:
    StrCpy $0 "$1\$0"

    # Call verification callback if provided, put return code in $1:
    ${If} $2 == ""
        StrCpy $1 1
    ${Else}
        Push $0  # Call with full name of the file to be removed.
        Call $2  # Call verification callback.
        Pop  $1  # Return code. 0 - Skip, 1 - OK to remove.
    ${EndIf}

    # Remove the file if the verification function indicates it's OK:
    ${If} $1 = 1
        ${Logged1} Delete "$0"
    ${EndIf}

    # Restore the stack:
    Pop $2
    Pop $1

    # Empty return code:
    StrCpy $0 ""
    Exch   $0
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
    Exch $0  # Full path name of the file to be removed.

    ${If} ${FileExists} "$0"
        # Search version string in the batch file:
        StrCpy $vim_batch_ver_found 0
        ${LineFind} "$0" "/NUL" "1:-1" "un._VimVerifyBatchCallback"

        ${If} $vim_batch_ver_found <> 1
            ${Log} "WARNING: [$0] cannot be removed since it is installed \
                    by a different version of Vim."
        ${EndIf}

        StrCpy $0 $vim_batch_ver_found
    ${Else}
        ${Log} "WARNING: [$0] has already been removed."
        StrCpy $0 0
    ${EndIf}

    # Output:
    Exch $0
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
# Function un.VimUnregShellExt                                            {{{2
#   Unregister vim shell extension.
#
#   Register view should be set before call this function.
#
#   Parameters : N/A
#   Returns    : N/A
# ----------------------------------------------------------------------------
Function un.VimUnregShellExt
    Push $R0

    # Unregister all supported file extensions:
    ${LoopArray} "${VIM_FILE_EXT_LIST}" "un._VimUnregFileExtCallback" \
        "" "" $R0

    # .vim file extension is specific to Vim, try to remove that from
    # registry:
    ${Logged3} DeleteRegKey /ifempty HKCR ".vim\OpenWithList"
    ${Logged3} DeleteRegKey /ifempty HKCR ".vim"

    # Unregister "Open With ..." list entry:
    ${Logged3} DeleteRegKey /ifempty HKCR \
        "Applications\gvim.exe\shell\edit\command"
    ${Logged3} DeleteRegKey /ifempty HKCR \
        "Applications\gvim.exe\shell\edit"
    ${Logged3} DeleteRegKey /ifempty HKCR \
        "Applications\gvim.exe\shell"
    ${Logged3} DeleteRegKey /ifempty HKCR \
        "Applications\gvim.exe"

    # Unregister shell extension:
    ${Logged3} DeleteRegKey /ifempty HKCR "*\shellex\ContextMenuHandlers\gvim"
    ${Logged3} DeleteRegValue SHCTX "${REG_KEY_SH_EXT}" "${VIM_SH_EXT_CLSID}"
    ${Logged3} DeleteRegKey /ifempty SHCTX "${REG_KEY_VIM}\Gvim"
    ${Logged3} DeleteRegKey /ifempty SHCTX "${REG_KEY_VIM}"

    # Unregister inproc server:
    # $R0 - CLSID registry key.
    StrCpy $R0 "CLSID\${VIM_SH_EXT_CLSID}"
    ${Logged3} DeleteRegKey /ifempty HKCR "$R0\InProcServer32"
    ${Logged3} DeleteRegKey /ifempty HKCR "$R0"

    Pop $R0
FunctionEnd

# ----------------------------------------------------------------------------
# Function un._VimUnregFileExtCallback                                    {{{2
#   Callback function for LoopArray.  It's used to unregister one file
#   extension supported by Vim.
# ----------------------------------------------------------------------------
Function un._VimUnregFileExtCallback
    ${ExchAt} 2 $0  # Array item.

    # Register supported file extension:
    ${Logged3} DeleteRegKey /ifempty HKCR "$0\OpenWithList\gvim.exe"

    Pop $0  # Ignored item callback arg 2
    Pop $0  # Ignored item callback arg 2

    # Empty return code:
    StrCpy $0 ""
    Exch   $0
FunctionEnd
