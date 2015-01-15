/*
	Dynamic Town Invasion Mission by Vampire
*/
private ["_canTown","_nearPlyr","_grpCnt","_housePos","_sqdPos","_msg","_alert","_winMsg","_crate","_wait"];

if (!isNil "VEMFTownInvaded") exitWith {
	// Town Already Under Occupation
};

VEMFTownInvaded = true;

diag_log text format ["[VEMF]: Running Dynamic Town Invasion Mission."];

// Find A Town to Invade
while {true} do {
	_canTown = call VEMFFindTown;
	_nearPlyr = {isPlayer _x} count ((_canTown select 1) nearEntities[["Epoch_Male_F", "Epoch_Female_F"], 800]) > 0;
	
	if (!_nearPlyr) exitWith {
		// No Players Near Else Loop Again
	};
	
	uiSleep 30;
};

// Group Count
_grpCnt = 3;

// We Found a Town with No Players. Let's Invade.
// Format: [POS, HouseCount]
_housePos = [(_canTown select 1), _grpCnt] call VEMFHousePositions;

_sqdPos = [];
{
	// 4 Units to a Squad. One Squad Leader.
	if (!(count _x <= 4)) then {
		_x resize 4;
		_sqdPos = _sqdPos + _x;
	} else {
		_sqdPos = _sqdPos + _x;
	};
} forEach _housePos;


// Now we have Unit Positions, We Announce the Mission and Wait
_msg = format ["We have spotted hostile fireteams in %1! We'll give you some supplies if you can liberate the town.", (_canTown select 0)];
_alert = [_msg] call VEMFBroadcast;

if (!_alert) exitWith {
	// No Players have a Radio Equipped. Maybe we can try later?
	diag_log text format ["[VEMF]: DynTownInv: Mission Ended for No Active Radios."];
	VEMFTownInvaded = nil;
};

// Usage: COORDS, Radius
_wait = [(_canTown select 1),1000] call VEMFNearWait;

if (!_wait) exitWith {
	diag_log text format ["[VEMF]: DynTownInv: Mission Ended for Timeout."];
	VEMFTownInvaded = nil;
};

// Player is Near, so Spawn the Units
[(_canTown select 1),_sqdPos,false,1,"VEMFDynInv"] ExecVM VEMFSpawnAI;

waitUntil{!isNil "VEMFDynInv"};

// Wait for Mission Completion
[(_canTown select 1),"VEMFDynInv"] call VEMFWaitMissComp;

// Rewards
if (!(isNil "VEMFDynInvKiller")) then {
	_winMsg = format ["%1 has been cleared! You can find your reward at the town center.", (_canTown select 0)];
	VEMFChatMsg = _winMsg;
	(owner (vehicle VEMFDynInvKiller)) publicVariableClient "VEMFChatMsg";
	VEMFDynKiller = nil;
	
	_crate = createVehicle ["Box_IND_AmmoVeh_F",(_canTown select 1),[],0,"CAN_COLLIDE"];
	_crate setObjectTextureGlobal [0, "#(argb,8,8,3)color(0,0,0,0.8)"];
	_crate setObjectTextureGlobal [1, "#(argb,8,8,3)color(0.82,0.42,0.02,0.3)"];
	_crate setVariable ["VEMFScenery", true];
	_crate setPos ((_canTown select 1) findEmptyPosition [0,25,(typeOf _crate)]);
	[_crate] call VEMFLoadLoot;
	diag_log text format ["[VEMF]: DynTownInv: Crate Spawned At: %1 / Grid: %2", (getPosATL _crate), mapGridPosition (getPosATL _crate)];
};

VEMFDynInv = nil;
VEMFTownInvaded = nil;