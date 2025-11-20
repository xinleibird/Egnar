-- Change to values corresponding to your setup
local MeleeAttack = 59
local RangedAttack = 63

function Egnar_OnLoad()
	Egnar_Frame:Hide()
	_, cl = UnitClass("player")
	if cl ~= "ROGUE" then
		DEFAULT_CHAT_FRAME:AddMessage("Egnar is only for rogues")
		return
	end
	FontString1:SetTextColor(1, 1, 1)

	this:RegisterEvent("PLAYER_TARGET_CHANGED")
	this:RegisterEvent("UNIT_FACTION")

	this:SetScript("OnEvent", Egnar_OnEvent)
	this:SetScript("OnUpdate", Egnar_OnUpdate)

	this:RegisterForDrag("LeftButton")
	this:SetScript("OnDragStart", function()
		this:StartMoving()
	end)
	this:SetScript("OnDragStop", function()
		this:StopMovingOrSizing()
	end)

	DEFAULT_CHAT_FRAME:AddMessage("Egnar Loaded")
end

function SetColor(r, g, b, a)
	Egnar_Frame:SetBackdropColor(r, g, b, a)
	Egnar_Frame:SetBackdropBorderColor(r, g, b, a)
end

function Egnar_OnUpdate()
	if IsActionInRange(MeleeAttack) == 1 then
		if UnitXP_SP3 then
			if UnitXP("behind", "player", "target") then
				FontString1:SetText("背后")
				SetColor(unpack({ 0, 1, 0, 1 }))
			else
				FontString1:SetText("直面")
				SetColor(unpack({ 1, 0, 0, 1 }))
			end
		else
			FontString1:SetText("肉搏")
			SetColor(unpack({ 0, 1, 0, 1 }))
		end
	elseif IsActionInRange(RangedAttack) == 1 then
		if CheckInteractDistance("target", 4) then
			FontString1:SetText("可射")
			SetColor(unpack({ 0, 0.5, 1, 0.7 }))
		else
			FontString1:SetText("极射")
			SetColor(unpack({ 0, 0, 1, 0.7 }))
		end
	elseif CheckInteractDistance("target", 4) then
		FontString1:SetText("死区")
		SetColor(unpack({ 1, 0.5, 0, 0.3 }))
	else
		FontString1:SetText("不及")
		SetColor(unpack({ 1, 0.5, 0, 0.3 }))
	end
end

function Egnar_OnEvent()
	if UnitExists("target") and (not UnitIsDead("target")) and UnitCanAttack("player", "target") then
		Egnar_Frame:Show()
	else
		Egnar_Frame:Hide()
	end
end
