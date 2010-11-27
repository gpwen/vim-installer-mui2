# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# slovak.nsi : Slovak language strings for gvim NSIS installer.
#
# Locale ID    : 1051
# Locale Name  : sk
# fileencoding :
# Author       :

!include "helper_util.nsh"
${VimAddLanguage} "Slovak" "sk"


##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

LangString str_dest_folder          ${LANG_SLOVAK} \
    "Destination Folder (Must end with $\"vim$\")"

LangString str_show_readme          ${LANG_SLOVAK} \
    "Show README after installation finish"

# Install types:
LangString str_type_typical         ${LANG_SLOVAK} \
    "Typical"

LangString str_type_minimal         ${LANG_SLOVAK} \
    "Minimal"

LangString str_type_full            ${LANG_SLOVAK} \
    "Full"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_group_old_ver        ${LANG_SLOVAK} \
    "Uninstall Existing Version(s)"
LangString str_desc_old_ver         ${LANG_SLOVAK} \
    "Uninstall existing Vim version(s) from your system."

LangString str_section_exe          ${LANG_SLOVAK} \
    "Vim GUI"
LangString str_desc_exe             ${LANG_SLOVAK} \
    "Vim GUI executables and runtime files.  This component is required."

LangString str_section_console      ${LANG_SLOVAK} \
    "Vim console program"
LangString str_desc_console         ${LANG_SLOVAK} \
    "Console version of Vim (vim.exe)."

LangString str_section_batch        ${LANG_SLOVAK} \
    "Create .bat files"
LangString str_desc_batch           ${LANG_SLOVAK} \
    "Create .bat files for Vim variants in the Windows directory for \
     command line use."

LangString str_group_icons          ${LANG_SLOVAK} \
    "Create icons for Vim"
LangString str_desc_icons           ${LANG_SLOVAK} \
    "Create icons for Vim at various locations to facilitate easy access."

LangString str_section_desktop      ${LANG_SLOVAK} \
    "On the Desktop"
LangString str_desc_desktop         ${LANG_SLOVAK} \
    "Create icons for gVim executables on the desktop."

LangString str_section_start_menu   ${LANG_SLOVAK} \
    "In the Start Menu Programs Folder"
LangString str_desc_start_menu      ${LANG_SLOVAK} \
    "Add Vim in the programs folder of the start menu.  \
     Applicable to Windows 95 and later."

LangString str_section_quick_launch ${LANG_SLOVAK} \
    "In the Quick Launch Bar"
LangString str_desc_quick_launch    ${LANG_SLOVAK} \
    "Add Vim shortcut in the quick launch bar."

LangString str_group_edit_with      ${LANG_SLOVAK} \
    "Add Vim Context Menu"
LangString str_desc_edit_with       ${LANG_SLOVAK} \
    "Add Vim to the $\"Open With...$\" context menu list."

LangString str_section_edit_with32  ${LANG_SLOVAK} \
    "32-bit Version"
LangString str_desc_edit_with32     ${LANG_SLOVAK} \
    "Add Vim to the $\"Open With...$\" context menu list \
     for 32-bit applications."

LangString str_section_edit_with64  ${LANG_SLOVAK} \
    "64-bit Version"
LangString str_desc_edit_with64     ${LANG_SLOVAK} \
    "Add Vim to the $\"Open With...$\" context menu list \
     for 64-bit applications."

LangString str_section_vim_rc       ${LANG_SLOVAK} \
    "Create Default Config"
LangString str_desc_vim_rc          ${LANG_SLOVAK} \
    "Create a default config file (_vimrc) if one does not already exist."

LangString str_group_plugin         ${LANG_SLOVAK} \
    "Create Plugin Directories"
LangString str_desc_plugin          ${LANG_SLOVAK} \
    "Create plugin directories.  Plugin directories allow extending Vim \
     by dropping a file into a directory."

LangString str_section_plugin_home  ${LANG_SLOVAK} \
    "Private"
LangString str_desc_plugin_home     ${LANG_SLOVAK} \
    "Create plugin directories in HOME (if you defined one) or Vim \
     install directory."

LangString str_section_plugin_vim   ${LANG_SLOVAK} \
    "Shared"
LangString str_desc_plugin_vim      ${LANG_SLOVAK} \
    "Create plugin directories in Vim install directory, it is used for \
     everybody on the system."

LangString str_section_vis_vim      ${LANG_SLOVAK} \
    "VisVim Extension"
LangString str_desc_vis_vim         ${LANG_SLOVAK} \
    "VisVim Extension for Microsoft Visual Studio integration."

LangString str_section_nls          ${LANG_SLOVAK} \
    "Native Language Support"
LangString str_desc_nls             ${LANG_SLOVAK} \
    "Install files for native language support."

LangString str_unsection_register   ${LANG_SLOVAK} \
    "Unregister Vim"
LangString str_desc_unregister      ${LANG_SLOVAK} \
    "Unregister Vim from the system."

LangString str_unsection_exe        ${LANG_SLOVAK} \
    "Remove Vim Executables/Runtime Files"
LangString str_desc_rm_exe          ${LANG_SLOVAK} \
    "Remove all Vim executables and runtime files."

LangString str_unsection_rc         ${LANG_SLOVAK} \
    "Remove Vim Config File"
LangString str_desc_rm_rc           ${LANG_SLOVAK} \
    "Remove Vim configuration file $vim_install_root\_vimrc. \
     Skip this if you have modified the configuration file."


##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_too_many_ver  ${LANG_SLOVAK} \
    "Found $vim_old_ver_count Vim versions on your system.$\r$\n\
     This installer can only handle ${VIM_MAX_OLD_VER} versions \
     at most.$\r$\n\
     Please remove some versions and start again."

LangString str_msg_invalid_root  ${LANG_SLOVAK} \
    "Invalid install path: $vim_install_root!$\r$\n\
     It should end with $\"vim$\"."

LangString str_msg_bin_mismatch  ${LANG_SLOVAK} \
    "Binary path mismatch!$\r$\n$\r$\n\
     Expect the binary path to be $\"$vim_bin_path$\",$\r$\n\
     but system indicates the binary path is $\"$INSTDIR$\"."

LangString str_msg_vim_running   ${LANG_SLOVAK} \
    "Vim is still running on your system.$\r$\n\
     Please close all instances of Vim before you continue."

LangString str_msg_register_ole  ${LANG_SLOVAK} \
    "Attempting to register Vim with OLE. \
     There is no message indicates whether this works or not."

LangString str_msg_unreg_ole     ${LANG_SLOVAK} \
    "Attempting to unregister Vim with OLE. \
     There is no message indicates whether this works or not."

LangString str_msg_rm_start      ${LANG_SLOVAK} \
    "Uninstalling the following version:"

LangString str_msg_rm_fail       ${LANG_SLOVAK} \
    "Fail to uninstall the following version:"

LangString str_msg_no_rm_key     ${LANG_SLOVAK} \
    "Cannot find uninstaller registry key."

LangString str_msg_no_rm_reg     ${LANG_SLOVAK} \
    "Cannot find uninstaller from registry."

LangString str_msg_no_rm_exe     ${LANG_SLOVAK} \
    "Cannot access uninstaller."

LangString str_msg_rm_copy_fail  ${LANG_SLOVAK} \
    "Fail to copy uninstaller to temporary directory."

LangString str_msg_rm_run_fail   ${LANG_SLOVAK} \
    "Fail to run uninstaller."

LangString str_msg_abort_install ${LANG_SLOVAK} \
    "Installer will abort."

LangString str_msg_install_fail  ${LANG_SLOVAK} \
    "Installation failed. Better luck next time."

LangString str_msg_rm_exe_fail   ${LANG_SLOVAK} \
    "Some files in $vim_bin_path have not been deleted!$\r$\n\
     You must do it manually."

LangString str_msg_rm_root_fail  ${LANG_SLOVAK} \
    "WARNING: Cannot remove $\"$vim_install_root$\", it is not empty!"
