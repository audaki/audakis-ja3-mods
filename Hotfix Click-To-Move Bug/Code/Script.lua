
function CombatPath:GetAP(pos, endStance)
  if not pos then
    return
  end
  local pos_type = type(pos)
  local ap, stance
  if pos_type == "number" then
    ap = self.paths_ap[pos]
    stance = self.final_destination_stances and self.final_destination_stances[pos] or self.destination_stances and self.destination_stances[pos]
    if endStance and stance and stance ~= endStance then
      return ap + GetStanceToStanceAP(stance, endStance)
    end
    return ap
  elseif pos_type == "table" then
    local min_cost
    for i, p in ipairs(pos) do
      local c = self:GetAP(p)
      if c and (not min_cost or min_cost > c) then
        min_cost = c
      end
    end
    return min_cost
  end
  pos = point_pack(pos)
  ap = self.paths_ap[pos]
  stance = self.final_destination_stances and self.final_destination_stances[pos] or self.destination_stances and self.destination_stances[pos]
  if endStance and stance and stance ~= endStance then
    return ap + GetStanceToStanceAP(stance, endStance)
  end
  return ap
end


local lMergeCombatPath = function(mergePath, pathToMerge, traversal_stance, destination_stance, extra_cost, free_move_ap)
  free_move_ap = free_move_ap or 0
  for posPacked, canReach in pairs(pathToMerge.destinations) do
    local costBase = pathToMerge.paths_ap[posPacked] + extra_cost
    local cost = Max(0, costBase - free_move_ap)
    local recordedCost = mergePath.paths_ap_discounted[posPacked]
    if not recordedCost or cost < recordedCost then
      mergePath.paths_ap[posPacked] = costBase
      mergePath.paths_ap_discounted[posPacked] = cost
      mergePath.paths_prev_pos[posPacked] = pathToMerge.paths_prev_pos[posPacked]
      mergePath.destinations[posPacked] = true
      -- Kira: set real final destionation stance here
      mergePath.final_destination_stances[posPacked] = destination_stance
      -- Kira: destination_stances are actually traversal stances
      mergePath.destination_stances[posPacked] = traversal_stance
    end
  end
end



function GetCombatPathKeepStanceAware(mover, stance_at_end, ap)
  ap = ap or mover.ActionPoints
  local mergedPath = CombatPath:new({
    destinations = {},
    destination_stances = {},
    final_destination_stances = {},
    paths_ap = {},
    paths_ap_discounted = {},
    paths_prev_pos = {},
    unit = mover,
    stance = mover.stance,
    ap = ap,
    start_pos = mover:GetPos(),
    move_modifier = mover:GetMoveModifier(mover.stance)
  })
  if GetKeepStanceOption(mover) then
    local extraCosts = GetStanceChangesAdditionalCost(mover, mover.stance, stance_at_end)
    local currentStancePath = CombatPath:new()
    currentStancePath:RebuildPaths(mover, ap - extraCosts, nil, mover.stance)
    -- Kira: stance is the same, so use stance for traversal stance and destination stance
    lMergeCombatPath(mergedPath, currentStancePath, mover.stance, mover.stance, extraCosts, Max(mover.start_move_free_ap, mover.free_move_ap))
    return mergedPath
  end
  local extraCostStanding = GetStanceChangesAdditionalCost(mover, "Standing", stance_at_end)
  local standingPath = CombatPath:new()
  standingPath:RebuildPaths(mover, ap - extraCostStanding, nil, "Standing")
  local extraCostCrouching = GetStanceChangesAdditionalCost(mover, "Crouch", stance_at_end)
  local crouchPath = CombatPath:new()
  crouchPath:RebuildPaths(mover, ap - extraCostCrouching, nil, "Crouch")
  local extraCostProne = GetStanceChangesAdditionalCost(mover, "Prone", stance_at_end)
  local pronePath = CombatPath:new()
  pronePath:RebuildPaths(mover, ap - extraCostProne, nil, "Prone")
  local moverStance = mover.stance
  local paths = {
    {
      standingPath,
      "Standing",
      extraCostStanding
    },
    {
      crouchPath,
      "Crouch",
      extraCostCrouching
    },
    {
      pronePath,
      "Prone",
      extraCostProne
    }
  }
  table.sort(paths, function(a, b)
    if a[2] == moverStance then
      return true
    end
    if b[2] == moverStance then
      return false
    end
    return true
  end)
  for i, path in ipairs(paths) do
    -- Kira: use stance properly as traversal_stance and also give stance_at_end
    lMergeCombatPath(mergedPath, path[1], path[2], stance_at_end, path[3], Max(mover.start_move_free_ap, mover.free_move_ap))
  end
  return mergedPath
end

