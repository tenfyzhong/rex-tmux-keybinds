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
    local actual = capture(function() require('rex-tmux-keybinds').setup() end)
    lu.assertEquals(actual, expected)
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

os.exit(lu.LuaUnit.run())
