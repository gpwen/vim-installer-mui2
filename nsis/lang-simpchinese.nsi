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

LangString str_dest_folder          ${LANG_SIMPCHINESE} \
    "安装路径 (必须以 vim 结尾)"

LangString str_show_readme          ${LANG_SIMPCHINESE} \
    "安装完成后显示 README 文件"

# Install types:
LangString str_type_typical         ${LANG_SIMPCHINESE} \
    "典型安装"

LangString str_type_minimal         ${LANG_SIMPCHINESE} \
    "最小安装"

LangString str_type_full            ${LANG_SIMPCHINESE} \
    "完全安装"


##############################################################################
# Section Titles
##############################################################################

LangString str_section_exe          ${LANG_SIMPCHINESE} \
    "安装 Vim 图形界面"

LangString str_section_console      ${LANG_SIMPCHINESE} \
    "安装 Vim 命令行程序"

LangString str_section_batch        ${LANG_SIMPCHINESE} \
    "安装批处理文件"

LangString str_section_desktop      ${LANG_SIMPCHINESE} \
    "安装桌面快捷方式"

LangString str_section_start_menu   ${LANG_SIMPCHINESE} \
    "安装启动菜单项"

LangString str_section_quick_launch ${LANG_SIMPCHINESE} \
    "安装快速启动"

LangString str_section_edit_with    ${LANG_SIMPCHINESE} \
    "安装快捷菜单"

LangString str_section_vim_rc       ${LANG_SIMPCHINESE} \
    "创建缺省配置文件"

LangString str_section_plugin_home  ${LANG_SIMPCHINESE} \
    "创建插件目录"

LangString str_section_plugin_vim   ${LANG_SIMPCHINESE} \
    "创建公共插件目录"

LangString str_section_vis_vim      ${LANG_SIMPCHINESE} \
    "安装 VisVim 插件"

LangString str_section_nls          ${LANG_SIMPCHINESE} \
    "安装多语言支持"

LangString str_unsection_register   ${LANG_SIMPCHINESE} \
    "删除 Vim 系统配置"

LangString str_unsection_exe        ${LANG_SIMPCHINESE} \
    "删除 Vim 执行文件以及脚本"

LangString str_unsection_plugin     ${LANG_SIMPCHINESE} \
    "删除 Vim 插件目录 $vim_plugin_path"

LangString str_unsection_root       ${LANG_SIMPCHINESE} \
    "删除 Vim 安装目录 $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_desc_exe          ${LANG_SIMPCHINESE} \
    "安装 Vim 图形界面及脚本。此为必选安装。"

LangString str_desc_console      ${LANG_SIMPCHINESE} \
    "安装 Vim 命令行程序 (vim.exe)。该程序在命令行窗口中运行。"

LangString str_desc_batch        ${LANG_SIMPCHINESE} \
    "为 Vim 的各种变体创建批处理程序，以便在命令行下运行 Vim。"

LangString str_desc_desktop      ${LANG_SIMPCHINESE} \
    "在桌面上为 Vim 创建若干快捷方式，以方便启动 Vim。"

LangString str_desc_start_menu   ${LANG_SIMPCHINESE} \
    "在启动菜单中添加 Vim 组。适用于 Windows 95 及以上版本。"

LangString str_desc_quick_launch ${LANG_SIMPCHINESE} \
    "在快速启动条上添加 Vim。"

LangString str_desc_edit_with    ${LANG_SIMPCHINESE} \
    "将 Vim 添加到“打开方式”快捷菜单中。"

LangString str_desc_vim_rc       ${LANG_SIMPCHINESE} \
    "在安装目录下没有 _vimrc 文件的情况下，生成该文件的缺省版本。_vimrc \
     文件是用于设置 Vim 选项的配置文件。"

LangString str_desc_plugin_home  ${LANG_SIMPCHINESE} \
    "在 HOME 目录下创建(空的)插件目录结构。若您未设置 HOME 目录，会在安装\
     目录下创建该目录结构，这将影响系统上所有用户。插件目录用于安\
     装 Vim 扩展插件，只要将文件复制到相关的子目录中即可。"

LangString str_desc_plugin_vim   ${LANG_SIMPCHINESE} \
    "在 Vim 安装目录下创建(空的)插件目录结构，系统上所有用户都能使用安装在\
     该目录下的扩展插件。插件目录用于安装 Vim 扩展插件，只要将文件复制到\
     相关的子目录中即可。"

LangString str_desc_vis_vim      ${LANG_SIMPCHINESE} \
    "用于与微软 Microsoft Visual Studio 进行集成的 VisVim 插件。"

LangString str_desc_nls          ${LANG_SIMPCHINESE} \
    "安装用于多语言支持的文件。"

LangString str_desc_unregister   ${LANG_SIMPCHINESE} \
    "删除和 Vim 相关的系统配置。"

LangString str_desc_rm_exe       ${LANG_SIMPCHINESE} \
    "删除 Vim 的所有执行文件及脚本。"

LangString str_desc_rm_plugin    ${LANG_SIMPCHINESE} \
    "删除您的 Vim  插件目录 $vim_plugin_path。$\r$\n$\r$\n\
     请注意该目录下所有文件都会被删除。如果您在该目录下有需要保留的文件，\
     切勿选择该项！"

LangString str_desc_rm_root      ${LANG_SIMPCHINESE} \
    "删除 Vim 安装目录 $vim_install_root。请注意该目录下可能有您的 Vim 配置\
     文件。如果你需要保留该目录下您修改过的配置文件，请勿选择该项。"


##############################################################################
# Messages
##############################################################################

LangString str_msg_vim_running   ${LANG_SIMPCHINESE} \
    "您的系统上仍有 Vim 在运行，$\r$\n\
     请您在执行后续步骤前退出这些 Vim。"

LangString str_msg_rm_start      ${LANG_SIMPCHINESE} \
    "开始卸载以下版本："

LangString str_msg_rm_fail       ${LANG_SIMPCHINESE} \
    "以下版本卸载失败："

LangString str_msg_no_rm_key     ${LANG_SIMPCHINESE} \
    "找不到卸载程序的注册表键。"

LangString str_msg_no_rm_reg     ${LANG_SIMPCHINESE} \
    "在注册表中未找到卸载程序路径。"

LangString str_msg_no_rm_exe     ${LANG_SIMPCHINESE} \
    "找不到卸载程序。"

LangString str_msg_rm_copy_fail  ${LANG_SIMPCHINESE} \
    "无法将卸载程序复制到临时目录。"

LangString str_msg_rm_run_fail   ${LANG_SIMPCHINESE} \
    "执行卸载程序失败。"

LangString str_msg_abort_install ${LANG_SIMPCHINESE} \
    "安装程序将退出。"

LangString str_msg_install_fail  ${LANG_SIMPCHINESE} \
    "安装失败。祝您下次好运。"

LangString str_msg_rm_exe_fail   ${LANG_SIMPCHINESE} \
    "目录 $0 下有部分文件删除失败！$\r$\n您必须手工删除该目录。"

LangString str_msg_invalid_root  ${LANG_SIMPCHINESE} \
    "安装路径 $vim_install_root 无效！$\r$\n卸载程序将终止。"
