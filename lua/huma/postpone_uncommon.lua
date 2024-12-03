
local rime = require('huma.lib.lib')


local function init(env)
    env.charset = env.charset or rime.load_charset()
end

local function filter(input, env)
    local context = env.engine.context
    if not context:get_option("postpone_uncommon") then
        for cand in input:iter() do yield(cand) end
    else
        local charset = env.charset
        local dropped_cands = {}
        for cand in input:iter() do
            local cand_gen = cand:get_genuine()
            if cand_gen.type == 'completion' or cand_gen.type == 'sentence' then
                -- insert uncommon characters before completion or sentence candidates
                if #dropped_cands > 0 then
                    for _, c in ipairs(dropped_cands) do
                        yield(c)
                    end
                    dropped_cands = {}
                end
                yield(cand)
            else
                local text = cand_gen.text
                -- postpone uncommon chinese characters only
                if utf8.len(text) == 1 and rime.filter_chinese(text) and not rime.filter_charset(text, charset) then
                    table.insert(dropped_cands, cand)
                else
                    yield(cand)
                end
            end
        end
        for _, c in ipairs(dropped_cands) do
            yield(c)
        end
    end
end

return { init = init, func = filter }
