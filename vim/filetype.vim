" my filetype file
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  au!
  au BufRead,BufNewFile Changes	setfiletype changelog
  au BufRead,BufNewFile *.tt2   setfiletype tt2html
augroup END

