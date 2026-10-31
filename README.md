# rex-tmux-keybinds

Tmux/rmux-style keybindings for Rex, managed by
[rexpack](https://github.com/tenfyzhong/rexpack). Pure Lua; no build step.
Migrated from the Rex Beta 0.1.0 (1497) configuration.

## Configure

Add this plugin specification to `~/.config/rex/plugins/rex-tmux-keybinds.lua`:

```lua
return {
    "tenfyzhong/rex-tmux-keybinds",
    init = function()
        require("rex-tmux-keybinds").setup({
            prefix = "ctrl+s",
        })
    end,
}
```

Change `prefix` in that file (for example to `"ctrl+b"`), then run
`rex config check` and `rex config reload`. It defaults to `ctrl+s` when omitted.
Use Rex key syntax. The prefix must be a single key chord, not a mode-qualified
binding or a multi-step sequence; Rex validates the key syntax at config load.
The entry key, terminal-mode entry key, double-prefix passthrough and
`P Ctrl+a` passthrough all use the configured value.

The configured prefix takes precedence over conflicting built-in bindings. For
example, `ctrl+enter` becomes the prefix instead of sending Ctrl+J,
and with prefix `c`, `P c` sends `c` instead of creating a tab. The same
passthrough precedence applies in terminal mode. The bare key `t` (case
insensitive) is rejected before any registration because `P t` must remain
available to enter and exit terminal mode.

Register during `init`: modes and bindings must exist at configuration load.
Requiring the module itself has no side effects. Call `setup` once per config
load; reload Rex to change options. The plugin owns the `prefix`, `resize`,
`terminal` and `terminal_prefix` modes, plus the global bindings below.
Avoid defining conflicting modes or loading the old keybindings simultaneously.

When migrating, remove `require("keybindings")` from `init.lua`. Keep the old
file as an inactive backup if desired. To roll back, remove this plugin spec,
restore the old require and reload Rex. Other plugins can continue to extend
`prefix`; declaration order matters if they copy or replace existing bindings.

## Keys

`P` means press and release the configured prefix. Uppercase letters require
Shift. Escape cancels the one-shot prefix. Rex's native Cmd shortcuts remain.

| Keys | Action |
| --- | --- |
| `P c`, `P n/p`, `P Ctrl+l/h` | New, next, previous tab |
| `P ,`, `P &`, `P w` | Rename tab, close tab, toggle sidebar |
| `P 0`–`P 9`, `P = 0`–`P = 9` | Go to tabs 0–9 and 10–19 (API positions 1–20) |
| `P Alt+h/l` | Move tab backward/forward |
| `P N`, `P s`, `P $`, `P (` / `P )` | New, switch, rename, previous/next session |
| `P \` / `P %`, `P -` / `P "` | Split right, split down |
| `P h/j/k/l`, `P arrows` | Focus pane |
| `P o/O`, `P z`, `P x`, `P !` | Next/previous pane, zoom, close, move to new tab |
| `P H/J/K/L`, `P Ctrl+arrows` | Resize by 2 percentage points |
| `P {` / `P }`, `P Alt+arrows` | Move pane |
| `P Space` | Balance panes |
| `P R` | Enter persistent resize mode |
| `P t` | Enter/exit terminal passthrough mode |
| `P Ctrl+a`, `P P` | Send the configured prefix to the terminal |
| `Ctrl+Enter` | Send Ctrl+J |
| `P r`, `P /`, `P :`, `P ?` | Reload, find, palette, shortcut editor |
| `P PageUp/PageDown` | Previous/next shell prompt (requires shell integration) |

Resize mode uses `h/j/k/l` or arrows for 2%, uppercase `H/J/K/L` for 10%,
`=` to balance, and Enter/Escape/`q` to exit. Units are percentages, not cells.

Terminal mode forwards Ctrl+h/j/k/l and Escape to Vim/fzf or the shell.
Prefix navigation remains available; `P t` exits. This is manual switching,
without foreground-process detection. Terminal-prefix bindings reuse the
prefix map, except `t` exits all modes.

This plugin provides native Rex actions, not a tmux command interpreter.
It does not implement vi copy mode, tmux buffers, detach, synchronized input,
URL/agent pickers or status bars. Fastcopy is a separate plugin.

## Tests

```sh
make test-deps
make test
```

Requires LuaRocks and LuaJIT (or `make test LUA=lua5.1`). LuaUnit 3.5-1 is a
local test dependency, not a runtime dependency. On Homebrew, use
`make test-deps LUAROCKS_FLAGS=--lua-dir=/opt/homebrew/opt/luajit` if needed.
Tests compare the full default mode/binding map with the original migration
fixture and check custom-prefix propagation, invalid options and import safety.
The fixture is frozen historical input; do not update it to match implementation
changes. Run `rex config check` and reload for native integration verification.

The GitHub Actions `Tests` workflow runs the unit suite on Lua 5.1 and LuaJIT
for pushes and pull requests, and can also be started manually. Native Rex
configuration checks and keyboard interactions require a local Rex installation
and are not run by CI.
