" VimTabs.vim - A vim plugin for writing guitar tablature
" Author: Andrew Kingery
" Version: 0.3

if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

let s:tuning = ['e', 'B', 'G', 'D', 'A', 'E']

function! s:InitTab(length)
    call setline(1, ['[]', ''])
    call tabs#DrawStrings(2, a:length)
    call append('$', '')
    call cursor(1, 2)
    startinsert
endfunction

" Appends a staff of length hyphens per string after line lnum.
function! tabs#DrawStrings(lnum, length)
    let l:line = '|' . repeat('-', a:length) . '|'
    call append(a:lnum, map(copy(s:tuning), 'v:val . l:line'))
endfunction

" On a staff, the new one goes below its paragraph, keeping lyrics with their
" staff; elsewhere below the cursor line. It gets at least two blank lines on
" each side, the buffer edges counting as blank.
function! s:NewStaff(length)
    let l:after = line('.')
    if s:OnStringLine()
        let l:blank = search('^\s*$', 'nW')
        let l:after = l:blank ? l:blank - 1 : line('$')
    endif
    let l:above = s:CountBlank(l:after, -1)
    let l:below = s:CountBlank(l:after + 1, 1)
    call append(l:after, repeat([''], 2 - l:below))
    call tabs#DrawStrings(l:after, a:length)
    call append(l:after, repeat([''], 2 - l:above))
    call cursor(l:after + 2 - l:above + 1, 3)
    startgreplace
endfunction

" Counts up to two blank lines from lnum on, in direction step. getline()
" returns '' past the buffer edges, so they count as blank.
function! s:CountBlank(lnum, step)
    let l:n = 0
    while l:n < 2 && getline(a:lnum + l:n * a:step) =~# '^\s*$'
        let l:n += 1
    endwhile
    return l:n
endfunction

function! tabs#DrawBars()
    let l:pos = getcurpos()
    call s:ToFirstLine()
    silent execute "normal! \<C-v>5jr|"
    call s:ClearNames(col('.'), col('.'))
    call setpos('.', l:pos)
endfunction

" Extends the strings of the current staff that are shorter than width with '-'.
" search() keeps the cursor, so it's safe in Insert mode.
function! s:PadStaff(width)
    let l:top = search('\C^' . s:tuning[0] . '|', 'bcnW')
    if l:top == 0
        return
    endif
    for l:lnum in range(l:top, l:top + len(s:tuning) - 1)
        let l:line = getline(l:lnum)
        if strlen(l:line) < a:width
            call setline(l:lnum, l:line . repeat('-', a:width - strlen(l:line)))
        endif
    endfor
endfunction

" Motion to the next bar, or to the end of an unclosed staff.
function! s:BarOrEOL()
    return stridx(getline('.'), '|', col('.')) >= 0 ? 'f|' : '$'
endfunction

function! s:OnStringLine()
    return s:IsString(getline('.'))
endfunction

" Columns 1 and 2 hold the string name and the opening bar.
function! s:OnNameOrBar()
    return col('.') < 3
endfunction

function! s:IsString(line)
    return a:line =~# '^[a-gA-G]|'
endfunction

" Insert mode keys for moving one string down (step 1) or up (-1). They do
" nothing at the staff edges, where typing would overwrite lyrics or chord names.
function! s:StringStep(key, step)
    if !s:OnStringLine()
        return a:key
    endif
    return s:IsString(getline(line('.') + a:step)) ? "\<C-\>\<C-o>" . (a:step > 0 ? 'j' : 'k') : ''
endfunction

function! s:OnFirstLine()
    return getline('.')[0:1] ==# s:tuning[0] . '|'
endfunction

" Opfunc for d: clears the notes the motion covers. Only string lines change,
" never their first two columns, and bars stay: a motion edits notes, not
" measures. Leaves the cursor at the first cleared character.
function! s:HyphenDelete(type)
    let l:first = line("'[")
    let l:last = line("']")
    let l:start = []
    for l:lnum in range(l:first, l:last)
        if !s:IsString(getline(l:lnum))
            continue
        endif
        " Linewise: the whole string. Characterwise: the motion may start and
        " end in the middle of the first and last line.
        let l:from = l:lnum == l:first && a:type ==# 'char' ? col("'[") : 3
        let l:to = l:lnum == l:last && a:type ==# 'char' ? col("']") : strlen(getline(l:lnum))
        let l:from = max([l:from, 3])
        if s:ClearNotes(l:lnum, l:from, l:to) && empty(l:start)
            let l:start = [l:lnum, l:from]
        endif
    endfor
    if !empty(l:start)
        call cursor(l:start)
    endif
endfunction

" Replaces everything but bars in columns from to to of line lnum with '-'.
" Returns whether there was anything to clear.
function! s:ClearNotes(lnum, from, to)
    if a:from > a:to
        return 0
    endif
    let l:line = getline(a:lnum)
    let l:notes = substitute(l:line[a:from - 1 : a:to - 1], '[^|]', '-', 'g')
    call setline(a:lnum, l:line[: a:from - 2] . l:notes . l:line[a:to :])
    return 1
endfunction

function! s:HyphenChange(type)
    call s:HyphenDelete(a:type)
    startgreplace
endfunction

" Pads the staff first, so the e string reaches the column and block commands
" from there cover all strings.
function! s:ToFirstLine()
    let l:col = col('.')
    call s:PadStaff(l:col)
    if s:OnFirstLine()
        return
    endif
    call search('\C^' . s:tuning[0] . '|', 'bW')
    call cursor(line('.'), l:col)
endfunction

function! s:Chord(Letter)
    if !s:OnStringLine()
        return
    endif
    let l:pos = getcurpos()
    call s:ToFirstLine()
    let l:col = col('.')
    " Restore the user's value even if a :normal! below fails.
    let l:ve = &l:virtualedit
    setlocal virtualedit=all
    try
        silent execute 'normal! kR' . a:Letter . "\<Esc>j" . l:col . '|'
    finally
        let &l:virtualedit = l:ve
    endtry
    for l:fret in g:Chords[a:Letter]
        silent execute 'normal! "_s' . l:fret . "\<Esc>j"
    endfor
    call setpos('.', l:pos)
endfunction

function! s:YankStaff(register)
    let l:pos = getcurpos()
    call s:ToFirstLine()
    silent execute "normal! \<C-v>5j\"" . a:register . 'y'
    call setpos('.', l:pos)
endfunction

function! s:ClearColumns(count)
    if s:OnNameOrBar()
        return
    endif
    let l:pos = getcurpos()
    call s:ToFirstLine()
    let l:col = col('.')
    let l:count = min([a:count, col('$') - l:col])
    silent execute "normal! \<C-v>5j" . repeat('l', l:count - 1) . 'r-'
    call s:ClearNames(l:col, l:col + l:count - 1)
    call cursor(l:pos[1], l:pos[2] + a:count)
endfunction

" Blanks the chord names that start in columns first to last; s:Chord() puts a
" name above the staff, starting at its chord's column.
function! s:ClearNames(first, last)
    let l:pos = getcurpos()
    call s:ToFirstLine()
    let l:names = line('.') - 1
    for l:c in range(a:first, a:last)
        if l:names > 0 && getline(l:names)[l:c - 1] =~# '\S' && getline(l:names)[l:c - 2] !~# '\S'
            call cursor(l:names, l:c)
            silent execute "normal! viWr\<Space>"
            call setline(l:names, substitute(getline(l:names), '\s\+$', '', ''))
        endif
    endfor
    call setpos('.', l:pos)
endfunction

" Only a block over all six strings removes whole chords.
function! s:ClearVisualNames()
    if visualmode() !=# "\<C-v>" || !s:OnFirstLine() || line("'>") - line("'<") < 5
        return
    endif
    call s:ClearNames(min([col("'<"), col("'>")]), max([col("'<"), col("'>")]))
endfunction

" Mapping for String Lines

" Set local leader unless the user has his own localleader
let s:set_leader = !exists('g:maplocalleader')
if s:set_leader
    let maplocalleader = '-'
endif
" chord completion
for s:c in keys(g:Chords)
    execute 'nnoremap <buffer> <silent> <localleader>' . s:c . ' :<C-u>call <SID>Chord(' . string(s:c) . ')<CR>'
endfor

" Mapping to draw bars with -| in normal mode and | in insert/replace mode
nnoremap <buffer> <silent> <expr> <localleader><Bar> <SID>OnStringLine() ? ':<C-u>call tabs#DrawBars()<CR>' : ''
inoremap <buffer> <silent> <expr> <Bar> <SID>OnStringLine() ? '<C-\><C-o>:<C-u>call tabs#DrawBars()<CR><Right>' : '<Bar>'

" [count]-<CR> adds a staff, count hyphens wide
nnoremap <buffer> <silent> <localleader><CR> :<C-u>call <SID>NewStaff(v:count ? v:count : 60)<CR>

" selections
nnoremap <buffer> <silent> <expr> <S-v> <SID>OnStringLine() ? ':<C-u>call <SID>ToFirstLine()<CR><C-v>5j' : '<S-v>'
nnoremap <buffer> <silent> <expr> yy <SID>OnStringLine() ? ':<C-u>call <SID>YankStaff(' . string(v:register) . ')<CR>' : 'yy'

" movement
inoremap <buffer> <silent> <expr> <CR> <SID>StringStep('<CR>', 1)
inoremap <buffer> <silent> <expr> <Tab> <SID>StringStep('<Tab>', 1)
inoremap <buffer> <silent> <expr> <S-Tab> <SID>StringStep('<S-Tab>', -1)

" map insert mode to Replace mode if cursor on a string line
nnoremap <buffer> <silent> <expr> i !<SID>OnStringLine() ? 'i' : <SID>OnNameOrBar() ? ':<C-u>call cursor(0, 3)<CR>gR' : 'gR'
nnoremap <buffer> <expr> a <SID>OnStringLine() ? 'a<C-\><C-o>gR' : 'a'
nnoremap <buffer> <silent> <expr> I !<SID>OnStringLine() ? 'I' : <SID>OnNameOrBar() ? ':<C-u>call cursor(0, 3)<CR>gR' : 'T<Bar>gR'
nnoremap <buffer> <expr> A <SID>OnStringLine() ? <SID>BarOrEOL() . 'a<C-\><C-o>gR' : 'A'
inoremap <buffer> <expr> <Space> <SID>OnStringLine() ? '-' : '<Space>'

" replace deleted things with hyphens
" <C-u> drops the count from the command line, so pass it on to g@.
nnoremap <buffer> <silent> <expr> d <SID>OnStringLine() ? ':<C-u>set opfunc=<SID>HyphenDelete<CR>' . v:count1 . 'g@' : 'd'
nnoremap <buffer> <silent> <expr> dd <SID>OnStringLine() ? ':<C-u>set opfunc=<SID>HyphenDelete<CR>' . v:count1 . 'g@_' : 'dd'
vnoremap <buffer> <silent> <expr> d <SID>OnStringLine() ? 'r-:<C-u>call <SID>ClearVisualNames()<CR>' : 'd'
nnoremap <buffer> <silent> <expr> c <SID>OnStringLine() ? ':<C-u>set opfunc=<SID>HyphenChange<CR>' . v:count1 . 'g@' : 'c'
nnoremap <buffer> <silent> <expr> cc <SID>OnStringLine() ? ':<C-u>set opfunc=<SID>HyphenChange<CR>' . v:count1 . 'g@_' : 'cc'
vnoremap <buffer> <silent> <expr> c <SID>OnStringLine() ? 'r-:<C-u>call <SID>ClearVisualNames()<CR>gR' : 'c'
nnoremap <buffer> <silent> <expr> C <SID>OnStringLine() ? ':<C-u>set opfunc=<SID>HyphenChange<CR>' . v:count1 . 'g@$' : 'C'
nnoremap <buffer> <expr> x !<SID>OnStringLine() ? 'x' : <SID>OnNameOrBar() ? '' : 'r-'
nnoremap <buffer> <expr> s !<SID>OnStringLine() ? 's' : <SID>OnNameOrBar() ? '' : 'r-gR'
nnoremap <buffer> <silent> <expr> X <SID>OnStringLine() ? ':<C-u>call <SID>ClearColumns(' . v:count1 . ')<CR>' : 'X'

" Typing past the end of one string extends the whole staff.
augroup tabs_pad
    autocmd! * <buffer>
    autocmd TextChangedI,InsertLeave <buffer> if s:OnStringLine() | call s:PadStaff(strlen(getline('.'))) | endif
augroup END

" Undo for `set ft=`. :autocmd would swallow a following '|', hence :execute.
let b:undo_ftplugin = 'silent! execute "autocmd! tabs_pad * <buffer>"'
" Without maplist() (Vim before 8.2.4825) the mappings outlive `set ft=`.
if exists('*maplist')
    let s:sid = matchstr(expand('<SID>'), '\d\+')
    for s:map in maplist()
        if s:map.buffer && s:map.sid == s:sid
            " No spaces before '|': unmap treats trailing whitespace as part of the lhs.
            let b:undo_ftplugin .= '|silent! ' . s:map.mode . 'unmap <buffer> ' . substitute(s:map.lhs, '|', '<Bar>', 'g')
        endif
    endfor
endif

if s:set_leader
    unlet maplocalleader
endif

if !filereadable(expand('%')) && line('$') == 1 && getline(1) ==# ''
    call s:InitTab(60)
endif
