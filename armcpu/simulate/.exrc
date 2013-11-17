if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
inoremap <Nul> 
inoremap <expr> <Up> pumvisible() ? "\" : "\<Up>"
inoremap <expr> <S-Tab> pumvisible() ? "\" : "\<S-Tab>"
inoremap <expr> <Down> pumvisible() ? "\" : "\<Down>"
imap <silent> <Plug>IMAP_JumpBack =IMAP_Jumpfunc('b', 0)
imap <silent> <Plug>IMAP_JumpForward =IMAP_Jumpfunc('', 0)
vmap <NL> <Plug>IMAP_JumpForward
nmap <NL> <Plug>IMAP_JumpForward
map ,,f :python FixTable()
map ,,c :python CreateTable()
map L :call LookUpWord() 
vmap [% [%m'gv``
nnoremap \d :YcmShowDetailedDiagnostic
nmap \S :execute(":S " . input('Regex-off: /'))
nmap <silent> \P :call SessionPaste("P")
nmap <silent> \p :call SessionPaste("p")
vmap <silent> \Y Y:call SessionYank()
vmap <silent> \y y:call SessionYank()
nmap <silent> \y :call SessionYank()
omap <silent> \y :call SessionYank()
vmap ]% ]%m'gv``
vmap a% [%v]%
nmap gx <Plug>NetrwBrowseX
noremap <silent> j gj
noremap <silent> k gk
vnoremap p :let current_reg = @"gvs=current_reg
nnoremap z/ :if AutoHighlightToggle()|set hls|endif
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetrwBrowseX(expand("<cWORD>"),0)
vmap <silent> <Plug>IMAP_JumpBack `<i=IMAP_Jumpfunc('b', 0)
vmap <silent> <Plug>IMAP_JumpForward i=IMAP_Jumpfunc('', 0)
vmap <silent> <Plug>IMAP_DeleteAndJumpBack "_<Del>i=IMAP_Jumpfunc('b', 0)
vmap <silent> <Plug>IMAP_DeleteAndJumpForward "_<Del>i=IMAP_Jumpfunc('', 0)
nmap <silent> <Plug>IMAP_JumpBack i=IMAP_Jumpfunc('b', 0)
nmap <silent> <Plug>IMAP_JumpForward i=IMAP_Jumpfunc('', 0)
nnoremap <F9> :NERDTreeToggle
nnoremap <F5> :GundoToggle
inoremap  bi
inoremap  <Home>
inoremap  <End>
inoremap  lwi
inoremap  <Left>
inoremap <expr> 	 pumvisible() ? "\" : "\	"
inoremap <NL> <Down>
inoremap  <Up>
inoremap  <Right>
inoremap  O
imap  <Plug>IMAP_JumpForward
let &cpo=s:cpo_save
unlet s:cpo_save
set backspace=indent,eol,start
set balloonexpr=eclim#util#Balloon(eclim#util#GetLineError(line('.')))
set completefunc=youcompleteme#Complete
set completeopt=preview,menuone
set cpoptions=aAceFsB
set fileencodings=utf-8,gb2312,gbk,iso-8859,ucs-bom
set formatoptions=tcqmro
set helplang=en
set history=50
set hlsearch
set incsearch
set omnifunc=youcompleteme#OmniComplete
set ruler
set runtimepath=~/.vim,~/.vim/bundle/YouCompleteMe,~/.vim/bundle/gundo,~/.vim/bundle/nerdtree,~/.vim/bundle/syntastic,~/.vim/bundle/vim-coffee-script,~/.vim/bundle/vim-jade,~/.vim/bundle/vim-l9,/usr/share/vim/vimfiles,/usr/share/vim/vim74,/usr/share/vim/vimfiles/after,~/.vim/bundle/vim-coffee-script/after,~/.vim/after,/usr/share/vim/vimfiles/eclim,/usr/share/vim/vimfiles/eclim/after
set shiftwidth=4
set showcmd
set softtabstop=4
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set tabstop=4
set tags=./tags,tags;
set title
set undodir=/tmp
set undofile
set updatetime=2000
set wildmenu
" vim: set ft=vim :
