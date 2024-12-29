local Tran = {}
local Simplifier = {}

local dict = {
    ['a'] = { 'あ', 'ア' },
    ['i'] = { 'い', 'イ' },
    ['u'] = { 'う', 'ウ' },
    ['e'] = { 'え', 'エ' },
    ['o'] = { 'お', 'オ' },
    ['ka'] = { 'か', 'カ' },
    ['ki'] = { 'き', 'キ' },
    ['ku'] = { 'く', 'ク' },
    ['ke'] = { 'け', 'ケ' },
    ['ko'] = { 'こ', 'コ' },
    ['sa'] = { 'さ', 'サ' },
    ['shi'] = { 'し', 'シ' },
    ['su'] = { 'す', 'ス' },
    ['se'] = { 'せ', 'セ' },
    ['so'] = { 'そ', 'ソ' },
    ['ta'] = { 'た', 'タ' },
    ['chi'] = { 'ち', 'チ' },
    ['tsu'] = { 'つ', 'ツ' },
    ['te'] = { 'て', 'テ' },
    ['to'] = { 'と', 'ト' },
    ['na'] = { 'な', 'ナ' },
    ['ni'] = { 'に', 'ニ' },
    ['nu'] = { 'ぬ', 'ヌ' },
    ['ne'] = { 'ね', 'ネ' },
    ['no'] = { 'の', 'ノ' },
    ['ha'] = { 'は', 'ハ' },
    ['hi'] = { 'ひ', 'ヒ' },
    ['Fu'] = { 'ふ', 'フ' },
    ['he'] = { 'へ', 'ヘ' },
    ['ho'] = { 'ほ', 'ホ' },
    ['ma'] = { 'ま', 'マ' },
    ['mi'] = { 'み', 'ミ' },
    ['mu'] = { 'む', 'ム' },
    ['me'] = { 'め', 'メ' },
    ['mo'] = { 'も', 'モ' },
    ['ya'] = { 'や', 'ヤ' },
    ['yu'] = { 'ゆ', 'ユ' },
    ['yo'] = { 'よ', 'ヨ' },
    ['ra'] = { 'ら', 'ラ' },
    ['ri'] = { 'り', 'リ' },
    ['ru'] = { 'る', 'ル' },
    ['re'] = { 'れ', 'レ' },
    ['ro'] = { 'ろ', 'ロ' },
    ['wa'] = { 'わ', 'ワ' },
    ['wo'] = { 'を', 'ヲ' },
    ['n'] = { 'ん', 'ン' },
    ['ga'] = { 'が', 'ガ' },
    ['gi'] = { 'ぎ', 'ギ' },
    ['gu'] = { 'ぐ', 'グ' },
    ['ge'] = { 'げ', 'ゲ' },
    ['go'] = { 'ご', 'ゴ' },
    ['za'] = { 'ざ', 'ザ' },
    ['zi'] = { 'じ', 'ジ' },
    ['zu'] = { 'ず', 'ズ' },
    ['ze'] = { 'ぜ', 'ゼ' },
    ['zo'] = { 'ぞ', 'ゾ' },
    ['da'] = { 'だ', 'ダ' },
    ['di'] = { 'ぢ', 'ヂ' },
    ['du'] = { 'づ', 'ヅ' },
    ['de'] = { 'で', 'デ' },
    ['do'] = { 'ど', 'ド' },
    ['ba'] = { 'ば', 'バ' },
    ['bi'] = { 'び', 'ビ' },
    ['bu'] = { 'ぶ', 'ブ' },
    ['be'] = { 'べ', 'ベ' },
    ['bo'] = { 'ぼ', 'ボ' },
    ['pa'] = { 'ぱ', 'パ' },
    ['pi'] = { 'ぴ', 'ピ' },
    ['pu'] = { 'ぷ', 'プ' },
    ['pe'] = { 'ぺ', 'ペ' },
    ['po'] = { 'ぽ', 'ポ' },
    ['kya'] = { 'きゃ', 'キャ' },
    ['kyu'] = { 'きゅ', 'キュ' },
    ['kyo'] = { 'きょ', 'キョ' },
    ['sya'] = { 'しゃ', 'シャ' },
    ['syu'] = { 'しゅ', 'シュ' },
    ['syo'] = { 'しょ', 'ショ' },
    ['cya'] = { 'ちゃ', 'チャ' },
    ['nya'] = { 'にゃ', 'ニャ' },
    ['nyu'] = { 'にゅ', 'ニュ' },
    ['nyo'] = { 'にょ', 'ニョ' },
    ['hya'] = { 'ひゃ', 'ヒャ' },
    ['hyu'] = { 'ひゅ', 'ヒュ' },
    ['hyo'] = { 'ひょ', 'ヒョ' },
    ['mya'] = { 'みゃ', 'ミャ' },
    ['myu'] = { 'みゅ', 'ミュ' },
    ['myo'] = { 'みょ', 'ミョ' },
    ['rya'] = { 'りゃ', 'リャ' },
    ['ryu'] = { 'りゅ', 'リュ' },
    ['ryo'] = { 'りょ', 'リョ' },
    ['gya'] = { 'ぎゃ', 'ギャ' },
    ['gyu'] = { 'ぎゅ', 'ギュ' },
    ['gyo'] = { 'ぎょ', 'ギョ' },
    ['zya'] = { 'じゃ', 'ジャ' },
    ['zyu'] = { 'じゅ', 'ジュ' },
    ['zyo'] = { 'じょ', 'ジョ' },
    ['dya'] = { 'ぢゃ', 'ヂャ' },
    ['dyu'] = { 'ぢゅ', 'ヂュ' },
    ['dyo'] = { 'ぢょ', 'ヂョ' },
    ['bya'] = { 'びゃ', 'ビャ' },
    ['byu'] = { 'びゅ', 'ビュ' },
    ['byo'] = { 'びょ', 'ビョ' },
    ['pya'] = { 'ぴゃ', 'ピャ' },
    ['pyu'] = { 'ぴゅ', 'ピュ' },
    ['pyo'] = { 'ぴょ', 'ピョ' },
}

function Tran.init(env)
    local config = env.engine.schema.config
    local quality = config:get_int(env.name_space .. '/quality')
    local option_name = config:get_string(env.name_space .. '/option_name')
    env.quality = quality
    env.option_name = option_name
end

function Tran.func(input, seg, env)
    local context = env.engine.context
    if not context:get_option(env.option_name) then
        return
    end
    local candidates = dict[input]
    if not candidates then
        return
    end
    for _, candidate in ipairs(candidates) do
        local cand = Candidate('kana', seg.start, seg._end, candidate, '〔 仮名 〕')
        cand.quality = env.quality
        yield(cand)
    end
end

function Simplifier.init(env)
    local config = env.engine.schema.config
    env.opencc_t2s = Opencc('huma.t2s.json')
    env.opencc_t2jp = Opencc('huma.t2jp.json')
    env.option_jp = config:get_string(env.name_space .. '/jp_option_name')
    env.option_zh = config:get_string(env.name_space .. '/zh_option_name')
end

function Simplifier.func(input, env)
    local context = env.engine.context
    local opencc = context:get_option(env.option_jp) and env.opencc_t2jp or
        (context:get_option(env.option_zh) and env.opencc_t2s or nil)
    if not opencc then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end
    for cand in input:iter() do
        local text = opencc:convert(cand.text)
        if text == cand.text then
            yield(cand)
        else
            local cand = cand:to_shadow_candidate('simplifier', text, '〔 ' .. cand.text .. ' 〕')
            yield(cand)
        end
    end
end

return { translator = Tran, simplifier = Simplifier }
