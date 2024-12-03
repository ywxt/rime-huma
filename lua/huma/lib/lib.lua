-- lib.lua
local rime = {}
package.loaded[...] = rime
rime.encoder = {}

--[[ rime.encoder.load_settings()
用一个 librime 风格的列表描述构词规则。之后解析为另一张表，面向后端函数，其元素
以词组长度为键，以表格 { char_idx, code_idx } 的列表为值，依次描述词组的每一码
。formula 中 'U' 和 'u' 之后的字母表示从末尾倒数，解析为负数索引。
sample encoder configuration (input):
{
  { length_equal = 2, formula = 'AaAbBaBb' },
  { length_equal = 3, formula = 'AaBaCaCb' },
  { length_in_range = {4, 10}, formula = 'AaBaCaZa' }
}
output:
{
  nil,
  { { 1, 1 }, { 1, 2 }, { 2, 1 }, { 2, 2 } },
  { { 1, 1 }, { 2, 1 }, { 3, 1 }, { 3, 2 } },
  { { 1, 1 }, { 2, 1 }, { 3, 1 }, { -1, 1 } },
  ... -- 第 5 至 10 个元素与第 4 个元素相同。
}
--]]

function rime.encoder.parse_formula(formula)
    if type(formula) ~= 'string' or formula:gsub('%u%l', '') ~= '' then
        return
    end
    local rule = {}
    local A, a, U, u, Z, z = ('AaUuZz'):byte(1, -1)
    for m in formula:gmatch('%u%l') do
        local upper, lower = m:byte(1, 2)
        local char_idx = upper < U and upper - A + 1 or upper - Z - 1
        local code_idx = lower < u and lower - a + 1 or lower - z - 1
        rule[#rule + 1] = { char_idx, code_idx }
    end
    return rule
end

function rime.encoder.load_settings(setting)
    -- 注意到公式同则规则同，可通过 f2r 在 rt 中作引用定义，以节省资源。
    local ft, f2r, rt = {}, {}, {}
    for _, t in ipairs(setting) do
        if t.length_equal then
            ft[t.length_equal] = t.formula
        elseif t.length_in_range then
            local min, max = table.unpack(t.length_in_range)
            for l = min, max do ft[l] = t.formula end
        end
    end
    -- setting 中的 length 不一定连续且一般不包括 1，所以不能用 ipairs()。
    for k, f in pairs(ft) do
        local rule = rime.encoder.parse_formula(f)
        if not rule then return end
        if not f2r[f] then f2r[f] = rule end
        rt[k] = f2r[f]
    end
    return rt
end

function rime.switch_option(name, context)
    context:set_option(name, not context:get_option(name))
end

-- Cycle options of a switcher. When #options == 1, toggle the only option.
-- Otherwise unset the first set option and unset the next, or the previous if
-- 'reverse' is true. When no set option is present, try the key
-- 'options.save', then 'options.default', then 1.
function rime.cycle_options(options, env, reverse)
    local context = env.engine.context
    if #options == 0 then return 0 end
    if #options == 1 then
        rime.switch_option(options[1], context)
        return 1
    end
    local state
    for k, v in ipairs(options) do
        if context:get_option(v) then
            context:set_option(v, false)
            state = (reverse and (k - 1) or (k + 1)) % #options
            if state == 0 then state = #options end
            break
        end
    end
    local k = state or options.save or options.default or 1
    context:set_option(options[k], true)
    return k
end

-- Set an option in 'options' if no one is set yet.
function rime.init_options(options, context)
    for k, v in ipairs(options) do if context:get_option(v) then return end end
    local k = state or options.save or options.default or 1
    context:set_option(options[k], true)
end

-- Generate a processor that cycle a group of options with a key.
-- For now only works when composing.
function rime.make_option_cycler(options, cycle_key_config_path,
                                 switch_key_config_path, reverse)
    local processor, cycle_key, switch_key = {}
    processor.init = function(env)
        local config = env.engine.schema.config
        rime.init_options(options, env.engine.context)
        cycle_key = config:get_string(cycle_key_config_path)
        switch_key = config:get_string(switch_key_config_path)
    end
    processor.func = function(key, env)
        local context = env.engine.context
        if context:is_composing() and key:repr() == cycle_key then
            local state = rime.cycle_options(options, env, reverse)
            if state > 1 then options.save = state end
            return 1
        elseif context:is_composing() and key:repr() == switch_key then
            -- 选项状态可能在切换方案时被重置，因此需检测更新。但是不能在 filter.init
            -- 中检测，因为得到的似乎是重置之前的状态，说明组件初始化先于状态重置。为
            -- 经济计，仅在手动切换开关时检测。
            -- https://github.com/rime/librime/issues/449
            -- Todo: 对于较新的 librime-lua，尝试利用 option_update_notifier 更新
            -- options.save
            for k, v in ipairs(options) do
                if context:get_option(v) then
                    if k > 1 then options.save = k end
                end
            end
            local k = options.save or options.default
            -- Consider the 1st options as OFF state.
            if context:get_option(options[1]) then
                context:set_option(options[1], false)
                context:set_option(options[k], true)
            else
                context:set_option(options[k], false)
                context:set_option(options[1], true)
            end
            return 1
        end
        return 2 -- kNoop
    end
    return processor
end

function rime.generate_candidate(cand, comment)
    local type = cand:get_dynamic_type()

    local function create_candidate(create_func, cand_type, text, comment)
        if create_func then
            return create_func(cand, cand_type, text, comment, true)
        else
            return Candidate(cand_type, text, comment)
        end
    end

    if type == 'Shadow' then
        cand = create_candidate(ShadowCandidate, cand.type, cand.text, comment)
    else
        cand.comment = comment
    end

    return cand
end

local chinese_charset = {
    { first = 0x4E00, last = 0x9FFF },   -- 基本汉字+补充
    { first = 0x3400, last = 0x4DBF },   -- 扩A
    { first = 0x20000, last = 0x2A6DF }, -- 扩B
    { first = 0x2A700, last = 0x2B73F }, -- 扩C
    { first = 0x2B740, last = 0x2B81F }, -- 扩D
    { first = 0x2B820, last = 0x2CEAF }, -- 扩E
    { first = 0x2CEB0, last = 0x2EBEF }, -- 扩F
    { first = 0x30000, last = 0x3134F }, -- 扩G
    { first = 0x31350, last = 0x323AF }, -- 扩H
    { first = 0x2EBF0, last = 0x2EE4F }, -- 擴I
    { first = 0x323B0, last = 0x3347F }, -- 擴J
    { first = 0x38000, last = 0x3AB9F }, -- 篆書
    { first = 0x2E80, last = 0x2EF3 },   -- 部首扩展
    { first = 0x2F00, last = 0x2FD5 },   -- 康熙部首
    { first = 0xF900, last = 0xFAFF },   -- 兼容汉字
    { first = 0x2F800, last = 0x2FA1D }, -- 兼容扩展
    { first = 0xE815, last = 0xE86F },   -- PUA(GBK)部件
    { first = 0xE400, last = 0xE5E8 },   -- 部件扩展
    { first = 0xE600, last = 0xE6CF },   -- PUA增补
    { first = 0x31C0, last = 0x31E3 },   -- 汉字笔画
    { first = 0x2FF0, last = 0x2FFB },   -- 汉字结构
    { first = 0x3105, last = 0x312F },   -- 汉语注音
    { first = 0x31A0, last = 0x31BA },   -- 注音扩展
    { first = 0x3007, last = 0x3007 }    -- 〇

}

function rime.load_charset()
    return require('huma/lib/charset')
end

local function is_chinese(code)
    for index, value in ipairs(chinese_charset) do
        if code >= value.first and code <= value.last then return true end
    end
    return false
end

-- check if a character is in a charset map.
local function is_in_charset(char, charset) return charset[char] end

-- 對於CJK之外的字符不做過濾，假定所有的字符在CJK區
-- check if all characters of the string are in a charset map.
function rime.filter_charset(string, charset)
    if not charset then return true end -- this means all characters are allowed.
    for index, code in utf8.codes(string) do
        if not is_in_charset(utf8.char(code), charset) then return false end
    end
    return true
end

-- check if all characters of the string are CJK characters by code points.
function rime.filter_chinese(string)
    for index, code in utf8.codes(string) do
        if not is_chinese(code) then return false end
    end
    return true
end
