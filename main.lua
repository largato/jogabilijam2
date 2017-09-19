require "entitymanager"

local Map = require "libs/Simple-Tiled-Implementation/sti"
local sodapop = require "libs/sodapop/sodapop"
local Camera = require "camera"
local Scene = require "scene"
local SampleChar = require "samplechar"

local currentScene = nil

function love.load()
   love.window.setMode(800, 600)

   local map = Map("assets/maps/green_valley.lua")
   currentScene = Scene(Camera(800, 600), map)

   local player
   for k, object in pairs(map.objects) do
      if object.name == "Player" then
         player = object
         break
      end
   end

   manager:add(SampleChar(player.x, player.y, 96))
   manager:add(SampleChar(player.x + 64, player.y, 96))
   manager:add(SampleChar(player.x, player.y + 64, 96))
   manager:add(SampleChar(player.x + 64, player.y + 64, 96))
end

function love.update(dt)
   currentScene:update(dt)
end

function love.draw()
   currentScene:draw()
end

function love.keypressed(key, scancode, isRepeat)
   if key=="l" and not isRepeat then
      currentScene.camera:zoomOut()
   elseif key=="k" and not isRepeat then
      currentScene.camera:zoomIn()
   elseif key=="space" and not isRepeat then
      currentScene.camera:panTo(2, 1200, 1200)
   end
end
