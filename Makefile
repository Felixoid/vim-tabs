VIM ?= vim

# make test [T=pattern]
.PHONY: test
test:
	@$(VIM) -Nu NONE -i NONE -es $(if $(T),--cmd "let g:test_filter = '$(T)'") -S test/run.vim </dev/null; \
	rc=$$?; cat test/out.log; exit $$rc
