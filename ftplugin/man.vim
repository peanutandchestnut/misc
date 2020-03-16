" filetype check is needed as i call runtime ftplugin/man.vim in my vimrc
if exists('b:loaded_man_cfg') || &filetype != "man"
  finish
endif
let b:loaded_man_cfg = 1

setlocal nolist
nnoremap <buffer> s :Section<cr>
nnoremap <buffer> S :SubSection<cr>
nnoremap <buffer> o :Option<cr>
nnoremap <buffer> i /\v^\s*

com -buffer Section FFline \v\C^[A-Z][^a-z]*$
com -buffer Option FFline \v\C^\s+\-\-?\w
com -buffer SubSection FFline \v\C^   \S.*$
