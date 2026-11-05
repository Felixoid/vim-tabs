" VimTabs.vim - A vim plugin for writing guitar tablature
" Author: Andrew Kingery
" Version: 0.2

if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

let s:tuning = ['e', 'B', 'G', 'D', 'A', 'E']

function! s:InitTab(length)
    silent execute "normal! i[]\<CR>\<CR>"
    call tabs#DrawStrings(a:length)
    " reset position
    silent execute 'normal! ggl'
    startinsert
endfunction

function! tabs#DrawStrings(length)
    for l:string in s:tuning
        silent execute 'normal! i' . l:string . "|\<C-o>" . a:length . "a-\<Esc>a|\<Esc>o"
    endfor
endfunction

function! tabs#DrawBars()
    let l:jump_back = s:OnFirstLine()
    call s:ToFirstLine()
    silent execute "normal! \<C-v>5jr|"
    call s:ClearNames(col('.'), col('.'))
    if !l:jump_back
        silent execute "normal! \<C-o>"
    endif
endfunction

function! s:OnStringLine()
    return getline('.') =~# '^[a-gA-G]|'
endfunction

function! s:OnStringChar()
    return s:OnStringLine() && getline('.')[col('.') - 1] ==# '-'
endfunction

function! s:OnFirstLine()
    return getline('.')[0:1] ==# s:tuning[0] . '|'
endfunction

function! s:HyphenDelete(type)
    silent execute 'normal! `[v`]r-'
endfunction

function! s:HyphenChange(type)
    silent execute 'normal! `[v`]r-'
    startgreplace
endfunction

function! s:ToFirstLine()
    noh
    if s:OnFirstLine()
        return
    endif
    silent execute 'normal! ?\C^' . s:tuning[0] . '|?s+' . (col('.') - 1) . "\<CR>"
endfunction

function! s:Chord(Letter)
    let l:pos = getcurpos()
    call s:ToFirstLine()
    let l:col = col('.')
    set ve=all
    silent execute 'normal! kR' . a:Letter . "\<Esc>j" . l:col . '|'
    set ve=
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
    " Columns 1 and 2 hold the string name and the opening bar.
    if col('.') < 3
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
for c in keys(g:Chords)
    execute 'nnoremap <buffer> <silent> <localleader>' . c . ' :<C-u>call <SID>Chord(' . string(c) . ')<CR>'
endfor

" Mapping to draw bars with -| in normal mode and | in insert/replace mode
nnoremap <buffer> <silent> <expr> <localleader><Bar> <SID>OnStringLine() ? ':<C-u>call tabs#DrawBars()<CR>' : ''
inoremap <buffer> <silent> <expr> <Bar> <SID>OnStringLine() ? '<Esc>l:<C-u>call tabs#DrawBars()<CR>lgR' : '<Bar>'

" selections
nnoremap <buffer> <silent> <expr> <S-v> <SID>OnStringLine() ? ':<C-u>call <SID>ToFirstLine()<CR><C-v>5j' : '<S-v>'
nnoremap <buffer> <silent> <expr> yy <SID>OnStringLine() ? ':<C-u>call <SID>YankStaff(' . string(v:register) . ')<CR>' : 'yy'

" movement
inoremap <buffer> <expr> <Tab> <SID>OnStringLine() ? '<Esc>jlgR' : '<Tab>'
inoremap <buffer> <expr> <S-Tab> <SID>OnStringLine() ? '<Esc>klgR' : '<S-Tab>'

" map insert mode to Replace mode if cursor on a string line
nnoremap <buffer> <expr> i <SID>OnStringChar() ? 'gR' : 'i'
nnoremap <buffer> <expr> a <SID>OnStringLine() ? 'lgR' : 'a'
nnoremap <buffer> <expr> I <SID>OnStringLine() ? 'T<Bar>gR' : 'I'
nnoremap <buffer> <expr> A <SID>OnStringLine() ? 'f<Bar>lR' : 'A'
inoremap <buffer> <expr> <Space> <SID>OnStringLine() ? '-' : '<Space>'

" replace deleted things with hyphens
" <C-u> drops the count from the command line, so pass it on to g@.
nnoremap <buffer> <silent> <expr> d <SID>OnStringLine() ? ':<C-u>set opfunc=<SID>HyphenDelete<CR>' . v:count1 . 'g@' : 'd'
vnoremap <buffer> <silent> <expr> d <SID>OnStringLine() ? 'r-:<C-u>call <SID>ClearVisualNames()<CR>' : 'd'
nnoremap <buffer> <silent> <expr> c <SID>OnStringLine() ? ':<C-u>set opfunc=<SID>HyphenChange<CR>' . v:count1 . 'g@' : 'c'
vnoremap <buffer> <silent> <expr> c <SID>OnStringLine() ? 'r-:<C-u>call <SID>ClearVisualNames()<CR>gR' : 'c'
nnoremap <buffer> <expr> C <SID>OnStringLine() ? 'v$r-gR' : 'C'
nnoremap <buffer> <expr> x <SID>OnStringLine() ? 'r-' : 'x'
nnoremap <buffer> <expr> s <SID>OnStringLine() ? 'r-gR' : 's'
nnoremap <buffer> <silent> <expr> X <SID>OnStringLine() ? ':<C-u>call <SID>ClearColumns(' . v:count1 . ')<CR>' : 'X'

" plugin undo for `set ft=`
let s:lead = substitute(maplocalleader, ' ', '<Space>', 'g')
let s:undo = map(keys(g:Chords) + ['<Bar>'], '"nunmap <buffer> " . s:lead . v:val')
let s:undo += map(['<S-v>', 'yy', 'i', 'a', 'I', 'A', 'd', 'c', 'C', 'x', 'X', 's'], '"nunmap <buffer> " . v:val')
let s:undo += map(['<Bar>', '<Tab>', '<S-Tab>', '<Space>'], '"iunmap <buffer> " . v:val')
let s:undo += ['vunmap <buffer> d', 'vunmap <buffer> c']
" No spaces before '|': unmap treats trailing whitespace as part of the lhs.
let b:undo_ftplugin = 'silent! ' . join(s:undo, '|silent! ')

if s:set_leader
    unlet maplocalleader
endif

if !filereadable(expand('%')) && line('$') == 1 && getline(1) ==# ''
    call s:InitTab(60)
endif
