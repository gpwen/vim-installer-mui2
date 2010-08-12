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

LangString str_section_old_ver      ${LANG_TRADCHINESE} \
    "����"
LangString str_desc_old_ver         ${LANG_TRADCHINESE} \
    "�����դU�q���W�Ѫ����� Vim�C"

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

LangString str_section_desktop      ${LANG_TRADCHINESE} \
    "�w�ˮୱ���|"
LangString str_desc_desktop         ${LANG_TRADCHINESE} \
    "�b�ୱ�� Vim �w�˭Y�z���|�A�H��K�Ұ� Vim�C"

LangString str_section_start_menu   ${LANG_TRADCHINESE} \
    "�w�ˡu�}�l�v��椤���Ұʲ�"
LangString str_desc_start_menu      ${LANG_TRADCHINESE} \
    "�b�u�}�l�v��椤�Ы� Vim �ҰʲաC�A�Τ_ Windows 95 �ΥH�W�����C"

LangString str_section_quick_launch ${LANG_TRADCHINESE} \
    "�w�˧ֳt�Ұ�"
LangString str_desc_quick_launch    ${LANG_TRADCHINESE} \
    "�w�� Vim �ֳt�Ұʶ��C"

LangString str_section_edit_with    ${LANG_TRADCHINESE} \
    "�w�˧ֱ����"
LangString str_desc_edit_with       ${LANG_TRADCHINESE} \
    "�b�u���}�覡�v�ֱ���椤�K�[ Vim ���C"

LangString str_section_vim_rc       ${LANG_TRADCHINESE} \
    "�Ы��q�{�]�w��"
LangString str_desc_vim_rc          ${LANG_TRADCHINESE} \
    "�b�w�˸�Ƨ��U�S�� _vimrc �ɮת����p�U�A�Ыظ��ɮת��q�{�����C_vimrc \
     �ɮץΤ_�]�w Vim �ﶵ�C"

LangString str_section_plugin_home  ${LANG_TRADCHINESE} \
    "�Ыش����Ƨ�"
LangString str_desc_plugin_home     ${LANG_TRADCHINESE} \
    "�b HOME ��Ƨ��U�Ы�(�Ū�)�����Ƨ����c�C�Y�դU���]�w HOME ��Ƨ��A�|\
     �b�w�˸�Ƨ��U�ЫظӸ�Ƨ����c�C�����Ƨ��Τ_�w�� Vim ���X�i����A�u\
     �n�N�������ɮ״_���������l��Ƨ����Y�i�C"

LangString str_section_plugin_vim   ${LANG_TRADCHINESE} \
    "�Ыئ@�ɴ����Ƨ�"
LangString str_desc_plugin_vim      ${LANG_TRADCHINESE} \
    "�b Vim �w�˸�Ƨ��U�Ы�(�Ū�)�����Ƨ����c�A�q���W�Ҧ��Τ᳣��ϥΦw��\
     �b�Ӹ�Ƨ������X�i����C�����Ƨ��Τ_�w�� Vim ���X�i����A�u�n�N������\
     �ɮ״_���������l��Ƨ����Y�i�C"

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

LangString str_unsection_plugin     ${LANG_TRADCHINESE} \
    "���� Vim �����Ƨ� $vim_plugin_path"
LangString str_desc_rm_plugin       ${LANG_TRADCHINESE} \
    "�����z�� Vim �����Ƨ� $vim_plugin_path�C$\r$\n$\r$\n\
     �Ъ`�N�Ӹ�Ƨ��U�Ҧ��ɮ׳��|�Q�����C�Y�դU�b�Ӹ�Ƨ��U���Ʊ�O�d���ɮסA\
     ���ŤĿ�Ӷ��I"

LangString str_unsection_root       ${LANG_TRADCHINESE} \
    "���� Vim �w�˸�Ƨ� $vim_install_root"
LangString str_desc_rm_root         ${LANG_TRADCHINESE} \
    "���� Vim �w�˸�Ƨ� $vim_install_root�C�Ъ`�N�Ӹ�Ƨ��U�i�঳�դU�� Vim \
     �]�w�ɡC�Y�դU�ݭn�O�d�Ӹ�Ƨ��U�Q�׭q�L���]�w�ɡA���ŤĿ�Ӷ��C"


##############################################################################
# Messages                                                                {{{1
##############################################################################

LangString str_msg_vim_running   ${LANG_TRADCHINESE} \
    "�դU���q���W�|�����b�B�椧 Vim�A$\r$\n\
     �нлդU�b����Z��B�J�e�N������h�X�C"

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
    "��Ƨ� $0 �U�������ɮץ��ಾ���I$\r$\n�դU������u�����Ӹ�Ƨ��C"

LangString str_msg_invalid_root  ${LANG_TRADCHINESE} \
    "�w�˸�Ƨ� $vim_install_root �L�ġI$\r$\n�����{���N�פ�C"
