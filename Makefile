
install:
	install -m644 vimrc ~/.vimrc
	[ -d ~/.vim ] || mkdir ~/.vim
	cp -r vim/* ~/.vim/
	# CtrlP
	[ -d ~/.vim/bundle/ctrlp.vim ] || \
		git clone --depth=1 https://github.com/ctrlpvim/ctrlp.vim.git ~/.vim/bundle/ctrlp.vim
	(cd ~/.vim/bundle/ctrlp.vim && git pull --rebase)
	# Syntastic
	[ -d ~/.vim/bundle/syntastic ] || \
		git clone --depth=1 https://github.com/vim-syntastic/syntastic.git ~/.vim/bundle/syntastic
	(cd ~/.vim/bundle/syntastic && git pull --rebase)
	# Go
	[ -d ~/.vim/bundle/vim-go ] || \
		git clone --depth=1 https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go
	(cd ~/.vim/bundle/vim-go && \
		git fetch && \
		git checkout "$$(git describe --tags `git rev-list --tags --max-count=1`)")
	# Rust
	[ -d ~/.vim/bundle/rust.vim ] || \
		git clone --depth=1 https://github.com/rust-lang/rust.vim.git ~/.vim/bundle/rust.vim
	(cd ~/.vim/bundle/rust.vim && git pull --rebase)
	[ -d ~/.vim/bundle/vim-racer ] || \
		git clone --depth=1 https://github.com/racer-rust/vim-racer.git ~/.vim/bundle/vim-racer
	(cd ~/.vim/bundle/vim-racer && git pull --rebase)
	# Generate doc tags
	vim -e -u NONE -c "helptags ~/.vim/doc" -c q
