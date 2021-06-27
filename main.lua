local horsepills = RegisterMod("Horse Pills", 1)
local game = Game()
local itempickedup = false
--local someoneHasHorseT = false
horsepills.COLLECTIBLE_HORSEPILLS = Isaac.GetItemIdByName("Horse Tranquilizer")
--[[local Challenges = {
    CHALLENGE_HORSE = Isaac.GetChallengeIdByName("Ketamine Addiction")
}]]

horsepills:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
	--External Item Description
	if EID then
		EID:addCollectible(horsepills.COLLECTIBLE_HORSEPILLS, "Replaces all pills with horse pills.#Spawns a pill.")
	end
	itempickedup = false
--someoneHasHorseT = false
end)

--takes the ID of a pill that the game is trying to spawn, and adds 2048 to it, since all horse pill IDs are 2048 + the original ID
function horsepills:onPillSpawn(entity)
	local player = Isaac.GetPlayer(0)
	if (player:HasCollectible(horsepills.COLLECTIBLE_HORSEPILLS) --[[or game.Challenge == Challenges.CHALLENGE_HORSE]]) and entity.PickupVariant == PICKUP_PILL and entity.SubType <= 2047 then
		horsepill = 2048 + entity.SubType
		entity:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,horsepill,true)
	end
end

--spawns pill when item is picked up
function horsepills:onItemGet(entity)
	local player = Isaac.GetPlayer(0)
	--local animName = string.sub((player:GetSprite():GetAnimation()), 1, 6)
	if --[[entity.PickupVariant == PICKUP_COLLECTIBLE and]] entity.SubType == horsepills.COLLECTIBLE_HORSEPILLS and itempickedup == false and entity.Price == 0 --[[animName == "Pickup"]] then
		--print("horse T picked up")
		itempickedup = true
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, math.random(2049,2061), Game():GetRoom():FindFreePickupSpawnPosition(Isaac.GetPlayer(0).Position, 0, true), Vector.Zero, player)
	end
end

--this is a really stupid way to do this, since the game won't be able to spawn golden pills if you have Mom's Bottle of Pills or Little Baggy + Deck of Cards, but idk how else to change pills that get added directly to player's inventory into horse pills
horsepills:AddCallback(ModCallbacks.MC_GET_PILL_COLOR, function()
	local player = Isaac.GetPlayer(0)
  if (player:HasCollectible(horsepills.COLLECTIBLE_HORSEPILLS) --[[or game.Challenge == Challenges.CHALLENGE_HORSE]]) and (player:HasCollectible(102) or (player:HasCollectible(85) and player:HasCollectible(252))) then
    return math.random(2049,2061)
	end
end)

horsepills:AddCallback(ModCallbacks.MC_USE_PILL, function()
	itempickedup = false
end)

horsepills:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, horsepills.onPillSpawn, PickupVariant.PICKUP_PILL)
horsepills:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, horsepills.onPillSpawn, PickupVariant.PICKUP_PILL)
horsepills:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, horsepills.onItemGet, PickupVariant.PICKUP_COLLECTIBLE)
