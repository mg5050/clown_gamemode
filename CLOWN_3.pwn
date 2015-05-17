#include <a_samp>
#include <zcmd>

#undef MAX_PLAYERS

// Bit ops
#define CeilDiv(%1,%2) 			(((%1) + (%2) - 1) / (%2)) // divide then round up
#define CellBitVal(%1)          (1 << ((%1) % cellbits)) // Value of a bit, taking into account cell position
#define BinaryCells(%1) 		(CeilDiv((%1), cellbits)) // How many cells are needed for %1 amount of binary elements

#define AccessBit(%1,%2) 		(_:%1[(%2) / cellbits]) // variable, bit number starting at 0
#define GetBoolBit(%1,%2) 		(AccessBit(%1, (%2)) &  (CellBitVal((%2))))// variable, bit number starting at 0
#define SetBoolBit(%1,%2) 		(AccessBit(%1, (%2)) |= (CellBitVal((%2))))
#define UnsetBoolBit(%1,%2) 	if(GetBoolBit(%1, (%2))) AccessBit(%1, (%2)) ^= CellBitVal((%2))

#define IsOPRC(%1) 		 		(GetBoolBit(OPRC_Status, (%1))) // Has player been checked
#define SetOPRC(%1) 		 	(SetBoolBit(OPRC_Status, (%1)))
#define UnsetOPRC(%1) 			UnsetBoolBit(OPRC_Status, (%1))
//

#define ABS(%1) 				((%1) < 0 ? (-%1) : (%1))
#define ALIGNMENT_CENTER 		(2) 			// Text draw alignment
#define ALTSYSMSG(%1,%2) 		(SCM(%1, COLOR_ALT_SYSMSG, %2))
#define ALTSYSMSG_ALL(%1) 		(SendClientMessageToAll(COLOR_ALT_SYSMSG, (%1)))
#define CC_RED 					(3)   			// Car color red
#define CC_WHITE                (1)
#define COLOR_ALT_SYSMSG        (COLOR_RED) 	// Orange
#define COLOR_BLACK 			(0x000000FF)
#define COLOR_BOT 				(0xDE00FFFF) 	// Purple
#define COLOR_CIV           	(0x2ADF00FF)	// Dark neon green
#define COLOR_CLOWN         	(COLOR_RED)
#define COLOR_CLOWN_INVISIBLE 	(0xFF000000)
#define COLOR_NACHO_YELLOW		(0xFFCC00FF)
#define COLOR_RED           	(0xFF0000FF)
#define COLOR_SOFT_BLUE         (0x008AFFFF)
#define COLOR_SYSMSG 			(COLOR_NACHO_YELLOW)
#define COLOR_WHITE             (0xFFFFFFFF)
#define DEF_STR 				(129) 			// Max input + 1 for null terminator
#define DELAY_SPAWN_VEH 		(3 * 60)		// Delay for spawn vehicles in seconds
#define INVALID_DIALOG 			(-1) 			// Hides dialog
#define INVALID_TIMER 			(-1)
#define KEY_PRESSED(%1) 		(((newkeys & (%1)) == (%1)) && ((oldkeys & (%1)) != (%1)))
#define MAX_INT_STR 			(11) 			// Max cells required to hold largest integer as string
#define MAX_NRGS 				(20) 			// Max Clown NRGs
#define MAX_PING                (500)
#define MAX_PLAYERS 			(50)            // Change as needed
#define MAX_SKINS				(300)
#define MAX_TURISMOS 			(10) 			// Max Clown Turismos
#define MID_GATE 				(969)           // Model id Clown spawn gate
#define MID_NRG		 			(522) 			// Model id NRG-900
#define MID_TURISMO 			(451)       	// Model id Turismo
#define MIN_ROUND_PLAYERS 		(2) 			// Minimum amount of players needed to start a round
#define MIN_TEAM_CLOWN_SIZE 	(0.25)			// Minimum percentage of players who are clowns
#define ONEMIN      			(60 * ONESEC)	// One minute in milliseconds
#define ONESEC 					(1000) 			// One second in milliseconds
#define OPRC_CAM_DISTANCE 		(10.0)
#define OPRC_CAM_INCREMENT 		(0.65)
#define OPRC_CAM_INTERVAL 		(20)
#define PING_KICK_INTERVAL      (20 * ONESEC)
#define ROUND_REST          	(10 * ONESEC) 	// Time between rounds
#define ROUND_REST_INITIAL 		(ROUND_REST) 	// Time before first round is started
#define ROUND_TIME          	(10 * ONEMIN)
#define Reset_pTimers(%1) 		for(new pTimersList:i = pTimersList:0; i < pTimersList; i++) pTimers[(%1)][i] = INVALID_TIMER // Change init. value of pTimers instead?
#define SCM(%1,%2,%3)           (SendClientMessage((%1), (%2), %3))
#define SELF_DESTRUCT_RADIUS 	(5.0)
#define SELF_DESTRUCT_TYPE 		(0) 			// 1 - flame, no damage
#define SKIN_CIV            	(CivSkins[random(sizeof(CivSkins))])
#define SKIN_CLOWN 				(264)
#define SYSMSG(%1,%2) 			(SCM((%1), COLOR_SYSMSG, (%2)))
#define SYSMSG_ALL(%1) 			(SendClientMessageToAll(COLOR_SYSMSG, (%1)))
#define TEAM_CIV            	(0)
#define TEAM_CLOWN          	(1)
#define VEHICLE_DECAY_RATE 		(5.0)        	// Amount of vehicle health decreased per second
#define VW_DEFAULT 				(0)				// Default virtual world
#define WEATHER_DEFAULT     	(WEATHER_FOG)
#define WEATHER_FOG 			(9) 			// Heavy fog
#define WELCOME_TIME 			(15 * ONESEC)   // Time Welcome message is shown
#define ZCMD:%1(%2) 			COMMAND:%1(%2)

#define BlankLine(%1) 			(SYSMSG((%1), " "))
#define CreateAllVehicles() 	CreateClownVehicles(); CreateCivVehicles()
#define DestroyAllVehicles() 	for(new i = 0; i < MAX_VEHICLES; i++) DestroyVehicle(i)
#define HidePlayerDialog(%1) 	(ShowPlayerDialog((%1), INVALID_DIALOG, 0, "", "", "", ""))
#define IsClownTeamReady(%1,%2) (floatdiv(float((%1)), float((%2))) >= MIN_TEAM_CLOWN_SIZE)// Parameters: # of Clowns, # of players
#define KillPlayer(%1) 			(SetPlayerHealth((%1), 0.0))
#define Kill_pTimers(%1) 		for(new pTimersList:i = pTimersList:0; i < pTimersList; i++) Kill_pTimer((%1), i) // playerid
#define byte 					(8)
#define cellbytes 				(cellbits / byte)// Bytes in a cell
#define forConnected(%1) 		for(new %1 = 0; %1 < MAX_PLAYERS; %1++) if(IsPlayerConnected(%1) && !IsPlayerNPC(%1))
#define forTeam(%1,%2) 			forConnected(%1) if(GetPlayerTeam(%1) == (%2)) // Variable, team
#define setstr(%1,%2) 			(memcpy((%1), (%2), 0, strlen((%2)) * cellbytes)) // Dest, source
#define strequal(%1,%2) 		(strcmpEx((%1), (%2)) == 0) // str1, str2, case sensitive

#define DEBUG_LEVEL 			(1)
/*
Debug levels:
0 - No debug, everything operational,
1 - no team balance, same round time, no vehicle lifespan
2 - no bots
3 - Completely debugged, no rounds
*/

/*
enum _:DialogIDs
{
};

enum pDims
{
	Float:Xpos,
	Float:Ypos,
	Float:Zpos,
	Float:Angle
};
*/

enum pTimersList
{
	WelcomeTimer
};

stock bool:RoundStatus = false;
stock RoundCount = 0;
stock pTimers[MAX_PLAYERS][pTimersList]; // all times for individual in one place for easy destructions
new Text:ClassInfo[2]; // Note: 2 can be replaced with "Teams" but it creates many tag mismatches
new Text:Welcome;
new	RoundEndTimer = INVALID_TIMER;
new	firstgate = INVALID_OBJECT_ID; // First north gate created in Clown spawn
new	lastgate = INVALID_OBJECT_ID; // Last north gate created in Clown spawn
new	bin:OPRC_Status[BinaryCells(MAX_PLAYERS)];
new	const CivSkins[18] = {10,22,26,32,33,35,39,68,130,134,137,179,185,195,230,239,259,274};

forward RoundBegin();
forward RoundEnd(const teamid);
forward VehicleLifespan();
forward RoundCountdown(const milliseconds);
forward PingKick();
forward OPRC_Cam(const Float:angle);

main()
{
	print("\n*************************");
	print("\nClown MAdNEss by Malice\n");
	print("*************************\n");
	
 	ClassInfo[TEAM_CIV] = \
	 TextDrawCreate(150.0, 198.7500, "~n~~g~Civilian Team:~n~~n~~w~Stay alive as long as possible by using teamwork, strategy, and superior firepower.~n~~n~\
	 ~n~~b~Weapons:~n~~n~~y~Desert Eagle~n~~r~Combat Shotgun~n~~b~Micro SMG~n~~g~M4~n~~p~Sniper Rifle~n~~w~Satchel Charges~n~");
 	TextDrawTextSize(ClassInfo[TEAM_CIV], 500.0, 150.0);
	TextDrawFont(ClassInfo[TEAM_CIV], 1);
 	TextDrawUseBox(ClassInfo[TEAM_CIV], true);
  	TextDrawBoxColor(ClassInfo[TEAM_CIV], 0x0000007F); // Semi-transparent
  	TextDrawLetterSize(ClassInfo[TEAM_CIV], 0.375, 0.95);
  	TextDrawAlignment (ClassInfo[TEAM_CIV], ALIGNMENT_CENTER);
  	TextDrawSetShadow(ClassInfo[TEAM_CIV], 0);
  	TextDrawSetOutline(ClassInfo[TEAM_CIV], 1);
	//TextDrawBackgroundColor(ClassInfo[TEAM_CIV], COLOR_BLACK);
	
	ClassInfo[TEAM_CLOWN] = \
	TextDrawCreate(150.0, 198.7500, "~n~~r~Clown Team:~n~~n~~w~Eliminate all Civilians using stealth, teamwork, and strategy. \
	Clowns are invisible on the Civilian map.~n~~n~~b~Weapons:~n~~n~~y~Chainsaw~n~~r~Grenades~n~~b~Fire Extinguisher~n~~g~Suicide Attack [Detonator]~n~~n~");
 	TextDrawTextSize(ClassInfo[TEAM_CLOWN], 500.0, 150.0);
 	TextDrawFont(ClassInfo[TEAM_CIV], 1);
    TextDrawUseBox(ClassInfo[TEAM_CLOWN], true);
    TextDrawBoxColor(ClassInfo[TEAM_CLOWN], 0x0000007F); // Semi-transparent
    TextDrawLetterSize(ClassInfo[TEAM_CLOWN], 0.375, 0.95);
    TextDrawAlignment (ClassInfo[TEAM_CLOWN], ALIGNMENT_CENTER);
   	TextDrawSetShadow(ClassInfo[TEAM_CLOWN], 0);
    TextDrawSetOutline(ClassInfo[TEAM_CLOWN], 1);
	//TextDrawBackgroundColor(ClassInfo[TEAM_CLOWN], COLOR_BLACK);

	Welcome = TextDrawCreate(425.0, 235.0, "~n~~y~CLOWN - Stealth and Survival~n~~n~~b~Welcome to the server!\
	~n~~n~~r~Rules:~n~~n~~w~No hacking or unfair mods.~n~C-Bug allowed.~n~~n~~g~Have fun!~n~");
	TextDrawAlignment (Welcome, ALIGNMENT_CENTER);
	TextDrawTextSize(Welcome, 300.0, 250.0);
	TextDrawFont(Welcome, 1);
	TextDrawLetterSize(Welcome, 0.375, 0.95);
 	TextDrawUseBox(Welcome, true);
    TextDrawBoxColor(Welcome, 0x0000007F); // Semi-transparent
}

public OnGameModeInit()
{
	SetGameModeText("ClownMAdNEss");
	UsePlayerPedAnims();
	EnableStuntBonusForAll(false);
	DisableInteriorEnterExits();
	AllowAdminTeleport(true);
	SetWorldTime(0);
	SetWeather(WEATHER_DEFAULT);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL); // Note: Redundant?
	
	// Pos is set to avoid spastic camera from changing camera position
	AddPlayerClassEx(TEAM_CIV, SKIN_CIV, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0); // Civ class
	AddPlayerClassEx(TEAM_CLOWN, SKIN_CLOWN, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0); // Clown class
	
	new count;
	
	// West wall
	count = CreateObjectArray(MID_GATE, 0.0, 2573.5, 2573.5, 8.75, -1707.0, -1635.0, 3.0, 1.0, 7.0, 0.0, 0.0, 90.0);
	// East wall
	count += CreateObjectArray(MID_GATE, 0.0, 2599.0, 2599.0, 8.75, -1707.0, -1635.0, 3.0, 1.0, 7.0, 0.0, 0.0, 90.0);
	// South wall
    count += CreateObjectArray(MID_GATE, 8.75, 2573.0, 2594.0, 0.0, -1707.25, -1707.25, 3.0, 1.0, 7.0, 0.0, 0.0, 0.0);
	// North wall
	CreateClownSpawnGate(firstgate, lastgate);
	
	printf("%d Gates created", count + ((lastgate - firstgate) + 1));
	
	CreateAllVehicles();
	
	#if DEBUG_LEVEL < 3
	SetTimer("RoundBegin", ROUND_REST_INITIAL, false);
	RoundCountdown(ROUND_REST_INITIAL);
	#endif
	#if DEBUG_LEVEL < 2
	//ConnectNPC("BOT_DFT_Driver", "DFT");
	#endif
	#if DEBUG_LEVEL == 0
	SetTimer("VehicleLifespan", ONESEC, true);
	//SetTimer("PingKick", PING_KICK_INTERVAL, true);
	#endif
	SetTimerEx("OPRC_Cam", OPRC_CAM_INTERVAL, false, "f", 0.0); // OPRC Spin camera
	
	return true;
}

public OnGameModeExit()
{
	return true;
}

public OPRC_Cam(const Float:angle)
{
	forConnected(i) if(IsOPRC(i)) // Only OPRC players
	{
		SetPlayerCameraPos
		(
			i,
			1544.5582 + OPRC_CAM_DISTANCE * floatsin(-angle, degrees),
			-1374.5245 + OPRC_CAM_DISTANCE * floatcos(-angle, degrees),
			335.0
		);
    	SetPlayerCameraLookAt(i, 1544.5582, -1374.5245, 330.0556);
	}
	if(angle + OPRC_CAM_INCREMENT >= 360.0)
	{
		SetTimerEx("OPRC_Cam", OPRC_CAM_INTERVAL, false, "f", (angle + OPRC_CAM_INCREMENT) - 360.0);
	}
	else
	{
		SetTimerEx("OPRC_Cam", OPRC_CAM_INTERVAL, false, "f", angle + OPRC_CAM_INCREMENT);
 	}
}

public OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return true;

	if(!IsOPRC(playerid)) // First time OPRC since death or join
	{
		SetPlayerPos(playerid, 1544.5582, -1374.5245, 330.0556);
		SetPlayerFacingAngle(playerid, 179.3475);
		SetPlayerCameraPos(playerid, 1550.3569, -1385.3124, 333.3828);
		SetPlayerCameraLookAt(playerid, 1544.5582, -1374.5245, 330.0556);
		SetOPRC(playerid);
	}
	
	switch(GetPlayerTeam(playerid))
	{
	    case TEAM_CIV:
	    {
	        TextDrawHideForPlayer(playerid, ClassInfo[TEAM_CLOWN]);
			TextDrawShowForPlayer(playerid, ClassInfo[TEAM_CIV]);
	    }
	    case TEAM_CLOWN:
	    {
	        TextDrawHideForPlayer(playerid, ClassInfo[TEAM_CIV]);
	        TextDrawShowForPlayer(playerid, ClassInfo[TEAM_CLOWN]);
	    }
	}
	
	return true;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return true;
	
	#if DEBUG_LEVEL == 0
	
	new
		clowns = 0,
		civs = 0;
	forConnected(i) // Count members of each team
	{
    	if(IsPlayerSpawned(i) && (i != playerid)) // Note: i != playerid prevents GetPState bug
    	{
 			if(GetPlayerTeam(i) == TEAM_CIV) civs++;
 			else if(GetPlayerTeam(i) == TEAM_CLOWN) clowns++;
			// else // Note: NO_TEAM players are ignored
 		}
	}
		
	if(GetPlayerTeam(playerid) == TEAM_CIV) // Player is attempting to play as civ
	{
	    // Can only spawn as Civ if round has not started or if there are more clowns than civs
		if(RoundStatus == true/* && !(clowns > civs && clowns > 0)*/) // Player is attempting to play as Civ while round is in progress
		{
		    //SYSMSG(playerid, "Unless the Clown team is full, you cannot spawn as a Civilian while the round is in progress.");
            SYSMSG(playerid, "You cannot spawn as a Civilian while the round is in progress.");
			return false;
		}
		else if(!IsClownTeamReady(clowns, clowns + civs)) // Player is attempting to play as Civ while Clown team is not ready
		{
			SYSMSG(playerid, "The Clown team still needs more players.");
			return false;
		}
	}
	// Player wants to play as Clown before round
	// If both teams negate the player a spawn, we have a problem
	// Clowns can't be more than civs
	// Civs can't be over 75% of server
	// We shouldn't use all players as total as some players will be AFK
	else if(RoundStatus == false && clowns >= civs && clowns > 0)
	{
		SYSMSG(playerid, "The Clown team is currently full.");
		return false;
	}
	
	#endif
	
	return true;
}

public OnPlayerSpawn(playerid)
{
    if(IsPlayerNPC(playerid)) return true;
    
    UnsetOPRC(playerid);
	
	if(GetPlayerTeam(playerid) == TEAM_CLOWN)
	{
	    TextDrawHideForPlayer(playerid, ClassInfo[TEAM_CLOWN]); // Hide class info TextDraw
	    //SetPlayerColor(playerid, COLOR_CLOWN);
	    forConnected(i) // Show all players on map in case player just played as civilian
	    {
	        if(IsPlayerSpawned(i))
	        {
				if(GetPlayerTeam(i) == TEAM_CLOWN)
				{
					SetPlayerMarkerForPlayer(playerid, i, COLOR_CLOWN); // Show Clowns to player
					SetPlayerMarkerForPlayer(i, playerid, COLOR_CLOWN); // Show PlayerMarker to other Clowns

					ShowPlayerNameTagForPlayer(playerid, i, true); // Show teammate nametags
					ShowPlayerNameTagForPlayer(i, playerid, true); // Show nametag to teammates
				}
				else // This includes unspawned players?
				{
					SetPlayerMarkerForPlayer(playerid, i, COLOR_CIV); // Show Civilians to player
					SetPlayerMarkerForPlayer(i, playerid, COLOR_CLOWN_INVISIBLE); // Hide your PlayerMarker to Civilians

					ShowPlayerNameTagForPlayer(playerid, i, true); // Show Civilian nametags
					ShowPlayerNameTagForPlayer(i, playerid, false); // Hide nametag to civilians
				}
			}
	    }
	    
	    // Positive offset
	    if(random(2) == 1) SetPlayerPos(playerid, 2585.4285 + float(random(10)), -1697.2355 + float(random(5)), 1.6406);
	    // Negative offset
	    else SetPlayerPos(playerid, 2585.4285 - float(random(5)), -1697.2355 - float(random(5)), 1.6406);
	    SetPlayerFacingAngle(playerid, 0.0);
    	GivePlayerWeapon(playerid, 9, 1); // Chainsaw
		GivePlayerWeapon(playerid, 16, 30); // Grenades
		GivePlayerWeapon(playerid, 42, 1000); // Fire Extinguisher, Limit to avoid possible abuse
		GivePlayerWeapon(playerid, 40, 1); // Detonator
		// Bug: GetPlayerWeaponData returns no weapon in any slot unless any weapon has been equipped
		SetPlayerArmedWeapon(playerid, 42); // Arm fire extinguisher
	    if(!RoundStatus) SYSMSG(playerid, "The round will begin shortly. Please wait.");
	}
	else // Player is civilian
	{
		TextDrawHideForPlayer(playerid, ClassInfo[TEAM_CIV]); // Hide class info TextDraw
		//SetPlayerColor(playerid, COLOR_CIV);
		forConnected(i) // Show all players on map in case player just played as civilian
	    {
	        if(IsPlayerSpawned(i))
	        {
				if(GetPlayerTeam(i) == TEAM_CLOWN)
				{
					SetPlayerMarkerForPlayer(playerid, i, COLOR_CLOWN_INVISIBLE); // Hide clowns
					SetPlayerMarkerForPlayer(i, playerid, COLOR_CIV); // Show me to Clowns
					
					ShowPlayerNameTagForPlayer(playerid, i, false); // Hide Clowns to me
					ShowPlayerNameTagForPlayer(i, playerid, true); // Show me to clowns
				}
				else
				{
					SetPlayerMarkerForPlayer(playerid, i, COLOR_CIV); // Show fellow civs
					SetPlayerMarkerForPlayer(i, playerid, COLOR_CIV); // Show to other civs
					
					ShowPlayerNameTagForPlayer(playerid, i, true); // Show teammates to me
					ShowPlayerNameTagForPlayer(i, playerid, true); // Show me to teammates
				}
			}
	    }
	    /*
	    new rand = random(sizeof(CivSpawns));
		SetPlayerPos(playerid, CivSpawns[rand][Xpos], CivSpawns[rand][Ypos], CivSpawns[rand][Zpos]);
		SetPlayerFacingAngle(playerid, CivSpawns[rand][Angle]);
		SetCameraBehindPlayer(playerid);
		*/
		SetPlayerSkin(playerid, SKIN_CIV); // Random CivSkins
  		// Positive offset
	    if(random(2) == 1) SetPlayerPos(playerid, 890.6274 + float(random(5)), -1222.9038 + float(random(5)), 16.9766);
	    // Negative offset
		else SetPlayerPos(playerid, 890.6274 - float(random(5)), -1222.9038 - float(random(5)), 16.9766);
        SetPlayerFacingAngle(playerid, 270.0953);
		/*
			Note: SetSpawnInfo would be a better alternative to this
			but it seems the team parameter is bugged and does not work.
			This is crucial to the anti-teamkill function and GetPlayerTeam.
		*/
  		GivePlayerWeapon(playerid, 24, cellmax); // Desert Eagle
		GivePlayerWeapon(playerid, 27, cellmax); // Combat Shotgun
		GivePlayerWeapon(playerid, 28, cellmax); // Micro SMG
		GivePlayerWeapon(playerid, 31, cellmax); // M4
		GivePlayerWeapon(playerid, 34, cellmax); // Sniper rifle
		GivePlayerWeapon(playerid, 39, 50); // Satchel charge
		GivePlayerWeapon(playerid, 40, 1); // Detonator
 		SetPlayerArmedWeapon(playerid, 24); // Arm deagle
 		if(!RoundStatus) SYSMSG(playerid, "Prepare for the onslaught of clowns.");
	}
	SetPlayerArmour(playerid, 100.0); // Give player armor
	SetCameraBehindPlayer(playerid);

	return true;
}

public OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid))
	{
	    SetPlayerColor(playerid, COLOR_BOT);
		return true;
	}
    
    Reset_pTimers(playerid);
    
    UnsetOPRC(playerid);

	new pname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, pname, sizeof(pname));
	
	if(!strequal(pname, "Malice"))
	{
	    //SendPlayerMessageToPlayer(playerid, 0, "Hello");
	    fclose(fopen("joinalert", io_write));
	}

	if((strcmpEx(pname, "BOT_", false, 4) == 0))
	{
		KickANDAnnounce(playerid, "Impersonating a bot");
	}
	
	SendDeathMessage(playerid, playerid, 200); // Connect icon
	SYSMSG(playerid, "Welcome to the server!");
	
	TextDrawShowForPlayer(playerid, Welcome);
	
	pTimers[playerid][WelcomeTimer] = SetTimerEx("TDHide", WELCOME_TIME, false, "ii", playerid, _:Welcome);

	return true;
}

forward TDHide(const playerid, const Text:text);
public TDHide(const playerid, const Text:text) TextDrawHideForPlayer(playerid, text);

public OnPlayerDisconnect(playerid, reason)
{
	if(reason != 2) SendDeathMessage(playerid, playerid, 201);
	// reasons = timeout, exit, kick
	
    if(IsPlayerNPC(playerid)) return true;
    
   	Kill_pTimers(playerid);
    
   	new
		clowns = 0,
		civs = 0;
	forConnected(i) // Count members of each team
	{
    	if(IsPlayerSpawned(i) && (i != playerid)) // Count minus player
    	{
 			if(GetPlayerTeam(i) == TEAM_CIV) civs++;
 			else if(GetPlayerTeam(i) == TEAM_CLOWN) clowns++;
			// else // Note: NO_TEAM players are ignored
 		}
	}

	if(RoundStatus == true)
	{
		if(GetPlayerTeam(playerid) == TEAM_CLOWN) // Clown has left
		{
			if(clowns == 0 && civs > 0) // Last Clown just left
		    {
				if(RoundEndTimer != INVALID_TIMER) // Note: Is this necessary?
				{
					KillTimer(RoundEndTimer); // Kill normal RoundEnd timer
					RoundEnd(TEAM_CIV); // Civs victorious
				}
			}
		}
		else // Civilian has left
		{
			/*
				Note: Make sure GetPlayerState will return the player is dead
				otherwise TeamAliveCount will be flawed
			*/
			if(civs == 0 && clowns > 0) // Last civ just left
		    {
				if(RoundEndTimer != INVALID_TIMER) // Note: Is this necessary?
				{
					KillTimer(RoundEndTimer); // Kill normal RoundEnd timer
					RoundEnd(TEAM_CLOWN); // Clowns victorious
				}
			}
		}
	}

	return true;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(IsPlayerNPC(playerid)) return true;

	if(GetPlayerTeam(playerid) == TEAM_CLOWN) // Clown has died
	{
	}
	else // Civilian has died
	{
		ForceClassSelection(playerid); // Player wont be able to choose civ again if round is in progress
		/*
			Note: Make sure GetPlayerState will return the player is dead
			otherwise TeamAliveCount will be flawed
		*/
		if(RoundStatus == true)
		{
			if(TeamAliveCount(TEAM_CIV) == 0) // Last civ just died
		    {
				if(RoundEndTimer != INVALID_TIMER) // Note: Is this necessary?
				{
					KillTimer(RoundEndTimer); // Kill normal RoundEnd timer
					RoundEnd(TEAM_CLOWN); // Clowns victorious
				}
			}
		}
	}
	
	SendDeathMessage(killerid, playerid, reason);

	return true;
}

public OnVehicleSpawn(vehicleid)
{
	return true;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(text[0] == '!')
	{
		new str[DEF_STR];
		GetPlayerName(playerid, str, sizeof(str));
		format(str, sizeof(str), "!%s: %s", str, text[1]);
		if(GetPlayerTeam(playerid) == TEAM_CIV)
		{
			forTeam(i, TEAM_CIV) SCM(i, COLOR_CIV, str);
		}
		else
		{
			forTeam(i, TEAM_CLOWN) SCM(i, COLOR_CLOWN, str);
		}
		
		return false;
	}
	
	return true;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return false;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(ispassenger == 0) // Entering as driver
	{
	    /*
	    if(vehicleid == VID_DFT && !IsPlayerNPC(playerid)) // player is attempting to jack DFT
	    {
	        SetVehicleParamsForPlayer(vehicleid, playerid, false, true);
		}
		*/
		// Is the player carjacking a teammate?
	    new driverid = GetVehicleDriver(vehicleid);
	    if(driverid != INVALID_PLAYER_ID && GetPlayerTeam(driverid) == GetPlayerTeam(playerid))
	    {
     		SetVehicleParamsForPlayer(vehicleid, playerid, false, true);
	    }
	    else // Player is not carjacking a teammate
	    {
	        SetVehicleParamsForPlayer(vehicleid, playerid, false, false); // In case the vehicle has been previously locked to the player
	    }
	}
	
	return true;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return true;
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

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
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
	/*
	new str[DEF_STR], Float:health;
	GetPlayerHealth(playerid, health);
	format(str, sizeof(str), "%f", health);
	SYSMSG(playerid,str);
	*/
	
	if(KEY_PRESSED(KEY_FIRE))
	{
	    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) // Note: Redundant?
	    {
	    	new
	    	    weapon,
	    	    ammo;
			GetPlayerWeaponData(playerid, 12, weapon, ammo);
			// Note: ammo for detonator can be negative even when it is really 1
			// Therefore we check for 0 only
			if(weapon != WEAPON_BOMB || ammo == 0) // Player does not have detonator, therefore he has used it
			{
			    printf("weapon %d ammo %d armedwep %d", weapon, ammo, GetPlayerWeapon(playerid));
    			if(GetPlayerTeam(playerid) == TEAM_CLOWN) // Clown has self detonated
				{
   					new
                	        Float:x,
                	        Float:y,
                	        Float:z;

					GetPlayerPos(playerid, x, y, z);
					KillPlayer(playerid); // Player has suicided
					CreateExplosion(x, y, z, SELF_DESTRUCT_TYPE, SELF_DESTRUCT_RADIUS);
				}
				else // Civ
				{
	   				GivePlayerWeapon(playerid, WEAPON_BOMB, 1);
			    	SetPlayerArmedWeapon(playerid, WEAPON_BOMB);
				}
			}

		}
	}
    
	return true;
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
	return true;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return true;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public RoundBegin()
{
	#if DEBUG_LEVEL == 0
	new
		clowns = 0,
		civs = 0;
	forConnected(i) // Count members of each team
	{
	    if(IsPlayerSpawned(i))
	    {
 			if(GetPlayerTeam(i) == TEAM_CIV) civs++;
 			else if(GetPlayerTeam(i) == TEAM_CLOWN) clowns++;
			// else // Note: NO_TEAM players are ignored
		}
	}
	
	// If not enough players
	if(civs + clowns < MIN_ROUND_PLAYERS) // Total amount of players has to be at least
	{
		SetTimer("RoundBegin", ROUND_REST, false); // Attempt to start round again in ROUND_REST
		SetTimerEx("RoundCountdown", 7 * ONESEC, false, "i", ROUND_REST - (7 * ONESEC)); // Show in 7 seconds
		GameTextForAll("~b~Round ~n~start ~n~failed", 2 * ONESEC, 4);
		// Server stays quiet until round can be started
		// We want to avoid spamming and annoying people who are waiting
		return false;
	}
	
	RoundEndTimer = SetTimerEx("RoundEnd", ROUND_TIME, false, "i", TEAM_CIV); // Note: TEAM_CIV wins if clowns don't succeed
	#else
    RoundEndTimer = SetTimerEx("RoundEnd", ROUND_TIME, false, "i", TEAM_CIV); // Note: TEAM_CIV wins if clowns don't succeed
    #endif
	
	RoundStatus = true;

	SYSMSG_ALL("The round has begun.");
 	GameTextForAll("~b~Round has started", 5000, 4);
    
    //ExplodeObjectRange(firstgate, lastgate); // Explode gate blocking clown spawn
    LiftObjectRange(firstgate, lastgate, 5.0, 1.0);

	return true;
}

public RoundEnd(const teamid) // Note: teamid of winning team
{
	RoundEndTimer = INVALID_TIMER;
    RoundStatus = false;
    
    SYSMSG_ALL("The round has ended.");
    
    if(teamid == TEAM_CIV) SYSMSG_ALL("Civilians Win!!!");
	else SYSMSG_ALL("Clowns Win!!!");

	forConnected(i)
	{
		SetPlayerCameraPos(i, 1550.3569, -1385.3124, 333.3828);
		SetPlayerCameraLookAt(i, 1544.5582, -1374.5245, 330.0556);
		
  		ForceClassSelection(i);
  		KillPlayer(i);
	}
    
    SetTimer("RoundBegin", ROUND_REST, false);
    RoundCountdown(ROUND_REST);
    //CreateClownSpawnGate(firstgate, lastgate); // Create gate at clown spawn again
    LiftObjectRange(firstgate, lastgate, -5.0, 1.0); // Lower gates
    
    DestroyAllVehicles();
    CreateAllVehicles();
    
	return true;
}

// Note: Each vehicle being driven by a Civ has a lifespan of a few minutes
// We don't want Civs constantly in vehicles
public VehicleLifespan()
{
	new vid, Float:vhealth;
	forConnected(i)
	{
	    vid = GetPlayerVehicleID(i);
	    if(GetPlayerTeam(i) == TEAM_CIV && vid > 0)
	    {
			GetVehicleHealth(vid, vhealth);
			// Note: Vehicle health below 250 means the vehicle is on fire
			if(vhealth >= 250.0) SetVehicleHealth(vid, vhealth - VEHICLE_DECAY_RATE);
	    }
	}

	return true;
}

//ZCMD callbacks
public OnPlayerCommandReceived(playerid, cmdtext[]) // before exec
{
	return true;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success) // after exec
{
	return true;
}

public PingKick() forConnected(i) if(GetPlayerPing(i) > MAX_PING) KickANDAnnounce(i, "Maximum ping exceeded.");

// Milliseconds countdown will last
public RoundCountdown(const milliseconds)
{
	// Round could have been cancelled due to insufficient players
	if(milliseconds < ONESEC/* && RoundStatus == false*/) return;
	else
	{
		new millistr[MAX_INT_STR + 28];
		format(millistr, sizeof(millistr), "~b~Attempting round start in:~n~~r~%d", milliseconds / ONESEC);
		GameTextForAll(millistr, 2 * ONESEC, 4);
		SetTimerEx("RoundCountdown", ONESEC, false, "i", milliseconds - ONESEC);
	}
}

/*
ZCMD:endround(playerid, params)
{
	if(!IsPlayerAdmin(playerid)) return false;
	
	if(RoundEndTimer != INVALID_TIMER)
	{
	    KillTimer(RoundEndTimer);
	    RoundEnd(TEAM_CIV);
	}
	
	return true;
}
*/

ZCMD:help(playerid, params)
{
    BlankLine(playerid);
	SYSMSG(playerid, "Civilian Gameplay: You must survive the entire round on one life.");
	SYSMSG(playerid, "Clown Gameplay: You must eliminate all Civilians. Dead Civilians become Clowns.");
	SYSMSG(playerid, "Commands: /kill | '!' for teamchat");
 	BlankLine(playerid);
	    
	return true;
}

ZCMD:kill(playerid, params)
{
	if(!IsPlayerSpawned(playerid)) return true;
	KillPlayer(playerid);
	
	return true;
}
// Players per team
// Note: Counts unspawned players in OPRC as well
stock TeamPlayerCount(const teamid)
{
	new count = 0;

	forTeam(i, teamid) count++;

	return count;
}

// Players spawned per team
stock TeamAliveCount(const teamid)
{
	new alive = 0;
	
	forTeam(i, teamid) if(IsPlayerSpawned(i)) alive++;
	
	return alive;
}

// Is this player spawned?
// Note: When is "PLAYER_STATE_SPAWNED" state used?
stock IsPlayerSpawned(const playerid)
{
	new pstate = GetPlayerState(playerid);
	
	if
	(
		(
			pstate == PLAYER_STATE_ONFOOT ||
			pstate == PLAYER_STATE_DRIVER ||
			pstate == PLAYER_STATE_PASSENGER ||
			pstate == PLAYER_STATE_SPAWNED
		)
		&& !IsOPRC(playerid)
	) return true;

	return false;
}

stock GetVehicleDriver(const vehicleid)
{
	new driverid = INVALID_PLAYER_ID;
	forConnected(i)
	{
	    // if(IsPlayerInAnyVehicle(i)) // Could be faster?
	    if(GetPlayerVehicleID(i) == vehicleid) return driverid; // Found
	}

	return driverid; // Not found
}

stock ExplodeObjectRange(const firstobject, const lastobject)
{
	new Float:x, Float:y, Float:z;
	for(new i = firstobject; i <= lastobject; i++)
	{
		GetObjectPos(i, x, y, z);
		CreateExplosion(x, y, z, 0, 0.0);
	    DestroyObject(i);
	}
}

stock LiftObjectRange(const firstobject, const lastobject, const Float:lift, const Float:speed)
{
	new
		Float:x,
		Float:y,
		Float:z;
	for(new i = firstobject; i <= lastobject; i++)
	{
		GetObjectPos(i, x, y, z);
		MoveObject(i, x, y, z + lift, speed);
	}
}

stock DestroyObjectRange(const firstobject, const lastobject)
{
	for(new i = firstobject; i <= lastobject; i++)
	{
	    DestroyObject(i);
	}

	return true;
}

stock CreateObjectArray(const objectid, Float:incx, Float:startx, Float:maxx, Float:incy, Float:starty, Float:maxy, Float:incz, Float:startz, Float:maxz, Float:rx, Float:ry, Float:rz)
{
	new
		Float:x = startx,
		Float:y = starty,
		Float:z = startz,
		count = 0;

	/*
		Note: When we set inc to 0 to denote no increase the function will loop perpetually
 		To avoid this we set it to 1.0 so eventually it will end
	*/
	if(incx == 0.0) incx = 1.0;
	if(incy == 0.0) incy = 1.0;
	if(incz == 0.0) incz = 1.0;

	while(x <= maxx)
	{
 		while(y <= maxy)
		{
			while(z <= maxz)
			{
				count++;
   				CreateObject(objectid, x, y, z, rx, ry, rz);
   				z += incz;
			}
			z = startz;
			y += incy;
		}
		y = starty;
		x += incx;
	}

	return count;
}

stock GetWeaponNameEx(const weaponid)
{
	new name[50];
	switch(weaponid)
	{
	    case 18: setstr("Molotov Cocktail", name);
	    case 44: setstr("Nightvision", name);
	    case 45: setstr("Thermal Goggles", name);
   	 	default: GetWeaponName(weaponid, name, sizeof(name));
	}

	return name;
}

//Sscanf by Y_Less

/*----------------------------------------------------------------------------*-
Function:
	sscanf
Params:
	string[] - String to extract parameters from.
	format[] - Parameter types to get.
	{Float,_}:... - Data return variables.
Return:
	0 - Successful, not 0 - fail.
Notes:
	A fail is either insufficient variables to store the data or insufficient
	data for the format string - excess data is disgarded.

	A string in the middle of the input data is extracted as a single word, a
	string at the end of the data collects all remaining text.

	The format codes are:

	c - A character.
	d, i - An integer.
	h, x - A hex number (e.g. a colour).
	f - A float.
	s - A string.
	z - An optional string.
	pX - An additional delimiter where X is another character.
	'' - Encloses a litteral string to locate.
	u - User, takes a name, part of a name or an id and returns the id if they're connected.

	Now has IsNumeric integrated into the code.

	Added additional delimiters in the form of all whitespace and an
	optioanlly specified one in the format string.
-*----------------------------------------------------------------------------*/

stock sscanf(string[], format[], {Float,_}:...)
{
	#if defined isnull
		if (isnull(string))
	#else
		if (string[0] == 0 || (string[0] == 1 && string[1] == 0))
	#endif
		{
			return format[0];
		}
	#pragma tabsize 4
	new
		formatPos = 0,
		stringPos = 0,
		paramPos = 2,
		paramCount = numargs(),
		delim = ' ';
	while (string[stringPos] && string[stringPos] <= ' ')
	{
		stringPos++;
	}
	while (paramPos < paramCount && string[stringPos])
	{
		switch (format[formatPos++])
		{
			case '\0':
			{
				return 0;
			}
			case 'i', 'd':
			{
				new
					neg = 1,
					num = 0,
					ch = string[stringPos];
				if (ch == '-')
				{
					neg = -1;
					ch = string[++stringPos];
				}
				do
				{
					stringPos++;
					if ('0' <= ch <= '9')
					{
						num = (num * 10) + (ch - '0');
					}
					else
					{
						return -1;
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num * neg);
			}
			case 'h', 'x':
			{
				new
					num = 0,
					ch = string[stringPos];
				do
				{
					stringPos++;
					switch (ch)
					{
						case 'x', 'X':
						{
							num = 0;
							continue;
						}
						case '0' .. '9':
						{
							num = (num << 4) | (ch - '0');
						}
						case 'a' .. 'f':
						{
							num = (num << 4) | (ch - ('a' - 10));
						}
						case 'A' .. 'F':
						{
							num = (num << 4) | (ch - ('A' - 10));
						}
						default:
						{
							return -1;
						}
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num);
			}
			case 'c':
			{
				setarg(paramPos, 0, string[stringPos++]);
			}
			case 'f':
			{
				setarg(paramPos, 0, _:floatstr(string[stringPos]));
			}
			case 'p':
			{
				delim = format[formatPos++];
				continue;
			}
			case '\'':
			{
				new
					end = formatPos - 1,
					ch;
				while ((ch = format[++end]) && ch != '\'') {}
				if (!ch)
				{
					return -1;
				}
				format[end] = '\0';
				if ((ch = strfind(string, format[formatPos], false, stringPos)) == -1)
				{
					if (format[end + 1])
					{
						return -1;
					}
					return 0;
				}
				format[end] = '\'';
				stringPos = ch + (end - formatPos);
				formatPos = end + 1;
			}
			case 'u':
			{
				new
					end = stringPos - 1,
					id = 0,
					bool:num = true,
					ch;
				while ((ch = string[++end]) && ch != delim)
				{
					if (num)
					{
						if ('0' <= ch <= '9')
						{
							id = (id * 10) + (ch - '0');
						}
						else
						{
							num = false;
						}
					}
				}
				if (num && IsPlayerConnected(id))
				{
					setarg(paramPos, 0, id);
				}
				else
				{
					#if !defined foreach
						#define foreach(%1,%2) for (new %2 = 0; %2 < MAX_PLAYERS; %2++) if (IsPlayerConnected(%2))
						#define __SSCANF_FOREACH__
					#endif
					string[end] = '\0';
					num = false;
					new
						name[MAX_PLAYER_NAME];
					id = end - stringPos;
					foreach (Player, playerid)
					{
						GetPlayerName(playerid, name, sizeof (name));
						if (!strcmp(name, string[stringPos], true, id))
						{
							setarg(paramPos, 0, playerid);
							num = true;
							break;
						}
					}
					if (!num)
					{
						setarg(paramPos, 0, INVALID_PLAYER_ID);
					}
					string[end] = ch;
					#if defined __SSCANF_FOREACH__
						#undef foreach
						#undef __SSCANF_FOREACH__
					#endif
				}
				stringPos = end;
			}
			case 's', 'z':
			{
				new
					i = 0,
					ch;
				if (format[formatPos])
				{
					while ((ch = string[stringPos++]) && ch != delim)
					{
						setarg(paramPos, i++, ch);
					}
					if (!i)
					{
						return -1;
					}
				}
				else
				{
					while ((ch = string[stringPos++]))
					{
						setarg(paramPos, i++, ch);
					}
				}
				stringPos--;
				setarg(paramPos, i, '\0');
			}
			default:
			{
				continue;
			}
		}
		while (string[stringPos] && string[stringPos] != delim && string[stringPos] > ' ')
		{
			stringPos++;
		}
		while (string[stringPos] && (string[stringPos] == delim || string[stringPos] <= ' '))
		{
			stringPos++;
		}
		paramPos++;
	}
	do
	{
		if ((delim = format[formatPos++]) > ' ')
		{
			if (delim == '\'')
			{
				while ((delim = format[formatPos++]) && delim != '\'') {}
			}
			else if (delim != 'z')
			{
				return delim;
			}
		}
	}
	while (delim > ' ');
	return 0;
}

// Creates clown spawn gate, returns the first and last gate
// Note: If preferred firstgate and lastgate can be set internally
stock CreateClownSpawnGate(&fgate, &lgate)
{
	// North wall
	new
		Float:z = 1.0,
		Float:x = 2573.0,
 		count = 0;
	while(z <= 7.0)
	{
 		while(x <= 2594.0)
		{
 			count++;
   			lgate = CreateObject(MID_GATE, x, -1628.5, z, 0.0, 0.0, 0.0);
			x += 8.75;
		}
		x = 2573.0;
		z += 3.0;
	}

	fgate = lgate - (count - 1); // Example: lastobject = 10, ncount = 5, objects 6, 7, 8, 9, 10 = 5 objects

	return true;
}

// Created by Y_Less
// Note: Function has been modified
stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;

	GetPlayerPos(playerid, x, y, a);

	if(GetPlayerVehicleID(playerid)) GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	else GetPlayerFacingAngle(playerid, a);

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

stock GetXYofCircle(&Float:x, &Float:y, Float:angle, Float:distance)
{
	x += distance * floatsin(-angle, degrees);
	y += distance * floatcos(-angle, degrees);
}

//Made by Y_Less
stock strcmpEx(const string1[], const string2[], bool:ignorecase=false, length=cellmax)
{
	if (string1[0])
	{
		if (string2[0]) return strcmp(string1, string2, ignorecase, length);
		else return 1; // Positive as st1 is greater (strcmp spec).
	}
	else
	{
		if (string2[0]) return -1; // Negative as str2 is greater.
		else return 0; // The strings are the same (empty).
	}
}

stock KickANDAnnounce(const playerid, const reason[])
{
	new str[DEF_STR];
    GetPlayerName(playerid, str, sizeof(str));
	format(str, sizeof(str), "%s has been kicked. Reason: %s", str, reason);
	ALTSYSMSG_ALL(str);
	TogglePlayerControllable(playerid, false);
	Kick(playerid);
}

stock BanANDAnnounce(const playerid, const reason[])
{
	new str[DEF_STR];
	GetPlayerName(playerid, str, sizeof(str));
	format(str, sizeof(str), "%s has been banned. Reason: %s", str, reason);
	ALTSYSMSG_ALL(str);
	TogglePlayerControllable(playerid, false);
	BanEx(playerid, reason);
}

stock GetPlayerCount()
{
	new count;
	forConnected(i) count++;
	return count;
}

stock ShowPlayerDialogEx(const playerid, const /*DialogIDs:*/dialogid)
{
	switch(dialogid)
	{
	}
}

stock Kill_pTimer(const playerid, const pTimersList:timerid)
{
	if(pTimers[playerid][timerid] != INVALID_TIMER)
	{
	  	KillTimer(pTimers[playerid][timerid]);
    	pTimers[playerid][timerid] = INVALID_TIMER;
 	}
}

stock CreateClownVehicles()
{
	// Create Turismo array of vehicles at Clown spawn
	new
		Float:x = 2578.7581,
		Float:y = -1685.5419,
		count = 0;
	while(y < -1677.7263)
	{
		while(x < 2590.6064 && count < MAX_NRGS)
		{
		    count++;
		    AddStaticVehicleEx(MID_NRG, x, y, 1.7876, 0.0, CC_RED, CC_RED, DELAY_SPAWN_VEH);
		    x += 1.25;
		}
		x = 2578.7581;
		y += 2.75;
	}
	printf("%d NRGs created", count);

	// Create Turismo array of vehicles at Clown spawn
	count = 0;
	y = -1670.0;
	while(y < -1637.4866)
	{
		while(x < 2590.6064 && count < MAX_TURISMOS)
		{
		    count++;
		    AddStaticVehicleEx(MID_TURISMO, x, y, 3.0, 0.0, CC_RED, CC_RED, DELAY_SPAWN_VEH);
		    x += 4.0;
		}
		x = 2578.7581;
		y += 6.0;
	}
	printf("%d Turismos created", count);
}

stock CreateCivVehicles()
{
	AddStaticVehicleEx(578,934.6259,-1216.7593,17.4085,270.0873,1,1, DELAY_SPAWN_VEH); // DFT1
	AddStaticVehicleEx(578,934.6105,-1221.3265,17.4200,269.1041,1,1, DELAY_SPAWN_VEH); // DFT2
	AddStaticVehicleEx(578,934.6273,-1226.1890,17.4259,268.6809,1,1, DELAY_SPAWN_VEH); // DFT3
}

stock GetPIDFromName(const pname[])
{
	new name[MAX_PLAYER_NAME];
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			GetPlayerName(i, name, sizeof(name));
			if(strequal(name, pname)) return i;
		}
	}
	return INVALID_PLAYER_ID;
}
