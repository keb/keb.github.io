.PHONY: build serve dev

LUASMITH_VERSION := 0.10
LUASMITH := luasmith.com

build: $(LUASMITH)
	./$(LUASMITH) theme.lua

$(LUASMITH):
	curl -fsSL https://github.com/jaredkrinke/luasmith/releases/download/$(LUASMITH_VERSION)/luasmith-$(LUASMITH_VERSION)-universal.zip -o luasmith.zip
	unzip -o luasmith.zip
	rm luasmith.zip
	chmod +x $@

serve: build
	darkhttpd ./public/ --port 5000 --header 'Access-Control-Allow-Origin: *'

dev:
	watchexec -r -i 'public/**' -i 'luasmith.*' -- $(MAKE) serve
