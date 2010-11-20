# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# german.nsi : German language strings for gvim NSIS installer.
#
# Locale ID    : 1031
# fileencoding : cp1252
# Author       : Christian Brabandt, tux

!include "helper_util.nsh"
${VimAddLanguage} "German" "de"


##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

LangString str_dest_folder          ${LANG_GERMAN} \
    "Zielverzeichnis ausw�hlen (muss auf $\"vim$\" enden)"

LangString str_show_readme          ${LANG_GERMAN} \
    "README-Datei nach der Installation anzeigen"

# Install types:
LangString str_type_typical         ${LANG_GERMAN} \
    "Typisch"

LangString str_type_minimal         ${LANG_GERMAN} \
    "Minimal"

LangString str_type_full            ${LANG_GERMAN} \
    "Vollst�ndig"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_group_old_ver        ${LANG_GERMAN} \
    "Vorherige Version deinstallieren"
LangString str_desc_old_ver         ${LANG_GERMAN} \
    "Vorherige installierte Versionen auf diesem System deinstallieren."

LangString str_section_exe          ${LANG_GERMAN} \
    "Vim GUI"
LangString str_desc_exe             ${LANG_GERMAN} \
    "Vim-GUI-Anwendung und Laufzeitdateien (Dieser Teil ist zwingend\
     erforderlich)."

LangString str_section_console      ${LANG_GERMAN} \
    "Vim Konsolenanwendung"
LangString str_desc_console         ${LANG_GERMAN} \
    "Konsolenversion von Vim."

LangString str_section_batch        ${LANG_GERMAN} \
    ".bat-Dateien erstellen"
LangString str_desc_batch           ${LANG_GERMAN} \
    ".bat-Dateien erstellen, um Vim in der Konsole auszuf�hren."

LangString str_group_icons          ${LANG_GERMAN} \
    "Vim-Verkn�pfungen erstellen"
LangString str_desc_icons           ${LANG_GERMAN} \
    "Verkn�pfungen mit Vim f�r einfachen Aufruf erstellen."

LangString str_section_desktop      ${LANG_GERMAN} \
    "Auf dem Desktop"
LangString str_desc_desktop         ${LANG_GERMAN} \
    "Icons f�r GVim auf dem Desktop erstellen."

LangString str_section_start_menu   ${LANG_GERMAN} \
    "Im Startmen�"
LangString str_desc_start_menu      ${LANG_GERMAN} \
    "Vim im Programmverzeichnis des Startmen�s hinzuf�gen\
     Windows 95 und h�her."

LangString str_section_quick_launch ${LANG_GERMAN} \
    "In der Schnellstartleiste"
LangString str_desc_quick_launch    ${LANG_GERMAN} \
    "Verkn�pfung zu Vim in der Schnellstartleiste ablegen."

LangString str_group_edit_with      ${LANG_GERMAN} \
    "Vim zum Kontextmen� hinzuf�gen"
LangString str_desc_edit_with       ${LANG_GERMAN} \
    "Vim in das $\"�ffnen mit...$\"-Kontextmen� einf�gen."

LangString str_section_edit_with32  ${LANG_GERMAN} \
    "32-Bit-Version"
LangString str_desc_edit_with32     ${LANG_GERMAN} \
    "Vim in das $\"�ffnen mit...$\"-Kontextmen� \
     f�r 32-Bit-Anwendungen integrieren."

LangString str_section_edit_with64  ${LANG_GERMAN} \
    "64-Bit-Version"
LangString str_desc_edit_with64     ${LANG_GERMAN} \
    "Vim in das $\"�ffnen mit...$\"-Kontextmen� \
     f�r 64-Bit-Anwendungen integrieren."

LangString str_section_vim_rc       ${LANG_GERMAN} \
    "Standard-Konfigurationsdatei erstellen"
LangString str_desc_vim_rc          ${LANG_GERMAN} \
    "Eine Standard-Konfigurationsdatei (_vimrc) erstellen, \
     falls noch keine existiert."

LangString str_group_plugin         ${LANG_GERMAN} \
    "Plugin-Verzeichnisse anlegen"
LangString str_desc_plugin          ${LANG_GERMAN} \
    "Plugin-Verzeichnisse anlegen.  Plugins erlauben es, Vim \
     um zus�tzliche Funktionen zu erweitern."

LangString str_section_plugin_home  ${LANG_GERMAN} \
    "Privat"
LangString str_desc_plugin_home     ${LANG_GERMAN} \
    "Plugin-Verzeichnis im Basisverzeichnis (falls es existiert) oder im \
     Vim-Installationspfad erstellen."

LangString str_section_plugin_vim   ${LANG_GERMAN} \
    "Freigegeben"
LangString str_desc_plugin_vim      ${LANG_GERMAN} \
    "Plugin-Verzeichnisse im Vim-Installationspfad erstellen. Diese werden \
     f�r alle Benutzer dieses Systems genutzt."

LangString str_section_vis_vim      ${LANG_GERMAN} \
    "VisVim-Erweiterung"
LangString str_desc_vis_vim         ${LANG_GERMAN} \
    "VisVim-Erweiterung zur Integration in Microsoft Visual Studio."

LangString str_section_nls          ${LANG_GERMAN} \
    "Unterst�tzung f�r andere Sprachen"
LangString str_desc_nls             ${LANG_GERMAN} \
    "Dateien zur Unterst�tzung anderer Sprachen als Englisch installieren."

LangString str_unsection_register   ${LANG_GERMAN} \
    "Vim deinstallieren"
LangString str_desc_unregister      ${LANG_GERMAN} \
    "Vim vom System entfernen."

LangString str_unsection_exe        ${LANG_GERMAN} \
    "Vim-Anwendung und Laufzeitdateien entfernen"
LangString str_desc_rm_exe          ${LANG_GERMAN} \
    "Alle Vim-Anwendungen und Laufzeitdateien von diesem System entfernen."

LangString str_unsection_rc         ${LANG_GERMAN} \
    "Vim-Konfigurationsdatei entfernen"
LangString str_desc_rm_rc           ${LANG_GERMAN} \
    "Vim-Konfiguration $vim_install_root\_vimrc entfernen. \
     �berspringen, um die Konfigurationsdatei zu behalten."


##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_too_many_ver  ${LANG_GERMAN} \
    "$vim_old_ver_count Vim-Versionen auf diesem System gefunden..$\r$\n\
     Dieser Installer kann maximal ${VIM_MAX_OLD_VER} Versionen \
     handhaben.$\r$\n\
     Bitte alte Versionen entfernen und noch einmal probieren."

LangString str_msg_invalid_root  ${LANG_GERMAN} \
    "Nicht g�ltiges Installationsverzeichnis: $vim_install_root!$\r$\n\
     Der Pfad muss auf $\"vim$\" enden."

LangString str_msg_bin_mismatch  ${LANG_GERMAN} \
    "Pfaddiskrepanz!$\r$\n$\r$\n\
     Erwarte Anwendungsverzeichnis $\"$vim_bin_path$\",$\r$\n\
     aber fand Anwendungpfad $\"$INSTDIR$\" vor."

LangString str_msg_vim_running   ${LANG_GERMAN} \
    "Laufender Vim-Prozess erkannt.$\r$\n\
     Bitte alle laufenden Vim-Prozesse vor dem Fortfahren beenden."

LangString str_msg_register_ole  ${LANG_GERMAN} \
    "Versuche OLE-Registrierung durchzuf�hren."

LangString str_msg_unreg_ole     ${LANG_GERMAN} \
    "Versuche OLE-Registrierung zu l�schen."

LangString str_msg_rm_start      ${LANG_GERMAN} \
    "Deinstalliere die folgende Version:"

LangString str_msg_rm_fail       ${LANG_GERMAN} \
    "Deinstallation der Version fehlgeschlagen:"

LangString str_msg_no_rm_key     ${LANG_GERMAN} \
    "Deinstallationsschl�ssel in der Registrierungsdatenbank nicht gefunden."

LangString str_msg_no_rm_reg     ${LANG_GERMAN} \
    "Kein Uninstaller in der Registrierungsdatenbank gefunden."

LangString str_msg_no_rm_exe     ${LANG_GERMAN} \
    "Kein Zugriff auf den Uninstaller."

LangString str_msg_rm_copy_fail  ${LANG_GERMAN} \
    "Fehler beim Kopieren des Uninstallers in ein tempor�res Verzeichnis."

LangString str_msg_rm_run_fail   ${LANG_GERMAN} \
    "Fehler beim Aufruf des Uninstallers."

LangString str_msg_abort_install ${LANG_GERMAN} \
    "Installation wird abgebrochen."

LangString str_msg_install_fail  ${LANG_GERMAN} \
    "Installation fehlerhaft beendet."

LangString str_msg_rm_exe_fail   ${LANG_GERMAN} \
    "Einige Dateien im Pfad $vim_bin_path konnten nicht gel�scht werden!$\r$\n\
     Diese Dateien m�ssen manuell gel�scht werden."

LangString str_msg_rm_root_fail  ${LANG_GERMAN} \
    "Achtung: Kann Verzeichnis $\"$vim_install_root$\" nicht entfernen, \
     weil es nicht leer ist!"
