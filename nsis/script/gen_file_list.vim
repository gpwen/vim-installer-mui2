" vi:set ts=8 sts=4 sw=4 fdm=marker:
"
" This Vim script is used to generate NSIS commands to install/un-install
" files from templates held in the current buffer.  Please refer to section
" III of nsis/README.txt for detail.
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
"   This function will handle line continuation.
" Arguments:
"   buf_id        : ID of the buffer to read from;
"   line_num      : Line number of the line to read;
"   field_sep     : Field separator (regular express for split);
"   fields        : Output list contains all fields on the line;
"   pending_lines : Working buffer for line continuation processing.
" Return:
"   0 If no valid line has been processed;
"   1 If a valid line has been successfully processed.
" ----------------------------------------------------------------------------
function! s:Readline(buf_id, line_num, field_sep, fields, pending_lines)
    " Initialize output fields:
    if (!empty(a:fields))
        call remove(a:fields, 0, -1)
    endif

    " Read one line from the specified buffer.  Lines will be cached in the
    " pending lines buffer until the next blank line, comment line or line
    " without line continuation character is found.  Therefore, the caller
    " needs to read one more line beyond the end of the buffer to make sure
    " the last block of continuation lines are processed.
    let has_more = 0
    let lines    = getbufline(a:buf_id, a:line_num)
    if (len(lines) > 0)
        " We got a valid line, clean it up:
        let lines[0] = substitute(lines[0], '^\s\+', '', '')
        let lines[0] = substitute(lines[0], '\s\+$', '', '')

        " Process the line: Lines with useful content will be added to the
        " pending lines buffer.  A flag will be set to indicate whether line
        " continuation character present or not (has_more).
        if (lines[0] ==# '\')
           " The line contains nothing but backslash, it should be treated as
           " line continuation.  However, since the line contains nothing, we
           " won't record it in the pending lines buffer:
            let has_more = 1
        elseif (strlen(lines[0]) < 1)
            " Skip empty lines:
            let has_more = 0
        elseif (strpart(lines[0], 0, 1) ==# '#')
            " Skip comments (lines started with '#'):
            let has_more = 0
        elseif (lines[0] =~ '\s\+\\$')
            " This line has useful content and ends with a single backslash
            " with preceding white spaces, we'll record it in the pending
            " lines buffer after cleanup the line continuation character.  The
            " line continuation flag should also be set.
            let has_more = 1
            let lines[0] = substitute(lines[0], '\s\+\\$', '', '')
            call add(a:pending_lines, lines[0])
        else
            " This is a normal line with useful content.  Record it after
            " processing line continuation escape sequence.
            let has_more = 0
            let lines[0] = substitute(lines[0], '\s\@<=\\\\$', '\\', '')
            call add(a:pending_lines, lines[0])
        endif
    endif

    " We need to process pending lines unless more continuation lines are
    " expected (has_more), or the pending lines buffer is empty:
    if (has_more  ||  len(a:pending_lines) < 1)
        return 0
    end

    " Processing pending lines: Join them and split the result into fields.
    call extend(a:fields, split(join(a:pending_lines, ''), a:field_sep, 1))

    " All pending lines have been processed, empty the buffer:
    call remove(a:pending_lines, 0, -1)

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

    " Process macro definitions in the buffer.  We intentionally process one
    " more line to make sure the last line continuation block is processed.
    let line_num      = 1
    let read_stat     = 1
    let def_spec      = []
    let pending_lines = []
    while line_num <= num_defs + 1
        " Prefix for debug message output:
        let msg_prefix = '# ' . a:fname . ' line ' . line_num . ': '

        " Read one line from the definition buffer:
        let read_stat = s:Readline
            \ (buf_id_defs, line_num, '\s*=\s*', def_spec, pending_lines)
        let line_num += 1

        if (read_stat != 1)
            continue
        endif

        " Skip those lines with incorrect format:
        if (len(def_spec) != 2)
            call s:WriteErr(msg_prefix, join(def_spec, '='), fname_defines)
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
"   line_num      : Line number (zero based) of the line to be loaded from the
"                   template buffer;
"   tmpl_spec     : Output list for template fields;
"   nsis_defs     : Dictionary holds NSIS macro definitions.  Macro
"                   substitution will be performed on all fields after the
"                   loaded lines have been broken up into fields;
"   pending_lines : Working buffer for line continuation processing.
" Return:
"   0 If no valid line has been loaded;
"   1 If a valid line has been successfully loaded and processed.
" ----------------------------------------------------------------------------
function! s:LoadTemplateLine(line_num, tmpl_spec, nsis_defs, pending_lines)
    " Prefix for debug message output:
    let msg_prefix = '# ' . s:fname_tmpl . ' line ' . a:line_num . ': '

    " Read one line from the template buffer, the delimiter for fields is a
    " vertical bar (|) that NOT preceded by a backslash (\).  This makes it
    " possible to use backslash to escape vertical bar.
    let read_stat  = s:Readline
        \ (s:buf_id_tmpl, a:line_num, '\s*\\\@<!|\s*',
        \  a:tmpl_spec, a:pending_lines)

    if (read_stat != 1)
        return 0
    endif

    " Skip those lines with incorrect format:
    if (len(a:tmpl_spec) != s:NUM_FIELDS)
        let err_line = join(a:tmpl_spec, '|')
        execute 'buffer ' . s:buf_id_install
        call s:WriteErr(msg_prefix, err_line, s:fname_tmpl)

        execute 'buffer ' . s:buf_id_uninst
        $put =''
        $put =msg_prefix . 'Syntax error, skip: ' . err_line

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
        " Skip empty pattern:
        if (strlen(pattern) < 1)
            continue
        endif

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
        endwhile

        call extend(file_list, temp_list)
    endfor

    " Restore the current directory:
    cd -

    return file_list
endfunction


" ----------------------------------------------------------------------------
" Function: s:AddNewDirs(dir_list, target_path, new_dir)                  {{{1
"   Add a new relative directory to the directory list.  This list will be
"   used to generated NSIS directory remove commands.  All parent directories
"   of the directory will be added to make sure we won't left behind any empty
"   directory after uninstallation.
" Arguments:
"   dir_list    : List of directories to be created on the target system.
"   target_path : Target path.
"   new_dir     : New directory to add (relative to source path).
" Return:
"   0 if nothing added;
"   1 Otherwise.
" ----------------------------------------------------------------------------
function! s:AddNewDirs(dir_list, target_path, new_dir)
    " Skip empty relative path, we already added that:
    if (a:new_dir ==# '')
        return 0
    endif

    " Add the relative path and all of its parent path:
    let temp_dir = a:new_dir
    while (temp_dir !=# '')
        " Add the relative path to the new directory list:
        call add(a:dir_list,  a:target_path . '\' . tr(temp_dir, '/', '\'))

        " Move to its parent directory:
        let temp_dir = fnamemodify(temp_dir, ':h')
        if (temp_dir ==# '.')
            let temp_dir = ''
        endif
    endwhile

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:GenInstallCmds(target_path, src_root, file_list, ...)       {{{1
"   Generate NSIS file install commands for specified files.  Generated
"   commands will be appended to the Vim buffer for NSIS install commands.
" Arguments:
"   target_path : Target path.
"   src_root    : Root path for source files.
"   file_list   : List of files to install (relative to source root).
"   dir_list    : List of directories to be created on the target system.
"   keep_dir    : If 1, keep relative path of source files when copy to target
"                 path;  Otherwise, copy source files to target path without
"                 relative path.
" Return:
"   0 if no command generated;
"   1 if succeeded.
" ----------------------------------------------------------------------------
function! s:GenInstallCmds(target_path, src_root, file_list,
                         \ dir_list, keep_dir)
    " Generate install commands: NSIS command to set output path.
    execute 'buffer ' . s:buf_id_install

    " Skip if no file found:
    if (len(a:file_list) < 1)
        $put ='# No file found, skip!'
        return 0
    endif

    " Append path delimiter to source root.  Source root uses forward slash,
    " we need backslash here since NSIS only knows that:
    let full_root = tr(a:src_root, '/', '\') . '\'

    " In order to keep relative path of source files, we need to update NSIS
    " output directory when relative path of source file changes.  prev_dir is
    " used to record the last relative path we set, so we can detect change in
    " relative path.
    if (a:keep_dir)
        " We need to keep relative path, so set the last relative path to an
        " invalid value so it will be updated for the first source file:
        let prev_dir = ':'
    else
        " No relative path should be kept, so we'll essentially disable
        " detection of relative path change and simply use target path as NSIS
        " output path for all files:
        let prev_dir = ''
        $put ='${Logged1} SetOutPath ' . a:target_path
    endif

    " In all cases, we'll add target path so that no empty target path will be
    " left after un-intallation:
    call add(a:dir_list, a:target_path)

    " Generate NSIS commands to install files:
    let one_item = ''
    let new_dir  = ''
    for one_item in a:file_list
        " Detect change in the relative path of source files if we need to
        " keep the relative path:
        if (a:keep_dir)
            " Relative path of the source file.  Convert forward slash back to
            " backslash since NSIS only knows that.
            let new_dir = fnamemodify(one_item, ':h')

            " In case the source file does not have relative path:
            if (new_dir ==# '.')
                let new_dir = ''
            endif

            " If the relative path changed, update NSIS output directory and
            " record the new directory created:
            if (new_dir !=# prev_dir)
                " Update relative path:
                let prev_dir = new_dir

                " Set NSIS output path:
                let new_dir  =
                    \ (prev_dir ==# '') ?
                    \   a:target_path :
                    \   (a:target_path . '\' . tr(prev_dir, '/', '\'))
                $put ='${Logged1} SetOutPath ' . new_dir

                " Add the new relative path and all of its parents to the new
                " directory list:
                call s:AddNewDirs(a:dir_list, a:target_path, prev_dir)
            end
        endif

        " Generate NSIS File command to install the file.  We need to convert
        " forward slash back to backslash since NSIS only knows that.
        $put ='${Logged1} File ' . full_root . tr(one_item, '/', '\')
    endfor

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:GenUninstallCmds(target_path, file_list, keep_dir)          {{{1
"   Generate NSIS file uninstall commands for specified files.  Generated
"   commands will be appended to the Vim buffer for NSIS uninstall commands.
" Arguments:
"   target_path : Target path.
"   file_list   : List of files to uninstall (relate to source root).
"   keep_dir    : If 1, keep relative path of source files when copy to target
"                 path;  Otherwise, copy source files to target path without
"                 relative path.
" Return:
"   0 if no command generated;
"   1 if succeeded.
" ----------------------------------------------------------------------------
function! s:GenUninstallCmds(target_path, file_list, keep_dir)
    " Generate install commands: NSIS command to set output path.
    execute 'buffer ' . s:buf_id_uninst

    " Skip if no file found:
    if (len(a:file_list) < 1)
        $put ='# No file found, skip!'
        return 0
    endif

    let one_item = ''
    for one_item in a:file_list
        " If we don't need to keep relative path when install source files,
        " source files have been installed into the target path directly
        " without relative path.  Therefore, we only need their file name to
        " remove them.  We need to convert forward slash back to backslash
        " since NSIS only knows that.
        let one_item = a:keep_dir ?
                     \ tr(one_item, '/', '\') :
                     \ fnamemodify(one_item, ':t')

        " Generate NSIS commands to remove the file:
        $put ='${Logged1} Delete ' . a:target_path . '\' . one_item
    endfor

    return 1
endfunction


" ----------------------------------------------------------------------------
" Function: s:GenNsisCommands()                                           {{{1
"   Main function to generate NSIS commands from file template.  Generated
"   commands will be appended to previously created Vim buffers for
"   install/uninstall commands.
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

    " Process templates in the input buffer.  We intentionally process one
    " more line to make sure the last line continuation block is processed.
    let line_num      = 1
    let load_stat     = 1
    let target_path   = ''
    let src_root      = ''
    let pending_lines = []
    let tmpl_spec     = []
    let file_list     = []
    let dir_list      = []
    let target_len    = 0
    let keep_dir      = 1
    let target_path   = ''
    let src_root      = ''
    let patterns      = []
    while line_num <= num_tmplates + 1
        " Load and process one line from the template buffer:
        let load_stat = s:LoadTemplateLine(line_num, tmpl_spec,
                                        \  nsis_defs, pending_lines)
        let line_num += 1

        if (load_stat != 1)
            continue
        endif

        " For easier access:
        let target_path = tmpl_spec[s:IDX_TARGET]
        let src_root    = tmpl_spec[s:IDX_SRC_ROOT]
        let patterns    = tmpl_spec[s:IDX_PATTERNS]

        " If target path ends with "\*", do not keep relative path of source
        " files.  Otherwise, keep the relative path.  Please note both "/*"
        " and "\*" will be converted to "\*" when loading the template.
        let target_len  = strlen(target_path)
        if (target_len > 2  &&
          \ strpart(target_path, target_len - 2) ==# '\*')
            " Remove the special flag from target path:
            let target_path = strpart(target_path, 0, target_len - 2)
            let keep_dir    = 0
        else
            let keep_dir    = 1
        endif

        " Expand the source file patterns to generate a file list, and then
        " clean up the list (remove directories etc.).  Skip if no file found.
        let file_list = s:ExpandPatterns(src_root, patterns)

        " Generate NSIS commands to install/uninstall files:
        call s:GenInstallCmds(target_path, src_root, file_list,
                            \ dir_list, keep_dir)
        call s:GenUninstallCmds(target_path, file_list, keep_dir)
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
" for install/uninstall commands:
call s:GenNsisCommands()

" Save install commands:
execute 'buffer '  . s:buf_id_install
execute 'saveas! ' . g:gen_fcmds_fname_install

" Save uninstall commands:
execute 'buffer '  . s:buf_id_uninst
execute 'saveas! ' . g:gen_fcmds_fname_uninst

" Restore compatibility:
let &cpo = s:save_cpo

" All done, quit:
if g:gen_fcmds_debug_on == 0
    qall
endif
