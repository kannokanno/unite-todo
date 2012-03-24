let s:vimticket_dir = expand('~/.vimticket')
let s:vimnotes_dir = s:vimticket_dir . '/notes'

function! vimticket#add#simple()
  call s:update([input('Ticket #1:')])
endfunction

function! vimticket#add#each()
  call s:update(getbufline('%', 1, '$'))
endfunction

" TODO indexにidとファイルパスをもたせた方が管理しやすい
function! s:update(tickets)
  let list = []
  let file = s:vimticket_dir. '/tickets.txt'
  if !isdirectory(s:vimnotes_dir)
     call mkdir(s:vimnotes_dir)
  endif
  if filereadable(file)
    for line in readfile(file)
      call add(list, line)
    endfor
  else
    " TODO
    echo 'unread:' . file
  endif

  for ticket in a:tickets
    call add(list, "[ ] " . ticket)
  endfor
  call writefile(list, file)
endfunction
