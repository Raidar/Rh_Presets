--[[ LF Search presets ]]--

----------------------------------------
--[[ description:
  -- Presets for LF Search.
  -- Схемы для LF Search.
--]]
----------------------------------------

--------------------------------------------------------------------------------
local _G = _G

----------------------------------------
local far = far
--local F = far.Flags

----------------------------------------
--local context = context
--local logShow = context.ShowInfo

--------------------------------------------------------------------------------
local unit = {}

unit.guid = win.Uuid("f333ea9c-380c-4ce3-bdc7-26a1ec1920e5")

---------------------------------------- context.tables
-- [[
-- Simple copy of table without links to one and the same table.
-- Простая копия таблицы без учёта ссылок на одну и ту же таблицу.
-- WARNING: There is no support of key-subtables and cycles!
local function _copy (t, usemeta, tpairs) --> (table)

  local u = {}
  for k, v in tpairs(t) do
    u[k] = type(v) == 'table' and _copy(v, usemeta, tpairs) or v

  end

  return usemeta and setmetatable(u, getmetatable(t)) or u

end --

local function copy (t)

  return _copy(t or {}, false, pairs)

end ----

-- Expand table t by values from u (using subvalues).
-- Наращение таблицы t значениями из u (с учётом подзначений).
local function _expand (t, u, tpairs) --|> (t)

  for k, v in tpairs(u) do
    local w, tp = t[k], type(v)
    if w == nil then
      t[k] = tp == 'table' and _copy(v, false, tpairs) or v

    elseif tp == 'table' and type(w) == 'table' then
      _expand(w, v, tpairs)

    end
  end

  return t

end --

local function expand (t, u)

  if u == nil then return t end

  return _expand(t or {}, u, pairs)

end ----
--]]

-- Автозамена без предупреждения.
local function AutoReplace (sTitle, sFound, sReps)

  return "all"

end --

---------------------------------------- Chars
--[[
-- Following characters are already used: aefnrt luLUE R
local Chars = {

  b = '0x00A0', -- No-Break space
  d = '0x2014', -- Em dash
  h = '0x2010', -- Hyphen
  s = '0x0020', -- Space

} --- Chars
--]]
---------------------------------------- Kinds
local Kinds = {

  nsearch  = "search",
  nreplace = "replace",
  asearch  = "test:search",
  areplace = "test:replace",
  xcount   = "test:count",
  xlist    = "test:showall",

} --- Kinds

local KindChars = {

  nsearch  = "s",
  nreplace = "r",
  asearch  = "a",
  areplace = "u",
  xcount   = "c",
  xlist    = "l",

} --- KindChars

do
  for k, v in pairs(Kinds) do
    KindChars[v] = KindChars[k]

  end
end -- do

---------------------------------------- Templates
local Templates = {}

Templates.separator = {

  --text = "text",
  --name = "sep",
  --data = nil,

} -- separator

Templates.default = {

  --text = "text",
  --name = "name",
  --key = "key",

  action = Kinds.nreplace,

  data = {
    --sSearchPat = [[find]],
    --sReplacePat = [[replace]],

    bConfirmReplace = true,

    bCaseSens = false,
    bWholeWorlds = false,
    bExtended = false,

    bRegExpr = true,
    sRegexLib = "far",

    sScope  = "block",
    sOrigin = "cursor",
    bSearchBack = false,

    --fUserChoiceFunc = AutoReplace,
  },

} -- default

---------------------------------------- Presets
local Presets = {

  -- plain --
  { template = "separator",
    text = "plain",
    name = "plain",
  },

    -- Чистка:
  { template = "plain",
    text = "&P — Замена обычных точек пробелом",
    name = "Points to Space",
    data = {
      sSearchPat = [[(\x0020)*(\.){2,}(\x0020)*]],
      sReplacePat = [[\x0020]],
    },
  },
  { template = "plain",
    text = "&S — Замена нескольких пробелов пробелом",
    name = "Spaces to Space",
    data = {
      sSearchPat = [[[\x0020\t]([\x0020\t])+]],
      sReplacePat = [[\x0020]],
    },
  },
  { template = "plain",
    text = "&. — Замена пробелов с точкой пробелом",
    name = "Spaced point to Space",
    data = {
      --sSearchPat = [[(\x0020\.\x0020){1,}]],
      sSearchPat = [[(\x0020\.(?=\x0020)){1,}]],
      sReplacePat = [[\x0020]],
    },
  },
  { template = "plain",
    text = "&, — Замена пробелов с точками пробелом",
    name = "Spaced points to Space",
    data = {
      sSearchPat = [[(\x0020\.){2,}]],
      sReplacePat = [[\x0020]],
    },
  },

  { template = "plain",
    text = "&T — Замена табуляции пробелом",
    name = "Tabs to Space",
    data = {
      sSearchPat = [[(\t)+]],
      sReplacePat = [[\x0020]],
    },
  },

    -- Преобразование:
  { template = "plain",
    text = "&$ — 4 пробела на табуляцию",
    name = "Spaces to Tab",
    data = {
      sSearchPat = [[(\x0020){4}]],
      sReplacePat = [[\t]],
    },
  },
  { template = "plain",
    text = "&  — Удаление пробелов у табуляции",
    name = "Clear spaces around Tab",
    data = {
      sSearchPat = [[(\x0020)*\t(\x0020)*]],
      sReplacePat = [[\t]],
    },
  },
  { template = "plain",
    text = "&~ — Тире для списка",
    name = "dash + nb-space",
    data = {
      sSearchPat = [[([—\-])(\x0020)]],
      sReplacePat = [[— ]],
    },
  },
  { template = "plain",
    text = "&- — Правильное тире",
    name = "Correct dash",
    data = {
      sSearchPat = [[(^|\x0020)\-\-?(\x0020|$)]],
      sReplacePat = [[$1—$2]],
    },
  },
  { template = "plain",
    text = "&_ — Неразрывный пробел + тире",
    name = "nb-space + dash",
    data = {
      -- Manual replace only!
      sSearchPat = [[\x0020([—\-]\-?)(\x0020)]],
      sReplacePat = [[ —$2]],
    },
  },
  { template = "plain",
    text = "&= — Неразрывный дефис",
    name = "nb-hyphen",
    data = {
      sSearchPat = [[(\i)-(\i)]],
      sReplacePat = [[$1‑$2]],
    },
  },

    -- Проверка:
  { template = "plain",
    text = "&R — Russian in English word",
    name = "Rus in Eng word",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[[a-zA-Z\d]*[a-zA-Z][а-яА-ЯёЁ\d]+[a-zA-Z][a-zA-Z\d]*]],
    },
  },
  { template = "plain",
    text = "&E — English in Russian word",
    name = "Eng in Rus word",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[[а-яА-ЯёЁ\d]*[а-яА-ЯёЁ][a-zA-Z\d]+[а-яА-ЯёЁ][а-яА-ЯёЁ\d]*]],
    },
  },
  { template = "plain",
    text = "&  — Russian + English in word",
    name = "Rus+Eng in word",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[[а-яА-ЯёЁ\d]*[а-яА-ЯёЁ]\d*[a-zA-Z][a-zA-Z\d]*]],
    },
  },
  { template = "plain",
    text = "&  — English + Russian in word",
    name = "Eng+Rus in word",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[[a-zA-Z\d]*[a-zA-Z]\d*[а-яА-ЯёЁ][а-яА-ЯёЁ\d]*]],
    },
  },
  { template = "plain",
    text = "&L — Разрыв двух длинных слов",
    name = "Space between nb-ed words",
    action = Kinds.nreplace,
    data = {
      sSearchPat = [[\b(\w{2,}) (\w{2,})]],
      sReplacePat = [[$1 $2]],
    },
  },

  -- readme --
  { template = "separator",
    text = "readme",
    name = "readme",
  },

    -- Оформление:
  { template = "readme",
    text = "&G — Пустая строка перед заголовками",
    name = "Empty-lined headings",
    data = {
      sSearchPat = [[^((Глава)|(Лекция)|(Приложение)|(Раздел)|(ЧАСТЬ)|(Chapter)|(PART))]],
      sReplacePat = [[\n$1]],
    },
  },
  { template = "readme",
    text = "&H — Выделение подразделов в строки",
    name = "Split subheadings",
    data = {
      sSearchPat = [[(\))\.]],
      sReplacePat = [[$1\n]],
    },
  },
  { template = "readme",
    text = "&  — Удаление номеров страниц оглавления",
    name = "Delete content page numbers",
    data = {
      sSearchPat = [[ \(\d+\)$]],
      sReplacePat = [[]],
    },
  },
  { template = "readme",
    text = "&  — Удаление номеров страниц ответов",
    name = "Delete content answer page numbers",
    data = {
      sSearchPat = [[ \/ \d+(\))]],
      sReplacePat = [[$1]],
    },
  },

    -- Проверка:
  { template = "readme",
    text = "&  — Поиск длинных строк",
    name = "Lengthy lines",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[^(.){81,}?]],
    },
  },
  { template = "readme",
    text = "&F — Поиск нумерованных формул",
    name = "Numbered formulae",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[([\s]){2,} \( ([\d])* ([\.])+ ([\d])* \)$]],
      bExtended = true,
    },
  },
  { template = "readme",
    text = "&  — Поиск исключаемых [fmt] <Site>",
    name = "Excluded [fmt] <Site>",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[\[.{2,}\] \s \<.{3,}\>]],
      bExtended = true,
    },
  },
  { template = "readme",
    text = "&Q — Неразрывный после rus-предслов",
    name = "Nbsp after rus-praewords",
    --key = "Ctrl+R",
    data = {
      sSearchPat = [[(^|(?<![\-‑]))\b(я|а|и|в|к|о|с|у)(ъ?)\x20]],
      --sSearchPat = [[(^|(?<![\-‑]))\b(а|и|не|ни|в|к|о|с|у|во|до|за|из|ко|на|об|от|по|со)\x20]],
      sReplacePat = [[$2$3\xA0]],
      bExtended = true,
    },
  },
  { template = "readme",
    text = "&W — Неразрывный перед rus-послесловами",
    name = "Nbsp before rus-postwords",
    --key = "Ctrl+R",
    data = {
      sSearchPat = [[\x20(б|ж)\b]],
      --sSearchPat = [[\x20(бы|же|ли)\b]],
      sReplacePat = [[\xA0$1]],
      bExtended = true,
    },
  },
  { template = "readme",
    text = "&  — Неразрывный после lat-предслов",
    name = "Nbsp after lat-praewords",
    --key = "Ctrl+E",
    data = {
      sSearchPat = [[(^|(?<![\-‑]))\b(a|an|e|o|u|y)\x20]],
      --sSearchPat = [[(^|(?<![\-‑]))\b(or|a|an|at|to|in|on|by|of)\x20]],
      sReplacePat = [[$2\xA0]],
      bExtended = true,
    },
  },

  { template = "readme",
    text = "&  — Замена Nbsp между 2-б. словами",
    name = "Replace Nbsp between 2-letter words",
    data = {
      sSearchPat = [[\b(\i{2,})\x00A0(\i{2,})]],
      sReplacePat = [[$1 $2]],
    },
  },

  -- fantlab --
  { template = "separator",
    text = "fantlab",
    name = "fantlab",
  },

  { template = "fantlab",
    text = "&  — Очистка названия от жанра",
    name = "Clear work/opus name of genre",
    data = {
      sSearchPat = [[(\s\([^\(]+?\))\s*$]],
      sReplacePat = [[]],
    },
  },

  { template = "fantlab",
    text = "&! — Очистка от жанра и номеров страниц",
    name = "Clear opus name of genre && page numbers",
    data = {
      sSearchPat = [[(\s\([^\(]+?\))?\,\s[сc](тр)?\.\s\d+(\-\d+)?\s*$]],
      sReplacePat = [[]],
    },
  },

  { template = "fantlab",
    text = "&  — Удаление значения рейтинга",
    name = "Delete rating value",
    data = {
      sSearchPat = [[\t\t\d\.\d\d\s\(\d+\)]],
      sReplacePat = [[]],
    },
  },
  { template = "fantlab",
    text = "&  — Удаление счётчика отзывов",
    name = "Delete review counter",
    data = {
      sSearchPat = [[\t\d+\sотз\.]],
      sReplacePat = [[]],
    },
  },
  { template = "fantlab",
    text = "&  — Удаление пустой оценки",
    name = "Delete empty mark",
    data = {
      sSearchPat = [[^\-$]],
      sReplacePat = [[]],
    },
  },
  { template = "fantlab",
    text = "&@ — Очистка от рейтинга, отзывов, оценок",
    name = "Clear opus name of ranks, reviews, values",
    data = {
      sSearchPat = [[^((\t\t\d\.\d\d\s\(\d+\)\s*)|(\t\d+\sотз\.\s*)|(\-)|(\s+))$]],
      sReplacePat = [[]],
    },
  },
  { template = "fantlab",
    text = "&  — Формат года публикации произведения",
    name = "Format year of opus publication",
    data = {
      sSearchPat = [[\s+\((\d+)\)(\s\/\/\s)?\s*$]],
      sReplacePat = [[. @($1).$2]],
    },
  },
  { template = "fantlab",
    text = "&  — Формат года написания произведения",
    name = "Format year of opus writing",
    data = {
      sSearchPat = [[\s+\((\d+)\)\,\sнаписано\sв\s(\d+)]],
      sReplacePat = [[. @$2 ($1).]],
    },
  },
  { template = "fantlab",
    text = "&  — Формат основного названия произведения",
    name = "Format base name of opus",
    data = {
      sSearchPat = [=[\s+\/\s+]=],
      sReplacePat = [[./ ]],
    },
  },
  { template = "fantlab",
    text = "&  — Формат альтер-названия произведения",
    name = "Format alt-name of opus",
    data = {
      sSearchPat = [=[\s+\[(\=.+?)\]]=],
      sReplacePat = [[ {$1}]],
    },
  },
--

  -- html --
  { template = "separator",
    text = "html",
    name = "html",
  },

    -- Преобразование:
  { template = "html",
    text = "&  — Выделение начальных тегов в строки",
    name = "Split all open tags",
    data = {
      sSearchPat = [[(\<[^\/])]],
      sReplacePat = [[\n$1]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Выделение тегов-абзацев в строки",
    name = "Split para-tags",
    data = {
      sSearchPat = [[([\.\?\!…]) (\< p \>)]],
      sReplacePat = [[$1\n$2]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Очистка конца html-страницы",
    name = "Clear html end",
    data = {
      sSearchPat = [[(\< \/ HTML \>) .*]],
      sReplacePat = [[$1\n]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Очистка перед конечным тегом",
    name = "Unspaced end-tags",
    data = {
      sSearchPat = [[\s* (\< \/)]],
      sReplacePat = [[$1]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Очистка фона html-страницы",
    name = "Clear html bg",
    data = {
      sSearchPat = [[\s bgcolor \= \" (\#)? (\w){1,6} \"]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Удаление скриптов из html",
    name = "Clear html-scripts",
    data = {
      sSearchPat = [[\<(script) .*? \<\/\1\>]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&D — Удаление динамики из html",
    name = "Clear html-dynamic",
    data = {
      sSearchPat = [[\<((script)|(noscript)|(form)) .*? \<\/\1\>]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Удаление объектов из html",
    name = "Clear html-objects",
    data = {
      sSearchPat = [[\<(object) .*? \<\/\1\>]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Удаление ссылки на djv-разделы",
    name = "Delete djv-anchors",
    data = {
      sSearchPat = [[\<((script)|(noscript)|(form)) .*? \<\/\1\>]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Основные теги строчными буквами",
    name = "Main tags as lower",
    data = {
      sSearchPat = [[(\<\/? ( P|H\d|A|B|I|BR|SUB|SUP|FONT|SPAN|TH|TR|TD|HR|PRE|IMG|BLOCKQUOTE ) ( (\s)|(\>) ))]],
      sReplacePat = [[\L$1\E]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Остальные теги строчными буквами",
    name = "Rest tags as lower",
    data = {
      sSearchPat = [[(\<\/? ( UL|LI|CENTER|NOBR|TABLE|TBODY|BODY|HEAD|META|TITLE|STYLE|LINK|HTML ) ( (\s)|(\>) ))]],
      sReplacePat = [[\L$1\E]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&# — Замена числовых мнемоник символами",
    name = "Mnemonics to chars",
    data = {
      sSearchPat = [[\&\#(\d+)\;]],
      sReplacePat = [[
local n = tonumber(t[1])
-- from useStrings:
local s = string.char(bit64.band(n, 0xFF),
                      bit64.band(bit64.rshift(n, 8), 0xFF))
s = win.Utf16ToUtf8(s)
return s
]],
      bExtended = true,
      bRepIsFunc = true,
    },
  },
  { template = "html",
    text = "&  — Добавление ссылки на sup-ссылку",
    name = "Add href to sup-note",
    data = {
      sSearchPat = [[(\<sup\>)(\d+)(\<\/sup\>)]],
      sReplacePat = [[$1<a href="#Note_$2">$2</a>$3]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Замена sup-ссылки на sup-якорь",
    name = "Replace sup-href by sup-name",
    data = {
      sSearchPat = [[a href="#Note_]],
      sReplacePat = [[a name="Note_]],
      bRegExpr = false,
    },
  },
  { template = "html",
    text = "&  — Выравнивание sup-ссылки",
    name = "Align sup-href",
    data = {
      sSearchPat = [[(href="\#Note_)(\d)("\>)]],
      sReplacePat = [[$10$2]],
    },
  },
  { template = "html",
    text = "&  — Закрывающие теги перед пробелом",
    name = "Closed tags before space",
    data = {
      sSearchPat = [[ (\<\/[bi]\>)]],
      sReplacePat = [[$1 ]],
    },
  },
  { template = "html",
    text = "&  — Закрывающие теги перед знаком",
    name = "Closed tags before signs",
    data = {
      sSearchPat = [[([\.\,\:\;\!\?])(\<\/([bius]|em|emphasis|strong)\>)]],
      sReplacePat = [[$2$1]],
    },
  },

  -- sub_assa --
  { template = "separator",
    text = "sub_assa",
    name = "sub_assa",
  },

    -- Преобразование:
  { template = "assa",
    text = "&  — Русский язык для стиля",
    name = "Rus lang for style",
    data = {
      sSearchPat = [[(^Style\: .+\,)0$]],
      sReplacePat = [[$1204]],
    },
  },
  { template = "assa",
    text = "&N — Позиционирование тега \\N",
    name = "Positioning \\N tag",
    data = {
      sSearchPat = [[\s*\\[nN]\s*]],
      sReplacePat = [[\\N ]],
      bCaseSens = true,
    },
  },

  -- pascal --
  { template = "separator",
    text = "pascal",
    name = "pascal",
  },

    -- Оформление:
  { template = "pascal",
    text = "&  — Ключевые слова строчными буквами",
    name = "Keywords as lower",
    data = {
      sSearchPat = [[\b(Function|Procedure|Property|Try|Except|Finally|For|If|While|With|Repeat|Until|Case|End|Unit|INTERFACE|IMPLEMENTATION|Const|Type|Var|Uses|Constructor|Destructor|Inherited)\b]],
      sReplacePat = [[\L$1\E]],
    },
  },
  { template = "pascal",
    text = "&  — Типовые слова строчными буквами",
    name = "Typewords as lower",
    data = {
      sSearchPat = [[\b(Integer|Cardinal|Byte|Word|Extended|Boolean|String|LongInt|LongWord|Double|Single|Char|Break|Continue|Exit|True|False|ResourceString)\b]],
      sReplacePat = [[\L$1\E]],
    },
  },

  -- lum --
  --[[
  { template = "separator",
    text = "Lua User Menu",
    name = "lum",
  },--]]
  --[=[
  { template = "lum",
    text = "&  — AccelStr A -> S+A",
    name = "Convert AccelStr letter to shift+letter",
    data = {
      sSearchPat = [[(AccelStr\s\=\s\")([A-Z])(\")]],
      sReplacePat = [[$1S+$2$3]],
      bCaseSens = true,
    },
  },
  { template = "lum",
    text = "&  — AccelStr a -> A",
    name = "Convert AccelStr lower letter to upper",
    data = {
      sSearchPat = [[(AccelStr\s\=\s\")([a-z])(\")]],
      sReplacePat = [[$1\u$2$3]],
      bCaseSens = true,
    },
  },
  { template = "lum",
    text = "&  — AccelStr S+A -> A",
    name = "Convert AccelStr shift+letter to letter",
    data = {
      sSearchPat = [[(AccelStr\s\=\s\")S\+([A-Z])(\")]],
      sReplacePat = [[$1$2$3]],
      bCaseSens = true,
    },
  },
  { template = "lum",
    text = "&  — AccelStr A -> a",
    name = "Convert AccelStr upper letter to lower",
    data = {
      sSearchPat = [[(AccelStr\s\=\s\")([A-Z])(\")]],
      sReplacePat = [[$1\l$2$3]],
      bCaseSens = true,
    },
  },
  --]=]

--
} --- Presets

---------------------------------------- FillData
local F = far.Flags
local BT_None = F.BTYPE_NONE
local EditorGetInfo = editor.GetInfo

function unit.FillData () --> (Data)

  local Mold = {}   -- Данные по template

  local Data = {}   -- Данные для меню
  unit.Data = Data

  -- Обеспечение уникальности:
  local NameChecks = {} -- имён предустановок (пресетов)
  local HotChars = {    -- горячих букв-клавиш
    true, true, true, true,
    true, true, true, true,
  }
  local sNameFmt = "%s: %s"
  local sTextFmt = "%s %s"
  local sNameError    = "Unique name required for:\nname=%s\ntext=%s"
  local sHotCharError = "Unique hot char required for:\nname=%s\ntext=%s"

  local Default = Templates.default
  if Default then
    local data = Default.data

    local Type = far.AdvControl(F.ACTL_GETWINDOWINFO, 0).Type
    if Type == F.WTYPE_EDITOR then
      local Info = EditorGetInfo()

      if Info.BlockType == BT_None then
        data.sScope, data.sOrigin = "global", "cursor"

      else
        data.sScope, data.sOrigin = "block", "scope"

      end

    else
      data.sScope, data.sOrigin = "global", "scope"

    end

  end -- if

  for k = 1, #Presets do
    local Preset = copy(Presets[k])

    -- Поля предустановки:
    local Name = Preset.name or ''
    local Text = Preset.text or ''
    local Tmpl = Preset.template or 'default'
    Name = sNameFmt:format(Tmpl, Name)

    -- Проверки уникальности:
    if NameChecks[Name] then
      error(sNameError:format(Name, Text))

    end
    NameChecks[Name] = Preset -- true

    if Tmpl ~= "separator" then
      --local HotPos = Text:find('&', 1, true)
      --local HotChar = HotPos and Text:sub(HotPos + 1, HotPos + 1) or ''
      local HotChar = Text:sub(1, 1) and Text:sub(2, 2) or ''
      if HotChar == ' ' then HotChar = '' end
      if HotChar ~= '' then
        if HotChars[HotChar] then
          error(sHotCharError:format(Name, Text))

        end

        HotChars[HotChar] = Preset -- true

      end

    end -- if

    local Template = Templates[Tmpl] or Default
    if (Tmpl ~= 'default') and
       not Template.__expanded then
      expand(Template, Default)
      Template.__expanded = true

    end -- if

    -- Подготовка предустановки:
    expand(Preset, Template)
    if Tmpl == "separator" then
    --if Preset.template == "separator" and not Text:find("^%:sep%:") then
      Preset.text = ":sep:"..Text

    else
      Preset.text = sTextFmt:format(KindChars[Preset.action], Text)

    end

--[[
    if Preset.name == "Rus in Eng word" then
      far.Show(Preset.name,
               Preset.data.sSearchPat, Preset.data.sReplacePat,
               Preset.data.bRegExpr and 'RegExp')
    end -- if
--]]

    Data[#Data + 1] = Preset
--[[
    -- TODO: Исправить:
    -- WARN: Теряется первый пресет
    if Tmpl == "separator" then
      Data[#Data + 1] = Preset

    else
      local Pos = Mold[Tmpl]
      if not Pos then
        Pos = #Data + 1
        Mold[Tmpl] = Pos
        -- Данные для подменю
        Data[Pos] = {
          mold = true,

          text = Templ,
          name = Templ,
        }

      end

      local Sub = Data[Pos]
      Sub[#Sub + 1] = Preset

    end -- if-else
--]]
  end -- for

  return Data

end -- FillData

---------------------------------------- main
do
  local arg = (...)
  --far.Show(arg and arg[1])
  if type(arg) == 'table' then arg = arg[1] end
  if type(arg) ~= 'string' then arg = '' end
  --far.Show(arg, ...)
  --far.Show(unpack(...))

  local Data = unit.FillData()
  --far.Show(unpack(Data))

  -- Поиск пункта
  -- TODO: В отдельную функцию!
  local argData
  for k = 1, #Data do
    local t = Data[k]

    if t.mold then
      local ok
      for n = 1, #t do
        local u = t[n]
        if u.name == arg then
          argData = u
          ok = true

          break
        end

      end -- for

      if ok then break end

    elseif t.name == arg then
      argData = t

      break
    end

  end -- for

  if argData then
    --far.Show(argData.action, argData.data.sSearchPat, argData.data.sReplacePat)
    lfsearch.EditorAction(argData.action, argData.data)

  else
    return unit

  end
end -- do
--------------------------------------------------------------------------------
