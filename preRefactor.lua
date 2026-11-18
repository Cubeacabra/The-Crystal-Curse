


function love.load()
	--Setup Libraries
	anim8 = require 'libraries/anim8'
	camera = require 'libraries/camera'
	sti = require 'libraries/sti'
	NPC = require 'libraries/npc'
	narrator = require 'libraries/narrator'
	playerLib = require 'libraries/player'
	level1 = require 'libraries/level1'
	collisionFunctions = require 'libraries/collision'


	--NOTE: Music Code from Google AI

	-- 1. Load background music as a "stream" (saves RAM by streaming from disk)
	bgMusic = love.audio.newSource("audio/LobsterVillage80k.wav", "stream")

	-- 2. Load short sound effects as "static" (loads fully into RAM for instant playback)
	clickSound = love.audio.newSource("audio/bonk.mp3", "static")

	-- 3. Configure the background music to loop continuously
	bgMusic:setLooping(true)

	-- 4. Play the background music immediately
	bgMusic:play()

	--Make Character Not Blurry
	love.graphics.setDefaultFilter("nearest", "nearest")

	player = playerLib.new(416, 700, 3, 'sprites/LobsterSpriteSheet.png')
	--debugPlayer = playerLib.new(416, 700, 3, 'sprites/DEBUGLobsterSpriteSheet.png')




	--NOW IN player.lua
	--[[
	--Initialize Player Default Values
	player = {}

	--Positions/Scale (units are pixels (other than scaleFactor)
	player.x = 416
	player.y = 700
	player.scaleFactor = 3
	player.width = 32 * player.scaleFactor
	player.height = 32 * player.scaleFactor

	--Movement
	player.vy = 0
	player.jumpForce = -1000
	player.ay = 2500
	player.speed = 5

	--Attacking	
	player.attackRange = 48 --How far left/right to attack
	player.attackCooldown = 0.5 --How long before can attack again
	player.timer = 0 -- The variable that will change to determine if attack cooldown is done yet
	player.health = 100
	player.maxHealth = 100
	]]

	--Setup Maps/Camera
	lobsterVillageMap = sti('maps/LobsterVillageMap.lua')
	crystalCaveMap = sti('maps/CrystalCave.lua')
	currentMap = lobsterVillageMap;
	--currentMap = crystalCaveMap;



	cam = camera()

	lobsterVillage = level1.new(lobsterVillageMap, cam)
	currentLevel = lobsterVillage

	--NOW IN player.lua
	--[[

	--Player Sprites
	player.spriteSheet = love.graphics.newImage('sprites/LobsterSpriteSheet.png')
	player.spriteSheetDEBUG = love.graphics.newImage('sprites/DEBUGLobsterSpriteSheet.png')


	--Setup Player Anim
	--player.grid = anim8.newGrid(32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
	player.grid = anim8.newGrid(32, 32, player.spriteSheetDEBUG:getWidth(), player.spriteSheetDEBUG:getHeight())
	player.direction = 'none'

	--DEMO: anim8.newGrid(frameWidth, frameHeight, imageWidth, imageHeight, left, top, border)
	player.animations = {}
	player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2) --grid cells, which row, how long per frame
	player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.1) --grid cells, which row, how long per frame
	player.animations.up = anim8.newAnimation(player.grid('1-4', 1), 0.2) --grid cells, which row, how long per frame
	player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.1) --grid cells, which row, how long per frame
	player.animations.idle = anim8.newAnimation(player.grid('1-4', 1), 0.2) --grid cells, which row, how long per frame

	--Default Anim
	player.anim = player.animations.left

	]]


	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()

	--NOW IN player.lua
	--[[
	--DEBUGGING
	player.debugger = false
	player.debugX = -1
	player.debugY = -1
	player.badX = -1
	player.badY = -1


	]]

	--MOVED TO EACH level#.lua FILE
	--[[

	--Initialize NPC list
	allNPCs = {}


	--Initialize Each NPC
	allNPCs.mayorLobster = NPC.new('sprites/MayorLobsterSpriteSheet.png', 320, 750, 80, 0, 1000, "Mayor Lobster") --Spritesheet, x, y, wanderx, wandery, health, name



	--Init Narrator
	narrator:init()

	--Initialize Narrator Character list
	allDialogue = {}


	allDialogue.mayorLobster = narrator:newCharacter("Mayor Lobster:", "sprites/LobsterMayor.png"), name, sprite


	narrator:bindNPC(allNPCs.mayorLobster, allDialogue.mayorLobster, "MayorLobster") --bindNPC(NPC, NarratorCharacter, InkScriptName)


	--Interaction Distance
	interactRange = 80

	--Nearby NPC
	nearbyNPC = nil --nil = nothing is here


	--Initialize Enemies
	allEnemies = {}
	table.insert(allEnemies, NPC.new('sprites/DemoShark.png', 720, 750, 80, 0, 120, "Demo Shark"))]]

end


--MOVED TO npc.lua
--[[

--Find closest NPC
function findNearestNPC()
local closest, closestDist = nil, interactRange
--List of NPCs in narrator class
for _, npc in ipairs(narrator._boundNPCs) do
local dx = npc.x - player:getLeft()
local dy = npc.y - player:getTop()
local dist = math.sqrt(dx * dx + dy * dy)
if (dist <= closestDist) then
closest = npc
closestDist = dist
end
end

return closest
end]]


--NOW IN collisions.lua
--[[

function platformAt(x, y)
--Get Platforms layer
local layer = currentMap.layers["Platforms"]

--Convert coordinates to tiles
local tx = math.floor(x / currentMap.tilewidth) + 1
local ty = math.floor(y / currentMap.tileheight) + 1


--All Debug Stuff
--player.debugger = (layer.data[ty] and layer.data[ty][tx])	


if layer.data[ty] and layer.data[ty][tx] then
player.debugX = tx
player.debugY = ty
player.badX = x
player.badY = y
end

--Make sure the spot in the layer exist AND there is a tree at that layer
return layer.data[ty] and layer.data[ty][tx]
end



function jumpThroughPlatformAt(x, y)
local layer = currentMap.layers["JumpThroughPlatforms"]
local tx = math.floor(x / currentMap.tilewidth) + 1
local ty = math.floor(y / currentMap.tileheight) + 1

--player.debugger = (layer.data[ty] and layer.data[ty][tx])	



if layer.data[ty] and layer.data[ty][tx] then
player.debugX = tx
player.debugY = ty
player.badX = x
player.badY = y
end
--Make sure the spot in the layer exist AND there is a tree at that layer
return layer.data[ty] and layer.data[ty][tx]
end



function checkCollisionY(oldX, oldY, newPotentialY)
--Get the x positions of the tiles the lobster will overlap
local firstTileX = math.floor(player.x / currentMap.tilewidth)
local lastTileX = math.floor((player.x + player.width - 1) / currentMap.tilewidth)


--Hitting Platform From Below
if (player.vy > 0) then
--Loop through tiles to determine if collision happens
for x = firstTileX, lastTileX do
if platformAt(x * currentMap.tilewidth, newPotentialY + player.height) then --Use newY + height bc we need to check bottom of player
-- Collision detected!
player.y = oldY	
player.vy = 0;
end
end

--Hitting Platform From Above
elseif (player.vy < 0) then
--Loop through tiles to determine if collision happens
for x = firstTileX, lastTileX do
if platformAt(x * currentMap.tilewidth, newPotentialY) then --just use newY bc checking top of player
-- Collision detected!
player.y = oldY	
player.vy = 0;
end
end
end



end

function checkCollisionX(oldX, oldY, newPotentialX)
--Get the x positions of the tiles the lobster will overlap
local firstTileY = math.floor(player.y / currentMap.tilewidth)
local lastTileY = math.floor((player.y + player.height - 1) / currentMap.tilewidth)


--Hitting Platform From Below
if (player.direction == 'right') then
--Loop through tiles to determine if collision happens
for y = firstTileY, lastTileY do
if platformAt(newPotentialX + player.width, y * currentMap.tileheight) then --Use newY + height bc we need to check bottom of player
-- Collision detected!
player.x = oldX	
--player.vy = 0;
return false;
end
end

--Hitting Platform From Above
elseif (player.direction == 'left') then
--Loop through tiles to determine if collision happens
for y = firstTileY, lastTileY do
if platformAt(newPotentialX, y * currentMap.tileheight) then --just use newY bc checking top of player
-- Collision detected!
player.x = oldX	
--player.vy = 0;
return false;
end
end
end
return true;


end


function checkJumpThroughCollisionY(oldX, oldY, newPotentialY)
--See checkCollisionY function for explanation, same code but we only check for collision going down
if (player.vy > 0) then
firstTileX = math.floor(player.x / currentMap.tilewidth)
lastTileX = math.floor((player.x + player.width - 1) / currentMap.tilewidth)

for x = firstTileX, lastTileX do
if jumpThroughPlatformAt(x * currentMap.tilewidth, newPotentialY + player.height) then
-- Collision detected!
player.y = oldY	
player.vy = 0;
end
end

end
end

]]

function attack(enemyList)

	--Get player attack range values
	local attackRangeLeft = player.x
	local attackRangeRight = player.x + player.width
	if player.direction == "left" then
		attackRangeLeft = attackRangeLeft - player.attackRange
	else
		attackRangeRight = attackRangeRight + player.attackRange
	end
	local attackRangeTop = player.y
	local attackRangeBottom = player.y + player.height

	--Loop through all enemies
	for _, character in pairs(enemyList) do
		--Get enemy boundaries values
		local enemyLeft = character.x
		local enemyRight = character.x + character.width
		local enemyTop = character.y
		local enemyBottom = character.y + character.height




		--	if (attackRangeLeft <= enemyRight) and (attackRangeBottom >= enemyTop) and (enemyLeft <= attackRangeRight) and (enemyBottom >= attackRangeTop) then
		if (collisionFunctions.AABB(attackRangeLeft, attackRangeRight, attackRangeTop, attackRangeBottom, enemyLeft, enemyRight, enemyTop, enemyBottom)) then
			clickSound:play()
			--	player.debugger = true
			character.health = character.health - 50
			--actual attacking goes here
		end

		--	player.debugger = false




	end


end



--MOVED TO collision.lua
--[[

function AABB(L1, R1, T1, B1, L2, R2, T2, B2)
return ((L1 <= R2) and (B1 >= T2) and (L2 <= R1) and (B2 >= T1))

end
]]

function love.update(dt)
	--	if player.health <= 0 then
	--		love.load()
	--	end


	--NOW IN player.lua
	--[[	--To Determine If Idle
	local isMoving = false
	]]
	--Determine if Dialogue Open

	--MOVED TO level1.lua
	--local isTalking = narrator:isOpen()


	--NOW IN player.lua
	--[[
	--Store For Reset Position Upon Collision
	local oldX, oldY = player.x, player.y


	--Only run movement code if player not in dialogue
	if not isTalking then
	--Move Right
	if love.keyboard.isDown("d") then
	--Set direction/anim first
	player.direction = 'right'
	player.anim = player.animations.right
	--If there is no collision, update player position accordingly
	if (checkCollisionX(oldX, oldY, player.x + player.speed)) then
	player.x = player.x + player.speed
	isMoving = true
	end
	end

	--Move Left
	if love.keyboard.isDown("a") then
	--Set direction/anim first
	player.direction = 'left'
	player.anim = player.animations.left
	--If there is no collision, update player position accordingly
	if (checkCollisionX(oldX, oldY, player.x - player.speed)) then
	player.x = player.x - player.speed
	isMoving = true
	end
	end


	--Update Player Velocity
	player.vy = player.vy + player.ay * dt


	--Update Player Position (Potentially)
	newPotentialY = player.y + player.vy * dt


	--Make Sure Player Y Is Valid
	checkCollisionY(oldX, oldY, newPotentialY)
	checkJumpThroughCollisionY(oldX, oldY, newPotentialY)

	--Update player y
	player.y = player.y + player.vy * dt


	end --End branch about only move when not talking

	--Set Anim To Idle If Not Moving
	if isMoving == false then
	player.anim = player.animations.idle
	player.direction = 'none'
	end



	--Update Player Animation
	player.anim:update(dt)



	--Set/Clamp camera so no scroll offscreen
	cam:lookAt(player.x, player.y)
	local width,height = love.graphics.getDimensions()

	--map width/height in pixels
	local mapWidth = currentMap.width * currentMap.tilewidth
	local mapHeight = currentMap.height * currentMap.tileheight

	cam.x = math.max(width / 2, math.min(cam.x,mapWidth - width/2))
	cam.y = math.max(height / 2, math.min(cam.y,mapHeight - height/2))


	]]


	--MOVED TO level1.lua
	--[[
	--LUA NOTE: the '_' before 'character' means we no need the key, just the value
	--Update all NPCS
	for _, character in pairs(allNPCs) do
	character:update(dt)
	end

	--Update all Enemies + Detect/Apply Player Damage
	for _, character in pairs(allEnemies) do
	character:update(dt)
	--Player overlaps => take damage + "knockback"
	if (AABB(player:getLeft(), player:getLeft() + player:getWidth(), player:getTop(), player:getTop() + player:getHeight(), character.x, character.x + character.width, character.y, character.y + character.height)) then
	player:setHealth(math.max(player:getHealth() - 10, 0))
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
	nearbyNPC = findNearestNPC()
	end



	--Remove dead enemies

	--initialize, # means length of table, end value, step size
	-- for (int i = allEnemies.size(); i >= 1; i--)
	for i = #allEnemies, 1, -1 do
	if (allEnemies[i].health <= 0) then
	table.remove(allEnemies, i)
	end
	end


	player:update(dt, currentMap, isTalking, cam)


	narrator:update(dt)
	]]
	--	lobsterVillage
	lobsterVillage:update(dt, player, currentMap, cam)
end
--MOVED TO npc.lua
--[[
function drawInteractionPrompt(npc)
love.graphics.setColor(1,1,1)
love.graphics.print("Press E to Talk", npc.x - 25, npc.y - 25)
end
]]
function love.draw()

	lobsterVillage:draw(player, currentMap, cam)

	--MOVED TO level1.lua
	--[[
	--Attatch camera for all this
	cam:attach()

	--Draw map/player
	currentMap:drawLayer(currentMap.layers["Platforms"])
	currentMap:drawLayer(currentMap.layers["JumpThroughPlatforms"])
	currentMap:drawLayer(currentMap.layers["Background"])
	currentMap:drawLayer(currentMap.layers["Buildings"])
	currentMap:drawLayer(currentMap.layers["Foliage"])
	player:draw()
	]]



	--NOW IN player.lua
	--	player.anim:draw(player.spriteSheetDEBUG, player.x, player.y, 0, 3)


	--player.anim:draw(player.spriteSheet, player.x, player.y, 0, 3)





	--allNPCs.mayorLobster:draw()

	--MOVED TO level1.lua
	--[[
	--Draw NPCs
	for _, character in pairs(allNPCs) do
	character:draw()
	end

	--Draw Enemies
	for _, character in pairs(allEnemies) do
	if (character.health >= 0) then
	character:draw()
	end
	end

	love.graphics.print("# enemies alive are " .. #allEnemies, 200, 500)

	--If there is NPC nearby, detect that and open dialogue
	if (nearbyNPC) then
	drawInteractionPrompt(nearbyNPC)
	end

	--Detatch camera for all this
	cam:detach() 

	player:drawHealthBar()
	]]



	--NOW IN player.lua
	--[[
	--Make graphics black + draw for background bar
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 50, 50, 102, 22)

	--Make graphics red + draw for health bar
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", 51, 51, 100 * (player.getHealth / player.getMaxHealth), 20)

	--Make color white again (default) so no tint stuff
	love.graphics.setColor(1, 1, 1)
	]]
	--Draw stuff that not affected by camera here



	--MOVED TO level1.lua
	--[[
	--Draw narrator
	narrator.draw()
	]]





	--DEBUG STUFF
	--[[	if player.debugger then
	love.graphics.print("TRUE", 50, 50)
	love.graphics.print("X tile: " .. player.debugX, 50, 70)
	love.graphics.print("Y tile: " .. player.debugY, 50, 90)
	love.graphics.print("Bad X val: " .. player.badX, 50, 110)
	love.graphics.print("Bad Y val: " .. player.badY, 50, 130)

	else 
	love.graphics.print("FALSE", 50, 50)
	end
	love.graphics.print("Player X: " .. player.debugX, 50, 150)
	love.graphics.print("Player Y: " .. player.debugY, 50, 170)


	]]


	--[[	if player.debugger then
	player.y = 100
	love.graphics.print("TRUE", 50, 50)
	else
	love.graphics.print("FALSE", 50, 50)
	end
	]]


end



function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if key == 'space' then
		player:setVy(player:getJumpForce())
	end

	--Narrator is open
	if currentLevel:getNarrator():isOpen() then
		--Do said action
		if key == "space" or key == "return" then
			currentLevel:getNarrator():onAction()

			--Go to previous option
		elseif key == "up" or key == "w" or key == "a" then
			currentLevel:getNarrator():prevOption()

			--Go to next Option
		elseif key == "down" or key == "s" or key == "d" then
			currentLevel:getNarrator():nextOption()
		end
	else
		if key == "e" and nearbyNPC then
			currentLevel:getNarrator():startScript(nearbyNPC)
		end
	end
end


function love.mousepressed(x, y, button)
	if button == 1 then --1 = left click
		--	player.debugger = false
		attack(currentLevel:getEnemies())
	end
end
