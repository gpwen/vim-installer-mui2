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
    "�w�˸��| (�����H vim ����)"

LangString str_ShowReadme          ${LANG_TRADCHINESE} \
    "�w�˧�������� README �ɮ�"

# Install types:
LangString str_TypeTypical         ${LANG_TRADCHINESE} \
    "�嫬�w��"

LangString str_TypeMinimal         ${LANG_TRADCHINESE} \
    "�̤p�w��"

LangString str_TypeFull            ${LANG_TRADCHINESE} \
    "�����w��"


##############################################################################
# Section Titles
##############################################################################

LangString str_SectionExe          ${LANG_TRADCHINESE} \
    "�w�� Vim �ϧάɭ��{��"

LangString str_SectionConsole      ${LANG_TRADCHINESE} \
    "�w�� Vim �R�O��{��"

LangString str_SectionBatch        ${LANG_TRADCHINESE} \
    "�w�˧妸�ɮ�"

LangString str_SectionDesktop      ${LANG_TRADCHINESE} \
    "�w�ˮୱ���|"

LangString str_SectionStartMenu    ${LANG_TRADCHINESE} \
    "�w�ˡ��}�l����椤���Ұʲ�"

LangString str_SectionQuickLaunch  ${LANG_TRADCHINESE} \
    "�w�˧ֳt�Ұ�"

LangString str_SectionEditWith     ${LANG_TRADCHINESE} \
    "�w�˧ֱ����"

LangString str_SectionVimRC        ${LANG_TRADCHINESE} \
    "�Ы��q�{�]�w��"

LangString str_SectionPluginHome   ${LANG_TRADCHINESE} \
    "�Ыش���ؿ�"

LangString str_SectionPluginVim    ${LANG_TRADCHINESE} \
    "�Ыئ@�ɴ���ؿ�"

LangString str_SectionVisVim       ${LANG_TRADCHINESE} \
    "�w�� VisVim ����"

LangString str_SectionNLS          ${LANG_TRADCHINESE} \
    "�w�˥��a�y�����"

LangString str_UnsectionRegister   ${LANG_TRADCHINESE} \
    "���� Vim �t�γ]�w"

LangString str_UnsectionExe        ${LANG_TRADCHINESE} \
    "���� Vim �{���θ}��"

LangString str_UnsectionPlugin     ${LANG_TRADCHINESE} \
    "���� Vim ����ؿ� $vim_plugin_path"

LangString str_UnsectionRoot       ${LANG_TRADCHINESE} \
    "���� Vim �w�˥ؿ� $vim_install_root"


##############################################################################
# Description for Sections
##############################################################################

LangString str_DescExe         ${LANG_TRADCHINESE} \
    "�w�� Vim �ϧάɭ��{���θ}���C��������w�ˡC"

LangString str_DescConsole     ${LANG_TRADCHINESE} \
    "�w�� Vim �R�O��{�� (vim.exe)�C�ӵ{���b����O���f���B��C"

LangString str_DescBatch       ${LANG_TRADCHINESE} \
    "�� Vim ���U������Ыا妸�ɡA�H�K�b�R�O��U�Ұ� Vim�C"

LangString str_DescDesktop     ${LANG_TRADCHINESE} \
    "�b�ୱ�� Vim �w�˭Y�z���|�A�H��K�Ұ� Vim�C"

LangString str_DescStartmenu   ${LANG_TRADCHINESE} \
    "�b���}�l����椤�Ы� Vim �ҰʲաC�A�Τ_ Windows 95 �ΥH�W�����C"

LangString str_DescQuicklaunch ${LANG_TRADCHINESE} \
    "�w�� Vim �ֳt�Ұʶ��C"

LangString str_DescEditwith    ${LANG_TRADCHINESE} \
    "�b�����}�覡���ֱ���椤�K�[ Vim ���C"

LangString str_DescVimRC       ${LANG_TRADCHINESE} \
    "�p�G�w�˸��|�U�S�� _vimrc �ɮסA�N�Ыظ��ɮת��q�{�����C_vimrc �ɮץΤ_�]�w Vim �ﶵ�C"

LangString str_DescPluginHome  ${LANG_TRADCHINESE} \
    "�ӿﶵ�Τ_�b HOME ���|�U�Ы�(�Ū�)����ؿ����c�C�Y���]�w HOME ���|�A�|�b�w�˸��|�U�Ыظӥؿ����c�A�o�N�v�T�q���W�Ҧ��Τ�C����ؿ��Τ_�w�� Vim ���X�i����A�u�n�N�������ɮ״_���������l�ؿ����Y�i�C"

LangString str_DescPluginVim   ${LANG_TRADCHINESE} \
    "�ӿﶵ�Τ_�b Vim �w�˸��|�Ы�(�Ū�)����ؿ����c�A�q���W�Ҧ��Τ᳣��ϥΦw�˦b�ӥؿ������X�i����C����ؿ��Τ_�w�� Vim ���X�i����A�u�n�N�������ɮ״_���������l�ؿ����Y�i�C"

LangString str_DescVisVim      ${LANG_TRADCHINESE} \
    "VisVim �O�Τ_�P�L�n Microsoft Visual Studio �n��i���X������C"

LangString str_DescNLS         ${LANG_TRADCHINESE} \
    "�w�˥Τ_������a�y�����ɮסC"

LangString str_DescUnregister  ${LANG_TRADCHINESE} \
    "�����P Vim �������t�γ]�w�C"

LangString str_DescRmExe       ${LANG_TRADCHINESE} \
    "�����Ҧ��� Vim �{���θ}���C"

LangString str_DescnRmPlugin   ${LANG_TRADCHINESE} \
    "�����z�� Vim  ����ؿ� $vim_plugin_path�C�Ъ`�N�ӥؿ��U�Ҧ��ɮ׳��|�Q�����C�Y�z�b�ӥؿ��U���Ʊ�O�d���ɮסA���Ų����Ӷ��C"

LangString str_DescnRmRoot     ${LANG_TRADCHINESE} \
    "���� Vim �w�˥ؿ� $vim_install_root�C�Ъ`�N�ӥؿ��U�i��αz�� Vim �]�w�ɡC�p�G�z�ݭn�O�d�ӥؿ��U�z�׭q�L���]�w�ɡA���Ų����Ӷ��C"


##############################################################################
# Messages
##############################################################################

LangString str_MsgInstallFail  ${LANG_TRADCHINESE} \
    "�w�˥��ѡC�w���U���n�B�C"

LangString str_MsgUnregister   ${LANG_TRADCHINESE} \
    "�������P Vim �������t�γ]�w ..."

LangString str_MsgRmExe        ${LANG_TRADCHINESE} \
    "������ Vim �{���θ}�� ..."

LangString str_MsgRmExeFail    ${LANG_TRADCHINESE} \
    "�ؿ� $0 �U�������ɮץ��ಾ���I$\n�z������u�����ӥؿ��C"

LangString str_MsgRmPlugin     ${LANG_TRADCHINESE} \
    "������ Vim ����ؿ� $vim_plugin_path ..."

LangString str_MsgRmRoot       ${LANG_TRADCHINESE} \
    "������ Vim �w�˥ؿ� $vim_install_root ..."

LangString str_MsgInvalidRoot  ${LANG_TRADCHINESE} \
    "�w�˸��| $vim_install_root �L�ġI$\n�����{���N�פ�C"
