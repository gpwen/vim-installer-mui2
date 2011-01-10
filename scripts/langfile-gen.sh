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

# Name of the locale mapping file:
NSIS_LC_MAPPING=locale_mapping.dat

# Name of the English template file:
OPT_EN_LANG_FILE=/tmp/english.nsi.$$

# Link for git repository:
LINK_GIT_RAW_BASE="http://github.com/gpwen/vim-installer-mui2/raw"

# Link for language template:
LINK_LANG_TMPL_BASE="$LINK_GIT_RAW_BASE/misc/lang-tmpl"

# Link for language file:
LINK_LANG_FILE_BASE="$LINK_GIT_RAW_BASE/master/nsis/lang"

# Command line options:
OPT_NSIS_PATH=
OPT_WIKI_PAGE=
OPT_DUMP_LANG=

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
    $CMD [-s <nsis-path>] [-w]

Where:
  -d             : Dump name of all language supported by NSIS.
  -s <nsis-path> : NSIS install path, cygwin format.  This script will try to
                   detect it automatically from path of makensis command if
                   not specified.
  -w             : Generate wiki-page summarized all language file instead of
                   generating language files."

return 0
}

##############################################################################
# Main script begins here                                                 {{{1
# ============================================================================
# Parse the command line:
while getopts :s:dhw option; do
    case $option in
        d) OPT_DUMP_LANG=1
           ;;

        h) print_usage
           exit 0
           ;;

        s) OPT_NSIS_PATH="$OPTARG"
           ;;

        w) OPT_WIKI_PAGE=1
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

# Make sure locale mapping file exist under the current directory:
if [[ ! -r "$NSIS_LC_MAPPING" ]]; then
    print -u2 "$CMD: Cannot access locale mapping table $NSIS_LC_MAPPING!"
    exit 1
fi

# Output wiki-page:
if [[ $OPT_WIKI_PAGE -ne 0 ]]; then
    print "<TABLE BORDER=\"1\" ALIGN=\"CENTER\" CELLSPACING=\"0\""
    print "  RULES=\"GROUPS\" FRAME=\"HSIDES\">"
    print "  <THEAD>"
    print "    <TR>"
    print "      <TH>Language</TH>"
    print "      <TH>Locale ID</TH>"
    print "      <TH>Locale Name</TH>"
    print "      <TH>Template</TH>"
    print "      <TH>Final</TH>"
    print "      <TH>fileencoding</TH>"
    print "      <TH>Author</TH>"
    print "    </TR>"
    print "  </THEAD>"
    print "  <TBODY ALIGN=\"CENTER\">"
fi

# Generate templates for all languages:
for LANG_FILE_FULL in "$OPT_NSIS_PATH"/*.nlf; do
    # Name of the language:
    NSIS_LANG_NAME=${LANG_FILE_FULL##*/}
    NSIS_LANG_NAME=${NSIS_LANG_NAME%.*}

    # Only dump all languages supported by NSIS:
    if [[ $OPT_DUMP_LANG -ne 0 ]]; then
        print $NSIS_LANG_NAME
        continue
    fi

    # ID of the language, all upper case:
    typeset -u NSIS_LANG_ID="LANG_$NSIS_LANG_NAME"

    # Name of the language file, all lower case:
    typeset -l NSIS_LANG_FILE="${NSIS_LANG_NAME}.nsi"

    # Determine Locale ID (LCID):
    NSIS_LCID=$(
        perl -pe '
            s/[\s\r\n]+$//iox;
            if (!$lcid_found)
            {
                $lcid_found = /^ \s* \# \s+ Language \s+ ID \s*/iox;
                $_          = "";
                next;
            }
            else
            {
                print "$_\n";
                last;
            }' "$LANG_FILE_FULL")

    # Determine GNU gettext style locale name:
    NSIS_LC_NAME=$(grep -iE ": ${NSIS_LANG_NAME}$" $NSIS_LC_MAPPING)
    NSIS_LC_NAME=${NSIS_LC_NAME%%:*}
    NSIS_LC_NAME=${NSIS_LC_NAME%% *}
    if [[ -z "$NSIS_LC_NAME" ]]; then
        print -u2 "$CMD: Cannot find locale name for [$NSIS_LANG_NAME]!"
        NSIS_LC_NAME="UNKNOWN"
    fi

    # Output wiki-page:
    if [[ $OPT_WIKI_PAGE -ne 0 ]]; then
        LINK_TEMP="$LINK_LANG_TMPL_BASE/$NSIS_LANG_FILE"
        print "    <TR>"
        print "      <TD>$NSIS_LANG_NAME</TD>"
        print "      <TD>$NSIS_LCID</TD>"
        print "      <TD>$NSIS_LC_NAME</TD>"
        print "      <TD><A HREF=\"$LINK_TEMP\">$NSIS_LANG_FILE</A></TD>"

        if git cat-file -e master:nsis/lang/$NSIS_LANG_FILE 2>/dev/null; then
            # Get author of the language file:
            NSIS_AUTHOR=$(git show master:nsis/lang/$NSIS_LANG_FILE | \
                perl -pe '
                  s/[\s\r\n]+$//iox;
                  $_ = /^ \# \s+ Author \s* : \s* (.+) $/iox ? $1 : "";
                  ')
            NSIS_AUTHOR=${NSIS_AUTHOR:-"N/A"}

            # Get encoding of the file:
            NSIS_ENCODING=$(git show master:nsis/lang/$NSIS_LANG_FILE | \
                perl -pe '
                  s/[\s\r\n]+$//iox;
                  $_ = /^ \# \s+ fileencoding \s* : \s* (.+)$/iox ? $1 : "";
                  ')
            NSIS_ENCODING=${NSIS_ENCODING:-"N/A"}

            LINK_TEMP="$LINK_LANG_FILE_BASE/$NSIS_LANG_FILE"
            print "      <TD><A HREF=\"$LINK_TEMP\">$NSIS_LANG_FILE</A></TD>"
            print "      <TD>$NSIS_ENCODING</TD>"
            print "      <TD>$NSIS_AUTHOR</TD>"
        else
            print "      <TD>&nbsp;</TD>"
            print "      <TD>&nbsp;</TD>"
            print "      <TD>&nbsp;</TD>"
        fi
        print "    </TR>"
        continue;
    fi

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

    # Copy English language file:
    cp -p $OPT_EN_LANG_FILE $NSIS_LANG_FILE

    # Replace language name/ID etc.:
    NSIS_LANG_NAME=$NSIS_LANG_NAME \
    NSIS_LANG_ID=$NSIS_LANG_ID \
    NSIS_LCID=$NSIS_LCID \
    NSIS_LC_NAME=$NSIS_LC_NAME \
    NSIS_LANG_FILE=$NSIS_LANG_FILE \
    perl -pi'nsis_orig_*.bak' -e '
        s/[\s\r\n]+$//iox;

        # Replace file header:
        if (!$content_start)
        {
            $content_start =
                /^\${VimAddLanguage} \s+ "English" \s+ "en"$/xo;

            $_ = ($content_start) ?
               "# vi:set ts=8 sts=4 sw=4 fdm=marker:\n" .
               "#\n" .
               "# $ENV{NSIS_LANG_FILE} : $ENV{NSIS_LANG_NAME} " .
               "language strings for gvim NSIS installer.\n" .
               "#\n" .
               "# Locale ID    : $ENV{NSIS_LCID}\n" .
               "# Locale Name  : $ENV{NSIS_LC_NAME}\n" .
	       "# fileencoding :\n" .
               "# Author       :\n" .
               "\n" .
               "!include \"helper_util.nsh\"\n" .
               "\${VimAddLanguage} \"$ENV{NSIS_LANG_NAME}\" " .
               "\"$ENV{NSIS_LC_NAME}\"\n" : "";

            next;
        }

        # File content:
        s/ \${LANG_ENGLISH} / \${$ENV{NSIS_LANG_ID}} /go;
        $_ .= "\n";' $NSIS_LANG_FILE
done

# Output wiki-page:
if [[ $OPT_WIKI_PAGE -ne 0 ]]; then
    print "  </TBODY>"
    print "</TABLE>"
fi

# Remove backup files:
rm -f nsis_orig_*.bak

##############################################################################
# vim600: set foldmethod=marker:                                          }}}1
##############################################################################
