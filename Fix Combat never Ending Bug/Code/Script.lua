


function Combat:ShouldEndDueToNoVisibility()
  if Game and Game.game_type == "PvP" then
    return
  end
  local any_visibility
  for _, t in ipairs(g_Teams) do
    if g_Visibility[t] and #g_Visibility[t] > 0 then
      for i, tt in ipairs(g_Teams) do

        if t:IsEnemySide(tt) and g_Visibility[tt] and #g_Visibility[tt] > 0 then

          for _, visUnit in ipairs(g_Visibility[tt]) do
            if visUnit.team and visUnit.team == t then
              any_visibility = true
              break
            end
          end

          if any_visibility then
            break
          end
        end
        if any_visibility then
          break
        end
      end
      if any_visibility then
        break
      end
    end
  end

  if any_visibility then
    self.turns_no_visibility = 0
  else
    self.turns_no_visibility = self.turns_no_visibility + 1
  end


  return self.turns_no_visibility >= 4
end


function OnMsg.PostCombatEnd()
  MapForEach("map", "Unit", function(unit)
    if (unit.team and (unit.team.side ~= 'player1' and unit.team.side ~= 'player2')) then
      unit.AddStatusEffect('Unaware')
    end
  end)
end