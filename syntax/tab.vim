" Vim syntax file

if exists('b:current_syntax')
    finish
endif

syntax match tabHeader /^\[.*\]/

" Only string lines get tab highlighting, so lyrics and comments stay plain.
syntax match tabString /^[a-gA-G]|.*/ contains=tabHyphen,tabFret,tabTechnique,tabMute,tabHarmonic,tabBar,tabName
syntax match tabHyphen /-/ contained
syntax match tabFret /\d\+/ contained
syntax match tabTechnique "[hpbrt/\\~]" contained
syntax match tabMute /x/ contained
syntax match tabHarmonic /<\d\+>/ contained
syntax match tabBar /|/ contained
" Last, so it wins over tabTechnique for a 'b|' string.
syntax match tabName /^[a-gA-G]\ze|/ contained

" Very magic pieces for the patterns below. A chord is a root, then quality
" and extensions: Am, C7, Emaj7, Amin, CM7, F#m7b5, Dsus4, C/G.
let s:chord = '[A-G][#b]?(maj|min|dim|aug|sus|add|m|[0-9#b+/A-GM])*'
let s:string_below = '\ze\n[a-gA-G]\|'
execute 'syntax match tabChords ,\v^\s*(' . s:chord . '\s*)+' . s:string_below . ', contains=tabChord'
execute 'syntax match tabChord ,\v' . s:chord . ', contained'
unlet s:chord s:string_below

hi def link tabHeader Title
hi def link tabName Identifier
hi def link tabHyphen Comment
hi def link tabFret Number
hi def link tabTechnique Operator
hi def link tabMute Special
hi def link tabHarmonic Special
hi def link tabBar Delimiter
hi def link tabChord SpecialComment

let b:current_syntax = 'tab'
