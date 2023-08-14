








--
--
--CombatActions.BurstFire.GetActionResults = function (self, unit, args)
--  local args = table.copy(args)
--  args.weapon = self:GetAttackWeapons(unit, args)
--  args.num_shots = args.num_shots or args.weapon and args.weapon:GetAutofireShots(self)
--  args.multishot = true
--  args.damage_bonus = self:ResolveValue("dmg_penalty")
--
--  if not args.prediction and args.weapon.owner == 'Grunty' and args.aim >= 3 then
--    print('FULLY AIMED!')
--  end
--
--  local attack_args = unit:PrepareAttackArgs(self.id, args)
--  local results = attack_args.weapon:GetAttackResults(self, attack_args)
--  return results, attack_args
--end



--
--local count = {}
--Unit.OrigExecFirearmAttacks = Unit.ExecFirearmAttacks
--Unit.ExecFirearmAttacks = function(self, action, cost_ap, attack_args, results)
--
--  if (not attack_args.prediction) and attack_args.weapon and (attack_args.weapon.owner == 'Vicki') then
--    Inspect(table.copy(results))
--    print(' ')
--    print(' ')
--    print('Attacker: ' .. attack_args.weapon.owner)
--    if attack_args.action_id then
--      print('Action: ' .. attack_args.action_id)
--    end
--    local myCount = count[attack_args.weapon.owner] or 1
--    print('Attack: ' .. myCount)
--    myCount = myCount + 1
--    count[attack_args.weapon.owner] = myCount
--    print('Aim: ' .. results.aim)
--    for _, mod in ipairs(results.chance_to_hit_modifiers) do
--      print((TDevModeGetEnglishText(mod.name or '') or '') .. ': ' .. (mod.value or 0) .. '%')
--    end
--  end
--  return Unit.OrigExecFirearmAttacks(self, action, cost_ap, attack_args, results)
--end