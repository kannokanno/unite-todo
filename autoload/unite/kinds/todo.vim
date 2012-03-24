let s:save_cpo = &cpo
set cpo&vim

"function! unite#kinds#todo#define()
"  return s:kind
"endfunction
"
"" TODO defineのほうが呼ばれない
"call unite#define_kind(s:kind)
"
"let s:kind = {
"      \ 'name' : 'todo',
"      \ 'default_action' : 'toggle',
"      \ 'action_table': {},
"      \ 'is_selectable': 1,
"      \ 'parents': ['jump_list'],
"      \}
"
"let s:kind.action_table.add = {
"      \ 'description' : 'add todo',
"      \ 'is_quit': 0,
"      \ 'is_invalidate_cache': 1,
"      \ }
"function! s:kind.action_table.add.func(candidate)
"  call unite#sources#todo#update(input('Input Todo:'))
"endfunction
"
"let s:kind.action_table.delete = {
"      \ 'description' : 'delete todo',
"      \ 'is_selectable': 1,
"      \ 'is_quit': 0,
"      \ 'is_invalidate_cache': 1,
"      \ }
"function! s:kind.action_table.delete.func(candidates)
"  for candidate in a:candidates
"    " TODO 毎回ファイルI/Oさせてるので非効率
"    call unite#sources#todo#delete(candidate.word)
"  endfor
"endfunction
"
"let s:kind.action_table.toggle = {
"      \ 'description' : 'toggle done/undone',
"      \ 'is_selectable': 1,
"      \ 'is_quit': 0,
"      \ 'is_invalidate_cache': 1,
"      \ }
"function! s:kind.action_table.toggle.func(candidates)
"  for candidate in a:candidates
"    " TODO 毎回ファイルI/Oさせてるので非効率
"    call unite#sources#todo#toggle({'title': candidate.word})
"  endfor
"endfunction
"
let &cpo = s:save_cpo
unlet s:save_cpo
