----------------------PADDLE CLASS-----------------------------
--Reperesnts the paddle that can move up and down.
--Uesd in main program to deflect the ball back towards opponent side
paddle=Class{}
function paddle:init(x,y,width,height)
	self.x=x
	self.y=y 
	self.width=width 
	self.height=height 
	self.dy=0
end
function paddle:update(dt)
	if self.dy<0 then 
		self.y=math.max(0,self.y+self.dy*dt)
	else
		self.y=math.min(VIRTUAL_HEIGHT-self.height,self.y+self.dy*dt)
	end
end
-- Now we need to create the paddle which is call by our main function 
function paddle:render()
	love.graphics.setColor(1,1,0)
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end