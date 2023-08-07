
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
      local value = self.Scroll
      local percent = floatfloor(1000 * value / max) / 10.0

      local meta = self.prop_meta or {}
      local name = self.prop_meta.name or self.prop_meta.id or ''
      local displayType = 'percent'
      local postfix = ''


      displayType = meta.valueDisplayType or displayType
      postfix = meta.valueDisplayPostfix or postfix


      if displayType == 'showAll' then
        idName:SetText(T{
          '<name>: <value><postfix><valign top 3><scale 600>/<max><postfix> (<percent>%)',
          name = name,
          value = value,
          max = max,
          percent = percent,
          postfix = postfix,
        })
      elseif displayType == 'percent' then
        idName:SetText(T{
          '<name>: <percent>%',
          name = name,
          percent = percent,
        })
      elseif displayType == 'value' then
        idName:SetText(T{
          '<name>: <value><postfix>',
          name = name,
          value = value,
          postfix = postfix,
        })
      elseif displayType == 'valueWithMax' then
        idName:SetText(T{
          '<name>: <value><postfix><valign top 3><scale 600>/<max><postfix>',
          name = name,
          value = value,
          max = max,
          postfix = postfix,
        })
      end
    end

  end
end