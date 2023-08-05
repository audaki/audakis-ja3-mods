

function OnMsg.BecomeLiked(likerId, likeeId)
  if g_Units and g_Units[likerId] then
    table.insert(g_Units[likerId].Likes, likeeId)
  end
end

function OnMsg.BecomeDisliked(dislikerId, dislikeeId)
  if g_Units and g_Units[dislikerId] then
    table.insert(g_Units[dislikerId].Dislikes, dislikeeId)
  end
end