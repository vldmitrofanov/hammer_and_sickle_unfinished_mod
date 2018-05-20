-- sellerQuest
SQ_AVAILABLE		=	0
SQ_TAKED		=	1
SQ_ZIGMUNDKILLED	=	2
SQ_WAITCAR		= 	3
SQ_ZIGMUNDLIVE		=	4
SQ_DONE			=	5
SQ_TOZIGMUND		=	6

-- convoyQuest
CQ_AVAILABLE		=	1
CQ_WITHCAR		=	2
CQ_FAILED		=	3
CQ_DONE			=	4
CQ_BADFIN		=	5

-- piterDeal
PQ_NONE			=	0
PQ_RECRUIT		=	1
PQ_ENEMY		=	2
PQ_OK			=	3
PQ_DELAIEDENEMY		=	4

-- fidelQuest
FQ_NONE			=	0
FQ_TAKED		=	1
FQ_KILLED		=	2
FQ_DONED		=	3
FQ_INPARTY		=	4

-- larryQuest
LQ_NONE			=	0
LQ_TAKED		=	1
LQ_KILLED		=	2
LQ_DONED		=	3
LQ_INPARTY		=	4
LQ_FAILED		=	5

-- zigfridQuest
ZQ_NONE			=	0
ZQ_TAKED		=	1
ZQ_INPARTY		=	3
ZQ_DONED		=	4
ZQ_RUN			=	5
ZQ_FAILED		=	6

-- MTQuest
MQ_NOTTAKED		=	0
MQ_DONED		=	1
MQ_FAILED		=	2
MQ_MCLEODTALKED		=	3
MQ_MCLEODKILLED		=	4
MQ_BARMENTALKED		=	5

-- BattleChoice
BC_ZERO			=	0
BC_MT			=	1
BC_SENT			=	2

-- zone type
ZT_FOREST		=	1
ZT_CITY			=	2
ZT_CAVE			=	3

-- ambient type
AT_NORMAL		=	1		
AT_DUST			=	2
AT_SPECIAL		=	3
AT_SPECIAL1		=	4
AT_SPECIAL2		=	5

-- radio state
RS_NONE			=	0
RS_WATERPUMP		=	1
RS_AFTERWATERPUMP	=	2
RS_AGENT		=	3
RS_MCLEODTALKED		=	4
RS_MCLEODTALKEDDIED	=	5
RS_MCLEODFAILED		=	6
RS_BROKE		=	7
RS_AFTERWATERPUMP1	=	8
RS_WPUMPFAILED		=	9

-- game misc const

GC_CRITICALPROB		=	4	-- Base critical probability [10]
GC_XPDENOMINATOR	=	16	-- XP for enemy denominator [5.4]
GC_REPAIRONBASE		=	19	-- Repair on base cost coeff [0.5]
GC_SHOPSELLING		=	21	-- Shop selling coeff [0.3]
GC_ALWAYSSMALLCRIT	=	79	-- Always small critical [0]

GC_UNHIDEPROB0TILES	=	1	-- Base unhide probability 0 tiles [80]
GC_UNHIDEPROBNTILES	=	2	-- Base unhide probability N tiles [0]
GC_NUMBERNTILES		=	3	-- Number N tiles (see prev record) [30]
GC_VPWITHSTR0		=	5	-- Base VP with strength 0 [50]
GC_VPFOR1STR		=	6	-- Base VP for 1 strength [10]
GC_APWITHDEX0		=	7	-- Base AP with dexterity 0 [36]
GC_APFOR1DEX		=	8	-- Base AP for 1 dexterity [2]
GC_INTERRUPTSKILL	=	9	-- Base interrupt skill value [25]
GC_SHOOTWITHDEX0	=	10	-- Base shooting stat with dexterity 0 [20]
GC_SHOOTFOR1DEX		=	11	-- Base shooting stat  for 1 dexterity [1]
GC_STEALTHWITHDEX0	=	12	-- Base stealth stat with dex 0 [5]
GC_STEALTHFOR1DEX	=	13	-- Base stealth stat for 1 dex [2]
GC_SPOTWITHINT0		=	14	-- Base spot stat with int 0 [5]
GC_SPOTFOR1INT		=	15	-- Base spot stat for 1 int [2]
GC_VPFRACTION1		=	17	-- VP fraction when no stun is possible [0.9]
GC_VPFRACTION2		=	18	-- VP fraction when stun probability becomes max [0.5]
GC_MAXVPFORHEALING	=	20	-- Max VP value (for healing) [250]
GC_UNHIDEPROB		=	22	-- Unhide probability modifier if calm [0.1]
GC_ALWAYSATTACKSOUNDS	=	23	-- AI units always attack sounds they hear [1]
GC_WOUNDEDATTACKSOUNDS	=	24	-- wounded AI units attack sounds they hear [1]
GC_TOHITFORSHOOTSOUND	=	73	-- AI - min ToHit to shoot sound [4]
GC_TOHITFORGRENADESOUND	=	74	-- AI - min ToHit to throw grenade to sound [33]
GC_BACKSTUBMELEE	=	76      -- BackstabMeleeMultiplier [2.5]
GC_BACKSTUBMIN		=	77      -- BackstabMinDamageMult [0]
GC_BACKSTUBMAX		=	78      -- BackstabMaxDamageMult [0]
GC_APADENOMINATOR	=	84	-- APA denominator [26]
GC_MINBACKOFFPERCENT	=	85	-- Minimal back-off probability, per cent [0]
GC_MAXBACKOFFPERCENT	=	88	-- Maximal back-off probability, per cent [20]
GC_MINSKILLPROGRESS	=	89	-- Skill progress min value [0.01]
GC_MAXSKILLPROGRESS	=	90	-- Skill progress max value [1]
GC_BURSTENIGMOUS	=	91	-- Burst enigmous modifier [0.7]
GC_AUTOSEARCH1CORPSE	=	94	-- Autosearch probability with 1 corpse [20]
GC_AUTOSEARCHNEXTCORPSE	=	95	-- Autosearch probability for 1 new corpse [20]
GC_AUTOSEARCHRADIUS	=	96	-- Radius to count corpses to try autosearch [5]
GC_HIDEDENOMINATOR	=	1000001 -- [1.0]
GC_UNHIDEMINTILES	=	1000002 -- [5.0]
GC_TRAPFAILPROB		=	1000003 -- [80]
GC_ARMORHEADPROB	=	1000004 -- [100]
GC_ARMORHANDSPROB	=	1000005 -- [50]
GC_ARMORLEGSPROB	=	1000006 -- [50]
GC_ARMORTORSOPROB	=	1000007 -- [0]
GC_NORMALSIGHTDIST	=	1000008 -- [20]
GC_SNIPESIGHTDISTMOD	=	1000009 -- [3.0]

-- unit class (hero)

UC_SCOUT	=	1
UC_SNIPER	=	2
UC_GRENADIER	=	3
UC_SOLDIER	=	4
UC_MEDIC	=	5
UC_ENGINEER	=	6
UC_SOLDIERUK	=	10
UC_SCOUTUK	=	11

-- for UnitGetAPToHitUnit

-- Warning
UCR_OK			=	1
UCR_OK_RELOAD		=	2 -- ok, but attack will be replaced by reload
UCR_OK_FIXJAMMED	=	3 -- ok, but attack will be replaced by reload
UCR_NO_TARGET		=	4   
UCR_NOT_REALTIME	=	5
UCR_NOT_ENOUGH_AP	=	6
-- Error
UCR_UNAVAILABLE		=	7
UCR_GENERAL_FAILURE	=	8
UCR_INVALID_COMMAND	=	9
UCR_PATH_NOT_FOUND	=	10
UCR_NEED_RELOAD		=	11
UCR_NO_EQUIPMENT	=	12
UCR_WEAPON_JAMMED	=	13
UCR_CRITICALS_BAN	=	14
UCR_TARGET_OUT_OF_RANGE	=	15
UCR_CANT_SEE_TARGET	=	16
UCR_NEED_HIGHER_SKILL	=	17
UCR_CANT_HEAL		=	18
UCR_DOOR_LOCKED		=	19
UCR_INVENTORY_NO_PLACE	=	20

SF_NONE			=	0
SF_WEAPON		=	1
SF_GRENADE		=	2
SF_MELEE		=	4
SF_ARMOUR		=	8
SF_UNIFORM		=	16
SF_MONEY		=	32
SF_KEY			=	64
SF_MINE			=	128
SF_MINEDETECTOR		=	256
SF_FIRSTAID		=	512
SF_TOOL			=	1024
SF_PICKLOCK		=	2048
SF_WIRECUTTER		=	4096
-- for ItemGetTypeEx
SF_CLIP			=	9192

SH_MEDIC		=	1
SH_SELLER		=	2
SH_ZIGMUND		=	3
SH_FORESTER		=	4
SH_ANTIQUAR		=	5
SH_PITER        =   6

-- event type

HT_GAZETTE		=	1400232
HT_OPERALLIES		=	1400231
HT_OPERSOVIET		=	1400230

-- events

ET_ADITFULL		=	1400526
ET_ADITPARTIAL		=	1400527
ET_ADITSINGLE		=	1400528

ET_CITYADOCS  		=	1400520
ET_CITYADOCSSINGLE	=	1400521
ET_CITYAOUT		=	1400522
ET_CITYAOUTSINGLE	=	1400523
ET_CITYAWEAPON		=	1400524
ET_CITYAWEAPONSINGLE	=	1400525
ET_CITYDOCS  		=	1400513
ET_CITYDOCS2  		=	1400514
ET_CITYDOCSSINGLE	=	1400515
ET_CITYDOCSSINGLE2	=	1400529
ET_CITYWEAPON		=	1400516
ET_CITYWEAPON2		=	1400517
ET_CITYWEAPONSINGLE	=	1400518
ET_CITYWEAPONSINGLE2	=	1400519
ET_CITYANTIQUARGAZETTE	=	1400512

ET_PRISONGAZETTE	=	1400511

ET_ROADPOSTUS		=	1400502
ET_ROADPOSTCOMPLETE	=	1000007
ET_ROADPOSTCORPSES	=	1400503
ET_ROADPOSTFAILED	=	1400501

ET_WPUMP		=	1400504
ET_WPUMPSINGLE		=	1400505
ET_WPUMPGAZETTE		=	1400510

ET_WSTATIONARMY		=	1400506
ET_WSTATIONARMYSINGLE	=	1400507
ET_WSTATIONCIVIL	=	1400508
ET_WSTATIONCIVILSINGLE	=	1400509

-- difficulty

DF_EASY			=	1.39
DF_NORMAL		=	2.68
DF_HARD			=	4.06
MAX_CARMA		=	15
DEFAULT_ENEMY_LEVEL	=	2

-- final

FP_GOOD			=	1
FP_MED			=	2
FP_BAD			=	3
FP_VERYBAD		=	4

-- critical types for UnitHasCritical

C_DEATH 		= 	0
C_AP_REDUCTION		=	1
C_BLIND			=	2
C_WEAPONSKILL_REDUCTION	=	3
C_VP			=	4
C_MOTIONLESS		=	5
C_ENCUMBRANCE		=	6
C_ACCIDENTAL_SHOT	=	7
C_LOST_WEAPON		=	8
C_IDLE_HAND		=	9
C_STUN			=	10
C_DAMAGE_WEAPON		=	11
C_PATIENT		=	12
C_DEAF			=	13
C_BLEEDING		=	14

-- unfinished mod --

-- GVPiterBaseQuest
PBQ_NONE = 0
PBQ_TAKEN = 1
PBQ_ITEM = 2
PBQ_ITEMZIG = 3
PBQ_STORED = 4
PBQ_ATTACK = 5
PBQ_DONE = 8
PBQ_FAILED = 9

-- Seller quest
SQ_TOPITER		=	7
-------------------------------------------------------------------------
out( 'SConst scripts were loaded' )
