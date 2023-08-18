
-- Wrap original function
if not audaOrigPlayVoiceResponse then
  audaOrigPlayVoiceResponse = PlayVoiceResponse
end

local t = VoiceResponseTypes
local types = { t.GroupOrder, t.Order, t.Selection, t.SelectionStealth }
for _, vt in ipairs(types) do
  if not vt.audaOldCooldown then
    vt.audaOldCooldown = vt.Cooldown
    vt.Cooldown = 10 * 1000
  end
  if not vt.audaOldPerLineCooldown then
    vt.audaOldPerLineCooldown = vt.PerLineCooldown
    vt.PerLineCooldown = 30 * 1000
  end
end

function PlayVoiceResponse(unit, eventType, force)
  if eventType == 'Order' or eventType == 'GroupOrder' or eventType == 'Selection' or eventType == 'SelectionStealth' or eventType == 'CombatMovementStealth' then
    if InteractionRand(100, 'RepetitiveVoiceResponse') < 50 then
      return
    end
  end

  audaOrigPlayVoiceResponse(unit, eventType, force)
end

-- Uninstall routine
function OnMsg.ReloadLua()
  local isBeingDisabled = not table.find(ModsLoaded, 'id', CurrentModId)
  if not isBeingDisabled then
    return
  end

  if not audaOrigPlayVoiceResponse then
    return
  end

  PlayVoiceResponse = audaOrigPlayVoiceResponse

  for _, vt in ipairs(types) do
    if vt.audaOldCooldown then
      vt.Cooldown = vt.audaOldCooldown
      vt.audaOldCooldown = nil
    end
    if vt.audaOldPerLineCooldown then
      vt.PerLineCooldown = vt.audaOldPerLineCooldown
      vt.audaOldPerLineCooldown = nil
    end
  end
end