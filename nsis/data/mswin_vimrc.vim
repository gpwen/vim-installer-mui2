" Default vimrc for MS Windows.
"
" Use Vim settings with all sorts of enhancement.
set nocompatible
source $VIMRUNTIME/vimrc_example.vim

" Remap for MS Windows:
source $VIMRUNTIME/mswin.vim

" MS Windows behavior for mouse and selection:
behave mswin

" Use the diff.exe that comes with the self-extracting gvim.exe:
set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  " Use quotes only when needed, they may cause trouble:
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''

  " If the path has a space:  When using cmd.exe (Win NT/2000/XP) put quotes
  " around the whole command and around the diff command.  Otherwise put a
  " double quote just before the space and at the end of the command.  Putting
  " quotes around the whole thing doesn't work on Win 95/98/ME.  This is
  " mostly guessed!
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
