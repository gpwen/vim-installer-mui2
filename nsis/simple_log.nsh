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

# Close log.
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
