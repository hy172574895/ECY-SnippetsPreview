" Author: Jimmy Huang (1902161621@qq.com)
" License: WTFPL

let g:snippets_preview_dir = expand( '<sfile>:p:h:h:h' )
let g:snippets_preview_dir = tr(g:snippets_preview_dir, '\', '/')
let g:snippets_preview_dir = g:snippets_preview_dir . '/preview_file/'

fun! s:Timer_cb1(timer_id) abort
  call feedkeys("\<F1>", 'i')
  echo 'Building, please wait.'
  call timer_start(500, function('s:Timer_cb2'))
endf

fun! s:Timer_cb2(timer_id) abort
  let l:content = getbufline(bufnr(),1, "$")
  if mode() != 'n' 
    call feedkeys("\<ESC>", 'i')
  endif
  
  if match(l:content, 'An error occured') != -1
    exe 'bd!'
  else
    let s:preview_content[s:snippets[s:snippets_len][0]] = {'preview': l:content}
  endif
  if s:preview_windows_nr != -1
    exe 'bd!' . string(s:preview_windows_nr)
  endif
  let s:preview_windows_nr = -1
  let s:snippets_len -= 1
  echo 'Building, please wait.'
  call timer_start(200, function('s:Timer_cb3'))
endf

fun! s:Timer_cb3(timer_id) abort
  if s:snippets_len < 0
    let l:file_path = g:snippets_preview_dir . s:filetype
    if filereadable(l:file_path)
      call delete(l:file_path)
    endif
    let l:json = json_encode(s:preview_content)
    call writefile([l:json], l:file_path, "a")
    echo "Building Done"
  else
    call s:PreviewExpanding(s:filetype, s:snippets[s:snippets_len][0])
  endif
endf

function! s:PreviewExpanding(filetype, input) abort
  if mode() == 'i'
    call feedkeys("\<ESC>", 'i')
  endif
  let s:postion_colum = col('.')
  let s:postion_line  = line('.')
  let g:abc = ''
  execute 'new'
  let s:preview_windows_nr = bufnr()
  let &filetype = a:filetype
  echo 'Building, please wait.'
  call feedkeys('i'. a:input, 'i')
  call timer_start(1000, function('s:Timer_cb1'))
endfunction

function! BuildSnippetsPreview() abort
  call UltiSnips#SnippetsInCurrentScope(1)

  let s:snippets = items(g:current_ulti_dict_info)
  exec "inoremap <silent> <F1> <C-R>=UltiSnips#ExpandSnippetOrJump()<cr>"
  let s:snippets_len = len(s:snippets) - 1
  let s:filetype =  &filetype
  let s:preview_content = {}
  let s:preview_windows_nr = -1
  call s:PreviewExpanding(s:filetype, s:snippets[s:snippets_len][0])
endfunction
