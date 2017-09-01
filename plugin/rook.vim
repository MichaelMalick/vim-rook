" rook.vim - Evaluate R code in a tmux pane or neovim terminal
" Author:   Michael Malick <malickmj@gmail.com>
" Version:  1.4


if exists('g:loaded_rook') || &cp || v:version < 700
  finish
endif
let g:loaded_rook = 1

if !exists('g:rook_attach_dict')
    let g:rook_attach_dict = { }
endif

if !exists('g:rook_tmp_file')
    let g:rook_tmp_file = substitute(tempname(), '\', '/', 'g')
endif

if !exists('g:rook_source_send')
    let g:rook_source_send = 1
endif

if !exists('g:rook_rstudio_folding')
    let g:rook_rstudio_folding = 0
endif

if !exists('g:rook_target_type')
    if has('nvim') || has('terminal')
        let g:rook_target_type = 'vim'
    else
        let g:rook_target_type = 'tmux'
    endif
endif

"" The single space at the end of the command lines is necessary!!
command! -nargs=1 -complete=custom,rook#completion_target Rattach 
    \:call rook#command_rattach(<q-args>)

command! -range -nargs=? Rwrite 
    \:call rook#command_rwrite(<line1>, <line2>, <q-args>)

command! -nargs=? -complete=custom,rook#completion_rfunctions Rhelp 
    \:call rook#command_rhelp(<q-args>)

command! -nargs=? -complete=custom,rook#completion_rfunctions Rview 
    \:call rook#command_rview(<q-args>)

xnoremap <silent> <Plug>RookSend     :<C-U>call rook#send(1)<CR>
nnoremap <silent> <Plug>RookSend     :<C-U>call rook#send(0)<CR>g@
nnoremap <silent> <Plug>RookSendLine :<C-U>call rook#send_line()<Bar>
    \ exe 'norm! '.g:rook_count1.'g@_'<CR>

xnoremap <silent> <Plug>RookRFunctionVisual
    \ :<C-U>call rook#text_object_rfunction()<CR>
onoremap <silent> <Plug>RookRFunctionPending
    \ :<C-U>call rook#text_object_rfunction()<CR>

xnoremap <silent> <Plug>RookRmdChunkVisualI
    \ :<C-U>call rook#text_object_rmdchunk(1)<CR>
onoremap <silent> <Plug>RookRmdChunkPendingI
    \ :<C-U>call rook#text_object_rmdchunk(1)<CR>
xnoremap <silent> <Plug>RookRmdChunkVisualA
    \ :<C-U>call rook#text_object_rmdchunk(0)<CR>
onoremap <silent> <Plug>RookRmdChunkPendingA
    \ :<C-U>call rook#text_object_rmdchunk(0)<CR>

augroup rook_plugin_master
    autocmd!
    autocmd VimLeave * call delete(g:rook_tmp_file)
    autocmd BufNewFile,BufRead * call rook#source_cmd()
    "" only set rstudio-folding for r filetypes
    autocmd FileType r call rook#fold_expr()
    "" on buffer entry set b:rook_target_id
    autocmd BufEnter,BufWinEnter *.r,*.R,*.rmd,*.Rmd,*.rnw,*.Rnw
        \ call rook#set_buffer_target_id()
augroup END

