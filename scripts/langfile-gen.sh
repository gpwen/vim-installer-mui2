#!/bin/ksh

##############################################################################
# This script is used to generate template for language support file.
#
# Author: Guopeng Wen
##############################################################################

# Name of this script:
CMD_FULLPATH=$0
CMD=$(basename $0)

# Name of the OS:
SYSTEM_TYPE=$(uname -s)

# Name of the English template file:
OPT_EN_LANG_FILE=/tmp/english.nsi.$$

# Command line options:
OPT_NSIS_PATH=

# Remove temporary file when exit:
trap "rm -rf ${OPT_EN_LANG_FILE}" EXIT

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
Generates language file templates for Vim NSIS installer.  Templates will be
generated from language files installed by NSIS.

This command must be run within git repository, it needs to access files in
the repository.

USAGE:
    $CMD [-s <nsis-path>]

Where:
  -s <nsis-path> : NSIS install path, cygwin format.  This script will try to
                   detect it automatically from path of makensis command if
                   not specified."

return 0
}

##############################################################################
# Main script begins here                                                 {{{1
# ============================================================================
# Parse the command line:
while getopts :sh option; do
    case $option in
        h) print_usage
           exit 0
           ;;

        s) OPT_NSIS_PATH="$OPTARG"
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

# Try to determine NSIS install path:
if [[ -z "$OPT_NSIS_PATH" ]]; then
    if ! which makensis 1>/dev/null 2>&1; then
        print -u2 "$CMD: ERROR : Cannot execute makensis!"
        return 1
    fi

    OPT_NSIS_PATH=$(which makensis)
    OPT_NSIS_PATH=${OPT_NSIS_PATH%/*}
fi

# Get English language file:
rm -f $OPT_EN_LANG_FILE
git show master:nsis/lang/english.nsi > $OPT_EN_LANG_FILE
if [[ ! -f "$OPT_EN_LANG_FILE" ]]; then
    print -u2 "$CMD: Cannot find English language file!"
    print -u2 "Are you in git repository?"
    exit 1
fi

# Check environment:
OPT_NSIS_PATH="$OPT_NSIS_PATH/Contrib/Language files"
if [[ ! -d "$OPT_NSIS_PATH" ]]; then
    print -u2 "$CMD: Cannot find NSIS install path!"
    exit 1
fi

# Generate templates for all languages:
for LANG_FILE_FULL in "$OPT_NSIS_PATH"/*.nlf; do
    # Name of the language:
    NSIS_LANG_NAME=${LANG_FILE_FULL##*/}
    NSIS_LANG_NAME=${NSIS_LANG_NAME%.*}

    # ID of the language, all upper case:
    typeset -u NSIS_LANG_ID="LANG_$NSIS_LANG_NAME"

    # Name of the language file, all lower case:
    typeset -l NSIS_LANG_FILE="${NSIS_LANG_NAME}.nsi"

    # Skip English, that's the original template:
    if [[ "$NSIS_LANG_NAME" == "English" ]]; then
        continue;
    fi

    # Skip existing files:
    if [[ -f $NSIS_LANG_FILE ]]; then
        print "Skip existing language file : $NSIS_LANG_FILE"
    else
        print "Generating language file : $NSIS_LANG_FILE ..."
    fi

    # Determine Locale ID (LCID):
    NSIS_LCID=$(
    perl -p -e '
        chomp;
        if (!$lcid_found)
        {
            $lcid_found = /^ \s* \# \s+ Language \s+ ID \s* $/iox;
            $_          = "";
            next;
        }
        else
        {
            print "$_\n";
            last;
        }' "$LANG_FILE_FULL")

    # Copy English language file:
    cp -p $OPT_EN_LANG_FILE $NSIS_LANG_FILE

    # Replace language name/ID etc.:
    NSIS_LANG_NAME=$NSIS_LANG_NAME \
    NSIS_LANG_ID=$NSIS_LANG_ID \
    NSIS_LCID=$NSIS_LCID \
    NSIS_LANG_FILE=$NSIS_LANG_FILE \
    perl -pi'nsis_orig_*.bak' -e '
        chomp;

        # Replace file header:
        if (!$content_start)
        {
            $content_start =
                /^\!insertmacro \s+ MUI_LANGUAGE \s+ "English"$/xo;

            $_ = ($content_start) ?
               "# vi:set ts=8 sts=4 sw=4 fdm=marker:\n" .
               "#\n" .
               "# $ENV{NSIS_LANG_FILE}: $ENV{NSIS_LANG_NAME} " .
               "language strings for gvim NSIS installer.\n" .
               "# Locale ID: $ENV{NSIS_LCID}\n" .
               "#\n" .
               "# Author:\n" .
               "\n" .
               "!insertmacro MUI_LANGUAGE \"$ENV{NSIS_LANG_NAME}\"\n" : "";

            next;
        }

        # File content:
        s/ \${LANG_ENGLISH} / \${$ENV{NSIS_LANG_ID}} /go;
        $_ .= "\n";' $NSIS_LANG_FILE
done

# Remove backup files:
rm -f nsis_orig_*.bak

##############################################################################
# vim600: set foldmethod=marker:                                          }}}1
##############################################################################
