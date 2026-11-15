call pathogen#infect()

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
syntax on
set hlsearch

" Fix the number of colors for terminal
if &t_Co >= 256
  colorscheme desert
  set cursorline
  set termguicolors
  hi CursorLine guibg=#2c1c1c ctermbg=234 cterm=none
  hi SignColumn guibg=#c2bfa5 ctermbg=144
  hi Terminal guibg=#000000 ctermbg=0
endif

set nocompatible
set nomodeline
set backspace=indent,eol,start
set autoindent  " always set autoindenting on
set nobackup  " do not keep a backup file, use versions instead
set viminfo='20,"50'  " read/write a .viminfo file, max 20 marks, 50 lines of registers
set history=50
set ruler
set hidden
set showcmd
set incsearch
set scrolloff=5
set visualbell

set softtabstop=4
set shiftwidth=4
set textwidth=0
set expandtab

set signcolumn=yes
set statusline=%F%m%r%h%w\ [%{&ff}]\ %y\ [CHR=%b/0x%B]\ [POS=%04l,%03c(%03v)]\ [%p%%]\ [LEN=%L]
set laststatus=2

let perl_fold=1
let perl_nofold_packages=1
let perl_fold_anonymous_subs=1
let perl_include_pod=0

let c_no_comment_fold=1

let g:go_version_warning = 0
let g:go_fmt_command = "goimports"
let g:go_def_mapping_enabled=0
let g:go_code_completion_enabled=0
let g:go_template_use_pkg=1

let g:rust_bang_comment_leader=1
let g:rust_fold=1
let g:rustfmt_autosave=1

let g:netrw_liststyle=3
let g:netrw_winsize=25

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

" Auto add matching } with indentation
imap {<CR> {<CR>}<C-o>O<Tab>

" disable search highlight
nmap <Leader>h :nohlsearch<CR>


nmap <C-O> :set paste!<CR>

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

if executable('zls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'zls',
        \ 'cmd': {server_info->['zls']},
        \ 'allowlist': ['zig'],
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

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END


set completeopt=menuone,noinsert,noselect
let g:asyncomplete_auto_completeopt=0

" autocompletion with tab
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

function! s:DiffWithSaved()
  vert diffsplit
  edit #
  diffthis
endfunction
com! DiffSaved call s:DiffWithSaved()

filetype plugin indent on

" GnuPG clearsigning
com -range=% Sign <line1>,<line2>:!gpg --clearsign

augroup perl
  au!
  au FileType perl setlocal cindent
  au FileType perl setlocal foldlevel=0 foldmethod=syntax foldcolumn=2 foldnestmax=1
augroup END

augroup yaml
  au!
  au FileType yaml setlocal softtabstop=2 shiftwidth=2 expandtab
augroup END

augroup cprog
  au!
  au FileType c,cpp setlocal cindent formatoptions=crql
  au FileType c,cpp setlocal foldmethod=syntax foldcolumn=1 foldnestmax=1
  au FileType c,cpp imap <buffer> <Tab> <C-R>=CleverTab()<CR>
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

if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif
