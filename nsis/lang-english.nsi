# vi:set ts=8 sts=4 sw=4:
#
# lang-english.nsi: English language strings for gvim Windows installer.
#
# Author: Guopeng Wen

# For a list of languages supported by NSIS, check:
#   "<nsis>/Contrib/Language files"
# ${LANG_<language>} will be defined be defined as the language id after you
# inserted the language.  For example, after you insert "English",
# ${LANG_ENGLISH} will be defined as the language ID so you can use it in the
# following language string definition.
!insertmacro MUI_LANGUAGE "English"


##############################################################################
# MUI Configuration Strings
##############################################################################

LangString str_dest_folder          ${LANG_ENGLISH} \
    "Destination Folder (Must end with $\"vim$\")"

LangString str_show_readme          ${LANG_ENGLISH} \
    "Show README after installation finish"

# Install types:
LangString str_type_typical         ${LANG_ENGLISH} \
    "Typical"

LangString str_type_minimal         ${LANG_ENGLISH} \
    "Minimal"

LangString str_type_full            ${LANG_ENGLISH} \
    "Full"


##############################################################################
# Section Titles
##############################################################################

LangString str_section_exe          ${LANG_ENGLISH} \
    "Vim GUI"

LangString str_section_console      ${LANG_ENGLISH} \
    "Vim console program"

LangString str_section_batch        ${LANG_ENGLISH} \
    "Create .bat files"

LangString str_section_desktop      ${LANG_ENGLISH} \
    "Create icons on the Desktop"

LangString str_section_start_menu   ${LANG_ENGLISH} \
    "Add Start Menu Entry"

LangString str_section_quick_launch ${LANG_ENGLISH} \
    "Add Quick Launch Entry"

LangString str_section_edit_with    ${LANG_ENGLISH} \
    "Add Vim Context Menu"

LangString str_section_vim_rc       ${LANG_ENGLISH} \
    "Create Default Config"

LangString str_section_plugin_home  ${LANG_ENGLISH} \
    "Create Plugin Directories"

LangString str_section_plugin_vim   ${LANG_ENGLISH} \
    "Create Shared Plugin Directories"

LangString str_section_vis_vim      ${LANG_ENGLISH} \
    "VisVim Extension"

LangString str_section_nls          ${LANG_ENGLISH} \
    "Native Language Support"

LangString str_unsection_register   ${LANG_ENGLISH} \
    "Unregister Vim"

LangString str_unsection_exe        ${LANG_ENGLISH} \
    "Remove Vim Excutables/Runtime Files"

LangString str_unsection_plugin     ${LANG_ENGLISH} \
    "Remove Vim Plugin Directory $vim_plugin_path"

LangString str_unsection_root       ${LANG_ENGLISH} \
    "Remove Vim Root Directory $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_desc_exe          ${LANG_ENGLISH} \
    "Vim GUI executables and runtime files.  This component is required."

LangString str_desc_console      ${LANG_ENGLISH} \
    "Console version of vim (vim.exe)."

LangString str_desc_batch        ${LANG_ENGLISH} \
    "Create .bat files for Vim variants in the Windows directory for \
     command line use."

LangString str_desc_desktop      ${LANG_ENGLISH} \
    "Create icons for gVim executables on the desktop."

LangString str_desc_start_menu   ${LANG_ENGLISH} \
    "Add Vim to the start menu.  Appicable to Windows 95 and later."

LangString str_desc_quick_launch ${LANG_ENGLISH} \
    "Add Vim shortcut to the Quick launch panel."

LangString str_desc_edit_with    ${LANG_ENGLISH} \
    "Add Vim to the $\"Open With...$\" context menu list."

LangString str_desc_vim_rc       ${LANG_ENGLISH} \
    "Create a default _vimrc file if one does not already exist. \
     The _vimrc file is used to set options for how Vim behaves."

LangString str_desc_plugin_home  ${LANG_ENGLISH} \
    "Create plugin directories in HOME (if you defined one) or Vim \
     install directory (used for everybody on the system). \
     Plugin directories allow extending Vim by dropping a file into \
     a directory."

LangString str_desc_plugin_vim   ${LANG_ENGLISH} \
    "Create plugin directories in Vim install directory (used for \
     everybody on the system).  Plugin directories allow extending \
     Vim by dropping a file into a directory."

LangString str_desc_vis_vim      ${LANG_ENGLISH} \
    "VisVim Extension for Microsoft Visual Studio integration."

LangString str_desc_nls          ${LANG_ENGLISH} \
    "Install files for native language support."

LangString str_desc_unregister   ${LANG_ENGLISH} \
    "Unregister Vim from the system."

LangString str_desc_rm_exe       ${LANG_ENGLISH} \
    "Remove all Vim excutables and runtime files."

LangString str_desc_rm_plugin    ${LANG_ENGLISH} \
    "Remove all files in your Vim plugin directory $vim_plugin_path.$\n$\n\
     CAREFUL: Do NOT remove the directory if you have created something \
     there that you want to keep."

LangString str_desc_rm_root      ${LANG_ENGLISH} \
    "Remove Vim root directory $vim_install_root.  Please note this \
     directory contains your Vim configuration files.  Skip this if \
     you have modified configuration files that you want to keep."


##############################################################################
# Messages
##############################################################################

LangString str_msg_vim_running   ${LANG_ENGLISH} \
    "Vim is still running on your system.  Please close all instances of Vim \
     before you continue."

LangString str_msg_install_fail  ${LANG_ENGLISH} \
    "Installation failed. Better luck next time."

LangString str_msg_unregister    ${LANG_ENGLISH} \
    "Unregistering Vim ..."

LangString str_msg_rm_exe        ${LANG_ENGLISH} \
    "Removing Vim excutables/runtime files ..."

LangString str_msg_rm_exe_fail   ${LANG_ENGLISH} \
    "Some files in $0 have not been deleted!$\nYou must do it manually."

LangString str_msg_rm_plugin     ${LANG_ENGLISH} \
    "Removing Vim plugin directory $vim_plugin_path ..."

LangString str_msg_rm_root       ${LANG_ENGLISH} \
    "Removing Vim root directory $vim_install_root ..."

LangString str_msg_invalid_root  ${LANG_ENGLISH} \
    "Invalid install path $vim_install_root!$\nAbort uninstaller."
