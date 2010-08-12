# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# tradchinese.nsi: Traditional Chinese language strings for gvim NSIS
# installer, fileencoding should be big5.
#
# Author : Guopeng Wen

!insertmacro MUI_LANGUAGE "TradChinese"


##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

LangString str_dest_folder          ${LANG_TRADCHINESE} \
    "安裝資料夾 (必須以 vim 結尾)"

LangString str_show_readme          ${LANG_TRADCHINESE} \
    "安裝完成後顯示 README 檔案"

# Install types:
LangString str_type_typical         ${LANG_TRADCHINESE} \
    "典型安裝"

LangString str_type_minimal         ${LANG_TRADCHINESE} \
    "最小安裝"

LangString str_type_full            ${LANG_TRADCHINESE} \
    "完全安裝"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_section_old_ver      ${LANG_TRADCHINESE} \
    "移除"
LangString str_desc_old_ver         ${LANG_TRADCHINESE} \
    "移除閣下電腦上老版本的 Vim。"

LangString str_section_exe          ${LANG_TRADCHINESE} \
    "安裝 Vim 圖形界面程式"
LangString str_desc_exe             ${LANG_TRADCHINESE} \
    "安裝 Vim 圖形界面程式及腳本。此為必選安裝。"

LangString str_section_console      ${LANG_TRADCHINESE} \
    "安裝 Vim 命令行程式"
LangString str_desc_console         ${LANG_TRADCHINESE} \
    "安裝 Vim 命令行程式 (vim.exe)。該程式在控制臺窗口中運行。"

LangString str_section_batch        ${LANG_TRADCHINESE} \
    "安裝批次檔案"
LangString str_desc_batch           ${LANG_TRADCHINESE} \
    "為 Vim 的各種變體創建批次檔，以便在命令行下啟動 Vim。"

LangString str_section_desktop      ${LANG_TRADCHINESE} \
    "安裝桌面捷徑"
LangString str_desc_desktop         ${LANG_TRADCHINESE} \
    "在桌面為 Vim 安裝若干捷徑，以方便啟動 Vim。"

LangString str_section_start_menu   ${LANG_TRADCHINESE} \
    "安裝「開始」菜單中的啟動組"
LangString str_desc_start_menu      ${LANG_TRADCHINESE} \
    "在「開始」菜單中創建 Vim 啟動組。適用于 Windows 95 及以上版本。"

LangString str_section_quick_launch ${LANG_TRADCHINESE} \
    "安裝快速啟動"
LangString str_desc_quick_launch    ${LANG_TRADCHINESE} \
    "安裝 Vim 快速啟動項。"

LangString str_section_edit_with    ${LANG_TRADCHINESE} \
    "安裝快捷選單"
LangString str_desc_edit_with       ${LANG_TRADCHINESE} \
    "在「打開方式」快捷選單中添加 Vim 項。"

LangString str_section_vim_rc       ${LANG_TRADCHINESE} \
    "創建默認設定檔"
LangString str_desc_vim_rc          ${LANG_TRADCHINESE} \
    "在安裝資料夾下沒有 _vimrc 檔案的情況下，創建該檔案的默認版本。_vimrc \
     檔案用于設定 Vim 選項。"

LangString str_section_plugin_home  ${LANG_TRADCHINESE} \
    "創建插件資料夾"
LangString str_desc_plugin_home     ${LANG_TRADCHINESE} \
    "在 HOME 資料夾下創建(空的)插件資料夾結構。若閣下未設定 HOME 資料夾，會\
     在安裝資料夾下創建該資料夾結構。插件資料夾用于安裝 Vim 的擴展插件，只\
     要將相應的檔案復制到相關的子資料夾中即可。"

LangString str_section_plugin_vim   ${LANG_TRADCHINESE} \
    "創建共享插件資料夾"
LangString str_desc_plugin_vim      ${LANG_TRADCHINESE} \
    "在 Vim 安裝資料夾下創建(空的)插件資料夾結構，電腦上所有用戶都能使用安裝\
     在該資料夾里的擴展插件。插件資料夾用于安裝 Vim 的擴展插件，只要將相應的\
     檔案復制到相關的子資料夾中即可。"

LangString str_section_vis_vim      ${LANG_TRADCHINESE} \
    "安裝 VisVim 插件"
LangString str_desc_vis_vim         ${LANG_TRADCHINESE} \
    "VisVim 是用于與微軟 Microsoft Visual Studio 軟體進行整合的插件。"

LangString str_section_nls          ${LANG_TRADCHINESE} \
    "安裝本地語言支持"
LangString str_desc_nls             ${LANG_TRADCHINESE} \
    "安裝用于支持本地語言的檔案。"

LangString str_unsection_register   ${LANG_TRADCHINESE} \
    "移除 Vim 系統設定"
LangString str_desc_unregister      ${LANG_TRADCHINESE} \
    "移除與 Vim 相關的系統設定。"

LangString str_unsection_exe        ${LANG_TRADCHINESE} \
    "移除 Vim 程式及腳本"
LangString str_desc_rm_exe          ${LANG_TRADCHINESE} \
    "移除所有的 Vim 程式及腳本。"

LangString str_unsection_plugin     ${LANG_TRADCHINESE} \
    "移除 Vim 插件資料夾 $vim_plugin_path"
LangString str_desc_rm_plugin       ${LANG_TRADCHINESE} \
    "移除您的 Vim 插件資料夾 $vim_plugin_path。$\r$\n$\r$\n\
     請注意該資料夾下所有檔案都會被移除。若閣下在該資料夾下有希望保留的檔案，\
     切勿勾選該項！"

LangString str_unsection_root       ${LANG_TRADCHINESE} \
    "移除 Vim 安裝資料夾 $vim_install_root"
LangString str_desc_rm_root         ${LANG_TRADCHINESE} \
    "移除 Vim 安裝資料夾 $vim_install_root。請注意該資料夾下可能有閣下的 Vim \
     設定檔。若閣下需要保留該資料夾下被修訂過的設定檔，切勿勾選該項。"


##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_vim_running   ${LANG_TRADCHINESE} \
    "閣下的電腦上尚有正在運行之 Vim，$\r$\n\
     煩請閣下在執行后續步驟前將其全部退出。"

LangString str_msg_rm_start      ${LANG_TRADCHINESE} \
    "正移除如下版本："

LangString str_msg_rm_fail       ${LANG_TRADCHINESE} \
    "以下版本移除失敗："

LangString str_msg_no_rm_key     ${LANG_TRADCHINESE} \
    "找不到反安裝程式的登錄檔入口。"

LangString str_msg_no_rm_reg     ${LANG_TRADCHINESE} \
    "在登錄檔中未找到反安裝程式路徑。"

LangString str_msg_no_rm_exe     ${LANG_TRADCHINESE} \
    "找不到反安裝程式。"

LangString str_msg_rm_copy_fail  ${LANG_TRADCHINESE} \
    "無法將法將反安裝程式复制到臨時目錄。"

LangString str_msg_rm_run_fail   ${LANG_TRADCHINESE} \
    "執行反安裝程式失敗。"

LangString str_msg_abort_install ${LANG_TRADCHINESE} \
    "安裝程式將退出。"

LangString str_msg_install_fail  ${LANG_TRADCHINESE} \
    "安裝失敗。預祝下次好運。"

LangString str_msg_rm_exe_fail   ${LANG_TRADCHINESE} \
    "資料夾 $0 下有部分檔案未能移除！$\r$\n閣下必須手工移除該資料夾。"

LangString str_msg_invalid_root  ${LANG_TRADCHINESE} \
    "安裝資料夾 $vim_install_root 無效！$\r$\n卸載程式將終止。"
