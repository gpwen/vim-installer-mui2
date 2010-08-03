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

LangString str_dest_folder          ${LANG_TRADCHINESE} \
    "�w�˸��| (�����H vim ����)"

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
# Section Titles
##############################################################################

LangString str_section_exe          ${LANG_TRADCHINESE} \
    "�w�� Vim �ϧάɭ��{��"

LangString str_section_console      ${LANG_TRADCHINESE} \
    "�w�� Vim �R�O��{��"

LangString str_section_batch        ${LANG_TRADCHINESE} \
    "�w�˧妸�ɮ�"

LangString str_section_desktop      ${LANG_TRADCHINESE} \
    "�w�ˮୱ���|"

LangString str_section_start_menu   ${LANG_TRADCHINESE} \
    "�w�ˡ��}�l����椤���Ұʲ�"

LangString str_section_quick_launch ${LANG_TRADCHINESE} \
    "�w�˧ֳt�Ұ�"

LangString str_section_edit_with    ${LANG_TRADCHINESE} \
    "�w�˧ֱ����"

LangString str_section_vim_rc       ${LANG_TRADCHINESE} \
    "�Ы��q�{�]�w��"

LangString str_section_plugin_home  ${LANG_TRADCHINESE} \
    "�Ыش���ؿ�"

LangString str_section_plugin_vim   ${LANG_TRADCHINESE} \
    "�Ыئ@�ɴ���ؿ�"

LangString str_section_vis_vim      ${LANG_TRADCHINESE} \
    "�w�� VisVim ����"

LangString str_section_nls          ${LANG_TRADCHINESE} \
    "�w�˥��a�y�����"

LangString str_unsection_register   ${LANG_TRADCHINESE} \
    "���� Vim �t�γ]�w"

LangString str_unsection_exe        ${LANG_TRADCHINESE} \
    "���� Vim �{���θ}��"

LangString str_unsection_plugin     ${LANG_TRADCHINESE} \
    "���� Vim ����ؿ� $vim_plugin_path"

LangString str_unsection_root       ${LANG_TRADCHINESE} \
    "���� Vim �w�˥ؿ� $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_desc_exe          ${LANG_TRADCHINESE} \
    "�w�� Vim �ϧάɭ��{���θ}���C��������w�ˡC"

LangString str_desc_console      ${LANG_TRADCHINESE} \
    "�w�� Vim �R�O��{�� (vim.exe)�C�ӵ{���b����O���f���B��C"

LangString str_desc_batch        ${LANG_TRADCHINESE} \
    "�� Vim ���U������Ыا妸�ɡA�H�K�b�R�O��U�Ұ� Vim�C"

LangString str_desc_desktop      ${LANG_TRADCHINESE} \
    "�b�ୱ�� Vim �w�˭Y�z���|�A�H��K�Ұ� Vim�C"

LangString str_desc_start_menu   ${LANG_TRADCHINESE} \
    "�b���}�l����椤�Ы� Vim �ҰʲաC�A�Τ_ Windows 95 �ΥH�W�����C"

LangString str_desc_quick_launch ${LANG_TRADCHINESE} \
    "�w�� Vim �ֳt�Ұʶ��C"

LangString str_desc_edit_with    ${LANG_TRADCHINESE} \
    "�b�����}�覡���ֱ���椤�K�[ Vim ���C"

LangString str_desc_vim_rc       ${LANG_TRADCHINESE} \
    "�b�w�˸��|�U�S�� _vimrc �ɮת����p�U�A�Ыظ��ɮת��q�{�����C_vimrc \
     �ɮץΤ_�]�w Vim �ﶵ�C"

LangString str_desc_plugin_home  ${LANG_TRADCHINESE} \
    "�b HOME ���|�U�Ы�(�Ū�)����ؿ����c�C�Y�դU���]�w HOME ���|�A�|�b\
     �w�˸��|�U�Ыظӥؿ����c�A�o�N�v�T�q���W�Ҧ��Τ�C����ؿ��Τ_�w�� \
     Vim ���X�i����A�u�n�N�������ɮ״_���������l�ؿ����Y�i�C"

LangString str_desc_plugin_vim   ${LANG_TRADCHINESE} \
    "�b Vim �w�˸��|�U�Ы�(�Ū�)����ؿ����c�A�q���W�Ҧ��Τ᳣��ϥΦw��\
     �b�ӥؿ������X�i����C����ؿ��Τ_�w�� Vim ���X�i����A�u�n�N������\
     �ɮ״_���������l�ؿ����Y�i�C"

LangString str_desc_vis_vim      ${LANG_TRADCHINESE} \
    "VisVim �O�Τ_�P�L�n Microsoft Visual Studio �n��i���X������C"

LangString str_desc_nls          ${LANG_TRADCHINESE} \
    "�w�˥Τ_������a�y�����ɮסC"

LangString str_desc_unregister   ${LANG_TRADCHINESE} \
    "�����P Vim �������t�γ]�w�C"

LangString str_desc_rm_exe       ${LANG_TRADCHINESE} \
    "�����Ҧ��� Vim �{���θ}���C"

LangString str_desc_rm_plugin    ${LANG_TRADCHINESE} \
    "�����z�� Vim  ����ؿ� $vim_plugin_path�C�Ъ`�N�ӥؿ��U�Ҧ��ɮ�\
     ���|�Q�����C�Y�դU�b�ӥؿ��U���Ʊ�O�d���ɮסA���Ų����Ӷ��C"

LangString str_desc_rm_root      ${LANG_TRADCHINESE} \
    "���� Vim �w�˥ؿ� $vim_install_root�C�Ъ`�N�ӥؿ��U�i�঳�դU�� Vim \
     �]�w�ɡC�Y�դU�ݭn�O�d�ӥؿ��U�Q�׭q�L���]�w�ɡA���Ų����Ӷ��C"


##############################################################################
# Messages
##############################################################################

LangString str_msg_vim_running   ${LANG_TRADCHINESE} \
    "�դU���q���W�|�����b�B�椧 Vim�A�нлդU�b����Z��B�J�e�N������h�X�C"

LangString str_msg_install_fail  ${LANG_TRADCHINESE} \
    "�w�˥��ѡC�w���U���n�B�C"

LangString str_msg_unregister    ${LANG_TRADCHINESE} \
    "�������P Vim �������t�γ]�w ..."

LangString str_msg_rm_exe        ${LANG_TRADCHINESE} \
    "������ Vim �{���θ}�� ..."

LangString str_msg_rm_exe_fail   ${LANG_TRADCHINESE} \
    "�ؿ� $0 �U�������ɮץ��ಾ���I$\n�դU������u�����ӥؿ��C"

LangString str_msg_rm_plugin     ${LANG_TRADCHINESE} \
    "������ Vim ����ؿ� $vim_plugin_path ..."

LangString str_msg_rm_root       ${LANG_TRADCHINESE} \
    "������ Vim �w�˥ؿ� $vim_install_root ..."

LangString str_msg_invalid_root  ${LANG_TRADCHINESE} \
    "�w�˸��| $vim_install_root �L�ġI$\n�����{���N�פ�C"
