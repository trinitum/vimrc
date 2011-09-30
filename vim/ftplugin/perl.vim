" Vim filetype plugin for Perl

if !exists("b:loaded_perl_ftplugin")
	setlocal tabstop=4
	setlocal shiftwidth=4
	setlocal iskeyword+=:

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

	let b:loaded_perl_ftplugin = 1
endif

if exists("s:loaded_perl_ftplugin_definitions")
	finish
endif

function s:ToggleComments ()
	let l:line = getline(".")
	if match(l:line, "^#") == -1
		call setline(".", substitute(l:line, "^", "#", ""))
	else
		call setline(".", substitute(l:line, "^#", "", ""))
	endif
endfunction

function s:CommentOut ()
	call setline(".", substitute(getline("."), "^", "#", ""))
endfunction

function s:Uncomment ()
	call setline(".", substitute(getline("."), "^#", "", ""))
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

let s:loaded_perl_ftplugin_definitions = 1
