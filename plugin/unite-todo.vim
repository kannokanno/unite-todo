" FILE: unite-todo.vim
" AUTHOR: kanno <akapanna@gmail.com>
" Last Change: 2012 Mar 26
" License: This file is placed in the public domain.
if exists('g:loaded_unite_todo') && g:loaded_unite_todo
    finish
endif
let g:loaded_unite_todo = 1

let s:save_cpo = &cpo
set cpo&vim
 
command! -nargs=0 UniteTodoAddSimple call unite#todo#add([input('Todo:')])
command! -nargs=0 -range UniteTodoAddRange call unite#todo#add(reverse(getbufline('%', <line1>, <line2>)))
command! -nargs=0 UniteTodoAddBuffer call unite#todo#add(reverse(getbufline('%', 1, '$')))

let &cpo = s:save_cpo
unlet s:save_cpo
