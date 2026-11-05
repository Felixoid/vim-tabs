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
    if !l:jump_back
        silent execute "normal! \<C-o>"
    endif
endfunction

function! s:OnStringLine()
    return getline(line('.')) =~ "^[a-gA-G]\|.*-*.*"
endfunction

function! s:OnStringChar()
    return s:OnStringLine() && getline('.')[col('.')-1] == "-"
endfunction

function! s:OnFirstLine()
    return getline('.')[0:1] == s:tuning[0]."|"
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
    silent execute "normal! ?^". s:tuning[0]. "|?s+". (col(".")-1). "\<CR>"
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
nnoremap <buffer> <silent> <expr> d <SID>OnStringLine() ? ':set opfunc=<SID>HyphenDelete<CR>g@':'d'
nnoremap <buffer> <silent> <expr> c <SID>OnStringLine() ? ':set opfunc=<SID>HyphenChange<CR>g@':'c'
vnoremap <buffer> <expr> d <SID>OnStringLine() ? 'r-' : 'd'
vnoremap <buffer> <expr> c <SID>OnStringLine() ? 'r-gR' : 'c'
nnoremap <buffer> <expr> C <SID>OnStringLine() ? 'v$r-gR' : 'C'
nnoremap <buffer> <expr> x <SID>OnStringLine() ? 'r-' : 'x'
nnoremap <buffer> <expr> s <SID>OnStringLine() ? 'r-gR' : 's'

" plugin undo for `set ft=`
let s:lead = substitute(maplocalleader, ' ', '<Space>', 'g')
let s:undo = map(keys(g:Chords) + ['<Bar>'], '"nunmap <buffer> " . s:lead . v:val')
let s:undo += map(['<S-v>', 'yy', 'i', 'a', 'I', 'A', 'd', 'c', 'C', 'x', 's'], '"nunmap <buffer> " . v:val')
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
