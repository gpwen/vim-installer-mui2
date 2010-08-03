# vi:set ts=8 sts=4 sw=4:
#
# lang-simp-chinese.nsi: Simplified Chinese language strings for gvim Windows
# installer, fileencoding should be big5.
#
# Author : Guopeng Wen

!insertmacro MUI_LANGUAGE "TradChinese"


##############################################################################
# MUI Configuration Strings
##############################################################################

LangString str_DestFolder          ${LANG_TRADCHINESE} \
    "安裝路徑 (必須以 vim 結尾)"

LangString str_ShowReadme          ${LANG_TRADCHINESE} \
    "安裝完成後顯示 README 檔案"

# Install types:
LangString str_TypeTypical         ${LANG_TRADCHINESE} \
    "典型安裝"

LangString str_TypeMinimal         ${LANG_TRADCHINESE} \
    "最小安裝"

LangString str_TypeFull            ${LANG_TRADCHINESE} \
    "完全安裝"


##############################################################################
# Section Titles
##############################################################################

LangString str_SectionExe          ${LANG_TRADCHINESE} \
    "安裝 Vim 圖形界面程式"

LangString str_SectionConsole      ${LANG_TRADCHINESE} \
    "安裝 Vim 命令行程式"

LangString str_SectionBatch        ${LANG_TRADCHINESE} \
    "安裝批次檔案"

LangString str_SectionDesktop      ${LANG_TRADCHINESE} \
    "安裝桌面捷徑"

LangString str_SectionStartMenu    ${LANG_TRADCHINESE} \
    "安裝“開始”菜單中的啟動組"

LangString str_SectionQuickLaunch  ${LANG_TRADCHINESE} \
    "安裝快速啟動"

LangString str_SectionEditWith     ${LANG_TRADCHINESE} \
    "安裝快捷選單"

LangString str_SectionVimRC        ${LANG_TRADCHINESE} \
    "創建默認設定檔"

LangString str_SectionPluginHome   ${LANG_TRADCHINESE} \
    "創建插件目錄"

LangString str_SectionPluginVim    ${LANG_TRADCHINESE} \
    "創建共享插件目錄"

LangString str_SectionVisVim       ${LANG_TRADCHINESE} \
    "安裝 VisVim 插件"

LangString str_SectionNLS          ${LANG_TRADCHINESE} \
    "安裝本地語言支持"

LangString str_UnsectionRegister   ${LANG_TRADCHINESE} \
    "移除 Vim 系統設定"

LangString str_UnsectionExe        ${LANG_TRADCHINESE} \
    "移除 Vim 程式及腳本"

LangString str_UnsectionPlugin     ${LANG_TRADCHINESE} \
    "移除 Vim 插件目錄 $vim_plugin_path"

LangString str_UnsectionRoot       ${LANG_TRADCHINESE} \
    "移除 Vim 安裝目錄 $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_DescExe         ${LANG_TRADCHINESE} \
    "安裝 Vim 圖形界面程式及腳本。此為必選安裝。"

LangString str_DescConsole     ${LANG_TRADCHINESE} \
    "安裝 Vim 命令行程式 (vim.exe)。該程式在控制臺窗口中運行。"

LangString str_DescBatch       ${LANG_TRADCHINESE} \
    "為 Vim 的各種變體創建批次檔，以便在命令行下啟動 Vim。"

LangString str_DescDesktop     ${LANG_TRADCHINESE} \
    "在桌面為 Vim 安裝若干捷徑，以方便啟動 Vim。"

LangString str_DescStartmenu   ${LANG_TRADCHINESE} \
    "在“開始”菜單中創建 Vim 啟動組。適用于 Windows 95 及以上版本。"

LangString str_DescQuicklaunch ${LANG_TRADCHINESE} \
    "安裝 Vim 快速啟動項。"

LangString str_DescEditwith    ${LANG_TRADCHINESE} \
    "在“打開方式”快捷選單中添加 Vim 項。"

LangString str_DescVimRC       ${LANG_TRADCHINESE} \
    "如果安裝路徑下沒有 _vimrc 檔案，就創建該檔案的默認版本。_vimrc 檔案用于設定 Vim 選項。"

LangString str_DescPluginHome  ${LANG_TRADCHINESE} \
    "該選項用于在 HOME 路徑下創建(空的)插件目錄結構。若未設定 HOME 路徑，會在安裝路徑下創建該目錄結構，這將影響電腦上所有用戶。插件目錄用于安裝 Vim 的擴展插件，只要將相應的檔案復制到相關的子目錄中即可。"

LangString str_DescPluginVim   ${LANG_TRADCHINESE} \
    "該選項用于在 Vim 安裝路徑創建(空的)插件目錄結構，電腦上所有用戶都能使用安裝在該目錄里的擴展插件。插件目錄用于安裝 Vim 的擴展插件，只要將相應的檔案復制到相關的子目錄中即可。"

LangString str_DescVisVim      ${LANG_TRADCHINESE} \
    "VisVim 是用于與微軟 Microsoft Visual Studio 軟體進行整合的插件。"

LangString str_DescNLS         ${LANG_TRADCHINESE} \
    "安裝用于支持本地語言的檔案。"

LangString str_DescUnregister  ${LANG_TRADCHINESE} \
    "移除與 Vim 相關的系統設定。"

LangString str_DescRmExe       ${LANG_TRADCHINESE} \
    "移除所有的 Vim 程式及腳本。"

LangString str_DescnRmPlugin   ${LANG_TRADCHINESE} \
    "移除您的 Vim  插件目錄 $vim_plugin_path。請注意該目錄下所有檔案都會被移除。若您在該目錄下有希望保留的檔案，切勿移除該項。"

LangString str_DescnRmRoot     ${LANG_TRADCHINESE} \
    "移除 Vim 安裝目錄 $vim_install_root。請注意該目錄下可能用您的 Vim 設定檔。如果您需要保留該目錄下您修訂過的設定檔，切勿移除該項。"


##############################################################################
# Messages
##############################################################################

LangString str_MsgInstallFail  ${LANG_TRADCHINESE} \
    "安裝失敗。預祝下次好運。"

LangString str_MsgUnregister   ${LANG_TRADCHINESE} \
    "正移除與 Vim 相關的系統設定 ..."

LangString str_MsgRmExe        ${LANG_TRADCHINESE} \
    "正移除 Vim 程式及腳本 ..."

LangString str_MsgRmExeFail    ${LANG_TRADCHINESE} \
    "目錄 $0 下有部分檔案未能移除！$\n您必須手工移除該目錄。"

LangString str_MsgRmPlugin     ${LANG_TRADCHINESE} \
    "正移除 Vim 插件目錄 $vim_plugin_path ..."

LangString str_MsgRmRoot       ${LANG_TRADCHINESE} \
    "正移除 Vim 安裝目錄 $vim_install_root ..."

LangString str_MsgInvalidRoot  ${LANG_TRADCHINESE} \
    "安裝路徑 $vim_install_root 無效！$\n卸載程式將終止。"
