--
N_WAIT_TIME_TO_SLEEP = 2;
N_WAIT_TIME_TO_SLEEP1 = 1;
G_DelayGameStartFlag = false
---------------------------------------------------------------------------
--
function GroupStop( gr )
	local c = GroupGetSize( gr )
	local i = 0
	for i = 0, c - 1 do
		local unit = GroupGetUnit( gr, i )
		if IsValid( unit ) then
			UnitStop( unit )
		end
	end
end
---------------------------------------------------------------------------
--
function UnitCanFight( unit )
	local a = IsValid( unit ) and ( not ( UnitIsUnconscious( unit ) or UnitIsDead( unit ) ) )
	return a
end
---------------------------------------------------------------------------
--
function WaitForUI( nID )
	if nID == nil then return end
	if G_DelayGameStartFlag then return end

	while IsUIActionIDPresent( nID ) ~= nil do
		Sleep( N_WAIT_TIME_TO_SLEEP )
	end
end
---------------------------------------------------------------------------
--
function CameraSet( camera )
	WaitForUI( CameraMove( camera, 0 ) )
end
---------------------------------------------------------------------------
--
function WaitForUnit( unit )
	Sleep( N_WAIT_TIME_TO_SLEEP );
	while UnitCanFight( unit ) == nil or UnitIsAction( unit ) ~= nil do
		Sleep( N_WAIT_TIME_TO_SLEEP1 );
	end
end
---------------------------------------------------------------------------
--
function WaitForObject( object )
	Sleep( N_WAIT_TIME_TO_SLEEP );
	while ObjectIsAction( object ) ~= nil do
		Sleep( N_WAIT_TIME_TO_SLEEP );
	end
end
---------------------------------------------------------------------------
--
function WaitForPassCalc()
	SlowSyncAIMap()
	Sleep( N_WAIT_TIME_TO_SLEEP );
	while PassCalcerIsActive() do
		Sleep( N_WAIT_TIME_TO_SLEEP );
	end
end
---------------------------------------------------------------------------
--
function SleepForTurn( n )
	local startTurn = GetTurn();
	local k = nil;
	if n == nil then k = 1 else k = n end;
	while ( GetTurn() - startTurn ) < k do
		Sleep( N_WAIT_TIME_TO_SLEEP * 5 );
	end;
end
---------------------------------------------------------------------------
--
function WaitForUnitCommand( unit )
	Sleep( N_WAIT_TIME_TO_SLEEP );
	while UnitIsAction( unit ) == nil do
		Sleep( N_WAIT_TIME_TO_SLEEP );
	end
end
---------------------------------------------------------------------------
--
function WaitForGroup( group )
	local bWait = 1;
	while bWait == 1 do
		Sleep( N_WAIT_TIME_TO_SLEEP );
		bWait = nil;
		for n = 0, ( GroupGetSize( group ) - 1 ) 
		do
			local unit = GroupGetUnit( group, n )
			if unit ~= nil and UnitIsAction( unit ) == 1 then
				bWait = 1;
			end;
		end

	end
end
---------------------------------------------------------------------------
--
function WaitForUnitRoute( unit, bBreakIfDead )
	if IsValid( unit ) then
		local R = UnitGetRoute( unit );
		Sleep( N_WAIT_TIME_TO_SLEEP );
		while IsValid( R ) and ( ( ( not bBreakIfDead ) or UnitCanFight( unit ) ) and RouteIsFinished( R ) == nil ) do
		--while RouteIsFinished( R ) == nil do
			Sleep( N_WAIT_TIME_TO_SLEEP );
		end
	end
end
---------------------------------------------------------------------------
-- ���� bBreakIfDead == TRUE - �� route ��������� �����������, ���� unit ����
--
function WaitForGroupRoute( group, bBreakIfDead )
	local bWait = 1
	local R = {}
	local U = {}
	for n = 0, ( GroupGetSize( group ) - 1 ) 
	do
		local unit = GroupGetUnit( group, n )
		if IsValid( unit ) then
			R[ n ] = UnitGetRoute( unit )
			U[ n ] = unit
		end;
	end
	while bWait == 1 do
		Sleep( N_WAIT_TIME_TO_SLEEP );
		bWait = nil;
		for n = 0, ( GroupGetSize( group ) - 1 ) 
		do
			if IsValid( U[ n ] ) and IsValid( R[ n ] ) then
				if ( ( not bBreakIfDead ) or UnitCanFight( U[ n ] ) ) and RouteIsFinished( R[ n ] ) == nil then
					bWait = 1
				end
			end;
		end

	end
end
---------------------------------------------------------------------------
--
function GroupIsCross( group1, group2 )
	if GroupGetSize( GroupGetCross( group1, group2 ) ) == 0 then
		return FALSE;
	else
		return TRUE;
	end
end
---------------------------------------------------------------------------
--
function UnitCanSee( unit, group )
	local a = GroupIsCross( UnitGetVisible( unit ), group )
	return a
end
---------------------------------------------------------------------------
--
function UnitCanSeeUnit( u1, u2 )
	local a = CreateGroup( UnitGetName(u2) )
	local b = UnitCanSee( u1, a )
	return b
end
---------------------------------------------------------------------------
--
function GroupCanSee( gr1, gr2 )
	local a = GroupIsCross( GroupGetVisible(gr1), gr2 )
	return a
end
---------------------------------------------------------------------------
--
function outGroup( gr )
	local c = GroupGetSize(gr)
	out( "Group size:",c )
	for i = 0, c-1 do
		out( GroupGetUnit( gr, i ) )
	end
end
---------------------------------------------------------------------------
--
function GroupIsDead( gr )
	local c = GroupGetSize(gr)
	for i = 0, c-1 do
		if not UnitIsDead( GroupGetUnit( gr, i ) ) then
			return FALSE
		end
	end
	return TRUE
end
---------------------------------------------------------------------------
--
function GetParty()
	local party = PlayerGetUnits(0)
	return party
end
---------------------------------------------------------------------------
--
function DividedDeploy( variant )
	if variant == nil then variant = "" end
	local party = GetParty()
	GroupStop(party)
	if party == nil then
		out( "DividedDeploy - No Party found!!!" )
		return
	end
	local hero = GetHero()
	if hero == nil then
		out( "DividedDeploy - No Hero found!!!" )
		return
	end
	if UnitCanFight(hero) then
		UnitSetToWaypoint ( hero, "UnitHero"..variant )
	end	
	GroupRemoveUnit( party, hero )
	for i = 1, GroupGetSize(party) do
		local merc = GroupGetUnit ( party, i-1 )
		if merc ~= nil and UnitCanFight(merc) then
			UnitSetToWaypoint( merc, "Unit"..i..variant )
		end
	end
end
---------------------------------------------------------------------------
function DividedDeployDemo( variant )
	if variant == nil then variant = "" end
	local party = GetParty()
	GroupStop(party)
	if party == nil then
		out( "DividedDeploy - No Party found!!!" )
		return
	end
	for i = 1, GroupGetSize(party) do
		local merc = GroupGetUnit ( party, i-1 )
		if merc ~= nil and UnitCanFight(merc) then
			UnitSetToWaypoint( merc, "Unit"..i..variant )
		end
	end
end
---------------------------------------------------------------------------
--
function UnitAIMode( unit, mode )
	UnitCheat( unit, CHEAT_NOAI, not mode )
	Sleep( N_WAIT_TIME_TO_SLEEP )
end
---------------------------------------------------------------------------
--
function GroupAIMode( group, mode )
	local i
	local sza = GroupGetSize( group )
	for i = 0, sza - 1 do
		local u = GroupGetUnit( group, i )
		if(IsValid(u)) then
			UnitAIMode( u, mode )
		end
	end
end
---------------------------------------------------------------------------
--
function BeginSequence( bBlockInput )
	WaitForUI( c_BeginSequence( bBlockInput ) )
end
---------------------------------------------------------------------------
--
function GroupRemove( group )
	for n = 0, ( GroupGetSize( group ) - 1 ) 
	do
		local unit = GroupGetUnit( group, n )
		if(IsValid(unit)) then
			UnitRemove( unit )
		end
	end
end
---------------------------------------------------------------------------
--
function WaitForUnitWaypoint( unit, waypoint, dist )
	if dist == nil then dist = 0.1 end
	local bd = GetDistance( GetPos(unit), GetWaypointPos(waypoint) )
	while bd > dist do
		Sleep(1)
--		out( dist, " - ", bd )
		bd = GetDistance( GetPos(unit), GetWaypointPos(waypoint) )
	end
end
---------------------------------------------------------------------------
--
function UnitReachWaypoint( unit, waypoint, dist )
	if dist == nil then dist = 0.1 end
		bd = GetDistance( GetPos( unit ), GetWaypointPos( waypoint ) )		
		if bd <= dist then 
		return true 
		else return false
	end
end
---------------------------------------------------------------------------
--
function GroupSetDirection( group, direction )
	local sz = GroupGetSize( group )
	local i = 0
	for i = 0, ( sz - 1 ) do
		local unit = GroupGetUnit( group, i )
		UnitSetDirection( unit, direction )
	end
end
---------------------------------------------------------------------------
--
function GetPosition ( var )
	local position = GetPos( var )
	return position
end
---------------------------------------------------------------------------
--
function GroupDeleteUnit( group, unit )
	local temp = CreateGroup()
	GroupAddUnit( temp, unit )
	if GroupIsCross( group, temp ) then
		GroupRemoveUnit( group, unit )
	end
end
---------------------------------------------------------------------------
--
function GroupCanFight( gr )
	local c = GroupGetSize(gr)
	local i
	for i = 0, c-1 do
		local u = GroupGetUnit( gr, i )
		if( IsValid(u) and UnitCanFight( u ) ) then
			return TRUE
		end
	end
	return FALSE
end
---------------------------------------------------------------------------
--
function GroupRoaming( group, wpt, radius )
	local szt = GroupGetSize( group )
	local i
	for i = 0, ( szt - 1 ) do
		local unit = GroupGetUnit( group, i )
		if(IsValid(unit)) then
		        UnitRoaming( unit, wpt, radius )
		end
	end
end
---------------------------------------------------------------------------
--
function GroupCancelAction( group )
	local i
	for i = 0, GroupGetSize( group ) - 1 do
		local unit = GroupGetUnit( group, i )
		if(IsValid(unit)) then
			UnitCancelAction( unit )
		end
	end
end
---------------------------------------------------------------------------
--
function GroupSetPose( group, pose )
	local i
	local sz = GroupGetSize( group )
	for i = 0, sz - 1 do
		local unit = GroupGetUnit( group, i )
		if(IsValid(unit)) then
			UnitSetPose( unit, pose )
		end
	end
	WaitForGroup( group )
end		
---------------------------------------------------------------------------
--
function GroupSetWishPose( group, pose )
	local i
	local sz = GroupGetSize( group )
	for i = 0, sz - 1 do
		local u = GroupGetUnit( group, i )
		if(IsValid(u)) then
			UnitSetWishPose( u, pose )
		end
	end
end		
---------------------------------------------------------------------------
--
function PartyMoveToDeploy( variant )
	if variant == nil then variant = "" end
	local party = GetParty()
	GroupStop(party)
	if party == nil then
		out( "DividedDeploy - No Party found!!!" )
		return
	end
	local hero = GetHero()
	if hero == nil then
		out( "DividedDeploy - No Hero found!!!" )
		return
	end
	if UnitCanFight(hero) then
		UnitMoveToWaypoint( hero, "UnitHero"..variant )
	end	
	GroupRemoveUnit( party, hero )
	for i = 1, GroupGetSize(party) do
		local merc = GroupGetUnit( party, i-1 )
		if merc ~= nil and UnitCanFight(merc) then
			UnitMoveToWaypoint( merc, "Unit"..i..variant )
		end
	end
end
---------------------------------------------------------------------------
--
function OnExit()
	ShowLeaveZoneDialog( 16837 )
	return
end
---------------------------------------------------------------------------
--
function GroupInArea( group, waypoint1, waypoint2 )
	local i
	local sz = GroupGetSize( group )
	for i = 0, sz - 1 do
		local unit = GroupGetUnit( group, i )
		if IsValid(unit) and UnitCanFight( unit ) and ( not UnitInArea( unit, waypoint1, waypoint2 ) ) then
			return FALSE
		end
	end
	return TRUE
end		
---------------------------------------------------------------------------
--
function GroupCanFightSize( group )
	local summ = 0
	for i = 0, GroupGetSize( group ) - 1 do
		local unit = GroupGetUnit( group, i )
		if IsValid(unit) and UnitCanFight(unit) then
			summ = summ + 1
		end
	end
	return summ
end
--------------------------------------------------------------------------
--
function GroupIsWearingPK( group )
	for i = 0, GroupGetSize( group ) - 1 do
		local unit = GroupGetUnit( group, i )
		if IsValid(unit) and UnitIsWearingPK( unit ) then return TRUE end
	end
	return FALSE	
end
---------------------------------------------------------------------------
--
function GroupCanSeeUnit( group, unit )
	local tempgroup = CreateGroup()
	GroupAddUnit( tempgroup, unit )
	if ( GroupCanSee( group, tempgroup ) ) then
		return true
	else
		return false
	end
end
---------------------------------------------------------------------------
--
function GroupKeepMoving( gr )
	local c = GroupGetSize( gr )
	local i = 0
	for i = 0, c - 1 do
		local unit = GroupGetUnit( gr, i )
		if IsValid( unit ) then
			UnitKeepMoving( unit )
		end
	end
end
---------------------------------------------------------------------------
--
function UnitIsHearGroup( unit, group )
	if(IsValid(unit) and IsValid(group)) then
		local c = GroupGetSize( group )
		local i
		for i = 0, c-1 do
			local u = GroupGetUnit( group, i )
			if IsValid(u) and UnitIsHearUnit( unit, u ) then
				return TRUE
			end
		end
	end
	return FALSE
end
---------------------------------------------------------------------------
--
function GiveGoodWeapon( unit )
	UnitCreateItem( unit, 106 )
	UnitCreateItem( unit, 106 )
	UnitCreateItem( unit, 106 )
	UnitCreateItem( unit, 106 )
	UnitCreateItem( unit, 106 )
	CreateAndActivateItem( unit, 39 )
	WaitForUnit( unit )
end
---------------------------------------------------------------------------
--
function GroupActivateWeapon( gr, bActivate )
	local c = GroupGetSize( gr )
	local i = 0
	for i = 0, c - 1 do
		local unit = GroupGetUnit( gr, i )
		if IsValid( unit ) then
			UnitActivateWeapon( unit, bActivate )
		end
	end
end
---------------------------------------------------------------------------
function GroupSwarmToWaypoint( gr, waypoint )
	local c = GroupGetSize( gr )
	local i = 0
	for i = 0, c - 1 do
		local unit = GroupGetUnit( gr, i )
		if IsValid( unit ) then
			UnitSetSwarmLogic( unit, waypoint )
		end
	end
end
---------------------------------------------------------------------------
function DelayGameStartEx()
	c_DelayGameStartEx()
	G_DelayGameStartFlag = true
end
---------------------------------------------------------------------------
function DelayGameStart()
	DelayGameStartEx()
	BeginSequence(true)
end
---------------------------------------------------------------------------
function StartGameEx()
	c_StartGameEx()
	G_DelayGameStartFlag = false
	--
	Sleep( 1 )
end
---------------------------------------------------------------------------
function StartGameWithSequence()
	StartGameEx()
end
---------------------------------------------------------------------------
function StartGame()
	StartGameEx()
	WaitForUI( EndSequence() )
end
---------------------------------------------------------------------------
--
function GroupGiveXP( group, nXP )
	local c = GroupGetSize( group )
	local i = 0
	for i = 0, c - 1 do
		local unit = GroupGetUnit( group, i )
		if IsValid( unit ) then
			UnitGiveXP( unit, nXP )
		end
	end
end
---------------------------------------------------------------------------
--
function OnPlayerLose( bScenarioLose )
	if bScenarioLose == 1 then
		ShowLoseDialog( 20985 )
	else
		ShowLoseDialog( 20984 )
	end
end
--------------------------------------------------------------------------
--
function OnRealExit()
	ExitToChapter()
end
---------------------------------------------------------------------------
--
function DialogPlayWithSequence( dialogID, HeroOnLeft )
	BeginSequence()
	DialogPlay( dialogID, HeroOnLeft )
	EndSequence()
end
---------------------------------------------------------------------------
--
function Message( stringID )
	WaitForUI( DialogModeBegin() )
out('1')
	WaitForUI( DialogModeSet( stringID, 0, 0 ) )
out('2')
	if GetLastDialogResult() == 0 then
		return
	end
out('3')
	WaitForUI( DialogModeEnd() )
out('4')
end
---------------------------------------------------------------------------
--
function OnWeaponBroken( unit, jm, br )
	local x = GetGlobalGameVar( "JAMMEDWEP", 0 )
	local y = GetGlobalGameVar( "BROKENWEP", 0 )
	if jm == 1 then
		if x == "0" then
			SetGlobalGameVar( "JAMMEDWEP", "1" )
			Sleep(40)
			ShowHint( 153 )
		end
	end
	if br == 1 then
		if y == "0" then
			SetGlobalGameVar( "BROKENWEP", "1" )
			Sleep(40)
			ShowHint( 152 )
		end
	end
end
---------------------------------------------------------------------------
--
out( "Common functions were loaded" )
