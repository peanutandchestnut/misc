let s:op = {}

function s:op.select()
  if self.visual
    exec 'norm! gv'
  else
    " `] inside an opfunc is inclusive, it's different from last change.
    exe printf('norm! `[%s`]', self.wise)
  endif
endfunction

" return {wise: , visual: ,start:, end:, text: , optype: }
" optype is original type, you need it to call other operations
function ddd#op#new(type, op_args, ...) abort
  let visual = get(a:op_args, 0, 0)
  if visual
    let wise = visualmode()
    let start = getpos("'<")
    let end = getpos("'>")
  els
    let wise = a:type ==# 'line' ? 'V' : a:type ==# 'char' ? 'v' : "\<ctrl-v>"
    let start = getpos("'[")
    let end = getpos("']")
  endif

  let notext = get(a:000, 0, 0)
  let text = notext ? '' : dddu#get_pos_string(start, end, wise)

  let op = deepcopy(s:op)
  let op.wise = wise
  let op.visual = visual
  let op.start = start
  let op.end = end
  let op.text = text
  let op.optype = a:type

  return op

endfunction


" op can be opfunc or mapping
function ddd#op#execute(operation, op) abort
  if exists('*'.a:operation)
    call call (a:operation, [a:op.optype, a:op.visual])
  else
    call a:op.select()
    exec 'norm' a:operation
  endif
endfunction

function ddd#op#search_literal(type, ...) abort
  let op = ddd#op#new(a:type, a:000)
  let @/ = dddu#literalize_vim(op.text)
endfunction

function ddd#op#substitude_literal(type, ...) abort
  call call('ddd#op#search_literal', [a:type] + a:000)
  call feedkeys(':%s//')
endfunction

function ddd#op#search_in_browser(type, ...)
  let op = ddd#op#new(a:type, a:000)
  let cmd = printf(
        \ 'google-chrome "http://google.com/search?q=%s" &>/dev/null &', op.text)
  call system(cmd)
endfunction

function ddd#op#system(type, ...) abort
  let visual = get(a:000, 0, 0)
  let op = ddd#op#new(a:type, a:000)
  let cmd = input('shell command : ')
  call setreg('"', trim(system(cmd, op.text)), 'v')
  call op.select()
  norm! p
endfunction

" a-b        : range(a, b)
" a,b        : a and b
" a-         : a until last
" -b         : 1 until b
function ddd#op#get_column(type, ...) abort
  let column = input('column : ')
  if empty(column) || column <= 0 | return | endif

  let cmd = ''
  let first = 1
  for item in split(column, ',')

    " print OFS for non first item
    if !first
      let cmd .= ' printf OFS;'
    endif
    let first = 0

    if item =~# '-'
      let [i0, i1] = split(item, '\v\s*\-\s*', 1)
      if i0 ==# '' | let i0 = 1 | endif

      if i1 ==# ''

        " print until last filed
        let cmd .= printf('for(i=%d;i<=NF;i++) {printf "%%s", (i==%d ? "" : OFS) $i}; ', i0, i0)
      else
        let cmd .= ' printf "%s", ' . join(map(range(i0, i1), '''$'' . v:val'), ' OFS ') . ';'
      endif
    else
      let cmd .= printf('printf "%%s", $%d; ', item)
    endif
  endfor
  let cmd .= ' printf "\n";'
  let cmd = printf("awk '{%s}' ", cmd)

  call ddd#log#debug('column commmand : ' . cmd)
  let op = ddd#op#new(a:type, a:000)

  call setreg(v:register, system(cmd, op.text), "\<c-v>")
endfunction

function ddd#op#clang_format(type, ...) abort

  let op = ddd#op#new(a:type, a:000)

  " clang-format.py will check l:lines to determine range
  let l:lines = printf('%d:%d', op.start[1], op.end[1])
  let cmd = printf('py3file %s', g:ddd_clang_format_py_path)
  call ddd#log#debug('ClangFormat command : ' . cmd)
  exec cmd
endfunction

function ddd#op#setup_keep_cursor(func)
  let &opfunc = a:func
  call s:store_cursor()
  return 'g@'
endfunction

function s:restore_cursor() abort
  if !exists('s:cpos')
    return
  endif
  call setpos('.', s:cpos)
endfunction

function s:store_cursor() abort
  let s:cpos = getcurpos()
endfunction

" mimic https://github.com/t9md/atom-vim-mode-plus/wiki/OccurrenceModifier
" omo short for Occurence Modifier Operator
function ddd#op#omo(operator) abort
  let s:omo_old_mark_a = getpos("'a")
  let cpos = getcurpos()

  " goto start of word only if it's \w
  if dddu#get_cc() =~# '\w'
    norm! yiw
  endif

  " there is no way to get current word position in opfunc, must mark it here
  norm! ma
  call setpos('.', cpos)
  exe 'set opfunc=ddd#op#omo_' . a:operator

  " use i to make sure it works with norm co..
  call feedkeys('g@', 'im')
endfunction

function ddd#op#omo_co(type, ...) abort

  let op = ddd#op#new(a:type, a:000)

  " select text, release, gv will be used in co_insert_leave
  call op.select()
  exe "norm! \<esc>"

  " hook callback
  augroup mo_co_insert
    au!
    autocmd InsertLeave <buffer> ++once call s:co_insert_leave()
  augroup end

  " go back to starting position, change current word
  norm! `a

  let s:omo_cnr = changenr()

  " use i to make sure it works with norm co..
  call feedkeys( dddu#get_cc() =~# '\w' ? 'ciw' : 'cl', 'in' )

endfunction

function ddd#op#omo_do(type, ...) abort
  let op = ddd#op#new(a:type, a:000)
  call ddd#op#execute('ddd#op#omo_co', op)
  call feedkeys("\<esc>")
endfunction

function ddd#op#omo_guo(type, ...) abort
  let str = tolower(@@)
  let op = ddd#op#new(a:type, a:000)
  call ddd#op#execute('ddd#op#omo_co', op)
  call feedkeys(printf("%s\<esc>", str))
endfunction

function ddd#op#omo_gUo(type, ...) abort
  let str = toupper(@@)
  let op = ddd#op#new(a:type, a:000)
  call ddd#op#execute('ddd#op#omo_co', op)
  call feedkeys(printf("%s\<esc>", str))
endfunction

function ddd#op#omo_gso(type, ...) abort
  let chars = split(@@, '\zs')
  let str = join(map(chars, {i,v -> v=~# '[a-z]' ? toupper(v) : tolower(v)}), '')
  let op = ddd#op#new(a:type, a:000)
  call ddd#op#execute('ddd#op#omo_co', op)
  call feedkeys(printf("%s\<esc>", str))
endfunction

function s:co_insert_leave() abort
  let cword = @"
  let replacement = dddu#get_last_change()
  let is_word = cword !~# '\W'

  try
    " undo last change, all change are done in following :substitute, this also
    " make sure `< and `> is still valid.
    exe 'undo ' s:omo_cnr

    norm! `a

    " setup search pattern, restrict it in operator text
    let cword_len = len(cword)
    if is_word
      if cword_len == 1
        let @/ = printf('\v\C%%V<%s>', cword)
      else
        let @/ = printf('\v\C%%V<%s%%V%s>', cword[0:-2], cword[-1:-1])
      endif
    else
      if len(cword) != 1
        throw 'unknown state, changing multiple non-word characters'
      endif
      let w = escape(cword, '\')
      let @/ = printf('\V\%%V%s', w)
    endif

    call ddd#log#debug('omo : @/ : ' . @/)

    " replace all matching iterms, including the start one
    let cmd = printf("'<,'>s//%s/eg", substitute(replacement, '\n', '\r', 'g'))
    call ddd#log#debug('omo : substitute : ' . cmd)
    exe cmd
  finally
    norm! `a
    let @@ = cword
    call setpos("'a", s:omo_old_mark_a)
  endtry
endfunction
