
--- author: ???		current maintainer: mcb			v1.0
--  gibt den key zurück unter dem _wert gespeichert ist
function KeyOf(_wert, _table)
	if _table == nil then return false end
	for k, v in pairs(_table) do
		if v == _wert then 
			return k
		end 
	end
	return nil
end


ObserverInfo = {ObservedPlayers = {}, ObservedResearch = {}, ObservedUpgrade = {}, ShowLines = {}}

function ObserverInfo.InitIfLocalSpecForAllPlayers(guipath)
	if GUI.GetPlayerID()==17 then
		local p = {}
		for i=1,XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() do
			if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(i)==1 then
				table.insert(p, i)
			end
		end
		ObserverInfo.Init(p, guipath)
	end
end

function ObserverInfo.Init(players, guipath)
	ObserverInfo.ObservedPlayers = players
	ObserverInfo.GameCallback_StartResearch = GameCallback_StartResearch
	function GameCallback_StartResearch(id, tech, state)
		if ObserverInfo.GameCallback_StartResearch then
			ObserverInfo.GameCallback_StartResearch(id, tech, state)
		end
		if IsAlive(id) and KeyOf(GetPlayer(id), ObserverInfo.ObservedPlayers) then
			ObserverInfo.AddResearch(id, tech)
		end
	end
	ObserverInfo.GameCallback_EntityAttached = GameCallback_EntityAttached
	function GameCallback_EntityAttached(attacher, attached_to, attach_type, attached_event)
		if ObserverInfo.GameCallback_EntityAttached then
			ObserverInfo.GameCallback_EntityAttached(attacher, attached_to, attach_type, attached_event)
		end
		if attach_type==57 and IsAlive(attached_to)
		and ObserverInfo.ShowBuildingsOfUCats[Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(attached_to))]
		and KeyOf(GetPlayer(attached_to), ObserverInfo.ObservedPlayers) then
			ObserverInfo.AddUpgrade(attached_to)
		end
		if attach_type==20 and IsAlive(attacher)
		and ObserverInfo.ShowBuildingsOfUCats[Logic.GetUpgradeCategoryByBuildingType(Logic.GetEntityType(attacher))]
		and KeyOf(GetPlayer(attacher), ObserverInfo.ObservedPlayers) then
			ObserverInfo.AddBuild(attacher)
		end
	end
	ObserverInfo.GameCallback_OnBuildingUpgradeComplete = GameCallback_OnBuildingUpgradeComplete
	function GameCallback_OnBuildingUpgradeComplete(_OldID, _NewID)
		ObserverInfo.GameCallback_OnBuildingUpgradeComplete(_OldID, _NewID)
		for i=table.getn(ObserverInfo.ObservedUpgrade),1,-1 do
			local r = ObserverInfo.ObservedUpgrade[i]
			if r.id==_OldID and r.build==false then
				table.remove(ObserverInfo.ObservedUpgrade, i)
			end
		end
	end
	ObserverInfo.GameCallback_OnBuildingConstructionComplete = GameCallback_OnBuildingConstructionComplete
	function GameCallback_OnBuildingConstructionComplete(_BuildingID,_PlayerID)
		ObserverInfo.GameCallback_OnBuildingConstructionComplete(_BuildingID,_PlayerID)
		for i=table.getn(ObserverInfo.ObservedUpgrade),1,-1 do
			local r = ObserverInfo.ObservedUpgrade[i]
			if r.id==_BuildingID and r.build==true then
				table.remove(ObserverInfo.ObservedUpgrade, i)
			end
		end
	end
	ObserverInfo.GameCallback_OnTechnologyResearched = GameCallback_OnTechnologyResearched
	function GameCallback_OnTechnologyResearched(pl,tech)
		ObserverInfo.GameCallback_OnTechnologyResearched(pl,tech)
		for i=table.getn(ObserverInfo.ObservedResearch),1,-1 do
			local r = ObserverInfo.ObservedResearch[i]
			if r.player==pl and r.tech==tech then
				table.remove(ObserverInfo.ObservedResearch, i)
			end
		end
	end
	if XGUIEng.GetWidgetID("ObserverInfo")==0 then
		CWidget.Transaction_AddRawWidgetsFromFile(guipath or "data/maps/externalmap/observerinfo.xml", "VideoPreview")
		--Script.Load("data/maps/externalmap/ObserverInfoGUI.lua")
		CWidget.Transaction_Commit()
	end
	XGUIEng.ShowWidget("ObserverInfo", 1)
	Input.KeyBindDown(Keys.F7, 'XGUIEng.ShowWidget("ObserverInfo", 1-XGUIEng.IsWidgetShown("ObserverInfo"))', 2)
end

ObserverInfo.ShowBuildingsOfUCats = {
	[UpgradeCategories.Headquarters] = true,
	[UpgradeCategories.Archery] = true,
	[UpgradeCategories.Barracks] = true,
	[UpgradeCategories.Stable] = true,
	[UpgradeCategories.Foundry] = true,
	[UpgradeCategories.Tavern] = true,
	[UpgradeCategories.Monastery] = true,
	[UpgradeCategories.Tower] = true,
	[UpgradeCategories.University] = true,
	[UpgradeCategories.VillageCenter] = true,
}

function ObserverInfo.UpdateWidget()
	local txt = ""
	for _,p in ipairs(ObserverInfo.ObservedPlayers) do
		txt = txt..ObserverInfo.GetPlayerLine(p)
	end
	local ttxt = ""
	for i=table.getn(ObserverInfo.ObservedResearch),1,-1 do
		local r = ObserverInfo.ObservedResearch[i]
		local t, del = ObserverInfo.GetResearchTextLine(r)
		ttxt = t..ttxt
		if del then
			table.remove(ObserverInfo.ObservedResearch, i)
		end
	end
	txt = txt.." @cr "..ttxt
	ttxt = ""
	for i=table.getn(ObserverInfo.ObservedUpgrade),1,-1 do
		local r = ObserverInfo.ObservedUpgrade[i]
		local t, del = ObserverInfo.GetUpgradeLine(r)
		ttxt = t..ttxt
		if del then
			table.remove(ObserverInfo.ObservedUpgrade, i)
		end
	end
	txt = txt.." @cr "..ttxt
	ttxt = ""
	for i=table.getn(ObserverInfo.ShowLines),1,-1 do
		local r = ObserverInfo.ShowLines[i]
		local t, del = ObserverInfo.GetShowLine(r)
		ttxt = t..ttxt
		if del then
			table.remove(ObserverInfo.ShowLines, i)
		end
	end
	txt = txt.." @cr "..ttxt
	XGUIEng.SetText("ObserverInfoTxt", txt)
end

function ObserverInfo.AddResearch(id, tech)
	ObserverInfo.InsertByPlayer(ObserverInfo.ObservedResearch, {id=id, tech=tech, progressActive=false, timer=Logic.GetTime(), player=GetPlayer(id)})
end

function ObserverInfo.AddUpgrade(id)
	ObserverInfo.InsertByPlayer(ObserverInfo.ObservedUpgrade, {id=id, type=ObserverInfo.GetNextETypeInUCat(Logic.GetEntityType(id)), timer=Logic.GetTime(), player=GetPlayer(id), build=false})
end

function ObserverInfo.AddBuild(id)
	ObserverInfo.InsertByPlayer(ObserverInfo.ObservedUpgrade, {id=id, type=Logic.GetEntityType(id), timer=Logic.GetTime(), player=GetPlayer(id), build=true})
end

function ObserverInfo.AddLine(pl, txt)
	ObserverInfo.InsertByPlayer(ObserverInfo.ShowLines, {player=pl, txt=txt, timer=Logic.GetTime()})
end

function ObserverInfo.InsertByPlayer(t, ins)
	local p = ins.player
	for i=1,table.getn(t) do
		if t[i].player > p then
			table.insert(t, i, ins)
			return
		end
	end
	table.insert(t, ins)
end

function ObserverInfo.GetPlayerColoredName(p)
	return " @color:"..table.concat({GUI.GetPlayerColor(p)}, ",").." "..UserTool_GetPlayerName(p).." @color:255,255,255 "
end

function ObserverInfo.GetTechName(tech)
	local stt = "names/"..KeyOf(tech, Technologies)
	return XGUIEng.GetStringTableText(stt) or stt
end

function ObserverInfo.GetBuildingTypeName(ty)
	local stt = "names/"..Logic.GetEntityTypeName(ty)
	return XGUIEng.GetStringTableText(stt) or stt
end

function ObserverInfo.GetResearchTextLine(r)
	if IsDead(r.id) or Logic.GetTechnologyResearchedAtBuilding(r.id)~=r.tech or r.cancelled then
		if r.timer+15<Logic.GetTime() then
			return "", true
		end
		r.cancelled = true
		return " @cr "..ObserverInfo.GetPlayerColoredName(r.player)..ObserverInfo.GetTechName(r.tech)..(r.progressActive and " cancelled" or " 0%")
	end
	r.progressActive = true
	r.timer = Logic.GetTime()
	local prog = Logic.GetTechnologyProgress(r.player, r.tech)
	return " @cr "..ObserverInfo.GetPlayerColoredName(r.player)..ObserverInfo.GetTechName(r.tech).." "..prog.."%"
end

function ObserverInfo.GetPlayerLine(p)
	local skilled, slost, bkilled, blost = ObserverInfo.ReadPlayerKillStats(p)
	return ObserverInfo.GetPlayerColoredName(p)
	.."A:"..Logic.GetNumberOfAttractedWorker(p)
	.." L:"..Logic.GetNumberOfEntitiesOfTypeOfPlayer(p, Entities.PU_Serf)
	.." M:"..Logic.GetNumberOfAttractedSoldiers(p).." ("..Logic.GetNumberOfLeader(p)..") Pop:"
	..Logic.GetPlayerAttractionUsage(p).."/"..Logic.GetPlayerAttractionLimit(p)
	.." KD: "..skilled.."/"..slost.." + "..bkilled.."/"..blost
	.." @cr "
end

function ObserverInfo.GetUpgradeLine(r)
	if r.build then
		if IsDead(r.id) or r.cancelled then
			if r.timer+15<Logic.GetTime() then
				return "", true
			end
			r.cancelled = true
			return " @cr "..ObserverInfo.GetPlayerColoredName(r.player)..ObserverInfo.GetBuildingTypeName(r.type).." cancelled"
		end
		r.timer = Logic.GetTime()
		local prog = ObserverInfo.ReadBuildProgress(r.id)
		prog = math.floor(prog*100)
		return " @cr "..ObserverInfo.GetPlayerColoredName(r.player)..ObserverInfo.GetBuildingTypeName(r.type).." "..prog.."%"
	else
		if IsDead(r.id) or Logic.GetRemainingUpgradeTimeForBuilding(r.id)==Logic.GetTotalUpgradeTimeForBuilding(r.id) or r.cancelled then
			if r.timer+15<Logic.GetTime() then
				return "", true
			end
			r.cancelled = true
			return " @cr "..ObserverInfo.GetPlayerColoredName(r.player)..ObserverInfo.GetBuildingTypeName(r.type).." cancelled"
		end
		r.timer = Logic.GetTime()
		local t = Logic.GetTotalUpgradeTimeForBuilding(r.id)
		local prog = math.floor((t-Logic.GetRemainingUpgradeTimeForBuilding(r.id))/t*100)
		return " @cr "..ObserverInfo.GetPlayerColoredName(r.player)..ObserverInfo.GetBuildingTypeName(r.type).." "..prog.."%"
	end
end

function ObserverInfo.GetShowLine(r)
	if r.timer+15<Logic.GetTime() then
		return "", true
	end
	return " @cr "..ObserverInfo.GetPlayerColoredName(r.player)..r.txt
end

function ObserverInfo.ReadPlayerKillStats(p)
	local sv = S5Hook.GetRawMem(8758176)[0][10][p*2+1]
	return sv[82]:GetInt(), sv[83]:GetInt(), sv[84]:GetInt(), sv[85]:GetInt()
end

function ObserverInfo.ReadBuildProgress(id)
	return S5Hook.GetEntityMem(id)[76]:GetFloat()
end

function ObserverInfo.GetNextETypeInUCat(ety)
	local uc = Logic.GetUpgradeCategoryByBuildingType(ety)
	local types = {Logic.GetBuildingTypesInUpgradeCategory(uc)}
	table.remove(types, 1)
	local found = false
	for _,et in ipairs(types) do
		if found then
			return et
		elseif et==ety then
			found = true
		end
	end
end
