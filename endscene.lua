local Object = require 'libs/classic/classic'

EndScene = Object:extend()

function EndScene:new(team)
   self.team = team
end

function EndScene:init()
end

function EndScene:update(dt)
end

function EndScene:draw(ox, oy)
   love.graphics.print("Time \"" .. self.team .. "\" venceu", 400, 300)
end

function EndScene:keyPressed(key, scancode,  isRepeat)
end

return EndScene
