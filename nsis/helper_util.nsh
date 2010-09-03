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
    Exch $R0  # Input string

    # Degenerated case: empty input string:
    ${If} "$R0" == ""
        Exch $R0
        Return
    ${EndIf}

    Push $R1  # Character from the input string
    Push $R2  # Start offset/length to copy

    # Count number of white spaces at the beginning of the string:
    StrCpy $R2 0
    ${Do}
        StrCpy $R1 $R0 1 $R2
        ${If}   $R1 S== " "
        ${OrIf} $R1 S== "$\t"
        ${OrIf} $R1 S== "$\r"
        ${OrIf} $R1 S== "$\n"
            IntOp $R2 $R2 + 1
        ${Else}
            ${ExitDo}
        ${EndIf}
    ${Loop}

    # Trim left:
    ${If} $R2 > 0
        StrCpy $R0 $R0 "" $R2
    ${EndIf}

    # Count number of white spaces at the end of the string:
    ${If} $R0 != ""
        StrCpy $R2 -1
        ${Do}
            StrCpy $R1 $R0 1 $R2
            ${If}   $R1 S== " "
            ${OrIf} $R1 S== "$\t"
            ${OrIf} $R1 S== "$\r"
            ${OrIf} $R1 S== "$\n"
                IntOp $R2 $R2 - 1
            ${Else}
                ${ExitDo}
            ${EndIf}
        ${Loop}

        # Trim right:
        IntOp $R2 $R2 + 1
        ${If} $R2 < 0
            StrCpy $R0 $R0 $R2
        ${EndIf}
    ${EndIf}

    # Output:
    Pop  $R2
    Pop  $R1
    Exch $R0
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
    Exch $R1  # String
    Exch
    Exch $R0  # Delimiter
    Exch

    # Count number of fields.  $R0 is number of fields on output if delimiter
    # found in the input string.  Unfortunately, WordFindS cannot handle the
    # case where delimiter is not present in the input string.  We have to
    # work around the problem by appending an extra delimiter, and remove it
    # from field count later.
    ${WordFindS} `$R1$R0 ` `$R0` "#" $R0
    IntOp $R0 $R0 - 1

    # Output:
    Pop  $R1
    Exch $R0
    Pop  ${_FIELD_COUNT}
!macroend

##############################################################################
# Function LoopArray $_SPEC $_ITEM_CALLBACK $_ARG1 $_ARG2                 {{{1
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
#   The following
#   content will be pushed onto stack when calling item callback function:
#     - $_ITEM : The current item of the array.
#     - $_ARG1 : Caller specified item callback arg 1.
#     - $_ARG2 : Caller specified item callback arg 2.
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
#     N/A
##############################################################################

# Shortcuts to declare the function for installer/uninstaller:
!define DECLARE_LoopArray   '!insertmacro _DECLARE_LoopArray ""'
!define DECLARE_UnLoopArray '!insertmacro _DECLARE_LoopArray "un."'

# Shortcut to call the function:
!define LoopArray           '!insertmacro _LoopArrayCall'

!macro _LoopArrayCall _SPEC _ITEM_CALLBACK _ARG1 _ARG2
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

    !undef _FUNC_PREFIX
!macroend

# Definition of the function body:
!macro _DECLARE_LoopArray _PREFIX
    Function ${_PREFIX}_LoopArrayFunc
        # Incoming parameters has been put on the stack:
        Exch      $R3    # Item callback arg 2
        ${ExchAt} 1 $R2  # Item callback arg 1
        ${ExchAt} 2 $R1  # Item callback address
        ${ExchAt} 3 $R0  # Array specification

        Push $R4         # Item index, 1 based
        Push $R5         # Item count
        Push $R6         # Current item

        # Count items: items are delimited by newline (\n):
        ${CountFields} "$R0" "$\n" $R5

        # ??? Debug:
        ${Log} "### Array items: $R5"

        # Loop all items:
        ${For} $R4 1 $R5
            # Get current item (item no. $R4):
            ${WordFindS} "$R0" "$\n" "+$R4" $R6

            # Trim white space from both ends of the item.  WordFindS cannot
            # support empty fields correctly, so we have to put white spaces
            # in empty fields and trim them afterward.
            ${TrimString} $R6 $R6

            # ??? Debug:
            ${Log} "### Array item $R4: [$R6]"

            # Put item on the stack:
            Push $R6

            # Call the row callback function:
            Push $R2  # Row callback arg 1
            Push $R3  # Row callback arg 2
            Call $R1
        ${Next}

        # Restore the stack:
        Pop $R6
        Pop $R5
        Pop $R4
        Pop $R3
        Pop $R2
        Pop $R1
        Pop $R0
    FunctionEnd
!macroend

##############################################################################
# Function LoopMatrix $_SPEC $_ROW_CALLBACK $_ARG1 $_ARG2                 {{{1
#   Loop through rows of the input text matrix.
#
#   This function will loop through all rows of the input text matrix, and
#   call the row callback function for each row, with content of all columns
#   of that row pushed onto stack.
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
#   The following content will be pushed onto stack when calling the row
#   callback function:
#     - $_COL1 : Column 1 of the current row.
#     - $_COL2 : Column 2 of the current row.
#     ...
#     - $_COLn : Column n of the current row.
#     - $_ARG1 : Caller specified item callback arg 1.
#     - $_ARG2 : Caller specified item callback arg 2.
#
#   Row callback function MUST aware number of column in the specified text
#   matrix, and restore the stack accordingly.
#
#   NSIS script does not support array, this function is a extremely
#   inefficient workaround (for 2D array).  It only works in limited cases.
#
#   Parameters:
#     The following parameters should be pushed onto stack in order.
#     - $_SPEC         : Matrix specification.
#     - $_ROW_CALLBACK : Row callback function.
#     - $_ARG1         : Row callback arg 1.
#     - $_ARG2         : Row callback arg 2.
#   Returns:
#     N/A
##############################################################################

# Shortcuts to declare the function for installer/uninstaller:
!define DECLARE_LoopMatrix   '!insertmacro _DECLARE_LoopMatrix ""'
!define DECLARE_UnLoopMatrix '!insertmacro _DECLARE_LoopMatrix "un."'

# Shortcut to call the function:
!define LoopMatrix           '!insertmacro _LoopMatrixCall'

!macro _LoopMatrixCall _SPEC _ROW_CALLBACK _ARG1 _ARG2
    !ifndef __UNINSTALL__
        !define _FUNC_PREFIX ""
    !else
        !define _FUNC_PREFIX "un."
    !endif

    Push `${_SPEC}`  # Matrix specification
    Push $R0
    GetFunctionAddress $R0 `${_ROW_CALLBACK}`
    Exch $R0         # Address of row callback
    Push `${_ARG1}`  # Argument 1
    Push `${_ARG2}`  # Argument 2
    Call ${_FUNC_PREFIX}_LoopMatrixFunc

    !undef _FUNC_PREFIX
!macroend

# Definition of the function body:
!macro _DECLARE_LoopMatrix _PREFIX
    Function ${_PREFIX}_LoopMatrixFunc
        # Incoming parameters has been put on the stack:
        Exch      $R3    # Row callback arg 2
        ${ExchAt} 1 $R2  # Row callback arg 1
        ${ExchAt} 2 $R1  # Row callback address
        ${ExchAt} 3 $R0  # Matrix specification

        Push $R4         # Row index, 1 based
        Push $R5         # Column index, 1 based
        Push $R6         # Row count
        Push $R7         # Column count
        Push $R8         # Current row
        Push $R9         # Current column

        # Count rows: rows are delimited by newline (\n):
        ${CountFields} "$R0" "$\n" $R6

        # Count columns: columns are delimited by vertical bar (|):
        ${WordFindS} "$R0" "$\n" "+1" $R8
        ${CountFields} "$R8" "|" $R7

        # ??? Debug:
        ${Log} "### Rows: $R6, Columns: $R7"

        # Loop all rows:
        ${For} $R4 1 $R6
            # Get current row (row no. $R4):
            ${WordFindS} "$R0" "$\n" "+$R4" $R8

            # Loop all columns on the current row:
            ${For} $R5 1 $R7
                # Get column no. $R5:
                ${WordFindS} "$R8" "|" "+$R5" $R9

                # Trim white space from both ends of the column.  WordFindS
                # cannot support empty fields correctly, so we have to put
                # white spaces in empty fields and trim them afterward.
                ${TrimString} $R9 $R9

                # ??? Debug:
                ${Log} "### Row $R4, Col $R5: [$R9]"

                # Put column on the stack:
                Push $R9
            ${Next}

            # Call the row callback function:
            Push $R2  # Row callback arg 1
            Push $R3  # Row callback arg 2
            Call $R1
        ${Next}

        # Restore the stack:
        Pop $R9
        Pop $R8
        Pop $R7
        Pop $R6
        Pop $R5
        Pop $R4
        Pop $R3
        Pop $R2
        Pop $R1
        Pop $R0
    FunctionEnd
!macroend

!endif # __HELPER_UTIL__NSH__
