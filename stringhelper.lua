function string.starts(str, start)
   return string.sub(str, 1, string.len(start)) == start
end
