
AudaUi = {
  isKira = table.find(ModsLoaded, 'id', 'audaTest'),

  -- Show XP / Level?
  showXp = true,

  -- Show Free Move AP?
  showFreeMove = true,

  -- Show Tired / Rest Status?
  showTired = true,

  -- Show Morale Influences?
  showMorale = true,

  -- Show Trap Type?
  showTrapType = true,

  -- Show Option Slider Numbers?
  showSliderNumbers = true,

  -- Show Colored Ammo?
  showColoredAmmo = true,


  applyOptions = function()

    if table.find(ModsLoaded, 'id', CurrentModId) then
      AudaUi.showXp = CurrentModOptions.audaUi_showXp and true or false
      AudaUi.showFreeMove = CurrentModOptions.audaUi_showFreeMove and true or false
      AudaUi.showTired = CurrentModOptions.audaUi_showTired and true or false
      AudaUi.showMorale = CurrentModOptions.audaUi_showMorale and true or false
      AudaUi.showTrapType = CurrentModOptions.audaUi_showTrapType and true or false
      AudaUi.showSliderNumbers = CurrentModOptions.audaUi_showSliderNumbers and true or false
      AudaUi.showColoredAmmo = CurrentModOptions.audaUi_showColoredAmmo and true or false
    else
      AudaUi.showXp = false
      AudaUi.showFreeMove = false
      AudaUi.showTired = false
      AudaUi.showMorale = false
      AudaUi.showTrapType = false
      AudaUi.showSliderNumbers = false
      AudaUi.showColoredAmmo = false
    end

    AudaUi.setup_showXp()
    AudaUi.setup_showFreeMove()
    AudaUi.setup_showTired()
    AudaUi.setup_showMorale()
    AudaUi.setup_showTrapType()
    AudaUi.setup_showSliderNumbers()
    AudaUi.setup_showColoredAmmo()

    local dlg = GetInGameInterfaceModeDlg()
    local partyUi = dlg and dlg.idParty
    if partyUi then
      partyUi:RespawnContent()
    end
    local weaponUi = dlg and dlg:ResolveId("idWeaponUI")
    if weaponUi then
      weaponUi:RespawnContent()
    end
  end,


  -- Setup show XP functionality
  setup_showXp = function()
    local xt = audaFindXtByTextId(XTemplates.PDAMercRollover, 997240698559)
    if not xt then
      return
    end

    if not AudaUi.showXp then
      xt:SetProperty('ContextUpdateOnOpen', false)
      xt:SetProperty('OnContextUpdate', nil)
    else
      xt:SetProperty('ContextUpdateOnOpen', true)
      xt:SetProperty('OnContextUpdate', function(self, context, ...)
        local level = CalcLevel(context.Experience)
        local nextLevel = Min(#XPTable, level + 1)
        self:SetText('XP (Level ' .. level .. ') <right><style PDABrowserTextLightMedium>' .. context.Experience .. ' / ' .. XPTable[nextLevel] .. '</style><newline><left>' .. T(997240698559, "Energy<right><style PDABrowserTextLightMedium><EnergyStatusEffect()></style>"))
        return XContextControl.OnContextUpdate(self, context)
      end)
    end
  end,


  -- Setup show Free Move functionality
  setup_showFreeMove = function()

    if not XTemplates.PDAMercRollover or not XTemplates.PDAMercRollover[1] then
      return
    end

    local xtRoot = XTemplates.PDAMercRollover[1]

    if not xtRoot.audaUiOrig__Margins then
      xtRoot:SetProperty('audaUiOrig__Margins', xtRoot.Margins)
    end

    if not AudaUi.showFreeMove then
      xtRoot:SetProperty('Margins', xtRoot.audaUiOrig__Margins)
    else
      xtRoot:SetProperty('Margins', box(42, 1, 0, 0))
    end

    local rXt = audaFindXtByComment(xtRoot, 'ap indicator')
    if rXt then

      if not rXt.audaUiOrig__OnContextUpdate then
        rXt:SetProperty('audaUiOrig__OnContextUpdate', rXt.OnContextUpdate)
      end

      if not AudaUi.showFreeMove then
        rXt:SetProperty('OnContextUpdate', rXt.audaUiOrig__OnContextUpdate)
      else
        rXt:SetProperty('OnContextUpdate', function(self, context, ...)

          local text

          if g_Combat then
            local currentAP = context:GetUIActionPoints()
            local bonus = context.free_move_ap
            local ctx = SubContext(context, {
              current = currentAP,
              bonus = bonus,
            })
            if 1000 <= bonus then
              text = T({
                "<apn(current)><style PDASMLevelTxt>+<apn(bonus)></style>",
                ctx
              })
            else
              text = T({
                263805086279,
                "<apn(current)>",
                ctx
              })
            end
          else
            local maxAP = context:GetMaxActionPoints()
            text = T({
              330002924751,
              "<apn(maxActionPoints)>",
              maxActionPoints = maxAP
            })
          end
          text = text .. " " .. T(363250742550, "<style PDARolloverHeaderDark>AP</style>")
          self:SetText(text)
          XContextControl.OnContextUpdate(self, context)
        end)
      end
    end

    local apDisplays = audaFindXtListByTextId(XTemplates.SquadsAndMercs, 219068997732)
    for _, xt in ipairs(apDisplays) do

      if not xt.audaUiOrig__OnContextUpdate then
        xt:SetProperty('audaUiOrig__OnContextUpdate', xt.OnContextUpdate)
      end

      if not AudaUi.showFreeMove then
        xt:SetProperty('OnContextUpdate', xt.audaUiOrig__OnContextUpdate)
      else
        xt:SetProperty('OnContextUpdate', function(self, context, ...)

          local text
          if not IsKindOf(context, "Unit") then
            return
          end
          self.parent:SetVisible(not not g_Combat and not context:IsDead() and not context:IsDowned())

          if g_Combat then
            self.parent.MinWidth = 39
            self.parent.MaxWidth = 49
            local currentAP = context:GetUIActionPoints()
            local bonus = context.free_move_ap
            local ctx = SubContext(context, {
              current = currentAP,
              bonus = bonus,
            })
            if 1000 <= bonus then
              text = T({
                "<apn(current)><style PDASM_NewSquadLabel>+<apn(bonus)></style>",
                ctx
              })
            else
              text = T({
                263805086279,
                "<apn(current)>",
                ctx
              })
            end
          else
            self.parent.MinWidth = 30
            self.parent.MaxWidth = 30
            local maxAP = context:GetMaxActionPoints()
            text = T({
              330002924751,
              "<apn(maxActionPoints)>",
              maxActionPoints = maxAP
            })
          end

          self:SetText(text)
          XContextControl.OnContextUpdate(self, context)
        end)
      end
    end
  end,

  setup_showTired = function()
    local xt = audaFindParentXtByTextId(XTemplates.PDAMercRollover, 997240698559)
    local eXt = audaFindXtByTextId(xt, 997240698559)

    if not xt or not eXt then
      return
    end

    local removeTiredXtFn = function()
      for i, p in ipairs(xt) do
        if p.Id == 'audaTiredRest' then
          table.remove(xt, i)
          break
        end
      end
    end

    -- Always remove element first if it was added in a previous cycle
    removeTiredXtFn()

    eXt.Margins = nil

    if not AudaUi.showTired then
      return
    end

    -- Fix margins of sibling element due to FoldWhenHidden
    eXt.Margins = box(0, 0, 0, 2)

    local tiredXt = PlaceObj("XTemplateWindow", {
      "__class",
      "XText",
      "Id",
      "audaTiredRest",
      "VAlign",
      "center",
      "Clip",
      false,
      "UseClipBox",
      false,
      "TextStyle",
      "SatelliteContextMenuKeybind",
      "Translate",
      true,
      "ContextUpdateOnOpen",
      true,
      "OnContextUpdate",
      function(self, context, ...)

        if not g_SatelliteUI or IsInventoryOpened() then
          self:SetVisible(false)
          self:SetText('')
          return
        end

        local hp = context.HitPoints
        local additional = GetHPAdditionalTiredTime(hp)

        local travelTime = MulDivRound(context.TravelTime, 10, const.Scale.h)
        local travelTimeMax = MulDivRound(const.Satellite.UnitTirednessTravelTime + additional, 10, const.Scale.h)
        local travelTimeRemain = travelTimeMax - travelTime

        local restTimer = MulDivRound(Game.CampaignTime - context.RestTimer, 10, const.Scale.h)
        local restTimerMax = MulDivRound(const.Satellite.UnitTirednessRestTime, 10, const.Scale.h)
        local restTimerRemain = restTimerMax - restTimer

        local text
        if travelTimeRemain >= 0 then
          text = text .. T {
            '<style SatelliteContextMenuKeybind>Tired In<scale 690> (Travel)<scale 1000></style><right><style PDABrowserTextLightMedium><travelTimeRemain>h<scale 690> (Max: <travelTimeMax>h)<scale 1000></style><newline><left>',
            travelTimeRemain = travelTimeRemain / 10.0,
            travelTime = travelTime / 10,
            travelTimeMax = travelTimeMax / 10,
          }
        else
          text = text .. T {
            '<style SatelliteContextMenuKeybind>Tired In<scale 690> (Travel)<scale 1000></style><right><style PDABrowserTextLightMedium><scale 690>+Tired Incoming<scale 1000></style><newline><left>',
          }
        end

        if context.RestTimer > 0 and restTimerRemain >= 0 then
          text = text .. T {
            '<style SatelliteContextMenuKeybind>Rested In</style><right><style PDABrowserTextLightMedium><restTimerRemain>h<scale 690> (Max: <restTimerMax>h)<scale 1000></style><newline><left>',
            restTimerRemain = restTimerRemain == 120 and 12 or (restTimerRemain / 10.0),
            restTimer = restTimer / 10,
            restTimerMax = restTimerMax / 10,
          }
        elseif context.RestTimer > 0 then
          text = text .. T {
            '<style SatelliteContextMenuKeybind>Rested In</style><right><style PDABrowserTextLightMedium><scale 690>+Rest Incoming<scale 1000></style><newline><left>',
          }
        else
          text = text .. T {
            '<style SatelliteContextMenuKeybind>Rested In</style><right><style PDABrowserTextLightMedium><scale 690>Not Resting Normally<scale 1000></style><newline><left>',
          }
        end

        self:SetVisible(true)
        self:SetText(text)
        return XContextControl.OnContextUpdate(self, context)
      end,
      "FoldWhenHidden",
      true,
      box(1, 0, 1, 0),
      T(997240698559, "Tired/Rest Placeholder")
    })

    table.insert(xt, tiredXt)
  end,

  setup_showMorale = function()

    local xt = audaFindXtByTextId(XTemplates.PDAMercRollover, 258629704073)
    if not xt then
      return
    end

    if not AudaUi.showMorale then
      xt:SetProperty('ContextUpdateOnOpen', false)
      xt:SetProperty('OnContextUpdate', nil)
    else
      xt:SetProperty('ContextUpdateOnOpen', true)
      xt:SetProperty('OnContextUpdate', function(self, context, ...)

        if not AudaUi.showMorale then
          self:SetText(T(258629704073, "Morale<right><style PDABrowserTextLightMedium><MercMoraleText()></style>"))
          return
        end

        local merc = context

        local influences = ''

        local teamMorale = merc.team and merc.team.morale or 0
        local personalMorale = 0
        local isDisliking = false

        for _, dislikedMerc in ipairs(merc.Dislikes) do
          local dislikedIndex = table.find(merc.team.units, "session_id", dislikedMerc)
          if dislikedIndex and not merc.team.units[dislikedIndex]:IsDead() then
            personalMorale = personalMorale - 1
            influences = influences .. '<style InventoryHintTextRed>Dislikes ' .. merc.team.units[dislikedIndex].Nick .. '</style> -1<newline>'
            isDisliking = true
            break
          end
        end

        if not isDisliking then
          for _, likedMerc in ipairs(merc.Likes) do
            local likedIndex = table.find(merc.team.units, "session_id", likedMerc)
            if likedIndex and not merc.team.units[likedIndex]:IsDead() then
              personalMorale = personalMorale + 1
              influences = influences .. '<style InventoryRolloverValuableItemValue>Likes ' .. merc.team.units[likedIndex].Nick .. '</style> +1<newline>'
              break
            end
          end
        end

        local isWounded = false
        local idx = merc:HasStatusEffect("Wounded")
        if idx and merc.StatusEffects[idx].stacks >= 3 then
          isWounded = true
        end
        if merc.HitPoints < MulDivRound(merc.MaxHitPoints, 50, 100) or isWounded then
          if HasPerk(merc, "Psycho") then
            personalMorale = personalMorale + 1
            influences = influences .. '<style InventoryRolloverValuableItemValue>Is Wounded (Psycho)</style> +1<newline>'
          else
            personalMorale = personalMorale - 1
            influences = influences .. '<style InventoryHintTextRed>Is Wounded</style> -1<newline>'
          end
        end
        for _, likedMerc in ipairs(merc.Likes) do
          local ud = gv_UnitData[likedMerc]
          if ud and ud.HireStatus == "Dead" then
            local deathDay = ud.HiredUntil
            if deathDay + 7 * const.Scale.day > Game.CampaignTime then
              personalMorale = personalMorale - 1
              influences = influences .. '<style InventoryHintTextRed>Liked ' .. ud.Nick .. ' is dead</style> -1<newline>'
              break
            end
          end
        end
        if merc:HasStatusEffect("ZoophobiaChecked") then
          personalMorale = personalMorale - 1
          influences = influences .. '<style InventoryHintTextRed>Zoophobia</style> -1<newline>'
        end
        if merc:HasStatusEffect("ClaustrophobiaChecked") then
          personalMorale = personalMorale - 1
          influences = influences .. '<style InventoryHintTextRed>Claustrophobia</style> -1<newline>'
        end
        if merc:HasStatusEffect("FriendlyFire") then
          personalMorale = personalMorale - 1
          influences = influences .. '<style InventoryHintTextRed>FriendlyFire\'d</style> -1<newline>'
        end
        if merc:HasStatusEffect("Conscience_Guilty") then
          personalMorale = personalMorale - 1
          influences = influences .. '<style InventoryHintTextRed>Guilty</style> -1<newline>'
        end
        if merc:HasStatusEffect("Conscience_Sinful") then
          personalMorale = personalMorale - 2
          influences = influences .. '<style InventoryHintTextRed>Sinful</style> -2<newline>'
        end
        if merc:HasStatusEffect("Conscience_Proud") then
          personalMorale = personalMorale + 1
          influences = influences .. '<style InventoryRolloverValuableItemValue>Proud</style> +1<newline>'
        end
        if merc:HasStatusEffect("Conscience_Righteous") then
          personalMorale = personalMorale + 2
          influences = influences .. '<style InventoryRolloverValuableItemValue>Righteous</style> +2<newline>'
        end

        if teamMorale >= 1 then
          influences = influences .. '<style InventoryRolloverValuableItemValue>Team Morale</style> +' .. teamMorale .. '<newline>'
        elseif teamMorale <= -1 then
          influences = influences .. '<style InventoryHintTextRed>Team Morale</style> ' .. teamMorale .. '<newline>'
        end

        --local diff = (personalMorale + teamMorale) - Clamp(personalMorale + teamMorale, -3, 3)
        --if diff >= 1 then
        --  influences = influences .. '(Capped to +3)<newline>'
        --elseif diff <= -1 then
        --  influences = influences .. '(Capped to -3)<newline>'
        --end


        local finalMorale = Clamp(personalMorale + teamMorale, -3, 3)
        local influencesWasEmpty = #influences == 0
        if finalMorale == -3 then
          influences = influences .. '= <style PDA_FinancesValueTextRed>Abysmal</style> (-3AP)'
        elseif finalMorale == -2 then
          influences = influences .. '= <style PDA_FinancesValueTextRed>Very Low</style> (-2AP)'
        elseif finalMorale == -1 then
          influences = influences .. '= <style PDA_FinancesValueTextRed>Low</style> (-1AP)'
        elseif finalMorale == 0 then
          influences = influences .. '= Stable'
        elseif finalMorale == 1 then
          influences = influences .. '= <style InventoryRolloverValuableItemValue>High</style> (+1AP)'
        elseif finalMorale == 2 then
          influences = influences .. '= <style InventoryRolloverValuableItemValue>Very High</style> (+2AP)'
        elseif finalMorale == 3 then
          influences = influences .. '= <style InventoryRolloverValuableItemValue>Exceptional</style> (+3AP)'
        end

        if influencesWasEmpty then
          influences = string.sub(influences, 3)
        end

        --T(258629704073, "Morale<right><style PDABrowserTextLightMedium><MercMoraleText()></style>")

        self:SetText('Morale<right><style PDABrowserTextLightMedium>' .. influences .. '</style>')

        return XContextControl.OnContextUpdate(self, context)
      end)
    end
  end,

  setup_showTrapType = function()
    if not CombatActions.Interact_Disarm then
      return
    end

    if not CombatActions.Interact_Disarm.audaUiOrig__GetActionDisplayName then
      CombatActions.Interact_Disarm.audaUiOrig__GetActionDisplayName = CombatActions.Interact_Disarm.GetActionDisplayName
    end

    if not AudaUi.showTrapType then
      CombatActions.Interact_Disarm.GetActionDisplayName = CombatActions.Interact_Disarm.audaUiOrig__GetActionDisplayName
      return
    end

    CombatActions.Interact_Disarm.GetActionDisplayName = function(self, units)
      local trapName = T(726087963038, "Trap")
      local isMechanical = false

      for i, u in ipairs(units) do
        if u.GetTrapDisplayName then
          trapName = u:GetTrapDisplayName()
        end
      end

      for i, u in ipairs(units) do
        if IsKindOf(u, "BoobyTrappable") and (u.boobyTrapType or 0) >= 1 then
          if u.boobyTrapType == 3 or u.boobyTrapType == 4 then
            isMechanical = true
          end
          if u.GetTrapDisplayName then
            trapName = u:GetTrapDisplayName()
          end

        end
      end

      return T({ 0, '<type_prefix> <trap_in><trap_name>',
                 type_prefix = isMechanical and 'Disable Mechanical' or 'Defuse Explosive',
                 trap_in = TGetID(trapName) ~= 726087963038 and 'Trap in ' or '',
                 trap_name = trapName
      })
    end
  end,

  setup_showSliderNumbers = function()

    local xt = audaFindXtByName(XTemplates.PropNumber, 'MoveThumb')

    if not xt then
      return
    end

    if not xt.audaUiOrig__func then
      xt:SetProperty('audaUiOrig__func', xt.func)
    end


    if not AudaUi.showSliderNumbers then
      xt:SetProperty('func', xt.audaUiOrig__func)
    else
      xt:SetProperty('func', function(self, ...)
        xt.audaUiOrig__func(self, ...)

        local idName = self.parent and self.parent.idName or nil
        if idName then
          local max = self.Max
          if max == 0 then
            max = 100
          end
          local value = self.Scroll
          local percent = floatfloor(1000 * value / max) / 10.0

          local meta = self.prop_meta or {}
          local name = self.prop_meta.name or self.prop_meta.id or ''
          local displayType = 'percent'
          local postfix = ''


          displayType = meta.valueDisplayType or displayType
          postfix = meta.valueDisplayPostfix or postfix


          if displayType == 'showAll' then
            idName:SetText(T{
              '<name>: <value><postfix><valign top 3><scale 600>/<max><postfix> (<percent>%)',
              name = name,
              value = value,
              max = max,
              percent = percent,
              postfix = postfix,
            })
          elseif displayType == 'percent' then
            idName:SetText(T{
              '<name>: <percent>%',
              name = name,
              percent = percent,
            })
          elseif displayType == 'value' then
            idName:SetText(T{
              '<name>: <value><postfix>',
              name = name,
              value = value,
              postfix = postfix,
            })
          elseif displayType == 'valueWithMax' then
            idName:SetText(T{
              '<name>: <value><postfix><valign top 3><scale 600>/<max><postfix>',
              name = name,
              value = value,
              max = max,
              postfix = postfix,
            })
          end
        end

      end)
    end
  end,

  setup_showColoredAmmo = function()

    if AudaUi.showColoredAmmo then
      _9mm_Shock.colorStyle = 'AmmoHPColor'
      InventoryItemDefs['_9mm_Shock'].colorStyle = 'AmmoHPColor'
    end

    if not TFormat.audaUiOrig__bullets then
      TFormat.audaUiOrig__bullets = TFormat.bullets
    end

    if not AudaUi.showColoredAmmo then
      TFormat.bullets = TFormat.audaUiOrig__bullets
    else
      TFormat.bullets = function(context_obj, bullets, max, icon)
        icon = icon or "<image UI/Icons/Rollover/ammo_placeholder 1400>"
        bullets = bullets or GetBulletCount(context_obj)
        if not bullets then
          return T(994336406701, "<image UI/Icons/Hud/ammo_infinite>")
        end
        local max = max or context_obj and context_obj.MagazineSize or context_obj.MaxStacks

        local text = '<bullets>'
        if context_obj.ammo and context_obj.ammo.colorStyle and context_obj.ammo.colorStyle ~= 'AmmoBasicColor' then
          local colorStyle = context_obj.ammo.colorStyle
          text = '<color ' .. colorStyle .. '>' .. text .. '</color>'
        end
        if not max then
          return T({
            text,
            bullets = bullets,
            icon = icon,
          })
        else
          text = text .. "<style InventoryItemsCountMax>/<max></style>"
          return T({
            text,
            bullets = bullets,
            max = max or 0,
            icon = icon,
          })
        end
      end
    end
  end,
}

OnMsg.ModsReloaded = AudaUi.applyOptions
OnMsg.ApplyModOptions = AudaUi.applyOptions
OnMsg.ReloadLua = AudaUi.applyOptions