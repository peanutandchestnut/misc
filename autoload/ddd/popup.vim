function ddd#popup#find_cursor_popup(...)
  let radius = get(a:000, 0, 2)
  let srow = screenrow()
  let scol = screencol()

  " it's necessary to test entire rect, as some popup might be quite small
  for r in range(srow - radius, srow + radius)
    for c in range(scol - radius, scol + radius)
      let winid = popup_locate(r, c)
      if winid != 0
        return winid
      endif
    endfor
  endfor

  return 0
endfunction

function ddd#popup#scroll_cursor_popup(down)
  let winid = ddd#popup#find_cursor_popup()
  if winid == 0
    return 0
  endif

  let pp = popup_getpos(winid)
  call popup_setoptions( winid,
        \ {'firstline' : pp.firstline + ( a:down ? 1 : -1 ) } )

  return 1
endfunction

function ddd#popup#rotate_cursor_popup(ccw)
  let winid = ddd#popup#find_cursor_popup()
  if winid == 0
    return 0
  endif

  let pos_list = ['topleft', 'topright', 'botright', 'botleft']
  let po = popup_getoptions(winid)
  let pp = popup_getpos(winid)
  let next_index = index( pos_list, po.pos ) + ( a:ccw ? -1 : 1 )
  call popup_setoptions( winid, {'posinverse' : 0})
  call popup_move( winid, {'pos' : pos_list[ next_index % 4 ],
        \ 'col' : screencol(), 'line' : screenrow() } )

  return 1
endfunction
