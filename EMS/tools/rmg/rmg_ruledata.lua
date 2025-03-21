-- ************************************************************************************************ --
-- *	Seed
-- *

EMS.RD.Rules.RMG_Seed = EMS.T.CopyTable(EMS.RD.Templates.StdRule);

function EMS.RD.Rules.RMG_Seed:SetValue(_value)
	EMS.RD.Rules.PredefinedRuleset:SoftCustomize()
	if _value < 0 or _value >= 1000000000 then
		--self.value = 0
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_Seed:GetTitle()
	return "Seed"--EMS.L.RMG_Seed
end

function EMS.RD.Rules.RMG_Seed:GetDescription()
	return "Legt den Seed zur Generierung der Karte fest. @cr @cr @color:51,204,255,255 HINWEIS: @color:255,255,255,255 Der Seed wirkt sich nur auf das Gelände aus. Entities können variieren, da der Server einen eigenen Seed für Zufallszahlen setzt."
end

-- ************************************************************************************************ --
-- *	GenerateRivers ( TeamBorders )
-- *

EMS.RD.Rules.RMG_GenerateRivers = EMS.T.CopyTable(EMS.RD.Templates.StdRule);

function EMS.RD.Rules.RMG_GenerateRivers:GetTitle()
	return "Team Abgrenzung"
end

function EMS.RD.Rules.RMG_GenerateRivers:GetDescription()
	return "Legt fest, wie rivalisierende Teams räumlich von einander getrennt werden sollen. @cr @cr Zäune - Tore können zusätzlich konfiguriert werden. Diese Öffnen sich zum Ende des Waffenstillstands. @cr Flüsse - Straßen sollten in diesem Fall auch aktiviert sein, da die Flüsse sonst nur im Winter zu überqueren sind. Bis zum Ende des Waffenstillstands ist der Bau von Brücken verboten. @cr keine - Die Karte ist für jeden Spieler gleichermaßen zugänglich."
end

function EMS.RD.Rules.RMG_GenerateRivers:SetValue(_value)
	EMS.RD.Rules.PredefinedRuleset:SoftCustomize()
	-- incompatible with random player location
	if EMS.RD.Rules.RMG_RandomPlayerPosition.value == 1 then
		return
	end

	if _value < 1 then
		_value = table.getn(RandomMapGenerator.TeamBorderTypes)
	elseif _value > table.getn(RandomMapGenerator.TeamBorderTypes) then
		_value = 1
	end
	self.value = _value
	
	XGUIEng.ShowWidget("RMG1Frame3a", RandomMapGenerator.TeamBorderTypes[self.value].gate)
	XGUIEng.ShowWidget("RMG1Frame3b", RandomMapGenerator.TeamBorderTypes[self.value].gate)
end

function EMS.RD.Rules.RMG_GenerateRivers:GetRepresentative()
	return RandomMapGenerator.TeamBorderTypes[self.value].representative or RandomMapGenerator.TeamBorderTypes[self.value].id
end

-- ************************************************************************************************ --
-- *	GateLayout
-- *

EMS.RD.Rules.RMG_GateLayout = EMS.T.CopyTable(EMS.RD.Templates.StdRule);

function EMS.RD.Rules.RMG_GateLayout:GetTitle()
	return "Tor Position"
end

function EMS.RD.Rules.RMG_GateLayout:GetDescription()
	return "Legt die Position fest, an der Tore erstellt werden sollen. @cr Ihr habt folgende Optionen: @cr - je Spieler:  Ein kleineres Tor für jeden Spieler @cr - je Team: Ein größeres Tor je Team @cr @cr @color:51,204,255,255 HINWEIS: @color:255,255,255,255 In der Kartenmitte befindet sich ein Kreis aus Zäunen, in dem die Tore generieret werden. Das Areal im Kreis ist neutraler Boden und bis zum Ende des Waffenstillstands nicht erreichbar."
end

function EMS.RD.Rules.RMG_GateLayout:SetValue(_value)
	EMS.RD.Rules.PredefinedRuleset:SoftCustomize()
	if _value < 1 then
		_value = table.getn(RandomMapGenerator.GateLayouts)
	elseif _value > table.getn(RandomMapGenerator.GateLayouts) then
		_value = 1
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_GateLayout:GetRepresentative()
	return RandomMapGenerator.GateLayouts[self.value].representative or RandomMapGenerator.GateLayouts[self.value].id
end

-- ************************************************************************************************ --
-- *	GateSize
-- *

EMS.RD.Rules.RMG_GateSize = EMS.T.CopyTable(EMS.RD.Templates.StdRule);

function EMS.RD.Rules.RMG_GateSize:GetTitle()
	return "Tor Größe"
end

function EMS.RD.Rules.RMG_GateSize:GetDescription()
	return "Legt die Größe der Tore fest. @cr @cr @color:51,204,255,255 HINWEIS: @color:255,255,255,255 In der Kartenmitte befindet sich ein Kreis aus Zäunen, in dem die Tore generieret werden. Das Areal im Kreis ist neutraler Boden und bis zum Ende des Waffenstillstands nicht erreichbar."
end

function EMS.RD.Rules.RMG_GateSize:SetValue(_value)
	EMS.RD.Rules.PredefinedRuleset:SoftCustomize()
	if _value < 1 then
		_value = table.getn(RandomMapGenerator.GateSizes)
	elseif _value > table.getn(RandomMapGenerator.GateSizes) then
		_value = 1
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_GateSize:GetRepresentative()
	return RandomMapGenerator.GateSizes[self.value].representative or RandomMapGenerator.GateSizes[self.value].id
end

-- ************************************************************************************************ --
-- *	GenerateRoads
-- *

EMS.RD.Rules.RMG_GenerateRoads = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
EMS.RD.Rules.RMG_GenerateRoads.Representatives = {[0] = "@center aus", [1] = "@center ein",};

function EMS.RD.Rules.RMG_GenerateRoads:GetTitle()
	return "Straßen"
end

function EMS.RD.Rules.RMG_GenerateRoads:GetDescription()
	return "Legt fest, ob Straßen zu nahegelegenen Spielern generiert werden sollen. @cr @cr @color:51,204,255,255 TIPP: @color:255,255,255,255 Wenn ihr bei Teambegrenzung die Option Flüsse wählt, werden Brücken an den Stellen generiert, an denen sich Starßen und Flüsse kreuzen."
end

-- ************************************************************************************************ --
-- *	LandscapeSet
-- *

EMS.RD.Rules.RMG_LandscapeSet = EMS.T.CopyTable(EMS.RD.Templates.StdRule);

function EMS.RD.Rules.RMG_LandscapeSet:GetTitle()
	return "Landschaftsset"
end

function EMS.RD.Rules.RMG_LandscapeSet:GetDescription()
	return "Legt das Landschaftsset fest."
end

function EMS.RD.Rules.RMG_LandscapeSet:SetValue(_value)
	EMS.RD.Rules.PredefinedRuleset:SoftCustomize()
	if _value < 1 then
		_value = table.getn(RandomMapGenerator.LandscapeSetKeys)
	elseif _value > table.getn(RandomMapGenerator.LandscapeSetKeys) then
		_value = 1
	end
	self.value = _value
	
	RandomMapGenerator.SetupThresholdsNormal()
	if RandomMapGenerator.LandscapeSetKeys[self.value].func then
		RandomMapGenerator.LandscapeSetKeys[self.value].func()
	end
end

function EMS.RD.Rules.RMG_LandscapeSet:Evaluate()
	if RandomMapGenerator.LandscapeSetKeys[self.value].eval then
		RandomMapGenerator.LandscapeSetKeys[self.value].eval()
	end
end
	
function EMS.RD.Rules.RMG_LandscapeSet:GetRepresentative()
	return RandomMapGenerator.LandscapeSetKeys[self.value].representative or RandomMapGenerator.LandscapeSetKeys[self.value].id
end

-- ************************************************************************************************ --
-- *	MirrorMap
-- *

EMS.RD.Rules.RMG_MirrorMap = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
EMS.RD.Rules.RMG_MirrorMap.Representatives = {[0] = "@center aus", [1] = "@center ein",};

function EMS.RD.Rules.RMG_MirrorMap:SetValue(_value)
	EMS.RD.Rules.PredefinedRuleset:SoftCustomize()
	-- incompatible with random player location
	if EMS.RD.Rules.RMG_RandomPlayerPosition.value == 1 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_MirrorMap:GetTitle()
	return "Kartenspiegelung"
end

function EMS.RD.Rules.RMG_MirrorMap:GetDescription()
	return "Die Kartenspiegelung erfolgt punktsymetrisch und funktioniert für jede Anzahl von Spielern und Teams. Jedes Zweite Segment wird in der Mitte noch einmal achsengespiegelt, so dass die Kanten aneinander passen."
end

-- ************************************************************************************************ --
-- *	PlayerPosition
-- *

EMS.RD.Rules.RMG_RandomPlayerPosition = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
EMS.RD.Rules.RMG_RandomPlayerPosition.Representatives = {[0] = "@center Kreis", [1] = "@center zufällig",};

function EMS.RD.Rules.RMG_RandomPlayerPosition:SetValue(_value)
	EMS.RD.Rules.PredefinedRuleset:SoftCustomize()
	if _value == 1 then
		EMS.GL.SetValueSynced("RMG_GenerateRivers", 1)
		EMS.GL.SetValueSynced("RMG_MirrorMap", 0)
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_RandomPlayerPosition:GetTitle()
	return "Startposition"
end

function EMS.RD.Rules.RMG_RandomPlayerPosition:GetDescription()
	return "Legt fest ob die Startpositionen der Spieler einen Kreis bilden, oder alle zufällig auf der Karte verteilt werden. @cr @cr @color:255,204,51,255 VORSICHT: @color:255,255,255,255 Bei zufälliger Verteilung sind Karte spiegeln und Team Abgrenzung nicht verfügbar. @cr @cr @color:255,102,51,255 WARNUNG: @color:255,255,255,255 Bei zufälliger Verteilung kann es Vorkommen, dass nicht genug Platz für alle Stukturen wie Rohstoffschächte vorhanden ist. Der Generator wird euch dies mitteilen. @cr Außerdem kann es in seltenen Fällen Vorkommen, dass eure Burgen ineinander stehen. @cr Bei Problemen könnt ihr es mit einem anderen Seed versuchen."
end

-- ************************************************************************************************ --
-- *	TerrainBaseHeight
-- *

EMS.RD.Rules.RMG_TerrainBaseHeight = EMS.T.CopyTable(EMS.RD.Templates.StdRule);

function EMS.RD.Rules.RMG_TerrainBaseHeight:GetTitle()
	return "Gelände-Basishöhe"
end

function EMS.RD.Rules.RMG_TerrainBaseHeight:GetDescription()
	return "Legt die Höhe der ebenen Flächen fest. @cr @cr @color:51,204,255,255 TIPP: @color:255,255,255,255 Dieser Wert hat allein keinen Einfluss auf die Karte. @cr Höhere Werte ermöglichen tiefe Schluchten in Kombination mit einer hohen Amplitude."
end

-- ************************************************************************************************ --
-- *	WaterBaseHeight
-- *

EMS.RD.Rules.RMG_WaterBaseHeight = EMS.T.CopyTable(EMS.RD.Templates.StdRule);

function EMS.RD.Rules.RMG_WaterBaseHeight:GetTitle()
	return "Wasser-Basishöhe"
end

function EMS.RD.Rules.RMG_WaterBaseHeight:GetDescription()
	return "Legt die Höhe von natürlichen Gewässern fest. @cr @cr @color:255,204,51,255 VORSICHT: @color:255,255,255,255 Die Wasser-Basishöhe sollte nicht über der Gelände-Basishöhe liegen, da die ebenen Flächen sonst Unterwasser liegen."
end

-- ************************************************************************************************ --
-- *	NoiseFactorZ
-- *

EMS.RD.Rules.RMG_NoiseFactorZ = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_NoiseFactorZ:GetTitle()
	return "Amplitude"
end

function EMS.RD.Rules.RMG_NoiseFactorZ:GetDescription()
	return "Dieser Wert gibt die Stärke von Erhebungen und Vertifungen an. Er wirkt sich nur auf die Z Achse aus."
end

function EMS.RD.Rules.RMG_NoiseFactorZ:SetValue(_value)
	self.value = _value
end

function EMS.RD.Rules.RMG_NoiseFactorZ:GetRepresentative()
	return self.value .."%"
end

-- ************************************************************************************************ --
-- *	NoiseFactorXY
-- *

EMS.RD.Rules.RMG_NoiseFactorXY = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_NoiseFactorXY:GetTitle()
	return "Maßstab"
end

function EMS.RD.Rules.RMG_NoiseFactorXY:GetDescription()
	return "Dieser Wert wirkt wie ein Zoom. Er wirkt sich nur auf die X und Y Achse aus. @cr @cr @color:51,204,255,255 TIPP: @color:255,255,255,255 @cr Kleinere Werte zoomen heran: Berge, Seen und Ebenen nehmen mehr Fläche ein. Abstände werden größer. @cr Größere Werte zoomer heraus: Berge, Seen und Ebenen nehmen weniger Fläche ein. Abstände werden kleiner. @cr @cr @color:255,204,51,255 VORSICHT: @color:255,255,255,255 Dieser Parameter hat sehr großen Einfluss auf die Karte!"
end

function EMS.RD.Rules.RMG_NoiseFactorXY:SetValue(_value)
	self.value = _value
end

function EMS.RD.Rules.RMG_NoiseFactorXY:GetRepresentative()
	return self.value .. "%"
end

-- ************************************************************************************************ --
-- *	Forest Density
-- *

EMS.RD.Rules.RMG_ForestDensity = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ForestDensity:GetTitle()
	return "Walddichte"
end

function EMS.RD.Rules.RMG_ForestDensity:GetDescription()
	return "Je höher der Wert, um so mehr Bäume und Sträucher werden generiert."
end

function EMS.RD.Rules.RMG_ForestDensity:SetValue(_value)
	self.value = _value
end

function EMS.RD.Rules.RMG_ForestDensity:GetRepresentative()
	return self.value .. "%"
end

-- ************************************************************************************************ --
-- *	ThresholdPike
-- *

EMS.RD.Rules.RMG_ThresholdPike = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdPike:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdPike:GetTitle()
	return "Gipfel"
end

function EMS.RD.Rules.RMG_ThresholdPike:GetDescription()
	return EMS.GL.GetThresholdDescription("Berggipfel")
end

-- ************************************************************************************************ --
-- *	ThresholdMountain
-- *

EMS.RD.Rules.RMG_ThresholdMountain = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdMountain:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdMountain:GetTitle()
	return "Berg"
end

function EMS.RD.Rules.RMG_ThresholdMountain:GetDescription()
	return EMS.GL.GetThresholdDescription("Berge")
end

-- ************************************************************************************************ --
-- *	ThresholdHill
-- *

EMS.RD.Rules.RMG_ThresholdHill = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdHill:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdHill:GetTitle()
	return "Hügel"
end

function EMS.RD.Rules.RMG_ThresholdHill:GetDescription()
	return EMS.GL.GetThresholdDescription("Hügel")
end

-- ************************************************************************************************ --
-- *	ThresholdSea
-- *

EMS.RD.Rules.RMG_ThresholdSea = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdSea:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdSea:GetTitle()
	return "Meer"
end

function EMS.RD.Rules.RMG_ThresholdSea:GetDescription()
	return EMS.GL.GetThresholdDescription("Meere")
end

-- ************************************************************************************************ --
-- *	ThresholdLake
-- *

EMS.RD.Rules.RMG_ThresholdLake = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdLake:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdLake:GetTitle()
	return "See"
end

function EMS.RD.Rules.RMG_ThresholdLake:GetDescription()
	return EMS.GL.GetThresholdDescription("Seen")
end

-- ************************************************************************************************ --
-- *	ThresholdCoast
-- *

EMS.RD.Rules.RMG_ThresholdCoast = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdCoast:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdCoast:GetTitle()
	return "Küste"
end

function EMS.RD.Rules.RMG_ThresholdCoast:GetDescription()
	return EMS.GL.GetThresholdDescription("Küsten")
end

-- ************************************************************************************************ --
-- *	ThresholdForest
-- *

EMS.RD.Rules.RMG_ThresholdForest = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdForest:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdForest:GetTitle()
	return "Wald"
end

function EMS.RD.Rules.RMG_ThresholdForest:GetDescription()
	return EMS.GL.GetThresholdDescription("Wälder")
end

-- ************************************************************************************************ --
-- *	ThresholdMeadow
-- *

EMS.RD.Rules.RMG_ThresholdMeadow = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdMeadow:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdMeadow:GetTitle()
	return "Wiese"
end

function EMS.RD.Rules.RMG_ThresholdMeadow:GetDescription()
	return EMS.GL.GetThresholdDescription("Wiesen")
end

-- ************************************************************************************************ --
-- *	ThresholdFlatland
-- *

EMS.RD.Rules.RMG_ThresholdFlatland = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdFlatland:SetValue(_value)
	if _value > 1000 or _value < 0 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdFlatland:GetTitle()
	return "Flachland"
end

function EMS.RD.Rules.RMG_ThresholdFlatland:GetDescription()
	return "Legt fest, zwischen welchen Werten die Geländehöhe geglättet werden soll. @cr @cr @color:51,204,255,255 HINWEIS: @color:255,255,255,255 Der linke Wert muss negativ sein, der rechte positiv."
end

-- ************************************************************************************************ --
-- *	ThresholdLowForest
-- *

EMS.RD.Rules.RMG_ThresholdLowForest = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdLowForest:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdLowForest:GetTitle()
	return "Wald"
end

function EMS.RD.Rules.RMG_ThresholdLowForest:GetDescription()
	return EMS.GL.GetThresholdDescription("Wälder")
end

-- ************************************************************************************************ --
-- *	ThresholdLowMeadow
-- *

EMS.RD.Rules.RMG_ThresholdLowMeadow = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdLowMeadow:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdLowMeadow:GetTitle()
	return "Wiese"
end

function EMS.RD.Rules.RMG_ThresholdLowMeadow:GetDescription()
	return EMS.GL.GetThresholdDescription("Wiesen")
end

-- ************************************************************************************************ --
-- *	ThresholdLowFlatland
-- *

EMS.RD.Rules.RMG_ThresholdLowFlatland = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdLowFlatland:SetValue(_value)
	if _value > 0 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdLowFlatland:GetTitle()
	return "Flachland"
end

function EMS.RD.Rules.RMG_ThresholdLowFlatland:GetDescription()
	return "Legt fest, zwischen welchen Werten die Geländehöhe geglättet werden soll. @cr @cr @color:51,204,255,255 HINWEIS: @color:255,255,255,255 Der linke Wert muss negativ sein, der rechte positiv."
end

-- ************************************************************************************************ --
-- *	ThresholdRoad
-- *

EMS.RD.Rules.RMG_ThresholdRoad = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdRoad:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdRoad:GetTitle()
	return "Straße"
end

function EMS.RD.Rules.RMG_ThresholdRoad:GetDescription()
	return "Legt fest, auf welchem Wert Straßen generiert werden sollen. @cr @cr @color:51,204,255,255 TIPP: @color:255,255,255,255 Wenn ihr wollt, dass die Straßen durch Wälder führen, müsst ihr einen Wert zwischen Wald und Hügel oder zwischen Wald und Küste wählen. @cr Die Option Straßen muss aktiviert sein."
end

-- ************************************************************************************************ --
-- *	ThresholdHighForest
-- *

EMS.RD.Rules.RMG_ThresholdHighForest = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdHighForest:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdHighForest:GetTitle()
	return "Hochwald"
end

function EMS.RD.Rules.RMG_ThresholdHighForest:GetDescription()
	return EMS.GL.GetThresholdDescription("Hochwälder")
end

-- ************************************************************************************************ --
-- *	ThresholdHighMeadow
-- *

EMS.RD.Rules.RMG_ThresholdHighMeadow = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdHighMeadow:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdHighMeadow:GetTitle()
	return "Hochwiese"
end

function EMS.RD.Rules.RMG_ThresholdHighMeadow:GetDescription()
	return EMS.GL.GetThresholdDescription("Hochwiesen")
end

-- ************************************************************************************************ --
-- *	ThresholdPlateau
-- *

EMS.RD.Rules.RMG_ThresholdPlateau = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ThresholdPlateau:SetValue(_value)
	if _value > 1000 or _value < -1000 then
		return
	end
	self.value = _value
end

function EMS.RD.Rules.RMG_ThresholdPlateau:GetTitle()
	return "Hochebene"
end

function EMS.RD.Rules.RMG_ThresholdPlateau:GetDescription()
	return "Dieser Wert verhält sich ähnlich wie die Option Flachland, nur dass die Geländehöhe oberhalb dieses Werts geglättet wird. @cr @cr @color:51,204,255,255 TIPP: @color:255,255,255,255 Setzt diesen Wert auf 1000 um Hochebenen zu deaktivieren."
end

-- ************************************************************************************************ --
-- *	Amount Clay Pit
-- *

EMS.RD.Rules.RMG_AmountClayPit = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountClayPit:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountClayPit:GetDescription()
	return EMS.GL.GetAmountDescription("Lehmschächten")
end

-- ************************************************************************************************ --
-- *	Content Clay Pit
-- *

EMS.RD.Rules.RMG_ContentClayPit = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentClayPit:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentClayPit:GetDescription()
	return EMS.GL.GetContentDescription("Lehmschächten")
end

-- ************************************************************************************************ --
-- *	Amount Clay Pile
-- *

EMS.RD.Rules.RMG_AmountClayPile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountClayPile:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountClayPile:GetDescription()
	return EMS.GL.GetAmountDescription("Lehmhaufen")
end

-- ************************************************************************************************ --
-- *	Content Clay Pile
-- *

EMS.RD.Rules.RMG_ContentClayPile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentClayPile:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentClayPile:GetDescription()
	return EMS.GL.GetContentDescription("Lehmhaufen")
end

-- ************************************************************************************************ --
-- *	Amount Stone Pit
-- *

EMS.RD.Rules.RMG_AmountStonePit = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountStonePit:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountStonePit:GetDescription()
	return EMS.GL.GetAmountDescription("Steinbrüchen")
end

-- ************************************************************************************************ --
-- *	Content Stone Pit
-- *

EMS.RD.Rules.RMG_ContentStonePit = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentStonePit:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentStonePit:GetDescription()
	return EMS.GL.GetContentDescription("Steinbrüchen")
end

-- ************************************************************************************************ --
-- *	Amount Stone Pile
-- *

EMS.RD.Rules.RMG_AmountStonePile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountStonePile:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountStonePile:GetDescription()
	return EMS.GL.GetAmountDescription("Steinhaufen")
end

-- ************************************************************************************************ --
-- *	Content Stone Pile
-- *

EMS.RD.Rules.RMG_ContentStonePile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentStonePile:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentStonePile:GetDescription()
	return EMS.GL.GetContentDescription("Steinhaufen")
end

-- ************************************************************************************************ --
-- *	Amount Iron Pit
-- *

EMS.RD.Rules.RMG_AmountIronPit = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountIronPit:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountIronPit:GetDescription()
	return EMS.GL.GetAmountDescription("Eisenschächten")
end

-- ************************************************************************************************ --
-- *	Content Iron Pit
-- *

EMS.RD.Rules.RMG_ContentIronPit = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentIronPit:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentIronPit:GetDescription()
	return EMS.GL.GetContentDescription("Eisenschächten")
end

-- ************************************************************************************************ --
-- *	Amount Iron Pile
-- *

EMS.RD.Rules.RMG_AmountIronPile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountIronPile:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountIronPile:GetDescription()
	return EMS.GL.GetAmountDescription("Eisenhaufen")
end

-- ************************************************************************************************ --
-- *	Content Iron Pile
-- *

EMS.RD.Rules.RMG_ContentIronPile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentIronPile:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentIronPile:GetDescription()
	return EMS.GL.GetContentDescription("Eisenhaufen")
end

-- ************************************************************************************************ --
-- *	Amount Sulfur Pit
-- *

EMS.RD.Rules.RMG_AmountSulfurPit = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountSulfurPit:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountSulfurPit:GetDescription()
	return EMS.GL.GetAmountDescription("Schwefelschächten")
end

-- ************************************************************************************************ --
-- *	Content Sulfur Pit
-- *

EMS.RD.Rules.RMG_ContentSulfurPit = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentSulfurPit:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentSulfurPit:GetDescription()
	return EMS.GL.GetContentDescription("Schwefelschächten")
end

-- ************************************************************************************************ --
-- *	Amount Sulfur Pile
-- *

EMS.RD.Rules.RMG_AmountSulfurPile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountSulfurPile:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountSulfurPile:GetDescription()
	return EMS.GL.GetAmountDescription("Schwefelhaufen")
end

-- ************************************************************************************************ --
-- *	Content Sulfur Pile
-- *

EMS.RD.Rules.RMG_ContentSulfurPile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentSulfurPile:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentSulfurPile:GetDescription()
	return EMS.GL.GetContentDescription("Schwefelhaufen")
end

-- ************************************************************************************************ --
-- *	Amount Village Center
-- *

EMS.RD.Rules.RMG_AmountVC = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountVC:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountVC:GetDescription()
	return "Legt die Anzahl an Siedlungsplätzen je Spieler fest."
end

function EMS.RD.Rules.RMG_AmountVC:SetValue(_value)
	if _value > 0 then
		self.value = _value
	end
end

-- ************************************************************************************************ --
-- *	Amount Wood Pile
-- *

EMS.RD.Rules.RMG_AmountWoodPile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_AmountWoodPile:GetTitle()
	return "Anzahl"
end

function EMS.RD.Rules.RMG_AmountWoodPile:GetDescription()
	return EMS.GL.GetAmountDescription("Holzhaufen")
end

-- ************************************************************************************************ --
-- *	Content Wood Pile
-- *

EMS.RD.Rules.RMG_ContentWoodPile = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_ContentWoodPile:GetTitle()
	return "Rohstoffmenge"
end

function EMS.RD.Rules.RMG_ContentWoodPile:GetDescription()
	return EMS.GL.GetContentDescription("Holzhaufen")
end

-- ************************************************************************************************ --
-- *	Show Resources
-- *

EMS.RD.Rules.RMG_ShowResources = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
EMS.RD.Rules.RMG_ShowResources.Representatives = {[0] = "@center aus", [1] = "@center ein",};

function EMS.RD.Rules.RMG_ShowResources:GetTitle()
	return "zeige Rohstoffschächte"
end

function EMS.RD.Rules.RMG_ShowResources:GetDescription()
	return "Legt fest, ob Spielern ihre Rohstoffschächte auf der Karte aufgedeckt werden sollen."
end

-- ************************************************************************************************ --
-- *	Show Village Centers
-- *

EMS.RD.Rules.RMG_ShowVillageCenters = EMS.T.CopyTable(EMS.RD.Templates.StdBool);
EMS.RD.Rules.RMG_ShowVillageCenters.Representatives = {[0] = "@center aus", [1] = "@center ein",};

function EMS.RD.Rules.RMG_ShowVillageCenters:GetTitle()
	return "zeige Dorfzentren"
end

function EMS.RD.Rules.RMG_ShowVillageCenters:GetDescription()
	return "Legt fest, ob Spielern ihre Dorfzentren auf der Karte aufgedeckt werden sollen."
end

-- ************************************************************************************************ --
-- *	Player Config
-- *

EMS.RD.Rules.RMG_PlayerConfig = EMS.T.CopyTable(EMS.RD.Templates.StdRule);
	
function EMS.RD.Rules.RMG_PlayerConfig:GetTitle()
	return "Spielerkonfiguration"
end

function EMS.RD.Rules.RMG_PlayerConfig:GetDescription()
	return "Hier könnt ihr Dummy Spieler hinzufügen und entfernen. @cr @cr @color:51,204,255,255 TIPP: @color:255,255,255,255 Ein Dummy Spieler wird bei der Generierung wie ein richtiger Spieler behandelt mit dem Unterschied, dass für ihn keine Startgebäude platziert werden. @cr Diese Einstellung dient in erster Linie dazu, bei ungleicher Anzahl an Spielern pro Team faire Platz- und Rohstoffverhältnisse herzustellen."
end

function EMS.RD.Rules.RMG_PlayerConfig:SetValue(_value)
	self.value = _value
end

function EMS.RD.Rules.RMG_PlayerConfig:GetValue()
	return self.value
end
