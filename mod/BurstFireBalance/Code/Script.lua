
for _, param in ipairs(CombatActions.BurstFire.Parameters) do
    if param.Name == 'dmg_penalty' then
        param.Value = -40
    end
end

g_PresetParamCache[CombatActions.BurstFire]['dmg_penalty'] = -40
