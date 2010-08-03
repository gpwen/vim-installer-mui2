# vi:set ts=8 sts=4 sw=4:
#
# lang-simp-chinese.nsi: Simplified Chinese language strings for gvim Windows
# installer, fileencoding should be cp936.
#
# Author : Guopeng Wen

!insertmacro MUI_LANGUAGE "SimpChinese"


##############################################################################
# MUI Configuration Strings
##############################################################################

LangString str_DestFolder          ${LANG_SIMPCHINESE} \
    "安装路径 (必须以 vim 结尾)"

LangString str_ShowReadme          ${LANG_SIMPCHINESE} \
    "安装完成后显示 README 文件"

# Install types:
LangString str_TypeTypical         ${LANG_SIMPCHINESE} \
    "典型安装"

LangString str_TypeMinimal         ${LANG_SIMPCHINESE} \
    "最小安装"

LangString str_TypeFull            ${LANG_SIMPCHINESE} \
    "完全安装"


##############################################################################
# Section Titles
##############################################################################

LangString str_SectionExe          ${LANG_SIMPCHINESE} \
    "安装 Vim 图形界面"

LangString str_SectionConsole      ${LANG_SIMPCHINESE} \
    "安装 Vim 命令行程序"

LangString str_SectionBatch        ${LANG_SIMPCHINESE} \
    "安装批处理文件"

LangString str_SectionDesktop      ${LANG_SIMPCHINESE} \
    "安装桌面快捷方式"

LangString str_SectionStartMenu    ${LANG_SIMPCHINESE} \
    "安装启动菜单项"

LangString str_SectionQuickLaunch  ${LANG_SIMPCHINESE} \
    "安装快速启动"

LangString str_SectionEditWith     ${LANG_SIMPCHINESE} \
    "安装快捷菜单"

LangString str_SectionVimRC        ${LANG_SIMPCHINESE} \
    "创建缺省配置文件"

LangString str_SectionPluginHome   ${LANG_SIMPCHINESE} \
    "创建插件目录"

LangString str_SectionPluginVim    ${LANG_SIMPCHINESE} \
    "创建公共插件目录"

LangString str_SectionVisVim       ${LANG_SIMPCHINESE} \
    "安装 VisVim 插件"

LangString str_SectionNLS          ${LANG_SIMPCHINESE} \
    "安装多语言支持"

LangString str_UnsectionRegister   ${LANG_SIMPCHINESE} \
    "删除 Vim 系统配置"

LangString str_UnsectionExe        ${LANG_SIMPCHINESE} \
    "删除 Vim 执行文件以及脚本"

LangString str_UnsectionPlugin     ${LANG_SIMPCHINESE} \
    "删除 Vim 插件目录 $vim_plugin_path"

LangString str_UnsectionRoot       ${LANG_SIMPCHINESE} \
    "删除 Vim 安装目录 $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_DescExe         ${LANG_SIMPCHINESE} \
    "安装 Vim 图形界面及脚本。此为必选安装。"

LangString str_DescConsole     ${LANG_SIMPCHINESE} \
    "安装 Vim 命令行程序 (vim.exe)。该程序在命令行窗口中运行。"

LangString str_DescBatch       ${LANG_SIMPCHINESE} \
    "为 Vim 的各种变种创造批处理程序，以便在命令行下运行 Vim。"

LangString str_DescDesktop     ${LANG_SIMPCHINESE} \
    "在桌面为 Vim 安装创建若干快捷方式，以方便启动 Vim。"

LangString str_DescStartmenu   ${LANG_SIMPCHINESE} \
    "在启动菜单中添加 Vim 项目。适用于 Windows 95 及以上版本。"

LangString str_DescQuicklaunch ${LANG_SIMPCHINESE} \
    "在快速启动条上添加 Vim。"

LangString str_DescEditwith    ${LANG_SIMPCHINESE} \
    "将 Vim 添加到“打开方式”快捷菜单中。"

LangString str_DescVimRC       ${LANG_SIMPCHINESE} \
    "如果安装目录下没有 _vimrc 文件，就生成该文件的缺省版本。_vimrc 文件是用于设置 Vim 选项的配置文件。"

LangString str_DescPluginHome  ${LANG_SIMPCHINESE} \
    "该选项用于在 HOME 目录下创建(空的)插件目录结构。若未设置 HOME 目录，会在安装目录下创建该目录结构，这将影响系统上所有用户。插件目录用于安装 Vim 扩展插件，只要将文件复制到相关的子目录中即可。"

LangString str_DescPluginVim   ${LANG_SIMPCHINESE} \
    "该选项用于在 Vim 安装目录下创建(空的)插件目录结构，系统上所有用户都能使用安装在该目录下的扩展插件。插件目录用于安装 Vim 扩展插件，只要将文件复制到相关的子目录中即可。"

LangString str_DescVisVim      ${LANG_SIMPCHINESE} \
    "用于与微软 Microsoft Visual Studio 进行集成的 VisVim 插件。"

LangString str_DescNLS         ${LANG_SIMPCHINESE} \
    "安装用于多语言支持的文件。"

LangString str_DescUnregister  ${LANG_SIMPCHINESE} \
    "删除和 Vim 相关的系统配置。"

LangString str_DescRmExe       ${LANG_SIMPCHINESE} \
    "删除 Vim 的所有执行文件及脚本。"

LangString str_DescnRmPlugin   ${LANG_SIMPCHINESE} \
    "删除您的 Vim  插件目录 $vim_plugin_path。请注意该目录下所有文件都会被删除。如果您在该目录下有需要保留的文件，请勿选择该项。"

LangString str_DescnRmRoot     ${LANG_SIMPCHINESE} \
    "删除 Vim 安装目录 $vim_install_root。请注意该目录下可能有您的 Vim 配置文件。如果你需要保留该目录下您修改过的配置文件，请勿选择该项。"


##############################################################################
# Messages
##############################################################################

LangString str_MsgInstallFail  ${LANG_SIMPCHINESE} \
    "安装失败。祝您下次好运。"

LangString str_MsgUnregister   ${LANG_SIMPCHINESE} \
    "正在删除与 Vim 相关的系统配置 ..."

LangString str_MsgRmExe        ${LANG_SIMPCHINESE} \
    "正在删除 Vim 执行文件和脚本 ..."

LangString str_MsgRmExeFail    ${LANG_SIMPCHINESE} \
    "目录 $0 下有部分文件删除失败！$\n您必须手工删除该目录。"

LangString str_MsgRmPlugin     ${LANG_SIMPCHINESE} \
    "正在删除 Vim 插件目录 $vim_plugin_path ..."

LangString str_MsgRmRoot       ${LANG_SIMPCHINESE} \
    "正在删除 Vim 安装目录 $vim_install_root ..."

LangString str_MsgInvalidRoot  ${LANG_SIMPCHINESE} \
    "安装路径 $vim_install_root 无效！$\n卸载程序将终止。"
