" Vim filetype plugin for Perl
"
" This is reimplimentation of those functions from perl-support
" which I actually use. It is lite and does what I want.

if !exists("b:loaded_erlang_ftplugin")
	setlocal tabstop=4
	setlocal shiftwidth=4
	setlocal iskeyword+=:

	nnoremap    <buffer> <silent> <LocalLeader>ry :call <SID>Tidy()<CR>

	let b:loaded_erlang_ftplugin = 1
endif

if exists("s:loaded_erlang_ftplugin_definitions")
	finish
endif

function s:Tidy()
	silent exe "update"
	silent exe "!escript ~/.vim/scripts/tidy_erl ".fnameescape(expand("%:p"))
	silent exe "edit"
	redraw!
endfunction

let s:loaded_erlang_ftplugin_definitions = 1
