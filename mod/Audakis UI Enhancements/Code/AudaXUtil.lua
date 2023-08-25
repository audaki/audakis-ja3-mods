
function audaFindXtById(obj, id)
  if (obj.Id or '') == id then
    return obj
  end
  for _, sub in ipairs(obj) do
    local match = audaFindXtById(sub, id)
    if match then
      return match
    end
  end
end

function audaFindXtByTextId(obj, id)
  if obj.Text and TGetID(obj.Text) == id then
    return obj
  end
  for _, sub in ipairs(obj) do
    local match = audaFindXtByTextId(sub, id)
    if match then
      return match
    end
  end
end

function audaFindXtListByTextId(obj, id)
  local matches = {}
  if obj.Text and TGetID(obj.Text) == id then
    return { obj }
  end
  for it1, sub in ipairs(obj) do
    local sub_matches = audaFindXtListByTextId(sub, id)
    for it2, sub_match in ipairs(sub_matches) do
      table.insert(matches, sub_match)
    end
  end
  return matches
end

function audaFindXtByComment(obj, comment)
  if (obj.comment or '') == comment then
    return obj
  end
  for _, sub in ipairs(obj) do
    local match = audaFindXtByComment(sub, comment)
    if match then
      return match
    end
  end
end

function audaFindParentXtByTextId(obj, id)
  if obj.Text and TGetID(obj.Text) == id then
    return obj, true
  end
  for _, sub in ipairs(obj) do
    local match, isDirect = audaFindParentXtByTextId(sub, id)
    if isDirect and match then
      return obj, false
    end
    if match then
      return match, false
    end
  end
end

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




--Zulib = Zulib or {}
--
--Zulib.setupModSlider = function(cfg)
--  if not cfg.modId or not cfg.optionId then
--    return
--  end
--  local mod = Mods[cfg.modId]
--  if not mod then
--    return
--  end
--
--  for _, option in ipairs(mod.GetOptionItems and mod:GetOptionItems()) do
--    if option.name == cfg.optionId then
--      option.GetOptionMeta = function(self)
--        local meta = ModItemOptionNumber.GetOptionMeta(self)
--        if cfg.displayType then
--          meta.valueDisplayType = cfg.displayType
--        end
--        if cfg.displayPostfix then
--          meta.valueDisplayPostfix = cfg.displayPostfix
--        end
--        return meta
--      end
--    end
--  end
--
--
--  for _, meta in ipairs(mod.options and mod.options.properties) do
--    if meta.id == cfg.optionId then
--      if cfg.displayType then
--        meta.valueDisplayType = cfg.displayType
--      end
--      if cfg.displayPostfix then
--        meta.valueDisplayPostfix = cfg.displayPostfix
--      end
--    end
--  end
--end