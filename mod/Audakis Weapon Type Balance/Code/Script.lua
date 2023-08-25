

local setBurstDamagePenalty = function(value)
  local action = CombatActions.BurstFire
  local params = action.Parameters
  local param = table.find_value(params, 'Name', 'dmg_penalty')
  value = value or -40

  param.Value = value

  action:PostLoad()
end

setBurstDamagePenalty()



local cthPresets = Presets.ChanceToHitModifier.Default

-- Remove preset on 2nd load (like when saving the mod in mod editor or when another mod is enabled by player)
if cthPresets.ASniperRifleShot then
  cthPresets.ASniperRifleShot:Done()
end

-- So we can add preset here with current code
PlaceObj('ChanceToHitModifier', {
  CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
    local mod = 0
    local side = attacker and attacker.team and attacker.team.side or ''
    if (side == 'player1' or side == 'player2') and IsKindOfClasses(weapon1, "SniperRifle") then
      mod = Min(0, -147 + attacker.Marksmanship + (attacker.Dexterity / 2) + (5 * aim))
    end

    if mod == 0 then
      return false, 0, T{"Sniper Rifle Shot"}
    else
      if aim == 0 then
        return true, mod, T{"Sniper: Hipshot"}
      elseif aim <= 2 then
        return true, mod, T{"Sniper: Quick Aim"}
      else
        return true, mod, T{"Sniper: Untrained"}
      end
    end
  end,
  RequireTarget = true,
  display_name = T("Sniper Rifle"),
  group = "Default",
  id = "ASniperRifleShot",
})

-- Sort Presets by their IDs, which fails when saving mod in mod editor
cthPresets.ASniperRifleShot:SortPresets()




CombatActions.DualShot.GetAPCost = function (self, unit, args)
  local weapon1, weapon2 = self:GetAttackWeapons(unit, args)
  if not weapon1 or not weapon2 then
    return -1
  end
  local aim = args and args.aim or 0

  local w1Attack = weapon1:GetBaseAttack(unit)
  w1Attack = w1Attack and CombatActions[w1Attack]
  local w2Attack = weapon2:GetBaseAttack(unit)
  w2Attack = w2Attack and CombatActions[w2Attack]

  local isSingleShot = w1Attack ~= w2Attack or w1Attack == CombatActions.SingleShot

  if isSingleShot then
    return Max(unit:GetAttackAPCost(self, weapon1, false, aim) + CombatActions.SingleShot.ActionPointDelta, unit:GetAttackAPCost(self, weapon2, false, aim) + CombatActions.SingleShot.ActionPointDelta) + self.ActionPointDelta
  end
  return Max(unit:GetAttackAPCost(self, weapon1, false, aim), unit:GetAttackAPCost(self, weapon2, false, aim)) + self.ActionPointDelta
end


-- Uninstall Routine
function OnMsg.ReloadLua()
  local isBeingDisabled = not table.find(ModsLoaded, 'id', CurrentModId)
  if isBeingDisabled then
    if cthPresets.ASniperRifleShot then
      cthPresets.ASniperRifleShot:Done()
      setBurstDamagePenalty(-50)
    end
  end
end

