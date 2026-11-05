" VimTabs.vim - A vim plugin for writing guitar tablature
" Author: Andrew Kingery
" Version: 0.2

if exists("g:loaded_VimTabs")
    finish
endif
let g:loaded_VimTabs = 1

let s:tuning=['e', 'B', 'G', 'D', 'A', 'E']

function! s:InitTab(length)
    silent execute "normal! i[]\<CR>\<CR>"
    call tabs#DrawStrings(a:length)
    " reset position
    silent execute "normal! ggl"
    startinsert
endfunction

function! tabs#DrawStrings(length)
    for @s in s:tuning
        silent execute "normal! i\<C-R>s|\<C-o>". a:length. "a-\<esc>a|\<esc>o"
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
    silent execute "normal! `[v`]r-"
endfunction

function! s:HyphenChange(type)
    silent execute "normal! `[v`]r-"
    startgreplace
endfunction

function! s:ToFirstLine()
    noh
    if s:OnFirstLine()
        return
    endif
    silent execute "normal! ?". s:tuning[0]. "?s+". (col(".")-1). "\<CR>"
endfunction

function! s:Chord(Letter)
    normal mm
    call s:ToFirstLine()
    set ve=all
    silent execute "normal! kR". a:Letter. "\<esc>j"
    set ve=
    for @r in g:Chords[a:Letter]
        silent execute "normal! s\<C-R>r\<esc>j"
    endfor
    normal `m
endfunction

" Mapping for String Lines

" chord completion
let maplocalleader = "-"
for c in keys(g:Chords)
    silent execute "nnoremap <localleader>". c." :call <SID>Chord(\"". c. "\")<CR>"
endfor

" Mapping to draw bars with -| in normal mode and | in insert/replace mode
nnoremap <silent> <expr> <localleader>\| <SID>OnStringLine() ? ':call tabs#DrawBars()<CR>':''
inoremap <silent> <expr> \| <SID>OnStringLine() ? '<esc>l:call tabs#DrawBars()<CR>lgR':'\|'

" selections
nnoremap <expr> <S-v> <SID>OnStringLine() ? ':call <SID>ToFirstLine()<CR><C-v>5j':'<S-v>'
nmap <expr> yy <SID>OnStringLine() ? 'mm<S-v>y`m':'yy'

" movement
inoremap <expr> <Tab> <SID>OnStringLine() ? '<esc>jlgR':'<Tab>'
inoremap <expr> <S-Tab> <SID>OnStringLine() ? '<esc>klgR':'<Tab>'

" map insert mode to Replace mode if cursor on a string line
nnoremap <expr> i <SID>OnStringChar() ? 'gR':'i'
nnoremap <expr> a <SID>OnStringLine() ? 'lgR':'a'
nnoremap <expr> I <SID>OnStringLine() ? 'T\|gR':'I'
inoremap <expr> <space> <SID>OnStringLine() ? '-':'<space>'

" replace deleted things with hyphens
nnoremap <silent> <expr> d <SID>OnStringLine() ? ':set opfunc=<SID>HyphenDelete<CR>g@':'d'
vnoremap <expr> d <SID>OnStringLine() ? 'r-':'d'
nnoremap <silent> <expr> c <SID>OnStringLine() ? ':set opfunc=<SID>HyphenChange<CR>g@':'c'
vnoremap <expr> c <SID>OnStringLine() ? 'r-gR':'d'
nnoremap <expr> C <SID>OnStringLine() ? 'v$r-gR':'C'
nnoremap <expr> x <SID>OnStringLine() ? 'r-':'x'
nnoremap <expr> s <SID>OnStringLine() ? 'r-gR':'s'

if !filereadable(expand('%'))
    call s:InitTab(60)
endif
