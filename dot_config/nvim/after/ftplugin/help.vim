if &modifiable
  " vimdocは78で改行すると良いらしい
  setl textwidth=78
  let &l:colorcolumn=&l:textwidth
  setl conceallevel=0
  setl spell
endif

setl tabstop=8
setl noexpandtab
setl norightleft
