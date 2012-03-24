let s:save_cpo = &cpo
set cpo&vim

"if exists("g:loaded_vimticket")
"  finish
"endif
"let g:loaded_vimticket = 1

command! -nargs=0 VimTicket :call vimticket#add#simple()
nnoremap <Space><Space> :<C-u>Unite ticket<CR>
nnoremap <Space>t :<C-u>VimTicket<CR>

let s:source = {
      \ 'name':'ticket',
      \}

function! s:source.gather_candidates(args, context)
  let lines = readfile(expand('~/.vimticket/tickets.txt'))
  " TODO idをファイル名に
  return map(lines, '{
        \   "word": v:val,
        \   "source": "lines",
        \   "kind": "vimticket",
        \   "action__path": expand("~/.vimticket/notes/".v:val.".txt"),
        \ }')
endfunction
call unite#define_source(s:source)
unlet s:source

let s:kind = {
      \ 'name' : 'vimticket',
      \ 'default_action' : 'toggle',
      \ 'action_table': {},
      \ 'is_selectable': 1,
      \ 'parents': ['jump_list'],
      \}

let s:kind.action_table.delete = {
      \ 'description' : 'delete ticket',
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
    let file = expand('~/.vimticket/tickets.txt')
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
    let file = expand('~/.vimticket/tickets.txt')
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
