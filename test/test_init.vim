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
    call Given(g:even, 6, 4)
    set filetype=
    call assert_match('No mapping found', execute('map <buffer>'))
    call assert_match('No mapping found', execute('map! <buffer>'))
    call assert_false(exists('#tabs_pad#TextChangedI#<buffer>'))
endfunction
