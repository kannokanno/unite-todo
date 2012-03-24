let s:save_cpo = &cpo
set cpo&vim

"call unite#sources#todo#init()
"
"function! unite#sources#todo#define()
"  return s:source
"endfunction
"let s:source = {
"      \ 'name':'todo',
"      \}
"
"function! s:source.gather_candidates(args, context)
"  " TODO idをファイル名に
"  " TODO action__pathのとり方
"  return map(unite#sources#todo#list(), '{
"        \   "word": v:val,
"        \   "source": "lines",
"        \   "kind": "todo",
"        \   "action__path": g:unite_data_directory . "/todo/note/" . v:val . ".txt",
"        \ }')
"endfunction
"let &cpo = s:save_cpo
"
"" TODO defineのほうが呼ばれない
"call unite#define_source(s:source)
"nnoremap <Space><Space> :<C-u>Unite todo<CR>
"
"" =====================================================
"" TODO 複数のファイルで共通的に使いたいので、どこか別のファイルに置きたい
"let s:save_cpo = &cpo
"set cpo&vim
"let s:todo_file = g:unite_data_directory . '/todo/todo.txt'
"let s:note_dir = g:unite_data_directory . '/todo/note'
"
"function! unite#sources#todo#init()
"  if !isdirectory(s:note_dir)
"    call mkdir(s:note_dir, 'p')
"  endif
"  if empty(glob(s:todo_file))
"    call writefile([], s:todo_file)
"  endif
"endfunction
"
"function! unite#sources#todo#class()
"  let todo = {}
"  let todo.file = s:todo_file
"
"  function! todo.list()
"    let list = []
"    for line in readfile(self.file)
"      call add(list, line)
"    endfor
"    return list
"  endfunction
"
"  function! todo.note()
"    
"  endfunction
"
"  function! update(list)
"    call writefile(a:list, self.file)
"  endfunction
"
"  function! todo.append(name)
"    call self.update(add(self.list(), "[ ] " . a:name))
"  endfunction
"
"  function! delete(name)
"    let note = self.note()
"    if filewritable(note) && !isdirectory(note)
"      call delete(note)
"    endif
"    echo filter(copy(self.list()), 'v:val != '.self.name)
"    "call self.update(filter(copy(self.list()), 'v:val != '.self.name))
"  endfunction
"
"  return todo
"endfunction
"
"" TODO 消せる
"function! unite#sources#todo#update(name)
"  call unite#sources#todo#class().append(a:name)
"endfunction
"
"function! unite#sources#todo#delete(name)
"  call unite#sources#todo#class().delete(a:name)
"endfunction
"
"function! unite#sources#todo#toggle(todo)
"  let list = []
"  for line in unite#sources#todo#list()
"    if line == a:todo.title 
"      if line =~ '^\[X\]'
"        let line = substitute(line, '\[X\]<.*>', '[ ]', "")
"      else
"        let line = substitute(line, '\[ \]', "[X]<".strftime("%Y/%m/%d %H:%M").">", "")
"      endif
"    endif
"    call add(list, line)
"  endfor
"  call writefile(list, s:todo_file)
"endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
