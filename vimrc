execute pathogen#infect()
if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

set viewoptions=cursor,folds
set nocompatible
set backspace=indent,eol,start
set ai			" always set autoindenting on
set nobackup		" do not keep a backup file, use versions instead
set viminfo='20,\"50	" read/write a .viminfo file, don't store more
			" than 50 lines of registers
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set hid
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set scrolloff=5
set vb

set softtabstop=4
set shiftwidth=4
set tw=0
set expandtab

set statusline=%F%m%r%h%w\ [%{&ff}]\ %y\ [CHR=%b/0x%B]\ [POS=%04l,%03c(%03v)]\ [%p%%]\ [LEN=%L]
set laststatus=2

set autowrite

let perl_fold=1
let perl_nofold_packages=1
let perl_fold_anonymous_subs=1
let perl_include_pod=0
let c_no_comment_fold=1
let g:omni_sql_no_default_maps=1
let g:go_fmt_command = "goimports"
let g:go_gocode_propose_source=0
let g:go_def_mapping_enabled=0

let g:rust_bang_comment_leader=1
let g:rust_fold=1
let g:rustfmt_autosave=1

let g:netrw_liststyle=3
let g:netrw_winsize=25

let g:ctrlp_open_new_file = 'r'

let g:neomake_go_enabled_makers = ['go', 'govet']
let g:neomake_rust_enabled_makers = ['cargo', 'clippy']

nmap <Leader>nm :Neomake<CR>
nmap <Leader>nc :NeomakeClean<CR>

nmap <Leader>vs :aboveleft Gstatus<CR>
nmap <Leader>vb :Gblame<CR>
nmap <Leader>vc :Gcommit<CR>
nmap <Leader>vw :Gwrite<CR>
nmap <Leader>va :Gcommit --amend<CR>
nmap <Leader>vp :Gpedit! diff<CR>:wincmd P<CR><C-W>_
nmap <Leader>vd :Gdiff<CR>
nmap <Leader>vg :Gpedit! log --pretty=format:'\%h \%an \%ad \%s' --date=short --graph<CR>:wincmd P<CR><C-W>_

map <Leader>si :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
" Don't use Ex mode, use Q for formatting
map Q gq

map <A-DOWN> gj
map <A-UP> gk
imap <A-DOWN> <ESC>gji
imap <A-UP> <ESC>gki

" Auto add matching }
imap {<CR> {<CR>}<ESC>O

" disable search highlight
nmap <C-H> :nohlsearch<CR>
" resync syntax highlight
nmap <C-K> :syn sync fromstart<CR>
imap <C-K> <ESC>:syn sync fromstart<CR>i
map <C-O> :set paste!<CR>

if executable('rls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'rls',
        \ 'cmd': {server_info->['rustup', 'run', 'stable', 'rls']},
        \ 'whitelist': ['rust'],
        \ })
endif

if executable('gopls')
    let g:go_autocomplete_enabled=0
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'whitelist': ['go'],
        \ })
endif

" autocompletion with tab
if has("insert_expand")
    function! CleverTab()
        if strpart( getline('.'), 0, col('.')-1 ) =~ '\(^\s*\|\s\)$'
            return "\<Tab>"
        else
            return "\<C-N>"
        endif
    endfunction

    function! CleverTabOmni()
        if strpart( getline('.'), 0, col('.')-1 ) =~ '\(^\s*\|\s\)$'
            return "\<Tab>"
        else
            return "\<C-X>\<C-O>"
        endif
    endfunction
endif

function ChlogDate()
    call append(line('.') - 1, strftime("%a %b %e %Y "))
endfunction

if has("cscope") && filereadable("/usr/bin/cscope")
   set csprg=/usr/bin/cscope
   set csto=0
   set cst
   set nocsverb
   " add any database in current directory
   if filereadable("cscope.out")
      cs add cscope.out
   " else add database pointed to by environment
   elseif $CSCOPE_DB != ""
      cs add $CSCOPE_DB
   endif
   set csverb
endif

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" Fix number of colors for xterm
if &term =~ "xterm" || &term =~ "256color"
  set t_Co=256
  if has('gui')
    colorscheme desert
    set cursorline
  else
    colorscheme desert256
    set cursorline
    let g:CSApprox_loaded=1
    let g:CSApprox_verbose_level=0
  endif
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

filetype plugin indent on

" GnuPG clearsigning
com -range=% Sign <line1>,<line2>:!gpg --clearsign

" Only do this part when compiled with support for autocommands.
if has("autocmd")

 " In text files, always limit the width of text to 78 characters
 au BufRead *.txt setlocal tw=78

 augroup perl
  au!
  au BufWinLeave *.pl,*.pm mkview
  au BufWinEnter *.pl,*.pm silent loadview
  au FileType perl setlocal cindent
  au FileType perl setlocal foldlevel=0 foldmethod=syntax foldcolumn=2 foldnestmax=1
  au FileType perl inoremap <buffer> <Tab> <C-R>=CleverTab()<CR>
 augroup END

 augroup yaml
  au!
  au FileType yaml setlocal softtabstop=2 shiftwidth=2 expandtab
 augroup END

 augroup xml
  au!
  au FileType xml,html setlocal noautoindent
  au FileType xml,html setlocal indentexpr=
  au FileType xml,html setlocal softtabstop=2 shiftwidth=2 expandtab
 augroup END

 augroup cprog
  au!
  au FileType c,cpp setlocal cindent formatoptions=crql
  au FileType c,cpp setlocal foldmethod=syntax foldcolumn=2 foldnestmax=1
 augroup END

 augroup chlog
   au!
   au FileType changelog map <buffer> <Leader>o O<ESC>O<ESC>:call ChlogDate()<CR>i<TAB>- 
   au FileType changelog setlocal tw=72
 augroup END

 augroup text
   au!
   au FileType text setlocal tw=72
 augroup END

 augroup make
   au!
   au FileType make setlocal softtabstop=8 shiftwidth=8 noexpandtab
 augroup END

 augroup go
   au!
   au FileType go setlocal tabstop=4 softtabstop=0 shiftwidth=0 noexpandtab
   au FileType go imap <buffer> <Tab> <C-R>=CleverTab()<CR>
   au FileType go setlocal foldmethod=indent foldnestmax=1 foldlevel=1
   au FileType go nnoremap <buffer> <silent> <C-]> :LspDefinition<CR>
   au FileType go nmap <buffer> <silent> <LocalLeader>gb <Plug>(go-build)
   au FileType go nmap <buffer> <silent> <LocalLeader>gy <Plug>(go-test-compile)
   au FileType go nmap <buffer> <silent> <LocalLeader>gl <Plug>(go-lint)
   au FileType go nmap <buffer> <silent> <LocalLeader>gt <Plug>(go-test)
   au FileType go nmap <buffer> <silent> <LocalLeader>gd <Plug>(go-doc)
   au FileType go nmap <buffer> <silent> <LocalLeader>gv <Plug>(go-vet)
   au FileType go nnoremap <buffer> <silent> <LocalLeader>gr :GoRun %<CR>
   au FileType go inoremap <buffer> <C-G> <ESC>:GoImport<Space>
   au BufWritePost *.go silent! GoInstall
 augroup END

 augroup rust
   au!
   au FileType rust inoremap <buffer> <Tab> <C-R>=CleverTab()<CR>
   au FileType rust nnoremap <buffer> <silent> <C-]> :LspDefinition<CR>
   au FileType rust nmap <buffer> <silent> <LocalLeader>cb :Cbuild<CR>
   au FileType rust nmap <buffer> <silent> <LocalLeader>cr :Crun<CR>
   au FileType rust nmap <buffer> <silent> <LocalLeader>ct :Ctest<CR>
   au FileType rust nmap <buffer> <silent> <LocalLeader>cu :Cupdate<CR>
 augroup END

 augroup gitcommit
     au!
     au FileType gitcommit nmap <buffer> <Leader>vp :Gpedit! diff --cached<CR>:wincmd P<CR><C-W>_
 augroup END

 augroup encrypted
    au!

    " First make sure nothing is written to ~/.viminfo while editing
    " an encrypted file.
    au BufReadPre,FileReadPre      *.gpg set viminfo=
    " We don't want a swap file, as it writes unencrypted data to disk
    au BufReadPre,FileReadPre      *.gpg set noswapfile
    " Switch to binary mode to read the encrypted file
    au BufReadPre,FileReadPre      *.gpg set bin
    au BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
    au BufReadPost,FileReadPost    *.gpg '[,']!gpg --decrypt 2> /dev/null
    " Switch to normal mode for editing
    au BufReadPost,FileReadPost    *.gpg set nobin
    au BufReadPost,FileReadPost    *.gpg let &ch = ch_save|unlet ch_save
    au BufReadPost,FileReadPost    *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

    " Convert all text to encrypted text before writing
    au BufWritePre,FileWritePre    *.gpg   '[,']!gpg --default-recipient-self -ae 2>/dev/null
    " Undo the encryption so we are back in the normal text, directly
    " after the file has been written.
    au BufWritePost,FileWritePost    *.gpg   u
 augroup END

endif " has("autocmd")

