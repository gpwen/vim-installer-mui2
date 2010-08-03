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
    "��װ·�� (������ vim ��β)"

LangString str_ShowReadme          ${LANG_SIMPCHINESE} \
    "��װ��ɺ���ʾ README �ļ�"

# Install types:
LangString str_TypeTypical         ${LANG_SIMPCHINESE} \
    "���Ͱ�װ"

LangString str_TypeMinimal         ${LANG_SIMPCHINESE} \
    "��С��װ"

LangString str_TypeFull            ${LANG_SIMPCHINESE} \
    "��ȫ��װ"


##############################################################################
# Section Titles
##############################################################################

LangString str_SectionExe          ${LANG_SIMPCHINESE} \
    "��װ Vim ͼ�ν���"

LangString str_SectionConsole      ${LANG_SIMPCHINESE} \
    "��װ Vim �����г���"

LangString str_SectionBatch        ${LANG_SIMPCHINESE} \
    "��װ�������ļ�"

LangString str_SectionDesktop      ${LANG_SIMPCHINESE} \
    "��װ�����ݷ�ʽ"

LangString str_SectionStartMenu    ${LANG_SIMPCHINESE} \
    "��װ�����˵���"

LangString str_SectionQuickLaunch  ${LANG_SIMPCHINESE} \
    "��װ��������"

LangString str_SectionEditWith     ${LANG_SIMPCHINESE} \
    "��װ��ݲ˵�"

LangString str_SectionVimRC        ${LANG_SIMPCHINESE} \
    "����ȱʡ�����ļ�"

LangString str_SectionPluginHome   ${LANG_SIMPCHINESE} \
    "�������Ŀ¼"

LangString str_SectionPluginVim    ${LANG_SIMPCHINESE} \
    "�����������Ŀ¼"

LangString str_SectionVisVim       ${LANG_SIMPCHINESE} \
    "��װ VisVim ���"

LangString str_SectionNLS          ${LANG_SIMPCHINESE} \
    "��װ������֧��"

LangString str_UnsectionRegister   ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ϵͳ����"

LangString str_UnsectionExe        ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ִ���ļ��Լ��ű�"

LangString str_UnsectionPlugin     ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ���Ŀ¼ $vim_plugin_path"

LangString str_UnsectionRoot       ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ��װĿ¼ $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_DescExe         ${LANG_SIMPCHINESE} \
    "��װ Vim ͼ�ν��漰�ű�����Ϊ��ѡ��װ��"

LangString str_DescConsole     ${LANG_SIMPCHINESE} \
    "��װ Vim �����г��� (vim.exe)���ó����������д��������С�"

LangString str_DescBatch       ${LANG_SIMPCHINESE} \
    "Ϊ Vim �ĸ��ֱ��ִ�������������Ա��������������� Vim��"

LangString str_DescDesktop     ${LANG_SIMPCHINESE} \
    "������Ϊ Vim ��װ�������ɿ�ݷ�ʽ���Է������� Vim��"

LangString str_DescStartmenu   ${LANG_SIMPCHINESE} \
    "�������˵������ Vim ��Ŀ�������� Windows 95 �����ϰ汾��"

LangString str_DescQuicklaunch ${LANG_SIMPCHINESE} \
    "�ڿ�������������� Vim��"

LangString str_DescEditwith    ${LANG_SIMPCHINESE} \
    "�� Vim ��ӵ����򿪷�ʽ����ݲ˵��С�"

LangString str_DescVimRC       ${LANG_SIMPCHINESE} \
    "�����װĿ¼��û�� _vimrc �ļ��������ɸ��ļ���ȱʡ�汾��_vimrc �ļ����������� Vim ѡ��������ļ���"

LangString str_DescPluginHome  ${LANG_SIMPCHINESE} \
    "��ѡ�������� HOME Ŀ¼�´���(�յ�)���Ŀ¼�ṹ����δ���� HOME Ŀ¼�����ڰ�װĿ¼�´�����Ŀ¼�ṹ���⽫Ӱ��ϵͳ�������û������Ŀ¼���ڰ�װ Vim ��չ�����ֻҪ���ļ����Ƶ���ص���Ŀ¼�м��ɡ�"

LangString str_DescPluginVim   ${LANG_SIMPCHINESE} \
    "��ѡ�������� Vim ��װĿ¼�´���(�յ�)���Ŀ¼�ṹ��ϵͳ�������û�����ʹ�ð�װ�ڸ�Ŀ¼�µ���չ��������Ŀ¼���ڰ�װ Vim ��չ�����ֻҪ���ļ����Ƶ���ص���Ŀ¼�м��ɡ�"

LangString str_DescVisVim      ${LANG_SIMPCHINESE} \
    "������΢�� Microsoft Visual Studio ���м��ɵ� VisVim �����"

LangString str_DescNLS         ${LANG_SIMPCHINESE} \
    "��װ���ڶ�����֧�ֵ��ļ���"

LangString str_DescUnregister  ${LANG_SIMPCHINESE} \
    "ɾ���� Vim ��ص�ϵͳ���á�"

LangString str_DescRmExe       ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ������ִ���ļ����ű���"

LangString str_DescnRmPlugin   ${LANG_SIMPCHINESE} \
    "ɾ������ Vim  ���Ŀ¼ $vim_plugin_path����ע���Ŀ¼�������ļ����ᱻɾ����������ڸ�Ŀ¼������Ҫ�������ļ�������ѡ����"

LangString str_DescnRmRoot     ${LANG_SIMPCHINESE} \
    "ɾ�� Vim ��װĿ¼ $vim_install_root����ע���Ŀ¼�¿��������� Vim �����ļ����������Ҫ������Ŀ¼�����޸Ĺ��������ļ�������ѡ����"


##############################################################################
# Messages
##############################################################################

LangString str_MsgInstallFail  ${LANG_SIMPCHINESE} \
    "��װʧ�ܡ�ף���´κ��ˡ�"

LangString str_MsgUnregister   ${LANG_SIMPCHINESE} \
    "����ɾ���� Vim ��ص�ϵͳ���� ..."

LangString str_MsgRmExe        ${LANG_SIMPCHINESE} \
    "����ɾ�� Vim ִ���ļ��ͽű� ..."

LangString str_MsgRmExeFail    ${LANG_SIMPCHINESE} \
    "Ŀ¼ $0 ���в����ļ�ɾ��ʧ�ܣ�$\n�������ֹ�ɾ����Ŀ¼��"

LangString str_MsgRmPlugin     ${LANG_SIMPCHINESE} \
    "����ɾ�� Vim ���Ŀ¼ $vim_plugin_path ..."

LangString str_MsgRmRoot       ${LANG_SIMPCHINESE} \
    "����ɾ�� Vim ��װĿ¼ $vim_install_root ..."

LangString str_MsgInvalidRoot  ${LANG_SIMPCHINESE} \
    "��װ·�� $vim_install_root ��Ч��$\nж�س�����ֹ��"
