" General {{{
filetype on
filetype plugin on
packloadall

" HACK: not sure why lua plugins aren't loaded automatically,
"       I'll have to look into this.
" source /usr/share/nvim/runtime/plugin/man.lua

set nu rnu
set splitright splitbelow
set modeline
set nofoldenable
set ignorecase
set smartcase
set autoindent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set nowrap
set cursorline
set scrolloff=4
set listchars=tab:→\ ,eol:↲
set nrformats=bin,hex,alpha
set diffopt="vertical"

set termguicolors
set background=dark
colorscheme decoldest
" }}} 

" Variables {{{
let man_hardwrap = 1
let ft_man_open_mode = 'vert'

let netrw_banner = 0
let netrw_liststyle = 3
let netrw_browse_split = 0

let M_E  = 2.718281828459045
let M_PI = 3.141592653589793
" }}}

" Functions {{{
function! Mod(a, b)
  let tmp = a:a % a:b
  return tmp < 0 ? a:b + tmp : tmp
endfunction

function! Rad(degrees)
  return a:degrees * g:M_PI / 180.0
endfunction

function! Deg(radians)
  return a:radians * 180.0 / g:M_PI
endfunction

function! Log2(param)
  return log(a:param) / log(2)
endfunction

function! KiB(n) 
  return       a:n  * 1024 
endfunction

function! MiB(n) 
  return g:KiB(a:n) * 1024 
endfunction

function! GiB(n) 
  return g:MiB(a:n) * 1024 
endfunction

function! TiB(n) 
  return g:GiB(a:n) * 1024 
endfunction

function! SyntaxStack()
  if !exists("*synstack") | return | endif
  echo map(synstack(line("."), col(".")), "synIDattr(v:val, 'name')")
endfunction

function! PairOf(symbol)
  if !exists("SymbolPairTable")
    " forward table
    let g:SymbolPairTable = {
    \ '(': ['(', ')'],
    \ '[': ['[', ']'],
    \ '{': ['{', '}'],
    \ '<': ['<', '>'],
    \ }
    " make it backward
    for [k, v] in items(g:SymbolPairTable)
      let g:SymbolPairTable[v[1]] = v
    endfor
  endif
  if exists(printf("g:SymbolPairTable['%s']", a:symbol))
    return g:SymbolPairTable[a:symbol]
  endif
  return [a:symbol, a:symbol]
endfunction

function! SelectionOf(mode)
  let [rs, re] = a:mode == "char" ? ["'[", "']"] : ["'<", "'>"]
  let [sl, sc] = getcharpos(rs)[1:2]
  let [el, ec] = getcharpos(re)[1:2]
  return [ sl, sc, el, ec ]
endfunction

" tiny version of surround.vim
function! OpSurround(mode)
  echo printf("%d %d", v:count, v:count1)
  let x = getcharstr()
  if x == "\<esc>" || x == "\<c-c>"
    return
  endif
  let [x, y] = PairOf(x)
  let [ sl, sc, el, ec ] = SelectionOf(a:mode)
  if a:mode == "line" || a:mode == "V"
    call append(el, y)
    call append(sl-1, x)
  elseif a:mode == "block" || a:mode == "\<c-v>"
    silent execute sl..','..el..'s/$\|\%>'..ec..'c/\=y/ | norm! ``'
    silent execute sl..','..el..'s/$\|\%'..sc..'c/\=x/ | norm! ``'
  else
    silent execute el..'s/$\|\%>'..ec..'c/\=y/ | norm! ``'
    silent execute sl..'s/$\|\%'..sc..'c/\=x/ | norm! ``'
  endif
endfunction

" inverse of OpSurround
function! OpTrim(mode)
  let x = getcharstr()
  if x =~ "\<esc>" || x =~ "\<c-c>"
    return
  endif
  let [ x, y ] = PairOf(x)
  let [ sl, se, el, ec] = SelectionOf(a:mode)
  if a:mode == "block" || a:mode == "\<c-v>"
    silent! execute sl..','..el..'s/\('..x..'\)\(.*\%.c[^\('..y..'\)]*\)\('..y..'\)/\2/ | norm! ``'
  else
  endif
endfunction

" }}} Functions

" Commands {{{
command! -nargs=1 VimCalc let answer = eval(<q-args>) |
                        \ let result = printf("%g", answer) |
                        \ call setreg("", result) |
                        \ echo result 
" }}} Commands

" Bindings {{{
let mapleader=' '
let maplocalleader='\'

" disable keys that get in the way
noremap <up>      <nop>
noremap <left>    <nop>
noremap <down>    <nop>
noremap <right>   <nop>
nnoremap H        <nop>
nnoremap M        <nop>
nnoremap L        <nop>
" write mechanics
nnoremap <leader>W :wa<cr>
nnoremap <leader>Q :wa<cr>:qa<cr>
nnoremap <leader>s :update<cr>
" line up/down
nnoremap - :move -2<cr>
nnoremap _ :move +1<cr>
" quick edit common files
nnoremap <leader>ev :vs $MYVIMRC<cr>
nnoremap <leader>ea :vs $XDG_CONFIG_HOME/alacritty/alacritty.yml<cr>
nnoremap <leader>ep :vs $XDG_CONFIG_HOME/zsh/.zprofile<cr>
nnoremap <leader>ez :vs $XDG_CONFIG_HOME/zsh/.zshrc<cr>
" text manipulation
nnoremap <leader>P m`viw<esc>g`<~g``
nnoremap <leader>U m`viwU<esc>g``
nnoremap <leader>u m`viwu<esc>g``
vnoremap <leader>== :'<,'>!column -t -s = -o =<cr>
nnoremap s :set opfunc=OpSurround<cr>g@
vnoremap s :<c-u>call OpSurround(visualmode())<cr>
nnoremap t :set opfunc=OpTrim<cr>g@
vnoremap t :<c-u>call OpTrim(visualmode())<cr>
" buffer movement 
nnoremap <leader>[ :bp<cr>
nnoremap <leader>] :bn<cr>
nnoremap <leader>. :cnext<cr>
nnoremap <leader>, :cprev<cr>
" tab movement
for n in range(1, 9)
  execute printf("nnoremap <a-%d> :norm %dgt<cr>", n, n)
endfor
nnoremap <leader>t :tab split<cr>
nnoremap <leader><leader> :norm gt<cr>
" window movement
nnoremap <a-h> :wincmd h<cr>
nnoremap <a-j> :wincmd j<cr>
nnoremap <a-k> :wincmd k<cr>
nnoremap <a-l> :wincmd l<cr>
nnoremap <a-H> :wincmd H<cr>
nnoremap <a-J> :wincmd J<cr>
nnoremap <a-K> :wincmd K<cr>
nnoremap <a-L> :wincmd L<cr>
nnoremap <a-s-o> :resize -4<cr>
nnoremap <a-o> :vert resize -8<cr>
nnoremap <a-s-p> :resize +4<cr>
nnoremap <a-p> :vert resize +8<cr>
" terminal movement
tnoremap <a-h> <c-\><c-n><c-w>h
tnoremap <a-j> <c-\><c-n><c-w>j
tnoremap <a-k> <c-\><c-n><c-w>k
tnoremap <a-l> <c-\><c-n><c-w>l
tnoremap <a-x> <c-\><c-n>
nnoremap <leader>T :vs<cr>:term<cr>i
" make ctags display confirm dialogue by default
nnoremap <c-]> g<c-]>
nnoremap g<c-]> <c-]>
" show syntax info under cursor
nnoremap <leader>`s :call SyntaxStack()<cr>
" toggle highlighting
nnoremap <leader>H :set hls!<cr>
" source init.vim
nnoremap <leader>R :source $HOME/.config/nvim/init.vim<cr>:edit<cr>
" enter calculator command.
nnoremap <leader>c :VimCalc<Space>
" }}}

" Autocmd (Setup) {{{
augroup Setup | autocmd!

function! s:SetupReadme()
  set cc=80
endfunction
autocmd BufRead,BufNewFile README* call s:SetupReadme()

function! s:SetupPlanfile()
  nnoremap <buffer> <leader>r /REMIND<cr>:set nohls<cr>j
  nnoremap <buffer> <leader>m :read !date +"\%Y-\%m-\%d (\%A, \%B \%d, \%Y)"<cr>
                             \<ESC>o<ESC>72i=<ESC>0
endfunction
autocmd BufRead,BufNewFile planfile call s:SetupPlanfile()

function! s:SetupTex()
  set tabstop=2
  set softtabstop=2
  set shiftwidth=2
  set expandtab
  set linebreak
  set spell
  set wrap
  " swap modes for moving vertically along a wrapped line lines.
  nnoremap <buffer> k gk
  nnoremap <buffer> j gj
  nnoremap <buffer> 0 g0
  nnoremap <buffer> $ g$
  nnoremap <buffer> gk k
  nnoremap <buffer> gj j
  nnoremap <buffer> g0 0
  nnoremap <buffer> g$ $
  " build commands are different for plaintex and latex
  if &filetype == "plaintex"
    nnoremap <buffer> <leader>m :w<cr>:!pdftex "%"<cr>
  else
    nnoremap <buffer> <leader>m :w<cr>:!pdflatex "%"<cr>
  endif
endfunction
autocmd FileType *tex call s:SetupTex()

function! s:SetupAsm()
  set nowrap
endfunction
autocmd FileType asm call s:SetupAsm()

function! s:SetupC(filename)
  set cc=80
  set cino=(0,l1,:0
  set tabstop=4
  set softtabstop=4
  set shiftwidth=4
  set expandtab
  set nowrap
  let &path = &path .. ".,"
  let &path = &path .. "/usr/include/,"
  let &path = &path .. "/usr/local/include,"
  let &path = &path .. "/usr/include/opencv4,"
  let &path = &path .. "/usr/include/cairo,"
  let &path = &path .. "/usr/include/lzo,"
  let &path = &path .. "/usr/include/libpng16,"
  let &path = &path .. "/usr/include/freetype2,"
  let &path = &path .. "/usr/include/harfbuzz,"
  let &path = &path .. "/usr/include/glib-2.0,"
  let &path = &path .. "/usr/include/sysprof-4,"
  let &path = &path .. "/usr/include/pixman-1,"
  let &path = &path .. "/usr/lib/glib-2.0/include,"
  let c_no_bracket_error = 1
  let c_no_curly_error = 1
  " stupid hack to make no_*_error above work in .c sources
  set filetype=cpp
  set syntax=c
  " expand brace block
  inoremap <buffer> {} {<enter>}<esc>O

  if a:filename =~ '.*\.h1'
    " this is our custom h1 language, we just don't want the mappings
    " for c/cpp in the else block because they are useless.
  else
    " quickly run make
    nnoremap <buffer> <leader>m :make<cr><Enter>:cnext<cr>:cprev<cr>
    " 'lookup' word under cursor using vimgrep in all .c, .h files.
    nnoremap <buffer> <leader>k viwy:execute("vimgrep /"..getreg("\"").."/ **/*.h **/*.c")<cr>
  endif
endfunction
autocmd FileType c,cpp call s:SetupC(expand("%"))
autocmd BufRead,BufNewFile *h1 call s:SetupC(expand("%"))

function! s:SetupPython()
  iabbrev <buffer> ubp #!/usr/bin/python
endfunction
autocmd FileType python call s:SetupPython()

function! s:SetupTerminal()
  setlocal nospell
endfunction
autocmd TermOpen * call s:SetupTerminal() 

augroup end
" }}}

" vi: sw=2 ts=2 sts=2 et fdm=marker nospell
