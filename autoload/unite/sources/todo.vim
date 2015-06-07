let s:save_cpo = &cpo
set cpo&vim

call unite#todo#init()

let s:source = {
      \ 'name':'todo',
      \}
function! s:source.gather_candidates(args, context)
  let candidates = []
  let list = empty(a:args) ? unite#todo#all() : unite#todo#select(s:pattern(a:args))
  for todo in list
    call add(candidates, {
          \   "word": join(filter([todo.status, todo.title, join(todo.tags)], 'v:val !=# ""')),
          \   "kind": "todo",
          \   "action__path": todo.note,
          \   "source__line": todo.line,
          \ })
    unlet todo
  endfor
  return candidates
endfunction

function! s:pattern(args)
  let arg = a:args[0]
  if arg ==? 'done' 
    return 'v:val.status =~ "[X]"'
  elseif arg ==? 'undone' 
    return 'v:val.status !~ "[X]"'
  elseif arg ==? 'tag' 
    if len(a:args) < 2 || empty(a:args[1])
      return ''
    endif
    return 'index(v:val.tags, "@'.a:args[1].'") != -1'
  endif
  return ''
endfunction

function! unite#sources#todo#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
