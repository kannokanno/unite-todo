let s:save_cpo = &cpo
set cpo&vim

call unite#todo#init()

"command! -nargs=0 UniteTodoAddSimple call s:add([input('Todo:')])
"nnoremap <Space>a :<C-u>UniteTodoAddSimple<CR>
"command! -nargs=0 -range UniteTodoAddRange call s:add(reverse(getbufline('%', <line1>, <line2>)))
"command! -nargs=0 UniteTodoAddBuffer call s:add(reverse(getbufline('%', 1, '$')))
"nnoremap <Space><Space> :<C-u>Unite todo<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

