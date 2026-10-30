LUA ?= luajit
LUAROCKS ?= luarocks
LUAROCKS_FLAGS ?=

.PHONY: test-deps test

test-deps:
	$(LUAROCKS) --lua-version=5.1 $(LUAROCKS_FLAGS) --tree .test-deps install luaunit 3.5-1

test:
	$(LUA) tests/keybindings.lua
