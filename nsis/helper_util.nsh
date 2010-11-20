# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# helper_util.nsh
# Some helper macros.
# Author: Guopeng Wen

!ifndef __HELPER_UTIL__NSH__
!define __HELPER_UTIL__NSH__

!include "LogicLib.nsh"
!include "Util.nsh"
!include "WordFunc.nsh"
!include "MUI2.nsh"

##############################################################################
# macro ExchAt $_OFFSET $_VAR                                             {{{1
#   Helper macro to exchange the content of a variable with specified location
#   of the stack.
#
#   Arguments:
#     $_OFFSET : Must be a positive integer indicate offset from the top of
#                the stack.
#     $_VAR    : Variable for content exchange.  The content of the specified
#                variable will be exchanged with the content on the stack.
##############################################################################
!define ExchAt "!insertmacro _ExchAt"
!macro _ExchAt _OFFSET _VAR
    Exch ${_OFFSET}
    Exch ${_VAR}
    Exch ${_OFFSET}
!macroend

##############################################################################
# macro TrimString $_INPUT $_OUTPUT                                       {{{1
#   Trim white spaces from both ends of the input string.
#
#   Parameters:
#     $_INPUT  : The input string.
#   Returns:
#     $_OUTPUT : Is the output string with white spaces stripped from both
#                ends.  " \r\n\t" will be considered as white space.
##############################################################################
!define TrimString "!insertmacro _TrimStringCall"

!macro _TrimStringCall _INPUT _OUTPUT
    Push `${_INPUT}`
    ${CallArtificialFunction} _TrimString
    Pop ${_OUTPUT}
!macroend

!macro _TrimString
    Exch $0  # Input string

    # Degenerated case: empty input string:
    ${If} "$0" == ""
        Exch $0
        Return
    ${EndIf}

    Push $R0  # Character from the input string
    Push $R1  # Start offset/length to copy

    # Count number of white spaces at the beginning of the string:
    StrCpy $R1 0
    ${Do}
        StrCpy  $R0 $0 1 $R1
        ${If}   $R0 S== " "
        ${OrIf} $R0 S== "$\t"
        ${OrIf} $R0 S== "$\r"
        ${OrIf} $R0 S== "$\n"
            IntOp $R1 $R1 + 1
        ${Else}
            ${ExitDo}
        ${EndIf}
    ${Loop}

    # Trim left:
    ${If} $R1 > 0
        StrCpy $0 $0 "" $R1
    ${EndIf}

    # Count number of white spaces at the end of the string:
    ${If} $0 != ""
        StrCpy $R1 -1
        ${Do}
            StrCpy  $R0 $0 1 $R1
            ${If}   $R0 S== " "
            ${OrIf} $R0 S== "$\t"
            ${OrIf} $R0 S== "$\r"
            ${OrIf} $R0 S== "$\n"
                IntOp $R1 $R1 - 1
            ${Else}
                ${ExitDo}
            ${EndIf}
        ${Loop}

        # Trim right:
        IntOp $R1 $R1 + 1
        ${If} $R1 < 0
            StrCpy $0 $0 $R1
        ${EndIf}
    ${EndIf}

    # Output:
    Pop  $R1
    Pop  $R0
    Exch $0
!macroend

##############################################################################
# macro VimAddLanguage $_LANGUAGE $_LOCALE_NAME                           {{{1
#   This macro is used to include the language file and generate a mapping
#   table to associate LCID, locale name, and language name.  LCID and Locale
#   name will used to make it simpler to specify language on command line.
#
#   Parameters:
#     $_LANGUAGE    : Name of the language to add.  This should be the
#                     language name assigned by NSIS.  For detail, check:
#                       <nsis>/Contrib/Language files
#     $_LOCALE_NAME : GNU gettext locale name for the language.  Detail can be
#                     found on the following webpage:
#                       http://www.gnu.org/software/gettext/
#                       manual/gettext.html#Locale-Names
#   Returns:
#     N/A
##############################################################################
!define VimAddLanguage "!insertmacro _VimAddLanguage"
!macro _VimAddLanguage _LANGUAGE _LOCALE_NAME
    # MUI2 macro to include language file:
    !insertmacro MUI_LANGUAGE "${_LANGUAGE}"

    # Item in language mapping table:
    #   LCID | Locale Name | Language Name
    !ifdef _VIM_LANG_MAPPING_ITEM
        !undef _VIM_LANG_MAPPING_ITEM
    !endif

    !define _VIM_LANG_MAPPING_ITEM \
        "${LANG_${_LANGUAGE}} | ${_LOCALE_NAME} | \
         ${LANGFILE_${_LANGUAGE}_NAME}"

    # Define language mapping table:
    !ifndef VIM_LANG_MAPPING
        !define VIM_LANG_MAPPING "${_VIM_LANG_MAPPING_ITEM}"
    !else
        !ifdef _VIM_LANG_MAPPING_TEMP
            !undef _VIM_LANG_MAPPING_TEMP
        !endif

        !define _VIM_LANG_MAPPING_TEMP "${VIM_LANG_MAPPING}"

        !undef  VIM_LANG_MAPPING
        !define VIM_LANG_MAPPING \
            "${_VIM_LANG_MAPPING_TEMP}$\n${_VIM_LANG_MAPPING_ITEM}"
    !endif
    
!macroend

##############################################################################
# macro CountFields $_STRING $_DELIMITER $_FIELD_COUNT                    {{{1
#   Count fields in the input string.
#
#   This macro works around a problem in the WordFindS macros.  That macro
#   won't return correct field count if no delimiter found in the input
#   string.
#
#   Parameters:
#     $_STRING      : Input string.
#     $_DELIMITER   : Input delimiter.
#   Returns:
#     $_FIELD_COUNT : Number of fields in the string.
##############################################################################
!define CountFields "!insertmacro _CountFields"

!macro _CountFields _STRING _DELIMITER _FIELD_COUNT
    Push `${_DELIMITER}`
    Push `${_STRING}`
    Exch      $1    # String
    ${ExchAt} 1 $0  # Delimiter

    # Count number of fields.  $0 is number of fields on output if delimiter
    # found in the input string.  Unfortunately, WordFindS cannot handle the
    # case where delimiter is not present in the input string.  We have to
    # work around the problem by appending an extra delimiter, and remove it
    # from field count later.
    ${WordFindS} `$1$0 ` `$0` "#" $0
    IntOp $0 $0 - 1

    # Output:
    Pop  $1
    Exch $0
    Pop  ${_FIELD_COUNT}
!macroend

##############################################################################
# Function LoopArray $_SPEC $_ITEM_CALLBACK $_ARG1 $_ARG2 $_EXIT_CODE     {{{1
#   Loop through items of the input text array.
#
#   This function will loop through all items in the input text array and call
#   the item callback function for each of them.  Items in the text array
#   should be delimited by newline "\n".
#
#   White spaces (including white space, tab, CR and LF) will be removed from
#   both ends of the item.  Items in the array should not be empty, you must
#   used some white spaces for that kind of item, otherwise the word
#   manipulation function used here (WordFindS) will fail.
#
#   The following content will be pushed onto stack when calling item callback
#   function:
#     - $_ITEM : The current item of the array.
#     - $_ARG1 : Caller specified item callback arg 1.
#     - $_ARG2 : Caller specified item callback arg 2.
#   The callback function should put return code on stack.  If the return code
#   is empty (""), LoopArray will continue to process the next item.
#   Otherwise, LoopArray will abort item processing, and use the non-empty
#   return code from the callback function as return code of LoopArray.
#
#   NSIS script does not support array, this function is a extremely
#   inefficient workaround.  It only works in limited cases.
#
#   Parameters:
#     The following parameters should be pushed onto stack in order.
#     - $_SPEC          : Array specification.
#     - $_ITEM_CALLBACK : Item callback.
#     - $_ARG1          : Item callback arg 1.
#     - $_ARG2          : Item callback arg 2.
#   Returns:
#     - $_EXIT_CODE     : Empty if the item callback function has never
#                         returned non-empty return code;  Otherwise, this is
#                         whatever the item callback returned.
##############################################################################

# Shortcuts to declare the function for installer/uninstaller:
!define DECLARE_LoopArray   '!insertmacro _DECLARE_LoopArray ""'
!define DECLARE_UnLoopArray '!insertmacro _DECLARE_LoopArray "un."'

# Shortcut to call the function:
!define LoopArray           '!insertmacro _LoopArrayCall'

!macro _LoopArrayCall _SPEC _ITEM_CALLBACK _ARG1 _ARG2 _EXIT_CODE
    !ifndef __UNINSTALL__
        !define _FUNC_PREFIX ""
    !else
        !define _FUNC_PREFIX "un."
    !endif

    Push `${_SPEC}`  # Array specification
    Push $R0
    GetFunctionAddress $R0 `${_ITEM_CALLBACK}`
    Exch $R0         # Address of item callback
    Push `${_ARG1}`  # Argument 1
    Push `${_ARG2}`  # Argument 2
    Call ${_FUNC_PREFIX}_LoopArrayFunc
    Pop ${_EXIT_CODE}

    !undef _FUNC_PREFIX
!macroend

# Definition of the function body:
!macro _DECLARE_LoopArray _PREFIX
    Function ${_PREFIX}_LoopArrayFunc
        # Incoming parameters:
        Exch      $3    # Item callback arg 2
        ${ExchAt} 1 $2  # Item callback arg 1
        ${ExchAt} 2 $1  # Item callback address
        ${ExchAt} 3 $0  # Array specification

        # Local working variables:
        Push $R0        # Item index, 1 based
        Push $R1        # Item count
        Push $R2        # Current item
        Push $R3        # Return code from the item callback

        # Count items: items are delimited by newline (\n):
        ${CountFields} "$0" "$\n" $R1

        # ??? Debug:
        #${Log} "### Array items: $R1"

        # Loop all items:
        StrCpy $R3 ""
        ${For} $R0 1 $R1
            # Get current item (item no. $R0):
            ${WordFindS} "$0" "$\n" "+$R0" $R2

            # Trim white space from both ends of the item.  WordFindS cannot
            # support empty fields correctly, so we have to put white spaces
            # in empty fields and trim them afterward.
            ${TrimString} $R2 $R2

            # ??? Debug:
            #${Log} "### Array item $R0: [$R2]"

            # Put item on the stack:
            Push $R2

            # Call the row callback function:
            Push $2   # Item callback arg 1
            Push $3   # Item callback arg 2
            Call $1
            Pop  $R3  # Return code from the item callback

            # Check return code from the item callback:
            ${If} "$R3" != ""
                # ??? Debug:
                ${Log} "Abort LoopArray: Item callback returns [$R3]"

                # Abort if non-empty return code found:
                ${ExitFor}
            ${EndIf}
        ${Next}

        # Return code:
        StrCpy $0 $R3

        # Restore the stack:
        Pop  $R3
        Pop  $R2
        Pop  $R1
        Pop  $R0
        Pop  $3
        Pop  $2
        Pop  $1
        Exch $0
    FunctionEnd
!macroend

##############################################################################
# Function LoopMatrix $_SPEC $_ROW_CALLBACK $_COL_ID $_ARG1/2 $_EXIT_CODE {{{1
#   Loop through rows of the input text matrix.
#
#   This function will loop through all rows of the input text matrix, and
#   call the row callback function for each row, with content of all columns
#   (or a specified column) of that row pushed onto stack.
#
#   Rows in the matrix should be delimited by newline (\n), columns in each
#   row should be delimited by vertical bar (|).  All rows must have identical
#   number of columns.  The function will calculate number of columns in the
#   first row and apply that to all rows.  White spaces (including white
#   space, tab, CR and LF) will be removed from both ends of each column.
#   Items in the matrix should not be empty, you must used some white spaces
#   for that kind of item, otherwise the word manipulation function used here
#   (WordFindS) will fail.
#
#   The following content will be pushed onto the stack when calling the row
#   callback function, if $_COL_ID is empty:
#     - $_COL1 : Column 1 of the current row.
#     - $_COL2 : Column 2 of the current row.
#     ...
#     - $_COLn : Column n of the current row.
#     - $_ARG1 : Caller specified item callback arg 1.
#     - $_ARG2 : Caller specified item callback arg 2.
#   Otherwise, the following column will be pushed on the stack:
#     - $_COLk : Column specified by $_COL_ID.
#     - $_ARG1 : Caller specified item callback arg 1.
#     - $_ARG2 : Caller specified item callback arg 2.
#
#   The callback function should put return code on stack.  If the return code
#   is empty (""), LoopMatrix will continue to process the next row.
#   Otherwise, LoopMatrix will abort row processing, and use the non-empty
#   return code from the callback function as return code of LoopMatrix.
#
#   Row callback function MUST know the number of column in the specified text
#   matrix, and restore the stack accordingly.
#
#   NSIS script does not support array, this function is a extremely
#   inefficient workaround (for 2D array).  It only works in limited cases.
#
#   Parameters:
#     The following parameters should be pushed onto stack in order.
#     - $_SPEC         : Matrix specification.
#     - $_ROW_CALLBACK : Row callback function.
#     - $_COL_ID       : If non-empty, only this column (the ID is 1 based)
#                        will be put onto the stack when calling row callback
#                        function; Otherwise, all columns will be put onto the
#                        stack.
#     - $_ARG1         : Row callback arg 1.
#     - $_ARG2         : Row callback arg 2.
#   Returns:
#     - $_EXIT_CODE    : Empty if the row callback function has never returned
#                        non-empty return code;  Otherwise, this is whatever
#                        the row callback returned.
##############################################################################

# Shortcuts to declare the function for installer/uninstaller:
!define DECLARE_LoopMatrix   '!insertmacro _DECLARE_LoopMatrix ""'
!define DECLARE_UnLoopMatrix '!insertmacro _DECLARE_LoopMatrix "un."'

# Shortcut to call the function:
!define LoopMatrix           '!insertmacro _LoopMatrixCall'

!macro _LoopMatrixCall _SPEC _ROW_CALLBACK _COL_ID _ARG1 _ARG2 _EXIT_CODE
    !ifndef __UNINSTALL__
        !define _FUNC_PREFIX ""
    !else
        !define _FUNC_PREFIX "un."
    !endif

    Push `${_SPEC}`    # Matrix specification
    Push $R0
    GetFunctionAddress $R0 `${_ROW_CALLBACK}`
    Exch $R0           # Address of row callback
    Push `${_COL_ID}`  # Column ID
    Push `${_ARG1}`    # Argument 1
    Push `${_ARG2}`    # Argument 2
    Call ${_FUNC_PREFIX}_LoopMatrixFunc
    Pop  ${_EXIT_CODE}

    !undef _FUNC_PREFIX
!macroend

# Definition of the function body:
!macro _DECLARE_LoopMatrix _PREFIX
    Function ${_PREFIX}_LoopMatrixFunc
        # Incoming parameters:
        Exch      $4    # $_ARG2
        ${ExchAt} 1 $3  # $_ARG1
        ${ExchAt} 2 $2  # $_COL_ID
        ${ExchAt} 3 $1  # $_ROW_CALLBACK
        ${ExchAt} 4 $0  # $_SPEC

        # Local working variables:
        Push $R0        # Row index, 1 based
        Push $R1        # Column index, 1 based
        Push $R2        # Row count
        Push $R3        # Column count
        Push $R4        # Current row
        Push $R5        # Current column
        Push $R6        # Return code of the row callback

        # Count rows: rows are delimited by newline (\n):
        ${CountFields} "$0" "$\n" $R2

        # Count columns: columns are delimited by vertical bar (|):
        ${WordFindS} "$0" "$\n" "+1" $R4
        ${CountFields} "$R4" "|" $R3

        # ??? Debug:
        #${Log} "### Rows: $R2, Columns: $R3"

        # Loop all rows:
        StrCpy $R6 ""
        ${For} $R0 1 $R2
            # Get current row (row no. $R0):
            ${WordFindS} "$0" "$\n" "+$R0" $R4

            ${If} "$2" == ""
                # No column ID specified, loop all columns on the current row:
                ${For} $R1 1 $R3
                    # Get column no. $R1:
                    ${WordFindS} "$R4" "|" "+$R1" $R5

                    # Trim white space from both ends of the column.  WordFindS
                    # cannot support empty fields correctly, so we have to put
                    # white spaces in empty fields and trim them afterward.
                    ${TrimString} $R5 $R5

                    # ??? Debug:
                    #${Log} "### Row $R0, Col $R1: [$R5]"

                    # Put column on the stack:
                    Push $R5
                ${Next}
            ${Else}
                # The caller specified a column, only put content of that
                # column on the stack:
                ${WordFindS} "$R4" "|" "+$2" $R5
                ${TrimString} $R5 $R5

                # ??? Debug:
                #${Log} "### Row $R0, Col $2: [$R5]"

                # Put column on the stack:
                Push $R5
            ${EndIf}

            # Call the row callback function:
            Push $3   # Row callback arg 1
            Push $4   # Row callback arg 2
            Call $1
            Pop  $R6  # Return code from the row callback

            # Check return code from the row callback:
            ${If} "$R6" != ""
                # ??? Debug:
                ${Log} "Abort LoopMatrix: Row callback returns [$R6]"

                # Abort if non-empty return code found:
                ${ExitFor}
            ${EndIf}
        ${Next}

        # Return code:
        StrCpy $0 $R6

        # Restore the stack:
        Pop  $R6
        Pop  $R5
        Pop  $R4
        Pop  $R3
        Pop  $R2
        Pop  $R1
        Pop  $R0
        Pop  $4
        Pop  $3
        Pop  $2
        Pop  $1
        Exch $0
    FunctionEnd
!macroend

!endif # __HELPER_UTIL__NSH__
