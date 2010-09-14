#!/bin/ksh

##############################################################################
# This script is used to repack vim self-excutable installer.  It runs under
# cywin, and assumes 7z is available.
#
# If you need to repack Vim installer, NSIS must be installed.
#
# Author: Guopeng Wen
#
##############################################################################

# Name of this script:
CMD_FULLPATH=$0
CMD=$(basename $0)

# Name of the OS:
SYSTEM_TYPE=$(uname -s)

# Command line options:
OPT_DOWNLOAD=0
OPT_NSIS_GIT=

##############################################################################
# function print_usage                                                    {{{1
#   Show help message.
#
#   Return:      N/A
#   Exit Status: N/A
# ============================================================================
function print_usage
{
   print -u2 "
Repack official Vim installer using new MUI 2.0 NSIS scripts.  Please note
this shell script only runs under cygwin.

USAGE:
    $CMD [-d] [-s <nsis-git>]

Where:
  -d            : Download Vim PC installer (needs wget) and source code for
                  new Vim NSIS installer (needs git) automatically.
  -s <nsis-git> : Full path name of the local Vim nsis git repository.  If
                  specified, this shell script will try to copy NSIS script
                  from that location instead of cloning remote repository."

return 0
}

##############################################################################
# Main script begins here                                                 {{{1
# ============================================================================
# Parse the command line:
while getopts :s:dh option; do
    case $option in
        h) print_usage
           exit 0
           ;;

        d) OPT_DOWNLOAD=1
           ;;

        s) OPT_NSIS_GIT="$OPTARG"
           ;;

        :) print -u2 "$CMD: ERROR:"
           print -u2 "Switch \"$OPTARG\" requires a following argument.\n"
           exit 1
           ;;

        *) print -u2 "$CMD: ERROR: Unknown switch entered.\n\n"
           print_usage
           ;;
    esac
done
shift $OPTIND-1

# Make sure this is invoked under cygwin:
if [[ $SYSTEM_TYPE != CYGWIN* ]]; then
    print -u2 "$CMD: ERROR : This script only supports cygwin!"
    return 1
fi

if ! which 7z 1>/dev/null 2>&1; then
    print -u2 "$CMD: ERROR : Cannot execute 7-Zip (7z)!"
    return 1
fi

# Check environment:
if [[ -d "vim-repack" ]]; then
    print -u2 "$CMD: Found \"vim-repack\" under the current directory,"
    print -u2 "$CMD: Please remove it before continue."
    exit 1
fi

# Download Vim PC installer if required:
if [[ $OPT_DOWNLOAD -ne 0 ]]; then
    wget -c ftp://ftp.vim.org/pub/vim/pc/gvim73.exe
fi

if [[ ! -r "gvim73.exe" ]]; then
    print -u2 "$CMD: ERROR : Cannot find official gvim installer to unpack!"
    return 1
fi

# Unpack the installer, auto-rename duplicated files:
mkdir -v vim-repack  &&  cd vim-repack
echo "u" | 7z x ../gvim73.exe
if [[ $? -ne 0 ]]; then
    print -u2 "$CMD: ERROR : Fail to unpack Vim installer!"
    exit 1
fi

mv -v \$0 vim
mv -v \$_OUTDIR/* vim/lang
rm -vrf \$_OUTDIR

cd vim
rm -vf \$3*

mkdir -v src
mv -v gvim.exe          src/gvim_ole.exe
mv -v install.exe       src/installw32.exe
mv -v uninstal.exe      src/uninstalw32.exe
mv -v vimrun.exe        src
mv -v xxd.exe           src/xxdw32.exe
mv -v diff.exe          ..

mv -v vim.exe           src/vimd32.exe
mv -v vim_1.exe         src/vimw32.exe

mkdir -v src/GvimExt
mv -v gvimext.dll       src/GvimExt/gvimext64.dll
mv -v gvimext_1.dll     src/GvimExt/gvimext.dll

mkdir -v src/VisVim
mv -v \$R0              src/VisVim/VisVim.dll
mv -v README_VisVim.txt src/VisVim

rm -vrf \$R2 \$PLUGINSDIR

# Try to copy NSIS script first if user specified path to the local git
# repository:
rm -vrf nsis
if [[ -n "$OPT_NSIS_GIT"  ]]; then
    if [[ -d "$OPT_NSIS_GIT/nsis" ]]; then
        cp -vr /cygdrive/d/users/VIM-LATEST/HG-BUFFER/vim-nsis.git/nsis .
    else
        print -u2 "$CMD: ERROR : Cannot find nsis under $OPT_NSIS_GIT!"
        print -u2 "Is that a valid Vim nsis git?"
        exit 1
    fi
fi

# If the above failed, try to download the git repository directly:
if [[ ! -d nsis  &&  $OPT_DOWNLOAD -ne 0 ]]; then
    git clone git://github.com/gpwen/vim-installer-mui2.git
    if [[ $? -ne 0  ||  ! -d vim-installer-mui2 ]]; then
        print -u2 "$CMD: ERROR : Fail to download source code for the new installer!"
        exit 1
    fi

    ( cd vim-installer-mui2  &&  git co -b test origin/master )
    mv -v vim-installer-mui2/nsis .
    rm -vrf vim-installer-mui2
fi

if [[ -d nsis ]]; then
    cd nsis
    makensis gvim.nsi
    if [[ $? -eq 0 ]]; then
        print
        print "$CMD: Vim installer successfully repacked as:"
        print "    vim-repack/vim/nsis/gvim73.exe"
    else
        print "$CMD: ERROR : Fail to repack Vim installer."
    fi
else
    print
    print "$CMD: Vim installer successfully unpacked into \"vim-repack\"."
    print "You can now copy"
    print "    <vim-git>/nsis"
    print "to"
    print "    vim-repack/vim"
    print "and run \"makensis gvim.nsi\" from:"
    print "    vim-repack/vim/nsis"
fi

##############################################################################
# vim600: set foldmethod=marker:                                          }}}1
##############################################################################
