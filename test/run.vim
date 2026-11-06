" Test runner: vim -Nu NONE -i NONE -es -S test/run.vim
" Runs every Test_* function from test/test_*.vim, writes test/out.log and
" exits non-zero on failure. XFail_* functions document known bugs: they must
" fail, and pass only when the bug is fixed (then rename them to Test_*).
" Set g:test_filter to a pattern to run only matching tests. Call Skip() in a
" test that can't run on this Vim.

let s:root = expand('<sfile>:p:h:h')
let s:log = s:root . '/test/out.log'

" Older Vims don't strip the indent in `=<< trim` heredocs.
if !has('patch-8.1.1585')
    call writefile(['the tests need Vim 8.1.1585 or newer; try test/smoke.vim'], s:log)
    cquit
endif

execute 'set rtp^=' . fnameescape(s:root)
filetype plugin on

" Options that tests or the plugin may change; restored after each test.
let s:options = ['virtualedit', 'ignorecase', 'smartcase']

let g:even =<< trim END
    []
       Am  C7  G
    e|-0-1-2-3|4-5-6-7-|
    B|-0-1-2-3|4-5-6-7-|
    G|-0-1-2-3|4-5-6-7-|
    D|-0-1-2-3|4-5-6-7-|
    A|-0-1-2-3|4-5-6-7-|
    E|-0-1-2-3|4-5-6-7-|
    lyrics
END

let g:uneven =<< trim END
    []

    e|--0--|--1
    B|--0--|--3--|
    G|--0--|--2--|
    D|--2--|--0--|
    A|--2--|-----|
    E|--0--|-----|
    lyrics
END

let g:blank =<< trim END
    []

    e|---------|
    B|---------|
    G|---------|
    D|---------|
    A|---------|
    E|---------|
END

" Reads the lines to the "current buffer"
function! Given(lines, lnum, col)
    call setline(1, a:lines)
    setfiletype tab
    call cursor(a:lnum, a:col)
endfunction

function! Keys(keys)
    call feedkeys(a:keys, 'tix')
endfunction

function! Skip(reason)
    throw 'skip: ' . a:reason
endfunction

" Fails with a unified diff: '-' is expected, '+' is the actual buffer.
function! ExpectBuffer(want)
    let l:have = getline(1, '$')
    if l:have !=# a:want
        call assert_report("buffer differs:\n" . s:Diff(a:want, l:have))
    endif
endfunction

" diff() needs Vim 9.1.0071; older Vims use the diff command.
function! s:Diff(want, have)
    if exists('*diff')
        return diff(a:want, a:have, {'context': 99})
    endif
    let l:want_file = tempname()
    let l:have_file = tempname()
    call writefile(a:want, l:want_file)
    call writefile(a:have, l:have_file)
    " Drop the '---' and '+++' header lines, which diff() doesn't print either.
    let l:diff = split(system('diff -U99 ' . shellescape(l:want_file) . ' ' . shellescape(l:have_file)), "\n")[2:]
    call delete(l:want_file)
    call delete(l:have_file)
    return join(l:diff, "\n")
endfunction

function! ExpectCursor(line, col)
    call assert_equal([a:line, a:col], [line('.'), col('.')], 'cursor')
endfunction

let s:out = []
let s:failed = 0
let s:skipped = 0
let s:saved = {}
for s:opt in s:options
    let s:saved[s:opt] = eval('&' . s:opt)
endfor

for s:file in sort(glob(s:root . '/test/test_*.vim', 1, 1))
    try
        execute 'source' fnameescape(s:file)
    catch
        call add(s:out, 'ERROR sourcing ' . fnamemodify(s:file, ':t') . ': ' . v:exception)
        let s:failed += 1
    endtry
endfor

" `:function /pattern` lists matching functions, one 'function Name(...)' per line.
let s:tests = []
for s:line in split(execute('function /^\(Test\|XFail\)_'), "\n")
    let s:name = matchstr(s:line, '\<\(Test\|XFail\)_\w\+')
    if s:name =~# get(g:, 'test_filter', '')
        call add(s:tests, s:name)
    endif
endfor

for s:test in sort(s:tests)
    let v:errors = []
    let s:skip = ''
    try
        call call(s:test, [])
    catch /^skip: /
        let s:skip = v:exception[6:]
    catch
        call add(v:errors, v:throwpoint . ': ' . v:exception)
    endtry
    stopinsert
    for [s:opt, s:val] in items(s:saved)
        execute 'let &' . s:opt . ' = s:val'
    endfor
    silent! %bwipeout!

    let s:xfail = s:test =~# '^XFail_'
    if !empty(s:skip)
        let s:status = 'skip'
    elseif s:xfail
        let s:status = empty(v:errors) ? 'XPASS' : 'xfail'
    else
        let s:status = empty(v:errors) ? 'ok' : 'FAIL'
    endif
    call add(s:out, printf('%-5s %s', s:status, s:test) . (empty(s:skip) ? '' : ': ' . s:skip))
    if s:status ==# 'FAIL'
        for s:error in v:errors
            " Drop Vim's location prefix, e.g. '...function Test_x[14]..ExpectBuffer line 6: '.
            let s:error = substitute(s:error, '^.\{-}line \d\+: ', '', '')
            for s:line in split(s:error, "\n")
                call add(s:out, '    ' . s:line)
            endfor
        endfor
    elseif s:status ==# 'XPASS'
        call add(s:out, '    fixed? rename it to Test_' . substitute(s:test[6:], 'must_', '', '') . ' (and fix the verb)')
    endif
    let s:failed += index(['FAIL', 'XPASS'], s:status) >= 0
    let s:skipped += s:status ==# 'skip'
endfor

call add(s:out, printf('%d tests, %d failed, %d skipped', len(s:tests), s:failed, s:skipped))
call writefile(s:out, s:log)
execute s:failed ? 'cquit' : 'qall!'
