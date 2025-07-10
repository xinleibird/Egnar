-- Change to values corresponding to your setup
local MeleeAttack = 59
local RangedAttack = 63
local REFRESH_INTERVAL = 0.1
local STRATA_OUT = "BACKGROUND"
local STRATA_IN = "FULLSCREEN"

local lastText
local lastR, lastG, lastB, lastA

local frame, font

local function Egnar_SetColor(r, g, b, a)
	if r == lastR and g == lastG and b == lastB and a == lastA then
		return
	end
	lastR, lastG, lastB, lastA = r, g, b, a
	frame:SetBackdropColor(r, g, b, a)
	frame:SetBackdropBorderColor(r, g, b, a)
end

local function Egnar_SetText(text)
	if text == lastText then
		return
	end
	lastText = text
	font:SetText(text)
end

local function isBehind()
	if UnitXP_SP3 and type(UnitXP) == "function" then
		local ok, behind = pcall(UnitXP, "behind", "player", "target")
		if ok then
			return behind and true or false
		end
	end
	return nil
end

local nextRefresh = 0

local function Egnar_OnUpdate()
	local now = GetTime()
	if now < nextRefresh then
		return
	end
	nextRefresh = now + REFRESH_INTERVAL

	if IsActionInRange(MeleeAttack) == 1 then
		local behind = isBehind()
		if behind == true then
			Egnar_SetText("背后")
			Egnar_SetColor(0, 1, 0, 1)
		elseif behind == false then
			Egnar_SetText("直面")
			Egnar_SetColor(1, 1, 0, 1)
		else
			Egnar_SetText("肉搏")
			Egnar_SetColor(0, 1, 0, 1)
		end
	elseif IsActionInRange(RangedAttack) == 1 then
		if CheckInteractDistance("target", 4) then
			Egnar_SetText("可射")
			Egnar_SetColor(0, 0.5, 1, 0.7)
		else
			Egnar_SetText("极射")
			Egnar_SetColor(0, 0, 1, 0.7)
		end
	elseif CheckInteractDistance("target", 4) then
		Egnar_SetText("死区")
		Egnar_SetColor(1, 0, 0, 1)
	else
		Egnar_SetText("不及")
		Egnar_SetColor(1, 0.5, 0, 0.3)
	end
end

local function Egnar_OnEvent(event)
	if event == "PLAYER_REGEN_DISABLED" then
		frame:SetFrameStrata(STRATA_IN)
		return
	elseif event == "PLAYER_REGEN_ENABLED" then
		frame:SetFrameStrata(STRATA_OUT)
		return
	end
	if UnitExists("target") and (not UnitIsDead("target")) and UnitCanAttack("player", "target") then
		frame:Show()
	else
		frame:Hide()
	end
end

function Egnar_OnLoad(self)
	frame = self
	font = FontString1
	frame:Hide()
	local _, cl = UnitClass("player")
	if cl ~= "ROGUE" then
		DEFAULT_CHAT_FRAME:AddMessage("Egnar is only for rogues")
		return
	end
	font:SetTextColor(1, 1, 1)
	frame:SetFrameStrata(STRATA_OUT)

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UNIT_FACTION")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")

	self:SetScript("OnEvent", Egnar_OnEvent)
	self:SetScript("OnUpdate", Egnar_OnUpdate)

	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function()
		if IsControlKeyDown() and IsShiftKeyDown() and IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	self:SetScript("OnDragStop", function()
		self:StopMovingOrSizing()
	end)

	DEFAULT_CHAT_FRAME:AddMessage("Egnar Loaded")
end
