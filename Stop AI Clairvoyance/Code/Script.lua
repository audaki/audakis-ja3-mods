


-- Uninstall Routine Prerequisite
if not audaOrigAIUpdateScoutLocation then
  audaOrigAIUpdateScoutLocation = AIUpdateScoutLocation
end

-- Uninstall Routine
function OnMsg.ReloadLua()
  local isBeingDisabled = not table.find(ModsLoaded, 'id', CurrentModId)
  if isBeingDisabled then
    AIUpdateScoutLocation = audaOrigAIUpdateScoutLocation
  end
end



local function findClosestEnemyForUnit(selfUnit, pos)
  if not IsValid(selfUnit) then
    return
  end
  pos = SnapToVoxel(pos or selfUnit)

  local threshold = const.SlabSizeX / 2
  local closest_enemy, min_dist
  local enemies = GetAllEnemyUnits(selfUnit)
  for _, enemy in ipairs(enemies) do
    if IsValidTarget(enemy) and selfUnit:IsConsideredEnemy(enemy) and (not min_dist or IsCloser(enemy, pos, min_dist)) then
      local dist = enemy:GetDist(pos)
      closest_enemy = enemy
      min_dist = dist + threshold
    end
  end
  return closest_enemy
end



function AIUpdateScoutLocation(unit)
  if not unit.last_known_enemy_pos then
    return
  end
  local sight = unit:GetSightRadius()
  if not CheckLOS(unit.last_known_enemy_pos, unit, sight) then
    return
  end



  local px = unit.last_known_enemy_pos:x()
  local py = unit.last_known_enemy_pos:y()
  local r = 5 * guim

  local sx1 = px - r
  local sx2 = px + r + 1
  local sy1 = py - r
  local sy2 = py + r + 1


  local closestEnemy = findClosestEnemyForUnit(unit)
  if closestEnemy then
    local eneX, eneY, eneZ = closestEnemy:GetPosXYZ()
    if eneX < px then
      sx1 = sx1 - 3 * guim
      sx2 = sx2 - 3 * guim
    elseif eneX > px then
      sx1 = sx1 + 3 * guim
      sx2 = sx2 + 3 * guim
    end
    if eneY < py then
      sy1 = sy1 - 3 * guim
      sy2 = sy2 - 3 * guim
    elseif eneY > py then
      sy1 = sy1 + 3 * guim
      sy2 = sy2 + 3 * guim
    end
  end

  local bbox = box(sx1, sy1, 0, sx2, sy2, MapSlabsBBox_MaxZ)
  local allDests, allDestsAdded = {}, {}
  local push_dest = function(x, y, z, dests, dest_added)
    local world_voxel = point_pack(x, y, z)
    if not dest_added[world_voxel] then
      dests[#dests + 1] = world_voxel
      dest_added[world_voxel] = true
    end
  end
  ForEachPassSlab(bbox, push_dest, allDests, allDestsAdded)
  if 0 < #allDests then
    local voxel = table.interaction_rand(allDests, "Combat")
    local x, y, z = point_unpack(voxel)
    unit.last_known_enemy_pos = point(x, y, z)
  end
end