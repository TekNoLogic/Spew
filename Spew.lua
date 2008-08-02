
local TABLEDEPTH = 5
local tostring, TableToString = tostring


local function Print(text)
	if not text or text:len() == 0 then text = " " end
	DEFAULT_CHAT_FRAME:AddMessage(text)
end


local colors = {boolean = "|cffff9100", number = "|cffff7fff", ["nil"] = "|cffff7f7f"}
local function escape(c) return "\\"..c:byte() end
local function pretty_tostring(value)
	local t = type(value)
	if t == "string" then return '|cff00ff00"'..value:gsub("|", "||"):gsub("([\001-\012\014-\031\128-\255])", escape)..'"|r'
	elseif t == "table" then
		if type(rawget(value, 0)) == "userdata" and type(value.GetObjectType) == "function" then return "|cffffea00<"..value:GetObjectType()..":"..(value:GetName() or "(anon)")..">|r"
		else return "|cff9f9f9f"..string.join(", ", TableToString(value)).."|r" end
	elseif colors[t] then return colors[t]..tostring(value).."|r"
	else return tostring(value) end
end


function TableToString(t, lasti, depth)
	depth = depth or 0
	if depth > TABLEDEPTH then return "...|cff9f9f9f}|r" end
	local i,v = next(t, lasti)
	if depth == 0 then
		if next(t, i) then return "|cff9f9f9f{|cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v), TableToString(t, i, depth+1)
		elseif v == nil then return "|cff9f9f9f{}|r"
		else return "|cff9f9f9f{|cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v).."|cff9f9f9f}|r" end
	end
	if next(t, i) then return "|cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v), TableToString(t, i, depth+1) end
	return "|cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v).."|cff9f9f9f}|r"
end


local function ArgsToString(a1, ...)
	if select('#', ...) < 1 then return pretty_tostring(a1)
	else return pretty_tostring(a1), ArgsToString(...) end
end


local blist, input = {GetDisabledFontObject = true, GetHighlightFontObject = true, GetNormalFontObject = true}
local function downcasesort(a,b) return a and b and tostring(a):lower() < tostring(b):lower() end
local function pcallhelper(success, ...) if success then return string.join(", ", ArgsToString(...)) end end
function Spew(a1, ...)
	if select('#', ...) == 0 then
		if type(a1) == "table" then
			if type(rawget(a1, 0)) == "userdata" and type(a1.GetObjectType) == "function" then
				-- We've got a frame!
				Print("|cffffea00<"..a1:GetObjectType()..":"..(a1:GetName() or input"(anon)").."|r")
				local sorttable = {}
				for i in pairs(a1) do table.insert(sorttable, i) end
				for i in pairs(getmetatable(a1).__index) do table.insert(sorttable, i) end
				table.sort(sorttable, downcasesort)
				for _,i in ipairs(sorttable) do
					local v, output = a1[i]
					if type(v) == "function" and type(i) == "string" and not blist[i] and (i:find("^Is") or i:find("^Can") or i:find("^Get")) then
						output = pcallhelper(pcall(v, a1))
					end
					if output then Print("  |cff7fd5ff"..tostring(i).."|r => "..output)
					else Print("  |cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v)) end
				end
				Print("|cffffea00>|r", true)
			else
				-- Normal table
				Print("|cff9f9f9f{  -- "..input.."|r")
				local sorttable = {}
				for i in pairs(a1) do table.insert(sorttable, i) end
				table.sort(sorttable, downcasesort)
				for _,i in ipairs(sorttable) do Print("  |cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(a1[i])) end
				Print("|cff9f9f9f}  -- "..input.."|r")
			end
		else Print(pretty_tostring(a1)) end
	else
		Print(string.join(", ", ArgsToString(a1, ...)))
	end
end


SLASH_SPEW1 = "/spew"
function SlashCmdList.SPEW(text)
	input = text:trim():match("^(.-);*$")
	local f, err = loadstring("Spew("..input..")")
	if f then f() else Print("|cffff0000Error:|r "..err) end
end


--[[
-- Testing code to help find crashes
TEKX = TEKX or 0
local blist, input = {GetDisabledFontObject = true, GetHighlightFontObject = true, GetNormalFontObject = true}
local function downcasesort(a,b) return a and b and tostring(a):lower() < tostring(b):lower() end
local a1=PlayerFrame
local sorttable = {}
for i in pairs(a1) do table.insert(sorttable, i) end
for i in pairs(getmetatable(a1).__index) do table.insert(sorttable, i) end
table.sort(sorttable, downcasesort)
for j,i in ipairs(sorttable) do
        local v, output = a1[i]
        if j > TEKX and type(v) == "function" and type(i) == "string" and not blist[i] and i:find("^Get") then
TEKX = j
ChatFrame1:AddMessage("Testing "..TEKX.." - "..i)
                output = pcall(v, a1)
return
        end
end
ChatFrame1:AddMessage("Done testing")
]]
