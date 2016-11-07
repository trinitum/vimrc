
install:
	install -m644 vimrc ~/.vimrc
	[ -d ~/.vim ] || mkdir ~/.vim
	cp -r vim/* ~/.vim/
	[ -d ~/.vim/bundle/vim-go ] || git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go
	(cd ~/.vim/bundle/vim-go && git fetch && git checkout v1.9)
	vim -e -u NONE -c "helptags ~/.vim/doc" -c q
