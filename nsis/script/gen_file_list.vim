" vi:set ts=8 sts=4 sw=4 fdm=marker:
"
" This Vim script is used to generate NSIS commands to install/un-install
" files from templates held in the current buffer.  Each line in the current
" buffer should be one of:
" - Blank line (lines with blank characters only); or
" - Comment line (lines with first non-blank character as '#'); or
" - Template definition line.
"
" The template definition line has the following format:
"   <target-path> | <src-root> | <src-patterns>
"
" where:
"
" - <target-path> is the path name on the target system where source file(s)
"   should be installed.  The path name will be used literally in generate
"   command except slash conversion and cleanup, NSIS variables can be used
"   there.  Forward slash can be used in path name, they will be converted to
"   backward slash automatically.
"
" - <src-root> is the root path for the source files (on the build system).
"   Either forward slash or backward slash can be used as path separator.
"
" - <src-patterns> is one or more patterns to match source files (on the build
"   system) under <src-root>.  Patterns are delimited by colon (:).  Path name
"   relative to the <src-root> can be included, and wildcards can be used.
"   Either forward slash or backward slash can be used as path separator (for
"   relative path).  The pattern will be passed to Vim glob() function to
"   expand.  Please note the pattern will *NOT* be expanded recursively,
"   you're expected to list all directories explicitly.
"
" - Fields of the template should be delimited by vertical bar(|), and
"   patterns in the pattern field should be delimited colon (:).  If vertical
"   bar and colon needs to be used as filed content, they should be escaped
"   using backslash, like \| or \:.  Those escape sequences will be escaped
"   after the template line has be split into fields.
"
" - If the first non-white character one a line is '#', the line will be
"   considered as comment line and skipped.
"
" - NSIS macro can be used in all fields of the template.  The syntax of the
"   macro reference is (the same as NSIS):
"     ${MACRO_NAME}
"   Macro will be expanded after escaped sequences processing.
"
" A macro definition file can be loaded before processing the buffer.  The
" name of the macro definition file should be specified in global variable:
"   g:gen_fcmds_fname_defines
" The default file name is 'vim_defines.conf'.  Each line in the file should
" be blank line, comment line (same as above) or macro definition line.  The
" format of the macro definition line is:
"   <NAME> = <VALUE>
" where
" - <NAME> is the name of the macro.  It can be referenced in template
"   definition as ${NAME}.
" - <VALUE> is the value of macro.
"
" Maintainer: Guopeng Wen <wenguopeng AT gmail.com>

" ----------------------------------------------------------------------------
" Global initialization & setup                                           {{{1
" ----------------------------------------------------------------------------

" Set compatibility to Vim default:
let s:save_cpo = &cpo
set cpo&vim

" Set debug flag.  Turn on debug flag by default to make it easier to debug
" from vim directly.  To debug, open the file template in vim, and then source
" in this script:
if !exists("g:gen_fcmds_debug_on")
    let g:gen_fcmds_debug_on = 1
endif

" Constants to access fields of templates:
let s:NUM_FIELDS   = 3
let s:IDX_TARGET   = 0
let s:IDX_SRC_ROOT = 1
let s:IDX_PATTERNS = 2

" It's very important to set 'bufhidden' as 'hide', otherwise the buffer will
" be unloaded once hide (which move other buffer to front).  If that happened,
" subsequent read from that buffer will return empty.
setlocal bufhidden=hide

" Make the current buffer unmodifiable to avoid accident change:
setlocal nomodifiable

" Record the buffer number/name of the current buffer (template buffer):
let s:buf_id_tmpl = bufnr('%')
let s:fname_tmpl  = bufname('%')

" New buffer for NSIS install commands:
new
setlocal bufhidden=hide
setlocal modifiable
call setline('$', '# Generated commands for NSIS installer, do not edit.')
let s:buf_id_install = bufnr('%')

" Set default name for the install command file:
if !exists("g:gen_fcmds_fname_install")
    let g:gen_fcmds_fname_install = 'install-cmds.nsi'
endif

" New buffer for NSIS uninstall commands:
new
setlocal bufhidden=hide
setlocal modifiable
call setline('$', '# Generated commands for NSIS uninstaller, do not edit.')
let s:buf_id_uninst  = bufnr('%')

" Set default name for the uninstall command file:
if !exists("g:gen_fcmds_fname_uninst")
    let g:gen_fcmds_fname_uninst = 'uninst-cmds.nsi'
endif

" Set default name for NSIS defines and load them if exist:
if !exists("g:gen_fcmds_fname_defines")
    let g:gen_fcmds_fname_defines = 'vim_defines.conf'
endif


" ----------------------------------------------------------------------------
" Function: s:DebugLog(msg)                                               {{{1
"   Write debug log to install command buffer.
" Arguments:
"   msg: Message to log.
" Return:
"   N/A
" ----------------------------------------------------------------------------
function! s:DebugLog(msg)
    execute 'buffer ' . s:buf_id_install
    $put =''
    $put ='# DEBUG: ' . a:msg

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:Readline(buf_id, line_num, ...)                             {{{1
"   Read one line from the specified buffer and split result into fields.
" Arguments:
"   buf_id     : ID of the buffer to read from;
"   line_num   : Line number of the line to read;
"   field_sep  : Field separator (regular express for split);
"   fields     : Output list contains all fields on the line.
"   last_lines : Output list contains last line read.
" Return:
"   0 If no valid line has been processed;
"   1 If a valid line has been successfully processed.
" ----------------------------------------------------------------------------
function! s:Readline(buf_id, line_num, field_sep, fields, last_lines)
    " Initialize output fields:
    if !empty(a:fields)
        call remove(a:fields, 0, -1)
    endif

    " Read one line from the specified buffer:
    let lines = getbufline(a:buf_id, a:line_num)
    if (len(lines) < 1)
        " Ignore if read fail:
        return 0
    endif

    " Clean up the line:
    let lines[0] = substitute(lines[0], '^\s\+', '', '')
    let lines[0] = substitute(lines[0], '\s\+$', '', '')

    " Skip empty line:
    if (len(lines[0]) < 1)
        return 0
    endif

    " Skip comments (lines started with '#'):
    if (strpart(lines[0], 0, 1) ==# '#')
        return 0
    endif

    " Record the last line processed:
    if !empty(a:last_lines)
        call remove(a:last_lines, 0, -1)
    endif

    call add(a:last_lines, lines[0])

    " Split the line to fields:
    call extend(a:fields, split(lines[0], a:field_sep, 1))

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:WriteErr(msg_prefix, line, fname_data)                      {{{1
"   Write a error message to buffer for the install commands.  This function
"   will also embed an NSIS !error command in that buffer, so that makensis
"   will be stopped with the appropriate error report.
" Arguments:
"   msg_prefix : Message prefix (line number etc.)
"   line       : Text line caused the error.
"   fname_data : Name of the data file caused the error.
" Return:
"   None
" ----------------------------------------------------------------------------
function! s:WriteErr(msg_prefix, line, fname_data)
    $put =''
    $put =a:msg_prefix . 'Syntax error, skip: ' . a:line
    $put ='!error \"Syntax error in [' . a:fname_data . ']!  \'
    $put ='        Please check ['  .
        \ g:gen_fcmds_fname_install .
        \ '] for detail.\"'

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:LoadDefines(fname, buf_id_log)                              {{{1
"   Load NSIS macro definitions into a dictionary.
" Arguments:
"   fname      : File name of the NSIS macro definition file to load.
"   buf_id_log : ID of the Vim buffer to write log messages.
" Return:
"   A dictionary contains definitions loaded from the NSIS macro definition
"   file.  Empty dictionary will be returned if the file does not exist.
" ----------------------------------------------------------------------------
function! s:LoadDefines(fname, buf_id_log)
    " Load NSIS defines if exist:
    let nsis_defs = {}
    if !filereadable(a:fname)
        return nsis_defs
    endif

    " Open NSIS definition file and record buffer ID etc.:
    execute 'sview ' . a:fname
    let buf_id_defs = bufnr('%')
    let num_defs    = line('$')

    " Don't unload this buffer, and avoid accidental change.
    setlocal bufhidden=hide
    setlocal nomodifiable

    " Log message will be written to the install command buffer:
    execute 'buffer ' . a:buf_id_log
    $put =''
    $put ='# Loading NSIS defines from: ' . a:fname

    let line_num    = 1
    let read_stat   = 1
    let def_spec    = []
    let last_lines  = []
    while line_num <= num_defs
        " Prefix for debug message output:
        let msg_prefix = '# ' . a:fname . ' line ' . line_num . ': '

        " Read one line from the definition buffer:
        let read_stat = s:Readline
            \ (buf_id_defs, line_num, '\s*=\s*', def_spec, last_lines)
        let line_num += 1

        if (read_stat != 1)
            continue
        endif

        " Skip those lines with incorrect format:
        if (len(def_spec) != 2)
            call s:WriteErr(msg_prefix, last_lines[-1], fname_defines)
            continue
        endif

        " Echo back the current definition for debug purpose:
        $put =msg_prefix . def_spec[0] . ' = ' . def_spec[1]

        " Record the definition:
        let nsis_defs[def_spec[0]] = def_spec[1]
    endwhile

    $put ='# NSIS defines load completed: ' . a:fname

    " Unload the temporary buffer for NSIS definition file:
    execute 'bunload! ' . buf_id_defs

    return nsis_defs
endfunction


" ----------------------------------------------------------------------------
" Function: s:LoadTemplateLine(line_num, tmpl_spec, nsis_defs)            {{{1
"   Read one line from the template buffer, and convert it to target path,
"   source root and source pattern.  The following
" Arguments:
"   line_num  : Line number (zero based) of the line to be loaded from
"               the template buffer.
"   tmpl_spec : Output list for template fields.
"   nsis_defs : Dictionary holds NSIS macro definitions.  Macro substitution
"               will be performed on all fields after the loaded lines have
"               been broken up into fields.
" Return:
"   0 If no valid line has been loaded;
"   1 If a valid line has been successfully loaded and processed.
" ----------------------------------------------------------------------------
function! s:LoadTemplateLine(line_num, tmpl_spec, nsis_defs)
    " Prefix for debug message output:
    let msg_prefix = '# ' . s:fname_tmpl . ' line ' . a:line_num . ': '

    " Read one line from the template buffer, the delimiter for fields is a
    " vertical bar (|) that NOT preceded by a backslash (\).  This makes it
    " possible to use backslash to escape vertical bar.
    let last_lines = []
    let read_stat  = s:Readline
        \ (s:buf_id_tmpl, a:line_num, '\s*\\\@<!|\s*',
        \  a:tmpl_spec, last_lines)

    if (read_stat != 1)
        return 0
    endif

    " Skip those lines with incorrect format:
    if (len(a:tmpl_spec) != s:NUM_FIELDS)
        execute 'buffer ' . s:buf_id_install
        call s:WriteErr(msg_prefix, last_lines[-1], s:fname_tmpl)

        execute 'buffer ' . s:buf_id_uninst
        $put =''
        $put =msg_prefix . 'Syntax error, skip: ' . last_lines[-1]

        return 0
    endif

    " The pattern field may contains multiple patterns, the delimiter for
    " patterns is colon (:) that NOT preceded by a backslash (\).  This makes
    " it possible to use backslash to escape colon.  We'll put target path,
    " source root and all patterns into one flat list so we can process them
    " in same way easily:
    let flat_list =
        \ a:tmpl_spec[s:IDX_TARGET : s:IDX_SRC_ROOT] +
        \ split(a:tmpl_spec[s:IDX_PATTERNS], '\s*\\\@<!:\s*', 1)

    " Length of the flat list:
    let total_len = len(flat_list)

    " Escape character processing and macro substitution etc.:
    let idx        = 0
    let macro_name = ''
    while idx < total_len
        " Escape character processing: \| -> | and  \: -> :
        let flat_list[idx] = substitute(flat_list[idx], '\\|', '|', 'g')
        let flat_list[idx] = substitute(flat_list[idx], '\\:', ':', 'g')

        " Macro substitution:
        for macro_name in keys(a:nsis_defs)
            let flat_list[idx] =
               \ substitute(flat_list[idx], '${' . macro_name . '}',
                          \ escape(a:nsis_defs[macro_name], '\'), 'g')
        endfor

        " Path delimiter conversion:
        if (idx == s:IDX_TARGET)
            " Convert any forward slash in target path to backslash since NSIS
            " only accept backslash.  Also remove trailing slashes if any:
            let flat_list[idx] = tr(flat_list[idx], '/', '\')
            let flat_list[idx] = substitute(flat_list[idx], '\\\+$', '', '')
        else
            " Convert backslash in other fields to forward slash for better
            " portability.  Also remove trailing slashes from path if any:
            let flat_list[idx] = tr(flat_list[idx], '\', '/')
            let flat_list[idx] = substitute(flat_list[idx], '/\+$', '', '')
        endif

        " Move to the next field:
        let idx += 1
    endwhile

    " Output the final result:
    let a:tmpl_spec[s:IDX_TARGET : s:IDX_SRC_ROOT] =
        \ flat_list[s:IDX_TARGET : s:IDX_SRC_ROOT]
    call remove(flat_list, s:IDX_TARGET, s:IDX_SRC_ROOT)
    let a:tmpl_spec[s:IDX_PATTERNS] = flat_list

    " Echo back the current line (converted) for debug purpose:
    let temp_msg = '# ' .
        \ join(a:tmpl_spec[s:IDX_TARGET : s:IDX_SRC_ROOT], ' | ') .
        \ ' | ' . join(a:tmpl_spec[s:IDX_PATTERNS], ' : ')

    for buf_id in [s:buf_id_install, s:buf_id_uninst]
        execute 'buffer ' . buf_id
        $put =''
        $put =msg_prefix
        $put =temp_msg
    endfor

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:ExpandPatterns(src_root, pattern_list)                      {{{1
"   Expand a list of file name pattern, and:
"   - Remove directories from the expanded list;
"   - Convert all forward slashes to backslash.
" Arguments:
"   src_root     : Root path for file name expansion.
"   pattern_list : List of file name patterns to expand.
" Return:
"   List of files generated from the pattern.
" ----------------------------------------------------------------------------
function! s:ExpandPatterns(src_root, pattern_list)
    " Change current directory to the source root:
    execute 'cd ' . fnameescape(a:src_root)

    " Expand all specified source file patterns to generate a file list:
    let pattern   = ''
    let idx       = 0
    let temp_list = []
    let file_list = []
    for pattern in a:pattern_list
        " Expand the pattern, store result in a list:
        let temp_list = split(glob(pattern, 1), "\n")

        " Clean up the generated file list (remove directories etc.):
        let idx = len(temp_list)
        while idx > 0
            let idx -= 1

            " Remove directories:
            if (isdirectory(temp_list[idx]))
                call remove(temp_list, idx)
                continue
            endif

            " Convert forward slash back to backslash since NSIS only knows
            " backslash:
            let temp_list[idx] = tr(temp_list[idx], '/', '\')
        endwhile

        call extend(file_list, temp_list)
    endfor

    " Restore the current directory:
    cd -

    return file_list
endfunction


" ----------------------------------------------------------------------------
" Function: s:GenInstallCmds(target_path, src_root, file_list)            {{{1
"   Generate NSIS file install commands for specified files.  Generated
"   commands will be appended to the Vim buffer for NSIS install commands.
" Arguments:
"   target_path : Target path.
"   src_root    : Root path for source files.
"   file_list   : List of files to install (relative to source root).
" Return:
"   0 if no command generated;
"   1 if succeeded.
" ----------------------------------------------------------------------------
function! s:GenInstallCmds(target_path, src_root, file_list)
    " Generate install commands: NSIS command to set output path.
    execute 'buffer ' . s:buf_id_install

    " Skip if no file found:
    if (len(a:file_list) < 1)
        $put ='# No file found, skip!'
        return 0
    endif

    " Append path delimiter to source root.  Source root uses forward slash,
    " we need backslash here:
    let full_root = tr(a:src_root, '/', '\') . '\'

    " Set NSIS output path.
    $put ='${Logged1} SetOutPath ' . a:target_path

    " Generate NSIS commands to install files:
    let one_item = ''
    for one_item in a:file_list
        $put ='${Logged1} File ' . full_root . one_item
    endfor

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:GenUninstallCmds(target_path, file_list)                    {{{1
"   Generate NSIS file uninstall commands for specified files.  Generated
"   commands will be appended to the Vim buffer for NSIS uninstall commands.
" Arguments:
"   target_path : Target path.
"   file_list   : List of files to uninstall (relate to source root).
" Return:
"   0 if no command generated;
"   1 if succeeded.
" ----------------------------------------------------------------------------
function! s:GenUninstallCmds(target_path, file_list)
    " Generate install commands: NSIS command to set output path.
    execute 'buffer ' . s:buf_id_uninst

    " Skip if no file found:
    if (len(a:file_list) < 1)
        $put ='# No file found, skip!'
        return 0
    endif

    let one_item = ''
    for one_item in a:file_list
        " Get file name:
        let one_item = fnamemodify(one_item, ':t')

        " NSIS commands to remove the file:
        $put ='${Logged1} Delete ' . a:target_path . '\' . one_item
    endfor

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:GenNsisCommands()                                           {{{1
"   Main function to generate NSIS commands from file template.  Generated
"   commands will be appended to previously created Vim buffers for
"   install/un-install commands.
" Arguments: N/A
" Return:    N/A
" ----------------------------------------------------------------------------
function! s:GenNsisCommands()
    " Load NSIS defines:
    let nsis_defs = s:LoadDefines(g:gen_fcmds_fname_defines, s:buf_id_install)

    " Write debug log:
    execute 'buffer ' . s:buf_id_install
    $put =''
    $put ='# Loading file templates from: ' . s:fname_tmpl

    " Count number of file template lines:
    execute 'buffer ' . s:buf_id_tmpl
    let num_tmplates = line('$')

    " Process templates in the input buffer:
    let line_num    = 1
    let load_stat   = 1
    let target_path = ''
    let src_root    = ''
    let patterns    = []
    let tmpl_spec   = []
    let file_list   = []
    let dir_list    = []
    while line_num <= num_tmplates
        " Load and process one line from the template buffer:
        let load_stat = s:LoadTemplateLine(line_num, tmpl_spec, nsis_defs)
        let line_num += 1

        if (load_stat != 1)
            continue
        endif

        " For easier access:
        let target_path = tmpl_spec[s:IDX_TARGET]
        let src_root    = tmpl_spec[s:IDX_SRC_ROOT]
        let patterns    = tmpl_spec[s:IDX_PATTERNS]

        " Record the output directory:
        call add(dir_list, target_path)

        " Expand the source file patterns to generate a file list, and then
        " clean up the list (remove directories etc.).  Skip if no file found.
        let file_list = s:ExpandPatterns(src_root, patterns)

        " Generate NSIS commands to install/uninstall files:
        call s:GenInstallCmds(target_path, src_root, file_list)
        call s:GenUninstallCmds(target_path, file_list)
    endwhile

    " Sort directory list in reverse order:
    call sort(dir_list)
    call reverse(dir_list)

    " Generate commands to remove directory, duplicated items will be removed:
    execute 'buffer ' . s:buf_id_uninst
    $put =''
    $put ='# Remove directories:'

    let one_item = ''
    let last_dir = ''
    for one_item in dir_list
        if one_item !=# last_dir
            let last_dir = one_item
            $put ='${Logged1} RMDir ' . one_item
        endif
    endfor

    return 1
endfunction


" ----------------------------------------------------------------------------
" Main Script                                                             {{{1
" ----------------------------------------------------------------------------
" Generate NSIS commands.  Generated command will be appended to Vim buffers
" for install/un-install commands:
call s:GenNsisCommands()

" Save install commands:
execute 'buffer '  . s:buf_id_install
execute 'saveas! ' . g:gen_fcmds_fname_install

" Save un-install commands:
execute 'buffer '  . s:buf_id_uninst
execute 'saveas! ' . g:gen_fcmds_fname_uninst

" Restore compatibility:
let &cpo = s:save_cpo

" All done, quit:
if g:gen_fcmds_debug_on == 0
    qall
endif
