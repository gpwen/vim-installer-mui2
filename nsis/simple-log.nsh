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

!include Util.nsh

# Global variables:
Var _simple_log_fname   # Log file name
Var _simple_log_fh      # Log file handle

# Log initialization.
#
# New file will be created if the specified log file does not exist;
# Otherwise, existing log file will be opened for append.
# Parameters:
#   $_LOG_FILE : Name of the log file.
# Returns:
#   None.
!define LogInit `!insertmacro _LogInitCall`
!macro _LogInitCall _LOG_FILE
    Push `${_LOG_FILE}`
    ${CallArtificialFunction} _LogInit
!macroend
!macro _LogInit
    # Incoming parameters has been put on the stack:
    Exch $R0

    # Create/open the specified log file:
    ${If} ${FileExists} `$R0`
        FileOpen $_simple_log_fh `$R0` w
    ${Else}
        SetFileAttributes `$R0` NORMAL
        FileOpen $_simple_log_fh `$R0` a
        FileSeek $_simple_log_fh 0 END
    ${EndIf}

    # Save log file name:
    StrCpy $_simple_log_fname ``
    ${If} $_simple_log_fh != ``
        StrCpy $_simple_log_fname `$R0`
    ${EndIf}

    # Restore the stack:
    Pop $R0
!macroend

# Reinitialize log.
#
# This macro will use the last open log file to re-initialize log.
!define LogReinit `!insertmacro _LogReinit`
!macro _LogReinit
    # Make log has been closed:
    ${LogClose}

    # Initialize it again using save log file name:
    ${LogInit} $_simple_log_fname
!macroend

# Close log.
!define LogClose `!insertmacro _LogClose`
!macro _LogClose
    ${If} $_simple_log_fh != ``
        FileClose $_simple_log_fh
        StrCpy $_simple_log_fh ``
        # SetFileAttributes `${_LOG_FILE}` READONLY|SYSTEM|HIDDEN
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
!macroend

!define Logged1 `!insertmacro _Logged1`
!macro _Logged1 _CMD _PARAM1
    ${Log} `${_CMD} ${_PARAM1}`
    `${_CMD}` `${_PARAM1}`
!macroend

!define Logged2 `!insertmacro _Logged2`
!macro _Logged2 _CMD _PARAM1 _PARAM2
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}`
!macroend

!define Logged3 `!insertmacro _Logged3`
!macro _Logged3 _CMD _PARAM1 _PARAM2 _PARAM3
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2} ${_PARAM3}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}` `${_PARAM3}`
!macroend

!define Logged4 `!insertmacro _Logged4`
!macro _Logged4 _CMD _PARAM1 _PARAM2 _PARAM3 _PARAM4
    ${Log} `${_CMD} ${_PARAM1} ${_PARAM2} ${_PARAM3} ${_PARAM4}`
    `${_CMD}` `${_PARAM1}` `${_PARAM2}` `${_PARAM3}` `${_PARAM4}`
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
