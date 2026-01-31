function GetZombieDistance(zombie, player)
	local zx = zombie:getX()
	local zy = zombie:getY()
	local px = player:getX()
	local py = player:getY()
	local dist = math.sqrt((zx - px) ^ 2 + (zy - py) ^ 2)
	return dist
end