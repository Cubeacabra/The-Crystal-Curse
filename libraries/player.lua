local collisionFunctions = require 'libraries/collision'

local player = {}

player.__index = player


function player.new(x, y, scaleFactor, sprite)
	local self = setmetatable({}, player)



	--Initialize Position/Scale
	self.x = x
	self.y = y
	self.scaleFactor = scaleFactor
	self.width = 32 * scaleFactor
	self.height = 32 * scaleFactor

	--Initialize Physics
	self.vy = 0
	self.jumpForce = -1000
	self.ay = 2500
	self.speed = 5


	--Initialize Attack Variables
	self.attackRange = 80
	self.attackCooldown = 0.5
	self.attackTimer = 0
	self.health = 100
	self.maxHealth = 100
	self.dieAfterTalk = false

	--Save starting values in case die
	self.startingX = x
	self.startingY = y

	--Initialize Spritesheets
	self.spriteSheet = love.graphics.newImage(sprite)

	--Setup Spritesheet Grid
	self.grid = anim8.newGrid(32, 32, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())


	--Setup Animations
	--DEMO: anim8.newGrid(frameWidth, frameHeight, imageWidth, imageHeight, left, top, border)
	self.animations = {}
	--UNUSED FOR NOW  self.animations.down = anim8.newAnimation(self.grid('1-4', 1), 0.2) --grid cells, which row, how long per frame
	--UNUSED FOR NOW  self.animations.up = anim8.newAnimation(self.grid('1-4', 1), 0.2) --grid cells, which row, how long per frame
	self.animations.idle = anim8.newAnimation(self.grid('1-4', 1), 0.2) --grid cells, which row, how long per frame
	self.animations.left = anim8.newAnimation(self.grid('1-4', 2), 0.1) --grid cells, which row, how long per frame
	self.animations.right = anim8.newAnimation(self.grid('1-4', 3), 0.1) --grid cells, which row, how long per frame

	--Default Anim/Direction
	self.anim = self.animations.left
	self.direction = 'none'


	--Joy Stick Stuff
	local joyStick
	useKeyboardControls = true

	canMove = false

	return self
end


--[[

Getters
Purpose: Grab the value of a variable in player
Parameters: N/A
Returns: The value of a requested player variable

]]


function player:getHealth()
	return self.health
end

function player:getMaxHealth()
	return self.maxHealth
end

function player:getLeft()
	return self.x
end

function player:getRight()
	return self.x + self.width
end

function player:getTop()
	return self.y
end

function player:getBottom()
	return self.y + self.height
end

function player:getWidth()
	return self.width
end

function player:getHeight()
	return self.height
end

function player:getDirection()
	return self.direction
end

function player:getVy()
	return self.vy
end

function player:getJumpForce()
	return self.jumpForce
end

function player:getUseKeyboardControls() 
	return useKeyboardControls
end

function player:getJoyStick() 
	return joyStick
end

function player:getDieAfterTalk() 
	return self.dieAfterTalk
end



--[[

Setters
Purpose: Set the value of a variable in player
Parameters:
- Varies, but represents the value you want to replace a player variable with
Returns: N/A

]]

function player:setHealth(health)
	self.health = health
end

function player:setX(x)
	self.x = x
end


function player:setY(y)
	self.y = y
end


function player:setDirection(direction)
	if (direction == "right" or direction == "left") then
		self.direction = direction
	end
end

function player:setVy(vy)
	self.vy = vy
end

function player:setDieAfterTalk(flag) 
	self.dieAfterTalk = flag
end




function love.joystickadded(j)
	joystick = j
	useKeyboardControls = false
end



--[[
--
-- Purpose: update things that happen every frame (backend stuff only, no drawing)
-- Parameters:
-- 	@param dt => id assume float/double? some kind of number for elapsed time
-- 	@param map => map object, current level name
-- 	@param isTalking => bool, whether the player is in dialogue
-- 	@param cam => camera (special table or struct or something idk its from a library)
-- Returns: N/A
--]]


function player:update(dt, map, isTalking, cam)
	--To Determine If Idle
	local isMoving = false

	--      --Determine if Dialogue Open
	--    local isTalking = narrator:isOpen()

	--Store For Reset Position Upon Collision
	local oldX, oldY = self.x, self.y

	canMove = not isTalking

	--Only run movement code if player not in dialogue
	if not isTalking then
		if (useKeyboardControls) then
			--Move Right
			if love.keyboard.isDown("d") then
				--Set direction/anim first
				self.direction = 'right'
				self.anim = self.animations.right
				--If there is no collision, update player position accordingly
				if (collisionFunctions.checkCollisionX(oldX, self.x + self.speed, self, map)) then
					self.x = self.x + self.speed
					isMoving = true
				end


				--Move Left
			elseif love.keyboard.isDown("a") then
				--Set direction/anim first
				self.direction = 'left'
				self.anim = self.animations.right
				--If there is no collision, update player position accordingly
				if (collisionFunctions.checkCollisionX(oldX, self.x - self.speed, self, map)) then
					self.x = self.x - self.speed
					isMoving = true
				end
			end

		else 
			if (joystick and joystick:isGamepad()) then
				local stickX = joystick:getGamepadAxis("leftx")
				if stickX > 0.2 then
					self.direction = 'right'
					self.anim = self.animations.right
					--If there is no collision, update player position accordingly
					if (collisionFunctions.checkCollisionX(oldX, self.x + self.speed, self, map)) then
						self.x = self.x + self.speed
						isMoving = true
					end
				elseif stickX < -0.2 then
					self.direction = 'left'
					self.anim = self.animations.right
					--If there is no collision, update player position accordingly
					if (collisionFunctions.checkCollisionX(oldX, self.x - self.speed, self, map)) then
						self.x = self.x - self.speed
						isMoving = true
					end
				end
			end
		end


		--Update Player Velocity
		self.vy = self.vy + self.ay * dt


		--Update Player Position (Potentially)
		local newPotentialY = self.y + self.vy * dt


		--Make Sure Player Y Is Valid
		collisionFunctions.checkCollisionY(oldY, newPotentialY, self, map)
		collisionFunctions.checkJumpThroughCollisionY(oldY, newPotentialY, self, map)

		--Update player y
		self.y = self.y + self.vy * dt


	end --End branch about only move when not talking


	--Set Anim To Idle If Not Moving
	if isMoving == false then
		self.anim = self.animations.idle
		--self.direction = 'none'
	end



	--Update Player Animation
	self.anim:update(dt)



	--Set/Clamp camera so no scroll offscreen
	cam:lookAt(self.x, self.y)
	local width,height = love.graphics.getDimensions()

	--map width/height in pixels
	local mapWidth = map.width * map.tilewidth
	local mapHeight = map.height * map.tileheight

	cam.x = math.max(width / 2, math.min(cam.x,mapWidth - width/2))
	cam.y = math.max(height / 2, math.min(cam.y,mapHeight - height/2))



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
	if (AABB(player.x, player.x + player.width, player.y, player.y + player.height, character.x, character.x + character.width, character.y, character.y + character.height)) then
	player.health = math.max(player.health - 10, 0)
	if (player.direction == "left") then
	player.x = player.x + 100
	else
	player.x = player.x - 100
	end
	end
	end
	]]
	--Try to locate an NPC but only if you aren't talking
	--[[   if isTalking then
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


	narrator:update(dt)]]

end

function player:draw()
	--	love.graphics.print("direction is: " .. self.direction, 400, 300)

	local drawX = self.x
	local scaleX = 3

	if (self.direction == "left") then
		drawX = self.x + self.width
		scaleX = -3
	end


	self.anim:draw(self.spriteSheet, drawX, self.y, 0, scaleX, 3)
	love.graphics.print("X= " .. self.x .. " Y= " .. self.y, 700, 100)
end

function player:drawHealthBar()
	--Make graphics black + draw for background bar
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", 50, 50, 102, 22)

	--Make graphics red + draw for health bar
	love.graphics.setColor(1, 0, 0)
	love.graphics.rectangle("fill", 51, 51, 100 * (self.health / self.maxHealth), 20)

	--Make color white again (default) so no tint stuff
	love.graphics.setColor(1, 1, 1)

end

function player:restart() 
	self.x = self.startingX
	self.y = self.startingY
	self.vy = 0
	self.ay = 2500
	self.attackTimer = 0
	self.health = self.maxHealth
	self.dieAfterTalk = false
end


return player
