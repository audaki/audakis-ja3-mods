

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

local mercRolloverMoraleXt = audaFindXtByTextId(XTemplates.PDAMercRollover, 258629704073)
if mercRolloverMoraleXt then
  mercRolloverMoraleXt.ContextUpdateOnOpen = true
  mercRolloverMoraleXt.OnContextUpdate = function(self, context, ...)
    local merc = context

    local influences = ''

    local teamMorale = merc.team and merc.team.morale or 0
    local personalMorale = 0
    local isDisliking = false
    for _, dislikedMerc in ipairs(merc.Dislikes) do
      local dislikedIndex = table.find(merc.team.units, "session_id", dislikedMerc)
      if dislikedIndex and not merc.team.units[dislikedIndex]:IsDead() then
        personalMorale = personalMorale - 1
        influences = influences .. '<style InventoryHintTextRed>Dislikes ' .. merc.team.units[dislikedIndex].Nick .. '</style> -1<newline>'
        isDisliking = true
        break
      end
    end


    if not isDisliking then
      for _, likedMerc in ipairs(merc.Likes) do
        local likedIndex = table.find(merc.team.units, "session_id", likedMerc)
        if likedIndex and not merc.team.units[likedIndex]:IsDead() then
          personalMorale = personalMorale + 1
          influences = influences .. '<style InventoryRolloverValuableItemValue>Likes ' .. merc.team.units[likedIndex].Nick .. '</style> +1<newline>'
          break
        end
      end
    end

    local isWounded = false
    local idx = merc:HasStatusEffect("Wounded")
    if idx and merc.StatusEffects[idx].stacks >= 3 then
      isWounded = true
    end
    if merc.HitPoints < MulDivRound(merc.MaxHitPoints, 50, 100) or isWounded then
      if HasPerk(merc, "Psycho") then
        personalMorale = personalMorale + 1
        influences = influences .. '<style InventoryRolloverValuableItemValue>Is Wounded (Psycho)</style> +1<newline>'
      else
        personalMorale = personalMorale - 1
        influences = influences .. '<style InventoryHintTextRed>Is Wounded</style> -1<newline>'
      end
    end
    for _, likedMerc in ipairs(merc.Likes) do
      local ud = gv_UnitData[likedMerc]
      if ud and ud.HireStatus == "Dead" then
        local deathDay = ud.HiredUntil
        if deathDay + 7 * const.Scale.day > Game.CampaignTime then
          personalMorale = personalMorale - 1
          influences = influences .. '<style InventoryHintTextRed>Liked ' .. ud.Nick .. ' is dead</style> -1<newline>'
          break
        end
      end
    end
    if merc:HasStatusEffect("ZoophobiaChecked") then
      personalMorale = personalMorale - 1
      influences = influences .. '<style InventoryHintTextRed>Zoophobia</style> -1<newline>'
    end
    if merc:HasStatusEffect("ClaustrophobiaChecked") then
      personalMorale = personalMorale - 1
      influences = influences .. '<style InventoryHintTextRed>Claustrophobia</style> -1<newline>'
    end
    if merc:HasStatusEffect("FriendlyFire") then
      personalMorale = personalMorale - 1
      influences = influences .. '<style InventoryHintTextRed>FriendlyFire\'d</style> -1<newline>'
    end
    if merc:HasStatusEffect("Conscience_Guilty") then
      personalMorale = personalMorale - 1
      influences = influences .. '<style InventoryHintTextRed>Guilty</style> -1<newline>'
    end
    if merc:HasStatusEffect("Conscience_Sinful") then
      personalMorale = personalMorale - 2
      influences = influences .. '<style InventoryHintTextRed>Sinful</style> -2<newline>'
    end
    if merc:HasStatusEffect("Conscience_Proud") then
      personalMorale = personalMorale + 1
      influences = influences .. '<style InventoryRolloverValuableItemValue>Proud</style> +1<newline>'
    end
    if merc:HasStatusEffect("Conscience_Righteous") then
      personalMorale = personalMorale + 2
      influences = influences .. '<style InventoryRolloverValuableItemValue>Righteous</style> +2<newline>'
    end

    if teamMorale >= 1 then
      influences = influences .. '<style InventoryRolloverValuableItemValue>Team Morale</style> +' .. teamMorale .. '<newline>'
    elseif teamMorale <= -1 then
      influences = influences .. '<style InventoryHintTextRed>Team Morale</style> ' .. teamMorale .. '<newline>'
    end

    --local diff = (personalMorale + teamMorale) - Clamp(personalMorale + teamMorale, -3, 3)
    --if diff >= 1 then
    --  influences = influences .. '(Capped to +3)<newline>'
    --elseif diff <= -1 then
    --  influences = influences .. '(Capped to -3)<newline>'
    --end

    local finalMorale = Clamp(personalMorale + teamMorale, -3, 3)
    if finalMorale == -3 then
      influences = influences .. '= <style PDA_FinancesValueTextRed>Abysmal</style> (-3AP)'
    elseif finalMorale == -2 then
      influences = influences .. '= <style PDA_FinancesValueTextRed>Very Low</style> (-2AP)'
    elseif finalMorale == -1 then
      influences = influences .. '= <style PDA_FinancesValueTextRed>Low</style> (-1AP)'
    elseif finalMorale == 0 then
      influences = influences .. '= Stable'
    elseif finalMorale == 1 then
      influences = influences .. '= <style InventoryRolloverValuableItemValue>High</style> (+1AP)'
    elseif finalMorale == 2 then
      influences = influences .. '= <style InventoryRolloverValuableItemValue>Very High</style> (+2AP)'
    elseif finalMorale == 3 then
      influences = influences .. '= <style InventoryRolloverValuableItemValue>Exceptional</style> (+3AP)'
    end

    --T(258629704073, "Morale<right><style PDABrowserTextLightMedium><MercMoraleText()></style>")

    self:SetText('Morale<right><style PDABrowserTextLightMedium>' .. influences .. '</style>')

    return XContextControl.OnContextUpdate(self, context)
  end
end