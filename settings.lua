require "assets"

local Object = require "libs/classic/classic"

Settings = Object:extend()

function Settings:new()
   self.settings = self:loadSettings()
end

function Settings:currentSettings()
   return self.settings
end

function Settings:loadSettings()
   local f = io.open("settings.conf", "r")
   if f == nil then
      return self:loadDefaultSettings()
   end
   local storedSettings = dofile("settings.conf")
   for i, storedSetting in ipairs(storedSettings) do
      for j, setting in ipairs(assets.config.defaultsettings) do
         if storedSetting[1] == setting[1] then
            setting[3] = storedSetting[2]
            self:applySetting(setting)
         end
      end
   end
   return assets.config.defaultsettings
end

function Settings:loadDefaultSettings()
   local defaultSettings = assets.config.defaultsettings
   local settings = {}
   for i, setting in ipairs(defaultSettings) do
      local setting = {setting[1], setting[2], setting[3], setting[4]}
      table.insert(settings, setting)
      self:applySetting(setting)
   end
   return settings
end

function Settings:toString(setting)
   local str = setting[1]
   if setting[2] == "boolean" then
      if setting[3] then
         str = str .. " [X]"
      else
         str = str .. " [ ]"
      end
   elseif setting[2] == "string" then
      str = str .. " < " .. setting[3] .. " >"
   end
   return str
end

function Settings:nextSetting(index)
   local setting = self.settings[index]
   if setting[2] == "boolean" then
      setting[3] = not setting[3]
   elseif setting[2] == "string" then
      self:nextString(setting)
   end
   self:applySetting(setting)
end

function Settings:previousSetting(index)
   local setting = self.settings[index]
   if setting[2] == "boolean" then
      setting[3] = not setting[3]
   elseif setting[2] == "string" then
      self:previousString(setting)
   end
   self:applySetting(setting)
end

function Settings:applySetting(setting)
   if setting[1] == "FullScreen" then
      local w, h, flags = love.window.getMode()
      flags.fullscreen = setting[3]
      if self.settings ~= nil then
        for i, setting in ipairs(self.settings) do
            if setting[1] == "Resolução" then
                local parts = setting[3]:split("x")
                w = parts[1]
                h = parts[2]
                break
            end
        end
      end
      love.window.setMode(w, h, flags)
      -- XXX screen doesn't resize automatically when disabling fullscreen mode
   elseif setting[1] == "Resolução" then
      local parts = setting[3]:split("x")
      local w, h, flags = love.window.getMode()
      w, h = parts[1], parts[2]
      love.window.setMode(w, h, flags)
   end
   love.event.clear() -- XXX when we change modes, looks like lua ignores previous key presses
                      -- and the "ispressed" parameter in love.keypressed is always false.
                      -- here we clear the event queue to fix this.
end

function Settings:screenScaleFactor()
   return love.graphics.getWidth() / 1280
end

function Settings:nextString(setting)
   local current = setting[3]
   local index = 0

   for i, v in ipairs(setting[4]) do
      if v == current then
         index = i
         break
      end
   end

   if i == 0 then
      return
   end

   index = index % #setting[4] + 1
   setting[3] = setting[4][index]
end

function Settings:previousString(setting)
   local current = setting[3]
   local index = 0

   for i, v in ipairs(setting[4]) do
      if v == current then
         index = i
         break
      end
   end

   if i == 0 then
      return
   end

   index = (index - 2) % #setting[4] + 1
   setting[3] = setting[4][index]
end

settings = Settings()
