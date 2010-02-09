
install:
	install -m644 vimrc ~/.vimrc
	[ -d ~/.vim ] || mkdir ~/.vim
	cp -r vim/* ~/.vim/
