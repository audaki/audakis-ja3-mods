function StatusEffectObject:RemoveStatusEffect(id, stacks, reason)
  local has = self:HasStatusEffect(id)
  if not has then
    return
  end
  NetUpdateHash("StatusEffectObject:RemoveStatusEffect", self, id, self:HasMember("GetPos") and self:GetPos())
  local effect = self.StatusEffects[has]
  local preset = CharacterEffectDefs[id]
  if not effect.stacks then
    table.remove(self.StatusEffects, has)
    self.StatusEffects[id] = nil

    if g_Units and self.session_id and self == g_Units[self.session_id] and self ~= gv_UnitData[self.session_id] then
      gv_UnitData[self.session_id]:RemoveStatusEffect(id)
    end

    self:UpdateStatusEffectIndex()
    for _, mod in ipairs(preset:GetProperty("Modifiers")) do
      self:RemoveModifier("StatusEffect:" .. id, mod.target_prop)
    end
    return
  end
  if reason == "death" and effect.dontRemoveOnDeath then
    return
  end
  local lost
  local to_remove = stacks == "all" and effect.stacks or stacks or 1
  local removedStacks = Min(effect.stacks, to_remove)
  effect.stacks = Max(0, effect.stacks - to_remove)
  if effect.stacks == 0 then
    table.remove(self.StatusEffects, has)
    self.StatusEffects[id] = nil

    if g_Units and self.session_id and self == g_Units[self.session_id] and self ~= gv_UnitData[self.session_id] then
      gv_UnitData[self.session_id]:RemoveStatusEffect(id)
    end

    self:UpdateStatusEffectIndex()
    for _, mod in ipairs(preset:GetProperty("Modifiers")) do
      self:RemoveModifier("StatusEffect:" .. id, mod.target_prop)
    end
    lost = true
    if Platform.developer and self:ReportStatusEffectsInLog() and not self:IsDead() then
      CombatLog("debug", T({
        Untranslated("<name> lost effect <effect>"),
        name = self:GetLogName(),
        effect = effect.DisplayName or Untranslated(id)
      }))
    end
    if effect.RemoveEffectText and not self:IsDead() then
      CombatLog("short", T({
        effect.RemoveEffectText,
        self
      }))
    end
  end
  ObjModified(self.StatusEffects)
  Msg("StatusEffectRemoved", self, id, removedStacks, reason)
end