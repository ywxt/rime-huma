-- rime.lua

huma_single_char_only = require("huma/single_char_only")


huma_postpone_fullcode = require("huma/postpone_fullcode")

huma_charset = require('huma/charset')

local _spelling = require('huma/spelling')
huma_spelling = _spelling.filter
huma_spelling_processor = _spelling.processor
