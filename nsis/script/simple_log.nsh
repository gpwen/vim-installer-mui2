# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# simple_log.nsh
# Macros for simple debug log.
# Author: Guopeng Wen
#
# Note:
#   Don't use back-quotes (``) in the string to be logged.  Back-quotes have
#   been used in the library to quote incoming parameters, use back-quotes in
#   your log message will break some macros, notably Logged* series.

!ifndef __SIMPLE_LOG__NSH__
!define __SIMPLE_LOG__NSH__

!include "LogicLib.nsh"
!include "Util.nsh"

##############################################################################
# Global variables:                                                       {{{1
##############################################################################
Var _simple_log_fname   # Log file name
Var _simple_log_title   # Log title
Var _simple_log_fh      # Log file handle

##############################################################################
# DECLARE_SimpleLogFunctions                                              {{{1
#   Macro to declare all functions used by simple log.
##############################################################################

!define DECLARE_SimpleLogFunctions "!insertmacro _DECLARE_SimpleLogFunctions"
!macro _DECLARE_SimpleLogFunctions
    # Declare all functions for both installer & uninstaller:
    !insertmacro _DECLARE_LogGetLocalTimeFunc ""
    !insertmacro _DECLARE_LogGetLocalTimeFunc "un."

    !insertmacro _DECLARE_LogErrorsFunc ""
    !insertmacro _DECLARE_LogErrorsFunc "un."
!macroend

##############################################################################
# _LogGetLocalTime $_LOCAL_TIME                                           {{{1
#   Helper macro to get local time as ISO date/time string.
#
#   Parameters:
#     N/A
#   Returns:
#     $_LOCAL_TIME : Local time in ISO format.
##############################################################################
# Shortcut to call the function:
!define _LogGetLocalTime '!insertmacro _LogGetLocalTimeCall'

!macro _LogGetLocalTimeCall _LOCAL_TIME
    !ifndef __UNINSTALL__
        !define _FUNC_PREFIX ""
    !else
        !define _FUNC_PREFIX "un."
    !endif

    Call ${_FUNC_PREFIX}_LogGetLocalTimeFunc
    Pop ${_LOCAL_TIME}

    !undef _FUNC_PREFIX
!macroend

# Definition of the function body:
!macro _DECLARE_LogGetLocalTimeFunc _PREFIX
    Function ${_PREFIX}_LogGetLocalTimeFunc
        Push $R0
        Push $R1
        Push $R2
        Push $R3
        Push $R4
        Push $R5
        Push $R6

        # Get local time:
        ${GetTime} "" "L" $R0 $R1 $R2 $R3 $R4 $R5 $R6

        # Construct ISO date/time string:
        StrCpy $R0 "$R2-$R1-$R0 $R4:$R5:$R6"

        # Restore the stack & return result on stack:
        Pop  $R6
        Pop  $R5
        Pop  $R4
        Pop  $R3
        Pop  $R2
        Pop  $R1
        Exch $R0  # Return result
    FunctionEnd
!macroend

##############################################################################
# LogInit $_LOG_FILE $_LOG_TITLE                                          {{{1
#   Log initialization.
#
#   New file will be created if the specified log file does not exist;
#   Otherwise, existing log file will be opened for append.
#
#   Parameters:
#     $_LOG_FILE  : Name of the log file.
#     $_LOG_TITLE : Title of the log.
#   Returns:
#     None.
##############################################################################
!define LogInit `!insertmacro _LogInitCall`
!macro _LogInitCall _LOG_FILE _LOG_TITLE
    Push `${_LOG_FILE}`
    Push `${_LOG_TITLE}`
    ${CallArtificialFunction} _LogInit
!macroend
!macro _LogInit
    # Incoming parameters has been put on the stack:
    Exch $1   # Log title
    Exch
    Exch $0   # Log file name
    Exch

    # Create/open the specified log file:
    ${If} ${FileExists} `$0`
        SetFileAttributes `$0` NORMAL
        FileOpen $_simple_log_fh `$0` a
        FileSeek $_simple_log_fh 0 END
    ${Else}
        FileOpen $_simple_log_fh `$0` w
    ${EndIf}

    # Save log file name & log title:
    StrCpy $_simple_log_fname ``
    StrCpy $_simple_log_title ``
    ${If} $_simple_log_fh != ``
        StrCpy $_simple_log_fname `$0`
        StrCpy $_simple_log_title `$1`
    ${EndIf}

    # Get local time:
    ${_LogGetLocalTime} $0

    # Write log header:
    ${Log} "$0 - Start $_simple_log_title"

    # Restore the stack:
    Pop $1
    Pop $0
!macroend

##############################################################################
# LogReinit                                                               {{{1
#   Reinitialize log.
#
#   This macro will re-use the last open log file/title to re-initialize log.
##############################################################################
!define LogReinit `!insertmacro _LogReinit`
!macro _LogReinit
    # Make log has been closed:
    ${LogClose}

    # Initialize it again using save log file name:
    ${LogInit} $_simple_log_fname $_simple_log_title
!macroend

##############################################################################
# LogClose                                                                {{{1
#   Close the log.
##############################################################################
!define LogClose `!insertmacro _LogCloseCall`
!macro _LogCloseCall
    ${CallArtificialFunction} _LogClose
!macroend
!macro _LogClose
    ${If} $_simple_log_fh != ``
        Push $R0

        # Get local time:
        ${_LogGetLocalTime} $R0

        # Write close message:
        ${Log} "$R0 - Close $_simple_log_title"

        # Restore the stack:
        Pop $R0

        # Close the log.  We'll leave file name and log title intact so that
        # it's possible to reopen the log.
        FileClose $_simple_log_fh
        StrCpy $_simple_log_fh ``
    ${EndIf}
!macroend

##############################################################################
# Log $_LOG_MSG                                                           {{{1
#   Log the specified message.
#
#   Parameters:
#     $_LOG_MSG : String to be logged.  CR/LF will be appended.
#   Returns:
#     None.
##############################################################################
!define Log `!insertmacro _Log`
!macro _Log _LOG_MSG
    ${If} $_simple_log_fh != ``
        FileWrite $_simple_log_fh `${_LOG_MSG}$\r$\n`
    ${EndIf}
!macroend

##############################################################################
# LogPrint $_LOG_MSG                                                      {{{1
#   Write the specified message to log file as well as NSIS detailed log
#   window.  Please note message written to the detailed log window before the
#   creation of that window will be lost.
#
#   Parameters:
#     $_LOG_MSG : String to be logged.
#   Returns:
#     None.
##############################################################################
!define LogPrint `!insertmacro _LogPrint`
!macro _LogPrint _LOG_MSG
    ${Log} `${_LOG_MSG}`
    DetailPrint `${_LOG_MSG}`
!macroend

##############################################################################
# LogErrors $_CMD                                                         {{{1
#   Helper macro to log error status.
#
#   Write error message to log if the error flag is set.  Otherwise, nothing
#   will be written.  Error flag will not be cleared.
#
#   Parameters:
#     $_CMD : Name of the command to be used in error log.
#   Returns:
#     None.
##############################################################################

# Shortcut to call the function:
!define LogErrors '!insertmacro _LogErrorsCall'

!macro _LogErrorsCall _CMD
    !ifndef __UNINSTALL__
        !define _FUNC_PREFIX ""
    !else
        !define _FUNC_PREFIX "un."
    !endif

    Push ${_CMD}
    Call ${_FUNC_PREFIX}_LogErrorsFunc

    !undef _FUNC_PREFIX
!macroend

# Definition of the function body:
!macro _DECLARE_LogErrorsFunc _PREFIX
    Function ${_PREFIX}_LogErrorsFunc
        Exch $0   # $_CMD
        ${If} ${Errors}
            # Log error flag:
            ${Log} `ERROR: The last $0 instruction has recoverable error!`

            # Make sure error flag is not cleared:
            SetErrors
        ${EndIf}
        Pop $0
    FunctionEnd
!macroend

##############################################################################
# Logged* $_CMD $_PARAM*                                                  {{{1
#   The following macros are used to log commands of 0/1/2/3/4 parameter(s).
#   You can simply prefix these macros to NSIS commands, the command as well
#   as it's parameters will be logged before execution.
#
#   Parameters:
#     $_CMD    : Command to run.
#     $_PARAM1 : Parameter 1.
#     $_PARAM2 : Parameter 2.
#     $_PARAM3 : Parameter 3.
#     $_PARAM4 : Parameter 4.
#     $_PARAM5 : Parameter 5.
#   Returns:
#     None.
##############################################################################
!define Logged0 `!insertmacro _Logged0`
!macro _Logged0 _CMD
    ${Log} `${_CMD}`
    `${_CMD}`
    ${LogErrors} `${_CMD}`
!macroend

!define Logged1 `!insertmacro _Logged1`
!macro _Logged1 _CMD _PARAM1
    ${Log} `${_CMD} ${_PARAM1}`
    `${_CMD}` `${_PARAM1}`
    ${LogErrors} `${_CMD}`
!macroend

!define Logged2 `!insertmacro _Logged2`
!macro _Logged2 _CMD _PARAM1 _PARAM2
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}`
    ${LogErrors} `${_CMD}`
!macroend

!define Logged3 `!insertmacro _Logged3`
!macro _Logged3 _CMD _PARAM1 _PARAM2 _PARAM3
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2} ${_PARAM3}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}` `${_PARAM3}`
    ${LogErrors} `${_CMD}`
!macroend

!define Logged4 `!insertmacro _Logged4`
!macro _Logged4 _CMD _PARAM1 _PARAM2 _PARAM3 _PARAM4
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2} ${_PARAM3} ${_PARAM4}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}` `${_PARAM3}` `${_PARAM4}`
    ${LogErrors} `${_CMD}`
!macroend

!define Logged5 `!insertmacro _Logged5`
!macro _Logged5 _CMD _PARAM1 _PARAM2 _PARAM3 _PARAM4 _PARAM5
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2} ${_PARAM3} ${_PARAM4} ${_PARAM5}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}` `${_PARAM3}` `${_PARAM4}` `${_PARAM5}`
    ${LogErrors} `${_CMD}`
!macroend

##############################################################################
# Logged*Reopen $_CMD $_PARAM*                                            {{{1
#   The following are special variant of the above $Logged* macros, which will
#   close the log file before execution the command, and reopen the log file
#   after that.  It's used to log execution of external commands that will
#   write to the same log file.
#
#   Parameters:
#     $_CMD    : Command to run.
#     $_PARAM1 : Parameter 1.
#     $_PARAM2 : Parameter 2.
#     $_PARAM3 : Parameter 3.
#     $_PARAM4 : Parameter 4.
#     $_PARAM5 : Parameter 5.
#   Returns:
#     None.
##############################################################################
!define Logged2Reopen `!insertmacro _Logged2Reopen`
!macro _Logged2Reopen _CMD _PARAM1 _PARAM2
    Push $R0

    # Log command to be executed and close log file:
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2}`
    ${LogClose}

    # Execute the command, save error status to $R0:
    StrCpy $R0 0
    `${_CMD}` `${_PARAM1}` `${_PARAM2}`
    ${If} ${Errors}
        StrCpy $R0 1
    ${EndIf}

    # Reopen the log:
    ${LogReinit}

    # Log and restore error status:
    ${If} $R0 <> 0
        SetErrors
        ${LogErrors} `${_CMD}`
    ${EndIf}

    Pop $R0
!macroend

##############################################################################
# LoggedQuit $_EXIT_CODE                                                  {{{1
#   Close log and exit the installer with Quit.
#
#   Parameters:
#     $_EXIT_CODE : Exit code to set before quit.
#   Returns:
#     None.
##############################################################################
!define LoggedQuit `!insertmacro _LoggedQuit`
!macro _LoggedQuit _EXIT_CODE
    # Write final log and close the log:
    ${Log} "About to quit with exit code ${_EXIT_CODE}."
    ${LogClose}

    # Set exit code:
    SetErrorLevel ${_EXIT_CODE}

    # Quit:
    Quit
!macroend

##############################################################################
# LoggedAbort $_EXIT_CODE                                                 {{{1
#   Quit the installer (logged quit) in silent mode; Abort otherwise.
#
#   This should be used in callback function to give user a second chance to
#   make correction in the GUI mode.
#
#   Parameters:
#     $_EXIT_CODE : Exit code to set if quit.
#   Returns:
#     None.
##############################################################################
!define LoggedAbort `!insertmacro _LoggedAbort`
!macro _LoggedAbort _EXIT_CODE
    # Quit in silent mode, let user try again in GUI mode:
    ${If} ${Silent}
        ${LoggedQuit} ${VIM_QUIT_PARAM}
    ${Else}
        Abort
    ${EndIf}
!macroend

##############################################################################
# LogSectionStart                                                         {{{1
#   Log start of a section.
#   This macro should be inserted at the beginning of a section.
##############################################################################
!define LogSectionStart `!insertmacro _LogSectionStart`
!macro _LogSectionStart
    !ifdef __SECTION__
        ${Log} `$\r$\nEnter section ${__SECTION__}`
    !endif
!macroend

##############################################################################
# LogSectionEnd                                                           {{{1
#   Log end of a section.
#   This macro should be inserted at the end of a section.
##############################################################################
!define LogSectionEnd `!insertmacro _LogSectionEnd`
!macro _LogSectionEnd
    !ifdef __SECTION__
        ${Log} `Leave section ${__SECTION__}`
    !endif
!macroend

##############################################################################
# LogChkSectionFlag _FLAG _BIT_MASK _SET_TEXT _RESULT                     {{{1
#   Helper macro to interpret section flag.
#
#   Parameters:
#     $_FLAG     : Section flag to test.
#     $_BIT_MASK : Flag bit mask to test.
#     $_SET_TEXT : Text to append when the bit is set.
#     $_RESULT   : Result string (to append the interpretion).
#   Returns:
#     None.
##############################################################################
!define LogChkSectionFlag `!insertmacro _LogChkSectionFlag`
!macro _LogChkSectionFlag _FLAG _BIT_MASK _SET_TEXT _RESULT
    Push $R0

    IntOp $R0 ${_FLAG} & ${_BIT_MASK}
    ${If} $R0 = ${_BIT_MASK}
        ${IfThen} ${_RESULT} S!= "" \
            ${|} StrCpy ${_RESULT} "${_RESULT}|" ${|}
        StrCpy ${_RESULT} "${_RESULT}${_SET_TEXT}"
    ${EndIf}

    Pop $R0
!macroend

##############################################################################
# LogSectionStatus _MAX_SECTION                                           {{{1
#   Log section status, mostly for debug purpose.
#
#   Parameters:
#     $_MAX_SECTION : Upper limit (exclusive) of the section ID to log.
#   Returns:
#     None.
##############################################################################
!define LogSectionStatus `!insertmacro _LogSectionStatusCall`

!macro _LogSectionStatusCall _MAX_SECTION
    Push `${_MAX_SECTION}`
    ${CallArtificialFunction} _LogSectionStatus
!macroend

!macro _LogSectionStatus
    # Incoming parameters has been put on the stack:
    Exch $0   # Upper limit (exclusive) of the section ID to log
    Push $R0  # Section ID
    Push $R1  # Section status string
    Push $R2  # Section properties

    ${Log} "Section status:"

    # Loop all sections:
    ${For} $R0 0 $0
        # Get section flag & skip invalid sections:
        SectionGetFlags $R0 $R2
        ${IfThen} ${Errors} ${|} ${Continue} ${|}

        # Interpret section flags:
        StrCpy $R1 ""
        ${LogChkSectionFlag} $R2 ${SF_SELECTED}  "SEL"     $R1
        ${LogChkSectionFlag} $R2 ${SF_SECGRP}    "GRP"     $R1
        ${LogChkSectionFlag} $R2 ${SF_SECGRPEND} "GRPEND"  $R1
        ${LogChkSectionFlag} $R2 ${SF_BOLD}      "BOLD"    $R1
        ${LogChkSectionFlag} $R2 ${SF_RO}        "RO"      $R1
        ${LogChkSectionFlag} $R2 ${SF_EXPAND}    "EXPAND"  $R1
        ${LogChkSectionFlag} $R2 ${SF_PSELECTED} "PSEL"    $R1
        ${LogChkSectionFlag} $R2 ${SF_TOGGLED}   "TOGGLE"  $R1
        ${LogChkSectionFlag} $R2 ${SF_NAMECHG}   "NAMECHG" $R1

        ${If} $R1 S!= ""
            StrCpy $R1 " [$R1]"
        ${EndIf}

        StrCpy $R1 "  Section $R0: Flags=$R2$R1"

        # Show other section properties:
        SectionGetInstTypes $R0 $R2
        StrCpy $R1 "$R1, InstTypes=$R2"

        SectionGetSize $R0 $R2
        StrCpy $R1 "$R1, Size=$R2"

        SectionGetText $R0 $R2
        StrCpy $R1 "$R1, Text=[$R2]"

        # Log section status:
        ${Log} "$R1"
    ${Next}

    # Restore the stack:
    Pop $R2
    Pop $R1
    Pop $R0
    Pop $0
!macroend

##############################################################################
# LogStack                                                                {{{1
#   Debug macro to log stack status, needs System plugin.
#
#   Please note if the NSIS has N items, this macro needs to use as many as
#   (20N + 1) items on the private stack of the System plugin to dump them.
#   Use with caution.
#
#   Parameters: None
#   Returns:    None
##############################################################################
!define LogStack `!insertmacro _LogStackCall`
!macro _LogStackCall
    ${CallArtificialFunction} _LogStack
!macroend

!macro _LogStack
    System::Store "s"  # Save all registers

    ${Log} "=== Begin Stack Dump (Top) ==="

    # Move content of NSIS stack to the private stack of the System plugin,
    # and show content of stack during the process:
    #   $R0 : Stack content
    #   $R1 : Item counter
    # Please note we HAVE TO save all registers (20 of them) for each item on
    # NSIS stack, that will bloat content saved on the private stack 20x!  I
    # really wish I have a better way to enumerate stack content from script
    # without destroy the stack.
    StrCpy $R1 0
    ${Do}
        # Pop NSIS stack, until it's empty:
        Pop $R0
        ${If} ${Errors}
            ${ExitDo}
        ${EndIf}

        # Save ALL registers to the private stack of the System plugin.  This
        # seems to be the only way to use that private stack.
        System::Store "s"

        # Show stack content:
        ${Log} "  Stack Item #$R1: $R0"

        # Count number of items found on the stack:
        IntOp $R1 $R1 + 1
    ${LoopUntil} ${Errors}

    # Clear error:
    ClearErrors

    ${Log} "=== End Stack Dump (Bottom) ==="

    # Restore NSIS stack from private stack of the System plugin:
    ${While} $R1 > 0
        # Restore all registers.  As a side effect, our item counter are also
        # restored, that makes it easier to determine the end of loop:
        System::Store "l"
        Push $R0
    ${EndWhile}

    System::Store "l"  # Restore all registers
!macroend

##############################################################################
# ShowMsg $_MSG                                                           {{{1
#   Show general message.
#
#   The specified message will be written to log file, show in NSIS detailed
#   log window, and show in a popup dialog box unless the silent mode has been
#   enabled.
#
#   Parameters:
#     $_MSG : The message to show.
##############################################################################
!define ShowMsg `!insertmacro _ShowMsgCall`
!macro _ShowMsgCall _MSG
    Push `${_MSG}`
    ${CallArtificialFunction} _ShowMsg
!macroend
!macro _ShowMsg
    # Incoming parameters has been put on the stack:
    Exch $0

    # Write message to debug log:
    ${Log} `$0`

    # Also show message in NSIS detailed log window.  This might not work if
    # the detailed log window has not been created yet.
    DetailPrint `$0`

    # Show message box only if we're not in silent install mode:
    ${IfNot} ${Silent}
        MessageBox MB_OK|MB_ICONINFORMATION `$0` /SD IDOK
    ${EndIf}

    # Restore the stack:
    Pop $0
!macroend

##############################################################################
# ShowErr $_ERR_MSG                                                       {{{1
#   Show error message.
#
#   The specified error message will be written to log file, show in NSIS
#   detailed log window, and show in a popup dialog box unless the silent mode
#   has been enabled.
#
#   Parameters:
#     $_ERR_MSG : Error message.
##############################################################################
!define ShowErr `!insertmacro _ShowErrCall`
!macro _ShowErrCall _ERR_MSG
    Push `${_ERR_MSG}`
    ${CallArtificialFunction} _ShowErr
!macroend
!macro _ShowErr
    # Incoming parameters has been put on the stack:
    Exch $0

    # Write error message to debug log:
    ${Log} `ERROR: $0`

    # Also show error message in NSIS detailed log window.  This might not
    # work if the detailed log window has not been created yet.
    DetailPrint `$0`

    # Show message box only if we're not in silent install mode:
    ${IfNot} ${Silent}
        MessageBox MB_OK|MB_ICONEXCLAMATION `$0` /SD IDOK
    ${EndIf}

    # Restore the stack:
    Pop $0
!macroend

!endif # __SIMPLE_LOG__NSH__
