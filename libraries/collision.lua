local collision = {}



function collision.platformAt(x,y, map)
	--Get Platforms layer
	local layer = map.layers["Platforms"]

	--Convert coordinates to tiles
	local tx = math.floor(x / map.tilewidth) + 1
	local ty = math.floor(y / map.tileheight) + 1


	--All Debug Stuff
	--[[player.debugger = (layer.data[ty] and layer.data[ty][tx])


	if layer.data[ty] and layer.data[ty][tx] then
	player.debugX = tx
	player.debugY = ty
	player.badX = x
	player.badY = y
	end]]

	--Make sure the spot in the layer exist AND there is a tree at that layer
	return layer.data[ty] and layer.data[ty][tx]
end

function collision.jumpThroughPlatformAt(x, y, map) 
	local layer = map.layers["JumpThroughPlatforms"]
	local tx = math.floor(x / map.tilewidth) + 1
	local ty = math.floor(y / map.tileheight) + 1

	--player.debugger = (layer.data[ty] and layer.data[ty][tx])



	--[[if layer.data[ty] and layer.data[ty][tx] then
	player.debugX = tx
	player.debugY = ty
	player.badX = x
	player.badY = y
	end]]
	--Make sure the spot in the layer exist AND there is a tree at that layer
	return layer.data[ty] and layer.data[ty][tx]


end

function collision.checkCollisionY(oldY, newPotentialY, player, map)
	--Get the x positions of the tiles the lobster will overlap
	local firstTileX = math.floor(player:getLeft() / map.tilewidth)
	local lastTileX = math.floor((player:getLeft() + player:getWidth() - 1) / map.tilewidth)


	--Hitting Platform From Below
	--Loop through tiles to determine if collision happens
	for x = firstTileX, lastTileX do
		if (player:getVy() > 0 and collision.platformAt(x * map.tilewidth, newPotentialY + player:getHeight(), map)) or (player:getVy() < 0 and collision.platformAt(x * map.tilewidth, newPotentialY, map) ) then
			-- Collision detected!
			--Change so player isn't jump no more ONLY if they collide on ground
			if (player:getVy() > 0) then
				player:setJumping(false);
			end
			player:setY(oldY)
			player:setVy(0);

		end

	end
end


function collision.checkJumpThroughCollisionY(oldY, newPotentialY, player, map)
	--Get the x positions of the tiles the lobster will overlap
	local firstTileX = math.floor(player:getLeft() / map.tilewidth)
	local lastTileX = math.floor((player:getLeft() + player:getWidth() - 1) / map.tilewidth)


	--Hitting Platform From Below
	--Loop through tiles to determine if collision happens
	for x = firstTileX, lastTileX do
		if (player:getVy() > 0 and collision.jumpThroughPlatformAt(x * map.tilewidth, newPotentialY + player:getHeight(), map)) then
			-- Collision detected!
			--Change so player isn't jump no more ONLY if they collide on ground
			if (player:getVy() > 0) then
				player:setJumping(false);
			end
			player:setY(oldY)
			player:setVy(0);
		end

	end
end

function collision.checkCollisionX(oldX, newPotentialX, player, map)
	--Get the x positions of the tiles the lobster will overlap
	local firstTileY = math.floor(player:getTop() / map.tileheight)
	local lastTileY = math.floor((player:getTop() + player:getHeight() - 1) / map.tileheight)


	--Hitting Platform From Below
	--Loop through tiles to determine if collision happens
	for y = firstTileY, lastTileY do
		if (player:getDirection() == "right" and collision.platformAt(newPotentialX + player:getWidth(), y * map.tileheight, map)) or (player:getDirection() == "left" and collision.platformAt(newPotentialX, y * map.tileheight, map)) then 
			-- Collision detected!
			player:setX(oldX);
			return false;
		end
	end

	return true;

end

function collision.AABB(L1, R1, T1, B1, L2, R2, T2, B2)
        return ((L1 <= R2) and (B1 >= T2) and (L2 <= R1) and (B2 >= T1))

end



return collision


