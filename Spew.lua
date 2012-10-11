
local myname, ns = ...

local TABLEITEMS, TABLEDEPTH = 5, 1
local tostring, TableToString = tostring

local panel = ns.tekPanelAuction("SpewPanel", "Spew")
local cf = CreateFrame("ScrollingMessageFrame", nil, panel)
cf:SetPoint("TOPLEFT", 25, -75)
cf:SetPoint("BOTTOMRIGHT", -15, 40)
cf:SetMaxLines(1000)
cf:SetFontObject(ChatFontSmall)
cf:SetJustifyH("LEFT")
cf:SetFading(false)
cf:EnableMouseWheel(true)
cf:SetScript("OnHide", cf.ScrollToBottom)
cf:SetScript("OnMouseWheel", function(frame, delta)
	if delta > 0 then
		if IsShiftKeyDown() then frame:ScrollToTop()
		else for i=1,4 do frame:ScrollUp() end end
	elseif delta < 0 then
		if IsShiftKeyDown() then frame:ScrollToBottom()
		else for i=1,4 do frame:ScrollDown() end end
	end
end)


local b = LibStub("tekKonfig-Button").new(cf, "TOPRIGHT", cf, "BOTTOMRIGHT", -155, -3)
b:SetText("Clear")
b:SetScript("OnClick", function() cf:Clear() end)

local function Print(text, frame)
	if not text or text:len() == 0 then text = " " end
	(frame or cf):AddMessage(text)
end


local colors = {boolean = "|cffff9100", number = "|cffff7fff", ["nil"] = "|cffff7f7f"}
local noescape = {["\a"] = "a", ["\b"] = "b", ["\f"] = "f", ["\n"] = "n", ["\r"] = "r", ["\t"] = "t", ["\v"] = "v"}
local function escape(c) return "\\".. (noescape[c] or c:byte()) end
local function pretty_tostring(value, depth)
	depth = depth or 0
	local t = type(value)
	if t == "string" then return '|cff00ff00"'..value:gsub("|", "||"):gsub("([\001-\031\128-\255])", escape)..'"|r'
	elseif t == "table" then
		if depth > TABLEDEPTH then return "|cff9f9f9f{...}|r"
		elseif type(rawget(value, 0)) == "userdata" and type(value.GetObjectType) == "function" then return "|cffffea00<"..value:GetObjectType()..":"..(value:GetName() or "(anon)")..">|r"
		else return "|cff9f9f9f"..string.join(", ", TableToString(value, nil, nil, depth+1)).."|r" end
	elseif colors[t] then return colors[t]..tostring(value).."|r"
	else return tostring(value) end
end


function TableToString(t, lasti, items, depth)
	items = items or 0
	depth = depth or 0
	if items > TABLEITEMS then return "...|cff9f9f9f}|r" end
	local i,v = next(t, lasti)
	if items == 0 then
		if next(t, i) then return "|cff9f9f9f{|cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v, depth), TableToString(t, i, 1, depth)
		elseif v == nil then return "|cff9f9f9f{}|r"
		else return "|cff9f9f9f{|cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v, depth).."|cff9f9f9f}|r" end
	end
	if next(t, i) then return "|cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v, depth), TableToString(t, i, items+1, depth) end
	return "|cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v, depth).."|cff9f9f9f}|r"
end


local function ArgsToString(a1, ...)
	if select('#', ...) < 1 then return pretty_tostring(a1)
	else return pretty_tostring(a1), ArgsToString(...) end
end


local blist, input = {GetDisabledFontObject = true, GetHighlightFontObject = true, GetNormalFontObject = true}
local function downcasesort(a,b)
	local ta, tb = type(a), type(b)
	if ta == "number" and tb ~= "number" then return true end
	if ta ~= "number" and tb == "number" then return false end
	if ta == "number" and tb == "number" then return a < b end
	return a and b and tostring(a):lower() < tostring(b):lower()
end
local function pcallhelper(success, ...) if success then return string.join(", ", ArgsToString(...)) end end
function Spew(input, a1, ...)
	if select('#', ...) == 0 then
		if type(a1) == "table" then
			if type(rawget(a1, 0)) == "userdata" and type(a1.GetObjectType) == "function" then
				-- We've got a frame!
				Print("|cffffea00<"..a1:GetObjectType()..":"..(a1:GetName() or input.."(anon)").."|r")
				local sorttable = {}
				for i in pairs(a1) do table.insert(sorttable, i) end
				for i in pairs(getmetatable(a1).__index) do table.insert(sorttable, i) end
				table.sort(sorttable, downcasesort)
				for _,i in ipairs(sorttable) do
					local v, output = a1[i]
					if type(v) == "function" and type(i) == "string" and not blist[i] and (i:find("^Is") or i:find("^Can") or i:find("^Get")) then
						output = pcallhelper(pcall(v, a1))
					end
					if output then Print("    |cff7fd5ff"..tostring(i).."|r => "..output)
					else Print("    |cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(v)) end
				end
				Print("|cffffea00>|r")
				ShowUIPanel(panel)
			else
				-- Normal table
				Print("|cff9f9f9f{  -- "..input.."|r")
				local sorttable = {}
				for i in pairs(a1) do table.insert(sorttable, i) end
				table.sort(sorttable, downcasesort)
				for _,i in ipairs(sorttable) do Print("    |cff7fd5ff"..tostring(i).."|r = "..pretty_tostring(a1[i], 1)) end
				Print("|cff9f9f9f}  -- "..input.."|r")
				ShowUIPanel(panel)
			end
		else Print("|cff999999"..input.."|r => "..pretty_tostring(a1), DEFAULT_CHAT_FRAME) end
	else
		Print("|cff999999"..input.."|r => "..string.join(", ", ArgsToString(a1, ...)), DEFAULT_CHAT_FRAME)
	end
end


SLASH_SPEW1 = "/spew"
function SlashCmdList.SPEW(text)
	input = text:trim():match("^(.-);*$")
	if input == "" then ShowUIPanel(panel)
	elseif input == "mouse" then
		local t, f = {}, EnumerateFrames()
		SpewMouse = {}
		while f do
			if f:IsVisible() and MouseIsOver(f) then
				table.insert(SpewMouse, f)
				table.insert(t, f:GetName() or "<Anon>")
			end
			f = EnumerateFrames(f)
		end
		Spew("Visible frames under mouse (stored in table `SpewMouse`", t)
	else
		local f, err = loadstring(string.format("Spew(%q, %s)", input, input))
		if f then f() else Print("|cffff0000Error:|r "..err) end
	end
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
