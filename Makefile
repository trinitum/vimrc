
install:
	install -m644 vimrc ~/.vimrc
	[ -d ~/.vim ] || mkdir ~/.vim
	cp -r vim/* ~/.vim/
	[ -d ~/.vim/bundle/vim-go ] || git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go
	(cd ~/.vim/bundle/vim-go && git fetch && git checkout "$$(git describe --tags `git rev-list --tags --max-count=1`)")
	[ -d ~/.vim/bundle/vim-elixir ] || git clone https://github.com/elixir-lang/vim-elixir.git ~/.vim/bundle/vim-elixir
	(cd ~/.vim/bundle/vim-elixir && git pull --rebase)
	[ -d ~/.vim/bundle/ctrlp.vim ] || git clone https://github.com/ctrlpvim/ctrlp.vim.git
	(cd ~/.vim/bundle/ctrlp.vim && git pull --rebase)
	vim -e -u NONE -c "helptags ~/.vim/doc" -c q
