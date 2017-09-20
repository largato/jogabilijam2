require "entitymanager"
require "stringhelper"

local Map = require "libs/Simple-Tiled-Implementation/sti"
local sodapop = require "libs/sodapop/sodapop"
local Camera = require "camera"
local Scene = require "scene"
local SampleChar = require "samplechar"

local currentScene = nil
local debugMode = true

function love.load()
   love.window.setMode(800, 600)

   local map = Map("assets/maps/green_valley.lua")
   currentScene = Scene(Camera(800, 600), map)

   for k, object in pairs(map.objects) do
      local parts = object.name:split("-")
      local characterType = parts[1]
      local characterName = parts[2]
      manager:add(SampleChar(object.x, object.y, 96, characterType))
   end
end

function love.update(dt)
   currentScene:update(dt)
end

function love.draw()
   currentScene:draw()
   if debugMode then
      drawDebugInfo()
   end
end

function love.keypressed(key, scancode, isRepeat)
   if key=="space" and not isRepeat then
      currentScene.camera:panTo(2, currentScene.map.width * currentScene.map.tilewidth / 2 - currentScene.camera.width / 2,
                                currentScene.map.height * currentScene.map.tileheight / 2 - currentScene.camera.height / 2)
   end
end

function drawDebugInfo()
   love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end
