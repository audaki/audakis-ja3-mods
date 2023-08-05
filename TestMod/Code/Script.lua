TextStyles.ConsoleLog.TextFont = 'droid, 10, bold'

if not origConsolePrint then
  origConsolePrint = ConsolePrint
end

g_audaBufferSize = 2048

function ConsolePrint(text)
  text = text or ''

  local lines = {}
  for line in text:gmatch('[^\r\n]+') do
    lines[#lines + 1] = line
  end

  local buffer = ''
  for _, line in ipairs(lines) do
    if #line >= 1 then
      if #buffer + #line + 1 < g_audaBufferSize then
        if #buffer >= 1 then
          buffer = buffer .. '\n' .. line
        else
          buffer = line
        end
      else
        origConsolePrint(buffer)
        buffer = line
      end
    end
  end

  if #buffer >= 1 then
    origConsolePrint(buffer)
  end
end

print = CreatePrint({''})



CurrentModOptions.properties[1].Test = 42

function audaFindXtByName(obj, name)
  if (obj.name or '') == name then
    return obj
  end
  for _, sub in ipairs(obj) do
    local match = audaFindXtByName(sub, name)
    if match then
      return match
    end
  end
end

local xtMoveThumbFunc = audaFindXtByName(XTemplates.PropNumber, 'MoveThumb')


if xtMoveThumbFunc then
  if not xtMoveThumbFunc.origFunc then
    xtMoveThumbFunc.origFunc = xtMoveThumbFunc.func
  end
  xtMoveThumbFunc.func = function(self, ...)
    xtMoveThumbFunc.origFunc(self, ...)

    local idName = self.parent and self.parent.idName or nil
    if idName then
      local max = self.Max
      if max == 0 then
        max = 100
      end
      local scroll = self.Scroll
      local percent = floatfloor(1000 * scroll / max) / 10.0

      local meta = self.prop_meta or {}
      local name = self.prop_meta.name or self.prop_meta.id
      local propMetaId = meta.id or meta.name or ''
      local valueDisplayType = 'percent'


      valueDisplayType = meta.valueDisplayType or valueDisplayType



      if valueDisplayType == 'showAll' then
        idName:SetText(T{
          '<name>: <scroll><valign top 3><scale 600>/<max> (<percent>%)',
          name = name,
          scroll = scroll,
          max = max,
          percent = percent
        })
      elseif valueDisplayType == 'percent' then
        idName:SetText(T{
          '<name>: <percent>%',
          name = name,
          percent = percent
        })
      elseif valueDisplayType == 'numberWithMax' then
        idName:SetText(T{
          '<name>: <scroll><valign top 3><scale 600>/<max>',
          name = name,
          scroll = scroll,
          max = max,
        })
      elseif valueDisplayType == 'number' then
        idName:SetText(T{
          '<name>: <scroll><valign top 3>',
          name = name,
          scroll = scroll,
        })
      elseif valueDisplayType == 'rawPercent' then
        idName:SetText(T{
          '<name>: <scroll>%',
          name = name,
          scroll = scroll,
        })
      end
    end

  end
end