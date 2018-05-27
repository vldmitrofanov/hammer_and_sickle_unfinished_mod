-- common functions

function int( num )
	return(random(num,num))
end

function round( num )
	num = int(num+0.5)
	return(num)
end

function div( a,b )
	a = int(a/b)
	return(a)
end

function max( a,b )
	if(a>b) then
		return(a)
	end
	return(b)
end

function min( a,b )
	if(a<b) then
		return(a)
	end
	return(b)
end

function mod( a,b )
	return(a-int(a/b)*b)
end

function IsEqualPos(pos1,pos2)
	return( GetDistance(pos1,pos2)<=0.1 )
end

function copyUnit( unit, bNoNeedInventorySave, bNoNeedUniformSave, bNeedHeal )
	if(bNeedHeal) then
		UnitRegenerateVP(unit,10000)
		UnitHealCriticals(unit)
		UnitClearModifiers(unit)
	end
	local uName = UnitGetName(unit)
	for i=0,16 do
		local attr = UnitGetSkillMaxValue(unit,i)
		putMarker(uName.."ATTR"..i,attr)
	end	
	for i=1,94 do
		if(IsUnitHasPerk(unit,i)) then
			putMarker(uName.."PERK"..i,1)
		end
	end
	if(not bNoNeedInventorySave) then
		local item = UnitGetFirstItem( unit )
		local i = 0
		local iterated = {}		
		while(IsValid(item) and (not iterated[item])) do
			iterated[item] = true
			local id = UnitGetItemID( unit, item )
			i = i+1
			putMarker(uName.."ITEM"..i,id)
			local d = ItemGetDurability(item)
			if((d~=nil) and (d~=0)) then
				putMarker(uName.."ITEMDURABILITY"..i,d)
				putMarker(uName.."ITEMMAXDURABILITY"..i,ItemGetCurMaxDurability(item))
				if(isItemFirearm(item)) then
					if(ItemIsJammed(item)) then
						putMarker(uName.."ITEMJAMMED"..i,1)
					end
					if(ItemIsBroken(item)) then
						putMarker(uName.."ITEMBROKEN"..i,1)
					end
				end
			else
				putMarker(uName.."ITEMDURABILITY"..i,0)
			end
			item = UnitGetNextItem( unit, item )
		end
		putMarker(uName.."ITEM"..i+1,0)
		item = UnitGetSlotItem( unit, 0 )
		if(IsValid(item)) then
			putMarker(uName.."SLOT0",ItemGetID(item))
			local d = ItemGetDurability(item)
			if((d~=nil) and (d~=0)) then
				putMarker(uName.."SLOT0DURABILITY",d)
				putMarker(uName.."SLOT0MAXDURABILITY",ItemGetCurMaxDurability(item))
				if(isItemFirearm(item)) then
					if(ItemIsJammed(item)) then					
						putMarker(uName.."SLOT0JAMMED",1)
					end
					if(ItemIsBroken(item)) then
						putMarker(uName.."SLOT0BROKEN",1)
					end
				end
			else	
				putMarker(uName.."SLOT0DURABILITY",0)
			end
		else
			putMarker(uName.."SLOT0",0)
		end			
		item = UnitGetSlotItem( unit, 1 )
		if(IsValid(item)) then
			putMarker(uName.."SLOT1",ItemGetID(item))
			local d = ItemGetDurability(item)
			if((d~=nil) and (d~=0)) then
				putMarker(uName.."SLOT1DURABILITY",d)
				putMarker(uName.."SLOT1MAXDURABILITY",ItemGetCurMaxDurability(item))
				if(isItemFirearm(item)) then
					if(ItemIsJammed(item)) then					
						putMarker(uName.."SLOT1JAMMED",1)
					end
					if(ItemIsBroken(item)) then
						putMarker(uName.."SLOT1BROKEN",1)
					end
				end
			else
				putMarker(uName.."SLOT1DURABILITY",0)
			end
		else
			putMarker(uName.."SLOT1",0)
		end			
	end
	if(not bNoNeedUniformSave) then
		local item = UnitGetUniform(unit)
		if(IsValid(item)) then
			putMarker(uName.."UNIFORM",ItemGetID(item))
		end
	end
	local wID
	local adaptation
	local counter
	for i=1,5 do
		wID,adaptation,counter = UnitGetWeaponAdaptationInfo(unit,i)
		if(wID==nil) then
			wID = 0
		end
		putMarker(uName.."AWEAPON"..i,wID)	
		putMarker(uName.."ADAPTATION"..i,adaptation)	
		putMarker(uName.."ACOUNTER"..i,counter)
	end
	for i=0,24 do
		counter = UnitGetStat(unit,i)
		putMarker(uName.."STAT"..i,counter)
	end
	SetGlobalGameVar(uName.."NAME", UnitGetRealName(unit))

	counter = 0
        local item = UnitGetArmour( unit )
	if(IsValid(item)) then
		counter = ItemGetID(item)		
	end
	putMarker(uName.."ARMOR",counter)
end

function pasteUnit( unit, delta, bNoInventory, bNoUniform )
	local uName = UnitGetName(unit)

	if(delta==nil) then
		delta = 0
	end		

	local attr = getMarker(uName.."ATTR13")
	if(attr~=0) then
		UnitSetXPLevel(unit,attr+delta)
		putMarker(uName.."ATTR13",0)
	else
		return
	end

	for i=0,16 do
		local attr = getMarker(uName.."ATTR"..i)
		if((i~=13) and (attr~=0)) then
			UnitSetSkillMaxValue(unit,i,attr)
			putMarker(uName.."ATTR"..i,0)
		end
	end	
	for i=1,94 do
		local hasPerk = getMarker(uName.."PERK"..i)
		if(hasPerk==1) then
			UnitTakePerk(unit,i)
			putMarker(uName.."PERK"..i,0)
		end
	end
	if(not bNoInventory) then
		while(destroyItemInBackpack(unit)) do end
		UnitTakeOffSlotItem( unit, 0 )
		UnitTakeOffSlotItem( unit, 1 )

		i = 1	
		local id = getMarker(uName.."ITEM1")
		while(id~=0) do
			putMarker(uName.."ITEM1",0)
			local item = UnitCreateItem(unit,id,false)
			if(IsValid(item)) then
				local d = getMarker(uName.."ITEMDURABILITY"..i)	
				if(d~=0) then
					local d1 = getMarker(uName.."ITEMMAXDURABILITY"..i)
out("Create item ",item," ",id," d = ",d," d1 = ",d1)
					ItemSetDurability(item,d,d1,ItemGetMaxDurability(item))
					if(isItemFirearm(item)) then
						if(getMarker(uName.."ITEMJAMMED"..i)==1) then
							ItemSetJammed(item,true)
						end
						if(getMarker(uName.."ITEMBROKEN"..i)==1) then
							ItemSetBroken(item,true)
						end
					end
				end
			end
			i = i+1
			id = getMarker(uName.."ITEM"..i)
		end
		id = getMarker(uName.."SLOT0")
		if(id~=0) then
			putMarker(uName.."SLOT0",0)
			local item = ItemCreate(id)
			if(IsValid(item)) then
				local d = getMarker(uName.."SLOT0DURABILITY")
				if(d~=0) then
					local d1 = getMarker(uName.."SLOT0MAXDURABILITY")
out("Create item in slot0 ",item," ",id," d = ",d," d1 = ",d1)
					ItemSetDurability(item,d,d1,ItemGetMaxDurability(item))
					if(isItemFirearm(item)) then
						if(getMarker(uName.."SLOT0JAMMED")==1) then
							ItemSetJammed(item,true)
						end
						if(getMarker(uName.."ISLOT0BROKEN")==1) then
							ItemSetBroken(item,true)
						end
					end
				end
				UnitEquipSlotItem( unit, 0, item )
			end
		end
		id = getMarker(uName.."SLOT1")
		if(id~=0) then
			putMarker(uName.."SLOT1",0)
			local item = ItemCreate(id)
			if(IsValid(item)) then
				local d = getMarker(uName.."SLOT1DURABILITY")
				if(d~=0) then
					local d1 = getMarker(uName.."SLOT1MAXDURABILITY")
out("Create item in slot1 ",item," ",id," d = ",d," d1 = ",d1)
					ItemSetDurability(item,d,d1,ItemGetMaxDurability(item))
					if(isItemFirearm(item)) then
						if(getMarker(uName.."SLOT1JAMMED")==1) then
							ItemSetJammed(item,true)
						end
						if(getMarker(uName.."ISLOT1BROKEN")==1) then
							ItemSetBroken(item,true)
						end
					end
				end
				UnitEquipSlotItem( unit, 1, item )
			end
		end
	end
	if(not bNoUniform) then
		id = getMarker(uName.."UNIFORM")
		if(id~=0) then
			putMarker(uName.."UNIFORM",0)
			local item = ItemCreate(id)
			UnitSetUniform(unit,item)
		end
	end
	for i=1,5 do
		local wID = getMarker(uName.."AWEAPON"..i)	
		if((wID~=nil) and (wID~=0)) then
			putMarker(uName.."AWEAPON"..i,0)
			local adaptation = getMarker(uName.."ADAPTATION"..i)	
			local counter = getMarker(uName.."ACOUNTER"..i)
			UnitSetWeaponAdaptationInfo(unit,wID,adaptation,counter)
		end
	end
	for i=0,24 do
		local stat = getMarker(uName.."STAT"..i)
		if(stat~=0) then
			UnitSetStat(unit,i,stat)
			putMarker(uName.."STAT"..i,0)
		end
	end
	local name = GetGlobalGameVar(uName.."NAME","0")
	if(name~="0") then
		UnitSetRealName(unit,name)
	end

	local id = getMarker(uName.."ARMOR")
	if(id~=0) then
		putMarker(uName.."ARMOR",0)
		UnitSetArmour(unit,ItemCreate(id))
	end

end

function giveXP( xp )
	xp = Pow(xp,1.01)
	GroupGiveXP( GetParty(), xp )
	OutLog(GetString(1350110)..int(xp).." XP",0)
end

function giveRelativeXP( divider )
	local all = 0
	local sz = GroupGetSize(GetParty())
	for i=0,sz-1 do
		local unit = GroupGetUnit(GetParty(),i)
		if(unitIsActive(unit)) then
			all = all + (UnitGetXPToNextLevel(unit)*divider)
		end
	end
	AddMedalPoints(GetHero(), divider*1000)
	giveXP(all / sz)
end

function toJournal( id )
	local days
	local time
	days,time = getDate()
	local zone = ScenarioGetCurrentZoneName()
	if(zone==nil) then
		zone = "???"
	end
	local title = GetString( 20994 )..days.." "..time.." "..zone
	if(AddJournalRecordEx(id,title,2,days,time,zone)) then
		OutLog(GetString(1350111),0)
	end
end

function giveMoney( money )
	money = int(money)
	if(money>0) then
		PlayerGiveMoney(0,money)
		OutLog(GetString(1350112)..money,0)
	end
end

function giveStuff()
	OutLog(GetString(1350121),0)
end

function lostMoney( money )
	money = min(money,PlayerGetMoney(0))
	money = int(money)
	if(money>0) then		
		PlayerTakeMoney(0,money)
		OutLog(GetString(1350113)..money,0)
	end
end

function dice( unit, attr, mod )
	mod = mod - GetDifficulty() + DF_NORMAL
	local rnd = (UnitGetSkillMaxValue( unit, attr )+mod)*10
	local prefix
	if(attr==ST_DEX) then
		prefix = GetString(1350114)
	elseif(attr==ST_STR) then
		prefix = GetString(1350115)
	elseif(attr==ST_INT) then
		prefix = GetString(1350116)
	end
	local throw = random(100)+GVCarma
	out("Throw : ",throw," Need : ",rnd)
	if(throw<rnd) then
		OutLog(GetString(1350117)..prefix..GetString(1350118),0)
		return(true)
	else
		OutLog(GetString(1350117)..prefix..GetString(1350119),0)
		return(false)
	end
end

function addZone( name )
	if(not isZoneOpened( name )) then
		ScenarioAddVisibleZone(name)
		if((name=="City") or (name=="Sewerage") or (name=="Railroad")) then
			putMarker("CityOpened",1)
			putMarker("SewerageOpened",1)
			putMarker("RailroadOpened",1)
		elseif((name=="WPump") or (name=="WSewerage") or (name=="WStation")) then
			putMarker("WPumpOpened",1)
			putMarker("WSewerageOpened",1)
			putMarker("WStationOpened",1)
		elseif((name=="RoadBridge") or (name=="BaseSEUpper") or (name=="BaseSEDown")) then
			putMarker("RoadBridgeOpened",1)
			putMarker("BaseSEUpperOpened",1)
			putMarker("BaseSEDownOpened",1)
		else				
			putMarker(name.."Opened",1)
		end
		OutLog(GetString(1350120),0)
	end
end

function isZoneOpened( name )
	local ret = getMarker(name.."Opened")
	if(ret==1) then
		return(true)
	else
		return(false)
	end
end

function getPlayerLevel( player )
	if(player==nil) then
		player = 0
	end
        local summ = 0
        local group = PlayerGetUnits(player)
        local sz = GroupGetSize( group );
        for I = 0, sz - 1 do
		local unit = GroupGetUnit( group, I )
		if(IsValid(unit)) then
--			summ = summ + UnitGetSkillMaxValue(unit,ST_LEVEL)
			local lvl = UnitGetSkillMaxValue(unit,ST_LEVEL)
			if(lvl>summ) then
				summ = lvl
			end				
		end
	end
--        if(sz>0) then
--        	summ = summ / sz
--        end
        return summ
end

function UpdateUnitSkills( unit, effectiveLevel, resultLevel )
	if(IsValid(unit) and UnitCanFight(unit) and (UnitGetName(unit)~="LARRY")) then
		local deltaLevel=RPGDiffGetAILevel()
		UnitSetXPLevel(unit,effectiveLevel+deltaLevel)
		local SkillAP=UnitGetSkillMaxValue(unit,ST_AP)*RPGDiffGetAIAP()
		UnitSetSkillMaxValue(unit,ST_AP,SkillAP)
		UnitSetSkill(unit,ST_AP,SkillAP )
		local SkillVP=UnitGetSkillMaxValue(unit,ST_VP )*RPGDiffGetAIVP()
		UnitSetSkillMaxValue(unit,ST_VP,SkillVP)
		UnitSetSkill(unit, ST_VP, SkillVP )
		local hide = 1
		if ( RPGDiffGetHideProb() == 15 ) then			
			hide = 1.15
		elseif ( RPGDiffGetHideProb() == 30 ) then			
			hide = 1.30
		elseif ( RPGDiffGetHideProb() == 75 ) then			
			hide = 1.45
		end
		hide = UnitGetSkillMaxValue( unit, ST_STEALTH ) * hide
		UnitSetSkillMaxValue( unit, ST_STEALTH, hide )
		UnitSetSkill( unit, ST_STEALTH, hide )
		UnitSetSkillMaxValue( unit, ST_LEVEL, resultLevel )
		if((GetDiplomacy(UnitGetPlayer(unit),0)==DS_ENEMY) and
			(random(100)<RPGDiffGetHideProb()) and 
			(not UnitIsHiding( unit ))) then
			UnitHide(unit)
		end 
	end
end

function UpdatePlayerUnitsSkills( PlayerID, effectiveDelta, resultDelta )
	if(effectiveDelta==nil) then
		effectiveDelta = 0
	end
	if(resultDelta==nil) then
		resultDelta = DEFAULT_ENEMY_LEVEL
	end
	local level = getPlayerLevel( 0 )+effectiveDelta
	for i=0, GroupGetSize( PlayerGetUnits( PlayerID ) ) - 1 do
		local unit = GroupGetUnit( PlayerGetUnits( PlayerID ), i )
		if(IsValid(unit)) then
			UpdateUnitSkills( unit, level, level+resultDelta )
		end
	end
end

function initEnemyPlayer( player, effectiveDelta, resultDelta )
	UpdatePlayerUnitsSkills( player, effectiveDelta, resultDelta )
	correctGroupHide( PlayerGetUnits(player) )
	checkAmmunition( player )
end

function isPeace()
	for i=1,15 do
		local group = PlayerGetUnits(i)
		if(     GroupCanFight(group) and
			(GetDiplomacy(0,i)==DS_ENEMY)) then
			return(false)
		end
	end
	return(true)
end

function trueDrawWeapon( unit )
	local needFix = false
	if(UnitIsWeaponInHand( unit, WP_GRENADE )) then
		needFix = true
	end
	if(not UnitIsWeaponInHand( unit, WP_NORMAL )) then 
		UnitSelectSlot( unit, 0 ) 
		WaitForUnit( unit )
	end
	if(not UnitIsWeaponInHand( unit, WP_NORMAL )) then 
		UnitSelectSlot( unit, 1 ) 
		WaitForUnit( unit )
	end
	if(not UnitIsWeaponInHand( unit, WP_NORMAL )) then
		UnitDrawWeapon( unit )
		WaitForUnit( unit )
	end
	local ret = UnitIsWeaponInHand( unit, WP_NORMAL )
	if(ret) then
		if(needFix) then
			UnitActivateWeapon(unit,false)
			WaitForUnit( unit )
		end
		UnitActivateWeapon(unit,true)
		WaitForUnit( unit )
		UnitWeaponRepairBroken(unit,1000)
		UnitWeaponRepairJammed(unit,1000)
	end
	return(ret)
end

function showUnitInfo(unit,weightOfUnit,maxWeight)
	if(unitIsOurs(unit)) then
		local name = GetString(1350122)
		if(weightOfUnit==nil) then
			weightOfUnit = calcUnitWeight(unit)
                        maxWeight = getUnitMaxWeight(unit)
		end
		local loading = weightOfUnit * 100 / maxWeight
		if(loading<=100) then
			name = name.."<color=green>"
		else
			name = name.."<color=red>"
		end
		UnitSetToolTipAdditional(unit, name..round(loading).."%<color=beige>" )
	end
end

function showUnitsInfoThread()
	while(1) do
		if(IsRealTime()) then
			for i=0,GroupGetSize(GetParty())-1 do	
				local unit = GroupGetUnit(GetParty(),i)
				if(IsValid(unit)) then
					showUnitInfo(unit)
				end
			end
		end
		Sleep(20)
	end
end

showUnitsInfoFired = false
function showUnitsInfo()
	if(not showUnitsInfoFired) then
		showUnitsInfoFired = true
		StartThread(showUnitsInfoThread)
	end
end

function getCarryingPartyCorpse( unit )
	if(IsValid(unit)) then
		for j=0,GroupGetSize(GetParty())-1 do
			local corpse = GroupGetUnit(GetParty(),j)
			if(IsValid(corpse) and UnitIsUnconscious(corpse) and UnitIsCarryingCorpse(unit,corpse)) then
				return(corpse)			
			end
		end
	end
	return(nil)
end

function isSomeCarryingUnit( corpse )
	if(IsValid(corpse)) then
		for j=0,GroupGetSize(GetParty())-1 do
			local unit = GroupGetUnit(GetParty(),j)
			if(IsValid(unit) and UnitIsCarryingCorpse(unit,corpse)) then
				return(true)			
			end
		end
	end
	return(false)
end

function removeDead()
	local unitsToRemove = {}
	local cnt = 0
	for i=1,15 do
		local group = PlayerGetUnits(i)
		local j
		for j=0,GroupGetSize(group)-1 do
			local unit = GroupGetUnit(group,j)
			if(IsValid(unit) and (UnitIsDead(unit) or UnitIsUnconscious(unit))) then
				cnt = cnt+1
				unitsToRemove[cnt] = unit
			end
		end
	end
	for j=1,cnt do
		UnitRemove(unitsToRemove[j])
	end
end

function removeDeadEx()
	local unitsToRemove = {}
	local unitsToChange = {}
	local rcnt = 0
	local scnt = 0
	local curTime = getCurrentTime()
	for i=1,15 do
		local group = PlayerGetUnits(i)
		local j
		for j=0,GroupGetSize(group)-1 do
			local unit = GroupGetUnit(group,j)
			if(IsValid(unit) and (UnitIsDead(unit) or UnitIsUnconscious(unit))) then
				if(unitKilledAt[unit]==nil) then
					rcnt = rcnt+1
					unitsToRemove[rcnt] = unit
				elseif( curTime-unitKilledAt[unit] > SEC_PER_DAY ) then
					if(random(0,100)>50) then
						rcnt = rcnt+1
						unitsToRemove[rcnt] = unit
					elseif(random(0,100)>50) then
						scnt = scnt+1
						unitsToChange[scnt] = unit
					end	
				end
			end
		end
	end
	for j=1,rcnt do
		UnitRemove(unitsToRemove[j])
	end
	local bones = {1320022,1320024,1320025}
	for j=1,scnt do
		local dir = UnitGetDirection(unitsToChange[j])
		DeleteWaypoint("bonesLoc")
		CreateWaypoint("bonesLoc",unitsToChange[j])
		RecalcWaypointPos("bonesLoc")
		CreateObject( bones[random(1,4)], "bonesLoc", (dir*45)+random(5,25), "bones"..j )
		UnitRemove(unitsToChange[j])
	end
	WaitForPassCalc()
end

firearms = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
		31,32,34,35,36,37,38,39,40,41,42,43,44,45,57,47,48,49,355,64,356,354,176,177,173,172,171,
		174,175,161,162,163,159,160,158,180,183,182,190,343,211,217,222,212,215,218,220,221,214,213,219,
		298,299,225,223,357,344,348,353,347,351,350,352,345,346,349,364,378,227,434,442,461,382,467,489,
		490,491,492,493,494,495,496,497,498,499,500,511,572,573,574,669,670,
		1156103,1156104,1340011,1340031,1340036,1340037,1340061}

function UnitHasFireArms(unit)
	for i,v in firearms do
		if(HasInventoryItemUnit(unit,v)) then
			return(true)
		end	
	end
	return(false)
end

longFirearms = {12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
		31,32,34,35,36,37,38,39,40,41,42,43,44,45,57,47,48,49,355,64,356,354,176,177,173,172,171,
		174,175,161,162,163,159,160,158,180,183,182,190,343,211,217,222,212,215,218,220,221,214,213,219,
		299,225,223,357,344,348,353,347,351,350,364,227,434,442,461,382,467,489,
		492,493,494,495,496,498,499,500,511,572,573,574,669,
		1156104}

function unitHasLongFirearms(unit)
	for i,v in longFirearms do
		if(HasInventoryItemUnit(unit,v)) then
			return(true)
		end	
	end
	return(false)
end

function unitHasFirearmsInHand(unit)
	local ret = (UnitIsWeaponInHand(unit,WP_NORMAL) or
		UnitIsWeaponInHand(unit,WP_MELEE) or
		UnitIsWeaponInHand(unit,WP_GRENADE))
	return(ret)
end

function isItemLongFirearm(item)
	if(IsValid(item)) then
		local itemID = ItemGetID(item)
		for i,v in longFirearms do
			if(itemID==v) then
				return(true)
			end
		end
	end
	return(false)
end

function isItemFirearm(item)
	if(IsValid(item) and (ItemGetTypeEx(item)==SF_WEAPON)) then
		return(true)  
	end
	return(false)
end

melee = {249,240,241,239,250,244,242,248,243,236,129,246,234,237,235,230,
	233,231,232,210,216,245,247,192,365,407,501,538,1340022}

function isItemMelee(item)
	if(IsValid(item) and (ItemGetTypeEx(item)==SF_MELEE)) then
		return(true)
	end
	return(false)
end

function isItemHasDurability(item)
	local ret = (isItemFirearm(item) or isItemMelee(item))
	return(ret)
end

silencers = { 298,299,344,347,348,350,351,352,353,345,346,349,498 }

function isItemSilencer(itemID)
	for i,v in silencers do
		if(itemID==v) then
			return(true)
		end
	end
	return(false)
end

heavy = { 180,183,182,190,378,500,41,42,43,44,45,47,48,57,489,499 }

function isItemHeavy(itemID)
	for i,v in heavy do
		if(itemID==v) then
			return(true)
		end
	end
	return(false)
end

alreadyTaked = {}

function getNearestFirearm(unit)
	local item = ItemLootNext()
	local nearestItem = nil
	local distance = 10000000
	local pos = GetPos(unit)
	local iterated = {}
	if(IsValid(unit) and UnitCanFight(unit)) then
		while(IsValid(item) and (not iterated[item])) do
			iterated[item] = true
			if(isItemFirearm(item) and
				(alreadyTaked[item]==nil)) then
				local dist = GetDistance(pos,GetPos(item))
				if(dist<distance) then
					distance = dist
					nearestItem = item
				end
			end
			item = ItemLootNext(item)
			Sleep(2)
		end
		if(IsValid(nearestItem)) then
			alreadyTaked[nearestItem]=true		
		end
	end
	return(nearestItem)
end

function unitTakeFirearms(unit)
	local item = getNearestFirearm(unit)
	if(IsValid(item)) then
		UnitStop(unit)
		WaitForUnit(unit)
		UnitCancelAction(unit)
		UnitTakeObject(unit,item)
		return(true)
	end
	return(false)
end

function groupTakeFirearms(group)
	if(IsValid(group)) then
		local diced = false
        	local sz = GroupGetSize( group )
	        for I = 0, sz - 1 do
        	        local unit = GroupGetUnit( group, I )
			if(unitIsActive( unit )) then
				if(unitTakeFirearms(unit)) then
					diced = true
				end
			end
		end
		if(diced) then
--			WaitForGroupRoute(group)
			WaitForGroup(group)
		end
	end
end

function addPerksToGroup( no, bForced )
	if(bForced or isDifficultyAboveNormal()) then
		local group = PlayerGetUnits(no)
		local szt = GroupGetSize( group )
		for i = 0, ( szt - 1 ) do
			local unit = GroupGetUnit( group, i )
			if(unitIsActive(unit)) then
				UnitGiveRandomPerks(unit)
			end
		end
	end
end

-- for t

UIAction = 0
UISequence = 0

function WaitForUIEx( nID )
	UIAction = UIAction + 1
	WaitForUI( nID )	
	UIAction = UIAction - 1
end

function isUIAction()
	if(UIAction>0) then
		return(true)
	else
		return(false)
	end
end

function isSequence()
	if(UISequence>0) then 
		return(true)
	else
		return(false)
	end
end

function StartGameWithSequenceEx()
	UISequence = UISequence + 1
	StartGameEx()
end

function BeginSequenceEx(bBlockInput)
	UISequence = UISequence + 1
	if(UISequence==1) then
		WaitForUI( c_BeginSequence( bBlockInput ) )
	end
end

function EndSequenceEx( cameraRestore )
	if(UISequence>0) then
		UISequence = UISequence - 1
		EndSequence(cameraRestore)
	end
end

CURRENT_TIME 		= "currentTime"
TIME_CHECK_INTERVAL	= 250
TIME_DELTA_SEC		= 60*RPGDiffGetTimeDivider()
TURN_TIME_DELTA_SEC	= 60
CHAPTER_TIME_DELTA_SEC	= 60*30
SEC_PER_DAY		= 24*60*60
SEC_PER_HOUR		= 60*60
SUNSET_TIME		= 21*60*60
SUNRISE_TIME		= 6*60*60
START_TIME		= 4*SEC_PER_HOUR+(30*4-6)*SEC_PER_DAY

-- Sun Rise: 	6:14
-- Sun Set: 	20:43

dayCount =
{
	31, 28, 31, 30,
	31, 30, 31, 31,
	30, 31, 30, 31,
}

function getTimeOfDay()
	local part = getPartOfTime(getCurrentTime())
	return(part)
end

function getPartOfTime(current)
	local ret = DAY;
	current = mod(current,SEC_PER_DAY)
	if((current>=SUNSET_TIME) or (current<=SUNRISE_TIME)) then
		ret = NIGHT
		end
	return(ret);	
end

AmbientLights = {}

AmbientLights[AT_NORMAL] =  
-- 0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23
{  1321024,1321026,1321027,1321028,1321028,1321030,1321039,1321005,1321006,1321007,1321008,1321009,1321010,1321010,1321010,1321012,1321012,1321014,1321016,1321018,1321020,1321021,1321022,1321023, }

AmbientLights[AT_DUST] =  
-- 0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23
{  1321024,1321026,1321027,1321028,1321028,1321029,1321038,1321004,1321006,1321007,1321008,1321009,1321010,1321010,1321010,1321011,1321011,1321013,1321015,1321017,1321019,1321021,1321022,1321023, }

AmbientLights[AT_SPECIAL] = 
-- 0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23
{  1321024,1321026,1321027,1321028,1321028,1321029,1321032,1321033,1321006,1321007,1321008,1321009,1321010,1321010,1321010,1321012,1321012,1321014,1321016,1321018,1321020,1321021,1321022,1321023, }

AmbientLights[AT_SPECIAL1] = 
-- 0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23
{  1380032,1380005,1380006,1380007,1380007,1380008,1380010,1380012,1380033,1380015,1380016,1380017,1380018,1380018,1380018,1380019,1380019,1380021,1380023,1380025,1380027,1380029,1380030,1380031, }

AmbientLights[AT_SPECIAL2] =  
-- 0       1       2       3       4       5       6       7       8       9       10      11      12      13      14      15      16      17      18      19      20      21      22      23
{  1321024,1321026,1321027,1321028,1321028,1380037,1380038,1380039,1321006,1321007,1321008,1321009,1321010,1321010,1321010,1321012,1321012,1321014,1321016,1380040,1380041,1321021,1321022,1321023, }


function setTimeOfDay( prev, now )
	if(currentZoneType~=ZT_CAVE) then
		local pTime = getPartOfTime(prev)
		local nTime = getPartOfTime(now)
		if((pTime~=nTime) or (GetTimeOfDay()~=nTime)) then
			SetTimeOfDay(nTime,false)
			OnTimeOfDayChanged(nTime)
		end
		local ambientArray = AmbientLights[currentZoneAmbient]
		local oldHour = getHour( prev )+1
		local oldAmbient = ambientArray[oldHour]
		local newHour = getHour( now )+1
		local newAmbient = ambientArray[newHour]
		if(oldAmbient~=newAmbient) then
                        out("Apply ambient light ",newAmbient)
			SetupAmbientLight(newAmbient)
		else
			out("Ambient light not applied")
		end
	end
end

function applyAmbientLight()
	if(currentZoneType~=ZT_CAVE) then
		local time = GetGlobalGameVar( CURRENT_TIME, START_TIME )
		local newHour = getHour( time )+1
		local ambientArray = AmbientLights[currentZoneAmbient]
		local newAmbient = ambientArray[newHour]
		out("Apply ambient light ",newAmbient)
		SetupAmbientLight(newAmbient)
	end
end

function applyTimeOfDay()
	if(currentZoneType~=ZT_CAVE) then
		local time = GetGlobalGameVar( CURRENT_TIME, START_TIME )
		local part = getPartOfTime(time)
		if(GetTimeOfDay()~=part) then
			SetTimeOfDay(part,false)
		end
		applyAmbientLight()
		OnTimeOfDayChanged(part)
	else
		OnTimeOfDayChanged(NIGHT)
	end
end

function skipHour( dHour,bNoApplyTime )
	local time1 = GetGlobalGameVar( CURRENT_TIME, START_TIME )
	timeNow = time1 + dHour*SEC_PER_HOUR
	SetGlobalGameVar(CURRENT_TIME,timeNow)
	if(not bNoApplyTime) then
		setTimeOfDay( time1, timeNow )
	end
	printTime()
end

function skipToHour( dHour,bNoApplyTime )
	local time1 = GetGlobalGameVar( CURRENT_TIME, START_TIME )
	local current = mod(time1,SEC_PER_DAY)
	local hour = int(current/SEC_PER_HOUR)
	local minute = int(mod(current,SEC_PER_HOUR)/60)
	local delta = dHour-hour;
	if(delta<=0) then
		delta=24+delta;
	end
	timeNow = time1 + delta*SEC_PER_HOUR - minute*60
	SetGlobalGameVar(CURRENT_TIME,timeNow)
	if(not bNoApplyTime) then
		setTimeOfDay( time1, timeNow )
	end
	printTime()
end

function showSkip()
	pauseTime( true )
	EndSequencePart()
	WaitForUIEx( DialogModeBegin() )
	WaitForUIEx( DialogModeSet( 1001340, 6, 0,
		1001341,1001342,1001343,1001344,1001345,1001346 ) )
	local ret = GetLastDialogResult()
	if(ret==0) then
		pauseTime( false )
		return
	end
	WaitForUIEx( DialogModeEnd() )
	WaitForUIEx(FadeOut())
        snd1 = PlaySound(1001434);
        snd2 = PlaySound(1001435);
	if(ret==1) then    	-- 1 hour
		skipHour( 1 )
	elseif(ret==2) then	-- 3 hours
		skipHour( 3 )
	elseif(ret==3) then	-- evening
	        skipToHour( 21 )
	elseif(ret==4) then	-- midnight
		skipToHour( 0 )
	elseif(ret==5) then	-- morning
		skipToHour( 6 )
	elseif(ret==6) then	-- midday
		skipToHour( 12 )
	end
	pauseTime( false )
	Sleep(100)
	StopSound(snd1)
	StopSound(snd2)
	WaitForUIEx(FadeIn())
end                             

function getHour( timeNow )
	local current = mod(timeNow,SEC_PER_DAY)
	local hour = int(current/SEC_PER_HOUR)
	return(hour)
end

function getDate(timeNow)
	if(timeNow==nil) then
		timeNow = GetGlobalGameVar( CURRENT_TIME, START_TIME );
	end
	local day = int(timeNow/SEC_PER_DAY)+1
	local d = 0
	local month = 0	
	for i=1,12 do
		d = d+dayCount[i]
		if(d>day) then
			month = i
			break
		end
	end
	d = d-dayCount[month]
	day = (day-d)+1
	if(day<10) then
		day = '0'..day
	end
	if(month<10) then
		month = '0'..month
	end
	local current = mod(timeNow,SEC_PER_DAY)
	local hour = int(current/SEC_PER_HOUR)
	if(hour<10) then
		hour = '0'..hour
	end
	local minute = int(mod(current,SEC_PER_HOUR)/60)
	if(minute<10) then
		minute = '0'..minute
	end
	local time = hour..":"..minute
	local days = day.."/"..month.."/49"
	return days,time
end

function printTime()
	local days
	local time
	days,time = getDate()
	local msg = "<color=white>"..days.." <color=yellow>"..time.."    "
	OutHdr(msg,0)
end

function printSkipTime(toSkip)
	local days
	local time
	days,time = getDate()
	local days1
	local time1
	days1,time1 = getDate(toSkip*SEC_PER_HOUR)
	local msg = "<color=white>"..days.." <color=yellow>"..time.."<color=green> ["..time1.."]"
	OutHdr(msg,0)
end

notPause = true

function timeTick( delta )
	local timeNow = 0
	while true do
		if(notPause and 
			threadsEnabled and
			(not isUIAction()) and 
			(not isSequence()) and 
			(not PassCalcerIsActive()) and 
			IsRealTime()) then
			timeNow = GetGlobalGameVar( CURRENT_TIME, START_TIME )
			local newTime = timeNow+delta
                        setTimeOfDay( timeNow, newTime )
			timeNow = newTime
			if(threadsEnabled) then
				SetGlobalGameVar(CURRENT_TIME,timeNow)
			end
			printTime()		
		end
		Sleep(TIME_CHECK_INTERVAL)
	end
end

function pauseTime( enable )
	notPause = not enable
end

function startTime( delta )
	StartThread(timeTick,TIME_DELTA_SEC)
end

function putTimeMarker( marker, hours )
	if(hours==nil) then
		hours=0
	end
	timeNow = GetGlobalGameVar( CURRENT_TIME, START_TIME )
	timeNow = timeNow + hours*SEC_PER_HOUR
	SetGlobalGameVar(marker,timeNow)
end

function getTimeMarker( marker )
	timeNow = GetGlobalGameVar(marker,0)
	timeNow = timeNow + 0
	return(timeNow)	
end

function getCurrentTime()
	timeNow = GetGlobalGameVar( CURRENT_TIME, START_TIME )
	timeNow = timeNow + 0
	return(timeNow)	
end

function isTimeExpired( marker, default )
	markerTime = GetGlobalGameVar( marker, 0 )
	markerTime = markerTime + 0
	if(markerTime==0) then
		return(default)
	else
		timeNow = GetGlobalGameVar( CURRENT_TIME, START_TIME )
        	timeNow = timeNow + 0
		return(markerTime<timeNow)
	end
end

function putMarker( marker, flag )
	if(flag==nil) then
		flag = 1
	end
	SetGlobalGameVar(marker,flag)
end

function incMarker( marker, delta )
	if(delta==nil) then
		delta = 1
	end
	markerValue = GetGlobalGameVar( marker, 0 )
	markerValue = markerValue + delta
	SetGlobalGameVar(marker,markerValue)
end

function getMarker( marker )
	markerValue = GetGlobalGameVar( marker, 0 )
	markerValue = markerValue + 0
	return(markerValue)
end

--	          ForestBand  Lesnik Convoy	 Village City	Prison	Waterpump	RoadPost	     loseCar       VPP      ZEVip  BritBase
--ForestBand   0             1	   2       3     5        6	       20           2    	    	4
--Lesnik       1	         0     2       2     4        5        19           2               3
--Convoy       2             2     0       3     3        5        18           1               2
--Village      3             2     3       0     3        3        17           3               2
--City	       5             4     3       3     0        2        15           3               1
--Prison       7             6     5       4     4        0        17           4               1
--Adit         20            19    18      17    15       17       0  	        18              14
--Waterpump    20            19    18      17    15       17       0  	        18              14
--RoadPost     2             2     1       3     3        5        18           0               2
--Checkpoint   -             -     -       5     -        -        -            -               -
--LoseCar      4             3     2       2     1        1        14           2               -
--BaseMT       10            9     9       7     7        4        18           -               -      
--VPP	       8	         7	   6       6     4        6	       13           -               -
--RoadBridge   11            10    9       9     7        9        11           -               -           7
--Logovo       22            21    21      19    19	      16	   15           -               -           20
--ZEVip        2             1     4       2     5        3        20           4               4           12          0       3
--BritBase     6             5     8       7     7        6        24           6               7           7           3       0

function skipTravelTime(zoneName,bNoApplyTime,bNoSkipTime)
	local prevZone = GVLastZone
	if(not bNoSkipTime) then
		ScenarioHighlightZone(prevZone,false)
		out("*** TravelTime > prevZone : ",prevZone," zoneName : ",zoneName)
	end
	local hoursToSkip = 0
	if(prevZone~=zoneName) then
		if(not bNoSkipTime) then
			GVLastZone = zoneName
			SetGlobalGameVar( "lastZone", GVLastZone )
		end
		if(prevZone=="Checkpoint") then
			local class = UnitGetClass(GetHero())
			if((class==UC_SCOUT) or (class==UC_SNIPER)) then
				hoursToSkip = 16
			else
				hoursToSkip = 5
			end
		elseif( ((prevZone=="ForestBand") or (zoneName=="ForestBand")) ) then
			if(((prevZone=="Lesnik") or (zoneName=="Lesnik"))) then
				hoursToSkip = 1
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 2
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 6
			elseif(((prevZone=="Convoy") or (zoneName=="Convoy"))) then
				hoursToSkip = 2
			elseif(((prevZone=="Village") or (zoneName=="Village"))) then
				hoursToSkip = 3
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 1.5
			elseif(((prevZone=="City") or (zoneName=="City") or (prevZone=="Railroad") or (zoneName=="Railroad") or (prevZone=="Sewerage") or (zoneName=="Sewerage"))) then
				hoursToSkip = 5
			elseif(((prevZone=="Prison") or (zoneName=="Prison"))) then
				hoursToSkip = 6
			elseif(((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage"))) then
				hoursToSkip = 20
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 18
			elseif(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 2
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 4
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 20
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 10
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 8
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 11
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 22
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 9
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 11
			end
		elseif( ((prevZone=="Lesnik") or (zoneName=="Lesnik")) ) then
			if(((prevZone=="Convoy") or (zoneName=="Convoy"))) then
				hoursToSkip = 2
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 1
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 5
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 1
			elseif(((prevZone=="Village") or (zoneName=="Village"))) then
				hoursToSkip = 2
			elseif(((prevZone=="City") or (zoneName=="City") or (prevZone=="Railroad") or (zoneName=="Railroad") or (prevZone=="Sewerage") or (zoneName=="Sewerage"))) then
				hoursToSkip = 4
			elseif(((prevZone=="Prison") or (zoneName=="Prison"))) then
				hoursToSkip = 5
			elseif(((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage"))) then
				hoursToSkip = 19
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 17
			elseif(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 2
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 3
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 19
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 9
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 7
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 10
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 21
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 8
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 10
			end
	    elseif( ((prevZone=="ZEVip") or (zoneName=="ZEVip")) ) then
			if(((prevZone=="Convoy") or (zoneName=="Convoy"))) then
				hoursToSkip = 4
			elseif(((prevZone=="Lesnik") or (zoneName=="Lesnik"))) then
				hoursToSkip = 1
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 3
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 1
			elseif(((prevZone=="Village") or (zoneName=="Village"))) then
				hoursToSkip = 2
			elseif(((prevZone=="City") or (zoneName=="City") or (prevZone=="Railroad") or (zoneName=="Railroad") or (prevZone=="Sewerage") or (zoneName=="Sewerage"))) then
				hoursToSkip = 5
			elseif(((prevZone=="Prison") or (zoneName=="Prison"))) then
				hoursToSkip = 3
			elseif(((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage"))) then
				hoursToSkip = 20
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 17
			elseif(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 4
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 4
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 19
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 9
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 12
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 10
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 21
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 8
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 10
			end
		elseif( ((prevZone=="Convoy") or (zoneName=="Convoy")) ) then
			if(((prevZone=="Village") or (zoneName=="Village"))) then
				hoursToSkip = 3
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 4
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 8
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 2
			elseif(((prevZone=="City") or (zoneName=="City") or (prevZone=="Railroad") or (zoneName=="Railroad") or (prevZone=="Sewerage") or (zoneName=="Sewerage"))) then
				hoursToSkip = 3
			elseif(((prevZone=="Prison") or (zoneName=="Prison"))) then
				hoursToSkip = 5
			elseif(((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage"))) then
				hoursToSkip = 18
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 16
			elseif(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 1
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 2
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 18
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 9
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 6
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 9
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 21
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 7
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 9
			end
		elseif( ((prevZone=="Village") or (zoneName=="Village")) ) then
			if(((prevZone=="City") or (zoneName=="City") or (prevZone=="Railroad") or (zoneName=="Railroad") or (prevZone=="Sewerage") or (zoneName=="Sewerage"))) then
				hoursToSkip = 3
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 2
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 7
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 1
			elseif(((prevZone=="Prison") or (zoneName=="Prison"))) then
				hoursToSkip = 3
			elseif(((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage"))) then
				hoursToSkip = 17
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 15
			elseif(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 3
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 2
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 17
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 7
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 6
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 9
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 19
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 7
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 9
			end
		elseif( (prevZone=="City") or (zoneName=="City") or (prevZone=="Railroad") or (zoneName=="Railroad")  or (prevZone=="Sewerage") or (zoneName=="Sewerage")) then
			if(((prevZone=="Prison") or (zoneName=="Prison"))) then
				hoursToSkip = 2
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 5
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 7
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 2
			elseif(((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage"))) then
				hoursToSkip = 15
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 13
			elseif(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 3
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 1
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 15
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 7
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 4
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 7
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 19
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 5
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 7
			end
		elseif( ((prevZone=="Prison") or (zoneName=="Prison")) ) then
			if(((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage"))) then
				hoursToSkip = 17
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 3
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 6
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 15
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 2
			elseif(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 4
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 1
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 17
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 4
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 6
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 9
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 16
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 7
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 9
			end
	    elseif( ((prevZone=="BritBase") or (zoneName=="BritBase")) ) then
			if(((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage"))) then
				hoursToSkip = 18
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 3
			elseif(((prevZone=="Prison") or (zoneName=="Prison"))) then
				hoursToSkip = 6
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 15
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 2
			elseif(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 6
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 7
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 17
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 4
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 6
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 9
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 16
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 7
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 9
			end
		elseif( ((prevZone=="WStation") or (zoneName=="WStation") or (prevZone=="WPump") or (zoneName=="WPump") or (prevZone=="WSewerage") or (zoneName=="WSewerage")) ) then
			if(((prevZone=="RoadPost") or (zoneName=="RoadPost"))) then
				hoursToSkip = 18
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 20
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 18
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 15
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 2
			elseif(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 14
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 0.5
			elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 18
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 13
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 11
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 15
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 9
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 11
			end
		elseif( ((prevZone=="RoadPost") or (zoneName=="RoadPost")) ) then
			if(((prevZone=="LoseCar") or (zoneName=="LoseCar"))) then
				hoursToSkip = 2
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 4
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 6
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 16
			elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 18
			end
		elseif( ((prevZone=="LoseCar") or (zoneName=="LoseCar")) ) then
			if(((prevZone=="Adit") or (zoneName=="Adit"))) then
				hoursToSkip = 14
			elseif(((prevZone=="ZEVip") or (zoneName=="ZEVip"))) then
				hoursToSkip = 4
			elseif(((prevZone=="BritBase") or (zoneName=="BritBase"))) then
				hoursToSkip = 7
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 12
			end
		elseif(((prevZone=="Adit") or (zoneName=="Adit"))) then
		        if(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
				hoursToSkip = 18
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 15
			elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 13
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 11
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 19
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 2
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 9
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 11
			end
		elseif(((prevZone=="BaseMT") or (zoneName=="BaseMT"))) then
		        if(((prevZone=="VPP") or (zoneName=="VPP"))) then
				hoursToSkip = 12
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 5
			elseif( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 11
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 15
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 16
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 9
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 11
			end
		elseif(((prevZone=="VPP") or (zoneName=="VPP"))) then
			if( (prevZone=="RoadBridge") or (zoneName=="RoadBridge") or (prevZone=="BaseSEUpper") or (zoneName=="BaseSEUpper") ) then
				hoursToSkip = 8
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 5
			elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 21
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 6
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 8
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 11
			end
		elseif(((prevZone=="RoadBridge") or (zoneName=="RoadBridge"))) then
			if(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
				hoursToSkip = 13
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 9
			elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 2
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 4
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 9
			end
		elseif(((prevZone=="LogovoUpper") or (zoneName=="LogovoUpper"))) then
			if(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
				hoursToSkip = 11
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 17
			elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 13
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 13
			end
		elseif(((prevZone=="FinCamp") or (zoneName=="FinCamp"))) then
			if(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
				hoursToSkip = 7
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 13
			elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 2
			end
		elseif(((prevZone=="Bridge") or (zoneName=="Bridge"))) then
			if(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
				hoursToSkip = 5
			elseif(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 11
			end
		elseif(((prevZone=="Swamp") or (zoneName=="Swamp"))) then
			if(((prevZone=="NotRadioCamp") or (zoneName=="NotRadioCamp"))) then
				hoursToSkip = 8
			end
		end
		if(GVConvoyQuest==CQ_WITHCAR) then
--out("*** car travel ",GVConvoyQuest)
			hoursToSkip = hoursToSkip/3
		end
		if(GVParavozMove==1) then
--out("*** paravoz travel ",GVParavozMove)
			GVParavozMove = 0
			putMarker("paravozMove",0)
			hoursToSkip = hoursToSkip/5
		end
		if(not bNoSkipTime) then
out("*** hoursToSkip : ",hoursToSkip)
			skipHour( hoursToSkip,bNoApplyTime )	
		end
	else
		hoursToSkip = 0.083333333333
	end
	if(not bNoSkipTime) then
		ScenarioHighlightZone(zoneName,true)
	end
	return(hoursToSkip)
end

-- radio

--------------- for radio

GAP_SND_FIRST   = 30100
GAP_SND_CNT     = 4
MAX_SOUND	= 26

snd = nil
snd1 = nil
radioOn = false
soundList       = { 30000,30001,30002,30003,30004,30005,30006,30007,30008,30009,30010,30011,30012,
		    30200,30201,30202,30203,30204,30205,30206,30207,30208,30209,30210,30211,30212, }
delayList       = {    30,   30,   30,   30,   30,   30,   30,   30,  176,   59,   53,   50,   50,
		       30,   30,   30,   30,   30,   30,   30,   30,   30,   50,   30,   30,   30, }
played          = {     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
                        0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0, }

function turnRadioOff()
        if(isRadio()) then
                radioOn=false;
                if(IsValid(snd)) then StopSound(snd) end;
                if(IsValid(snd1)) then StopSound(snd1) end;
		Sleep(20)
		PauseMusic(false)
	end
end

function turnRadioOn(point,object)
	local pt
	if(point==nil) then
		pt = GetPos(object)
	else
		pt = GetWaypointPos(point)
	end
	if(not isRadio()) then
                radioOn = true;
		StartThread(radioPlay,pt,object)
	end
end

function radioPlay(point,object)
	while(isRadio()) do
		local i
		local sz
		sz = 0
		for i,v in played do
			played[i] = 0
			sz = sz + 1
		end
		MAX_SOUND = sz
		while( (sz>0) and playSoundWait(random(sz)+1,point,object)) do
			sz = sz-1
		end
	end
end

function isRadio()
	return(radioOn)
end

function waitRadio(time,object)
	local i
        for i=0, time-1 do
                Sleep(20);
		if(IsValid(object) and
			(ObjectGetDestroyStage(object)~=0)) then
			turnRadioOff()
		end
                if(not isRadio()) then break end;
	end
end

function findSound(ndx)
        local fnd = 0;
	local i
        for i = 1,MAX_SOUND do
                if(played[i]==0) then
                        fnd = fnd+1;
                        if(fnd==ndx) then
                                played[i] = 1;
                                return(i);
                                end
                        end
                end
        return(0);
end

function playSoundWait(ndx,wp,object)
        local rnd = random(GAP_SND_CNT)+GAP_SND_FIRST;
	PauseMusic(true)
        snd1 = Play3DSound(rnd,wp);
--      waitRadio(6);
        if(isRadio()) then
		local loc = findSound(ndx);
                snd = Play3DSound(soundList[loc],wp);
                waitRadio(delayList[loc],object);
                if(IsValid(snd1)) then 
			StopSound(snd1) 
		end;
                if(IsValid(snd)) then 
			StopSound(snd) 
		end;
		if(isRadio()) then
		        return(true);
		end
	end
        return(false);
end

function dicePostfix( unitNames )
	local units = {}
	local cnt = 0
	for i,v in unitNames do
		local unit = GetUnit(v)
		if(IsValid(unit) and UnitCanFight(unit) and
			GroupIsContainUnit(GetParty(),unit)) then
			cnt = cnt + 1
			units[cnt] = unit
		end
	end
	for i,v in units do
		if(random(1,cnt+1)==1) then
			return(UnitGetName(v))
		else
			cnt = cnt-1
		end
	end
	return("single")
end

function OnOpenObjectPrim( u, o )
        local on = ObjectGetName( o )
out('OnOpenObjectPrim ',on)
        if(on=="RADIO") then
		if(isRadio()) then 
			turnRadioOff()
		else
			turnRadioOn(nil,o)
		end
	end
end

function exitZonePrim()
	turnRadioOff()
	ShowLeaveZoneDialog( 16837 )
end

unitKilledAt = {}

function OnUnitDeathPrim(unit)
	if(IsValid(unit)) then
		unitKilledAt[unit] = getCurrentTime()
		UnitSetToolTipAdditional(unit,"")
		local name = UnitGetName(unit)
		if(UnitIsDead(unit)) then
			if(name=="LARRY") then
				putMarker("larryKilled",1)
				toJournal(1000038)
			elseif(name=="BUZZ") then
				putMarker("buzzKilled",1)
				toJournal(1000039)	
			elseif(name=="FIDEL") then
				putMarker("fidelKilled",1)
				toJournal(1000040)
			elseif(name=="MOSHE") then
				putMarker("mosheKilled",1)
				toJournal(1000044)
			elseif(name=="PAVEL") then
				putMarker("pavelKilled",1)
				toJournal(1000076)
			elseif(name=="ZIGFRID") then
				putMarker("zigfridKilled",1)
				toJournal(1000045)
			elseif(name=="IVAN") then
				putMarker("ivanKilled",1)
				toJournal(1000077)
			elseif(name=="RED") then
				putMarker("redKilled",1)
				toJournal(1000078)
			elseif(name=="KIM") then
				putMarker("kimKilled",1)
				toJournal(1000079)
			end	
		end
	end
end

function OnUnitDeath(unit)
out("*** OnUnitDeath ",unit)
	OnUnitDeathPrim(unit)
end

-- weight

function calcUnitWeight(unit)
	local WeightOfUnit = 0
	if(unitIsActive( unit )) then
		local item = UnitGetFirstItem( unit )
		local iterated = {}
		while(IsValid(item) and (not iterated[item]) ) do
			iterated[item] = true
			WeightOfUnit = WeightOfUnit + ItemGetWeight(item)
			item = UnitGetNextItem( unit , item )
		end
        	item = UnitGetSlotItem( unit, 0 )
		if(IsValid(item)) then
			WeightOfUnit = WeightOfUnit + ItemGetWeight(item)
		end
        	item = UnitGetSlotItem( unit, 1 )
		if(IsValid(item)) then
			WeightOfUnit = WeightOfUnit + ItemGetWeight(item)
		end
		item = UnitGetArmour( unit )
	       	if(IsValid(item)) then
			WeightOfUnit = WeightOfUnit + ItemGetWeight(item)
		end
	end
	return(WeightOfUnit)
end

function getUnitMaxWeight(unit)
	if(unitIsActive( unit )) then
		return(UnitGetSkill( unit, ST_STR ) * 2000-1000*(GetDifficulty()-1))
	else
		return(0)
	end
end

function CheckWeight()
	local PlayerGroupSize = GroupGetSize( GetParty() )
	for i = 0, PlayerGroupSize-1 do
		local unit = GroupGetUnit( GetParty(), i )
		if(unitIsOurs(unit)) then
			local WeightOfUnit = calcUnitWeight(unit)
			local MaxWeight = getUnitMaxWeight(unit)
			if(unitIsOurs(unit)) then
				local UnitSkillAP = UnitGetSkill( unit, ST_AP )
				if ( MaxWeight < WeightOfUnit ) and 
					( UnitSkillAP == UnitGetSkillMaxValue( unit, ST_AP ) ) then
					local DeltaAP = ( UnitSkillAP / 100 ) * 2 * GetDifficulty() * ( ( WeightOfUnit - MaxWeight ) / 1000 )
					if DeltaAP > UnitSkillAP then 
						DeltaAP = UnitSkillAP
					end
					UnitSetSkill( unit, ST_AP, UnitSkillAP - DeltaAP )
			        end
				showUnitInfo(unit,WeightOfUnit,MaxWeight)
			end
		end
	end
end

function inExitZone()
	return(false)
end

function OnStartTurnPrim( player )
	if((player~=0) and inExitZone()) then
out("*** PlayerGiveTurn(0)")
		PlayerGiveTurn(0)
	elseif(player == 0) then 
		CheckWeight() 
		skipHour( TURN_TIME_DELTA_SEC/SEC_PER_HOUR )
		printTime()
	else
		OnStartTurnCommonLogic( player )
	end
end

function OnStartTurn( player )
	OnStartTurnPrim( player )
end

--- common tricks

function OnDialogPhrasePrim( code, no )
	if(code=="zigfridTalk") then
		local zigfrid = GetUnit("zigfrid")
		if(no==1) then
			UnitPlayAnimation(zigfrid,3960,false,true)
		end
	elseif(code=="mcleodFidel1") then
		local mcleod = GetUnit("mcleod")
		if(no==5) then
			UnitPlayAnimation(mcleod,4343,false,true)
		elseif(no==10) then		
			UnitPlayAnimation(mcleod,4349,false,true)
		elseif(no==16) then		
--			UnitPlayAnimation(mcleod,4272,false,true)
		end
	elseif(code=="mcleod") then
		local mcleod = GetUnit("mcleod")
		if(no==2) then		
			UnitPlayAnimation(mcleod,4349,false,true)
		end
	elseif(code=="backLarry1") then
		if(no==5) then
			local larry = GetUnit("larry")
			UnitDisableCriticals(larry,true)
			UnitPutWeaponToBackpack(GetHero())
			WaitForUnit(GetHero())
			if(not UnitIsWeaponInHand( GetHero(), WP_FIST )) then
				UnitThrowWeaponOut(GetHero())
				Sleep(20)
			end	
			if(UnitIsWeaponInHand( GetHero(), WP_FIST )) then
				UnitShoot(GetHero(),larry,HL_HEAD)
				WaitForUnit(GetHero())
				if(UnitCanFight(larry)) then
					UnitPlayAnimation(larry,5443,false,true)
				end
				UnitDrawWeapon(GetHero())
				WaitForUnit(GetHero())
			end
			UnitDisableCriticals(larry,false)
		end
	end
end

function OnDialogPhrase( code, no )
	OnDialogPhrasePrim( code, no )
end

function unitMoveToUnit(unit,dest,dist)
	if(dist==nil) then
		dist = 3
	end
	if(dest==nil) then
		dest = GetHero()
	end	
	UnitStop(dest)
	UnitLookAtUnit(dest,unit)
	local wname = UnitGetName(dest).."utmp"
	DeleteWaypoint(wname)
	CreateWaypoint(wname,dest)
	RecalcWaypointPos(wname)
	UnitSetWishPose(unit,POSE_WALK)
	UnitSetPose(unit,POSE_WALK)
	WaitForUnit(unit)
	UnitMoveToWaypoint(unit,wname)
	while(GetDistance(GetPos(unit),GetPos(dest))>dist) do
		Sleep(5)
	end
	UnitCancelAction(unit)
	UnitStop(unit)
	UnitLookAtUnit(unit,dest)
	UnitLookAtUnit(dest,unit)
	WaitForUnit(dest)
end

function mcLeodTalk(camera)
	if(GVMTQuest == MQ_FAILED) then
		GVMTQuest = MQ_MCLEODTALKED
		dialogBlockStart(true)
		if(camera==nil) then
			focusCamera(GetHero())
		else
			WaitForUIEx(CameraSet(GetCamera(camera)))
		end
		BeginSequenceEx()
		WaitForUIEx(FadeOut())
		DividedDeploy()
		GroupActivateWeapon(GetParty(),false)
		if(DEBUG==1) then
			fidel = GroupGetUnit(GetParty(),1)
		else
			fidel = GetUnit("fidel")
		end
		if(unitIsOurs(fidel)) then
			UnitSetToWaypoint(fidel,"Unit_fidel")
			UnitLookAtUnit(fidel,GetHero())
		end
		local diplomacy = GetDiplomacy(0,1)
		SetDiplomacy(0,1,DS_NEUTRAL)
		SetDiplomacy(1,0,DS_NEUTRAL)
		PlaceTemplate(1350459,"mcleadStart")
		mcleod = GetUnit("mcleod")
		WaitForPassCalc()
		FadeIn()
		unitMoveToUnit(mcleod)
		GroupLookAtUnit(GetParty(),mcleod)
		WaitForGroup(GetParty())
		if(unitIsOurs(fidel)) then
			WaitForUIEx(DialogPlay("mcleodFidel1"))
			EndSequencePart()			
			WaitForUIEx( DialogModeBegin() )
			WaitForUIEx( DialogModeSet( 0, 2, 0, 1351561, 1351562 ) )
			local ret = GetLastDialogResult()
			if(ret~=0) then
				WaitForUIEx( DialogModeEnd() )
			end
			if(ret==2) then
				UnitSetWishPose(mcleod,POSE_RUN)
				UnitSetPose(mcleod,POSE_RUN)
				WaitForUnit(mcleod)
				GVMTQuest = MQ_MCLEODKILLED
				UnitCheat(mcleod,CHEAT_GODMODE,true)
				WaitForUnit(mcleod)
				if(not trueDrawWeapon(GetHero())) then
					DestroyItemInHand( GetHero() )
					CreateAndActivateItem(GetHero(),38)
				end
				if(not trueDrawWeapon(fidel)) then
					DestroyItemInHand( fidel )
					CreateAndActivateItem(fidel,38)
				end
				TempForbidTrackers()
				WaitForUnit(GetHero())
				WaitForUnit(fidel)
				UnitSetToHit(fidel,0)
				UnitSetToHit(GetHero(),0)
				UnitShootPrepare(GetHero(),mcleod,-1)
				UnitShoot(fidel,mcleod,-1)
				for i=1,GroupGetSize(GetParty())-1 do
					local unit = GroupGetUnit(GetParty(),i)
					if(not IsEqual(unit,fidel)) then
						if(trueDrawWeapon(unit)) then
							UnitShootPrepare(unit,mcleod,-1)
						end
					end
				end
				UnitCheat(GetHero(),CHEAT_GODMODE,true)
--				UnitShoot(mcleod,GetHero(),HL_HEAD)
--				Sleep(30)
				UnitPlayAnimation(mcleod,5473,false,true)				
				Sleep(10)
				UnitPlayAnimation(GetHero(),5443,false,true)
				
				local merc1 = GroupGetUnit(GetParty(),1)
				if(IsValid(merc1) and (not IsEqual(merc1,fidel))) then
					UnitPlayAnimation(merc1,5443,false,true)
				end
				if(GetDistance(GetPos(mcleod),GetPos(fidel))<4) then
					UnitShoot(mcleod,fidel,HL_HEAD)
	                                if(UnitCanFight(fidel)) then
		                                UnitShoot(fidel,mcleod,-1)
					end
--					Sleep(50)
					WaitForUnit(mcleod)
					if(UnitCanFight(fidel)) then	
						UnitPlayAnimation(fidel,5443,false,true)
					end
				end
				UnitMoveToWaypoint(mcleod,"mcleadStart")
				WaitForUnit(GetHero())
				Sleep(10)
				UnitShoot(GetHero(),mcleod,-1)
				WaitForUnitRoute(mcleod)
				UnitRemove(mcleod)
				GroupLookAtUnit(GetParty(),GetHero())	
				WaitForGroup(GetParty())
				UnitLookAtUnit(GetHero(),fidel)	
				if(UnitCanFight(fidel)) then
					WaitForUIEx(DialogPlay("mcleodFidelFail"))
				end
				GVWarBranchForced = 1
				GVRadioState = RS_MCLEODFAILED
				UnitSetToHit(fidel,-1)
				UnitSetToHit(GetHero(),-1)
				UnitCheat(GetHero(),CHEAT_GODMODE,false)
				toJournal(1000122)
			else
				GVRadioState = RS_MCLEODTALKED
				GVNeedDlgAboutRoadBridge = 1
				WaitForUIEx(DialogPlay("mcleodFidel2"))
				UnitMoveToWaypoint(mcleod,"mcleadStart")
				WaitForUnitRoute(mcleod)
				UnitRemove(mcleod)
				GroupLookAtUnit(GetParty(),GetHero())	
				WaitForGroup(GetParty())
				WaitForUIEx(DialogPlay("mcleodFidel3"))
				GVNeedDlgAboutRoadBridge = 0
				addZone("RoadBridge")
				toJournal(1000121)
			end
		else	
			GVRadioState = RS_MCLEODTALKED
			GVNeedDlgAboutRoadBridge = 1
			WaitForUIEx(DialogPlay("mcleod"))
			UnitMoveToWaypoint(mcleod,"mcleadStart")
			WaitForUnitRoute(mcleod)
			UnitRemove(mcleod)
			GVNeedDlgAboutRoadBridge = 0
			addZone("RoadBridge")
			toJournal(1000121)
		end	
		larry = GetUnit("larry")
		if((GVNeedDlgAboutRoadBridge==1) and unitIsOurs(larry)) then
			GVNeedDlgAboutRoadBridge = 0
			UnitLookAtUnit(GetHero(),larry)
			UnitLookAtUnit(larry,GetHero())
			WaitForUnit(larry)
			WaitForUIEx(DialogPlay("baseSELarry"))
		end
		EndSequenceEx()
		SetDiplomacy(0,1,diplomacy)
		SetDiplomacy(1,0,diplomacy)
		dialogBlockEnd()
		return(true)
	end
	return(false)
end

function zigfridTalk()
	local zigfrid = GetUnit("zigfrid")
	if((GVZigfridQuest == ZQ_TAKED) and unitIsOurs(zigfrid)) then
		GVRadioState = RS_AFTERWATERPUMP
		dialogBlockStart(true)
		focusCamera(GetHero())
		BeginSequenceEx()
		GroupLookAtUnit(GetParty(),zigfrid)
		WaitForGroup(GetParty())
		UnitLookAtUnit(zigfrid,GetHero())
		WaitForUIEx(DialogPlay("zigfridTalk"))
		local no = random(1,GroupGetSize(GetParty()))
		local unit = GroupGetUnit(GetParty(),no)
		DialogPlayAsAcks(UnitGetName(unit).."CommentZigfridTalk")
		GVZigfridQuest = ZQ_INPARTY
		UnitApplyCritical(zigfrid,27)
		putTimeMarker("BaseMTQuest",18)
		addZone("BaseMT")
		EndSequenceEx()
		dialogBlockEnd()
		toJournal( 1000093 )
		return(true)
	end
	return(false)
end

function mosheHistory()
	return(backgroundDialogs())
end

function backgroundDialogs()
	local moshe = GetUnit("moshe")	
	local larry = GetUnit("larry")	
	local buzz = GetUnit("buzz")	
	if((GVMosheTalked == 0) and unitIsOurs(moshe)) then	
		GVMosheTalked = 1
		dialogBlockStart(true)
		focusCamera(GetHero())
		BeginSequenceEx()
		GroupLookAtUnit(GetParty(),moshe)
		WaitForGroup(GetParty())
		UnitLookAtUnit(moshe,GetHero())
		WaitForUIEx(DialogPlay("mosheTalk1"))
		if(unitIsOurs(GetUnit("buzz"))) then
			WaitForUIEx(DialogPlay("mosheTalk1Buzz"))
		else
			WaitForUIEx(DialogPlay("mosheTalk1WithoutBuzz"))
		end
		WaitForUIEx(DialogPlay("mosheTalk2"))
		if(unitIsOurs(GetUnit("larry"))) then
			WaitForUIEx(DialogPlay("mosheTalk2Larry"))	
		end
		EndSequenceEx()
		dialogBlockEnd()
		return(true)
	elseif(unitIsOurs(larry) and (GVBuzzStrikeLarry==1) and (GVLarryTalked==0)) then
		GVLarryTalked=1
		dialogBlockStart(true)
		focusCamera(GetHero())
		BeginSequenceEx()
		UnitLookAtUnit(GetHero(),larry)
		UnitLookAtUnit(larry,GetHero())
		WaitForUnit(larry)
		WaitForUIEx(DialogPlay("backLarry1"))
		EndSequenceEx()
		dialogBlockEnd()
		return(true)
	elseif(unitIsOurs(buzz) and (GVPumpPassed==1) and (GVBuzzTalked==0)) then
		GVBuzzTalked=1
		dialogBlockStart(true)
		focusCamera(GetHero())
		BeginSequenceEx()
		UnitLookAtUnit(GetHero(),buzz)
		UnitLookAtUnit(buzz,GetHero())
		WaitForUnit(buzz)
		WaitForUIEx(DialogPlay("backBuzz1"))
		EndSequenceEx()
		dialogBlockEnd()
		return(true)
	end
	return(false)
end

function waitForZigfridRoute(zigfrid,waypoint)
	local ze = zoneEntered
	local bd = GetDistance( GetPos(zigfrid), GetWaypointPos(waypoint) )
	while((bd > 3) and 
		IsValid(zigfrid) and 
		UnitCanFight(zigfrid) and
		(ze==zoneEntered)) do
		Sleep(5)
		bd = GetDistance( GetPos(zigfrid), GetWaypointPos(waypoint) )
	end
	if((ze==zoneEntered) and IsValid(zigfrid) and UnitCanFight(zigfrid)) then
		UnitRemove(zigfrid)
	end
	WantTurnBased(false)
end

function zigfridRun(player,waypoint)
	local zigfrid = GetUnit("zigfrid")
	if((GVZigfridQuest == ZQ_TAKED) and unitIsOurs(zigfrid)) then
		dialogBlockStart(true)
		focusCamera(zigfrid)
		BeginSequenceEx()
		UnitSetWishPose(zigfrid,POSE_RUN)
		UnitSetPose(zigfrid,POSE_RUN)
		WaitForUnit(zigfrid)
		removeFromParty(zigfrid,player)
		GVZigfridQuest = ZQ_RUN
		EndSequenceEx()
		dialogBlockEnd()
		local no = random(1,GroupGetSize(GetParty()))
		local unit = GroupGetUnit(GetParty(),no)
out("*** commentRun ",UnitGetName(unit))
--		UnitSetRetreatLogic(zigfrid,waypoint)
		scriptLogic[zigfrid] = true
		WantTurnBased(true)
		PlayerGiveTurn(player)
		UnitMoveToWaypoint(zigfrid,waypoint)
		StartThread(waitForZigfridRoute,zigfrid,waypoint)
		Sleep(80)
		DialogPlayAsAcks(UnitGetName(unit).."CommentZigfridRun")
		GVRadioState = RS_AFTERWATERPUMP1
		toJournal( 1000094 )
		return(true)
	end
	return(false)
end

function zigfridTricks()
--	local zigfrid = GetUnit("zigfrid")
--	if(unitIsOurs(zigfrid)) then
--		if(GVZigfridQuest == ZQ_INPARTY) then
--			UnitApplyCritical(zigfrid,27)
--		elseif((GVZigfridQuest == ZQ_DONED) or (GVWarBranchForced>0)) then
--			UnitHealCriticals(zigfrid)
--		end
--	end
end

function placeAssasin( rnd, player )
out("*** Place assasin")
	if(rnd==nil) then
		rnd = 50
	end
	if(player==nil) then
		player = 14
	end
	if( ((GVPiterDeal==PQ_ENEMY) or (GVPiterDeal==PQ_DELAIEDENEMY)) and isTimeExpired("assasinGo",false)) then
out("*** Place assasin rnd ",rnd)
		if(random(100)<rnd) then
out("*** DICED!!!")
			local no = 0
			for i=1,4 do
				if(getMarker("assasin"..i)==0) then
					no = i
					break
				end
			end
			if(no~=0) then
				WaitForGroupRoute(GetParty())
				PlaceTemplate(1156002+no,"Unit6")
				local assasin = GetUnit("ass"..no)
				if(unitIsActive( assasin )) then
					dialogBlockStart(true)
					focusCamera(assasin)
					BeginSequenceEx()
					UnitDrawWeapon(assasin)
					UnitSetPlayer(assasin,player)
					WaitForUnit(assasin)
					UnitShootPrepare(assasin,GetHero(),HL_ANY)
					WaitForUnit(assasin)
					initEnemyPlayer(player)
					local attack = true
					WaitForUIEx(DialogPlay("assasin"..no))
					if((GVPiterDeal==PQ_DELAIEDENEMY) and
						(PlayerGetMoney(0)>=GVPiterMoney*2)) then
						EndSequencePart()			
						WaitForUIEx( DialogModeBegin() )
						WaitForUIEx(DialogModeSet(0,2,0,1400559,1352278))
						local ret = GetLastDialogResult()
						if(ret~=0) then
							WaitForUIEx(DialogModeEnd())
						end
						if(ret==1) then
							unitGiveItem( GetHero(), assasin, 535 )
							lostMoney(GVPiterMoney*2)
							attack = false
						end
					end
					if(attack) then
						GVPiterDeal=PQ_ENEMY
						UnitSetNormalLogic(assasin)
						putMarker("assasin"..no,1)
						EndSequenceEx()
						SetDiplomacy(0,player,DS_ENEMY)
						SetDiplomacy(player,0,DS_ENEMY)
						diceForTurn(player,GetHero())
					else
						GVPiterDeal=PQ_OK
						UnitMoveToWaypoint(assasin,"assasin")
						WaitForUnitRoute(assasin,5)
						UnitRemove(assasin)
						EndSequenceEx()
					end
					dialogBlockEnd()
					return(true)
				end
			else
				GVPiterDeal = PQ_OK
			end
		else
out("*** Not diced.")
		end
	end
	return(false)
end

function killPlayer(player)
	for i=0,GroupGetSize(PlayerGetUnits(player))-1 do
		local unit = GroupGetUnit(PlayerGetUnits(player),i)
		if(IsValid(unit) and (not UnitIsDead(unit))) then
			UnitKill(unit)
			OnUnitDeathPrim(unit)
		end
	end
end

function killE()
	for i=1,15 do
		if(GetDiplomacy(i,0)==DS_ENEMY) then
			killPlayer(i)
		end
	end
end

ccar = nil
cchest1 = nil
cchest2 = nil

function larryGo( no )
	larry = GetUnit("larry")
	if(IsValid(larry) and GroupIsContainUnit(GetParty(),larry)) then
		if(UnitCanFight(larry)) then
			if(no==nil) then
				no = 0
			end
			dialogBlockStart()
			WaitForUIEx(DialogPlay("larryGo"))
			WaitForUIEx(FadeOut())
			Sleep(10)
			UnitRemoveFromParty(larry,no)
			UnitSetPlayer(larry,no)
			UnitRemove(larry)
			Sleep(10)
			WaitForUIEx(FadeIn())
			dialogBlockEnd()
		else
			if(not UnitIsDead(larry)) then
				UnitKill(larry)
			end	
		end
	end		
end

function checkCar(no)
	while( IsValid(ccar) and
		IsValid(cchest1) and
		IsValid(cchest2) and
		(ObjectGetDestroyStage(ccar)==0) and
		(ObjectGetDestroyStage(cchest1)==0) and
		(ObjectGetDestroyStage(cchest2)==0) ) do
		Sleep(40)
	end	
	if(IsValid(ccar) and
		IsValid(cchest1) and
		IsValid(cchest2) and
		(GVConvoyQuest < CQ_FAILED)) then
		ObjectSetDestroyStage(ccar,2)
		ObjectSetDestroyStage(cchest1,2)
		ObjectSetDestroyStage(cchest2,2)
		GVConvoyQuest = CQ_FAILED
		toJournal(1000025)
		dialogBlockStart(true)
		WaitForUIEx(DialogPlay("convoyFail"))
		dialogBlockEnd()
		larryGo(no)
	end	
end

function startConvoyTricks( carTemplate, no )
	ccar = GetObject("eauto")
	if(IsValid(ccar)) then
		ObjectRemove(ccar)
	end
	cchest1 = GetObject("echest1")
	if(IsValid(cchest1)) then
		ObjectRemove(cchest1)
	end
	cchest2 = GetObject("echest2")
	if(IsValid(cchest2)) then
		ObjectRemove(cchest2)
	end
	if(GVConvoyQuest==CQ_AVAILABLE) then
		if(isTimeExpired( "convoy", true )) then
			toJournal(1000024)
			GVConvoyQuest = CQ_FAILED
			larryGo(no)
		end
	elseif(GVConvoyQuest==CQ_WITHCAR) then
		PlaceTemplate(carTemplate,"ecar")
		ccar = GetObject("eauto")
		cchest1 = GetObject("echest1")
		cchest2 = GetObject("echest2")
		StartThread(checkCar,no)
		WaitForPassCalc()
	end
end

function removeChests()
	if(IsValid(cchest1)) then
		ObjectRemove(cchest1)
	end
	if(IsValid(cchest2)) then
		ObjectRemove(cchest2)
	end
end

function unitIsOurs(unit)
	local ret = ( unitIsActive( unit ) and
		GroupIsContainUnit(GetParty(),unit))
	return(ret)
end

function makeDrink()
	local choice = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local selected = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local money = PlayerGetMoney(0)	
	while(1) do
		local cnt = 0
		local i
		local v
		for i,v in dcost do
			if(true) then
				cnt = cnt+1
				if(money>=dcost[i]) then
					choice[cnt] = denabled[i]
				else
					choice[cnt] = ddisabled[i]
				end
				selected[cnt] = i
			end
		end
		EndSequencePart()
		WaitForUIEx( DialogModeBegin() )
		WaitForUIEx( DialogModeSet( 1170044, cnt+1, 16-cnt,
			1321490,
			choice[1], choice[2], choice[3], choice[4], choice[5], choice[6],
			choice[7], choice[8], choice[9], choice[10], choice[11], choice[12],
			choice[13], choice[14], choice[15], choice[16], choice[17] ) )
		local ret = GetLastDialogResult()
		if(ret==0) then
			return 0
		else	
			WaitForUIEx( DialogModeEnd() )
			if(ret==1) then
				return 0
			end
			local ndx = selected[ret-1]
			if(money>=dcost[ndx]) then
				lostMoney(dcost[ndx])
				return ndx
			else
				MessageBox(30499)
			end
		end
	end
end

tcost		= { 600, 700 }
tenabled	= { 1321489, 1321493 }
tdisabled	= { 1321491, 1321492 }
tzone		= { "WStation", "Railroad" }

function makeTravel()
	local choice = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local selected = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local money = PlayerGetMoney(0)	
	while(1) do
		local cnt = 0
		local i
		local v
		for i,v in tzone do
			if((GVLastZone~=v) and isZoneOpened( v )) then
				cnt = cnt+1
				if(money>=tcost[i]) then
					choice[cnt] = tenabled[i]
				else
					choice[cnt] = tdisabled[i]
				end
				selected[cnt] = i
			end
		end
		EndSequencePart()
		WaitForUIEx( DialogModeBegin() )
		WaitForUIEx( DialogModeSet( 1170044, cnt+1, 16-cnt,
			1321490,
			choice[1], choice[2], choice[3], choice[4], choice[5], choice[6],
			choice[7], choice[8], choice[9], choice[10], choice[11], choice[12],
			choice[13], choice[14], choice[15], choice[16], choice[17] ) )
		local ret = GetLastDialogResult()
		if(ret==0) then
			return nil
		else	
			WaitForUIEx( DialogModeEnd() )
			if(ret==1) then
				return nil
			end
			local ndx = selected[ret-1]
			if(money>=tcost[ndx]) then
				local zone = tzone[ndx]
				lostMoney(tcost[ndx])
				return zone
			else
				MessageBox(30499)
			end
		end
	end
end

-- hide

Radius = 4
ListOfLight = {}
ListOfFloor = {}
ListOfUnits = {}
Night = false
lightCount = 0

function setLightRadius( aRadius )
	Radius = aRadius
end

function initFloor(prefix,floor)
	local i = 1
	while(true) do
		local lname = prefix..i
		local lamp = GetObject( lname ) 
		if(IsValid(lamp)) then
			ListOfLight[ lamp ] = GetPos( lamp )
			ListOfFloor[ lamp ] = floor
			local WPF = GetWaypointFloor( lname )
			if WPF ~= nil then
				ListOfLight[ lamp ] = GetWaypointPos( lname )
				ListOfFloor[ lamp ] = WPF
			else
				ListOfLight[ lamp ] = GetPos( lamp )
				ListOfFloor[ lamp ] = floor
			end
		else 
			break
		end
		i = i + 1
	end
	lightCount = lightCount + i - 1
end

hideInited = false
function hideInit( )
        if(not hideInited) then
		lightCount = 0
		initFloor("I",-2)
		initFloor("K",-1)
		initFloor("L",0)
out("*** First floor: ",lightCount)
	        initFloor("M",1)
	        initFloor("N",2)
out("*** Add second floor: ",lightCount)
		hideInited = true
	end
end

function UnitInLight( Unit )
	for Object, Position in ListOfLight do
        	local LampState = ObjectGetDestroyStage( Object )
		local Distance = GetDistance( GetPos( Unit ), Position )
		if ( LampState < 1 ) and 
		   ( Distance < Radius ) and 
		   ( not ObjectIsInPocket( Object ) ) and
		   ( UnitGetFloor( Unit ) == ListOfFloor[ Object ] ) then 
			return(true)
		end
	end
	return(false)
end

function lightCheck( playerNo )
	local group = PlayerGetUnits(playerNo)
	local groupSize = GroupGetSize( group )
	for i = 0, groupSize-1 do
		local unit = GroupGetUnit( group, i )
		if(IsValid(unit) and UnitCanFight(unit)) then
			if(UnitInLight( unit )) then
				if(ListOfUnits[unit]==nil) then
					ListOfUnits[unit] = 1
					if(UnitIsHiding(unit)) then
						if(playerNo==0) then
							UnitCancelAction(unit)
							UnitStop(unit)
							WaitForUnit(unit)
						end
						UnitHide(unit,false)
						WaitForUnit(unit)
					end
					UnitAllowHide( unit, false )
				end
			else
				if(ListOfUnits[unit]~=nil) then
					UnitAllowHide( unit, true ) 
					ListOfUnits[unit] = nil
				end
			end
		end
	end
end

function HIDE()	
	while(Night) do 
		for i=0,15 do
			lightCheck(i) 
		end
		Sleep(10)
	end 
end

function HideEnable()
	hideInit()
	Night = true	
	if(lightCount>0) then
		StartThread(HIDE)
	end
end

function correctUnitHide(unit,timeOfDay)
	if(unitIsActive( unit )) then
		if(timeOfDay==nil) then
			timeOfDay = getPartOfTime(getCurrentTime())
		end
		if((timeOfDay==DAY) and (currentZoneType~=ZT_CAVE)) then
			if(UnitIsHiding(unit)) then
				UnitHide(unit,false)
				WaitForUnit(unit)
			end
			UnitAllowHide(unit,false)
		else
			UnitAllowHide(unit,true)
		end
	end
end

function correctGroupHide(group,timeOfDay)
	if(timeOfDay==nil) then
		timeOfDay = getPartOfTime(getCurrentTime())
	end
	for i=0,GroupGetSize(group)-1 do
		local unit = GroupGetUnit(group,i)
		if(unitIsActive( unit )) then
			correctUnitHide(unit,timeOfDay)
		end
	end
end

function correctAllPlayersHide( timeOfDay )
	if(timeOfDay==nil) then
		timeOfDay = getPartOfTime(getCurrentTime())
	end
	for i=0,15 do
		local group = PlayerGetUnits(i)
		if(IsValid(group)) then
			correctGroupHide(group,timeOfDay)
		end
	end
end

function OnTimeOfDayChangedPrim( newTimeOfDay )
out("*** OnTimeOfDayChangedPrim ",newTimeOfDay)
	correctAllPlayersHide(newTimeOfDay)
	if((newTimeOfDay == NIGHT) or (currentZoneType==ZT_CAVE)) then
		HideEnable()
        else
		Night = false
	end
end

function OnTimeOfDayChanged( newTimeOfDay )
out("*** OnTimeOfDayChanged ",newTimeOfDay)
	OnTimeOfDayChangedPrim( newTimeOfDay )
end

-- misc

function OnUnitDamageUnitPrim(killer,unit)
end

function destroyItemInBackpack(unit)
	local item = UnitGetFirstItem(unit)
	if(IsValid(item)) then
		local itemID = UnitGetItemID( unit, item )
		UnitRemoveInventoryItem( unit, itemID )
		WaitForUnit(unit)
		return(true)
	end
	return(false)
end

function destroyAllItems(unit)
	while(destroyItemInBackpack(unit)) do end
	UnitActivateWeapon(unit,false)
	WaitForUnit(unit)
	UnitTakeOffSlotItem( unit, 0 )
	UnitTakeOffSlotItem( unit, 1 )
end

NPC = { BUZZ  = 1001007,LARRY = 1001011,
	FIDEL = 1001009,PAVEL = 1350045,
	ZIGFRID = 1321532, MOSHE = 1321123 }

currentZoneAmbient = AT_NORMAL
function startStandardZone( zoneName, zoneType, zoneAmbient )
	markRustedWeapon()
	if(zoneAmbient==nil) then
		currentZoneAmbient = AT_NORMAL
	else
		currentZoneAmbient = zoneAmbient
	end
	getVariables()
	testZoneInit()
	local deployParam = GetGlobalGameVar("deployParam","0")
	if(deployParam ~= "0") then
		SetGlobalGameVar("deployParam","0")
		DividedDeploy(deployParam)
	end
	local deployDirection = GetGlobalGameVar("deployDirection","8")
	deployDirection = deployDirection+0
	if(deployDirection~=8) then
		SetGlobalGameVar("deployDirection","8")
		WaitForGroupRoute(GetParty())
		GroupSetDirection(GetParty(),deployDirection)
		WaitForGroup(GetParty())
	end
	Sleep(10)
	focusCamera(GetHero())
	Sleep(10)
	GVZonesPassed = GVZonesPassed+1
	correctUniformHide(zoneType)
	partyRestoreUniformModifiers()
	checkPose()
	showUnitsInfo()
	skipTravelTime(zoneName,true)
	applyTimeOfDay()
	startTime()
	showCriticalInfo()
	zigfridTricks()
end

function OnMouseUnderZone( zoneName )
	local toSkip = skipTravelTime(zoneName,true,true)
	printSkipTime(toSkip)
end

function OnMouseMove()
	printTime()
end

function checkGlobalMap()
	getVariables()
	forcedZone = GetGlobalGameVar("forcedZone","0")
	if(forcedZone~="0") then
		SetGlobalGameVar("forcedZone","0")
		BeginZone(forcedZone)
		forcedZone = "0"
	elseif((GVLastZone=="BaseMT") and
		(GVNeedCaratelPlace == 1) and
		(GVWasIntermedia == 0)) then
		GVWasIntermedia = 1
		forcedZone = "Intermedia"
	elseif(GVNeedRadioTalk==1) then
		if(unitIsOurs(GetUnit("zigfrid"))) then
			GVNeedRadioTalk = 2
			forcedZone = "NotRadioCamp"
		else
			GVNeedRadioTalk = 0
			GVWarBranchForced = 1
		end
	elseif((GVLastZone=="Village") and
		(GVSellerEnemy==1) and
		(GVSellerQuestState==SQ_AVAILABLE) and
		(GVWasStartCamp==0)) then
		GVWasStartCamp = 1
		ScenarioAddVisibleZone("Lesnik")
		forcedZone = "StartCamp"
	elseif((GVLastZone=="ForestBand") and 
		(GVConvoyQuest==CQ_AVAILABLE) and
		(GVPiterDeal==PQ_NONE)) then
		ScenarioAddVisibleZone("Lesnik")
		forcedZone = "Lesnik"
	elseif(	(GVConvoyQuest>0) and
		(GVLastZone=="Convoy") and
		(GVWasRoadPost==0)) then
		GVWasRoadPost = 1
		forcedZone = "RoadPost"
	elseif(isNeedSwitchToWarBranch()) then
		if((GVGroupDontHasRadio==1) or isZoneOpened( "LogovoUpper" )) then
			forcedZone = "FinCampNotRadio"	
		else
			forcedZone = "FinCamp"
		end
	else
		return(false)
	end
	putVariables()
	if(forcedZone~="0") then
		BeginZone(forcedZone)
	end
	EnableGlobalInterface()
	return(true)
end

function GroupClearSounds(group)
	for i=0,GroupGetSize(group)-1 do
		local unit = GroupGetUnit(group,i)
		if(unitIsActive(unit)) then
			UnitClearSounds(unit)
		end
	end
end

function processDelayedEnter()
	return(true)
end

function initParty(zoneType)
	correctUniformHide(zoneType)
        partyRestoreUniformModifiers()
	checkPose()
	for i,k in smoked do
		smoked[i] = nil
	end
end

function testZoneInit()
	return(true)
end

function zoneEnteredTest()
	out("zoneEnteredTest generic func")
	return(true)
end

zoneEntered = 0
function OnEnterZonePrim( zoneName, zoneType, zoneAmbient )
	EnableFeature("reenter")
	processRustedWeapon()
	if(zoneAmbient==nil) then
		currentZoneAmbient = AT_NORMAL
	else
		currentZoneAmbient = zoneAmbient
	end
	--zoneEnteredTest()
	zoneEntered = zoneEntered+1
	if(zoneEntered>1) then
		GroupClearSounds(GetParty())
		getVariables()
		testZoneInit()
		local deployParam = GetGlobalGameVar("deployParam","0")
		if(deployParam ~= "0") then
			SetGlobalGameVar("deployParam","0")
			DividedDeploy(deployParam)
		end
		local deployDirection = GetGlobalGameVar("deployDirection","8")
		deployDirection = deployDirection+0
		if(deployDirection~=8) then
			SetGlobalGameVar("deployDirection","8")
			WaitForGroupRoute(GetParty())
			GroupSetDirection(GetParty(),deployDirection)
			WaitForGroup(GetParty())
		end
		skipTravelTime(zoneName)
		applyAmbientLight()
		initParty(zoneType)
		processDelayedEnter()
		StartGameEx()
		Sleep(10)
		focusCamera(GetHero())
		Sleep(10)
		zigfridTricks()
		AutoSave()
		threadsEnabled=true
	end
	correctAllPlayersHide()
	OutLog(GetString(1500456)..unfVer,0)
end

threadsEnabled=true
talkEnabled=true
function OnRealExitPrim()
	WaitForUIEx(FadeOut())
	turnRadioOff()
	processRustedWeapon()
	putVariables()
	SetLeaveZoneMode(true)
	SetLootMode(true)
	if(IsValid(healedPlayers)) then
		for i,v in healedPlayers do
			healPlayer(v)
		end
	end
        threadsEnabled=false
	UISequence=0
	UIAction=0
	talkEnabled=true
	partyLoseUniformModifiers()
	DelayGameStartEx()
end

function OnRealExit()
--t("*** O
	OnRealExitPrim()
	ExitToGlobal()
end

------ uniform

function getZoneModifier(item)
	local cityM
	local forestM
	cityM,forestM = GetUniformModifiers(item)
	if(currentZoneType==ZT_FOREST) then
		modifier = forestM
	elseif(currentZoneType==ZT_CITY) then
		modifier = cityM
	elseif(currentZoneType==ZT_CAVE) then
		modifier = cityM
	end
	if(modifier==nil) then
		modifier = 0
	end
	return(modifier)
end

function OnUnitUniformChanged(unit,oldItem,newItem)
	local delta = 0
	if(IsValid(oldItem)) then
		delta = delta-getZoneModifier(oldItem)
	end
	if(IsValid(newItem)) then
		delta = delta+getZoneModifier(newItem)
	end
	local hide = UnitGetSkillMaxValue( unit,ST_STEALTH )	
	UnitSetSkillMaxValue( unit,ST_STEALTH,hide+delta )	
end

partyUniforms = {}

correctUniformHideThreadFired = false
function correctUniformHideThread()
	for i=0,GroupGetSize(GetParty())-1 do
		local unit = GroupGetUnit(GetParty(),i)
		if(IsValid(unit)) then
			local item = UnitGetUniform(unit)
			partyUniforms[unit] = item
		end
	end
	--readsEnabled = true
	if(not correctUniformHideThreadFired) then
		correctUniformHideThreadFired = true
		while(1) do
			if(threadsEnabled) then
				for i=0,GroupGetSize(GetParty())-1 do
					local unit = GroupGetUnit(GetParty(),i)
					if(IsValid(unit)) then
						local item = UnitGetUniform(unit)
						if(     (partyUniforms[unit]==nil) or
							(ItemGetID(partyUniforms[unit])~=ItemGetID(item))) then
							OnUnitUniformChanged(unit,partyUniforms[unit],item)
	        	                		partyUniforms[unit]=item
						end
					end
				end
			end
			Sleep(10)
		end
	end
end

currentZoneType = ZT_FOREST
function correctUniformHide(zoneType)
	currentZoneType = zoneType
	StartThread(correctUniformHideThread)
end

function partyLoseUniformModifiers()
	for i=0,GroupGetSize(GetParty())-1 do
		local unit = GroupGetUnit(GetParty(),i)
		local hide = UnitGetSkillMaxValue( unit,ST_STEALTH )
		local item = UnitGetUniform(unit)
		UnitSetSkillMaxValue( unit,ST_STEALTH,hide-getZoneModifier(item) )
	end
end

function partyRestoreUniformModifiers()
	for i=0,GroupGetSize(GetParty())-1 do
		local unit = GroupGetUnit(GetParty(),i)
		applyUniformModifiers(unit)
	end
end

function applyUniformModifiers(unit)
	local hide = UnitGetSkillMaxValue( unit,ST_STEALTH )
out("*** UNIFORM WAS ",	hide)
	local item = UnitGetUniform(unit)
	UnitSetSkillMaxValue( unit,ST_STEALTH,hide+getZoneModifier(item) )	
out("*** UNIFORM NOW ",	hide+getZoneModifier(item))
end

function isCivilianUniform( uID )
	return( (uID==631) or (uID==633) or (uID==634) or 
		(uID==1340023) or
		(uID==1340187) or
		(uID==139) or
		((uID>=636) and (uID<=649)) or
		(uID==631) or (uID==634) or 
		((uID>=651) and (uID<=655)) )
end

function isAlliesUniform( uID )
	return( ((uID>=662) and (uID<=666)) or
		(uID==554) or (uID==565) or (uID==566) or
		(uID==1340062) or (uID==1340063))
end

function unitInCivilianUniform( unit )
	local item = UnitGetUniform(unit)
	if(IsValid(item) and isCivilianUniform( ItemGetID(item) )) then
		return(true)
	else
		return(false)
	end
end

function unitInAlliesUniform( unit )
	local item = UnitGetUniform(unit)
	if(IsValid(item) and isAlliesUniform( ItemGetID(item) )) then
		return(true)
	else
		return(false)
	end
end

function UnitIsIncorrect(unit)
	local ret = UnitIsIncorrectUniform(unit) or
		UnitIsIncorrectWeapon(unit)
	return(ret)
end

function UnitIsIncorrectWeapon(unit)
	if((not unitInAlliesUniform( unit )) and
		(unitHasLongFirearms(unit) or
		unitHasFirearmsInHand(unit))) then
		return(true)
	end	
	return(false)
end

function UnitIsIncorrectUniform(unit)
	if((not unitInAlliesUniform( unit )) and
		(not unitInCivilianUniform( unit ))) then
		return(true)
	end	
	return(false)
end

function groupSeeUnitWithIncorrectWeapon(group)
	for i=0,GroupGetSize(GetParty())-1 do
		local unit = GroupGetUnit(GetParty(),i)
		if( IsValid(unit) and UnitIsIncorrectWeapon(unit) and
			GroupCanSeeUnit( group, unit )) then
			return(unit)
		end
	end
	return(nil)
end

function groupSeeUnitWithIncorrectUniform(group)
	for i=0,GroupGetSize(GetParty())-1 do
		local unit = GroupGetUnit(GetParty(),i)
		if( IsValid(unit) and UnitIsIncorrectUniform(unit) and
			GroupCanSeeUnit( group, unit )) then
			return(unit)
		end
	end
	return(nil)
end

function UnitVisibledByWhom( unit )
	local enemyVision = CreateGroup()
	if(IsValid(unit)) then
		local group = PlayerGetUnits(1)
		for j = 0, GroupGetSize( group ) - 1 do
			local whom = GroupGetUnit( group, j )		
			if(IsValid(whom) and UnitCanSeeUnit(whom,unit)) then
				GroupAddUnit(enemyVision,whom)
			end
		end
	end
	return(enemyVision)
end

function getNearestGroupVision(group,target)
	local wpPos = GetPos(target)
	local minDistance = 1000000
	local u = nil
	for i=0,GroupGetSize(group)-1 do
		local unit = GroupGetUnit(group,i)
		if(unitIsActive( unit )) then
			local dist = GetDistance(GetPos(unit),wpPos)
			if((dist<minDistance) and
				UnitCanSeeUnit(unit,target)) then 
				minDistance = dist
				u = unit
			end	
		end
	end
	return(u)
end

function groupSeeNearestFromWaypoint(group,wp)
	local wpPos = GetWaypointPos(wp)
	local minDistance = 1000000
	local u = nil
	for i=0,GroupGetSize(GetParty())-1 do
		local unit = GroupGetUnit(GetParty(),i)
		if(IsValid(unit)) then
			local dist = GetDistance(GetPos(unit),wpPos)
			if((dist<minDistance) and
				GroupCanSeeUnit(group,unit)) then 
				minDistance = dist
				u = unit
			end
		end
	end
	if(minDistance>15) then
		u = nil
	end	
	return(u)
end

function forceZone(zoneName,deployParam,direction)
	if(deployParam==nil) then
		deployParam = "0"
	end
	if(direction==nil) then
		direction = "8"
	end
	SetGlobalGameVar("deployParam",deployParam)
	SetGlobalGameVar("deployDirection",direction)
	SetGlobalGameVar("forcedZone",zoneName)
	OnRealExitPrim()
out("** ExitToGlobal")
	ExitToGlobal()
end

function forceSubZone(zoneName,deployParam,direction)
	if(deployParam==nil) then
		deployParam = "0"
	end
	if(direction==nil) then
		direction = "8"
	end
	SetGlobalGameVar("deployParam",deployParam)
	SetGlobalGameVar("forcedZone",zoneName)
	SetGlobalGameVar("deployDirection",direction)
	OnRealExitPrim()
out("** ExitToChapter")
	ExitToChapter()
end

function checkForcedZone()
	forcedZone = GetGlobalGameVar("forcedZone","0")
	if(forcedZone~="0") then
		SetGlobalGameVar("forcedZone","0")
	        BeginZone(forcedZone)
		return(true)
	end
	return(false)
end

function initVariables()
	GVLastZone = "Checkpoint"
	GVLastHint = 0
	GVSellerQuestState = SQ_AVAILABLE
	GVLarryKnowAboutZigmundDeath = 0
	GVCarma = 0
	GVPiterDeal = PQ_NONE
	GVConvoyQuest = 0
	GVPiterMoney = 0
	GVFidelQuest = FQ_NONE
	GVWasStartCamp = 0
	GVZonesPassed = 1
	GVBuzzWaitInVillage = 0
	GVMashinistDead = 0
	GVParavozMove = 0
	GVNeedDlgAboutWaterpump = 0
	GVNeedDlgAboutPrison = 0
	GVNeedDlgAboutRoadBridge = 0
	GVAntiquarAvailable = 0
	GVMashinistNotTalked = 1
	GVLesnikEnemy = 0
	GVSellerEnemy = 0
	GVZigmundEnemy = 0
	GVLesnikFriend = 0
	GVZigmundTrade = 0
	GVWasRoadPost = 0
	GVEnteredFromWaterpump = 0
	GVBuzzSayAboutPoison = 0
	GVZigfridQuest = ZQ_NONE
	GVTravelWithBandits = 0
	GVNeedCaratelPlace = 0
	GVBaseSERetreat = 0
	GVWasIntermedia = 0
	GVNeedRadioTalk = 0
	GVMosheTalked = 0
	GVZigfridEnemy = 0
	GVNeedAgentPlace = 0
	GVAgentKilled = 0
	GVWarBranchForced = 0
	GVPavelHistory = 0
	GVLarryQuest = LQ_NONE
	GVPrisonPassed = 0
	GVMTQuest = MQ_NOTTAKED
	GVRadioState = 0
	GVKnowAboutGunter = 0
	GVBattleChoice = BC_ZERO
	GVSecretBagObtained = 0
	GVCurEvent = 0
	GVLastEvent = 0
	GVPumpPassed = 0
	GVArrestCount = 0
	GVBuzzGo = 0
	GVBuzzStrikeLarry = 0
	GVLarryTalked = 0
	GVBuzzTalked = 0
	GVHeroKnowAboutZigfrid = 0
	GVBuzzFree = 0
	GVNeedRadioBroke = 0
	GVGroupDontHasRadio = 0
	GVCityPassed = 0
	GVDocsToBuzz = 0
	GVColonelLive = 0
	GVMihLive = 0
	GVHeroKillBuzz = 0
	GVMosheGo = 0
	GVLastUpdateBad = 0
	--unfinished mod--
	GVPiterTrade = 0
	GVPiterBaseQuest = PBQ_NONE
	GVPiterDead = 0
end

function getVariables()
	GVSellerQuestState = getMarker( "sellerQuestState" )
	GVLarryKnowAboutZigmundDeath = getMarker("larryKnowAboutZigmundDeath")
	GVCarma = getMarker("Carma")
	GVPiterDeal = getMarker("piterDeal")
	GVWasRoadPost = getMarker("wasRoadPost")
	GVConvoyQuest = getMarker("convoyQuest")
	GVLastZone = GetGlobalGameVar( "lastZone", "0" )
	GVLastHint = getMarker("lastHint")
	GVPiterMoney = getMarker("piterMoney")
	GVFidelQuest = getMarker("fidelQuest")
	GVWasStartCamp = getMarker("wasStartCamp")
	GVZonesPassed = getMarker("zonesPassed")
	GVBuzzWaitInVillage = getMarker("buzzWaitInVillage")
	GVMashinistDead = getMarker("mashinistDead")
	GVParavozMove = getMarker("paravozMove")
	GVNeedDlgAboutWaterpump = getMarker("needDlgAboutWaterpump")
	GVNeedDlgAboutPrison = getMarker("needDlgAboutPrison")
	GVNeedDlgAboutRoadBridge = getMarker("needDlgAboutRoadBridge")
	GVAntiquarAvailable = getMarker("antiquarAvailable")
	GVMashinistNotTalked = getMarker("mashinistNotTalked")
	GVLesnikEnemy = getMarker("lesnikEnemy")
	GVSellerEnemy = getMarker( "sellerEnemy" )
	GVZigmundEnemy = getMarker( "zigmundEnemy" )
	GVLesnikFriend = getMarker("lesnikFriend")
	GVZigmundTrade = getMarker("zigmundTrade")
	GVEnteredFromWaterpump = getMarker("enteredFromWaterpump")
	GVBuzzSayAboutPoison = getMarker("buzzSayAboutPoison")
	GVZigfridQuest = getMarker("zigfridQuest")
	GVTravelWithBandits = getMarker("travelWithBandits")
	GVNeedCaratelPlace = getMarker("needCaratelPlace")
	GVBaseSERetreat = getMarker("baseSERetreat")
	GVWasIntermedia = getMarker("wasIntermedia")
	GVNeedRadioTalk = getMarker("needRadioTalk")
	GVMosheTalked = getMarker("mosheTalked")
	GVZigfridEnemy = getMarker("zigfridEnemy")
	GVNeedAgentPlace = getMarker("needAgentPlace")
	GVAgentKilled = getMarker("agentKilled")
	GVWarBranchForced = getMarker("warBranchForced")
	GVPavelHistory = getMarker("pavelHistory")
	GVLarryQuest = getMarker("larryQuest")
	GVPrisonPassed = getMarker("prisonPassed")
	GVMTQuest = getMarker("MTQuest")
	GVRadioState = getMarker("RadioState")
	GVKnowAboutGunter = getMarker("knowAboutGunter")
	GVBattleChoice = getMarker("battleChoice")
	GVSecretBagObtained = getMarker("secretBagObtained")
	GVCurEvent = getMarker("curEvent")
	GVLastEvent = getMarker("lastEvent")
	GVPumpPassed = getMarker("pumpPassed")
	GVArrestCount = getMarker("arrestCount")
	GVBuzzGo = getMarker("buzzGo")
	GVBuzzStrikeLarry = getMarker("buzzStrikeLarry")
	GVLarryTalked = getMarker("larryTalked")
	GVBuzzTalked = getMarker("buzzTalked")
	GVHeroKnowAboutZigfrid = getMarker("heroKnowAboutZigfrid")
	GVBuzzFree = getMarker("buzzFree")
	GVNeedRadioBroke = getMarker("needRadioBroke")
	GVGroupDontHasRadio = getMarker("groupDontHasRadio")
	GVCityPassed = getMarker("cityPassed")
	GVDocsToBuzz = getMarker("docsToBuzz")
	GVColonelLive = getMarker("colonelLive")
	GVMihLive = getMarker("mihLive")
	GVHeroKillBuzz = getMarker("heroKillBuzz")
	GVMosheGo = getMarker("mosheGo")
	GVLastUpdateBad = getMarker("lastUpdateBad")
	--unfinished mod--
	GVPiterTrade = getMarker("piterTrade")
	GVPiterBaseQuest = getMarker("piterBaseQuest")
	GVPiterDead = getMarker("piterDead")
end

function putVariables()
	SetGlobalGameVar("lastZone", GVLastZone)
	putMarker("lastHint", GVLastHint)
	putMarker("sellerQuestState", GVSellerQuestState)
	putMarker("larryKnowAboutZigmundDeath",GVLarryKnowAboutZigmundDeath)
	putMarker("Carma",GVCarma)
	putMarker("piterDeal",GVPiterDeal)
	putMarker("convoyQuest",GVConvoyQuest)
	putMarker("wasRoadPost",GVWasRoadPost)
	putMarker("piterMoney",GVPiterMoney)
	putMarker("fidelQuest",GVFidelQuest)
	putMarker("wasStartCamp",GVWasStartCamp)
	putMarker("zonesPassed",GVZonesPassed)
	putMarker("buzzWaitInVillage",GVBuzzWaitInVillage)
	putMarker("mashinistDead",GVMashinistDead)
	putMarker("paravozMove",GVParavozMove)
	putMarker("needDlgAboutWaterpump",GVNeedDlgAboutWaterpump)
	putMarker("needDlgAboutPrison",GVNeedDlgAboutPrison)
	putMarker("needDlgAboutRoadBridge",GVNeedDlgAboutRoadBridge)
	putMarker("antiquarAvailable",GVAntiquarAvailable)
	putMarker("mashinistNotTalked",GVMashinistNotTalked)
	putMarker("lesnikEnemy",GVLesnikEnemy)
	putMarker("sellerEnemy",GVSellerEnemy)
	putMarker("zigmundEnemy",GVZigmundEnemy)
	putMarker("lesnikFriend",GVLesnikFriend)
	putMarker("zigmundTrade",GVZigmundTrade)
	putMarker("enteredFromWaterpump",GVEnteredFromWaterpump)
	putMarker("buzzSayAboutPoison",GVBuzzSayAboutPoison)
	putMarker("zigfridQuest",GVZigfridQuest)
	putMarker("travelWithBandits",GVTravelWithBandits)
	putMarker("needCaratelPlace",GVNeedCaratelPlace)
	putMarker("baseSERetreat",GVBaseSERetreat)
	putMarker("wasIntermedia",GVWasIntermedia)
	putMarker("needRadioTalk",GVNeedRadioTalk)
	putMarker("mosheTalked",GVMosheTalked)
	putMarker("zigfridEnemy",GVZigfridEnemy)
	putMarker("needAgentPlace",GVNeedAgentPlace)
	putMarker("agentKilled",GVAgentKilled)
	putMarker("warBranchForced",GVWarBranchForced)
	putMarker("pavelHistory",GVPavelHistory)
	putMarker("larryQuest",GVLarryQuest)
	putMarker("prisonPassed",GVPrisonPassed)
	putMarker("MTQuest",GVMTQuest)
	putMarker("RadioState",GVRadioState)
	putMarker("knowAboutGunter",GVKnowAboutGunter)
	putMarker("battleChoice",GVBattleChoice)
	putMarker("secretBagObtained",GVSecretBagObtained)
	putMarker("curEvent",GVCurEvent)
	putMarker("lastEvent",GVLastEvent)
	putMarker("pumpPassed",GVPumpPassed)
	putMarker("arrestCount",GVArrestCount)
	putMarker("buzzGo",GVBuzzGo)
	putMarker("buzzStrikeLarry",GVBuzzStrikeLarry)
	putMarker("larryTalked",GVLarryTalked)
	putMarker("buzzTalked",GVBuzzTalked)
	putMarker("heroKnowAboutZigfrid",GVHeroKnowAboutZigfrid)
	putMarker("buzzFree",GVBuzzFree)
	putMarker("needRadioBroke",GVNeedRadioBroke)
	putMarker("groupDontHasRadio",GVGroupDontHasRadio)
	putMarker("cityPassed",GVCityPassed)
	putMarker("docsToBuzz",GVDocsToBuzz)
	putMarker("colonelLive",GVColonelLive)
	putMarker("mihLive",GVMihLive)
	putMarker("heroKillBuzz",GVHeroKillBuzz)
	putMarker("mosheGo",GVMosheGo)
	putMarker("lastUpdateBad",GVLastUpdateBad)
	--unfinished mod--
	putMarker("piterTrade",GVPiterTrade)
	putMarker("piterBaseQuest",GVPiterBaseQuest)
	putMarker("piterDead",GVPiterDead)
end

function unitIsCarryHeavyWeapon(unit)
	local item1 = UnitGetSlotItem(unit,0)
	local item2 = UnitGetSlotItem(unit,1)
	local ret = (	(IsValid(item1) and isItemHeavy(ItemGetID(item1))) or 
		(IsValid(item2) and isItemHeavy(ItemGetID(item2))))
	return(ret)
end

checkForRunThreadFired = false
function checkForRunThread()
	if(not checkForRunThreadFired) then
		checkForRunThreadFired = true
		while(1) do
			if(not IsRealTime()) then
				for i=0,GroupGetSize(GetParty())-1 do
					local unit = GroupGetUnit(GetParty(),i)
					if(unitIsActive( unit ) and
						(not IsUnitHasPerk(unit,29))) then
						if((UnitGetWishPose(unit)==POSE_RUN) and
							unitIsCarryHeavyWeapon(unit)) then
							UnitSetWishPose(unit,POSE_WALK)
						end
					end
				end
			end					
			Sleep(10)
		end
	end
end

function checkPose()
	StartThread(checkForRunThread)
end 

function OnPlayerTakePerk( unit, id )
	if(id==76) then
		local was = UnitGetSkillMaxValue(unit,ST_INT)
		UnitSetSkillMaxValue(unit,ST_INT,was+1)
		UnitSetSkillMaxValue(unit,ST_SPOT,UnitGetSkillMaxValue(unit,ST_SPOT)+GetMiscConst(GC_SPOTFOR1INT))
	elseif(id==77) then
		local was = UnitGetSkillMaxValue(unit,ST_STR)
		UnitSetSkillMaxValue(unit,ST_STR,was+1)
		UnitSetSkillMaxValue(unit,ST_VP,UnitGetSkillMaxValue(unit,ST_VP)+GetMiscConst(GC_VPFOR1STR))
	elseif(id==78) then
		UnitSetSkillMaxValue(unit,ST_VP,UnitGetSkillMaxValue(unit,ST_VP)+30)
	elseif(id==79) then
		local was = UnitGetSkillMaxValue(unit,ST_DEX)
		UnitSetSkillMaxValue(unit,ST_DEX,was+1)
		UnitSetSkillMaxValue(unit,ST_STEALTH,UnitGetSkillMaxValue(unit,ST_STEALTH)+GetMiscConst(GC_STEALTHFOR1DEX))
		UnitSetSkillMaxValue(unit,ST_SHOOTING,UnitGetSkillMaxValue(unit,ST_SHOOTING)+GetMiscConst(GC_SHOOTFOR1DEX))
		UnitSetSkillMaxValue(unit,ST_AP,UnitGetSkillMaxValue(unit,ST_AP)+GetMiscConst(GC_APFOR1DEX))
	end
end

function dialogBlockStart(bWait)
	if(bWait) then
		waitForUIAction()
	end
	UIAction = UIAction + 1
end

function dialogBlockEnd()
	UIAction = UIAction - 1
end

function waitForUIAction()
	while(UIAction>0) do 
		Sleep(20) 
		out('Wait for ui action end...')
	end
end

function isNeedSwitchToWarBranch()
	if((GVNeedDlgAboutWaterpump==1) and 
		((GVSellerEnemy==1) or 
			(GVSellerQuestState==SQ_TOZIGMUND) or
			(GVConvoyQuest==CQ_BADFIN) or
			(GVConvoyQuest==CQ_FAILED)) and

		(GVLesnikEnemy==1) and

		((GVZigmundEnemy==1) or
		 	((GVZigmundTrade==0) and 
			((GVLarryQuest==LQ_FAILED) or (GVConvoyQuest==CQ_BADFIN))))) then
		GVWarBranchForced = 1
	end
	if(isTimeExpired("finalQuest",false)) then
                GVWarBranchForced = 1
	end
	if(	(GVWarBranchForced==1) 
		or (GVCarma>MAX_CARMA) 
		) then
		GVWarBranchForced = 1
		return(true)
	else
		return(false)
	end
end

function GroupLookAtUnit(group,unit)
	if(IsValid(unit) and IsValid(group)) then
		for i=0,GroupGetSize(group)-1 do
			local u = GroupGetUnit(group,i)
			if(unitIsActive( unit )) then
				UnitLookAtUnit(u,unit)
			end
		end
	end
end

function GroupIsHearUnit( group, unit )
	if(IsValid(unit) and IsValid(group)) then
	        for i = 0, GroupGetSize( group )-1 do
			local u = GroupGetUnit( group, i )		
                	if(unitIsActive( u ) and UnitIsHearUnit( u, unit )) then
                        	return(true)
	                end
        	end
	end
        return(false)
end

civilDocs = {
	BUZZ  		= 1340302,
	LARRY 		= 1340304,
	FIDEL 		= 1340303,
	ZIGFRID 	= 1340306,
	MOSHE	  	= 1340305,
	PAVEL  		= 1340307,
	HERO		= 1340308,
}

armyDocs = {
	BUZZ  		= 1340309,
	LARRY 		= 1340312,
	FIDEL 		= 1340311,
	ZIGFRID 	= 1340314,
	MOSHE	  	= 1340313,
	PAVEL  		= 1340315,
	HERO		= 1340316,
}

ARMY_BLANK		=	1166003
CIVIL_BLANK		=	435
FAKE_PASS		=	515
NEW_PASS		=	1340320
CIVIL_DOC_COST		=	280
ARMY_DOC_COST		=	400

function unitHasSomeDocuments(unit)
	for i,v in civilDocs do
		if(HasInventoryItemUnit(unit,v)) then
			return(true)
		end
	end
	for i,v in armyDocs do
		if(HasInventoryItemUnit(unit,v)) then
			return(true)
		end
	end
	if(IsEqual(unit,GetHero()) and
		(HasInventoryItemUnit(unit,FAKE_PASS) or HasInventoryItemUnit(unit,NEW_PASS))) then
		return(true)
	end
	return(false)
end

function unitHasCorrectDocuments(unit)
	local name = UnitGetName(unit)
	if(IsEqual(unit,GetHero())) then
		name = "HERO"
	end
	if(unitInCivilianUniform( unit ) and 
		HasInventoryItemUnit(unit,civilDocs[name])) then
		return(true)
	end
	if(unitInAlliesUniform( unit ) and 
		HasInventoryItemUnit(unit,armyDocs[name])) then
		return(true)
	end
	if(IsEqual(unit,GetHero()) and
		unitInAlliesUniform( unit ) and
		HasInventoryItemUnit(unit,NEW_PASS)) then
		return(true)
	end
	return(false)
end

function giveMoneyToPolice(unit)
	local pmoney = {500,1000,0}
	local cnt = 3
	local choices = {1321835,1321836,1321837}
	for i,v in choices do
		if(pmoney[i]>PlayerGetMoney(0)) then
			choices[i] = 0
		end
	end
	pmoney[3] = PlayerGetMoney(0)
	EndSequencePart()			
	WaitForUIEx( DialogModeBegin() )
	WaitForUIEx( DialogModeSet( 1170044, 3, 0,
		choices[1],choices[2],choices[3],
		pmoney[1],pmoney[2]))
	local ret = GetLastDialogResult()
	if(ret~=0) then
		WaitForUIEx(DialogModeEnd())
		local delta = pmoney[ret]/pmoney[1]
		lostMoney(pmoney[ret])
		if(dice(unit,ST_DEX,-2+delta)) then
			WaitForUIEx(DialogPlay("policeIncorrectUniform4"))
			WaitForUIEx(YesNoDialog( 16837 ))
			ret = GetLastDialogResult()
			if(ret==1) then
				OnRealExitPrim()
				ExitToGlobal()
				return(true)
			end
		end
	end
	return(false)
end	

function isExistWaypoint( wname )
	local strman = CreateUnit( 692, 0, "StremMan", wname, 0 )
	if(strman~=nil) then
		UnitRemove( strman )
		return(true)
	end
	return(false)
end

function removeFromParty(unit,newNo,bNeedCopy,bNeedHeal)
	if(IsValid(unit)) then
		if(newNo==nil) then
			newNo=1
		end
		OnUnitUniformChanged(unit,UnitGetUniform(unit),1)
		UnitRemoveFromParty(unit,newNo)
		UnitSetPlayer(unit,newNo)
		UnitSetNormalLogic(unit)
		UnitAIMode(unit,true)
		UnitSetToolTipAdditional(unit,"")
		if(bNeedCopy) then
			copyUnit(unit,false,false,bNeedHeal)
		end
	end
end

function addToParty(unit)
	applyUniformModifiers(unit)
	partyUniforms[unit]=UnitGetUniform(unit)
	UnitAddToParty(unit,0)
	correctGroupHide(GetParty())
end

rustedTime = {}
rustedDurability = {}
excludeRusted = {}

function markRustedWeapon()
	local item = ItemLootNext()
	local iterated = {}
	while(IsValid(item) and (not iterated[item])) do
		iterated[item] = true
		if(isItemHasDurability(item)) then
			excludeRusted[item] = true
		end
		item = ItemLootNext(item)
		Sleep(2)
	end
end

function processRustedWeapon()
	local itemsToRemove = {}
	local cnt = 0
	local item = ItemLootNext()
	local iterated = {}
	while(IsValid(item) and (not iterated[item])) do
		iterated[item] = true
		if(excludeRusted[item]==nil) then
			if(isItemHasDurability(item)) then
			        if(currentZoneType==ZT_CITY) then
					cnt = cnt+1
					itemsToRemove[cnt] = item
				else
					if(rustedTime[item]==nil) then
						rustedDurability[item]=ItemGetDurability(item)
					else
						local lastd = rustedDurability[item]
						rustedDurability[item] = rustedDurability[item] - ((getCurrentTime()-rustedTime[item])/SEC_PER_HOUR)*GetDifficulty()
						if(rustedDurability[item]<=0) then
							cnt = cnt+1
							itemsToRemove[cnt] = item
							rustedDurability[item] = 0
						elseif(rustedDurability[item]<=50) then
                	                	        ItemSetBroken(item,true)
						end		
						ItemSetDurability(item,rustedDurability[item],
							ItemGetCurMaxDurability(item),
							ItemGetMaxDurability(item))
					end
					rustedTime[item]=getCurrentTime()
				end
			elseif(ItemGetTypeEx(item)==SF_GRENADE) then
				cnt = cnt+1
				itemsToRemove[cnt] = item
			end
		end
		item = ItemLootNext(item)
		Sleep(2)
	end
	for j=1,cnt do
		ItemRemove(itemsToRemove[j])
	end
end

hState = {}

function makeRest(unit,player)
	if(player==nil) then
		player = 1
	end
	if(IsEqual(unit,GetHero())) then
		if(isPeace()) then
			showSkip()
		else
			OutLog(GetString(1350125),0)
		end
	else
		WaitForUIEx(YesNoDialog( 1001353 ))
		local nAns = GetLastDialogResult()
		if( nAns == 1 ) then
			DialogPlayAsAcks(UnitGetName(unit).."Reject")
			Sleep(40)
			BeginSequenceEx()
			SetDiplomacy(0,player,DS_ALLY)
			SetDiplomacy(player,0,DS_ALLY)
			removeFromParty(unit,player,true,false)
			UnitPutWeaponToBackpack(unit)
			WaitForUnit(unit)
			UnitSetWishPose(unit,POSE_WALK)
			UnitSetPose(unit,POSE_WALK)
			WaitForUnit(unit)
			local restName = "rest"..random(1,4)
			RecalcWaypointPos(restName)
			UnitMoveToWaypoint(unit,restName)
			WaitForUnitRouteEx(unit,5)
			UnitSetCanTalk(unit,true)
			hState[unit] = 2
			putMarker(UnitGetName(unit).."rested",1)
			UnitAIMode(unit,false)	
			UnitSetTalkDistance(unit,2.0)
			EndSequenceEx()
		end
	end
end

function someFromPartyInArea(w1,w2,floor)
	for i=0,GroupGetSize(GetParty())-1 do
		local unit=GroupGetUnit(GetParty(),i)
		if(IsValid(unit) and
			UnitInArea(unit,w1,w2) and 
			((floor==nil) or (UnitGetFloor(unit)==floor))) then
			return(unit)
		end
	end
	return(nil)
end

function createParty()
	if(GroupGetSize(GetParty())>1) then
		local merc = GroupGetUnit(GetParty(),1)
		if(IsValid(merc)) then
			UnitRemoveFromParty(merc,0)
			UnitRemove(merc)
		end
	end
	if(GroupGetSize(GetParty())>1) then
		local merc = GroupGetUnit(GetParty(),1)
		if(IsValid(merc)) then
			UnitRemoveFromParty(merc,0)
			UnitRemove(merc)
		end
	end
	DeleteWaypoint("party")
	CreateWaypoint("party",GetHero())
	RecalcWaypointPos("party")
	addToParty(CreateUnit(1001007,0,"buzz","party",getPlayerLevel() ))
	addToParty(CreateUnit(1001011,0,"larry","party",getPlayerLevel() ))
	addToParty(CreateUnit(1001009,0,"fidel","party", getPlayerLevel() ))
	addToParty(CreateUnit(1321123,0,"moshe","party", getPlayerLevel() ))
	addToParty(CreateUnit(1321532,0,"zigfrid","party", getPlayerLevel() ))
	addToParty(CreateUnit(1350045,0,"pavel","party", getPlayerLevel() ))
end	

function WaitForUnitRouteEx( unit, maxSeconds )
	if IsValid( unit ) then
		local R = UnitGetRoute( unit );
		local i = 0
		Sleep( N_WAIT_TIME_TO_SLEEP );
		while( IsValid( R ) and unitIsActive( unit ) and (RouteIsFinished( R ) == nil)) do
			Sleep( N_WAIT_TIME_TO_SLEEP );
			i = i+N_WAIT_TIME_TO_SLEEP
			if(i>=maxSeconds*20) then
				break
			end
		end
	end
end

function WaitForGroupRouteEx( group, maxSeconds )
	local bWait = 1
	local R = {}
	local U = {}
	for n = 0, ( GroupGetSize( group ) - 1 ) 
	do
		local unit = GroupGetUnit( group, n )
		if unitIsActive( unit ) then
			R[ n ] = UnitGetRoute( unit )
			U[ n ] = unit
		end;
	end
	local i = 0
	while bWait == 1 do
		Sleep( N_WAIT_TIME_TO_SLEEP );
		i = i+N_WAIT_TIME_TO_SLEEP
		if(i>=maxSeconds*20) then
			break
		end
		bWait = nil;
		for n = 0, ( GroupGetSize( group ) - 1 ) do
			if unitIsActive( U[ n ] ) and IsValid( R[ n ] ) then
				if RouteIsFinished( R[ n ] ) == nil then
					bWait = 1
				end
			end;
		end
	end
end

function GroupSetPoseEx( group, pose )
	local sz = GroupGetSize( group )
	for i = 0, sz - 1 do
		local unit = GroupGetUnit( group, i )
		if(unitIsActive(unit)) then
			UnitSetPose( unit, pose )
		end
	end
end

pavelTalkFired = false
function pavelComment(reg1,reg2)
	pavelTalkFired = true
	while(unitIsOurs(pavel) and
		(not UnitInArea(pavel,reg1,reg2))) do
		Sleep(20)
	end	
	if(     (GVPavelHistory == 0) and
		unitIsOurs(pavel)) then
		dialogBlockStart(true)
		GVPavelHistory = 1
		BeginSequenceEx()
		WaitForUIEx(DialogPlay("agentHired"))
		if(IsValid(buzz) and UnitCanFight(buzz)) then
			WaitForUIEx(DialogPlay("agentHiredBuzz"))
		end	
		UnitSetRealName(pavel,GetString(1350714))
		EndSequenceEx()
		dialogBlockEnd()
	end
end

function unitIsActive( unit )
	local ret = ( IsValid(unit) and UnitCanFight(unit) and
		(not UnitIsInPocket(unit)))
	return(ret)
end

function radioTalk(unit,object,player)
	local ret = false
	if(IsValid(unit) and IsEqual(unit,GetHero())) then
		if(player==nil) then
			player=1
		end
		if(GVRadioState ~= RS_NONE) then
			ret = true
			if(not isPeace()) then
				OutLog(GetString(1351996),0)
			else
				turnRadioOff()
				if(GVNeedRadioBroke == 1) then
					ObjectSetDestroyStage(object,1)
					GVNeedRadioBroke = 0
					GVGroupDontHasRadio = 1
					GVNeedRadioTalk = 1
					toJournal(1000110)
				else
					dialogBlockStart(true)
					if(GVRadioState == RS_MCLEODTALKED) then
						GVCarma = GVCarma - 1
						WaitForUIEx(DialogPlay("mcleodRadio"))
--						giveXP(GVZonesPassed*1000)
						giveRelativeXP( 0.2 )
					elseif(GVRadioState == RS_WPUMPFAILED) then
						WaitForUIEx(DialogPlay("wpumpFailedRadio"))
--						giveXP(GVZonesPassed*1000)
						giveRelativeXP( 0.2 )
						GVWarBranchForced = 1
					elseif(GVRadioState == RS_MCLEODFAILED) then
						WaitForUIEx(DialogPlay("mcleodfailedRadio"))
--						giveXP(GVZonesPassed*1000)
						giveRelativeXP( 0.2 )
					elseif(GVRadioState == RS_MCLEODTALKEDDIED) then
						GVCarma = GVCarma - 1
						WaitForUIEx(DialogPlay("mcleoddiedRadio"))
						WaitForUIEx(DialogPlay("mcleoddiedRadio"..dicePostfix({"buzz","moshe","larry","fidel","zigfrid"})))
--						giveXP(GVZonesPassed*1000)
						giveRelativeXP( 0.2 )
					elseif(GVRadioState == RS_WATERPUMP) then
						GVCarma = GVCarma - 1
						WaitForUIEx(DialogPlay("wpumpRadio"))
--						giveXP(GVZonesPassed*1000)
						giveRelativeXP( 0.2 )
					elseif(GVRadioState == RS_AFTERWATERPUMP) then
						GVCarma = GVCarma - 1
						WaitForUIEx(DialogPlay("awpumpRadio"))
--						giveXP(GVZonesPassed*1000)
						giveRelativeXP( 0.2 )
					elseif(GVRadioState == RS_AFTERWATERPUMP1) then
						GVCarma = GVCarma - 1
						WaitForUIEx(DialogPlay("awpumpRadio1"))
--						giveXP(GVZonesPassed*1100)
						giveRelativeXP( 0.2 )
					elseif(GVRadioState == RS_AGENT) then
						GVGroupDontHasRadio = 0
						GVCarma = GVCarma - 1
						local restedUnits = {}
						WaitForUIEx(DialogPlay("mtRadio"))
--						giveXP(GVZonesPassed*2000)
						giveRelativeXP( 0.2 )
						local pfx = dicePostfix( {"buzz","fidel","larry","zigfrid"} )
						if(pfx~="single") then
							BeginSequenceEx()
							WaitForUIEx(DialogPlay("mtRadio"..pfx))
							WaitForUIEx(FadeOut())
							SetDiplomacy(0,player,DS_ALLY)
							SetDiplomacy(player,0,DS_ALLY)
							local cnt = GroupGetSize(GetParty())-1
							for i=1,cnt do
								local unit = GroupGetUnit(GetParty(),i)
								restedUnits[i] = unit
							end	
							for i=1,cnt do
								local unit = restedUnits[i]
								if(IsValid(unit) and UnitCanFight(unit)) then
									removeFromParty(unit,player,true,false)
									UnitPutWeaponToBackpack(unit)
									WaitForUnit(unit)
									UnitSetCanTalk(unit,true)
									hState[unit] = 2
			                                		UnitSetToWaypoint(unit,"rest")
									WaitForUnit(unit)
									UnitSetWishPose(unit,POSE_WALK)
									UnitSetPose(unit,POSE_WALK)
									WaitForUnit(unit)
									UnitMoveToWaypoint(unit,"rest"..random(1,4))
									putMarker(UnitGetName(unit).."rested",1)
									WaitForUnitRoute(unit)
									UnitAIMode(unit,false)
									UnitSetTalkDistance(unit,2.0)
								end
							end
							Sleep(40)
							WaitForUIEx(FadeIn())
							EndSequenceEx()
						end
						GVNeedAgentPlace=1
						toJournal(1000118)
					elseif(GVRadioState==RS_BROKE) then
						ObjectSetDestroyStage(object,1)
						WaitForUIEx(DialogPlay("radioBroke"))
						GVGroupDontHasRadio=1
						toJournal(1000110)
					end
				       	GVRadioState=RS_NONE
					dialogBlockEnd()
				end
			end
		end
	end
	return(ret)
end

function healPlayer(player)
	for i=0,GroupGetSize(PlayerGetUnits(player))-1 do
		local unit=GroupGetUnit(PlayerGetUnits(player),i)
		if(IsValid(unit) and UnitCanFight(unit)) then
			UnitHealCriticals(unit)
			UnitRegenerateVP(unit,1000)
		end
	end
end

function unitGiveItem(unitFrom,unitTo,item,isRead)
	if(unitIsActive(unitFrom) and unitIsActive(unitTo)) then
		UnitLookAtUnit(unitFrom,unitTo)
		UnitLookAtUnit(unitTo,unitFrom)
		WaitForUnit(unitTo)
		WaitForUnit(unitFrom)
		UnitActivateWeapon(unitFrom,false)
		UnitActivateWeapon(unitTo,false)
		WaitForUnit(unitTo)
		WaitForUnit(unitFrom)
		UnitSetPose(unitFrom,POSE_WALK)
		UnitSetPose(unitTo,POSE_WALK)
		WaitForUnit(unitTo)
		WaitForUnit(unitFrom)
		UnitPlayAnimation(unitFrom,5453,false)
		Sleep(16)
		local ani=5454
		if(isRead~=nil) then
			ani=5458
		end
		UnitPlayAnimation(unitTo,ani,false)
		Sleep(6)
		UnitHoldItem(unitFrom,item)
		Sleep(11)
		UnitHoldItem( unitFrom, -1 )
		UnitHoldItem( unitTo, item )
		Sleep(18)
		UnitHoldItem( unitTo, -1 )
	end
end

function makePass(itemID,cost,enabledDocs,itemDocs,hours)
	if(hours==nil) then
		hours = 1
	end
	local selected = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local newItems = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local itemsToMake = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	local dcnt
	local unit
	local ucnt = 0
	dcnt,unit = WhoHasInventoryItem(itemID)
	local vret = false
	if(IsValid(unit) and (PlayerGetMoney(0)>=cost)) then
		for i=0,GroupGetSize(GetParty())-1 do
			local unit = GroupGetUnit(GetParty(),i)
			local name = UnitGetName(unit)
			if(IsEqual(unit,GetHero())) then
				name = "HERO"
			end
			local item = itemDocs[name]
			if(UnitCanFight(unit) and 
				(not HasInventoryItemUnit(unit,item)) ) then
				ucnt = ucnt + 1
				selected[ucnt] = enabledDocs[name]
				newItems[ucnt] = item
			end
		end
		local sum = 0
		local icnt = 0
		while(true) do
			EndSequencePart()
			WaitForUIEx( DialogModeBegin() )
			WaitForUIEx( DialogModeSet( 1351841, 10, 1,
                       		1351842,1351840, 
				selected[1],selected[2],selected[3],selected[4],
				selected[5],selected[6],selected[7],selected[8], sum ) )
			local ret = GetLastDialogResult()
			if(ret==0) then
				break 
			elseif(ret==1) then
				WaitForUIEx( DialogModeEnd() )
				break
			elseif(ret==2) then
				WaitForUIEx( DialogModeEnd() )
				if(icnt>0) then
					skipHour(icnt*hours)
					for i=1,icnt do
						dcnt,unit = WhoHasInventoryItem(itemID)
						if(IsValid(unit)) then
							UnitRemoveInventoryItem(unit,itemID)
							UnitCreateItem(unit,itemsToMake[i])
						end     	
					end
					giveStuff()
					lostMoney(sum)
					vret = true
				end
				break
			else
				WaitForUIEx( DialogModeEnd() )
				selected[ret-2]	= 0
				icnt = icnt + 1
				itemsToMake[icnt] = newItems[ret-2]
				sum = sum + cost
				if((sum+cost>PlayerGetMoney(0)) or (icnt>=dcnt)) then
					selected[1] = 0
					selected[2] = 0
					selected[3] = 0
					selected[4] = 0
					selected[5] = 0
					selected[6] = 0
					selected[7] = 0
					selected[8] = 0
				end
			end
		end	
	end
	return vret
end

IT_NONE		=	0
IT_ADAPTATION	=	1
IT_SKILL	=	2
IT_MONEY	=	3
IT_UNUSED	=	4
IT_BUHLO	=	5

usedItems = {
{ 	-- NSD Sten Mk2
	ID = 1340322, 
	type = 	IT_ADAPTATION,
	str = 1352273, 
	ani = nil, 
	skill = nil, 
	skillDelta = 30, 
	linkedItem = 29,
	remove = true, 
	skippedTime = 1
},
{ 	-- NSD MP41
	ID = 1410013, 
	type = 	IT_ADAPTATION,
	str = 1400856, 
	ani = nil, 
	skill = nil, 
	skillDelta = 23, 
	linkedItem = 343,
	remove = true, 
	skippedTime = 1
},
{ 	-- NSD LeeEnfield
	ID = 1410011, 
	type = 	IT_ADAPTATION,
	str = 1400859, 
	ani = nil, 
	skill = nil, 
	skillDelta = 27, 
	linkedItem = 15,
	remove = true, 
	skippedTime = 1.5
},
{ 	-- NSD FG42
	ID = 1410012, 
	type = 	IT_ADAPTATION,
	str = 1400862, 
	ani = nil, 
	skill = nil, 
	skillDelta = 32, 
	linkedItem = 21,
	remove = true, 
	skippedTime = 1.5
},
{ 	-- Medical field manual
	ID = 1340323, 
	type = 	IT_SKILL,
	str = 1352274, 
	ani = nil, 
	skill = ST_MEDICINE,	
	skillDelta = 20,
	linkedItem = nil, 
	remove = true,
	skippedTime = 1
}, 
{       -- Belomor
	ID = 1320002, 
	type = 	IT_NONE,
	str = nil, 
	ani = 4268, 
	skill = nil, 
	skillDelta = nil, 
	linkedItem = nil, 
	remove = false, 
	skippedTime = nil
},
{       -- Camel
	ID = 1410161, 
	type = 	IT_NONE,
	str = nil, 
	ani = 4268, 
	skill = nil, 
	skillDelta = nil, 
	linkedItem = nil, 
	remove = false, 
	skippedTime = nil
},
{       -- Condom
	ID = 1410162, 
	type = 	IT_UNUSED,
	str = nil, 
	ani = nil, 
	skill = nil, 
	skillDelta = nil, 
	linkedItem = nil, 
	remove = false, 
	skippedTime = nil
},
{       -- Shnaps
	ID = 1410163, 
	type = 	IT_BUHLO,
	str = nil, 
	ani = nil, 
	skill = nil, 
	skillDelta = nil, 
	linkedItem = nil, 
	remove = false, 
	skippedTime = nil
},
{       -- Cash
	ID = 535, 
	type = 	IT_MONEY,
	str = nil, 
	ani = nil, 
	skill = nil, 
	skillDelta = 1000, 
	linkedItem = nil, 
	remove = true, 
	skippedTime = nil
}
}

smoked = {}
useInProgress = false
function OnUnitUseItem( unit )
	if(not useInProgress) then
		useInProgress = true
		local slot = UnitGetActiveSlot( unit )
		local item = UnitGetSlotItem( unit, slot )
		local itemID = ItemGetID(item)
		for i,v in usedItems do
			if(v.ID==itemID) then
				if(v.skippedTime~=nil) then
				WaitForUIEx(FadeOut())
					skipHour(v.skippedTime)
				elseif(v.ani~=nil) then
					local vp = UnitGetSkill(unit,ST_VP)
					if((vp>0) and ((smoked[unit]==nil) or (smoked[unit]<=GetTurn()))) then	
						local rnd = random(3,6)
						UnitSetTempModifier(unit,ST_INT,1,rnd)
						UnitSetTempModifier(unit,ST_SPOT,GetMiscConst(GC_SPOTFOR1INT),rnd)
						rnd = random(6,7)
						UnitSetTempModifier(unit,ST_VP,-min(vp,random(20,30)),rnd)
						smoked[unit] = GetTurn()+rnd
					end
					UnitSetPose(unit,POSE_WALK)
					WaitForUnit(unit)
					UnitPlayAnimation(unit,v.ani,false,true)
					WaitForUnit(unit)
				end
				if(v.type == IT_ADAPTATION) then
                	                local mult = 1 + ((UnitGetSkillMaxValue( unit, ST_INT )-5)/10)
					local new = v.skillDelta*mult
					UnitIncAdaptation(unit,v.linkedItem,new)
				elseif(v.type == IT_UNUSED) then
					UnitSayAck(unit,101)
				elseif(v.type == IT_SKILL) then
					local mult = 1 + ((UnitGetSkillMaxValue( unit, ST_INT )-5)/10)
					local old = UnitGetSkillMaxValue(unit,v.skill)
					local new = old+(old/100*v.skillDelta)*mult
					UnitSetSkillMaxValue(unit,v.skill,new)
				elseif(v.type == IT_MONEY) then
					giveMoney(v.skillDelta)
				elseif(v.type == IT_BUHLO) then
					local str = UnitGetSkillMaxValue(unit,ST_STR)
					local int = UnitGetSkillMaxValue(unit,ST_INT)
					local dex = UnitGetSkillMaxValue(unit,ST_DEX)
					UnitSetPose(unit,POSE_WALK)
					WaitForUnit(unit)
					if( (str<=1) or (int<=1) or (dex<=1) ) then
						local slot = -1
						local itm = UnitGetSlotItem(unit,0)
                                                if(IsValid(itm) and (ItemGetID(itm)==itemID)) then
							slot = 0
						else
							itm = UnitGetSlotItem(unit,1)
	                                                if(IsValid(itm) and (ItemGetID(itm)==itemID)) then
								slot = 1
							end
						end
						if(slot>=0) then
							UnitTakeOffSlotItem( unit, slot )
							UnitUpdateAnimation(unit)
							WaitForUnit(unit)
						end
						local ani = {956,1769,610,1756,3706,3707,2198,2199,2200,4428}
						UnitPlayAnimation(unit,ani[random(1,11)],false,true)
						WaitForUnit(unit)
						UnitApplyCritical(unit, 37)
					else
						UnitPlayAnimation(unit,1410145,false,true)
						Sleep(30)
						Play3DSound(1430600,GetPos(unit))
						WaitForUnit(unit)
						local rnd = random(10,25)
						UnitSetTempModifier(unit,ST_STR,-1,rnd)
						UnitSetTempModifier(unit,ST_VP,-GetMiscConst(GC_VPFOR1STR),rnd)
						rnd = random(10,25)
						UnitSetTempModifier(unit,ST_INT,-1,rnd)
						UnitSetTempModifier(unit,ST_SPOT,-GetMiscConst(GC_SPOTFOR1INT),rnd)
						rnd = random(10,25)
						UnitSetTempModifier(unit,ST_DEX,-1,rnd)
						UnitSetTempModifier(unit,ST_STEALTH,-GetMiscConst(GC_STEALTHFOR1DEX),rnd)
--						UnitSetTempModifier(unit,ST_SHOOTING,-GetMiscConst(GC_SHOOTFOR1DEX),rnd)
						UnitSetTempModifier(unit,ST_AP,-GetMiscConst(GC_APFOR1DEX),rnd)
						UnitSetTempModifier(unit,ST_IC,random(20,50),rnd-2)
					end
				end
				if(v.remove) then
					UnitTakeOffSlotItem( unit, slot )
					UnitUpdateAnimation(unit)
				end
				if(v.skippedTime~=nil) then
					WaitForUIEx(FadeIn())
				end
				if(v.str~=nil) then
					OutLog(GetString(v.str),0)
				end
				break;
			end
		end
       		useInProgress = false
	end
end

-- shop

zigmundStuff = 
{
	{ id = 3, prob = 	50 }, --	Luger P-08 (Parabellum)
	{ id = 4, prob = 	30 }, --	Sauer 38•
	{ id = 5, prob = 	40 }, --	Walther P-38
	{ id = 12, prob = 	50 }, --	Mauser 33/40 Rifle
	{ id = 21, prob = 	10 }, --	FG-42
	{ id = 22, prob = 	10 }, --	Walther G-41W Rifle
	{ id = 24, prob = 	60 }, --	Mauser M98 Rifle (Polish)
	{ id = 25, prob = 	60 }, --	Mauser M29 Rifle (Polish)
	{ id = 38, prob = 	50 }, --	MP-40
	{ id = 39, prob = 	10 }, --	STG-43
	{ id = 40, prob = 	40 }, --	MP-28
	{ id = 41, prob = 	3 }, --	MG-34
	{ id = 42, prob = 	2 }, --	MG-42
	{ id = 47, prob = 	10 }, --	ZB 26/30
	{ id = 174, prob = 	50 }, --	Manlicher-Carcano M38 Rifle
	{ id = 161, prob = 	50 }, --	MP-40/2
	{ id = 162, prob = 	15 }, --	Suomi
	{ id = 159, prob = 	20 }, --	Beretta Œ38/42
	{ id = 160, prob = 	40 }, --	MP-38
	{ id = 158, prob = 	20 }, --	Beretta Œ1938€
	{ id = 180, prob = 	5 }, --	Panzerschrek
	{ id = 190, prob = 	5 }, --	Panzerfaust
	{ id = 343, prob = 	30 }, --	MP-41
	{ id = 511, prob = 	20 }, --	Volksgewehr45
	{ id = 427, prob = 	60 }, --	Dynamite
	{ id = 433, prob = 	50 }, --	TNT
	{ id = 430, prob = 	40 }, --	Liddite
	{ id = 431, prob = 	30 }, --	Nitroglicerin
	{ id = 429, prob = 	20 }, --	Hecsogen
	{ id = 123, prob = 	20 }, --	M39
	{ id = 133, prob = 	20 }, --	M24
	{ id = 140, prob = 	20 }, --	M34
	{ id = 141, prob = 	50 }, --	SRCM mod.35
	{ id = 142, prob = 	50 }, --	Breda
	{ id = 143, prob = 	30 }, --	Z-23
	{ id = 144, prob = 	30 }, --	O-23
	{ id = 145, prob = 	30 }, --	OF37
	{ id = 358, prob = 	10 }, --	PWM 1
	{ id = 228, prob = 	5 }, --	TG-21
	{ id = 368, prob = 	70 }, --	SMIZ35_Mine
	{ id = 369, prob = 	50 }, --	Shumi_Mine
	{ id = 370, prob = 	30 }, --	Pmi43_Mine
	{ id = 8, prob = 	50 }, --	Mauser Š-96 1912
	{ id = 76, prob = 	45 }, --	Parabellum 8-round Pistol Clip
	{ id = 77, prob = 	35 }, --	Sauer 38X 8-round Pistol Clip
	{ id = 78, prob = 	45 }, --	Walther 8-round Pistol Clip
	{ id = 85, prob = 	35 }, --	Mauser 5-round Rifle Clip
	{ id = 93, prob = 	15 }, --	FG42 20-round Rifle Clip
	{ id = 105, prob = 	35 }, --	MP40 SMG 32-round Magazine
	{ id = 106, prob = 	20 }, --	STG43 SMG Magazine
	{ id = 109, prob = 	10 }, --	MG34/MG42 Boxed Cartridge Belt
	{ id = 115, prob = 	15 }, --	ZB26/30 Magazine
	{ id = 181, prob = 	20 }, --	Panzerschrek rocket
	{ id = 191, prob = 	20 }, --	Panzerfaust rocket
	{ id = 373, prob = 	35 }, --	Manlicher-Carcano M91/24 6-round Rifle Clip
	{ id = 372, prob = 	35 }, --	Manlicher-Carcano M38 6-round Rifle Clip
	{ id = 437, prob = 	20 }, --	Suomi SMG Cartridge Drum
	{ id = 441, prob = 	25 }, --	Beretta SMG Magazine
	{ id = 587, prob = 	8 }, --	Mauser 1912 10-round Clip JHP for Parabellum Cartridg
	{ id = 591, prob = 	10 }, --	Parabellum 8-round Pistol Clip JHP
	{ id = 592, prob = 	20 }, --	Sauer 38X 8-round Pistol Clip JHP
	{ id = 594, prob = 	12 }, --	Walther 8-round Pistol Clip JHP
	{ id = 596, prob = 	10 }, --	Beretta SMG Magazine JHP
	{ id = 598, prob = 	10 }, --	MP40 SMG 32-round Magazine JHP
	{ id = 603, prob = 	10 }, --	STG43 SMG Magazine JHP
	{ id = 604, prob = 	10 }, --	Suomi SMG Cartridge Drum JHP
	{ id = 82, prob = 	35 }, --	Mauser 1912 10-round Clip for Parabellum Cartridg
	{ id = 624, prob = 	5 },	-- 	Armor#1
	{ id = 244, prob = 	20 },	--	Ger_Machete_Knife
	{ id = 242, prob = 	20 },	--	Ger_Dagger_Knife
	{ id = 243, prob = 	20 },	--	Ger_Luftwaffe_Machete_Knife
	{ id = 236, prob = 	20 },	--	Ger_Kappmesser_Knife
	{ id = 234, prob = 	20 },	--	Finnish_Knife
	{ id = 237, prob = 	20 },	--	Ger_SSA_Dagger_Knife
	{ id = 235, prob = 	20 },	--	Ger_Pukke
	{ id = 230, prob = 	20 },	--	Ger_ThrowingKnife
	{ id = 231, prob = 	5 },	--	Ger_Shuriken

}

medicalStuff = 
{
	{ id = 400, prob = 40 },	-- (buffvp1) Liquid Cardiac Stimulant 
	{ id = 409, prob = 10 },	-- (buffvp2) Morphine Injection 
	{ id = 402, prob = 5 },	-- (buffvp3) Cardiac And Respiratory Stimulant 

	{ id = 406, prob = 40 },	-- (heal crit&vp1) Adhesive Surgical Plaster
	{ id = 396, prob = 20 },	-- (heal crit&vp2) Compressed Gauze Bandage
	{ id = 401, prob = 10 },	-- (heal crit&vp3) First Aid Kit

	{ id = 405, prob = 30 },	-- (heal critonly1) Haemostatic Forceps
	{ id = 399, prob = 20 },	-- (heal critonly2) Forceps, Abbey
	{ id = 397, prob = 5  },	-- (heal critonly3) Bullet Extractor

	{ id = 413, prob = 40 },	-- (stopbleeding1) Haemostatic Powder
	{ id = 410, prob = 20 },	-- (stopbleeding2) Fast Haemostatic Powder
	{ id = 414, prob = 10 },	-- (stopbleeding3) Haemostatic Liquid

	{ id = 398, prob = 50 },	-- (tempcritremove1) Acetophenetidin Analgesic Tablet
	{ id = 411, prob = 20 },	-- (tempcritremove2) Morphine Sulfate Analgesic Pill
	{ id = 412, prob = 5 },		-- (tempcritremove3) Chloroform Powerful Analgesic

	{ id = 408, prob = 5 },	-- (buffap) squirt 
}

sellerStuff = 
{
	{ id = 1, prob = 	30 },	-- 	Colt M1911 
	{ id = 2, prob = 	40 },	-- 	Luger (British)
	{ id = 11, prob = 	70 },	-- 	Nagant Revolver
	{ id = 15, prob = 	50 },	-- 	Lee-Enfield N4 Mk1
	{ id = 16, prob = 	10 },	-- 	M1 Carbine 1936 
	{ id = 23, prob = 	40 },	-- 	MAS 36 Rifle
	{ id = 29, prob = 	40 },	-- 	Sten MkII
	{ id = 30, prob = 	30 },	-- 	Sten MkIV
	{ id = 31, prob = 	20 },	-- 	Sten MkV
	{ id = 32, prob = 	30 },	-- 	Sten MkIII
	{ id = 45, prob = 	10 },	-- 	Bren Mk1
	{ id = 57, prob = 	10 },	-- 	Browning Œ1922
	{ id = 48, prob = 	15 },	-- 	Chatellerault Œ1924/1929
	{ id = 49, prob = 	10 },	-- 	Garand M1 Rifle
	{ id = 183, prob = 	5 },	-- 	PIAT
	{ id = 182, prob = 	5 },	-- 	Bazooka
	{ id = 350, prob = 	10 },	-- 	DeLizl Carbine
	{ id = 349, prob = 	10 },	-- 	Welrod_Mk1
	{ id = 489, prob = 	30 },	-- 	LewisMkI
	{ id = 493, prob = 	5 },	-- 	M1941_JohnsonRifle
	{ id = 499, prob = 	3 },	-- 	M1941_JohnsonLightGun
	{ id = 490, prob = 	15 },	-- 	BrowningHP
	{ id = 491, prob = 	30 },	-- 	Colt_38_Special
	{ id = 500, prob = 	10 },	-- 	M20_Bazooka
	{ id = 496, prob = 	10 },	-- 	Sterling_Patchett
	{ id = 497, prob = 	10 },	-- 	Sterling_Patchett_Para
	{ id = 572, prob = 	40 },	-- 	Springfield M1917
	{ id = 427, prob = 	70 },	-- 	Dynamite
	{ id = 433, prob = 	50 },	-- 	TNT
	{ id = 430, prob = 	40 },	-- 	Liddite
	{ id = 431, prob = 	30 },	-- 	Nitroglicerin
	{ id = 429, prob = 	20 },	-- 	Hecsogen
	{ id = 122, prob = 	60 },	-- 	Mk3A1
	{ id = 146, prob = 	40 },	-- 	36M Mk1
	{ id = 149, prob = 	20 },	-- 	F1
	{ id = 366, prob = 	50 },	-- 	6_Mark1_Mine
	{ id = 74, prob = 	35 },	-- 	Colt M1911 8-round Pistol Clip
	{ id = 84, prob = 	70 },	-- 	Nagant shells #21
	{ id = 87, prob = 	40 },	-- 	Lee-Enfield N4 Mk 1 10-round Rifle Clip
	{ id = 89, prob = 	35 },	-- 	Springfield M1917 5-round Rifle Clip
	{ id = 94, prob = 	45 },	-- 	MAS 36 5-round Rifle Clip
	{ id = 102, prob = 	30 },	-- 	Sten SMG 32-round Magazine
	{ id = 112, prob = 	15 },	-- 	Bren Machine-Gun Magazine
	{ id = 113, prob = 	15 },	-- 	Browning M1922 Magazine
	{ id = 116, prob = 	20 },	-- 	Chatellerault Machine-Gun Magazine
	{ id = 117, prob = 	20 },	-- 	Garand Œ1 8-round Rifle Clip
	{ id = 185, prob = 	20 },	-- 	PIAT rocket
	{ id = 184, prob = 	20 },	-- 	BazookaShell
	{ id = 488, prob = 	20 },	-- 	Lewis_MkI_Clip
	{ id = 506, prob = 	10 },	-- 	M1941_JohnsonRifleClip
	{ id = 502, prob = 	5 },	-- 	M1941_JohnsonLightGunClip
	{ id = 503, prob = 	20 },	-- 	BrowningHPClip
	{ id = 504, prob = 	35 },	-- 	Colt_38_SpecialClip
	{ id = 510, prob = 	20 },	-- 	M20 BazookaShell
	{ id = 509, prob = 	20 },	-- 	Sterling_PatchettClip
	{ id = 583, prob = 	10 },	-- 	BrowningHPClip JHP
	{ id = 584, prob = 	10 },	-- 	Colt M1911 8-round Pistol Clip JHP
	{ id = 585, prob = 	10 },	-- 	Colt_38_SpecialClip JHP
	{ id = 590, prob = 	30 },	-- 	Nagant shells JHP #21
	{ id = 586, prob = 	10 },	-- 	Luger P08 8-round Pistol Clip JHP
	{ id = 601, prob = 	5 },	-- 	Sten SMG 32-round Magazine JHP
	{ id = 602, prob = 	5 },	-- 	Sterling_PatchettClip JHP
	{ id = 75, prob = 	45 },	-- 	Luger P08 8-round Pistol Clip
	{ id = 624, prob = 	10 },	-- 	Armor#1
	{ id = 625, prob = 	5 },	-- 	Armor#2
	{ id = 626, prob = 	5 },	-- 	Armor#3
	{ id = 249, prob =	20 },	--	UK_Khukuri_Knife
	{ id = 240, prob =	20 },	--	UK_Ka_bar_Knife
	{ id = 241, prob =	20 },	--	UK_M3_Knife
	{ id = 239, prob =	20 },	--	UK_Fairbairn_Sykes_Knife
	{ id = 250, prob =	20 },	--	UK_M_1917_Knife
	{ id = 248, prob =	20 },	--	UK_Gladius_Knife
	{ id = 246, prob =	20 },	--	UK_BillyClub
	{ id = 233, prob =	20 },	--	UK_ThrowingKnife
	{ id = 232, prob =	20 },	--	UK_Chakra
	{ id = 245, prob =	5 },	--	Katana_Knife
	{ id = 247, prob =	20 },	--	UK_BlackJack
}

piterStuff =
{
	{ id = 1, prob = 	30 },	-- 	Colt M1911 
	{ id = 2, prob = 	40 },	-- 	Luger (British)
	{ id = 11, prob = 	70 },	-- 	Nagant Revolver
	{ id = 15, prob = 	50 },	-- 	Lee-Enfield N4 Mk1
	{ id = 16, prob = 	10 },	-- 	M1 Carbine 1936 
	{ id = 23, prob = 	40 },	-- 	MAS 36 Rifle
	{ id = 29, prob = 	40 },	-- 	Sten MkII
	{ id = 30, prob = 	30 },	-- 	Sten MkIV
	{ id = 31, prob = 	20 },	-- 	Sten MkV
	{ id = 32, prob = 	30 },	-- 	Sten MkIII
	{ id = 45, prob = 	10 },	-- 	Bren Mk1
	{ id = 57, prob = 	10 },	-- 	Browning Œ1922
	{ id = 48, prob = 	15 },	-- 	Chatellerault Œ1924/1929
	{ id = 49, prob = 	10 },	-- 	Garand M1 Rifle
	{ id = 183, prob = 	5 },	-- 	PIAT
	{ id = 182, prob = 	5 },	-- 	Bazooka
	{ id = 350, prob = 	10 },	-- 	DeLizl Carbine
	{ id = 349, prob = 	10 },	-- 	Welrod_Mk1
	{ id = 489, prob = 	30 },	-- 	LewisMkI
	{ id = 493, prob = 	5 },	-- 	M1941_JohnsonRifle
	{ id = 499, prob = 	3 },	-- 	M1941_JohnsonLightGun
	{ id = 490, prob = 	15 },	-- 	BrowningHP
	{ id = 491, prob = 	30 },	-- 	Colt_38_Special
	{ id = 500, prob = 	10 },	-- 	M20_Bazooka
	{ id = 496, prob = 	10 },	-- 	Sterling_Patchett
	{ id = 497, prob = 	10 },	-- 	Sterling_Patchett_Para
	{ id = 572, prob = 	40 },	-- 	Springfield M1917
	{ id = 427, prob = 	70 },	-- 	Dynamite
	{ id = 433, prob = 	50 },	-- 	TNT
	{ id = 430, prob = 	40 },	-- 	Liddite
	{ id = 431, prob = 	30 },	-- 	Nitroglicerin
	{ id = 429, prob = 	20 },	-- 	Hecsogen
	{ id = 122, prob = 	60 },	-- 	Mk3A1
	{ id = 146, prob = 	40 },	-- 	36M Mk1
	{ id = 149, prob = 	20 },	-- 	F1
	{ id = 366, prob = 	50 },	-- 	6_Mark1_Mine
	{ id = 74, prob = 	35 },	-- 	Colt M1911 8-round Pistol Clip
	{ id = 84, prob = 	70 },	-- 	Nagant shells #21
	{ id = 87, prob = 	40 },	-- 	Lee-Enfield N4 Mk 1 10-round Rifle Clip
	{ id = 89, prob = 	35 },	-- 	Springfield M1917 5-round Rifle Clip
	{ id = 94, prob = 	45 },	-- 	MAS 36 5-round Rifle Clip
	{ id = 102, prob = 	30 },	-- 	Sten SMG 32-round Magazine
	{ id = 112, prob = 	15 },	-- 	Bren Machine-Gun Magazine
	{ id = 113, prob = 	15 },	-- 	Browning M1922 Magazine
	{ id = 116, prob = 	20 },	-- 	Chatellerault Machine-Gun Magazine
	{ id = 117, prob = 	20 },	-- 	Garand Œ1 8-round Rifle Clip
	{ id = 185, prob = 	20 },	-- 	PIAT rocket
	{ id = 184, prob = 	20 },	-- 	BazookaShell
	{ id = 488, prob = 	20 },	-- 	Lewis_MkI_Clip
	{ id = 506, prob = 	10 },	-- 	M1941_JohnsonRifleClip
	{ id = 502, prob = 	5 },	-- 	M1941_JohnsonLightGunClip
	{ id = 503, prob = 	20 },	-- 	BrowningHPClip
	{ id = 504, prob = 	35 },	-- 	Colt_38_SpecialClip
	{ id = 510, prob = 	20 },	-- 	M20 BazookaShell
	{ id = 509, prob = 	20 },	-- 	Sterling_PatchettClip
	{ id = 583, prob = 	10 },	-- 	BrowningHPClip JHP
	{ id = 584, prob = 	10 },	-- 	Colt M1911 8-round Pistol Clip JHP
	{ id = 585, prob = 	10 },	-- 	Colt_38_SpecialClip JHP
	{ id = 590, prob = 	30 },	-- 	Nagant shells JHP #21
	{ id = 586, prob = 	10 },	-- 	Luger P08 8-round Pistol Clip JHP
	{ id = 601, prob = 	5 },	-- 	Sten SMG 32-round Magazine JHP
	{ id = 602, prob = 	5 },	-- 	Sterling_PatchettClip JHP
	{ id = 75, prob = 	45 },	-- 	Luger P08 8-round Pistol Clip
	{ id = 624, prob = 	10 },	-- 	Armor#1
	{ id = 625, prob = 	5 },	-- 	Armor#2
	{ id = 626, prob = 	5 },	-- 	Armor#3
	{ id = 249, prob =	20 },	--	UK_Khukuri_Knife
	{ id = 240, prob =	20 },	--	UK_Ka_bar_Knife
	{ id = 241, prob =	20 },	--	UK_M3_Knife
	{ id = 239, prob =	20 },	--	UK_Fairbairn_Sykes_Knife
	{ id = 250, prob =	20 },	--	UK_M_1917_Knife
	{ id = 248, prob =	20 },	--	UK_Gladius_Knife
	{ id = 246, prob =	20 },	--	UK_BillyClub
	{ id = 233, prob =	20 },	--	UK_ThrowingKnife
	{ id = 232, prob =	20 },	--	UK_Chakra
	{ id = 245, prob =	5 },	--	Katana_Knife
	{ id = 247, prob =	20 },	--	UK_BlackJack
	{ id = 244, prob = 	20 },	--	Ger_Machete_Knife
	{ id = 242, prob = 	20 },	--	Ger_Dagger_Knife
	{ id = 243, prob = 	20 },	--	Ger_Luftwaffe_Machete_Knife
	{ id = 236, prob = 	20 },	--	Ger_Kappmesser_Knife
	{ id = 234, prob = 	20 },	--	Finnish_Knife
	{ id = 237, prob = 	20 },	--	Ger_SSA_Dagger_Knife
	{ id = 235, prob = 	20 },	--	Ger_Pukke
	{ id = 230, prob = 	20 },	--	Ger_ThrowingKnife
	{ id = 231, prob = 	5 },	--	Ger_Shuriken
	{ id = 133, prob = 	20 }, --	M24
	{ id = 140, prob = 	20 }, --	M34
	{ id = 141, prob = 	50 }, --	SRCM mod.35
	{ id = 142, prob = 	50 }, --	Breda
	{ id = 143, prob = 	30 }, --	Z-23
	{ id = 144, prob = 	30 }, --	O-23
	{ id = 145, prob = 	30 }, --	OF37
	{ id = 358, prob = 	10 }, --	PWM 1
	{ id = 228, prob = 	5 }, --	TG-21
	{ id = 368, prob = 	70 }, --	SMIZ35_Mine
	{ id = 369, prob = 	50 }, --	Shumi_Mine
	{ id = 370, prob = 	30 }, --	Pmi43_Mine
	{ id = 8, prob = 	50 }, --	Mauser Š-96 1912
	{ id = 76, prob = 	45 }, --	Parabellum 8-round Pistol Clip
	{ id = 77, prob = 	35 }, --	Sauer 38X 8-round Pistol Clip
	{ id = 78, prob = 	45 }, --	Walther 8-round Pistol Clip
	{ id = 85, prob = 	35 }, --	Mauser 5-round Rifle Clip
	{ id = 93, prob = 	15 }, --	FG42 20-round Rifle Clip
	{ id = 105, prob = 	35 }, --	MP40 SMG 32-round Magazine
	{ id = 106, prob = 	20 }, --	STG43 SMG Magazine
	{ id = 109, prob = 	10 }, --	MG34/MG42 Boxed Cartridge Belt
	{ id = 115, prob = 	15 }, --	ZB26/30 Magazine
	{ id = 181, prob = 	20 }, --	Panzerschrek rocket
	{ id = 191, prob = 	20 }, --	Panzerfaust rocket
	{ id = 373, prob = 	35 }, --	Manlicher-Carcano M91/24 6-round Rifle Clip
	{ id = 372, prob = 	35 }, --	Manlicher-Carcano M38 6-round Rifle Clip
	{ id = 437, prob = 	20 }, --	Suomi SMG Cartridge Drum
}

foresterStuff = 
{
	{ id = 395, prob = 70	}, --	Picklock1
	{ id = 390, prob = 40	}, --	Picklock2
	{ id = 393, prob = 10	}, --	Picklock3
	{ id = 529, prob = 20	}, --	Wirecutter
	{ id = 387, prob = 50	}, --	MineClearingKit1
	{ id = 386, prob = 30	}, --	MineClearingKit2
	{ id = 388, prob = 10	}, --	MineClearingKit3
	{ id = 519, prob = 40	}, --	WeaponRepair1
	{ id = 520, prob = 20	}, --	WeaponRepair2
	{ id = 521, prob = 10	}, --	WeaponRepair3
}

antiquarStuff = 
{
	{ id = 534, prob = 20	}, --	Gold
	{ id = 532, prob = 20	}, --	Gold Clock
	{ id = 533, prob = 20	}, --	Gold Cup
	{ id = 536, prob = 20	}, --	Gold Ring
	{ id = 540, prob = 20	}, --	Jewels
	{ id = 531, prob = 20	}, --	Necklace
	{ id = 541, prob = 20	}, --	Picture
	{ id = 538, prob = 10	}, --	RareSword
}

SHOP_GENERATE_INTERVAL = SEC_PER_DAY

function itemInStuff(itemID,stuff)
	for i,v in stuff do
		if(v.id==itemID) then
			return(true)
		end
	end
	return(false)
end

function generateShop( id, stuff )
	local shopTime = getMarker("SHOPTIME"..id)
	local curTime = getCurrentTime()
	if(curTime-shopTime>SHOP_GENERATE_INTERVAL) then
		putMarker("SHOPTIME"..id,curTime)
		ClearShop(id)
		for i,v in stuff do
			for k=0,GVZonesPassed do
				if(v.prob>random(0,100)) then
					AddShopItem(id,v.id)
--				else
--					break
				end
			end
		end
	end
	local itemsToRemove = {}
	local iterated = {}
	local cnt = 0
	local item = ItemLootNext()
	while(IsValid(item) and (not iterated[item])) do
		iterated[item] = true 
	        local itemID = ItemGetID(item)
		if(itemInStuff(itemID,stuff) and (excludeRusted[item]==nil)) then
			cnt = cnt+1
			itemsToRemove[cnt] = item
			AddShopItem(id,itemID)
		end
		item = ItemLootNext(item)
		Sleep(2)
	end
	for j=1,cnt do
		ItemRemove(itemsToRemove[j])
	end
end

function addEvent(id,type)
	putMarker("eventID"..GVLastEvent,id)
	putMarker("eventType"..GVLastEvent,type)
	local days
	local time
	days,time =getDate()
	SetGlobalGameVar("eventDate"..GVLastEvent,days)
	SetGlobalGameVar("eventTime"..GVLastEvent,time)
	GVLastEvent=GVLastEvent+1
end

MAX_BG_HINT	=	5

function showEvent()
	local ret=false
	if(GVLastEvent>GVCurEvent) then
		local eventID=getMarker("eventID"..GVCurEvent)
		local eventType=getMarker("eventType"..GVCurEvent)
		local eventDays=GetGlobalGameVar("eventDate"..GVCurEvent,"0")
		local eventTime=GetGlobalGameVar("eventTime"..GVCurEvent,"0")
		GVCurEvent=GVCurEvent+1
		WaitForUIEx(ShowHintEx(eventID,eventType,2,eventDays,eventTime))
		ret=true
	elseif((GVLastHint<MAX_BG_HINT) and (random(100)<50)) then
		WaitForUIEx(ShowHintEx(1000001+GVLastHint,HT_OPERSOVIET,0,0))
		GVLastHint=GVLastHint+1 
		ret=true
	end
	EnableGlobalInterface()
	return(ret)
end

function focusCamera(u)
out("*** focusCamera start")
	WaitForUIEx(FocusCamera(u))
out("*** focusCamera end")
end

function mercCheck(basePlacement,player)
	if(GVBuzzGo == 1) then
		buzz = GetUnit("buzz")
		if(IsValid(buzz)) then
			putMarker("BUZZrested",0)
			UnitRemove(buzz)
			buzz = nil
		end
		local buzzInBed = GetUnit("buzzInBed")
		if(IsValid(buzzInBed)) then
			UnitRemove(buzzInBed)
		end
	end
	SetDiplomacy(0,player,DS_ALLY)
	SetDiplomacy(player,0,DS_ALLY)
	RecalcWaypointPos("rest1")
	RecalcWaypointPos("rest2")
	RecalcWaypointPos("rest3")
	local turnPassed = false
	for i=1,7 do
		local unitName = GetGlobalGameVar(basePlacement.."toBase"..i,"0")
		if(NPC[unitName]~=nil) then
			unit = CreateUnit(NPC[unitName],0,unitName,"rest1",1)
			if(unit~=nil) then
				turnPassed = true
				PlayerGiveTurn(player)
				UnitSetPlayer(unit,player)
				destroyAllItems(unit)
				pasteUnit(unit)
				UnitSetWishPose(unit,POSE_WALK)
				UnitSetPose(unit,POSE_WALK)
				WaitForUnit(unit)
				UnitSetCanTalk(unit,true)
				UnitMoveToWaypoint(unit,"rest"..random(2,4))
				WaitForUnitRouteEx(unit,4)
				hState[unit] = 2
				putMarker(unitName.."rested",1)
				SetGlobalGameVar(basePlacement.."toBase"..i,"0")
				UnitAIMode(unit,false)	
				UnitSetTalkDistance(unit,2.0)
			end
		else
			break
		end
	end
	if(turnPassed) then
		PlayerGiveTurn(0)
	end
end

function diceForTurn( destPlayer, unit )
	if(destPlayer==nil) then
		destPlayer = 1
	end
	if((GetDiplomacy(0,destPlayer)==DS_ENEMY) and 
		(GroupCanFightSize(PlayerGetUnits(destPlayer))>0)) then
		WantTurnBased(true)
		if(unit==nil) then
			unit = GetHero()
		end
		if(dice(unit,ST_DEX,-2)) then
			PlayerGiveTurn(0)
		else
			PlayerGiveTurn(destPlayer)
		end
		WantTurnBased(false)
	end
end

function larrySeeWeapon(larry)
	local q
	local unit
	q,unit = WhoHasInventoryItem(172)
	if(unitIsActive(unit) and 
		(UnitIsSeeUnit(larry,unit) or IsEqual(unit,larry))) then
		return(true)
	end
	return(false)
end

larryEnemy = false
function larryWeapon(larry)
	if(unitIsOurs(GetUnit("buzz"))) then
		WaitForUIEx(DialogPlay("larryCheckZigmundBuzz"))
	elseif(unitIsOurs(GetUnit("fidel"))) then
		WaitForUIEx(DialogPlay("larryCheckZigmundFidel"))
	elseif(unitIsOurs(GetUnit("moshe"))) then
		WaitForUIEx(DialogPlay("larryCheckZigmundMoshe"))
	else	
		WaitForUIEx(DialogPlay("larryCheckZigmundHero"))
	end	
	WaitForUIEx(DialogPlay("larryWeapon"))
	removeFromParty(larry,1)
	SetDiplomacy(0,1,DS_ENEMY)
	SetDiplomacy(1,0,DS_ENEMY)
	larryEnemy = true
end

function larryCheckZigmund(larry)
	if(unitIsOurs(GetUnit("buzz"))) then
		WaitForUIEx(DialogPlay("larryCheckZigmundBuzz"))
	elseif(unitIsOurs(GetUnit("fidel"))) then
		WaitForUIEx(DialogPlay("larryCheckZigmundFidel"))
	elseif(unitIsOurs(GetUnit("moshe"))) then
		WaitForUIEx(DialogPlay("larryCheckZigmundMoshe"))
	else	
		WaitForUIEx(DialogPlay("larryCheckZigmundHero"))
	end	
	WaitForUIEx(DialogPlay("larryCheckZigmund"))
	removeFromParty(larry,15)
	UnitMoveToWaypoint(larry,"UnitHero_1")
	Sleep(60)
	WaitForUIEx(FadeOut())
	Sleep(20)
	UnitRemove(larry)
	WaitForUIEx(FadeIn())
	if(unitIsOurs(GetUnit("buzz"))) then
		WaitForUIEx(DialogPlay("larryCheckZigmundBuzzComment"))
	end	
end

function getPartySize()
	local ret = 1
	if(unitIsActive(GetUnit("larry"))) then
		ret = ret+1
	end
	if(unitIsActive(GetUnit("pavel"))) then
		ret = ret+1
	end
	if(unitIsActive(GetUnit("zigfrid"))) then
		ret = ret+1
	end
	if(unitIsActive(GetUnit("buzz"))) then
		ret = ret+1
	end
	if(unitIsActive(GetUnit("fidel"))) then
		ret = ret+1
	end
	return(ret)
end

function checkAfterRest(unit,dest)
	putMarker(UnitGetName(dest).."rested",0)
	UnitSetCanTalk(dest,false)
	hState[dest]=nil
	local un = UnitGetName(dest)
	if((GVBuzzGo==1) and
		((un=="LARRY") or 
		((un=="FIDEL") and (getPartySize()>2)) or 
		(un=="ZIGFRID"))) then
		GVBuzzGo = 2
		dialogBlockStart(true)
		BeginSequenceEx(false)
		talked[dest] = true
		UnitLookAtUnit(unit,dest)
		UnitLookAtUnit(dest,unit)
		WaitForUnit(dest)			
		WaitForUIEx(DialogPlay(un.."BuzzGo"))
		talked[dest] = false
		EndSequenceEx()
		dialogBlockEnd()
		UnitSayAck(dest,102)
		addToParty( dest )
		return(true)
	elseif(un=="LARRY") then
		if((GVLarryKnowAboutZigmundDeath==0) and
		   (larrySeeWeapon(dest) or (GVSellerQuestState==SQ_DONE))) then
			dialogBlockStart(true)
			BeginSequenceEx(false)
			talked[dest] = true
			UnitPlayAnimation( dest, -1, true, true )
			UnitLookAtUnit(unit,dest)
			UnitLookAtUnit(dest,unit)
			WaitForUnit(unit)
			WaitForUnit(dest)
			if(larrySeeWeapon(dest)) then
				larryWeapon(dest)
			else
				larryCheckZigmund(dest)
			end
			talked[dest] = false
			EndSequenceEx()
			dialogBlockEnd()
			diceForTurn()
			return(true)
		end
	end
	return(false)
end

function namedDeploy()
	UnitSetToWaypoint(GetHero(),"heroDeploy")
	for i=1,GroupGetSize(GetParty())-1 do
		local unit = GroupGetUnit(GetParty(),i)
		if(unitIsOurs(unit)) then
			UnitSetToWaypoint(unit,UnitGetName(unit).."Deploy")
		end
	end
end

function OnUnitGiveItem(unit)
	if(unitIsOurs(unit)) then
		local WeightOfUnit = calcUnitWeight(unit)
		local MaxWeight = getUnitMaxWeight(unit)
		if((WeightOfUnit*100/MaxWeight>110) 
--			and (random(100)<33)
			) then
			UnitSayAck(unit,104)
		end
	end
end

function showHeroesScreen()
	local badFin = (GVWarBranchForced > 0) or
		((GVDocsToBuzz == 0) and (GVMihLive==0) and (GVColonelLive==0))
	if(badFin) then
		WaitForUI(uiShowFinalInfo(1320585,1410255,1462056,1410311,true)) -- mainhero bad 1
	else
		if(GVMihLive==1) then
			WaitForUI(uiShowFinalInfo(1320585,1410255,1462054,1410311,true)) -- mainhero goo
		else	
			WaitForUI(uiShowFinalInfo(1320585,1410255,1462055,1410311,true)) -- mainhero good 2
		end	
	end	
	if((getMarker("buzzHire")~=0) and 
		(getMarker("buzzKilled")~=1) and 
		(GVHeroKillBuzz~=1)) then
		if(badFin) then
			if(random(100)<50) then
				WaitForUI(uiShowFinalInfo(1320588,1410256,1462048,1410310)) -- buzz bad 1
			else
				WaitForUI(uiShowFinalInfo(1320588,1410256,1462049,1410310)) -- buzz bad 2
			end
		else
			if(GVMihLive==0) then
				WaitForUI(uiShowFinalInfo(1320588,1410256,1462046,1410310)) -- buzz good 1
			else
				WaitForUI(uiShowFinalInfo(1320588,1410256,1462047,1410310)) -- buzz good 2
			end
		end
	end
	if(unitIsOurs(GetUnit("moshe")) or (GVMosheGo==1)) then
		if(badFin) then
			if(GVMosheGo==1) then
				WaitForUI(uiShowFinalInfo(1320586,1410259,1462062)) -- moshe bad out
			else
				WaitForUI(uiShowFinalInfo(1320586,1410259,1462061)) -- moshe bad in
			end
		else
			if(GVMosheGo==1) then
				WaitForUI(uiShowFinalInfo(1320586,1410259,1462060)) -- moshe good out
			else
				WaitForUI(uiShowFinalInfo(1320586,1410259,1462059)) -- moshe good in
			end
		end
	end	
	if(unitIsOurs(GetUnit("larry"))) then
		if(badFin) then
			if(random(100)<50) then
				WaitForUI(uiShowFinalInfo(1320584,1410258,1462052)) -- larry bad 1
			else
				WaitForUI(uiShowFinalInfo(1320584,1410258,1462053)) -- larry bad 1
			end
		else
			if(GVCarma<8) then
				WaitForUI(uiShowFinalInfo(1320584,1410258,1462050)) -- larry good 1
			else
				WaitForUI(uiShowFinalInfo(1320584,1410258,1462051)) -- larry good 2
			end
		end
	end
	if(unitIsOurs(GetUnit("fidel"))) then
		if(badFin) then
			if(random(100)<50) then
				WaitForUI(uiShowFinalInfo(1320583,1410257,1462040)) -- fidel bad 1
			else
				WaitForUI(uiShowFinalInfo(1320583,1410257,1462041)) -- fidel bad 2
			end
		else
			if(GVMihLive==0) then
				WaitForUI(uiShowFinalInfo(1320583,1410257,1462039)) -- fidel med
			else	
				if(GVCarma<8) then
					WaitForUI(uiShowFinalInfo(1320583,1410257,1462037)) -- fidel good 1
				else
					WaitForUI(uiShowFinalInfo(1320583,1410257,1462038)) -- fidel good 2
				end	
			end
		end
	end
	if(unitIsOurs(GetUnit("pavel"))) then
		if(badFin) then
			WaitForUI(uiShowFinalInfo(1320587,1410260,1462058)) -- pavel bad 1
		else
			WaitForUI(uiShowFinalInfo(1320587,1410260,1462057)) -- pavel good 1
		end
	end
	if(unitIsOurs(GetUnit("zigfrid"))) then
		if(badFin) then
			if(random(100)<50) then
				WaitForUI(uiShowFinalInfo(1320589,1410261,1462044)) -- zigfrid bad 1
			else
				WaitForUI(uiShowFinalInfo(1320589,1410261,1462045)) -- zigfrid bad 2
			end
		else
			if(GVCarma<8) then
				WaitForUI(uiShowFinalInfo(1320589,1410261,1462042)) -- zigfrid good 1
			else
				WaitForUI(uiShowFinalInfo(1320589,1410261,1462043)) -- zigfrid good 2
			end
		end
	end
end

function gameOver( bAllDead, outroPrefix )
	if(not bAllDead) then
		WaitForUIEx( FadeOut() )
        	showHeroesScreen()
	end
	WaitForUI( ShowHallOfFame( true ) )
	PauseMusic(true)
	PlayVideo("cfg\\outro"..outroPrefix..".seq")
end

function filterGroup( group )
	local ret = CreateGroup()
	for i=0,GroupGetSize(group)-1 do
		local u = GroupGetUnit(group,i)
		if(IsValid(u)) then
			GroupAddUnit(ret,u)
		end
	end
	return(ret)
end

function isDifficultyAboveEasy()
	local ret = GetDifficulty()-DF_EASY
	return(ret>0.4)
end

function isDifficultyLesserEasy()
	local ret = DF_EASY-GetDifficulty()
	return(ret>0.1)
end

function isDifficultyLesserOrEqualEasy()
	local ret = DF_EASY-GetDifficulty()
	return(ret>0.001)
end

function isDifficultyAboveNormal()
	local ret = GetDifficulty()-DF_NORMAL
	return(ret>0.4)
end

function isDifficultyAboveOrEqualNormal()
	local ret = GetDifficulty()-DF_NORMAL
	return(ret>-0.01)
end

function isDifficultyLesserNormal()
	local ret = DF_NORMAL-GetDifficulty()
	return(ret>0.1)
end

function isDifficultyLesserOrEqualNormal()
	local ret = DF_NORMAL-GetDifficulty()
	return(ret>0.001)
end

function isDifficultyLesserHard()
	local ret = DF_HARD-GetDifficulty()
	return(ret>0.1)
end

function OnKeyboard( keyID, bState )
end

selectedUnit = nil
function OnSelectUnit(unit,nSelected)
	if(nSelected==1) then
		selectedUnit = unit
	end
end

critInfo = {
30604,
30568,
30569,
30574,
0,	-- CL_VP
30572,
0,	-- C_ENCUMBRANCE
30602,
30603,
30571,
30573,
0, 	-- C_DAMAGE_WEAPON
30605,
30570,
30567
}

function showUnitCriticalInfo(unit)
	if(selectedUnit~=nil and IsValid(selectedUnit) and IsUnitHasPerk(selectedUnit,65)) then
		if(UnitCanFight(unit)) then
			local s = ""
			for i = C_DEATH, C_BLEEDING do
				local no = critInfo[i+1]
				if(no~=0 and UnitHasCritical(unit,i)) then
					s = s.."<br>"..GetString(no)
				end
			end
			if(s~="") then
				UnitSetToolTipAdditional(unit, "<color=red>"..s.."<font face=Courier size=16pt><color=beige>" )
			else
				UnitSetToolTipAdditional(unit, "" )
			end
		else
			UnitSetToolTipAdditional(unit, "" )
		end
	else
		UnitSetToolTipAdditional(unit, "" )
	end
end

function showCriticalThread()
	while(1) do
		for j=1,15 do
			local group = PlayerGetUnits(j)
			for i=0,GroupGetSize(group)-1 do
				local u = GroupGetUnit(group,i)
				if(IsValid(u)) then
					showUnitCriticalInfo(u)
				end
			end                             
		end
		Sleep(10)
	end
end

showCriticalInfoFired = false
function showCriticalInfo()
	if(not showCriticalInfoFired) then
		showCriticalInfoFired = true
		StartThread(showCriticalThread)
	end
end

unfVer = "UnfinishedMod:1.02b" --mod version
-------------------------------------------------------------------------
out( 'Sickle scripts were loaded' )
