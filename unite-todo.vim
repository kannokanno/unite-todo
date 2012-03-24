let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name':'todo',
      \}

function! s:source.gather_candidates(args, context)
  " TODO idをファイル名に
  " TODO action__pathのとり方
  " TODO 正規表現使えないの？
  return map(s:list('v:val !~ "[X]"'), '{
        \   "word": v:val,
        \   "source": "lines",
        \   "kind": "todo",
        \   "action__path": g:unite_data_directory . "/todo/note/" . v:val . ".txt",
        \ }')
endfunction
let &cpo = s:save_cpo

" TODO defineのほうが呼ばれない
call unite#define_source(s:source)
unlet s:source

" =====================================================
" TODO 複数のファイルで共通的に使いたいので、どこか別のファイルに置きたい
let s:save_cpo = &cpo
set cpo&vim
let s:todo_file = g:unite_data_directory . '/todo/todo.txt'
let s:note_dir = g:unite_data_directory . '/todo/note'

function! s:list(pattern)
  let list = []
  for line in readfile(s:todo_file)
    call add(list, line)
  endfor
  return empty(a:pattern) ? list : filter(list, a:pattern)
endfunction

function! s:all()
  return s:list([])
endfunction

function! s:note(id)
  return g:unite_data_directory . "/todo/note/" . a:id . ".txt"
endfunction

function! s:update(list)
  call writefile(a:list, s:todo_file)
endfunction

function! s:add(id)
  call s:update(insert(s:all(), "[ ] " . a:id))
endfunction

" TODO flagはださい
function! s:rename(id, after, append)
  let list = []
  for line in s:all()
    if line == a:id 
      let line = a:append ? line . a:after : a:after
    endif
    call add(list, line)
  endfor
  call s:update(list)
endfunction

function! s:delete(id)
  let note = s:note(a:id)
  if filewritable(note) && !isdirectory(note)
    call delete(note)
  endif
  call s:update(s:list('v:val !=# "'.a:id.'"'))
endfunction

function! s:toggle(id)
  let list = []
  for line in s:all()
    if line == a:id 
      let line = line =~ '^\[X\]' ? 
            \ substitute(line, '\[X\]<.*>', '[ ]', "") :
            \ substitute(line, '\[ \]', "[X]<".strftime("%Y/%m/%d %H:%M").">", "")
    endif
    call add(list, line)
  endfor
  call s:update(list)
endfunction

function! s:tag(id, tag)
  call s:rename(a:id, ' @' . a:tag, 1)
endfunction

let s:kind = {
      \ 'name' : 'todo',
      \ 'default_action' : 'toggle',
      \ 'action_table': {},
      \ 'is_selectable': 1,
      \ 'parents': ['jump_list'],
      \}

let s:kind.action_table.add = {
      \ 'description' : 'add todo',
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }
function! s:kind.action_table.add.func(candidate)
  call s:add(input('Input Todo:'))
endfunction

let s:kind.action_table.rename = {
      \ 'description' : 'rename todo',
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }
function! s:kind.action_table.rename.func(candidate)
  call s:rename(a:candidate.word,
        \input('Rename Todo:' . a:candidate.word . '->',
        \a:candidate.word), 0)
endfunction

let s:kind.action_table.delete = {
      \ 'description' : 'delete todo',
      \ 'is_selectable': 1,
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }
function! s:kind.action_table.delete.func(candidates)
  for candidate in a:candidates
    " TODO 毎回ファイルI/Oさせてるので非効率
    call s:delete(candidate.word)
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
    " TODO 毎回ファイルI/Oさせてるので非効率
    call s:toggle(candidate.word)
  endfor
endfunction

let s:kind.action_table.tag = {
      \ 'description' : 'add tag',
      \ 'is_selectable': 1,
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }
function! s:kind.action_table.tag.func(candidates)
  let tag = input('Input tag:')
  for candidate in a:candidates
    " TODO 毎回ファイルI/Oさせてるので非効率
    call s:tag(candidate.word, tag)
  endfor
endfunction

" TODO defineのほうが呼ばれない
call unite#define_kind(s:kind)
echo 'ok'
unlet s:kind

let &cpo = s:save_cpo
unlet s:save_cpo

nnoremap <Space><Space> :<C-u>Unite todo<CR>
