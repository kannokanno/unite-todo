let s:save_cpo = &cpo
set cpo&vim

let g:unite_todo_data_directory = get(g:, 'unite_todo_data_directory', get(g:, 'unite_data_directory', expand('~/.unite')))
let g:unite_todo_note_suffix = get(g:, 'unite_todo_note_suffix', 'txt')
let g:unite_todo_note_title = get(g:, 'unite_todo_note_title', 0)
 
let s:todo_file = printf('%s/todo/todo.txt', g:unite_todo_data_directory)
let s:note_dir = printf('%s/todo/note', g:unite_todo_data_directory)

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

  let note_title = g:unite_todo_note_title ? words[2] : words[0]
  return {
        \ 'id': words[0],
        \ 'status': words[1],
        \ 'title': words[2],
        \ 'tags': tags,
        \ 'note': unite#todo#formatNoteString(note_title),
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

function! unite#todo#new(id, title) abort
  call unite#todo#checkExists(a:id)
  return unite#todo#struct(join([a:id, '[ ]', a:title], ','))
endfunction

" TODO dirty
function! unite#todo#input(args, use_range, line1, line2)
  let args = split(a:args)
  let todo_list = a:use_range ?
        \ unite#todo#add(reverse(getline(a:line1, a:line2))) :
        \ unite#todo#add([input('Todo:')])

  if count(args, '-tag') > 0
    for todo in todo_list
      let tags = unite#todo#trim(input(printf('[%s] Tags(comma separate):', todo.title)))
      if !empty(tags)
        let todo.tags = map(split(tags, ','), '"@".v:val')
        call unite#todo#rename(todo)
      endif
    endfor
  endif
  if count(args, '-memo') > 0
    for todo in todo_list
      tabnew 
      call unite#todo#open(todo)
    endfor
  endif
endfunction

" TODO もうちょい綺麗に
function! unite#todo#add(title_list)
  let added = []
  let size = len(a:title_list)
  if size == 0
    echo 'todo is empty'
  else
    for l:title in a:title_list
      let trimmedTitle = unite#todo#trim(l:title)
      if !empty(trimmedTitle)
        try
          let todo = unite#todo#new(s:normalization(trimmedTitle), trimmedTitle)
        catch "existsSameTask"
          continue
        endtry
        call unite#todo#update(insert(unite#todo#all(), todo))
        call add(added, todo)
      endif
    endfor
  endif
  return added
endfunction

function! unite#todo#trim(str)
  return substitute(a:str, '^\s\+\|\s\+$', '', 'g')
endfunction

function! unite#todo#rename(newTodo)
  let list = []
  for oldTodo in unite#todo#all()
    if oldTodo.id == a:newTodo.id
      if oldTodo.title != a:newTodo.title
        try
          call add(list, unite#todo#changeTitle(oldTodo, a:newTodo.title))
        catch "existsSameTask"
          return
        endtry
      else
        call add(list, a:newTodo)
      endif
    else
      call add(list, oldTodo)
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

function! unite#todo#open(todo)
  execute ':edit ' . a:todo.note
endfunction

function! s:normalization(str)
  let l:str = a:str
  let l:str = substitute(l:str, "[ /\\'\"]", '_', 'g')
  return l:str
endfunction

function! unite#todo#checkExists(id) abort
  let existings = filter(readfile(s:todo_file), 'v:val =~ "' . a:id . ',.*"')
  if len(existings)
    echom " "
    echom "同一タスクが存在しています"
    throw "existsSameTask"
  endif
endfunction

function! unite#todo#formatNoteString(note_title)
  return printf('%s/%s.%s', s:note_dir, a:note_title, g:unite_todo_note_suffix)
endfunction

function! unite#todo#changeTitle(oldTodo, newTitle) abort
  let l:oldNote = a:oldTodo.note
  let l:newTodo = a:oldTodo
  let l:newTodo.id = s:normalization(a:newTitle)
  call unite#todo#checkExists(l:newTodo.id)
  let l:newTodo.title = a:newTitle
  let l:newTodo.note = unite#todo#formatNoteString(a:newTitle)
  call rename(l:oldNote, l:newTodo.note)
  return l:newTodo
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
