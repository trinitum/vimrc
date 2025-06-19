execute pathogen#infect()
if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2
  syntax on
  set hlsearch
endif

" Fix the number of colors for terminal
if &term =~ '256color'
  colorscheme desert
  set cursorline
  if has('termguicolors') && $TERM_PROGRAM !~ "Apple_Terminal"
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
  endif
  hi CursorLine guibg=#2c1c1c ctermbg=234 cterm=none
  hi SignColumn guibg=#c2bfa5 ctermbg=144
endif

set viewoptions=cursor,folds
set nocompatible
set nomodeline
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

set signcolumn=yes
set statusline=%F%m%r%h%w\ [%{&ff}]\ %y\ [CHR=%b/0x%B]\ [POS=%04l,%03c(%03v)]\ [%p%%]\ [LEN=%L]
set laststatus=2

set autowrite

let perl_fold=1
let perl_nofold_packages=1
let perl_fold_anonymous_subs=1
let perl_include_pod=0

let c_no_comment_fold=1
let g:omni_sql_no_default_maps=1

let g:go_version_warning = 0
let g:go_fmt_command = "goimports"
let g:go_gocode_propose_source=0
let g:go_def_mapping_enabled=0
let g:go_code_completion_enabled=0
let g:go_template_use_pkg=1

let g:rust_bang_comment_leader=1
let g:rust_fold=1
let g:rustfmt_autosave=1

let g:netrw_liststyle=3
let g:netrw_winsize=25

let g:ctrlp_open_new_file = 'r'

nmap <Leader>vs :aboveleft Git<CR>
nmap <Leader>vb :Git blame<CR>
nmap <Leader>vc :Git commit<CR>
nmap <Leader>vw :Gwrite<CR>
nmap <Leader>va :Git commit --amend<CR>
nmap <Leader>vp :Git! --paginate diff<CR>:wincmd P<CR><C-W>_
nmap <Leader>vd :Gdiff<CR>
nmap <Leader>vg :Git! --paginate log --pretty=format:'\%h \%an \%ad \%s' --date=short --graph<CR>:wincmd P<CR><C-W>_

nmap <Leader>fb :Buffers<CR>
nmap <Leader>fc :Commits<CR>
nmap <Leader>ff :Files<CR>
nmap <expr> <Leader>fg ':Rg '.expand('<cword>').'<CR>'
nmap <Leader>fh :History<CR>

map <Leader>si :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
            \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

" Don't use Ex mode, use Q for formatting
map Q gq

" Auto add matching }
imap {<CR> {<CR>}<ESC>O

" disable search highlight
nmap <C-H> :nohlsearch<CR>
" resync syntax highlight
nmap <C-K> :syn sync fromstart<CR>
imap <C-K> <ESC>:syn sync fromstart<CR>i
map <C-O> :set paste!<CR>

let g:lsp_diagnostics_echo_cursor=1
let g:lsp_diagnostics_virtual_text_enabled=0
let g:lsp_preview_keep_focus=0
let g:lsp_text_edit_enabled=0

if executable('rust-analyzer')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'Rust Language Server',
        \ 'cmd': {server_info->['rust-analyzer']},
        \ 'allowlist': ['rust'],
        \ })
endif

if executable('gopls')
    let g:go_autocomplete_enabled=0
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
        \ 'allowlist': ['go'],
        \ })
endif

if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '--query-driver=/opt/homebrew/bin/arm-none-eabi-gcc']},
        \ 'allowlist': ['c', 'cpp'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> <C-]> <plug>(lsp-definition)
    nmap <buffer> [d <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]d <plug>(lsp-next-diagnostic)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> <Leader>lr <plug>(lsp-rename)
    nmap <buffer> <silent> <Leader>ls :LspStopServer<CR>
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> gp <plug>(lsp-preview-focus)
    nmap <buffer> gc <plug>(lsp-preview-close)

    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-b> lsp#scroll(-4)
endfunction

if has("autocmd")
    augroup lsp_install
        au!
        " call s:on_lsp_buffer_enabled only for languages that has the server registered.
        autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    augroup END
endif


set completeopt=menuone,noinsert,noselect
let g:asyncomplete_auto_completeopt=0

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
  au FileType c,cpp imap <buffer> <Tab> <C-R>=CleverTab()<CR>
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
   au FileType go nmap <buffer> <silent> <LocalLeader>gb <Plug>(go-build)
   au FileType go nmap <buffer> <silent> <LocalLeader>gy <Plug>(go-test-compile)
   au FileType go nmap <buffer> <silent> <LocalLeader>gt <Plug>(go-test)
   au FileType go nmap <buffer> <silent> <LocalLeader>gd <Plug>(go-doc)
   au FileType go nmap <buffer> <silent> <LocalLeader>gf :GoFillStruct<CR>
   au FileType go nmap <buffer> <silent> <LocalLeader>ge :GoIfErr<CR>
   au FileType go nmap <buffer> <silent> <LocalLeader>gj :GoAddTags<CR>
   au FileType go nnoremap <buffer> <silent> <LocalLeader>gr :GoRun %<CR>
   au FileType go inoremap <buffer> <C-G> <ESC>:GoImport<Space>
   au BufWritePost *.go silent! GoInstall
 augroup END

 augroup rust
   au!
   au FileType rust inoremap <buffer> <Tab> <C-R>=CleverTab()<CR>
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

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
