# Multiple Language Support Status

The following table shows the current multiple language support status of the
upgraded Vim NSIS installer.  If the `Final` column is not empty, the
corresponding language has been supported.  The content of that column is a
link to the language file for that language, that file contains all strings
that could be shown on the user interface.  You're more welcomed to review
that file and send feedback if you're using that language.

Locale names listed under the `Locale Name` column is [[GNU gettext|
http://www.gnu.org/software/gettext/manual/gettext.html#Locale-Names]] locale
name for the language, it can be used as shortcut to specify that language on
command line (Please refer to user manual of the installer for detail).

Please note that:

* Multiple language support is not enabled by default, you need to enable
  `HAVE_MULTI_LANG` macro in file `nsis/gvim.nsi` manually.

* All strings used on the user interface has been listed in the language file.
  However, some debug messages are not listed since those messages only appear
  in debug log.

You can help to add more languages to the installer by translating the
language file.  Here's how:

* Find a language that has not been supported yet;

* Download the template file (the one listed in the `Template` column);

* In order to support older versions of Windows (Windows 95), NSIS language
  strings must be encoded in Windows codepage for that language.  Therefore,
  you should find out the correct fileencoding for that language before you
  start.

  If you are not sure, you can always install [[NSIS |
  http://nsis.sourceforge.net/]],  check language files in sub-directory
  "`Contrib\Language files`" under the NSIS install directory.  You should use
  the same fileencoding as the corresponding language file you found there.

* Translate strings listed in the template file, and save the file with
  the correct fileencoding.

* Post the file to `vim-dev` mailing list.

Your help on translation are highly appreciated.
