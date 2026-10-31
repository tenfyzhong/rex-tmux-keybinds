package.path = './lua/?.lua;./lua/?/init.lua;./.test-deps/share/lua/5.1/?.lua;' .. package.path
local lu = require('luaunit')

local function capture(run)
    local result = { modes = {}, bindings = {} }
    _G.rex = {
        mode = function(name, options) result.modes[name] = options end,
        bind = function(key, action, args)
            result.bindings[key] = { action = action, args = args }
        end,
        bindings = function(options)
            local list = {}
            for key, binding in pairs(result.bindings) do
                local prefix = options.mode .. '/'
                if key:sub(1, #prefix) == prefix then
                    list[#list + 1] = {
                        key = key:sub(#prefix + 1), action = binding.action, args = binding.args,
                    }
                end
            end
            return list
        end,
    }
    run()
    return result
end

TestBindings = {}
function TestBindings:testRequireHasNoSideEffects()
    package.loaded['rex-tmux-keybinds'] = nil
    local actual = capture(function() require('rex-tmux-keybinds') end)
    lu.assertEquals(actual, { modes = {}, bindings = {} })
end

function TestBindings:testOriginalParity()
    local expected = capture(function() dofile('tests/fixtures/original-keybindings.lua') end)
    for _, key in ipairs({ 'ctrl+h', 'ctrl+j', 'ctrl+k', 'ctrl+l' }) do
        expected.bindings[key] = nil
    end
    local actual = capture(function() require('rex-tmux-keybinds').setup() end)
    lu.assertEquals(actual, expected)
end

function TestBindings:testNoGlobalPaneNavigation()
    local actual = capture(function() require('rex-tmux-keybinds').setup() end)
    for _, key in ipairs({ 'ctrl+h', 'ctrl+j', 'ctrl+k', 'ctrl+l' }) do
        lu.assertNil(actual.bindings[key], key)
    end
end

function TestBindings:testCustomPrefix()
    local actual = capture(function() require('rex-tmux-keybinds').setup({ prefix = 'ctrl+b' }) end)
    lu.assertEquals(actual.bindings['ctrl+b'], {
        action = 'client.mode.enter', args = { name = 'prefix', once = true },
    })
    lu.assertNil(actual.bindings['ctrl+s'])
    lu.assertNil(actual.bindings['prefix/ctrl+s'])
    for _, mode in ipairs({ 'prefix', 'terminal_prefix' }) do
        for _, key in ipairs({ 'ctrl+a', 'ctrl+b' }) do
            lu.assertEquals(actual.bindings[mode .. '/' .. key], {
                action = 'pane.send_key', args = { key = 'ctrl+b' },
            })
        end
    end
    lu.assertEquals(actual.bindings['terminal/ctrl+b'].args, { name = 'terminal_prefix', once = true })
    lu.assertEquals(actual.bindings['terminal_prefix/t'].action, 'client.mode.exit_all')
    lu.assertEquals(actual.bindings['terminal_prefix/c'].action, 'client.tab.new')
end

function TestBindings:testInvalidOptionsFailBeforeRegistration()
    for _, options in ipairs({ false, 'ctrl+b', { prefix = false }, { prefix = '' }, { prefix = ' ' }, { prefix = 42 } }) do
        local actual = capture(function()
            lu.assertErrorMsgContains('rex-tmux-keybinds:', function()
                require('rex-tmux-keybinds').setup(options)
            end)
        end)
        lu.assertEquals(actual, { modes = {}, bindings = {} })
    end
end

local function assertPrefixWorks(prefix)
    local actual = capture(function() require('rex-tmux-keybinds').setup({ prefix = prefix }) end)
    lu.assertEquals(actual.bindings[prefix], {
        action = 'client.mode.enter', args = { name = 'prefix', once = true },
    }, prefix)
    lu.assertEquals(actual.bindings['terminal/' .. prefix], {
        action = 'client.mode.enter', args = { name = 'terminal_prefix', once = true },
    }, prefix)
    for _, mode in ipairs({ 'prefix', 'terminal_prefix' }) do
        for _, key in ipairs({ prefix, 'ctrl+a' }) do
            lu.assertEquals(actual.bindings[mode .. '/' .. key], {
                action = 'pane.send_key', args = { key = prefix },
            }, prefix)
        end
    end
    lu.assertEquals(actual.bindings['prefix/t'].action, 'client.mode.enter')
    lu.assertEquals(actual.bindings['terminal_prefix/t'].action, 'client.mode.exit_all')
end

function TestBindings:testPrefixOverridesGlobalBindings()
    for _, prefix in ipairs({ 'ctrl+h', 'ctrl+j', 'ctrl+k', 'ctrl+l', 'ctrl+enter' }) do
        assertPrefixWorks(prefix)
    end
end

function TestBindings:testPrefixOverridesCommandBindings()
    local original = capture(function() dofile('tests/fixtures/original-keybindings.lua') end)
    for key in pairs(original.bindings) do
        local prefix = key:match('^prefix/(.+)$')
        -- Sequences are not single-chord prefixes; t is reserved for mode switching.
        if prefix and prefix ~= 't' and not prefix:find('=>', 1, true) then
            assertPrefixWorks(prefix)
        end
    end
end

function TestBindings:testTerminalTogglePrefixRejectedBeforeRegistration()
    for _, prefix in ipairs({ 't', 'T' }) do
        local actual = capture(function()
            lu.assertErrorMsgContains('reserved for terminal mode', function()
                require('rex-tmux-keybinds').setup({ prefix = prefix })
            end)
        end)
        lu.assertEquals(actual, { modes = {}, bindings = {} })
    end
end

os.exit(lu.LuaUnit.run())
