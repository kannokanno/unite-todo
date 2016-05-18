let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#todo#define()
  return s:kind
endfunction

let s:kind = {
      \ 'name' : 'todo',
      \ 'default_action' : 'toggle',
      \ 'action_table': {},
      \ 'is_selectable': 1,
      \ 'parents': ['common', 'openable'],
      \}

let s:kind.action_table.open = { 'description' : 'open note of todo', 'is_selectable': 1 }
function! s:kind.action_table.open.func(candidates)
  for candidate in a:candidates
    call unite#todo#open(unite#todo#struct(candidate.source__line))
  endfor
endfunction

let s:kind.action_table.preview = { 'description' : 'preview note' }
function! s:kind.action_table.preview.func(candidate)
  let todo = unite#todo#struct(a:candidate.source__line)
  if filereadable(todo.note)
    execute ':pedit ' . todo.note
  endif
endfunction

" TODO edit_titleと同じ処理。移譲する設定があるはず
let s:kind.action_table.edit = { 'description' : 'edit todo title' }
function! s:kind.action_table.edit.func(candidate)
  let todo = unite#todo#struct(a:candidate.source__line)
  let after = unite#todo#trim(input('Todo:' . todo.title . '->', todo.title))
  if !empty(after)
    let todo.title = after
    call unite#todo#rename(todo)
  endif
endfunction

let s:kind.action_table.edit_title = { 'description' : 'edit todo title' }
function! s:kind.action_table.edit_title.func(candidate)
  let todo = unite#todo#struct(a:candidate.source__line)
  let after = unite#todo#trim(input('Todo:' . todo.title . '->', todo.title))
  if !empty(after)
    let todo.title = after
    call unite#todo#rename(todo)
  endif
endfunction

let s:kind.action_table.add_tag = { 'description' : 'add todo tag', 'is_selectable': 1 }
function! s:kind.action_table.add_tag.func(candidates)
  let tags = unite#todo#trim(input('Tags(comma separate):'))
  if !empty(tags)
    " TODO 毎回ファイルI/Oさせてるので非効率
    for candidate in a:candidates
      let todo = unite#todo#struct(candidate.source__line)
      call extend(todo.tags, map(split(tags, ','), '"@".v:val'))
      call unite#todo#rename(todo)
    endfor
  endif
endfunction

let s:kind.action_table.edit_tag = { 'description' : 'edit todo tag' }
function! s:kind.action_table.edit_tag.func(candidate)
  let todo = unite#todo#struct(a:candidate.source__line)
  let before = join(map(todo.tags, 'substitute(v:val, "^@", "", "")'), ',')
  let after = unite#todo#trim(input('Tags(comma separate):' . before . '->', before))
  if !empty(after)
    let todo.tags = map(split(after, ','), '"@".v:val')
    call unite#todo#rename(todo)
  endif
endfunction

let s:kind.action_table.delete = { 'description' : 'delete todo', 'is_selectable': 1 }
function! s:kind.action_table.delete.func(candidates)
  if input('delete ok? [y/N]') =~? '^y\%[es]$'
    for candidate in a:candidates
      " TODO 毎回ファイルI/Oさせてるので非効率
      call unite#todo#delete(unite#todo#struct(candidate.source__line))
    endfor
  endif
endfunction

let s:kind.action_table.toggle = { 'description' : 'toggle done/undone', 'is_selectable': 1 }
function! s:kind.action_table.toggle.func(candidates)
  for candidate in a:candidates
    " TODO 毎回ファイルI/Oさせてるので非効率
    call unite#todo#toggle(unite#todo#struct(candidate.source__line))
  endfor
endfunction

let s:parent_kind = {
      \ 'is_quit': 0,
      \ 'is_invalidate_cache': 1,
      \ }
" TODO 回せないかな
call extend(s:kind.action_table.edit_title, s:parent_kind, 'error')
call extend(s:kind.action_table.add_tag, s:parent_kind, 'error')
call extend(s:kind.action_table.edit_tag, s:parent_kind, 'error')
call extend(s:kind.action_table.delete, s:parent_kind, 'error')
call extend(s:kind.action_table.toggle, s:parent_kind, 'error')
call extend(s:kind.action_table.preview, s:parent_kind, 'error')

let &cpo = s:save_cpo
unlet s:save_cpo
