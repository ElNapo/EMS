-- ************************************************************************************************ 
-- *                                                                                              * 
-- *                                                                                              * 
-- *                                              EMS                                             * 
-- *                                         GUI Legenden                                         * 
-- *                                                                                              * 
-- *                                                                                              * 
-- ************************************************************************************************ 
EMS.GL = {};
EMS.GL.Command = {};
EMS.CanChangeRules = false;

function EMS.GL.Setup()
	EMS.GL.MenuShown = false;
	-- Load Sync mechanism
	EMS.GL.ExternSyncMethod = Sync.CallNoSync;

	-- remove not needed things
	--XGUIEng.ShowWidget("EMSPUGFrame12",0);
	--XGUIEng.ShowWidget("EMSPUGFrame7",0);
	
	EMS.GL.GameStarted = false;
	
	EMS.GL.SetupMenuController();
	EMS.GL.HideMenuElementsInErbe();
	
	-- Yes callback is overwritten and handles GUI actions
	EMS.GL.DialogYesCallback = function() end;
	EMS.GL.DialogNoCallback = function() end;
	
	EMS.GL.GUIAction_ToggleMenu = GUIAction_ToggleMenu;
	EMS.GL.MenuWindows = {
		"StatisticsWindow",
		"DiplomacyWindow",
		"TradeWindow",
		"QuestWindow",
		"BuyHeroWindow",
		"NetworkWindow",
		"EMSMenu"
	};
	
	EMS.GL.HideAllNormalWindows = function()
		for i = 1, table.getn(EMS.GL.MenuWindows) -1 do
			XGUIEng.ShowWidget(EMS.GL.MenuWindows[i], 0);
		end
	end
	
	EMS.GL.CheckWindowsShown = function()
		-- only display rule window if no other window is displayed
		local shown = false;
		for i = 1, table.getn(EMS.GL.MenuWindows) do
			if XGUIEng.IsWidgetShown(EMS.GL.MenuWindows[i]) == 1 then
				XGUIEng.ShowWidget("EMSRuleOverview", 0);
				shown = true;
			end
		end
		if not shown and not EMS.GL.GameStarted then
			XGUIEng.ShowWidget("EMSRuleOverview", 1);
		end
	end
	
	-- remove color change buttons that are not needed
	for i = 8, EMS.TotalPlayerCount+1, -1 do
		XGUIEng.ShowWidget("EMSCCB"..i, 0);
	end

	-- hide color changer on map start
	XGUIEng.ShowWidget("EMSColorChanger", 0);
	
	GUIAction_ToggleMenu = function( _menu, _state)
		if XGUIEng.IsWidgetShown(XGUIEng.GetWidgetID("DiplomacyWindow")) == 0 then
			XGUIEng.ShowWidget("EMSColorChanger", 0);
		end
		if _menu == "MainMenuWindow" and _state == 0 then
			-- hide quit menu if it was open
			XGUIEng.ShowWidget("MainMenuBoxQuitAppWindow", 0);
			return 0;
		end
		if _menu == "MainMenuWindow" or _menu == XGUIEng.GetWidgetID("MainMenuWindow") then
			local ret = EMS.GL.ToggleMainMenu();
			EMS.GL.CheckWindowsShown();
			XGUIEng.ShowWidget("MainMenuBoxQuitAppWindow", 0);
			return ret;
		elseif XGUIEng.IsWidgetShown("EMSMenu") == 1 then
			return;
		end
		local ret = EMS.GL.GUIAction_ToggleMenu(_menu, _state);
		EMS.GL.CheckWindowsShown();
		if XGUIEng.IsWidgetShown(XGUIEng.GetWidgetID("DiplomacyWindow")) == 0 then
			XGUIEng.ShowWidget("EMSColorChanger", 0);
		else
			XGUIEng.ShowWidget("EMSColorChanger", 1);
		end
		return ret;
	end
	EMS.GL.OverwriteSaveGameFunctions();
	
	EMS.GL.SetupPingWindow();
	EMS.GL.SetupOptions();
	EMS.GL.SetupChatHistory();
	
	EMS.GL.SoundTable = {
		["#01"] = "MP_TauntYes",
		["#02"] = "MP_TauntNo",
		["#03"] = "MP_TauntNow",
		["#04"] = "MP_TauntAttack",
		["#05"] = "MP_TauntAttackArea",
		["#06"] = "MP_TauntDefendArea",
		["#07"] = "MP_TauntHelpMe",
		["#08"] = "MP_TauntNeedClay",
		["#09"] = "MP_TauntNeedGold",
		["#10"] = "MP_TauntNeedIron",
		["#11"] = "MP_TauntNeedStone",
		["#12"] = "MP_TauntNeedSulfur",
		["#13"] = "MP_TauntNeedWood",
		["#14"] = "MP_TauntVeryGood",
		["#15"] = "MP_TauntYouAreLame",
		["#16"] = "MP_TauntFunny01",
		["#17"] = "MP_TauntFunny02",
		["#18"] = "MP_TauntFunny03",
		["#19"] = "MP_TauntFunny04",
		["#20"] = "MP_TauntFunny05",
	};
	
	EMS.GL.SetupCommands();
	
	-- this overwrites MP Game Callback completely
	EMS.GL.MPGame_ApplicationCallback_ReceivedChatMessage = MPGame_ApplicationCallback_ReceivedChatMessage;
	MPGame_ApplicationCallback_ReceivedChatMessage = function(_msg, _alliedOnly, _senderID)

		local ColorR, ColorG, ColorB = 255,255,255;
		if _senderID <= XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer() and _senderID > 0 then
			ColorR, ColorG, ColorB = GUI.GetPlayerColor( _senderID );
		end
		local color = "@color:" .. ColorR .. "," .. ColorG .. "," .. ColorB .. " ";

		if _alliedOnly == 1 then
			if _senderID == -1 then
				_msg = "(S) " .. color .. _msg;
			else
				_msg = "(T) " .. color .. _msg;
			end;
		else
			_msg = color .. _msg;
		end
		
		-- teamchat for spectators
		if GUI.GetPlayerID() == 17 and _senderID == -1 then
			_alliedOnly = 0;
		end
		
		if 	_alliedOnly == 1
		and _senderID ~= GUI.GetPlayerID()
		and	Logic.GetDiplomacyState( _senderID, GUI.GetPlayerID() ) ~= Diplomacy.Friendly then
			return;
		end	
		
		-- default "ping" sound
		local soundId = Sounds.Misc_Chat;
		
		local soundMessage = false;
		if string.find( _msg, "yipie", 1, true ) then
			soundMessage = true;
			soundId = Sounds.Misc_Chat2;
		elseif string.find( _msg, "#%d%d") then
			local starts, ends = string.find( _msg, "#%d%d");
			local soundIdKey = string.sub(_msg, starts, ends);
			if EMS.GL.SoundTable[soundIdKey] then
				soundId = Sounds["VoicesMentor_" .. EMS.GL.SoundTable[soundIdKey]];
				_msg = string.sub(_msg, 0, starts-1) .. XGUIEng.GetStringTableText("VoicesMentor/" .. EMS.GL.SoundTable[soundIdKey]);
				soundMessage = true;
			end
		end

		-- display neutral messages
		if _senderID == -1 then
			Sound.PlayGUISound(Sounds.Misc_Chat, 0);
			GUI.AddNote( _msg );
			if not string.find(_msg, "Spectator Marker", 1, true)
			and not string.find(_msg, "Global Marker", 1, true)
			and not soundMessage then
				EMS.GL.ChatHistory.Add(_msg);
			end
			return;
		end
		
		-- add to chat history despite mute
		-- but no soundmessages
		if not soundMessage then
			EMS.GL.ChatHistory.Add(_msg);
		end
		
		
		-- mute soundmessages
		if EMS.GL.Options.Config.Sound[_senderID] == 0 and soundMessage then
			return;
		end
		
		-- sender is muted
		if EMS.GL.Options.Config.Chat[_senderID] == 0 then
			return;
		end
		
		Sound.PlayGUISound(soundId, 0);
		GUI.AddNote(_msg);
	end
	
	EMS.GL.CurrentPage = "";
	EMS.GL.CurrentRulePage = 1;
	
	EMS.GL.MainMenuButtons = {
		["Restart"] = function()
			-- Restart Map
			EMS.GL.OpenYesNoDialog(EMS.L.DoYouWantToRestart, Framework.RestartMap);
		end,
		["OpenRules"] = function()
			EMS.GL.UpdateCompleteRuleGUI();
			EMS.GL.ShowPage("EMSPagesUnits");
		end,
		["Save"] = function()
			MainWindow_SaveGame_GenerateList();
			EMS.GL.ShowPage("MainMenuSaveWindow");
		end,
		["Load"] = function()
			MainWindow_LoadGame_GenerateList();
			EMS.GL.ShowPage("MainMenuLoadWindow");
		end,
		["Options"] = function()
			EMS.GL.ShowPage("MainMenuOptionWindow");
		end,
		["Extra"] = function()
			XGUIEng.ShowWidget(EMS.GL.OptionsMenu, 0);
			XGUIEng.ShowWidget("EMSMPOptionsAdditional", 1);
			EMS.GL.ShowPage("", 0);
		end,
		["CloseMenu"] = function()
			EMS.GL.ToggleMainMenu();
		end,
		["LeaveGame"] = function()
			EMS.GL.OpenYesNoDialog(EMS.L.DoYouReallyWantToQuit, QuitGame);
		end,
	};
	
	EMS.GL.ExtraMenuButtons = {
		["ChatHistory"] = function()
			-- Start/Restart Map
			EMS.GL.ShowPage("EMSPagesChatHistory");
		end,
		["Ping"] = function()
			EMS.GL.Options.UpdateGUIComplete();
			EMS.GL.ShowPage("EMSPagesPingView");
		end,
		["BackToMain"] = function()
			XGUIEng.ShowWidget(EMS.GL.OptionsMenu, 1);
			XGUIEng.ShowWidget("EMSMPOptionsAdditional", 0);
			EMS.GL.ShowPage("", 0);
		end,
	};
	
	EMS.GL.GUIUpdate =
	{
		["Sword"] = EMS.GL.GUIUpdate_Units,
		["PoleArm"] = EMS.GL.GUIUpdate_Units,
		["Bow"] = EMS.GL.GUIUpdate_Units,
		["HeavyCavalry"] = EMS.GL.GUIUpdate_Units,
		["LightCavalry"] = EMS.GL.GUIUpdate_Units,
		["Rifle"] = EMS.GL.GUIUpdate_Units,
		["Thief"] = EMS.GL.GUIUpdate_Units,
		["Scout"] = EMS.GL.GUIUpdate_Units,
		["Bridge"] = EMS.GL.GUIUpdate_Units,
		["TowerLevel"] = EMS.GL.GUIUpdate_Units,
		["Markets"] = EMS.GL.GUIUpdate_Markets,
		["Cannon1"] = EMS.GL.GUIUpdate_Cannons,
		["Cannon2"] = EMS.GL.GUIUpdate_Cannons,
		["Cannon3"] = EMS.GL.GUIUpdate_Cannons,
		["Cannon4"] = EMS.GL.GUIUpdate_Cannons,
		["Cannons"] = EMS.GL.GUIUpdate_Cannons,
		["MakeSummer"] = EMS.GL.GUIUpdate_GfxToggleButton,
		["MakeRain"] = EMS.GL.GUIUpdate_GfxToggleButton,
		["MakeSnow"] = EMS.GL.GUIUpdate_GfxToggleButton,
		["AntiBug"] = EMS.GL.GUIUpdate_TextToggleButton,
		["BlessLimit"] = EMS.GL.GUIUpdate_TextToggleButton,
		["HQRush"] = EMS.GL.GUIUpdate_TextToggleButton,
		["ResourceLevel"] = EMS.GL.GUIUpdate_ResourceLevel,
		["Peacetime"] = EMS.GL.GUIUpdate_Text,
		["WeatherChangeLockTimer"] = EMS.GL.GUIUpdate_Text,
		["TradeLimit"] = EMS.GL.GUIUpdate_Text,
		["TowerLimit"] = EMS.GL.GUIUpdate_Text,
		["PredefinedRuleset"] = EMS.GL.GUIUpdate_TextToggleButton,
		["GameMode"] = EMS.GL.GUIUpdate_TextToggleButton,
	};
	for i = 1, 8 do
		EMS.GL.GUIUpdate["NumberOfHeroesForPlayer"..i] = EMS.GL.GUIUpdate_TextHero;
	end
	EMS.GL.GUIUpdate["NumberOfHeroesForAll"] = EMS.GL.GUIUpdate_TextHero;
	
	local heroes = 
	{
		"Dario",
		"Ari",
		"Erec",
		"Salim",
		"Pilgrim",
		"Helias",
		"Drake",
		"Yuki",
		"Kerberos",
		"Mary_de_Mortfichet",
		"Varg",
		"Kala"
	}
	for i = 1, 12 do
		EMS.GL.GUIUpdate[heroes[i]] = EMS.GL.GUIUpdate_GfxToggleButton;
	end
	
	EMS.GL.MapRuleToGUIWidget =
	{
		["Sword"] = {"EMSPU1Lvl", 4},
		["PoleArm"] = {"EMSPU2Lvl", 4},
		["Bow"] = {"EMSPU3Lvl", 4},
		["HeavyCavalry"] = {"EMSPU5Lvl", 2},
		["LightCavalry"] = {"EMSPU6Lvl", 2},
		["Rifle"] = {"EMSPU7Lvl", 2},
		["Thief"] = {"EMSPU8Lvl", 1},
		["Scout"] = {"EMSPU9Lvl", 1},
		["Bridge"] = {"EMSPU10Lvl", 1},
		["TowerLevel"] = {"EMSPU11Lvl", 3},
		["Markets"] = {"EMSPUGF6Value","EMSPU12Lvl1"},
		["MakeSummer"] = "EMSPUGF3Value1",
		["MakeRain"] = "EMSPUGF3Value2",
		["MakeSnow"] = "EMSPUGF3Value3",
		["AntiBug"] = "EMSPUGF7Value",
		["BlessLimit"] = "EMSPUGF8Value",
		["HQRush"] = "EMSPUGF9Value",
		["Peacetime"] = {"EMSPUGF1Value"},
		["WeatherChangeLockTimer"] = {"EMSPUGF2Value"},
		["TradeLimit"] = {"EMSPUGF5Value"},
		["TowerLimit"] = {"EMSPUGF4Value"},
		["NumberOfHeroesForPlayer9"] = "EMSPUH9Value";
		["PredefinedRuleset"] = "EMSPUGF11Value",
		["GameMode"] = "EMSPUGF12Value",
	};
	for i = 1, 12 do
		EMS.GL.MapRuleToGUIWidget[heroes[i]] = "EMSPH"..i.."N";
	end
	
	EMS.GL.MapWidgetToRule =
	{
		["EMSPUGF1Value"] = "Peacetime",
		["EMSPUGF2Value"] = "WeatherChangeLockTimer",
		["EMSPUGF6Value"] = "Markets",
		["EMSPUGF5Value"] = "TradeLimit",
		["EMSPUGF4Value"] = "TowerLimit",
		["EMSPUH9Value"] = "NumberOfHeroesForAll",
	};
	
	EMS.GL.GameInformation_IsHumanPlayerAttachedToPlayerID = XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID;
	XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID = function(_playerId)
		if not EMS.T.IsMultiplayer() then
			if _playerId == 1 then return 1 end
		end
		return EMS.GL.GameInformation_IsHumanPlayerAttachedToPlayerID(_playerId);
	end
	
	local c = 1;
	for playerId = 1, 8 do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID( playerId ) == 1 then
			EMS.GL.MapWidgetToRule["EMSPUH"..c.."Value"] = "NumberOfHeroesForPlayer"..playerId;
			EMS.GL.MapRuleToGUIWidget["NumberOfHeroesForPlayer"..playerId] = "EMSPUH"..c.."Value";
			c = c + 1;
		end
	end
	
	EMS.GL.UpdatePlayerNames();
	
	EMS.GL.CustomTextInputCallback = function(_input, _noChange, _widget)
		if _noChange then return end;
		local rule = EMS.GL.MapWidgetToRule[_widget];
		EMS.GL.SetValue(rule,tonumber(_input));
	end
	
	EMS.GL.HeroInputCallback = function(_input, _noChange, _widget)
		if _noChange then return end;
		local rule = EMS.GL.MapWidgetToRule[_widget];
		EMS.GL.SetValue(rule,tonumber(_input));
	end
	

	EMS.GL.CustomTextInputs = {
		["Peacetime"] = CTI.New({Widget="EMSPUGF1Value", Before = "@center ", NumbersOnly=true, MaxLength=3, Callback=EMS.GL.CustomTextInputCallback}),
		["WeatherChangeLockTimer"] = CTI.New({Widget="EMSPUGF2Value", Before = "@center ", NumbersOnly=true, MaxLength=1, Callback=EMS.GL.CustomTextInputCallback}),
		["Markets"] = CTI.New({Widget="EMSPUGF6Value", Before = "@center ", NumbersOnly=true, MaxLength=3, Callback=EMS.GL.CustomTextInputCallback}),
		["TradeLimit"] = CTI.New({Widget="EMSPUGF5Value", Before = "@center ", NumbersOnly=true, MaxLength=6, Callback=EMS.GL.CustomTextInputCallback}),
		["TowerLimit"] = CTI.New({Widget="EMSPUGF4Value", Before = "@center ", NumbersOnly=true, MaxLength=6, Callback=EMS.GL.CustomTextInputCallback}),
	};
	for i = 1,8 do
		EMS.GL.CustomTextInputs["NumberOfHeroesForPlayer"..i] = CTI.New({Widget="EMSPUH"..i.."Value", Before = "@center ", NumbersOnly=true, MaxLength=2, Callback=EMS.GL.HeroInputCallback});
	end
	EMS.GL.CustomTextInputs["NumberOfHeroesForAll"] = CTI.New({Widget="EMSPUH9Value", Before = "@center ", NumbersOnly=true, MaxLength=2, Callback=EMS.GL.HeroInputCallback});
	EMS.GL.CTIGroup = CTIGroup.New();
	local order = {"Peacetime","WeatherChangeLockTimer","Markets","TradeLimit","TowerLimit"};
	for i = 1,5 do
		EMS.GL.CTIGroup:Add(EMS.GL.CustomTextInputs[order[i]]);
	end
	
	-- chose menu
	if EMS.T.IsMultiplayer() then
		EMS.GL.OptionsMenu = "EMSMPOptionsMain";
	else
		EMS.GL.OptionsMenu = "EMSMPOptionsMainSP";
	end
	XGUIEng.ShowWidget(EMS.GL.OptionsMenu, 1);
	
	EMS.GL.GUIUpdate_All();
	EMS_GL_UpdateGUIDelayed = function()
		EMS.GL.GUIUpdate_All();
		return true;
	end
	StartSimpleJob("EMS_GL_UpdateGUIDelayed");
	
	if GUI.GetPlayerID() ~= EMS.GV.HostId then
		XGUIEng.SetText("EMSPUSCRequest"," @center Host: " .. tostring(UserTool_GetPlayerName(EMS.GV.HostId)));
	end
	
	EMS.GL.HostReminderCounter = 1;
	EMS_GL_HostReminder = function()
		-- for new players that dont open rule menu themselves
		EMS.GL.HostReminderCounter = EMS.GL.HostReminderCounter -1;
		if EMS.GL.HostReminderCounter <= 0 then
			if GUI.GetPlayerID() == EMS.GV.HostId
			and not EMS.GL.GameStarted
			and XGUIEng.IsWidgetShown("EMSMenu") == 0 then
				EMS.GL.ShowMainMenu();
				EMS.GL.ShowPage("EMSPagesUnits");
			end
			return true;
		end
	end
	StartSimpleJob("EMS_GL_HostReminder");
	if EMS.GV.IsHost then
		EMS.CanChangeRules = true;
	end
	
	if EMS.T.IsMultiplayer() then
		XGUIEng.ShowWidget("EMSMPOptionsStart", 0);
	end
end

function EMS.GL.LoadGUI()
	--[[if CMod then
		local archives = {CMod.GetAllArchives()};
		for i = 1, table.getn(archives) do
			if string.find(archives[i], "Balancing_Stuff", 1, true) or string.find(archives[i], "BalancingStuff", 1, true) then
				return;
			end
		end
	end]]
	S5Hook.LoadGUI("maps\\user\\EMS\\ems.xml");
end

function EMS.GL.HideMenuElementsInErbe()
	if not EMS.T.IsErbe() then
		return;
	end
	
	local elements = {
		"EMSPU7",
		"EMSPU8Lvl0",
		"EMSPU8Lvl1",
		"EMSPU9Lvl0",
		"EMSPU9Lvl1",
		"EMSPU10Lvl0",
		"EMSPU10Lvl1",
		"EMSPH7N",
		"EMSPH8N",
		"EMSPH12N",
		
	};
	
	for i = 1, table.getn(elements) do
		XGUIEng.ShowWidget(elements[i],0);
	end
end

function EMS.GL.SetupPingWindow()
	EMS.GL.PingWindow = {};
	for i = 1, EMS.GV.MaxPlayers do
		XGUIEng.SetText("EMSPPVP"..i, "");
		XGUIEng.SetText("EMSPPVPH"..i, "");
		XGUIEng.SetText("EMSPPVPL"..i, "");
		XGUIEng.SetText("EMSPPVPA"..i, "");
	end
	EMS.GL.PingWindow.Ticks = 0;
	EMS.GL.PingWindow.AveragePings = {};
	EMS.GL.PingWindow.Values = {};
	for player, data in pairs(EMS.PlayerList) do
		EMS.GL.PingWindow.Values[data.Name] = {CurrentPing=0, Max=0, Min=500, Average=0};
		EMS.GL.PingWindow.AveragePings[data.Name] = {};
	end
	
	EMS.GL.PingWindow.ProcessPing = function()
		EMS.GL.PingWindow.Ticks = EMS.GL.PingWindow.Ticks + 1;
		local index, ping, name, t, nr, average, networkadress;
		for i = 1, XNetwork.UserInSession_GetNumber() do
			index = i-1;
			networkadress = XNetwork.UserInSession_GetNetworkAddressByIndex(index);
			if networkadress ~= XNetwork.Host_UserInSession_GetHostNetworkAddress() then
				-- not for host
				ping = XNetwork.Ping_Get(index);
				name = XNetwork.UserInSession_GetUserNameByNetworkAddress(networkadress).."("..index..")";
				if not EMS.GL.PingWindow.Values[name] then
					EMS.GL.PingWindow.Values[name] = {CurrentPing=0, Max=0, Min=0, Average=0};
					EMS.GL.PingWindow.AveragePings[name] = {};
				end
				t = EMS.GL.PingWindow.Values[name];
				t.CurrentPing = ping;
				if t.Max < ping then
					t.Max = ping;
				elseif t.Min > ping then
					t.Min = ping;
				end
				table.insert(EMS.GL.PingWindow.AveragePings[name], ping);
				nr = table.getn(EMS.GL.PingWindow.AveragePings[name]);
				average = 0;
				for i = 1, nr do
					average = average + EMS.GL.PingWindow.AveragePings[name][i];
				end
				t.Average = average/nr;
			end
		end
		if math.mod(EMS.GL.PingWindow.Ticks, 10) == 0 then
			EMS.GL.ExternSyncMethod("EMS.GL.PingWindow.UpdateValues", EMS.GL.PingWindow.Values);
		end
		EMS.GL.PingWindow.UpdateWindow();
	end
	EMS.GL.PingWindow.UpdateWindow = function()
		local id, values;
		for player, data in pairs(EMS.PlayerList) do
			id = player;
			values = EMS.GL.PingWindow.Values[data.Name];
			XGUIEng.SetText("EMSPPVP"..id, values.CurrentPing);
			XGUIEng.SetText("EMSPPVPH"..id, values.Max);
			XGUIEng.SetText("EMSPPVPL"..id, values.Min);
			XGUIEng.SetText("EMSPPVPA"..id, values.Average);
		end
	end
	EMS.GL.PingWindow.UpdateValues = function(_values)
		if EMS.GV.IsHost then
			return;
		end
		EMS.GL.PingWindow.Values = _values;
		EMS.GL.PingWindow.UpdateWindow();
	end
	EMS_GL_PingWindow_GetPing = function()
		EMS.GL.PingWindow.ProcessPing();
	end
	
	EMS_GL_PingWindow_UpdateCNetworkPing = function()
		if Game.GameTimeGetFactor() == 0 then
			return;
		end
		local ping, t, average, nr, name;
		for player, data in pairs(EMS.PlayerList) do
			name = data.Name;
			ping = GetPingByName(name);
			t = EMS.GL.PingWindow.Values[name];
			t.CurrentPing = ping;
			if t.Max < ping then
				t.Max = ping;
			elseif t.Min > ping then
				t.Min = ping;
			end
			table.insert(EMS.GL.PingWindow.AveragePings[name], 1, ping);
			nr = table.getn(EMS.GL.PingWindow.AveragePings[name]);
			if nr >= 200 then
				table.remove(EMS.GL.PingWindow.AveragePings[name], nr);
				nr = nr - 1;
			end
			average = 0;
			for i = 1, nr do
				average = average + EMS.GL.PingWindow.AveragePings[name][i];
			end
			t.Average = average/nr;
		end
		EMS.GL.PingWindow.UpdateWindow();
	end
	
	if CNetwork then
		StartSimpleJob("EMS_GL_PingWindow_UpdateCNetworkPing");
	else
		if EMS.GV.IsHost and EMS.T.IsMultiplayer() then
			EMS.GL.PingWindow.JobId = StartSimpleJob("EMS_GL_PingWindow_GetPing");
		end
	end
	
end

function EMS.GL.SetupOptions()
	EMS.GL.Options = {Config={}};
	EMS.GL.Options.Config = {Chat={},Sound={},Vision={}};
	for i = 1, EMS.GV.MaxPlayers do
		EMS.GL.Options.Config.Chat[i] = 1;
		EMS.GL.Options.Config.Sound[i] = 1;
		EMS.GL.Options.Config.Vision[i] = 0;
	end

	EMS.GL.Options.UpdateGUIComplete = function()
		local c = 1;
		EMS.GL.Options.PlayerToID = {};
		EMS.GL.Options.IDToPlayer = {};
		for player, data in pairs(EMS.PlayerList) do
			EMS.GL.Options.PlayerToID[player] = c;
			EMS.GL.Options.IDToPlayer[c] = player;
			XGUIEng.SetText("EMSPPVN"..player, data.Name);
			if player == GUI.GetPlayerID() then
				XGUIEng.ShowWidget("EMSPPVO"..c, 0);
			end
			EMS.GL.Options.UpdateGUIRow(player);
			c = c + 1;
		end
		for i = c, 16 do -- TODO: not to be hardcoded
			XGUIEng.ShowWidget("EMSPPVO"..i, 0);
			XGUIEng.ShowWidget("EMSPPVN"..i, 0);
			XGUIEng.ShowWidget("EMSPPVP"..i, 0);
			XGUIEng.ShowWidget("EMSPPVPH"..i, 0);
			XGUIEng.ShowWidget("EMSPPVPL"..i, 0);
			XGUIEng.ShowWidget("EMSPPVPA"..i, 0);
		end
	end
	EMS.GL.Options.UpdateGUIRow = function(_player)
		local id = _id or EMS.GL.Options.PlayerToID[_player];
		local options = {"Vision","Chat","Sound"};
		for i = 1,3 do
			local option = "EMSPPVO"..id..options[i];
			if EMS.GL.Options.Config[options[i]][_player] == 1 then
				XGUIEng.SetText(option, EMS.GV.AllowedColor.." @center " .. EMS.L.Options[options[i]]);
			else
				XGUIEng.SetText(option, EMS.GV.ForbiddenColor.." @center " .. EMS.L.Options[options[i]]);
			end
		end
	end
	
	EMS.GL.Options.UpdateTooltip = function(_option, _id)
		if _id == 9 then
			_option = _option.."All";
		end
		XGUIEng.SetText("EMSToolText", EMS.L.Options[_option]);
	end
	EMS.GL.Options.Set = function(_option, _id, _flag)
		local player = EMS.GL.Options.IDToPlayer[_id];
		if _option == "OptionChat" then
			EMS.GL.Options.Config.Chat[player] = _flag;
		elseif _option == "OptionSound" then
			EMS.GL.Options.Config.Sound[player] = _flag;
		elseif _option == "OptionVision" then
			EMS.GL.Options.Config.Vision[player] = _flag
				Sync.Call("EMS.T.SetShareExploration", player, GUI.GetPlayerID(), _flag );
		end
	end
	EMS.GL.Options.Toggle = function(_option, _id)
		if _id == 9 then
			for id = 1, EMS.GV.MaxPlayers do
				EMS.GL.Options.Set(_option, id, 0);
			end
			EMS.GL.Options.UpdateGUIComplete();
			return;
		end
		local player = EMS.GL.Options.IDToPlayer[_id];
		local option, text = 1;
		if _option == "OptionChat" then
			EMS.GL.Options.Config.Chat[player] = 1 - EMS.GL.Options.Config.Chat[player]
		elseif _option == "OptionSound" then
			EMS.GL.Options.Config.Sound[player] = 1 - EMS.GL.Options.Config.Sound[player]
		elseif _option == "OptionVision" then
			EMS.GL.Options.Config.Vision[player] = 1 - EMS.GL.Options.Config.Vision[player];
			Sync.Call("EMS.T.SetShareExploration", player, GUI.GetPlayerID(), 
				  EMS.GL.Options.Config.Vision[player]);
		end
		EMS.GL.Options.UpdateGUIRow(player);
	end
	EMS.GL.Options.UpdateGUIComplete();
	EMS.GL.Options.UpdateDiplomacy = function()
		local diplomacyState;
		for player, data in pairs(EMS.PlayerList) do
			local id = EMS.GL.Options.PlayerToID[player];
			diplomacyState = Logic.GetDiplomacyState(player, GUI.GetPlayerID());
			if diplomacyState == Diplomacy.Friendly then
				XGUIEng.SetMaterialTexture( "EMSPPVO"..id.."Dipl", 0, "graphics\\textures\\gui\\window_status_friend.png" );
			elseif diplomacyState == Diplomacy.Hostile then
				XGUIEng.SetMaterialTexture( "EMSPPVO"..id.."Dipl", 0, "graphics\\textures\\gui\\window_status_hostile.png" );
			else
				XGUIEng.SetMaterialTexture( "EMSPPVO"..id.."Dipl", 0, "graphics\\textures\\gui\\window_status_neutral.png" );
			end
		end
	end
end

function EMS.GL.SetupChatHistory()
	EMS.GL.ChatHistory = {};
	EMS.GL.ChatHistory.History = {}
	EMS.GL.ChatHistory.Add = function(_text)
		local seconds = math.floor(Logic.GetTime());
		local hours = math.floor(seconds/3600);
		local minutes = math.floor((seconds-(hours*3600))/60);
		local seconds = math.floor((seconds-(hours*3600)-(minutes*60)));
		hours, minutes, seconds = tostring(hours), tostring(minutes), tostring(seconds)
		if string.len(hours) == 1 then
			hours = "0"..hours;
		end
		if string.len(minutes) == 1 then
			minutes = "0"..minutes;
		end
		if string.len(seconds) == 1 then
			seconds = "0"..seconds;
		end
		local time = "["..hours..":"..minutes..":"..seconds.."]";
		table.insert(EMS.GL.ChatHistory.History, {time, _text});
		EMS.GL.ChatHistory.UpdateAll();
	end
	EMS.GL.ChatHistory.UpdateAll = function()
		-- small history
		local lines = 5;
		local nr = table.getn(EMS.GL.ChatHistory.History);
		local start = math.min(lines, nr-1);
		local text = "";
		for i = nr-start, nr do
			text = text .. EMS.GL.ChatHistory.History[i][2] .. " @cr ";
		end
		XGUIEng.SetText("EMSChat", text);
		-- big history
		EMS.GL.ChatHistory.UpdateBig(0);
	end
	EMS.GL.CurrentIndex = 1;
	EMS.GL.ChatHistory.UpdateBig = function(_dif)
		local lines = 20;
		local currentLines = table.getn(EMS.GL.ChatHistory.History);
		if _dif == "min" then
			EMS.GL.CurrentIndex = 1
		elseif _dif == "max" then
			EMS.GL.CurrentIndex = currentLines - lines;
		else
			EMS.GL.CurrentIndex = EMS.GL.CurrentIndex + _dif;
		end
		-- index must be > 0
		EMS.GL.CurrentIndex = math.max(1, EMS.GL.CurrentIndex);
		-- index cannot be greater then totalLines - linesToShow
		EMS.GL.CurrentIndex = math.min(math.max(1, currentLines - lines), EMS.GL.CurrentIndex);
		local text = "";
		local t;
		local timetext = "";
		local numOfLines = math.min(currentLines-1, lines);
		for i = 0, numOfLines do
			t = EMS.GL.ChatHistory.History[EMS.GL.CurrentIndex+i];
			text = text .. t[1] .. " " .. t[2] .. " @cr ";
		end
		XGUIEng.SetText("EMSPCHWindow", text);
		XGUIEng.SetText("EMSPCHTotalMessages", EMS.L.Messages .. " " .. EMS.GL.CurrentIndex .. " - " .. (EMS.GL.CurrentIndex + numOfLines) ..
											   " " .. EMS.L.Of .. " " .. currentLines);
	end
	
	EMS.GL.UpdateGameDate();
	
	-- chat input
	EMS.GL.CustomChatInput = function(_input, _noChange, _widget)
		if _input == nil or _input == "" then
			return;
		end
		GameCallback_GUI_ChatStringInputDone(_input,0)
		XGUIEng.SetText("EMSChatInput", "");
		XGUIEng.ShowWidget("EMSChatInput",0);
		XGUIEng.ShowWidget("EMSChatBG",0);
	end
	
	EMS.GL.OpenMenuChat = function()
		XGUIEng.ShowWidget("EMSChatBG",1);
		XGUIEng.ShowWidget("EMSChatInput",1);
		XGUIEng.ShowWidget("EMSChatBG",1)
		XGUIEng.ShowWidget("EMSChatBG",1)
	end
		
	EMS.GL.CustomChatInputObj = CTI.New({Widget="EMSChatInput", MaxLength=80, Callback=EMS.GL.CustomChatInput, OpenCallback=EMS.GL.OpenMenuChat})
end

function EMS.GL.ShowPage(_page, _flag)
	local flag = _flag or 1 - XGUIEng.IsWidgetShown(_page);
	XGUIEng.ShowWidget(EMS.GL.CurrentPage, 0);
	XGUIEng.ShowWidget(_page, flag);
	XGUIEng.ShowWidget("EMSPagesBG", flag);
	XGUIEng.ShowWidget("EMSInvisibleClickCatcher", flag);
	EMS.GL.CurrentPage = _page;
end

function EMS.GL.ToggleRulePage(_value)
	_value = _value or 1
	XGUIEng.ShowWidget(EMS.GV.Pages[EMS.GL.CurrentRulePage], 0)
	_value = EMS.GL.CurrentRulePage + _value
	if _value < 1 then
		_value = table.getn(EMS.GV.Pages)
	elseif _value > table.getn(EMS.GV.Pages) then
		_value = 1
	end
	XGUIEng.ShowWidget(EMS.GV.Pages[_value], 1)
	EMS.GL.CurrentRulePage = _value
end

function EMS.GL.TrySync(...)
	if not EMS.CanChangeRules then
		return;
	end
	if EMS.GL.GameStarted then
		return;
	end
	-- quick sync for display
	EMS.GL.ExternSyncMethod(unpack(arg));
	-- slow sync for server record.
	Sync.Call(unpack(arg));
end

function EMS.GL.SetValue(_rule, _value)
	EMS.GL.TrySync("EMS.GL.SetValueSynced", _rule, _value);
end

function EMS.GL.Toggle(_rule, _reverse)
	if not EMS.CanChangeRules then
		return;
	end
	if not _reverse then
		EMS.GL.GetRule(_rule):Increase();
	else
		EMS.GL.GetRule(_rule):Decrease();
	end
	EMS.GL.TrySync("EMS.GL.SetValueSynced", _rule, EMS.GL.GetRule(_rule):GetValue());
end

function EMS.GL.SetValueSynced(_rule, _value)
	EMS.GL.GetRule(_rule):SetValue(_value);
	EMS.GL.GUIUpdate[_rule](_rule, _value);
	EMS.GL.GUIUpdate_TextToggleButton("PredefinedRuleset");
end

function EMS.GL.ToggleSynced(_rule)
	EMS.GL.GetRule(_rule):Increase();
	EMS.GL.GUIUpdate[_rule](_rule);
	if _rule == "PredefinedRuleset" then
		EMS.GL.GUIUpdate_All();
	end
	EMS.GL.GUIUpdate_TextToggleButton("PredefinedRuleset");
end

function EMS.GL.ActivateInput(_rule)
	if not EMS.CanChangeRules then
		return;
	end
	if EMS.GL.GameStarted then
		return;
	end
	EMS.GL.CustomTextInputs[_rule]:Open();
end

function EMS.GL.UpdateTooltip(_rule, _id)
	XGUIEng.SetText("EMSToolText", tostring(EMS.GL.GetRule(_rule):GetDescription(_id)));
end

function EMS.GL.UpdateTooltipByWidget(_widgetName, _id)
	local rule = EMS.GL.MapWidgetToRule[_widgetName];
	XGUIEng.SetText("EMSToolText", tostring(EMS.GL.GetRule(rule):GetDescription(_id)));
end

function EMS.GL.UpdateTooltipManually(_rule)
	XGUIEng.SetText("EMSToolText", EMS.L[_rule]);
end

function EMS.GL.MainMenuButtonPressed(_buttonId)
	EMS.GL.MainMenuButtons[_buttonId]();
end

function EMS.GL.ExtraMenuButtonPressed(_buttonId)
	EMS.GL.ExtraMenuButtons[_buttonId]();
end

function EMS.GL.GUIUpdate_All()
	for rule, update in pairs(EMS.GL.GUIUpdate) do
		update(rule, EMS.GL.GetRule(rule):GetValue());
	end
end

function EMS.GL.GetRule(_rule)
	return EMS.RD.Rules[_rule] or EMS.RD[_rule];
end

function EMS.GL.GUIUpdate_Units(_rule, _value)
	local widget = EMS.GL.MapRuleToGUIWidget[_rule];
	for i = 1, EMS.GL.GetRule(_rule):GetValue() do
		XGUIEng.SetMaterialColor( widget[1]..i, 0, 255, 255, 255, 255 );
		XGUIEng.SetMaterialColor( widget[1]..i, 1, 255, 255, 255, 255 );
	end
	for i = EMS.GL.GetRule(_rule):GetValue()+1, widget[2] do
		XGUIEng.SetMaterialColor( widget[1]..i, 0, 50, 50, 50, 255 );
		XGUIEng.SetMaterialColor( widget[1]..i, 1, 150, 150, 150, 255 );
	end
end

function EMS.GL.GUIUpdate_Markets(_rule, _value)
	local widget = EMS.GL.MapRuleToGUIWidget[_rule];
	if EMS.GL.GetRule(_rule):GetValue() >= 0 then
		XGUIEng.SetMaterialColor( widget[2], 0, 255, 255, 255, 255 );
		XGUIEng.SetMaterialColor( widget[2], 1, 255, 255, 255, 255 );
	else
		XGUIEng.SetMaterialColor( widget[2], 0, 50, 50, 50, 255 );
		XGUIEng.SetMaterialColor( widget[2], 1, 150, 150, 150, 255 );
	end
	EMS.GL.GUIUpdate_Text(_rule);
end

function EMS.GL.GUIUpdate_Text(_rule)
	local widget = EMS.GL.MapRuleToGUIWidget[_rule];
	local value = EMS.GL.GetRule(_rule):GetValue();
	if value <= 0 then
		value = "-";
	end
	XGUIEng.SetText(widget[1], "@center "..value);
end

function EMS.GL.GUIUpdate_Number(_rule)
	local widget = EMS.GL.MapRuleToGUIWidget[_rule];
	local value = EMS.GL.GetRule(_rule):GetRepresentative();
	XGUIEng.SetText(widget[1], "@center "..value);
end

function EMS.GL.GUIUpdate_TextHero()
	for i = 1,8 do
		XGUIEng.SetText(EMS.GL.MapRuleToGUIWidget["NumberOfHeroesForPlayer"..i], "@center "..EMS.RD.Rules["NumberOfHeroesForPlayer"..i]:GetValue());
	end
	XGUIEng.SetText("EMSPUH9Value", "@center "..EMS.RD.Rules["NumberOfHeroesForAll"]:GetValue());
end

function EMS.GL.GUIUpdate_Cannons()
	for i = 1, 4 do
		if EMS.RD.Rules["Cannon"..i]:GetValue() == 1 then
			XGUIEng.SetMaterialColor( "EMSPU4Lvl"..i, 0, 255, 255, 255, 255 );
			XGUIEng.SetMaterialColor( "EMSPU4Lvl"..i, 1, 255, 255, 255, 255 );
		else
			XGUIEng.SetMaterialColor( "EMSPU4Lvl"..i, 0, 50, 50, 50, 255 );
			XGUIEng.SetMaterialColor( "EMSPU4Lvl"..i, 1, 150, 150, 150, 255 );
		end
	end
end

function EMS.GL.GUIUpdate_GfxToggleButton(_rule)
	local widget = EMS.GL.MapRuleToGUIWidget[_rule];
	if EMS.GL.GetRule(_rule):GetValue() == 1 then
		XGUIEng.SetMaterialColor( widget, 0, 255, 255, 255, 255 );
		XGUIEng.SetMaterialColor( widget, 1, 255, 255, 255, 255 );
	else
		XGUIEng.SetMaterialColor( widget, 0, 50, 50, 50, 255 );
		XGUIEng.SetMaterialColor( widget, 1, 150, 150, 150, 255 );
	end
end

function EMS.GL.GUIUpdate_TextToggleButton(_rule)
	local widget = EMS.GL.MapRuleToGUIWidget[_rule];
	XGUIEng.SetText(widget, EMS.GL.GetRule(_rule):GetRepresentative());
end

function EMS.GL.GUIUpdate_ResourceLevel()
	if GUI.GetPlayerID() > 8 then
		return;
	end
	local lvl = EMS.RD.Rules.ResourceLevel:GetValue()
	local color_light = "@color:0,233,255 ";
	local color_dark  = "@color:0,114,125 ";
	local color = "";
	for i = 1,3 do
		if lvl == i then
			color = color_light;
		else
			color = color_dark;
		end
		XGUIEng.SetText("EMSPUGF10Value" .. i, color .. " @center " .. EMS.L.ResourceLevels[i]);
	end
	if table.getn(EMS.RD.AdditionalConfig.Ressources.Normal) == 0 then
		return;
	end
	if lvl == 1 then
		for i = 1,6 do
			XGUIEng.SetText("EMSROR"..i.."Amount", EMS.RD.AdditionalConfig.Ressources.Normal[GUI.GetPlayerID()][i]);
		end
	elseif lvl == 2 then
		for i = 1,6 do
			XGUIEng.SetText("EMSROR"..i.."Amount", EMS.RD.AdditionalConfig.Ressources.FastGame[GUI.GetPlayerID()][i]);
		end
	elseif lvl == 3 then
		for i = 1,6 do
			XGUIEng.SetText("EMSROR"..i.."Amount", EMS.RD.AdditionalConfig.Ressources.SpeedGame[GUI.GetPlayerID()][i]);
		end
	end
end

function EMS.GL.GUIUpdate_RuleOverview()
	-- Peactime
	XGUIEng.SetText("EMSROL1Text", EMS.GV.RuleOverviewColor1 .. " @center " .. EMS.L.Peacetime);
	XGUIEng.SetText("EMSROL1Value", EMS.GV.RuleOverviewColor2 .. " @center " .. EMS.RD.Rules.Peacetime:GetValue());
	
	-- Ruleset
	XGUIEng.SetText("EMSROL2Text", EMS.GV.RuleOverviewColor1 .. " @center " .. EMS.L.PredefinedRuleset);
	XGUIEng.SetText("EMSROL2Value", EMS.GV.RuleOverviewColor2 .. " " .. EMS.RD.Rules.PredefinedRuleset:GetRepresentative());
	
	-- GameMode
	XGUIEng.SetText("EMSROL3Text", EMS.GV.RuleOverviewColor1 .. " @center " .. EMS.L.GameMode);
	XGUIEng.SetText("EMSROL3Value", EMS.GV.RuleOverviewColor2 .. " " .. EMS.RD.Rules.GameMode:GetRepresentative());

	XGUIEng.SetText("EMSRORHead", EMS.GV.RuleOverviewColor2 .. " @center ".. EMS.RD.Rules.ResourceLevel:GetRepresentative());
end

function EMS.GL.SetupMenuController()
	EMS.GL.MenuController = {};
	EMS.GL.MenuController.Open = false;
	
	EMS.GL.ControllerUpdate = function()
		if XGUIEng.IsModifierPressed(Keys.ModifierAlt) == 1 and XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 then
			if XGUIEng.IsWidgetShown("EMSMenu") == 0 then
				EMS.GL.ShowMainMenu();
				EMS.GL.MenuController.Open = true;
			end
		else
			if EMS.GL.MenuController.Open then
				EMS.GL.HideMainMenu();
				EMS.GL.MenuController.Open  = false;
			end
		end
	end
end

function EMS.GL.UpdatePlayerNames()
	local c = 1;
	for playerId = 1, 8 do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID( playerId ) == 1 then
			XGUIEng.SetText("EMSPUH"..c.."Text", EMS.PlayerList[playerId].ColorName);
			c = c + 1;
		end
	end
	-- TODO auf 16 spieler erweitern
	XGUIEng.SetText("EMSPUH9Text", EMS.L.AllPlayers);
	for i = c, 8 do
		XGUIEng.ShowWidget("EMSPUH"..i, 0);
	end
end

function EMS.GL.UpdateGameDate()
	local CreateDate = function()
		local time = Framework.GetSystemTimeDateString();
		local offsets = {1,4,6,7,9,10,12,13,15,16};
		local t = {};
		for i = 1, 10, 2 do
			t[i] = string.sub(time, offsets[i], offsets[i+1]);
		end
		return t[5] .. "." .. t[3] .. "." .. t[1] .. "  " .. t[7] .. ":" .. t[9];
	end
	
	XGUIEng.SetText("EMSPCHDate", EMS.L.GameOf .. " " .. CreateDate());
end


function EMS.GL.HideMainMenu()
	XGUIEng.ShowWidget("EMSMenu", 0);
	XGUIEng.ShowWidget("Normal", 1);
	if not EMS.GL.GameStarted then
		XGUIEng.ShowWidget("EMSRuleOverview", 1);
	else
		if not (EMS.GL.CustomShown or false) then
			XGUIEng.ShowWidget("EMSRuleOverview", 0);
		end
	end
end

function EMS.GL.ShowMainMenu()
	XGUIEng.ShowWidget("EMSMenu", 1);
	XGUIEng.ShowWidget("Normal", 0);
	XGUIEng.ShowWidget("EMSRuleOverview", 0);
end

function EMS.GL.ToggleMainMenu()
	if XGUIEng.IsWidgetShown("EMSMenu") == 1 then
		EMS.GL.HideMainMenu();
		EMS.GL.HideAllNormalWindows();
	else
		GUI.CancelState();
		EMS.GL.ShowMainMenu();
	end
end

function EMS.GL.OpenYesNoDialog(_title, _yesCallback, _noCallback)
	XGUIEng.SetText("EMSPLGQuestion", "@center " .. _title);
	EMS.GL.DialogYesCallback = _yesCallback or function() EMS.GL.ShowPage("", 0); end;
	EMS.GL.DialogNoCallback  = _noCallback or function() EMS.GL.ShowPage("", 0); end;
	if XGUIEng.IsWidgetShown("EMSPagesYesNo") == 0 then
		EMS.GL.ShowPage("EMSPagesYesNo");
	end
end

function EMS.GL.StartRequest()
	if not EMS.CanChangeRules then
		return;
	end
	if EMS.GL.GameStarted then
		return;
	end
	XGUIEng.ShowWidget("EMSPUSCRequest", 0);
	XGUIEng.ShowWidget("EMSPUSCYes", 1);
	XGUIEng.ShowWidget("EMSPUSCNo", 1);
end

function EMS.GL.StartRequestYes()
	XGUIEng.ShowWidget("EMSPUSCYes", 0);
	XGUIEng.ShowWidget("EMSPUSCNo", 0);
	EMS.GL.ToggleMainMenu();
	
	local startDelay = 2
	if Logic.GetTime() < startDelay then -- things look bad
		Sound.PlayGUISound( Sounds.VoicesMentor_MP_TauntNo, 100)
		Message("Das Spiel kann nicht zu Sekunde 0 gestartet werden.")
		Message("Wartet noch "..(startDelay-Logic.GetTime()).." Sekunden!") -- TODO: Make these things look less ugly
		XGUIEng.ShowWidget("EMSPUSCRequest", 1)
		return
	end
	
	Sync.Call("EMS.GL.InitiateStart");
	if EMS.UseCNetwork then -- TODO: refactor Sync.Call, so sync call works as a substitute.
		Sync.Call("EMS.GL.SetRulesByConfig", Sync.TableToString(EMS.RD.GetRuleConfig()));
	else
		Sync.Call("EMS.GL.SetRulesByConfig", EMS.RD.GetRuleConfig());
	end
	
	local startController = 2;
	EMS_GL_ControlStart = function()
		startController = startController - 1;
		if EMS.GL.GameStarted then
			return true;
		end
		if startController <= 0 then
			Sync.Call("EMS.GL.InitiateStart");
			startController = 2;
			return;
		end
	end
	EMS.GL.ControlStartJob = StartSimpleJob("EMS_GL_ControlStart");
end

function EMS.GL.StartRequestNo()
	XGUIEng.ShowWidget("EMSPUSCRequest", 1);
	XGUIEng.ShowWidget("EMSPUSCYes", 0);
	XGUIEng.ShowWidget("EMSPUSCNo", 0);
end

function EMS.GL.InitiateStart()
	if EMS.GL.GameStarted then
		return;
	end
	EMS.GL.GameStarted = true;
	if not EMS.T.IsErbe() then
		Sound.PlayGUISound(Sounds.Misc_so_signalhorn, 50);
	end
	Sound.PlayGUISound(Sounds.OnKlick_PB_Tower3, 50);
	EMS.GL.HideMainMenu();
	EMS.GL.StartCounter = 10;
	EMS.GL.StartCounterJobId = StartSimpleJob("EMS_GL_Start_Counter_Job");
	XGUIEng.SetText("EMSMACountdown", "@color:0,255,0 @center --------- " .. EMS.GL.StartCounter .. " ---------");
	XGUIEng.ShowWidget("EMSMACountdown", 1);
	-- for host:
	XGUIEng.SetText("EMSPUSCRequest"," @center Host: " .. tostring(UserTool_GetPlayerName(EMS.GV.HostId)));
end


function EMS.GL.SetRulesByConfig(_config)
	EMS.GL.RulesSet = EMS.GL.RulesSet or false;
	if EMS.GL.RulesSet then
		return;
	end
	EMS.GL.RulesSet = true;
	EMS.RD.SetRulesByConfig(_config);
end

function EMS_GL_Start_Counter_Job()
	EMS.GL.StartCounter = EMS.GL.StartCounter - 1;
	local color = "";
	if EMS.GL.StartCounter > 5 then
		color = "@color:0,255,0";
	elseif EMS.GL.StartCounter >= 3 then
		color = "@color:255,140,0";
	else
		color = "@color:255,0,0";
	end
	XGUIEng.SetText("EMSMACountdown", color.." @center --------- " .. EMS.GL.StartCounter .. " ---------");
	if EMS.GL.StartCounter <= 0 then
		XGUIEng.ShowWidget("EMSMACountdown", 0);
		EMS.StartGame();
		return true;
	end
end

function EMS.GL.OverwriteSaveGameFunctions()
	EMS.GL.MainWindow_SaveGame_DoSaveGame = MainWindow_SaveGame_DoSaveGame;
	MainWindow_SaveGame_DoSaveGame = function( _index )
		-- Index
		local Index = MainWindow_SaveGame_SaveListOffset + _index
		local SaveGameName
		if MainWindow_SaveGame_NameList[Index+1] ~= nil then
			SaveGameName = "save_" .. MainWindow_SaveGame_NameList[Index+1].Index
		else
			-- Create save game name
			SaveGameName = "save_" .. ( Index + 1 )
		end
		-- Init name
		MainWindow_SaveGame_SaveGameName = nil
		MainWindow_SaveGame_SaveGameDescOld = nil
		MainWindow_SaveGame_SaveGameDescNew = nil
		-- Create description
		local Description = MainWindow_SaveGame_CreateSaveGameDescription()
		-- Check if savegame alredy used -> overwrite box
		if MainWindow_SaveGame_NameList[Index+1] ~= nil then
			MainWindow_SaveGame_SaveGameName = SaveGameName
			MainWindow_SaveGame_SaveGameDescOld = MainWindow_SaveGame_NameList[Index+1].Desc
			MainWindow_SaveGame_SaveGameDescNew = Description
			EMS.GL.OpenYesNoDialog(EMS.L.DoYouReallyWantToOverwriteThisSaveGame,
				function()
					EMS.GL.ShowPage("", 0);
					EMS.GL.ToggleMainMenu();
					Framework.SaveGame(SaveGameName, Description);
					GUI.AddNote(XGUIEng.GetStringTableText( "InGameMessages/GUI_GameSaved" ));
				end,
				function()
					EMS.GL.ShowPage("MainMenuSaveWindow"); 
				end);
			return
		end
		Framework.SaveGame( SaveGameName, Description )
		GUI.AddNote(XGUIEng.GetStringTableText( "InGameMessages/GUI_GameSaved" ));
		EMS.GL.ToggleMainMenu();
	end

	MainWindow_SaveGame_UpdateButton = function(_Slot)
		local Index = MainWindow_SaveGame_SaveListOffset + _Slot
		local Name = Index + 1 .. " - " .. XGUIEng.GetStringTableText( "IngameMenu/SaveGame_EmptySlot" )
		local DisableState = 0
		if MainWindow_SaveGame_NameList[Index+1] ~= nil then
			-- Create save game name
			Name = ( MainWindow_SaveGame_NameList[Index+1].Index ) .. " - " .. MainWindow_SaveGame_NameList[Index+1].Desc
		end
		if XNetwork ~= nil and XNetwork.Manager_DoesExist() == 1 then
			DisableState = 1
		end
		local Text = "@color:255,255,255,0 . @color:255,255,255 " .. Name
		XGUIEng.SetText( XGUIEng.GetCurrentWidgetID(), Text )
		XGUIEng.DisableButton( XGUIEng.GetCurrentWidgetID(), DisableState )
	end
	
	MainWindow_LoadGame_UpdateButton = function( _Slot )
		local Index = MainWindow_SaveGame_LoadListOffset + _Slot
		local Name = ""
		local DisableState = 0
		if Index < table.getn(MainWindow_LoadGame_NameList) then
			-- Create save game name
			if MainWindow_LoadGame_NameList[Index+1].Index ~= nil then
				Name = ( MainWindow_LoadGame_NameList[Index+1].Index ) .. " - " .. MainWindow_LoadGame_NameList[Index+1].Desc
			else
				Name = MainWindow_LoadGame_NameList[Index+1].Desc
			end
		else
			DisableState = 1
		end
		if XNetwork ~= nil and XNetwork.Manager_DoesExist() == 1 then
			DisableState = 1
		end
		local Text = "@color:255,255,255,0 . @color:255,255,255 " .. Name
		XGUIEng.SetText( XGUIEng.GetCurrentWidgetID(), Text )
		XGUIEng.DisableButton( XGUIEng.GetCurrentWidgetID(), DisableState )
	end
end

function EMS.GL.SetupCommands()
	
	EMS.GL.Commands = {
		["/CC1"] = EMS.GL.Command.CustomColor1,
		["/CC2"] = EMS.GL.Command.CustomColor2,
		["/CC3"] = EMS.GL.Command.CustomColor3,
	};
	
	EMS.GL.GameCallback_GUI_ChatStringInputDone = GameCallback_GUI_ChatStringInputDone;
	GameCallback_GUI_ChatStringInputDone = function(_Message, _WidgetID)
		local pos = not string.find(_Message, "/send ",1, true) and string.find(_Message, "/", 1, true)
		if pos == 1 then
			if EMS.GL.Commands[_Message] then
				EMS.GL.Commands[_Message]();
			end
			return;
		end
		EMS.GL.GameCallback_GUI_ChatStringInputDone(_Message,_WidgetID)
	end
	
	EMS.GL.CustomColors = {
		SettlersDefault = 1,
		SettlersDefaultAndKimichuraCustom = 2,
		KimichuraCustom = 3
	};

	EMS.GL.CommandSettings = {
		CustomColor = 3,
		CustomColorKey = "EMS/CustomColor",
	};
	
	local customColor = GDB.GetValue(EMS.GL.CommandSettings.CustomColorKey);
	if customColor > 0 then
		EMS.GL.CommandSettings.CustomColor = customColor;
	end
end

function EMS.GL.Command.CustomColor1()
	-- seeing standard settler colors
	EMS.GL.CommandSettings.CustomColor = EMS.GL.CustomColors.SettlersDefault;
	GDB.SetValue(EMS.GL.CommandSettings.CustomColorKey, EMS.GL.CommandSettings.CustomColor);
end

function EMS.GL.Command.CustomColor2()
	-- seeing player name in color and custom color
	EMS.GL.CommandSettings.CustomColor = EMS.GL.CustomColors.SettlersDefaultAndKimichuraCustom;
	GDB.SetValue(EMS.GL.CommandSettings.CustomColorKey, EMS.GL.CommandSettings.CustomColor);
end

function EMS.GL.Command.CustomColor3()
	-- seeing custom color only
	EMS.GL.CommandSettings.CustomColor = EMS.GL.CustomColors.KimichuraCustom;
	GDB.SetValue(EMS.GL.CommandSettings.CustomColorKey, EMS.GL.CommandSettings.CustomColor);
end


function EMS.GL.RuleOverviewSetCustom(_title, _text)
	XGUIEng.SetText("EMSROTitle", _title);
	XGUIEng.SetText("EMSROText", _text);
end

function EMS.GL.UpdateCompleteRuleGUI()
	for k,v in pairs(EMS.GL.GUIUpdate) do
		v(k);
	end
end

function EMS.GL.RuleOverviewShowRules()
	XGUIEng.ShowWidget("EMSRORules",1);
	XGUIEng.ShowWidget("EMSROCustom",0);
	EMS.GL.CustomShown = false;
	if EMS.GL.GameStarted then
		XGUIEng.ShowWidget("EMSRuleOverview", 0);
	end
end

function EMS.GL.RuleOverviewShowCustom()
	EMS.GL.CustomShown = true;
	XGUIEng.ShowWidget("EMSRuleOverview", 1);
	XGUIEng.ShowWidget("EMSRORules",0);
	XGUIEng.ShowWidget("EMSROCustom",1);
end

function EMS.GL.CloseInfo()
	XGUIEng.ShowWidget("EMSMAInfo", 0);
end

function EMS.GL.Info(_text)
	XGUIEng.ShowWidget("EMSMAInfo", 1);
	XGUIEng.SetText("EMSMAIText", tostring(_text));
end

EMS.GL.ColorIds = {};
function EMS.GL.NextPlayerColor(_player)
	-- change the locals player color
	local playerId = -1;
	if CNetwork then
		-- map slot to player id on both pages
		_player = _player + MP_DiplomacyWindow.page * 8;
		local count = 0;
		for pID, pTable in pairs(MP_DiplomacyWindow.Players) do
			count = count + 1;
			if count == _player then
				playerId = pID;
			end
		end
	else
		-- map slot _player to _playerId without cnetwork
		local count = 0;
		for pID, pTable in pairs(EMS.PlayerList) do
			count = count + 1;
			if count == _player then
				playerId = pID;
			end
		end
	end
	
	if playerId == -1 then
		return;
	end
	local colorId;
	if EMS.GL.ColorIds[playerId] == nil then
		colorId = XNetwork.GameInformation_GetNextFreeLogicPlayerColor(XNetwork.GameInformation_GetLogicPlayerColor(_player));
		if colorId == 0 then colorId = 1 end
	else
		colorId = math.mod(EMS.GL.ColorIds[playerId], 16) + 1;
	end
	EMS.GL.ColorIds[playerId] = colorId;
	
	Display.SetPlayerColorMapping( playerId, colorId );
	local colorRGB = EMS.GV.PlayerColorsRGB[colorId];
	Logic.PlayerSetPlayerColor(playerId, colorRGB[1], colorRGB[2], colorRGB[3]);
	
	-- update player color info
	EMS.PlayerList[playerId] = EMS.T.GetPlayerInformation(playerId);
end

function EMS.GL.RandomizeRules()
	if EMS.GL.GameStarted then return end
	if GUI.GetPlayerID() ~= EMS.GV.HostId then 
		Message("Nur der Host kann diesen Button benutzen!")
		Sound.PlayGUISound(Sounds.VoicesMentor_COMMENT_BadPlay_rnd_01)
		return 
	end
	-- all checks passed, use XGUIEng.GetRandom(upperBound) to generate rules
	EMS.GL.CustomRNG:Init()
	local rng = function(_upperBound)
		return EMS.GL.CustomRNG:GetRandomNumber(_upperBound)
	end
	-- just mimic the button callback
	-- troop rules
	EMS.GL.SetValue( "Sword", rng(5))
	EMS.GL.SetValue( "PoleArm", rng(5))
	EMS.GL.SetValue( "Bow", rng(5))
	EMS.GL.SetValue( "Cannon1", rng(2))
	EMS.GL.SetValue( "Cannon2", rng(2))
	EMS.GL.SetValue( "Cannon3", rng(2))
	EMS.GL.SetValue( "Cannon4", rng(2))
	EMS.GL.SetValue( "HeavyCavalry", rng(3))
	EMS.GL.SetValue( "LightCavalry", rng(3))
	EMS.GL.SetValue( "Rifle", rng(3))
	EMS.GL.SetValue( "Thief", rng(2))
	EMS.GL.SetValue( "Scout", rng(2))
	EMS.GL.SetValue( "Bridge", rng(3))
	EMS.GL.SetValue( "TowerLevel", rng(4))
	
	-- heroes allowed
	local heroes = {
		"Dario",
		"Ari",
		"Erec",
		"Salim",
		"Pilgrim",
		"Helias",
		"Drake",
		"Yuki",
		"Kerberos",
		"Mary_de_Mortfichet",
		"Varg",
		"Kala"
	}
	for i = 1,12,1 do
		EMS.GL.SetValue( heroes[i], rng(2))
	end
	-- and hero count, this will be fun :)
	if EMS.GL.Is16PlayerEnvironment() then
		-- problem: heroes per player cannot be set for pId > 8 so just set the same count for all
		EMS.GL.SetValue( "NumberOfHeroesForAll", rng(13))
	else
		-- now here we can do some chaos :D
		for pId = 1, 8 do
			EMS.GL.SetValue( "NumberOfHeroesForPlayer"..pId, rng(13))
		end
	end
	
	
	-- misc stuff
	EMS.GL.SetValue( "MakeSummer", rng(2))
	EMS.GL.SetValue( "MakeRain", rng(2))
	EMS.GL.SetValue( "MakeSnow", rng(2))
	EMS.GL.SetValue( "HQRush", rng(2)) -- was previously commented out, lame.
	EMS.GL.SetValue( "BlessLimit", rng(2))
	EMS.GL.SetValue( "AntiBug", rng(2)) -- was previously commented out, lame.
	
	-- weather timer
	EMS.GL.SetValue( "WeatherChangeLockTimer", math.max( 1, EMS.GL.GetPoissonDistributedRealisation(13) - 8))
	
	-- peace time
	EMS.GL.SetValue( "Peacetime", rng(49))
	EMS.GL.SetValue( "TowerLimit", math.ceil(math.exp(EMS.GL.GetPoissonDistributedRealisation(100)/10 - 8.2)) )
	if rng(2) == 1 then
		EMS.GL.SetValue( "Markets", rng(15))
		EMS.GL.SetValue( "TradeLimit", math.max( 0, EMS.GL.GetPoissonDistributedRealisation(100)*250 - 20000))
	else
		EMS.GL.SetValue( "Markets", -1)
	end
	local ressourceLevelRng = rng(10)
	if ressourceLevelRng < 6 then
		EMS.GL.SetValue( "ResourceLevel", 1)
	elseif ressourceLevelRng < 9 then
		EMS.GL.SetValue( "ResourceLevel", 2)
	else
		EMS.GL.SetValue( "ResourceLevel", 3)
	end
end

-- returns true iff one of the positions 9 to 16 is used by a human player
function EMS.GL.Is16PlayerEnvironment()
	for pId = 9, 16 do
		if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID( pId ) == 1 then
			return true
		end
	end
	return false
end

-- for time stuff use different distributions
-- returns a single realisation of a random variable X where for any k \in \N_0:
--	P(X == k) = e^{-\lambda} \lambda^k / k!
function EMS.GL.GetPoissonDistributedRealisation( _lambda) -- this thing is insanely bugged rn
	-- do a lot of chained decisions 
	-- upper limit that hopefully will never be reached
	local upperLimit = 1000
	local k = 0
	local expLambda = math.exp(-_lambda)
	-- prepare some variables that will be helpful later on
	local probLeqk = 0 -- P(X <= k)
	local probEqk = 0 -- P(X == k)
	local kFaculty = 1 -- k!
	local kPotency = 1 -- lambda^k
	while k < upperLimit do
		probEqk = expLambda * kPotency / kFaculty
		probLeqk = probLeqk + probEqk
		-- argument to the biased coin is P(X == k | X >= k)
		-- if this coin is successful then return k
		if EMS.GL.GetBiasedCoinRealisation( probEqk / (1-probLeqk + probEqk)) then 
			return k
		else -- else increment k and update kFaculty and kPotency
			k = k + 1
			kFaculty = k*kFaculty
			kPotency = _lambda * kPotency
		end
	end
	return upperLimit
end

-- Just to check whether the poisson distributed RVs work as intended
function EMS.GL.TestPoissonDistribution(_numTests, _lambda)
	local realisations = {}
	for j = 1, _numTests do
		realisations[j] = EMS.GL.GetPoissonDistributedRealisation( _lambda)
	end
	-- compute the mean
	local mean = 0
	for j = 1, _numTests do
		mean = mean + realisations[j]
	end
	mean = mean / _numTests
	LuaDebugger.Log("Mean: "..mean)
	-- compute variance
	local var = 0
	for j = 1, _numTests do
		var = var + (realisations[j]-mean)*(realisations[j]-mean)
	end
	var = var / _numTests
	LuaDebugger.Log("Variance: "..var)
	
end


function EMS.GL.GetBiasedCoinRealisation( _prob)
	local multiplier = 1000
	return EMS.GL.CustomRNG:GetRandomNumber(multiplier) <= _prob*multiplier
end

EMS.GL.CustomRNG = {}
EMS.GL.CustomRNG.Prime = 684713 -- prime that will be used by the generator
EMS.GL.CustomRNG.CurrVal = 1 -- this one is actually illegal
EMS.GL.CustomRNG.LCGMultiplier = 75
EMS.GL.CustomRNG.LCGAdditive = 74
EMS.GL.CustomRNG.LCGModulus = 65537 -- 2^16 + 1
EMS.GL.CustomRNG.USE_LCG_FLAG = true
function EMS.GL.CustomRNG:Init()
	EMS.GL.CustomRNG.Seed = XGUIEng.GetRandom(self.Prime)
	EMS.GL.CustomRNG.SeedLCG = XGUIEng.GetRandom(self.LCGModulus)
end
function EMS.GL.CustomRNG:GetRandomNumber( _upperBound)
	-- if the flag is active then use the linear congruential generator
	if self.USE_LCG_FLAG then
		local rawVal = self:GetRandomNumberLCG()
		return math.mod(rawVal, _upperBound)
	end
	-- else use the custom prime one
	-- first update the currVal
	self.CurrVal = math.ceil(math.mod(self.CurrVal * self.Seed, self.Prime)) -- this should never hit 0
	if self.CurrVal == 0 then self.CurrVal = 1 end -- account for numerical instabilities
	return math.mod(self.CurrVal, _upperBound)
end
function EMS.GL.CustomRNG:GetRandomNumberLCG()
	local newVal = self.LCGMultiplier * self.SeedLCG + self.LCGAdditive
	self.SeedLCG = math.mod(newVal, self.LCGModulus)
	return self.SeedLCG
end



