# vi:set ts=8 sts=4 sw=4:
#
# lang-english.nsi: English language strings for gvim Windows installer.
#
# Author: Guopeng Wen

!insertmacro MUI_LANGUAGE "English"


##############################################################################
# MUI Configuration Strings
##############################################################################

LangString str_DestFolder          ${LANG_ENGLISH} \
    "Destination Folder (Must end with $\"vim$\")"

LangString str_ShowReadme          ${LANG_ENGLISH} \
    "Show README after installation finish"

# Install types:
LangString str_TypeTypical         ${LANG_ENGLISH} \
    "Typical"

LangString str_TypeMinimal         ${LANG_ENGLISH} \
    "Minimal"

LangString str_TypeFull            ${LANG_ENGLISH} \
    "Full"


##############################################################################
# Section Titles
##############################################################################

LangString str_SectionExe          ${LANG_ENGLISH} \
    "Vim GUI"

LangString str_SectionConsole      ${LANG_ENGLISH} \
    "Vim console program"

LangString str_SectionBatch        ${LANG_ENGLISH} \
    "Create .bat files"

LangString str_SectionDesktop      ${LANG_ENGLISH} \
    "Create icons on the Desktop"

LangString str_SectionStartMenu    ${LANG_ENGLISH} \
    "Add Start Menu Entry"

LangString str_SectionQuickLaunch  ${LANG_ENGLISH} \
    "Add Quick Launch Entry"

LangString str_SectionEditWith     ${LANG_ENGLISH} \
    "Add Vim Context Menu"

LangString str_SectionVimRC        ${LANG_ENGLISH} \
    "Create Default Config"

LangString str_SectionPluginHome   ${LANG_ENGLISH} \
    "Create Plugin Directories"

LangString str_SectionPluginVim    ${LANG_ENGLISH} \
    "Create Shared Plugin Directories"

LangString str_SectionVisVim       ${LANG_ENGLISH} \
    "VisVim Extension"

LangString str_SectionNLS          ${LANG_ENGLISH} \
    "Native Language Support"

LangString str_UnsectionRegister   ${LANG_ENGLISH} \
    "Unregister Vim"

LangString str_UnsectionExe        ${LANG_ENGLISH} \
    "Remove Vim Excutables/Runtime Files"

LangString str_UnsectionPlugin     ${LANG_ENGLISH} \
    "Remove Vim Plugin Directory $vim_plugin_path"

LangString str_UnsectionRoot       ${LANG_ENGLISH} \
    "Remove Vim Root Directory $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_DescExe         ${LANG_ENGLISH} \
    "Vim GUI executables and runtime files.  This component is required."

LangString str_DescConsole     ${LANG_ENGLISH} \
    "Console version of vim (vim.exe)."

LangString str_DescBatch       ${LANG_ENGLISH} \
    "Create .bat files for Vim variants in the Windows directory for command line use."

LangString str_DescDesktop     ${LANG_ENGLISH} \
    "Create icons for gVim executables on the desktop."

LangString str_DescStartmenu   ${LANG_ENGLISH} \
    "Add Vim to the start menu.  Appicable to Windows 95 and later."

LangString str_DescQuicklaunch ${LANG_ENGLISH} \
    "Add Vim shortcut to the Quick launch panel."

LangString str_DescEditwith    ${LANG_ENGLISH} \
    "Add Vim to the $\"Open With...$\" context menu list."

LangString str_DescVimRC       ${LANG_ENGLISH} \
    "Create a default _vimrc file if one does not already exist.  The _vimrc file is used to set options for how Vim behaves."

LangString str_DescPluginHome  ${LANG_ENGLISH} \
    "Create plugin directories in HOME (if you have a home directory) or Vim install directory (used for everybody on the system).  Plugin directories allow extending Vim by dropping a file into a directory."

LangString str_DescPluginVim   ${LANG_ENGLISH} \
    "Create plugin directories in Vim install directory (used for everybody on the system).  Plugin directories allow extending Vim by dropping a file into a directory."

LangString str_DescVisVim      ${LANG_ENGLISH} \
    "VisVim Extension for Microsoft Visual Studio integration."

LangString str_DescNLS         ${LANG_ENGLISH} \
    "Install files for native language support."

LangString str_DescUnregister  ${LANG_ENGLISH} \
    "Unregister Vim from the system."

LangString str_DescRmExe       ${LANG_ENGLISH} \
    "Remove all Vim excutables and runtime files."

LangString str_DescnRmPlugin   ${LANG_ENGLISH} \
    "Remove all files in your Vim plugin directory $vim_plugin_path.  Skip this if you have created something there that you want to keep."

LangString str_DescnRmRoot     ${LANG_ENGLISH} \
    "Remove Vim root directory $vim_install_root.  Please note this directory contains your Vim configuration files.  Skip this if you have modified configuration files that you want to keep."


##############################################################################
# Messages
##############################################################################

LangString str_MsgInstallFail  ${LANG_ENGLISH} \
    "Installation failed. Better luck next time."

LangString str_MsgUnregister   ${LANG_ENGLISH} \
    "Unregistering Vim ..."

LangString str_MsgRmExe        ${LANG_ENGLISH} \
    "Removing Vim excutables/runtime files ..."

LangString str_MsgRmExeFail    ${LANG_ENGLISH} \
    "Some files in $0 have not been deleted!$\nYou must do it manually."

LangString str_MsgRmPlugin     ${LANG_ENGLISH} \
    "Removing Vim plugin directory $vim_plugin_path ..."

LangString str_MsgRmRoot       ${LANG_ENGLISH} \
    "Removing Vim root directory $vim_install_root ..."

LangString str_MsgInvalidRoot  ${LANG_ENGLISH} \
    "Invalid install path $vim_install_root!$\nAbort uninstaller."
