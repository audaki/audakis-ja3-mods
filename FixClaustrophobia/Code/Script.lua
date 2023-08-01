function Unit:Despawn()
  self:AutoRemoveCombatEffects()
  self:InterruptPreparedAttack()
  self:RemoveEnemyPindown()
  local dlg = GetInGameInterfaceModeDlg()
  local crosshair = dlg and dlg.crosshair
  if crosshair and crosshair.context.target == self then
    dlg:RemoveCrosshair("Despawn")
    if g_Combat then
      if g_Combat:ShouldEndCombat() then
        g_Combat:EndCombatCheck(true)
      else
        SetInGameInterfaceMode("IModeCombatMovement")
      end
    else
      SetInGameInterfaceMode("IModeExploration", {suppress_camera_init = true})
    end
  end
  if not self:IsAmbientUnit() then
    self:SyncWithSession("map")
  end
  self:RemoveAllStatusEffects('despawn')
  if SelectedObj == self then
    SelectObj()
  end
  if self.Squad then
    local squad = gv_Squads[self.Squad]
    if squad and (squad.Side == "enemy1" or squad.Side == "enemy2") then
      RemoveUnitFromSquad(gv_UnitData[self.session_id])
    end
  elseif not IsMerc(self) then
    gv_UnitData[self.session_id] = nil
  end
  if g_Combat and not self:IsLocalPlayerControlled() and CountAnyEnemies() == 1 then
    g_Combat.retreat_enemies = true
  end
  DoneObject(self)
  if g_Combat and not g_AIExecutionController then
    g_Combat:EndCombatCheck("force")
  end
end


function StatusEffectObject:RemoveStatusEffect(id, stacks, reason)
  local has = self:HasStatusEffect(id)
  if not has then
    return
  end
  NetUpdateHash("StatusEffectObject:RemoveStatusEffect", self, id, self:HasMember("GetPos") and self:GetPos())
  local effect = self.StatusEffects[has]
  local preset = CharacterEffectDefs[id]

  local shallUpdateUnitData = g_Units
      and self.session_id
      and self == g_Units[self.session_id]
      and self ~= gv_UnitData[self.session_id]
      and self.team
      and (self.team.side == "player1" or self.team.side == "player2")
      and reason ~= 'despawn'

  if not effect.stacks then
    table.remove(self.StatusEffects, has)
    self.StatusEffects[id] = nil

    if shallUpdateUnitData then
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

    if shallUpdateUnitData then
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