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
 
command! -nargs=* -range=0 UniteTodoAddSimple call unite#todo#input(<q-args>, <count>, <line1>, <line2>)
command! -nargs=* UniteTodoAddBuffer call unite#todo#input(<q-args>, -1, 1, '$')

let &cpo = s:save_cpo
unlet s:save_cpo
