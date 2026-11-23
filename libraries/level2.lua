local level2 = {}

level2.__index = level2
NPC = require 'libraries/npc'
--narrator = require 'libraries/narrator'
collisionFunctions = require 'libraries/collision'
sharkKing = require 'libraries/kingShark'

function level2.new(map, camera, narrator)
	local self = setmetatable({}, level2)
	self.map = map
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	self.narrator = narrator


	-- 1. Load background music as a "stream" (saves RAM by streaming from disk)
	bgMusic2 = love.audio.newSource("audio/KingSharkTheme.mp3", "stream")

	-- 3. Configure the background music to loop continuously
	bgMusic2:setLooping(true)



	--Initialize NPC list
	allLvl2NPCs = {}






	--Initialize Narrator Character list
	allLvl2Dialogue = {}




	--Interaction Distance
	interactRange = 80

	--Nearby NPC
	nearbyNPC = nil --nil = nothing is here


	--Initialize Enemies
	allLvl2Enemies = {}
	table.insert(allLvl2Enemies, sharkKing.new('sprites/KingSharkSpriteSheet.png', 400, 400, 300, 300, 3000, "King Shark", 64, 32, "audio/sharkAttackSound.mp3", 5))
	changeLevels = false


	levelComplete = false

	return self
end

function level2:checkLevelDone()
	return changeLevels
end

function level2:cleanup()
	bgMusic2:stop()
end


function level2:toggleLevelDone()
	changeLevels = not changeLevels
end

function level2:getEnemies() 
	return allLvl2Enemies
end

function level2:getNarrator() 
	return self.narrator
end

function level2:getLevelComplete() 
	return levelComplete
end


function level2:update(dt, player, map, camera)
	local isTalking = self.narrator:isOpen()


	--LUA NOTE: the '_' before 'character' means we no need the key, just the value
	--Update all NPCS
	for _, character in pairs(allLvl2NPCs) do
		character:update(dt)
	end

	--Update all Enemies + Detect/Apply Player Damage
	for _, character in pairs(allLvl2Enemies) do
		character:update(dt, player)
		--Player overlaps => take damage + "knockback"
		if (collisionFunctions.AABB(player:getLeft(), player:getLeft() + player:getWidth(), player:getTop(), player:getTop() + player:getHeight(), character.x, character.x + character.width, character.y, character.y + character.height)) then
			player:setHealth(math.max(player:getHealth() - 10, 0))
			character.attackSound:play()
			if (player:getDirection() == "left") then
				player:setX(player:getLeft() + 100)
			else
				player:setX(player:getLeft() - 100)
			end
		end
	end


	--Try to locate an NPC but only if you aren't talking
	if isTalking then
		nearbyNPC = nil
	else
		nearbyNPC = NPC.findNearestNPC(self.narrator, player)
	end



	--Remove dead enemies

	--initialize, # means length of table, end value, step size
	-- for (int i = allEnemies.size(); i >= 1; i--)
	for i = #allLvl2Enemies, 1, -1 do
		if (allLvl2Enemies[i].health <= 0) then
			if (allLvl2Enemies[i].name == "King Shark") then
				levelComplete = true
			end
			table.remove(allLvl2Enemies, i)
			
		end
	end




	player:update(dt, map, isTalking, camera)
	self.narrator:update(dt)

end

function level2:draw(player, map, camera)
	--Attatch camera for all this
	camera:attach()

	--Draw map/player
	map:drawLayer(map.layers["Platforms"])
	map:drawLayer(map.layers["JumpThroughPlatforms"])
	map:drawLayer(map.layers["Background"])
	map:drawLayer(map.layers["Buildings"])
	map:drawLayer(map.layers["Foliage"])
	player:draw()

	--Draw NPCs
	for _, character in pairs(allLvl2NPCs) do
		character:draw()
	end


	--Draw Enemies
	for _, character in pairs(allLvl2Enemies) do
		if (character.health >= 0) then
			if (character.damagedSinceLastFrame and (character.damagedFrames <= character.damageTime)) then
				love.graphics.setColor(1, 0, 0)
				character.damagedFrames = character.damagedFrames + 1
				if (character.damagedFrames >= character.damageTime) then
					character.damagedFrames = 0
					character.damagedSinceLastFrame = false
				end
			end
			character:draw()
			love.graphics.setColor(1, 1, 1)
		end
	end

--	love.graphics.print("# enemies alive are " .. #allLvl2Enemies, 200, 500)

	--If there is NPC nearby, detect that and open dialogue
	if (nearbyNPC) then
		nearbyNPC:drawInteractionPrompt()
		--drawInteractionPrompt(nearbyNPC)
	end

	--Detatch camera for all this
	camera:detach()

	player:drawHealthBar()


	--Draw narrator
	self.narrator.draw()


end

function level2:startup()
	-- 4. Play the background music immediately
	bgMusic2:play()
	player:setX(200)
	player:setY(400)
end

function level2:restart()
	--ReInitialize NPC list
	allLvl2NPCs = {}

	--Initialize Narrator Character list
	allLvl2Dialogue = {}

	--Nearby NPC
	nearbyNPC = nil --nil = nothing is here


	--Initialize Enemies
	allLvl2Enemies = {}
	table.insert(allLvl2Enemies, sharkKing.new('sprites/KingSharkSpriteSheet.png', 400, 400, 300, 300, 3000, "King Shark", 64, 32, "audio/sharkAttackSound.mp3", 5))
	
	bgMusic2:stop()
	bgMusic2:play()
	player:setX(200)
	player:setY(400)


end



return level2
