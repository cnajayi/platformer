local Globals = require "src.Globals"
local Push = require "libs.push"
local Sounds = require "src.game.Sounds"
local Player = require "src.game.Player"
local Camera = require "libs.sxcamera"
local HUD = require "src.game.HUDimproved"

-- Load is executed only once; used to setup initial resource for your game
function love.load()
    love.window.setTitle("CS489 Platformer")
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {fullscreen = false, resizable = true})
    math.randomseed(os.time()) -- RNG setup for later

    stageCompleteTimer = 0

    player = Player(0,0)
    hud = HUD(player)

    camera = Camera(gameWidth/2,gameHeight/2,
        gameWidth,gameHeight)
    camera:setFollowStyle('PLATFORMER')

    stagemanager:setPlayer(player)
    stagemanager:setCamera(camera)
    --stagemanager:setStage(1)

    titleFont = love.graphics.newFont("fonts/Kaph-Regular.ttf",26)
    stagemanager:setStage(0)

end

-- When the game window resizes
function love.resize(w,h)
    Push:resize(w,h) -- must called Push to maintain game resolution
end

-- Event for keyboard pressing
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "F2" or key == "tab" then
        debugFlag = not debugFlag  
    elseif gameState == "over" then
        gameState = "start"
        player:reset()
        stagemanager:setStage(0)
    elseif key == "return" and gameState=="start" then
        gameState = "play"
        stagemanager:setStage(1)

    else
        player:keypressed(key) 
    end
end

-- Event to handle mouse pressed (there is another for mouse release)
function love.mousepressed(x, y, button, istouch)
    gx, gy = Push:toGame(x,y)

end

-- Update is executed each frame, dt is delta time (a fraction of a sec)
function love.update(dt)
    if player.lives <= 0 and gameState ~= "over" then 
        gameState = "over"
        stagemanager:currentStage():stopMusic()
        Sounds["game_over"]:play()
    end

    if gameState == "play" then
        stagemanager:currentStage():update(dt)
        player:update(dt, stagemanager:currentStage())
        hud:update(dt)

        camera:update(dt)
        camera:follow(
            math.floor(player.x+48), math.floor(player.y))

    elseif gameState == "start" then

    elseif gameState == "over" then

    elseif gameState == "complete" then
        stageCompleteTimer = stageCompleteTimer + dt
        hud:update(dt) 

        if stageCompleteTimer >= 3 then
            gameState = "play"
            player:nextStage(stagemanager.createStage[2]())
            stagemanager:setStage(2)
        end
    end
end

-- Draws the game after the update
function love.draw()
    Push:start() 
    -- always draw between Push:start() and Push:finish()

    if gameState == "play" then
        drawPlayState()
    elseif gameState == "start" then
        drawStartState()
    elseif gameState == "over" then
        drawGameOverState()
    elseif gameState == "complete" then
        drawCompleteState()
    else --Error, should not happen
        love.graphics.setColor(1,1,0) -- Yellow
        love.graphics.printf("Error", 0,20,gameWidth,"center")
    end

    Push:finish()
end

function drawPlayState()

    stagemanager:currentStage():drawBg()

    camera:attach()

    stagemanager:currentStage():draw()
    player:draw()
    
    camera:detach()

    hud:draw()
end

function drawStartState()
    love.graphics.setColor(0.3,0.3,0.3) -- dark gray
    stagemanager:currentStage():drawBg()
    stagemanager:currentStage():draw() -- draw Stage zero
    player:draw() -- and the player sprite
    love.graphics.setColor(1,1,0) -- Yellow
    love.graphics.printf("CS489 Platformer", titleFont,0,20,gameWidth,"center") -- Title    love.graphics.printf("Press Enter to Play", 0,140,gameWidth,"center")
    love.graphics.printf("Press Enter to Start",0,100,gameWidth,"center") -- Title    love.graphics.printf("Press Enter to Play", 0,140,gameWidth,"center")
        
end

function drawGameOverState()
    love.graphics.setColor(0.3,0.3,0.3)
    stagemanager:currentStage():drawBg()
    camera:attach()  -- draw moving objects within attach() - detach()
    stagemanager:currentStage():draw()
    --player:draw()
    camera:detach() -- ends camera effect

    love.graphics.setColor(1,0,0,1)
    love.graphics.printf("Game Over", titleFont,0,80,gameWidth,"center")
    love.graphics.printf("Total Score "..player.score,0,110,gameWidth,"center")

    love.graphics.printf("Press any key for Start Screen", 0,150,gameWidth,"center")
end

function drawCompleteState()
    --love.graphics.setColor(0.3,0.3,0.3)
    stagemanager:currentStage():drawBg()
    camera:attach()  -- draw moving objects within attach() - detach()
    stagemanager:currentStage():draw()
    --player:draw()
    camera:detach() -- ends camera effect

    love.graphics.setColor(1,1,1)
    love.graphics.printf("Stage Complete!", titleFont,0,80,gameWidth,"center")
    love.graphics.printf("Total Score "..player.score,0,110,gameWidth,"center")
    love.graphics.printf("Coins: "..player.coins, 0, 130, gameWidth, "center")
    love.graphics.printf("Gems: "..player.gems, 0, 160, gameWidth, "center")
end
