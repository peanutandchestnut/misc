let s:maps = {}

function! misc#ui#loadMaps(maps)
  for item in a:maps
    call misc#ui#bindKey(item[0], item[1], item[2], item[3], item[4])
  endfor
endfunction

function! misc#ui#bindKey(key, mode, no, filetypes, map) abort
  if a:map ==# '' | return | endif

  let hasNvim = has('nvim')

  if a:filetypes == []
    " global map
    for index in  range(len(a:mode))
      if !hasNvim && a:mode[index] ==# 't' | continue | endif
      exec printf('%s%smap %s %s', a:mode[index], a:no?'nore':'', a:key, a:map)
    endfor
    return
  endif

  for ft in a:filetypes
    if !has_key(s:maps, ft) | let s:maps[ft] = [] | endif
    let s:maps[ft] += [{'key':a:key, 'mode':a:mode, 'no':a:no, 'map':a:map}]
  endfor
endfunction

function! misc#ui#loadFiletypeMap(ft) abort
  if !has_key(s:maps, a:ft) | return | endif

  let maps = s:maps[a:ft]
  for item in maps
    if item.map ==# ''
      echoe string(item).' has blank map' | continue
    endif
    for index in  range(len(item.mode))
      exec printf('%s%smap <buffer> %s %s', item.mode[index], item.no?'nore':'', item.key, item.map)
    endfor
  endfor
endfunction

function! misc#ui#loadAutoMap(ft) abort
  if !has_key(s:maps, a:ft) | return | endif

  let maps = s:maps[a:ft]
  exec 'augroup auto_map_' . a:ft | au!
  for item in maps
    if item.map ==# ''
      echoe string(item).' has blank map' | continue
    endif
    for index in range(len(item.mode))
      exec printf('autocmd BufReadPost %s %s%smap <buffer> %s %s',
            \ a:ft, item.mode[index], item.no?'nore':'', item.key, item.map)
    endfor
  endfor
  augroup END
endfunction

function! misc#ui#loadProjSetting(projType)
  let projMap = get(g:projMaps, a:projType, [])
  if projMap == [] | return | endif
  "call misc#switchRtp('./.vim')
  call misc#ui#loadMaps(projMap)
endfunction
