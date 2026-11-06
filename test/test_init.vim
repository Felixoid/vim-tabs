function! Test_empty_buffer_gets_a_staff()
    setfiletype tab
    let l:want =<< trim END
        []

        e|------------------------------------------------------------|
        B|------------------------------------------------------------|
        G|------------------------------------------------------------|
        D|------------------------------------------------------------|
        A|------------------------------------------------------------|
        E|------------------------------------------------------------|

    END
    call ExpectBuffer(l:want)
    call ExpectCursor(1, 2)
endfunction

function! Test_undo_ftplugin_removes_mappings_and_autocmds()
    if !exists('*maplist')
        call Skip('no maplist()')
    endif
    call Given(g:even, 6, 4)
    set filetype=
    call assert_match('No mapping found', execute('map <buffer>'))
    call assert_match('No mapping found', execute('map! <buffer>'))
    call assert_false(exists('#tabs_pad#TextChangedI#<buffer>'))
endfunction

function! Test_undo_ftplugin_with_space_localleader()
    if !exists('*maplist')
        call Skip('no maplist()')
    endif
    let g:maplocalleader = ' '
    try
        call Given(g:even, 6, 4)
        call assert_notequal('', maparg('<Space>Am', 'n'))
        set filetype=
    finally
        unlet g:maplocalleader
    endtry
    call assert_match('No mapping found', execute('map <buffer>'))
endfunction

function! Test_undo_ftplugin_keeps_other_mappings()
    call Given(g:even, 6, 4)
    nnoremap <buffer> Q :echo 'mine'<CR>
    set filetype=
    call assert_notequal('', maparg('Q', 'n'))
endfunction
