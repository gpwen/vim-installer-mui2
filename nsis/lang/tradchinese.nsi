# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# tradchinese.nsi: Traditional Chinese language strings for gvim NSIS
# installer.
#
# Locale ID    : 1028
# fileencoding : big5
# Author       : Guopeng Wen

!include "helper_util.nsh"
${VimAddLanguage} "TradChinese" "zh_TW"


##############################################################################
# MUI Configuration Strings                                               {{{1
##############################################################################

LangString str_dest_folder          ${LANG_TRADCHINESE} \
    "�w�˸�Ƨ� (�����H vim ����)"

LangString str_show_readme          ${LANG_TRADCHINESE} \
    "�w�˧�������� README �ɮ�"

# Install types:
LangString str_type_typical         ${LANG_TRADCHINESE} \
    "�嫬�w��"

LangString str_type_minimal         ${LANG_TRADCHINESE} \
    "�̤p�w��"

LangString str_type_full            ${LANG_TRADCHINESE} \
    "�����w��"


##############################################################################
# Section Titles & Description                                            {{{1
##############################################################################

LangString str_group_old_ver        ${LANG_TRADCHINESE} \
    "�����ª���"
LangString str_desc_old_ver         ${LANG_TRADCHINESE} \
    "�����դU�q���W�ª����� Vim�C"

LangString str_section_exe          ${LANG_TRADCHINESE} \
    "�w�� Vim �ϧάɭ��{��"
LangString str_desc_exe             ${LANG_TRADCHINESE} \
    "�w�� Vim �ϧάɭ��{���θ}���C��������w�ˡC"

LangString str_section_console      ${LANG_TRADCHINESE} \
    "�w�� Vim �R�O��{��"
LangString str_desc_console         ${LANG_TRADCHINESE} \
    "�w�� Vim �R�O��{�� (vim.exe)�C�ӵ{���b����O���f���B��C"

LangString str_section_batch        ${LANG_TRADCHINESE} \
    "�w�˧妸�ɮ�"
LangString str_desc_batch           ${LANG_TRADCHINESE} \
    "�� Vim ���U������Ыا妸�ɡA�H�K�b�R�O��U�Ұ� Vim�C"

LangString str_group_icons          ${LANG_TRADCHINESE} \
    "�إ� Vim �ϥ�"
LangString str_desc_icons           ${LANG_TRADCHINESE} \
    "�إ߭Y�z Vim �ϥܡA�H�K�_�ϥ� Vim�C"

LangString str_section_desktop      ${LANG_TRADCHINESE} \
    "��ୱ"
LangString str_desc_desktop         ${LANG_TRADCHINESE} \
    "�إ߭Y�z Vim �ϥܩ�ୱ�W�A�H��K�Ұ� Vim�C"

LangString str_section_start_menu   ${LANG_TRADCHINESE} \
    "��u�}�l�v�\����u�{���v��"
LangString str_desc_start_menu      ${LANG_TRADCHINESE} \
    "�b�u�}�l�v�\����u�{���v�����إ� Vim �ҰʲաC\
     �A�Τ_ Windows 95 �ΥH�W�����C"

LangString str_section_quick_launch ${LANG_TRADCHINESE} \
    "��ֳt�ҰʦC"
LangString str_desc_quick_launch    ${LANG_TRADCHINESE} \
    "�b�ֳt�ҰʦC���إ� Vim �ϥܡC"

LangString str_group_edit_with      ${LANG_TRADCHINESE} \
    "�w�˧ֱ����"
LangString str_desc_edit_with       ${LANG_TRADCHINESE} \
    "�b�u���}�覡�v�ֱ���椤�K�[ Vim ���C"

LangString str_section_edit_with32  ${LANG_TRADCHINESE} \
    "32 �줸����"
LangString str_desc_edit_with32     ${LANG_TRADCHINESE} \
    "�b 32 �줸�{�����u���}�覡�v�ֱ���椤�K�[ Vim ���C"

LangString str_section_edit_with64  ${LANG_TRADCHINESE} \
    "64 �줸����"
LangString str_desc_edit_with64     ${LANG_TRADCHINESE} \
    "�b 64 �줸�{�����u���}�覡�v�ֱ���椤�K�[ Vim ���C"

LangString str_section_vim_rc       ${LANG_TRADCHINESE} \
    "�إ��q�{�]�w��"
LangString str_desc_vim_rc          ${LANG_TRADCHINESE} \
    "�b�w�˸�Ƨ��U�إ��q�{�� Vim �]�w��(_vimrc)�C\
     �Y�ӳ]�w�ɤw�g�s�b�A�h���L�����C"

LangString str_group_plugin         ${LANG_TRADCHINESE} \
    "�إߴ����Ƨ�"
LangString str_desc_plugin          ${LANG_TRADCHINESE} \
    "�إ�(�Ū�)�����Ƨ����c�C�����Ƨ��Τ_�w�� Vim ���X�i����A\
     �u�n�N�ɮ״_���������l��Ƨ����Y�i�C"

LangString str_section_plugin_home  ${LANG_TRADCHINESE} \
    "�إߴ����Ƨ�"
LangString str_desc_plugin_home     ${LANG_TRADCHINESE} \
    "�b HOME ��Ƨ��U�إ�(�Ū�)�����Ƨ����c�C�Y�դU���]�w HOME ��Ƨ��A�|\
     �b�w�˸�Ƨ��U�إ߸Ӹ�Ƨ����c�C"

LangString str_section_plugin_vim   ${LANG_TRADCHINESE} \
    "�إߦ@�ɴ����Ƨ�"
LangString str_desc_plugin_vim      ${LANG_TRADCHINESE} \
    "�b Vim �w�˸�Ƨ��U�إ�(�Ū�)�����Ƨ����c�A�q���W�Ҧ��Τ᳣��ϥΦw��\
     �b�Ӹ�Ƨ������X�i����C"

LangString str_section_vis_vim      ${LANG_TRADCHINESE} \
    "�w�� VisVim ����"
LangString str_desc_vis_vim         ${LANG_TRADCHINESE} \
    "VisVim �O�Τ_�P�L�n Microsoft Visual Studio �n��i���X������C"

LangString str_section_nls          ${LANG_TRADCHINESE} \
    "�w�˥��a�y�����"
LangString str_desc_nls             ${LANG_TRADCHINESE} \
    "�w�˥Τ_������a�y�����ɮסC"

LangString str_unsection_register   ${LANG_TRADCHINESE} \
    "���� Vim �t�γ]�w"
LangString str_desc_unregister      ${LANG_TRADCHINESE} \
    "�����P Vim �������t�γ]�w�C"

LangString str_unsection_exe        ${LANG_TRADCHINESE} \
    "���� Vim �{���θ}��"
LangString str_desc_rm_exe          ${LANG_TRADCHINESE} \
    "�����Ҧ��� Vim �{���θ}���C"

LangString str_unsection_rc         ${LANG_TRADCHINESE} \
    "���� Vim �]�w��"
LangString str_desc_rm_rc           ${LANG_TRADCHINESE} \
    "���� Vim �]�w�ɡu$vim_install_root\_vimrc�v�C\
     �Y�դU�׭q�L���]�w�ɡA���ŤĿ�Ӷ��C"

##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_too_many_ver  ${LANG_TRADCHINESE} \
    "�դU���q���W�w�ˤF $vim_old_ver_count �Ӥ��P������ Vim�A$\r$\n\
     ���O���w�˵{���̦h�u��B�z ${VIM_MAX_OLD_VER} �Ӫ����C$\r$\n\
     �нлդU��u�����@�Ǫ����H�Z�A�B�楻�w�˵{���C"

LangString str_msg_invalid_root  ${LANG_TRADCHINESE} \
    "�w�˸�Ƨ��u$vim_install_root�v�L�ġI$\r$\n\
     �Ӹ�Ƨ������H�uvim�v�����C"

LangString str_msg_bin_mismatch  ${LANG_TRADCHINESE} \
    "Vim ����{���w�˸��|���`�I$\r$\n$\r$\n\
     �Ӫ��� Vim ������{���w�˸��|���ӬO�u$vim_bin_path�v,$\r$\n\
     �Өt�Ϋo���ܸӸ��|���u$INSTDIR�v�C"

LangString str_msg_vim_running   ${LANG_TRADCHINESE} \
    "�դU���q���W�|�����b�B�椧 Vim�A$\r$\n\
     �нлդU�b����Z��B�J�e�N������h�X�C"

LangString str_msg_register_ole  ${LANG_TRADCHINESE} \
    "�չϪ`�U Vim OLE ���A�{���C�Ъ`�N���צ��\�P�_�����A��ܶi�@�B���H���C"

LangString str_msg_unreg_ole     ${LANG_TRADCHINESE} \
    "�չϪ`�P Vim OLE ���A�{���C�Ъ`�N���צ��\�P�_�����A��ܶi�@�B���H���C"

LangString str_msg_rm_start      ${LANG_TRADCHINESE} \
    "�������p�U�����G"

LangString str_msg_rm_fail       ${LANG_TRADCHINESE} \
    "�H�U�����������ѡG"

LangString str_msg_no_rm_key     ${LANG_TRADCHINESE} \
    "�䤣��Ϧw�˵{�����n���ɤJ�f�C"

LangString str_msg_no_rm_reg     ${LANG_TRADCHINESE} \
    "�b�n���ɤ������Ϧw�˵{�����|�C"

LangString str_msg_no_rm_exe     ${LANG_TRADCHINESE} \
    "�䤣��Ϧw�˵{���C"

LangString str_msg_rm_copy_fail  ${LANG_TRADCHINESE} \
    "�L�k�N�k�N�Ϧw�˵{���`����{�ɥؿ��C"

LangString str_msg_rm_run_fail   ${LANG_TRADCHINESE} \
    "����Ϧw�˵{�����ѡC"

LangString str_msg_abort_install ${LANG_TRADCHINESE} \
    "�w�˵{���N�h�X�C"

LangString str_msg_install_fail  ${LANG_TRADCHINESE} \
    "�w�˥��ѡC�w���U���n�B�C"

LangString str_msg_rm_exe_fail   ${LANG_TRADCHINESE} \
    "��Ƨ��u$vim_bin_path�v�U�������ɮץ��ಾ���I$\r$\n\
     �դU�u���u�����Ӹ�Ƨ��C"

LangString str_msg_rm_root_fail  ${LANG_TRADCHINESE} \
    "ĵ�i�G�L�k�R�� Vim �w�˸�Ƨ��u$vim_install_root�v�A\
     �Ӹ�Ƨ��U������L�ɮסC"
