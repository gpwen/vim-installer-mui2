# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# italian.nsi : Italian language strings for gvim NSIS installer.
#
# Locale ID    : 1040
# Locale Name  : it
# fileencoding : latin1
# Author       : Antonio Colombo

!include "script\helper_util.nsh"
${VimAddLanguage} "Italian" "it"


##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

LangString str_dest_folder          ${LANG_ITALIAN} \
    "Cartella di installazione (deve finire con $\"vim$\")"

LangString str_show_readme          ${LANG_ITALIAN} \
    "Visualizza README al termine dell'installazione"

# Install types:
LangString str_type_typical         ${LANG_ITALIAN} \
    "Tipica"

LangString str_type_minimal         ${LANG_ITALIAN} \
    "Minima"

LangString str_type_full            ${LANG_ITALIAN} \
    "Completa"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_group_old_ver        ${LANG_ITALIAN} \
    "Disinstalla versione/i esistente/i"
LangString str_desc_old_ver         ${LANG_ITALIAN} \
    "Disinstalla versione/i esistente/i di Vim dal vostro sistema."

LangString str_section_exe          ${LANG_ITALIAN} \
    "Vim GUI (gvim.exe per Windows)"
LangString str_desc_exe             ${LANG_ITALIAN} \
    "Vim GUI programmi e file di supporto.  Questa componente � indispensabile."

LangString str_section_console      ${LANG_ITALIAN} \
    "Vim console (vim.exe per MS-DOS)"
LangString str_desc_console         ${LANG_ITALIAN} \
    "Versione console di Vim (vim.exe)."

LangString str_section_batch        ${LANG_ITALIAN} \
    "Crea file di invocazione (MS-DOS) .bat"
LangString str_desc_batch           ${LANG_ITALIAN} \
    "Crea file di invocazione .bat per varianti di Vim nella directory \
     di Windows, da utilizzare da linea di comando (MS-DOS)."

LangString str_group_icons          ${LANG_ITALIAN} \
    "Crea icone per Vim"
LangString str_desc_icons           ${LANG_ITALIAN} \
    "Crea icone per Vim in vari posti, per rendere facile l'accesso."

LangString str_section_desktop      ${LANG_ITALIAN} \
    "Sul Desktop"
LangString str_desc_desktop         ${LANG_ITALIAN} \
    "Crea icone per programma gvim sul desktop."

LangString str_section_start_menu   ${LANG_ITALIAN} \
    "Nella cartella del men� START"
LangString str_desc_start_menu      ${LANG_ITALIAN} \
    "Aggiungi Vim alle cartelle del men� START.  \
     Disponibile solo da Windows 95 in avanti."

LangString str_section_quick_launch ${LANG_ITALIAN} \
    "Nella barra di Avvio Veloce"
LangString str_desc_quick_launch    ${LANG_ITALIAN} \
    "Aggiungi un puntatore a Vim nella barra di Avvio Veloce."

LangString str_group_edit_with      ${LANG_ITALIAN} \
    "Aggiungi Vim al Men� Contestuale"
LangString str_desc_edit_with       ${LANG_ITALIAN} \
    "Aggiungi Vim alla lista contestuale $\"Apri con...$\"."

LangString str_section_edit_with32  ${LANG_ITALIAN} \
    "Versione a 32-bit"
LangString str_desc_edit_with32     ${LANG_ITALIAN} \
    "Aggiungi Vim alla lista contestuale $\"Apri con...$\" \
     per applicazioni a 32-bit."

LangString str_section_edit_with64  ${LANG_ITALIAN} \
    "Versione a 64-bit"
LangString str_desc_edit_with64     ${LANG_ITALIAN} \
    "Aggiungi Vim alla lista contestuale $\"Apri con...$\" \
     per applicazioni a 64-bit."

LangString str_section_vim_rc       ${LANG_ITALIAN} \
    "Crea Configurazione di default"
LangString str_desc_vim_rc          ${LANG_ITALIAN} \
    "Crea file configurazione di default (_vimrc) se non ne \
     esiste gi� uno."

LangString str_group_plugin         ${LANG_ITALIAN} \
    "Crea Directory per Plugin"
LangString str_desc_plugin          ${LANG_ITALIAN} \
    "Crea Directory per Plugin.  Servono per aggiungere funzionalit� \
     a Vim aggiungendo file a una di queste directory."

LangString str_section_plugin_home  ${LANG_ITALIAN} \
    "Privato"
LangString str_desc_plugin_home     ${LANG_ITALIAN} \
    "Crea Directory Plugin in HOME (se definita) o nella \
     directory di installazione di Vim."

LangString str_section_plugin_vim   ${LANG_ITALIAN} \
    "Condiviso"
LangString str_desc_plugin_vim      ${LANG_ITALIAN} \
    "Crea Directory Plugin nella directory di installazione di Vim \
     per uso da parte di tutti gli utenti di questo sistema."

LangString str_section_vis_vim      ${LANG_ITALIAN} \
    "Estensione VisVim"
LangString str_desc_vis_vim         ${LANG_ITALIAN} \
    "Estensione VisVim per integrazione con Microsoft Visual Studio."

LangString str_section_nls          ${LANG_ITALIAN} \
    "Supporto Multilingue (NLS)"
LangString str_desc_nls             ${LANG_ITALIAN} \
    "Installa file per supportare messaggi in diverse lingue."

LangString str_unsection_register   ${LANG_ITALIAN} \
    "Togli Vim dal Registry"
LangString str_desc_unregister      ${LANG_ITALIAN} \
    "Togli Vim dal Registry di configurazione sistema."

LangString str_unsection_exe        ${LANG_ITALIAN} \
    "Cancella programmi/file_ausiliari Vim"
LangString str_desc_rm_exe          ${LANG_ITALIAN} \
    "Cancella tutti i programmi/file_ausiliari di Vim."

LangString str_unsection_rc         ${LANG_ITALIAN} \
    "Cancella file di configurazione di Vim"
LangString str_desc_rm_rc           ${LANG_ITALIAN} \
    "Cancella file di configurazione di Vim $vim_install_root\_vimrc. \
     Da saltare se avete personalizzato il file di configurazione."


##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_too_many_ver  ${LANG_ITALIAN} \
    "Trovate $vim_old_ver_count versioni di Vim sul vostro sistema.$\r$\n\
     Questo programma di installazione pu� gestirne solo \
     ${VIM_MAX_OLD_VER}.$\r$\n\
     Disinstallate qualche versione precedente e ricominciate."

LangString str_msg_invalid_root  ${LANG_ITALIAN} \
    "Nome di directory di installazione non valida: $vim_install_root!$\r$\n\
     Dovrebbe terminare con $\"vim$\"."

LangString str_msg_bin_mismatch  ${LANG_ITALIAN} \
    "Incongruenza di installazione!$\r$\n$\r$\n\
     Cartella di installazione dev'essere $\"$vim_bin_path$\",$\r$\n\
     ma il sistema segnala invece $\"$INSTDIR$\"."

LangString str_msg_vim_running   ${LANG_ITALIAN} \
    "Vim ancora in esecuzione sul vostro sistema.$\r$\n\
     Chiudete tutte le sessioni attive di Vim per continuare."

LangString str_msg_register_ole  ${LANG_ITALIAN} \
    "Tentativo di registrazione di Vim con OLE. \
     Non ci sono messaggi che indicano se ha funzionato o no."

LangString str_msg_unreg_ole     ${LANG_ITALIAN} \
    "Tentativo di togliere da Registry  Vim con OLE. \
     Non ci sono messaggi che indicano se ha funzionato o no."

LangString str_msg_rm_start      ${LANG_ITALIAN} \
    "Disinstallazione delle seguenti versioni:"

LangString str_msg_rm_fail       ${LANG_ITALIAN} \
    "Disinstallazione non riuscita per la seguente versione:"

LangString str_msg_no_rm_key     ${LANG_ITALIAN} \
    "Non riesco a trovare chiave di disinstallazione nel Registry."

LangString str_msg_no_rm_reg     ${LANG_ITALIAN} \
    "Non riesco a trovare programma disinstallazione nel Registry."

LangString str_msg_no_rm_exe     ${LANG_ITALIAN} \
    "Non riesco a utilizzare programma disinstallazione."

LangString str_msg_rm_copy_fail  ${LANG_ITALIAN} \
    "Non riesco a copiare programma disinstallazione a una \
     directory temporanea."

LangString str_msg_rm_run_fail   ${LANG_ITALIAN} \
    "Non riesco a eseguire programma disinstallazione."

LangString str_msg_abort_install ${LANG_ITALIAN} \
    "Il programma di disinstallazione verr� chiuso senza aver fatto nulla."

LangString str_msg_install_fail  ${LANG_ITALIAN} \
    "Installazione non riuscita. Miglior fortuna alla prossima!"

LangString str_msg_rm_exe_fail   ${LANG_ITALIAN} \
    "Alcuni file in $vim_bin_path non sono stati cancellati!$\r$\n\
     Dovreste cancellarli voi stessi."

LangString str_msg_rm_root_fail  ${LANG_ITALIAN} \
    "AVVISO: Non posso cancellare $\"$vim_install_root$\", non � vuota!"
