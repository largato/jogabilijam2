require "entitymanager"
require "stringhelper"
require "scenemanager"
require "settings"
require "soundmanager"

local Map = require "libs/Simple-Tiled-Implementation/sti"
local Camera = require "camera"
local Scene = require "scene"
local EndScene = require "endscene"
local MenuScene = require "menuscene"
local DialogScene = require "dialogscene"
local SettingsScene = require "settingsscene"
local CreditsScene = require "creditsscene"

local debugMode = true

function love.load()
   soundManager:add("battle", "assets/sounds/battle.mp3")
   soundManager:add("menu", "assets/sounds/menu.mp3")
   soundManager:add("menuselect", "assets/sounds/menuselect.wav", true)
   soundManager:add("accept", "assets/sounds/accept.mp3", true)
   soundManager:playLoop("menu")

   local map = Map("assets/maps/green_valley.lua")
   sceneManager:add("menu", MenuScene())
   sceneManager:add("prologue", DialogScene('prologue', "battle"))
   sceneManager:add("battle", Scene(Camera(), map))
   sceneManager:add("PlayerWon", EndScene("Jogador"))
   sceneManager:add("EnemyWon", EndScene("Inimigo"))
   sceneManager:add("settings", SettingsScene())
   sceneManager:add("credits", CreditsScene())
   sceneManager:setCurrent("menu")
end

function love.update(dt)
   if dt < 1/30 then
      love.timer.sleep(1/30 - dt)
   end
   sceneManager:update(dt)
end

function love.draw()
   sceneManager:draw()
   if debugMode then
      drawDebugInfo()
   end
end

function love.keypressed(key, scancode, isRepeat)
   sceneManager:keyPressed(key, scancode, isRepeat)
end

function drawDebugInfo()
   love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end
