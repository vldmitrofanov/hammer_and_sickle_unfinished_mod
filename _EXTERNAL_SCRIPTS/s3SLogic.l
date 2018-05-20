function OnWeaponBroken( unit, jm, br )
	if(not GroupIsContainUnit( GetParty(), unit )) then
		if(UnitIsUsingCannon(unit)) then
out("*** CANNON JAMMED OR BROKEN!")
			UnitAttachToCannon(unit,nil,false)
		elseif(jm==1) then
out("*** WEAPON JAMMED!")
			local slot = UnitGetActiveSlot( unit )
			local item = UnitGetSlotItem( unit, slot )
       			if(not isItemFirearm(item)) then
       				trueDrawWeapon(unit)
				slot = UnitGetActiveSlot( unit )
				item = UnitGetSlotItem( unit, slot )
			end
			if(isItemFirearm(item) and ItemIsJammed( item )) then
				local skill = UnitGetSkill(unit,ST_ENGINEERING)
				UnitWeaponRepairJammed(unit,skill)
				WaitForUnit(unit)
				if(ItemIsJammed( item )) then
out("*** WEAPON NOT REPAIRED, SKILL ",skill)
					unitSetMelee(unit)
				end
			else
				unitSetMelee(unit)		
			end
		elseif(br==1) then
out("*** WEAPON BROKEN!")
			unitSetMelee(unit)
		end
	end
end

-- Создаёт в рюкзаке юнита патроны соответствующие оружию в руках
-- Второй параметр тип патронов/снарядов:
-- type = 0 - обычные
-- type = 1 - бронебойные
-- type = 2 - JHP
-- type = 3 - специальные

function CreateAmmo( unit, type )
	local item = nil
	if(UnitIsUsingCannon(unit)) then
		item = UnitGetCannonItem( unit )	
	        if(ItemIsJammed( item ) or ItemIsBroken( item )) then
			UnitAttachToCannon(unit,nil,false)
			return(true)
		end
	else
		if( not UnitIsWeaponInHand( unit, WP_NORMAL )) then
			return(true)
		end
		local slot = UnitGetActiveSlot( unit )
		item = UnitGetSlotItem( unit, slot )
		if(ItemIsJammed( item )) then
			local skill = UnitGetSkill(unit,ST_ENGINEERING)
			UnitWeaponRepairJammed(unit,skill)
			WaitForUnit(unit)
			if(ItemIsJammed( item )) then
                        out("*** weapon is jammed")
				return(false)
			end
		elseif(ItemIsBroken( item )) then
                        out("*** weapon is broken")
			return(false)
		end
	end
	local WeaponID = ItemGetID( item )
	local AmmoID = nil
	if(type==nil) then
		AmmoID = ClipForWeapon[ WeaponID ]
	elseif(type == 1) then 
		AmmoID = ClipForWeaponRED[ WeaponID ]
	elseif(type == 2) then 
		AmmoID = ClipForWeaponJHP[ WeaponID ]
	elseif(type == 3) then 
		AmmoID = ClipForWeaponSpecial[ WeaponID ]
	else 
		AmmoID = ClipForWeapon[ WeaponID ]
	end
	if( AmmoID == nil ) then
		out("*** Bad AmmoID for WeaponID ",WeaponID)
		return(false)
	end
	if( not HasInventoryItemUnit( unit, AmmoID ) ) then 
		UnitCreateItem( unit, AmmoID, false )
		out( "WeaponID = ", WeaponID, " > AmmoID = ", AmmoID )
	end
	return(true)
end

ClipForWeapon = {}
ClipForWeaponRED = {}
ClipForWeaponJHP = {}
ClipForWeaponSpecial = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--			ID			ID		Name Weapon							Name Clip
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ClipForWeapon	[	1	]	=	74	--	Colt M1911						>>>	Colt M1911 Pistol Clip
ClipForWeapon	[	2	]	=	75	--	Luger (British)						>>>	Luger P08 8-round Pistol Clip 
ClipForWeapon	[	3	]	=	76	--	Luger P-08 (Parabellum)					>>>	Parabellum 8-round Pistol Clip
ClipForWeapon	[	4	]	=	77	--	Sauer 38Х						>>>	Sauer 38X Pistol Clip
ClipForWeapon	[	5	]	=	78	--	Walther P-38						>>>	Walther P38 8-round Pistol Clip
ClipForWeapon	[	6	]	=	79	--	TT 1933							>>>	ТТ Pistol Clip
ClipForWeapon	[	7	]	=	81	--	Mauser К-96 1926					>>>	Mauser M.712 20-round Pistol Clip
ClipForWeapon	[	8	]	=	82	--	Mauser К-96 1912					>>>	Mauser 1912 10-round Clip for Parabellum Cartrid
ClipForWeapon	[	9	]	=	81	--	Mauser M.712						>>>	Mauser M.712 20-round Pistol Clip
ClipForWeapon	[	10	]	=	83	--	Webley Scott "Army express"				>>>	Speedloader for Six .38 rounds
ClipForWeapon	[	11	]	=	84	--	Nagant Revolver 1910					>>>	Nagant 1896 Cartridges
ClipForWeapon	[	12	]	=	85	--	Mauser 33/40 Rifle					>>>	Mauser 5-round Rifle Clip
ClipForWeapon	[	13	]	=	86	--	Mosin 1891/1930 Rifle					>>>	Mosin Rifle Clip
ClipForWeapon	[	14	]	=	86	--	Mosin 38 Carbine					>>>	Mosin Rifle Clip
ClipForWeapon	[	15	]	=	87	--	Lee-Enfield N4 Mk1					>>>	Lee-Enfiled 10-round Rifle Clip 
ClipForWeapon	[	16	]	=	88	--	M1 Carbine 1936						>>>	M-1 Carbine Clip
ClipForWeapon	[	17	]	=	85	--	Mauser 98К Carbine (Scoped version)			>>>	Mauser 5-round Rifle Clip
ClipForWeapon	[	18	]	=	89	--	Springfield M1917 (Scoped version)			>>>	Springfield M1917 Rifle Clip
ClipForWeapon	[	19	]	=	90	--	AVS-36							>>>	AVS-36 Rifle Clip
ClipForWeapon	[	20	]	=	91	--	SVT-40 Rifle						>>>	SVT- 40  Rifle Clip
ClipForWeapon	[	21	]	=	93	--	FG42							>>>	FG42 Rifle Clip
ClipForWeapon	[	22	]	=	85	--	Walther G-41W Rifle					>>>	Mauser 5-round Rifle Clip
ClipForWeapon	[	23	]	=	94	--	MAS 36 Rifle						>>>	MAS Rifle Clip 
ClipForWeapon	[	24	]	=	85	--	Mauser M98 Rifle (Polish)				>>>	Mauser 5-round Rifle Clip
ClipForWeapon	[	25	]	=	85	--	Mauser M29 Rifle (Polish)				>>>	Mauser 5-round Rifle Clip
ClipForWeapon	[	26	]	=	97	--	Thompson_M1						>>>	Thompson M1 SMG 100-round Cartridge Drum
ClipForWeapon	[	27	]	=	99	--	Thompson_1928						>>>	Thompson 1928 SMG 30-round Magazine 
ClipForWeapon	[	28	]	=	101	--	M3A1							>>>	М3А1 SMG Magazine
ClipForWeapon	[	29	]	=	102	--	Sten_MkII						>>>	Sten SMG 32-round Magazine 
ClipForWeapon	[	30	]	=	102	--	Sten_MkIV						>>>	Sten SMG 32-round Magazine 
ClipForWeapon	[	31	]	=	102	--	Sten_MkV						>>>	Sten SMG 32-round Magazine 
ClipForWeapon	[	32	]	=	102	--	Sten_MkIII						>>>	Sten SMG 32-round Magazine 
ClipForWeapon	[	34	]	=	103	--	PPSH41							>>>	PPSH/PPD SMG Cartridge Drum
ClipForWeapon	[	35	]	=	104	--	PPSH41_modified						>>>	PPShm/PPS SMG Magazine
ClipForWeapon	[	36	]	=	104	--	PPS42							>>>	PPShm/PPS SMG Magazine
ClipForWeapon	[	37	]	=	104	--	PPS43							>>>	PPShm/PPS SMG Magazine
ClipForWeapon	[	38	]	=	105	--	MP40							>>>	MP40 SMG 32-round Magazine 
ClipForWeapon	[	39	]	=	106	--	MP43							>>>	STG43 SMG Magazine
ClipForWeapon	[	40	]	=	105	--	MP28_Bergmann						>>>	MP40 SMG 32-round Magazine 
ClipForWeapon	[	41	]	=	109	--	MG34							>>>	MG34 Boxed Cartridge Belt
ClipForWeapon	[	42	]	=	109	--	MG42							>>>	MG34 Boxed Cartridge Belt
ClipForWeapon	[	43	]	=	110	--	DP							>>>	DP Cartridge Drum
ClipForWeapon	[	44	]	=	111	--	RPD							>>>	RPD Boxed Cartridge Belt
ClipForWeapon	[	45	]	=	112	--	Bren							>>>	Bren Machine-Gun Magazine
ClipForWeapon	[	47	]	=	115	--	ZB_26_30						>>>	ZB26/30 Magazine
ClipForWeapon	[	48	]	=	116	--	Chattelraut M1924/1929					>>>	Chatellerault Machine-Gun Magazine
ClipForWeapon	[	49	]	=	117	--	Garand M1 Rifle						>>>	Garand М1 Shells
ClipForWeapon	[	57	]	=	113	--	Browning_M1922						>>>	Browning M1922 Magazine
ClipForWeapon	[	64	]	=	132	--	Vickers 12.7-mm						>>>	Vickers 12.7 Boxed Cartridge Belt
ClipForWeapon	[	158	]	=	441	--	Beretta_M1938A						>>>	Beretta SMG Magazine
ClipForWeapon	[	159	]	=	441	--	Beretta_M38_42						>>>	Beretta SMG Magazine
ClipForWeapon	[	160	]	=	105	--	MP38							>>>	MP40 SMG 32-round Magazine 
ClipForWeapon	[	161	]	=	105	--	MP40_2							>>>	MP40 SMG 32-round Magazine 
ClipForWeapon	[	162	]	=	437	--	Suomi							>>>	Suomi SMG Cartridge Drum
ClipForWeapon	[	163	]	=	103	--	PPD40							>>>	PPSH/PPD SMG Cartridge Drum
ClipForWeapon	[	171	]	=	85	--	Walther G-41W Rifle (Scoped version)			>>>	Mauser 5-round Rifle Clip
ClipForWeapon	[	172	]	=	117	--	Garand M1 Rifle (Scoped version)			>>>	Garand М1 Shells
ClipForWeapon	[	173	]	=	87	--	Lee-Enfield N4 Mk1 Rifle (Scoped version)		>>>	Lee-Enfiled 10-round Rifle Clip 
ClipForWeapon	[	174	]	=	372	--	Manlicher-Carcano M38 Rifle				>>>	Manlicher-Carcano M38 Rifle Clip
ClipForWeapon	[	175	]	=	373	--	Manlicher-Carcano M91/24 Rifle (Scoped version)		>>>	Manlicher-Carcano M91 Rifle Clip
ClipForWeapon	[	176	]	=	86	--	Mosin 1891/1930 Rifle (Scoped version)			>>>	Mosin Rifle Clip
ClipForWeapon	[	177	]	=	91	--	SVT-40 Rifle (Scoped version)				>>>	SVT- 40  Rifle Clip
ClipForWeapon	[	180	]	=	181	--	Panzerschrek						>>>	Panzerschrek Rocket
ClipForWeapon	[	182	]	=	184	--	Bazooka_M1						>>>	Bazooka Rocket
ClipForWeapon	[	183	]	=	185	--	PIAT							>>>	PIAT Rocket
ClipForWeapon	[	190	]	=	191	--	Panzerfaust						>>>	Panzerfaust Rocket
ClipForWeapon	[	211	]	=	418	--	PK_MG FF						>>>	PK_MGFF_Clip
ClipForWeapon	[	212	]	=	419	--	PK_MK 108						>>>	PK_MK108_Clip
ClipForWeapon	[	213	]	=	417	--	PK_MG81Z						>>>	PK_MG81Z_Clip
ClipForWeapon	[	214	]	=	422	--	PK_PZB41						>>>	PK_PZB41_Clip
ClipForWeapon	[	215	]	=	420	--	PK_MSS41						>>>	PK_MSS41_Clip
ClipForWeapon	[	217	]	=	132	--	PK_Vickers 12.7 mm					>>>	Vickers 12.7 Boxed Cartridge Belt
ClipForWeapon	[	218	]	=	185	--	PK_PIAT							>>>	PIAT Rocket
ClipForWeapon	[	219	]	=	424	--	PK_SHKAS						>>>	PK_SHKAS_Clip
ClipForWeapon	[	220	]	=	423	--	PK_PTRS (Snipe)						>>>	PK_PTRS_Sniper_Clip
ClipForWeapon	[	221	]	=	421	--	PK_PTR_Boys						>>>	PK_PTR_Boys_Clip
ClipForWeapon	[	222	]	=	383	--	PK_DShK							>>>	DShk Boxed Cartridge Belt
ClipForWeapon	[	223	]	=	224	--	PK_AGS 17						>>>	PK_AGSClip
ClipForWeapon	[	225	]	=	226	--	PK_Gatling 12 mm					>>>	PK_GatlingClip
ClipForWeapon	[	227	]	=	363	--	PK_LasGun						>>>	LZ-SystemClip
ClipForWeapon	[	298	]	=	379	--	Stun Pistol						>>>	Stuning Dart
ClipForWeapon	[	299	]	=	379	--	Stun rifle						>>>	Stuning Dart
ClipForWeapon	[	343	]	=	105	--	MP41							>>>	MP40 SMG 32-round Magazine 
ClipForWeapon	[	344	]	=	102	--	Sten_MkIII_Silencer					>>>	Sten SMG 32-round Magazine 
ClipForWeapon	[	345	]	=	84	--	Nagant Revolver (Silenced version)			>>>	Nagant 1896 Cartridges
ClipForWeapon	[	346	]	=	82	--	Mauser К-96 1912 (Silenced version)			>>>	Mauser 1912 10-round Clip for Parabellum Cartrid
ClipForWeapon	[	347	]	=	105	--	MP41_Silencer						>>>	MP40 SMG 32-round Magazine 
ClipForWeapon	[	348	]	=	101	--	M3A1_Silencer						>>>	М3А1 SMG Magazine
ClipForWeapon	[	349	]	=	76	--	Welrod Mk1 (Silenced)					>>>	Parabellum 8-round Pistol Clip
ClipForWeapon	[	350	]	=	74	--	DeLizl Carbine						>>>	Colt M1911 Pistol Clip
ClipForWeapon	[	351	]	=	85	--	Mauser 98К Carbine (Scoped and Silenced version)	>>>	Mauser 5-round Rifle Clip
ClipForWeapon	[	352	]	=	377	--	LittleJoe						>>>	LittleJoe_Clip
ClipForWeapon	[	353	]	=	441	--	Beretta_M1938A_Silencer					>>>	Beretta SMG Magazine
ClipForWeapon	[	354	]	=	384	--	Flak38 20-mm Cannon					>>>	Flak38 Magazine
ClipForWeapon	[	355	]	=	383	--	DShK 12.7-mm (Tripod Mounted)				>>>	DShk Boxed Cartridge Belt
ClipForWeapon	[	356	]	=	385	--	MG-34 (Tripod Mounted)					>>>	MG34 Boxed Cartridge Belt (Tripod Mounted version
ClipForWeapon	[	357	]	=	469	--	BHLG-1Z							>>>	OLD PK_LZ-SystemClip
ClipForWeapon	[	364	]	=	469	--	TLG-3							>>>	OLD PK_LZ-SystemClip
ClipForWeapon	[	378	]	=	376	--	Colt M1911 "BigJoe"					>>>	Colt_M1911_BigJoe_Clip
ClipForWeapon	[	382	]	=	381	--	SeaDevil (Scoped version)				>>>	Sea Devil Rifle Clip
ClipForWeapon	[	434	]	=	363	--	PK_LasGun_Helena					>>>	LZ-SystemClip
ClipForWeapon	[	442	]	=	385	--	Zundapp_MG34						>>>	MG34 Boxed Cartridge Belt (Tripod Mounted version
ClipForWeapon	[	461	]	=	85	--	Mauser 33/40 Rifle (Scoped version)			>>>	Mauser 5-round Rifle Clip
ClipForWeapon	[	467	]	=	468	--	Prototype8M1						>>>	Prototype8M1Clip
ClipForWeapon	[	489	]	=	488	--	LewisMk1						>>>	LewisMk1Magazine
ClipForWeapon	[	490	]	=	503	--	Browning HP						>>>	BrowningHPClip
ClipForWeapon	[	491	]	=	504	--	Colt Detective Special .38 S&W				>>>	Colt_38_SpecialClip
ClipForWeapon	[	492	]	=	505	--	SKS45							>>>	SKS45Clip
ClipForWeapon	[	493	]	=	506	--	M1941 JohnsonRifle					>>>	M1941_JohnsonRifleClip
ClipForWeapon	[	494	]	=	507	--	AK47							>>>	AK47Clip
ClipForWeapon	[	495	]	=	508	--	TKB408							>>>	TKB408Clip
ClipForWeapon	[	496	]	=	509	--	Sterling_Patchett					>>>	Sterling_Patchett_Clip
ClipForWeapon	[	497	]	=	509	--	Sterling_Patchett_Para					>>>	Sterling_Patchett_Clip
ClipForWeapon	[	498	]	=	509	--	Sterling_Patchett_Silencer				>>>	Sterling_Patchett_Clip
ClipForWeapon	[	499	]	=	502	--	M1941_JohnsonLightGun					>>>	M1941_JohnsonLightGunClip
ClipForWeapon	[	500	]	=	510	--	M20_Bazooka						>>>	M20_BazookaShell
ClipForWeapon	[	511	]	=	106	--	Volksgewehr45						>>>	STG43 SMG Magazine
ClipForWeapon	[	513	]	=	422	--	PK_RoboGunPZB41						>>>	PK_PZB41_Clip
ClipForWeapon	[	516	]	=	417	--	PK_RoboGunMG81Z						>>>	PK_MG81Z_Clip
ClipForWeapon	[	572	]	=	89	--	Springfield M1917					>>>	Springfield M1917 Rifle Clip
ClipForWeapon	[	573	]	=	506	--	M1941 JohnsonRifle_sniper				>>>	M1941_JohnsonRifleClip
ClipForWeapon	[	574	]	=	505	--	SKS45_sniper						>>>	SKS45Clip
ClipForWeapon	[	669	]	=	93	--	FG42Sniper						>>>	FG42 Rifle Clip
ClipForWeapon	[	670	]	=	673	--	Samopal25						>>>	CZ M25 Clip
ClipForWeapon	[	1156103	]	=	1156101	--	APS_(Stechkin)						>>>	APS_Clip
ClipForWeapon	[	1156104	]	=	1156102	--	MAT-49							>>>	MAT-49_Clip

ClipForWeaponJHP	[	1	]	=	584	--	Colt M1911				>>>	Colt M1911 Pistol Clip JHP
ClipForWeaponJHP	[	2	]	=	586	--	Luger (British)				>>>	Luger P08 8-round Pistol Clip  JHP
ClipForWeaponJHP	[	3	]	=	591	--	Luger P-08 (Parabellum)			>>>	Parabellum 8-round Pistol Clip JHP
ClipForWeaponJHP	[	4	]	=	592	--	Sauer 38Х				>>>	Sauer 38X Pistol Clip JHP
ClipForWeaponJHP	[	5	]	=	594	--	Walther P-38				>>>	Walther P38 8-round Pistol Clip JHP
ClipForWeaponJHP	[	6	]	=	582	--	TT 1933					>>>	ТТ Pistol Clip JHP
ClipForWeaponJHP	[	7	]	=	589	--	Mauser К-96 1926			>>>	Mauser M.712 20-round Pistol Clip JHP
ClipForWeaponJHP	[	8	]	=	587	--	Mauser К-96 1912			>>>	Mauser 1912 10-round Clip JHP for Parabellum Cart
ClipForWeaponJHP	[	9	]	=	589	--	Mauser M.712				>>>	Mauser M.712 20-round Pistol Clip JHP
ClipForWeaponJHP	[	10	]	=	593	--	Webley Scott "Army express"		>>>	Speedloader for Six .38 rounds JHP
ClipForWeaponJHP	[	11	]	=	590	--	Nagant Revolver 1910			>>>	Nagant 1896 Cartridges JHP
ClipForWeaponJHP	[	21	]	=	614	--	FG42					>>>	FG42 Rifle Clip JHP
ClipForWeaponJHP	[	26	]	=	608	--	Thompson_M1				>>>	Thompson M1 SMG 100-round Cartridge Drum JHP
ClipForWeaponJHP	[	27	]	=	607	--	Thompson_1928				>>>	Thompson 1928 SMG 30-round Magazine  JHP
ClipForWeaponJHP	[	28	]	=	612	--	M3A1					>>>	М3А1 SMG Magazine JHP
ClipForWeaponJHP	[	29	]	=	601	--	Sten_MkII				>>>	Sten SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	30	]	=	601	--	Sten_MkIV				>>>	Sten SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	31	]	=	601	--	Sten_MkV				>>>	Sten SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	32	]	=	601	--	Sten_MkIII				>>>	Sten SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	34	]	=	599	--	PPSH41					>>>	PPSH/PPD SMG Cartridge Drum JHP
ClipForWeaponJHP	[	35	]	=	600	--	PPSH41_modified				>>>	PPShm/PPS SMG Magazine JHP
ClipForWeaponJHP	[	36	]	=	600	--	PPS42					>>>	PPShm/PPS SMG Magazine JHP
ClipForWeaponJHP	[	37	]	=	600	--	PPS43					>>>	PPShm/PPS SMG Magazine JHP
ClipForWeaponJHP	[	38	]	=	598	--	MP40					>>>	MP40 SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	39	]	=	603	--	MP43					>>>	STG43 SMG Magazine JHP
ClipForWeaponJHP	[	40	]	=	598	--	MP28_Bergmann				>>>	MP40 SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	158	]	=	596	--	Beretta_M1938A				>>>	Beretta SMG Magazine JHP
ClipForWeaponJHP	[	159	]	=	596	--	Beretta_M38_42				>>>	Beretta SMG Magazine JHP
ClipForWeaponJHP	[	160	]	=	598	--	MP38					>>>	MP40 SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	161	]	=	598	--	MP40_2					>>>	MP40 SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	162	]	=	604	--	Suomi					>>>	Suomi SMG Cartridge Drum JHP
ClipForWeaponJHP	[	163	]	=	599	--	PPD40					>>>	PPSH/PPD SMG Cartridge Drum JHP
ClipForWeaponJHP	[	343	]	=	598	--	MP41					>>>	MP40 SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	344	]	=	601	--	Sten_MkIII_Silencer			>>>	Sten SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	345	]	=	590	--	Nagant Revolver (Silenced version)	>>>	Nagant 1896 Cartridges JHP
ClipForWeaponJHP	[	346	]	=	587	--	Mauser К-96 1912 (Silenced version)	>>>	Mauser 1912 10-round Clip JHP for Parabellum Cart
ClipForWeaponJHP	[	347	]	=	598	--	MP41_Silencer				>>>	MP40 SMG 32-round Magazine  JHP
ClipForWeaponJHP	[	348	]	=	612	--	M3A1_Silencer				>>>	М3А1 SMG Magazine JHP
ClipForWeaponJHP	[	349	]	=	591	--	Welrod Mk1 (Silenced)			>>>	Parabellum 8-round Pistol Clip JHP
ClipForWeaponJHP	[	353	]	=	596	--	Beretta_M1938A_Silencer			>>>	Beretta SMG Magazine JHP
ClipForWeaponJHP	[	490	]	=	583	--	Browning HP				>>>	BrowningHPClip JHP
ClipForWeaponJHP	[	491	]	=	585	--	Colt Detective Special .38 S&W		>>>	Colt_38_SpecialClip JHP
ClipForWeaponJHP	[	494	]	=	595	--	AK47					>>>	AK47Clip JHP
ClipForWeaponJHP	[	495	]	=	611	--	TKB408					>>>	TKB408Clip JHP
ClipForWeaponJHP	[	496	]	=	602	--	Sterling_Patchett			>>>	Sterling_Patchett_Clip JHP
ClipForWeaponJHP	[	497	]	=	602	--	Sterling_Patchett_Para			>>>	Sterling_Patchett_Clip JHP
ClipForWeaponJHP	[	498	]	=	602	--	Sterling_Patchett_Silencer		>>>	Sterling_Patchett_Clip JHP
ClipForWeaponJHP	[	511	]	=	603	--	Volksgewehr45				>>>	STG43 SMG Magazine JHP
--ClipForWeaponJHP	[	669	]	=	614	--	FG42Sniper				>>>	FG42 Rifle Clip JHP
ClipForWeaponJHP	[	670	]	=	674	--	Samopal25				>>>	CZ M25 ClipJHP

ClipForWeaponRED	[	180	]	=	545	--	Panzerschrek	>>>	Panzerschrek Rocket Red
ClipForWeaponRED	[	182	]	=	542	--	Bazooka_M1	>>>	Bazooka Rocket Red
ClipForWeaponRED	[	183	]	=	546	--	PIAT		>>>	PIAT Rocket Red
ClipForWeaponRED	[	190	]	=	544	--	Panzerfaust	>>>	Panzerfaust Rocket Red
ClipForWeaponRED	[	218	]	=	546	--	PK_PIAT		>>>	PIAT Rocket Red
ClipForWeaponRED	[	500	]	=	543	--	M20_Bazooka	>>>	M20 Bazooka rocket Red

ClipForWeaponSpecial	[	227	]	=	622	--	PK_LasGun		>>>	LZ-SystemMegaClip
ClipForWeaponSpecial	[	357	]	=	363	--	BHLG-1Z			>>>	LZ-SystemClip
ClipForWeaponSpecial	[	364	]	=	363	--	TLG-3			>>>	LZ-SystemClip
ClipForWeaponSpecial	[	434	]	=	622	--	PK_LasGun_Helena	>>>	LZ-SystemMegaClip
ClipForWeaponSpecial	[	467	]	=	622	--	Prototype8M1		>>>	LZ-SystemMegaClip

function UnitGetVisibleEx( unit )
	local enemyVisible = CreateGroup()
	local player = UnitGetPlayer(unit)
	for i=0,15 do
		if(GetDiplomacy(player,i)==DS_ENEMY) then
			local group = PlayerGetUnits(i)
			for j = 0, GroupGetSize( group ) - 1 do
				local target = GroupGetUnit( group, j )		
				if(IsValid(target) and UnitCanFight(target) and UnitCanSeeUnit(unit,target)) then
					GroupAddUnit(enemyVisible,target)
				end
			end
		end
	end
	return(enemyVisible)
end

function UnitGetHear( unit )
	local enemyHeared = CreateGroup()
	local player = UnitGetPlayer(unit)
	for i=0,15 do
		if(GetDiplomacy(player,i)==DS_ENEMY) then
			local group = PlayerGetUnits(i)
			for j = 0, GroupGetSize( group ) - 1 do
				local target = GroupGetUnit( group, j )		
				if(IsValid(target) and UnitCanFight(target) and UnitIsHearUnit(unit,target)) then
					GroupAddUnit(enemyHeared,target)
				end
			end
		end
	end
	return(enemyHeared)
end

function PlayerGetVisibleEx( player )
	local enemyVisible = CreateGroup()
	playerGroup = PlayerGetUnits(player)
	for i=0,15 do
		if(GetDiplomacy(player,i)==DS_ENEMY) then
			local group = PlayerGetUnits(i)
			for k=0, GroupGetSize(playerGroup) - 1 do
				local unit = GroupGetUnit( playerGroup, k )
				if(unitIsActive(unit)) then
					for j = 0, GroupGetSize( group ) - 1 do
						local target = GroupGetUnit( group, j )		
						if(IsValid(target) and UnitCanFight(target) and UnitCanSeeUnit(unit,target)) then
							GroupAddUnit(enemyVisible,target)
						end
					end
				end
			end
		end
	end
	return(enemyVisible)
end

function PlayerGetHear( player )
	local enemyHeared = CreateGroup()
	playerGroup = PlayerGetUnits(player)
	for i=0,15 do
		if(GetDiplomacy(player,i)==DS_ENEMY) then
			local group = PlayerGetUnits(i)
			for k=0, GroupGetSize(playerGroup) - 1 do
				local unit = GroupGetUnit( playerGroup, k )
				if(unitIsActive(unit)) then
					for j = 0, GroupGetSize( group ) - 1 do
						local target = GroupGetUnit( group, j )		
						if(IsValid(target) and UnitCanFight(target) and UnitIsHearUnit(unit,target)) then
							GroupAddUnit(enemyHeared,target)
						end
					end
				end
			end
		end
	end
	return(enemyHeared)
end

function unitGetPlayer(unit)
	for i=1,15 do
		local group = PlayerGetUnits(i)
		if(GroupIsContainUnit( group, unit )) then
			return(i)
		end
	end
	return(0)
end

function getNearestFromUnit(unit,group,notEqual)
	local minDistTarget = nil
	if(IsValid(group)) then
		local pos = GetPos(unit)
		local minDist = 1000000
		for i = 0, GroupGetSize( group ) - 1 do
			local target = GroupGetUnit( group, i )
			if(     unitIsActive( target ) and
				(not IsEqual(target,unit))) then
				local tPos = GetPos(target)
				if((notEqual~=nil) and (random(100)<15)) then
					return(target)
				end	
				local dist = GetDistance(pos,tPos)
				if(dist<minDist) then
					minDist = dist
					minDistTarget = target
				end	
			end
		end
	end
	return(minDistTarget)
end

function getNearestVisibleByUnit(unit)
	local victim = getNearestFromUnit(unit,UnitGetVisibleEx( unit ))
	return(victim)
end

function getNearestHearByUnit(unit)
	local victim = getNearestFromUnit(unit,UnitGetHear( unit ))
	return(victim)
end

function getNearestVisibleByGroup(unit)
	local victim = nil
	local player = UnitGetPlayer(unit)
	if(player~=0) then
		victim = getNearestFromUnit(unit,PlayerGetVisibleEx( player ))
	end
	return(victim)
end

function getNearestHearByGroup(unit)
	local victim = nil
	local player = UnitGetPlayer(unit)
	if(player~=0) then
		victim = getNearestFromUnit(unit,PlayerGetHear( player ))
	end
	return(victim)
end

function OptimalShot( MinPercent, unit , target )
	local percent = UnitGetToHitUnit( unit, target, HL_HEAD )
	local part = HL_HEAD
	if percent < MinPercent then
		percent = UnitGetToHitUnit( unit, target, HL_LHAND )
		part = HL_LHAND
		if percent < MinPercent then
			percent = UnitGetToHitUnit( unit, target, HL_RHAND )
			part = HL_RHAND
			if percent < MinPercent then
				percent = UnitGetToHitUnit( unit, target, HL_LLEG )
				part = HL_LLEG
				if percent < MinPercent then
					percent = UnitGetToHitUnit( unit, target, HL_RLEG )
					part = HL_RLEG
					if percent < MinPercent then
						percent = UnitGetToHitUnit( unit, target, HL_BODY )
						part = HL_BODY
						if percent < MinPercent then
							percent = UnitGetToHitUnit( unit, target, HL_ANY )
							part = HL_ANY
						end
					end
				end
			end
		end
	end
	return part
end

function meleeCommands(unit)
	if(unitIsActive( unit )) then
		local target = getNearestVisibleByUnit(unit)
		if(not IsValid(target)) then
			target = getNearestVisibleByGroup(unit)
			if(not IsValid(target)) then
				target = getNearestHearByUnit(unit)
				if(not IsValid(target)) then
					target = getNearestHearByGroup(unit)
				end
			end
		end	
		if(IsValid(target)) then
			UnitShoot(unit, target, HL_ANY)
out("*** TARGET FOUNDED: ",UnitGetName(target))
		else
out("*** TARGET NOT FOUNDED")
			UnitSetDirection(unit, random(8))
			WaitForUnit(unit)
			target = getNearestVisibleByUnit(unit)
			if(IsValid(target)) then		
				UnitShoot(unit, target, HL_ANY)
			else    	
				UnitSetNormalLogic(unit)
				Sleep(100)
				if(unitIsActive( unit )) then
					UnitSetScriptLogic(unit)
				end
			end
		end
	end
end

function OnUnitNeedCommand(unit)
	meleeCommands(unit)
end

scriptLogic = {}

function unitSetScriptLogic(unit)
	if(IsValid(unit) and UnitCanFight(unit)) then
		scriptLogic[unit]=true
		UnitSetScriptLogic(unit)
	end
end

function unitSetMelee(unit,bNoCreateWeapon)
	if(UnitIsUsingCannon(unit)) then
		UnitAttachToCannon(unit,nil,false)
	else
		local melee = { 243,244,246,247,248,249 }
		UnitHealCriticals(unit)
		local ap = UnitGetSkillMaxValue(unit,ST_AP)
		UnitSetSkill(unit,ST_AP,ap)
		if(not bNoCreateWeapon) then
			UnitWeaponSetDurability(unit, random(20,100))
			WaitForUnit(unit)
			UnitWeaponSetBroken(unit)
			WaitForUnit(unit)
			CreateAndActivateItem(unit,melee[random(1,7)])
			WaitForUnit(unit)
		end
		UnitSetWishPose(unit,POSE_RUN)
		UnitSetPose(unit,POSE_RUN)
		WaitForUnit(unit)
		unitSetScriptLogic(unit)
	end
end

function ammunitionCreate( player )
	local SpecialWeapon = { 180, 182, 183, 190, 218, 298, 299, 352, 357, 378, 382, 500 }
	local group = PlayerGetUnits(player)
	for i=0,GroupGetSize(group)-1 do
		local unit = GroupGetUnit(group,i)
		if( unitIsActive( unit ) and (not scriptLogic[unit])) then
			if(UnitIsWeaponInHand( unit, WP_NORMAL ) and
				(UnitGetAmmoQuantityInHand(unit)<2)) then
				local SWeapon = nil
				local InHandID = ItemGetID( UnitGetSlotItem( unit, UnitGetActiveSlot( unit ) ) )
				for weapon, ID in SpecialWeapon do
					if InHandID == ID then SWeapon = true end
				end
				if SWeapon then
					if ( UnitGetAmmoQuantityInHand( unit ) == 0 ) then
						if(random(100)<50) then
out('*** ammunition created sweapon')
							if(CreateAmmo( unit )) then
								UnitReload(unit)
							else
out('*** switch to melee (bad create) sweapon')
								unitSetMelee(unit)
							end
						else
							unitSetMelee(unit)
out('*** switch to melee random sweapon')
						end
					end
				else
					if(random(100)<85) then
						if(CreateAmmo( unit )) then
out('*** ammunition created')
							UnitReload(unit)
						else
out('*** switch to melee (bad create)')
							unitSetMelee(unit)
						end
					else
out('*** random switch to melee')
						unitSetMelee(unit)
					end
				end
			else
				checkWeapon(unit)
			end
		end
	end
end

ammoChecked = {}
function checkAmmunition( player )
--	if(not ammoChecked[player]) then
		ammoChecked[player] = true
--		StartThread(ammunitionThread, player )
--	end
end

-----

function Friend( group, unit )
	scriptLogic[unit] = true
	for i=0, GroupGetSize( group )-1 do
		local friend = GroupGetUnit( group,i )
		if(     unitIsActive( friend )) then
			if 20 < GetDistance( GetPos( unit ), GetPos( friend ) ) then
				out("Distance ", GetDistance( GetPos( unit ), GetPos( friend ) ) )
				local waypoint = random(1000)
				CreateWaypoint( "Temp"..waypoint, friend )
				RecalcWaypointPos( "Temp"..waypoint )
				UnitSetWishPose( unit, POSE_RUN )
				WaitForUnit( unit )
				UnitSetPose( unit, POSE_RUN )
				WaitForUnit( unit )
				UnitMoveToWaypoint( unit, "Temp"..waypoint )
				WaitForUnitRoute( unit )
				if(unitIsActive( unit )) then
					UnitSetWishPose( unit, POSE_WALK )
					WaitForUnit( unit )
					UnitHide( unit )
					WaitForUnit( unit )
					UnitRoaming( unit, "Temp"..waypoint, 15 )
					scriptLogic[unit] = false
					return
				end
			end
		end
	end
	RoamingPrim( unit )
	if(IsValid(unit)) then
		scriptLogic[unit] = false
	end
end

function RoamingPrim( unit )
	if(unitIsActive( unit )) then
		local waypoint = random(1000)
		CreateWaypoint( "Temp"..waypoint, unit )
		RecalcWaypointPos( "Temp"..waypoint )
		UnitSetWishPose( unit, POSE_RUN )
		WaitForUnit( unit )
		UnitRoaming( unit, "Temp"..waypoint, 30 )
	end
end

function SetRoaming( unit, turns )
out("Roaming ",turns," for ",unit)
	scriptLogic[unit] = true
	RoamingPrim( unit )
	waitLogic(unit, turns)
end

function NeedForHelp( group, unit )
	scriptLogic[unit] = true
	RoamingPrim( unit )
	for i=0, GroupGetSize( group )-1 do
		local friend = GroupGetUnit( group,i )
		if(     unitIsActive( friend )) then
			if 20 < GetDistance( GetPos( unit ), GetPos( friend ) ) then
				if ( not IsValid( getNearestVisibleByUnit( friend ) ) ) then
					if ( not IsValid( getNearestHearByUnit( friend ) ) ) then
						local waypoint = random(1000)
						CreateWaypoint( "Temp"..waypoint, unit )
						RecalcWaypointPos( "Temp"..waypoint )
						UnitSetWishPose( friend, POSE_RUN )
						WaitForUnit( friend )
						UnitSetPose( friend, POSE_RUN )
						WaitForUnit( friend )
						UnitMoveToWaypoint( friend, "Temp"..waypoint )
						WaitForUnitRoute( friend )
						if(unitIsActive( unit )) then
							UnitRoaming( friend, "Temp"..waypoint, 15 )
						end
					end
				end
			end
		end
	end
	if(IsValid(unit)) then
		scriptLogic[unit] = false
	end
end

function waitLogic( unit, turns )
	SleepForTurn( turns )
	if(IsValid(unit)) then
		if(UnitCanFight(unit)) then
			UnitSetNormalLogic( unit )
			WaitForUnit( unit )
		end
		scriptLogic[unit] = false
	end
end

function SetPanic( unit, turns )
out("Panic ",turns," for ",unit)
	scriptLogic[unit] = true
	UnitSetPanicLogic( unit )
	WaitForUnit( unit )
	waitLogic(unit, turns)
end

function checkWeapon(unit)
	if(     unitIsActive( unit ) and
		(GetDiplomacy(0,UnitGetPlayer(unit))==DS_ENEMY) and
	        (not UnitIsUsingCannon( unit ) ) and    -- !!!
        	(not UnitIsWeaponInHand(unit,WP_GRENADE) ) and  -- !!!
		(not UnitHasFireArms(unit))) then
out("** TAKE WEAPON ",unit)
		UnitStop(unit)
		UnitCancelAction(unit)
		local item = getNearestFirearm(unit)
		if(IsValid(item)) then
out("** FOUNDED ",unit)
			UnitTakeObject(unit,item)
			WaitForUnitRoute(unit)
			WaitForUnit(unit)
out("** TAKED ",unit)
		end
	end
end

Position = {}
VP = {}

function OnStartTurnCommonLogic( playerNo )
out("*** OnStartTurnCommonLogic for ",playerNo)

	if(ammoChecked[playerNo]) then
		ammunitionCreate( playerNo )
	end

--	local group = PlayerGetUnits(playerNo)
--	for i=0,GroupGetSize(group)-1 do
--		local unit = GroupGetUnit(group,i)
--		if(unitIsActive( unit )) then
--			local vp = UnitGetSkill( unit, ST_VP )
--			if((not scriptLogic[unit])) then
--				if((not IsValid(getNearestVisibleByUnit( unit ))) and
--					(not IsValid(getNearestHearByUnit( unit ))) and
--					(VP[unit]~=nil) and		
--					(Position[unit]~=nil) and
--					(VP[unit] > vp) and
--					(IsEqualPos(Position[unit],GetPos( unit ))) ) then
--					out( "*** DICED for ", unit )
--      				local var = random(4)
--					out("*** Variant ", var )
--					if(var == 1) then
--						StartThread( SetPanic, unit, random( 1, 4 ) )
--					elseif(var == 2) then 
--						StartThread( Friend, group, unit )
--					elseif(var == 3) then 
--						StartThread( NeedForHelp, group, unit )
--					else 
--						StartThread( SetRoaming, unit, random( 1, 4 ) )
--					end
--				else
--					checkWeapon(unit)
--				end
--			end
--			VP[unit] = vp
--			Position[unit] = GetPos( unit )
--		end
--	end
end

USNeutral = true
armyNeutral = true

function isDoneCycle(unit)
	local ret = ( (not USNeutral) or 
		(not unitIsActive( unit )))
	return(ret)
end

function isDone(unit)
	local ret = ( (not USNeutral) or 
		(not unitIsActive( unit )) or
		(talked[unit]~=nil))
	return(ret)
end

function isNeedPlayAnimation(objName)
	if(objName~=nil) then
		local obj = GetObject(objName)
		if(IsValid(obj)) then
			return(ObjectGetDestroyStage(obj)==0)
		end
	end	
	return(true)
end

route = {}
count = {}
started = {}
talked = {}

function controlNPC(unit)
	if(unitIsActive( unit )) then
		controlPrim(unit)	
		if((not USNeutral) and unitIsActive( unit )) then
			UnitAIMode(unit,true)
			UnitSetNormalLogic(unit)
		end	
		scriptLogic[unit] = false
	end
end

function controlPrim(unit)
out("*** control started for ", unit)
	if( (not unitIsActive( unit )) or 
		started[unit]) then 
		return 
	end
	started[unit] = true
	local name = UnitGetName(unit)
	local r = route[name]
	scriptLogic[unit] = true
	UnitAIMode(unit,false)

	UnitSetWishPose( unit, POSE_WALK )
	WaitForUnit( unit )
	UnitSetPose( unit, POSE_WALK )
	WaitForUnit( unit )
	
	local no = 1
	
	while(not isDoneCycle(unit)) do
		if((DEBUG==nil) or (DEBUG==0)) then
			no = random(1,count[name])
		end
		local s = r[no]
		if( (not isDone(unit)) and isNeedPlayAnimation(s.obj)) then
			if(s.way~=nil) then
				UnitMoveToWaypoint(unit,s.way)
				local dist = GetDistance(GetPos(unit),GetWaypointPos(s.way))
				local oldDist = dist 
				while((dist>s.dist) and (not isDone(unit))) do
					Sleep(70)
					dist = GetDistance(GetPos(unit),GetWaypointPos(s.way))
					if(isDone(unit)) then break end
					if(IsRealTime() and (oldDist==dist) and (not PassCalcerIsActive())) then
						UnitMoveToWaypoint(unit,s.way)
					end
					oldDist = dist
				end
			end	
			if(not isDone(unit)) then
				local direction = s.direction
				if(direction==nil) then
					direction = random(0,8)
				end
				while(	UnitGetDirection(unit)~=direction) do
					UnitSetDirection(unit,direction)
					WaitForUnit(unit)
				end	
				if(not isDone(unit)) then
					if(s.ani1~=nil) then
						UnitPlayAnimation(unit,s.ani1,false,true)
						WaitForUnit(unit)
						UnitPlayAnimation(unit,-1,true,true)
						WaitForUnit(unit)
					end	
					if(s.ani2~=nil) then	
						UnitPlayAnimation(unit,s.ani2,true,true)
						if(IsValid(all)) then
							local target = getNearestFromUnit(unit,all)
							local tDirection = 0
							if( unitIsActive(target) and
								(not scriptLogic[target])) then
								tDirection = UnitGetDirection(target)
								if(GetDistance(GetPos(target),GetPos(unit))<4) then
									UnitLookAtUnit(target,unit)
								end
							end	
						end
						local turn = GetTurn()+random(s.turns/2,s.turns)+1
						while( (not isDone(unit)) and 
							(GetTurn()<turn)) do
							if( (s.direction~=nil) and
								(UnitGetDirection(unit)~=direction)) then
								if(s.way~=nil) then
									UnitSetToWaypoint(unit,s.way)
								end	
								UnitSetDirection(unit,direction)
								WaitForUnit(unit)
								UnitPlayAnimation(unit,s.ani2,true,true)
							end	
							Sleep(30)
						end	
						UnitPlayAnimation(unit,-1,true,true)
						if(not isDone(unit)) then
							WaitForUnit(unit)
							if(unitIsActive(target)) then
								UnitSetDirection(target,tDirection)
							end
						end	
					end
					if(s.ani3~=nil) then	
						UnitPlayAnimation(unit,s.ani3,false,true)
						WaitForUnit(unit)
						UnitPlayAnimation(unit,-1,true,true)
						WaitForUnit(unit)
					end	
				end
			end
		end	
		Sleep(40)
		if(DEBUG~=0) then
			no = no + 1
			if(no>count[name]) then
				no = 1
			end
		end
	end	
	started[unit] = nil
	if(not USNeutral) then
		UnitPlayAnimation( unit, -1, true, true )
		WaitForUnit(unit)
		UnitSetCanTalk(unit,false)
		UnitSetWishPose( unit, POSE_RUN )
		WaitForUnit( unit )
		UnitSetPose( unit, POSE_RUN )
		WaitForUnit( unit )
	end
end

function controlCivilian(unit)
	if(unitIsActive(unit)) then
		controlPrim(unit)	
		local name = UnitGetName(unit)
		if(not USNeutral) then
			UnitMoveToWaypoint(unit,name)
			WaitForUnitRoute(unit)
			UnitSetWishPose( unit, POSE_CROUCH )
			WaitForUnit( unit )
			UnitSetPose( unit, POSE_CROUCH )
		else
			scriptLogic[unit] = false
		end
	end
end

-------------------------------------------------------------------------
out( 'SLogic scripts were loaded' )