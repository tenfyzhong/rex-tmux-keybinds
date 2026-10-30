local M = {}

-- Call once per configuration load, from the rexpack spec's init callback.
function M.setup(options)
    if options == nil then options = {} end
    assert(type(options) == "table", "rex-tmux-keybinds: options must be a table")
    local prefix = options.prefix
    if prefix == nil then prefix = "ctrl+s" end
    assert(type(prefix) == "string" and prefix:match("%S"),
        "rex-tmux-keybinds: prefix must be a nonblank key string")

    rex.mode("prefix", { exclusive = true })
    rex.bind(prefix, "client.mode.enter", { name = "prefix", once = true })
    -- Uppercase keys must be written with shift+.
    -- See README.md for configuration and compatibility limits.

    -- Prefix passthrough (the old rmux Ctrl+S, Ctrl+A binding).
    rex.bind("prefix/ctrl+a", "pane.send_key", { key = prefix })
    rex.bind("prefix/" .. prefix, "pane.send_key", { key = prefix })
    rex.bind("ctrl+enter", "pane.send_key", { key = "ctrl+j" })
    rex.bind("prefix/r", "client.config.reload")

    -- Windows in tmux correspond to Rex tabs. Display numbers start at 0; Rex API positions start at 1.
    rex.bind("prefix/c", "client.tab.new")
    rex.bind("prefix/n", "client.tab.next")
    rex.bind("prefix/p", "client.tab.previous")
    rex.bind("prefix/ctrl+l", "client.tab.next")
    rex.bind("prefix/ctrl+h", "client.tab.previous")
    rex.bind("prefix/,", "client.tab.rename")
    rex.bind("prefix/shift+7", "client.tab.close") -- &
    rex.bind("prefix/w", "client.sidebar.toggle")
    rex.bind("prefix/1", "client.tab.goto", { index = 2 })
    rex.bind("prefix/2", "client.tab.goto", { index = 3 })
    rex.bind("prefix/3", "client.tab.goto", { index = 4 })
    rex.bind("prefix/4", "client.tab.goto", { index = 5 })
    rex.bind("prefix/5", "client.tab.goto", { index = 6 })
    rex.bind("prefix/6", "client.tab.goto", { index = 7 })
    rex.bind("prefix/7", "client.tab.goto", { index = 8 })
    rex.bind("prefix/8", "client.tab.goto", { index = 9 })
    rex.bind("prefix/9", "client.tab.goto", { index = 10 })
    rex.bind("prefix/0", "client.tab.goto", { index = 1 })
    rex.bind("prefix/=>0", "client.tab.goto", { index = 11 })
    rex.bind("prefix/=>1", "client.tab.goto", { index = 12 })
    rex.bind("prefix/=>2", "client.tab.goto", { index = 13 })
    rex.bind("prefix/=>3", "client.tab.goto", { index = 14 })
    rex.bind("prefix/=>4", "client.tab.goto", { index = 15 })
    rex.bind("prefix/=>5", "client.tab.goto", { index = 16 })
    rex.bind("prefix/=>6", "client.tab.goto", { index = 17 })
    rex.bind("prefix/=>7", "client.tab.goto", { index = 18 })
    rex.bind("prefix/=>8", "client.tab.goto", { index = 19 })
    rex.bind("prefix/=>9", "client.tab.goto", { index = 20 })
    rex.bind("prefix/alt+h", "client.tab.move.backward")
    rex.bind("prefix/alt+l", "client.tab.move.forward")

    -- Sessions. The picker replaces tmux's session list.
    rex.bind("prefix/shift+n", "session.new")
    rex.bind("prefix/s", "session.switch")
    rex.bind("prefix/shift+4", "session.rename") -- $
    rex.bind("prefix/shift+9", "session.previous") -- (
    rex.bind("prefix/shift+0", "session.next") -- )

    -- Splits: custom keys plus standard tmux aliases.
    rex.bind("prefix/\\", "pane.split", { direction = "right" })
    rex.bind("prefix/-", "pane.split", { direction = "down" })
    rex.bind("prefix/shift+5", "pane.split", { direction = "right" }) -- %
    rex.bind("prefix/shift+'", "pane.split", { direction = "down" }) -- "
    rex.bind("prefix/h", "pane.focus", { direction = "left" })
    rex.bind("prefix/j", "pane.focus", { direction = "down" })
    rex.bind("prefix/k", "pane.focus", { direction = "up" })
    rex.bind("prefix/l", "pane.focus", { direction = "right" })
    rex.bind("prefix/left", "pane.focus", { direction = "left" })
    rex.bind("prefix/down", "pane.focus", { direction = "down" })
    rex.bind("prefix/up", "pane.focus", { direction = "up" })
    rex.bind("prefix/right", "pane.focus", { direction = "right" })
    rex.bind("ctrl+h", "pane.focus", { direction = "left" })
    rex.bind("ctrl+j", "pane.focus", { direction = "down" })
    rex.bind("ctrl+k", "pane.focus", { direction = "up" })
    rex.bind("ctrl+l", "pane.focus", { direction = "right" })
    rex.bind("prefix/o", "pane.focus_next")
    rex.bind("prefix/shift+o", "pane.focus_previous")
    rex.bind("prefix/z", "pane.zoom")
    rex.bind("prefix/x", "pane.close")
    rex.bind("prefix/shift+1", "pane.move_to_new_tab") -- !
    rex.bind("prefix/shift+j", "pane.resize", { direction = "down", amount = 2 })
    rex.bind("prefix/shift+k", "pane.resize", { direction = "up", amount = 2 })
    rex.bind("prefix/shift+h", "pane.resize", { direction = "left", amount = 2 })
    rex.bind("prefix/shift+l", "pane.resize", { direction = "right", amount = 2 })
    rex.bind("prefix/ctrl+left", "pane.resize", { direction = "left", amount = 2 })
    rex.bind("prefix/ctrl+down", "pane.resize", { direction = "down", amount = 2 })
    rex.bind("prefix/ctrl+up", "pane.resize", { direction = "up", amount = 2 })
    rex.bind("prefix/ctrl+right", "pane.resize", { direction = "right", amount = 2 })
    rex.bind("prefix/shift+[", "pane.move", { direction = "left" }) -- {
    rex.bind("prefix/shift+]", "pane.move", { direction = "right" }) -- }
    rex.bind("prefix/alt+left", "pane.move", { direction = "left" })
    rex.bind("prefix/alt+down", "pane.move", { direction = "down" })
    rex.bind("prefix/alt+up", "pane.move", { direction = "up" })
    rex.bind("prefix/alt+right", "pane.move", { direction = "right" })
    rex.bind("prefix/space", "pane.balance")

    -- Persistent resize mode replaces tmux's repeat-time window.
    -- Amounts are percentages of the split, not terminal cells.
    rex.mode("resize", { exclusive = true })
    rex.bind("prefix/shift+r", "client.mode.enter", { name = "resize" })
    rex.bind("resize/h", "pane.resize", { direction = "left", amount = 2 })
    rex.bind("resize/j", "pane.resize", { direction = "down", amount = 2 })
    rex.bind("resize/k", "pane.resize", { direction = "up", amount = 2 })
    rex.bind("resize/l", "pane.resize", { direction = "right", amount = 2 })
    rex.bind("resize/left", "pane.resize", { direction = "left", amount = 2 })
    rex.bind("resize/down", "pane.resize", { direction = "down", amount = 2 })
    rex.bind("resize/up", "pane.resize", { direction = "up", amount = 2 })
    rex.bind("resize/right", "pane.resize", { direction = "right", amount = 2 })
    rex.bind("resize/shift+h", "pane.resize", { direction = "left", amount = 10 })
    rex.bind("resize/shift+j", "pane.resize", { direction = "down", amount = 10 })
    rex.bind("resize/shift+k", "pane.resize", { direction = "up", amount = 10 })
    rex.bind("resize/shift+l", "pane.resize", { direction = "right", amount = 10 })
    rex.bind("resize/=", "pane.balance")
    rex.bind("resize/enter", "client.mode.exit")
    rex.bind("resize/escape", "client.mode.exit")
    rex.bind("resize/q", "client.mode.exit")

    -- Manual application passthrough for Vim/fzf. Escape must reach the editor.
    -- Prefix, t enters; prefix, t exits. Prefix navigation still works.
    rex.mode("terminal", { exclusive = false })
    rex.bind("prefix/t", "client.mode.enter", { name = "terminal" })

    rex.bind("terminal/ctrl+h", "pane.send_key", { key = "ctrl+h" })
    rex.bind("terminal/ctrl+j", "pane.send_key", { key = "ctrl+j" })
    rex.bind("terminal/ctrl+k", "pane.send_key", { key = "ctrl+k" })
    rex.bind("terminal/ctrl+l", "pane.send_key", { key = "ctrl+l" })
    rex.bind("terminal/escape", "pane.send_key", { key = "escape" })

    -- Native alternatives, not tmux copy-mode or a tmux command interpreter.
    rex.bind("prefix//", "client.find.open")
    rex.bind("prefix/shift+;", "client.palette.toggle") -- :
    rex.bind("prefix/shift+/", "client.shortcuts.edit") -- ?
    rex.bind("prefix/pageup", "client.prompt.previous")
    rex.bind("prefix/pagedown", "client.prompt.next")

    -- A terminal-specific prefix keeps all prefix commands available while making
    -- P t exit terminal mode. Copy the shared bindings instead of maintaining two
    -- lists. The one-shot prefix is popped by Rex before its action performs.
    rex.mode("terminal_prefix", { exclusive = true })
    for _, binding in ipairs(rex.bindings{ mode = "prefix" }) do
        if binding.key ~= "t" then
            rex.bind("terminal_prefix/" .. binding.key, binding.action, binding.args)
        end
    end
    rex.bind("terminal/" .. prefix, "client.mode.enter", {
        name = "terminal_prefix",
        once = true,
    })
    rex.bind("terminal_prefix/t", "client.mode.exit_all")
end

return M
