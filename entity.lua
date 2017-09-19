local Object = require "libs/classic/classic"

Entity = Object:extend()

function Entity:new(x, y, type)
   self.x = x
   self.x = y
   self.type = type
end

return Entity
