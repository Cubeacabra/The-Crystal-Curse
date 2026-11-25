local level1 = {}

level1.__index = level1
NPC = require 'libraries/npc'
collisionFunctions = require 'libraries/collision'

function level1.new(map, camera, narrator)
	local self = setmetatable({}, level1)
	self.map = map
	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()
	self.narrator = narrator

	-- 1. Load background music as a "stream" (saves RAM by streaming from disk)
	bgMusic = love.audio.newSource("audio/LobsterVillage80k.wav", "stream")

	-- 3. Configure the background music to loop continuously
	bgMusic:setLooping(true)



	--Initialize NPC list
	allLvl1NPCs = {}


	--Initialize Each NPC
	----function NPC.new(spriteSheetPath, x, y, wanderX, wanderY, health, name, spriteWidth, spriteHeight, attackSound)

	allLvl1NPCs.mayorLobster = NPC.new('sprites/MayorLobsterSpriteSheet.png', 900, 190, 70, 0, 1000, "Mayor Lobster", 32, 32, nil, 3) --Spritesheet, x, y, wanderx, wandery, health, name
	allLvl1NPCs.friendLobster = NPC.new('sprites/RegularLobsterSpriteSheet.png', 300, 770, 70, 0, 1000, "Mayor Lobster", 32, 32, nil, 3) --Spritesheet, x, y, wanderx, wandery, health, name
	allLvl1NPCs.basicLobster = NPC.new('sprites/RegularLobsterSpriteSheet.png', 700, 770, 70, 0, 1000, "Mayor Lobster", 32, 32, nil, 3) --Spritesheet, x, y, wanderx, wandery, health, name
	allLvl1NPCs.scientistLobster = NPC.new('sprites/ScientistLobsterSpriteSheet.png', 1000, 770, 70, 0, 1000, "Mayor Lobster", 32, 32, nil, 3) --Spritesheet, x, y, wanderx, wandery, health, name




	--Initialize Narrator Character list
	allLvl1Dialogue = {}


	allLvl1Dialogue.mayorLobster = self.narrator:newCharacter("Mayor Lobster:", "sprites/LobsterMayor.png") -- name, sprite
	allLvl1Dialogue.friendLobster = self.narrator:newCharacter("Luke the Lobster", "sprites/LobsterFriend.png") -- name, sprite
	allLvl1Dialogue.basicLobster = self.narrator:newCharacter("Loretta the Lobster", "sprites/LobsterFriend.png") -- name, sprite
	allLvl1Dialogue.scientistLobster = self.narrator:newCharacter("Scientist Lobster", "sprites/LobsterScientist.png") -- name, sprite




	self.narrator:bindNPC(allLvl1NPCs.mayorLobster, allLvl1Dialogue.mayorLobster, "MayorLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)
	self.narrator:bindNPC(allLvl1NPCs.friendLobster, allLvl1Dialogue.friendLobster, "FriendLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)
	self.narrator:bindNPC(allLvl1NPCs.basicLobster, allLvl1Dialogue.basicLobster, "BasicLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)
	self.narrator:bindNPC(allLvl1NPCs.scientistLobster, allLvl1Dialogue.scientistLobster, "ScientistLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)




	OG_narrAddress = tostring(self.narrator)
	OG_listAddress = tostring(self.narrator._boundNPCs)


	--Interaction Distance
	interactRange = 80

	--Nearby NPC
	nearbyNPC = nil --nil = nothing is here


	--Initialize Enemies
	allLvl1Enemies = {}

	table.insert(allLvl1Enemies, NPC.new('sprites/SharkSpriteSheet.png', 800, 550, 80, 0, 120, "Demo Shark", 64, 32, "audio/sharkAttackSound.mp3", 2))




	changeLevels = false
	tagCrapRunning = false

	self.narrator.onTag = function(tag)
		tagCrapRunning = true
		storedTag = tag
		if (tag == "Mayor Lobster Success") then
			changeLevels = true
		elseif (tag == "Mayor Lobster Failure") then
			player:setDieAfterTalk(true)
		end
	end



	return self
end

function level1:checkLevelDone()
	return changeLevels
end

function level1:cleanup()
	bgMusic:stop()
end

function level1:toggleLevelDone()
	changeLevels = not changeLevels
end

function level1:getEnemies() 
	return allLvl1Enemies
end

function level1:getNarrator() 
	return self.narrator
end


function level1:update(dt, player, map, camera)
	local isTalking = self.narrator:isOpen()

	--LUA NOTE: the '_' before 'character' means we no need the key, just the value
	charCount = 0
	--Update all NPCS
	for _, character in pairs(allLvl1NPCs) do
		charCount = charCount + 1
		character:update(dt)
		--myX = character.x
		--myY = character.y
	end

	--Update all Enemies + Detect/Apply Player Damage
	for _, character in pairs(allLvl1Enemies) do
		character:update(dt)
		--Player overlaps => take damage + "knockback"
		if ((player:getDamageCooldown() <= 0) and collisionFunctions.AABB(player:getLeft(), player:getLeft() + player:getWidth(), player:getTop(), player:getTop() + player:getHeight(), character.x, character.x + character.width, character.y, character.y + character.height)) then
			player:setHealth(math.max(player:getHealth() - 10, 0))
			character.attackSound:play()
		--[[	if (player:getDirection() == "left") then
				player:setX(player:getLeft() + 100)
			else
				player:setX(player:getLeft() - 100)
			end
			]]

			player:setInvFrames()
		end
	end

	--Try to locate an NPC but only if you aren't talking
	if isTalking then
		nearbyNPC = nil
	elseif charCount > 0 then
		nearbyNPC = NPC.findNearestNPC(self.narrator, player)
	end



	--Remove dead enemies

	--initialize, # means length of table, end value, step size
	-- for (int i = allEnemies.size(); i >= 1; i--)
	for i = #allLvl1Enemies, 1, -1 do
		if (allLvl1Enemies[i].health <= 0) then
			table.remove(allLvl1Enemies, i)
		end
	end




	player:update(dt, map, isTalking, camera)
	self.narrator:update(dt)

end

function level1:draw(player, map, camera)
	--Attatch camera for all this
	camera:attach()

	--Draw map/player
	map:drawLayer(map.layers["Platforms"])
	map:drawLayer(map.layers["JumpThroughPlatforms"])
	map:drawLayer(map.layers["Background"])
	map:drawLayer(map.layers["Buildings"])
	map:drawLayer(map.layers["Foliage"])

	if (player:getDamageCooldown() > 0) then
		local testVal = math.floor(10 * player:getDamageCooldown())
		if (testVal % 4 == 0 or testVal % 4 == 1) then
			love.graphics.setColor(1, 127/255, 127/255)
			player:draw()
			love.graphics.setColor(1, 1, 1)
		else
			love.graphics.setColor(1, 1, 1)
			player:draw()
		end

	else
		player:draw()
	end

	--love.graphics.print(player:getDamageCooldown(), 400, 400)

	--Draw NPCs
	for _, character in pairs(allLvl1NPCs) do
		character:draw()
	end

	--Draw Enemies
	for _, character in pairs(allLvl1Enemies) do
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
		--[[if (character.health >= 0) then
		character:draw()
		end]]
	end

	--love.graphics.print("# NPCS good alive are " .. #allLvl1NPCs, 200, 500)
	--[[if (tagCrapRunning) then
	love.graphics.print("storedTag is " .. tostring(storedTag), 200, 450)
	else
	love.graphics.print("TAG NO RUN", 200, 450)
	end]]

	--If there is NPC nearby, detect that and open dialogue
	if (nearbyNPC) then
		nearbyNPC:drawInteractionPrompt(player)
		--drawInteractionPrompt(nearbyNPC)
	end

	--Detatch camera for all this
	camera:detach()

	player:drawHealthBar()


	--Draw narrator
	self.narrator.draw()


end

function level1:startup()
	-- 4. Play the background music immediately
	bgMusic:play()
	player:setX(416)
	player:setY(700)
end

function level1:restart()
	--ReInitialize NPC list
	allLvl1NPCs = {}


	self.narrator._boundNPCs = {}

	--Initialize Each NPC
	allLvl1NPCs.mayorLobster = NPC.new('sprites/MayorLobsterSpriteSheet.png', 900, 190, 70, 0, 1000, "Mayor Lobster", 32, 32, nil, 3) --Spritesheet, x, y, wanderx, wandery, health, name
	allLvl1NPCs.friendLobster = NPC.new('sprites/RegularLobsterSpriteSheet.png', 300, 770, 70, 0, 1000, "Mayor Lobster", 32, 32, nil, 3) --Spritesheet, x, y, wanderx, wandery, health, name
	allLvl1NPCs.basicLobster = NPC.new('sprites/RegularLobsterSpriteSheet.png', 700, 770, 70, 0, 1000, "Mayor Lobster", 32, 32, nil, 3) --Spritesheet, x, y, wanderx, wandery, health, name
	allLvl1NPCs.scientistLobster = NPC.new('sprites/RegularLobsterSpriteSheet.png', 1000, 770, 70, 0, 1000, "Mayor Lobster", 32, 32, nil, 3) --Spritesheet, x, y, wanderx, wandery, health, name




	--Initialize Narrator Character list
	allLvl1Dialogue = {}


	allLvl1Dialogue.mayorLobster = self.narrator:newCharacter("Mayor Lobster", "sprites/LobsterMayor.png")--, name, sprite
	allLvl1Dialogue.friendLobster = self.narrator:newCharacter("Luke the Lobster", "sprites/LobsterFriend.png") -- name, sprite
	allLvl1Dialogue.basicLobster = self.narrator:newCharacter("Loretta the Lobster", "sprites/LobsterFriend.png") -- name, sprite
	allLvl1Dialogue.scientistLobster = self.narrator:newCharacter("Scientist Lobster", "sprites/LobsterScientist.png") -- name, sprite


	self.narrator:bindNPC(allLvl1NPCs.mayorLobster, allLvl1Dialogue.mayorLobster, "MayorLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)
	self.narrator:bindNPC(allLvl1NPCs.friendLobster, allLvl1Dialogue.friendLobster, "FriendLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)
	self.narrator:bindNPC(allLvl1NPCs.basicLobster, allLvl1Dialogue.basicLobster, "BasicLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)
	self.narrator:bindNPC(allLvl1NPCs.scientistLobster, allLvl1Dialogue.scientistLobster, "ScientistLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)


	--Nearby NPC
	nearbyNPC = nil --nil = nothing is here


	--Initialize Enemies
	allLvl1Enemies = {}
	table.insert(allLvl1Enemies, NPC.new('sprites/SharkSpriteSheet.png', 800, 550, 80, 0, 120, "Demo Shark", 64, 32, "audio/sharkAttackSound.mp3", 2))
	
	changeLevels = false

	bgMusic:stop()
	bgMusic:play()


end



return level1
