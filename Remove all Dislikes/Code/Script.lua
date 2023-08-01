

audaHasRemovedAllDislikes = true


function UnitProperties:GetPersonalMorale()
  local teamMorale = self.team and self.team.morale or 0
  local personalMorale = 0
  local isDisliking = false
  --for _, dislikedMerc in ipairs(self.Dislikes) do
  --  local dislikedIndex = table.find(self.team.units, "session_id", dislikedMerc)
  --  if dislikedIndex and not self.team.units[dislikedIndex]:IsDead() then
  --    personalMorale = personalMorale - 1
  --    isDisliking = true
  --    break
  --  end
  --end
  if not isDisliking then
    for _, likedMerc in ipairs(self.Likes) do
      local likedIndex = table.find(self.team.units, "session_id", likedMerc)
      if likedIndex and not self.team.units[likedIndex]:IsDead() then
        personalMorale = personalMorale + 1
        break
      end
    end
  end
  local isWounded = false
  local idx = self:HasStatusEffect("Wounded")
  if idx and self.StatusEffects[idx].stacks >= 3 then
    isWounded = true
  end
  if self.HitPoints < MulDivRound(self.MaxHitPoints, 50, 100) or isWounded then
    if HasPerk(self, "Psycho") then
      personalMorale = personalMorale + 1
    else
      personalMorale = personalMorale - 1
    end
  end
  for _, likedMerc in ipairs(self.Likes) do
    local ud = gv_UnitData[likedMerc]
    if ud and ud.HireStatus == "Dead" then
      local deathDay = ud.HiredUntil
      if deathDay + 7 * const.Scale.day > Game.CampaignTime then
        personalMorale = personalMorale - 1
        break
      end
    end
  end
  if self:HasStatusEffect("ZoophobiaChecked") then
    personalMorale = personalMorale - 1
  end
  if self:HasStatusEffect("ClaustrophobiaChecked") then
    personalMorale = personalMorale - 1
  end
  if self:HasStatusEffect("FriendlyFire") then
    personalMorale = personalMorale - 1
  end
  if self:HasStatusEffect("Conscience_Guilty") then
    personalMorale = personalMorale - 1
  end
  if self:HasStatusEffect("Conscience_Sinful") then
    personalMorale = personalMorale - 2
  end
  if self:HasStatusEffect("Conscience_Proud") then
    personalMorale = personalMorale + 1
  end
  if self:HasStatusEffect("Conscience_Righteous") then
    personalMorale = personalMorale + 2
  end
  return Clamp(personalMorale + teamMorale, -3, 3)
end