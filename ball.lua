---------------BALL CLASS-------------------
--Represents a ball which will bounce back and forth between paddles
--and walls until it passes a left or right boundary of the screen,
--scoring a point for the opponent.
ball =Class{}
function ball:init(x,y,r)
	self.x=x 
	self.y=y
	self.r=r 
	--these variables are kept to track the velocity on both X axis and Y axis 
	-- since the ball can move in both the dimensions
	self.dy = love.math.random(2)==1 and -100 or 100
	self.dx = love.math.random(-50,50) 
end
--[[
    Expects a paddle as an argument and returns true or false, depending
    on whether their rectangles overlap.
]]
function ball:collides(paddle)
	-- first, check to see if the left edge of either is further to 
	if self.x-self.r > paddle.x+paddle.width or paddle.x>self.x+self.r then
      return false
  end 
  if self.y-self.r >paddle.height+paddle.y or  paddle.y> self.y+self.r then
    return false
  end
    return true;
  end

-- Places the ball in the middle of a screen, with an initial random velocity in both the directions
function ball:reset()
	self.x=VIRTUAL_WIDTH/2-2
	self.y=VIRTUAL_HEIGHT/2-2
	self.dy=love.math.random(2)==1 and -100 or 100
	self.dx=love.math.random(-50,50)
end
-- Simply applies the velocity to position scaled by delta time
function ball:update(dt)
	self.x=self.x+self.dx*dt 
	self.y=self.y+self.dy*dt
end
function ball:render()
	love.graphics.setColor(1,0,0,1)
	love.graphics.circle('fill', self.x, self.y, self.r)
end