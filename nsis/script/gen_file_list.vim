" vi:set ts=8 sts=4 sw=4 fdm=marker:
"
" This Vim script is used to generate NSIS commands to install/uninstall files
" from templates held in the current buffer.  Each line in the current buffer
" should be one of:
" - Blank line (lines with blank characters only); or
" - Comment line (lines with first non-blank character as '#'); or
" - Template definition line.
"
" The template definition line has the following format:
"   <target-path> , <src-pattern>
" where
" - <target-path> is the path name on the target system where source file(s)
"   should be installed.  The path name will be used literally in generate
"   command except slash conversion and cleanup, NSIS variables can be used
"   there.  Forward slash can be used in path name, they will be converted to
"   backward slash automatically.
" - <src-pattern> is the pattern for the source files (on the build system).
"   Path name should be included, and wildcards can be used.  Either forward
"   slash or backward slash can be used as path separator.  The pattern will
"   be passed to Vim glob() function to expand.  Please note the pattern will
"   *NOT* be expanded recursively, you're expected to list all directories
"   explicitly.
" - If the first non-white character one a line is '#', the line will be
"   considered as comment line and skipped.
" - NSIS macro can be used in all fields of the template.  The syntax of the
"   macro reference is (the same as NSIS):
"     ${MACRO_NAME}
"   Macro will be expanded after the line has been split into fields.
"
" A macro definition file can be loaded before processing the buffer.  The
" name of the macro definition file should be specified in global variable:
"   g:fname_defines
" The default file name is 'vim_defines.conf'.  Each line in the file should
" be blank line, comment line (same as above) or macro definition line.  The
" format of the macro definition line is:
"   <NAME> = <VALUE>
" where
" - <NAME> is the name of the macro.  It can be referenced in template
"   definition as ${NAME}.
" - <VALUE> is the value of macro.
"
" Maintainer:  Guopeng Wen <wenguopeng AT gmail.com>
" Last Change: 2011-01-30

" Set compatibility to Vim default:
let s:save_cpo = &cpo
set cpo&vim


" ----------------------------------------------------------------------------
" Function: s:GenListReadline(buf_id, line_num, ...)                      {{{1
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
function! s:GenListReadline(buf_id, line_num, field_sep, fields, last_lines)
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
" Function: s:GenListErr(msg_prefix, line, fname_data)                    {{{1
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
function! s:GenListErr(msg_prefix, line, fname_data)
    $put =''
    $put =a:msg_prefix . 'Syntax error, skip: ' . a:line
    $put ='!error \"Syntax error in [' . a:fname_data . ']!  \'
    $put ='        Please check [' . g:fname_install . '] for detail.\"'

    return 1
endfunction


" ----------------------------------------------------------------------------
" Main Script                                                             {{{1
" ----------------------------------------------------------------------------
" It's very important to set 'bufhidden' as 'hide', otherwise the buffer will
" be unloaded once hide (which move other buffer to front).  If that happened,
" subseqent read from that buffer will return empty.
setlocal bufhidden=hide

" Make the current buffer unmodifiable to avoid accident change:
setlocal nomodifiable

" Record the buffer number/name of the current buffer (template buffer):
let buf_id_tmpl  = bufnr('%')
let fname_tmpl   = bufname('%')

" Line of text in the current buffer:
let num_tmplates = line('$')

" New buffer for NSIS install commands:
new
setlocal bufhidden=hide
setlocal modifiable
call setline('$', '# Generated commands for NSIS installer, do not edit.')
let buf_id_install = bufnr('%')

" Set default name for the install command file:
if !exists("g:fname_install")
    let g:fname_install = 'install-cmds.nsi'
endif

" New buffer for NSIS uninstall commands:
new
setlocal bufhidden=hide
setlocal modifiable
call setline('$', '# Generated commands for NSIS uninstaller, do not edit.')
let buf_id_uninst  = bufnr('%')

" Set default name for the uninstall command file:
if !exists("g:fname_uninst")
    let g:fname_uninst = 'uninst-cmds.nsi'
endif

" Set default name for NSIS defines:
if !exists("g:fname_defines")
    let g:fname_defines = 'vim_defines.conf'
endif

" Load NSIS defines if exist:
let nsis_defs    = {}
if filereadable(g:fname_defines)
    " Open NSIS definition file and record buffer ID etc.:
    execute 'sview ' . g:fname_defines
    let buf_id_defs = bufnr('%')
    let num_defs    = line('$')

    " Don't unload this buffer, and avoid accidental change.
    setlocal bufhidden=hide
    setlocal nomodifiable

    " Log message will be written to the install command buffer:
    execute 'buffer ' . buf_id_install
    $put =''
    $put ='# Loading NSIS defines from: ' . g:fname_defines

    let line_num    = 1
    let read_stat   = 1
    let def_spec    = []
    let last_lines  = []
    while line_num <= num_defs
        " Prefix for debug message output:
        let msg_prefix = '# ' . g:fname_defines . ' line ' . line_num . ': '

        " Read one line from the definition buffer:
        let read_stat = s:GenListReadline
            \ (buf_id_defs, line_num, '\s*=\s*', def_spec, last_lines)
        let line_num += 1

        if (read_stat != 1)
            continue
        endif

        " Skip those lines with incorrect format:
        if (len(def_spec) != 2)
            call s:GenListErr(msg_prefix, last_lines[-1], fname_defines)
            continue
        endif

        " Echo back the current definition for debug purpose:
        $put =msg_prefix . def_spec[0] . ' = ' . def_spec[1]

        " Record the definition:
        let nsis_defs[def_spec[0]] = def_spec[1]
    endwhile

    $put ='# NSIS defines load completed: ' . g:fname_defines
end

" Write debug log:
execute 'buffer ' . buf_id_install
$put =''
$put ='# Loading file templates from: ' . g:fname_tmpl

" Process templates in the input buffer:
let NUM_FIELDS = 2
let line_num   = 1
let read_stat  = 1
let tmpl_spec  = []
let last_lines = []
let msg_prefix = ''
let temp_msg   = ''
let macro_name = ''
let file_list  = []
let dir_list   = []
let one_item   = ''
let idx        = 0
while line_num <= num_tmplates
    " Prefix for debug message output:
    let msg_prefix = '# ' . g:fname_tmpl . ' line ' . line_num . ': '

    " Read one line from the template buffer:
    let read_stat = s:GenListReadline
        \ (buf_id_tmpl, line_num, '\s*,\s*', tmpl_spec, last_lines)
    let line_num += 1

    if (read_stat != 1)
        continue
    endif

    " Skip those lines with incorrect format:
    if (len(tmpl_spec) != NUM_FIELDS)
        execute 'buffer ' . buf_id_install
        call s:GenListErr(msg_prefix, last_lines[-1], fname_tmpl)

        execute 'buffer ' . buf_id_uninst
        $put =''
        $put =msg_prefix . 'Syntax error, skip: ' . last_lines[-1]

        continue
    endif

    " Perform macro substitution:
    for macro_name in keys(nsis_defs)
        let idx = 0
        while idx < NUM_FIELDS
            let tmpl_spec[idx] =
               \ substitute(tmpl_spec[idx], '${' . macro_name . '}',
                          \ escape(nsis_defs[macro_name], '\'), 'g')
            let idx += 1
        endwhile
    endfor

    " Convert any forward slash in target path to backslash since NSIS only
    " accept backslash:
    let tmpl_spec[0] = tr(tmpl_spec[0], '/', '\')

    " Also remove trailing slashes if any:
    let tmpl_spec[0] = substitute(tmpl_spec[0], '\\\+$', '', '')

    " Record the output directory:
    call add(dir_list, tmpl_spec[0])

    " Convert backslash in source path to forward slash for better
    " portability:
    let tmpl_spec[1] = tr(tmpl_spec[1], '\', '/')

    " Echo back the current line (converted) for debug purpose:
    let temp_msg = msg_prefix . tmpl_spec[0] . ', ' . tmpl_spec[1]

    execute 'buffer ' . buf_id_install
    $put =''
    $put =temp_msg

    execute 'buffer ' . buf_id_uninst
    $put =''
    $put =temp_msg

    " Generate install commands: NSIS command to set output path.
    execute 'buffer ' . buf_id_install
    $put ='${Logged1} SetOutPath ' . tmpl_spec[0]

    " Generate NSIS commands to install files:
    let file_list = split(glob(tmpl_spec[1], 1), "\n")
    for one_item in file_list
        " Convert forward slash back to backslash, if any:
        let one_item = tr(one_item, '/', '\')

        " NSIS commands to install the file:
        $put ='${Logged1} File ' . one_item
    endfor

    " Generate uninstall commands:
    execute 'buffer ' . buf_id_uninst
    for one_item in file_list
        " Get file name:
        let one_item = fnamemodify(one_item, ':t')

        " NSIS commands to install the file:
        $put ='${Logged1} Delete ' . tmpl_spec[0] . '\' . one_item
    endfor
endwhile

" Sort directory list in reverse order:
call sort(dir_list)
call reverse(dir_list)

" Generate commands to remove directory, duplicated items will be removed:
execute 'buffer ' . buf_id_uninst
$put =''
$put ='# Remove directories:'

let last_dir = ''
for one_item in dir_list
    if one_item !=# last_dir
        let last_dir = one_item
        $put ='${Logged1} RMDir ' . one_item
    endif
endfor

" Save install commands:
execute 'buffer '  . buf_id_install
execute 'saveas! ' . g:fname_install

" Save un-install commands:
execute 'buffer '  . buf_id_uninst
execute 'saveas! ' . g:fname_uninst

" Restore compatibility:
let &cpo = s:save_cpo

" All done, quit:
qall
