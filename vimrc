if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
   set fileencodings=ucs-bom,utf-8,latin1
endif

set nocompatible
set backspace=indent,eol,start
set tw=72
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
set cursorline

set statusline=%F%m%r%h%w\ [%{&ff}]\ %y\ [CHR=%b/0x%B]\ [POS=%04l,%03c(%03v)]\ [%p%%]\ [LEN=%L]
set laststatus=2

let perl_fold=1
let perl_nofold_packages=1
let c_no_comment_fold=1
" let perl_include_pod=1
let g:omni_sql_no_default_maps=1

" Don't use Ex mode, use Q for formatting
map Q gq

map <A-DOWN> gj
map <A-UP> gk
imap <A-DOWN> <ESC>gji
imap <A-UP> <ESC>gki

" Goto next/previous error
map <C-DOWN> :cn<CR>
map <C-UP> :cp<CR>
imap <C-DOWN> <ESC>:cn<CR>i
imap <C-UP> <ESC>:cp<CR>i

" Auto add matching }
imap {<CR> {<CR>}<ESC>O

nmap <C-K> :tabnew<CR>
" toggle line numbering
nmap <C-N> :set number!<CR>
" disable search highlight
nmap <C-H> :nohlsearch<CR>
" resync syntax highlight
nmap <C-P> :syn sync fromstart<CR>
imap <C-P> <ESC>:syn sync fromstart<CR>i
map <C-O> :set paste!<CR>
imap <C-O> <ESC>:set paste!<CR>i

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" autocompletion with tab
if has("insert_expand")
    function! CleverTab()
        if strpart( getline('.'), 0, col('.')-1 ) =~ '\(^\s*\|\s\)$'
            return "\<Tab>"
        else
            return "\<C-N>"
        endif
    endfunction

    " bind function to the tab key
    inoremap <Tab> <C-R>=CleverTab()<cr>
endif

if exists('$EMAIL') && $EMAIL != ''
    let g:full_user_email =$EMAIL
elseif exists('$EMAIL_ADDRESS') && $EMAIL_ADDRESS != ''
    let g:full_user_email =$EMAIL_ADDRESS
else
    let login=system('whoami')
    if v:shell_error
	let login = 'nobody'
    else
	let newline = stridx(login, "\n")
        if newline != -1
             let login = strpart(login, 0, newline)
        endif
    endif

    " Try to get the full name from gecos field in /etc/passwd.
    if filereadable('/etc/passwd')
        for line in readfile('/etc/passwd')
            if line =~ '^' . login
                let name = substitute(line,'^\%([^:]*:\)\{4}\([^:]*\):.*$','\1','')
                " Only keep stuff before the first comma.
                let comma = stridx(name, ',')
                if comma != -1
                    let name = strpart(name, 0, comma)
                endif
                " And substitute & in the real name with the login of our user.
                let amp = stridx(name, '&')
                if amp != -1
                    let name = strpart(name, 0, amp) . toupper(login[0]) . 
	                       \ strpart(login, 1) . strpart(name, amp + 1)
                endif
            endif
        endfor
    endif

    " If we haven't found a name, try to gather it from other places.
    if !exists('name')
        " Maybe the environment has something of interest.
        if exists("$NAME")
            let name = $NAME
        else
            " No? well, use the login name and capitalize first
            " character.
            let name = toupper(login[0]) . strpart(login, 1)
        endif
    endif

    " Get our hostname.
    let hostname = system('hostname')
    if v:shell_error
       let hostname = 'localhost'
    else
        let newline = stridx(hostname, "\n")
        if newline != -1
            let hostname = strpart(hostname, 0, newline)
        endif
    endif

    " And finally set the username.
    let g:full_user_email = name . '  <' . login . '@' . hostname . '>'
endif

function ChlogDate()
    call append(line('.') - 1, strftime("%a %b %e %Y "). g:full_user_email)
endfunction

let g:email_match_list = matchstr(g:full_user_email, '\([^<]\{-1,}\)\s\+<\([^>]\)>')
let g:user_name        = g:email_match_list[1]
let g:user_email       = g:email_match_list[2]
let g:Perl_AuthorName  = g:user_name
let g:Perl_Email       = g:user_email
let g:BASH_AuthorName  = g:user_name
let g:BASH_Email       = g:user_email

function InsEmail()
    let cline = getline('.')
    let curpos = col('.')
    let new_line_value = strpart(cline, 0, col('.')) . g:full_user_email . strpart(cline, col('.'))
    call setline('.', new_line_value)
    call setpos('.', [ 0, line('.'), curpos + len(g:full_user_email) + 1, 0 ])
endfunction

map <Leader>m :call InsEmail()<CR>
imap <Leader>m <ESC>:call InsEmail()<CR>i

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
  else
    colorscheme desert256
    let g:CSApprox_loaded=1
    let g:CSApprox_verbose_level=0
  endif
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
  set cursorline
endif

filetype plugin indent on

" GnuPG clearsigning
com -range=% Sign <line1>,<line2>:!gpg --clearsign

" Only do this part when compiled with support for autocommands.
if has("autocmd")

 " In text files, always limit the width of text to 78 characters
 autocmd BufRead *.txt setlocal tw=78

 augroup perl
  au!
  au BufWinLeave *.pl,*.pm mkview
  au BufWinEnter *.pl,*.pm silent loadview
  autocmd FileType perl setlocal shiftwidth=4 softtabstop=4 expandtab
  autocmd FileType perl setlocal textwidth=0
  autocmd FileType perl setlocal cindent
  autocmd FileType perl setlocal foldlevel=0 foldmethod=syntax foldcolumn=2 foldnestmax=1
 augroup END

 augroup tt2
  au!
  au BufWinLeave *.tt2 mkview
  au BufWinEnter *.tt2 silent loadview
  autocmd FileType tt2html setlocal indentexpr= tw=0 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType tt2html map <buffer> <C-T> :setlocal filetype=tt2<CR>
  autocmd FileType tt2html imap <buffer> <C-T> <ESC>:setlocal filetype=tt2<CR>i
  autocmd FileType tt2     setlocal indentexpr= tw=0 softtabstop=4 shiftwidth=4 expandtab
  autocmd FileType tt2     map <buffer> <C-T> :setlocal filetype=tt2html<CR>
  autocmd FileType tt2     imap <buffer> <C-T> <ESC>:setlocal filetype=tt2html<CR>i
 augroup END

 augroup xml
  au!
  autocmd BufReadPre,FileReadPre *.xml,*xhtml setlocal noautoindent
  autocmd BufReadPre,FileReadPre *.xml,*xhtml setlocal indentexpr=
  autocmd BufReadPre,FileReadPre *.xml,*xhtml setlocal shiftwidth=2 expandtab
 augroup END

 augroup html
  au!
  autocmd FileType html setlocal identexpr=
  autocmd FileType html setlocal tw=0
  autocmd FileType html setlocal softtabstop=4 shiftwidth=4
 augroup END

 augroup cprog
  au!
  autocmd FileType c,cpp setlocal cindent formatoptions=crql
  autocmd FileType c,cpp setlocal shiftwidth=4 softtabstop=4 expandtab
  autocmd FileType c,cpp setlocal foldmethod=syntax foldcolumn=2 foldnestmax=1
 augroup END

 augroup chlog
  au!
   autocmd FileType changelog setlocal shiftwidth=4 softtabstop=4 expandtab
   autocmd FileType changelog map <buffer> <Leader>o O<ESC>O<ESC>:call ChlogDate()<CR>i<TAB>* 
 augroup END

 augroup encrypted
    au!

    " First make sure nothing is written to ~/.viminfo while editing
    " an encrypted file.
    autocmd BufReadPre,FileReadPre      *.gpg set viminfo=
    " We don't want a swap file, as it writes unencrypted data to disk
    autocmd BufReadPre,FileReadPre      *.gpg set noswapfile
    " Switch to binary mode to read the encrypted file
    autocmd BufReadPre,FileReadPre      *.gpg set bin
    autocmd BufReadPre,FileReadPre      *.gpg let ch_save = &ch|set ch=2
    autocmd BufReadPost,FileReadPost    *.gpg '[,']!gpg --decrypt 2> /dev/null
    " Switch to normal mode for editing
    autocmd BufReadPost,FileReadPost    *.gpg set nobin
    autocmd BufReadPost,FileReadPost    *.gpg let &ch = ch_save|unlet ch_save
    autocmd BufReadPost,FileReadPost    *.gpg execute ":doautocmd BufReadPost " . expand("%:r")

    " Convert all text to encrypted text before writing
    autocmd BufWritePre,FileWritePre    *.gpg   '[,']!gpg --default-recipient-self -ae 2>/dev/null
    " Undo the encryption so we are back in the normal text, directly
    " after the file has been written.
    autocmd BufWritePost,FileWritePost    *.gpg   u
 augroup END

endif " has("autocmd")

