let s:save_cpo = &cpo
set cpo&vim
 
let s:base_dir = get(g:, 'unite_data_directory', expand('~/.unite'))
let s:todo_file = s:base_dir . '/todo/todo'
let s:note_dir = s:base_dir . '/todo/note'

function! unite#todo#init()
  if !isdirectory(s:note_dir)
    call mkdir(s:note_dir, 'p')
  endif
  if empty(glob(s:todo_file))
    call writefile([], s:todo_file)
  endif
endfunction

function! unite#todo#struct(line)
  let words = split(a:line, ',') 
  if len(words) < 4
    let tags = [] 
  elseif len(words) == 4
    let tags = [words[3]] 
  else
    let tags = words[3:]
  endif
  return {
        \ 'id': words[0],
        \ 'status': words[1],
        \ 'title': words[2],
        \ 'tags': tags,
        \ 'note': s:note_dir . '/' . words[0] . '.txt',
        \ 'line': a:line,
        \ }
endfunction

function! unite#todo#select(pattern)
  let todo_list = map(readfile(s:todo_file), 'unite#todo#struct(v:val)')
  return empty(a:pattern) ? todo_list : filter(todo_list, a:pattern)
endfunction

function! unite#todo#all()
  return unite#todo#select([])
endfunction

function! unite#todo#update(structs)
  call writefile(
        \ map(a:structs, 'join([v:val.id, v:val.status, v:val.title, join(v:val.tags, ",")], ",")'),
        \ s:todo_file)
endfunction

function! unite#todo#new(id, title)
  return unite#todo#struct(join([a:id, '[ ]', a:title], ','))
endfunction

" TODO もうちょい綺麗に
function! unite#todo#add(title_list)
  let size = len(a:title_list)
  if size == 0
    echo 'todo is empty'
  else
    for i in range(0, size-1)
      let title = unite#todo#trim(a:title_list[i])
      if !empty(title)
        call unite#todo#update(insert(unite#todo#all(), unite#todo#new(localtime().'_'.i, title)))
      endif
    endfor
  endif
endfunction

function! unite#todo#trim(str)
  return substitute(a:str, '^\s\+\|\s\+$', '', 'g')
endfunction

function! unite#todo#rename(todo)
  let list = []
  for todo in unite#todo#all()
    if todo.id == a:todo.id 
      call add(list, a:todo)
    else
      call add(list, todo)
    endif
  endfor
  call unite#todo#update(list)
endfunction

function! unite#todo#delete(todo)
  let note = a:todo.note
  if filewritable(note) && !isdirectory(note)
    call delete(note)
  endif
  call unite#todo#update(unite#todo#select('v:val.id !=# "'.a:todo.id.'"'))
endfunction

function! unite#todo#toggle(todo)
  let list = []
  for todo in unite#todo#all()
    if todo.id == a:todo.id 
      let todo.status = todo.status =~ '^\[X\]' ? 
            \ "[ ]" :
            \ "[X]<".strftime("%Y/%m/%d %H:%M").">"
    endif
    call add(list, todo)
  endfor
  call unite#todo#update(list)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
