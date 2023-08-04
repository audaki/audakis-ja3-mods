StatGainingPrerequisites.TrapDisarmExplosives.oncePerMapVisit = false
StatGainingPrerequisites.TrapDisarmMechanical.oncePerMapVisit = false
StatGainingPrerequisites.ResourceDiscovery.oncePerMapVisit = false
StatGainingPrerequisites.TrapDiscovery.oncePerMapVisit = false

StatGainingPrerequisites.ExplosiveMultiHit.failChance = 0

const.StatGaining.PointsPerLevel = 2
const.StatGaining.MilestoneAfterMax = 666
const.StatGaining.BonusToRoll = 15

  UndefineClass('Loner')
  DefineClass.Loner = {
    __parents = { "Perk" },
    __generated_by_class = "ModItemCharacterEffectCompositeDef",

    __copy_group = "Quirk",
    object_class = "Perk",
    msg_reactions = {
      PlaceObj('MsgReaction', {
        Event = "TurnStart",
        Handler = function (self, team)
          local reaction_idx = table.find(self.msg_reactions or empty_table, "Event", "TurnStart")
          if not reaction_idx then return end

          local function exec(self, team)
            for _, unit in ipairs(g_Units) do
              if unit.team == team and HasPerk(unit, self.id) then
                local proc = true
                for _, other in ipairs(unit.team.units) do
                  if unit ~= other and DivRound(unit:GetDist(other), const.SlabSizeX) <= self:ResolveValue("loner_radius") then
                    proc = false
                    break
                  end
                end

                if proc then
                  unit:AddStatusEffect("Inspired")
                  PlayVoiceResponse(unit, "Loner")
                end
              end
            end
          end
          local id = GetCharacterEffectId(self)

          if id then
            local objs = {}
            for session_id, data in pairs(gv_UnitData) do
              local obj = g_Units[session_id] or data
              if obj:HasStatusEffect(id) then
                objs[session_id] = obj
              end
            end
            for _, obj in sorted_pairs(objs) do
              exec(self, team)
            end
          else
            exec(self, team)
          end

        end,
        HandlerCode = function (self, team)
          for _, unit in ipairs(g_Units) do
            if unit.team == team and HasPerk(unit, self.id) then
              local proc = true
              for _, other in ipairs(unit.team.units) do
                if unit ~= other and DivRound(unit:GetDist(other), const.SlabSizeX) <= self:ResolveValue("loner_radius") then
                  proc = false
                  break
                end
              end

              if proc then
                unit:AddStatusEffect("Inspired")
                PlayVoiceResponse(unit, "Loner")
              end
            end
          end
        end,
        param_bindings = false,
      }),
    },
    DisplayName = T(643033597159, --[[ModItemCharacterEffectCompositeDef Loner DisplayName]] "Loner"),
    Description = T(238527648977, --[[ModItemCharacterEffectCompositeDef Loner Description]] "Become <color EmStyle>Inspired</color> when there are no teammates <color EmStyle>in your vicinity</color> at turn start."),
    Icon = "UI/Icons/Perks/Loner",
    Tier = "Quirk",
  }




-- TODO: Set this to TRUE on release blyat
local ttsjIsRelease = false

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

  local statGaining = GetMercStateFlag(unit.session_id, "StatGaining") or {}
  local cooldowns = statGaining.Cooldowns or {}
  local prefix = "FAIL"
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
            bonusToRoll = bonusToRoll + 20
          elseif stat == 'Marksmanship' then
            bonusToRoll = bonusToRoll + 28
          elseif stat == 'Mechanical' then
            bonusToRoll = bonusToRoll + 20
          elseif stat == 'Explosives' then
            bonusToRoll = bonusToRoll + 20
          elseif stat == 'Medical' then
            bonusToRoll = bonusToRoll + 20
          end

          local thresholdBase = unit[stat]
          local thresholdAdd = floatfloor((100 - unit[stat]) // 2.5)
          local threshold = thresholdBase + thresholdAdd - bonusToRoll
          local rollBase = InteractionRand(100, "StatGaining") + 1
          local roll = rollBase
          reason_text = 'Need: ' .. threshold .. ' (' .. thresholdBase .. '+' .. thresholdAdd .. '-' .. bonusToRoll .. '), Chance: ' .. (100 - threshold) .. '%, Roll: ' .. roll
          reason_text = T({'roll (<chance>%)', stat = unit[stat], chance = 100 - threshold})
          if threshold <= roll then
            GainStat(unit, stat)
            unit.statGainingPoints = unit.statGainingPoints - 1
            local cd = InteractionRandRange(const.StatGaining.PerStatCDMin, const.StatGaining.PerStatCDMax, "StatCooldown")
            cooldowns[stat] = Game.CampaignTime + cd
            statGaining.Cooldowns = cooldowns
            prefix = "WIN"
          end
        else
          reason_text = 'too high'
        end
      else
        reason_text = 'roll cooldown'
      end
    else
      reason_text = 'starved Train Points'
    end
  else
    reason_text = 'extraFail (' .. failChance .. '%)'
  end

  if statBefore <= 99 then
    CombatLog(ttsjIsRelease and "debug" or "important", T({
      '<prefix> <nick> <statAbbr>(<statBefore>) <reason>',
      prefix = prefix,
      nick = unit.Nick,
      statAbbr = statAbbr,
      statBefore = statBefore,
      reason = reason_text,
    }))
  end

  SetMercStateFlag(unit.session_id, "StatGaining", statGaining)
end

function ReceiveStatGainingPoints(unit, xpGain)
  if HasPerk(unit, "OldDog") then
    return
  end

  local calcXpThresholds = function(level)
    local out = {}
    local pointsForLevel = 2 + Clamp(level, 1, 9)
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
  local sgp = unit.statGainingPoints

  if 0 < xpGain then
    local sgeIncrease = 300 + (5 * unit['Wisdom'])
    if sgp <= 4 then
      sgeIncrease = sgeIncrease + 100 + InteractionRand(Max(500, (4000 + 60 * unit['Wisdom']) - (1500 * sgp)))
    -- between 5 and 14 do nothing
    elseif sgp == 15 then
      sgeIncrease = MulDivRound(sgeIncrease, 90, 100)
    elseif sgp == 16 then
      sgeIncrease = MulDivRound(sgeIncrease, 80, 100)
    elseif sgp == 17 then
      sgeIncrease = MulDivRound(sgeIncrease, 70, 100)
    elseif sgp == 18 then
      sgeIncrease = MulDivRound(sgeIncrease, 60, 100)
    elseif sgp >= 19 then
      sgeIncrease = MulDivRound(sgeIncrease, 50, 100)
    end
    CombatLog(ttsjIsRelease and "debug" or "important", T { 0, "<nick>.sge = <sge> + <sgeIncrease>", nick = unit.Nick, sgeIncrease = sgeIncrease, sge = unit.statGainingPointsExtra })
    unit.statGainingPointsExtra = unit.statGainingPointsExtra + sgeIncrease
  end

  while unit.statGainingPointsExtra >= 10000 do
    CombatLog(ttsjIsRelease and "debug" or "important", T { 0, "<nick> +1 Train Point (sge)", nick = unit.Nick })
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
        CombatLog(ttsjIsRelease and "debug" or "important", T { 0, "<nick> +1 Train Point for XP threshold", nick = unit.Nick })
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
        CombatLog(ttsjIsRelease and "debug" or "important", T { 0, "<nick> got Train Point for XP milestone threshold", nick = unit.Nick })
        pointsToGain = pointsToGain + 1
        xpSinceLastMilestone = 0
        milestone = milestone + increment
      end
    end
  end

  --if pointsToGain >= 1 then
  --  CombatLog(ttsjIsRelease and "debug" or "important", T { 0, "<nick> gaining <points> Train Points", nick = unit.Nick, points = pointsToGain })
  --end
  unit.statGainingPoints = unit.statGainingPoints + pointsToGain
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
      local is_learned_max = student[stat] >= t_stat or student[stat] > max_learned_stat
      if not is_learned_max then
        student.stat_learning = student.stat_learning or {}

        local progressPerTick = MulDivRound(t_stat, 100 + merc.Leadership, 100) + self:ResolveValue("learning_base_bonus")
        if HasPerk(merc, "Teacher") then
          local bonusPercent = CharacterEffectDefs.Teacher:ResolveValue("MercTrainingBonus")
          progressPerTick = progressPerTick + MulDivRound(progressPerTick, bonusPercent, 100)
        end

        -- mod start
        if student.statGainingPoints == 0 then
          progressPerTick = 1 + progressPerTick // 20
          if not student.stat_learning[stat] or student.stat_learning[stat].progress == 0 or InteractionRand(100) <= 1 then
            if CurrentModOptions['ttsj_showTrainingIneffectiveNotification'] then
              CombatLog("important", T { 0, "<merc_nickname> is bored and needs to see action (earn XP). Training is only worth 5% now. (Not Enough Train Points)", merc_nickname = student.Nick })
            end
          end
        end
        -- mod end

        student.stat_learning[stat] = student.stat_learning[stat] or { progress = 0, up_levels = 0 }
        local learning_progress = student.stat_learning[stat].progress
        learning_progress = learning_progress + progressPerTick

        local progress_threshold = self:ResolveValue("learning_speed") * student[stat] * (100 + self:ResolveValue("wisdow_weight") - Max(0, (student.Wisdom - 50) * 2)) / 100
        if learning_progress >= progress_threshold then

          -- mod start
          student.statGainingPoints = Max(0, student.statGainingPoints - 1)
          -- mod end

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
    local sgp = context.statGainingPoints
    local boosted_text = ''
    if sgp <= 4 then
      boosted_text = '  <color PDASectorInfo_Yellow>(boosted)</color>'
    end
    if sgp >= 15 then
      boosted_text = '  <color PDASM_NewSquadLabel>(slowed)</color>'
    end
    self:SetText(T(488971610056, "ATTRIBUTES") ..
        T({' | <style CrosshairAPTotal>Avail Train Points <sgp></style><style InventoryRolloverPropSmall><boosted_text></style>',
           sgp = sgp,
           boosted_text = boosted_text}))
    return XContextControl.OnContextUpdate(self, context)
  end
end