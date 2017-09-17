local sti = require "libs/Simple-Tiled-Implementation/sti"
local map, width, height

function love.load()
   map = sti("assets/maps/green_valley.lua")
   width = map.width * map.tilewidth
   height = map.height * map.tileheight
   print("Map width:", width)
   print("Map height:", width)
end

function love.update(dt)
   map:update(dt)
end

function love.draw()
   map:draw(-width / 2, -height / 2)
end
