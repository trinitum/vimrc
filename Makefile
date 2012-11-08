
install:
	install -m644 vimrc ~/.vimrc
	[ -d ~/.vim ] || mkdir ~/.vim
	cp -r vim/* ~/.vim/
	vim -e -u NONE -c "helptags ~/.vim/doc" -c q
