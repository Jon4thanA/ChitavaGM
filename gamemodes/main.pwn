/*
• FOLLOW ON INSTAGRAM: www.instagram.com/nikachitava18/
• LIKE FACEBOOK PAGE: www.facebook.com/ChitavaProduction
*/


#include <a_samp>
#include <crashdetect>
#include <fix>
#include <a_mysql>
#include <streamer>
#include <Pawn.CMD>
#include <sscanf2>
#include <foreach>
#include <Pawn.Regex>


/* define */
#define	SendErrorMessage(%0,%1)			SendClientMessage(%0, 0xFFFFFFFF, "{828282}* {EA4335} "%1)
#define SendInfoMessage(%0,%1)			SendClientMessage(%0, 0xFFFFFFFF, "{4582A1}* S.INFO {FFFFFF} "%1)
#define SendAdminInfo(%0,%1)			SendClientMessage(%0, 0xFFFFFFFF, "{FF6347}* A.INFO {FFFFFF} "%1)
#define KickEx(%0); 					SetTimerEx("OnPlayerKick", 250, false, "i", %0);
#define GetName(%0) 					PlayerInfo[%0][pName]
#define NONE_3D_TEXT 					(Text3D:-1)
#define IsAdmin(%0) 					if(PlayerInfo[playerid][pAdmin] < %0) return true

/* new */
new MySQL:dbHandle;
new bool:gps[MAX_PLAYERS];

enum player
{
	ID,
	pName[MAX_PLAYER_NAME],
	pPassword[32],
	pMail[64],
	pSex,
	pSkin,
	pLevel,
	pLogin,
	pMoney,
	pHouse,
	pBizz,
	pFillBizz,
	pSetSpawn, // 0 default spawn , 1 - house 2 - organization
	pBank,
	pLeader,
	pRank,
	pMember,
	pModel ,//fraction skin
	pSpeedometerTimer,
	pSalary,
	pDrugs,
	pAmmo,
	bool:Gun[47],
	GunAmmo[13],
	pAdmin,
	pBan,
	pWarn,
	pUnwarntime
};
new PlayerInfo[MAX_PLAYERS][player];

/* House system */
new TotalHouse;
new Text3D:House3DText[990] = {NONE_3D_TEXT, ...};
new HouseCP[990] = {-1, ...};


enum hInfo
{
	hOwner[MAX_PLAYER_NAME],
	Float:hEnter_X,
	Float:hEnter_Y,
	Float:hEnter_Z,
	Float:hExit_X,
	Float:hExit_Y,
	Float:hExit_Z,
	hPrice,
	hOwned,
	hLock,
	hInt,
	hClass,
	hIcon,
	hTax,
	hID
};
new HouseInfo[990][hInfo];
/* end house*/

/* Vehicle */
new Text:SpeedTextDraw[10];
new PlayerText:SpeedTextDraws[MAX_PLAYERS][6];
new engine,lights,alarm,doors,bonnet,boot,objective;

enum e_vehicleInfo
{
	vID,
	bool:vEngine,
	bool:vLock,
	Float:vFuel,
	bool:vLimit,
	Float:vX,
	Float:vY,
	Float:vZ,
	bool:vRentcar,
	bool:vLights
};

new vInfo[MAX_VEHICLES][e_vehicleInfo];
/* end vehicle */

/* admin system */
new bool:AdminLogged[MAX_PLAYERS];
enum e_admininfo
{
	admID,
	admLevel,
	admGoto,
	admGethere,
	admSpectate,
	admKicked,
	admWarned,
	admOffWarned,
	admBaned,
	admOffBaned,
	admMuted,
	admAnsed
}
new AdminInfo[MAX_PLAYERS][e_admininfo];
/* end admin*/

/* Bussines system */
new TotalBizz;
new Text3D:Bizz3DText[990] = {NONE_3D_TEXT, ...};
new BizzCP[990] = {-1, ...};

new shop_item_list[6][70] = {"Mobile Phone","SIM Card","Heal","Photo Camera","Rope","Mask"};
new shop_item_price[6] = {800, 250, 300, 400, 150, 200};
new shop_prod_count[6] = {5, 5, 3, 5, 2, 2};

new burger_item_list[4][70] = {"Pizza", "Burger", "Big Mac", "Big Taste"};
new burger_item_price[4] = {300, 250, 350, 400};
new burger_prod_count[4] = {5, 5, 10, 10};

new club_item_list[6][70] = {"Wine", "Vodka", "Whisky", "Tequila", "Juice", "Water"};
new club_item_price[6] = {400, 350, 700, 550, 200, 100};
new club_prod_count[6] = {5, 5, 10, 10, 5, 5};

enum bInfo
{
	bName[32],
	bOwner[MAX_PLAYER_NAME],
	Float:bEnter_X,
	Float:bEnter_Y,
	Float:bEnter_Z,
	Float:bExit_X,
	Float:bExit_Y,
	Float:bExit_Z,
	Float:bBar_X,
	Float:bBar_Y,
	Float:bBar_Z,
	bLock,
	bPrice,
	bType,
	bProd,
	bProfitHour,
	bBank,
	bMaxProd,
	bGuest,
	bProfit,
	bOwned,
	bInt,
	bWorld,
	Text3D:bText,
	bImprove,
	bIcon,
	bPick,
	bTax,
	bLockTime,
	bID
};

new BizzInfo[990][bInfo];

/* end bussines*/

/* filling bussines */
new TotalFill;
new Text3D:Fill3DText[50] = {NONE_3D_TEXT, ...};

enum fInfo
{
	fOwner[MAX_PLAYER_NAME],
	Float:fMenu_X,
	Float:fMenu_Y,
	Float:fMenu_Z,
	fLock,
	fPrice,
	fValue,
	fProd,
	fFuel,
	fMaxFuel,
	fBank,
	fOwned,
	fIcon,
	fPick,
	fLockTime,
	fID
};
new FillInfo[50][fInfo];
/* end filling*/

/* warehouses */
new TotalWarehouse;
enum w_info
{
	wID,
	wAmmo,
	wBank,
	wDrug,
	wStatus
};
new wInfo[50][w_info];
new Text3D:WarehousePosText[12];
/* end warehouse */

enum dialogs
{
	d_None,
	d_REG,
	d_MAIL,
	d_SEX,
	d_FINISH,
	d_LOGIN,
	d_BUYHOUSE,
	d_HOUSEINFO,
	d_HPANEL,
	d_SELLHOUSE,
	d_BUYBIZZ,
	d_BIZZINFO,
	d_BPANEL,
	d_SALARY,
	d_BNAME,
	d_SELLBIZZ,
	d_SALARYWITHDRAW,
    d_SALARYINPUT,
   	d_SHOP,
    d_BURGER,
    d_CLUB,
    d_BANK,
    d_BANKWITHDRAW,
    d_BANKINPUT,
    d_HOUSETAX,
	d_BIZZTAX,
	d_MAKELEADER,
	d_LEADERS,
	d_GANGLEADER,
	d_MAFIALEADER,
	d_BUYFILLING,
	d_BFILLPANEL,
	d_SELLFILL,
	d_FILL,
	d_FILLSALARY,
	d_FILLSALARYWITHDRAW,
    d_FILLSALARYINPUT,
    d_DUTYFORM,
    d_CHANGEDUTYFORM,
    d_GANGSTORE,
    d_GETGUN,
    d_GETSTOREAMMO,
    d_GETSTOREDRUGS,
    d_GETSTOREMONEY,
    d_PUTSTOREAMMO,
    d_PUTSTOREDRUGS,
    d_PUTSTOREMONEY,
    d_ADMINLOGIN,
    d_AMMONATION,
    d_BUYWEAPON,
    d_BUYAMMO,
    d_LMENU,
    d_CHANGEFRACSKIN
}

/* world time */
new ghour = 0;
new realtime = 1;
new timeshift = 0;
new shifthour;

new InviteSkin[MAX_PLAYERS];
new FormaFrac[MAX_PLAYERS];

static const FractionDefaultSkin[13] = {0, 300, 164, 287, 98, 102, 105, 175, 108, 114, 127, 112};
static const FractionSkins[][] =
{
	{0, 1},
	{300, 284, 303, 310, 283, 265, 306, 1}, //pd
	{164, 227, 57, 147, 150, 1}, //FBI
	{287, 179, 191, 1}, //army
	{240, 98, 76, 150, 197, 147, 1}, //pres
	{102, 103, 104, 19, 13, 1}, // ballas
	{105, 106, 107, 269, 271, 270, 293, 195, 1}, // grove
	{175, 174, 173, 273, 226, 1}, // rifa
	{108, 109, 110, 47, 190, 1}, // vagos
	{114, 115, 116, 292, 41, 1}, // aztecas
	{127, 290, 124, 223, 113, 93, 1}, // lcn
	{117, 122, 123, 294, 120, 169, 1}, // yakudza
	{112, 111, 125, 126, 43, 46, 233, 1} // rm
};

/* skin shop */
new Text:enable_skin_TD[8];
new SelectCharPlace[MAX_PLAYERS];
static const stock JoinShopF[][2] = {
	{65, 455},
	{192, 500},
	{219, 610},
	{93, 650},
	{211, 675},
	{233, 700},
	{148, 710},
	{169, 725},
	{141, 750},
	{76, 775},
	{150, 815},
	{214, 900}
};

static const stock JoinShopM[][2] = {
	{25,250},
	{15,325},
	{36,462},
	{50,500},
	{95,517},
	{96,550},
	{136,600},
	{143,625},
	{155,678},
	{2,700},
	{14,750},
	{24,776},
	{58,800},
	{7,819},
	{23,850},
	{33,900},
	{60,950},
	{67,1000},
	{73,1125},
	{184,1150},
	{21,1175},
	{22,1200},
	{30,1250},
	{183,1300},
	{255,1325},
	{4,1350},
	{6,1397},
	{8,1400},
	{42,1420},
	{273,1450},
	{17,1500},
	{45,1700},
	{82,1900},
	{83,2000},
	{185,2150},
	{290,2250},
	{291,3000},
	{28,3150},
	{29,3200},
	{248,3500},
	{247,3740},
	{254,3800},
	{249,3955},
	{18,4000},
	{19,4150},
	{47,4200},
	{48,4217},
	{101,4250},
	{299,4300},
	{289,4400},
	{61,4450},
	{121,4500},
	{227,4515},
	{228,4525},
	{292,4535},
	{293,4550},
	{297,4600},
	{122,4612},
	{111,4618},
	{117,4650},
	{118,4750},
	{126,5000},
	{127,5100},
	{296,5200},
	{3,5300},
	{119,5400},
	{208,5500},
	{295,5600},
	{46,5700},
	{294,5800}
};


/* server pickups */
new BankPick[5]; // 0 - 1 enter - extir 2,3,4 - salary
new PolicePick[2];
new FBIPick[2];
new ArmyPick[2];
new ResPick[2];
new BallasPick[2], GrovePick[2], RifaPick[2], VagosPick[2], AztecasPick[2];
new LcnPick[2], YakPick[2], RmPick[2];
new DutyForm[4];
new AmmoPick[2];
/* --- */
new pdcar[19], fbicar[9], armycar[33],rescar[8];
new ballascar[9], grovecar[9], aztecascar[9], vagoscar[9], rifacar[9];
new lcncar[9], yakcar[9],rmcar[9];

new FractionRankName[12][11][60] = { //fractions x rangs x length
	{"-","Police Officer l Class","Police Officer ll Class","Police Officer lll Class","SERGEANT I","SERGEANT II","SERGEANT III","LIEUTENANT","CAPTAIN","ASSISTENT CHIEF OF POLICE","CHIEF OF POLICE"}, //PD
	{"-","Intern","JR.Agent","Agent Of Dep.ATG","Agent Of Dep.ANG","Senior Agent","ATG Dep. Head","ANG Dep. Head","Inspector FBI","Deputy Director","Director of FBI"}, //FBI
	{"-","Soldier","Corporal","Sergeant","Sergeant Mayor","Lieutenant","Captain","Major","Lieutenant Colonel","Colonel","General Of NA"}, //ARMY
	{"-","Driver","Security","Head Of Security","Secretary","Deputy","Vice-Minister","Minister","Mayor","Vice-President","President"}, //RESIDENCE
	{"-","Baby","Buster","Cracker","Gun Bro","Up Bro","Gangster","Folcks","Shooter","Star","Big Daddy"}, //BALLAS
	{"-","Newman","Hustle","Killa","Cracker","Gangsta","O.G","Mobsta","Big Bro","Legend","Daddy"}, //GROVE
	{"-","Novato","Perro","Ghettor","Mirando","Sabio","Invasor","Nestro","Apromaxiado","Diputado","Padre"}, //RIFA
	{"-","Mamaracho","Perro","Bandito","Vato Loco","Sabio","Forajido","Veterano","Elite","El Orgullo","Padre"}, //VAGOS
	{"-","Novato","Gringo","Bandito","Estimado","Amigo","Ermano","Djunior","Veterano","Vato Loco","Padre"},  //AZTEAS
	{"-","Novica","Assosiato","Sombattente","Soldier","Mebrdzoli","Ufrosis Moadgile","Ufrosi","Boss","Marcheveli","Don"}, //LCN
	{"-","Kuimite","Oyadzi","Cayko-Caumont","Cambio","JR.Cambio","Vakagasira","Fuku-Hombute","Keday","Syatey","Vacas"}, //YAKUDZA
	{"-","Shniri","Arifi","Mochxubare","Mujiki","Quchis Bichi","Kai Bichi","Blatnoi","Qurdi","Kanonieri Qurdi","Avtoriteti"} //RM
};

new minute_timer;

main()
{
	print("\n/*----------------------------------*/");
	print("   author Nika Chitava");
	print("   powered by Chitava Production");
	print("/*----------------------------------*/\n");
}

public OnGameModeInit()
{
	MYSQL_CONNECT();
	/* server settings */
	SendRconCommand("hostname NEW GAMEMODE BY Chitava Production");
	SendRconCommand("language Georgian");
	SendRconCommand("password !00");
	SetGameModeText("Mode V 4.0 (BETA)");
	/* */
	LoadMAP();
	LoadPickup();
	Load3DText();
	LoadVehicles();
	LoadTextDraw();
	SetTimer("OnPlayerUpdateTimer", 1000, 1);
	minute_timer = SetTimer("MinuteTimer", 60000, true);
	ShowPlayerMarkers(0);
	LimitPlayerMarkerRadius(50.0);
	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	SetNameTagDrawDistance(50.0);
	Streamer_TickRate(100);
	Streamer_VisibleItems(0,2500);
	/*-----------------*/
    for(new Vehicles = 0; Vehicles < MAX_VEHICLES; Vehicles++)
	{
        vInfo[Vehicles][vFuel] = 300;
        vInfo[Vehicles][vEngine] = false;
        vInfo[Vehicles][vLights] = false;
		SetVehicleHealth(Vehicles, 999.0);
		SetVehicleNumberPlate(Vehicles, "Chitava");
	}
	/*-----------------*/
	CreateTrigger(1405.2507,-33.4383,1504.5602-1.77); //pd
	CreateTrigger(1688.7605,-1419.7156,3087.0383-1.77); //fbi
	CreateTrigger(274.0574,1923.0823,5.1380-1.77); //army
	CreateTrigger(-807.6265,-688.1851,4001.0859-1.77); //residence
    CreateTrigger(2014.4634,1344.8119,632.0748-1.77); //ghetto
    CreateTrigger(-2243.6067,717.5988,3001.5166-1.77); //mafia
    CreateTrigger(2860.6919,788.9444,801.7853-1.77);
	return 1;
}

stock MYSQL_CONNECT() 
{
    dbHandle = mysql_connect("localhost", "gs47", "mrfi9vc9R4", "gs47");
	switch(mysql_errno())
	{
	    case 0: print("MYSQL warmatebit daukavshirda servers");
	    default: print("MYSQL ver daukavshirda servers");
	}
	mysql_log(ERROR | WARNING);
	mysql_set_charset("cp1251");
	
	/*-----------------*/
    mysql_tquery(dbHandle, "SELECT * FROM `property`", "LoadProperty", "");
    mysql_tquery(dbHandle, "SELECT * FROM `bussines`", "LoadBussines", "");
    mysql_tquery(dbHandle, "SELECT * FROM `filling`", "LoadFillings", "");
    mysql_tquery(dbHandle, "SELECT * FROM `warehouse`", "LoadWarehouses", "");
	/*-----------------*/
}

public OnGameModeExit()
{
    for(new i; i < TotalHouse; i ++) SaveProperty(i);
    for(new i; i < TotalBizz; i ++) SaveBizz(i);
    for(new i; i < TotalFill; i ++) SaveFill(i);
	for(new i; i < TotalWarehouse; i ++) SaveWarehouse(i);
    KillTimer(minute_timer);
	return 1;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == 0 && weaponid > 39) return BanEx(playerid, "NEW CRASHER");
    if(hittype != 0 && hittype != 1 && hittype != 2 && hittype != 3 && hittype != 4) return SendErrorMessage(playerid, "Tqven gaikicket cheterobistvis (#007)"), KickEx(playerid);
	if(hittype == BULLET_HIT_TYPE_PLAYER && (BadFloat(fX) || BadFloat(fY) || BadFloat(fZ)))
	{
	    SendErrorMessage(playerid, "Tqven gaikicket cheterobistvis (#006)");
		KickEx(playerid);
	    return false;
	}
	if(PlayerInfo[playerid][GunAmmo][GetWeaponSlot(weaponid)] < 0)
	{
	    SendErrorMessage(playerid, "Tqven gaikicket cheterobistvis (#001)");
	    KickEx(playerid);
	}
	PlayerInfo[playerid][GunAmmo][GetWeaponSlot(weaponid)]--;
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(GetPVarInt(playerid, "SelectTextDrawEnter") == 1)
	{
    	new string[128];
		if(clickedid == enable_skin_TD[6])
	    {
	        PlayerPlaySound(playerid, 17803, 0.0, 0.0, 0.0);
			if(PlayerInfo[playerid][pSex] == 1)
			{
  			    if(SelectCharPlace[playerid] == sizeof(JoinShopM)-1) SelectCharPlace[playerid] = 0;
				else SelectCharPlace[playerid]++;
				SetPlayerSkin(playerid, JoinShopM[SelectCharPlace[playerid]][0]);
				format(string, sizeof(string), "~w~~n~~n~~n~~n~~n~~n~COST: ~g~%i$", JoinShopM[SelectCharPlace[playerid]][1]);
			}
			else
			{
				if(SelectCharPlace[playerid] == sizeof(JoinShopF)-1) SelectCharPlace[playerid] = 0;
				else SelectCharPlace[playerid]++;
				SetPlayerSkin(playerid, JoinShopF[SelectCharPlace[playerid]][0]);
				format(string, sizeof(string), "~w~~n~~n~~n~~n~~n~~n~COST: ~g~%i$", JoinShopF[SelectCharPlace[playerid]][1]);
			}
			GameTextForPlayer(playerid, string, 3000, 3);
		}
		if(clickedid == enable_skin_TD[7])
		{
		    PlayerPlaySound(playerid, 17803, 0.0, 0.0, 0.0);
			if(PlayerInfo[playerid][pSex] == 1)
			{
   			    if(SelectCharPlace[playerid] == 0) SelectCharPlace[playerid] = sizeof(JoinShopM)-1;
				else SelectCharPlace[playerid]--;
				SetPlayerSkin(playerid, JoinShopM[SelectCharPlace[playerid]][0]);
				format(string, sizeof(string), "~w~~n~~n~~n~~n~~n~~n~COST: ~g~%i$", JoinShopM[SelectCharPlace[playerid]][1]);
			}
			else
			{
				if(SelectCharPlace[playerid] == 0) SelectCharPlace[playerid] = sizeof(JoinShopF)-1;
				else SelectCharPlace[playerid]--;
				SetPlayerSkin(playerid, JoinShopF[SelectCharPlace[playerid]][0]);
				format(string, sizeof(string), "~w~~n~~n~~n~~n~~n~~n~COST: ~g~%i$", JoinShopF[SelectCharPlace[playerid]][1]);
			}
			GameTextForPlayer(playerid, string, 3000, 3);
		}
		if(clickedid == enable_skin_TD[3])
		{
		    new bizid = GetPVarInt(playerid, "BUSINESS_ID");
      		if(BizzInfo[bizid][bProd] < 10) return SendErrorMessage(playerid, "Bizneshi ar aris sakmarisi produqti");
		    new price = (PlayerInfo[playerid][pSex] == 1) ? (JoinShopM[SelectCharPlace[playerid]][1]) : (JoinShopF[SelectCharPlace[playerid]][1]);
			if(PlayerInfo[playerid][pMoney] < price) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
			PlayerInfo[playerid][pSkin] = (PlayerInfo[playerid][pSex] == 1) ? (JoinShopM[SelectCharPlace[playerid]][0]) : (JoinShopF[SelectCharPlace[playerid]][0]);
			UpdatePlayerData(playerid, "pSkin", PlayerInfo[playerid][pSkin]);
   			GiveServerMoney(playerid, -price);
   			BizzInfo[bizid][bProfitHour] += price;
   			BizzInfo[bizid][bBank] += price/2;
   			BizzInfo[bizid][bProfit] += price/2;
			UpdateBizz(bizid);
			SaveBizz(bizid);
			TogglePlayerControllable(playerid,true);

   			SetPlayerPos(playerid, BizzInfo[bizid][bBar_X], BizzInfo[bizid][bBar_Y], BizzInfo[bizid][bBar_Z]);

			SetPlayerVirtualWorld(playerid, BizzInfo[bizid][bWorld]);
			SetPlayerInterior(playerid, BizzInfo[bizid][bInt]);
			SelectCharPlace[playerid] = 0;
			SetCameraBehindPlayer(playerid);
			SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
			
			for(new i; i < 8; i++) TextDrawHideForPlayer(playerid, enable_skin_TD[i]);
		    CancelSelectTextDraw(playerid),SetPVarInt(playerid, "SelectTextDrawEnter", 0);
		   	SendInfoMessage(playerid, "Tqven sheidzinet axali tansacmeli");
		}
	    if(clickedid == enable_skin_TD[4] || (clickedid == Text:INVALID_TEXT_DRAW))
	    {
	        new bizid = GetPVarInt(playerid, "BUSINESS_ID");
		    TogglePlayerControllable(playerid,true);

   			SetPlayerPos(playerid, BizzInfo[bizid][bBar_X], BizzInfo[bizid][bBar_Y], BizzInfo[bizid][bBar_Z]);

			SetPlayerVirtualWorld(playerid, BizzInfo[bizid][bWorld]);
			SetPlayerInterior(playerid, BizzInfo[bizid][bInt]);
			SelectCharPlace[playerid] = 0;
			SetCameraBehindPlayer(playerid);
			for(new i; i < 8; i++) TextDrawHideForPlayer(playerid, enable_skin_TD[i]);
		    CancelSelectTextDraw(playerid),SetPVarInt(playerid, "SelectTextDrawEnter", 0);
		    return true;
		}
	}
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(PlayerInfo[playerid][pLogin] == 1)
	{
		SpawnPlayer(playerid);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);
	static const fmt_query[] = "SELECT `ID` FROM `users` WHERE `pName` = '%s'";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
	format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "CheckReg", "i", playerid);
	
	clear_player_data(playerid);
	LoadPlayerTextdraws(playerid);
	LoadRemoveObjects(playerid);
	return 1;
}

stock LoadRemoveObjects(playerid)
{
	RemoveBuildingForPlayer(playerid, 3980, 1481.1875, -1785.0703, 22.3828, 50); //bank exterior
	RemoveBuildingForPlayer(playerid, 14795, 1388.882813, -20.882799, 1005.203125, 0.250000); //pd interior
	/* Zona 51 */
	RemoveBuildingForPlayer(playerid, 1499,    2577.83007812,-1291.40002441,1043.10998535, 5.0); // Door in Zona 51
	RemoveBuildingForPlayer(playerid, 16094, 191.1406, 1870.0391, 21.4766, 0.25); //zona 51
	RemoveBuildingForPlayer(playerid, 1499,    2530.6880,-1305.5405,1048.2957, 5.0); // Door in Zona 51
}

stock LoadPlayerTextdraws(playerid)
{
	/* Speedometre */
 	SpeedTextDraws[playerid][0] = CreatePlayerTextDraw(playerid, 560.603088, 387.916717, "1000");
	PlayerTextDrawLetterSize(playerid, SpeedTextDraws[playerid][0], 0.264932, 1.489166);
	PlayerTextDrawAlignment(playerid, SpeedTextDraws[playerid][0], 1);
	PlayerTextDrawColor(playerid, SpeedTextDraws[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, SpeedTextDraws[playerid][0], true);
	PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, SpeedTextDraws[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, SpeedTextDraws[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, SpeedTextDraws[playerid][0], 51);
	PlayerTextDrawFont(playerid, SpeedTextDraws[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, SpeedTextDraws[playerid][0], 1);

	SpeedTextDraws[playerid][1] = CreatePlayerTextDraw(playerid, 590.462829, 433.166534, "IND_LIGHT");
	PlayerTextDrawLetterSize(playerid, SpeedTextDraws[playerid][1], 0.000000, 0.202013);
	PlayerTextDrawTextSize(playerid, SpeedTextDraws[playerid][1], 570.532958, 0.000000);
	PlayerTextDrawAlignment(playerid, SpeedTextDraws[playerid][1], 1);
	PlayerTextDrawColor(playerid, SpeedTextDraws[playerid][1], 0);
	PlayerTextDrawUseBox(playerid, SpeedTextDraws[playerid][1], true);
	PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][1], 0xFF990099);
	PlayerTextDrawSetShadow(playerid, SpeedTextDraws[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, SpeedTextDraws[playerid][1], 0);
	PlayerTextDrawFont(playerid, SpeedTextDraws[playerid][1], 0);
	PlayerTextDrawSetPreviewModel(playerid, SpeedTextDraws[playerid][1], 0);
	PlayerTextDrawSetPreviewRot(playerid, SpeedTextDraws[playerid][1], 0.000000, 0.000000, 0.000000, 0.000000);

	SpeedTextDraws[playerid][2] = CreatePlayerTextDraw(playerid, 569.379333, 433.166534, "IND_LOCK");
	PlayerTextDrawLetterSize(playerid, SpeedTextDraws[playerid][2], 0.000000, 0.202013);
	PlayerTextDrawTextSize(playerid, SpeedTextDraws[playerid][2], 549.449462, 0.000000);
	PlayerTextDrawAlignment(playerid, SpeedTextDraws[playerid][2], 1);
	PlayerTextDrawColor(playerid, SpeedTextDraws[playerid][2], 0);
	PlayerTextDrawUseBox(playerid, SpeedTextDraws[playerid][2], true);
	PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][2], 0xFF990099);
	PlayerTextDrawSetShadow(playerid, SpeedTextDraws[playerid][2], 0);
	PlayerTextDrawSetOutline(playerid, SpeedTextDraws[playerid][2], 0);
	PlayerTextDrawFont(playerid, SpeedTextDraws[playerid][2], 0);

	SpeedTextDraws[playerid][3] = CreatePlayerTextDraw(playerid, 538.330749, 418.250152, "FUELS_~w~~n~2000");
	PlayerTextDrawLetterSize(playerid, SpeedTextDraws[playerid][3], 0.142646, 0.800831);
	PlayerTextDrawAlignment(playerid, SpeedTextDraws[playerid][3], 2);
	PlayerTextDrawColor(playerid, SpeedTextDraws[playerid][3], 0xFF9900FF);
	PlayerTextDrawSetShadow(playerid, SpeedTextDraws[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, SpeedTextDraws[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, SpeedTextDraws[playerid][3], 51);
	PlayerTextDrawFont(playerid, SpeedTextDraws[playerid][3], 2);
	PlayerTextDrawSetProportional(playerid, SpeedTextDraws[playerid][3], 1);

	SpeedTextDraws[playerid][4] = CreatePlayerTextDraw(playerid, 602.986755, 418.250091, "HEALTH_~w~~n~1000.0");
	PlayerTextDrawLetterSize(playerid, SpeedTextDraws[playerid][4], 0.142646, 0.800831);
	PlayerTextDrawAlignment(playerid, SpeedTextDraws[playerid][4], 2);
	PlayerTextDrawColor(playerid, SpeedTextDraws[playerid][4], 0xFF9900FF);
	PlayerTextDrawSetShadow(playerid, SpeedTextDraws[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, SpeedTextDraws[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, SpeedTextDraws[playerid][4], 51);
	PlayerTextDrawFont(playerid, SpeedTextDraws[playerid][4], 2);
	PlayerTextDrawSetProportional(playerid, SpeedTextDraws[playerid][4], 1);

	SpeedTextDraws[playerid][5] = CreatePlayerTextDraw(playerid, 582.029174, 416.833343, "IND_ENGINE");
	PlayerTextDrawLetterSize(playerid, SpeedTextDraws[playerid][5], 0.000000, 0.248696);
	PlayerTextDrawTextSize(playerid, SpeedTextDraws[playerid][5], 557.414367, 0.000000);
	PlayerTextDrawAlignment(playerid, SpeedTextDraws[playerid][5], 1);
	PlayerTextDrawColor(playerid, SpeedTextDraws[playerid][5], 0);
	PlayerTextDrawUseBox(playerid, SpeedTextDraws[playerid][5], true);
	PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][5], 0xFF990090);
	PlayerTextDrawSetShadow(playerid, SpeedTextDraws[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, SpeedTextDraws[playerid][5], 0);
	PlayerTextDrawFont(playerid, SpeedTextDraws[playerid][5], 0);
}

stock clear_player_data(playerid)
{
    AdminLogged[playerid] = false;
    gps[playerid] = false;
	InviteSkin[playerid] = 0;
	FormaFrac[playerid] = 0;
	SetPVarInt(playerid, "FracDuty", 0);
	
	for(new i = 0; i < 47; i++)
	{
	    PlayerInfo[playerid][Gun][i] = false;
	}
	for(new i = 0; i < 13; i++)
	{
	    PlayerInfo[playerid][GunAmmo][i] = 0;
	}
}

forward OnPlayerUpdateTimer();
public OnPlayerUpdateTimer()
{
	CheckHour();
	UpdateFracWareHouse();
	UpdateGangWareHouse();
	UpdateMafiaWareHouse();
	return 1;
}

forward MinuteTimer();
public MinuteTimer()
{
    for(new i=0; i< MAX_VEHICLES; i++)
	{
		if(vInfo[i][vEngine] == true /*&& VehicleSpeed(i) == 0*/)
		{
			vInfo[i][vFuel] -= 1.01;
			return 1;
		}
	}
	return 1;
}

forward OnPlayerKick(playerid);
public OnPlayerKick(playerid)
{
	Kick(playerid);
}

stock VehicleSpeed(carid)
{
    new Float:X, Float:Y, Float:Z;
    GetVehicleVelocity(carid,X,Y,Z);
    return floatround( floatsqroot( X * X + Y * Y + Z * Z ) * 100 );
}

forward UpdateSpeedometr(playerid);
public  UpdateSpeedometr(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
	    new vehicleid = GetPlayerVehicleID(playerid);
	    new strings[40], Float: veh_hp;
		GetVehicleHealth(vehicleid, veh_hp);

		format(strings, 40, "FUELS_~n~~w~%0.0f", vInfo[vehicleid][vFuel]);
		PlayerTextDrawSetString(playerid,SpeedTextDraws[playerid][3], strings);

		format(strings, 7, " %i", VehicleSpeed(vehicleid));
		PlayerTextDrawSetString(playerid, SpeedTextDraws[playerid][0], strings);

		format(strings, 26,"HEALTH_~n~~w~%0.0f", veh_hp);
		PlayerTextDrawSetString(playerid, SpeedTextDraws[playerid][4],strings);
		
		UpdateSpeedTD(playerid, vehicleid);
	}
}

stock UpdateSpeedTD(playerid, vehicleid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		if(!vInfo[vehicleid][vLock]) PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][2], 0xFF000099), PlayerTextDrawHide(playerid, SpeedTextDraws[playerid][2]), PlayerTextDrawShow(playerid, SpeedTextDraws[playerid][2]);
		else PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][2], 0xFF990099), PlayerTextDrawHide(playerid, SpeedTextDraws[playerid][2]), PlayerTextDrawShow(playerid, SpeedTextDraws[playerid][2]);

		if(!vInfo[vehicleid][vEngine]) PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][5], 0xFF000099), PlayerTextDrawHide(playerid, SpeedTextDraws[playerid][5]), PlayerTextDrawShow(playerid, SpeedTextDraws[playerid][5]);//0xFF9900FF
		else PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][5], 0xFF990099), PlayerTextDrawHide(playerid, SpeedTextDraws[playerid][5]), PlayerTextDrawShow(playerid, SpeedTextDraws[playerid][5]);

		if(!vInfo[vehicleid][vLights]) PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][1], 0xFF000099), PlayerTextDrawHide(playerid, SpeedTextDraws[playerid][1]), PlayerTextDrawShow(playerid, SpeedTextDraws[playerid][1]);
		else PlayerTextDrawBoxColor(playerid, SpeedTextDraws[playerid][1], 0xFF990099), PlayerTextDrawHide(playerid, SpeedTextDraws[playerid][1]), PlayerTextDrawShow(playerid, SpeedTextDraws[playerid][1]);
	}
	return 1;
}

forward CheckReg(playerid);
public CheckReg(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(rows) ShowLoginDialog(playerid); //tu ukve acc moidzebna bazashi
	else ShowRegistration(playerid); //tu ver modzebna
}

stock ShowLoginDialog(playerid)
{
	new string[256];
	format(string, sizeof(string), "{4582A1}Mogesalmebit serverze - Chitava Production. \n\n\
	\t{4582A1}* {FFFFFF}Account ukve registrirebulia.\n\
	\t{4582A1}* {FFFFFF}Tqveni saxeli: %s\n\n\
	{4582A1}* Sheiyvanet tqveni paroli:", PlayerInfo[playerid][pName]);
	ShowPlayerDialog(playerid, d_LOGIN, DIALOG_STYLE_PASSWORD, "{4582A1}Avtorizacia", string, "Shesvla", "Gamosvla");
}

stock ShowRegistration(playerid)
{
    new string[256];
    format(string, sizeof(string), "{4582A1}Mogesalmebit serverze - Chitava Production. \n\n\
	{FFFFFF}\nGtxovt, chaweret tqveni axali paroli:\n\n\
	{828282}* Parolis sigrdze unda iyos: 6-15 simbolomde.\n\
	* Gamoiyenet cifrebi da asoebi.\n\
	* Chven girchevt ar daayenot iseti paroli romelic ukve giyeniat sxvagan");
	ShowPlayerDialog(playerid, d_REG, DIALOG_STYLE_INPUT, "{4582A1}Account Registracia - {FFFFFF}Paroli", string, "Archeva", "Gamosvla");
}
stock ShowEmail(playerid)
{
	new string[256];
	format(string, sizeof(string), "{FFFFFF}\tGtxovt sheiyvanot tqveni moqmedi e-mail\n\n\
	{4582A1}* {828282}Tu tqven dakarget accountan wvdoma, shegedzlebat misi dabruneba\n\
	\n\t{4582A1}* {FFFFFF}Sheiyvanet tqveni moqmedi E-Mail");
	ShowPlayerDialog(playerid, d_MAIL, DIALOG_STYLE_INPUT, "{4582A1}Account Registracia - {FFFFFF}E-Mail", string, "Archeva", "Gamosvla");
}

stock isNumeric(const string[])
{
	for (new i = 0, j = strlen(string); i < j; i++)
 	{
  		if (string[i] > '9' || string[i] < '0') return 1;
    }
    return 0;
}

stock GetPlayerID(name[])
{
	foreach(new i: Player)
	{
		if(strcmp(GetName(i), name, true, strlen(name)) == 0) return i;
	}
	return INVALID_PLAYER_ID;
}

stock show_market_dialog(playerid)
{
    new string[600];
	for(new i = 0; i < 6; i++)
	{
	    format(string, sizeof(string),
	    "{4582A1}Saqoneli\t{4582A1}Fasi\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n",
	    shop_item_list[0], shop_item_price[0],shop_item_list[1], shop_item_price[1],shop_item_list[2], shop_item_price[2],
		shop_item_list[3], shop_item_price[3],shop_item_list[4], shop_item_price[4],shop_item_list[5], shop_item_price[5]);
	}
	ShowPlayerDialog(playerid, d_SHOP, DIALOG_STYLE_TABLIST_HEADERS, "{4582A1}Magazia 24/7",string, "Yidva","Gasvla");
	return 1;
}
stock show_burger_dialog(playerid)
{
	new string[600];
	for(new i = 0; i < 4; i++)
	{
	    format(string, sizeof(string),
	    "{4582A1}Saqoneli\t{4582A1}Fasi\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n",
	    burger_item_list[0], burger_item_price[0], burger_item_list[1], burger_item_price[1], burger_item_list[2], burger_item_price[2],
		burger_item_list[3], burger_item_price[3]);
	}
	ShowPlayerDialog(playerid, d_BURGER, DIALOG_STYLE_TABLIST_HEADERS, "{4582A1}Burger", string, "Yidva","Gasvla");
	return 1;
}
stock show_club_dialog(playerid)
{
    new string[600];
	for(new i = 0; i < 6; i++)
	{
	    format(string, sizeof(string),
	    "{4582A1}Sasmelebi\t{4582A1}Fasi\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n\
	    {828282}- {FFFFFF}%s\t{33AA33}%d$\n",
	    club_item_list[0], club_item_price[0],club_item_list[1], club_item_price[1],club_item_list[2], club_item_price[2],
		club_item_list[3], club_item_price[3],club_item_list[4], club_item_price[4],club_item_list[5], club_item_price[5]);
	}
	ShowPlayerDialog(playerid, d_CLUB, DIALOG_STYLE_TABLIST_HEADERS, "{4582A1}Club",string, "Yidva","Gasvla");
	return 1;
}

stock ShowBankDialog(playerid)
{
    new string[400];
	strcat(string,"{86ec67}- {FFFFFF}Balansis shemowmeba\n");
	strcat(string,"{86ec67}- {FFFFFF}Tanxis moxsna angarishidan\n");
	strcat(string,"{86ec67}- {FFFFFF}Tanxis shetana angarishze\n");
	strcat(string,"{86ec67}- {FFFFFF}Saxlis angarishis shevseba\n");
	strcat(string,"{86ec67}- {FFFFFF}Biznesis angarishis shevseba\n");
	ShowPlayerDialog(playerid, d_BANK, DIALOG_STYLE_LIST, "{86ec67}Bank", string,"Archeva","Gamosvla");
}


stock CreateTrigger(Float:x,Float:y,Float:z)
{
	new Trigger = CreateObject(1317,x,y,z,0.0,0.0,0.0);
	SetObjectMaterial(Trigger,0,18646,"matcolours","blue",0xAA80FFDD);
	return Trigger;
}

stock gov_member(playerid)
{
	new member = PlayerInfo[playerid][pMember];
	if(member == 1 || member == 2 || member == 3 || member == 4) return 1;
	return 0;
}
stock ghetto_members(playerid)
{
	new member = PlayerInfo[playerid][pMember];
	if(member == 5 || member == 6 || member == 7 || member == 8 || member == 9) return 1;
	return 0;
}
stock mafia_members(playerid)
{
	new member = PlayerInfo[playerid][pMember];
	if(member == 10 || member == 11 || member == 12) return 1;
	return 0;
}

stock IsABike(carid){switch(GetVehicleModel(carid)){case 448,435,449,450,457,462,464,465,481,485,501,509,510,530,564,569,570,584,594,606,607,608,610,611:return true;}return false;}

stock SendRadioMessage(member, color, string[])
{
	foreach(new i:Player)
	{
		if(PlayerInfo[i][pMember] == member || PlayerInfo[i][pLeader] == member) SendClientMessage(i, color, string);
	}
}

stock SendFamilyMessage(member, color, string[])
{
	foreach(new i:Player)
	{
		if(PlayerInfo[i][pMember] == member || PlayerInfo[i][pLeader] == member) SendClientMessage(i, color, string);
	}
}
forward SendTeamMessage(team, color, string[]);
public SendTeamMessage(team, color, string[])
{
	foreach(new i:Player)
	{
		if(gov_member(i)) SendClientMessage(i, color, string);
	}
}

stock SendAdminMessage(color, string[])
{
	foreach(new x:Player)
	{
		if(PlayerInfo[x][pAdmin] > 0)
		{
		    SendClientMessage(x, color, string);
		}
	}
}

stock CheckHour()
{
	new hour, minute, second, tmphour, tmpminute, tmpsecond;
	gettime(hour, minute, second);
	gettime(tmphour, tmpminute, tmpsecond);
	FixHour(tmphour);
	tmphour = shifthour;

	if ((tmphour > ghour) || (tmphour == 0 && ghour == 23))
	{
		ghour = tmphour;
		new string[100];
		format(string, 126, "Mimdinare dro {FFFFFF}%d:00", ghour);
		SendClientMessageToAll(0xFF9900AA, string);
		PayDay();
		if (realtime) SetWorldTime(tmphour);
    }
}
stock PayDay()
{
	for(new i; i < TotalBizz; i ++)
	{
	    BizzInfo[i][bProfitHour] = 0;
		UpdateBizz(i);
		SaveBizz(i);
	}
	for(new i; i < TotalBizz; i ++)
	{
	    if(!BizzInfo[i][bOwned]) continue;
	    new targetid = GetPlayerID(BizzInfo[i][bOwner]);
	    if(BizzInfo[i][bTax] < GetBizzTax(i))
	    {
	        if(targetid != INVALID_PLAYER_ID)
	        {
				BizzInfo[i][bLock] = 1;
				BizzInfo[i][bLockTime] = 1;
				UpdateBizz(i);
				SaveBizz(i);

				SendErrorMessage(targetid, "Tqven biznesi daxurulia davalianebis gamo");
                new string[200];
			    format(string, sizeof(string), "{828282}* {EA4335}Tu davalianeba ar iqneba dafaruli %d saatshi, is gaiyideba avtomaturad", 12-BizzInfo[i][bLock]);
			    SendClientMessage(targetid, 0xFFFFFFFF, string);
	        }
	        else
	        {
	            BizzInfo[i][bLock] = 1;
				BizzInfo[i][bLockTime] = 1;
				UpdateBizz(i);
				SaveBizz(i);
	        }
	    }
	    else
	    {
	        BizzInfo[i][bTax] -= GetBizzTax(i);
	        UpdateBizz(i);
			SaveBizz(i);
	    }
	    if(BizzInfo[i][bLockTime] > 0)
	    {
	        BizzInfo[i][bLockTime] ++;
	    }
	    if(BizzInfo[i][bLockTime] > 12)
	    {
	        PlayerInfo[targetid][pBizz] = -1;
   			UpdatePlayerData(targetid, "pBizz", PlayerInfo[targetid][pBizz]);
			BizzInfo[i][bLock] = 1;
			BizzInfo[i][bOwned] = 0;
 			strmid(BizzInfo[i][bOwner], "The State", 0, strlen("The State"), 15);
			GiveServerMoney(targetid, BizzInfo[i][bPrice]*3/4);
   			UpdateBizz(i);
    		SaveBizz(i);
    		SendErrorMessage(targetid, "Tqven biznesi gaiyideba davalianebis gamo");
	    }
	}
  	for(new i; i < TotalHouse; i ++)
	{
	    if(!HouseInfo[i][hOwned]) continue;
	    if(HouseInfo[i][hTax] < GetHouseTax(i))
	    {
	        new targetid = GetPlayerID(HouseInfo[i][hOwner]);
	        if(targetid != INVALID_PLAYER_ID)
	        {
	   			PlayerInfo[targetid][pBank] += HouseInfo[i][hPrice]*3/4;
			    UpdatePlayerData(targetid, "pBank", PlayerInfo[targetid][pBank]);
			    PlayerInfo[targetid][pSetSpawn] = 0;
			    UpdatePlayerData(targetid, "pSetSpawn", PlayerInfo[targetid][pSetSpawn]);
			    PlayerInfo[targetid][pHouse] = -1;
			    UpdatePlayerData(targetid, "pHouse", PlayerInfo[targetid][pHouse]);

				SendErrorMessage(targetid, "Tqveni saxli gaiyida, angarishze arasakmarisi tanxis gamo");
			    new string[200];
			    format(string, sizeof(string), "{828282}* {EA4335}Tqven sabanko angarishze dairicxa saxlis girebulebis 75% (%$d)", HouseInfo[i][hPrice]);
			    SendClientMessage(targetid, 0xFFFFFFFF, string);

	     		strmid(HouseInfo[i][hOwner],"The State",0,strlen("The State"), MAX_PLAYER_NAME);
			    HouseInfo[i][hLock] = 1;
			    HouseInfo[i][hOwned] = 0;
			    HouseInfo[i][hTax] = 0;
			    UpdateHouse(i);
				SaveProperty(i);
			}
			else
			{
			}
	    }
	    else
	    {
	        HouseInfo[i][hTax] -= GetHouseTax(i);
	        UpdateHouse(i);
			SaveProperty(i);
	    }
	}
 	foreach(Player, i)
  	{
   		switch(PlayerInfo[i][pMember])
		{
			case 1:{ PlayerInfo[i][pSalary] += 1500*PlayerInfo[i][pRank]; } //PD
			case 2:{ PlayerInfo[i][pSalary] += 2500*PlayerInfo[i][pRank]; } //FBI
			case 3:{ PlayerInfo[i][pSalary] += 3000*PlayerInfo[i][pRank]; } //ARMY
			case 4:{ PlayerInfo[i][pSalary] += 4000*PlayerInfo[i][pRank]; } //RESIDENCE
		}
  		new salary = PlayerInfo[i][pSalary];
		PlayerInfo[i][pBank] += salary;
		UpdatePlayerData(i, "pBank", PlayerInfo[i][pBank]);

		// dasamatebelia saxelwmifo xazina + payday-ze nalogi mosaxleobas

		SendClientMessage(i, 0x73B461FF, "__________Bank check__________");
  		new str[500];
    	format(str, sizeof(str), "Xelfasi: $%d\n", salary);
     	SendClientMessage(i, -1, str);
      	format(str, sizeof(str), "Bankis mimdinare angarishi: $%d", PlayerInfo[i][pBank]);
       	SendClientMessage(i, -1, str);
       	if(PlayerInfo[i][pWarn] > 0)
		{
		    PlayerInfo[i][pUnwarntime] ++;
			UpdatePlayerData(i, "pUnwarntime", PlayerInfo[i][pUnwarntime]);
			if(PlayerInfo[i][pUnwarntime] >=10)
			{
			    SendInfoMessage(i, "Tqven mogexsnat 1 Warn");
			    PlayerInfo[i][pUnwarntime] = 0;
		    	UpdatePlayerData(i, "pUnwarntime", PlayerInfo[i][pUnwarntime]);
				PlayerInfo[i][pWarn] -= 1;
				UpdatePlayerData(i, "pWarn", PlayerInfo[i][pWarn]);
				return true;
			}
		}
       	SendClientMessage(i, 0x73B461FF , " __________________________________");
        PlayerInfo[i][pSalary] = 0;
		new string[10];
  		format(string, sizeof(string), "~y~PAYDAY");
		GameTextForPlayer(i, string, 3000, 1);
		
	}
	return true;
}

stock FixHour(hour)
{
	hour = timeshift+hour;
	if (hour < 0) { hour = hour+24; }
	else if (hour > 23) { hour = hour-24; }
	shifthour = hour;
	return 1;
}


public OnPlayerDisconnect(playerid, reason)
{
	if(PlayerInfo[playerid][pLogin] == 1)
	{
	    PlayerInfo[playerid][pLogin] = 0;
	}
	if(GetPVarInt(playerid, "FracDuty") == 1)
    {
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
		DeletePVar(playerid, "FracDuty");
    }
   	for(new i = 0; i < 8; i++) TextDrawHideForPlayer(playerid, enable_skin_TD[i]);
	return true;
}

public OnPlayerSpawn(playerid)
{
	if(PlayerInfo[playerid][pLogin] == 0)
	{
	    SendErrorMessage(playerid, "Tqven ar gagivliat avtorizacia");
	    Kick(playerid);
	}
	switch(PlayerInfo[playerid][pSetSpawn])
	{
	    case 0:
	    {
	        if(PlayerInfo[playerid][pLogin] == 1)
			{
			    SetPlayerPos(playerid, 1762.3068,-1897.8140,13.5629);
			}
	    }
		case 1:
		{
		    if(PlayerInfo[playerid][pHouse] != -1)
			{
			    new h = PlayerInfo[playerid][pHouse];
			    SetPlayerPos(playerid,HouseInfo[h][hExit_X],HouseInfo[h][hExit_Y],HouseInfo[h][hExit_Z]);
			    SetPlayerInterior(playerid,HouseInfo[h][hInt]);
				SetPlayerVirtualWorld(playerid,h+50);
			 	/* ---------------------------------------------- */
				TogglePlayerControllable(playerid, 0);
				SetTimerEx("FREEZE" , 2000, false, "d", playerid);
				/*---------------------------------------------- */
			}
		}
		case 2:
		{
		    if(PlayerInfo[playerid][pMember])
		    {
		        switch(PlayerInfo[playerid][pMember])
		        {
		            case 1:
		            {
		                SetPlayerPos(playerid, 1408.2394,-20.2247,1504.5602);
		                SetPlayerFacingAngle(playerid, 357.2126);
		                SetPlayerInterior(playerid, 2);
		                SetPlayerVirtualWorld(playerid, 2);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
		            case 2:
		            {
                  		SetPlayerPos(playerid, 1689.4285,-1418.7601,3087.0383);
		                SetPlayerFacingAngle(playerid, 86.8501);
		                SetPlayerInterior(playerid, 2);
		                SetPlayerVirtualWorld(playerid, 2);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
              		case 3:
		            {
                  		SetPlayerPos(playerid, 292.0774,1939.2260,5.1380);
		                SetPlayerFacingAngle(playerid, 91.8058);
		                SetPlayerInterior(playerid, 2);
		                SetPlayerVirtualWorld(playerid, 2);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
              		case 4:
		            {
                  		SetPlayerPos(playerid, -793.2617,-688.3517,4004.5850);
		                SetPlayerFacingAngle(playerid, 11.7308);
		                SetPlayerInterior(playerid, 2);
		                SetPlayerVirtualWorld(playerid, 2);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
		            case 5:
		            {
                  		SetPlayerPos(playerid, 2013.9065,1343.9182,632.0748);
		                SetPlayerFacingAngle(playerid, 180.9447);
		                SetPlayerInterior(playerid, 1);
		                SetPlayerVirtualWorld(playerid, 1);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
              		case 6:
		            {
                  		SetPlayerPos(playerid, 2013.9065,1343.9182,632.0748);
		                SetPlayerFacingAngle(playerid, 180.9447);
		                SetPlayerInterior(playerid, 1);
		                SetPlayerVirtualWorld(playerid, 2);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
		            case 7:
		            {
                  		SetPlayerPos(playerid, 2013.9065,1343.9182,632.0748);
		                SetPlayerFacingAngle(playerid, 180.9447);
		                SetPlayerInterior(playerid, 1);
		                SetPlayerVirtualWorld(playerid, 3);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
              		case 8:
		            {
                  		SetPlayerPos(playerid, 2013.9065,1343.9182,632.0748);
		                SetPlayerFacingAngle(playerid, 180.9447);
		                SetPlayerInterior(playerid, 1);
		                SetPlayerVirtualWorld(playerid, 4);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
              		case 9:
		            {
                  		SetPlayerPos(playerid, 2013.9065,1343.9182,632.0748);
		                SetPlayerFacingAngle(playerid, 180.9447);
		                SetPlayerInterior(playerid, 1);
		                SetPlayerVirtualWorld(playerid, 5);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
		            case 10:
		            {
             			SetPlayerPos(playerid, -2237.7754,717.5922,3001.5166);
		                SetPlayerFacingAngle(playerid, 177.4549);
		                SetPlayerInterior(playerid, 5);
		                SetPlayerVirtualWorld(playerid, 1);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
              		case 11:
		            {
             			SetPlayerPos(playerid, -2237.7754,717.5922,3001.5166);
		                SetPlayerFacingAngle(playerid, 177.4549);
		                SetPlayerInterior(playerid, 5);
		                SetPlayerVirtualWorld(playerid, 2);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
              		case 12:
		            {
             			SetPlayerPos(playerid, -2237.7754,717.5922,3001.5166);
		                SetPlayerFacingAngle(playerid, 177.4549);
		                SetPlayerInterior(playerid, 5);
		                SetPlayerVirtualWorld(playerid, 3);
		                /* ---------------------------------------------- */
						TogglePlayerControllable(playerid, 0);
						SetTimerEx("FREEZE" , 2000, false, "d", playerid);
						/*---------------------------------------------- */
		            }
		        }
		    }
		}
	}
	if(ghetto_members(playerid) || mafia_members(playerid))
	{
	    SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
	}
	else
	{
 		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	}
	if(GetPVarInt(playerid, "FracDuty") == 1)
    {
		SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
		DeletePVar(playerid, "FracDuty");
    }
	SetPlayerToTeamColor(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	vInfo[vehicleid][vX] = 0.0;
	vInfo[vehicleid][vY] = 0.0;
	vInfo[vehicleid][vZ] = 0.0;
	vInfo[vehicleid][vLights] = false;
	vInfo[vehicleid][vEngine] = false;
	vInfo[vehicleid][vLock] = false;
	SetVehicleHealth(vehicleid,999);
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
    if(PlayerInfo[playerid][pLogin] == 0) return 0;
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

forward OnPlayerCommandReceived(playerid, cmd[], params[], flags);
public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(PlayerInfo[playerid][pLogin] == 0) return 0;
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{ 
    if(newstate == PLAYER_STATE_DRIVER)
    {
        if(!IsABike(GetPlayerVehicleID(playerid)))
        {
	     	for(new i = 0; i < 10; i++) TextDrawShowForPlayer(playerid, SpeedTextDraw[i]);
			for(new i = 0; i < 6; i++) PlayerTextDrawShow(playerid, SpeedTextDraws[playerid][i]);
		    SendInfoMessage(playerid, "Manqanis dzravis asamushaveblad daachiret CTRL");
            PlayerInfo[playerid][pSpeedometerTimer] = SetTimerEx("UpdateSpeedometr", 250, true, "i", playerid);
		}
    }
    if(oldstate == PLAYER_STATE_DRIVER)
	{
		for(new i = 0; i < 10; i++) TextDrawHideForPlayer(playerid, SpeedTextDraw[i]);
		for(new i = 0; i < 6; i++) PlayerTextDrawHide(playerid, SpeedTextDraws[playerid][i]);
   		KillTimer(PlayerInfo[playerid][pSpeedometerTimer]);
	}
    if(newstate == PLAYER_STATE_DRIVER)
	{
		new veh = GetPlayerVehicleID(playerid);
		if(veh >= pdcar[0] && veh <= pdcar[18])
		{
			if(PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pMember] == 1)
			{
			    if(GetPVarInt(playerid, "FracDuty") != 1) return SendErrorMessage(playerid, "Tqven ar dagiwyiat samushao dge");
			    RemovePlayerFromVehicle(playerid);
		 	}
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"Police Department\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
		if(veh >= fbicar[0] && veh <= fbicar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 2 || PlayerInfo[playerid][pMember] == 2)
			{
				if(GetPVarInt(playerid, "FracDuty") != 1) return SendErrorMessage(playerid, "Tqven ar dagiwyiat samushao dge");
			    RemovePlayerFromVehicle(playerid);
			}
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"F.B.I\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
		if(veh >= armycar[0] && veh <= armycar[32])
		{
			if(PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pMember] == 3)
			{
			    if(GetPVarInt(playerid, "FracDuty") != 1) return SendErrorMessage(playerid, "Tqven ar dagiwyiat samushao dge");
			    RemovePlayerFromVehicle(playerid);
		 	}
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"National Army\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
  		if(veh >= rescar[0] && veh <= rescar[7])
		{
			if(PlayerInfo[playerid][pLeader] == 4 || PlayerInfo[playerid][pMember] == 4)
			{
			    if(GetPVarInt(playerid, "FracDuty") != 1) return SendErrorMessage(playerid, "Tqven ar dagiwyiat samushao dge");
			    RemovePlayerFromVehicle(playerid);
			}
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"Prezidentis rezidencias\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
		if(veh >= ballascar[0] && veh <= ballascar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 5 || PlayerInfo[playerid][pMember] == 5) { }
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"The Ballas Gang\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
		if(veh >= grovecar[0] && veh <= grovecar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 6 || PlayerInfo[playerid][pMember] == 6) { }
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"The Grove Gang\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
  		if(veh >= vagoscar[0] && veh <= vagoscar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 8 || PlayerInfo[playerid][pMember] == 8) { }
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"The Vagos Gang\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
  		if(veh >= aztecascar[0] && veh <= aztecascar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 9 || PlayerInfo[playerid][pMember] == 9) { }
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"The Aztecas Gang\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
    	if(veh >= rifacar[0] && veh <= rifacar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 7 || PlayerInfo[playerid][pMember] == 7) { }
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"The Rifa Gang\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
		if(veh >= lcncar[0] && veh <= lcncar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 10 || PlayerInfo[playerid][pMember] == 10) { }
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"The Mafia La Cosa Nostra\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
  		if(veh >= yakcar[0] && veh <= yakcar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 11 || PlayerInfo[playerid][pMember] == 11) { }
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"The Mafia Yakudza\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
		if(veh >= rmcar[0] && veh <= rmcar[8])
		{
			if(PlayerInfo[playerid][pLeader] == 12 || PlayerInfo[playerid][pMember] == 12) { }
			else
			{
			    SendErrorMessage(playerid, "Es transporti ekutvnis: - \"The Mafia Russian Mafia\"");
				RemovePlayerFromVehicle(playerid);
			}
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(gps[playerid])
	{
	    gps[playerid] = false;
	    DisablePlayerRaceCheckpoint(playerid);
	    GameTextForPlayer(playerid, "GPS: OFF", 0, 1);
	}
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	for(new i; i < TotalBizz; i ++)
	{
	    if(i < TotalBizz && checkpointid == BizzCP[i])
	    {
	        if(!BizzInfo[i][bOwned])
	        {
	            ShowPlayerDialog(playerid, d_BUYBIZZ, DIALOG_STYLE_MSGBOX, "BUSSINES", "{86ec67}- {FFFFFF}Gsurt biznesis shedzena?", "Diax", "Ara");
	        }
	        if(BizzInfo[i][bOwned])
	        {
	            ShowPlayerDialog(playerid, d_BIZZINFO, DIALOG_STYLE_MSGBOX, "BUSSINES", "{86ec67}- {FFFFFF}Gsurt shesvla?", "Diax", "Ara");
	        }
	        SetPVarInt(playerid, "BUSINESS_ID", i);
	    }
	}
	for(new i; i < TotalHouse; i ++)
	{
		if(i < TotalHouse && checkpointid == HouseCP[i])
		{
            if(!HouseInfo[i][hOwned])
  			{
 				ShowPlayerDialog(playerid, d_BUYHOUSE, DIALOG_STYLE_MSGBOX, "Saxli iyideba", "Gsurt saxlis shedzena?", "Diax", "Ara");
	    	}
		    else
		    {
      			ShowPlayerDialog(playerid, d_HOUSEINFO, DIALOG_STYLE_MSGBOX, "Saxli dakavebulia", "Gsurt saxlshi shesvla?", "Diax", "Ara");
		    }
		}
	}
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
    if(pickupid == BankPick[0])
	{
	    SetPlayerPos(playerid, 1480.9247,-1770.5258,18.7929);
	    SetPlayerFacingAngle(playerid, 0.6122);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == BankPick[1])
	{
	    SetPlayerPos(playerid, 303.6361,1330.4989,2023.8380);
	    SetPlayerFacingAngle(playerid, 48.3215);
	    SetPlayerVirtualWorld(playerid, 3);
	    SetPlayerInterior(playerid, 3);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == PolicePick[0])
	{
	    SetPlayerPos(playerid, 1552.7719,-1675.4928,16.1953);
	    SetPlayerFacingAngle(playerid, 89.7554);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == PolicePick[1])
	{
	    SetPlayerPos(playerid, 1378.1785,-27.3974,1504.5602);
	    SetPlayerFacingAngle(playerid, 267.3461);
	    SetPlayerVirtualWorld(playerid, 2);
	    SetPlayerInterior(playerid, 2);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == FBIPick[0])
	{
	    SetPlayerPos(playerid, 939.3333,-1717.8876,13.8423);
	    SetPlayerFacingAngle(playerid, 91.0699);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == FBIPick[1])
	{
        SetPlayerPos(playerid, 1672.9795,-1401.6713,3087.0383);
	    SetPlayerFacingAngle(playerid, 270.4091);
	    SetPlayerVirtualWorld(playerid, 2);
	    SetPlayerInterior(playerid, 2);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == ArmyPick[0])
	{
	    SetPlayerPos(playerid, 152.4454,1829.8981,17.6481);
	    SetPlayerFacingAngle(playerid, 180.9503);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == ArmyPick[1])
	{
        SetPlayerPos(playerid, 250.9918,1932.4318,5.1380);
	    SetPlayerFacingAngle(playerid, 270.1636);
	    SetPlayerVirtualWorld(playerid, 2);
	    SetPlayerInterior(playerid, 2);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == ResPick[0])
	{
	    SetPlayerPos(playerid, 1126.0839,-2037.1696,69.8836);
	    SetPlayerFacingAngle(playerid, 268.3816);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == ResPick[1])
	{
        SetPlayerPos(playerid, -787.3594,-665.5316,4001.0859);
	    SetPlayerFacingAngle(playerid, 93.3076);
	    SetPlayerVirtualWorld(playerid, 2);
	    SetPlayerInterior(playerid, 2);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == BallasPick[0])
	{
	    SetPlayerPos(playerid, 2000.1322,-1115.3987,27.1318);
	    SetPlayerFacingAngle(playerid, 179.4423);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == BallasPick[1])
	{
        SetPlayerPos(playerid, 2014.5332,1318.7330,632.0648);
	    SetPlayerFacingAngle(playerid, 0.5468);
	    SetPlayerVirtualWorld(playerid, 1);
	    SetPlayerInterior(playerid, 1);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == GrovePick[0])
	{
	    SetPlayerPos(playerid, 2521.8171,-1679.2455,15.4970);
	    SetPlayerFacingAngle(playerid, 87.3627);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == GrovePick[1])
	{
       	SetPlayerPos(playerid, 2014.5332,1318.7330,632.0648);
	    SetPlayerFacingAngle(playerid, 0.5468);
	    SetPlayerVirtualWorld(playerid, 2);
	    SetPlayerInterior(playerid, 1);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == RifaPick[0])
	{
	    SetPlayerPos(playerid, 2785.3162,-1926.3407,13.5469);
	    SetPlayerFacingAngle(playerid, 88.3672);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == RifaPick[1])
	{
        SetPlayerPos(playerid, 2014.5332,1318.7330,632.0648);
	    SetPlayerFacingAngle(playerid, 0.5468);
	    SetPlayerVirtualWorld(playerid, 3);
	    SetPlayerInterior(playerid, 1);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == VagosPick[0])
	{
	    SetPlayerPos(playerid, 2756.4670,-1181.2284,69.3964);
	    SetPlayerFacingAngle(playerid, 1.2699);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == VagosPick[1])
	{
        SetPlayerPos(playerid, 2014.5332,1318.7330,632.0648);
	    SetPlayerFacingAngle(playerid, 0.5468);
	    SetPlayerVirtualWorld(playerid, 4);
	    SetPlayerInterior(playerid, 1);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == AztecasPick[0])
	{
	    SetPlayerPos(playerid, 2185.9885,-1812.9164,13.5550);
	    SetPlayerFacingAngle(playerid, 358.6102);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == AztecasPick[1])
	{
        SetPlayerPos(playerid, 2014.5332,1318.7330,632.0648);
	    SetPlayerFacingAngle(playerid, 0.5468);
	    SetPlayerVirtualWorld(playerid, 5);
	    SetPlayerInterior(playerid, 1);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == LcnPick[0])
	{
	    SetPlayerPos(playerid, 2482.8652,1526.8008,11.3656);
	    SetPlayerFacingAngle(playerid, 323.7085);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == LcnPick[1])
	{
        SetPlayerPos(playerid, -2216.6519,688.3545,3001.5159);
	    SetPlayerFacingAngle(playerid, 358.7318);
	    SetPlayerVirtualWorld(playerid, 1);
	    SetPlayerInterior(playerid, 5);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == YakPick[0])
	{
	    SetPlayerPos(playerid, 1459.1748,2773.6685,10.8203);
	    SetPlayerFacingAngle(playerid, 266.9089);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == YakPick[1])
	{
        SetPlayerPos(playerid, -2216.6519,688.3545,3001.5159);
	    SetPlayerFacingAngle(playerid, 358.7318);
	    SetPlayerVirtualWorld(playerid, 2);
	    SetPlayerInterior(playerid, 5);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == RmPick[0])
	{
	    SetPlayerPos(playerid, 938.9464,1733.6953,8.8516);
	    SetPlayerFacingAngle(playerid, 265.3135);
	    SetPlayerVirtualWorld(playerid, 0);
	    SetPlayerInterior(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == RmPick[1])
	{
        SetPlayerPos(playerid, -2216.6519,688.3545,3001.5159);
	    SetPlayerFacingAngle(playerid, 358.7318);
	    SetPlayerVirtualWorld(playerid, 3);
	    SetPlayerInterior(playerid, 5);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	if(pickupid == AmmoPick[0])
	{
	    SetPlayerPos(playerid, 2860.7183,800.0045-2.0,801.7853);
	    SetPlayerFacingAngle(playerid, 179.4547);
	    SetPlayerVirtualWorld(playerid, 5);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
 	if(pickupid == AmmoPick[1])
	{
	    SetPlayerPos(playerid, 1367.0569,-1280.0521,13.5469);
	    SetPlayerFacingAngle(playerid, 90.1961);
	    SetPlayerVirtualWorld(playerid, 0);
	    /* ---------------------------------------------- */
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("FREEZE" , 2000, false, "d", playerid);
		/*---------------------------------------------- */
	}
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_WALK) //alt
	{
	    for(new i; i < TotalBizz; i ++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 2.0, BizzInfo[i][bExit_X], BizzInfo[i][bExit_Y], BizzInfo[i][bExit_Z]))
			{
				SetPlayerInterior(playerid,0);
				SetPlayerVirtualWorld(playerid,0);
				SetPlayerPos(playerid,BizzInfo[i][bEnter_X],BizzInfo[i][bEnter_Y],BizzInfo[i][bEnter_Z]);
			}
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.0, 292.6172,1339.6455,2023.8380) || IsPlayerInRangeOfPoint(playerid, 1.0, 292.6619,1346.0580,2023.8380) || IsPlayerInRangeOfPoint(playerid, 1.0, 292.4394,1352.2371,2023.8380))
		{
		    ShowBankDialog(playerid);
		}
		for(new i; i < TotalFill; i ++)
		{
		    if(IsPlayerInRangeOfPoint(playerid, 2.0, FillInfo[i][fMenu_X], FillInfo[i][fMenu_Y], FillInfo[i][fMenu_Z]))
		    {
		        if(FillInfo[i][fOwned])
		        {
		            SendErrorMessage(playerid, "Am benzin gasamart sadgurs ukve yavs mflobeli.");
		        }
		        if(!FillInfo[i][fOwned])
		        {
					ShowPlayerDialog(playerid, d_BUYFILLING, DIALOG_STYLE_MSGBOX, "-", "{828282}-  {FFFFFF}Gsurt sheidzinot es benzin gasamarti sadguri?", "Diax", "Gamosvla");
		        }
		    }
		}
	  	if(IsPlayerInRangeOfPoint(playerid, 1.0, 1402.6268,-20.9833,1504.5602)) //pd
		{
		    if(PlayerInfo[playerid][pMember] == 1)
		    {
		        if(GetPVarInt(playerid, "FracDuty") == 1)
		        {
		            ShowPlayerDialog(playerid, d_CHANGEDUTYFORM, DIALOG_STYLE_MSGBOX, "{86ec67}- {FFFFFF}Duty Form", "{FFFFFF}Gsurt gamoicvalot samushao forma?", "Archeva", "Gamosvla");
		        }
		        else
		        {
		        	ShowPlayerDialog(playerid, d_DUTYFORM, DIALOG_STYLE_MSGBOX, "{86ec67}- {FFFFFF}Duty Form", "{FFFFFF}Gsurt samushao formis chacma?", "Archeva", "Gamosvla");
				}
		    }
		    else
		    {
		        SendErrorMessage(playerid, "Tqven ar xart policieli");
		    }
		}
	 	if(IsPlayerInRangeOfPoint(playerid, 1.0, 1689.4038,-1413.8408,3087.0383)) //FBI
		{
		    if(PlayerInfo[playerid][pMember] == 2)
		    {
		        if(GetPVarInt(playerid, "FracDuty") == 1)
		        {
		            ShowPlayerDialog(playerid, d_CHANGEDUTYFORM, DIALOG_STYLE_MSGBOX, "{86ec67}- {FFFFFF}Duty Form", "{FFFFFF}Gsurt gamoicvalot samushao forma?", "Archeva", "Gamosvla");
		        }
		        else
		        {
		        	ShowPlayerDialog(playerid, d_DUTYFORM, DIALOG_STYLE_MSGBOX, "{86ec67}- {FFFFFF}Duty Form", "{FFFFFF}Gsurt samushao formis chacma?", "Archeva", "Gamosvla");
				}
		    }
		    else
		    {
		        SendErrorMessage(playerid, "Tqven ar xart F.B.I agenti");
		    }
		}
	 	if(IsPlayerInRangeOfPoint(playerid, 1.0, 291.7471,1936.1003,5.1380)) //ARMY
		{
		    if(PlayerInfo[playerid][pMember] == 3)
		    {
		        if(GetPVarInt(playerid, "FracDuty") == 1)
		        {
		            ShowPlayerDialog(playerid, d_CHANGEDUTYFORM, DIALOG_STYLE_MSGBOX, "{86ec67}- {FFFFFF}Duty Form", "{FFFFFF}Gsurt gamoicvalot samushao forma?", "Archeva", "Gamosvla");
		        }
		        else
		        {
		        	ShowPlayerDialog(playerid, d_DUTYFORM, DIALOG_STYLE_MSGBOX, "{86ec67}- {FFFFFF}Duty Form", "{FFFFFF}Gsurt samushao formis chacma?", "Archeva", "Gamosvla");
				}
		    }
		    else
		    {
		        SendErrorMessage(playerid, "Tqven ar xart jariskaci");
		    }
		}
	 	if(IsPlayerInRangeOfPoint(playerid, 1.0, -792.9036,-687.9256,4004.5850)) //RESIDENCE
		{
		    if(PlayerInfo[playerid][pMember] == 4)
		    {
		        if(GetPVarInt(playerid, "FracDuty") == 1)
		        {
		            ShowPlayerDialog(playerid, d_CHANGEDUTYFORM, DIALOG_STYLE_MSGBOX, "{86ec67}- {FFFFFF}Duty Form", "{FFFFFF}Gsurt gamoicvalot samushao forma?", "Archeva", "Gamosvla");
		        }
		        else
		        {
		        	ShowPlayerDialog(playerid, d_DUTYFORM, DIALOG_STYLE_MSGBOX, "{86ec67}- {FFFFFF}Duty Form", "{FFFFFF}Gsurt samushao formis chacma?", "Archeva", "Gamosvla");
				}
		    }
		    else
		    {
		        SendErrorMessage(playerid, "Tqven ar xart prezidentis rezidenciis wevri");
		    }
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.0, 1405.2507,-33.4383,1504.5602)) //pd
	 	{
	 	    if(GetPlayerVirtualWorld(playerid) == 2)
			{
			    if(wInfo[1][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 1) return SendErrorMessage(playerid, "Es ar aris tqveni organizaciis sawyobi");
				if(GetPVarInt(playerid, "FracDuty") != 1) return SendErrorMessage(playerid, "Tqven ar dagiwyiat samushao dge");
				ShowPlayerDialog(playerid, d_GETGUN,DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Select Gun", "{86ec67}- {FFFFFF}M4\n{86ec67}- {FFFFFF}Silenced 9mm\n{86ec67}- {FFFFFF}Shotgun\n{86ec67}- {FFFFFF}MP5\n{86ec67}- {FFFFFF}Nightstick\n{86ec67}- {FFFFFF}Armor", "Archeva", "Gamosvla");
			}
	 	}
	 	if(IsPlayerInRangeOfPoint(playerid, 1.0, 1688.7605,-1419.7156,3087.0383)) //fbi
	 	{
	 	    if(GetPlayerVirtualWorld(playerid) == 2)
			{
			    if(wInfo[2][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 2) return SendErrorMessage(playerid, "Es ar aris tqveni organizaciis sawyobi");
				if(GetPVarInt(playerid, "FracDuty") != 1) return SendErrorMessage(playerid, "Tqven ar dagiwyiat samushao dge");
				ShowPlayerDialog(playerid, d_GETGUN,DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Select Gun", "{86ec67}- {FFFFFF}M4\n{86ec67}- {FFFFFF}Silenced 9mm\n{86ec67}- {FFFFFF}Shotgun\n{86ec67}- {FFFFFF}MP5\n{86ec67}- {FFFFFF}Nightstick\n{86ec67}- {FFFFFF}Armor", "Archeva", "Gamosvla");
			}
	 	}
   		if(IsPlayerInRangeOfPoint(playerid, 1.0, 274.0574,1923.0823,5.1380)) //army
	 	{
	 	    if(GetPlayerVirtualWorld(playerid) == 2)
			{
			    if(wInfo[13][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 3) return SendErrorMessage(playerid, "Es ar aris tqveni organizaciis sawyobi");
				if(GetPVarInt(playerid, "FracDuty") != 1) return SendErrorMessage(playerid, "Tqven ar dagiwyiat samushao dge");
				ShowPlayerDialog(playerid, d_GETGUN,DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Select Gun", "{86ec67}- {FFFFFF}M4\n{86ec67}- {FFFFFF}Silenced 9mm\n{86ec67}- {FFFFFF}Shotgun\n{86ec67}- {FFFFFF}MP5\n{86ec67}- {FFFFFF}Nightstick\n{86ec67}- {FFFFFF}Armor", "Archeva", "Gamosvla");
			}
	 	}
   		if(IsPlayerInRangeOfPoint(playerid, 1.0, -807.6265,-688.1851,4001.0859)) //residence
	 	{
	 	    if(GetPlayerVirtualWorld(playerid) == 2)
			{
			    if(wInfo[4][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 4) return SendErrorMessage(playerid, "Es ar aris tqveni organizaciis sawyobi");
				if(GetPVarInt(playerid, "FracDuty") != 1) return SendErrorMessage(playerid, "Tqven ar dagiwyiat samushao dge");
				ShowPlayerDialog(playerid, d_GETGUN,DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Select Gun", "{86ec67}- {FFFFFF}M4\n{86ec67}- {FFFFFF}Silenced 9mm\n{86ec67}- {FFFFFF}Shotgun\n{86ec67}- {FFFFFF}MP5\n{86ec67}- {FFFFFF}Nightstick\n{86ec67}- {FFFFFF}Armor", "Archeva", "Gamosvla");
			}
	 	}
		if(IsPlayerInRangeOfPoint(playerid, 1.0, 2014.4634,1344.8119,632.0748))  //ghetto
	 	{
			if(GetPlayerVirtualWorld(playerid) == 1)
			{
				if(wInfo[5][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 5) return SendErrorMessage(playerid, "Es sawyobi ar aris tqveni bandis");
				ShowPlayerDialog(playerid, d_GANGSTORE, DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Gang Store", "{FFFFFF}- Tyviebis ageba\n- Narkotikis ageba\n- Tanxis ageba sawyobidan\n{73BB73}- Tyviebis chadeba\n{73BB73}- Narkotikis chadeba\n{73BB73}- Tanxis chadeba sawyobshi", "Archeva", "Gamosvla");
			}
			if(GetPlayerVirtualWorld(playerid) == 2)
			{
				if(wInfo[6][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 6) return SendErrorMessage(playerid, "Es sawyobi ar aris tqveni bandis");
				ShowPlayerDialog(playerid, d_GANGSTORE, DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Gang Store", "{FFFFFF}- Tyviebis ageba\n- Narkotikis ageba\n- Tanxis ageba sawyobidan\n{73BB73}- Tyviebis chadeba\n{73BB73}- Narkotikis chadeba\n{73BB73}- Tanxis chadeba sawyobshi", "Archeva", "Gamosvla");
			}
			if(GetPlayerVirtualWorld(playerid) == 3)
			{
				if(wInfo[7][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 7) return SendErrorMessage(playerid, "Es sawyobi ar aris tqveni bandis");
				ShowPlayerDialog(playerid, d_GANGSTORE, DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Gang Store", "{FFFFFF}- Tyviebis ageba\n- Narkotikis ageba\n- Tanxis ageba sawyobidan\n{73BB73}- Tyviebis chadeba\n{73BB73}- Narkotikis chadeba\n{73BB73}- Tanxis chadeba sawyobshi", "Archeva", "Gamosvla");
			}
            if(GetPlayerVirtualWorld(playerid) == 4)
			{
				if(wInfo[8][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 8) return SendErrorMessage(playerid, "Es sawyobi ar aris tqveni bandis");
				ShowPlayerDialog(playerid, d_GANGSTORE, DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Gang Store", "{FFFFFF}- Tyviebis ageba\n- Narkotikis ageba\n- Tanxis ageba sawyobidan\n{73BB73}- Tyviebis chadeba\n{73BB73}- Narkotikis chadeba\n{73BB73}- Tanxis chadeba sawyobshi", "Archeva", "Gamosvla");
			}
   			if(GetPlayerVirtualWorld(playerid) == 5)
			{
				if(wInfo[9][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 9) return SendErrorMessage(playerid, "Es sawyobi ar aris tqveni bandis");
				ShowPlayerDialog(playerid, d_GANGSTORE, DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Gang Store", "{FFFFFF}- Tyviebis ageba\n- Narkotikis ageba\n- Tanxis ageba sawyobidan\n{73BB73}- Tyviebis chadeba\n{73BB73}- Narkotikis chadeba\n{73BB73}- Tanxis chadeba sawyobshi", "Archeva", "Gamosvla");
			}
	 	}
   		if(IsPlayerInRangeOfPoint(playerid, 1.0, -2243.6067,717.5988,3001.5166)) //mafia
	 	{
			if(GetPlayerVirtualWorld(playerid) == 1)
			{
			    if(wInfo[10][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 10) return SendErrorMessage(playerid, "Es sawyobi ar aris tqveni mafiis");
				ShowPlayerDialog(playerid, d_GANGSTORE, DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Gang Store", "{FFFFFF}- Tyviebis ageba\n- Narkotikis ageba\n- Tanxis ageba sawyobidan\n{73BB73}- Tyviebis chadeba\n{73BB73}- Narkotikis chadeba\n{73BB73}- Tanxis chadeba sawyobshi", "Archeva", "Gamosvla");
			}
			if(GetPlayerVirtualWorld(playerid) == 2)
			{
			    if(wInfo[11][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 11) return SendErrorMessage(playerid, "Es sawyobi ar aris tqveni mafiis");
				ShowPlayerDialog(playerid, d_GANGSTORE, DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Gang Store", "{FFFFFF}- Tyviebis ageba\n- Narkotikis ageba\n- Tanxis ageba sawyobidan\n{73BB73}- Tyviebis chadeba\n{73BB73}- Narkotikis chadeba\n{73BB73}- Tanxis chadeba sawyobshi", "Archeva", "Gamosvla");
			}
			if(GetPlayerVirtualWorld(playerid) == 3)
			{
			    if(wInfo[12][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
				if(PlayerInfo[playerid][pMember] != 12) return SendErrorMessage(playerid, "Es sawyobi ar aris tqveni mafiis");
				ShowPlayerDialog(playerid, d_GANGSTORE, DIALOG_STYLE_LIST, "{86ec67}- {FFFFFF}Gang Store", "{FFFFFF}- Tyviebis ageba\n- Narkotikis ageba\n- Tanxis ageba sawyobidan\n{73BB73}- Tyviebis chadeba\n{73BB73}- Narkotikis chadeba\n{73BB73}- Tanxis chadeba sawyobshi", "Archeva", "Gamosvla");
			}
		}
	}
	if(newkeys == KEY_YES)
	{
     	if(GetPVarInt(playerid, "InviteMember") > 0)
	    {
	        PlayerInfo[playerid][pMember] = GetPVarInt(playerid, "InviteMember");
	        PlayerInfo[playerid][pRank] = 1;
	        PlayerInfo[playerid][pModel] = FractionDefaultSkin[GetPVarInt(playerid, "InviteMember")];
			SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
			SetPlayerToTeamColor(playerid);
			DeletePVar(playerid, "InviteMember");
			UpdatePlayerData(playerid, "pMember", PlayerInfo[playerid][pMember]);
			UpdatePlayerData(playerid, "pRank", PlayerInfo[playerid][pRank]);
			UpdatePlayerData(playerid, "pModel", PlayerInfo[playerid][pModel]);
			new str[36 + MAX_PLAYER_NAME - 4];
			SetPVarInt(GetPVarInt(playerid,"Inviter"), "Invited", playerid);
			format(str, sizeof(str), "%s daetanxma organizaciashi gawevrianebas.", GetName(playerid));
			SendClientMessage(GetPVarInt(playerid,"Inviter"), 0xFFFFFFFF, str);
			new string[100];
			string[0] = EOS;
			for(new i = 0; i < 10; i++)
			{
			    new skin = FractionSkins[PlayerInfo[playerid][pMember]][i];
			    if(skin == 1) break;
			    format(string, sizeof(string), "%s[%d]\n", string, skin);
			}
			PlayerInfo[playerid][pSetSpawn] = 2;
			ShowPlayerDialog(GetPVarInt(playerid,"Inviter"), d_CHANGEFRACSKIN, DIALOG_STYLE_LIST, "Change Skin", string, "Shemdegi", "Gamosvla");
            DeletePVar(playerid, "Inviter");
	    }
	}
	if(newkeys == KEY_NO) //n
	{
	    for(new i; i < TotalBizz; i ++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 2.0, BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z]))
			{
			    switch(BizzInfo[i][bType])
			    {
			        case 1: show_market_dialog(playerid);
			        case 2: show_burger_dialog(playerid);
			        case 3: show_club_dialog(playerid);
			        case 4:
			        {
			            new string[128];
						SetPlayerPos(playerid, 459.9371,-1510.9280,3001.1060);
						SetPlayerFacingAngle(playerid, 357.8251);
						SetPlayerCameraPos(playerid,460.030395,-1506.320678,3002.574707);
						SetPlayerCameraLookAt(playerid,459.943572,-1516.138061,3000.674072);
		    			SetPlayerInterior(playerid, 2);
						SetPlayerVirtualWorld(playerid, playerid);
						SendInfoMessage(playerid, "Airchiet sasurveli tansacmeli");
		    			TogglePlayerControllable(playerid, 0);
						for(new x; x < 8; x++) TextDrawShowForPlayer(playerid, enable_skin_TD[x]);
						SelectTextDraw(playerid, 0xFFCC00FF),SetPVarInt(playerid, "SelectTextDrawEnter", 1);
						if(PlayerInfo[playerid][pSex] == 1)
						{
							SelectCharPlace[playerid] = 0;
							SetPlayerSkin(playerid, JoinShopM[SelectCharPlace[playerid]][0]);
							format(string, sizeof(string), "~w~~n~~n~~n~~n~~n~~n~COST: ~g~%i$", JoinShopM[SelectCharPlace[playerid]][1]);
						}
						else
						{
							SelectCharPlace[playerid] = 0;
							SetPlayerSkin(playerid, JoinShopF[SelectCharPlace[playerid]][0]);
							format(string, sizeof(string), "~w~~n~~n~~n~~n~~n~~n~COST: ~g~%i$", JoinShopF[SelectCharPlace[playerid]][1]);
						}
						GameTextForPlayer(playerid, string, 3000, 3);
			        }
			    }
			}
		}
		if(IsPlayerInRangeOfPoint(playerid, 1.0, 2860.6919,788.9444,801.7853))
		{
		    if(GetPlayerVirtualWorld(playerid) == 5)
		    {
		        ShowPlayerDialog(playerid, d_AMMONATION, DIALOG_STYLE_LIST,  "{FFCC00}AMMO-NATION", "{FFCC00}- {FFFFFF}Iaragebi\n{FFCC00}- {FFFFFF}Tyviebi", "Archeva", "Gamosvla");
		    }
		}
		if(GetPVarInt(playerid, "InviteMember") > 0)
	    {
	        DeletePVar(playerid, "InviteMember");
			new str[32 + MAX_PLAYER_NAME - 4];
			format(str, sizeof(str), "%s uaryo tqveni shemotavazebas", GetName(playerid));
			SendClientMessage(GetPVarInt(playerid,"Inviter"), 0xFFFFFFFF, str);
			DeletePVar(playerid, "Inviter");
	    }
	}
    if(newkeys == KEY_ACTION)
	{
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
			callcmd::engine(playerid);
		}
	}
	if(newkeys == KEY_CROUCH)
	{
	    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	    {
			for(new i; i < TotalFill; i ++)
			{
				if(IsPlayerInRangeOfPoint(playerid, 2.0, FillInfo[i][fMenu_X], FillInfo[i][fMenu_Y], FillInfo[i][fMenu_Z]))
				{
				    SetPVarInt(playerid, "FILL_ID", i);
				    if(!FillInfo[i][fOwned]) return SendErrorMessage(playerid, "Am benzin gasamart sadgurs ar yavs mflobeli");
				    if(FillInfo[i][fLock] == 1) return SendErrorMessage(playerid, "Es benzin gasamarti sadguri daxurulia");
					new str[200];
					format(str, sizeof(str), "{86ec67}- {FFFFFF}Chaweret sawvavis raodenoba, ramdenis chasxmac gindat manqanashi\n{86ec67}- {FFFFFF}1 litri sawvavis fasi - {86ec67}%d$", FillInfo[i][fValue]);
				    ShowPlayerDialog(playerid, d_FILL, DIALOG_STYLE_INPUT, "{86ec67}- {FFFFFF}Refill car", str, "Migeba", "Gamosvla");
				}
			}
	    }
	}
	if(newkeys == 4)
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            callcmd::lights(playerid);
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case d_LOGIN:
	    {
	        if(!response) // tu gamotova
	        {
	            SendErrorMessage(playerid, "Tamashidan gasasvlelad daweret: /q(uit)");
	            Kick(playerid);
	        }
	        if(!strlen(inputtext)) //tu veli carieli datova
	        {
	            ShowLoginDialog(playerid);
	            SendInfoMessage(playerid, "Parolis sheyvana aucilebelia, avtorizaciistvis");
	            return true;
	        }
	        for(new i = strlen(inputtext)-1; i != -1; i--) //sheyvanili simboloebis shemowmeba
	        {
	            switch(inputtext[i])
	            {
	                case '0'..'9', 'a'..'z', 'A'..'Z': continue;
	                default: ShowLoginDialog(playerid);
	            }
	        }
	      	//if(!strmid(PlayerInfo[playerid][pPassword], inputtext, 0, strlen(inputtext), 32))
 			if(!GetString(PlayerInfo[playerid][pPassword], inputtext)) // tu paroli ar aris swori
	        {
	            ShowLoginDialog(playerid);
	            SendErrorMessage(playerid, "Sheiyvanet swori paroli!");
	            //return true;
	        }
	        else //tu paroli sworia
	        {
	            new str[45 + MAX_PLAYER_NAME -4];
	            format(str, sizeof(str), "SELECT * FROM `users` WHERE `pName` = '%s'", PlayerInfo[playerid][pName]);
	            mysql_tquery(dbHandle, str, "LoadPlayerData", "i", playerid);
	        }
	    }
	    case d_REG:
	    {
	        if(!response)
	        {
	            SendInfoMessage(playerid, "Tamashidan gasasvlelad sheivanet: /q(uit)");
	            Kick(playerid);
	        }
         	if(!strlen(inputtext)) //tu chasaweri veli carieli datova da gaagrdzela
          	{
           		ShowRegistration(playerid);
             	SendErrorMessage(playerid, "Parolis sheyvana aucilebelia registraciistvis");
             	return true;
           	}
			else if(strlen(inputtext) < 8 || strlen(inputtext) > 32) //parolis sigrdzis shemowmeba
			{
   				ShowRegistration(playerid);
       			SendErrorMessage(playerid, "Parolis sigrdze unda iyos: 8-dan 32 simbolomde");
       			return true;
			}
			//parolshi gamoyenebuli simboloebis shemowmeba
			for(new i = strlen(inputtext)-1; i != -1; i--)
  			{
     			switch(inputtext[i])
     			{
        			case '0'..'9', 'a'..'z', 'A'..'Z': continue;
           			default:
		   			{
	   					ShowRegistration(playerid);
					   	SendErrorMessage(playerid, "Paroli unda iyos sheyvanili cifrebita da latinuri asoebit.");
		   			}
              	}
          	}
          	strmid(PlayerInfo[playerid][pPassword], inputtext, 0, strlen(inputtext), 32);
          	UpdatePlayerData(playerid, "pPassword", PlayerInfo[playerid][pPassword]);
  			ShowEmail(playerid);
	    }
	    case d_MAIL:
	    {
	        if(response)
	        {
         		if(!strlen(inputtext))
		        {
	         		ShowEmail(playerid);
		          	SendErrorMessage(playerid, "Registraciistvis aucilebelia sheiyvanet Email");
		          	return true;
		        }
		        else if(strlen(inputtext) < 8 || strlen(inputtext) > 32) //mail sigrdzis shemowmeba
				{
					ShowEmail(playerid);
	 				SendErrorMessage(playerid, "Sheiyvanet swori Mail");
	 				return true;
				}
				if(strfind(inputtext, "@", true) == -1)
				{
					ShowEmail(playerid);
	 				SendErrorMessage(playerid, "Sheiyvanet swori Mail");
	 				return true;
				}
			 	strmid(PlayerInfo[playerid][pMail], inputtext, 0, strlen(inputtext), 64);
		 		UpdatePlayerData(playerid, "pMail", PlayerInfo[playerid][pMail]);
		 		ShowPlayerDialog(playerid, d_SEX, DIALOG_STYLE_MSGBOX, "{4582A1}Account Registracia -{FFFFFF}Sqesi",
					"{FFFFFF}Airchiet tqveni personajis sqesi", "Kaci", "Qali");
	        }
	        else
	        {
	            ShowEmail(playerid);
	        }
	    }
	    case d_SEX:
	    {
	        if(response) //tu airchia pirveli (kaci)
	        {
	            PlayerInfo[playerid][pSex] = 1;
	            PlayerInfo[playerid][pSkin] = 3;
	        }
	        else //tu airchia meore (qali)
	        {
	            PlayerInfo[playerid][pSex] = 2;
	            PlayerInfo[playerid][pSkin] = 69;
	        }
	        ShowPlayerDialog(playerid, d_FINISH, DIALOG_STYLE_MSGBOX, "{4582A1}Account Registracia -{FFFFFF}Dasruleba",
	            "{4582A1}* {828282}Darwmunebuli xart, rom infroa miutitet sworad?", "Diax", "Ara");
	    }
	    case d_FINISH:
	    {
	        if(response)
	        {
	            new sql_str[2000];
	            mysql_format(dbHandle, sql_str, sizeof(sql_str), "INSERT INTO `users` (`pName`, `pPassword`, `pLevel`, `pMail`, `pSex`, `pSkin`) VALUES ('%e', '%e', '%d', '%e', '%d', '%d')",
	            PlayerInfo[playerid][pName], PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pMail], PlayerInfo[playerid][pSex], PlayerInfo[playerid][pSkin]);
	            mysql_query(dbHandle, sql_str);
	            PlayerInfo[playerid][pLevel] = 1;
	            
	            UpdatePlayerData(playerid, "pLevel", PlayerInfo[playerid][pLevel]);
	            
	            SetSpawnInfo(playerid, 0, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	            TogglePlayerSpectating(playerid, 0);
	            SpawnPlayer(playerid);
	            SendInfoMessage(playerid, "Gilocavt, tqven warmatebit daregistrirdit");
	            PlayerInfo[playerid][pLogin] = 1;
	        }
	        else
	        {
	            ShowRegistration(playerid);
	        }
	    }
	    case d_BUYHOUSE:
	    {
	        if(response)
	        {
			    for(new h = 0; h <= TotalHouse; h ++)
				{
					if(IsPlayerInRangeOfPoint(playerid, 2.0, HouseInfo[h][hEnter_X], HouseInfo[h][hEnter_Y], HouseInfo[h][hEnter_Z]))
					{
					    if(PlayerInfo[playerid][pHouse] != -1 && strcmp(PlayerInfo[playerid][pName], HouseInfo[PlayerInfo[playerid][pHouse]][hOwner], true) == 0)
					    {
					        SendErrorMessage(playerid, "Tqven ukve gaqvt saxli.");
					        return true;
					    }
					    if(PlayerInfo[playerid][pMoney] < HouseInfo[h][hPrice]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
					    PlayerInfo[playerid][pHouse] = h;
					    UpdatePlayerData(playerid, "pHouse", PlayerInfo[playerid][pHouse]);
					    HouseInfo[h][hOwned] = 1;
					    strmid(HouseInfo[h][hOwner],PlayerInfo[playerid][pName], 0, strlen(PlayerInfo[playerid][pName]), MAX_PLAYER_NAME);
					    GiveServerMoney(playerid,  -HouseInfo[h][hPrice]);
					    
					    PlayerInfo[playerid][pSetSpawn] = 1;
					    UpdatePlayerData(playerid, "pSetSpawn", PlayerInfo[playerid][pSetSpawn]);
					    
					    new house = PlayerInfo[playerid][pHouse];
					    UpdateHouse(house);
					    SaveProperty(house);
					    
						SendInfoMessage(playerid, "Tqven warmatebit sheidzinet saxli. Ar dagaviwyet saxlis angarishis shevseba");
						SendInfoMessage(playerid, "Saxlis panelis samartavad gamoiyenet brdzaneba: {FF9600}/hpanel");
					    return true;
					}
				}
	        }
	        else { return true; }
	    }
	    case d_HOUSEINFO:
	    {
	        if(response)
	        {
             	for(new h; h < TotalHouse; h ++)
				{
					if(IsPlayerInRangeOfPoint(playerid, 2.0, HouseInfo[h][hEnter_X], HouseInfo[h][hEnter_Y], HouseInfo[h][hEnter_Z]))
					{
					    if(PlayerInfo[playerid][pHouse] == h || HouseInfo[h][hLock] == 0)
					    {
             				SetPlayerInterior(playerid,HouseInfo[h][hInt]);
							SetPlayerVirtualWorld(playerid,h+50);
							SetPlayerPos(playerid,HouseInfo[h][hExit_X],HouseInfo[h][hExit_Y],HouseInfo[h][hExit_Z]);
							/* ---------------------------------------------- */
		    				TogglePlayerControllable(playerid, 0);
							SetTimerEx("FREEZE" , 2000, false, "d", playerid);
							/* ---------------------------------------------- */
							return true;
					    }
						else
						{
							GameTextForPlayer(playerid, "~r~Locked", 5000, 1);
						}
					}
				}
	        }
	        else { }
	    }
	    case d_HPANEL:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
	                    new h = PlayerInfo[playerid][pHouse];
	                    if(!IsPlayerInRangeOfPoint(playerid, 10.0, HouseInfo[h][hEnter_X], HouseInfo[h][hEnter_Y], HouseInfo[h][hEnter_Z]) && !IsPlayerInRangeOfPoint(playerid, 10.0, HouseInfo[h][hExit_X], HouseInfo[h][hExit_Y], HouseInfo[h][hExit_Z])) 
	                    {
	                        SendErrorMessage(playerid, "Unda iyot saxltan axlos");
	                        return true;
	                    }
	                    if(HouseInfo[h][hLock] == 1)
	                    {
	                        HouseInfo[h][hLock] = 0;
							GameTextForPlayer(playerid,"~w~House ~g~UNLOCK", 5000, 3);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							UpdateHouse(h);
							SaveProperty(h);
							return true;
	                    }
	                    if(HouseInfo[h][hLock] == 0)
	                    {
	                        HouseInfo[h][hLock] = 1;
							GameTextForPlayer(playerid, "~w~House ~r~LOCK", 5000, 3);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							UpdateHouse(h);
							SaveProperty(h);
							return true;
	                    }
	                }
	                case 1:
	                {
						new h = PlayerInfo[playerid][pHouse];
	    	    		if(h == -1) return SendErrorMessage(playerid, "Tqven ar gaqvt saxli");
	                    new string[256];
	                    format(string, sizeof(string), "{86ec67}Tqveni gadasaxadi yovel 1 saatshi:\t{FFFFFF}%d$\n{86ec67}Saxlis angarishi:\t\t\
						{FFFFFF}%d$\n\n\t{86ec67}* {FFFFFF}Tu tanxa ar iqneba droulad gadaxdili, tqveni saxli gaiyideba\n\t{86ec67}* Chaweret shesatani tanxis raodenoba", GetHouseTax(h), HouseInfo[h][hTax]);
	                    ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "Saxlis gadasaxadi", string, "Gadaxda", "Archeva");
	                }
	                case 2:
	                {
	                    callcmd::sellhouse(playerid);
	                }
	                case 3:
	                {
	                    new h = PlayerInfo[playerid][pHouse];
						EnableGPS(playerid, HouseInfo[h][hEnter_X], HouseInfo[h][hEnter_Y], HouseInfo[h][hEnter_Z]);
						SendInfoMessage(playerid, "Tqveni saxli moinishna rukaze");
	                }
	            }
	        }
	        else { }
	    }
	    case d_SELLHOUSE:
	    {
	        new h = PlayerInfo[playerid][pHouse];
	    	if(response)
	    	{
	    	    if(h == -1) return SendErrorMessage(playerid, "Tqven ar gaqvt saxli");
	    	    HouseInfo[h][hLock] = 0;
	    	    HouseInfo[h][hOwned] = 0;
	    	    strmid(HouseInfo[h][hOwner], "The State", 0, strlen("The State"), 15);
	    	    GiveServerMoney(playerid, HouseInfo[h][hPrice]*3/4);
	    	    UpdateHouse(h);
	    	    SaveProperty(h);
	    	    PlayerInfo[playerid][pHouse] = -1;
	    	    UpdatePlayerData(playerid, "pHouse", PlayerInfo[playerid][pHouse]);
	    	    PlayerInfo[playerid][pSetSpawn] = 0;
		    	UpdatePlayerData(playerid, "pSetSpawn", PlayerInfo[playerid][pSetSpawn]);
	    	}
	    	else { }
	    }
	    case d_BUYBIZZ:
	    {
	        if(response)
	        {
              	for(new b = 0; b <= TotalBizz; b ++)
				{
					if(IsPlayerInRangeOfPoint(playerid, 2.0, BizzInfo[b][bEnter_X], BizzInfo[b][bEnter_Y], BizzInfo[b][bEnter_Z]))
					{
					    if(PlayerInfo[playerid][pFillBizz] == -1)
					    {
						    if(PlayerInfo[playerid][pBizz] != -1 && strcmp(PlayerInfo[playerid][pName], BizzInfo[PlayerInfo[playerid][pBizz]][bOwner], true) == 0)
						    {
						        SendErrorMessage(playerid, "Tqven ukve gaqvt biznesi.");
						        return true;
						    }
						    if(PlayerInfo[playerid][pMoney] < BizzInfo[b][bPrice]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
						    PlayerInfo[playerid][pBizz] = b;
						    UpdatePlayerData(playerid, "pBizz", PlayerInfo[playerid][pBizz]);
						    BizzInfo[b][bOwned] = 1;
						    strmid(BizzInfo[b][bOwner],PlayerInfo[playerid][pName], 0, strlen(PlayerInfo[playerid][pName]), MAX_PLAYER_NAME);
						    GiveServerMoney(playerid,  -BizzInfo[b][bPrice]);

						    new bizz = PlayerInfo[playerid][pBizz];
						    UpdateBizz(bizz);
						    SaveBizz(bizz);

							SendInfoMessage(playerid, "Tqven warmatebit sheidzinet biznesi. Ar dagaviwyet gadasaxadebis gadaxda");
							SendInfoMessage(playerid, "Biznesis panelis samartavad gamoiyenet brdzaneba: {FF9600}/bpanel");
						    return true;
						}
						else
						{
						    SendErrorMessage(playerid, "Tqven ukve gaqvt biznesi");
						}
					}
				}
	        }
	        else { }
	    }
     	case d_BIZZINFO:
	    {
	        if(response)
	        {
	            for(new b; b < TotalBizz; b ++)
				{
					if(IsPlayerInRangeOfPoint(playerid, 2.0, BizzInfo[b][bEnter_X], BizzInfo[b][bEnter_Y], BizzInfo[b][bEnter_Z]))
					{
					    if(BizzInfo[b][bLock] == 0)
					    {
             				SetPlayerInterior(playerid,BizzInfo[b][bInt]);
							SetPlayerVirtualWorld(playerid,BizzInfo[b][bWorld]);
							SetPlayerPos(playerid,BizzInfo[b][bExit_X],BizzInfo[b][bExit_Y],BizzInfo[b][bExit_Z]);
							BizzInfo[b][bGuest] += 1;
							SetPVarInt(playerid, "BUSINESS_ID", b);
							SaveBizz(b);
							/* ---------------------------------------------- */
		    				TogglePlayerControllable(playerid, 0);
							SetTimerEx("FREEZE" , 2000, false, "d", playerid);
							/* ---------------------------------------------- */
							return true;
					    }
						else
						{
							GameTextForPlayer(playerid, "~r~Locked", 5000, 1);
						}
					}
				}
	        }
	        else { }
	    }
	    case d_BPANEL: 
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
                     	new b = PlayerInfo[playerid][pBizz];
	                    if(BizzInfo[b][bLock] == 1)
	                    {
	                        BizzInfo[b][bLock] = 0;
							GameTextForPlayer(playerid,"~w~Bussines ~g~UNLOCK", 5000, 3);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							UpdateBizz(b);
							SaveBizz(b);
							return true;
	                    }
	                    if(BizzInfo[b][bLock] == 0)
	                    {
	                        BizzInfo[b][bLock] = 1;
							GameTextForPlayer(playerid, "~w~Bussines ~r~LOCK", 5000, 3);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							UpdateBizz(b);
							SaveBizz(b);
							return true;
	                    }
	                }
	                case 1:
	                {
	                    ShowPlayerDialog(playerid, d_SALARY, DIALOG_STYLE_LIST, "{86ec67}Salaros martva", "{86ec67} - {FFFFFF}Biznesis balansze\n{86ec67} - {FFFFFF}Tanxis gamotana\n{86ec67} - {FFFFFF}Tanxis shetana", "Archeva", "Gamosvla");
	                }
	                case 2:
	                {
	                    new b = PlayerInfo[playerid][pBizz];
	                	new string[400];
	                    format(string, sizeof(string), "{86ec67}Tanxa salaroshi:\t\t{FFFFFF}%d$\n{86ec67}Shemosavali 1 saatshi:\t{FFFFFF}%d$\n{86ec67}Produqtis raodenoba:\t\t{FFFFFF}%d / %d\n{86ec67}Sul shemosavali:\t\t{FFFFFF}%d$\n{86ec67}Klienti\t\t\t{FFFFFF}%d", BizzInfo[b][bBank], BizzInfo[b][bProfitHour], BizzInfo[b][bProd], BizzInfo[b][bMaxProd], BizzInfo[b][bProfit], BizzInfo[b][bGuest]);
	                    ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "Biznesis statistika", string, "Migeba", "");
					}
					case 3:
					{
					    SendInfoMessage(playerid, "Es funqcia daemateba shemdeg ganaxlebebze");
					}
					case 4:
					{
					    new b = PlayerInfo[playerid][pBizz];
					    new string[200];
					    format(string, sizeof(string), "{86ec67}Exlandeli saxeli:\t{828282}%s\n{86ec67}- {828282}Chaweret qveda velshi axali saxeli biznesistvis", BizzInfo[b][bName]);
					    ShowPlayerDialog(playerid, d_BNAME, DIALOG_STYLE_INPUT, "Biznesis saxeli", string, "Archeva", "Gamosvla");
					    
					}
					case 5:
					{
					    callcmd::sellbizz(playerid);
					}
					case 6:
					{
					    SendInfoMessage(playerid, "Es funqcia daemateba shemdeg ganaxlebebze");
					}
				}
	    	}
	        else { }
	    }
	    case d_SALARY:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
	                    new b = PlayerInfo[playerid][pBizz];
	                	new string[200];
	                    format(string, sizeof(string), "{86ec67}Tanxa salaroshi:\t\t{FFFFFF}%d$\n\n", BizzInfo[b][bBank]);
	                    ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "Biznesis salaro", string, "Migeba", "");
	                }
	                case 1:
	                {
	                    new b = PlayerInfo[playerid][pBizz];
	                    new string[200];
	                    format(string, sizeof(string), "{86ec67}Tanxa salaroshi:\t\t{FFFFFF}%d$\n\n\tSheiyvanet gasatani tanxis raodenoba", BizzInfo[b][bBank]);
	                    ShowPlayerDialog(playerid, d_SALARYWITHDRAW, DIALOG_STYLE_INPUT, "Tanxis moxsna salarodan", string, "Gamotana", "Gamosvla");
	                }
	                case 2:
	                {
	                    new b = PlayerInfo[playerid][pBizz];
	                    new string[200];
	                    format(string, sizeof(string), "{86ec67}Tanxa salaroshi:\t\t{FFFFFF}%d$\n\n\tSheiyvanet shesatani tanxis raodenoba", BizzInfo[b][bBank]);
	                    ShowPlayerDialog(playerid, d_SALARYINPUT, DIALOG_STYLE_INPUT, "Tanxis shetana salaroshi", string, "Gamotana", "Gamosvla");
	                }
	            }
	        }
	    }
	    case d_SALARYWITHDRAW:
	    {
	        if(response)
	        {
	            if(isNumeric(inputtext) || !strlen(inputtext)) return 1;
				new cash = strval(inputtext);
				if(cash < 1) return SendErrorMessage(playerid, "Araswori tanxis odenoba");
				new biz = PlayerInfo[playerid][pBizz];
				if(BizzInfo[biz][bBank] < cash) return SendErrorMessage(playerid, "Biznesis salaroshi ar aris sakmarisi tanxa");
				BizzInfo[biz][bBank] -= cash;
				GiveServerMoney(playerid, cash);
				UpdateBizz(biz);
				SaveBizz(biz);
				
				new string[150];
				format(string, sizeof(string), "{4582A1}* B.INFO {FFFFFF}Tqven moxsenit biznesis angarishidan {86ec67}%d$", cash);
				SendClientMessage(playerid, 0xFFFFFFFF, string);
	        }
	        else { }
	    }
	    case d_SALARYINPUT:
	    {
	        if(response)
	        {
             	if(isNumeric(inputtext) || !strlen(inputtext)) return 1;
				new cash = strval(inputtext);
				if(cash < 1) return SendErrorMessage(playerid, "Araswori tanxis odenoba");
				if(PlayerInfo[playerid][pMoney] < cash) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
				new biz = PlayerInfo[playerid][pBizz];
				BizzInfo[biz][bBank] += cash;
				GiveServerMoney(playerid, -cash);
				UpdateBizz(biz);
				SaveBizz(biz);
				
				new string[150];
				format(string, sizeof(string), "{4582A1}* B.INFO {FFFFFF}Tqven sheitanet biznesis angarishze {86ec67}%d$", cash);
				SendClientMessage(playerid, 0xFFFFFFFF, string);
	        }
	        else { }
	    }
	    case d_BNAME:
	    {
	        if(response)
	        {
	            if(!strlen(inputtext)) SendErrorMessage(playerid, "Ar datovot veli carieli");
				if(strlen(inputtext) < 4 || strlen(inputtext) > 20) SendErrorMessage(playerid, "Saxelis sigrdze unda iyos: 4-dan 20 simbolomde");
				new b = PlayerInfo[playerid][pBizz];
				strmid(BizzInfo[b][bName], inputtext, 0, strlen(inputtext), 32);
				UpdateBizz(b);
				SaveBizz(b);
				SendInfoMessage(playerid, "Tqven sheucvalet tqven biznes saxeli");
	        }
	        else { }
	    }
	    case d_SELLBIZZ:
	    {
	        new b = PlayerInfo[playerid][pBizz];
	    	if(response)
	    	{
 	    		if(b == 999) return SendErrorMessage(playerid, "Tqven ar gaqvt biznesi");
 	    		PlayerInfo[playerid][pBizz] = -1;
 	    		UpdatePlayerData(playerid, "pBizz", PlayerInfo[playerid][pBizz]);
				BizzInfo[b][bLock] = 1;
    			BizzInfo[b][bOwned] = 0;
  	    		strmid(BizzInfo[b][bOwner], "The State", 0, strlen("The State"), 15);
    	    	GiveServerMoney(playerid, BizzInfo[b][bPrice]*3/4);
	    	    UpdateBizz(b);
	    	    SaveBizz(b);
			}
			else { }
	    }
	    case d_SHOP:
	    {
	        if(response)
	        {
	            new bizid = GetPVarInt(playerid, "BUSINESS_ID");
	            if(BizzInfo[bizid][bProd] < shop_prod_count[listitem]) return SendErrorMessage(playerid, "Bizneshi ar aris sakmarisi produqti");
		    	if(PlayerInfo[playerid][pMoney] < shop_item_price[listitem]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
	            switch(listitem)
	            {
	                case 0:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet mobiluri telefoni");
	                }
	                case 1:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet sim barati");
	                }
	                case 2:
	                {
                 		SendInfoMessage(playerid, "Tqven sheidzinet medikamentebi");
	                }
	                case 3:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet fotoaparati");
	                    GivePlayerWeapon(playerid, 43, 50);
	                }
	                case 4:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet toki");
	                }
	                case 5:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet nigabi");
	                }
				}
    			if(BizzInfo[bizid][bProd] > 0)
				{
    				BizzInfo[bizid][bProd] -= shop_prod_count[listitem];
				    UpdateBizz(bizid);
				}
    			if(listitem != 0) show_market_dialog(playerid);
       			BizzInfo[bizid][bProfitHour] += shop_item_price[listitem];
       			BizzInfo[bizid][bBank] += shop_item_price[listitem];
       			BizzInfo[bizid][bProfit] += shop_item_price[listitem];
				UpdateBizz(bizid);
				SaveBizz(bizid);
				GiveServerMoney(playerid, -shop_item_price[listitem]);
				return 1;
	        }
	        else { }
	    }
	    case d_BURGER:
	    {
	        if(response)
	        {
		        new bizid = GetPVarInt(playerid, "BUSINESS_ID");
	         	if(BizzInfo[bizid][bProd] < burger_prod_count[listitem]) return SendErrorMessage(playerid, "Bizneshi ar aris sakmarisi produqti");
	    		if(PlayerInfo[playerid][pMoney] < burger_item_price[listitem]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
	    		switch(listitem)
	            {
	                case 0:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet pizza");
	                }
	                case 1:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet burger");
	                }
	                case 2:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet Big Mac");
	                }
	                case 3:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet Big Taste");
	                }
	            }
	            if(BizzInfo[bizid][bProd] > 0)
				{
    				BizzInfo[bizid][bProd] -= burger_prod_count[listitem];
				    UpdateBizz(bizid);
				}
    			if(listitem != 0) show_burger_dialog(playerid);
       			BizzInfo[bizid][bProfitHour] += burger_item_price[listitem];
       			BizzInfo[bizid][bBank] += burger_item_price[listitem];
       			BizzInfo[bizid][bProfit] += burger_item_price[listitem];
				UpdateBizz(bizid);
				SaveBizz(bizid);
				GiveServerMoney(playerid, -burger_item_price[listitem]);
				return 1;
			}
			else { }
	    }
     	case d_CLUB:
	    {
	        if(response)
	        {
	            new bizid = GetPVarInt(playerid, "BUSINESS_ID");
	            if(BizzInfo[bizid][bProd] < club_prod_count[listitem]) return SendErrorMessage(playerid, "Bizneshi ar aris sakmarisi produqti");
		    	if(PlayerInfo[playerid][pMoney] < club_item_price[listitem]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
	            switch(listitem)
	            {
	                case 0:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet gvino");
	                }
	                case 1:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet arayi");
	                }
	                case 2:
	                {
                 		SendInfoMessage(playerid, "Tqven sheidzinet viski");
	                }
	                case 3:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet tekila");
	                }
	                case 4:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet naturaluri wveni");
	                }
	                case 5:
	                {
	                    SendInfoMessage(playerid, "Tqven sheidzinet wyali");
	                }
				}
    			if(BizzInfo[bizid][bProd] > 0)
				{
    				BizzInfo[bizid][bProd] -= club_prod_count[listitem];
				    UpdateBizz(bizid);
				}
    			if(listitem != 0) show_club_dialog(playerid);
       			BizzInfo[bizid][bProfitHour] += club_item_price[listitem];
       			BizzInfo[bizid][bBank] += club_item_price[listitem];
       			BizzInfo[bizid][bProfit] += club_item_price[listitem];
				UpdateBizz(bizid);
				SaveBizz(bizid);
				GiveServerMoney(playerid, -club_item_price[listitem]);
				return 1;
	        }
	        else { }
	    }
		case d_BANK:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
	                    new string[256];
	                    format(string, sizeof(string), "{86ec67}Mimdinare balansi:\t\t{FFFFFF}%d$\n{86ec67}Davalianeba:\t\t{FFFFFF}0$", PlayerInfo[playerid][pBank]);
	                    ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "Sabanko angarishi", string, "Migeba", "");
	                }
	                case 1:
	                {
						new string[256];
						format(string, sizeof(string), "{86ec67}Tqveni mimdinare balansi:\t\t{828282}%d$\n\n\t{86ec67}* {828282}Chaweret gasatni tanxis raodenoba", PlayerInfo[playerid][pBank]);
						ShowPlayerDialog(playerid, d_BANKWITHDRAW, DIALOG_STYLE_INPUT, "Tanxis gatana", string, "Migeba", "Archeva");
	                }
	                case 2:
	                {
						new string[256];
						format(string, sizeof(string), "{86ec67}Tqveni mimdinare balansi:\t\t{828282}%d$\n\n\t{86ec67}* {828282}Chaweret shesatani tanxis raodenoba", PlayerInfo[playerid][pBank]);
						ShowPlayerDialog(playerid, d_BANKINPUT, DIALOG_STYLE_INPUT, "Tanxis shetana", string, "Migeba", "Archeva");
	                }
	                case 3:
	                {
	                    new h = PlayerInfo[playerid][pHouse];
	    	    		if(h == -1) return SendErrorMessage(playerid, "Tqven ar gaqvt saxli");
	                    new string[256];
	                    format(string, sizeof(string), "{86ec67}Tqveni gadasaxadi yovel 1 saatshi:\t{FFFFFF}%d$\n{86ec67}Saxlis angarishi:\t\t\
						{FFFFFF}%d$\n\n\t{86ec67}* {FFFFFF}Tu tanxa ar iqneba droulad gadaxdili, tqveni saxli gaiyideba\n\t{86ec67}* Chaweret shesatani tanxis raodenoba", GetHouseTax(h), HouseInfo[h][hTax]);
	                    ShowPlayerDialog(playerid, d_HOUSETAX, DIALOG_STYLE_INPUT, "Saxlis gadasaxadi", string, "Gadaxda", "Archeva");
	                }
	                case 4:
	                {
	                    new b = PlayerInfo[playerid][pBizz];
	    	    		if(b == -1) return SendErrorMessage(playerid, "Tqven ar gaqvt biznesi");
	                    new string[256];
	                    format(string, sizeof(string), "{86ec67}Tqveni gadasaxadi yovel 1 saatshi:\t{FFFFFF}%d$\n{86ec67}Biznesis angarishi:\t\t\
						{FFFFFF}%d$\n\n\t{86ec67}* {FFFFFF}Tu tanxa ar iqneba droulad gadaxdili, tqveni biznesi daixureba 12 saatis ganmavlobashi\n\t{86ec67}* Am 12 saatis shemdeg tu ar daifareba davalianeba biznesi gaiyideba", GetBizzTax(b), BizzInfo[b][bTax]);
	                    ShowPlayerDialog(playerid, d_BIZZTAX, DIALOG_STYLE_INPUT, "Biznesis gadasaxadi", string, "Gadaxda", "Archeva");
	                }
	            }
	        }
	        else { GameTextForPlayer(playerid,"~g~GOOD LUCK", 5000, 1); }
	    }
	    case d_BANKWITHDRAW:
	    {
	        if(response)
	        {
	            new cash = strval(inputtext);
	            if(isNumeric(inputtext) || !strlen(inputtext)) return 1;
	            if(PlayerInfo[playerid][pBank] < cash)
				{
					 ShowBankDialog(playerid);
					 return SendErrorMessage(playerid, "Biznesis angarishze ar aris sakmarisi tanxa");
				}
	            if(cash < 1)
				{
				    ShowBankDialog(playerid);
				    return SendErrorMessage(playerid, "Sheiyvanet tanxis swori odenoba");
				}
				if(cash > 20000)
				{
				    ShowBankDialog(playerid);
				    return SendErrorMessage(playerid, "Ertjeradad shegidzliat gaitanot mxolod 20.000$");
				}
				PlayerInfo[playerid][pBank] -= cash;
				UpdatePlayerData(playerid, "pBank", PlayerInfo[playerid][pBank]);
				GiveServerMoney(playerid, cash);
	            return true;
	        }
	        else
			{
				ShowBankDialog(playerid);
			}
	    }
     	case d_BANKINPUT:
	    {
	        if(response)
	        {
	            new cash = strval(inputtext);
	            if(isNumeric(inputtext) || !strlen(inputtext)) return 1;
	            if(PlayerInfo[playerid][pMoney] < cash)
				{
					 ShowBankDialog(playerid);
					 return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
				}
	            if(cash < 1)
				{
				    ShowBankDialog(playerid);
				    return SendErrorMessage(playerid, "Sheiyvanet tanxis swori odenoba");
				}
				GiveServerMoney(playerid, -cash);
				PlayerInfo[playerid][pBank] += cash;
				UpdatePlayerData(playerid, "pBank", PlayerInfo[playerid][pBank]);
	            return true;
	        }
	        else
			{
				ShowBankDialog(playerid);
			}
	    }
	    case d_HOUSETAX:
	    {
	        if(response)
	        {
	            new h = PlayerInfo[playerid][pHouse];
	            new cash = strval(inputtext);
	            if(isNumeric(inputtext) || !strlen(inputtext)) return 1;
	            if(PlayerInfo[playerid][pMoney] < cash)
				{
					 ShowBankDialog(playerid);
					 return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
				}
    			if(cash < 1)
				{
				    ShowBankDialog(playerid);
				    return SendErrorMessage(playerid, "Sheiyvanet tanxis swori odenoba");
				}
				GiveServerMoney(playerid, -cash);
				HouseInfo[h][hTax] += cash;
				UpdateHouse(h);
				SaveProperty(h);
	        }
	        else
	        {
	            ShowBankDialog(playerid);
	        }
	    }
	    case d_BIZZTAX:
	    {
	        if(response)
	        {
	            new b = PlayerInfo[playerid][pBizz];
				new cash = strval(inputtext);
				if(isNumeric(inputtext) || !strlen(inputtext)) return 1;
    			if(PlayerInfo[playerid][pMoney] < cash)
				{
					 ShowBankDialog(playerid);
					 return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
				}
    			if(cash < 1)
				{
				    ShowBankDialog(playerid);
				    return SendErrorMessage(playerid, "Sheiyvanet tanxis swori odenoba");
				}
				GiveServerMoney(playerid, -cash);
				BizzInfo[b][bTax] += cash;
				UpdateBizz(b);
				SaveBizz(b);
	        }
	        else
	        {
	            ShowBankDialog(playerid);
	        }
	    }
	    case d_MAKELEADER:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 1; InviteSkin[GetPVarInt(playerid,"ActionID")] = 283; }  //police
	                case 1: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 2; InviteSkin[GetPVarInt(playerid,"ActionID")] = 165; }  //fbi
					case 2: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 3; InviteSkin[GetPVarInt(playerid,"ActionID")] = 61;  }  //army
					case 3: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 4; InviteSkin[GetPVarInt(playerid,"ActionID")] = 147; }  //presdent
	            }
	            PlayerInfo[GetPVarInt(playerid,"ActionID")][pLeader] = FormaFrac[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember] = FormaFrac[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pModel] = InviteSkin[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pSetSpawn] = 2;
				
				
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pLeader", PlayerInfo[GetPVarInt(playerid,"ActionID")][pLeader]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pMember", PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pRank", PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pModel", PlayerInfo[GetPVarInt(playerid,"ActionID")][pModel]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pSetSpawn", PlayerInfo[GetPVarInt(playerid,"ActionID")][pSetSpawn]);
				
	            new str1[200];
	            format(str1, sizeof(str1), "{4582A1}* L.INFO {FFFFFF}Administratorma %s-ma dagnishnat organizaciis mmartvelad - {4582A1}%s", GetName(playerid), GetFracName(PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]));
	            SendClientMessage(GetPVarInt(playerid,"ActionID"), 0xFFFFFFFF, str1);
	            
	            new str2[200];
	            format(str2, sizeof(str2), "{4582A1}* S.INFO {FFFFFF}Motamashe {4582A1}%s[%d] {FFFFFF}dainishna organizaciis mmartvelad {4582A1}%s", GetName(GetPVarInt(playerid,"ActionID")), GetPVarInt(playerid,"ActionID"), playerid,GetFracName(PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]));
	            SendClientMessage(playerid, 0xFFFFFFFF, str2);
	            
				SetPlayerSkin(GetPVarInt(playerid,"ActionID"), InviteSkin[GetPVarInt(playerid,"ActionID")]);
				SetPlayerToTeamColor(GetPVarInt(playerid,"ActionID"));
				
				SpawnPlayer(GetPVarInt(playerid,"ActionID"));
	        }
	        else { }
	    }
	    case d_GANGLEADER:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 5; InviteSkin[GetPVarInt(playerid,"ActionID")] = 104; } //ballas
	                case 1: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 6; InviteSkin[GetPVarInt(playerid,"ActionID")] = 270; } //grove
	                case 2: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 7; InviteSkin[GetPVarInt(playerid,"ActionID")] = 173; } //rifa
	                case 3: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 8; InviteSkin[GetPVarInt(playerid,"ActionID")] = 110; } //vagos
	                case 4: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 9; InviteSkin[GetPVarInt(playerid,"ActionID")] = 116; } //aztecas
	            }
             	PlayerInfo[GetPVarInt(playerid,"ActionID")][pLeader] = FormaFrac[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember] = FormaFrac[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pModel] = InviteSkin[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pSetSpawn] = 2;


				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pLeader", PlayerInfo[GetPVarInt(playerid,"ActionID")][pLeader]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pMember", PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pRank", PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pModel", PlayerInfo[GetPVarInt(playerid,"ActionID")][pModel]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pSetSpawn", PlayerInfo[GetPVarInt(playerid,"ActionID")][pSetSpawn]);

	            new str1[200];
	            format(str1, sizeof(str1), "{4582A1}* L.INFO {FFFFFF}Administratorma %s-ma dagnishnat organizaciis mmartvelad - {4582A1}%s", GetName(playerid), GetFracName(PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]));
	            SendClientMessage(GetPVarInt(playerid,"ActionID"), 0xFFFFFFFF, str1);

	            new str2[200];
	            format(str2, sizeof(str2), "{4582A1}* S.INFO {FFFFFF}Motamashe {4582A1}%s[%d] {FFFFFF}dainishna organizaciis mmartvelad {4582A1}%s", GetName(GetPVarInt(playerid,"ActionID")), GetPVarInt(playerid,"ActionID"),GetFracName(PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]));
	            SendClientMessage(playerid, 0xFFFFFFFF, str2);

				SetPlayerSkin(GetPVarInt(playerid,"ActionID"), InviteSkin[GetPVarInt(playerid,"ActionID")]);
				SetPlayerToTeamColor(GetPVarInt(playerid,"ActionID"));

				SpawnPlayer(GetPVarInt(playerid,"ActionID"));
	        }
	        else { }
	    }
     	case d_MAFIALEADER:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 10; InviteSkin[GetPVarInt(playerid,"ActionID")] = 127; } //ballas
	                case 1: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 11; InviteSkin[GetPVarInt(playerid,"ActionID")] = 120; } //grove
	                case 2: { PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank] = 10; FormaFrac[GetPVarInt(playerid,"ActionID")] = 12; InviteSkin[GetPVarInt(playerid,"ActionID")] = 46; } //rifa
	            }
             	PlayerInfo[GetPVarInt(playerid,"ActionID")][pLeader] = FormaFrac[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember] = FormaFrac[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pModel] = InviteSkin[GetPVarInt(playerid,"ActionID")];
				PlayerInfo[GetPVarInt(playerid,"ActionID")][pSetSpawn] = 2;


				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pLeader", PlayerInfo[GetPVarInt(playerid,"ActionID")][pLeader]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pMember", PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pRank", PlayerInfo[GetPVarInt(playerid,"ActionID")][pRank]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pModel", PlayerInfo[GetPVarInt(playerid,"ActionID")][pModel]);
				UpdatePlayerData(GetPVarInt(playerid,"ActionID"), "pSetSpawn", PlayerInfo[GetPVarInt(playerid,"ActionID")][pSetSpawn]);

	            new str1[200];
	            format(str1, sizeof(str1), "{4582A1}* L.INFO {FFFFFF}Administratorma %s-ma dagnishnat organizaciis mmartvelad - {4582A1}%s", GetName(playerid), GetFracName(PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]));
	            SendClientMessage(GetPVarInt(playerid,"ActionID"), 0xFFFFFFFF, str1);

	            new str2[200];
	            format(str2, sizeof(str2), "{4582A1}* S.INFO {FFFFFF}Motamashe {4582A1}%s[%d] {FFFFFF}dainishna organizaciis mmartvelad {4582A1}%s", GetName(GetPVarInt(playerid,"ActionID")), GetPVarInt(playerid,"ActionID"),GetFracName(PlayerInfo[GetPVarInt(playerid,"ActionID")][pMember]));
	            SendClientMessage(playerid, 0xFFFFFFFF, str2);

				SetPlayerSkin(GetPVarInt(playerid,"ActionID"), InviteSkin[GetPVarInt(playerid,"ActionID")]);
				SetPlayerToTeamColor(GetPVarInt(playerid,"ActionID"));

				SpawnPlayer(GetPVarInt(playerid,"ActionID"));
	        }
	        else { }
	    }
     	case d_BUYFILLING:
	    {
	        if(response)
	        {
              	for(new i = 0; i <= TotalFill; i ++)
				{
					if(IsPlayerInRangeOfPoint(playerid, 2.0, FillInfo[i][fMenu_X], FillInfo[i][fMenu_Y], FillInfo[i][fMenu_Z]))
					{
					    if(PlayerInfo[playerid][pBizz] == -1)
					    {
						    if(PlayerInfo[playerid][pFillBizz] != -1 && strcmp(PlayerInfo[playerid][pName], FillInfo[PlayerInfo[playerid][pFillBizz]][fOwner], true) == 0)
						    {
						        SendErrorMessage(playerid, "Tqven ukve gaqvt biznesi.");
						        return true;
						    }
						    if(PlayerInfo[playerid][pMoney] < FillInfo[i][fPrice]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
						    PlayerInfo[playerid][pFillBizz] = i;
						    UpdatePlayerData(playerid, "pFillBizz", PlayerInfo[playerid][pFillBizz]);
						    FillInfo[i][fOwned] = 1;
						    strmid(FillInfo[i][fOwner],PlayerInfo[playerid][pName], 0, strlen(PlayerInfo[playerid][pName]), MAX_PLAYER_NAME);
						    GiveServerMoney(playerid,  -FillInfo[i][fPrice]);

						    new fill = PlayerInfo[playerid][pFillBizz];
						    UpdateFill(fill);
						    SaveFill(fill);

							SendInfoMessage(playerid, "Tqven warmatebit sheidzinet benzin gasamarti sadguri. Ar dagaviwyet gadasaxadebis gadaxda");
							SendInfoMessage(playerid, "Biznesis panelis samartavad gamoiyenet brdzaneba: {FF9600}/bpanel");
						    return true;
						}
						else
						{
						    SendErrorMessage(playerid, "Tqven ukve gaqvt biznesi");
						}
					}
				}
	        }
	        else { }
	    }
	    case d_BFILLPANEL:
	    {
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
	                {
                     	new b = PlayerInfo[playerid][pFillBizz];
	                    if(FillInfo[b][fLock] == 1)
	                    {
	                        FillInfo[b][fLock] = 0;
							GameTextForPlayer(playerid,"~w~Bussines ~g~UNLOCK", 5000, 3);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							UpdateFill(b);
							SaveFill(b);
							return true;
	                    }
	                    if(FillInfo[b][fLock] == 0)
	                    {
	                        FillInfo[b][fLock] = 1;
							GameTextForPlayer(playerid, "~w~Bussines ~r~LOCK", 5000, 3);
							PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
							UpdateFill(b);
							SaveFill(b);
							return true;
	                    }
	                }
	                case 1:
	                {
	                    ShowPlayerDialog(playerid, d_FILLSALARY, DIALOG_STYLE_LIST, "{86ec67}Salaros martva", "{86ec67} - {FFFFFF}Biznesis balansze\n{86ec67} - {FFFFFF}Tanxis gamotana\n{86ec67} - {FFFFFF}Tanxis shetana", "Archeva", "Gamosvla");
	                }
	                case 2:
	                {
	                    new b = PlayerInfo[playerid][pFillBizz];
	                	new string[400];
	                    format(string, sizeof(string), "{86ec67}Tanxa salaroshi:\t\t{FFFFFF}%d$\n{86ec67}Sawvavis raodenoba:\t\t{FFFFFF}%d / %d\n{86ec67}Produqtis raodenoba:\t\t{FFFFFF}%d", FillInfo[b][fBank], FillInfo[b][fFuel], FillInfo[b][fMaxFuel], FillInfo[b][fProd]);
	                    ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "Biznesis statistika", string, "Migeba", "");
					}
					case 3:
					{
					    SendInfoMessage(playerid, "Es funqcia daemateba shemdeg ganaxlebebze");
					}
					case 4:
					{
					    callcmd::sellfill(playerid);
					}
					case 5:
					{
					    SendInfoMessage(playerid, "Es funqcia daemateba shemdeg ganaxlebebze");
					}
				}
	    	}
	        else { }
	    }
	    case d_SELLFILL:
	    {
         	new b = PlayerInfo[playerid][pFillBizz];
	    	if(response)
	    	{
 	    		if(b == 999) return SendErrorMessage(playerid, "Tqven ar gaqvt biznesi");
 	    		PlayerInfo[playerid][pFillBizz] = -1;
 	    		UpdatePlayerData(playerid, "pFillBizz", PlayerInfo[playerid][pFillBizz]);
				FillInfo[b][fLock] = 1;
    			FillInfo[b][fOwned] = 0;
  	    		strmid(FillInfo[b][fOwner], "The State", 0, strlen("The State"), 15);
    	    	GiveServerMoney(playerid, FillInfo[b][fPrice]*3/4);
	    	    UpdateFill(b);
	    	    SaveFill(b);
			}
			else { }
	    }
	    case d_FILL:
	    {
	        if(response)
	        {
	            new fillid = GetPVarInt(playerid, "FILL_ID");
        		if(!strlen(inputtext))  return SendErrorMessage(playerid, "Tqven datovet veli carieli");
				if(strlen(inputtext) < 1 || strlen(inputtext) > 300) return SendErrorMessage(playerid, "Minimaluri raodenoba 1 litri, maqsimaluri - 300");
				if(FillInfo[fillid][fFuel] < strval(inputtext)) return SendErrorMessage(playerid, "Am benzin gasamart sadgruze ar aris sakmarisi sawvavi");
				if(vInfo[GetPlayerVehicleID(playerid)][vFuel] + strval(inputtext) > 300) return SendErrorMessage(playerid, "Am raodenobis sawvavi ar chaeteva tqvevs avzshi");
				if(PlayerInfo[playerid][pMoney] < FillInfo[fillid][fValue] * strval(inputtext)) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
				GiveServerMoney(playerid, - FillInfo[fillid][fValue] * strval(inputtext));
				FillInfo[fillid][fFuel] -= strval(inputtext);
				FillInfo[fillid][fBank] += FillInfo[fillid][fValue] * strval(inputtext);
				new Float:fuel = vInfo[GetPlayerVehicleID(playerid)][vFuel] +strval(inputtext);
				vInfo[GetPlayerVehicleID(playerid)][vFuel] = fuel;
				UpdateFill(fillid);
				SaveFill(fillid);
			}
	        else { }
	    }
	    case d_FILLSALARY:
	    {
			if(response)
			{
				switch(listitem)
				{
				    case 0:
				    {
				        new i = PlayerInfo[playerid][pFillBizz];
	                	new string[200];
	                    format(string, sizeof(string), "{86ec67}Tanxa salaroshi:\t\t{FFFFFF}%d$\n\n", FillInfo[i][fBank]);
	                    ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "Biznesis salaro", string, "Migeba", "");
				    }
				    case 1:
				    {
				        new i = PlayerInfo[playerid][pFillBizz];
	                    new string[200];
	                    format(string, sizeof(string), "{86ec67}Tanxa salaroshi:\t\t{FFFFFF}%d$\n\n\tSheiyvanet gasatani tanxis raodenoba", FillInfo[i][fBank]);
	                    ShowPlayerDialog(playerid, d_FILLSALARYWITHDRAW, DIALOG_STYLE_INPUT, "Tanxis moxsna salarodan", string, "Gamotana", "Gamosvla");
				    }
				    case 2:
				    {
				        new i = PlayerInfo[playerid][pFillBizz];
	                    new string[200];
	                    format(string, sizeof(string), "{86ec67}Tanxa salaroshi:\t\t{FFFFFF}%d$\n\n\tSheiyvanet shesatani tanxis raodenoba", FillInfo[i][fBank]);
	                    ShowPlayerDialog(playerid, d_FILLSALARYINPUT, DIALOG_STYLE_INPUT, "Tanxis shetana salaroshi", string, "Gamotana", "Gamosvla");
				    }
				}
			}
			else { }
	    }
	    case d_FILLSALARYWITHDRAW:
	    {
			if(response)
			{
       			if(isNumeric(inputtext) || !strlen(inputtext)) return 1;
				new cash = strval(inputtext);
				if(cash < 1) return SendErrorMessage(playerid, "Araswori tanxis odenoba");
				new biz = PlayerInfo[playerid][pFillBizz];
				if(FillInfo[biz][fBank] < cash) return SendErrorMessage(playerid, "Biznesis salaroshi ar aris sakmarisi tanxa");
				FillInfo[biz][fBank] -= cash;
				GiveServerMoney(playerid, cash);
				UpdateFill(biz);
				SaveFill(biz);

				new string[150];
				format(string, sizeof(string), "{4582A1}* B.INFO {FFFFFF}Tqven moxsenit biznesis angarishidan {86ec67}%d$", cash);
				SendClientMessage(playerid, 0xFFFFFFFF, string);
			}
			else { }
	    }
	    case d_FILLSALARYINPUT:
	    {
	        if(response)
	        {
	            if(isNumeric(inputtext) || !strlen(inputtext)) return 1;
				new cash = strval(inputtext);
				if(cash < 1) return SendErrorMessage(playerid, "Araswori tanxis odenoba");
				if(PlayerInfo[playerid][pMoney] < cash) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
				new biz = PlayerInfo[playerid][pFillBizz];
				FillInfo[biz][fBank] += cash;
				GiveServerMoney(playerid, -cash);
				UpdateFill(biz);
				SaveFill(biz);

				new string[150];
				format(string, sizeof(string), "{4582A1}* B.INFO {FFFFFF}Tqven sheitanet biznesis angarishze {86ec67}%d$", cash);
				SendClientMessage(playerid, 0xFFFFFFFF, string);
	        }
	        else { }
	    }
	    case d_DUTYFORM:
	    {
	        if(response)
	        {
	            if(GetPVarInt(playerid, "FracDuty") == 1) return SendInfoMessage(playerid, "Tqven ukve dawyebuli gaqvt mushaoba");
	            SetPlayerSkin(playerid, PlayerInfo[playerid][pModel]);
                SetPlayerToTeamColor(playerid);
                SetPVarInt(playerid, "FracDuty", 1);
                SendInfoMessage(playerid, "Samushao dge daiwyo");
	        }
	        else { }
	    }
	    case d_CHANGEDUTYFORM:
	    {
	        if(response)
	        {
	            if(GetPVarInt(playerid, "FracDuty") == 0) return SendInfoMessage(playerid, "Tqven ar dagiwyiat samushao dge");
	            SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
                SetPlayerToTeamColor(playerid);
                SetPVarInt(playerid, "FracDuty", 0);
                SendInfoMessage(playerid, "Samushao dge dasrulda");
	        }
	        else { }
		}
		case d_GETGUN:
			
		{
			if(response)
			{
			    switch(listitem)
			    {
			        case 0: GiveServerWeapon(playerid, 31, 50), wInfo[PlayerInfo[playerid][pMember]][wAmmo] -= 50, SaveWarehouse(PlayerInfo[playerid][pMember]);
			        case 1: GiveServerWeapon(playerid, 23, 30), wInfo[PlayerInfo[playerid][pMember]][wAmmo] -= 30, SaveWarehouse(PlayerInfo[playerid][pMember]);
			        case 2: GiveServerWeapon(playerid, 25, 10), wInfo[PlayerInfo[playerid][pMember]][wAmmo] -= 10, SaveWarehouse(PlayerInfo[playerid][pMember]);
			        case 3: GiveServerWeapon(playerid, 29, 50), wInfo[PlayerInfo[playerid][pMember]][wAmmo] -= 50, SaveWarehouse(PlayerInfo[playerid][pMember]);
			        case 4: GiveServerWeapon(playerid, 3, 1),   wInfo[PlayerInfo[playerid][pMember]][wAmmo] -= 5, SaveWarehouse(PlayerInfo[playerid][pMember]);
			        case 5: SetPlayerAttachedObject(playerid, 6, 19515, 1, 0.0190, 0.0500, 0.0030, 0.0000, -1.0000, 0.1000, 1.1340, 1.1780, 1.0890, -1, -1), wInfo[PlayerInfo[playerid][pMember]][wAmmo] -= 5, SaveWarehouse(PlayerInfo[playerid][pMember]);
			    }
			}
			else { }
		}
		case d_GANGSTORE:
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0: //tyviebis ageba
		            {
						ShowPlayerDialog(playerid, d_GETSTOREAMMO, DIALOG_STYLE_INPUT, "{FFFFFF}Gang Store {4582A1}- {FFFFFF}Get Ammo", "{FFFFFF}Chaweret tyviebis sachiro raodenoba\nMinimaluru - 1, Maqsimaluri - 500", "Archeva", "Gamosvla");
		            }
		            case 1: //narkotikis ageba
		            {
		                ShowPlayerDialog(playerid, d_GETSTOREDRUGS, DIALOG_STYLE_INPUT, "{FFFFFF}Gang Store{86ec67}- {FFFFFF}Get Drugs", "{FFFFFF}Chaweret narkotikis sachiro raodenoba\nMinimaluru - 1, Maqsimaluri - 10", "Archeva", "Gamosvla");
		            }
		            case 2: //tanxis ageba mxolod lideri
		            {
		                ShowPlayerDialog(playerid, d_GETSTOREMONEY, DIALOG_STYLE_INPUT, "{FFFFFF}Gang Store{86ec67}- {FFFFFF}Get Money", "{FFFFFF}Chaweret tanxis sachiro raodenoba\nMinimaluru - 1$, Maqsimaluri - 50.000$", "Archeva", "Gamosvla");
		            }
              		case 3: //tyviebis chadeba
		            {
						ShowPlayerDialog(playerid, d_PUTSTOREAMMO, DIALOG_STYLE_INPUT, "{FFFFFF}Gang Store{86ec67}- {FFFFFF}Put Ammo", "{FFFFFF}Chaweret tyviebis raodenoba\nMinimaluru - 1, Maqsimaluri - 500", "Archeva", "Gamosvla");
		            }
		            case 4: //narkotikis chadeba
		            {
		                ShowPlayerDialog(playerid, d_PUTSTOREDRUGS, DIALOG_STYLE_INPUT, "{FFFFFF}Gang Store{86ec67}- {FFFFFF}Put Drugs", "{FFFFFF}Chaweret narkotikis raodenoba\nMinimaluru - 1, Maqsimaluri - 10", "Archeva", "Gamosvla");
		            }
		            case 5: //tanxis chadeba mxolod lideri
		            {
		                ShowPlayerDialog(playerid, d_PUTSTOREMONEY, DIALOG_STYLE_INPUT, "{FFFFFF}Gang Store{86ec67}- {FFFFFF}Put Money", "{FFFFFF}Chaweret tanxis raodenoba\nMinimaluru - 1$, Maqsimaluri - 50.000$", "Archeva", "Gamosvla");
		            }
		        }
		    
		    }
		    else { }
		}
		case d_GETSTOREAMMO:
		{
		    if(response)
		    {
		        new ammo = strval(inputtext);
		        if(wInfo[PlayerInfo[playerid][pMember]][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
		        if(wInfo[PlayerInfo[playerid][pMember]][wAmmo] < ammo) return SendErrorMessage(playerid, "Sawyobshi ar aris sakmarisi raodenobis tyviebi");
		        if(ammo < 1 || ammo > 500) return SendErrorMessage(playerid, "Minimaluri raodneoba - 1, Maqsimaluri - 500");
				if(PlayerInfo[playerid][pAmmo] + ammo > 1000) return SendErrorMessage(playerid, "Tqven gaqvt tyviebis maqsimaluri raodneoba");
				wInfo[PlayerInfo[playerid][pMember]][wAmmo] -= ammo;
				SaveWarehouse(PlayerInfo[playerid][pMember]);
				PlayerInfo[playerid][pAmmo] += ammo;
				UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
				new str[100];
				format(str, sizeof(str), "[F] {DE781F}%s {FFFFFF}(%d) aigo sawyobidan {4582A1}%d {FFFFFF}tyvia", PlayerInfo[playerid][pName], playerid, ammo);
				SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, str);
		    }
		    else { }
		}
  		case d_GETSTOREDRUGS:
		{
		    if(response)
		    {
		        new drug = strval(inputtext);
		        if(wInfo[PlayerInfo[playerid][pMember]][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
		        if(wInfo[PlayerInfo[playerid][pMember]][wDrug] < drug) return SendErrorMessage(playerid, "Sawyobshi ar aris sakmarisi raodenobis narkotiki");
	         	if(drug < 1 || drug > 10) return SendErrorMessage(playerid, "Minimaluri raodneoba - 1, Maqsimaluri - 10");
				if(PlayerInfo[playerid][pDrugs] + drug > 100) return SendErrorMessage(playerid, "Tqven gaqvt narkotikis maqsimaluri raodneoba");
				wInfo[PlayerInfo[playerid][pMember]][wDrug] -= drug;
				SaveWarehouse(PlayerInfo[playerid][pMember]);
				PlayerInfo[playerid][pDrugs] += drug;
				UpdatePlayerData(playerid, "pDrugs", PlayerInfo[playerid][pDrugs]);
				new str[100];
				format(str, sizeof(str), "[F] {DE781F}%s {FFFFFF}(%d) aigo sawyobidan {4582A1}%d gr. {FFFFFF}narkotiki", PlayerInfo[playerid][pName], playerid, drug);
				SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, str);
		    }
		    else { }
		}
  		case d_GETSTOREMONEY:
		{
		    if(response)
		    {
		        new money = strval(inputtext);
		        if(wInfo[PlayerInfo[playerid][pMember]][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
		        if(PlayerInfo[playerid][pRank] != 10) return SendErrorMessage(playerid, "Xelmisawvdomia mxolod lideristvis");
		        if(wInfo[PlayerInfo[playerid][pMember]][wBank] < money) return SendErrorMessage(playerid, "Sawyobshi ar aris sakmarisi raodenobis tanxa");
	         	if(money < 1 || money > 50000) return SendErrorMessage(playerid, "Minimaluri raodneoba - 1$, Maqsimaluri - 50.000$");
				wInfo[PlayerInfo[playerid][pMember]][wBank] -= money;
				SaveWarehouse(PlayerInfo[playerid][pMember]);
				GiveServerMoney(playerid, money);
				new str[100];
				format(str, sizeof(str), "[F] {DE781F}%s {FFFFFF}(%d) aigo sawyobidan {4582A1}%d$", PlayerInfo[playerid][pName], playerid, money);
				SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, str);
		    }
		    else { }
		}
		case d_PUTSTOREAMMO:
		{
			if(response)
			{
			    new ammo = strval(inputtext);
			    if(wInfo[PlayerInfo[playerid][pMember]][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
			    if(wInfo[PlayerInfo[playerid][pMember]][wAmmo] + ammo > 5000) return SendErrorMessage(playerid, "Am raodenis tyvia ar chaeteva sawyobshi");
			    if(PlayerInfo[playerid][pAmmo] < ammo) return SendErrorMessage(playerid, "Tqvne ar gaqvt shesabamisi raodenobis tyviebi");
			    if(ammo < 1 || ammo > 500) return SendErrorMessage(playerid, "Minimaluri raodneoba - 1, Maqsimaluri - 500");
			    PlayerInfo[playerid][pAmmo] -= ammo;
			    UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
			    wInfo[PlayerInfo[playerid][pMember]][wAmmo] += ammo;
			    SaveWarehouse(PlayerInfo[playerid][pMember]);
			    new str[100];
				format(str, sizeof(str), "[F] {DE781F}%s {FFFFFF}(%d) chado sawyobidan {4582A1}%d {ffffff}tyvia", PlayerInfo[playerid][pName], playerid, ammo);
				SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, str);
			}
			else { }
		}
  		case d_PUTSTOREDRUGS:
		{
			if(response)
			{
			    new drug = strval(inputtext);
			    if(wInfo[PlayerInfo[playerid][pMember]][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
			    if(wInfo[PlayerInfo[playerid][pMember]][wDrug] + drug > 5000) return SendErrorMessage(playerid, "Am raodenis narkotiki ar chaeteva sawyobshi");
			    if(PlayerInfo[playerid][pDrugs] < drug) return SendErrorMessage(playerid, "Tqvne ar gaqvt shesabamisi raodenobis narkotiki");
			    if(drug < 1 || drug > 100) return SendErrorMessage(playerid, "Minimaluri raodneoba - 1, Maqsimaluri - 100");
			    PlayerInfo[playerid][pDrugs] -= drug;
			    UpdatePlayerData(playerid, "pDrugs", PlayerInfo[playerid][pDrugs]);
			    wInfo[PlayerInfo[playerid][pMember]][wDrug] += drug;
			    SaveWarehouse(PlayerInfo[playerid][pMember]);
			    new str[100];
				format(str, sizeof(str), "[F] {DE781F}%s {FFFFFF}(%d) chado sawyobidan {4582A1}%d gr.{ffffff}narkotiki", PlayerInfo[playerid][pName], playerid, drug);
				SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, str);
			}
			else { }
		}
  		case d_PUTSTOREMONEY:
		{
			if(response)
			{
			    new money = strval(inputtext);
			    if(wInfo[PlayerInfo[playerid][pMember]][wStatus] == 0) return SendErrorMessage(playerid, "Sawyobi daxurulia");
			    if(wInfo[PlayerInfo[playerid][pMember]][wBank] + money > 2000000) return SendErrorMessage(playerid, "Sawyobshi aris maqsimaluri raodenobis tanxa");
			    if(PlayerInfo[playerid][pMoney] < money) return SendErrorMessage(playerid, "Tqvne ar gaqvt shesabamisi raodenobis tanxa");
			    if(money < 1 || money > 50000) return SendErrorMessage(playerid, "Minimaluri raodneoba - 1, Maqsimaluri - 50.000$");
			    GiveServerMoney(playerid, -money);
			    wInfo[PlayerInfo[playerid][pMember]][wBank] += money;
			    SaveWarehouse(PlayerInfo[playerid][pMember]);
			    new str[100];
				format(str, sizeof(str), "[F] {DE781F}%s {FFFFFF}(%d) chado sawyobidan {4582A1}%d$", PlayerInfo[playerid][pName], playerid, money);
				SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, str);
			}
			else { }
		}
		case d_ADMINLOGIN:
		{
      		if(!response) return 1;
			new string[144];
		    for(new i = strlen(inputtext); i != 0; --i)
		    {
		    	switch(inputtext[i])
				{
				    case 'À'..'ß', 'à'..'ÿ', ' ': return ShowPlayerDialog(playerid, d_ADMINLOGIN, DIALOG_STYLE_PASSWORD, "{FFCC00}Admin authorization", "{FFFFFF}Chaweret paroli, gaitvaliswinet shemdegi pirobebi:\n\n{FFCC00}• {FFFFFF}Parolis sigrdze unda iyos {FFCC00}6 {FFFFFF}- {FFCC00}32 {FFFFFF}simbolomde\n{FFCC00}• {FFFFFF}Paroli sheyvanili unda iyos latinurisimboloebit\n{FFCC00}• {FFFFFF}Rata gaiarot avtorizacia /alogin", "Migeba", "Gamosvla");
				}
			}
			if(GetPVarInt(playerid, "type_alogin") == 1)
			{
				if(!strlen(inputtext) || GetString(inputtext, "qwerty") || strlen(inputtext) < 6 || strlen(inputtext) > 32 || strfind(inputtext, "=", true) != -1)
				return ShowPlayerDialog(playerid, d_ADMINLOGIN, DIALOG_STYLE_PASSWORD, "{FFCC00}Admin authorization", "{FFFFFF}Chaweret paroli, gaitvaliswinet shemdegi pirobebi:\n\n{FFCC00}• {FFFFFF}Parolis sigrdze unda iyos {FFCC00}6 {FFFFFF}- {FFCC00}32 {FFFFFF}simbolomde\n{FFCC00}• {FFFFFF}Paroli sheyvanili unda iyos latinurisimboloebit\n{FFCC00}• {FFFFFF}Rata gaiarot avtorizacia /alogin", "Migeba", "Gamosvla");
				SetPVarString(playerid, "inputtext", inputtext);
				format(string, sizeof(string), "SELECT * FROM `admin` WHERE admName = '%s'", GetName(playerid));
				mysql_tquery(dbHandle, string, "RegAlogin", "is", playerid, GetName(playerid));
			}
			else
			{
			    if(!strlen(inputtext)) return ShowPlayerDialog(playerid, d_ADMINLOGIN, DIALOG_STYLE_PASSWORD, "{FFCC00}Admin authorization", "{FFFFFF}Sheiyvanet tqveni administratoris paroli", "migeba", "gamosvla");
				mysql_format(dbHandle, string, sizeof(string), "SELECT * FROM `admin` WHERE admName = '%s' AND admPassword = '%e'", GetName(playerid), inputtext);
				mysql_tquery(dbHandle, string, "AuthReg", "i", playerid);
			}
			return 1;
		}
		case d_AMMONATION:
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
					{
					    new string[300];
					    format(string, sizeof(string),
					    "{FFCC00}WEAPON\t{FFCC00}PRICE\n\
					    {828282}- {FFFFFF}9mm\t{33AA33}1500$\n\
					    {828282}- {FFFFFF}SD PISTOL\t{33AA33}2000$\n\
					    {828282}- {FFFFFF}KNIFE\t{33AA33}500$\n\
					    {828282}- {FFFFFF}BASEBALL BAT\t{33AA33}200$\n\
					    {828282}- {FFFFFF}PARACHUTE\t{33AA33}2500$\n\
					    {828282}- {FFFFFF}RIFLE\t{33AA33}4500$\n", "Archeva", "Gamosvla");
                        ShowPlayerDialog(playerid, d_BUYWEAPON, DIALOG_STYLE_TABLIST_HEADERS, "{4582A1}WEAPON",string, "Yidva","Gasvla");
					}
		            case 1:
					{
					    SetPVarInt(playerid, "GUN_ID", 0);
						ShowPlayerDialog(playerid, d_BUYAMMO, DIALOG_STYLE_INPUT, "{FFCC00}AMMO", "{FFFFFF}Chaweret tyviebis sachiro raodenoba\n{828282}* {FFFFFF}1 tyvia = 10$\n", "Yidva", "Gamosvla");
					}
				}
		    }
		    else { }
		}
		case d_BUYWEAPON:
		{
			if(response)
			{
			    switch(listitem)
			    {
			        case 0: //id 22
			        {
			            SetPVarInt(playerid, "GUN_ID", 22);
			            ShowPlayerDialog(playerid, d_BUYAMMO, DIALOG_STYLE_INPUT, "{FFCC00}AMMO", "{FFFFFF}Tqven airchiet iaragi {33AA33}9mm\n{FFFFFF}Chaweret tyviebis sachiro raodenoba\n{828282}* {FFFFFF}1 tyvia = 10$\n", "Yidva", "Gamosvla");
                        GiveServerMoney(playerid, -1500);
				    }
			        case 1: //id 23
			        {
			            SetPVarInt(playerid, "GUN_ID", 23);
			            ShowPlayerDialog(playerid, d_BUYAMMO, DIALOG_STYLE_INPUT, "{FFCC00}AMMO", "{FFFFFF}Tqven airchiet iaragi {33AA33}SD PISTOL\n{FFFFFF}Chaweret tyviebis sachiro raodenoba\n{828282}* {FFFFFF}1 tyvia = 10$\n", "Yidva", "Gamosvla");
                        GiveServerMoney(playerid, -2000);
				    }
			        case 2: // knife 4
			        {
			            if(PlayerInfo[playerid][pMoney] < 500) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
			            GiveServerWeapon(playerid, 4, 1);
			            GiveServerMoney(playerid, -500);
			        }
			        case 3: //bita - 5
			        {
			            if(PlayerInfo[playerid][pMoney] < 200) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
			            GiveServerWeapon(playerid, 5, 1);
			            GiveServerMoney(playerid, -200);
			        }
			        case 4: //parachute 46
			        {
			            if(PlayerInfo[playerid][pMoney] < 2500) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
			            GiveServerWeapon(playerid, 46, 1);
			            GiveServerMoney(playerid, -2500);
			        }
			        case 5: //rifle 33
			        {
			            SetPVarInt(playerid, "GUN_ID", 33);
			            ShowPlayerDialog(playerid, d_BUYAMMO, DIALOG_STYLE_INPUT, "{FFCC00}AMMO", "{FFFFFF}Tqven airchiet iaragi {33AA33}RIFLE\n{FFFFFF}Chaweret tyviebis sachiro raodenoba\n{828282}* {FFFFFF}1 tyvia = 10$\n", "Yidva", "Gamosvla");
                        GiveServerMoney(playerid, -4500);
					}
			    }
			}
			else { }
		}
		case d_BUYAMMO:
		{
		    if(response)
		    {
      			new ammo = strval(inputtext);
         		if(PlayerInfo[playerid][pMoney] < ammo*10) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tanxa");
	 			if(ammo < 1 || ammo > 100) return SendErrorMessage(playerid, "Minimaluri raodneoba - 1, Maqsimaluri - 100");
	 			if(GetPVarInt(playerid, "GUN_ID") > 0)
	 			{
					GiveServerWeapon(playerid, GetPVarInt(playerid, "GUN_ID"), ammo);
					GiveServerMoney(playerid, -ammo*10);
	 			}
	 			if(GetPVarInt(playerid, "GUN_ID") == 0)
 				{
				    PlayerInfo[playerid][pAmmo] += ammo;
				    UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
					GiveServerMoney(playerid, -ammo*10);
	 			}
				SetPVarInt(playerid, "GUN_ID", 0);
		    }
		    else { }
		}
		case d_LMENU:
		{
		    if(response)
		    {
		        switch(listitem)
		        {
		            case 0:
		            {
						if(wInfo[PlayerInfo[playerid][pMember]][wStatus] == 0)
						{
						    wInfo[PlayerInfo[playerid][pMember]][wStatus] = 1;
						    SaveWarehouse(PlayerInfo[playerid][pMember]);
							if(gov_member(playerid))
							{
							    new string[256];
								format(string, sizeof(string), "[R] %s %s[%d]: gaago organizaciis sawyobi", FractionRankName[PlayerInfo[playerid][pMember]-1][PlayerInfo[playerid][pRank]], PlayerInfo[playerid][pName], playerid);
								SendRadioMessage(PlayerInfo[playerid][pMember], 0xa8e607FF, string);
							}
							if(ghetto_members(playerid) || mafia_members(playerid))
							{
							    new string[256];
								format(string, sizeof(string), "[F] %s %s[%d]: gaago sawyobi", FractionRankName[PlayerInfo[playerid][pMember]-1][PlayerInfo[playerid][pRank]], PlayerInfo[playerid][pName], playerid);
								SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, string);
							}
							return true;
						}
						else if(wInfo[PlayerInfo[playerid][pMember]][wStatus] == 1)
						{
						    wInfo[PlayerInfo[playerid][pMember]][wStatus] = 0;
						    SaveWarehouse(PlayerInfo[playerid][pMember]);
          					if(gov_member(playerid))
							{
							    new string[256];
								format(string, sizeof(string), "[R] %s %s[%d]: daketa organizaciis sawyobi", FractionRankName[PlayerInfo[playerid][pMember]-1][PlayerInfo[playerid][pRank]], PlayerInfo[playerid][pName], playerid);
								SendRadioMessage(PlayerInfo[playerid][pMember], 0xa8e607FF, string);
							}
							if(ghetto_members(playerid) || mafia_members(playerid))
							{
							    new string[256];
								format(string, sizeof(string), "[F] %s %s[%d]: daketa sawyobi", FractionRankName[PlayerInfo[playerid][pMember]-1][PlayerInfo[playerid][pRank]], PlayerInfo[playerid][pName], playerid);
								SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, string);
							}
							return true;
						}
		            }
		            case 1:
		            {
		                callcmd::members(playerid);
		            }
		        }
		    }
		    else { }
		}
  		case d_CHANGEFRACSKIN:
		{
		    if(response)
			{ 
			    new string[64 + MAX_PLAYER_NAME - 4];
				PlayerInfo[GetPVarInt(playerid, "Invited")][pModel] = FractionSkins[PlayerInfo[playerid][pMember]][listitem];
				SetPlayerSkin(GetPVarInt(playerid, "Invited"), PlayerInfo[GetPVarInt(playerid, "Invited")][pModel]);
				UpdatePlayerData(playerid, "pModel", PlayerInfo[playerid][pModel]);
				format(string, sizeof(string), "%s[%d] shegicvalat organizaciis skini", GetName(playerid), playerid);
				SendClientMessage(GetPVarInt(playerid, "Invited"), 0xFFFFFFFF, string);
				DeletePVar(playerid, "Invited");
			}
			else
			{
   				DeletePVar(playerid, "Invited");
			}
		}
	}
	return 1;
}

forward AuthReg(playerid);
public AuthReg(playerid)
{
    new rows;
    new query[2500];
	cache_get_row_count(rows);
	if(!rows)
	{
	    SendErrorMessage(playerid, "Araswori paroli");
		SetPVarInt(playerid, "attempt_password", GetPVarInt(playerid, "attempt_password")+1); //parolis chaweris cdebis raodenoba
		if(GetPVarInt(playerid, "attempt_password")>3)
		{
			DeletePVar(playerid, "attempt_password");
			return KickEx(playerid, 2112); //kick
		}
	}
	else
	{
		AdminLogged[playerid] = true;
		AdminInfo[playerid][admID] = cache_get_value_name_int(0, "admID", AdminInfo[playerid][admID]);
		AdminInfo[playerid][admGoto] = cache_get_value_name_int(0, "admGoto", AdminInfo[playerid][admGoto]);
	    AdminInfo[playerid][admGethere] = cache_get_value_name_int(0, "admGethere", AdminInfo[playerid][admGethere]);
	    AdminInfo[playerid][admSpectate] = cache_get_value_name_int(0, "admSpectate", AdminInfo[playerid][admSpectate]);
	    AdminInfo[playerid][admKicked] = cache_get_value_name_int(0, "admKicked", AdminInfo[playerid][admKicked]); // kicked
		AdminInfo[playerid][admWarned] = cache_get_value_name_int(0, "admWarned", AdminInfo[playerid][admWarned]); // warned
 		AdminInfo[playerid][admOffWarned] = cache_get_value_name_int(0, "admOffWarned", AdminInfo[playerid][admOffWarned]); // offwarned
 		AdminInfo[playerid][admBaned] = cache_get_value_name_int(0, "admBaned", AdminInfo[playerid][admBaned]); // baned
 		AdminInfo[playerid][admOffBaned] = cache_get_value_name_int(0, "admOffBaned", AdminInfo[playerid][admOffBaned]); // offbaned
 		AdminInfo[playerid][admMuted] = cache_get_value_name_int(0, "admMuted", AdminInfo[playerid][admMuted]); // muted
 		AdminInfo[playerid][admAnsed] = cache_get_value_name_int(0, "admAnsed", AdminInfo[playerid][admAnsed]); // ansed

	  	static const AdminRanks[10][50] = {"Support","JR. Administrator","Administrator","Head Administrator","Chief Administrator","Server Tracker","Leader Tester","Co-Owner","Developer","Full Stack Developer"};
		new string[144];
		format(string, sizeof(string), "{FF6347}* A.INFO {FFFFFF}Tqven gaiaret avtorizacia rogorc %s", AdminRanks[PlayerInfo[playerid][pAdmin]-1]);
	 	SendClientMessage(playerid, 0xFF6347FF, string);
		 	
  		query[0] = EOS;
		format(query, 128, "UPDATE `admin` SET last_connect = CURDATE() WHERE admName = '%s' LIMIT 1", GetName(playerid));
		mysql_tquery(dbHandle, query, "", "");
	}
	return 1;
}


forward RegAlogin(playerid, name[]);
public RegAlogin(playerid, name[])
{
    new rows;
	cache_get_row_count(rows);
	if(!rows) return 1;
	new inputtext[16];
	GetPVarString(playerid, "inputtext", inputtext, sizeof(inputtext));
	new query[2500];
	query[0] = EOS;
	mysql_format(dbHandle, query, sizeof(query), "UPDATE `admin` SET admPassword = '%s' WHERE admName = '%s' LIMIT 1", inputtext, GetName(playerid));
	mysql_tquery(dbHandle, query, "", "");
	AdminLogged[playerid] = true;
	new string[144];
	format(string, sizeof(string), "{FF6347}* A.INFO {FFFFFF}Tqveni administratoris paroli: {FFFFFF}%s", inputtext);
	SendClientMessage(playerid, 0xFF6347AA, string);
	SendInfoMessage(playerid, "Girchevt gadaigot screenshot, rata ar dagaviwyet. Gilaki: {FFFFFF}F8");
	
	static const AdminRanks[10][50] = {"Support","JR. Administrator","Administrator","Head Administrator","Chief Administrator","Server Tracker","Leader Tester","Co-Owner","Developer","Full Stack Developer"};
	format(string, sizeof(string), "{FF6347}* A.INFO {FFFFFF}Tqven gaiaret avtorizacia rogorc %s", AdminRanks[PlayerInfo[playerid][pAdmin]-1]);
 	SendClientMessage(playerid, 0xFF6347AA, string);
	
	query[0] = EOS;
	format(query, 128, "UPDATE `admin` SET last_connect = CURDATE() WHERE admName = '%s' LIMIT 1", GetName(playerid));
	mysql_tquery(dbHandle, query, "", "");
	return 1;
}

forward Alogin(playerid, name[]);
public Alogin(playerid, name[])
{
	new rows;
	cache_get_row_count(rows);
	if(!rows)
	{
		if(PlayerInfo[playerid][pAdmin] > 0)
		{
			PlayerInfo[playerid][pAdmin] = 0;
			UpdatePlayerData(playerid, "pAdmin", PlayerInfo[playerid][pAdmin]);
		}
		return 1;
	}
	new Password[32];
	cache_get_value_name(0, "admPassword", Password, 32);
	if(GetString(Password, "qwerty"))
	{
		SetPVarInt(playerid, "type_alogin", 1);
		ShowPlayerDialog(playerid, d_ADMINLOGIN, DIALOG_STYLE_PASSWORD, "{FFCC00}Admin authorization", "{FFFFFF}Chaweret paroli, gaitvaliswinet shemdegi pirobebi:\n\n{FFCC00}• {FFFFFF}Parolis sigrdze unda iyos {FFCC00}6 {FFFFFF}- {FFCC00}32 {FFFFFF}simbolomde\n{FFCC00}• {FFFFFF}Paroli sheyvanili unda iyos latinurisimboloebit\n{FFCC00}• {FFFFFF}Rata gaiarot avtorizacia /alogin", "Migeba", "Gamosvla");
	}
	else
	{
		SetPVarInt(playerid, "type_alogin", 0);
		ShowPlayerDialog(playerid, d_ADMINLOGIN, DIALOG_STYLE_PASSWORD, "{FFCC00}Admin authorization", "{FFFFFF}Sheiyvanet tqveni administratoris paroli", "migeba", "gamosvla");
	}
	return 1;
}

forward SetAdmin(playerid, name[], level);
public SetAdmin(playerid, name[], level)
{
	new string[350];
	new rows;
	cache_get_row_count(rows);
	if(rows)
	{
		new level2 = cache_get_value_name_int(0, "admLevel", AdminInfo[playerid][admLevel]);
		if(level2 > PlayerInfo[playerid][pAdmin]) return SendErrorMessage(playerid, "Tqvenze magal level administrators ver danishnavt");
		if(!level)
		{
		    if(GetPlayerID(name) != INVALID_PLAYER_ID) PlayerInfo[GetPlayerID(name)][pAdmin] = 0;
      		UpdatePlayerData(playerid, "pAdmin", PlayerInfo[playerid][pAdmin]);
			mysql_format(dbHandle, string, sizeof(string), "DELETE FROM `admin` WHERE admName = '%s'", name);
			mysql_tquery(dbHandle, string, "", "");
			format(string, sizeof(string), "{FF6347}* A.INFO {FFFFFF}Tqven moxsenit %s administratoris postidan", name);
	    	SendClientMessage(playerid, 0xFF6347AA, string);
		}
		else
		{
		    if(GetPlayerID(name) != INVALID_PLAYER_ID) PlayerInfo[GetPlayerID(name)][pAdmin] = level;
			mysql_format(dbHandle, string, sizeof(string), "UPDATE `admin` SET admlevel = %d WHERE admName = '%s' LIMIT 1", level, name);
			mysql_tquery(dbHandle, string, "", "");
			format(string, sizeof(string), "{FF6347}* A.INFO {FFFFFF}Tqven danishnet %s %i level administratorad", name, level);
	    	SendClientMessage(playerid, 0xFF6347AA, string);
	    	PlayerInfo[playerid][pAdmin] = level;
			UpdatePlayerData(playerid, "pAdmin", PlayerInfo[playerid][pAdmin]);
		}
	}
	else
	{
		if(!level) return SendErrorMessage(playerid, "Motamashe ar aris administratori");
		mysql_format(dbHandle, string, sizeof(string), "INSERT INTO `admin` (admName,admLevel,last_connect,put_admin,data) VALUES ('%s',%d,CURDATE(),'%s',CURDATE())", name, level, GetName(playerid));
		mysql_tquery(dbHandle, string, "", "");
		format(string, sizeof(string), "{FF6347}* A.INFO {FFFFFF}%s daemata administratorebis siashi. Admin level %i", name, level);
	    SendClientMessage(playerid, 0xFF6347AA, string);
	    PlayerInfo[GetPlayerID(name)][pAdmin] = level;
	    UpdatePlayerData(playerid, "pAdmin", PlayerInfo[playerid][pAdmin]);
	    if(GetPlayerID(name) != INVALID_PLAYER_ID)
    	{
    	    PlayerInfo[GetPlayerID(name)][pAdmin] = level;
    	    UpdatePlayerData(playerid, "pAdmin", PlayerInfo[playerid][pAdmin]);
    	    format(string, sizeof(string), "{FF6347}* A.INFO {FFFFFF}%s-ma dagnishnat administratorad", GetName(playerid));
	    	SendClientMessage(GetPlayerID(name), 0xFF6347AA, string);
    	}
	}
	return 1;
}

//player personal information
forward LoadPlayerData(playerid);
public LoadPlayerData(playerid)
{
	cache_get_value_name_int(0, "ID", PlayerInfo[playerid][ID]);
	cache_get_value_name_int(0, "pLevel", PlayerInfo[playerid][pLevel]);
	cache_get_value_name_int(0, "pSex", PlayerInfo[playerid][pSex]);
	cache_get_value_name_int(0, "pSkin", PlayerInfo[playerid][pSkin]);
	cache_get_value_name_int(0, "pMoney", PlayerInfo[playerid][pMoney]);
	cache_get_value_name_int(0, "pHouse", PlayerInfo[playerid][pHouse]);
	cache_get_value_name_int(0, "pBizz", PlayerInfo[playerid][pBizz]);
	cache_get_value_name_int(0, "pFillBizz", PlayerInfo[playerid][pFillBizz]);
	cache_get_value_name_int(0, "pSetSpawn", PlayerInfo[playerid][pSetSpawn]);
    cache_get_value_name_int(0, "pBank", PlayerInfo[playerid][pBank]);
    cache_get_value_name_int(0, "pLeader", PlayerInfo[playerid][pLeader]);
    cache_get_value_name_int(0, "pRank", PlayerInfo[playerid][pRank]);
    cache_get_value_name_int(0, "pMember", PlayerInfo[playerid][pMember]);
    cache_get_value_name_int(0, "pModel", PlayerInfo[playerid][pModel]);
    cache_get_value_name_int(0, "pDrugs", PlayerInfo[playerid][pDrugs]);
    cache_get_value_name_int(0, "pAmmo", PlayerInfo[playerid][pAmmo]);
    cache_get_value_name_int(0, "pAdmin", PlayerInfo[playerid][pAdmin]);
    cache_get_value_name_int(0, "pWarn", PlayerInfo[playerid][pWarn]);
    cache_get_value_name_int(0, "pUnwarntime", PlayerInfo[playerid][pUnwarntime]);
	//
 	new ban;
  	cache_get_value_name_int(0, "pBan", ban);
   	if(ban > getdate())
    {
		new string[64];
		format(string, sizeof(string), "Tqven gadevt ban\nBan agexsnebat %d dgeshi", ban-getdate());
  		ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "Tqveni account dablokilia!", string, "Okay", "");
    	KickEx(playerid);
     	return true;
    }
    if(ban <= getdate())
    {
        PlayerInfo[playerid][pBan] = 0;
        UpdatePlayerData(playerid, "pBan", PlayerInfo[playerid][pBan]);
    }
	//
	ResetPlayerMoney(playerid);
	ResetServerWeapon(playerid);
	GivePlayerMoney(playerid, PlayerInfo[playerid][pMoney]);
	SetPlayerSkin(playerid, PlayerInfo[playerid][pSkin]);
	PlayerInfo[playerid][pLogin] = 1;
	TogglePlayerSpectating(playerid, false);
	SetPlayerScore(playerid, PlayerInfo[playerid][pLevel]);
	SpawnPlayer(playerid);
	return true;
}

//load fillings
forward LoadFillings();
public LoadFillings()
{
	new rows, time = GetTickCount();
	cache_get_row_count(rows);
	if(rows)
	{
	    for(new i = 0; i < rows; i++)
	    {
	        cache_get_value_name_int(i, "fID", FillInfo[i][fID]);
	        
	        cache_get_value_name(i, "fOwner", FillInfo[i][fOwner], MAX_PLAYER_NAME);

			cache_get_value_name_float(i, "fMenu_X", FillInfo[i][fMenu_X]);
			cache_get_value_name_float(i, "fMenu_Y", FillInfo[i][fMenu_Y]);
			cache_get_value_name_float(i, "fMenu_Z", FillInfo[i][fMenu_Z]);
			
			cache_get_value_name_int(i, "fLock", FillInfo[i][fLock]);
			cache_get_value_name_int(i, "fPrice", FillInfo[i][fPrice]);
			cache_get_value_name_int(i, "fValue", FillInfo[i][fValue]);
			cache_get_value_name_int(i, "fProd", FillInfo[i][fProd]);
			cache_get_value_name_int(i, "fFuel", FillInfo[i][fFuel]);
			cache_get_value_name_int(i, "fMaxFuel", FillInfo[i][fMaxFuel]);
			cache_get_value_name_int(i, "fBank", FillInfo[i][fBank]);
			cache_get_value_name_int(i, "fOwned", FillInfo[i][fOwned]);
			cache_get_value_name_int(i, "fLockTime", FillInfo[i][fLockTime]);
			
			FillInfo[i][fIcon] = CreateDynamicMapIcon(FillInfo[i][fMenu_X], FillInfo[i][fMenu_Y], FillInfo[i][fMenu_Z], 55, 0xFFFFFFFF, 0, -1, -1, 50);
			FillInfo[i][fPick] = CreateDynamicPickup(1650, 23, FillInfo[i][fMenu_X], FillInfo[i][fMenu_Y], FillInfo[i][fMenu_Z]);
			Fill3DText[i] = CreateDynamic3DTextLabel(" BIZZ ",0xE1AE3CFF, FillInfo[i][fMenu_X], FillInfo[i][fMenu_Y], FillInfo[i][fMenu_Z], 25.0);

			UpdateFill(i);
			TotalFill++;
	    }
	    printf("[CP] Gas station loaded: %d | Time: %d (ms)", TotalFill, GetTickCount() - time);
	}
}

forward LoadWarehouses();
public LoadWarehouses()
{
    new rows, time = GetTickCount();
	cache_get_row_count(rows);
	if(rows)
	{
	    for(new i = 1; i < rows; i++)
		{
		    cache_get_value_name_int(i, "wID", wInfo[i][wID]);
		    cache_get_value_name_int(i, "wAmmo", wInfo[i][wAmmo]);
		    cache_get_value_name_int(i, "wBank", wInfo[i][wBank]);
		    cache_get_value_name_int(i, "wDrug", wInfo[i][wDrug]);
			cache_get_value_name_int(i, "wStatus", wInfo[i][wStatus]);
			TotalWarehouse ++;
		}
		printf("[CP] Warehouses loaded: %d | Time: %d (ms)", rows, GetTickCount() - time);
	}
}

//load server bussines's
forward LoadBussines();
public LoadBussines()
{
	new rows, time = GetTickCount();
	cache_get_row_count(rows);
	if(rows)
	{
	    for(new i = 0; i < rows; i++)
	    {
			cache_get_value_name_int(i, "bID", BizzInfo[i][bID]);
			
			cache_get_value_name(i, "bOwner", BizzInfo[i][bOwner], MAX_PLAYER_NAME);
			cache_get_value_name(i, "bName", BizzInfo[i][bName], 32);
			
			cache_get_value_name_float(i, "bEnter_X", BizzInfo[i][bEnter_X]);
			cache_get_value_name_float(i, "bEnter_Y", BizzInfo[i][bEnter_Y]);
			cache_get_value_name_float(i, "bEnter_Z", BizzInfo[i][bEnter_Z]);

            cache_get_value_name_float(i, "bExit_X", BizzInfo[i][bExit_X]);
			cache_get_value_name_float(i, "bExit_Y", BizzInfo[i][bExit_Y]);
			cache_get_value_name_float(i, "bExit_Z", BizzInfo[i][bExit_Z]);
			
			cache_get_value_name_float(i, "bBar_X", BizzInfo[i][bBar_X]);
			cache_get_value_name_float(i, "bBar_Y", BizzInfo[i][bBar_Y]);
			cache_get_value_name_float(i, "bBar_Z", BizzInfo[i][bBar_Z]);
			
			cache_get_value_name_int(i, "bLock", BizzInfo[i][bLock]);
			cache_get_value_name_int(i, "bPrice", BizzInfo[i][bPrice]);
			cache_get_value_name_int(i, "bType", BizzInfo[i][bType]);
			cache_get_value_name_int(i, "bProd", BizzInfo[i][bProd]);
			cache_get_value_name_int(i, "bProfitHour", BizzInfo[i][bProfitHour]);
			cache_get_value_name_int(i, "bBank", BizzInfo[i][bBank]);
			cache_get_value_name_int(i, "bMaxProd", BizzInfo[i][bMaxProd]);
			cache_get_value_name_int(i, "bGuest", BizzInfo[i][bGuest]);
			cache_get_value_name_int(i, "bProfit", BizzInfo[i][bProfit]);
			cache_get_value_name_int(i, "bOwned", BizzInfo[i][bOwned]);
			cache_get_value_name_int(i, "bInt", BizzInfo[i][bInt]);
			cache_get_value_name_int(i, "bWorld", BizzInfo[i][bWorld]);
			cache_get_value_name_int(i, "bImprove", BizzInfo[i][bImprove]);
			cache_get_value_name_int(i, "bTax", BizzInfo[i][bTax]);
			cache_get_value_name_int(i, "bLockTime", BizzInfo[i][bLockTime]);
			
			switch(BizzInfo[i][bType])
			{
			    case 1: // 24/7
			    {
			        BizzInfo[i][bIcon] = CreateDynamicMapIcon(BizzInfo[i][bEnter_X], BizzInfo[i][bEnter_Y], BizzInfo[i][bEnter_Z], 17, 0xFFFFFFFF, 0, -1, -1, 50);
			        BizzInfo[i][bPick] = CreateDynamicPickup(19592, 23, BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z]);
					BizzInfo[i][bText] = CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z],25.0);
				}
			    case 2: // burger
			    {
			        BizzInfo[i][bIcon] = CreateDynamicMapIcon(BizzInfo[i][bEnter_X], BizzInfo[i][bEnter_Y], BizzInfo[i][bEnter_Z], 10, 0xFFFFFFFF, 0, -1, -1, 50);
			        BizzInfo[i][bPick] = CreateDynamicPickup(2663, 23, BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z]);
					BizzInfo[i][bText] = CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z],25.0);
				}
       			case 3: // club
			    {
			        BizzInfo[i][bIcon] = CreateDynamicMapIcon(BizzInfo[i][bEnter_X], BizzInfo[i][bEnter_Y], BizzInfo[i][bEnter_Z], 48, 0xFFFFFFFF, 0, -1, -1, 50);
			        BizzInfo[i][bPick] = CreateDynamicPickup(1546, 23, BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z]);
					BizzInfo[i][bText] = CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z],25.0);
				}
				case 4: //skin shop
				{
				    BizzInfo[i][bIcon] = CreateDynamicMapIcon(BizzInfo[i][bEnter_X], BizzInfo[i][bEnter_Y], BizzInfo[i][bEnter_Z], 45, 0xFFFFFFFF, 0, -1, -1, 50);
				    BizzInfo[i][bPick] = CreateTrigger(BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z]-1.77);
				    BizzInfo[i][bText] = CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, BizzInfo[i][bBar_X], BizzInfo[i][bBar_Y], BizzInfo[i][bBar_Z],25.0);
				}
			}
			Bizz3DText[i] = CreateDynamic3DTextLabel(" BIZZ ",0xE1AE3CFF, BizzInfo[i][bEnter_X], BizzInfo[i][bEnter_Y], BizzInfo[i][bEnter_Z],25.0);
			BizzCP[i] = CreateDynamicCP(BizzInfo[i][bEnter_X], BizzInfo[i][bEnter_Y], BizzInfo[i][bEnter_Z], 1.0, -1, -1, -1, 25.0);
			UpdateBizz(i);
			TotalBizz++;
	    }
	    printf("[CP] Bussines loaded: %d | Time: %d (ms)", TotalBizz, GetTickCount() - time);
	}
}
//load server property's
forward LoadProperty();
public LoadProperty()
{
    new rows, time = GetTickCount();
	cache_get_row_count(rows);
	if(rows)
	{
		for (new i = 0;i < rows;i ++)
		{
		    cache_get_value_name_int(i, "hID", HouseInfo[i][hID]);
		    
		    cache_get_value_name(i, "hOwner", HouseInfo[i][hOwner], MAX_PLAYER_NAME);
		    
			cache_get_value_name_float(i, "hEnter_X", HouseInfo[i][hEnter_X]);
			cache_get_value_name_float(i, "hEnter_Y", HouseInfo[i][hEnter_Y]);
			cache_get_value_name_float(i, "hEnter_Z", HouseInfo[i][hEnter_Z]);
			cache_get_value_name_float(i, "hExit_X", HouseInfo[i][hExit_X]);
			cache_get_value_name_float(i, "hExit_Y", HouseInfo[i][hExit_Y]);
			cache_get_value_name_float(i, "hExit_Z", HouseInfo[i][hExit_Z]);
            cache_get_value_name_int(i, "hOwned", HouseInfo[i][hOwned]);
            cache_get_value_name_int(i, "hInt", HouseInfo[i][hInt]);
            cache_get_value_name_int(i, "hLock", HouseInfo[i][hLock]);
            cache_get_value_name_int(i, "hClass", HouseInfo[i][hClass]);
            cache_get_value_name_int(i, "hPrice", HouseInfo[i][hPrice]);
            cache_get_value_name_int(i, "hTax", HouseInfo[i][hTax]);
            if(!HouseInfo[i][hOwned])
			{
				HouseInfo[i][hIcon] = CreateDynamicMapIcon(HouseInfo[i][hEnter_X], HouseInfo[i][hEnter_Y], HouseInfo[i][hEnter_Z], 31, 0xFFFFFFFF, 0, -1, -1, 25);
			}
			if(HouseInfo[i][hOwned])
			{
				HouseInfo[i][hIcon] = CreateDynamicMapIcon(HouseInfo[i][hEnter_X], HouseInfo[i][hEnter_Y], HouseInfo[i][hEnter_Z], 32, 0xFFFFFFFF, 0, -1, -1, 25);
			}
			HouseCP[i] = CreateDynamicCP(HouseInfo[i][hEnter_X], HouseInfo[i][hEnter_Y], HouseInfo[i][hEnter_Z], 1.0, -1, -1, -1, 25.0);
			House3DText[i] = CreateDynamic3DTextLabel(" PROPERTY ",0xE1AE3CFF,HouseInfo[i][hEnter_X], HouseInfo[i][hEnter_Y],HouseInfo[i][hEnter_Z],25.0);
			UpdateHouse(i);
			TotalHouse ++;
		}
		printf("[CP] Houses loaded: %d | Time: %d (ms)", TotalHouse, GetTickCount() - time);
	}
}

stock UpdatePlayerData(playerid,field [],data)
{
    new query[600];
	format(query, sizeof(query), "UPDATE `users` SET `%s` = '%d' WHERE `pName` = '%s' LIMIT 1",field, data, PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "", "");
	return 1;
}

stock SaveFill(id)
{
    new query[1600];
	new string[128];
	query = "UPDATE `filling` SET ";
	acc_float_strcat(query, sizeof(query), "fMenu_X", FillInfo[id][fMenu_X]);
	acc_float_strcat(query, sizeof(query), "fMenu_Y", FillInfo[id][fMenu_Y]);
	acc_float_strcat(query, sizeof(query), "fMenu_Z", FillInfo[id][fMenu_Z]);
	acc_str_strcat(query, sizeof(query), "fOwner", FillInfo[id][fOwner]);

	acc_int_strcat(query, sizeof(query), "fLock", FillInfo[id][fLock]);
	acc_int_strcat(query, sizeof(query), "fPrice", FillInfo[id][fPrice]);
	acc_int_strcat(query, sizeof(query), "fValue", FillInfo[id][fValue]);
	acc_int_strcat(query, sizeof(query), "fFuel", FillInfo[id][fFuel]);
	acc_int_strcat(query, sizeof(query), "fMaxFuel", FillInfo[id][fMaxFuel]);
	acc_int_strcat(query, sizeof(query), "fBank", FillInfo[id][fBank]);
	acc_int_strcat(query, sizeof(query), "fOwned", FillInfo[id][fOwned]);
	acc_int_strcat(query, sizeof(query), "fLockTime", FillInfo[id][fLockTime]);
	strdel(query, strlen(query)-1, strlen(query));
	format(string,sizeof(string)," WHERE `fID` = '%d'",FillInfo[id][fID]);
	strcat(query, string);
	mysql_tquery(dbHandle, query, "", "");
}

//save bizz
stock SaveBizz(bizz)
{
	new query[1600];
	new string[128];
	query = "UPDATE `bussines` SET ";
	acc_float_strcat(query, sizeof(query), "bEnter_X", BizzInfo[bizz][bEnter_X]);
	acc_float_strcat(query, sizeof(query), "bEnter_Y", BizzInfo[bizz][bEnter_Y]);
	acc_float_strcat(query, sizeof(query), "bEnter_Z", BizzInfo[bizz][bEnter_Z]);
	acc_float_strcat(query, sizeof(query), "bExit_X", BizzInfo[bizz][bExit_X]);
	acc_float_strcat(query, sizeof(query), "bExit_Y", BizzInfo[bizz][bExit_Y]);
	acc_float_strcat(query, sizeof(query), "bExit_Z", BizzInfo[bizz][bExit_Z]);
	acc_float_strcat(query, sizeof(query), "bBar_X", BizzInfo[bizz][bBar_X]);
	acc_float_strcat(query, sizeof(query), "bBar_Y", BizzInfo[bizz][bBar_Y]);
	acc_float_strcat(query, sizeof(query), "bBar_Z", BizzInfo[bizz][bBar_Z]);
	acc_str_strcat(query, sizeof(query), "bOwner", BizzInfo[bizz][bOwner]);
	acc_str_strcat(query, sizeof(query), "bName", BizzInfo[bizz][bName]);
	acc_int_strcat(query, sizeof(query), "bLock", BizzInfo[bizz][bLock]);
	acc_int_strcat(query, sizeof(query), "bPrice", BizzInfo[bizz][bPrice]);
	acc_int_strcat(query, sizeof(query), "bType", BizzInfo[bizz][bType]);
	acc_int_strcat(query, sizeof(query), "bProd", BizzInfo[bizz][bProd]);
	acc_int_strcat(query, sizeof(query), "bProfitHour", BizzInfo[bizz][bProfitHour]);
	acc_int_strcat(query, sizeof(query), "bBank", BizzInfo[bizz][bBank]);
	acc_int_strcat(query, sizeof(query), "bMaxProd", BizzInfo[bizz][bMaxProd]);
	acc_int_strcat(query, sizeof(query), "bGuest", BizzInfo[bizz][bGuest]);
	acc_int_strcat(query, sizeof(query), "bProfit", BizzInfo[bizz][bProfit]);
	acc_int_strcat(query, sizeof(query), "bOwned", BizzInfo[bizz][bOwned]);
	acc_int_strcat(query, sizeof(query), "bInt", BizzInfo[bizz][bInt]);
	acc_int_strcat(query, sizeof(query), "bWorld", BizzInfo[bizz][bWorld]);
	acc_int_strcat(query, sizeof(query), "bImprove", BizzInfo[bizz][bImprove]);
	acc_int_strcat(query, sizeof(query), "bTax", BizzInfo[bizz][bTax]);
	acc_int_strcat(query, sizeof(query), "bLockTime", BizzInfo[bizz][bLockTime]);
	strdel(query, strlen(query)-1, strlen(query));
	format(string,sizeof(string)," WHERE `bID` = '%d'",BizzInfo[bizz][bID]);
	strcat(query, string);
	mysql_tquery(dbHandle, query, "", "");
}

stock SaveWarehouse(id)
{
	new query[600];
	new string[128];
	query = "UPDATE `warehouse` SET ";
	acc_int_strcat(query, sizeof(query), "wAmmo", wInfo[id][wAmmo]);
	acc_int_strcat(query, sizeof(query), "wBank", wInfo[id][wBank]);
	acc_int_strcat(query, sizeof(query), "wDrug", wInfo[id][wDrug]);
	acc_int_strcat(query, sizeof(query), "wStatus", wInfo[id][wStatus]);
	strdel(query, strlen(query)-1, strlen(query));
	format(string,sizeof(string)," WHERE `wID` = '%d'",wInfo[id][wID]);
	strcat(query, string);
	mysql_tquery(dbHandle, query, "", "");
}

stock SaveProperty(house)
{
    new query[600];
	new string[128];
	query = "UPDATE `property` SET ";
	acc_float_strcat(query, sizeof(query), "hEnter_X", HouseInfo[house][hEnter_X]);
	acc_float_strcat(query, sizeof(query), "hEnter_Y", HouseInfo[house][hEnter_Y]);
	acc_float_strcat(query, sizeof(query), "hEnter_Z", HouseInfo[house][hEnter_Z]);
	acc_float_strcat(query, sizeof(query), "hExit_X", HouseInfo[house][hExit_X]);
	acc_float_strcat(query, sizeof(query), "hExit_Y", HouseInfo[house][hExit_Y]);
	acc_float_strcat(query, sizeof(query), "hExit_Z", HouseInfo[house][hExit_Z]);
	acc_str_strcat(query, sizeof(query), "hOwner", HouseInfo[house][hOwner]);
	acc_int_strcat(query, sizeof(query), "hPrice", HouseInfo[house][hPrice]);
	acc_int_strcat(query, sizeof(query), "hInt", HouseInfo[house][hInt]);
	acc_int_strcat(query, sizeof(query), "hLock", HouseInfo[house][hLock]);
	acc_int_strcat(query, sizeof(query), "hOwned", HouseInfo[house][hOwned]);
	acc_int_strcat(query, sizeof(query), "hClass", HouseInfo[house][hClass]);
	acc_int_strcat(query, sizeof(query), "hTax", HouseInfo[house][hTax]);
	strdel(query, strlen(query)-1, strlen(query));
	format(string,sizeof(string)," WHERE `hID` = '%d'",HouseInfo[house][hID]);
	strcat(query, string);
	mysql_tquery(dbHandle, query, "", "");
}

stock UpdateHouse(h)
{
	new hclass[50];
	switch(HouseInfo[h][hClass])
	{
	    case 1: hclass = "NOPE CLASS";
	    case 2: hclass = "MEDIMUM CLASS";
	    case 3: hclass = "ELITE CLASS";
	    case 4: hclass = "LUXURY CLASS";
	}

	if(!HouseInfo[h][hOwned])
	{
		DestroyDynamicMapIcon(HouseInfo[h][hIcon]);
		HouseInfo[h][hIcon] = CreateDynamicMapIcon(HouseInfo[h][hEnter_X], HouseInfo[h][hEnter_Y], HouseInfo[h][hEnter_Z], 31, 0xFFFFFFFF, 0, -1, -1, 25);
		new string[200];
		format(string,sizeof(string), "\
			{FAAC58} Saxli iyideba \n\n\
			{73B461}Saxlis nomeri: {FFFFFF}%d\n\
			{73B461}Saxlis klasi: {FFFFFF}%s\n\
			{73B461}Safasuri: {FFFFFF}$%d",
			HouseInfo[h][hID],
			hclass,
			HouseInfo[h][hPrice]
		);
		UpdateDynamic3DTextLabelText(House3DText[h],0xFFFFFFFF,string);
	}
	if(HouseInfo[h][hOwned])
	{
		DestroyDynamicMapIcon(HouseInfo[h][hIcon]);
		HouseInfo[h][hIcon] = CreateDynamicMapIcon(HouseInfo[h][hEnter_X], HouseInfo[h][hEnter_Y], HouseInfo[h][hEnter_Z], 32, 0xFFFFFFFF, 0, -1, -1, 25);
		
		static const dour_status[2][40 + 1] = {
		"{3D9829}Giaa{FFFFFF}",
		"{C22323}Daxurulia{FFFFFF}"
		};
		
		new string[200];
		format(string,sizeof(string), "\
			{FAAC58} Saxli dakavebulia \n\n\
			{73B461}Saxlis nomeri: {FFFFFF}%d\n\
			{73B461}Saxlis klasi: {FFFFFF}%s\n\
			{73B461}Mflobeli: {FFFFFF}%s\n\
			{73B461}Karebi: %s",
			HouseInfo[h][hID],
			hclass,
			HouseInfo[h][hOwner],
			dour_status[HouseInfo[h][hLock]]
		);
		UpdateDynamic3DTextLabelText(House3DText[h],0xFFFFFFFF,string);
	}
	return 1;
}

stock GetHouseTax(id)
{
	new htax;
	switch(HouseInfo[id][hClass])
	{
	    case 1: htax = 50;
	    case 2: htax = 150;
	    case 3: htax = 200;
	    case 4: htax = 300;
	}
	return htax;
}

stock GetBizzTax(id)
{
	new btax;
	switch(BizzInfo[id][bType]) 
	{
	    case 1: btax = 1000;
	    case 2: btax = 1500;
	    case 3: btax = 2000;
	    case 4: btax = 2000;
	}
	return btax;
}

stock UpdateFill(id)
{
	if(!FillInfo[id][fOwned])
	{
	    new string[200];
	    format(string, sizeof(string), "\
	        {FAAC58}Gas Station for sell \n\n\
	        {73B461}Station number: {FFFFFF}%d\n\
	        {73B461}Station Price: {FFFFFF}%d",
	        FillInfo[id][fID],
	        FillInfo[id][fPrice]
		);
		UpdateDynamic3DTextLabelText(Fill3DText[id], 0xFFFFFFFF, string);
	}
		
	if(FillInfo[id][fOwned])
	{
		static const dour_status[2][40 + 1] = {
		"{3D9829}Open{FFFFFF}",
		"{C22323}Close{FFFFFF}"
		};

		new string[250];
		format(string,sizeof(string), "\
			{73B461}Station number: {FFFFFF}%d\n\
			{73B461}Owner: {FFFFFF}%s\n\
			{73B461}Fuel: {FFFFFF}[%d l. / %d l.]\n\
			{73B461}Fuel Price: {FFFFFF}%d\n\
			{73B461}Product: {FFFFFF}%d\n\
			{73B461}Status: %s",
			FillInfo[id][fID],
			FillInfo[id][fOwner],
			FillInfo[id][fFuel],
			FillInfo[id][fMaxFuel],
			FillInfo[id][fValue],
			FillInfo[id][fProd],
			dour_status[FillInfo[id][fLock]]
		);
		UpdateDynamic3DTextLabelText(Fill3DText[id], 0xFFFFFFFF, string);
	}
	return 1;
}

stock UpdateBizz(b)
{
	new type[50];
	switch(BizzInfo[b][bType])
	{
 		case 1: type = "24/7";
   		case 2: type = "BURGER BAR";
	    case 3: type = "CLUB";
	    case 4: type = "SKIN SHOP";
	}

	if(!BizzInfo[b][bOwned])
	{
 		new string[200];
		format(string,sizeof(string), "\
			{FAAC58}Bussines for sell \n\n\
			{73B461}Bussines number: {FFFFFF}%d\n\
			{73B461}Bussines type: {FFFFFF}%s\n\
			{73B461}Price: {FFFFFF}$%d",
			BizzInfo[b][bID],
			type,
			BizzInfo[b][bPrice]
		);
		UpdateDynamic3DTextLabelText(Bizz3DText[b],0xFFFFFFFF,string);
	}
	if(BizzInfo[b][bOwned])
	{
		static const dour_status[2][40 + 1] = {
		"{3D9829}Open{FFFFFF}",
		"{C22323}Close{FFFFFF}"
		};

		new string[200];
		format(string,sizeof(string), "\
			{73B461}Bussines number: {FFFFFF}%d\n\
			{73B461}Bussines name: {FFFFFF}%s / %s\n\
			{73B461}Owner: {FFFFFF}%s\n\
			{73B461}Status: %s",
			BizzInfo[b][bID],
			BizzInfo[b][bName],
			type,
			BizzInfo[b][bOwner],
			dour_status[BizzInfo[b][bLock]]
		);
		UpdateDynamic3DTextLabelText(Bizz3DText[b],0xFFFFFFFF,string);
	}
	return 1;
}
/* OTHER SCRIPTS */
stock GetString(param1[],param2[])
{
	return !strcmp(param1, param2, false);
}
stock acc_int_strcat(query[], len, name[], number)
{
	new string[100];
	format(string, sizeof(string), "`%s` = '%d',",name, number);
	strcat(query, string, len);
	return true;
}
stock acc_str_strcat(query[], len, name[], str[])
{
	new string[100];
	format(string, sizeof(string), "`%s` = '%s',",name, str);
	strcat(query, string, len);
	return true;
}
stock acc_float_strcat(query[], len, name[], Float:number)
{
	new string[100];
	format(string, sizeof(string), "`%s` = '%f',", name, number);
	strcat(query, string, len);
	return true;
}

stock BadFloat(Float:x)
{
	if(x >= 10.0 || x <= -10.0)
	    return true;
	return false;
}
stock GiveServerWeapon(playerid, weapon, ammo)
{
	new slot = GetWeaponSlot(weapon);
	PlayerInfo[playerid][Gun][weapon] = true;
	PlayerInfo[playerid][GunAmmo][slot] += ammo;
	GivePlayerWeapon(playerid, weapon, ammo);
}

stock ResetServerWeapon(playerid)
{
	for(new i = 0; i < 13; i++)
	{
	    PlayerInfo[playerid][GunAmmo][i] = 0;
	}
	for(new i = 0; i < 47; i++)
	{
	    PlayerInfo[playerid][Gun][i] = false;
	}
	ResetPlayerWeapons(playerid);
}
stock GetWeaponSlot(weaponid)
{
 	new slot;
 	switch(weaponid)
 	{
   		case 0,1: slot = 0;
   		case 2..9: slot = 1;
   		case 22..24: slot = 2;
   		case 25..27: slot = 3;
   		case 28,29,32: slot = 4;
   		case 30,31: slot = 5;
   		case 33,34: slot = 6;
   		case 35..38: slot = 7;
   		case 16..18,39: slot = 8;
   		case 41..43: slot = 9;
   		case 10..15: slot = 10;
		case 44..46: slot = 11;
	 	case 40: slot = 12;
	 	default: slot = -1;
 	}
 	return slot;
}

forward FREEZE(playerid);
public FREEZE(playerid)
{
	TogglePlayerControllable(playerid, 1);
}

stock UpdateFracWareHouse()
{
	new FRAC_WH_TEXT[256];
	
	format(FRAC_WH_TEXT,500,"(ALT)\n\nPolice Department\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n\n{FFFFFF}Sawyobi: %s",wInfo[1][wAmmo],wInfo[1][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[0],0x0800FFFF,FRAC_WH_TEXT);
	
	format(FRAC_WH_TEXT,500,"(ALT)\n\nF.B.I\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n\n{FFFFFF}Sawyobi: %s",wInfo[2][wAmmo],wInfo[2][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[1],0x0800FFAA,FRAC_WH_TEXT);
	
	format(FRAC_WH_TEXT,500,"(ALT)\n\nNational Army\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n\n{FFFFFF}Sawyobi: %s",wInfo[3][wAmmo],wInfo[3][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[2],0xFF5757FF,FRAC_WH_TEXT);
	
	format(FRAC_WH_TEXT,500,"(ALT)\n\nPresident Residence\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n\n{FFFFFF}Sawyobi: %s",wInfo[4][wAmmo],wInfo[4][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[3],0xD4FF00FF,FRAC_WH_TEXT);
}

stock UpdateGangWareHouse()
{
	new GANG_WH_TEXT[256];

	format(GANG_WH_TEXT,500,"(ALT)\n\nThe Ballas\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n{FFFFFF}Narkotiki: {63BD4E}%d gr.\n{FFFFFF}Fuli: {63BD4E}%d$\n\n{FFFFFF}Sawyobi: %s",wInfo[5][wAmmo],wInfo[5][wDrug],wInfo[5][wBank],wInfo[5][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[4],0xCC00FFAA,GANG_WH_TEXT);
 	format(GANG_WH_TEXT,500,"(ALT)\n\nGrove Street\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n{FFFFFF}Narkotiki: {63BD4E}%d gr.\n{FFFFFF}Fuli: {63BD4E}%d$\n\n{FFFFFF}Sawyobi: %s",wInfo[6][wAmmo],wInfo[6][wDrug],wInfo[6][wBank],wInfo[6][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
    Update3DTextLabelText(WarehousePosText[5],0x009900AA,GANG_WH_TEXT);
   	format(GANG_WH_TEXT,500,"(ALT)\n\nThe Rifa\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n{FFFFFF}Narkotiki: {63BD4E}%d gr.\n{FFFFFF}Fuli: {63BD4E}%d$\n\n{FFFFFF}Sawyobi: %s",wInfo[7][wAmmo],wInfo[7][wDrug],wInfo[7][wBank],wInfo[7][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[6],0x7777ffAA,GANG_WH_TEXT);
	format(GANG_WH_TEXT,500,"(ALT)\n\nLos Santos Vagos\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n{FFFFFF}Narkotiki: {63BD4E}%d gr.\n{FFFFFF}Fuli: {63BD4E}%d$\n\n{FFFFFF}Sawyobi: %s",wInfo[8][wAmmo],wInfo[8][wDrug],wInfo[8][wBank],wInfo[8][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[7],0xffcd00AA,GANG_WH_TEXT);
	format(GANG_WH_TEXT,500,"(ALT)\n\nVarios Los Aztecas\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n{FFFFFF}Narkotiki: {63BD4E}%d gr.\n{FFFFFF}Fuli: {63BD4E}%d$\n\n{FFFFFF}Sawyobi: %s",wInfo[9][wAmmo],wInfo[9][wDrug],wInfo[9][wBank],wInfo[9][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[8],0x00b4e1AA,GANG_WH_TEXT);
}

stock UpdateMafiaWareHouse()
{
	new MAFIA_WH_TEXT[256];
	
	format(MAFIA_WH_TEXT, 500, "(ALT)\n\nLa Cosa Nostra\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n{FFFFFF}Narkotiki: {63BD4E}%d gr.\n{FFFFFF}Fuli: {63BD4E}%d$\n\n{FFFFFF}Sawyobi: %s",wInfo[10][wAmmo],wInfo[10][wDrug],wInfo[10][wBank],wInfo[10][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[9],0xe68a00AA,MAFIA_WH_TEXT);
	format(MAFIA_WH_TEXT, 500, "(ALT)\n\nYakudza\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n{FFFFFF}Narkotiki: {63BD4E}%d gr.\n{FFFFFF}Fuli: {63BD4E}%d$\n\n{FFFFFF}Sawyobi: %s",wInfo[10][wAmmo],wInfo[11][wDrug],wInfo[11][wBank],wInfo[11][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[10],0xb30000AA,MAFIA_WH_TEXT);
	format(MAFIA_WH_TEXT, 500, "(ALT)\n\nRussian Mafia\n\n{FFFFFF}Tyviebi: {63BD4E}%d\n{FFFFFF}Narkotiki: {63BD4E}%d gr.\n{FFFFFF}Fuli: {63BD4E}%d$\n\n{FFFFFF}Sawyobi: %s",wInfo[12][wAmmo],wInfo[12][wDrug],wInfo[12][wBank],wInfo[12][wStatus]?("{63BD4E}Gaxsnilia"):("{F04245}Chaketilia"));
	Update3DTextLabelText(WarehousePosText[11],0x661a00AA,MAFIA_WH_TEXT);
}

stock LoadTextDraw()
{
    enable_skin_TD[0] = TextDrawCreate(252.900085, 417.749694, "ld_pool:ball");
	TextDrawLetterSize(enable_skin_TD[0], 0.000000, 0.000000);
	TextDrawTextSize(enable_skin_TD[0], 19.000000, 16.000000);
	TextDrawAlignment(enable_skin_TD[0], 1);
	TextDrawColor(enable_skin_TD[0], 255);
	TextDrawSetShadow(enable_skin_TD[0], 0);
	TextDrawSetOutline(enable_skin_TD[0], 0);
	TextDrawBackgroundColor(enable_skin_TD[0], 255);
	TextDrawFont(enable_skin_TD[0], 4);
	TextDrawSetProportional(enable_skin_TD[0], 0);
	TextDrawSetShadow(enable_skin_TD[0], 0);

	enable_skin_TD[1] = TextDrawCreate(361.499938, 417.899719, "ld_pool:ball");
	TextDrawLetterSize(enable_skin_TD[1], 0.000000, 0.000000);
	TextDrawTextSize(enable_skin_TD[1], 19.000000, 16.000000);
	TextDrawAlignment(enable_skin_TD[1], 1);
	TextDrawColor(enable_skin_TD[1], 255);
	TextDrawSetShadow(enable_skin_TD[1], 0);
	TextDrawSetOutline(enable_skin_TD[1], 0);
	TextDrawBackgroundColor(enable_skin_TD[1], 255);
	TextDrawFont(enable_skin_TD[1], 4);
	TextDrawSetProportional(enable_skin_TD[1], 0);
	TextDrawSetShadow(enable_skin_TD[1], 0);

	enable_skin_TD[2] = TextDrawCreate(262.900085, 417.812194, "LD_SPAC:white");
	TextDrawLetterSize(enable_skin_TD[2], 0.000000, 0.000000);
	TextDrawTextSize(enable_skin_TD[2], 108.699935, 15.669992);
	TextDrawAlignment(enable_skin_TD[2], 1);
	TextDrawColor(enable_skin_TD[2], 255);
	TextDrawSetShadow(enable_skin_TD[2], 0);
	TextDrawSetOutline(enable_skin_TD[2], 0);
	TextDrawBackgroundColor(enable_skin_TD[2], 255);
	TextDrawFont(enable_skin_TD[2], 4);
	TextDrawSetProportional(enable_skin_TD[2], 0);
	TextDrawSetShadow(enable_skin_TD[2], 0);

	enable_skin_TD[3] = TextDrawCreate(287.900085, 419.162200, "SELECT");
	TextDrawLetterSize(enable_skin_TD[3], 0.247998, 1.271873);
	TextDrawTextSize(enable_skin_TD[3], 10.000000, 36.000000);
	TextDrawAlignment(enable_skin_TD[3], 2);
	TextDrawColor(enable_skin_TD[3], -1);
	TextDrawUseBox(enable_skin_TD[3], 1);
	TextDrawBoxColor(enable_skin_TD[3], 268435456);
	TextDrawSetShadow(enable_skin_TD[3], 0);
	TextDrawSetOutline(enable_skin_TD[3], 0);
	TextDrawBackgroundColor(enable_skin_TD[3], 255);
	TextDrawFont(enable_skin_TD[3], 2);
	TextDrawSetProportional(enable_skin_TD[3], 1);
	TextDrawSetShadow(enable_skin_TD[3], 0);
	TextDrawSetSelectable(enable_skin_TD[3], true);

	enable_skin_TD[4] = TextDrawCreate(347.303710, 419.162200, "CANCEL");
	TextDrawLetterSize(enable_skin_TD[4], 0.247998, 1.271873);
	TextDrawTextSize(enable_skin_TD[4], 10.000000, 36.000000);
	TextDrawAlignment(enable_skin_TD[4], 2);
	TextDrawColor(enable_skin_TD[4], -1);
	TextDrawUseBox(enable_skin_TD[4], 1);
	TextDrawBoxColor(enable_skin_TD[4], 1090519040);
	TextDrawSetShadow(enable_skin_TD[4], 0);
	TextDrawSetOutline(enable_skin_TD[4], 0);
	TextDrawBackgroundColor(enable_skin_TD[4], 255);
	TextDrawFont(enable_skin_TD[4], 2);
	TextDrawSetProportional(enable_skin_TD[4], 1);
	TextDrawSetShadow(enable_skin_TD[4], 0);
	TextDrawSetSelectable(enable_skin_TD[4], true);

	enable_skin_TD[5] = TextDrawCreate(314.899719, 425.024749, "ld_pool:ball");
	TextDrawLetterSize(enable_skin_TD[5], 0.000000, 0.000000);
	TextDrawTextSize(enable_skin_TD[5], 3.000000, 2.549998);
	TextDrawAlignment(enable_skin_TD[5], 1);
	TextDrawColor(enable_skin_TD[5], 0xFFCC00FF);
	TextDrawSetShadow(enable_skin_TD[5], 0);
	TextDrawSetOutline(enable_skin_TD[5], 0);
	TextDrawBackgroundColor(enable_skin_TD[5], 255);
	TextDrawFont(enable_skin_TD[5], 4);
	TextDrawSetProportional(enable_skin_TD[5], 0);
	TextDrawSetShadow(enable_skin_TD[5], 0);

	enable_skin_TD[6] = TextDrawCreate(218.200012, 406.137207, "");
	TextDrawLetterSize(enable_skin_TD[6], 0.000000, 0.000000);
	TextDrawTextSize(enable_skin_TD[6], 42.000000, 37.000000);
	TextDrawAlignment(enable_skin_TD[6], 1);
	TextDrawColor(enable_skin_TD[6], -1);
	TextDrawSetShadow(enable_skin_TD[6], 0);
	TextDrawSetOutline(enable_skin_TD[6], 0);
	TextDrawBackgroundColor(enable_skin_TD[6], 268435456);
	TextDrawFont(enable_skin_TD[6], 5);
	TextDrawSetProportional(enable_skin_TD[6], 0);
	TextDrawSetShadow(enable_skin_TD[6], 0);
	TextDrawSetSelectable(enable_skin_TD[6], true);
	TextDrawSetPreviewModel(enable_skin_TD[6], 19131);
	TextDrawSetPreviewRot(enable_skin_TD[6], 0.000000, 0.000000, 90.000000, 1.000000);

	enable_skin_TD[7] = TextDrawCreate(373.200500, 406.374694, "");
	TextDrawLetterSize(enable_skin_TD[7], 0.000000, 0.000000);
	TextDrawTextSize(enable_skin_TD[7], 42.000000, 37.000000);
	TextDrawAlignment(enable_skin_TD[7], 1);
	TextDrawColor(enable_skin_TD[7], -1);
	TextDrawSetShadow(enable_skin_TD[7], 0);
	TextDrawSetOutline(enable_skin_TD[7], 0);
	TextDrawBackgroundColor(enable_skin_TD[7], 268435456);
	TextDrawFont(enable_skin_TD[7], 5);
	TextDrawSetProportional(enable_skin_TD[7], 0);
	TextDrawSetShadow(enable_skin_TD[7], 0);
	TextDrawSetSelectable(enable_skin_TD[7], true);
	TextDrawSetPreviewModel(enable_skin_TD[7], 19131);
	TextDrawSetPreviewRot(enable_skin_TD[7], 0.000000, 0.000000, -90.000000, 1.000000);
	//
    SpeedTextDraw[0] = TextDrawCreate(531.303710, 359.916809, "usebox");
	TextDrawLetterSize(SpeedTextDraw[0], 0.449999, 1.600000);
	TextDrawTextSize(SpeedTextDraw[0], 76.837471, 74.083366);
	TextDrawAlignment(SpeedTextDraw[0], 1);
	TextDrawColor(SpeedTextDraw[0], 134744319);
	TextDrawUseBox(SpeedTextDraw[0], true);
	TextDrawBoxColor(SpeedTextDraw[0], 0);
	TextDrawSetShadow(SpeedTextDraw[0], 0);
	TextDrawSetOutline(SpeedTextDraw[0], 1);
	TextDrawBackgroundColor(SpeedTextDraw[0], -256);
	TextDrawFont(SpeedTextDraw[0], 5);
	TextDrawSetProportional(SpeedTextDraw[0], 1);
	TextDrawSetPreviewModel(SpeedTextDraw[0], 1329);
	TextDrawSetPreviewRot(SpeedTextDraw[0], 90.000000, 0.000000, 0.000000, 1.000000);

	SpeedTextDraw[1] = TextDrawCreate(569.722351, 398.999938, "KM/H");
	TextDrawLetterSize(SpeedTextDraw[1], 0.135150, 0.777499);
	TextDrawAlignment(SpeedTextDraw[1], 2);
	TextDrawColor(SpeedTextDraw[1], 0xFF9900FF);
	TextDrawSetShadow(SpeedTextDraw[1], 0);
	TextDrawSetOutline(SpeedTextDraw[1], 0);
	TextDrawBackgroundColor(SpeedTextDraw[1], 51);
	TextDrawFont(SpeedTextDraw[1], 2);
	TextDrawSetProportional(SpeedTextDraw[1], 1);

	SpeedTextDraw[2] = TextDrawCreate(596.553405, 424.416656, "usebox");
	TextDrawLetterSize(SpeedTextDraw[2], 0.000000, 1.502032);
	TextDrawTextSize(SpeedTextDraw[2], 543.827209, 0.000000);
	TextDrawAlignment(SpeedTextDraw[2], 1);
	TextDrawColor(SpeedTextDraw[2], 0);
	TextDrawUseBox(SpeedTextDraw[2], true);
	TextDrawBoxColor(SpeedTextDraw[2], 134744319);//
	TextDrawSetShadow(SpeedTextDraw[2], 0);
	TextDrawSetOutline(SpeedTextDraw[2], 0);
	TextDrawFont(SpeedTextDraw[2], 0);

	SpeedTextDraw[3] = TextDrawCreate(596.553405, 424.416656, "usebox");
	TextDrawLetterSize(SpeedTextDraw[3], 0.000000, 1.502032);
	TextDrawTextSize(SpeedTextDraw[3], 543.827209, 0.000000);
	TextDrawAlignment(SpeedTextDraw[3], 1);
	TextDrawColor(SpeedTextDraw[3], 0);
	TextDrawUseBox(SpeedTextDraw[3], true);
	TextDrawBoxColor(SpeedTextDraw[3], 134744319);//134744319
	TextDrawSetShadow(SpeedTextDraw[3], 0);
	TextDrawSetOutline(SpeedTextDraw[3], 0);
	TextDrawFont(SpeedTextDraw[3], 0);

	SpeedTextDraw[4] = TextDrawCreate(560.819946, 413.583404, "ENGINE");
	TextDrawLetterSize(SpeedTextDraw[4], 0.130934, 0.841665);
	TextDrawAlignment(SpeedTextDraw[4], 1);
	TextDrawColor(SpeedTextDraw[4], -1);
	TextDrawSetShadow(SpeedTextDraw[4], 0);
	TextDrawSetOutline(SpeedTextDraw[4], 0);
	TextDrawBackgroundColor(SpeedTextDraw[4], 51);
	TextDrawFont(SpeedTextDraw[4], 2);
	TextDrawSetProportional(SpeedTextDraw[4], 1);

	SpeedTextDraw[5] = TextDrawCreate(591.399902, 411.000030, "usebox");
	TextDrawLetterSize(SpeedTextDraw[5], 0.000000, -0.468147);
	TextDrawTextSize(SpeedTextDraw[5], 547.575378, 0.000000);
	TextDrawAlignment(SpeedTextDraw[5], 1);
	TextDrawColor(SpeedTextDraw[5], 0);
	TextDrawUseBox(SpeedTextDraw[5], true);
	TextDrawBoxColor(SpeedTextDraw[5], -1);//-1
	TextDrawSetShadow(SpeedTextDraw[5], 0);
	TextDrawSetOutline(SpeedTextDraw[5], 0);
	TextDrawFont(SpeedTextDraw[5], 0);

	SpeedTextDraw[6] = TextDrawCreate(572.064453, 394.333282, "BOX_MODEL");
	TextDrawLetterSize(SpeedTextDraw[6], 0.449999, 1.600000);
	TextDrawTextSize(SpeedTextDraw[6], 56.691062, 56.000026);
	TextDrawAlignment(SpeedTextDraw[6], 1);
	TextDrawColor(SpeedTextDraw[6], 134744319);
	TextDrawUseBox(SpeedTextDraw[6], true);
	TextDrawBoxColor(SpeedTextDraw[6], 0);
	TextDrawSetShadow(SpeedTextDraw[6], 0);
	TextDrawSetOutline(SpeedTextDraw[6], 1);
	TextDrawBackgroundColor(SpeedTextDraw[6], -256);
	TextDrawFont(SpeedTextDraw[6], 5);
	TextDrawSetProportional(SpeedTextDraw[6], 1);
	TextDrawSetPreviewModel(SpeedTextDraw[6], 1329);
	TextDrawSetPreviewRot(SpeedTextDraw[6], 90.000000, 0.000000, -26.000000, 1.000000);

	SpeedTextDraw[7] = TextDrawCreate(559.414184, 429.916748, "LOCK");
	TextDrawLetterSize(SpeedTextDraw[7], 0.130934, 0.841665);
	TextDrawAlignment(SpeedTextDraw[7], 2);
	TextDrawColor(SpeedTextDraw[7], -1);
	TextDrawSetShadow(SpeedTextDraw[7], 0);
	TextDrawSetOutline(SpeedTextDraw[7], 0);
	//TextDrawBackgroundColor(SpeedTextDraw[7], 51);
	TextDrawFont(SpeedTextDraw[7], 2);
	TextDrawSetProportional(SpeedTextDraw[7], 1);

	SpeedTextDraw[8] = TextDrawCreate(580.966125, 429.916748, "LIGHT");
	TextDrawLetterSize(SpeedTextDraw[8], 0.130934, 0.841665);
	TextDrawAlignment(SpeedTextDraw[8], 2);
	TextDrawColor(SpeedTextDraw[8], -1);
	TextDrawSetShadow(SpeedTextDraw[8], 0);
	TextDrawSetOutline(SpeedTextDraw[8], 0);
	TextDrawBackgroundColor(SpeedTextDraw[8], 51);
	TextDrawFont(SpeedTextDraw[8], 2);
	TextDrawSetProportional(SpeedTextDraw[8], 1);

	SpeedTextDraw[9] = TextDrawCreate(509.282348, 394.333282, "BOX_MODEL");
	TextDrawLetterSize(SpeedTextDraw[9], 0.449999, 1.600000);
	TextDrawTextSize(SpeedTextDraw[9], 56.691062, 56.000026);
	TextDrawAlignment(SpeedTextDraw[9], 1);
	TextDrawColor(SpeedTextDraw[9], 134744319);
	TextDrawUseBox(SpeedTextDraw[9], true);
	TextDrawBoxColor(SpeedTextDraw[9], 0);
	TextDrawSetShadow(SpeedTextDraw[9], 0);
	TextDrawSetOutline(SpeedTextDraw[9], 1);
	TextDrawBackgroundColor(SpeedTextDraw[9], -256);
	TextDrawFont(SpeedTextDraw[9], 5);
	TextDrawSetProportional(SpeedTextDraw[9], 1);
	TextDrawSetPreviewModel(SpeedTextDraw[9], 1329);
	TextDrawSetPreviewRot(SpeedTextDraw[9], 90.000000, 0.000000, -26.000000, 1.000000);
}

stock LoadMAP()
{
	#include "../source/INT-HOUSE7.pwn"
	#include "../source/INT-HOUSE8.pwn"
	#include "../source/INT-HOUSE9.pwn"
	#include "../source/INT-HOUSE10.pwn"
	/*********************************/
	#include "../source/INT-BURGER.pwn"
	#include "../source/INT-CLUB.pwn"
	#include "../source/INT-SHOP.pwn"
	#include "../source/INT-VICTIM.pwn"
	/*********************************/
	#include "../source/INT-BANK.pwn"
	#include "../source/EXT-BUSSTOP.pwn"
	/*********************************/
	#include "../source/INT-PD.pwn"
	#include "../source/INT-FBI.pwn"
	#include "../source/INT-ARMY.pwn"
	#include "../source/INT-RESIDENCE.pwn"
	#include "../source/INT-GANG.pwn"
	#include "../source/INT-MAFIA.pwn"
	#include "../source/EXT-ZONA51.pwn"
	#include "../source/INT-AMMO.pwn"
}

stock LoadPickup()
{
    BankPick[0] = CreateDynamicPickup(19133, 23, 304.7563,1329.2961,2023.8380, 3);
    BankPick[1] = CreateDynamicPickup(19133, 23, 1481.0514,-1772.3130,18.7929);
    BankPick[2] = CreateTrigger(292.6172,1339.6455,2023.8380-1.77);
    BankPick[3] = CreateTrigger(292.6619,1346.0580,2023.8380-1.77);
    BankPick[4] = CreateTrigger(292.4394,1352.2371,2023.8380-1.77);
    PolicePick[0] = CreateDynamicPickup(19133, 23, 1376.7712,-27.4658,1504.5602, 2);
    PolicePick[1] = CreateDynamicPickup(19133, 23, 1555.4957,-1675.7402,16.1953);
    FBIPick[0] = CreateDynamicPickup(19133, 23, 1671.2797,-1401.8287,3087.0383, 2);
    FBIPick[1] = CreateDynamicPickup(19133, 23, 941.0916,-1717.7953,13.9701);
    ArmyPick[0] = CreateDynamicPickup(19133, 23, 249.5149,1932.3789,5.1380, 2);
    ArmyPick[1] = CreateDynamicPickup(19133, 23, 151.9958,1831.4390,17.6481);
    ResPick[0] = CreateDynamicPickup(19133, 23, -785.8101,-665.2155,4001.0859, 2);
    ResPick[1] = CreateDynamicPickup(19133, 23, 1122.7098,-2036.8984,69.8942);
    BallasPick[0] = CreateDynamicPickup(19133, 23, 2014.2932,1317.3335,632.0648, 1);
    BallasPick[1] = CreateDynamicPickup(19133, 23, 2000.0908,-1114.0598,27.1250);
    GrovePick[0] = CreateDynamicPickup(19133, 23, 2014.2932,1317.3335,632.0648, 2);
    GrovePick[1] = CreateDynamicPickup(19133, 23, 2523.2717,-1679.2948,15.4970);
    RifaPick[0] = CreateDynamicPickup(19133, 23, 2014.2932,1317.3335,632.0648, 3);
    RifaPick[1] = CreateDynamicPickup(19133, 23, 2787.0762,-1926.1168,13.5469);
    VagosPick[0] = CreateDynamicPickup(19133, 23, 2014.2932,1317.3335,632.0648, 4);
    VagosPick[1] = CreateDynamicPickup(19133, 23, 2756.3379,-1182.8085,69.4035);
    AztecasPick[0] = CreateDynamicPickup(19133, 23, 2014.2932,1317.3335,632.0648, 5);
    AztecasPick[1] = CreateDynamicPickup(19133, 23, 2185.8508,-1815.2263,13.5469);
    LcnPick[0] = CreateDynamicPickup(19133, 23, -2216.6819,686.3856,3001.5159, 1);
    LcnPick[1] = CreateDynamicPickup(19133, 23, 2480.9919,1525.0446,11.7813);
    YakPick[0] = CreateDynamicPickup(19133, 23, -2216.6819,686.3856,3001.5159, 2);
    YakPick[1] = CreateDynamicPickup(19133, 23, 1456.1317,2773.3872,10.8203);
    RmPick[0] = CreateDynamicPickup(19133, 23, -2216.6819,686.3856,3001.5159, 3);
    RmPick[1] = CreateDynamicPickup(19133, 23, 937.0781,1733.2778,8.8516);
    DutyForm[0] = CreateDynamicPickup(1275, 23, 1402.6268,-20.9833,1504.5602, 2);// PD
    DutyForm[1] = CreateDynamicPickup(1275, 23, 1689.4038,-1413.8408,3087.0383, 2);// FBI
    DutyForm[2] = CreateDynamicPickup(1275, 23, 291.7471,1936.1003,5.1380, 2);// ARMY
    DutyForm[3] = CreateDynamicPickup(1275, 23, -792.9036,-687.9256,4004.5850, 2);// RESIDENCE
	AmmoPick[0] = CreateDynamicPickup(19133, 23, 1368.9984,-1279.6820,13.5469);
	AmmoPick[1] = CreateDynamicPickup(19133, 23, 2860.7625,801.0223,801.7853,5);
}


stock Load3DText()
{
	// Create3DTextLabel(text[], color, Float:X, Float:Y, Float:Z, Float:DrawDistance, virtualworld, testLOS)
    WarehousePosText[0] = Create3DTextLabel("_", 0x36A8CFAA, 1405.2507,-33.4383,1504.5602, 10.0, 2, 1); //PD
    WarehousePosText[1] = Create3DTextLabel("_", 0x36A8CFAA, 1688.7605,-1419.7156,3087.0383, 10.0, 2, 1); //FBI
    WarehousePosText[2] = Create3DTextLabel("_", 0x36A8CFAA, 274.0574,1923.0823,5.1380, 10.0, 2, 1); //ARMY
    WarehousePosText[3] = Create3DTextLabel("_", 0x36A8CFAA, -807.6265,-688.1851,4001.0859, 10.0, 2, 1); //RESIDENCE
    WarehousePosText[4] = Create3DTextLabel("_", 0x36A8CFAA, 2014.4634,1344.8119,632.0748, 10.0, 1, 1); //BALLAS
    WarehousePosText[5] = Create3DTextLabel("_", 0x36A8CFAA, 2014.4634,1344.8119,632.0748, 10.0, 2, 1); //GROVE
    WarehousePosText[6] = Create3DTextLabel("_", 0x36A8CFAA, 2014.4634,1344.8119,632.0748, 10.0, 3, 1); //RIFA
    WarehousePosText[7] = Create3DTextLabel("_", 0x36A8CFAA, 2014.4634,1344.8119,632.0748, 10.0, 4, 1); //VAGOS
    WarehousePosText[8] = Create3DTextLabel("_", 0x36A8CFAA, 2014.4634,1344.8119,632.0748, 10.0, 5, 1); //AZTECAS
    WarehousePosText[9] = Create3DTextLabel("_", 0x36A8CFAA, -2243.6067,717.5988,3001.5166, 10.0, 1, 1); //LCN
    WarehousePosText[10] = Create3DTextLabel("_", 0x36A8CFAA, -2243.6067,717.5988,3001.5166, 10.0, 2, 1); //YAKUDZA
    WarehousePosText[11] = Create3DTextLabel("_", 0x36A8CFAA, -2243.6067,717.5988,3001.5166, 10.0, 3, 1); //RM
    CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, 2860.6919,788.9444,801.7853,5.0); //ammo nation
}

stock LoadVehicles()
{
	pdcar[0] = AddStaticVehicleEx(415, 1558.7000, -1710.5000, 5.5757, 0.0000, 79, 1, 900);
	pdcar[1] = AddStaticVehicleEx(596, 1587.5000, -1710.5000, 5.5757, 0.0000, 79, 1, 900);
	pdcar[2] = AddStaticVehicleEx(596, 1583.5000, -1710.5000, 5.5757, 0.0000, 79, 1, 900);
	pdcar[3] = AddStaticVehicleEx(596, 1578.5500, -1710.5000, 5.5757, 0.0000, 79, 1, 900);
	pdcar[4] = AddStaticVehicleEx(596, 1574.3500, -1710.5000, 5.5757, 0.0000, 79, 1, 900);
	pdcar[5] = AddStaticVehicleEx(596, 1570.2500, -1710.5000, 5.5757, 0.0000, 79, 1, 900);
	pdcar[6] = AddStaticVehicleEx(601, 1529.2648, -1683.9962, 5.5413, 270.7345, 79, 1, 900);
	pdcar[7] = AddStaticVehicleEx(601, 1529.3715, -1688.1726, 5.6362, 269.6888, 79, 1, 900);
	pdcar[8] = AddStaticVehicleEx(523, 1545.5000, -1663.1000, 5.4239, 90.0000, 79, 1, 900);
	pdcar[9] = AddStaticVehicleEx(523, 1545.5000, -1667.8837, 5.4239, 90.0000, 79, 1, 900);
	pdcar[10] = AddStaticVehicleEx(523, 1545.5000, -1672.0883, 5.4239, 90.0000, 79, 1, 900);
	pdcar[11] = AddStaticVehicleEx(523, 1545.5000, -1676.3691, 5.4239, 90.0000, 79, 1, 900);
	pdcar[12] = AddStaticVehicleEx(599, 1585.5000, -1671.5000, 5.9595, -90.0000, 79, 1, 900);
	pdcar[13] = AddStaticVehicleEx(599, 1585.5000, -1667.5000, 5.9595, -90.0000, 79, 1, 900);
	pdcar[14] = AddStaticVehicleEx(427, 1530.5500, -1645.3389, 5.8962, 180.0000, 79, 1, 900);
	pdcar[15] = AddStaticVehicleEx(427, 1534.7000, -1645.3389, 5.8962, 180.0000, 79, 1, 900);
	pdcar[16] = AddStaticVehicleEx(427, 1539.0000, -1645.3389, 5.8962, 180.0000, 79, 1, 900);
	pdcar[17] = AddStaticVehicleEx(497, 1555.0000, -1612.0000, 13.5000, 180.0000, 79, 1, 900);
	pdcar[18] = AddStaticVehicleEx(497, 1565.0000, -1612.0000, 13.5000, 180.0000, 79, 1, 900);
	
	fbicar[0] = AddStaticVehicleEx(490, 929.9684, -1727.6338, 13.6761, 90.0000,  0, 0, 900);
	fbicar[1] = AddStaticVehicleEx(490, 929.9684, -1711.8790, 13.6761, 90.0000,  0, 0, 900);
	fbicar[2] = AddStaticVehicleEx(482, 949.3714, -1693.8885, 13.6656, 0.0000,   0, 0, 900);
	fbicar[3] = AddStaticVehicleEx(482, 945.6992, -1693.8885, 13.6656, 0.0000,   0, 0, 900);
	fbicar[4] = AddStaticVehicleEx(415, 942.3234, -1694.5857, 13.2475, 0.0000,   0, 0, 900);
	fbicar[5] = AddStaticVehicleEx(415, 938.8193, -1694.5857, 13.2475, 0.0000,   0, 0, 900);
	fbicar[6] = AddStaticVehicleEx(426, 946.4802, -1757.0316, 13.2497, 180.0000, 0, 0, 900);
	fbicar[7] = AddStaticVehicleEx(426, 951.1573, -1757.0316, 13.2497, 180.0000, 0, 0, 900);
	fbicar[8] = AddStaticVehicleEx(426, 956.1215, -1757.0316, 13.2497, 180.0000, 0, 0, 900);

 	armycar[0] = AddStaticVehicleEx(470,292.9335,1846.8453,17.6333,270.7710,0,0,900); 
	armycar[1] = AddStaticVehicleEx(470,292.9335,1851.2974,17.6341,270.7710,0,0,900); 
	armycar[2] = AddStaticVehicleEx(470,292.9335,1855.8220,17.6347,270.7710,0,0,900); 
	armycar[3] = AddStaticVehicleEx(470,292.9335,1860.3022,17.6330,270.7710,0,0,900);
	armycar[4] = AddStaticVehicleEx(470,276.7169,1967.5135,17.6323,270.2390,0,0,900); 
	armycar[5] = AddStaticVehicleEx(470,276.7169,1944.0948,17.6323,270.2390,0,0,900);
	armycar[6] = AddStaticVehicleEx(470,276.7169,1950.0948,17.6333,270.2390,0,0,900);
	armycar[7] = AddStaticVehicleEx(470,276.7169,1956.0948,17.6330,270.2390,0,0,900);
	armycar[8] = AddStaticVehicleEx(470,276.7169,1962.0948,17.6371,270.2390,0,0,900); 
	armycar[9] = AddStaticVehicleEx(470,184.40990000,1945.04360000,19.65430000,91.06440000,-1,-1,900);
	armycar[0] = AddStaticVehicleEx(470,183.96970000,1950.09970000,19.78680000,88.88780000,-1,-1,900);
	armycar[10] = AddStaticVehicleEx(470,183.67430000,1954.93640000,19.77820000,90.21300000,-1,-1,900);
	armycar[11] = AddStaticVehicleEx(470,184.13430000,1960.09620000,19.57300000,88.98510000,-1,-1,900);
	armycar[12] = AddStaticVehicleEx(470,183.87360000,1965.14810000,19.73130000,91.99030000,-1,-1,900);
	armycar[13] = AddStaticVehicleEx(500,203.7240,1866.9736,13.2801,271.3324,77,77,900);
	armycar[14] = AddStaticVehicleEx(500,184.05790000,1970.22350000,19.77450000,89.54330000,-1,-1,900);
	armycar[15] = AddStaticVehicleEx(500,183.93110000,1975.23380000,19.79280000,90.13170000,-1,-1,900);
	armycar[16] = AddStaticVehicleEx(500,183.60440000,1980.46470000,19.71780000,90.51290000,-1,-1,900);
	armycar[17] = AddStaticVehicleEx(500,183.64470000,1985.51730000,19.79170000,88.25440000,-1,-1,900);
	armycar[18] = AddStaticVehicleEx(500,183.76640000,1990.41660000,19.74800000,88.68630000,-1,-1,900);
	armycar[19] = AddStaticVehicleEx(500,183.59310000,1995.62610000,19.76930000,87.44930000,-1,-1,900);
	armycar[20] = AddStaticVehicleEx(500,203.5927,1872.2008,13.2459,271.1720,77,77,900);
	armycar[21] = AddStaticVehicleEx(500,221.9194,1855.0072,13.0356,1.6078,77,77,900);
	armycar[22] = AddStaticVehicleEx(500,217.1713,1854.8744,13.0242,1.6078,77,77,900); 
	armycar[23] = AddStaticVehicleEx(500,212.6617,1854.7483,13.0134,1.6078,77,77,900); 
	armycar[24] = AddStaticVehicleEx(500,203.7943,1862.3488,13.2462,271.1720,77,77,900); 
	armycar[25] = AddStaticVehicleEx(433,276.6297,1981.7429,18.0773,271.1830,0,0,900);
	armycar[26] = AddStaticVehicleEx(433,276.6297,1987.7429,18.0773,271.1830,0,0,900);
	armycar[27] = AddStaticVehicleEx(433,276.6297,1993.7429,18.0773,271.1830,0,0,900);
	armycar[28] = AddStaticVehicleEx(433,276.6297,1999.7429,18.0773,271.1830,0,0,900);
	armycar[29] = AddStaticVehicleEx(433,276.6297,2015.2429,18.0773,271.1830,0,0,900);
	armycar[30] = AddStaticVehicleEx(433,276.6297,2021.2429,18.0773,271.1830,0,0,900);
	armycar[31] = AddStaticVehicleEx(433,276.6297,2027.2429,18.0773,271.1830,0,0,900);
	armycar[32] = AddStaticVehicleEx(433,276.6297,2033.2429,18.0773,271.1830,0,0,900); 
	
 	rescar[0] = AddStaticVehicleEx(421,1273.4521,-2010.5002,58.9184,179.1348, 1,1, 900); //
	rescar[1] = AddStaticVehicleEx(421,1264.8278,-2010.5033,59.1654,180.1958, 1,1, 900); //
	rescar[2] = AddStaticVehicleEx(421,1257.0714,-2010.3876,59.3871,180.4212, 1,1, 900); //
	rescar[3] = AddStaticVehicleEx(579,1245.9888,-2013.5712,59.7531,269.9879, 1,1, 900); //
	rescar[4] = AddStaticVehicleEx(579,1245.8104,-2020.5096,59.7647,268.9523, 1,1, 900); //
	rescar[5] = AddStaticVehicleEx(579,1245.4808,-2028.4899,59.7712,268.9511, 1,1, 900); //
	rescar[6] = AddStaticVehicleEx(409,1248.6931,-2043.7338,59.6126,270.3727, 1,1, 900); //
	rescar[7] = AddStaticVehicleEx(487,1151.3722,-2054.6990,69.2506,269.9958, 1,1, 900); //
	

    ballascar[0] = AddStaticVehicleEx(478, 2035.9824, -1129.0745, 24.4930, 180.4207, 85, 85, 2000);
	ballascar[1] = AddStaticVehicleEx(478, 2032.4999, -1129.0533, 24.5965, 180.9257, 85, 85, 2000);
	ballascar[2] = AddStaticVehicleEx(478, 2029.1277, -1129.0117, 24.6724, 180.0636, 85, 85, 2000);
	ballascar[3] = AddStaticVehicleEx(566, 2017.3907, -1143.4758, 24.7815, 270.2826, 85, 85, 2000);
	ballascar[4] = AddStaticVehicleEx(566, 2018.3511, -1128.7894, 24.7746, 269.8306, 85, 85, 2000);
	ballascar[5] = AddStaticVehicleEx(517, 2006.1587, -1128.6938, 25.1995, 269.0016, 85, 85, 2000);
	ballascar[6] = AddStaticVehicleEx(517, 2005.2440, -1143.5433, 25.2096, 269.3634, 85, 85, 2000);
	ballascar[7] = AddStaticVehicleEx(566, 1992.5656, -1143.4426, 25.4819, 268.8755, 85, 85, 2000);
	ballascar[8] = AddStaticVehicleEx(566, 1993.0916, -1128.5111, 25.4864, 267.9565, 85, 85, 2000);
	
	grovecar[0] = AddStaticVehicleEx(492, 2484.5916, -1681.2344, 13.1284, 0.1969, 86, 86, 2000);
	grovecar[1] = AddStaticVehicleEx(492, 2488.2288, -1681.2366, 13.1292, 0.1623, 86, 86, 2000);
	grovecar[2] = AddStaticVehicleEx(492, 2491.5364, -1681.2566, 13.1308, 0.3492, 86, 86, 2000);
	grovecar[3] = AddStaticVehicleEx(478, 2480.6936, -1656.0184, 13.3315, 90.5766, 86, 86, 2000);
	grovecar[4] = AddStaticVehicleEx(478, 2487.7554, -1655.9534, 13.3533, 90.2856, 86, 86, 2000);
	grovecar[5] = AddStaticVehicleEx(478, 2494.7190, -1655.9841, 13.3842, 89.4066, 86, 86, 2000);
	grovecar[6] = AddStaticVehicleEx(404, 2507.9238, -1665.8998, 13.1538, 11.2708, 86, 86, 2000);
	grovecar[7] = AddStaticVehicleEx(404, 2507.3582, -1673.3708, 13.1115, 344.2334, 86, 86, 2000);
	grovecar[8] = AddStaticVehicleEx(491, 2473.1763, -1696.9934, 13.1934, 359.6302, 86, 86, 2000);
	
	aztecascar[0] = AddStaticVehicleEx(567,2189.9895,-1805.9298,13.3246,0.5546, 2, 2, 2000);
	aztecascar[1] = AddStaticVehicleEx(567,2189.8958,-1795.3765,13.3273,0.1785, 2, 2, 2000);
	aztecascar[2] = AddStaticVehicleEx(534,2173.8774,-1807.6886,13.0952,359.5479, 2, 2, 2000);
	aztecascar[3] = AddStaticVehicleEx(534,2170.1592,-1807.6505,13.0972,358.3568, 2, 2, 2000);
	aztecascar[4] = AddStaticVehicleEx(534,2165.8708,-1807.5740,13.0971,359.5009, 2, 2, 2000);
	aztecascar[5] = AddStaticVehicleEx(534,2161.5151,-1807.4827,13.0989,359.1814, 2, 2, 2000);
	aztecascar[6] = AddStaticVehicleEx(478,2161.6189,-1793.3018,13.3532,180.1061, 2, 2, 2000);
	aztecascar[7] = AddStaticVehicleEx(478,2165.8894,-1793.2917,13.3530,180.1996, 2, 2, 2000);
	aztecascar[8] = AddStaticVehicleEx(478,2170.3567,-1793.2579,13.3538,179.3669, 2, 2, 2000);
	
 	vagoscar[0] = AddStaticVehicleEx(478, 2744.5334, -1192.5728, 69.3895, 89.8636, 6, 6, 2000);
	vagoscar[1] = AddStaticVehicleEx(478, 2744.4133, -1188.3857, 69.3913, 90.9851, 6, 6, 2000);
	vagoscar[2] = AddStaticVehicleEx(478, 2744.2852, -1184.8571, 69.3911, 89.8234, 6, 6, 2000);
	vagoscar[3] = AddStaticVehicleEx(474, 2734.3101, -1175.4796, 69.0215, 0.5476, 6, 6, 2000);
	vagoscar[4] = AddStaticVehicleEx(474, 2726.1040, -1175.2797, 69.0178, 359.6979, 6, 6, 2000);
	vagoscar[5] = AddStaticVehicleEx(576, 2726.2268, -1165.8281, 68.9166, 0.0299, 6, 6, 2000);
	vagoscar[6] = AddStaticVehicleEx(576, 2734.2678, -1166.0570, 68.9183, 0.2336, 6, 6, 2000);
	vagoscar[7] = AddStaticVehicleEx(474, 2726.2681, -1156.3014, 69.1720, 0.7132, 6, 6, 2000);
	vagoscar[8] = AddStaticVehicleEx(474, 2734.1755, -1156.1888, 69.1289, 359.5342, 6, 6, 2000);
	
	rifacar[0] = AddStaticVehicleEx(529, 2776.3135, -1944.9955, 13.1794, 359.6935, 79, 79, 2000);
	rifacar[1] = AddStaticVehicleEx(529, 2776.3247, -1933.6443, 13.1722, 359.8563, 79, 79, 2000);
	rifacar[2] = AddStaticVehicleEx(529, 2762.3210, -1944.9410, 13.1802, 359.6683, 79, 79, 2000);
	rifacar[3] = AddStaticVehicleEx(529, 2762.1904, -1933.9778, 13.1727, 359.1748, 79, 79, 2000);
	rifacar[4] = AddStaticVehicleEx(439, 2776.3789, -1956.1095, 13.4437, 359.7525, 79, 79, 2000);
	rifacar[5] = AddStaticVehicleEx(439, 2762.3655, -1955.7142, 13.4437, 0.0547, 79, 79, 2000);
	rifacar[6] = AddStaticVehicleEx(478, 2762.8286, -1963.6973, 13.5400, 270.1351, 79, 79, 2000);
	rifacar[7] = AddStaticVehicleEx(478, 2762.8679, -1967.6732, 13.5393, 270.3792, 79, 79, 2000);
	rifacar[8] = AddStaticVehicleEx(478, 2762.8923, -1971.7921, 13.5410, 269.8494, 79, 79, 2000);
	
	lcncar[0] = AddStaticVehicleEx(445,2498.0776,1525.1748,10.6914,248.6218,0,0,900);
	lcncar[1] = AddStaticVehicleEx(445,2508.0278,1522.1840,10.6894,262.1964,0,0,900);
	lcncar[2] = AddStaticVehicleEx(445,2502.2026,1537.4308,10.6953,248.9315,0,0,900);
	lcncar[3] = AddStaticVehicleEx(445,2510.0457,1534.9587,10.6953,261.1335,0,0,900);
	lcncar[4] = AddStaticVehicleEx(579,2479.7197,1538.9919,10.7640,205.1942,0,0,900);
	lcncar[5] = AddStaticVehicleEx(579,2491.8162,1546.9395,10.7430,197.9589,0,0,900);
	lcncar[6] = AddStaticVehicleEx(579,2475.8020,1551.1644,10.7556,188.0770,0,0,900);
	lcncar[7] = AddStaticVehicleEx(579,2490.2097,1554.5439,10.7499,187.7266,0,0,900);
	lcncar[8] = AddStaticVehicleEx(409,2491.8184,1565.1055,10.6145,162.4102,0,0,900);
	
	yakcar[0] = AddStaticVehicleEx(545,1494.2773,2838.4568,10.6323,179.2910,0,0,900);
	yakcar[1] = AddStaticVehicleEx(545,1489.4897,2838.4001,10.6317,179.5951,0,0,900);
	yakcar[2] = AddStaticVehicleEx(545,1484.6467,2838.4004,10.6326,181.4441,0,0,900);
	yakcar[3] = AddStaticVehicleEx(545,1479.7792,2838.3418,10.6318,178.8892,0,0,900);
	yakcar[4] = AddStaticVehicleEx(546,1475.1292,2839.1572,10.6009,178.5839,0,0,900);
	yakcar[5] = AddStaticVehicleEx(546,1470.2874,2839.0613,10.4402,182.9935,0,0,900);
	yakcar[6] = AddStaticVehicleEx(546,1465.4781,2838.9939,10.5335,179.0478,0,0,900);
	yakcar[7] = AddStaticVehicleEx(546,1460.6122,2838.9731,10.5060,179.8506,0,0,900);
	yakcar[8] = AddStaticVehicleEx(409,1475.3849,2773.0833,10.6203,180.2495,0,0,900);
	
 	rmcar[0] = AddStaticVehicleEx(551,983.1696,1719.3485,8.4555,91.1639,0,0,900);
	rmcar[1] = AddStaticVehicleEx(551,983.0984,1722.5786,8.4555,92.8734,0,0,900);
	rmcar[2] = AddStaticVehicleEx(551,983.1155,1726.1731,8.4553,90.4063,0,0,900);
	rmcar[3] = AddStaticVehicleEx(551,983.0601,1729.8684,8.4533,91.2542,0,0,900);
	rmcar[4] = AddStaticVehicleEx(580,983.0984,1734.0294,8.4478,90.1340,0,0,900);
	rmcar[5] = AddStaticVehicleEx(580,983.0426,1738.0096,8.4478,91.1444,0,0,900);
	rmcar[6] = AddStaticVehicleEx(580,983.0810,1742.0023,8.4446,91.3384,0,0,900);
	rmcar[7] = AddStaticVehicleEx(580,982.9680,1746.2189,8.4446,90.1041,0,0,900);
	rmcar[8] = AddStaticVehicleEx(409,973.2565,1698.3420,8.4484,358.9415,0,0,900);
}


stock EnableGPS(playerid, Float:x, Float:y, Float:z)
{
	gps[playerid] = true;
 	SetPlayerRaceCheckpoint(playerid, 1, Float:x, Float:y, Float:z, Float:x, Float:y, Float:z, 4.0);
	GameTextForPlayer(playerid, "GPS: ON", 0, 1);
	return true;
}

stock GiveServerMoney(playerid, money)
{
	PlayerInfo[playerid][pMoney] += money;
	GivePlayerMoney(playerid, money);
	new string[60 + MAX_PLAYER_NAME - 4 + 20];
	if(money > 0) format(string, sizeof(string), "~g~+%d$", money);
	else format(string, sizeof(string), "~r~%d$", money);
	GameTextForPlayer(playerid, string, 3000, 1);
	format(string, sizeof(string), "UPDATE `users` SET `pMoney` = '%d' WHERE `pName` = '%s'", PlayerInfo[playerid][pMoney], PlayerInfo[playerid][pName]);
	mysql_query(dbHandle, string);
}

stock IsOnline(name[])
{
    new Pname[24];
    for(new i; i< MAX_PLAYERS; i++)
    {
        if(!IsPlayerConnected(i)) continue;
        GetPlayerName(i, Pname, 24);
        if(!strcmp(Pname, name, true)) return 1;
    }
    return 0;
}

stock GetFracName(factionID)
{
	new text[32];
	switch(factionID)
	{
 		case 1: text = "LSPD";
 		case 2: text = "FBI";
 		case 3: text = "National Army";
 		case 4: text = "President Residence";
 		case 5: text = "Ballas";
 		case 6: text = "Grove";
 		case 7: text = "Rifa";
 		case 8: text = "Vagos";
 		case 9: text = "Aztecas";
 		case 10: text = "La Cosa Nostra";
 		case 11: text = "Yakudza";
 		case 12: text = "Russian Mafia";
		default: text = "None";
	}
	return text;
}

stock ProxDetectorS(Float:radi, playerid, targetid)
{
	if(IsPlayerConnected(playerid)&&IsPlayerConnected(targetid))
	{
		new Float:posx, Float:posy, Float:posz;
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetPlayerPos(playerid, oldposx, oldposy, oldposz);
		GetPlayerPos(targetid, posx, posy, posz);
		tempposx = (oldposx -posx);
		tempposy = (oldposy -posy);
		tempposz = (oldposz -posz);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
		{
			return true;
		}
	}
	return false;
}

forward SetPlayerToTeamColor(playerid);
public SetPlayerToTeamColor(playerid)
{
	switch(PlayerInfo[playerid][pMember])
	{
		case 0:	SetPlayerColor(playerid, 0xFFFFFF00); //none
		case 1: SetPlayerColor(playerid, 0x0800FFFF); //pd
		case 2: SetPlayerColor(playerid, 0x0800FFAA); //fbi
		case 3: SetPlayerColor(playerid, 0xFF5757FF); //army
		case 4: SetPlayerColor(playerid, 0xD4FF00FF); //prez
		case 5: SetPlayerColor(playerid, 0x990099AA); //ballas
		case 6: SetPlayerColor(playerid, 0x009900AA); //grove
		case 7: SetPlayerColor(playerid, 0x5200ccAA); //rifa
		case 8: SetPlayerColor(playerid, 0xffd633AA); //vagos
		case 9: SetPlayerColor(playerid, 0x00ffffAA); //aztecas
		case 10: SetPlayerColor(playerid, 0xe68a00AA); //lcn
		case 11: SetPlayerColor(playerid, 0xb30000AA); //yakudza
		case 12: SetPlayerColor(playerid, 0x661a00AA); //rm
	}
	return true;
}

/* OTHER SCRIPTS END */

/* SERVER COMMANDS */
CMD:admin(playerid, params[])
{
    IsAdmin(1);
    if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "s[128]", params[0])) return SendInfoMessage(playerid, "format: /a [text]");
    if(strlen(params[0]) > 128) return true;
    new string[128];
	format(string, sizeof(string), "[A] %s[%d]: %s", GetName(playerid), playerid, params[0]);
	SendAdminMessage(0xFFFF00AA, string);
	return true;
}
alias:admin("a");

CMD:kick(playerid, params[])
{
	IsAdmin(2);
    if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "us[256]",params[0],params[1])) return SendInfoMessage(playerid, "format: /kick [playerid] [reason]");
    if(PlayerInfo[params[0]][pLogin] != 1) return SendErrorMessage(playerid, "Am motamashes ar gauvlia avtorizacia");
    new string[128];
    format(string, sizeof(string), "Administratorma %s[%d] gaagdo serveridan motamashe %s. Mizezi: %s", GetName(playerid), playerid, GetName(params[0]), params[1]);
    SendClientMessageToAll(0xFF6347AA,string);
    KickEx(params[0]);
    AdminInfo[playerid][admKicked]++;
    new query[600];
	format(query, sizeof(query), "UPDATE `admin` SET `admKicked` = '%i' WHERE `admName` = '%s' LIMIT 1",AdminInfo[playerid][admKicked], PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "", "");
    return true;
}
CMD:warn(playerid, params[0])
{
	IsAdmin(5);
 	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "us[256]",params[0],params[1])) return SendInfoMessage(playerid, "format: /warn [playerid] [reason]");
    if(PlayerInfo[params[0]][pLogin] != 1) return SendErrorMessage(playerid, "Am motamashes ar gauvlia avtorizacia");
	PlayerInfo[params[0]][pWarn] ++;
	UpdatePlayerData(params[0], "pWarn", PlayerInfo[params[0]][pWarn]);
	new string[128];
	format(string, sizeof(string), "Administratorma %s[%d] misca gafrtxileba %s[%d] [%d/3] Mizezi: %s", GetName(playerid), playerid, GetName(params[0]), params[0], PlayerInfo[params[0]][pWarn], params[1]);
	SendClientMessageToAll(0xFF6347AA, string);
	
	PlayerInfo[params[0]][pRank] = 0;
	UpdatePlayerData(params[0], "pRank", PlayerInfo[params[0]][pRank]);
    PlayerInfo[params[0]][pLeader] = 0;
    UpdatePlayerData(params[0], "pLeader", PlayerInfo[params[0]][pLeader]);
    PlayerInfo[params[0]][pMember] = 0;
    UpdatePlayerData(params[0], "pMember", PlayerInfo[params[0]][pMember]);
    PlayerInfo[params[0]][pModel] = 0;
    UpdatePlayerData(params[0], "pModel", PlayerInfo[params[0]][pModel]);
    PlayerInfo[params[0]][pSetSpawn] = 0;
    UpdatePlayerData(params[0], "pSetSpawn", PlayerInfo[params[0]][pSetSpawn]);
    SetPlayerSkin(params[0], PlayerInfo[params[0]][pSkin]);
    SetPlayerToTeamColor(params[0]);
    if(PlayerInfo[params[0]][pWarn] == 3)
    {
        SendInfoMessage(playerid, "Tqven miiget 3 gafrtxileba");
        SendErrorMessage(playerid, "Tqven dagedot 5 dgiani BAN");
        PlayerInfo[params[0]][pBan] = getdate()+params[1];
        UpdatePlayerData(params[0], "pban", PlayerInfo[params[0]][pBan]);
		KickEx(params[0]);
		return true;
    }
    AdminInfo[playerid][admWarned]++;
    new query[600];
	format(query, sizeof(query), "UPDATE `admin` SET `admWarned` = '%i'  WHERE `admName` = '%s' LIMIT 1",AdminInfo[playerid][admWarned], PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "", "");
    return true;
}
CMD:ban(playerid, params[0])
{
    IsAdmin(7);
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
	if(sscanf(params, "dds[64]", params[0], params[1], params[2])) return SendInfoMessage(playerid, "format: /ban [playerid] [duration] [reason]");
 	if(!IsPlayerConnected(params[0])) return SendErrorMessage(playerid, "Motamashe ver moidzebna");
 	if(GetString(GetName(params[0]), "Nika Chitava") || GetString(GetName(params[0]), "Chitava_Production")) return 1; //tqven ver dagadeben bans
 	new string[128];
	format(string, sizeof(string), "Administratorma %s[%d] daado ban %s[%d] %d dgit. Mizezi: %s", GetName(playerid), playerid, GetName(params[0]), params[0], params[1], params[2]);
	SendClientMessageToAll(0xFF6347AA, string);
	PlayerInfo[params[0]][pBan] = getdate()+params[1];
	UpdatePlayerData(params[0], "pban", PlayerInfo[params[0]][pBan]);
	KickEx(params[0]);
	AdminInfo[playerid][admWarned]++;
    new query[600];
	format(query, sizeof(query), "UPDATE `admin` SET `admBaned` = '%i'  WHERE `admName` = '%s' LIMIT 1",AdminInfo[playerid][admBaned], PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "", "");
	return true;
}

CMD:makeadmin(playerid, params[])
{
    if(GetString(GetName(playerid), "Nika_Chitava"))
	{
		new playername[24], admin_level;
		if(sscanf(params, "s[24]i", playername, admin_level)) return SendInfoMessage(playerid, "Daweret: /setadmin [PLAYER_NAME] [ADMIN_LEVEL]");
		new string[128];
		format(string, sizeof(string), "SELECT * FROM `admin` WHERE `admName` = '%s'", playername);
		mysql_tquery(dbHandle, string, "SetAdmin", "isi", playerid, playername, admin_level);
	}
	return true;
}

CMD:setadmin(playerid, params[])
{
    if(GetString(GetName(playerid), "Nika_Chitava"))
	{
	    IsAdmin(10);
		if(AdminLogged[playerid] == false) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
		new playername[24], admin_level;
		if(sscanf(params, "s[24]i", playername, admin_level)) return SendInfoMessage(playerid, "Daweret: /setadmin [player name] [admin level]");
		new string[128];
		format(string, sizeof(string), "SELECT * FROM `admin` WHERE `admName` = '%s'", playername);
		mysql_tquery(dbHandle, string, "SetAdmin", "isi", playerid, playername, admin_level);
	}
	return true;
}


CMD:alogin(playerid, params[])
{
	if(AdminLogged[playerid]) return SendAdminInfo(playerid, "Tqven ukve gaiaret admin avtorizacia");
	new string[128];
	format(string, sizeof(string), "SELECT * FROM `admin` WHERE admName = '%s'", GetName(playerid));
	mysql_tquery(dbHandle, string, "Alogin", "is", playerid, GetName(playerid));
 	return 1;
}

CMD:makegun(playerid, params[])
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
    if(sscanf(params, "dd",params[0],params[1]))
    {
        new listitems[] = "{0099FF}Gamoiyenet /makegun [GUN_ID] [AMMO]\nIaragis ID-ebi:\n\n[1]{ffffff} Desert Eagle\n{0099FF}[2]{ffffff} ShotGun\n{0099FF}[3]{ffffff} M4\n{0099FF}[4]{ffffff} AK47\n{0099FF}[5]{ffffff} Country rifle\n{0099FF}[6]{ffffff} MP5";
        ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "Make Gun", listitems, "Gamortva", "");
        return 1;
    }
    switch(params[0])
    {
		case 1:
	    {
	        if(PlayerInfo[playerid][pAmmo] < params[1]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tyviebi");
	        GiveServerWeapon(playerid, 24, params[1]),
			PlayerInfo[playerid][pAmmo] -= params[1];
			UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
	    }
   		case 2:
	    {
	        if(PlayerInfo[playerid][pAmmo] < params[1]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tyviebi");
	        GiveServerWeapon(playerid, 25, params[1]),
			PlayerInfo[playerid][pAmmo] -= params[1];
			UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
	    }
   		case 3:
	    {
	        if(PlayerInfo[playerid][pAmmo] < params[1]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tyviebi");
	        GiveServerWeapon(playerid, 31, params[1]),
			PlayerInfo[playerid][pAmmo] -= params[1];
			UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
	    }
   		case 4:
	    {
	        if(PlayerInfo[playerid][pAmmo] < params[1]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tyviebi");
	        GiveServerWeapon(playerid, 30, params[1]),
			PlayerInfo[playerid][pAmmo] -= params[1];
			UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
	    }
   		case 5:
	    {
	        if(PlayerInfo[playerid][pAmmo] < params[1]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tyviebi");
	        GiveServerWeapon(playerid, 33, params[1]),
			PlayerInfo[playerid][pAmmo] -= params[1];
			UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
	    }
   		case 6:
	    {
	        if(PlayerInfo[playerid][pAmmo] < params[1]) return SendErrorMessage(playerid, "Ar gaqvt sakmarisi tyviebi");
	        GiveServerWeapon(playerid, 29, params[1]),
			PlayerInfo[playerid][pAmmo] -= params[1];
			UpdatePlayerData(playerid, "pAmmo", PlayerInfo[playerid][pAmmo]);
	    }
    }
	return true;
}

CMD:makeleader(playerid, params[])
{
    IsAdmin(8);
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "d",params[0])) return SendInfoMessage(playerid, "format: /makeleader [playerid]");
    if(PlayerInfo[playerid][pLeader] > 0) return SendErrorMessage(playerid, "Es motamashe ukve aris lideri");
    if(!IsPlayerConnected(params[0])) return true;
    new str1[50 + MAX_PLAYER_NAME];
	format(str1, sizeof(str1), "{FFFFFF}Makeleader - %s", GetName(params[0]));
    ShowPlayerDialog(playerid, d_MAKELEADER, DIALOG_STYLE_LIST, str1, "{828282}- {FFFFFF}Los Santos Police Department\n{828282}- {FFFFFF}F.B.I\n{828282}- {FFFFFF}National Army\n{828282}- {FFFFFF}President residence", "Archeva", "Gamosvla");
    SetPVarInt(playerid,"ActionID",params[0]);
    return true;
}
CMD:setgang(playerid, params[])
{
    IsAdmin(8);
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "d",params[0])) return SendInfoMessage(playerid, "format: /setgang [playerid]");
    if(PlayerInfo[playerid][pLeader] > 0) return SendErrorMessage(playerid, "Es motamashe ukve aris lideri");
    if(!IsPlayerConnected(params[0])) return true;
    new str1[50 + MAX_PLAYER_NAME];
	format(str1, sizeof(str1), "{FFFFFF}Makeleader - %s", GetName(params[0]));
    ShowPlayerDialog(playerid, d_GANGLEADER, DIALOG_STYLE_LIST, str1, "{828282}- {FFFFFF}Ballas\n{828282}- {FFFFFF}Grove\n{828282}- {FFFFFF}Rifa\n{828282}- {FFFFFF}Vagos\n{828282}- {FFFFFF}Aztecas", "Archeva", "Gamosvla");
    SetPVarInt(playerid,"ActionID",params[0]);
    return true;
}
CMD:setmafia(playerid, params[])
{
    IsAdmin(8);
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "d",params[0])) return SendInfoMessage(playerid, "format: /setgang [playerid]");
    if(PlayerInfo[playerid][pLeader] > 0) return SendErrorMessage(playerid, "Es motamashe ukve aris lideri");
    if(!IsPlayerConnected(params[0])) return true;
    new str1[50 + MAX_PLAYER_NAME];
	format(str1, sizeof(str1), "{FFFFFF}Makeleader - %s", GetName(params[0]));
    ShowPlayerDialog(playerid, d_MAFIALEADER, DIALOG_STYLE_LIST, str1, "{828282}- {FFFFFF}La Cosa Nostra\n{828282}- {FFFFFF}Yakudza\n{828282}- {FFFFFF}Russian Mafia", "Archeva", "Gamosvla");
    SetPVarInt(playerid,"ActionID",params[0]);
    return true;
}
CMD:auninvite(playerid, params[])
{
    IsAdmin(7);
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "d",params[0])) return SendInfoMessage(playerid, "format: /auninvite [playerid]");
    if(PlayerInfo[playerid][pLeader] == 0) return SendErrorMessage(playerid, "Es motamashe ukve aris lideri");
    PlayerInfo[params[0]][pLeader] = 0;
    PlayerInfo[params[0]][pMember] = 0;
    PlayerInfo[params[0]][pRank] = 0;
    DeletePVar(params[0], "FracDuty");
    PlayerInfo[params[0]][pSetSpawn] = 0;
    SetPlayerVirtualWorld(params[0], 0);
    SetPlayerInterior(params[0], 0);
    SpawnPlayer(params[0]);
    return true;
}
CMD:lmenu(playerid, params[])
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pRank] == 9)
	{
		new str[256];
		format(str, sizeof(str), "{FFCC00}1. {FFFFFF}Sawyobis %s\n{FFCC00}2. {FFFFFF}Online wevrebi\n{FFCC00}3. {FFFFFF}Offline motamashis gagdeba",wInfo[PlayerInfo[playerid][pMember]][wStatus]?("{F04245}Daxurva"):("{63BD4E}Gaxsna"));
		ShowPlayerDialog(playerid, d_LMENU, DIALOG_STYLE_LIST, "{FFCC00}LEADER MENU", str, "Archeva", "Gamosvla");
	}
	else
	{
	    SendErrorMessage(playerid, "Xelmisawvdomia mxolod lideristivs an moadgilestvis");
	}
	return true;
}
CMD:invite(playerid, params[])
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
    if(sscanf(params, "d", params[0])) return SendInfoMessage(playerid, "format: /invite [playerid]");
    if(!IsPlayerConnected(params[0])) return true;
	if(GetPVarInt(params[0], "InviteTimer") > gettime()) SendInfoMessage(playerid, "Am motamashes ukve shestavazes mowveva");
	if(PlayerInfo[playerid][pLeader] == 1 || PlayerInfo[playerid][pMember] > 0 &&PlayerInfo[playerid][pRank] == 9)
	{
		if(PlayerInfo[params[0]][pWarn] > 0) return SendErrorMessage(playerid, "Motamashes adevs warn");
		if(PlayerInfo[params[0]][pMember] > 0) return SendErrorMessage(playerid,  "Motamashe organizaciashia");
		if(!ProxDetectorS(5, playerid, params[0])) return SendErrorMessage(playerid, "Motamashe araa tqventan Axlos");
		
		SetPVarInt(params[0], "InviteMember", PlayerInfo[playerid][pMember]);
  		SetPVarInt(params[0], "Inviter", playerid);
    	SetPVarInt(params[0], "InviteTimer", gettime()+30);
		new str[144];
		format(str, sizeof(str), "%s gtavazobt %s-shi gawevrianebas. Tanxmobistvis daachiret {33AA33}Y{ffffff}, uaryofistvis {AA3333}N", GetName(playerid), GetFracName(PlayerInfo[playerid][pMember]));
		SendClientMessage(params[0], 0xFFFFFFFF, str);
		format(str, sizeof(str), "Tqven miiwviet %s tqvens organizaciashi.", GetName(params[0]));
		SendClientMessage(playerid, 0xFFFFFFFF, str);
	}
	return true;
}
CMD:uninvite(playerid, params[])
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(PlayerInfo[playerid][pMember] == 0) return 1;
	if(PlayerInfo[playerid][pLeader] != 1 || PlayerInfo[playerid][pRank] < 9) return SendErrorMessage(playerid, "Ar flobt sakmariss ranks");
	if(sscanf(params, "d", params[0])) return SendInfoMessage(playerid, "format: /uninvite [playerid]");
	if(PlayerInfo[playerid][pMember] > 0 && PlayerInfo[params[0]][pMember] != PlayerInfo[playerid][pMember]) return SendErrorMessage(playerid, "Motamashe araa tqvens organizaciashi");
	if(playerid == params[0]) return 1;
	if(!IsPlayerConnected(params[0])) return SendErrorMessage(playerid, "Motamashe ver moidzebna");
	PlayerInfo[params[0]][pRank] = 0;
	PlayerInfo[params[0]][pMember] = 0;
	PlayerInfo[params[0]][pModel] = 0;
	UpdatePlayerData(params[0], "pRank", PlayerInfo[params[0]][pRank]);
	UpdatePlayerData(params[0], "pMember", PlayerInfo[params[0]][pMember]);
	UpdatePlayerData(params[0], "pModel", PlayerInfo[params[0]][pModel]);
	SetPlayerSkin(params[0], PlayerInfo[params[0]][pSkin]);
	SetPlayerToTeamColor(params[0]);
	
	if(gov_member(playerid))
	{
 		new string[256];
		format(string, sizeof(string), "[R] %s[%d] gaagdo organizaciidan %s[%d]", GetName(playerid), playerid, GetName(params[0]), params[0]);
		SendRadioMessage(PlayerInfo[playerid][pMember], 0xa8e607FF, string);
	}
	if(ghetto_members(playerid) || mafia_members(playerid))
	{
 		new string[256];
		format(string, sizeof(string), "[F] %s[%d] gaagdo fraqciidan %s[%d]", GetName(playerid), playerid, GetName(params[0]), params[0]);
		SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, string);
	}
	return 1;
}

CMD:members(playerid)
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
 	if(PlayerInfo[playerid][pMember]==0) return SendErrorMessage(playerid, "Tqven ar xart arcert organizaciashi");
	new string[1024], count = 0,str[25 + MAX_PLAYER_NAME - 4];
	if(PlayerInfo[playerid][pMember] > 0)
	{
	    foreach(new x:Player)
		{
		    if(PlayerInfo[x][pMember] == PlayerInfo[playerid][pMember])
		    {
				format(str, sizeof(str), "%s[%d]\t\tRang: %d\n", GetName(x), x, PlayerInfo[x][pRank]);
				if(PlayerInfo[x][pRank] == 10) format(str, sizeof(str), "%s[%d]\t\tRank: Leader\n", GetName(x), x);
				strcat(string, str);
				count++;
		    }
		}
		format(str, sizeof(str), "\nAll: %d member", count);
		strcat(string, str);
		ShowPlayerDialog(playerid, d_None, DIALOG_STYLE_MSGBOX, "MEMBERS", string, "Migeba", "Gamosvla");
		return 1;
	}
	return 1;
}

CMD:leaders(playerid, params[])
{
	if(PlayerInfo[playerid][pLogin] == 0) return true;
	new l_string[1024], Names[MAX_PLAYER_NAME], factionID, y_string[256], b_string[512];
	
	format(y_string, sizeof(y_string), "SELECT * FROM `users` WHERE pLeader >= '1' ORDER BY `pLeader` ASC");
	mysql_query(dbHandle, y_string);
	
	new rows;
	cache_get_row_count(rows);
	if(!rows) return SendErrorMessage(playerid, "Bazashi liderebi ver moidzebna");
	
	strcat(l_string, "Name\tFraction\tStatusi\n");
	for new i = 0; i < rows; i++ do
	{
	    cache_get_value_name(i, "pName", Names);
	    cache_get_value_name_int(i,"pLeader",factionID);
	    format(b_string, sizeof(b_string), "{FFFFFF}%s\t%s\t%s\n", Names, GetFracName(factionID), IsOnline(Names) ? ("{7EDF17}Online{FFFFFF}") : ("{DF1717}Offline{FFFFFF}"));
		strcat(l_string, b_string);
	}
	ShowPlayerDialog(playerid, d_LEADERS, DIALOG_STYLE_TABLIST_HEADERS, "Server leaders", l_string, "Close", "");
	return true;
}

CMD:offleader(playerid, params[])
{
    IsAdmin(9);
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
	if(sscanf(params, "s[128]",params[0])) return SendInfoMessage(playerid, "format: /offleader [nickname]");
	new query[256];
	format(query,sizeof(query),"SELECT `pName` FROM `users` WHERE pName = '%s'",params[0]);
	mysql_query(dbHandle,query);
		
	new rows;
	cache_get_row_count(rows);
	if(!rows) return SendErrorMessage(playerid, "Motamashe ver moidzebna");

	format(query, sizeof(query), "UPDATE users SET pLeader = '0', pMember = '0', pRank = '0' WHERE pName = '%s'",params[0]);
	mysql_query(dbHandle,query);
	format(query, sizeof(query), "Admin: %s offleader: %s", GetName(playerid),params[0]);
	SendClientMessage(playerid, 0xFFFFFFFF, query);
	return true;
}

CMD:r(playerid, params[])
{
    if(!PlayerInfo[playerid][pLogin] || !gov_member(playerid)) return 1;
	if(sscanf(params, "s[128]", params[0])) return SendInfoMessage(playerid, "format: /r [text]");
	new fracID = PlayerInfo[playerid][pMember]-1;
 	new string[256];
	format(string, sizeof(string), "[R] %s %s[%d]: %s", FractionRankName[fracID][PlayerInfo[playerid][pRank]], PlayerInfo[playerid][pName], playerid, params[0]);
	SendRadioMessage(PlayerInfo[playerid][pMember], 0xa8e607FF, string);
	return true;
}
CMD:f(playerid, params[])
{
    if(!PlayerInfo[playerid][pLogin] || !ghetto_members(playerid) && !mafia_members(playerid)) return 1;
	if(sscanf(params, "s[128]", params[0])) return SendInfoMessage(playerid, "format: /f [text]");
	new fracID = PlayerInfo[playerid][pMember]-1;
 	new string[256];
	format(string, sizeof(string), "[F] %s %s[%d]: %s", FractionRankName[fracID][PlayerInfo[playerid][pRank]], PlayerInfo[playerid][pName], playerid, params[0]);
	SendFamilyMessage(PlayerInfo[playerid][pMember], 0x6DA3B5C8, string);
	return true;
}

CMD:d(playerid, params[])
{
    if(!PlayerInfo[playerid][pLogin] || !gov_member(playerid)) return 1;
	if(sscanf(params, "s[128]", params[0])) return SendInfoMessage(playerid, "format: /r [text]");
	if(PlayerInfo[playerid][pRank] < 7) return SendInfoMessage(playerid, "Am chatis gamoyeneba shesadzlebelia 7 rangidan");
	new fracID = PlayerInfo[playerid][pMember]-1;
 	new string[256];
	format(string, sizeof(string), "[D] %s %s[%d]: %s", FractionRankName[fracID][PlayerInfo[playerid][pRank]], PlayerInfo[playerid][pName], playerid, params[0]);
	SendTeamMessage(1, 0xFF6347AA, string);
	return true;
}

CMD:settime(playerid, params[])
{
	SetWorldTime(params[0]);
	return true;
}

CMD:addhouse(playerid, params[])
{
    IsAdmin(10);
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "d",params[0]))
	{
		SendInfoMessage(playerid, "format: /addhouse [Class]");
		SendInfoMessage(playerid, "1 - [NOPE] | 2 - [MEDIUM] | 3 - [ELITE] | 4 - [LUXURY]");
		return true;
	}
	if(params[0] < 1 || params[0] > 4) return SendInfoMessage(playerid, "1 - [NOPE] | 2 - [MEDIUM] | 3 - [ELITE] | 4 - [LUXURY]");
	
	new Float: posX, Float: posY, Float: posZ;
	GetPlayerPos(playerid, posX, posY, posZ);
	new query[200];
	format(query, sizeof(query), "INSERT INTO `property` (`hEnter_X`, `hEnter_Y`,`hEnter_Z`, `hLock`,`hClass`) VALUES ('%f', '%f', '%f', '1','%d')",posX,posY,posZ,params[0]);
	mysql_query(dbHandle,query);
	
	TotalHouse++;
	HouseInfo[TotalHouse][hID] = TotalHouse;
	HouseInfo[TotalHouse][hEnter_X] = posX;
	HouseInfo[TotalHouse][hEnter_Y] = posY;
	HouseInfo[TotalHouse][hEnter_Z] = posZ;
	HouseInfo[TotalHouse][hLock] = 1;
	HouseInfo[TotalHouse][hClass] = params[0];
	strmid(HouseInfo[TotalHouse][hOwner],"The State",0,strlen("The State"), MAX_PLAYER_NAME);
	
	if(HouseInfo[TotalHouse][hClass] == 1) //nopeclass - 50.000$
	{
		HouseInfo[TotalHouse][hInt] = 1;
		HouseInfo[TotalHouse][hExit_X] = 2025.3691;
		HouseInfo[TotalHouse][hExit_Y] = -1786.1152;
		HouseInfo[TotalHouse][hExit_Z] = 3026.4587;
		HouseInfo[TotalHouse][hPrice] = 50000;
	}
 	if(HouseInfo[TotalHouse][hClass] == 2) //medium - 80.000$
	{
		HouseInfo[TotalHouse][hInt] = 2;
		HouseInfo[TotalHouse][hExit_X] = 2206.6379;
		HouseInfo[TotalHouse][hExit_Y] = -404.3731;
		HouseInfo[TotalHouse][hExit_Z] = 1502.0081;
		HouseInfo[TotalHouse][hPrice] = 80000;
	}
	if(HouseInfo[TotalHouse][hClass] == 3) //elite - 140.000$
	{
		HouseInfo[TotalHouse][hInt] = 3;
		HouseInfo[TotalHouse][hExit_X] = 1479.6339;
		HouseInfo[TotalHouse][hExit_Y] = -1358.5889;
		HouseInfo[TotalHouse][hExit_Z] = 2097.2012;
		HouseInfo[TotalHouse][hPrice] = 140000;
	}
 	if(HouseInfo[TotalHouse][hClass] == 4) //luxury - 180.000$
	{
		HouseInfo[TotalHouse][hInt] = 4; 
		HouseInfo[TotalHouse][hExit_X] = 2194.4971;
		HouseInfo[TotalHouse][hExit_Y] = -738.3878;
		HouseInfo[TotalHouse][hExit_Z] = 1502.0032;
		HouseInfo[TotalHouse][hPrice] = 180000;
	}
	HouseCP[TotalHouse] = CreateDynamicCP(HouseInfo[TotalHouse][hEnter_X], HouseInfo[TotalHouse][hEnter_Y], HouseInfo[TotalHouse][hEnter_Z], 1.0, -1, -1, -1, 25.0);
	HouseInfo[TotalHouse][hIcon] = CreateDynamicMapIcon(HouseInfo[TotalHouse][hEnter_X], HouseInfo[TotalHouse][hEnter_Y], HouseInfo[TotalHouse][hEnter_Z], 31, 0xFFFFFFFF, 0, -1, -1, 25);
	House3DText[TotalHouse] = CreateDynamic3DTextLabel(" PROPERTY ",0xE1AE3CFF,HouseInfo[TotalHouse][hEnter_X], HouseInfo[TotalHouse][hEnter_Y],HouseInfo[TotalHouse][hEnter_Z],25.0);
	UpdateHouse(TotalHouse);
	SaveProperty(TotalHouse);
	return true;
}

CMD:hpanel(playerid, params[])
{
    new h = PlayerInfo[playerid][pHouse];
	if(h == -1 || strcmp(PlayerInfo[playerid][pName], HouseInfo[PlayerInfo[playerid][pHouse]][hOwner], true) == -1) return true;
 	new string[200];
  	format(string, sizeof(string), "{86ec67}- {FFFFFF}Karebis %s\n{86ec67}- {FFFFFF}Saxlis angarishi\n{86ec67}- {FFFFFF}Saxlis gayidva\n{86ec67}- {FFFFFF}Saxlis monishvna rukaze",HouseInfo[h][hLock]?("{63BD4E}Gaxsna"):("{F04245}Daketva"));
   	ShowPlayerDialog(playerid, d_HPANEL, DIALOG_STYLE_LIST, "HOUSE PANEL", string, "Archeva", "Gamosvla");
   	return true;
}
CMD:sellhouse(playerid)
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
    new h = PlayerInfo[playerid][pHouse];
	if(h == -1 || strcmp(PlayerInfo[playerid][pName], HouseInfo[PlayerInfo[playerid][pHouse]][hOwner], true) == -1) return true;
	if(!IsPlayerInRangeOfPoint(playerid, 10.0, HouseInfo[h][hEnter_X], HouseInfo[h][hEnter_Y], HouseInfo[h][hEnter_Z])) return true;
	new string[128];
	format(string, sizeof(string), "{86ec67} - {FFFFFF}Tqveni biznesis safasuri %d$\n\n{4582A1} * {828282}Gayidvis shemdeg tqven gibrundebat girebulebis 75%", HouseInfo[h][hPrice]);
	ShowPlayerDialog(playerid, d_SELLHOUSE, DIALOG_STYLE_MSGBOX, "{4582A1}Saxlis gayidva", string, "Archeva", "Gamosvla");
	return true;
}
CMD:exit(playerid, params[])
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
    for(new i; i < TotalHouse; i ++)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 10.0, HouseInfo[i][hExit_X], HouseInfo[i][hExit_Y], HouseInfo[i][hExit_Z])) continue;
		if(GetPlayerVirtualWorld(playerid) == i+50)
		{
			SetPlayerInterior(playerid,0);
			SetPlayerVirtualWorld(playerid,0);
			SetPlayerPos(playerid,HouseInfo[i][hEnter_X],HouseInfo[i][hEnter_Y],HouseInfo[i][hEnter_Z]);
		}
	}
	return true;
}
CMD:payday(playerid, params[])
{
    IsAdmin(10);
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
	PayDay();
	return true;
}

CMD:bpanel(playerid, params[])
{
	if(PlayerInfo[playerid][pBizz] >= 0)
	{
		new b = PlayerInfo[playerid][pBizz];
		if(b == -1) return SendErrorMessage(playerid, "Tqven ar flobt biznes");
	 	new string[300];
	  	format(string, sizeof(string), "{86ec67}- {FFFFFF}Biznesis %s\n{86ec67}- {FFFFFF}Salaros martva\n{86ec67}- {FFFFFF}Biznesis statistika\n{86ec67}- {FFFFFF}Produqtis shekveta\n{86ec67}- {FFFFFF}Biznesis saxelis shecvla\n{86ec67}- {FFFFFF}Biznesis gayidva\n{86ec67}- {FFFFFF}Biznesis gaumjobeseba",BizzInfo[b][bLock]?("{63BD4E}Gaxsna"):("{F04245}Daketva"));
	   	ShowPlayerDialog(playerid, d_BPANEL, DIALOG_STYLE_LIST, "BUSSINES PANEL", string, "Archeva", "Gamosvla");
	}
	if(PlayerInfo[playerid][pFillBizz] >= 0)
	{
	    new b = PlayerInfo[playerid][pFillBizz];
		if(b == -1) return SendErrorMessage(playerid, "Tqven ar flobt biznes");
	 	new string[300];
	  	format(string, sizeof(string), "{86ec67}- {FFFFFF}Biznesis %s\n{86ec67}- {FFFFFF}Salaros martva\n{86ec67}- {FFFFFF}Biznesis statistika\n{86ec67}- {FFFFFF}Sawvavis shekveta\n{86ec67}- {FFFFFF}Biznesis gayidva\n{86ec67}- {FFFFFF}Biznesis gaumjobeseba",FillInfo[b][fLock]?("{63BD4E}Gaxsna"):("{F04245}Daketva"));
	   	ShowPlayerDialog(playerid, d_BFILLPANEL, DIALOG_STYLE_LIST, "BUSSINES PANEL", string, "Archeva", "Gamosvla");
	}
	return true;
}
CMD:sellbizz(playerid)
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
    new b = PlayerInfo[playerid][pBizz];
	if(b == -1 || strcmp(PlayerInfo[playerid][pName], BizzInfo[b][bOwner], true) == -1) return true;
	if(!IsPlayerInRangeOfPoint(playerid, 10.0, BizzInfo[b][bEnter_X], BizzInfo[b][bEnter_Y], BizzInfo[b][bEnter_Z])) return true;
	new string[128];
	format(string, sizeof(string), "{86ec67} - {FFFFFF}Tqveni biznesis safasuri %d$\n\n{4582A1} * {828282}Gayidvis shemdeg tqven gibrundebat girebulebis 75%", BizzInfo[b][bPrice]);
	ShowPlayerDialog(playerid, d_SELLBIZZ, DIALOG_STYLE_MSGBOX, "{4582A1}Saxlis gayidva", string, "Archeva", "Gamosvla");
	return true;
}
CMD:sellfill(playerid)
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
    new b = PlayerInfo[playerid][pFillBizz];
	if(b == -1 || strcmp(PlayerInfo[playerid][pName], FillInfo[b][fOwner], true) == -1) return true;
	if(!IsPlayerInRangeOfPoint(playerid, 10.0, FillInfo[b][fMenu_X], FillInfo[b][fMenu_Y], FillInfo[b][fMenu_Z])) return true;
	new string[128];
	format(string, sizeof(string), "{86ec67} - {FFFFFF}Tqveni biznesis safasuri %d$\n\n{4582A1} * {828282}Gayidvis shemdeg tqven gibrundebat girebulebis 75%", FillInfo[b][fPrice]);
	ShowPlayerDialog(playerid, d_SELLFILL, DIALOG_STYLE_MSGBOX, "{4582A1}Saxlis gayidva", string, "Archeva", "Gamosvla");
	return true;
}
CMD:addbizz(playerid, params[])
{
    IsAdmin(10);
    if(PlayerInfo[playerid][pLogin] == 0) return true;
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
    if(sscanf(params, "d",params[0]))
	{
		SendInfoMessage(playerid, "format: /addbizz [TYPE]");
		SendInfoMessage(playerid, "1 - [24/7] | 2 - [BURGER] | 3 - [BAR] | 4 - [SKIN SHOP]");
		return true;
	}
	if(params[0] < 1 || params[0] > 4) return SendInfoMessage(playerid, "1 - [24/7] | 2 - [BURGER] | 3 - [BAR] | 4 - [SKIN SHOP]");

	new Float: posX, Float: posY, Float: posZ;
	GetPlayerPos(playerid, posX, posY, posZ);
	new query[200];
	format(query, sizeof(query), "INSERT INTO `bussines` (`bEnter_X`, `bEnter_Y`,`bEnter_Z`) VALUES ('%f', '%f', '%f')",posX,posY,posZ);
	mysql_query(dbHandle,query);

	TotalBizz++;
	BizzInfo[TotalBizz][bID] = TotalBizz;
	BizzInfo[TotalBizz][bEnter_X] = posX;
	BizzInfo[TotalBizz][bEnter_Y] = posY;
	BizzInfo[TotalBizz][bEnter_Z] = posZ;
    BizzInfo[TotalBizz][bLock] = 1;
    BizzInfo[TotalBizz][bType] = params[0];
    BizzInfo[TotalBizz][bProd] = 100;
    BizzInfo[TotalBizz][bProfitHour] = 0;
    BizzInfo[TotalBizz][bBank] = 0;
    BizzInfo[TotalBizz][bMaxProd] = 100;
    BizzInfo[TotalBizz][bGuest] = 0;
    BizzInfo[TotalBizz][bOwned] = 0;
    BizzInfo[TotalBizz][bProfit] = 0;
    BizzInfo[TotalBizz][bImprove] = 0;
    strmid(BizzInfo[TotalBizz][bOwner],"The State",0,strlen("The State"), MAX_PLAYER_NAME);
    strmid(BizzInfo[TotalBizz][bName],"NO NAME",0,strlen("NO NAME"), 32);

    if(BizzInfo[TotalBizz][bType] == 1) //247 
    {
        BizzInfo[TotalBizz][bInt] = 1;
        BizzInfo[TotalBizz][bInt] = 1;
        BizzInfo[TotalBizz][bExit_X] = 2587.3845;
        BizzInfo[TotalBizz][bExit_Y] = 1409.6226;
        BizzInfo[TotalBizz][bExit_Z] = 1800.9688;
        BizzInfo[TotalBizz][bBar_X] = 2581.7930;
        BizzInfo[TotalBizz][bBar_Y] = 1416.7307;
        BizzInfo[TotalBizz][bBar_Z] = 1800.9688;
        BizzInfo[TotalBizz][bPrice] = 40000;
        BizzInfo[TotalBizz][bIcon] = CreateDynamicMapIcon(BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z], 17, 0xFFFFFFFF, 0, -1, -1, 50);
	    BizzInfo[TotalBizz][bPick] = CreateDynamicPickup(19592, 23, BizzInfo[TotalBizz][bBar_X], BizzInfo[TotalBizz][bBar_Y], BizzInfo[TotalBizz][bBar_Z]);
	    Bizz3DText[TotalBizz] = CreateDynamic3DTextLabel(" BIZZ ",0xE1AE3CFF, BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z],25.0);
		BizzCP[TotalBizz] = CreateDynamicCP(BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z], 1.0, -1, -1, -1, 25.0);
		BizzInfo[TotalBizz][bText] = CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, BizzInfo[TotalBizz][bBar_X], BizzInfo[TotalBizz][bBar_Y], BizzInfo[TotalBizz][bBar_Z],25.0);
    }
    if(BizzInfo[TotalBizz][bType] == 2) //burger
    {
        BizzInfo[TotalBizz][bInt] = 2;
        BizzInfo[TotalBizz][bWorld] = 2;
        BizzInfo[TotalBizz][bExit_X] = 1086.0278;
        BizzInfo[TotalBizz][bExit_Y] = 1004.0371;
        BizzInfo[TotalBizz][bExit_Z] = 1600.9989;
        BizzInfo[TotalBizz][bBar_X] = 1082.9819;
        BizzInfo[TotalBizz][bBar_Y] = 993.2729;
        BizzInfo[TotalBizz][bBar_Z] = 1600.9989;
        BizzInfo[TotalBizz][bPrice] = 50000;
        BizzInfo[TotalBizz][bIcon] = CreateDynamicMapIcon(BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z], 10, 0xFFFFFFFF, 0, -1, -1, 50);
        BizzInfo[TotalBizz][bPick] = CreateDynamicPickup(2663, 23, BizzInfo[TotalBizz][bBar_X], BizzInfo[TotalBizz][bBar_Y], BizzInfo[TotalBizz][bBar_Z]);
        Bizz3DText[TotalBizz] = CreateDynamic3DTextLabel(" BIZZ ",0xE1AE3CFF, BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z],25.0);
		BizzCP[TotalBizz] = CreateDynamicCP(BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z], 1.0, -1, -1, -1, 25.0);
		BizzInfo[TotalBizz][bText] = CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, BizzInfo[TotalBizz][bBar_X], BizzInfo[TotalBizz][bBar_Y], BizzInfo[TotalBizz][bBar_Z],25.0);
    }
   	if(BizzInfo[TotalBizz][bType] == 3) //bar
    {
        BizzInfo[TotalBizz][bInt] = 4;
        BizzInfo[TotalBizz][bWorld] = 4;
        BizzInfo[TotalBizz][bExit_X] = 493.356;
        BizzInfo[TotalBizz][bExit_Y] = -24.8449;
        BizzInfo[TotalBizz][bExit_Z] = 1000.68;
        BizzInfo[TotalBizz][bBar_X] = 499.276;
        BizzInfo[TotalBizz][bBar_Y] = -20.7244;
        BizzInfo[TotalBizz][bBar_Z] = 1000.68;
        BizzInfo[TotalBizz][bPrice] = 70000;
        BizzInfo[TotalBizz][bIcon] = CreateDynamicMapIcon(BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z], 10, 0xFFFFFFFF, 0, -1, -1, 50);
        BizzInfo[TotalBizz][bPick] = CreateDynamicPickup(1546, 23, BizzInfo[TotalBizz][bBar_X], BizzInfo[TotalBizz][bBar_Y], BizzInfo[TotalBizz][bBar_Z]);
        Bizz3DText[TotalBizz] = CreateDynamic3DTextLabel(" BIZZ ",0xE1AE3CFF, BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z],25.0);
		BizzCP[TotalBizz] = CreateDynamicCP(BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z], 1.0, -1, -1, -1, 25.0);
		BizzInfo[TotalBizz][bText] = CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, BizzInfo[TotalBizz][bBar_X], BizzInfo[TotalBizz][bBar_Y], BizzInfo[TotalBizz][bBar_Z],25.0);
    }
    if(BizzInfo[TotalBizz][bType] == 4) //skin shop
    {
        BizzInfo[TotalBizz][bInt] = 5;
        BizzInfo[TotalBizz][bWorld] = 5;
        BizzInfo[TotalBizz][bExit_X] = 452.4813;
        BizzInfo[TotalBizz][bExit_Y] = -1497.6804;
        BizzInfo[TotalBizz][bExit_Z] = 3001.0859;
        BizzInfo[TotalBizz][bBar_X] = 461.7438;
        BizzInfo[TotalBizz][bBar_Y] = -1498.1750;
        BizzInfo[TotalBizz][bBar_Z] = 3001.0859;
        BizzInfo[TotalBizz][bPrice] = 90000;
        BizzInfo[TotalBizz][bIcon] = CreateDynamicMapIcon(BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z], 45, 0xFFFFFFFF, 0, -1, -1, 50);
        BizzInfo[TotalBizz][bPick] = CreateTrigger(BizzInfo[TotalBizz][bBar_X], BizzInfo[TotalBizz][bBar_Y], BizzInfo[TotalBizz][bBar_Z]-1.77);
        Bizz3DText[TotalBizz] = CreateDynamic3DTextLabel(" BIZZ ",0xE1AE3CFF, BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z],25.0);
		BizzCP[TotalBizz] = CreateDynamicCP(BizzInfo[TotalBizz][bEnter_X], BizzInfo[TotalBizz][bEnter_Y], BizzInfo[TotalBizz][bEnter_Z], 1.0, -1, -1, -1, 25.0);
		BizzInfo[TotalBizz][bText] = CreateDynamic3DTextLabel("{AFAFAF}PRESS: {ff9900}N ",0xE1AE3CFF, BizzInfo[TotalBizz][bBar_X], BizzInfo[TotalBizz][bBar_Y], BizzInfo[TotalBizz][bBar_Z],25.0);
    }
	UpdateBizz(TotalBizz);
	SaveBizz(TotalBizz);
	return true;

}

CMD:engine(playerid)
{
    if(PlayerInfo[playerid][pLogin] == 0) return true;
    if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 481 || GetVehicleModel(GetPlayerVehicleID(playerid)) == 509 || GetVehicleModel(GetPlayerVehicleID(playerid)) == 510) return SendErrorMessage(playerid, "Am transports ar gaachnia dzravi");
    if(GetPlayerVehicleID(playerid) == INVALID_VEHICLE_ID) return true;
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return true;
    new car = GetPlayerVehicleID(playerid);
	if(vInfo[car][vEngine] == false)
	{
		GetVehicleParamsEx(car,engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(car,VEHICLE_PARAMS_ON,lights,alarm,doors,bonnet,boot,objective);
		vInfo[car][vEngine] = true;
	}
	else if(vInfo[car][vEngine] == true)
	{
		GetVehicleParamsEx(car,engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(car,VEHICLE_PARAMS_OFF,lights,alarm,doors,bonnet,boot,objective);
		vInfo[car][vEngine] = false;
	}
	return true;
}
CMD:lights(playerid)
{
    if(GetPlayerVehicleID(playerid) == INVALID_VEHICLE_ID) return true;
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return true;
	if(vInfo[GetPlayerVehicleID(playerid)][vLights] == false)
	{
		GetVehicleParamsEx(GetPlayerVehicleID(playerid),engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(GetPlayerVehicleID(playerid),engine,VEHICLE_PARAMS_ON,alarm,doors,bonnet,boot,objective);
		vInfo[GetPlayerVehicleID(playerid)][vLights] = true;
	}
	else
	{
		GetVehicleParamsEx(GetPlayerVehicleID(playerid),engine,lights,alarm,doors,bonnet,boot,objective);
		SetVehicleParamsEx(GetPlayerVehicleID(playerid),engine,VEHICLE_PARAMS_OFF,alarm,doors,bonnet,boot,objective);
		vInfo[GetPlayerVehicleID(playerid)][vLights] = false;
	}
	return true;
}
CMD:tp(playerid)
{
	SetPlayerPos(playerid, 2871.977783, 781.022888, 801.177001);
	SetPlayerVirtualWorld(playerid, 5);
}
CMD:testmoney(playerid)
{
    IsAdmin(10);
	if(!AdminLogged[playerid]) return SendAdminInfo(playerid, "Aucilebelia admin avtorzaciis gavla");
	GiveServerMoney(playerid, 10000);
	return true;
}
CMD:spawn(playerid)
{
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
    SpawnPlayer(playerid);
}

/* Commands end */

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
