-- single_char_only.lua
-- Comes from @hchuihui the author of librime-lua
--    https://github.com/rime/librime/issues/248#issuecomment-468924677
local function filter(input, env)
    local b = env.engine.context:get_option("single_char_only")
    for cand in input:iter() do
        local cand_gen = cand:get_genuine()
        if (not b or utf8.len(cand.text) == 1 or cand_gen.type == 'kana') then yield(cand) end
    end
end

return filter
