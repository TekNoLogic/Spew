
local TABLEDEPTH = 5
local function print(text)
	if not text or text:len() == 0 then text = " " end
	for t in text:gmatch("[^\n]+") do DEFAULT_CHAT_FRAME:AddMessage(t:gsub("|", "||")) end
end


local function ArgsToString(a1, ...)
	local t = type(a1) == "string" and ('"'..a1..'"') or tostring(a1)
	if select('#', ...) < 1 then return t end
	return t, ArgsToString(...)
end

local function TableToString(t, lasti, depth)
	depth = depth or 0
	if depth > TABLEDEPTH then return "...}" end
	local i,v = next(t, lasti)
	if depth == 0 then
		if next(t, i) then return "{"..tostring(i).." = "..tostring(v), TableToString(t, i, depth+1)
		else return "{"..tostring(i).." = "..tostring(v).."}" end
	end
	if next(t, i) then return tostring(i).." = "..tostring(v), TableToString(t, i, depth+1) end
	return tostring(i).." = "..tostring(v).."}"
end

function Spew(a1, ...)
	if select('#', ...) == 0 then
		if type(a1) == "table" then
			print("{")
			for i,v in pairs(a1) do
				local text = type(v) == "table" and string.join(", ", TableToString(v)) or tostring(v)
				print("  "..tostring(i).." = "..text)
			end
			print("}")
		else print(tostring(a1)) end
	else
		print(string.join(", ", ArgsToString(a1, ...)))
	end
end


SLASH_SPEW1 = "/spew"
function SlashCmdList.SPEW(text)
	text = text:trim():match("^(.-);*$")
	local f, err = loadstring("Spew(" .. text .. ")")
	if f then f() else print("|cffff0000Error:|r ".. err) end
end
