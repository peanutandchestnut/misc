" vim:set foldmethod=marker :

" This vimrc should also work for 8.0(default version on ubuntu18.04).
"
" Map and command are public interface, plugin settings and functions are
" private implementation, interface must appear before implementation.

                                   " options {{{1

" show tab and trailing space
scriptencoding utf-8
set list listchars=trail:┄,tab:†·,extends:>,precedes:<,nbsp:+
scriptencoding

" add common source to path
set path+=**

" ignore tool and build
set wildignore=*/build/*,*/.git/*,*/.hg/*,*/.vscode/*,*/.clangd/*,*.o,*.a,*.so,*.dll,tags
set wildignorecase

" reduce esc delay to a acceptable number
set ttimeout ttimeoutlen=5 timeoutlen=1000

" copy indent of current line to newline
set autoindent

" smart indent for {, }, 'cinwords', #
set smartindent

" no tab, use shiftwidth in front of a line. use 4 for <tab> or <bs>
set expandtab smarttab shiftwidth=4 tabstop=8 softtabstop=4

" traditional backspace
set backspace=indent,eol,start

" turn on \C if uppercase letter appears in the pattern for /,?,:g,:s,n,N., not
" for *,# (unless you use / after them)
set ignorecase smartcase

" trigger CursorHold more frequently, required by coc
set updatetime=300

" make <c-a>, <c-x> work on decimal, hex, binary
set nrformats=octal,hex,bin

" mv swp, bak, undo out of file directory, use %usr%home%.vimswap%... style name
let &backup = !has('vms')
set backupdir=$HOME/.vimbak//
set directory=$HOME/.vimswap//
set undofile undodir=$HOME/.vimundo//

" hide buffer when it's abandoned
set hidden

" bash style wild menu
set wildmenu
set wildmode=list:longest

" use unix / and 0a as new line in session file
set sessionoptions+=unix,slash

" use unix / in expand()
set shellslash

" scan current and included files(might cause problem if lots file are
" included), restrict pop up menu height,
set complete-=i pumheight=16

" enable mouse for all modes. Sometimes you need it to copy something.
set mouse=a

" conceal only in visual and normal mode
set concealcursor=vn conceallevel=0

" add per project setting
set rtp+=.dedowsdi,.dedowsdi/after

" display search count
set shortmess-=S

if has('nvim')
  set rtp+=~/.vim
endif

" search tag in dir of current file upward until root, use current dir tags if
" nothing found
" set tags=./tags;,tags

" add -I to ignore binary file, exclude some dirs
let &grepprg = 'grep -n $* /dev/null --exclude-dir={.git,.hg,.clangd} -I'

if executable('zsh')
  let &shell = '/bin/zsh -o extendedglob'
endif

" some common fileencoding, the less general encoding must appear before the
" more general one
set fileencodings=ucs-bom,utf-8,default,gb18030,utf-16,latin1

" add spell to i_ctrl-x_ctrl-k
set spell spelllang=en_us dictionary+=spell

" save mark for 500files, limit saved register to 50 lines, exclude register
" greater than 10kbytes, no hlsearch during loading of viminfo.
set viminfo='500,<50,s10,h

" viminfo= doesn't expand environment variable, check n of viminfo for detail.
" don't save anything for help files.
let &viminfo .= ',r'.$VIMRUNTIME.'/doc'

" trivial options
set incsearch
set background=dark
set history=1000
set undolevels=5000
set number ruler
set laststatus=2 cmdheight=2
set scrolloff=1
set showmode showcmd novisualbell
set noshowmatch matchtime=3 matchpairs+=<:>
set belloff=esc
set nofoldenable
set signcolumn=number

                                " plugin {{{1

" ale {{{2
nnoremap <c-f7>  :ALELint<cr>

let g:ale_vim_vint_show_style_issues = 0
let g:ale_linters_explicit = 1

" you can not disable lint while enable language server, so i turn off auto
" lint.
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
let g:ale_lint_on_save = 1
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_insert_leave = 0

let g:ale_linters = {
\   'vim': ['vint'],
\   'sh': ['shellcheck'],
\   'glsl' : [],
\   'python' : [],
\   'cpp'  : []
\}

" ultisnips {{{2
let g:UltiSnipsExpandTrigger='<tab>'
let g:UltiSnipsJumpForwardTrigger='<c-j>'
let g:UltiSnipsJumpBackwardTrigger='<c-k>'

" split your window for :UltiSnipsEdit
let g:UltiSnipsEditSplit='vertical'

" coc.nvim {{{2
inoremap <silent><expr> <c-space> coc#refresh()
nnoremap <c-s> :call CocActionAsync('showSignatureHelp')<cr>
inoremap <c-s> <c-r>=CocActionAsync('showSignatureHelp')<cr>

nmap <f2> <Plug>(coc-rename)
nnoremap <f4> :CocHover<cr>
nmap <s-f10> <Plug>(coc-references)
nmap <f12> <Plug>(coc-definition)
nmap <c-f12> <Plug>(coc-type-definition)
nmap <s-f12> <Plug>(coc-implementation)

com CocDiagnosticInfo exec "norm \<plug>(coc-diagnostic-info)"
com CocReference exec "norm \<plug>(coc-references)"
com CocHover call CocActionAsync('doHover')
com CocCodeAction call CocActionAsync('codeAction')

" fugitive {{{2
com -nargs=* Glg Git! log --graph --pretty=format:'%h - <%an> (%ad)%d %s' --abbrev-commit --date=local <args>

" lightline {{{2
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'cocstatus', 'readonly', 'filename', 'modified'] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head',
      \   'cocstatus': 'coc#status',
      \ },
      \ 'component':
      \ {
      \     'test':'hello tabline'
      \ },
      \ }
augroup au_coc_status
  au!
  " it's annoying, it pollutes message and input prompt
  " autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()
augroup end

if &t_Co == 256
  let g:lightline.colorscheme = 'gruvbox'
endif

" hare {{{2
let s:find_exclude = '-name .hg -o -name .git -o -name build -o -name .vscode -o -name .clangd'
let g:project_source = printf('find . -type d \( %s \) -prune -o -type f -print', s:find_exclude)
nnoremap <c-p> :exe 'Hare file !' . g:project_source<cr>
nnoremap <c-h> :Hare file oldfiles<cr>
nnoremap <a-p> :exe 'Hare file !find . -type f'<cr>
nnoremap <c-b> :call misc#hare#jump('file',
            \ map(split(execute('ls'), "\n"), {i,v->matchstr(v, '\v.*"\zs.+\ze"')})
            \)<cr>
nnoremap <c-j> :call misc#hare#jump('btag',
            \ printf('!ctags --fields=-l -f -  %s <bar> cut -f1,3-', expand('%')), '/\v^')<cr>
nnoremap <a-j> :call misc#hare#jump('tag', function('<sid>read_tags', [""]), '/\v^')<cr>

let g:find_path = []
com Find exe printf('Hare file !find %s -type d \( %s \) -prune -o -type f -print',
            \ join(g:find_path), s:find_exclude)
com Folds Hare line /\v.*\{\{\{\d*$
com GrepCache exe 'Hare fline !cat' expand('%')
com -nargs=1 Readtags call misc#hare#jump('tag', function('s:read_tags', [<f-args>]), '/\v^')

" kinds is a combination of single letter kind
function s:read_tags(kinds) abort
  if !empty(a:kinds)
    let ors = map(split(a:kinds, '\zs'), {i,v->printf('(prefix? $kind "%s")', v)})
    let condition = printf('-Q ''(or %s )''', join(ors) )
  endif

  for tag in tagfiles()
    " must add tag parent path for this to work
    call append('$', printf("!_TAG_PARENT_PATH\t%s", fnamemodify(tag, ':p:h')))
    if empty(a:kinds)
      exe '$read' tag
    else
      exe printf('$read !readtags -t %s %s -el | grep -v "^__anon"', tag, condition)
    endif
  endfor
endfunction

" fzf {{{2

" fzf maps, commands {{{3\v^\!_TAG_PARENT_PATH\t\zs\s+

imap <a-x><a-k> <plug>(fzf-complete-word)
imap <a-x><a-f> <plug>(fzf-complete-path)
imap <a-x><a-j> <plug>(fzf-complete-file-ag)
imap <a-x><a-l> <plug>(fzf-complete-line)

com -nargs=* Ctags :call <SID>fzf_cpp_tags(<q-args>)

" select file from cached grep result

" fzf options {{{3
set rtp+=~/.fzf

function s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen | cc
endfunction

let g:fzf_action = {
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vertical rightbelow split',
      \ 'ctrl-a': 'argadd',
      \ 'ctrl-o': '!gio open',
      \ 'ctrl-q': function('s:build_quickfix_list')
      \ }
let g:fzf_layout = {'up':'~40%'}

" fzf helper functions {{{3

function s:fzf_cpp_tags(...)
  let query = get(a:000, 0, '')
  " there exists an extra field which i don't know how to control in
  " fzf#vim#tags, that's why it use 1,4..-2
  let tags_options = { 'options' : '--no-reverse -m -d "\t" --tiebreak=begin
              \ --with-nth 1,4..-2 -n .. --prompt "Ctags> "'}
  call fzf#vim#tags(
        \ query,
        \ extend(copy(g:fzf_layout), tags_options))
endfunction

" vimtex {{{2
com -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk -layout <q-args> -
com -complete=file -nargs=1 Rpdffmt :r !pdftotext
            \ -nopgbrk -layout <q-args> - |fmt -csw78

let g:tex_flavor = 'latex'

" vim-json {{{2
let g:vim_json_syntax_conceal = 0

" gutentags {{{2
let g:gutentags_project_root = ['.dedowsdi']
let g:gutentags_exclude_project_root = [$HOME]
let g:gutentags_exclude_filetypes = ['cmake', 'sh', 'json', 'md', 'text']
let g:gutentags_define_advanced_commands = 1
let g:gutentags_ctags_options_file = '.vim/.gutctags'

" easyalign {{{2
nmap     ,a  <Plug>(EasyAlign)
vmap     ,a  <Plug>(EasyAlign)

" commentary {{{2
map      ,c  <Plug>Commentary
nmap     ,cc <Plug>CommentaryLine
nmap     ,cu <Plug>Commentary<Plug>Commentary

" eython {{{2
map  <silent> ,e         <plug>eython_motion
vmap <silent> ie         <plug>eython_textobject_ie
omap <silent> ie         <plug>eython_textobject_ie
imap <silent> <c-x><c-n> <plug>eython_complete_next
imap <silent> <c-x><c-p> <plug>eython_complete_prev

" .vim {{{2
let g:dedowsdi_clang_format_py_path = '/usr/share/clang/clang-format-8/clang-format.py'
" let g:dedowsdi_clang_format_fallback_style = 'LLVM'

let g:dedowsdi_hist_use_vim_regex_search = 1
let g:dedowsdi_popup_scroll_keys = ['<c-y>', '<c-e>', '<c-f>']

" install plugins {{{2
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd! vim_plug_init VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" common
Plug 'mbbill/undotree'
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tommcdo/vim-exchange'

" colorscheme
Plug 'morhetz/gruvbox'

" comment
Plug 'tpope/vim-commentary'

" status line
Plug 'itchyny/lightline.vim'

" fuzzy
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" lint
Plug 'w0rp/ale'

" snippets
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'

" tags
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar'

" auto complete
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dedowsdi/vim-eython'

" ftplugin
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'othree/html5.vim'
Plug 'elzr/vim-json'
Plug 'tikhomirov/vim-glsl'
Plug 'lervag/vimtex'
Plug 'dedowsdi/cdef'

call plug#end()

                                  " misc {{{1

runtime! ftplugin/man.vim
set keywordprg=:Man

call misc#terminal#setup()

" plug#end() already call these commented commands
" filetype plugin indent on
" syntax enable

let g:gruvbox_number_column='bg1'
colorscheme gruvbox

" must be applied after colorscheme, avoid highlight overwrite.
if v:version > 800
  packadd! cfilter
  packadd! termdebug
endif
packadd! matchit

augroup zxd_misc
  au!

  if v:version > 800

    " too dangerious?
    " autocmd DirChanged * if filereadable('.vim/init.vim') | source .vim/init.vim | endif
    if !has('nvim')
      autocmd TerminalWinOpen * setl nonumber norelativenumber
    endif
  endif

  autocmd InsertEnter,InsertLeave * set cursorline!

  " place cursor to the position when last existing
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

  " no auto comment leader after o or O, remove comment leader when join comment lines
  autocmd FileType * setlocal formatoptions-=o formatoptions+=j
augroup end

" all kinds of maps {{{1

" text object {{{2
function s:add_to(lhs, rhs) abort
    exe printf('vmap %s %s', a:lhs, a:rhs)
    exe printf('omap %s %s', a:lhs, a:rhs)
endfunction

call s:add_to('aa', '<plug>dedowsdi_to_aa')
call s:add_to('ia', '<plug>dedowsdi_to_ia')
call s:add_to('il', '<plug>dedowsdi_to_il')
call s:add_to('al', '<plug>dedowsdi_to_al')
call s:add_to('in', '<plug>dedowsdi_to_in')
call s:add_to('an', '<plug>dedowsdi_to_an')
call s:add_to('ic', '<plug>dedowsdi_to_ic')
call s:add_to('iF', '<plug>dedowsdi_to_iF')
call s:add_to('aF', 'iF')

" motion and operator {{{2
nmap ,E <plug>dedowsdi_mo_vertical_E
nmap ,W <plug>dedowsdi_mo_vertical_W
nmap ,B <plug>dedowsdi_mo_vertical_B
nnoremap ,,  ,

function s:add_op(key, rhs)
    exe printf('nmap %s %s', a:key, a:rhs)
    exe printf('vmap %s %s', a:key, a:rhs)
endfunction

call s:add_op(',h', '<plug>dedowsdi_ahl_remove_cursor_highlights')
nnoremap ,hh :AhlRemoveCursorHighlights<cr>

call s:add_op(',l',     '<plug>dedowsdi_op_search_literal')
call s:add_op(',s',     '<plug>dedowsdi_op_substitute')
call s:add_op(',S',     '<plug>dedowsdi_op_system')
call s:add_op(',<bar>', '<plug>dedowsdi_op_get_column')
call s:add_op(',G',     '<plug>dedowsdi_op_literal_grep')
call s:add_op(',g',     '<plug>dedowsdi_op_search_in_browser')

nmap co  <plug>dedowsdi_op_co
nmap do  <plug>dedowsdi_op_do
nmap guo <plug>dedowsdi_op_guo
nmap gUo <plug>dedowsdi_op_gUo
nmap g~o <plug>dedowsdi_op_g~o
nmap ,f  <plug>dedowsdi_op_clang_format
nmap <expr> ,ff ',f' . v:count1 . '_'

" common maps {{{2
nnoremap <f3>    :set hlsearch!<cr>

nnoremap Y  y$
nnoremap K  :exec 'norm! K' <bar> wincmd p<cr>
nnoremap gc :SelectLastChange<cr>
nnoremap yoc :exe 'set colorcolumn='. (empty(&colorcolumn) ? '+1' : '')<cr>
nnoremap <c-l> :nohlsearch<Bar>diffupdate<CR><C-L>
nnoremap _m :ReadtagsI -ok m -k e <c-r><c-A><cr>

function s:browse_project_source() abort
  NewOneOff
  exe 'read !' g:fzf_project_source
  1
  call matchadd('Comment', '\v^.+$')
endfunction

nnoremap <c-w><space> :tab split<cr>
tnoremap <c-w><space> <c-w>:tab split<cr>
nnoremap <c-w>O :CloseFinishedTerminal<cr>
tnoremap <c-w><pageup> <c-w>:tabprevious<cr>
tnoremap <c-w><pagedown> <c-w>:tabnext<cr>
nnoremap <c-w><pageup> <c-w>:tabprevious<cr>
nnoremap <c-w><pagedown> <c-w>:tabnext<cr>
nnoremap <expr> <c-w>0 printf(':<c-u>%dWinFitBuf<cr>', v:count)

if v:version > 800
  cmap <tab> <Plug>dedowsdi_hist_expand_hist_wild
  set wildchar=<c-z>
endif

nmap ys<space> <plug>dedowsdi_misc_pair_add_space
nmap ds<space> <plug>dedowsdi_misc_pair_minus_space

cmap <c-a> <Plug>dedowsdi_readline_beginning_of_line
cnoremap <a-a> <c-a>
cmap <a-f> <Plug>dedowsdi_readline_forward_word
cmap <a-b> <Plug>dedowsdi_readline_backward_word
" cmap <c-f> <Plug>dedowsdi_readline_forward_char
" cmap <c-b> <Plug>dedowsdi_readline_backward_char
cmap <a-u> <Plug>dedowsdi_readline_uppercase_word
cmap <a-l> <Plug>dedowsdi_readline_lowercase_word
cmap <a-d> <Plug>dedowsdi_readline_forward_delete
cmap <a-k> <Plug>dedowsdi_readline_kill

nmap <c-w>` <plug>dedowsdi_term_toggle_gterm
tmap <c-w>` <plug>dedowsdi_term_toggle_gterm

                                  " command {{{1

com HiTest source $VIMRUNTIME/syntax/hitest.vim
com TrimTrailingWhitespace :keepp %s/\v\s+$//g
com DiffOrig vert new | set bt=nofile | r ++edit # | 0d_
  \ | diffthis | wincmd p | diffthis
com SelectLastChange exec 'normal! `[' . getregtype() . '`]'
com ReverseQuickFixList call setqflist(reverse(getqflist()))
com SuperWrite :w !sudo tee % > /dev/null
com -bang CfilterCoreHelp Cfilter<bang> '\v/vim/vim\d+/doc/[^/]+\.txt'
com Synstack echo map( synstack(line('.'), col('.')), 'synIDattr(v:val, "name")' )
com SynID echo synIDtrans(synID(line('.'), col('.'), 1))
com -nargs=+ SynIDattr echo synIDattr(
            \ synIDtrans(synID(line('.'), col('.'), 1)), <f-args>)
com ReloadDotVimFtplugin unlet b:loaded_{&filetype}_cfg | e
com-range UnsortUniq let g:__d={} | <line1>,<line2>g/^/
      \ if has_key(g:__d, getline('.')) | d | else | let g:__d[getline('.')]=1 | endif

" Expand {{{2
" Expand [x=+] [mods=%:p], " is always set
com -nargs=* Expand call s:expand_filepath(<f-args>)

function s:expand_filepath(...)
  if a:0 == 0
    let reg = '+'
    let expr = '%:p'
  elseif a:0 == 1
    if a:1 =~# '\v^[a-zA-Z"*+]$'
      let reg = a:1
      let expr = '%:p'
    else
      let reg = '+'
      let expr = a:1
    endif
  else
    let reg = a:1
    let expr = a:2
  endif

  call setreg(reg, expand(expr))
  call setreg('"', expand(expr))
endfunction

" Browse {{{2
com -nargs=? Browse call s:browse(<f-args>)

function s:browse(...)
  let path = expand(get(a:000, 0, '%:p'))
  call system(printf('google-chrome %s&', path))
endfunction

" NewOneOff
com NewOneOff call <sid>new_oneoff(<q-mods>)

function s:new_oneoff(mods) abort
  exe a:mods 'new'
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted modifiable
  file [one-off]
endfunction

" Less {{{2
com -bang -nargs=+ -complete=command Less call <sid>less(<q-args>, <q-mods>, <bang>0)

function s:less(cmd, mods, replace)

  " get result in current buffer, must be called before new
  let result = execute(a:cmd)
  NewOneOff
  exe printf('file [one-off] %s', a:cmd)
  call setline(1, split(result, "\n"))
  1
  " close old window buffer
  if a:replace
    wincmd p
    wincmd q
  endif
endfunction

" Tapi_cd {{{2
" arglist : [ cwd ]
" change window local working directory
function Tapi_lcd(bufnum, arglist)
  let winid = bufwinid(a:bufnum)
  let cwd = get(a:arglist, 0, '')
  if winid == -1 || empty(cwd)
    return
  endif
  call win_execute(winid, 'lcd ' . cwd)
endfunction

" CloseFinishedTerminal{{{2
com -nargs=0 CloseFinishedTerminal call s:close_finished_terminal()

function s:close_finished_terminal() abort
  let bufs = map(split( execute('ls F'), "\n" ), {i,v -> matchstr(v, '\v^\s*\zs\d+')})
  for buf in bufs
    call win_execute(bufwinid(str2nr( buf )), 'close')
  endfor
endfunction

" Job{{{2
com -nargs=+ -complete=shellcmd Job call s:job(<q-args>)

function s:job(cmd) abort
  call term_start( a:cmd, { 'exit_cb' : function('s:job_exit_cb'), 'hidden'  : 1 } )
endfunction

" if exit 0, wipe self in 10min, otherwise display self in split
function s:job_exit_cb(job, exit_status) abort
  let buf = ch_getbufnr(a:job, 'out')
  if a:exit_status == 0
    echom printf('%s, buf : %d', a:job, buf)

    function! s:clear_job_buf(timer) closure abort
      exe 'bwipe' buf
    endfunction

    let timer_id = timer_start( 10 * 60 * 1000, funcref('s:clear_job_buf') )

    augroup job_event_group
      exe printf('autocmd BufWinEnter <buffer=%d> call timer_stop(%d)', buf, timer_id)
    augroup end

  else
    exe 'botright sbuffer +set\ nonumber\ norelativenumber' buf
  endif
endfunction

" {Enable|Disable}AutoFormatTable
com EnableAutoFormatTable autocmd! auto_format_table BufWrite <buffer> call s:format_table()
com DisableAutoFormatTable autocmd! auto_format_table BufWrite <buffer>

augroup auto_format_table
  autocmd!
augroup end

function s:format_table() abort
  try
    let cview = winsaveview()

    " match only last line of table. It's
    " | ..........| + (endof file | blank line | line that doesn't starts with |)
    g /\v^\s*\|.*\|\s*$%(%$|\n\s*%($|[^|]))/ exe "norm \<Plug>(EasyAlign)ip*|\<cr>"
  finally
    call winrestview(cview)
  endtry
endfunction

" ReadTagMemberNames{{{2
com -nargs=+ ReadtagsI call s:readtags_i(<q-args>)

function s:readtags_i(args) abort
  let cmd = printf( 'readtagsi %s %s',
              \ join( map( tagfiles(), { i,v-> printf('-t "%s"', v)  } ) ),
              \ a:args )
  call misc#log#debug(cmd)
  call append( line('.'), systemlist(cmd) )
endfunction
