# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# simpchinese.nsi: Simplified Chinese language strings for gvim NSIS
# installer.
#
# Locale ID    : 2052
# fileencoding : cp936
# Author       : Guopeng Wen

!include "script\helper_util.nsh"
${VimAddLanguage} "SimpChinese" "zh_CN"


##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

LangString str_dest_folder          ${LANG_SIMPCHINESE} \
    "��װ·�� (������ vim ��β)"

LangString str_show_readme          ${LANG_SIMPCHINESE} \
    "��װ��ɺ���ʾ README �ļ�"

# Install types:
LangString str_type_typical         ${LANG_SIMPCHINESE} \
    "���Ͱ�װ"

LangString str_type_minimal         ${LANG_SIMPCHINESE} \
    "��С��װ"

LangString str_type_full            ${LANG_SIMPCHINESE} \
    "��ȫ��װ"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_group_old_ver        ${LANG_SIMPCHINESE} \
    "ж�ؾɰ汾"
LangString str_desc_old_ver         ${LANG_SIMPCHINESE} \
    "ж��ϵͳ�Ͼɰ汾�� Vim��"

LangString str_section_exe          ${LANG_SIMPCHINESE} \
    "��װ Vim ͼ�ν���"
LangString str_desc_exe             ${LANG_SIMPCHINESE} \
    "��װ Vim ͼ�ν��漰�ű�����Ϊ��ѡ��װ��"

LangString str_section_console      ${LANG_SIMPCHINESE} \
    "��װ Vim �����г���"
LangString str_desc_console         ${LANG_SIMPCHINESE} \
    "��װ Vim �����г��� (vim.exe)���ó����������д��������С�"

LangString str_section_batch        ${LANG_SIMPCHINESE} \
    "��װ�������ļ�"
LangString str_desc_batch           ${LANG_SIMPCHINESE} \
    "Ϊ Vim �ĸ��ֱ��崴������������Ա��������������� Vim��"

LangString str_group_icons          ${LANG_SIMPCHINESE} \
    "���� Vim ͼ��"
LangString str_desc_icons           ${LANG_SIMPCHINESE} \
    "Ϊ Vim ��������ͼ�꣬�Է���ʹ�� Vim��"

LangString str_section_desktop      ${LANG_SIMPCHINESE} \
    "��������"
LangString str_desc_desktop         ${LANG_SIMPCHINESE} \
    "��������Ϊ Vim ��������ͼ�꣬�Է������� Vim��"

LangString str_section_start_menu   ${LANG_SIMPCHINESE} \
    "�������˵��ĳ���˵���"
LangString str_desc_start_menu      ${LANG_SIMPCHINESE} \
    "�������˵��ĳ���˵������ Vim �顣������ Windows 95 �����ϰ汾��"

LangString str_section_quick_launch ${LANG_SIMPCHINESE} \
    "�ڿ���������������"
LangString str_desc_quick_launch    ${LANG_SIMPCHINESE} \
    "�ڿ�������������� Vim ͼ�ꡣ"

LangString str_group_edit_with      ${LANG_SIMPCHINESE} \
    "��װ��ݲ˵�"
LangString str_desc_edit_with       ${LANG_SIMPCHINESE} \
    "�� Vim ��ӵ����򿪷�ʽ����ݲ˵��С�"

LangString str_section_edit_with32  ${LANG_SIMPCHINESE} \
    "32 λ�汾"
LangString str_desc_edit_with32     ${LANG_SIMPCHINESE} \
    "�� Vim ��ӵ� 32 λ����ġ��򿪷�ʽ����ݲ˵��С�"

LangString str_section_edit_with64  ${LANG_SIMPCHINESE} \
    "64 λ�汾"
LangString str_desc_edit_with64     ${LANG_SIMPCHINESE} \
    "�� Vim ��ӵ� 64 λ����ġ��򿪷�ʽ����ݲ˵��С�"

LangString str_section_vim_rc       ${LANG_SIMPCHINESE} \
    "����ȱʡ�����ļ�"
LangString str_desc_vim_rc          ${LANG_SIMPCHINESE} \
    "�ڰ�װĿ¼������ȱʡ�� Vim �����ļ�(_vimrc)��\
     ������ļ��Ѿ����ڣ����Թ����"

LangString str_group_plugin         ${LANG_SIMPCHINESE} \
    "�������Ŀ¼"
LangString str_desc_plugin          ${LANG_SIMPCHINESE} \
    "����(�յ�)���Ŀ¼�ṹ�����Ŀ¼���ڰ�װ Vim ��չ�����\
     ֻҪ���ļ����Ƶ���ص���Ŀ¼�м��ɡ�"

LangString str_section_plugin_home  ${LANG_SIMPCHINESE} \
    "˽�в��Ŀ¼"
LangString str_desc_plugin_home     ${LANG_SIMPCHINESE} \
    "�� HOME Ŀ¼�´���(�յ�)���Ŀ¼�ṹ������δ���� HOME Ŀ¼�����ڰ�װ\
     Ŀ¼�´�����Ŀ¼�ṹ��"

LangString str_section_plugin_vim   ${LANG_SIMPCHINESE} \
    "�������Ŀ¼"
LangString str_desc_plugin_vim      ${LANG_SIMPCHINESE} \
    "�� Vim ��װĿ¼�´���(�յ�)���Ŀ¼�ṹ��ϵͳ�������û�����ʹ�ð�װ��\
     ��Ŀ¼�µ���չ�����"

LangString str_section_vis_vim      ${LANG_SIMPCHINESE} \
    "��װ VisVim ���"
LangString str_desc_vis_vim         ${LANG_SIMPCHINESE} \
    "��װ������΢�� Microsoft Visual Studio ���м��ɵ� VisVim �����"

LangString str_section_nls          ${LANG_SIMPCHINESE} \
    "��װ������֧��"
LangString str_desc_nls             ${LANG_SIMPCHINESE} \
    "��װ���ڶ�����֧�ֵ��ļ���"

LangString str_unsection_register   ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ϵͳ����"
LangString str_desc_unregister      ${LANG_SIMPCHINESE} \
    "ɾ���� Vim ��ص�ϵͳ���á�"

LangString str_unsection_exe        ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ִ���ļ��Լ��ű�"
LangString str_desc_rm_exe          ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ������ִ���ļ����ű���"


##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_too_many_ver  ${LANG_SIMPCHINESE} \
    "����ϵͳ�ϰ�װ�� $vim_old_ver_count ����ͬ�汾�� Vim��$\r$\n\
     ������װ�������ֻ�ܴ��� ${VIM_MAX_OLD_VER} ���汾��$\r$\n\
     �����ֹ�ɾ��һЩ�ɰ汾�Ժ������б���װ����"

LangString str_msg_invalid_root  ${LANG_SIMPCHINESE} \
    "��װ·����$vim_install_root����Ч��$\r$\n\
     ��·�������� vim ��β��"

LangString str_msg_bin_mismatch  ${LANG_SIMPCHINESE} \
    "Vim ִ�г���װ·���쳣��$\r$\n$\r$\n\
     �ð汾 Vim ��ִ�г���װ·��Ӧ���ǡ�$vim_bin_path��,$\r$\n\
     ��ϵͳȴָʾ��·��Ϊ��$INSTDIR����"

LangString str_msg_vim_running   ${LANG_SIMPCHINESE} \
    "����ϵͳ������ Vim �����У�$\r$\n\
     ������ִ�к�������ǰ�˳���Щ Vim��"

LangString str_msg_register_ole  ${LANG_SIMPCHINESE} \
    "��ͼע�� Vim OLE ����������ע�����۳ɹ���񶼲�����ʾ��һ������Ϣ��"

LangString str_msg_unreg_ole     ${LANG_SIMPCHINESE} \
    "��ͼע�� Vim OLE ����������ע�����۳ɹ���񶼲�����ʾ��һ������Ϣ��"

LangString str_msg_rm_start      ${LANG_SIMPCHINESE} \
    "��ʼж�����°汾��"

LangString str_msg_rm_fail       ${LANG_SIMPCHINESE} \
    "���°汾ж��ʧ�ܣ�"

LangString str_msg_no_rm_key     ${LANG_SIMPCHINESE} \
    "�Ҳ���ж�س����ע������"

LangString str_msg_no_rm_reg     ${LANG_SIMPCHINESE} \
    "��ע�����δ�ҵ�ж�س���·����"

LangString str_msg_no_rm_exe     ${LANG_SIMPCHINESE} \
    "�Ҳ���ж�س���"

LangString str_msg_rm_copy_fail  ${LANG_SIMPCHINESE} \
    "�޷���ж�س����Ƶ���ʱĿ¼��"

LangString str_msg_rm_run_fail   ${LANG_SIMPCHINESE} \
    "ִ��ж�س���ʧ�ܡ�"

LangString str_msg_abort_install ${LANG_SIMPCHINESE} \
    "��װ�����˳���"

LangString str_msg_install_fail  ${LANG_SIMPCHINESE} \
    "��װʧ�ܡ�ף���´κ��ˡ�"

LangString str_msg_rm_exe_fail   ${LANG_SIMPCHINESE} \
    "Ŀ¼��$vim_bin_path�����в����ļ�ɾ��ʧ�ܣ�$\r$\n\
     ��ֻ���ֹ�ɾ����Ŀ¼��"

LangString str_msg_rm_root_fail  ${LANG_SIMPCHINESE} \
    "���棺�޷�ɾ�� Vim ��װĿ¼��$vim_install_root����\
     ��Ŀ¼�����������ļ���"
