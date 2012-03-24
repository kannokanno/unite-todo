let s:save_cpo = &cpo
set cpo&vim

let s:todo_file = g:unite_data_directory . '/todo/todo.txt'
let s:note_dir = g:unite_data_directory . '/todo/note'

if !isdirectory(s:note_dir)
 call mkdir(s:note_dir, 'p')
endif
if empty(glob(s:todo_file))
  call writefile([], s:todo_file)
endif

function! s:update(added)
  call s:init()
  let list = []
  if filereadable(s:todo_file)
    for line in readfile(s:todo_file)
      call add(list, line)
    endfor
  else
    " TODO
    echo 'unread:' . file
  endif

  for todo in a:added
    call add(list, "[ ] " . todo)
  endfor
  call writefile(list, s:todo_file)
endfunction

let s:source = {
      \ 'name':'todo',
      \}

function! s:source.gather_candidates(args, context)
  let lines = readfile(s:todo_file)
  " TODO idをファイル名に
  return map(lines, '{
        \   "word": v:val,
        \   "source": "lines",
        \   "kind": "todo",
        \   "action__path": s:note_dir . "/" . v:val . ".txt",
        \ }')
endfunction
call unite#define_source(s:source)
unlet s:source

let s:kind = {
      \ 'name' : 'todo',
      \ 'default_action' : 'toggle',
      \ 'action_table': {},
      \ 'is_selectable': 1,
      \ 'parents': ['jump_list'],
      \}

let s:kind.action_table.delete = {
      \ 'description' : 'delete todo',
      \ 'is_selectable': 1,
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }
function! s:kind.action_table.delete.func(candidates)
  for candidate in a:candidates
    if filewritable(candidate.action__path) && !isdirectory(candidate.action__path)
      call delete(candidate.action__path)
    endif
    let list = []
    let file = expand(s:todo_file)
    for line in readfile(file)
      if line == candidate.word 
        continue
      endif
      call add(list, line)
    endfor
    call writefile(list, file)
  endfor
endfunction

let s:kind.action_table.toggle = {
      \ 'description' : 'toggle done/undone',
      \ 'is_selectable': 1,
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }
function! s:kind.action_table.toggle.func(candidates)
  for candidate in a:candidates
    let list = []
    let file = expand(s:todo_file)
    for line in readfile(file)
      if line == candidate.word 
        if line =~ '^\[X\]'
          let line = substitute(line, '\[X\]<.*>', '[ ]', "")
        else
          let line = substitute(line, '\[ \]', "[X]<".strftime("%Y/%m/%d %H:%M").">", "")
        endif
      endif
      call add(list, line)
    endfor
    call writefile(list, file)
  endfor
endfunction

call unite#define_kind(s:kind)
unlet s:kind

let &cpo = s:save_cpo

nnoremap <Space><Space> :<C-u>Unite todo<CR>
