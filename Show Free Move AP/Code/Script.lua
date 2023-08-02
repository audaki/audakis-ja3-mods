
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

XTemplates.PDAMercRollover[1].Margins = box(42, 1, 0, 0)

local mercRolloverApXt = audaFindXtByComment(XTemplates.PDAMercRollover, 'ap indicator')
if mercRolloverApXt then
  mercRolloverApXt.OnContextUpdate = function(self, context, ...)
    local text

    if g_Combat then
      local currentAP = context:GetUIActionPoints()
      local bonus = context.free_move_ap
      local ctx = SubContext(context, {
        current = currentAP,
        bonus = bonus,
      })
      if 1000 <= bonus then
        text = T({
          "<apn(current)><style PDASMLevelTxt>+<apn(bonus)></style>",
          ctx
        })
      else
        text = T({
          263805086279,
          "<apn(current)>",
          ctx
        })
      end
    else
      local maxAP = context:GetMaxActionPoints()
      text = T({
        330002924751,
        "<apn(maxActionPoints)>",
        maxActionPoints = maxAP
      })
    end
    text = text .. " " .. T(363250742550, "<style PDARolloverHeaderDark>AP</style>")
    self:SetText(text)
    XContextControl.OnContextUpdate(self, context)
  end
end

local apDisplays = audaFindXtListByTextId(XTemplates.SquadsAndMercs, 219068997732)
for _, xt in ipairs(apDisplays) do
  xt.OnContextUpdate = function(self, context, ...)
    local text
    if not IsKindOf(context, "Unit") then
      return
    end
    self.parent:SetVisible(not not g_Combat and not context:IsDead() and not context:IsDowned())

    if g_Combat then
      self.parent.MinWidth = 39
      self.parent.MaxWidth = 49
      local currentAP = context:GetUIActionPoints()
      local bonus = context.free_move_ap
      local ctx = SubContext(context, {
        current = currentAP,
        bonus = bonus,
      })
      if 1000 <= bonus then
        text = T({
          "<apn(current)><style PDASM_NewSquadLabel>+<apn(bonus)></style>",
          ctx
        })
      else
        text = T({
          263805086279,
          "<apn(current)>",
          ctx
        })
      end
    else
      self.parent.MinWidth = 30
      self.parent.MaxWidth = 30
      local maxAP = context:GetMaxActionPoints()
      text = T({
        330002924751,
        "<apn(maxActionPoints)>",
        maxActionPoints = maxAP
      })
    end

    self:SetText(text)
    XContextControl.OnContextUpdate(self, context)
  end
end