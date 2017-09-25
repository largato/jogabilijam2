function string:starts(start)
   return string.sub(self, 1, string.len(start)) == start
end

function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function string:trim()
   return (self:gsub("^%s*(.-)%s*$", "%1"))
end
