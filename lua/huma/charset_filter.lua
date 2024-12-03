local rime = require('huma.lib.lib')


local function init(env) env.charset = env.charset or rime.load_charset() end

local function get_charset_option(env)
    return env.engine.context:get_option('charset_filter')
end

local function get_charset(env, option)
    if option then return env.charset end
    return nil
end

local function get_chinese_only_option(env)
    return env.engine.context:get_option('chinese_only')
end



local function charset_filter(input, env)
    local charset_option = get_charset_option(env)
    local chinese_only_option = get_chinese_only_option(env)
    local charset = get_charset(env, charset_option)
    for cand in input:iter() do
        local cand_gen = cand:get_genuine()
        if rime.filter_chinese(cand_gen.text) then
            if rime.filter_charset(cand_gen.text, charset) then
                yield(cand)
            end
        else
            if not chinese_only_option then yield(cand) end
        end
    end
end

return { init = init, func = charset_filter }
