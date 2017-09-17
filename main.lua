local sti = require "libs/Simple-Tiled-Implementation/sti"
local sodapop = require "libs/sodapop/sodapop"
local Camera = require "camera"
local SampleChar = require "samplechar"

local map, width, heigh, playerSprite, char

function love.load()
   camera = Camera:new()
   setupDisplay()
   map = sti("assets/maps/green_valley.lua")
   width = map.width * map.tilewidth
   height = map.height * map.tileheight
   print("Map width:", width)
   print("Map height:", height)

   local player
   for k, object in pairs(map.objects) do
      if object.name == "Player" then
         player = object
         break
      end
   end

   char = SampleChar(player.x, player.y, 96)
end

function love.update(dt)
   camera:update(dt)
   updateInput(dt)
   map:update(dt)
   char:update(dt)
end

function love.draw()
   map:draw(-camera.x, -camera.y)
   char:draw(-camera.x, -camera.y)
end

function setupDisplay()
   love.window.setMode(camera.width, camera.height)
end

function updateInput(dt)
   if (love.keyboard.isDown("space")) then
      camera:panTo(2, width/2, height/2)
   end
end
