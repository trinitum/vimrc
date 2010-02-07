
install:
	install -m644 vimrc ~/.vimrc
	install -D -m644 vim/indent/perl.vim ~/.vim/indent/perl.vim
	install -D -m644 vim/syntax/perl.vim ~/.vim/syntax/perl.vim
	install -D -m644 vim/syntax/pod.vim ~/.vim/syntax/pod.vim
