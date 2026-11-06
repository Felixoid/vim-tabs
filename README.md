Vim-tabs: A Vim Plugin for Writing Guitar Tablature
==================================================

Vim-tabs is a plugin for Vim that makes writing guitar tablature easier.

Installation
------------

You can install vim-tabs using [vim-plug](https://github.com/junegunn/vim-plug) by adding `Plug 'kanderoo/vim-tabs'` to your vimrc and running `:PlugInstall`. Installation using Pathogen or Vundle might be possible, but I don't use those so I'm not sure.

The plugin needs Vim 8.0 or newer. Once installed, `:help tabs` opens this documentation inside Vim.

Getting Started
---------------

The plugin activates on files with the `.tab` extension. When you open a new (not yet saved) `.tab` file, it creates a blank tab for you: a `[]` title placeholder on the first line and six string lines in standard tuning, 60 columns wide:

```
[]

e|------------------------------------------------------------|
B|------------------------------------------------------------|
G|------------------------------------------------------------|
D|------------------------------------------------------------|
A|------------------------------------------------------------|
E|------------------------------------------------------------|
```

The cursor lands inside the brackets so you can type the song title right away.

A string line is any line that starts with a note name and a bar, like `e|` or `A|`. The six string lines in a row form a staff. All the mappings below work only on string lines; on any other line, such as the title, chord names or lyrics, Vim behaves as usual.

The mappings use the local leader. If you haven't set `g:maplocalleader`, the plugin uses `-` for its own mappings, and this documentation writes them that way.

Staffs
------

Type `-<CR>` in normal mode to add a new staff. On a staff, it goes below the paragraph the staff belongs to, so lyrics stay with their staff; on any other line, it goes below the cursor line. The new staff gets at least two blank lines above and below, and the cursor lands on its first string in Replace mode.

The new staff has 60 hyphens per string. A count sets another length: `30-<CR>` adds a staff with 30 hyphens per string.

When you type past the end of a string, the plugin extends every string of the staff with hyphens, so the staff stays even.

Editing Behavior
----------------

On string lines the usual editing commands are remapped so the tab keeps its shape. Text never shifts: characters are replaced, and deletions leave hyphens behind. Typing, `x`, `s`, `X` and the `d` and `c` operators leave the first two columns alone, so the string name and the opening bar stay.

### Typing notes

- `i`, `a`: start Replace mode at or after the cursor, instead of Insert mode.
- `I`: start Replace mode at the beginning of the current measure, right after the previous bar.
- `A`: start Replace mode right after the next bar, or at the end of the string when no bar follows.
- `<Space>` in Insert mode: type `-`.
- `<CR>` or `<Tab>` in Insert mode: move to the next string, in the same column. On the last string they do nothing.
- `<S-Tab>` in Insert mode: move to the previous string. On the first string it does nothing.

### Deleting and changing

- `x`: replace the character with `-`.
- `s`: replace the character with `-` and start Replace mode there.
- `X`: clear the column under the cursor on all six strings, together with the chord name that starts in it, and move to the next column. A count clears that many columns.
- `d{motion}`: replace the notes the motion covers with hyphens. Bars stay, and only string lines change, so `d}` clears the staff but keeps the lyrics. `dd` clears the whole string; `3dd` clears three strings.
- `c{motion}`, `cc`: the same as `d`, then start Replace mode at the first cleared character.
- `C`: the same as `c$`: clear the notes from the cursor to the end of the string, keeping the bars, then start Replace mode. A count reaches into the strings below, like `2C`.
- `d`, `c` in Visual mode: replace the selection with hyphens, bars included. A blockwise selection over all six strings also removes the chord names that start in it.

### Selecting and yanking

- `V`: select the column under the cursor on all six strings, as a block. Move left or right to widen it, then use `d`, `c`, `y` or any other operator.
- `yy`: yank the column under the cursor on all six strings, as a block. A register works as usual: `"ayy`.

Bar Lines
---------

Type `|` in Insert mode, or `-|` in normal mode, to draw a bar across all six strings at the cursor column. A chord name that starts in that column goes away. In Insert mode the cursor then moves past the bar, so you can keep typing.

Chords
------

Type `-` followed by a chord name in normal mode to write the chord onto the staff at the cursor column, with its name above. For example, `-Am` with the cursor in column 4 gives:

```
   Am
e|-0---
B|-1---
G|-2---
D|-2---
A|-0---
E|-----
```

Built in chords:

- major: `A B C D E F G`
- minor: `Am Bm Cm Dm Em Fm Gm`
- seventh: `A7 B7 C7 D7 E7 F7 G7`
- minor seventh: `Am7 Bm7 Cm7 Dm7 Em7 Fm7 Gm7`

When one chord name starts another, like `A`, `Am` and `Am7`, Vim waits for 'timeoutlen' after `-A` or `-Am` to see whether you type more.

### The `g:Chords` option

Add your own chords by setting `g:Chords` in your vimrc. Each entry lists the frets from the high e string downward; strings you leave out stay unplayed:

```vim
let g:Chords = {
\    'Asus4': ['0', '3', '2', '2', '0'],
\    'C':     ['3', '1', '0', '2', '3'],
\}
```

Your chords are added to the built in ones and win when the names match, like `C` above. The plugin reads `g:Chords` each time it opens a `.tab` file, so your vimrc is the right place for it.

Highlighting
------------

Only string lines and the chord names right above a staff get tab highlighting, so lyrics and comments stay plain. Each part has its own syntax group, linked to a standard one:

- `tabName`, the string name before the first bar: `Identifier`.
- `tabBar`, the bars: `Delimiter`.
- `tabHyphen`, the hyphens: `Comment`.
- `tabFret`, the fret numbers: `Number`.
- `tabTechnique`, slides `/` and `\`, hammer ons `h`, pull offs `p`, bends `b`, releases `r`, taps `t` and vibrato `~`: `Operator`.
- `tabMute`, dead notes `x`: `Special`.
- `tabHarmonic`, harmonics like `<12>`: `Special`.
- `tabChord`, chord names like `Am`, `C7`, `Emaj7`, `F#m7b5` or `C/G` on a line right above a staff: `SpecialComment`.
- `tabHeader`, the `[title]` line: `Title`.

To change a color, link the group to another one or give it your own colors in your vimrc, after the `:colorscheme` line:

```vim
highlight link tabHyphen NonText
highlight tabFret ctermfg=yellow guifg=#e5c07b
```

Turning the Plugin Off
----------------------

`:set filetype=` in a tab buffer removes the plugin's mappings and autocommands. Before Vim 8.2.4825 the mappings stay until you close the buffer.

How to Write Tab
---------------------

Tablature in plain text isn't completely standardized, but some norms are present. If you're looking at how to write tab I highly suggest reading through both the [wikipedia page on ASCII tab](https://en.wikipedia.org/wiki/ASCII_tab) and the [Guide To Tab Notation](https://www.classtab.org/tabbing.htm) by Howard Wright. The latter especially is a very good resource for a variety of tab styles.

Development
-----------

`make test` runs the tests in plain Vim, with no other dependencies. `make test T=pattern` runs only the tests whose names match the pattern. The tests need Vim 8.1.1585 or newer; `make smoke` runs a smaller smoke test that works on older Vims too.

`make test-vims` runs the tests in several Vim versions in Docker, using the [thinca/vim](https://hub.docker.com/r/thinca/vim) images, and a smaller smoke test in Vims too old for the tests. `VIMS` and `SMOKE_VIMS` override the versions, for example `make test-vims VIMS=v9.1.0000 SMOKE_VIMS=`.

`make doc` regenerates `doc/tabs.txt` from `README.md`. It runs [html2vimdoc](https://github.com/ycm-core/vim-tools) in Docker and builds its image on the first run.
