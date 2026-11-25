function love.load()
	--Setup Libraries
	anim8 = require 'libraries/anim8'
	camera = require 'libraries/camera'
	sti = require 'libraries/sti'
	NPC = require 'libraries/npc'
	narrator = require 'libraries/newNarrator'
	playerLib = require 'libraries/player'
	level1 = require 'libraries/level1'
	level2 = require 'libraries/level2'
	collisionFunctions = require 'libraries/collision'



	--Init Narrator
	narrator:init()


	--NOTE: Music Code from Google AI
	deathMusic = love.audio.newSource("audio/deathMusic.wav", "stream")
	deathMusicState = "off"
	deathMusic:setLooping(true)
	

	-- 2. Load short sound effects as "static" (loads fully into RAM for instant playback)
	clickSound = love.audio.newSource("audio/bonk.mp3", "static")

	--Make Character Not Blurry
	love.graphics.setDefaultFilter("nearest", "nearest")

	player = playerLib.new(416, 700, 3, 'sprites/LobsterSpriteSheet.png')
	--debugPlayer = playerLib.new(416, 700, 3, 'sprites/DEBUGLobsterSpriteSheet.png')

	gameState = "Main Menu"



	--Setup Maps/Camera
	mainMenuMap = sti('maps/mainMenu.lua')
	gameOverMap = sti('maps/gameOver.lua')
	victoryMap = sti('maps/victory.lua')
	lobsterVillageMap = sti('maps/DamagedLobsterVillageMap.lua')
	crystalCaveMap = sti('maps/CrystalCave.lua')
	currentMap = lobsterVillageMap;

	--currentMap = crystalCaveMap;


	cam = camera()

	lobsterVillage = level1.new(lobsterVillageMap, cam, narrator)
	crystalCave = level2.new(crystalCaveMap, cam, narrator)

	currentLevel = lobsterVillage
	--currentLevel = crystalCave

	currentLevel:startup()

	screenWidth = love.graphics.getWidth()
	screenHeight = love.graphics.getHeight()

end




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
			character.health = character.health - 50
			--actual attacking goes here
			character.damagedSinceLastFrame = true
		end





	end


end




function love.update(dt)

	if (gameState == "Playing") then
		currentLevel:update(dt, player, currentMap, cam)

		if (player:getHealth() <= 0 or (player:getDieAfterTalk() and not narrator:isOpen())) then
			gameState = "Game Over"
			deathMusicState = "on"
			deathMusic:play()
			--player:restart();
			--currentLevel:restart();
		end

		if (currentLevel:checkLevelDone() and not narrator:isOpen()) then
			--currentLevel:toggleLevelDone()
			currentLevel:cleanup()
			currentLevel = crystalCave
			currentMap = crystalCaveMap;
			if currentLevel:checkLevelDone() then
				currentLevel:restart()
			end
			currentLevel:startup()
		end
		
	end

	if (currentLevel == crystalCave and currentLevel:getLevelComplete()) then
		gameState = "Victory"
	end

end

function love.draw()
	if (gameState == "Main Menu") then
		mainMenuMap:drawLayer(mainMenuMap.layers["Base"])
		if (player:getUseKeyboardControls()) then
			love.graphics.print("Press enter to start the game", love.graphics:getWidth() / 2 - 100, love.graphics:getHeight() / 2)
		else
			love.graphics.print("Press right or bottom button to start the game", love.graphics:getWidth() / 2 - 150, love.graphics:getHeight() / 2)
		end
	elseif (gameState == "Playing") then
		currentLevel:draw(player, currentMap, cam)
	elseif (gameState == "Game Over") then
		mainMenuMap:drawLayer(gameOverMap.layers["Base"])
		love.graphics.print("Press enter to restart the game", love.graphics:getWidth() / 2 - 100, love.graphics:getHeight() - 100)
		currentLevel:cleanup()

	elseif (gameState == "Victory") then
		victoryMap:drawLayer(victoryMap.layers["Base"])
		currentLevel:cleanup()
		love.graphics.print("Press enter to restart the game", love.graphics:getWidth() / 2 - 140, love.graphics:getHeight() / 2 + 225)
	end
end


function love.keypressed(key)
	if (gameState == "Main Menu" and key == "return") then
		gameState = "Playing"
	elseif (gameState == "Game Over" and key == "return") then
		player:restart();
		currentLevel:restart();
		gameState = "Playing"
		if (deathMusicState == "on") then
			deathMusicState = "off"
			deathMusic:stop()
		end
	elseif (gameState == "Victory" and key == "return") then
		crystalCave:setLevelComplete()
		crystalCave:toggleLevelDone()
		currentLevel = lobsterVillage
		currentMap = lobsterVillageMap
		player:restart()
		lobsterVillage:restart()
		gameState = "Playing"

	end

	if key == "escape" then
		love.event.quit()
	end
	if key == 'space' and not player:getJumping() then
		player:setJumping(true)
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

function love.gamepadpressed(joystick, button)
	if (button == "a" or button == "b") and not player:getJumping() then
		player:setJumping(true)
		player:setVy(player:getJumpForce())
	elseif button == "x" or button == "y" then
		attack(currentLevel:getEnemies())	
	end


	--Narrator is open
	if currentLevel:getNarrator():isOpen() then
		--Do said action
		if button == "a" then
			currentLevel:getNarrator():onAction()

			--Go to previous option
		elseif button == "x" then
			currentLevel:getNarrator():prevOption()

			--Go to next Option
		elseif button == "b" then
			currentLevel:getNarrator():nextOption()
		end
	else
		if (button == "a" or button == "b") and gameState == "Playing" and nearbyNPC then
			currentLevel:getNarrator():startScript(nearbyNPC)
		end
	end

	if (gameState == "Main Menu" and (button == "a" or button == "b")) then
		gameState = "Playing"
	elseif (gameState == "Game Over" and (button == "a" or button == "b")) then
		player:restart();
		currentLevel:restart();
		if (deathMusicState == "on") then
			deathMusicState = "off"
			deathMusic:stop()
		end
		gameState = "Playing"
	elseif (gameState == "Victory" and (button == "a" or button == "b")) then
		crystalCave:setLevelComplete()
		crystalCave:toggleLevelDone()
		currentLevel = lobsterVillage
		currentMap = lobsterVillageMap
		player:restart()
		currentLevel:restart()
		gameState = "Playing"
	end

end

function love.mousepressed(x, y, button)
	if button == 1 then --1 = left click
		attack(currentLevel:getEnemies())
	end
end
