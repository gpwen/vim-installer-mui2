# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# kurdish.nsi : Kurdish language strings for gvim NSIS installer.
#
# Locale ID    : 9999
# fileencoding :
# Author       :

!insertmacro MUI_LANGUAGE "Kurdish"


##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

LangString str_dest_folder          ${LANG_KURDISH} \
    "Destination Folder (Must end with $\"vim$\")"

LangString str_show_readme          ${LANG_KURDISH} \
    "Show README after installation finish"

# Install types:
LangString str_type_typical         ${LANG_KURDISH} \
    "Typical"

LangString str_type_minimal         ${LANG_KURDISH} \
    "Minimal"

LangString str_type_full            ${LANG_KURDISH} \
    "Full"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_group_old_ver        ${LANG_KURDISH} \
    "Uninstall Existing Version(s)"
LangString str_desc_old_ver         ${LANG_KURDISH} \
    "Uninstall existing Vim version(s) from your system."

LangString str_section_exe          ${LANG_KURDISH} \
    "Vim GUI"
LangString str_desc_exe             ${LANG_KURDISH} \
    "Vim GUI executables and runtime files.  This component is required."

LangString str_section_console      ${LANG_KURDISH} \
    "Vim console program"
LangString str_desc_console         ${LANG_KURDISH} \
    "Console version of Vim (vim.exe)."

LangString str_section_batch        ${LANG_KURDISH} \
    "Create .bat files"
LangString str_desc_batch           ${LANG_KURDISH} \
    "Create .bat files for Vim variants in the Windows directory for \
     command line use."

LangString str_group_icons          ${LANG_KURDISH} \
    "Create icons for Vim"
LangString str_desc_icons           ${LANG_KURDISH} \
    "Create icons for Vim at various locations to facilitate easy access."

LangString str_section_desktop      ${LANG_KURDISH} \
    "On the Desktop"
LangString str_desc_desktop         ${LANG_KURDISH} \
    "Create icons for gVim executables on the desktop."

LangString str_section_start_menu   ${LANG_KURDISH} \
    "In the Start Menu Programs Folder"
LangString str_desc_start_menu      ${LANG_KURDISH} \
    "Add Vim in the programs folder of the start menu.  \
     Applicable to Windows 95 and later."

LangString str_section_quick_launch ${LANG_KURDISH} \
    "In the Quick Launch Bar"
LangString str_desc_quick_launch    ${LANG_KURDISH} \
    "Add Vim shortcut in the quick launch bar."

LangString str_group_edit_with      ${LANG_KURDISH} \
    "Add Vim Context Menu"
LangString str_desc_edit_with       ${LANG_KURDISH} \
    "Add Vim to the $\"Open With...$\" context menu list."

LangString str_section_edit_with32  ${LANG_KURDISH} \
    "32-bit Version"
LangString str_desc_edit_with32     ${LANG_KURDISH} \
    "Add Vim to the $\"Open With...$\" context menu list \
     for 32-bit applications."

LangString str_section_edit_with64  ${LANG_KURDISH} \
    "64-bit Version"
LangString str_desc_edit_with64     ${LANG_KURDISH} \
    "Add Vim to the $\"Open With...$\" context menu list \
     for 64-bit applications."

LangString str_section_vim_rc       ${LANG_KURDISH} \
    "Create Default Config"
LangString str_desc_vim_rc          ${LANG_KURDISH} \
    "Create a default config file (_vimrc) if one does not already exist."

LangString str_group_plugin         ${LANG_KURDISH} \
    "Create Plugin Directories"
LangString str_desc_plugin          ${LANG_KURDISH} \
    "Create plugin directories.  Plugin directories allow extending Vim \
     by dropping a file into a directory."

LangString str_section_plugin_home  ${LANG_KURDISH} \
    "Private"
LangString str_desc_plugin_home     ${LANG_KURDISH} \
    "Create plugin directories in HOME (if you defined one) or Vim \
     install directory."

LangString str_section_plugin_vim   ${LANG_KURDISH} \
    "Shared"
LangString str_desc_plugin_vim      ${LANG_KURDISH} \
    "Create plugin directories in Vim install directory, it is used for \
     everybody on the system."

LangString str_section_vis_vim      ${LANG_KURDISH} \
    "VisVim Extension"
LangString str_desc_vis_vim         ${LANG_KURDISH} \
    "VisVim Extension for Microsoft Visual Studio integration."

LangString str_section_nls          ${LANG_KURDISH} \
    "Native Language Support"
LangString str_desc_nls             ${LANG_KURDISH} \
    "Install files for native language support."

LangString str_unsection_register   ${LANG_KURDISH} \
    "Unregister Vim"
LangString str_desc_unregister      ${LANG_KURDISH} \
    "Unregister Vim from the system."

LangString str_unsection_exe        ${LANG_KURDISH} \
    "Remove Vim Executables/Runtime Files"
LangString str_desc_rm_exe          ${LANG_KURDISH} \
    "Remove all Vim executables and runtime files."

LangString str_unsection_rc         ${LANG_KURDISH} \
    "Remove Vim Config File"
LangString str_desc_rm_rc           ${LANG_KURDISH} \
    "Remove Vim configuration file $vim_install_root\_vimrc. \
     Skip this if you have modified the configuration file."


##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_too_many_ver  ${LANG_KURDISH} \
    "Found $vim_old_ver_count Vim versions on your system.$\r$\n\
     This installer can only handle ${VIM_MAX_OLD_VER} versions \
     at most.$\r$\n\
     Please remove some versions and start again."

LangString str_msg_invalid_root  ${LANG_KURDISH} \
    "Invalid install path: $vim_install_root!$\r$\n\
     It should end with $\"vim$\"."

LangString str_msg_bin_mismatch  ${LANG_KURDISH} \
    "Binary path mismatch!$\r$\n$\r$\n\
     Expect the binary path to be $\"$vim_bin_path$\",$\r$\n\
     but system indicates the binary path is $\"$INSTDIR$\"."

LangString str_msg_vim_running   ${LANG_KURDISH} \
    "Vim is still running on your system.$\r$\n\
     Please close all instances of Vim before you continue."

LangString str_msg_register_ole  ${LANG_KURDISH} \
    "Attempting to register Vim with OLE. \
     There is no message indicates whether this works or not."

LangString str_msg_unreg_ole     ${LANG_KURDISH} \
    "Attempting to unregister Vim with OLE. \
     There is no message indicates whether this works or not."

LangString str_msg_rm_start      ${LANG_KURDISH} \
    "Uninstalling the following version:"

LangString str_msg_rm_fail       ${LANG_KURDISH} \
    "Fail to uninstall the following version:"

LangString str_msg_no_rm_key     ${LANG_KURDISH} \
    "Cannot find uninstaller registry key."

LangString str_msg_no_rm_reg     ${LANG_KURDISH} \
    "Cannot find uninstaller from registry."

LangString str_msg_no_rm_exe     ${LANG_KURDISH} \
    "Cannot access uninstaller."

LangString str_msg_rm_copy_fail  ${LANG_KURDISH} \
    "Fail to copy uninstaller to temporary directory."

LangString str_msg_rm_run_fail   ${LANG_KURDISH} \
    "Fail to run uninstaller."

LangString str_msg_abort_install ${LANG_KURDISH} \
    "Installer will abort."

LangString str_msg_install_fail  ${LANG_KURDISH} \
    "Installation failed. Better luck next time."

LangString str_msg_rm_exe_fail   ${LANG_KURDISH} \
    "Some files in $vim_bin_path have not been deleted!$\r$\n\
     You must do it manually."

LangString str_msg_rm_root_fail  ${LANG_KURDISH} \
    "WARNING: Cannot remove $\"$vim_install_root$\", it is not empty!"
