local sti = require "libs/Simple-Tiled-Implementation/sti"
local Camera = require "camera"

local map, width, height


function love.load()
   camera = Camera:new()
   setupDisplay()
   map = sti("assets/maps/green_valley.lua")
   width = map.width * map.tilewidth
   height = map.height * map.tileheight
   print("Map width:", width)
   print("Map height:", width)
end

function love.update(dt)
   camera:update(dt)
   updateInput(dt)
   map:update(dt)
end

function love.draw()
   map:draw(-camera.x, -camera.y)
end

function setupDisplay()
   love.window.setMode(camera.width, camera.height)
end

function updateInput(dt)
   if (love.keyboard.isDown("space")) then
      camera:panTo(2, width/2, height/2)
   end
end
