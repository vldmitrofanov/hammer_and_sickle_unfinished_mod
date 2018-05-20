DEBUG=0

if(DEBUG == 1) then
	ExecCommand("cheat_showall 1")
end

healedPlayers = {1}

count["BANDIT1"] = 4
route["BANDIT1"] = 
{
	{ way = "i1", dist = 0.1, obj = nil, direction = 2, ani1 = 1320051, ani2 = 1320053, turns = 8, ani3 = nil },
	{ way = "i2", dist = 0.1, obj = nil, direction = 3, ani1 = 1058, ani2 = 1048, turns = 4, ani3 = nil },
	{ way = "i3", dist = 1, obj = nil, direction = 0, ani1 = 4271, ani2 = 4270, turns = 3, ani3 = 4269 },
	{ way = "i4", dist = 1, obj = nil, direction = nil, ani1 = 4273, ani2 = 4268, turns = 4, ani3 = 4269 },
}

count["BANDIT2"] = 4
route["BANDIT2"] = 
{
	{ way = "i5", dist = 0.1, obj = nil, direction = 5, ani1 = 1320051, ani2 = 1320054, turns = 10, ani3 = nil },
	{ way = "i6", dist = 1, obj = nil, direction = nil, ani1 = 3021, ani2 = 3958, turns = 4, ani3 = 3959 },
	{ way = "i7", dist = 0.1, obj = nil, direction = 4, ani1 = 1058, ani2 = 1048, turns = 4, ani3 = nil },
	{ way = "i8", dist = 1, obj = nil, direction = nil, ani1 = 3960, ani2 = 3958, turns = 3, ani3 = 3959 },
}

StateNPC = {}

function WaitForNPCRoute( unit, bBreakIfDead )
	if IsValid( unit ) then
		local R = UnitGetRoute( unit );
		Sleep( N_WAIT_TIME_TO_SLEEP );
		while IsValid( R ) and ( ( ( not bBreakIfDead ) or UnitCanFight( unit ) ) and RouteIsFinished( R ) == nil ) do
			Sleep( N_WAIT_TIME_TO_SLEEP );
			if ( talked[ unit ] ) then
				UnitStop( unit )
				UnitCancelAction( unit )
				return
			end
		end
	end
end

function PlayAnimation( unit, ID, speed, bCircled, bRest )
	UnitSetAnimSpeed( unit, speed )
	UnitPlayAnimation( unit, ID, bCircled, bRest )
	Sleep( 5 )
	UnitSetAnimSpeed( unit, 1 )
end

function NPCPlayAnimation( unit, ID, speed, bCircled, bRest )
	if ( talked[ unit ] ) then return end
	StartThread( PlayAnimation, unit, ID, speed, bCircled, bRest )
end

function CloseDoor()
	if( ( ObjectGetDestroyStage( GetObject( "door" ) ) > 1 ) or
		talked[zigmund]) then 
		return 
	end
	UnitMoveToWaypoint( zigmund, "door" )
	WaitForUnitRoute( zigmund )
	if(talked[zigmund]) then
		return 
	end
	UnitSetDirection( zigmund, 0 )
	WaitForUnit( zigmund )
	UnitPlayAnimation( zigmund, 3820, false )
	Sleep( 10 )
	ObjectClose( GetObject( "door" ) )
	Sleep( 10 )
end

function CheckWindow()
	local window1 = GetObject( "window1" )
	if ObjectIsOpened( window1 ) then
out("** window opened!")
		local dlg = { "zigwnd1","zigwnd3","zigwnd3" }
		DialogPlayAsAcks( dlg[random(1,4)] )
		UnitMoveToWaypoint(zigmund,"window")
		WaitForUnitRoute( zigmund )
		UnitSetDirection( zigmund, DIR_LEFT )
		WaitForUnit(zigmund)
		UnitPlayAnimation( zigmund, 3820, false )
		Sleep( 10 )
		ObjectClose( window1 )
		Sleep( 10 )
		UnitMoveToWaypoint( zigmund, "zigmund" )
		WaitForUnitRoute( zigmund )
		UnitSetDirection( zigmund, 1 )
		WaitForUnit( zigmund )
	end
	local window3 = GetObject( "window3" )
	if ObjectIsOpened( window3 ) then
out("** window opened!")
		local dlg = { "zigwnd1","zigwnd3","zigwnd3" }
		DialogPlayAsAcks( dlg[random(1,4)] )
		UnitMoveToWaypoint(zigmund,"window3")
		WaitForUnitRoute( zigmund )
		UnitSetDirection( zigmund, 0 )
		WaitForUnit(zigmund)
		UnitPlayAnimation( zigmund, 3820, false )
		Sleep( 10 )
		ObjectClose( window3 )
		Sleep( 10 )
		UnitMoveToWaypoint( zigmund, "zigmund" )
		WaitForUnitRoute( zigmund )
		UnitSetDirection( zigmund, 1 )
		WaitForUnit( zigmund )
	end
end

function NPC_Zigmund( unit, waypoint )
	if ( talked[ unit ] ) then
		return
	end
	if StateNPC[ unit ] > 0 then
		StateNPC[ unit ] = StateNPC[ unit ] - 1
		return
	end
	UnitSetWishPose( unit, POSE_WALK )
	WaitForUnit( unit )
	local r = random( 15 )
	if zigmundFirstTalk then
		r = random( 10 )
		if r > 2 then r = 7 end
	end
	-- ???????????:
	-- 1/15 ? ?????? (?? ???????)
	-- 2/15 ??????
	-- 2/15 ? ???????? ??????
	-- 2/15 ? ?????
	-- 8/15 ????? ?? "?????"
	-- ??? zigmundFirstTalk == true ???????????:
	-- 1/10 ? ?????? (?? ???????)
	-- 2/10 ??????
	-- 7/10 ????? ?? "?????"
	
out( "variant_Zigmund ", r )

	if r == 0 then
		UnitMoveToWaypoint( unit, "garbage" )
		WaitForNPCRoute( unit )
		UnitSetDirection( unit, 3 )
		WaitForUnit( unit )
		NPCPlayAnimation( unit, 4271, 3 )
		if ( talked[ unit ] ) then
			return
		end
		Sleep( 150 )
		NPCPlayAnimation( unit, 4270, 1 )
		if ( talked[ unit ] ) then
			return
		end
		Sleep( 40 )
		NPCPlayAnimation( unit, 4269, 2 )
		if ( talked[ unit ] ) then
			return
		end
		Sleep( 60 )
		if ( not ( talked[ unit ] ) ) then UnitMoveToWaypoint( unit, "smoke" ) end
	elseif r < 3 then
		UnitMoveToWaypoint( unit, "smoke" )
		WaitForNPCRoute( unit )
		if ( talked[ unit ] ) then
			return
		end
		UnitSetDirection( unit, 7 )
		WaitForUnit( unit )
		NPCPlayAnimation( unit, 4268, 4 )
		if ( talked[ unit ] ) then
			return
		end
		Sleep( 450 )
		NPCPlayAnimation( unit, 4272, 3 )
	elseif r < 5 then
		UnitMoveToWaypoint( unit, "hibara1" )
		WaitForNPCRoute( unit )
		if ( talked[ unit ] ) then
			return
		end
		UnitSetDirection( unit, 3 )
		WaitForUnit( unit )
		NPCPlayAnimation( unit, 4273, 4 )
		if ( talked[ unit ] ) then
			return
		end		
		Sleep( 100 )
		UnitMoveToWaypoint( unit, "hibara2" )
		WaitForNPCRoute( unit, "hibara2" )
		if ( talked[ unit ] ) then
			return
		end
		UnitSetDirection( unit, 5 )
		WaitForUnit( unit )
		NPCPlayAnimation( unit, 4273, 4 )
	elseif r < 7 then
		UnitMoveToWaypoint( unit, "saray" )
		WaitForNPCRoute( unit )
		if ( talked[ unit ] ) then
			return
		end
		UnitSetDirection( unit, 2 )
		WaitForUnit( unit )
		UnitSetPose( unit, POSE_CROUCH )
		WaitForUnit( unit )
		NPCPlayAnimation( unit, 1048, 3 )
	else
		local distance = GetDistance( GetWaypointPos( "zigmund" ), GetPos( unit ) )
		if ( distance > 3 ) then CloseDoor() end
		if ( talked[ unit ] ) then
			return
		end
		UnitMoveToWaypoint( unit, "zigmund" )
		WaitForUnitRoute( unit )
		UnitSetDirection( unit, 1 )
		WaitForUnit( unit )
		StateNPC[ unit ] = 4
		SleepForTurn(4)
	end
end

function ThreadNPC_Zigmund( unit, waypoint )
	StateNPC[ unit ] = 0
	UnitAIMode( unit, false )
	WaitForUnit( unit )
	while UnitCanFight( unit ) do
		out( "--== Zigmund ==-- ", StateNPC[ unit ] )
		NPC_Zigmund( unit, waypoint )
		if ( GetDiplomacy( 0, unitGetPlayer( unit ) ) == 0 ) then
			UnitAIMode( unit, true )
			UnitSetNormalLogic( unit )
			WaitForUnit( unit )
			return
		end
		if(IsRealTime() and isPeace() and (not talked[unit])) then
			for i = 0, 5 do
				if StateNPC[ unit ] > 0 then CheckWindow() end
				Sleep( 40 )
			end
		else
			SleepForTurn()
		end
	end
end

MAP_ITEM	=	578

function OnRealExit()
	if( ((GVSellerQuestState==SQ_ZIGMUNDLIVE) or
		(GVSellerQuestState==SQ_TAKED)) and
		IsValid(zigmund) and
		(not UnitCanFight(zigmund)) ) then
		OnUnitDeath(zigmund)
	end	
--============================================================================
	if caratelPlaced then putTimeMarker( "caratelsLeave", 1 ) end
--============================================================================
	OnRealExitPrim()
	ExitToGlobal()
end

function OnGrenadeThrow(unit, grID, x, y, z)
	if( (not assasinPlaced) and
		GroupCanSeeUnit(PlayerGetUnits(1),unit)) then
		makeEnemy()
	end	
end

caratelMode = false
function processDelayedEnter()
	if(IsValid(bandits) and (not GroupCanFight(bandits))) then
		bandits = nil
	end
	removeDeadEx()
	startConvoyTricks(1153010)
	if(unitIsActive(zigmund)) then
		generateShop( SH_ZIGMUND, zigmundStuff )
	end	
	if(	((GVWasStartCamp==0) and 
			((GVConvoyQuest==0) or (GVConvoyQuest==CQ_WITHCAR) or
			 (GVConvoyQuest==CQ_FAILED) or (GVConvoyQuest==CQ_DONE))) or

		((GVWasStartCamp==1) and 
			((GVLarryQuest==LQ_NONE) or (GVLarryQuest==LQ_KILLED) or 
			 (GVLarryQuest==LQ_DONED) or (GVLarryQuest==LQ_INPARTY)))) then
		zigmundNeutral = false
	else	
		zigmundNeutral = true
	end
	bandits = PlayerGetUnits(1)
	if(not startCaratel()) then
		if( caratelPlaced and isTimeExpired( "caratelsLeave",true ) ) then 
			GroupRemove( PlayerGetUnits(1) ) 
		end
	else
		caratelMode = true
	end
	initEnemyPlayer(1)
	addPerksToGroup(1)
	if(GVLarryQuest==LQ_DONED) then
		UnitRestoreFromPocket(larry)
		UnitPutWeaponToBackpack(larry )
		WaitForUnit(larry)
		pasteUnit(larry)
	end
	return(true)
end

assasinPlaced=false
function OnEnterZone()
	zigmundShowStore=false
	OnEnterZonePrim( "ForestBand",ZT_FOREST,AT_DUST )
	buzz=GetUnit("buzz")
	larry=GetUnit("larry")
	if(zoneEntered==2) then
		UnitSetCanTalk(sent,true)
	end
	if(zoneEntered>1) then
		if(caratelMode) then
			caratelTricks()
		else
			local zg=false
			if((GVZigmundTrade==1) or (not USNeutral)) then
				SetLootMode(true)
				if(GroupCanFight(PlayerGetUnits(1))) then
					zg=zigfridTalk()
				else
					zg=zigfridRun(2,"zigfrid")
				end
			else
				SetLootMode(false)
				zg=zigfridRun(2,"zigfrid")
			end
			if(not zg) then
				assasinPlaced=placeAssasin(assasinProbability)
			else
				assasinPlaced=false
			end
			if((not assasinPlaced) and
				(not zg)) then
				backgroundDialogs()
			end
		end
	end
    correctAllPlayersHide()
    if((not caratelMode) and unitIsOurs(larry)) then
	local banditsKilled=(not IsValid(bandits)) or (not GroupCanFight(bandits))
	if(not USNeutral) then
		if(banditsKilled) then
			if(GVLarryKnowAboutZigmundDeath==0) then
				GVLarryKnowAboutZigmundDeath=1
				dialogBlockStart(true)
				WaitForUIEx(DialogPlay("larryKnowAboutZigmundDeath"))
				dialogBlockEnd()
			end
		else
			removeFromParty(larry,1)
		end
	end
    end
end

function OnUnitDeath(unit)
	if(IsValid(unit)) then
		local name = UnitGetName(unit)
		if(name=="ZIGMUND") then
			GVSellerQuestState=SQ_ZIGMUNDKILLED
			toJournal(1000014)
		else
			OnUnitDeathPrim(unit)
		end
	end
end

function makeEnemy()
	if((not caratelMode) and USNeutral) then
		USNeutral=false
		SetLootMode(true)
		GVZigmundEnemy=1
		GVZigmundTrade=0
		SetDiplomacy(0,1,DS_ENEMY)
		SetDiplomacy(1,0,DS_ENEMY)
		if( unitIsOurs(larry)) then
			WaitForUIEx(DialogPlay("larryEnemy"))
			removeFromParty(larry,1)
			GroupAddUnit(bandits,larry)
			UnitSetNormalLogic(larry)
			UnitSetCanTalk(larry,false)
		end
		UnitSetCanTalk(sent,false)
		zigmundNeutral=true
		talked[unit]=true
		if(GVLarryQuest==LQ_TAKED) then
			GVLarryQuest=LQ_NONE
		end
		if(unitIsActive(zigmund)) then
			CreateAndActivateItem(zigmund,343)
		end
		return(true)
	end
	return(false)
end

function OnUnitKillUnit(killer,unit)
	OnUnitDamageUnit(killer,unit)
end

function OnMineTriggered( unit )
	if(IsValid(unit) and 
		(not caratelMode) and
		GroupIsContainUnit(bandits,unit)) then
		makeEnemy()
	end
end

function OnUnitDamageUnit(killer,victim)
	if((not caratelMode) and
		GroupIsContainUnit(bandits,victim) and
		GroupIsContainUnit(GetParty(), killer )) then
		makeEnemy()
	end
end

function heroAtArea()
	local ret = (UnitInArea(GetHero(),"g1","g2") and 
		not UnitInArea(GetHero(),"g3","g4"))
	return(ret)	
end

function someAtArea()
	for i=1,GroupGetSize(GetParty())-1 do
		local unit = GroupGetUnit(GetParty(),i)
		if(unitIsActive(unit)) then
			local name = UnitGetName(unit)
			
			if( (name~="LARRY") and 
				(name~="ZIGMUND") and
				UnitInArea(unit,"g1","g2")) then
				return(true)
			end
		end	
	end	
	return(false)
end

function isGroupObtainMap()
	local ret = (HasInventoryItemGroup(GetParty(),MAP_ITEM))
	return(ret)
end

function mapObtained()
out("*** MAP OBTAINED !!!!!!!")
	addZone( "convoy" )
	putTimeMarker( "convoy", 8 )
	GVConvoyQuest = CQ_AVAILABLE
end

talkWithSent = false
function isIntruded()
	if((GVZigmundTrade==1) or zigmundShowStore) then
		return(false)
	else
		local intruded = someAtArea()
		if((not talkWithSent) and (GVTravelWithBandits~=1)) then
			intruded = intruded or heroAtArea()
		else
			intruded = intruded or (heroAtArea() and UnitHasFireArms(GetHero()))
		end
		return(intruded)
	end	
end

sellConst = 0.1
function doZigmundTrade()
	SetMiscConst(GC_SHOPSELLING,sellConst)
--	WaitForUIEx(FadeOut())
--	Sleep(20)
	SetShopMode(true,SH_ZIGMUND,SF_WEAPON+SF_GRENADE+SF_MELEE+SF_ARMOUR+SF_MINE)
	uiShowShop()
--	WaitForUIEx(FadeIn())
end

assasinProbability = 60
sentFirstTalk = true
zigmundFirstTalk = true
zigmundNeutral = false
zigmundShowStore = false
function OnTalk(unit,dest)
	local needDice = false
	if(talkEnabled) then 
		dialogBlockStart(true)
		talkEnabled = false
		local name = UnitGetName(dest)
		if(name=="BANDIT1") then
			DialogPlayAsAcks("bandit1"..random(1,5))
		elseif(name=="BANDIT2") then
			DialogPlayAsAcks("bandit2"..random(1,5))
		elseif((name=="ZIGMUND") and zigmundShowStore) then	
			uiShowStore()
		elseif((name=="ZIGMUND") and zigmundNeutral) then	
			UnitLookAtUnit(dest,unit)
			DialogPlayAsAcks("zigmund"..random(1,5))
		else		
			BeginSequenceEx()
			talked[dest] = true
			UnitPlayAnimation( dest, -1, true, true )
			UnitStop(dest)
			WaitForUnit(dest)
			UnitCancelAction(dest)
			UnitLookAtUnit(unit,dest)
			UnitLookAtUnit(dest,unit)
			WaitForUnit(unit)
			WaitForUnit(dest)
			if(name=="ZIGMUND") then
				if((GVNeedDlgAboutWaterpump==1) and
					(GVZigmundTrade==1) and
					(HasInventoryItemGroup(GetParty(),1320003) or
					HasInventoryItemGroup(GetParty(),1320004)) and
					IsEqual(unit,GetHero())) then
					GVNeedDlgAboutWaterpump = 0
					GVMashinistNotTalked = 0
					WaitForUIEx(DialogPlay("zigmundTalkAboutWaterpump"))
					GVRadioState = RS_WATERPUMP
--					giveXP(2600)
					giveRelativeXP( 0.3 )
					addZone("WStation")
				elseif((GVNeedDlgAboutPrison==1) and
					(GVZigmundTrade==1) and
					IsEqual(unit,GetHero())) then
					GVNeedDlgAboutPrison = 0
					WaitForUIEx(DialogPlay("zigmundPrison"))
--					giveXP(3100)
					giveRelativeXP( 0.3 )
					addZone("Prison")	
				elseif(GVZigmundTrade==1) then	
					doZigmundTrade()
				elseif(GVWasStartCamp==1) then
					if(zigmundFirstTalk) then
						zigmundFirstTalk = false
						WaitForUIEx(DialogPlay("gkZigmundBegin"))
						local ret = 0
						EndSequencePart()
						WaitForUIEx(DialogModeBegin())
						WaitForUIEx( DialogModeSet( 0, 3, 0, 1320743,1320744,1320745 ) )
						ret = GetLastDialogResult()
						if(ret~=0) then
							WaitForUIEx(DialogModeEnd())
						else
							ret = 1	
						end
						if(ret==1) then
							WaitForUIEx(DialogPlay("gkZigmundMed1Good"))
						elseif(ret==2) then
							WaitForUIEx(DialogPlay("gkZigmundMed1Neutral"))
						elseif(ret==3) then
							WaitForUIEx(DialogPlay("gkZigmundMed1Bad"))
							makeEnemy()
							needDice = true
						end
						if(USNeutral) then
							WaitForUIEx(DialogPlay("gkZigmundMed2"))
							EndSequencePart()
							WaitForUIEx(DialogModeBegin())
							WaitForUIEx( DialogModeSet( 0, 2, 0, 1320746,1320747 ) )
							ret = GetLastDialogResult()
							if(ret~=0) then
								WaitForUIEx(DialogModeEnd())
							else
								ret = 1
							end
							if(ret==1) then
								WaitForUIEx(DialogPlay("gkZigmundNo"))
								toJournal(1000074)
								zigmundNeutral = true
							elseif(ret==2) then
								WaitForUIEx(DialogPlay("gkZigmundYes"))
								toJournal(1000073)
								zigmundShowStore = true
								UnitAddToParty(zigmund)
								for i=0, GroupGetSize(GetParty())-2 do
									UnitCreateItem(zigmund,28)	-- M3A1
									UnitCreateItem(zigmund,101)	-- SMG Magazine
								end	
								UnitMoveInventoryToStore( zigmund )
								UnitCreateItem(zigmund,1)
								UnitCreateItem(zigmund,1340062)
								UnitCreateItem(zigmund,515)
								if(unitIsOurs(GetUnit("moshe"))) then
									UnitCreateItem(zigmund,1340063)
								end	
								UnitMoveInventoryToStore( zigmund )
								UnitRemoveFromParty(zigmund,1)
								UnitSetPlayer(zigmund,1)
								UnitCreateItem(zigmund,1)
								zigmundNeutral = true
								GVNeedDlgAboutPrison = 0
								addZone("Prison")
								GVLarryQuest = LQ_TAKED
--								WaitForUIEx(FadeOut())
--								Sleep(20)
								uiShowStore()
--								WaitForUIEx(FadeIn())
							end
						end
					else	
						if(GVLarryQuest == LQ_DONED) then
							WaitForUIEx(DialogPlay("gkZigmundLarryFree"))
							putTimeMarker("larryHire")
							addToParty(larry)
							toJournal(1000016)
							SetDiplomacy(1,14,DS_ENEMY)
							SetDiplomacy(14,1,DS_ENEMY)
							SetDiplomacy(1,0,DS_ALLY)
							SetDiplomacy(0,1,DS_ALLY)	
							sellConst=0.25
							GVZigmundTrade=1
							SetLootMode(true)
							UnitSetCanTalk(sent,false)
							UnitSetCanTalk(zigmund,true,true)
							giveMoney(3500)
							doZigmundTrade()
							giveRelativeXP( 0.8 )
							assasinProbability = 10
							GVLarryQuest = LQ_INPARTY
						elseif(GVLarryQuest == LQ_KILLED) then
							WaitForUIEx(DialogPlay("gkZigmundLarryDied"))
							GVLarryQuest = LQ_FAILED
							zigmundNeutral = true
							UnitSetCanTalk(dest,false)
						end	
					end
				else
					if(zigmundFirstTalk) then
						WaitForUIEx(DialogPlay("zigmund"))
						WaitForUIEx( YesNoDialog(1166061) )
						if(GetLastDialogResult()==1) then
							WaitForUIEx(DialogPlay("zigmundYes"))
							UnitSetCanTalk(larry,true)	
							UnitCreateItem( GetHero(), MAP_ITEM )
							UnitRemoveItem(zigmund,GetItem("map"))
							GVSellerQuestState = SQ_ZIGMUNDLIVE
							toJournal(1000015)
							giveStuff()
						else
							WaitForUIEx(DialogPlay("zigmundNo"))
							makeEnemy()
							needDice = true
						end
						zigmundFirstTalk = false
						zigmundNeutral = true
					elseif(GVConvoyQuest==CQ_WITHCAR) then
						GVSellerQuestState = SQ_TOZIGMUND
						if(getMarker("larryKilled")==1) then
							WaitForUIEx(DialogPlay("zconvoyDoneLarryKilled"))
							giveMoney(3000)
							removeChests()
--							giveXP(4500)
							giveRelativeXP( 0.7 )
							UnitSetCanTalk(dest,false)
							toJournal(1000048)
							GVConvoyQuest = CQ_BADFIN
						else
							WaitForUIEx(DialogPlay("zconvoyDone"))
							GVConvoyQuest = CQ_DONE
							SetDiplomacy(1,14,DS_ENEMY)
							SetDiplomacy(14,1,DS_ENEMY)
							SetDiplomacy(1,0,DS_ALLY)
							SetDiplomacy(0,1,DS_ALLY)	
							sellConst = 0.2
							GVZigmundTrade = 1
							SetLootMode(true)
							UnitSetCanTalk(sent,false)
							UnitSetCanTalk(zigmund,true,true)
							giveMoney(3500)
							doZigmundTrade()
							removeChests()
--							giveXP(6700)
							giveRelativeXP( 0.8 )
							assasinProbability = 10
							toJournal(1000027)
							if(unitIsOurs(larry)) then
								WaitForUIEx(DialogPlay("zconvoyDoneLarry"))
							end
						end	
					elseif(GVConvoyQuest==CQ_FAILED) then
						WaitForUIEx(DialogPlay("zconvoyFail"))
						GVConvoyQuest = CQ_BADFIN
						UnitSetCanTalk(zigmund,false)
					end
				end	
			elseif(name=="LARRY") then
				if(GroupIsContainUnit( bandits, larry)) then
					WaitForUIEx(DialogPlay("larry"))
					addToParty(larry)
					putTimeMarker("larryHire")
					GroupDeleteUnit(bandits,larry)
					UnitSetCanTalk(larry,false)
					toJournal(1000016)
				end	
			elseif(name=="SENT") then
				if(sentFirstTalk) then
					WaitForUIEx(DialogPlay("sent"))
					sentFirstTalk = false
				else		
					WaitForUIEx(DialogPlay("sent1"))
				end	
				talkWithSent = true
				UnitSetCanTalk(sent,false)		
			end
			talked[dest] = false
			EndSequenceEx()
		end	
		talkEnabled = true
		if(needDice) then
			diceForTurn()
		end
		dialogBlockEnd()
	end	
end

function checkBoxDestroy()
	local box1 = GetObject("box1")
	local box2 = GetObject("box2")
	while((ObjectGetDestroyStage(box1)==0) and
		(ObjectGetDestroyStage(box2)==0)) do
		Sleep(20)
	end	
	if((GetDiplomacy(0,1)~=DS_ENEMY) and
		(not caratelMode) and
		(GVZigmundTrade==0)) then
		dialogBlockStart(true)
		if(makeEnemy()) then
			WaitForUIEx(DialogPlay("badopen"))
			diceForTurn()
		end	
		dialogBlockEnd()
	end	
end

openEnabled = true
function OnOpenObject(unit,object)
	if(
--		IsValid(unit) and 
		openEnabled) then
		openEnabled = false
		local on = ObjectGetName(object)
		if(((on=="BOX1") or (on=="BOX2")) and 
			(GetDiplomacy(0,1)~=DS_ENEMY) and
			(not caratelMode) and
--			GroupCanSeeUnit(bandits,unit) and
			GroupCanFight(bandits) and
			(GVZigmundTrade==0)
			) then
			dialogBlockStart(true)
			if(makeEnemy()) then
				WaitForUIEx(DialogPlay("badopen"))
				diceForTurn()
			end	
			dialogBlockEnd()
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
---------------------------------------------------------------------------------------------------------------------
--		else 	
--			if((on=="WINDOW1") and 
--				UnitCanFight(zigmund) and
--				(USNeutral or (not IsRealTime())) ) then
--out("** window opened!")
--				local dlg = { "zigwnd1","zigwnd3","zigwnd3" }
--				DialogPlayAsAcks( dlg[random(1,4)] )
--				UnitMoveToWaypoint(zigmund,"window")
--				WaitForUnitRoute(zigmund)
--				UnitSetDirection(zigmund,DIR_LEFT)
--				WaitForUnit(zigmund)
--				UnitPlayAnimation(zigmund,3819,false)
--				Sleep(10)
--				ObjectClose(object)
--			end
---------------------------------------------------------------------------------------------------------------------
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		end
		openEnabled = true
	end	
end

function waitBanditsRoute()
	UnitMoveToWaypoint(bandit1,"i1")
	UnitMoveToWaypoint(bandit2,"i5")
	WaitForUnitRoute(bandit1)
	WaitForUnitRoute(bandit2)
	if(USNeutral) then
		UnitSetCanTalk(bandit1,true,true)
		UnitSetCanTalk(bandit2,true,true)
		StartThread(controlNPC,bandit1)
		StartThread(controlNPC,bandit2)
	end	
end

function placeBandits()
	if(not caratelMode) then
		dialogBlockStart(true)
		CameraLock(true)
		PlaceTemplate(1330077,"bandits")
		bandit1 = GetUnit("bandit1")
		bandit2 = GetUnit("bandit2")
		GroupAddUnit(bandits,bandit1)
		GroupAddUnit(bandits,bandit2)
		if(GroupGetSize(GetParty())>1) then
			WaitForUIEx(DialogPlay("gkBandits"))
		else	
			WaitForUIEx(DialogPlay("gkBanditsSingle"))
		end	
		CameraLock(false)
		dialogBlockEnd()
	end	
end

--====================================================================================================================================
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function CheckVilage()
	local Units = {}
	local caratel3 = filterGroup(GetGroup(1350453))
	while GroupCanFight( caratel3 ) do
		for i = 0, GroupGetSize( caratel3 ) - 1 do
        	local unit = GroupGetUnit( caratel3, i )
			if( ( unitIsActive(unit) and 
				GetDistance( GetPos( unit ), GetWaypointPos( "playerGroup" ) ) < random( 10, 20 ) ) and 
				(not Units[ unit ])) then
				UnitCancelAction( unit )
				WaitForUnit( unit )
				UnitSetNormalLogic( unit )
				UnitSetPose( unit, POSE_WALK )
				WaitForUnit( unit )
				UnitRoaming( unit, "playerGroup", 40)
				Units[ unit ] = true
			end
		end
		Sleep( 100 )
	end
end

function startCaratel()
	if((GVNeedCaratelPlace==1) and
		(not caratelPlaced)) then
		GVLarryKnowAboutZigmundDeath = 1		
		SetLeaveZoneMode(false,1001383)
		if(not GroupCanFight( PlayerGetUnits(1) )) then
			PlaceTemplate( 1350451, "deadBandTamplaate" )
			UnitKill( GetUnit( "dead1" ) )
			UnitKill( GetUnit( "dead2" ) )
		else
			if IsValid( GetUnit( "sniper" ) ) then 
				UnitRemove( GetUnit( "sniper" ) ) 
			end
			killPlayer(1)
			WaitForPassCalc()
		end
		Sleep(40)
		ObjectOpen( GetObject( "gate" ) )
		return(true)
	end	
	return(false)
end

caratelPlaced = false
function caratelTricks()
	if((GVNeedCaratelPlace==1) and
		(not caratelPlaced)) then
		caratelPlaced = true
		BeginSequenceEx()
		Floor( 2 )
		GroupMoveToWaypoint( GetParty(), "playerGroup" )
		CameraMove( GetCamera( 1350451 ), 5000 )
		WaitForGroupRoute( GetParty() )
		UnitSetDirection( GetHero(), UnitGetDirection( GetHero() ) + 2 )
		WaitForUnit( GetHero() )
		Sleep( 20 )
		UnitSetDirection( GetHero(), UnitGetDirection( GetHero() ) + 2 )
		WaitForUnit( GetHero() )
		Sleep( 20 )
		UnitSetDirection( GetHero(), UnitGetDirection( GetHero() ) + 2 )
		WaitForUnit( GetHero() )
		Sleep( 30 )
		EndSequenceEx()
		dialogBlockStart(true)
		WaitForUIEx(DialogPlay("caratelAlarm"))		
		dialogBlockEnd()
		WantTurnBased( true )
		SleepForTurn( 2 )
		WantTurnBased( false )
		
		-- Vilage desruction
		BeginSequenceEx()
		WaitForUI( FadeOut() )
		Floor( 2 )
		CameraSet( GetCamera( 1350451 ) )
		WaitForUI( FadeIn() )
		CreateUnit( 1065, 1, "Gunner1", "c12", 1 )
		CreateUnit( 1065, 1, "Gunner2", "c22", 1 )
		CreateUnit( 1065, 1, "Gunner3", "Unit6", 1 )
		CreateUnit( 1065, 1, "Gunner4", "c33", 1 )
		CreateUnit( 1070, 1, "Gunner5", "rocketman", 1 )
		UnitSetShootMode( GetUnit( "Gunner1" ), SM_LONGBURST )
		UnitSetShootMode( GetUnit( "Gunner2" ), SM_LONGBURST )
		UnitSetShootMode( GetUnit( "Gunner3" ), SM_LONGBURST )
		UnitSetShootMode( GetUnit( "Gunner4" ), SM_LONGBURST )
		WaitForUnit( GetUnit( "Gunner1" ) )
		WaitForUnit( GetUnit( "Gunner2" ) )
		WaitForUnit( GetUnit( "Gunner3" ) )
		WaitForUnit( GetUnit( "Gunner4" ) )
		UnitSetPose( GetUnit( "Gunner1" ), POSE_RUN )
		UnitSetPose( GetUnit( "Gunner2" ), POSE_RUN )
		UnitSetPose( GetUnit( "Gunner3" ), POSE_RUN )
		UnitSetPose( GetUnit( "Gunner4" ), POSE_RUN )
		UnitSetPose( GetUnit( "Gunner5" ), POSE_RUN )
		WaitForUnit( GetUnit( "Gunner1" ) )
		WaitForUnit( GetUnit( "Gunner2" ) )
		WaitForUnit( GetUnit( "Gunner3" ) )
		WaitForUnit( GetUnit( "Gunner4" ) )
		WaitForUnit( GetUnit( "Gunner5" ) )
		UnitAttackWaypoint( GetUnit( "Gunner1" ), "smoke" )
		UnitAttackWaypoint( GetUnit( "Gunner2" ), "hibara2" )
		UnitAttackWaypoint( GetUnit( "Gunner3" ), "i6" )
		UnitAttackWaypoint( GetUnit( "Gunner4" ), "window3" )
		UnitSetToHit( GetUnit( "Gunner5" ), 80 )
		UnitSetAnimSpeed( GetUnit( "Gunner5" ), 0.1 )
		Sleep( 50 )
		UnitAttackWaypoint( GetUnit( "Gunner5" ), "window3" )
		WaitForUnit( GetUnit( "Gunner5" ) )
		UnitReload( GetUnit( "Gunner5" ) )
		UnitSetToWaypoint( GetUnit( "Gunner5" ), "rocketman_" )
		WaitForUnit( GetUnit( "Gunner5" ) )
		UnitAttackWaypoint( GetUnit( "Gunner5" ), "i5" )
		Sleep( 300 )
		UnitRemove( GetUnit( "Gunner1" ) )
		UnitRemove( GetUnit( "Gunner2" ) )
		UnitRemove( GetUnit( "Gunner3" ) )
		UnitRemove( GetUnit( "Gunner4" ) )
		UnitRemove( GetUnit( "Gunner5" ) )
		EndSequenceEx()
		
		placeCaratel()
		SetLeaveZoneMode( true )
		PlayerGiveTurn( 0 )
	end	
end

function allIsDead()
	local ret = (not GroupCanFight(PlayerGetUnits(1)))
	return(ret)
end

function victory()
	dialogBlockStart(true)
	if(unitIsOurs(GetUnit("larry"))) then
		WaitForUIEx(DialogPlay("caratelLarry"))
	end	
	dialogBlockEnd()
end

function placeCaratel()
	PlaceTemplate(1337015,"c1"..random(1,4))
	PlaceTemplate(1337016,"c2"..random(1,4))
	PlaceTemplate(1337017,"c3"..random(1,4))
	initEnemyPlayer(1)
	addPerksToGroup(1)
	local newLevel = getPlayerLevel( 0 )+1
	boss1 = GetUnit("boss1")
	boss2 = GetUnit("boss2")
	boss3 = GetUnit("boss3")
	UpdateUnitSkills( boss1, newLevel+1, newLevel+DEFAULT_ENEMY_LEVEL )
	UpdateUnitSkills( boss2, newLevel+1, newLevel+DEFAULT_ENEMY_LEVEL )
	UpdateUnitSkills( boss3, newLevel+1, newLevel+DEFAULT_ENEMY_LEVEL )
	SetDiplomacy(0,1,DS_ENEMY)
	SetDiplomacy(1,0,DS_ENEMY)
	local caratels = PlayerGetUnits(1)
	local caratel1 = GetGroup(1350451)
	local caratel2 = GetGroup(1350452)
	local caratel3 = GetGroup(1350453)
	GroupSetWishPose(caratels,POSE_RUN)
	GroupSetPose(caratels,POSE_RUN)
    	GroupSetRoute( caratel1, CreateRoute( "w2", "w3" ), true )
    	GroupSetRoute( caratel2, CreateRoute( "w1", "w4" ), true )
	for i = 0, GroupGetSize( caratel3 ) - 1 do
		local unit = GroupGetUnit( caratel3, i )
		UnitSetSwarmLogic( unit, "playerGroup" )
	end
	StartThread( CheckVilage )
	Trigger(allIsDead,victory)
end

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--====================================================================================================================================

DelayGameStart()
startStandardZone( "ForestBand", ZT_FOREST, AT_DUST )
DividedDeploy("_1")
WaitForGroupRoute(GetParty())
GroupSetDirection(GetParty(),DIR_UP)
WaitForGroup(GetParty())
bandits = PlayerGetUnits(1)
sent = GetUnit("sent")
zigmund = GetUnit("zigmund")
UnitPutWeaponToBackpack(zigmund)
initEnemyPlayer(1)
larry = GetUnit("larry")
UnitSetXPLevel(larry,getPlayerLevel(0)-1)
--itGiveRandomPerks(larry)
UnitTakePerk(larry,58)
UnitTakePerk(larry,38)

mob1 = GetUnit("mob1")
UnitSetCanTalk(sent,true)

UnitSetSkillMaxValue(sent,ST_SPOT,200)
UnitSetSkill(sent,ST_SPOT,200)

UnitSetCanTalk(zigmund,true)
sniper = GetUnit("sniper")
UnitAIMode(sniper,false)
UnitSetWishPose(sniper,POSE_CROUCH)
UnitSetPose(sniper,POSE_CROUCH)
WaitForUnit(sniper)

UnitSetToHit(sniper,GetDifficulty()*33)
UnitSetSkillMaxValue(sniper,ST_SPOT,200)
UnitSetSkill(sniper,ST_SPOT,200)
UnitSetSkillMaxValue(sniper,ST_STEALTH,150)
UnitSetSkill(sniper,ST_STEALTH,150)
Trigger(isIntruded,makeEnemy)
UnitSetSkillMaxValue(mob1,ST_SPOT,200)
UnitSetSkill(mob1,ST_SPOT,200)
UnitLockPose(sniper,true)
UnitHide(sniper)
UnitAIMode(sniper,true)
WaitForUIEx(CameraSet(GetCamera(1000009)))
if(GVWasStartCamp==1) then
	UnitPlaceInPocket(larry)
	ItemRemove(GetItem("map" ))
	if(GVTravelWithBandits==1) then
		StartGameWithSequenceEx()
		placeBandits()
		EndSequenceEx()
		StartThread(waitBanditsRoute)	
		PlayerGiveTurn(1)
	else
		StartGame()	
	end	
else
	UnitTakeObject( zigmund, GetItem("map" ))
	Trigger(isGroupObtainMap,mapObtained)
	StartGame()
end	
UnitSetRoute(mob1,CreateRoute("w1","w2","w3","w4"),1)
UnitRoaming(GetUnit("out1"),"o1",20)
UnitRoaming(GetUnit("out2"),"o2",20)
StartThread( ThreadNPC_Zigmund, zigmund, "zigmund" )
SetLootMode(false)
generateShop( SH_ZIGMUND, zigmundStuff )
StartThread(checkBoxDestroy)
focusCamera(GetHero())
AutoSave()