GH_BUNDLES=ctrlpvim/ctrlp.vim tpope/vim-unimpaired tpope/vim-fugitive tpope/vim-vinegar \
	   fatih/vim-go rust-lang/rust.vim prabirshrestha/async.vim prabirshrestha/vim-lsp \
	   prabirshrestha/asyncomplete.vim prabirshrestha/asyncomplete-lsp.vim

install:
	install -m644 vimrc ~/.vimrc
	[ -d ~/.vim ] || mkdir ~/.vim
	cp -r vim/* ~/.vim/
	# install plugins
	cd ~/.vim/bundle && for bundle in $(GH_BUNDLES); do \
		echo $$bundle; \
		[ -d $${bundle##*/} ] || git clone https://github.com/$$bundle; \
		( cd $${bundle##*/} && git pull --rebase ); done
	# Generate doc tags
	vim -e -c "Helptags" -c q
