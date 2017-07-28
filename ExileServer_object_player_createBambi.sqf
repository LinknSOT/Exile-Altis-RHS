/**
 * ExileServer_object_player_createBambi
 *
 * Exile Mod
 * www.exilemod.com
 * © 2015 Exile Mod Team
 *
 * This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/.
 */
private["_sessionID","_requestingPlayer","_spawnLocationMarkerName","_thugToCheck","_HaloSpawnCheck","_bambiPlayer","_accountData","_direction","_position","_spawnAreaPosition","_spawnAreaRadius","_clanID","_clanData","_clanGroup","_player","_devFriendlyMode","_devs","_parachuteNetID","_spawnType","_parachuteObject"];
_sessionID = _this select 0;
_requestingPlayer = _this select 1;
_spawnLocationMarkerName = _this select 2;
_bambiPlayer = _this select 3;
_accountData = _this select 4;
_direction = random 360;
if ((count ExileSpawnZoneMarkerPositions) isEqualTo 0) then
{
    _position = call ExileClient_util_world_findCoastPosition;
    if ((toLower worldName) isEqualTo "namalsk") then
    {
        while {(_position distance2D [76.4239, 107.141, 0]) < 100} do
        {
            _position = call ExileClient_util_world_findCoastPosition;
        };
    };
}
else
{
    _spawnAreaPosition = getMarkerPos _spawnLocationMarkerName;
    _spawnAreaRadius = getNumber(configFile >> "CfgSettings" >> "BambiSettings" >> "spawnZoneRadius");
    _position = [_spawnAreaPosition, _spawnAreaRadius] call ExileClient_util_math_getRandomPositionInCircle;
    while {surfaceIsWater _position} do
    {
        _position = [_spawnAreaPosition, _spawnAreaRadius] call ExileClient_util_math_getRandomPositionInCircle;
    };
};
_name = name _requestingPlayer;
_clanID = (_accountData select 3);
if !((typeName _clanID) isEqualTo "SCALAR") then
{
    _clanID = -1;
    _clanData = [];
}
else
{
    _clanData = missionNamespace getVariable [format ["ExileServer_clan_%1",_clanID],[]];
    if(isNull (_clanData select 5))then
    {
        _clanGroup = createGroup independent;
        _clanData set [5,_clanGroup];
        _clanGroup setGroupIdGlobal [_clanData select 0];
        missionNameSpace setVariable [format ["ExileServer_clan_%1",_clanID],_clanData];
    }
    else
    {
        _clanGroup = (_clanData select 5);
    };
    [_player] joinSilent _clanGroup;
};
_bambiPlayer setPosATL [_position select 0,_position select 1,0];
_bambiPlayer disableAI "FSM";
_bambiPlayer disableAI "MOVE";
_bambiPlayer disableAI "AUTOTARGET";
_bambiPlayer disableAI "TARGET";
_bambiPlayer disableAI "CHECKVISIBLE";
_bambiPlayer setDir _direction;
_bambiPlayer setName _name;
_bambiPlayer setVariable ["ExileMoney", 0, true];
_bambiPlayer setVariable ["ExileScore", (_accountData select 0)];
_bambiPlayer setVariable ["ExileKills", (_accountData select 1)];
_bambiPlayer setVariable ["ExileDeaths", (_accountData select 2)];
_bambiPlayer setVariable ["ExileClanID", _clanID];
_bambiPlayer setVariable ["ExileClanData", _clanData];
_bambiPlayer setVariable ["ExileHunger", 100];
_bambiPlayer setVariable ["ExileThirst", 100];
_bambiPlayer setVariable ["ExileTemperature", 37];
_bambiPlayer setVariable ["ExileWetness", 0];
_bambiPlayer setVariable ["ExileAlcohol", 0];
_bambiPlayer setVariable ["ExileName", _name];
_bambiPlayer setVariable ["ExileOwnerUID", getPlayerUID _requestingPlayer];
_bambiPlayer setVariable ["ExileIsBambi", true];
_bambiPlayer setVariable ["ExileXM8IsOnline", false, true];
_bambiPlayer setVariable ["ExileLocker", (_accountData select 4), true];
_devFriendlyMode = getNumber (configFile >> "CfgSettings" >> "ServerSettings" >> "devFriendyMode");
if (_devFriendlyMode isEqualTo 1) then
{
    _devs = getArray (configFile >> "CfgSettings" >> "ServerSettings" >> "devs");
    {
        if ((getPlayerUID _requestingPlayer) isEqualTo (_x select 0))exitWith
        {
            if((name _requestingPlayer) isEqualTo (_x select 1))then
            {
                _bambiPlayer setVariable ["ExileMoney", 500000, true];
                _bambiPlayer setVariable ["ExileScore", 100000];
            };
        };
    }
    forEach _devs;
};
_parachuteNetID = "";

_thugToCheck = _sessionID call ExileServer_system_session_getPlayerObject;
_HaloSpawnCheck = _thugToCheck getVariable ["playerWantsHaloSpawn", 0];

if (_HaloSpawnCheck isEqualTo 1) then
{
    _position set [2, getNumber(configFile >> "CfgSettings" >> "BambiSettings" >> "parachuteDropHeight")];
    if ((getNumber(configFile >> "CfgSettings" >> "BambiSettings" >> "haloJump")) isEqualTo 1) then
    {
        _bambiPlayer addBackpackGlobal "B_Parachute";
        _bambiPlayer setPosATL _position;
        _spawnType = 2;
    }
    else
    {
        _parachuteObject = createVehicle ["Steerable_Parachute_F", _position, [], 0, "CAN_COLLIDE"];
        _parachuteObject setDir _direction;
        _parachuteObject setPosATL _position;
        _parachuteObject enableSimulationGlobal true;
        _parachuteNetID = netId _parachuteObject;
        _spawnType = 1;
    };
}
else
{
 _spawnType = 1;
};

_score = (_accountData select 0);
if((getPlayerUID _requestingPlayer) in
  [
 "76561197964720994", //name
 "76561198062880086", // Tombstone
 "76561198065542168", // Jartz
 "76561198133936962" // Wrice
 ]) then {
     clearWeaponCargo _bambiPlayer; // clears items
     clearMagazineCargo _bambiPlayer; // clears items
     _bambiPlayer forceAddUniform "U_B_FullGhillie_ard"; // adds uniforms
     _bambiPlayer addVest "V_PlateCarrier2_rgr";
     _bambiPlayer addWeapon "Exile_Item_XM8";
     _bambiPlayer addWeapon "ItemCompass";
     _bambiPlayer addWeapon "ItemMap";
     _bambiPlayer addWeapon "ItemRadio";
     _bambiPlayer addWeapon "ItemGPS";
     _bambiPlayer addWeapon "Rangefinder";
     _bambiPlayer addItem "NVGoggles_INDEP";
     _bambiPlayer assignItem "NVGoggles_INDEP";
     _bambiPlayer addBackpack "B_TacticalPack_blk";
     _bambiPlayer addWeapon "srifle_EBR_F";
     _bambiPlayer addPrimaryWeaponItem "bipod_01_F_blk";
	 _bambiPlayer addPrimaryWeaponItem "optic_SOS";
     _bambiPlayer addMagazines ["20Rnd_762x51_Mag", 5];
     _bambiPlayer addItemToVest "Exile_Item_CanOpener";
     _bambiPlayer addItemToVest "Exile_Item_Vishpirin";
     _bambiPlayer addItemToVest "HandGrenade";
     _bambiPlayer addItemToBackpack "Exile_Item_DuctTape";	 
     _bambiPlayer addItemToBackpack "Exile_Item_PlasticBottleFreshWater";
     _bambiPlayer addItemToBackpack "Exile_Item_PlasticBottleFreshWater";
     _bambiPlayer addItemToBackpack "Exile_Item_EMRE";
     _bambiPlayer addItemToBackpack "Exile_Item_EMRE";							
} else {
    if ((getPlayerUID _requestingPlayer) in
    [
    "****user uid****", //name
    "****user uid****", //name
    "****user uid****"  //name
   
    ]) then {
    clearWeaponCargo _bambiPlayer; // clears items
    clearMagazineCargo _bambiPlayer; // clears items
    _bambiPlayer forceAddUniform "Exile_Uniform_Woodland"; // adds uniforms
    _bambiPlayer addVest "V_PlateCarrier2_rgr";
    _bambiPlayer addWeapon "Exile_Item_XM8";
    _bambiPlayer addWeapon "ItemCompass";
    _bambiPlayer addWeapon "ItemMap";
    _bambiPlayer addWeapon "ItemRadio";
    _bambiPlayer addWeapon "ItemGPS";
    _bambiPlayer addWeapon "Rangefinder";
    _bambiPlayer addItem "NVGoggles_INDEP";
    _bambiPlayer assignItem "NVGoggles_INDEP";
    _bambiPlayer addBackpack "B_AssaultPack_Kerry";
    _bambiPlayer addPrimaryWeaponItem "rhsusf_acc_eotech_552";
    _bambiPlayer addItemToVest "Exile_Item_CanOpener";
	_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
    _bambiPlayer addPrimaryWeaponItem "rhsusf_acc_nt4_black";
    _bambiPlayer addItemToVest  "Exile_Item_Vishpirin";
    _bambiPlayer addItemToBackpack "Exile_Item_PlasticBottleCoffee";
    _bambiPlayer addItemToBackpack "Exile_Item_EMRE";
} else {
    if ((getPlayerUID _requestingPlayer) in
    [
    "****user uid****",  //name
    "****user uid****", //name
    "****user uid****"  //name

    ]) then {
    clearWeaponCargo _bambiPlayer; // clears items
    clearMagazineCargo _bambiPlayer; // clears items
    _bambiPlayer addVest "V_BandollierB_blk";
    _bambiPlayer addWeapon "Exile_Item_XM8";
    _bambiPlayer addWeapon "ItemCompass";
    _bambiPlayer addWeapon "ItemMap";
    _bambiPlayer addWeapon "ItemRadio";
    _bambiPlayer addWeapon "ItemGPS";
    _bambiPlayer addWeapon "Rangefinder";
    _bambiPlayer addItem "NVGoggles_INDEP";
    _bambiPlayer assignItem "NVGoggles_INDEP";
    _bambiPlayer addPrimaryWeaponItem "bipod_01_F_snd";
    _bambiPlayer addItemToVest "Exile_Item_CanOpener";
	_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
    _bambiPlayer addItemToUniform "Exile_Item_GloriousKnakworst";
    _bambiPlayer addItemToUniform "Exile_Item_GloriousKnakworst";
    _bambiPlayer addItemToBackpack  "Exile_Item_Vishpirin";
    _bambiPlayer addItemToBackpack "Exile_Item_Bandage";
    _bambiPlayer addItemToBackpack "Exile_Item_PlasticBottleCoffee";
    _bambiPlayer addItemToBackpack "Exile_Item_PlasticBottleCoffee";
} else {
        if(_score > 0 && _score < 9999) then {
		clearWeaponCargo _bambiPlayer;
		clearMagazineCargo _bambiPlayer;
		_bambiPlayer addWeapon "Exile_Item_XM8";
		_bambiPlayer addWeapon "ItemMap";
		_bambiPlayer addWeapon "ItemRadio";
		_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
		_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
	} else {
		if(_score > 10000 && _score < 19999) then {
		clearWeaponCargo _bambiPlayer;
		clearMagazineCargo _bambiPlayer;
		hint "Scrounge loadout attached";
		_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
		_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
		_bambiPlayer addHeadgear "H_Cap_usblack";  				
		_bambiPlayer addWeapon 'Exile_Item_XM8';
		_bambiPlayer addWeapon "ItemCompass";
		_bambiPlayer addWeapon "ItemMap";
		_bambiPlayer addWeapon "ItemRadio";				
		_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
		_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
		_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
		_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
		} else {
			if(_score > 20000 && _score < 39999) then {
			clearWeaponCargo _bambiPlayer;
			clearMagazineCargo _bambiPlayer;
			hint "Advanced Scrounge respect loadout attached";
			_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
			_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
			_bambiPlayer addHeadgear "H_Cap_tan";  				
			_bambiPlayer addWeapon 'Exile_Item_XM8';
			_bambiPlayer addWeapon "ItemCompass";
			_bambiPlayer addWeapon "ItemMap";
			_bambiPlayer addWeapon "ItemRadio";						
			_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
			_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
			_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
			_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
			_bambiPlayer addItemToUniform "Exile_Item_Bandage";		
            _bambiPlayer addWeapon 'Exile_Weapon_Makarov';										
			_bambiPlayer addMagazines ["Exile_Magazine_8Rnd_9x18", 2];					
                } else {
                    if(_score > 40000 && _score < 59999) then {
                        clearWeaponCargo _bambiPlayer;
                        clearMagazineCargo _bambiPlayer;
                        hint "Master Scrounge respect loadout attached";
                        _bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
                        _bambiPlayer addVest "V_BandollierB_blk";
						_bambiPlayer addBackpack "Tiger_Backpack_Compact ";						
						_bambiPlayer addHeadgear "H_Cap_oli";  										
						_bambiPlayer addWeapon 'Exile_Item_XM8';
						_bambiPlayer addWeapon "ItemCompass";
						_bambiPlayer addWeapon "ItemMap";
						_bambiPlayer addWeapon "ItemRadio";
						_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
						_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
						_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
						_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
						_bambiPlayer addItemToUniform "Exile_Item_Bandage";						
						_bambiPlayer addWeapon 'Exile_Weapon_Makarov';										
						_bambiPlayer addMagazines ["Exile_Magazine_8Rnd_9x18", 2];					
                    } else {
                        if(_score > 60000 && _score < 79999) then {
                            clearWeaponCargo _bambiPlayer;
                            clearMagazineCargo _bambiPlayer;
                            hint "Junior Scavenger respect loadout attached";
                            _bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
							_bambiPlayer addVest "V_BandollierB_blk";
							_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
							_bambiPlayer addHeadgear "H_Cap_gry";  								
							_bambiPlayer addWeapon 'Exile_Item_XM8';
							_bambiPlayer addWeapon "ItemCompass";
							_bambiPlayer addWeapon "ItemMap";
							_bambiPlayer addWeapon "ItemRadio";
							_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
							_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
							_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
							_bambiPlayer addItemToUniform "Exile_Item_DuctTape";												
							_bambiPlayer addItemToVest "Exile_Item_Vishpirin";													
							_bambiPlayer addWeapon 'hgun_Rook40_F';										
							_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
							_bambiPlayer addWeapon 'SMG_05_F';										
							_bambiPlayer addMagazines ["30Rnd_9x21_Mag_SMG_02", 2];							
						} else {
							if(_score > 80000 && _score < 99999) then {
								clearWeaponCargo _bambiPlayer;
								clearMagazineCargo _bambiPlayer;
								hint "Scavenger respect loadout attached";
								_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
								_bambiPlayer addVest "V_BandollierB_oli";
								_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
								_bambiPlayer addHeadgear "H_Bandanna_sand";
								_bambiPlayer addWeapon 'Exile_Item_XM8';
								_bambiPlayer addWeapon "ItemCompass";
								_bambiPlayer addWeapon "ItemMap";
								_bambiPlayer addWeapon "ItemRadio";
								_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
								_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
								_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
								_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
								_bambiPlayer addItemToVest "Exile_Item_Vishpirin";													
								_bambiPlayer addWeapon 'hgun_Rook40_F';										
								_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
								_bambiPlayer addWeapon 'SMG_02_F';										
								_bambiPlayer addMagazines ["30Rnd_9x21_Mag_SMG_02", 2];
							} else {
								if(_score > 100000 && _score < 119999) then {
									clearWeaponCargo _bambiPlayer;
									clearMagazineCargo _bambiPlayer;
									hint "Advanced Scavenger respect loadout attached";
									_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
									_bambiPlayer addVest "V_HarnessO_brn";
									_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
									_bambiPlayer addHeadgear "H_Bandanna_cbr";
									_bambiPlayer addWeapon 'Exile_Item_XM8';
									_bambiPlayer addWeapon "ItemCompass";
									_bambiPlayer addWeapon "ItemMap";
									_bambiPlayer addWeapon "ItemRadio";
									_bambiPlayer addWeapon "Binocular";									
									_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
									_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
									_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
									_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
									_bambiPlayer addItemToVest "Exile_Item_Vishpirin";													
									_bambiPlayer addWeapon 'hgun_Rook40_F';										
									_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
									_bambiPlayer addWeapon 'SMG_02_F';										
									_bambiPlayer addMagazines ["30Rnd_9x21_Mag_SMG_02", 3];
								} else {
									if(_score > 120000 && _score < 139999) then {
										clearWeaponCargo _bambiPlayer;
										clearMagazineCargo _bambiPlayer;
										hint "Master Scavenger respect loadout attached";
										_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
										_bambiPlayer addVest "V_HarnessO_brn";
										_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
										_bambiPlayer addHeadgear "H_Bandanna_camo";
										_bambiPlayer addWeapon 'Exile_Item_XM8';
										_bambiPlayer addWeapon "ItemCompass";
										_bambiPlayer addWeapon "ItemMap";
										_bambiPlayer addWeapon "ItemRadio";
										_bambiPlayer addWeapon "Binocular";									
										_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
										_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
										_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
										_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
										_bambiPlayer addItemToVest "Exile_Item_Vishpirin";													
										_bambiPlayer addWeapon 'hgun_Rook40_F';										
										_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
										_bambiPlayer addWeapon 'SMG_01_F';				
										_bambiPlayer addMagazines ["30Rnd_45ACP_Mag_SMG_01", 2];
									} else {
										if(_score > 140000 && _score < 159999) then {
											clearWeaponCargo _bambiPlayer;
											clearMagazineCargo _bambiPlayer;
											hint "Junior Hunter respect loadout attached";
											_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
											_bambiPlayer addVest "V_HarnessO_brn";
											_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
											_bambiPlayer addHeadgear "H_Booniehat_oli";
											_bambiPlayer addWeapon 'Exile_Item_XM8';
											_bambiPlayer addWeapon "ItemCompass";
											_bambiPlayer addWeapon "ItemMap";
											_bambiPlayer addWeapon "ItemGPS";											
											_bambiPlayer addWeapon "ItemRadio";
											_bambiPlayer addWeapon "Binocular";									
											_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
											_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
											_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
											_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
											_bambiPlayer addItemToVest "Exile_Item_Vishpirin";													
											_bambiPlayer addWeapon 'hgun_Rook40_F';										
											_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
											_bambiPlayer addWeapon 'hlc_rifle_ak74';					
											_bambiPlayer addMagazines ["hlc_30Rnd_545x39_B_AK", 2];					
										} else {
											if(_score > 160000 && _score < 179999) then {
												clearWeaponCargo _bambiPlayer;
												clearMagazineCargo _bambiPlayer;
												hint "Hunter respect loadout attached";
												_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
												_bambiPlayer addVest "V_HarnessO_brn";
												_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
												_bambiPlayer addHeadgear "H_Booniehat_tan";
												_bambiPlayer addWeapon 'Exile_Item_XM8';
												_bambiPlayer addWeapon "ItemCompass";
												_bambiPlayer addWeapon "ItemMap";
												_bambiPlayer addWeapon "ItemGPS";											
												_bambiPlayer addWeapon "ItemRadio";
												_bambiPlayer addWeapon "Binocular";									
												_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
												_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
												_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
												_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
												_bambiPlayer addItemToVest "Exile_Item_InstaDoc";													
												_bambiPlayer addWeapon 'hgun_Rook40_F';										
												_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
												_bambiPlayer addWeapon 'hlc_rifle_ak74';					
												_bambiPlayer addMagazines ["hlc_30Rnd_545x39_B_AK", 2];												
											} else {
												if(_score > 180000 && _score < 199999) then {
													clearWeaponCargo _bambiPlayer;
													clearMagazineCargo _bambiPlayer;
													hint "Advanced Hunter respect loadout attached";
													_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
													_bambiPlayer addVest "V_HarnessO_brn";
													_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
													_bambiPlayer addHeadgear "H_Booniehat_khk";
													_bambiPlayer addWeapon 'Exile_Item_XM8';
													_bambiPlayer addWeapon "ItemCompass";
													_bambiPlayer addWeapon "ItemMap";
													_bambiPlayer addWeapon "ItemGPS";											
													_bambiPlayer addWeapon "ItemRadio";
													_bambiPlayer addWeapon "Binocular";									
													_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
													_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
													_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
													_bambiPlayer addItemToUniform "Exile_Item_DuctTape";	
													_bambiPlayer addItemToVest "Exile_Item_InstaDoc";													
													_bambiPlayer addWeapon 'hgun_Rook40_F';										
													_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
													_bambiPlayer addWeapon 'hlc_rifle_ak74';					
													_bambiPlayer addMagazines ["hlc_30Rnd_545x39_B_AK", 2];											
												} else {
													if(_score > 200000 && _score < 219999) then {
														clearWeaponCargo _bambiPlayer;
														clearMagazineCargo _bambiPlayer;
														hint "Master Hunter respect loadout attached";
														_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
														_bambiPlayer addVest "V_HarnessO_brn";
														_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
														_bambiPlayer addHeadgear "H_Booniehat_dgtl";
														_bambiPlayer addWeapon 'Exile_Item_XM8';
														_bambiPlayer addWeapon "ItemCompass";
														_bambiPlayer addWeapon "ItemMap";
														_bambiPlayer addWeapon "ItemGPS";											
														_bambiPlayer addWeapon "ItemRadio";
														_bambiPlayer addWeapon "Binocular";									
														_bambiPlayer addWeapon "NVGoggles_INDEP";									
														_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
														_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
														_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
														_bambiPlayer addItemToUniform "Exile_Item_DuctTape";	
														_bambiPlayer addItemToVest "Exile_Item_InstaDoc";													
														_bambiPlayer addWeapon 'hgun_Rook40_F';										
														_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
														_bambiPlayer addWeapon 'arifle_AK107';					
														_bambiPlayer addMagazines ["30Rnd_545x39_AK", 2];							
													} else {
														if(_score > 220000 && _score < 239999) then {
															clearWeaponCargo _bambiPlayer;
															clearMagazineCargo _bambiPlayer;
															hint "Junior Ranger respect loadout attached";
															_bambiPlayer forceAddUniform "U_B_CTRG_2";
															_bambiPlayer addVest "V_HarnessO_brn";
															_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
															_bambiPlayer addHeadgear "H_HelmetB_light_black";
															_bambiPlayer addWeapon 'Exile_Item_XM8';
															_bambiPlayer addWeapon "ItemCompass";
															_bambiPlayer addWeapon "ItemMap";
															_bambiPlayer addWeapon "ItemGPS";											
															_bambiPlayer addWeapon "ItemRadio";
															_bambiPlayer addWeapon "Binocular";									
															_bambiPlayer addWeapon "NVGoggles_INDEP";									
															_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
															_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
															_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
															_bambiPlayer addItemToUniform "Exile_Item_DuctTape";	
															_bambiPlayer addItemToVest "Exile_Item_InstaDoc";													
															_bambiPlayer addWeapon 'hgun_Rook40_F';										
															_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
															_bambiPlayer addWeapon 'arifle_MX_Black_F';														
															_bambiPlayer addMagazines ["30Rnd_65x39_caseless_mag", 2];												
														} else {
															if(_score > 240000 && _score < 259999) then {
																clearWeaponCargo _bambiPlayer;
																clearMagazineCargo _bambiPlayer;
																hint "Ranger respect loadout attached";
																_bambiPlayer forceAddUniform "U_B_CTRG_1";
																_bambiPlayer addVest "V_HarnessO_brn";
																_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
																_bambiPlayer addHeadgear "H_HelmetB_light_black";
																_bambiPlayer addWeapon 'Exile_Item_XM8';
																_bambiPlayer addWeapon "ItemCompass";
																_bambiPlayer addWeapon "ItemMap";
																_bambiPlayer addWeapon "ItemGPS";											
																_bambiPlayer addWeapon "ItemRadio";
																_bambiPlayer addWeapon "Binocular";									
																_bambiPlayer addWeapon "NVGoggles_INDEP";									
																_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
																_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
																_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
																_bambiPlayer addItemToUniform "Exile_Item_DuctTape";	
																_bambiPlayer addItemToVest "Exile_Item_InstaDoc";													
																_bambiPlayer addWeapon 'hgun_Rook40_F';										
																_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
																_bambiPlayer addWeapon 'arifle_MX_Black_F';														
																_bambiPlayer addMagazines ["30Rnd_65x39_caseless_mag", 2];												
															} else {
																if(_score > 260000 && _score < 279999) then {
																	clearWeaponCargo _bambiPlayer;
																	clearMagazineCargo _bambiPlayer;
																	hint "Advanced Ranger respect loadout attached";
																	_bambiPlayer forceAddUniform "U_B_CTRG_3";
																	_bambiPlayer addVest "V_HarnessO_brn";
																	_bambiPlayer addBackpack "B_TacticalPack_rgr";
																	_bambiPlayer addHeadgear "H_HelmetB_light_sand";
																	_bambiPlayer addWeapon 'Exile_Item_XM8';
																	_bambiPlayer addWeapon "ItemCompass";
																	_bambiPlayer addWeapon "ItemMap";
																	_bambiPlayer addWeapon "ItemGPS";											
																	_bambiPlayer addWeapon "ItemRadio";
																	_bambiPlayer addWeapon "Binocular";									
																	_bambiPlayer addWeapon "NVGoggles_INDEP";									
																	_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
																	_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
																	_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
																	_bambiPlayer addItemToUniform "Exile_Item_DuctTape";												
																	_bambiPlayer addItemToVest "Exile_Item_InstaDoc";													
																	_bambiPlayer addWeapon 'hgun_Rook40_F';										
																	_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
																	_bambiPlayer addWeapon 'arifle_MX_Black_F';													
																	_bambiPlayer addMagazines ["30Rnd_65x39_caseless_mag", 2];															
																} else {
																	if(_score > 280000 && _score < 299999) then {
																		clearWeaponCargo _bambiPlayer;
																		clearMagazineCargo _bambiPlayer;
																		hint "Master Ranger respect loadout attached";
																		_bambiPlayer forceAddUniform "U_B_CombatUniform_mcam";
																		_bambiPlayer addVest "V_HarnessO_brn";
																		_bambiPlayer addBackpack "B_TacticalPack_rgr";
																		_bambiPlayer addHeadgear "H_HelmetB_light_grass";
																		_bambiPlayer addWeapon 'Exile_Item_XM8';
																		_bambiPlayer addWeapon "ItemCompass";
																		_bambiPlayer addWeapon "ItemMap";
																		_bambiPlayer addWeapon "ItemGPS";											
																		_bambiPlayer addWeapon "ItemRadio";
																		_bambiPlayer addWeapon "Binocular";									
																		_bambiPlayer addWeapon "NVGoggles_INDEP";									
																		_bambiPlayer addItemToUniform "Exile_Item_CanOpener";
																		_bambiPlayer addItemToUniform "Exile_Item_BBQSandwich_Cooked";
																		_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleFreshWater";
																		_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
																		_bambiPlayer addItemToVest "Exile_Item_InstaDoc";													
																		_bambiPlayer addWeapon 'hgun_Rook40_F';										
																		_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
																		_bambiPlayer addWeapon 'arifle_MX_Black_F';															
																		_bambiPlayer addMagazines ["30Rnd_65x39_caseless_mag", 2];																						
																	} else {
																		if(_score > 300000 && _score < 319999) then {
																			clearWeaponCargo _bambiPlayer;
																			clearMagazineCargo _bambiPlayer;
																			hint "Junior Mercenary respect loadout attached";
																			_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
																			_bambiPlayer addVest "V_HarnessO_brn";
																			_bambiPlayer addBackpack "B_Kitbag_rgr";
																			_bambiPlayer addHeadgear "H_HelmetB_snakeskin";
																			_bambiPlayer addWeapon 'Exile_Item_XM8';
																			_bambiPlayer addWeapon "ItemCompass";
																			_bambiPlayer addWeapon "ItemMap";
																			_bambiPlayer addWeapon "ItemGPS";											
																			_bambiPlayer addWeapon "ItemRadio";
																			_bambiPlayer addWeapon "Rangefinder";									
																			_bambiPlayer addWeapon "NVGoggles_INDEP";									
																			_bambiPlayer addItemToUniform "Exile_Item_Beefparts";
																			_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleCoffee";
																			_bambiPlayer addItemToUniform "Exile_Item_DuctTape";	
																			_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
																			_bambiPlayer addItemToVest "Exile_Item_Vishpirin";																			
																			_bambiPlayer addWeapon 'hgun_Rook40_F';										
																			_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
																			_bambiPlayer addWeapon 'arifle_MX_Black_F';														
																			_bambiPlayer addMagazines ["30Rnd_65x39_caseless_mag", 2];												
																		} else {
																			if(_score > 320000 && _score < 339999) then {
																				clearWeaponCargo _bambiPlayer;
																				clearMagazineCargo _bambiPlayer;
																				hint "Mercenary respect loadout attached";
																				_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
																				_bambiPlayer addVest "V_HarnessO_brn";
																				_bambiPlayer addBackpack "B_Kitbag_rgr";
																				_bambiPlayer addHeadgear "H_HelmetB_snakeskin";
																				_bambiPlayer addWeapon 'Exile_Item_XM8';
																				_bambiPlayer addWeapon "ItemCompass";
																				_bambiPlayer addWeapon "ItemMap";
																				_bambiPlayer addWeapon "ItemGPS";											
																				_bambiPlayer addWeapon "ItemRadio";
																				_bambiPlayer addWeapon "Rangefinder";									
																				_bambiPlayer addWeapon "NVGoggles_INDEP";									
																				_bambiPlayer addItemToUniform "Exile_Item_Beefparts";
																				_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleCoffee";
																				_bambiPlayer addItemToUniform "Exile_Item_DuctTape";
																				_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
																				_bambiPlayer addItemToVest "Exile_Item_Vishpirin";																			
																				_bambiPlayer addWeapon 'hgun_Rook40_F';										
																				_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
																				_bambiPlayer addWeapon 'arifle_MX_Black_F';																
																				_bambiPlayer addMagazines ["30Rnd_65x39_caseless_mag", 2];	
																			} else {
																				if(_score > 340000 && _score < 359999) then {
																					clearWeaponCargo _bambiPlayer;
																					clearMagazineCargo _bambiPlayer;
																					hint "Advanced Mercenary respect loadout attached";
																					_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
																					_bambiPlayer addVest "V_HarnessO_brn";
																					_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
																					_bambiPlayer addHeadgear "H_HelmetB_snakeskin";
																					_bambiPlayer addWeapon 'Exile_Item_XM8';
																					_bambiPlayer addWeapon "ItemCompass";
																					_bambiPlayer addWeapon "ItemMap";
																					_bambiPlayer addWeapon "ItemGPS";											
																					_bambiPlayer addWeapon "ItemRadio";
																					_bambiPlayer addWeapon "Rangefinder";									
																					_bambiPlayer addWeapon "NVGoggles_INDEP";									
																					_bambiPlayer addItemToUniform "Exile_Item_Beefparts";
																					_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleCoffee";
																					_bambiPlayer addItemToUniform "Exile_Item_DuctTape";	
																					_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
																					_bambiPlayer addItemToVest "Exile_Item_Vishpirin";																			
																					_bambiPlayer addWeapon 'hgun_Rook40_F';										
																					_bambiPlayer addMagazines ["16Rnd_9x21_Mag", 2];
																					_bambiPlayer addWeapon 'arifle_MX_Black_F';															
																					_bambiPlayer addMagazines ["30Rnd_65x39_caseless_mag", 2];	
																				} else {
																					if(_score > 360000 && _score < 499999) then {
																						clearWeaponCargo _bambiPlayer;
																						clearMagazineCargo _bambiPlayer;
																						hint "Master Mercenary respect loadout attached";
																						_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";
																						_bambiPlayer addVest "V_HarnessO_brn";
																						_bambiPlayer addBackpack "Tiger_Backpack_Compact ";
																						_bambiPlayer addHeadgear "H_HelmetB_snakeskin";
																						_bambiPlayer addWeapon 'Exile_Item_XM8';
																						_bambiPlayer addWeapon "ItemCompass";
																						_bambiPlayer addWeapon "ItemMap";
																						_bambiPlayer addWeapon "ItemGPS";											
																						_bambiPlayer addWeapon "ItemRadio";
																						_bambiPlayer addWeapon "Rangefinder";									
																						_bambiPlayer addWeapon "NVGoggles_INDEP";						
																						_bambiPlayer addItemToUniform "Exile_Item_DuctTape";																							
																						_bambiPlayer addItemToUniform "Exile_Item_EMRE";
																						_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleCoffee";
																						_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
																						_bambiPlayer addItemToVest "Exile_Item_Vishpirin";																			
																						_bambiPlayer addItemToVest "HandGrenade";
																						_bambiPlayer addItemToVest "Chemlight_green";																						
																						_bambiPlayer addItemToVest "Chemlight_red";																						
																						_bambiPlayer addWeapon 'hgun_Pistol_heavy_01_F';										
																						_bambiPlayer addHandgunItem "optic_MRD";																								
																						_bambiPlayer addMagazines ["11Rnd_45ACP_Mag", 2];
																						_bambiPlayer addWeapon 'arifle_MX_SW_Black_F';												
																						_bambiPlayer addMagazines ["100Rnd_65x39_caseless_mag", 2];																							
																					} else {
																						if(_score > 500000) then {
																							clearWeaponCargo _bambiPlayer;
																							clearMagazineCargo _bambiPlayer;
																							hint "Commando respect loadout attached";
																							_bambiPlayer forceAddUniform "rhs_uniform_cu_ocp";	
																							_bambiPlayer addVest "V_HarnessO_brn";
																							_bambiPlayer addBackpack "B_Carryall_oli";
																							_bambiPlayer addHeadgear "H_HelmetSpecB_blk";
																							_bambiPlayer addWeapon 'Exile_Item_XM8';
																							_bambiPlayer addWeapon "ItemCompass";
																							_bambiPlayer addWeapon "ItemMap";
																							_bambiPlayer addWeapon "ItemGPS";											
																							_bambiPlayer addWeapon "ItemRadio";
																							_bambiPlayer addWeapon "Rangefinder";									
																							_bambiPlayer addWeapon "NVGoggles_INDEP";									
																							_bambiPlayer addItemToUniform "Exile_Item_DuctTape";	
																							_bambiPlayer addItemToUniform "Exile_Item_EMRE";
																							_bambiPlayer addItemToUniform "Exile_Item_PlasticBottleCoffee";
																							_bambiPlayer addItemToVest "Exile_Item_InstaDoc";
																							_bambiPlayer addItemToVest "Exile_Item_InstaDoc";																							
																							_bambiPlayer addItemToVest "Exile_Item_Vishpirin";																			
																							_bambiPlayer addItemToBackpack "HandGrenade";
																							_bambiPlayer addItemToBackpack "Chemlight_green";
																							_bambiPlayer addItemToBackpack "Chemlight_green";
																							_bambiPlayer addItemToBackpack "Chemlight_red";																							
																							_bambiPlayer addItemToBackpack "Chemlight_red";																						
																							_bambiPlayer addWeapon 'hgun_Pistol_heavy_01_F';										
																							_bambiPlayer addHandgunItem "optic_MRD";																								
																							_bambiPlayer addMagazines ["11Rnd_45ACP_Mag", 2];
																							_bambiPlayer addWeapon 'arifle_MX_SW_Black_F';	
																							_bambiPlayer addPrimaryWeaponItem "optic_ERCO_blk_F";															
																							_bambiPlayer addMagazines ["100Rnd_65x39_caseless_mag", 3];	
																						};																								
																					};																								
																				};																								
																			};																								
																		};							
																	};																								
																};																								
															};																								
														};										
													};	
												};	
											};
										};
									};	
								};
							};
						};
					};
				};
			};
		};	
	 };
};	
};
if((canTriggerDynamicSimulation _bambiPlayer) isEqualTo false) then 
{
	_bambiPlayer triggerDynamicSimulation true; 
};
_bambiPlayer addMPEventHandler ["MPKilled", {_this call ExileServer_object_player_event_onMpKilled}];
_bambiPlayer call ExileServer_object_player_database_insert;
_bambiPlayer call ExileServer_object_player_database_update;
[
    _sessionID,
    "createPlayerResponse",
    [
        _bambiPlayer,
        _parachuteNetID,
        str (_accountData select 0),
        (_accountData select 1),
        (_accountData select 2),
        100,
        100,
        0,
        (getNumber (configFile >> "CfgSettings" >> "BambiSettings" >> "protectionDuration")) * 60,
        _clanData,
        _spawnType
    ]
]
call ExileServer_system_network_send_to;
[_sessionID, _bambiPlayer] call ExileServer_system_session_update;
true
