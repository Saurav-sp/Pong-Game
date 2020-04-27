--PONG -9 :->  
---------------SERVER UPDATE---------------
--
-- from here we start basic building blocks for the development of Pong game.
--Language used:- Lua
-- Framwork used:- Love
-- Editor used:- Sublime text editor
-- SaurAV PandEY

-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of however large our window is; used to provide
-- a more retro aesthetic
--
--[[
  author:- sauravpandey474@gmail.com
]]
-- Location of Push 
-- https://github.com/Ulydev/push
--the "Class" library we're using will allow us to represent anything in
-- our game as code, rather than keeping track of many disparate variables and methods
-- Source of Class-> https://github.com/vrld/hump/blob/master/class.lua
push = require 'push'
Class=require'class'
--Paddle class which stores positions,dimensions and logic for rendering them  
require 'paddle'
--ball class which stores position,dimension, velocity updates and logic for recenter it
require'ball'

WINDOW_WIDTH=1300
WINDOW_HEIGHT=700
-- try to maintain the aspect ratio if 16\9
VIRTUAL_WIDTH=432     -- Used to get the clear vision on the different aspect screen size
VIRTUAL_HEIGHT=243

-- speed at which we will move our paddle, mltiplied by dt in update because of slow or laging in different system
PADDLE_SPEED=200

--[[
    Runs when the game first starts up, only once; used to initialize the game.
]]

function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')
  -- more retro-looing font object we can use for the claer vision of the font.
  -- seed the rng so that calls to random are always random 
  -- use the current time, science that will vary on startup time 
  -- Set the title of our Window 
  love.window.setTitle('Pong game')
  love.math.getRandomSeed(os.time())
  -- -- more "retro-looking" font object we can use for any text
  smallFont=love.graphics.newFont('font.ttf',8)
  --setting the largerfont for showing the score on the screen
  largeFont = love.graphics.newFont('font.ttf', 16)
  scoreFont = love.graphics.newFont('font.ttf', 32)
  --set Love2D active font to the small font bject
  love.graphics.setFont(smallFont)
  --Initialise the window with  virtual reslution
  push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
     fullscreen=false,
     vsync=true,
     resizable=true
  })
  --Initialise the score variables used for rendering on the screen and keeping track of the winner
  player1score=0
  player2score=0
  --Either sering player is going to be one or two
  servingPlayer=1
  -- player who won the game; not set to a proper value until we reach
  -- that state in the game
 winningPlayer =0

    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first serve)
    -- 2. 'serve' (waiting on a key press to serve the ball)
    -- 3. 'play' (the ball is in play, bouncing between paddles)
    -- 4. 'done' (the game is over, with a victor, ready for restart)
  --Initialize our players paddle, make them globally so that they can be detected by the other functions and modules
  player1=paddle(10,30,5,20)
  player2=paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT-30,5,20)
  Ball=ball(VIRTUAL_WIDTH/2-2,VIRTUAL_HEIGHT/2-2,2) 
  -- game state variable used to transition between parts of the game 
  -- used for beginning, menus, main game, high score list etc
  --we will use this to determine behaviour during render and update
  gameState='start'
end


function love.resize(w, h)
    push:resize(w, h)
end
--[[
    Runs every frame, with "dt" passed in, our delta in seconds 
    since the last frame, which LÖVE2D supplies us.
]]
function love.update(dt)
  if gameState=='serve' then
    -- before switching to play, initialize the ball's velocity based on player's score
    Ball.dy=love.math.random(-50,50)
    if servingPlayer==1 then
      Ball.dx = love.math.random(140,200)
    else
      Ball.dx=-love.math.random(140,200)
    end
    else if gameState=='play' then
    -- detect ball collision with paddles,reversing dx if true and 
    --slightly increasing it, then altering the dy based on the position of collision
         if Ball:collides(player1) then 
           Ball.dx=-Ball.dx*1.03
           Ball.x=player1.x+5
         --end
           --keep velocity going in the same direction but randomize it
          if Ball.dy<=0 then 
            Ball.dy=-love.math.random(10,150)
          else 
           Ball.dy=love.math.random(10,150)
          end
        end
          --end
  if Ball:collides(player2) then 
    Ball.dx=-Ball.dx*1.03
    Ball.x=player2.x-2
    --keep velocity going in the same direction but randomize it
  if Ball.dy<=0 then 
    Ball.dy=-love.math.random(10,150)
  else 
    Ball.dy=love.math.random(10,150)
   end
  end
  -- detect upper and lower boundry collision and reverse if collided
  if Ball.y<=0 then
  Ball.y=0
  Ball.dy=-Ball.dy
  end
  -- subtract the size of the ball
  if Ball.y>=VIRTUAL_HEIGHT-2 then
  Ball.y=VIRTUAL_HEIGHT-2
  Ball.dy=-Ball.dy
  end
  -- used to update the score of every endividual player2
    if Ball.x<0 then
      servingPlayer=1
      player2score=player2score+1
       -- if we've reached a score of 10, the game is over; set the
            -- state to done so we can show the victory message
          if player2score==3 then
            winningPlayer=2
            gameState='done'
          else
            gameState='serve'
            --places the ball in the middle of the screen, no velocity
            Ball:reset()
          end
        end

    if Ball.x>VIRTUAL_WIDTH then
      servingPlayer=2
      player1score=player1score+1
       if player1score == 3 then
          winningPlayer = 1
          gameState = 'done'
        else
          gameState = 'serve'
          Ball:reset()
        end
      end
    end
  -- for the player1 movement
  if love.keyboard.isDown('w') then 
    -- add ngative paddle speed to current Y scaled by delta time
    -- we will ensure that paddle will never go above
    player1.dy= -PADDLE_SPEED 
  elseif love.keyboard.isDown('s') then
    -- add positive speed to the current Y scaled by delta time
    --math.min wiil ensure that we will never go below the table
    player1.dy=PADDLE_SPEED
  else
	player1.dy=0
  end
  -- Player 2 movement
  if love.keyboard.isDown('up') then 
    --add negative paddle speed to the current Y scaled by delta time 
    player2.dy=-PADDLE_SPEED 
  elseif love.keyboard.isDown('down') then 
    -- add positive paddle speed to current Y scaled by delta time 
    player2.dy=PADDLE_SPEED
  else
	player2.dy=0
  end 
 -- update our ball based on its DX and DY only if we're in play state;
  -- scale the velocity by dt so movement is framerate-independent
  if gameState=='play' then 
   Ball:update(dt)
  end
  player1:update(dt)
  player2:update(dt)
end
end 
--[[
    keyboard handelling 
]]
function love.keypressed(key)
  --keys can be assed by the string name
  if key == 'escape'  then
    --function Love gives us to terminate the application
    love.event.quit()
     -- if we press enter during the start state of the game, we'll go into play mode
    -- during play mode, the ball will move in a random direction
  elseif key=='enter' or key=='return' then
    if gameState=='start' then
     gameState='serve'
   elseif gameState=='serve' then
    gameState='play'
  elseif gameState=='done' then
     -- game is simply in a restart phase here, but will set the serving
     -- player to the opponent of whomever won for fairness!
    gameState = 'serve'
    Ball:reset()

   -- reset scores to 0
    player1score = 0
    player2score = 0
    -- decide serving player as the opposite of who won
    if winningPlayer == 1 then
       servingPlayer = 2
    else
       servingPlayer = 1
     end
    end 
  end
end

--[[
     Called after update by LÖVE2D, used to draw anything to the screen, 
    updated or otherwise.
]]

function love.draw()
  push:apply('start')     --begin rendering at virtual resolution 
  -- clear the screen with the specific color, to make the background looking more intractive
  love.graphics.clear(40/255,45/255,52/255,255/255)   
  -- draw the welcome text towards the top of the screen
  love.graphics.setFont(smallFont)
  --
  displayScore()
  if gameState=='start' then 
     love.graphics.setFont(smallFont)
     love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
     love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
   elseif gameState=='serve' then
     love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'done' then
        -- UI messages
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end
     player1:render()
    player2:render()
    Ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
	 -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
--[[
    Simply draws the score to the screen.
]]
function displayScore()
    -- draw score on the left and right center of the screen
    -- need to switch font to draw before actually printing
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end