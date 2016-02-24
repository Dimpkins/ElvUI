﻿local E, L, V, P, G = unpack(select(2, ...));
local AB = E:GetModule("ActionBars");

local split = string.split;

local bar = CreateFrame("Frame", "ElvUI_Bar4", E.UIParent, "SecureHandlerStateTemplate");

function AB:CreateBar4()
	local point, anchor, attachTo, x, y = split(",", self["barDefaults"]["bar4"].position);
	bar:Point(point, anchor, attachTo, x, y);
	bar.id = "4";
	bar:SetFrameStrata("LOW");
	bar:CreateBackdrop("Default");
	bar.backdrop:SetAllPoints();
	bar.buttons = {};
	self:HookScript(bar, "OnEnter", "Bar_OnEnter");
	self:HookScript(bar, "OnLeave", "Bar_OnLeave");
	local button
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		button = _G["MultiBarLeftButton" .. i];
		bar.buttons[i] = button;
		bar:SetFrameRef("MultiBarLeftButton" .. i, button);
		self:HookScript(button, "OnEnter", "Button_OnEnter");
		self:HookScript(button, "OnLeave", "Button_OnEnter");
	end
	
	bar:Execute([[
		buttons = table.new();
		for i = 1, 12 do
			table.insert(buttons, self:GetFrameRef("MultiBarLeftButton" .. i));
		end
	]]);
	
	bar:SetAttribute("_onstate-page", [[ 
		for i, button in ipairs(buttons) do
			button:SetAttribute("actionpage", tonumber(newstate));
		end
	]]);
	
	bar:SetAttribute("_onstate-show", [[		
		if(newstate == "hide") then
			self:Hide();
		else
			self:Show();
		end
	]])
	
	self["handledBars"]["bar4"] = bar;
	E:CreateMover(bar, "ElvAB_4", L["Bar "] .. "4", nil, nil, nil, "ALL,ACTIONBARS");
	self:PositionAndSizeBar("bar4");
end