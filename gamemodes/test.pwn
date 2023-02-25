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
#define	SendErrorMessage(%0,%1)	SendClientMessage(%0, 0xFFFFFFFF, "{828282}* {EA4335} "%1)
#define SendInfoMessage(%0,%1)	SendClientMessage(%0, 0xFFFFFFFF, "{4582A1}* S.INFO{828282 }"%1)

new alcatrazbarrier[41];
new gatealcatrazstatus[41];
new arAlcatrazEnter[2];

/* new */
new MySQL:dbHandle;

enum player
{
	ID,
	pName[MAX_PLAYER_NAME],
	pPassword[32],
	pMail,
	pSex,
	pSkin,
	pLevel,
}
new PlayerInfo[MAX_PLAYERS][player];

enum dialogs
{
	dNone,
	dReg,
	dEmail,
	dSex,
	dFinishReg,
	dLogin,
}

main()
{
	print("\n----------------------------------");
	print(" Gamemode BY Chitava Production started ");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	arAlcatrazEnter[0] = CreateDynamicPickup(19135,1,3324.5034,2113.8389,7.4299,-1,-1);
	arAlcatrazEnter[1] = CreateDynamicPickup(19135,1,-1446.3629,1774.9664,3037.3174,99,99);

    alcatrazbarrier[0] = CreateDynamicObject(19870, 3223.331787, 2120.846436, 7.688662, 0.000000, 0.000000, 270.000000, -1, -1); //Центральные ворота Алькатраз №1
	alcatrazbarrier[1] = CreateDynamicObject(19870, 3223.612061, 2106.411621, 7.688662, 0.000000, 0.000000, 90.000000, -1, -1); //Центральные ворота Алькатраз №2
	alcatrazbarrier[2] = CreateDynamicObject(19858, 3220.926270, 2125.921387, 7.231689, 0.000000, 0.000000, 180.000000, -1, -1); //Возле центральных ворот, дверь в комнату охраны 1
	SetDynamicObjectMaterial(alcatrazbarrier[2], 0, 12805, "ce_loadbay", "sw_waredoor", 0);
	alcatrazbarrier[3] = CreateDynamicObject(19858, 3217.126465, 2101.346436, 7.211688, 0.000000, 0.000000, 0.000000, -1, -1); //Возле центральных ворот, дверь в комнату охраны 2
	SetDynamicObjectMaterial(alcatrazbarrier[3], 0, 12805, "ce_loadbay", "sw_waredoor", 0);
	alcatrazbarrier[4] = CreateDynamicObject(19302, 3223.483154, 2123.836670, 7.210523, 0.000007, 0.000000, 89.999977, -1, -1); //Решётка возле центральных ворот 1
	SetDynamicObjectMaterial(alcatrazbarrier[4], 0, 14842, "genintintpolicea", "copcell_bars", 0);
	alcatrazbarrier[5] = CreateDynamicObject(19302, 3223.483154, 2103.397949, 7.210523, 0.000014, 0.000000, 89.999954, -1, -1); //Решётка возле центральных ворот 2
	SetDynamicObjectMaterial(alcatrazbarrier[5], 0, 14842, "genintintpolicea", "copcell_bars", 0);
	alcatrazbarrier[6] = CreateDynamicObject(1495, -1449.805664, 1751.168213, 3036.314453, 0.000007, -0.000015, 179.999863, -1, -1); //Комната для адвокатов
	SetDynamicObjectMaterial(alcatrazbarrier[6], 1, 4003, "cityhall_tr_lan", "sl_griddyfence_sml", 0);
	alcatrazbarrier[7] = CreateDynamicObject(19302, -1464.882080, 1753.826538, 3037.554688, 0.000015, 0.000022, 89.999924, -1, -1);//Решётка возле столовой
	alcatrazbarrier[8] = CreateDynamicObject(19302, -1452.633179, 1767.157959, 3037.554688, 0.000000, 0.000000, 0.000000, -1, -1);//Рёшетка в центральном входе
	alcatrazbarrier[9] = CreateDynamicObject(19302, -1455.350098, 1753.826538, 3037.554688, 0.000007, 0.000022, 89.999947, -1, -1);//Вход куда-то в Альке.
	alcatrazbarrier[10] = CreateDynamicObject(1495, -1465.851563, 1751.163208, 3036.314453, 0.000007, -0.000030, 179.999771, -1, -1);//Столовая
	SetDynamicObjectMaterial(alcatrazbarrier[10], 1, 4003, "cityhall_tr_lan", "sl_griddyfence_sml", 0);//Столовая
	alcatrazbarrier[11] = CreateDynamicObject(1495, -1459.436035, 1751.168213, 3036.314453, 0.000007, -0.000022, 179.999817, -1, -1);//Вход к адвокатам
	SetDynamicObjectMaterial(alcatrazbarrier[11], 1, 4003, "cityhall_tr_lan", "sl_griddyfence_sml", 0);//Вход к адвокатам
	alcatrazbarrier[12] = CreateDynamicObject(1495, -1462.430542, 1757.599976, 3036.314453, 0.000007, -0.000029, -179.500320, -1, -1);
	SetDynamicObjectMaterial(alcatrazbarrier[12], 1, 4003, "cityhall_tr_lan", "sl_griddyfence_sml", 0);
	alcatrazbarrier[13] = CreateDynamicObject(19302, -1452.633179, 1782.953247, 3037.554688, 0.000000, 0.000007, 0.000000, -1, -1);//лифт
	alcatrazbarrier[14] = CreateDynamicObject(1495, -1457.137207, 1750.238159, 3036.314453, 0.000000, -0.000030, -90.000145, -1, -1);//У адвокатов в комнате.
	SetDynamicObjectMaterial(alcatrazbarrier[14], 1, 4003, "cityhall_tr_lan", "sl_griddyfence_sml", 0);
	alcatrazbarrier[15] = CreateDynamicObject(1495, -1455.2928, 1764.7581, 3036.3145, 0.000000, 0.000000, 90.000000, -1, -1);// Дверь ебаная - какая то
	SetDynamicObjectMaterial(alcatrazbarrier[15], 1, 4003, "cityhall_tr_lan", "sl_griddyfence_sml", 0);

	//КАМЕРЫ

	/*************************************************************************************************************************************************/

    alcatrazbarrier[16] = CreateDynamicObject(19302, 1386.558105, 970.759033, 3016.998779, 0.000000, 0.000096, 0.000000, -1, -1); //Камера 1 [1 этаж]
    alcatrazbarrier[17] = CreateDynamicObject(19302, 1381.483765, 970.759033, 3016.998779, 0.000000, 0.000091, 0.000000, -1, -1); //Камера 2 [1 этаж]
    alcatrazbarrier[18] = CreateDynamicObject(19302, 1376.421875, 970.759033, 3016.998779, 0.000000, 0.000097, 0.000000, -1, -1); //Камера 3 [1 этаж]
    alcatrazbarrier[19] = CreateDynamicObject(19302, 1371.348755, 970.759033, 3016.998779, 0.000000, 0.000067, 0.000000, -1, -1); //Камера 4 [1 этаж]
    alcatrazbarrier[20] = CreateDynamicObject(19302, 1366.307495, 970.759033, 3016.998779, 0.000000, 0.000067, 0.000000, -1, -1); // Камера 5 [1 этаж]
    alcatrazbarrier[21] = CreateDynamicObject(19302, 1361.266724, 970.759033, 3016.998779, 0.000000, 0.000068, 0.000000, -1, -1); // Камера 6 [1 этаж]
    alcatrazbarrier[22] = CreateDynamicObject(19302, 1356.224365, 970.759033, 3016.998779, 0.000000, 0.000075, 0.000000, -1, -1); // Камера 7 [1 этаж]

    /*************************************************************************************************************************************************/

    alcatrazbarrier[23] = CreateDynamicObject(19302, 1386.558105, 970.759033, 3020.672363, 0.000000, 0.000096, 0.000000, -1, -1); //Камера 1 [2 этаж]
    alcatrazbarrier[24] = CreateDynamicObject(19302, 1381.483765, 970.759033, 3020.672363, 0.000000, 0.000091, 0.000000, -1, -1); //Камера 2 [2 этаж]
    alcatrazbarrier[25] = CreateDynamicObject(19302, 1376.421875, 970.759033, 3020.672363, 0.000000, 0.000097, 0.000000, -1, -1); //Камера 3 [2 этаж]
    alcatrazbarrier[26] = CreateDynamicObject(19302, 1371.348755, 970.759033, 3020.672363, 0.000000, 0.000067, 0.000000, -1, -1); //Камера 4 [2 этаж]
    alcatrazbarrier[27] = CreateDynamicObject(19302, 1366.307495, 970.759033, 3020.672363, 0.000000, 0.000067, 0.000000, -1, -1); // Камера 5 [2 этаж]
    alcatrazbarrier[28] = CreateDynamicObject(19302, 1361.266724, 970.759033, 3020.672363, 0.000000, 0.000068, 0.000000, -1, -1); // Камера 6 [2 этаж]
    alcatrazbarrier[29] = CreateDynamicObject(19302, 1356.224365, 970.759033, 3020.672363, 0.000000, 0.000075, 0.000000, -1, -1); // Камера 7 [2 этаж]

    /*************************************************************************************************************************************************/

    alcatrazbarrier[30] = CreateDynamicObject(19302, 1386.558105, 970.759033, 3024.3257, 0.000000, 0.000096, 0.000000, -1, -1); //Камера 1 [3 этаж]
    alcatrazbarrier[31] = CreateDynamicObject(19302, 1381.483765, 970.759033, 3024.3257, 0.000000, 0.000091, 0.000000, -1, -1); //Камера 2 [3 этаж]
    alcatrazbarrier[32] = CreateDynamicObject(19302, 1376.421875, 970.759033, 3024.3257, 0.000000, 0.000097, 0.000000, -1, -1); //Камера 3 [3 этаж]
    alcatrazbarrier[33] = CreateDynamicObject(19302, 1371.348755, 970.759033, 3024.3257, 0.000000, 0.000067, 0.000000, -1, -1); //Камера 4 [3 этаж]
    alcatrazbarrier[34] = CreateDynamicObject(19302, 1366.307495, 970.759033, 3024.3257, 0.000000, 0.000067, 0.000000, -1, -1); // Камера 5 [3 этаж]
    alcatrazbarrier[35] = CreateDynamicObject(19302, 1361.266724, 970.759033, 3024.3257, 0.000000, 0.000068, 0.000000, -1, -1); // Камера 6 [3 этаж]
    alcatrazbarrier[36] = CreateDynamicObject(19302, 1356.224365, 970.759033, 3024.3257, 0.000000, 0.000075, 0.000000, -1, -1); // Камера 7 [3 этаж]

    /*************************************************************************************************************************************************/

    alcatrazbarrier[37] = CreateDynamicObject(19302, 1390.815674, 969.215637, 3016.998779, -0.000022, 0.000097, -89.999901, -1, -1); //Дверь охранников [1 этаж]
    alcatrazbarrier[38] = CreateDynamicObject(19302, 1390.815674, 969.215637, 3020.672363, -0.000022, 0.000097, -89.999901, -1, -1); //Дверь охранников [2 этаж]
    alcatrazbarrier[39] = CreateDynamicObject(19302, 1390.815674, 969.215637, 3024.325700, -0.000022, 0.000097, -89.999901, -1, -1); //Дверь охранников [3 этаж]
    alcatrazbarrier[40] = CreateDynamicObject(19302, 1353.715210, 961.285645, 3016.998779, -0.000044, 0.000096, -89.999832, -1, -1); //Дверь для выхода на улицу [1 этаж]
	MYSQL_CONNECT();
	#include "../source/NewAlcatraz"
	/* server settings */
	SendRconCommand("hostname NEW GAMEMODE BY Chitava Production");
	SendRconCommand("language Georgian");
	SendRconCommand("password !00");
	SetGameModeText("Mode V. 0.0.1 (BETA)");
	/*-----------------*/
	ShowPlayerMarkers(0);
	LimitPlayerMarkerRadius(50.0);
	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	SetNameTagDrawDistance(50.0);
	Streamer_TickRate(100);
	Streamer_VisibleItems(0,2500);
 	/*-----------------*/
	return 1;
}

stock MYSQL_CONNECT()
{
    dbHandle = mysql_connect("localhost", "root", "", "newdb");
	switch(mysql_errno())
	{
	    case 0: print("MYSQL warmatebit daukavshirda servers");
	    default: print("MYSQL ver daukavshirda servers");
	}
	mysql_log(ERROR | WARNING);
	mysql_set_charset("cp1251");
}

public OnGameModeExit()
{
	return 1;
}
CMD:settime(playerid, params[])
{
	SetWorldTime(params[0]);
}
CMD:gate(playerid, params[])
{
    if(GetAlcatrazBarrierID(playerid) == -1) return 1;

    if(GetPVarInt(playerid, "camopenalcatraz") > gettime()) return 1;
    SetPVarInt(playerid, "camopenalcatraz", gettime()+3);

    new mes[164];

    if(!GetPVarInt(playerid, "Alcatraz")) return PlayerPlaySound(playerid, 21001, 0.0, 0.0, 0.0);//Проверка на то охранник ли игрок который нажал на клавишу!
    if(GetAlcatrazBarrierID(playerid) == 0 || GetAlcatrazBarrierID(playerid) == 1)
    {
    	if(gatealcatrazstatus[GetAlcatrazBarrierID(playerid)])
		{
			gatealcatrazstatus[GetAlcatrazBarrierID(playerid)] = 0,CloseAlcatrazBarrierex(GetAlcatrazBarrierID(playerid));
			format(mes, sizeof(mes), "[Alcatraz]{FFFFFF} Cixis dacvam {ffffad}%s[%d]{FFFFFF} daketa mtavari karebi", PlayerInfo[playerid][pName], playerid);
			Security(0xFF0000FF, mes);
		}
        else
		{
	 		gatealcatrazstatus[GetAlcatrazBarrierID(playerid)] = 1, OpenAlcatrazBarrier(GetAlcatrazBarrierID(playerid));
			format(mes, sizeof(mes), "[Alcatraz]{FFFFFF} Cixis dacvam {ffffad}%s[%d]{FFFFFF} gaago mtavari karebi", PlayerInfo[playerid][pName], playerid);
			Security(0xFF0000FF, mes);
		}
        PlayerPlaySound(playerid, 41603, 0.0, 0.0, 0.0);
	}
	//Все автомотические двери
    if(GetAlcatrazBarrierID(playerid) == 2 || GetAlcatrazBarrierID(playerid) == 3 || GetAlcatrazBarrierID(playerid) == 4 || GetAlcatrazBarrierID(playerid) == 5 || GetAlcatrazBarrierID(playerid) == 6 || GetAlcatrazBarrierID(playerid) == 7
	|| GetAlcatrazBarrierID(playerid) == 8 || GetAlcatrazBarrierID(playerid) == 9 || GetAlcatrazBarrierID(playerid) == 10 || GetAlcatrazBarrierID(playerid) == 11 || GetAlcatrazBarrierID(playerid) == 12 || GetAlcatrazBarrierID(playerid) == 13
	|| GetAlcatrazBarrierID(playerid) == 14 || GetAlcatrazBarrierID(playerid) == 15 || GetAlcatrazBarrierID(playerid) == 37 || GetAlcatrazBarrierID(playerid) == 38 || GetAlcatrazBarrierID(playerid) == 39 || GetAlcatrazBarrierID(playerid) == 40)
	{
	    OpenAlcatrazBarrier(GetAlcatrazBarrierID(playerid));
        PlayerPlaySound(playerid, 41603, 0.0, 0.0, 0.0);
        SetTimerEx("CloseAlcatrazBarrierex", 3000, false, "d", GetAlcatrazBarrierID(playerid));
	}
	return 1;
}


CMD:t1(playerid)
{
	SetPlayerPos(playerid, 1390.714966, 968.055908, 3017.122803);
}

CMD:t2(playerid)
{
	SetPlayerPos(playerid, -1467.653564, 1750.897827, 3037.614746);
}

CMD:t3(playerid)
{
	SetPlayerPos(playerid, 3345.161377, 2110.913330, 27.155323);
}

CMD:t4(playerid)
{
	SetPlayerPos(playerid, 1737.988,-1391.600,3538.756);
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, PlayerInfo[playerid][pName], MAX_PLAYER_NAME);
	static const fmt_query[] = "SELECT `ID` FROM `users` WHERE `pName` = '%s'";
	new query[sizeof(fmt_query)+(-2+MAX_PLAYER_NAME)];
	format(query, sizeof(query), fmt_query, PlayerInfo[playerid][pName]);
	mysql_tquery(dbHandle, query, "CheckReg", "i", playerid);
	
	RemoveBuildingForPlayer(playerid, 4057, 1479.553955, -1693.140015, 19.577999, 0.250000);
	RemoveBuildingForPlayer(playerid, 4210, 1479.562012, -1631.453003, 12.078000, 0.250000);
	RemoveBuildingForPlayer(playerid, 713, 1457.937012, -1620.694946, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1258, 1445.006958, -1692.234009, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 712, 1445.812012, -1650.022949, 22.257000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1468.984009, -1704.640015, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 700, 1463.062012, -1701.569946, 13.726000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1231, 1479.694946, -1702.531006, 15.625000, 0.250000);
	RemoveBuildingForPlayer(playerid, 673, 1457.553955, -1697.288940, 12.398000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1468.984009, -1694.046021, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1231, 1479.381958, -1692.390015, 15.632000, 0.250000);
	RemoveBuildingForPlayer(playerid, 4186, 1479.553955, -1693.140015, 19.577999, 0.250000);
	RemoveBuildingForPlayer(playerid, 620, 1461.125000, -1687.562012, 11.835000, 0.250000);
	RemoveBuildingForPlayer(playerid, 700, 1463.062012, -1690.647949, 13.726000, 0.250000);
	RemoveBuildingForPlayer(playerid, 641, 1458.616943, -1684.131958, 11.101000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1457.272949, -1666.296021, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1468.984009, -1682.718018, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 712, 1471.406006, -1666.178955, 22.257000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1231, 1479.381958, -1682.312012, 15.632000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1458.256958, -1659.256958, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 712, 1449.850952, -1655.937012, 22.257000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1231, 1477.937012, -1652.725952, 15.632000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1479.609009, -1653.250000, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1457.350952, -1650.569946, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1454.421021, -1642.491943, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1467.850952, -1646.593018, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1472.897949, -1651.506958, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1465.937012, -1639.819946, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1231, 1466.468018, -1637.959961, 15.632000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1449.593018, -1635.046021, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1467.709961, -1632.890015, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1232, 1465.890015, -1629.975952, 15.531000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1472.663940, -1627.881958, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1479.468018, -1626.022949, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 3985, 1479.562012, -1631.453003, 12.078000, 0.250000);
	RemoveBuildingForPlayer(playerid, 4206, 1479.553955, -1639.609009, 13.648000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1232, 1465.834961, -1608.375000, 15.375000, 0.250000);
	RemoveBuildingForPlayer(playerid, 700, 1494.209961, -1694.437012, 13.726000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1488.765015, -1693.734009, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 620, 1496.975952, -1686.850952, 11.835000, 0.250000);
	RemoveBuildingForPlayer(playerid, 641, 1494.140015, -1689.234009, 11.101000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1488.765015, -1682.671021, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 712, 1480.609009, -1666.178955, 22.257000, 0.250000);
	RemoveBuildingForPlayer(playerid, 712, 1488.225952, -1666.178955, 22.257000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1486.406006, -1651.390015, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1491.366943, -1646.381958, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1493.131958, -1639.453003, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1486.178955, -1627.765015, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1280, 1491.218018, -1632.678955, 13.453000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1232, 1494.413940, -1629.975952, 15.531000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1286, 1504.750000, -1695.053955, 13.593000, 0.250000);
	RemoveBuildingForPlayer(playerid, 1285, 1504.750000, -1694.038940, 13.593000, 0.250000);
	RemoveBuildingForPlayer(playerid, 673, 1498.959961, -1684.609009, 12.398000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1504.163940, -1662.015015, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1504.718018, -1670.921021, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 620, 1503.187012, -1621.125000, 11.835000, 0.250000);
	RemoveBuildingForPlayer(playerid, 673, 1501.281006, -1624.578003, 12.398000, 0.250000);
	RemoveBuildingForPlayer(playerid, 673, 1498.359009, -1616.968018, 12.398000, 0.250000);
	RemoveBuildingForPlayer(playerid, 712, 1508.444946, -1668.741943, 22.257000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1505.694946, -1654.834961, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1508.515015, -1647.859009, 13.695000, 0.250000);
	RemoveBuildingForPlayer(playerid, 625, 1513.272949, -1642.491943, 13.695000, 0.250000);
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
    format(string, sizeof(string), "{4582A1}Mogesalmebit serverze - Chitava Production.\n\n\
	{4582A1}* {FFFFFF}Account ukve registrirebulia.\n\
	{4582A1}* {FFFFFF}Tqveni saxeli: %s\n\n\
	{828282}* Sheiyvanet tqveni paroli:", PlayerInfo[playerid][pName]);
	ShowPlayerDialog(playerid, dLogin, DIALOG_STYLE_PASSWORD, "{4582A1}Avtorizacia ", string, "Archeva", "Gamosvla");
}

stock ShowRegistration(playerid)
{
    new string[256];
	format(string,sizeof(string),"{4582A1}Mogesalmebit serverze - Chitava Production.\n\n\
	{FFFFFF}\nGtxovt, chawerot tqveni axali paroli:\n\n\
	{828282} * Paroli sigrdze unda iyos: 6-15 simbolomde.\n\
 	* Gamoiyenet cifrebi da asoebi.\n\
  	* Chven Girchevt Ar daayenot paroli, romelic ukve giyeniat sxvagan");
	ShowPlayerDialog(playerid, dReg, DIALOG_STYLE_INPUT, "{4582A1}Account Registracia -{FFFFFF} Paroli:", string, "Archeva", "Gamosvla");
}
stock ShowEmail(playerid)
{
	new string[256];
	format(string, sizeof(string), "{FFFFFF}\tGtxovt sheiyvanot tqveni moqmedi e-mail\n\n\
	{4582A1}* {828282}Tu tqven dakarget wvdoma accountan, shegedzlebat misi dabruneba\n\
	\n\t{4582A1}* {FFFFFF}Sheiyvanet tqveni moqmedi E-Mail");
	ShowPlayerDialog(playerid, dEmail, DIALOG_STYLE_INPUT, "{4582A1}Account Registracia -{FFFFFF} E-Mail:", string, "Archeva", "Gamosvla");
}


public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
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

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
    if(pickupid == arAlcatrazEnter[0])
	{
		SetPlayerPos(playerid,-1448.4562,1774.8718,3037.3174);
		SetPlayerFacingAngle(playerid, 89.8515);
		SetPlayerInterior(playerid, 99);
		SetPlayerVirtualWorld(playerid, 99);
	}
	else if(pickupid == arAlcatrazEnter[1])
	{
		SetPlayerPos(playerid,3322.0002,2113.8323,7.4299);
		SetPlayerFacingAngle(playerid, 92.0648);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
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
	    case dReg:
	    {
	        if(response)
	        {
	            if(!strlen(inputtext))
				{
			 		ShowRegistration(playerid), SendErrorMessage(playerid, "Parolis sheyvana aucilebelia");
				}
	            if(strlen(inputtext) < 8 || strlen(inputtext) > 32)
				{
					ShowRegistration(playerid);
				 	SendErrorMessage(playerid, "Parolis sigrdze unda iyos 8-dan 32 simbolomde");
				}
			 	new regex:rg_passwordcheck = regex_new("^[a-zA-Z0-9]{1,}$");
		        if(regex_check(inputtext,rg_passwordcheck))
		        {
		            strmid(PlayerInfo[playerid][pPassword], inputtext, 0, strlen(inputtext), 32);
		            ShowEmail(playerid);
				}
				else
				{
				    ShowRegistration(playerid);
				 	SendErrorMessage(playerid, "Paroli udna shedgebodes mxolod cifrebisa da latinuri simboloebisgan");
				}
				regex_delete(rg_passwordcheck);
	        }
	        else
	        {
				SendErrorMessage(playerid, "Rata gaxvidet serveridan daweret /q");
				return Kick(playerid);
	        }
	    }
	    case dEmail:
	    {
         	if(!strlen(inputtext))
      		{
                ShowEmail(playerid);
                return SendErrorMessage(playerid, "Aucilebelia sheiyvanet Email");
			}
			new regex:rg_mailcheck = regex_new("^[a-zA-Z0-9.-_]{1,43}@[a-zA-Z]{1,12}.[a-zA-Z]{1,8}$");
   			if(regex_check(inputtext,rg_mailcheck))
      		{
      		    strmid(PlayerInfo[playerid][pMail], inputtext, 0, strlen(inputtext), 64);
				ShowPlayerDialog(playerid, dSex, DIALOG_STYLE_MSGBOX, "{4582A1}Account Registracia -{FFFFFF} Sqesi",
						        "{FFFFFF}Airchiet tqveni personajis sqesi", "Kaci","Qali");
      		}
      		else
      		{
      		    ShowEmail(playerid);
                return SendErrorMessage(playerid, "Miutiet swori Email");
      		}
            regex_delete(rg_mailcheck);
	    }
	    case dSex:
	    {
            if(response)
			{
				PlayerInfo[playerid][pSex] = 1;
				PlayerInfo[playerid][pSkin] = 3;

			}
			else
			{
				PlayerInfo[playerid][pSex] = 2;
				PlayerInfo[playerid][pSkin] = 69;
			}
			ShowPlayerDialog(playerid, dFinishReg, DIALOG_STYLE_MSGBOX, "{4582A1}Account Registracia -{FFFFFF} Dasruleba",
			"{4582A1}* {828282}Darwmunebuli xart, rom infromacia miutitet sworad?", "Diax", "Tavidan");
	    }
	    case dFinishReg:
	    {
	        if(response)
	        {
				new strings[1200];
				mysql_format(dbHandle, strings, sizeof(strings), "INSERT INTO `users` (`pName`, `pPassword`, `pLevel`, `pMail`, `pSex`, `pSkin`) VALUES ('%e', '%e', '%d', '%e',  '%d', '%d')",
				PlayerInfo[playerid][pName], PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pMail], PlayerInfo[playerid][pSex], PlayerInfo[playerid][pSkin]);
				mysql_query(dbHandle, strings);
				PlayerInfo[playerid][pLevel] = 1;
			 	new str[128 + MAX_PLAYER_NAME - 4];
	    		format(str, sizeof(str), "UPDATE `users` SET `pLevel` = '%d' WHERE `pName` = '%s'", PlayerInfo[playerid][pLevel], PlayerInfo[playerid][pName]);
	   			mysql_query(dbHandle, str);
				SetSpawnInfo(playerid, 0, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
				TogglePlayerSpectating(playerid, 0);
				//SavePlayer(playerid);
				SpawnPlayer(playerid);
				SendInfoMessage(playerid, "Gilocavt, Registracia dasrulda");
	        }
	        else
	        {
	            ShowRegistration(playerid);
	        }
	    }
	}
	return 1;
}

CMD:givesecurity(playerid, params[])
{
	//if(!PlayerInfo[playerid][pAdmin]) return SendClientMessage(playerid, COLOR_WHITE, "{828282}* {EA4335}Ar xart administratori");
	if(sscanf(params, "d", params[0])) return SendClientMessage(playerid, 0xFFFFFFFF, "/givesecurity [ID player]");
	SetPVarInt(params[0], "Alcatraz", 1);
	SendClientMessage(params[0], 0xFFFFFFFF, "{EA4335}Adminma dagnishnat cixe alcatraz-is dacvad");
	SendClientMessage(playerid, 0xFFFFFFFF, "Tqven danishnet alcatrazis dacva");
	return 1;
}
CMD:get(playerid)
{
    SetPVarInt(playerid, "Alcatraz", 1);
}
stock GetAlcatrazBarrierID(playerid)
{
    if(IsPlayerInRangeOfPoint(playerid, 1.0, 3217.0310,2127.0720,6.9822)) return 0;// Центральные ворота 1
    if(IsPlayerInRangeOfPoint(playerid, 1.0, 3221.1860,2100.3718,7.0006)) return 1;// Центральные ворота 2

    if(IsPlayerInRangeOfPoint(playerid, 1.5, 3220.926270, 2125.921387, 7.231689)) return 2;// Дверь возле центральных ворот 1
    if(IsPlayerInRangeOfPoint(playerid, 1.5, 3217.126465, 2101.346436, 7.211688)) return 3;// Дверь возле центральных ворот 2

    if(IsPlayerInRangeOfPoint(playerid, 1.5, 3223.483154, 2123.836670, 7.210523)) return 4;//Решётка возле центральных ворот 1
    if(IsPlayerInRangeOfPoint(playerid, 1.5, 3223.483154, 2103.397949, 7.210523)) return 5;//Решётка возле центральных ворот 2

    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1450.6538,1750.9764,3037.3174)) return 6;//Вход Адвокатов

    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1464.882080, 1753.826538, 3037.554688)) return 7;//Столовая рядом решётка

    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1452.633179, 1767.157959, 3037.554688)) return 8;//Решётка центральный вход
    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1455.350098, 1753.826538, 3037.554688)) return 9;//Вход куда-то в Альке.

    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1465.851563, 1751.163208, 3036.314453)) return 10;//Вход в столовую
    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1459.436035, 1751.168213, 3036.314453)) return 11;//Вход к адвокатам

    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1462.430542, 1757.599976, 3036.314453)) return 12;//Вход в мед. алька

    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1452.633179, 1782.953247, 3037.554688)) return 13;//Дверь к лифту в Альке.

    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1457.137207, 1750.238159, 3036.314453)) return 14;//У адвокатов

    if(IsPlayerInRangeOfPoint(playerid, 1.5,-1455.2928, 1764.7581, 3036.3145)) return 15;//Дверь какая то ебаная

    if(IsPlayerInRangeOfPoint(playerid, 1.5, 1390.815674, 969.215637, 3016.998779)) return 37;//Дверь охранников [1 этаж]
    if(IsPlayerInRangeOfPoint(playerid, 1.5, 1390.815674, 969.215637, 3020.672363)) return 38;//Дверь охранников [2 этаж]
    if(IsPlayerInRangeOfPoint(playerid, 1.5, 1390.815674, 969.215637, 3024.325700)) return 39;//Дверь охранников [3 этаж]
    if(IsPlayerInRangeOfPoint(playerid, 1.5, 1353.715210, 961.285645, 3016.998779)) return 40;//Дверь для выхода на улицу [1 этаж]

	return -1;
}

stock OpenAlcatrazBarrier(id)
{
	switch(id)
	{//в открытом положений
	    case 0: MoveDynamicObject(alcatrazbarrier[id],3223.331787, 2120.846436, 4.2, 1.5, 0.000000, 0.000000, 270.000000);//Центральные ворота алькатраз 1
	    case 1: MoveDynamicObject(alcatrazbarrier[id],3223.612061, 2106.411621, 4.2, 1.5, 0.000000, 0.000000, 90.000000);//Центральные ворота алькатраз 2
	    case 2: MoveDynamicObject(alcatrazbarrier[id],3222.3901, 2125.8457, 7.2317, 1.5, 0.000000, 0.000000, 180.000000);//Дверь возле центральных ворот 1
	    case 3: MoveDynamicObject(alcatrazbarrier[id],3215.6956, 2101.3530, 7.2117, 1.5, 0.000000, 0.000000, 0.000000);//Дверь возле центральныъ ворот 2
 	   	case 4: MoveDynamicObject(alcatrazbarrier[id],3223.4390, 2122.3721, 7.2105, 1.5, 0.000007, 0.000000, 89.999977);//Решётка возле центральных ворот 1
	    case 5: MoveDynamicObject(alcatrazbarrier[id],3223.4929, 2104.7607, 7.2105, 1.5, 0.000000, 0.000000, 90.000000);//Решётка возле центральных ворот 2
	    case 6: MoveDynamicObject(alcatrazbarrier[id],-1448.4642, 1751.1801, 3036.3145, 1.5, 0.0000, 0.0000, 179.9999);//Дверь для входа Адвокату в его место
	    case 7: MoveDynamicObject(alcatrazbarrier[id],-1464.7943, 1755.4270, 3037.5547, 1.5, 0.0000, 0.0000, 89.9999);//Решётка возле столовой
		case 8: MoveDynamicObject(alcatrazbarrier[id],-1451.0850, 1767.0985, 3037.5547, 1.5, 0.0000, 0.0000, 0.0000);//Рёшетка в центральном входе
		case 9: MoveDynamicObject(alcatrazbarrier[id],-1455.2900, 1752.1863, 3037.5547, 1.5, 0.0000, 0.0000, 89.9999);//Вход куда-то в Альке.
		case 10: MoveDynamicObject(alcatrazbarrier[id],-1464.5543, 1751.1802, 3036.3145, 1.5, 0.0000, 0.0000, 179.9998);//Вход в столовую
		case 11: MoveDynamicObject(alcatrazbarrier[id],-1458.1346, 1751.1815, 3036.3145, 1.5, 0.000007, -0.000022, 179.999817);//Вход к адвокатам
		case 12: MoveDynamicObject(alcatrazbarrier[id],-1461.1691, 1757.6102, 3036.3145, 1.5, 0.0000, 0.0000, -179.5003);//Вход в мед. алька
		case 13: MoveDynamicObject(alcatrazbarrier[id],-1454.2544, 1782.9005, 3037.5547, 1.5, 0.0000, 0.0000, 0.0000);//Дверь к лифту в Альке.
		case 14: MoveDynamicObject(alcatrazbarrier[id],-1457.1516, 1750.2430, 3033.8145, 1.5, 0.0000, 0.0000, -90.0001);//У адвокатов
		case 15: MoveDynamicObject(alcatrazbarrier[id],-1455.3002, 1763.4556, 3036.3145, 1.5, 0.0000, 0.0000, 90.0000);//Дверь какая-то ебаная
		//......
		case 37: MoveDynamicObject(alcatrazbarrier[id],1390.8566, 970.6498, 3016.9988, 1.5, 0.0000, 0.0001, -89.9999);//Дверь охранников [1 этаж]
		case 38: MoveDynamicObject(alcatrazbarrier[id],1390.8566, 970.6498, 3020.672363, 1.5, 0.0000, 0.0001, -89.9999);//Дверь охранников [2 этаж]
		case 39: MoveDynamicObject(alcatrazbarrier[id],1390.8566, 970.6498, 3024.325700, 1.5, 0.0000, 0.0001, -89.9999);//Дверь охранников [3 этаж]
		case 40: MoveDynamicObject(alcatrazbarrier[id],1353.7469, 959.6853, 3016.9988, 1.5, 0.0000, 0.0001, -89.9998);//Дверь охранников [3 этаж]

  	}
	return 1;
}

forward CloseAlcatrazBarrierex(id);
public CloseAlcatrazBarrierex(id)
{
	switch(id)
	{//в закрытом положений
	    case 0: MoveDynamicObject(alcatrazbarrier[id],3223.331787, 2120.846436, 7.688662, 1.5, 0.000000, 0.000000, 270.000000);//Центральные ворота алькатраз 1
	    case 1: MoveDynamicObject(alcatrazbarrier[id],3223.612061, 2106.411621, 7.688662, 1.5, 0.000000, 0.000000, 90.000000);//Центральные ворота алькатраз 2
	    case 2: MoveDynamicObject(alcatrazbarrier[id],3220.926270, 2125.921387, 7.231689, 1.5, 0.000000, 0.000000, 180.000000);//Дверь возле центральных ворот 1
	    case 3: MoveDynamicObject(alcatrazbarrier[id],3217.126465, 2101.346436, 7.211688, 1.5, 0.000000, 0.000000, 0.000000);//Дверь возле центральныъ ворот 2
	   	case 4: MoveDynamicObject(alcatrazbarrier[id],3223.483154, 2123.836670, 7.210523, 1.5, 0.000007, 0.000000, 89.999977);//Решётка возле центральных ворот 1
	    case 5: MoveDynamicObject(alcatrazbarrier[id],3223.483154, 2103.397949, 7.210523, 1.5, 0.000000, 0.000000, 89.999954);//Решётка возле центральных ворот 2
	    case 6: MoveDynamicObject(alcatrazbarrier[id],-1449.805664, 1751.168213, 3036.314453, 1.5, 0.000007, -0.000015, 179.999863);//Дверь для входа Адвокату в его место
		case 7: MoveDynamicObject(alcatrazbarrier[id],-1464.882080, 1753.826538, 3037.554688, 1.5, 0.000015, 0.000022, 89.999924);//Решётка возле столовой
		case 8: MoveDynamicObject(alcatrazbarrier[id], -1452.633179, 1767.157959, 3037.554688, 1.5, 0.000000, 0.000000, 0.000000);//Рёшетка в центральном входе
		case 9: MoveDynamicObject(alcatrazbarrier[id], -1455.350098, 1753.826538, 3037.554688, 1.5, 0.0000, 0.0000, 89.9999);//Вход куда-то в Альке.
		case 10: MoveDynamicObject(alcatrazbarrier[id],-1465.851563, 1751.163208, 3036.314453, 1.5, 0.000007, -0.000030, 179.999771);//Вход в столовую
		case 11: MoveDynamicObject(alcatrazbarrier[id],-1459.436035, 1751.168213, 3036.314453, 1.5, 0.000007, -0.000022, 179.999817);//Вход к адвокатам
		case 12: MoveDynamicObject(alcatrazbarrier[id],-1462.430542, 1757.599976, 3036.314453, 1.5, 0.000007, -0.000029, -179.500320);//Вход в мед. алька
		case 13: MoveDynamicObject(alcatrazbarrier[id],-1452.633179, 1782.953247, 3037.554688, 1.5, 0.000000, 0.000007, 0.000000);//Дверь к лифту в Альке.
		case 14: MoveDynamicObject(alcatrazbarrier[id],-1457.137207, 1750.238159, 3036.314453, 1.5, 0.000000, -0.000030, -90.000145);//У адвокатов
		case 15: MoveDynamicObject(alcatrazbarrier[id],-1455.2928, 1764.7581, 3036.3145, 1.5, 0.0000, 0.0000, 90.0000);//Дверь какая-то ебаная
		//......
		case 37: MoveDynamicObject(alcatrazbarrier[id],1390.815674, 969.215637, 3016.998779, 1.5, -0.000022, 0.000097, -89.999901);//Дверь охранников [1 этаж]
		case 38: MoveDynamicObject(alcatrazbarrier[id],1390.815674, 969.215637, 3020.672363, 1.5, -0.000022, 0.000097, -89.999901);//Дверь охранников [2 этаж]
		case 39: MoveDynamicObject(alcatrazbarrier[id],1390.815674, 969.215637, 3024.325700, 1.5, -0.000022, 0.000097, -89.999901);//Дверь охранников [3 этаж]
		case 40: MoveDynamicObject(alcatrazbarrier[id],1353.715210, 961.285645, 3016.998779, 1.5, -0.000044, 0.000096, -89.999832);//Дверь охранников [3 этаж]
	}
	return 1;
}

stock Security(color,const string[])
{
    foreach(new i: Player)
    {
		if(IsPlayerConnected(i))
		{
			if(GetPVarInt(i, "Alcatraz") == 1) SendClientMessage(i, color, string);
		}
    }
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
