" vi:set ts=8 sts=4 sw=4 fdm=marker:
"
" This Vim script is used to generate NSIS commands to install/uninstall files
" from templates held in the current buffer.  Each line in the current buffer
" is one template in the following format:
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
"
" Maintainer:  Guopeng Wen <wenguopeng AT gmail.com>
" Last Change: 2011-01-30

" Set compatibility to Vim default:
let s:save_cpo = &cpo
set cpo&vim

" Record the buffer number/name of the current buffer (template buffer):
let buf_id_tmpl  = bufnr('%')
let tmpl_name    = bufname('%')

" Line of text in the current buffer:
let num_tmplates = line('$')

" New buffer for NSIS install commands:
new
setlocal bufhidden=hide
call setline('$', '# Generated commands for NSIS installer, do not edit.')
let buf_id_install = bufnr('%')

" Set default name for the install command file:
if exists("g:fname_install") == 0
    let g:fname_install = 'install-cmds.nsi'
endif

" New buffer for NSIS uninstall commands:
new
setlocal bufhidden=hide
call setline('$', '# Generated commands for NSIS uninstaller, do not edit.')
let buf_id_uninst  = bufnr('%')

" Set default name for the uninstall command file:
if exists("g:fname_uninst") == 0
    let g:fname_uninst = 'uninst-cmds.nsi'
endif

" Process templates in the input buffer:
let line_num   = 1
let lines      = []
let raw_tmpl   = ''
let tmpl_spec  = []
let msg_prefix = ''
let temp_msg   = ''
let file_list  = []
let dir_list   = []
let one_item   = ''
while line_num <= num_tmplates
    " Prefix for debug message output:
    let msg_prefix = '# Line ' . line_num . ': '

    " Read one line from the template buffer:
    let lines    = getbufline(buf_id_tmpl, line_num)
    let line_num = line_num + 1
    if (len(lines) < 1)
        " Ignore if read fail:
        continue
    endif

    let raw_tmpl = lines[0]

    " Clean up:
    let raw_tmpl = substitute(raw_tmpl, '^\s\+', '', '')
    let raw_tmpl = substitute(raw_tmpl, '\s\+$', '', '')

    " Skip empty line:
    if (len(raw_tmpl) < 1)
        continue
    endif

    " Skip comments (lines started with '#'):
    if (strpart(raw_tmpl, 0, 1) ==# '#')
        continue
    endif

    " Please refer to comments in file header for format of each line:
    "   <target-path> , <src-pattern>
    let tmpl_spec = split(raw_tmpl, '\s*,\s*', 1)

    " Skip those lines with incorrect format.  Error message will be embedded
    " in the output buffer directly:
    if (len(tmpl_spec) != 2)
        let temp_msg = msg_prefix . 'Syntax error, skip: ' . raw_tmpl

        execute 'buffer ' . buf_id_install
        $put =''
        $put =temp_msg
        $put ='!error \"Syntax error in [' . tmpl_name . ']!$\n\'
        $put ='        Please check [' .  g:fname_install .
            \ '] for detail.\"'

        execute 'buffer ' . buf_id_uninst
        $put =''
        $put =temp_msg

        continue
    endif

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
