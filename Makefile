VIM ?= vim
VIM_TOOLS_REF := 35f86c91a4d313368cddc24c20b625789dd645cf
DOC_IMAGE := vim-tabs-doc

define DOCKERFILE
FROM python:3-slim
ADD https://github.com/ycm-core/vim-tools/archive/$(VIM_TOOLS_REF).tar.gz /tmp/vim-tools.tgz
RUN mkdir /opt/vim-tools && tar xzf /tmp/vim-tools.tgz -C /opt/vim-tools --strip-components=1 \
 && pip install --no-cache-dir -r /opt/vim-tools/requirements.txt && rm /tmp/vim-tools.tgz
WORKDIR /src
ENTRYPOINT ["python3", "/opt/vim-tools/html2vimdoc.py"]
endef
export DOCKERFILE

# make test [T=pattern]
.PHONY: test
test:
	@$(VIM) -Nu NONE -i NONE -es $(if $(T),--cmd "let g:test_filter = '$(T)'") -S test/run.vim </dev/null; \
	rc=$$?; cat test/out.log; exit $$rc

.PHONY: smoke
smoke:
	@$(VIM) -Nu NONE -i NONE -es -S test/smoke.vim </dev/null; \
	rc=$$?; cat test/out.log; exit $$rc

# Tags of the thinca/vim images: VIMS run the tests, SMOKE_VIMS are too old for them.
VIMS ?= v8.1.1585 v8.2.3227 v8.2.4825 latest
SMOKE_VIMS ?= v7.4.2367 v8.0.0000

.PHONY: test-vims
test-vims:
	@failed=; \
	for v in $(addprefix run:,$(VIMS)) $(addprefix smoke:,$(SMOKE_VIMS)); do \
	  echo "== $${v#*:} ($${v%%:*})"; \
	  docker run --rm -u $$(id -u):$$(id -g) -v $(CURDIR):/src -w /src --entrypoint vim thinca/vim:$${v#*:} \
	    -Nu NONE -i NONE -es -S test/$${v%%:*}.vim </dev/null || failed="$$failed $${v#*:}"; \
	  grep -v '^ok' test/out.log; \
	done; \
	[ -z "$$failed" ] || { echo "failed on:$$failed"; exit 1; }

# The image is rebuilt only when the Dockerfile hash in its label differs.
.PHONY: doc
doc:
	@set -e; trap 'rm -f doc/tabs.txt.tmp' EXIT; \
	hash=$$(printf '%s' "$$DOCKERFILE" | sha256sum | cut -c1-12); \
	old=$$(docker image inspect -f '{{.Id}} {{index .Config.Labels "dockerfile.hash"}}' $(DOC_IMAGE) 2>/dev/null || true); \
	if [ "$${old#* }" != "$$hash" ]; then \
	  printf '%s\n' "$$DOCKERFILE" | docker build --label dockerfile.hash=$$hash -t $(DOC_IMAGE) -; \
	  [ -z "$$old" ] || docker image rm "$${old%% *}" >/dev/null 2>&1 || true; \
	fi; \
	docker run --rm -u $$(id -u):$$(id -g) -v $(CURDIR):/src $(DOC_IMAGE) -f tabs README.md > doc/tabs.txt.tmp; \
	mv doc/tabs.txt.tmp doc/tabs.txt
