

local cthPresets = Presets.ChanceToHitModifier.Default

if cthPresets.ASniperRifleShot then
  cthPresets.ASniperRifleShot:Done()
end

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

cthPresets.ASniperRifleShot:SortPresets()


function OnMsg.ReloadLua()
  local isBeingDisabled = not table.find(ModsLoaded, 'id', CurrentModId)
  if isBeingDisabled then
    if cthPresets.ASniperRifleShot then
      cthPresets.ASniperRifleShot:Done()
    end
  end
end

