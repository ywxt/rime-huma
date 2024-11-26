local lunar_calendar = require('huma/lib/lunar_calendar')
local solar_term = require('huma/lib/solar_term')
local lunar_ganzhi = require('huma/lib/lunar_ganzhi')

local function starts_with(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local function fn_date()
    -- 定义中英文月份对照表
    local month_names_long = {
        en = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" },
        cn = { "一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月" }
    }
    local month_names_short = {
        en = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" },
        cn = { "一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月" }
    }

    -- 获取月份名称，指定语言
    local function month_name(language, time)
        local current_date = os.date("*t", time) -- 获取当前时间表
        local month_index = current_date.month   -- 获取月份索引 (1-12)
        return { month_names_long[language][month_index] or "Invalid language", month_names_short[language][month_index] or
        "Invalid language" }
    end
    local datetime = os.time()
    return {
        { text = os.date('%Y-%m-%d', datetime), comment = '西曆' },
        { text = os.date('%Y年%m月%d日', datetime), comment = '西曆' },
        { text = month_name('en')[2] .. ' ' .. os.date('%d, %Y'), comment = '西曆' },
        { text = month_name('en')[1] .. ' ' .. os.date('%d, %Y'), comment = '西曆' },
        { text = lunar_calendar.solar2lunar(os.date('%Y%m%d', datetime)), comment = '農曆' },
        { text = lunar_ganzhi.ganzhi_date(os.date('%Y-%m-%d %H:%M:%S', datetime)), comment = '干支' },
        { text = lunar_ganzhi.ganzhi_date_with_zodiac(os.date('%Y-%m-%d %H:%M:%S', datetime)), comment = '干支' },
    }
end

local function fn_time()
    local datetime = os.time()
    return {
        { text = os.date('%H:%M:%S', datetime) },
        { text = os.date('%H時%M分%S秒', datetime) },
        { text = os.date('%Y-%m-%d %H:%M:%S', datetime), comment = '西曆' },
        { text = os.date('%Y年%m月%d日 %H時%M分%S秒', datetime), comment = '西曆' },
        { text = lunar_ganzhi.ganzhi_time(os.date('%Y-%m-%d %H:%M:%S', datetime)), comment = '干支' },
    }
end

local function fn_solar_term()
    local datetime = os.time()
    local solar_term_list = solar_term.solar_terms(os.date('%Y-%m-%d', datetime))
    local result = {}
    for i, v in ipairs(solar_term_list) do
        table.insert(result, { text = v['name'] .. ' ' .. v['date'], comment = '節氣' })
    end
    return result
end

local function fn_week()
    -- 定义一个中英文星期表
    local weekdays_long = {
        en = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" },
        cn = { "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" }
    }
    local weekdays_short = {
        en = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" },
        cn = { "週日", "週一", "週二", "週三", "週四", "週五", "週六" }
    }

    -- 格式化日期，返回指定语言的星期几
    local function format_weekday(lang, time)
        -- 获取当前日期的星期几，os.date("%w") 返回 0（星期日）到 6（星期六）
        local weekday_index = tonumber(os.date("%w", time)) + 1
        return {
            weekdays_long[lang][weekday_index] or "Invalid language",
            weekdays_short[lang][weekday_index] or "Invalid language",
        }
    end

    function week_number(time)
        -- 获取当前日期
        local current_date = os.date("*t", time)

        -- 获取年份的第一天
        local first_day_of_year = os.date("*t", os.time { year = current_date.year, month = 1, day = 1 })

        -- 计算当前日期和第一天之间的天数
        ---@diagnostic disable-next-line: param-type-mismatch
        local days_since_start_of_year = os.difftime(os.time(current_date), os.time(first_day_of_year)) / (24 * 60 * 60)

        -- 计算当前是今年的第几周
        local week_number = math.floor((days_since_start_of_year + first_day_of_year.wday - 1) / 7) + 1

        return week_number
    end

    local datetime = os.time()
    local result = {}
    local langs = { 'cn', 'en' }
    for i, lang in ipairs(langs) do
        local weekday = format_weekday(lang, datetime)
        for j, v in ipairs(weekday) do
            table.insert(result, { text = v, comment = '星期' })
        end
    end
    table.insert(result, { text = '第' .. week_number(datetime) .. '週', comment = '星期' })
    return result
end

local function fn_about()
    return {
        { text = 'ywxt', comment = '作者' },
        { text = 'https://github.com/ywxt/rime-huma', comment = '項目地址' },
    }
end

local function fn_help()
    return {
        { text = '日期', comment = '/date' },
        { text = '時間', comment = '/time' },
        { text = '節氣', comment = '/jieqi' },
        { text = '星期', comment = '/week' },
        { text = '幫助', comment = '/help' },
        { text = '關於', comment = '/about' },
    }
end

local menu = {
    ['date'] = { type = 'date', fn = fn_date },
    ['time'] = { type = 'time', fn = fn_time },
    ['jieqi'] = { type = 'solar_term', fn = fn_solar_term },
    ['week'] = { type = 'week', fn = fn_week },
    ['help'] = { type = 'help', fn = fn_help },
    ['about'] = { type = 'about', fn = fn_about },
}

local function translator(input, seg, env)
    local prefix = env.engine.schema.config:get_string('function_selector/prefix')
    if not starts_with(input, prefix) then
        return
    end
    command = string.sub(input, #prefix + 1)
    if not menu[command] then return end
    local items = menu[command].fn()
    for i, v in ipairs(items) do
        if v.comment then
            yield(Candidate(menu[command].type, seg.start, seg._end, v.text, '〔 ' .. v.comment .. ' 〕'))
        else
            yield(Candidate(menu[command].type, seg.start, seg._end, v.text, ''))
        end
    end
end

return translator
