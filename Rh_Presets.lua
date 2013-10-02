-- LF Search presets

--------------------------------------------------------------------------------
local _G = _G

--local rhlog = require "Rh_Scripts.Utils.Logging"
--local logMsg, linMsg = rhlog.Message, rhlog.lineMessage

--------------------------------------------------------------------------------

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
-- Following characters are already used: aefnrt luLUE R
local Chars = {
  b = '0x00A0', -- No-Break space
  d = '0x2014', -- Em dash
  h = '0x2010', -- Hyphen
  s = '0x0020', -- Space
} --- Chars

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
  { template = "readme",
    text = "&P — Замена обычных точек пробелом",
    name = "Points to Space",
    data = {
      sSearchPat = [[(\x0020)*(\.){2,}(\x0020)*]],
      sReplacePat = [[\x0020]],
    },
  },
  { template = "readme",
    text = "&S — Замена нескольких пробелов пробелом",
    name = "Spaces to Space",
    data = {
      sSearchPat = [[[\x0020\t]([\x0020\t])+]],
      sReplacePat = [[\x0020]],
    },
  },
  { template = "readme",
    text = "&. — Замена пробелов с точкой пробелом",
    name = "Spaced point to Space",
    data = {
      sSearchPat = [[(\x0020\.\x0020){1,}]],
      sReplacePat = [[\x0020]],
    },
  },
  { template = "readme",
    text = "&, — Замена пробелов с точками пробелом",
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
    text = "&$ — 4 пробела на табуляцию",
    name = "Spaces to Tab",
    data = {
      sSearchPat = [[(\x0020){4}]],
      sReplacePat = [[\t]],
    },
  },
  { template = "plain",
    text = "&  — Удаление пробелов у табуляции",
    name = "Clear spaces around Tab",
    data = {
      sSearchPat = [[(\x0020)*\t(\x0020)*]],
      sReplacePat = [[\t]],
    },
  },
  { template = "plain",
    text = "&- — Правильное тире",
    name = "Correct dash",
    data = {
      sSearchPat = [[(^|\x0020)-(\x0020|$)]],
      sReplacePat = [[$1—$2]],
    },
  },
  { template = "plain",
    text = "&= — Тире + неразрывный пробел",
    name = "dash + nb-space",
    data = {
      sSearchPat = [[([—\-])(\x0020)]],
      sReplacePat = [[— ]],
    },
  },
  { template = "plain",
    text = "&+ — Неразрывный пробел + тире",
    name = "nb-space + dash",
    data = {
      sSearchPat = [[\x0020([—\-])(\x0020)]],
      sReplacePat = [[ —$2]],
    },
  },
    -- Проверка:
  { template = "plain",
    text = "&R — Russian in English word",
    name = "Rus in Eng word",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[[a-zA-Z\d]*[a-zA-Z][а-яА-ЯёЁ\d]+[a-zA-Z][a-zA-Z\d]*]],
    },
  },
  { template = "plain",
    text = "&E — English in Russian word",
    name = "Eng in Rus word",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[[а-яА-ЯёЁ\d]*[а-яА-ЯёЁ][a-zA-Z\d]+[а-яА-ЯёЁ][а-яА-ЯёЁ\d]*]],
    },
  },
  { template = "plain",
    text = "&  — Russian + English in word",
    name = "Rus+Eng in word",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[[а-яА-ЯёЁ\d]*[а-яА-ЯёЁ]\d*[a-zA-Z][a-zA-Z\d]*]],
    },
  },
  { template = "plain",
    text = "&  — English + Russian in word",
    name = "Eng+Rus in word",
    action = Kinds.nsearch,
    data = {
      sSearchPat = [[[a-zA-Z\d]*[a-zA-Z]\d*[а-яА-ЯёЁ][а-яА-ЯёЁ\d]*]],
    },
  },

  -- readme --
  { template = "separator",
    text = "readme",
    name = "readme",
  },
    -- Оформление:
  { template = "readme",
    text = "&G — Пустая строка перед заголовками",
    name = "Empty-lined headings",
    data = {
      sSearchPat = [[^((Глава)|(Лекция)|(Приложение)|(Раздел)|(ЧАСТЬ)|(Chapter)|(PART))]],
      sReplacePat = [[\n$1]],
    },
  },
  { template = "readme",
    text = "&H — Выделение подразделов в строки",
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
    text = "&  — Неразрывный после коротких rus-слов",
    name = "Nbsp after short rus-words",
    data = {
      sSearchPat = [[\b(а|и|но|не|ни|в|к|о|с|у|во|до|за|из|ко|на|об|от|по|со|без|для|над|под|при|про|перед|после|сквозь|через)\x20]],
      sReplacePat = [[$1\xA0]],
      bExtended = true,
    },
  },
  { template = "readme",
    text = "&  — Неразрывный после коротких eng-слов",
    name = "Nbsp after short eng-words",
    data = {
      sSearchPat = [[\b(and|or|a|an|the|at|to|in|on|by|of|for|into|from|onto|over|with)\x20]],
      sReplacePat = [[$1\xA0]],
      bExtended = true,
    },
  },

  -- html --
  { template = "separator",
    text = "html",
    name = "html",
  },
    -- Преобразование:
  { template = "html",
    text = "&  — Выделение абзацев в строки",
    name = "Split para-tags",
    data = {
      sSearchPat = [[\. (\< p \>)]],
      sReplacePat = [[.\n$1]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Очистка конца html‑страницы",
    name = "Clear html end",
    data = {
      sSearchPat = [[(\< \/ HTML \>) .*]],
      sReplacePat = [[$1\n]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Очистка перед конечным тэгом",
    name = "Unspaced end-tags",
    data = {
      sSearchPat = [[\s* (\< \/)]],
      sReplacePat = [[$1]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Очистка фона html‑страницы",
    name = "Clear html bg",
    data = {
      sSearchPat = [[\s bgcolor \= \" (\#)? (\w){1,6} \"]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Удаление скриптов из html",
    name = "Clear html-scripts",
    data = {
      sSearchPat = [[\<(script) .*? \<\/\1\>]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&D — Удаление динамики из html",
    name = "Clear html-dynamic",
    data = {
      sSearchPat = [[\<((script)|(noscript)|(form)) .*? \<\/\1\>]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Удаление объектов из html",
    name = "Clear html-objects",
    data = {
      sSearchPat = [[\<(object) .*? \<\/\1\>]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Удаление ссылки на djv‑разделы",
    name = "Delete djv-anchors",
    data = {
      sSearchPat = [[\<((script)|(noscript)|(form)) .*? \<\/\1\>]],
      sReplacePat = [[]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Основные тэги строчными буквами",
    name = "Main tags as lower",
    data = {
      sSearchPat = [[(\<\/? ( P|H\d|A|B|I|BR|SUB|SUP|FONT|SPAN|TH|TR|TD|HR|PRE|IMG|BLOCKQUOTE ) ( (\s)|(\>) ))]],
      sReplacePat = [[\L$1\E]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Остальные тэги строчными буквами",
    name = "Rest tags as lower",
    data = {
      sSearchPat = [[(\<\/? ( UL|LI|CENTER|NOBR|TABLE|TBODY|BODY|HEAD|META|TITLE|STYLE|LINK|HTML ) ( (\s)|(\>) ))]],
      sReplacePat = [[\L$1\E]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Замена числовых мнемоник символами",
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
    text = "&  — Добавление ссылки на sup‑ссылку",
    name = "Add href to sup-note",
    data = {
      sSearchPat = [[(\<sup\>)(\d+)(\<\/sup\>)]],
      sReplacePat = [[$1<a href="#Note_$2">$2</a>$3]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Замена sup‑ссылки на sup‑якорь",
    name = "Replace sup-href by sup-name",
    data = {
      sSearchPat = [[a href="#Note_]],
      sReplacePat = [[a name="Note_]],
      bRegExpr = false,
    },
  },
  { template = "html",
    text = "&  — Выравнивание sup‑ссылки",
    name = "Align sup-href",
    data = {
      sSearchPat = [[(href="\#Note_)(\d)("\>)]],
      sReplacePat = [[$10$2]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Закрывающие теги перед пробелом",
    name = "Closed tags before space",
    data = {
      sSearchPat = [[ (\<\/[bi]\>)]],
      sReplacePat = [[$1 ]],
      bExtended = true,
    },
  },
  { template = "html",
    text = "&  — Закрывающие теги перед знаком",
    name = "Closed tags before signs",
    data = {
      sSearchPat = [[([\.\,\:\;\!\?])(\<\/[bi]\>)]],
      sReplacePat = [[$2$1]],
      bExtended = true,
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
    text = "&N — Новая строка после DSRT",
    name = "New line style after DSRT",
    data = {
      sSearchPat = [[\\n]],
      sReplacePat = [[\\N ]],
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
  -- [[
  { template = "separator",
    text = "Lua User Menu",
    name = "lum",
  },--]]
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
  --[=[
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
} --- Presets

---------------------------------------- Data
local Data = {}

do
  -- Обеспечение уникальности:
  local NameChecks = {} -- имён предустановок (пресетов)
  local HotChars = { true, true, true, true, } -- горячих букв-клавиш
  local sNameFmt = "%s: %s"
  local sTextFmt = "%s %s"
  local sNameError    = "Unique name required for:\nname=%s\ntext=%s"
  local sHotCharError = "Unique hot char required for:\nname=%s\ntext=%s"

  for k = 1, #Presets do
    local Preset = Presets[k]

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
    end

    -- Подготовка предустановки:
    expand(Preset, Templates[Tmpl] or Templates.default)
    if Tmpl == "separator" then
    --if Preset.template == "separator" and not Text:find("^%:sep%:") then
      Preset.text = ":sep:"..Text
    else
      Preset.text = sTextFmt:format(KindChars[Preset.action], Text)
    end
    Data[#Data + 1] = Preset
  end

end -- do

---------------------------------------- main
do
  local arg = ...
  if type(arg) == 'table' then arg = arg[1] end
  if type(arg) ~= 'string' then arg = '' end
  --far.Show(arg, ...)
  --far.Show(unpack(...))

  local argData
  for k = 1, #Data do
    local t = Data[k]
    if t.name == arg then argData = t end
  end

  if argData then
    --far.Show(argData.action, argData.data.sSearchPat, argData.data.sReplacePat)
    EditorAction(argData.action, argData.data)
  else
    return Data
  end
end -- do
--------------------------------------------------------------------------------
