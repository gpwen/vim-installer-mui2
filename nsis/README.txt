Files in this directory are used to build the Vim self-installing executable
(NSIS installer) for Windows with Nullsoft Scriptable Install System (NSIS).
The following guide shows how to build the installer.

==============================================================================
I. Build Instruction for Vim NSIS Installer
==============================================================================

1.  Software requirement:

    - NSIS (2.46 or above).  This is required to build the installer.  It's
      available at:
        http://nsis.sourceforge.net/
      The NSIS install directory should be added to the PATH environment.

    - UPX.  This is required if you want a compressed installer.  It's
      available at:
        http://upx.sourceforge.net/
      The UPX install directory should be added to the PATH environment.

    - Build environment for Vim.

2.  Prepare Vim source code for DOS/Windows build

    To build the Windows installer, the source tree of Vim needs to be
    rearranged, and also some EOL conversion needs to be performed.

    You can simply download the following two prepared source archives from
    Vim online (http://www.vim.org/download.php#pc):
	PC sources    (vim##src.zip)
	Runtime files (vim##rt.zip)
    and unpack them to your build directory.

    You can also generated those archives yourself from the latest Vim source
    code, see the Makefile in the top directory for detail.  You need a
    UNIX-like environment for such purpose, those archives can be generated
    with the following make commands:
        make dossrc
        make dosrt

3.  Go to the src/ directory and build Windows 95/98/ME console version of
    Vim.  Rename the output vim.exe as vimd32.exe and store it elsewhere.

4.  Go to the src/ directory and build Windows NT/2000/XP console version of
    Vim.  Rename the output vim.exe as vimw32.exe and store it elsewhere.

5.  Go to the src/ directory and build the GUI version of Vim, with OLE
    support enabled.  After build complete, you should rename the following
    outputs:
	src/gvim.exe    -> src/gvim_ole.exe
	src/xxd\xxd.exe -> src/xxdw32.exe

6.  Copy those renamed executables created in steps 3 and 4 back into the src\
    directory.

7.  Go to the src/GvimExt/ directory and
    - Build 32-bit version of gvimext.dll, rename it to gvimext32.dll;
    - Build 64-bit version of gvimext.dll, rename it to gvimext64.dll.
    You may install the official release of Vim from here:
        http://www.vim.org/download.php#pc
    and copy them from the binary directory.

8.  Go to the src/VisVim/ directory and build VisVim.dll (or get it from
    installed Vim).

9.  Get a "diff.exe" program (for example, from installed Vim) and put it in
    the "../.." directory (above the "vim##" directory, it's the same for all
    Vim versions).

10. Go to src/nsis/ to build the installer with:
	makensis gvim.nsi

==============================================================================
II. User Manual for Vim NSIS Installer
==============================================================================

User manual of the installer can be found here:
    nsis/data/install_manual.txt

==============================================================================
III. Specify Files to be Installed with Templates
==============================================================================

1. Introduction
------------------------------------------------------------------------------

NSIS provides very basic support to manipulate files on the target system.
For example, you can directly specify what files to be installed on the target
system in the installer, and what to be removed in the un-installer.  These
two sets of files are specified independent of each other.  Such scheme is
very flexible and powerful.  However, one would generally expect that the
un-installer removes whatever the installer installed, nothing more, nothing
less.  NSIS does not provide direct support for such feature.  The most
straightforward approach is removing each individual file explicitly with NSIS
commands, without using wild-cards or removing non-empty directories.
Needless to say, such process could be very tedious and error-prone.

Many different methods have been designed to work around such limitation to
make it easier to install/remove exactly the same set of files, for example:

- A log file can be created to record everything the installer installed, and
  later the un-installer can remove them according to the log file:
      http://nsis.sourceforge.net/Uninstall_only_installed_files

- An external utility can be used to generate NSIS file install/un-install
  commands from the same configuration:
      http://nsis.sourceforge.net/Talk:Uninstall_only_installed_files

The second approach is taken here.  To avoid external dependency, a Vim script
is used to generate NSIS commands:
    nsis/script/gen_file_list.vim
Two config files are used to specify files to be included in the installer
from the build system:
- A template definition file.
- An optional macro definition file.

The following sections will describe how the Vim script works, and the format
of those two files, which is necessary if you need to modify files to be
included in the installer.

Section 2 describes how the script works;  Section 3 and 4 describes common
formats of those config files;  Section 5 and 6 describe the format for macro
definition file and template definition file, respectively;  Section 7 lists
all template definitions currently in use.


2. How gen_file_list.vim works
------------------------------------------------------------------------------

As mentioned in the above section, gen_file_list.vim will generate NSIS file
install/un-install commands from the same config file(s) so that it's easier
to install/remove exactly the same set of files.  Two files are used to
specify files to be installed (removed):

- A template definition file.  This file is used to specify files to be
  installed (removed).  Vim glob() pattern is used to specify which files on
  the build system should be included.

- An optional macro definition file.  This file is used to define some macros
  that can be referenced in the template definition file.  It's mainly used to
  export macros defined in the NSIS script, such as target path and source
  path etc.  Currently this file is automatically generated by the main NSIS
  script.

When sourced, the script assumes the current Vim buffer contains template
definition.  Other parameters are specified using the following global
variables:

- g:gen_fcmds_fname_defines
  Name of the macro definition file, default to be "vim_defines.conf".

- g:gen_fcmds_fname_install
  Name of the file to hold generated NSIS install commands, default to be
  "install-cmds.nsi".

- g:gen_fcmds_fname_uninst
  Name of the file to hold generated NSIS un-install commands, default to be
  "uninst-cmds.nsi".

- g:gen_fcmds_debug_on
  Debug flag.  Default to be 1 (on).

The default setting makes it easier to debug the script directly.

The script will perform the following steps to generate NSIS commands:

- If the specified macro definition file exists, load all macros defined in
  that file.

- Parse templates in the current Vim buffer.  For each template found:
  - Performs macro substitution;
  - Expand file patterns specified in the template with Vim glob() function;
  - Generate NSIS file install/un-install commands, and record new directory
    created.

- After all templates have been processed, generate NSIS commands to remove
  empty directories according to the new directory list.

- Save NSIS install/un-install commands to the specified files and exit.

Those generated NSIS scripts can then be included as part of the main NSIS
script to generate the installer/un-installer.  The following two macros are
used in main NSIS script to run the above Vim script and pulls in the
generated commands:
    VimGenFileCmdsInstall
    VimGenFileCmdsUninstall

They perform the following operations:
- Config global variables used by the Vim script.
- Launch Vim to run the Vim script to generate NSIS commands.
- Pull in the generated NSIS install/un-install scripts.

The first macro should be used in the install section, it will pull in the
generated install script; the second macro should be used in the corresponding
un-install section to pull in the generated un-install script.

To debug the Vim script, you need to open a template definition file in Vim
first.  Make sure you have the following macro definition file under the
current working directory:
    vim_defines.conf
That file will be generated each time you run:
    makensis gvim.nsi

Next, source in the Vim script directly:
    :so gen_file_list.vim

Several new buffers will be created, and newly generated NSIS command is
contained in them.

Next, we'll go through formats of those definition files.


3. Comment Lines
------------------------------------------------------------------------------

Comment lines are supported in both macro definition file and template
definition file.  A line is considered to be a comment line if the first
non-blank character of that line is '#'.  All comment lines are ignored when
parsing the definition file.


4. Line Continuation
------------------------------------------------------------------------------

Both macro definition and template definition can be split into multiple
lines.  If the last non-white-space character of a line is a backslash
preceded by at least one white-space character (or nothing, in case the
backslash happens to be the first character of the line), the next line is
treated as an addition to the current line.  However, if the next line is a
blank line, comment line or EOF, the current line will be terminated even if
line continuation character presents.  The line continuation character
(backslash character and white-space characters around it) will be removed
before joining or terminating a line.

To include backslash character itself as the last character of a line (avoid
it to be treated as line continuation character), another backslash should be
added to escape it (i.e., use two backslashes in tandem).  The script will
process line continuation escape sequence immediately after detection of line
continuation.


5. Format of Macro Definition File
------------------------------------------------------------------------------

A macro definition file is used to define macros that can be referenced in
template definitions, it will be loaded before parsing template definitions.
The name of the macro definition file should be specified in global variable:
    g:gen_fcmds_fname_defines
The default file name is "vim_defines.conf".

Each line in the macro definition file should be one of:
- Blank line (lines with zero or more blank characters only); or
- Comment line; or
- Macro definition line.
The format of a macro definition line is:
  <NAME> = <VALUE>
where
- <NAME> is the name of the macro.  It can be referenced in template
  definition as ${<NAME>}.
- <VALUE> is the value of macro.

When parsing macro definition, white spaces at both ends of each definition
line, as well as white spaces surrounding the equal sign will be removed.

Macro expansion will be performed only once, therefore, recursive macro
definition is not supported.


6. Format of Template Definition File
------------------------------------------------------------------------------

The template definition file is used to specify files to be included in the
installer.  It uses Vim glob() pattern to specify files to be included from
the build system.

Each line in the template definition file should be one of:
- Blank line; or
- Comment line; or
- Template definition line.

The template definition line has the following format:
  <target-path> | <src-root> | <src-patterns>

where:

- <target-path> is the path name on the target system where source file(s)
  should be installed.  The path name will be used literally in the generated
  command except slash conversion and cleanup.  NSIS variables can be used
  here.  Either forward slash or backslash can be used as path separator, they
  will be converted to backward slash automatically.

- <src-root> is the root path for the source files (on the build system).
  Either forward slash or backslash can be used as path separator.

- <src-patterns> specifies one or more patterns to match source files to be
  included under <src-root> (on the build system).  Patterns are delimited by
  colon (:).  Path name relative to the <src-root> can be included, either
  forward slash or backslash can be used as path separator.

  As Vim glob() function will be used to expand the specified patterns, any
  glob() wildcards can be used.  For example, you can use the "**" pattern to
  match sub-directories recursively.

Fields of the template should be delimited by vertical bar(|), and patterns in
the pattern field should be delimited colon (:).  If vertical bar and/or colon
needs to be used in field content, they should be escaped with backslash, like
"\|" or "\:".  Those escape sequences will be processed after the template
line has been split into fields.

Relative path of source files (relative to <src-root>) will be kept by default
when install them into <target-path>.  That means:
    <src-root>\path\to\foo.txt
will be installed as:
    <target-path>\path\to\foo.txt
To remove the relative path (install source files into <target-path> directly
without relative path), append "\*" or "/*" to the <target-path> in the
template specification.  In this case the above file will be installed as:
    <target-path>\foo.txt

NSIS macro can be used in all fields of the template.  The syntax of the macro
reference is (the same as NSIS):
    ${MACRO_NAME}
Macro will be expanded after escape sequence processing.  Please note macro
expansion will be performed only once, recursive macro reference won't work.


7. List of Template Definition Files in Use
------------------------------------------------------------------------------

Currently the following templates are defined:

- nsis/data/runtime_files.list
  Specifies all runtime files to be installed, except Vim executable, DLLS and
  dynamically generated files (such as batch files).  Those files cannot be
  determined statically so they still need to be specified in the main NSIS
  script directly.

- nsis/data/nls_files.list
  Specifies all NLS files to be installed.
