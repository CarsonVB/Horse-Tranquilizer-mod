local horsepills = RegisterMod("Horse Pills", 1)
local RECOMMENDED_SHIFT_IDX = 35
local game = Game()
local rng = RNG()
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
	local seeds = game:GetSeeds()
	local startSeed = seeds:GetStartSeed()
	rng:SetSeed(startSeed, RECOMMENDED_SHIFT_IDX)
--someoneHasHorseT = false
end)

--takes the ID of a pill that the game is trying to spawn, and adds 2048 to it, since all horse pill IDs are 2048 + the original ID
function horsepills:onPillSpawn(entity)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if (player:HasCollectible(horsepills.COLLECTIBLE_HORSEPILLS) --[[or game:Challenge == Challenges.CHALLENGE_HORSE]]) and entity.PickupVariant == PICKUP_PILL and entity.SubType <= 2047 then
			horsepill = 2048 + entity.SubType
			entity:Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,horsepill,true)
		end
	end
end

--spawns pill when item is picked up
function horsepills:onItemGet(entity)
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		--local animName = string.sub((player:GetSprite():GetAnimation()), 1, 6)
		if --[[entity.PickupVariant == PICKUP_COLLECTIBLE and]] entity.SubType == horsepills.COLLECTIBLE_HORSEPILLS and entity.Price == 0 --[[animName == "Pickup"]] then
			--print("horse T picked up")
			local pillid
			local pill1 = player:GetPill(0)
			local pill2 = player:GetPill(1)
			if pill1 > 0 and pill1 < 2048 then
				player:SetPill(0, pill1+2048)
			end
			if pill2 > 0 and pill2 < 2048 then
				player:SetPill(1, pill2+2048)
			end
			if itempickedup == false then
				itempickedup = true
				--golden pills are a .7% chance, and a golden horse pill is .1% chance, since all pills are horse pills, then it should be .8% chance
				if (rng:RandomInt(999) >= 7) then
					pillid = (rng:RandomInt(12) + 2049)
				else
					pillid = 2062
				end
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, pillid, Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true), Vector.Zero, player)
			end
		end
	end
end

--this is a really stupid way to do this because im not using the same randomization seed to determine what pill is generated, but idk how else to change pills that get added directly to player's inventory into horse pills nor do i know the randomization used to detemine pickup types/values
horsepills:AddCallback(ModCallbacks.MC_GET_PILL_COLOR, function()
	local currPlayers = game:GetNumPlayers() - 1
	for i = 0, currPlayers do
	  if Isaac.GetPlayer(i):HasCollectible(horsepills.COLLECTIBLE_HORSEPILLS) then
	    for j = 0, currPlayers do
	      local player_any = Isaac.GetPlayer(j)
	      if (player_any:HasCollectible(102) or (player_any:HasCollectible(85) and player_any:HasCollectible(252))) then
	        if (rng:RandomInt(999) >= 7) then
	          pillid = (rng:RandomInt(12) + 2049)
	          return pillid
	         else
	           pillid = 2062
	           return pillid
	         end
	      end
	    end
	  end
	end
end)

horsepills:AddCallback(ModCallbacks.MC_USE_PILL, function()
	for i = 0, game:GetNumPlayers() - 1 do
		--ensures tainted isaac can't abuse the item
		if (Isaac.GetPlayer(i):GetPlayerType() == 21) then
			return
		end
	end
	--allows you to get a horse pill when picking up the item for a 2nd time, for instance, 2 different item pools
	itempickedup = false
end)

horsepills:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, horsepills.onPillSpawn, PickupVariant.PICKUP_PILL)
horsepills:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, horsepills.onPillSpawn, PickupVariant.PICKUP_PILL)
horsepills:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, horsepills.onItemGet, PickupVariant.PICKUP_COLLECTIBLE)
