



local hasAudaIsSpecialSuspiciousProperty = false
for _, prop in ipairs(UnitProperties.properties) do
  if prop.id == 'audaIsSpecialSuspicious' then
    hasAudaIsSpecialSuspiciousProperty = true
  end
end

if not hasAudaIsSpecialSuspiciousProperty then
  UnitProperties.properties[#UnitProperties.properties + 1] = {
    category = "AI",
    id = "audaIsSpecialSuspicious",
    editor = 'bool',
    default = false,
  }
end




function Combat:ShouldEndDueToNoVisibility()

  if Game and Game.game_type == "PvP" then
    return
  end
  local any_visibility
  for _, t in ipairs(g_Teams) do
    if g_Visibility[t] and #g_Visibility[t] > 0 then
      for i, tt in ipairs(g_Teams) do

        if t:IsEnemySide(tt) and g_Visibility[tt] and #g_Visibility[tt] > 0 then

          for _, visUnit in ipairs(g_Visibility[tt]) do
            if visUnit.team and visUnit.team == t then
              any_visibility = true
              break
            end
          end

          if any_visibility then
            break
          end
        end
        if any_visibility then
          break
        end
      end
      if any_visibility then
        break
      end
    end
  end

  if any_visibility then
    self.turns_no_visibility = 0
  else
    self.turns_no_visibility = self.turns_no_visibility + 1
  end

  local teamCount = 0
  for _, t in ipairs(g_Teams) do
    if #t.units >= 1 then
      teamCount = teamCount + 1
    end
  end

  local isShallEnd = self.turns_no_visibility >= teamCount * 5
  if isShallEnd then

    local p1Team = nil
    for _, t in ipairs(g_Teams) do
      if t.side == 'player1' then
        p1Team = t
      end
    end
    MapForEach("map", "Unit", function(unit)

      if (unit.team and p1Team and unit.team:IsEnemySide(p1Team)) then

        if unit:IsAware() then
          unit.audaIsSpecialSuspicious = true
        end

        unit:RemoveStatusEffect('Surprised')
        unit:RemoveStatusEffect('Suspicious')
        unit:AddStatusEffect('Unaware')

        unit.pending_aware_state = nil
        unit.alerted_by_enemy = nil
        unit.aware_reason = nil
      end
    end)
  end

  return isShallEnd
end

function OnMsg.PostCombatEnd()
  MapForEach("map", "Unit", function(unit)
    if unit.audaIsSpecialSuspicious then
      unit.pending_aware_state = 'suspicious'
    end
  end)
end



function Unit:SuspiciousRoutine()

  local isSpecialSuspicious = false
  if (self.audaIsSpecialSuspicious) then
    isSpecialSuspicious = true
  end


  local def = CharacterEffectDefs.Suspicious
  Sleep(self:TimeToAngleInterpolationEnd())
  local body = self.suspicious_body_seen and HandleToObject[self.suspicious_body_seen]
  if IsValid(body) then
    self:Face(body, 500)
  end
  local anim = self:TryGetActionAnim("Suspicious", "Standing")
  if anim then
    self:SetState(anim)
  end


  local last_update = GameTime()
  local time = self:GetEffectValue("suspicious_time") or 0
  self:SetEffectValue("suspicious_time", time)

  local grow_time = def:ResolveValue("sight_grow_time")
  local delay_time = def:ResolveValue("max_sight_delay")
  local sight_mod_max = def:ResolveValue("sight_modifier_max")
  local shrink_time = def:ResolveValue("sight_shrink_time")

  if (isSpecialSuspicious) then
    grow_time = 0
    delay_time = 9 * 1000
    shrink_time = 2 * 1000

    -- final sight mod is capped to 120 anyway
    sight_mod_max = 10000
  end

  repeat
    WaitMsg("CombatStarting", 100)
    if g_Combat then
      break
    end
    local time_now = GameTime()
    time = time + time_now - last_update
    last_update = time_now
    self:SetEffectValue("suspicious_time", time)
    local mod
    if grow_time > time then
      mod = MulDivRound(sight_mod_max, time, grow_time)
    elseif time < grow_time + delay_time then
      mod = sight_mod_max
    elseif time < grow_time + delay_time + shrink_time then
      local t = time - grow_time - delay_time
      mod = MulDivRound(sight_mod_max, shrink_time - t, shrink_time)
    else
      mod = nil
    end
    if self:GetEffectValue("suspicious_sight_mod") ~= mod then
      self:SetEffectValue("suspicious_sight_mod", mod)
      InvalidateUnitLOS(self)
    end
  until not mod


  self:SetEffectValue("suspicious_time", nil)
  self.suspicious_body_seen = nil
  self.audaIsSpecialSuspicious = false


  if isSpecialSuspicious then
    self:AddStatusEffect("Unaware")
    return
  end

  if not g_Combat and not g_StartingCombat and self:HasStatusEffect("Suspicious") then

    local enemies = GetAllEnemyUnits(self)
    local mindist
    for _, enemy in ipairs(enemies) do
      if enemy.team and enemy.team.player_team then
        local dist = self:GetDist(enemy)
        mindist = Min(mindist or dist, dist)
      end
    end

    if mindist and mindist < Suspicious:ResolveValue("remain_unaware_min_dist") * guim then
      TriggerUnitAlert("surprise", self, "suspicious")
    else
      self:AddStatusEffect("Unaware")
    end
  end
end