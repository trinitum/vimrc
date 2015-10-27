" Vim filetype plugin for Perl
"
" This is reimplimentation of those functions from perl-support
" which I actually use. It is lite and does what I want.

if !exists("b:loaded_perl_ftplugin")
	setlocal softtabstop=4
	setlocal shiftwidth=4
	setlocal iskeyword+=:

	ia ddpr use DDP;<CR>p
	ia bnch use Benchmark qw( cmpthese );<CR>cmpthese -10, {};<ESC>O
	ia bplt <ESC>:set paste<CR>i#!/usr/bin/env perl<CR>use 5.014;<CR>use strict;<CR>use warnings;<CR><ESC>:set nopaste<CR>i

	nnoremap    <buffer> <silent> <LocalLeader>cb :call <SID>BlockComment()<CR>
	vnoremap    <buffer> <silent> <LocalLeader>cb :call <SID>BlockComment()<CR>
	nnoremap    <buffer> <silent> <LocalLeader>cc :call <SID>ToggleComments()<CR>j
	vnoremap    <buffer> <silent> <LocalLeader>cc :call <SID>ToggleComments()<CR>j
	nnoremap    <buffer> <silent> <LocalLeader>co :call <SID>CommentOut()<CR>j
	vnoremap    <buffer> <silent> <LocalLeader>co :call <SID>CommentOut()<CR>j
	nnoremap    <buffer> <silent> <LocalLeader>cu :call <SID>Uncomment()<CR>j
	vnoremap    <buffer> <silent> <LocalLeader>cu :call <SID>Uncomment()<CR>j
	nnoremap    <buffer> <silent> <LocalLeader>cf :call <SID>SubComment("")<CR>$a
	inoremap    <buffer> <silent> <LocalLeader>cf :call <ESC><SID>SubComment("")<CR>$a
	nnoremap    <buffer> <silent> <LocalLeader>cm :call <SID>SubComment("\$self->")<CR>$a
	inoremap    <buffer> <silent> <LocalLeader>cm :call <ESC><SID>SubComment("\$self->")<CR>$a
	nnoremap    <buffer> <silent> <LocalLeader>cs :call <SID>SubComment("\$class->")<CR>$a
	inoremap    <buffer> <silent> <LocalLeader>cs :call <ESC><SID>SubComment("\$class->")<CR>$a
        nnoremap    <buffer> <silent> <LocalLeader>ca :call <SID>AttrComment()<CR>$a
        inoremap    <buffer> <silent> <LocalLeader>ca :call <ESC><SID>AttrComment()<CR>$a

	nnoremap    <buffer> <silent> <LocalLeader>rs :call <SID>SyntaxCheck()<CR>
	nnoremap    <buffer> <silent> <LocalLeader>re :call <SID>ChmodX()<CR>
	nnoremap    <buffer> <silent> <LocalLeader>ry :call <SID>PerlTidy("n")<CR>
	vnoremap    <buffer> <silent> <LocalLeader>ry :call <SID>PerlTidy("v")<CR>
	nnoremap    <buffer> <silent> <LocalLeader>ro :call <SID>ToggleRunOutput()<CR>
	nnoremap    <buffer> <silent> <LocalLeader>rr :call <SID>Run()<CR>

	let b:loaded_perl_ftplugin = 1
endif

if exists("s:loaded_perl_ftplugin_definitions")
	finish
endif

function s:ToggleComments ()
	let l:line = getline(".")
	if match(l:line, '^\s*#') == -1
		call setline(".", substitute(l:line, "^", "#", ""))
	else
		call setline(".", substitute(l:line, "#", "", ""))
	endif
endfunction

function s:CommentOut ()
	call setline(".", substitute(getline("."), "^", "#", ""))
endfunction

function s:Uncomment ()
	call setline(".", substitute(getline("."), "#", "", ""))
endfunction

function s:BlockComment () range
	call append(a:lastline, [ "", "=end comment", "=cut" ])
	call append(a:firstline-1, [ "=begin comment", "" ])
endfunction

function s:SubName ()
	let l:line = getline(".")
	if match(l:line, "^sub \\w\\+") == -1
		return ""
	else
		return substitute(l:line, "^sub \\(\\w\\+\\).*$", "\\1", "")
	endif
endfunction

function s:SubComment (prefix)
	let l:fname = s:SubName()
	let l:lnum  = line(".")
	call append(l:lnum - 1, [ "=head2 " . a:prefix . l:fname, "", "=cut", "" ])
	call cursor(l:lnum, 1)
endfunction

function s:AttrName ()
        let l:line = getline(".")
        if match(l:line, "^has \\w\\+") == -1
                return ""
        else
                return substitute(l:line, "^has \\(\\w\\+\\).*$", "\\1", "")
        endif
endfunction

function s:AttrComment ()
        let l:aname = s:AttrName()
        let l:lnum  = line(".")
        call append(l:lnum - 1, [ "=head3 " . l:aname, "", "=cut", "" ])
        call cursor(l:lnum, 1)
endfunction

function s:SyntaxCheck ()
	let l:bufnr = bufnr("%")
	silent exe "update"
	exe 'setlocal makeprg=perl\ -c'
	exe 'setlocal errorformat=
		\%-G%.%#had\ compilation\ errors.,
		\%-G%.%#syntax\ OK,
		\%m\ at\ %f\ line\ %l.,
		\%+A%.%#\ at\ %f\ line\ %l\\,%.%#,
		\%+C%.%#'
	silent exe "make ".fnameescape(expand("%:p"))
	exe "botright cwindow"
	redraw!
	if l:bufnr == bufnr("%")
		echohl Search
		echo "Syntax OK"
		echohl None
	else
		exe ".cc"
	endif
endfunction

if !exists("s:output_to")
	let s:output_to = 'term'
endif

function s:ToggleRunOutput ()
	if s:output_to == 'term'
		let s:output_to = 'buffer'
	else
		let s:output_to = 'term'
	endif
	echohl Search
	echo "Perl script output will be sent to ".s:output_to
	echohl None
endfunction

function s:Run ()
	let l:pathname = fnameescape(expand("%:p"))
	silent exe "update"
	if s:output_to == 'term'
		exe "!perl ".l:pathname
	else
		silent exe "botright new"
		setlocal syntax=none
		setlocal tabstop=8
		set buftype=nofile
		exe "%!perl ".l:pathname
	endif
endfunction

function s:ChmodX ()
	silent exe "update"
	silent exe "!chmod +x " . fnameescape(expand("%:p"))
	redraw!
	if v:shell_error
		echohl WarningMsg
		echo "Couldn't chmod +x file"
		echohl None
	else
		exe "edit"
	endif
endfunction

function s:PerlTidy (mode) range
	if a:mode=="n"
		let l:line = line(".")
		exe '%!perltidy'
		exe l:line
	endif
	if a:mode=="v"
		exe a:firstline.",".a:lastline."!perltidy"
	endif
	if filereadable("perltidy.ERR")
		call cursor(1,1)
		call search("perltidy.ERR")
		echohl WarningMsg
		echo "Perltidy found some errors!"
		echohl None
	endif
endfunction

let s:loaded_perl_ftplugin_definitions = 1
