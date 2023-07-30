StatGainingPrerequisites.TrapDisarmExplosives.oncePerMapVisit = false
StatGainingPrerequisites.TrapDisarmMechanical.oncePerMapVisit = false
StatGainingPrerequisites.ResourceDiscovery.oncePerMapVisit = false
StatGainingPrerequisites.TrapDiscovery.oncePerMapVisit = false

StatGainingPrerequisites.ExplosiveMultiHit.failChance = 0

const.StatGaining.PointsPerLevel = 3
const.StatGaining.MilestoneAfterMax = 666
const.StatGaining.BonusToRoll = 15

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

function RollForStatGaining(unit, stat, failChance)
  local statGaining = GetMercStateFlag(unit.session_id, "StatGaining") or {}
  local cooldowns = statGaining.Cooldowns or {}
  local success_text = "(fail) "
  local reason_text = ""
  local extraFailRoll = InteractionRand(100, "StatGaining")
  if not failChance or failChance <= extraFailRoll then
    if unit.statGainingPoints >= 1 then
      if not cooldowns[stat] or cooldowns[stat] <= Game.CampaignTime then
        if 0 < unit[stat] and unit[stat] < 100 then

          local bonusToRoll = 0

          if stat == 'Health' then
            bonusToRoll = bonusToRoll + 12
          elseif stat == 'Agility' then
            bonusToRoll = bonusToRoll + 7
          elseif stat == 'Dexterity' then
            bonusToRoll = bonusToRoll + 12
          elseif stat == 'Strength' then
            bonusToRoll = bonusToRoll + 12
          elseif stat == 'Wisdom' then
            bonusToRoll = bonusToRoll + 7
          elseif stat == 'Leadership' then
            bonusToRoll = bonusToRoll + 25
          elseif stat == 'Marksmanship' then
            bonusToRoll = bonusToRoll + 35
          elseif stat == 'Mechanical' then
            bonusToRoll = bonusToRoll + 25
          elseif stat == 'Explosives' then
            bonusToRoll = bonusToRoll + 25
          elseif stat == 'Medical' then
            bonusToRoll = bonusToRoll + 25
          end

          local thresholdAdd = (100 - unit[stat]) // 2.5
          local thresholdBase = unit[stat]
          local threshold = thresholdBase + thresholdAdd
          local rollBase = InteractionRand(100, "StatGaining") + 1
          local roll = rollBase + bonusToRoll
          reason_text = 'Need: ' .. threshold .. '(' .. thresholdBase .. ' + ' .. thresholdAdd  .. '), Rolled: ' .. roll .. ' (' .. rollBase .. ' + ' .. bonusToRoll .. ')'
          if threshold <= roll then
            GainStat(unit, stat)
            unit.statGainingPoints = unit.statGainingPoints - 1
            local cd = InteractionRandRange(const.StatGaining.PerStatCDMin, const.StatGaining.PerStatCDMax, "StatCooldown")
            cooldowns[stat] = Game.CampaignTime + cd
            statGaining.Cooldowns = cooldowns
            success_text = "(success) "
          end
        else
          reason_text = stat .. " is " .. unit[stat]
        end
      else
        reason_text = stat .. " is in cooldown"
      end
    else
      reason_text = "Not enough milestone points"
    end
  else
    reason_text = "Fail chance procced, need: " .. failChance .. ", Rolled: " .. extraFailRoll
  end

  -- TODO: this go debug again
  CombatLog("Important", success_text .. _InternalTranslate(unit.Nick) .. " stat gain " .. stat .. ". " .. reason_text)
  --CombatLog("debug", success_text .. _InternalTranslate(unit.Nick) .. " stat gain " .. stat .. ". " .. reason_text)

  SetMercStateFlag(unit.session_id, "StatGaining", statGaining)
end

function ReceiveStatGainingPoints(unit, xpGain)
  if HasPerk(unit, "OldDog") then
    return
  end

  local calcXpThresholds = function(level)
    local out = {}
    local pointsForLevel = const.StatGaining.PointsPerLevel + Clamp(level, 1, 9)
    local interval = 1000 // pointsForLevel
    for i = 1, pointsForLevel - 1 do
      out[#out + 1] = (out[#out] or 0) + interval
    end
    out[#out + 1] = 1000
    return out
  end

  local xp = unit.Experience
  local xpPercent, level = CalcXpPercentAndLevel(xp)
  local pointsToGain = 0

  if 0 < xpGain then
    unit.statGainingPointsExtra = (unit.statGainingPointsExtra or 0) + 1000 + (10 * unit['Wisdom'])
    CombatLog("debug", T { 0, "<merc_name>.statGainingPointsExtra = <extra_points>", merc_name = unit.Nick, extra_points = unit.statGainingPointsExtra })
  end

  if unit.statGainingPointsExtra >= 10000 then
    CombatLog("debug", T { 0, "<merc_name> got extra Train Point for statGainingPointsExtra", merc_name = unit.Nick })
    unit.statGainingPointsExtra = Max(0, unit.statGainingPointsExtra - 10000)
    pointsToGain = pointsToGain + 1
  end

  while level < #XPTable and 0 < xpGain do
    local xpThresholds = calcXpThresholds(level)
    local tempXp = Min(xpGain, XPTable[level + 1] - XPTable[level])
    xp = xp + tempXp
    xpGain = xpGain - tempXp
    local newXpPercent, newLevel = CalcXpPercentAndLevel(xp)
    if level < newLevel then
      newXpPercent = 1000
    end
    for i = 1, #xpThresholds do
      if xpPercent < xpThresholds[i] and newXpPercent >= xpThresholds[i] then
        CombatLog("debug", T { 0, "<merc_name> got Train Point for XP threshold", merc_name = unit.Nick })
        pointsToGain = pointsToGain + 1
      end
    end
    level = newLevel
    xpPercent = 0
  end
  if level == #XPTable and 0 < xpGain then
    local xpSinceLastMilestone = xp - XPTable[#XPTable]
    local milestone = const.StatGaining.MilestoneAfterMax
    local increment = const.StatGaining.MilestoneAfterMaxIncrement
    while xpSinceLastMilestone >= milestone do
      xpSinceLastMilestone = xpSinceLastMilestone - milestone
      milestone = milestone + increment
    end
    while 0 < xpGain do
      local xpToMilestone = milestone - xpSinceLastMilestone
      local tempXp = Min(xpGain, xpToMilestone)
      xp = xp + tempXp
      xpGain = xpGain - tempXp
      if xpToMilestone <= tempXp then
        CombatLog("debug", T { 0, "<merc_name> got Train Point for XP milestone threshold", merc_name = unit.Nick })
        pointsToGain = pointsToGain + 1
        xpSinceLastMilestone = 0
        milestone = milestone + increment
      end
    end
  end

  local isWellTrained = unit['Health'] >= 88 and
      unit['Agility'] >= 88 and
      unit['Dexterity'] >= 88 and
      unit['Strength'] >= 88 and
      unit['Wisdom'] >= 88 and
      unit['Leadership'] >= 88 and
      unit['Marksmanship'] >= 88 and
      unit['Mechanical'] >= 88 and
      unit['Explosives'] >= 88 and
      unit['Medical'] >= 88


  local teamSize = unit.team and unit.team.units and #unit.team.units or 1
  if unit.statGainingPoints < 30 and (unit.statGainingPoints + pointsToGain) >= 30 and teamSize >= 2 and not isWellTrained then
    if not unit.statGainingNotified and CurrentModOptions['ttsj_showTrainingReadyNotification'] then
      CombatLog("important", T { 0, "<merc_name> has seen a lot of action and will greatly profit from Training now.", merc_name = unit.Nick })
      unit.statGainingNotified = true
    end
  end


  if pointsToGain >= 1 then
    CombatLog("debug", T { 0, "<merc_name> gaining <points> Train Points", merc_name = unit.Nick, points = pointsToGain })
  end
  unit.statGainingPoints = Min(30, unit.statGainingPoints + pointsToGain)
end

SectorOperations.TrainMercs.Tick = function(self, merc)
  --Learning speed parameter defines the treshold of how much must be gained to gain 1 in a stat. Bigger number means slower.
  local sector = merc:GetSector()
  local stat = sector.training_stat
  if self:ProgressCurrent(merc, sector) >= self:ProgressCompleteThreshold(merc, sector) then
    return
  end
  local max_learned_stat = self:ResolveValue("max_learned_stat")
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
      student.statGainingNotified = false
      local is_learned_max = student[stat] >= t_stat or student[stat] > max_learned_stat
      if not is_learned_max then
        student.stat_learning = student.stat_learning or {}

        local progressPerTick = MulDivRound(t_stat, 100 + merc.Leadership, 100) + self:ResolveValue("learning_base_bonus")
        if HasPerk(merc, "Teacher") then
          local bonusPercent = CharacterEffectDefs.Teacher:ResolveValue("MercTrainingBonus")
          progressPerTick = progressPerTick + MulDivRound(progressPerTick, bonusPercent, 100)
        end

        if student.statGainingPoints == 0 then
          progressPerTick = 1 + progressPerTick // 20
          if not student.stat_learning[stat] or student.stat_learning[stat].progress == 0 or InteractionRand(100) <= 1 then
            if CurrentModOptions['ttsj_showTrainingIneffectiveNotification'] then
              CombatLog("important", T { 0, "<merc_nickname> is bored and needs to see action (earn XP). Training is only worth 5% now. (Not Enough Train Points)", merc_nickname = student.Nick })
            end
          end
        end

        student.stat_learning[stat] = student.stat_learning[stat] or { progress = 0, up_levels = 0 }
        local learning_progress = student.stat_learning[stat].progress
        learning_progress = learning_progress + progressPerTick

        local progress_threshold = self:ResolveValue("learning_speed") * student[stat] * (100 + self:ResolveValue("wisdow_weight") - Max(0, (student.Wisdom - 50) * 2)) / 100
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
local hasStatGainNotifiedProperty = false
for _, prop in ipairs(UnitProperties.properties) do
  if prop.id == 'statGainingPointsExtra' then
    hasExtraStatGainProperty = true
  end
  if prop.id == 'statGainingNotified' then
    hasStatGainNotifiedProperty = true
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

if not hasStatGainNotifiedProperty then
  UnitProperties.properties[#UnitProperties.properties + 1] = {
    category = "XP",
    id = "statGainingNotified",
    editor = "bool",
    default = false,
  }
end

local mercRolloverAttrsXt = audaFindXtByTextId(XTemplates.PDAMercRollover, 488971610056)
if mercRolloverAttrsXt then
  mercRolloverAttrsXt.ContextUpdateOnOpen = true
  mercRolloverAttrsXt.OnContextUpdate = function(self, context, ...)
    self:SetText(T(488971610056, "ATTRIBUTES") .. ' | <style CrosshairAPTotal>Available Train Points ' .. context.statGainingPoints .. ' / 30</style><newline>')
    return XContextControl.OnContextUpdate(self, context)
  end
end