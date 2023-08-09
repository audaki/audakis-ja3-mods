


PlaceObj('ChanceToHitModifier', {
  CalcValue = function (self, attacker, target, body_part_def, action, weapon1, weapon2, lof, aim, opportunity_attack, attacker_pos, target_pos)
    local mod = 0
    local side = attacker and attacker.team and attacker.team.side or ''
    if (side == 'player1' or side == 'player2') and IsKindOfClasses(weapon1, "SniperRifle") then
      mod = Min(0, -100 + attacker.Marksmanship + (2 * aim))
    end
    return mod ~= 0, mod, T{"Sniper Rifle Shot"}
  end,
  RequireTarget = true,
  display_name = T("Sniper Rifle"),
  group = "Default",
  id = "SniperRifleShot",
})

local cthPresets = Presets['ChanceToHitModifier']['Default']
local sniperRiflePreset = cthPresets.SniperRifleShot
if cthPresets[#cthPresets] == sniperRiflePreset then
  table.remove(cthPresets, #cthPresets)
  table.insert(cthPresets, 1, sniperRiflePreset)
end