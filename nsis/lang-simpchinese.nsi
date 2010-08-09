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
# Section Titles
##############################################################################

LangString str_section_exe          ${LANG_SIMPCHINESE} \
    "��װ Vim ͼ�ν���"

LangString str_section_console      ${LANG_SIMPCHINESE} \
    "��װ Vim �����г���"

LangString str_section_batch        ${LANG_SIMPCHINESE} \
    "��װ�������ļ�"

LangString str_section_desktop      ${LANG_SIMPCHINESE} \
    "��װ�����ݷ�ʽ"

LangString str_section_start_menu   ${LANG_SIMPCHINESE} \
    "��װ�����˵���"

LangString str_section_quick_launch ${LANG_SIMPCHINESE} \
    "��װ��������"

LangString str_section_edit_with    ${LANG_SIMPCHINESE} \
    "��װ��ݲ˵�"

LangString str_section_vim_rc       ${LANG_SIMPCHINESE} \
    "����ȱʡ�����ļ�"

LangString str_section_plugin_home  ${LANG_SIMPCHINESE} \
    "�������Ŀ¼"

LangString str_section_plugin_vim   ${LANG_SIMPCHINESE} \
    "�����������Ŀ¼"

LangString str_section_vis_vim      ${LANG_SIMPCHINESE} \
    "��װ VisVim ���"

LangString str_section_nls          ${LANG_SIMPCHINESE} \
    "��װ������֧��"

LangString str_unsection_register   ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ϵͳ����"

LangString str_unsection_exe        ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ִ���ļ��Լ��ű�"

LangString str_unsection_plugin     ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ���Ŀ¼ $vim_plugin_path"

LangString str_unsection_root       ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ��װĿ¼ $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_desc_exe          ${LANG_SIMPCHINESE} \
    "��װ Vim ͼ�ν��漰�ű�����Ϊ��ѡ��װ��"

LangString str_desc_console      ${LANG_SIMPCHINESE} \
    "��װ Vim �����г��� (vim.exe)���ó����������д��������С�"

LangString str_desc_batch        ${LANG_SIMPCHINESE} \
    "Ϊ Vim �ĸ��ֱ��崴������������Ա��������������� Vim��"

LangString str_desc_desktop      ${LANG_SIMPCHINESE} \
    "��������Ϊ Vim �������ɿ�ݷ�ʽ���Է������� Vim��"

LangString str_desc_start_menu   ${LANG_SIMPCHINESE} \
    "�������˵������ Vim �顣������ Windows 95 �����ϰ汾��"

LangString str_desc_quick_launch ${LANG_SIMPCHINESE} \
    "�ڿ�������������� Vim��"

LangString str_desc_edit_with    ${LANG_SIMPCHINESE} \
    "�� Vim ��ӵ����򿪷�ʽ����ݲ˵��С�"

LangString str_desc_vim_rc       ${LANG_SIMPCHINESE} \
    "�ڰ�װĿ¼��û�� _vimrc �ļ�������£����ɸ��ļ���ȱʡ�汾��_vimrc \
     �ļ����������� Vim ѡ��������ļ���"

LangString str_desc_plugin_home  ${LANG_SIMPCHINESE} \
    "�� HOME Ŀ¼�´���(�յ�)���Ŀ¼�ṹ������δ���� HOME Ŀ¼�����ڰ�װ\
     Ŀ¼�´�����Ŀ¼�ṹ���⽫Ӱ��ϵͳ�������û������Ŀ¼���ڰ�\
     װ Vim ��չ�����ֻҪ���ļ����Ƶ���ص���Ŀ¼�м��ɡ�"

LangString str_desc_plugin_vim   ${LANG_SIMPCHINESE} \
    "�� Vim ��װĿ¼�´���(�յ�)���Ŀ¼�ṹ��ϵͳ�������û�����ʹ�ð�װ��\
     ��Ŀ¼�µ���չ��������Ŀ¼���ڰ�װ Vim ��չ�����ֻҪ���ļ����Ƶ�\
     ��ص���Ŀ¼�м��ɡ�"

LangString str_desc_vis_vim      ${LANG_SIMPCHINESE} \
    "������΢�� Microsoft Visual Studio ���м��ɵ� VisVim �����"

LangString str_desc_nls          ${LANG_SIMPCHINESE} \
    "��װ���ڶ�����֧�ֵ��ļ���"

LangString str_desc_unregister   ${LANG_SIMPCHINESE} \
    "ɾ���� Vim ��ص�ϵͳ���á�"

LangString str_desc_rm_exe       ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ������ִ���ļ����ű���"

LangString str_desc_rm_plugin    ${LANG_SIMPCHINESE} \
    "ɾ������ Vim  ���Ŀ¼ $vim_plugin_path��$\r$\n$\r$\n\
     ��ע���Ŀ¼�������ļ����ᱻɾ����������ڸ�Ŀ¼������Ҫ�������ļ���\
     ����ѡ����"

LangString str_desc_rm_root      ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ��װĿ¼ $vim_install_root����ע���Ŀ¼�¿��������� Vim ����\
     �ļ����������Ҫ������Ŀ¼�����޸Ĺ��������ļ�������ѡ����"


##############################################################################
# Messages
##############################################################################

LangString str_msg_vim_running   ${LANG_SIMPCHINESE} \
    "����ϵͳ������ Vim �����У�$\r$\n\
     ������ִ�к�������ǰ�˳���Щ Vim��"

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
    "Ŀ¼ $0 ���в����ļ�ɾ��ʧ�ܣ�$\r$\n�������ֹ�ɾ����Ŀ¼��"

LangString str_msg_invalid_root  ${LANG_SIMPCHINESE} \
    "��װ·�� $vim_install_root ��Ч��$\r$\nж�س�����ֹ��"
