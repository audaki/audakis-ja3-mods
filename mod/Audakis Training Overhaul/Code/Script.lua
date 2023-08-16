
-- find text element by ID
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


-- Setup training actions
StatGainingPrerequisites.TrapDisarmExplosives.oncePerMapVisit = false
StatGainingPrerequisites.TrapDisarmMechanical.oncePerMapVisit = false
StatGainingPrerequisites.ResourceDiscovery.oncePerMapVisit = false
StatGainingPrerequisites.TrapDiscovery.oncePerMapVisit = false
StatGainingPrerequisites.ExplosiveMultiHit.failChance = 0


AudaAto = AudaAto or {
  -- TODO: Set this to TRUE on release
  isRelease = true,

  -- 12 hours
  tickLength = 12 * 60 * 60,

  -- sge = Stat Gaining (Points) Extra
  -- sgeGainMod = "Train Boost Gain Modifier"
  sgeGainMod = 50,

  sectorTrainingStatCap = 80,

  applyOptions = function(self)
    local s = CurrentModOptions.audaAtoSgeGainMod or '100%'
    self.sgeGainMod = tonumber(string.sub(s, 1, (string.find(s, '%%') - 1)))

    s = CurrentModOptions.audaAtoSectorTrainStatCap or '80'
    self.sectorTrainingStatCap = tonumber(string.sub(s, 1, 3))
  end,

  statNames = {
    'Health', 'Agility', 'Dexterity', 'Strength', 'Wisdom',
    'Leadership', 'Marksmanship', 'Mechanical', 'Explosives', 'Medical',
  },

  wisdomDependentStatNames = {
    'Leadership', 'Marksmanship', 'Mechanical', 'Explosives', 'Medical',
  },
  
  randCd = function(self, stat, minTicks, maxTicks)
    minTicks = minTicks or 15
    maxTicks = maxTicks or 30
    local cd = InteractionRandRange(minTicks * self.tickLength, maxTicks * self.tickLength, "StatCooldown")
    local cdMod = MulDivRound(Clamp(stat, 40, 97), 175, 100)
    cd = MulDivRound(cd, cdMod, 100)
    return cd
  end,

  randomCooldownsToUnit = function(self, unit_data)
    local sgData = GetMercStateFlag(unit_data.session_id, "StatGaining") or {}
    if not sgData.Cooldowns then
      sgData.Cooldowns = {}
    end

    for _, statName in ipairs(self.statNames) do
      sgData.Cooldowns[statName] = Game.CampaignTime + self:randCd(unit_data[statName] or 60, 5)
    end

    SetMercStateFlag(unit_data.session_id, "StatGaining", sgData)
  end,
}

function OnMsg.ModsReloaded()
  AudaAto:applyOptions()
end

function OnMsg.ApplyModOptions()
  AudaAto:applyOptions()
end


function RollForStatGaining(unit, stat, failChance)
  if unit[stat] <= 0 or unit[stat] >= 100 then
    return
  end

  local statAbbr = ''
  if stat == 'Health' then
    statAbbr = 'HLT'
  elseif stat == 'Agility' then
    statAbbr = 'AGI'
  elseif stat == 'Dexterity' then
    statAbbr = 'DEX'
  elseif stat == 'Strength' then
    statAbbr = 'STR'
  elseif stat == 'Wisdom' then
    statAbbr = 'WIS'
  elseif stat == 'Leadership' then
    statAbbr = 'LDR'
  elseif stat == 'Marksmanship' then
    statAbbr = 'MRK'
  elseif stat == 'Mechanical' then
    statAbbr = 'MEC'
  elseif stat == 'Explosives' then
    statAbbr = 'EXP'
  elseif stat == 'Medical' then
    statAbbr = 'MED'
  end

  local statBefore = unit[stat]

  local sgData = GetMercStateFlag(unit.session_id, "StatGaining") or {}
  local prefix = 'FAIL'
  local reason_text = ""
  sgData.Cooldowns = sgData.Cooldowns or {}
  local cooldowns = sgData.Cooldowns

  local extraFailRoll = InteractionRand(100, "StatGaining")
  if failChance and extraFailRoll < failChance then
    reason_text = 'CtF: ' .. failChance .. '%'
    goto statGainNope
  end

  if cooldowns[stat] and cooldowns[stat] > Game.CampaignTime then
    prefix = 'CD'
    reason_text = 'roll CD'

    if cooldowns[stat] then
      cooldowns[stat] = Max(cooldowns[stat] - AudaAto.tickLength, Game.CampaignTime)
    end

    goto statGainNope
  end


  if true then

    local bonusToRoll = 4
    
    -- 0 to 3
    local wisdomBonus = (Clamp(unit.Wisdom, 55, 100) - 55) / 15
    local thresholdDiffDiv = 180

    if stat == 'Health' then
      bonusToRoll = bonusToRoll + 3
    elseif stat == 'Agility' then
      bonusToRoll = bonusToRoll
    elseif stat == 'Dexterity' then
      bonusToRoll = bonusToRoll + 3
    elseif stat == 'Strength' then
      bonusToRoll = bonusToRoll + 5
    elseif stat == 'Wisdom' then
      bonusToRoll = bonusToRoll
      thresholdDiffDiv = 155
    elseif stat == 'Leadership' then
      bonusToRoll = bonusToRoll + wisdomBonus + 3
      thresholdDiffDiv = 400 + wisdomBonus * 50
    elseif stat == 'Marksmanship' then
      bonusToRoll = bonusToRoll + wisdomBonus + 3
      thresholdDiffDiv = 400 + wisdomBonus * 50
    elseif stat == 'Mechanical' then
      bonusToRoll = bonusToRoll + wisdomBonus + 3
      thresholdDiffDiv = 250 + wisdomBonus * 25
    elseif stat == 'Explosives' then
      bonusToRoll = bonusToRoll + wisdomBonus + 3
      thresholdDiffDiv = 250 + wisdomBonus * 25
    elseif stat == 'Medical' then
      bonusToRoll = bonusToRoll + wisdomBonus + 3
      thresholdDiffDiv = 250 + wisdomBonus * 25
    end

    local thresholdBase = Clamp(unit[stat], 70, 99)
    local thresholdAdd = MulDivRound(99 - thresholdBase, 100, thresholdDiffDiv)
    local threshold = thresholdBase + thresholdAdd - bonusToRoll
    local roll = InteractionRand(100, "StatGaining")
    --reason_text = 'Need: ' .. threshold .. ' (' .. thresholdBase .. '+' .. thresholdAdd .. '-' .. bonusToRoll .. '), Chance: ' .. (100 - threshold) .. '%, Roll: ' .. roll
    reason_text = T({ 'CtR: <chance>%', chance = 99 - threshold })
    if roll >= threshold then
      GainStat(unit, stat)
      cooldowns[stat] = Game.CampaignTime + AudaAto:randCd(statBefore)
      prefix = 'WIN'
    else
      prefix = 'MISS'
    end
  end

  ::statGainNope::

  if statBefore <= 99 then
    CombatLog(AudaAto.isRelease and "debug" or "important", T({
      'SG:<prefix> <nick> <statAbbr>(<statBefore>) <reason>',
      prefix = prefix,
      nick = unit.Nick or 'Merc',
      statAbbr = statAbbr,
      statBefore = statBefore,
      reason = reason_text,
    }))
  end

  SetMercStateFlag(unit.session_id, "StatGaining", sgData)
end



function ReceiveStatGainingPoints(unit, xpGain)
  if HasPerk(unit, "OldDog") then
    return
  end

  --local calcXpThresholds = function(level)
  --  local out = {}
  --  local pointsForLevel = floatfloor(1 + Clamp(level - 1, 0, 8) / 2)
  --  local interval = 1000 / pointsForLevel
  --  for i = 1, pointsForLevel - 1 do
  --    out[#out + 1] = (out[#out] or 0) + interval
  --  end
  --  out[#out + 1] = 1000
  --  return out
  --end

  --local xp = unit.Experience or 0
  --local xpPercent, level = CalcXpPercentAndLevel(xp)
  local pointsToGain = 0
  local sgp = unit.statGainingPoints or 0
  local wis = unit.Wisdom or 50

  if 0 < xpGain then

    local sgData = GetMercStateFlag(unit.session_id, "StatGaining")
    if sgData and sgData.Cooldowns then
      for _, key in ipairs(table.keys(sgData.Cooldowns)) do
        sgData.Cooldowns[key] = Max(sgData.Cooldowns[key] - AudaAto.tickLength, Game.CampaignTime)
      end
      SetMercStateFlag(unit.session_id, "StatGaining", sgData)
    end

    local sgeIncrease = 200 + MulDivRound(wis, 100, 100)
    sgeIncrease = MulDivRound(sgeIncrease, AudaAto.sgeGainMod, 100)
    if sgp <= 4 then
      local minBoost = MulDivRound(sgeIncrease, 25, 100)
      local maxBoost = MulDivRound(sgeIncrease, 50, 100)
      local sgeBoost = InteractionRandRange(minBoost, maxBoost, 'StatGainingExtra')
      if sgp == 1 then
        sgeBoost = MulDivRound(sgeBoost, 80, 100)
      elseif sgp == 2 then
        sgeBoost = MulDivRound(sgeBoost, 60, 100)
      elseif sgp == 3 then
        sgeBoost = MulDivRound(sgeBoost, 40, 100)
      elseif sgp == 4 then
        sgeBoost = MulDivRound(sgeBoost, 20, 100)
      end
      sgeIncrease = sgeIncrease + sgeBoost
    elseif sgp <= 9 then
      -- base
    elseif sgp <= 13 then
      sgeIncrease = MulDivRound(sgeIncrease, 90, 100)
    elseif sgp <= 17 then
      sgeIncrease = MulDivRound(sgeIncrease, 80, 100)
    elseif sgp <= 20 then
      sgeIncrease = MulDivRound(sgeIncrease, 60, 100)
    elseif sgp <= 22 then
      sgeIncrease = MulDivRound(sgeIncrease, 40, 100)
    else
      sgeIncrease = MulDivRound(sgeIncrease, 20, 100)
    end

    --CombatLog(AudaAto.isRelease and "debug" or "important", T { "<nick>.sge = <sge> + <sgeIncrease>", nick = unit.Nick or 'Merc', sge = unit.statGainingPointsExtra, sgeIncrease = sgeIncrease })
    unit.statGainingPointsExtra = floatfloor((unit.statGainingPointsExtra or 0) + sgeIncrease + 0.5)
  end

  while unit.statGainingPointsExtra >= 10000 do
    CombatLog(AudaAto.isRelease and "debug" or "important", T { "<nick> +1 Train Boost (sge)", nick = unit.Nick or 'Merc' })
    unit.statGainingPointsExtra = Max(0, unit.statGainingPointsExtra - 10000)
    pointsToGain = pointsToGain + 1
  end

  --while level < #XPTable and 0 < xpGain do
  --  local xpThresholds = calcXpThresholds(level)
  --  local tempXp = Min(xpGain, XPTable[level + 1] - XPTable[level])
  --  xp = xp + tempXp
  --  xpGain = xpGain - tempXp
  --  local newXpPercent, newLevel = CalcXpPercentAndLevel(xp)
  --  if level < newLevel then
  --    newXpPercent = 1000
  --  end
  --  for i = 1, #xpThresholds do
  --    if xpPercent < xpThresholds[i] and newXpPercent >= xpThresholds[i] then
  --      CombatLog(AudaAto.isRelease and "debug" or "important", T { "<nick> +1 Train Boost (threshold)", nick = unit.Nick or 'Merc' })
  --      pointsToGain = pointsToGain + 1
  --    end
  --  end
  --  level = newLevel
  --  xpPercent = 0
  --end
  --if level == #XPTable and 0 < xpGain then
  --  local xpSinceLastMilestone = xp - XPTable[#XPTable]
  --  local milestone = const.StatGaining.MilestoneAfterMax
  --  local increment = const.StatGaining.MilestoneAfterMaxIncrement
  --  while xpSinceLastMilestone >= milestone do
  --    xpSinceLastMilestone = xpSinceLastMilestone - milestone
  --    milestone = milestone + increment
  --  end
  --  while 0 < xpGain do
  --    local xpToMilestone = milestone - xpSinceLastMilestone
  --    local tempXp = Min(xpGain, xpToMilestone)
  --    xp = xp + tempXp
  --    xpGain = xpGain - tempXp
  --    if xpToMilestone <= tempXp then
  --      CombatLog(AudaAto.isRelease and "debug" or "important", T { "<nick> +1 Train Boost (milestone)", nick = unit.Nick or 'Merc' })
  --      pointsToGain = pointsToGain + 1
  --      xpSinceLastMilestone = 0
  --      milestone = milestone + increment
  --    end
  --  end
  --end
  --
  --if pointsToGain >= 1 then
  --  CombatLog(AudaAto.isRelease and "debug" or "important", T { "<nick> gaining <points> Train Points", nick = unit.Nick or 'Merc', points = pointsToGain })
  --end

  unit.statGainingPoints = unit.statGainingPoints + pointsToGain
end



-- Add random cooldowns on merc hire
function OnMsg.MercHireStatusChanged(unit_data, previousState, newState)
  if newState == "Hired" and previousState ~= newState then

    AudaAto:randomCooldownsToUnit(unit_data)

    if unit_data.statGainingPointsExtra == 0 then
      unit_data.statGainingPointsExtra = InteractionRandRange(1, 4242, 'StatGainingExtra')
    end

  end
end



for _, param in ipairs(SectorOperations.TrainMercs.Parameters) do
  if param.Name == 'ActivityDurationInHoursFull' then
    param.Value = 24
  end
end
g_PresetParamCache[SectorOperations.TrainMercs]['ActivityDurationInHoursFull'] = 24


SectorOperations.TrainMercs.ProgressPerTick = function (self, merc, prediction)
  local progressPerTick = self:ResolveValue("PerTickProgress")
  if CheatEnabled("FastActivity") then
    progressPerTick = progressPerTick*100
  end
  return progressPerTick
end


SectorOperations.TrainMercs.Tick = function(self, merc)
  --Learning speed parameter defines the treshold of how much must be gained to gain 1 in a stat. Bigger number means slower.
  local sector = merc:GetSector()
  local stat = sector.training_stat
  if self:ProgressCurrent(merc, sector) >= self:ProgressCompleteThreshold(merc, sector) then
    return
  end
  if merc.OperationProfession == "Student" then
    local teachers = GetOperationProfessionals(sector.Id, self.id, "Teacher")
    local teacher = teachers[1]
    if not teacher then
      return
    end
  else
    -- teacher
    local students = GetOperationProfessionals(sector.Id, self.id, "Student")
    local t_stat = merc[stat]
    for _, student in ipairs(students) do
      local is_learned_max = student[stat] >= t_stat or student[stat] >= AudaAto.sectorTrainingStatCap
      if not is_learned_max then
        student.stat_learning = student.stat_learning or {}

        local progressPerTick = MulDivRound(t_stat, 100 + merc.Leadership, 100) + self:ResolveValue("learning_base_bonus")
        if HasPerk(merc, "Teacher") then
          local bonusPercent = CharacterEffectDefs.Teacher:ResolveValue("MercTrainingBonus")
          progressPerTick = progressPerTick + MulDivRound(progressPerTick, bonusPercent, 100)
        end


        if #students >= 2 then
          progressPerTick = MulDivRound(progressPerTick, 100, 100 + 15 * (#students - 1))
        end

        if student.statGainingPoints == 0 then
          progressPerTick = MulDivRound(progressPerTick, 100, 1000)
        else
          progressPerTick = MulDivRound(progressPerTick, 1000, 100)
        end

        -- Ensure minimum progress
        progressPerTick = Max(5, progressPerTick)

        student.stat_learning[stat] = student.stat_learning[stat] or { progress = 0, up_levels = 0 }
        local learning_progress = student.stat_learning[stat].progress
        learning_progress = learning_progress + progressPerTick

        local progress_threshold = 250 * student[stat] * (150 - Max(80, (student.Wisdom - 50) * 2)) / 100

        if student[stat] >= (AudaAto.sectorTrainingStatCap - 20) then
          progress_threshold = MulDivRound(progress_threshold, 100 + 5 * (student[stat] - (AudaAto.sectorTrainingStatCap - 21)), 100)
        end

        if learning_progress >= progress_threshold then

          student.statGainingPoints = Max(0, student.statGainingPoints - 1)

          local gainAmount = 1
          local modId = string.format("StatTraining-%s-%s-%d", stat, student.session_id, GetPreciseTicks())
          GainStat(student, stat, gainAmount, modId, "Training")

          PlayVoiceResponse(student, "TrainingReceived")
          --CombatLog("important",T{424323552240, "<merc_nickname> gained +1 <stat_name> from training in <sector_id>", stat_name = stat_name, merc_nickname  =  student.Nick, sector_id = Untranslated(sector.Id)})
          learning_progress = 0
          student.stat_learning[stat].up_levels = student.stat_learning[stat].up_levels + 1
        end
        student.stat_learning[stat].progress = learning_progress
      end
    end
  end
  local students = GetOperationProfessionals(sector.Id, self.id, "Student")
  if not next(students) then
    --	self:Complete(sector)
    return
  end
end

local hasExtraStatGainProperty = false
for _, prop in ipairs(UnitProperties.properties) do
  if prop.id == 'statGainingPointsExtra' then
    hasExtraStatGainProperty = true
  end
end

if not hasExtraStatGainProperty then
  UnitProperties.properties[#UnitProperties.properties + 1] = {
    category = "XP",
    id = "statGainingPointsExtra",
    editor = "number",
    default = 0,
  }
end

local mercRolloverAttrsXt = audaFindXtByTextId(XTemplates.PDAMercRollover, 488971610056)
if mercRolloverAttrsXt then
  mercRolloverAttrsXt.ContextUpdateOnOpen = true
  mercRolloverAttrsXt.OnContextUpdate = function(self, context, ...)
    local sgp = context.statGainingPoints or 0
    local postfix = ''
    if sgp <= 4 then
      postfix = '<scale 400><color PDASectorInfo_Yellow><alpha ' .. 90 + (20 * (4 - sgp))
      postfix = postfix .. '><valign top 8> increased gain</alpha></color>'
    end
    self:SetText(T(488971610056, "ATTRIBUTES") ..
        T({ ' | <scale 850><style CrosshairAPTotal><sgp> TRAIN BOOST<plural></style><postfix>',
            sgp = sgp and ('+' .. sgp) or 'NO',
            plural = sgp == 1 and '' or 'S',
            postfix = postfix }))
    return XContextControl.OnContextUpdate(self, context)
  end
end