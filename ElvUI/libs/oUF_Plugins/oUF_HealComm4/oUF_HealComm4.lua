local _, ns = ...;
local oUF = ns.oUF or oUF;
assert(oUF, "oUF_HealComm4 was unable to locate oUF install");

local healcomm = LibStub("LibHealComm-4.0");
local format = string.format;
local min = math.min;

local function Update(self, event, unit)
	local healCommBar = self.HealCommBar;
	healCommBar.parent = self;
	
	if(not self.unit or UnitIsDeadOrGhost(self.unit) or not UnitIsConnected(self.unit)) then
		if(healCommBar.myBar) then
			healCommBar.myBar:Hide();
		end
		
		if(healCommBar.otherBar) then
			healCommBar.otherBar:Hide();
		end
		return;
	end
	
	local health, maxHealth = UnitHealth(self.unit), UnitHealthMax(self.unit);
	local guid = UnitGUID(self.unit);
	local timeFrame = self.HealCommTimeframe and GetTime() + self.HealCommTimeframe or nil;
	
	local myIncomingHeal = healcomm:GetHealAmount(guid, healcomm.ALL_HEALS, timeFrame, UnitGUID("player")) or 0;
	local allIncomingHeal = healcomm:GetHealAmount(guid, healcomm.ALL_HEALS, timeFrame) or 0;
	
	if(health + allIncomingHeal > maxHealth) then
		allIncomingHeal = maxHealth - health;
	end
	
	if(allIncomingHeal < myIncomingHeal) then
		myIncomingHeal = allIncomingHeal;
		allIncomingHeal = 0;
	else
		allIncomingHeal = allIncomingHeal - myIncomingHeal;
	end
	
	if(healCommBar.myBar) then
		healCommBar.myBar:SetMinMaxValues(0, maxHealth);
		healCommBar.myBar:SetValue(myIncomingHeal);
		healCommBar.myBar:Show();
	end

	if(healCommBar.otherBar) then
		healCommBar.otherBar:SetMinMaxValues(0, maxHealth);
		healCommBar.otherBar:SetValue(allIncomingHeal);
		healCommBar.otherBar:Show();
	end
	
	if(healCommBar.PostUpdate) then
		return healCommBar:PostUpdate(unit, myIncomingHeal, allIncomingHeal);
	end
end

local function Path(self, ...)
	return (self.HealCommBar.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function MultiUpdate(...)
	for i = 1, select("#", ...) do
		for _, frame in ipairs(oUF.objects) do
			if(frame.unit and (frame.HealCommBar and frame:IsElementEnabled("HealComm4")) and UnitGUID(frame.unit) == select(i, ...)) then
				Path(frame);
			end
		end
	end
end

local function HealComm_Heal_Update(event, casterGUID, spellID, healType, _, ...)
	MultiUpdate(...);
end

local function HealComm_Modified(event, guid)
	MultiUpdate(guid);
end

local function Enable(self)
	local healCommBar = self.HealCommBar;
	if(healCommBar) then
		healCommBar.__owner = self;
		healCommBar.ForceUpdate = ForceUpdate;
		
		self:RegisterEvent("UNIT_HEALTH", Path);
		self:RegisterEvent("UNIT_MAXHEALTH", Path);
		
		return true;
	end
end

local function Disable(self)
	local healCommBar = self.HealCommBar;
	if(healCommBar) then
		self:UnregisterEvent("UNIT_HEALTH", Path);
		self:UnregisterEvent("UNIT_MAXHEALTH", Path);
		
		if(healCommBar.myBar) then
			healCommBar.myBar:Hide();
		end
		
		if(healCommBar.otherBar) then
			healCommBar.otherBar:Hide();
		end
	end
end

oUF:AddElement("HealComm4", Path, Enable, Disable);

healcomm.RegisterCallback("HealComm4", "HealComm_HealStarted", HealComm_Heal_Update);
healcomm.RegisterCallback("HealComm4", "HealComm_HealUpdated", HealComm_Heal_Update);
healcomm.RegisterCallback("HealComm4", "HealComm_HealDelayed", HealComm_Heal_Update);
healcomm.RegisterCallback("HealComm4", "HealComm_HealStopped", HealComm_Heal_Update);
healcomm.RegisterCallback("HealComm4", "HealComm_ModifierChanged", HealComm_Modified);
healcomm.RegisterCallback("HealComm4", "HealComm_GUIDDisappeared", HealComm_Modified);