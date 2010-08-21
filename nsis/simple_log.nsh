# vi:set ts=8 sts=4 sw=4 fdm=marker:
#
# simple-log.nsi
# Macros for simple debug log.
# Author: Guopeng Wen
#
# Note:
# Don't use backquote (``) in the string to be logged.  Backquote has been
# used in the library to quote incoming parameters, use backquote in your log
# message will break some macros, notably Logged* series.

!ifndef __SIMPLE_LOG__NSH__
!define __SIMPLE_LOG__NSH__

!include "FileFunc.nsh"
!include "Util.nsh"

# Global variables:
Var _simple_log_fname   # Log file name
Var _simple_log_title   # Log title
Var _simple_log_fh      # Log file handle

# Helper macro to get local time as ISO date/time string.  Please note this
# macro will store output string in $R0 directly.
!macro _LogGetLocalTime
    Push $R1
    Push $R2
    Push $R3
    Push $R4
    Push $R5
    Push $R6

    # Get local time.  Please note this macro will be inserted into artificial
    # function, so the simple GetTime macro cannot be used.
    Push ""
    Push "L"
    ${CallArtificialFunction2} GetTime_
    Pop $R0
    Pop $R1
    Pop $R2
    Pop $R3
    Pop $R4
    Pop $R5
    Pop $R6

    # Construct ISO date/time string and stored in $R0 directly.
    StrCpy $R0 "$R2-$R1-$R0 $R4:$R5:$R6"

    # Restore the stack:
    Pop  $R6
    Pop  $R5
    Pop  $R4
    Pop  $R3
    Pop  $R2
    Pop  $R1
!macroend

# Log initialization.
#
# New file will be created if the specified log file does not exist;
# Otherwise, existing log file will be opened for append.
# Parameters:
#   $_LOG_FILE  : Name of the log file.
#   $_LOG_TITLE : Title of the log.
# Returns:
#   None.
!define LogInit `!insertmacro _LogInitCall`
!macro _LogInitCall _LOG_FILE _LOG_TITLE
    Push `${_LOG_FILE}`
    Push `${_LOG_TITLE}`
    ${CallArtificialFunction} _LogInit
!macroend
!macro _LogInit
    # Incoming parameters has been put on the stack:
    Exch $R1   # Log title
    Exch
    Exch $R0   # Log file name
    Exch

    # Create/open the specified log file:
    ${If} ${FileExists} `$R0`
        SetFileAttributes `$R0` NORMAL
        FileOpen $_simple_log_fh `$R0` a
        FileSeek $_simple_log_fh 0 END
    ${Else}
        FileOpen $_simple_log_fh `$R0` w
    ${EndIf}

    # Save log file name & log title:
    StrCpy $_simple_log_fname ``
    StrCpy $_simple_log_title ``
    ${If} $_simple_log_fh != ``
        StrCpy $_simple_log_fname `$R0`
        StrCpy $_simple_log_title `$R1`
    ${EndIf}

    # Get local time (stores in $R0):
    !insertmacro _LogGetLocalTime

    # Write log header:
    ${Log} "$R0 - Start $_simple_log_title"

    # Restore the stack:
    Pop $R1
    Pop $R0
!macroend

# Reinitialize log.
#
# This macro will re-use the last open log file/title to re-initialize log.
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

        # Get local time (stores in $R0):
        !insertmacro _LogGetLocalTime

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

# Log the specified message.
# Parameters:
#   $_LOG_MSG : String to be logged.  CR/LF will be appended.
# Returns:
#   None.
!define Log `!insertmacro _Log`
!macro _Log _LOG_MSG
    ${If} $_simple_log_fh != ``
        FileWrite $_simple_log_fh `${_LOG_MSG}$\r$\n`
    ${EndIf}
!macroend

# Write the specified message to log file as well as NSIS detailed log window.
# Please note message written to the detailed log window before the creation
# of that window will be lost.
# Parameters:
#   $_LOG_MSG : String to be logged.  CR/LF will be appended.
# Returns:
#   None.
!define LogPrint `!insertmacro _LogPrint`
!macro _LogPrint _LOG_MSG
    ${Log} `${_LOG_MSG}`
    DetailPrint `${_LOG_MSG}`
!macroend

# Helper macro to log error status.
#
# Write error message to log if the error flag is set.  Otherwise, nothing
# will be written.  Error flag will not be cleared.
#
# Parameters:
#   $_CMD : Name of the command to be used in error log.
# Returns:
#   None.
!define LogErrors `!insertmacro _LogErrors`
!macro _LogErrors _CMD
    ${If} ${Errors}
        # Log error flag:
        ${Log} `ERROR: The last ${_CMD} instruction has recoverable error!`

        # Make sure error flag is not cleared:
        SetErrors
    ${EndIf}
!macroend

# The following macros are used to log commands of 0/1/2/3/4 parameter(s).
# You can simply prefix these macros to NSIS commands, the command as well as
# it's parameters will be logged before execution.
# Parameters:
#   $_CMD    : Command to run.
#   $_PARAM1 : Parameter 1.
#   $_PARAM2 : Parameter 2.
#   $_PARAM3 : Parameter 3.
#   $_PARAM4 : Parameter 4.
# Returns:
#   None.
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

# The following are special variant of the above $Logged* macros, which will
# close the log file before execution the command, and reopen the log file
# after that.  It's used to log execution of external commands that will write
# to the same log file.
#
# Parameters:
#   $_CMD    : Command to run.
#   $_PARAM1 : Parameter 1.
#   $_PARAM2 : Parameter 2.
#   $_PARAM3 : Parameter 3.
#   $_PARAM4 : Parameter 4.
# Returns:
#   None.
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

# Log start of a section.
# This macro should be inserted at the beginning of a section.
!define LogSectionStart `!insertmacro _LogSectionStart`
!macro _LogSectionStart
    !ifdef __SECTION__
        ${Log} `$\r$\nEnter section ${__SECTION__}`
    !endif
!macroend

# Log end of a section.
# This macro should be inserted at the end of a section.
!define LogSectionEnd `!insertmacro _LogSectionEnd`
!macro _LogSectionEnd
    !ifdef __SECTION__
        ${Log} `Leave section ${__SECTION__}`
    !endif
!macroend

# Show error message.
# The specified error message will be written to log file, show in NSIS
# detailed log window, and show in a popup dialog box unless the silent mode
# has been enalbed.
# Parameters:
#   $_ERR_MSG : Error message.
!define ShowErr `!insertmacro _ShowErrCall`
!macro _ShowErrCall _ERR_MSG
    Push `${_ERR_MSG}`
    ${CallArtificialFunction} _ShowErr
!macroend
!macro _ShowErr
    # Incoming parameters has been put on the stack:
    Exch $R0

    # Write error message to debug log:
    ${Log} `ERROR: $R0`

    # Also show error message in NSIS detailed log window.  This might not
    # work if the detailed log window has not been created yet.
    DetailPrint `$R0`

    # Show message box only if we're not in silent install mode:
    ${IfNot} ${Silent}
        MessageBox MB_OK|MB_ICONEXCLAMATION `$R0` /SD IDOK
    ${EndIf}

    # Restore the stack:
    Pop $R0
!macroend

!endif # __SIMPLE_LOG__NSH__
