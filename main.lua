local Map = require "libs/Simple-Tiled-Implementation/sti"
local sodapop = require "libs/sodapop/sodapop"
local Camera = require "camera"
local Scene = require "scene"
local SampleChar = require "samplechar"

local playerSprite, char
local scene

function love.load()
   love.window.setMode(800, 600)

   local map = Map("assets/maps/green_valley.lua")
   local camera = Camera:new()
   camera:setSize(800, 600)

   scene = Scene:new()
   scene:setCamera(camera)
   scene:setMap(map)

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
   scene:update(dt)
   char:update(dt)
end

function love.draw()
   scene:draw()
   char:draw(-scene.camera.x, -scene.camera.y)
end

function love.keypressed(key, scancode, isRepeat)
   if key=="l" and not isRepeat then
      scene.camera:zoomOut()
   elseif key=="k" and not isRepeat then
      scene.camera:zoomIn()
   elseif key=="space" and not isRepeat then
      scene.camera:panTo(2, 1200, 1200)
   end
end
