

function OnMsg.BecomeLiked(likerId, likeeId)
  if g_Units and g_Units[likerId] then
    g_Units[likerId].Likes = table.copy(g_Units[likerId].Likes)
    table.insert(g_Units[likerId].Likes, likeeId)
  end
end

function OnMsg.BecomeDisliked(dislikerId, dislikeeId)
  if g_Units and g_Units[dislikerId] then
    g_Units[dislikerId].Dislikes = table.copy(g_Units[dislikerId].Dislikes)
    table.insert(g_Units[dislikerId].Dislikes, dislikeeId)
  end
end