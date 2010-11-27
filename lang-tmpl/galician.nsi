# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# galician.nsi : Galician language strings for gvim NSIS installer.
#
# Locale ID    : 1110
# Locale Name  : gl
# fileencoding :
# Author       :

!include "helper_util.nsh"
${VimAddLanguage} "Galician" "gl"


##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

LangString str_dest_folder          ${LANG_GALICIAN} \
    "Destination Folder (Must end with $\"vim$\")"

LangString str_show_readme          ${LANG_GALICIAN} \
    "Show README after installation finish"

# Install types:
LangString str_type_typical         ${LANG_GALICIAN} \
    "Typical"

LangString str_type_minimal         ${LANG_GALICIAN} \
    "Minimal"

LangString str_type_full            ${LANG_GALICIAN} \
    "Full"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_group_old_ver        ${LANG_GALICIAN} \
    "Uninstall Existing Version(s)"
LangString str_desc_old_ver         ${LANG_GALICIAN} \
    "Uninstall existing Vim version(s) from your system."

LangString str_section_exe          ${LANG_GALICIAN} \
    "Vim GUI"
LangString str_desc_exe             ${LANG_GALICIAN} \
    "Vim GUI executables and runtime files.  This component is required."

LangString str_section_console      ${LANG_GALICIAN} \
    "Vim console program"
LangString str_desc_console         ${LANG_GALICIAN} \
    "Console version of Vim (vim.exe)."

LangString str_section_batch        ${LANG_GALICIAN} \
    "Create .bat files"
LangString str_desc_batch           ${LANG_GALICIAN} \
    "Create .bat files for Vim variants in the Windows directory for \
     command line use."

LangString str_group_icons          ${LANG_GALICIAN} \
    "Create icons for Vim"
LangString str_desc_icons           ${LANG_GALICIAN} \
    "Create icons for Vim at various locations to facilitate easy access."

LangString str_section_desktop      ${LANG_GALICIAN} \
    "On the Desktop"
LangString str_desc_desktop         ${LANG_GALICIAN} \
    "Create icons for gVim executables on the desktop."

LangString str_section_start_menu   ${LANG_GALICIAN} \
    "In the Start Menu Programs Folder"
LangString str_desc_start_menu      ${LANG_GALICIAN} \
    "Add Vim in the programs folder of the start menu.  \
     Applicable to Windows 95 and later."

LangString str_section_quick_launch ${LANG_GALICIAN} \
    "In the Quick Launch Bar"
LangString str_desc_quick_launch    ${LANG_GALICIAN} \
    "Add Vim shortcut in the quick launch bar."

LangString str_group_edit_with      ${LANG_GALICIAN} \
    "Add Vim Context Menu"
LangString str_desc_edit_with       ${LANG_GALICIAN} \
    "Add Vim to the $\"Open With...$\" context menu list."

LangString str_section_edit_with32  ${LANG_GALICIAN} \
    "32-bit Version"
LangString str_desc_edit_with32     ${LANG_GALICIAN} \
    "Add Vim to the $\"Open With...$\" context menu list \
     for 32-bit applications."

LangString str_section_edit_with64  ${LANG_GALICIAN} \
    "64-bit Version"
LangString str_desc_edit_with64     ${LANG_GALICIAN} \
    "Add Vim to the $\"Open With...$\" context menu list \
     for 64-bit applications."

LangString str_section_vim_rc       ${LANG_GALICIAN} \
    "Create Default Config"
LangString str_desc_vim_rc          ${LANG_GALICIAN} \
    "Create a default config file (_vimrc) if one does not already exist."

LangString str_group_plugin         ${LANG_GALICIAN} \
    "Create Plugin Directories"
LangString str_desc_plugin          ${LANG_GALICIAN} \
    "Create plugin directories.  Plugin directories allow extending Vim \
     by dropping a file into a directory."

LangString str_section_plugin_home  ${LANG_GALICIAN} \
    "Private"
LangString str_desc_plugin_home     ${LANG_GALICIAN} \
    "Create plugin directories in HOME (if you defined one) or Vim \
     install directory."

LangString str_section_plugin_vim   ${LANG_GALICIAN} \
    "Shared"
LangString str_desc_plugin_vim      ${LANG_GALICIAN} \
    "Create plugin directories in Vim install directory, it is used for \
     everybody on the system."

LangString str_section_vis_vim      ${LANG_GALICIAN} \
    "VisVim Extension"
LangString str_desc_vis_vim         ${LANG_GALICIAN} \
    "VisVim Extension for Microsoft Visual Studio integration."

LangString str_section_nls          ${LANG_GALICIAN} \
    "Native Language Support"
LangString str_desc_nls             ${LANG_GALICIAN} \
    "Install files for native language support."

LangString str_unsection_register   ${LANG_GALICIAN} \
    "Unregister Vim"
LangString str_desc_unregister      ${LANG_GALICIAN} \
    "Unregister Vim from the system."

LangString str_unsection_exe        ${LANG_GALICIAN} \
    "Remove Vim Executables/Runtime Files"
LangString str_desc_rm_exe          ${LANG_GALICIAN} \
    "Remove all Vim executables and runtime files."

LangString str_unsection_rc         ${LANG_GALICIAN} \
    "Remove Vim Config File"
LangString str_desc_rm_rc           ${LANG_GALICIAN} \
    "Remove Vim configuration file $vim_install_root\_vimrc. \
     Skip this if you have modified the configuration file."


##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_too_many_ver  ${LANG_GALICIAN} \
    "Found $vim_old_ver_count Vim versions on your system.$\r$\n\
     This installer can only handle ${VIM_MAX_OLD_VER} versions \
     at most.$\r$\n\
     Please remove some versions and start again."

LangString str_msg_invalid_root  ${LANG_GALICIAN} \
    "Invalid install path: $vim_install_root!$\r$\n\
     It should end with $\"vim$\"."

LangString str_msg_bin_mismatch  ${LANG_GALICIAN} \
    "Binary path mismatch!$\r$\n$\r$\n\
     Expect the binary path to be $\"$vim_bin_path$\",$\r$\n\
     but system indicates the binary path is $\"$INSTDIR$\"."

LangString str_msg_vim_running   ${LANG_GALICIAN} \
    "Vim is still running on your system.$\r$\n\
     Please close all instances of Vim before you continue."

LangString str_msg_register_ole  ${LANG_GALICIAN} \
    "Attempting to register Vim with OLE. \
     There is no message indicates whether this works or not."

LangString str_msg_unreg_ole     ${LANG_GALICIAN} \
    "Attempting to unregister Vim with OLE. \
     There is no message indicates whether this works or not."

LangString str_msg_rm_start      ${LANG_GALICIAN} \
    "Uninstalling the following version:"

LangString str_msg_rm_fail       ${LANG_GALICIAN} \
    "Fail to uninstall the following version:"

LangString str_msg_no_rm_key     ${LANG_GALICIAN} \
    "Cannot find uninstaller registry key."

LangString str_msg_no_rm_reg     ${LANG_GALICIAN} \
    "Cannot find uninstaller from registry."

LangString str_msg_no_rm_exe     ${LANG_GALICIAN} \
    "Cannot access uninstaller."

LangString str_msg_rm_copy_fail  ${LANG_GALICIAN} \
    "Fail to copy uninstaller to temporary directory."

LangString str_msg_rm_run_fail   ${LANG_GALICIAN} \
    "Fail to run uninstaller."

LangString str_msg_abort_install ${LANG_GALICIAN} \
    "Installer will abort."

LangString str_msg_install_fail  ${LANG_GALICIAN} \
    "Installation failed. Better luck next time."

LangString str_msg_rm_exe_fail   ${LANG_GALICIAN} \
    "Some files in $vim_bin_path have not been deleted!$\r$\n\
     You must do it manually."

LangString str_msg_rm_root_fail  ${LANG_GALICIAN} \
    "WARNING: Cannot remove $\"$vim_install_root$\", it is not empty!"
