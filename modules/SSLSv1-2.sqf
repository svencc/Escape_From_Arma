/*
Title:  Sarogahtyps Simple Loot Spawner - SSLS V-1.0
Author: Sarogahtyp
Copyright: Sarogahtyp 2019-2021 under MIT-License (https://en.wikipedia.org/wiki/MIT_License)

Description:
Spawns weapons, items, clothes and backpacks in buildings near to alive players maybe inside a trigger area or marker area.
Deletes stuff if players are not close enough anymore.
The script doesnt care about any trigger preferences except the trigger area.
Main while loop runs every 2 seconds.
Soft delayed item spawning to prevent performance impact.

How to adjust/use the script: 
_spawn_area_array   ["string1", "string2", ...] or []
                 -> contains the names of triggers/markers in which area loot should spawn.
                 -> if empty then loot will spawn everywhere near players

_spawn_chance   number (0-100)
                ->  The chance to spawn loot inside of a specific house.
				-> value gets split into chance to spawn in a house and chance to spawn items on multiple positions in that house
				-> 100 means an average of 75% (50-100) for spawning in a house and
                   an average of 25% (0-50) for spawning on more than one spot in this house
				-> 40 would mean average 30% for spawning in a house and average 10% for spawning multiple
                -> the splitted values are randomized on each new loop run

_house_distance   number (0-x)
                  -> houses inside of this radius of a player will get considered for spawning loot

_player_exclude_distance   number (0-x)
                           -> if 2 players or more are closer together than this then only 1 player is considered
                           -> loot will get deleted if the specific house is farther away than _house_distance + _player_exclude_distance

_exclude_loot   ["string1", "string2", ...] or []
                -> you can add classnames there and those stuff will never spawn

_exclusive_loot   ["string1", "string2", ...] or []
                  -> add classnames here and nothing else will be spawned

_use_bohemia_classes   boolean (true or false)
                       -> if true then vanilla stuff will get spawned.

_use_mod_classes   boolean (true or false)
                   -> if true then stuff of your mods will get spawned.

_debug   boolean (true or false)
         -> if true then u get hints about the number of buildings where stuff was spawned or deleted and how many spawn places are active
		 -> shown on host machine only
*/

//***** EDIT BELOW TO ADJUST MAIN BEHAVIOR
// (L) means lower values are better for performance - (H) means the opposite

private _spawn_area_array = [];  // contains the names of triggers/markers in which areas loot should spawn. if empty then loot spawns in any house
private _no_spawn_area_array = []; // contains the names of triggers/markers in which areas loot should not spawn

private _spawn_chance = 100; // (L) The chance to spawn loot inside of a specific house ( see note above 'bout spawning ). This is the whole spawning chance!

private _max_item_types = 3; // maximum number of different item categories to be spawned on a single building position

private _assault_rifle_chance = 5;  // chance (or weight) to spawn an assault rifle
private _max_magazines_assault_rifle = 5;    // the maximum number of magazines spawned for an assault rifle
private _max_magazines_underbarrel_launcher = 3; // maximum number of ammo to spawn for  underbarrel grenade launchers

private _pistol_chance = 5; // chance (or weight) to spawn a pistol
private _max_magazines_pistol = 3; // the maximum number of magazines spawned for a pistol

private _long_rifle_chance = 5; // chance (or weight) to spawn a long rifle like machine guns and sniper guns
private _max_magazines_long_rifle = 3; // the maximum number of magazines spawned for a long rifle

private _short_rifle_chance = 5; // chance (or weight) to spawn a short rifle like SMGs
private _max_magazines_short_rifle = 3; // the maximum number of magazines spawned for a short rifle

private _spawn_weapons_stripped = true; // if true then weapons will spawn without their default attachments

private _launcher_chance = 5;  // chance (or weight) to spawn a launcher
private _max_magazines_launcher = 1; // maximum number of ammo to spawn for rocket launchers

private _backpack_chance = 5; // chance (or weight) to spawn a backpack
private _weapon_bag_chance = 1; // chance (or weight) to spawn a weapon bag to assemble statics

private _attachment_chance = 10; // chance (or weight) to spawn a weapon attachment
private _max_attachments = 2;	// the maximum number of attachments spawned on one spot

private _dress_chance = 5; // chance (or weight) to spawn a uniform, vest, helmet or something like that
private _max_dress = 2; // the maximum number of dress items spawned on one spot

private _basic_chance = 50; // chance (or weight) to spawn basic items like watch, map, gps, binocular, ace medical, food ...
private _max_basic = 5; // the maximum number of basic items spawned on one spot

private _misc_chance = 5; // chance (or weight) to spawn a acre radio, antenna, rope and some ammo types
private _max_misc = 2; // the maximum number of dress items spawned on one spot

private _house_distance = 35;  // (L) houses with that distance to players will spawn loot
private _player_exclude_distance = 50; // (H) if 2 players or more are closer together than this then only 1 player is considered

private _exclude_loot = []; //classnames of items which should never spawn (blacklist)
private _exclusive_loot = []; //add classnames here and nothing else will be spawned (whitelist)

private _use_bohemia_classes = true; // for spawning bohemia created stuff set this to true
private _use_mod_classes = true; // for spawning stuff from loaded mods set this to true

private _debug = true;  // information about number of places where items were spawned or deleted. shown on host machine only.

// if you have performance issues then consider introducing spawning areas (_spawn_area_array) before changing following values!
private _spawn_interval = 2; // (H) desired runtime for the main loop. time which is not needed will be used for soft spawning or a break.

//***** EDIT ABOVE TO ADJUST MAIN BEHAVIOR

if not ( hasInterface ) then { _debug = false };

// exit if _spawn_chance is 0
if (_spawn_chance isEqualTo 0) exitWith 
{
 if (_debug) then { systemChat "Unable to spawn anything. _spawn_chance is set to 0. Change it to a value above 0 in script file!"; };
  
 diag_log "SSLS: Unable to spawn anything. _spawn_chance is set to 0. Change to a value above 0 in script file";
};

// exit if all of the different spawn chances are 0
if ( _assault_rifle_chance isEqualTo 0 and _pistol_chance isEqualTo 0 and _long_rifle_chance isEqualTo 0 and _short_rifle_chance isEqualTo 0 and 
	 _launcher_chance isEqualTo 0 and _backpack_chance isEqualTo 0 and _weapon_bag_chance isEqualTo 0 and _dress_chance isEqualTo 0 and
	 _attachment_chance isEqualTo 0 and _misc_chance isEqualTo 0 and _basic_chance isEqualTo 0 ) exitWith 
{
 if (_debug) then { systemChat "Unable to spawn anything. All single spawn chances (like _assault_rifle_chance) are set to 0. Change it to a value above 0 in script file!"; };
  
 diag_log "SSLS: Unable to spawn anything. All single spawn chances (like _assault_rifle_chance) are set to 0. Change it to a value above 0 in script file!";
};

//***** init variables

private ["_class", "_classname", "_dummy", "_index", "_items_array", "_magazines", "_name", "_name_low", "_parents", "_phrase" ];

private _all_cfgWeapons_entries_array = [];
private _all_cfgWeapons_item_entries_array = [];
private _all_cfgVehicles_entries_array = [];
private _all_cfgVehilces_item_entries_array = [];
private _assault_rifles_mags_array = [];
private _pistols_mags_array = [];
private _long_rifles_mags_array = [];
private _short_rifles_mags_array = [];
private _launchers_mags_array = [];
private _attachment_items_array = [];
private _dress_items_array = [];
private _misc_items_array = [];
private _basic_items_array = [];
private _backpacks_array = [];
private _weapon_bags_array = [];

private _attachment_phrases = [ "optic", "muzzle", "flashlight", "bipod", "acc_", "laser", "cup_nvg_", "terminal" ];

private _dress_phrases = [ "uniform", "item_u_", "head", "cap",
						   "suit", "knee", "vest", "beret", "_vsr9", "gorka", "jeans", "fleck", "shirt", "boonie",
						   "beanie", "helmet", "gloves", "shorts", "overall", "goggles", "ghillie", "opscore",
						   "kneepad", "ratnik", "pmc_unit", "bandana", "casual", "soldier", "ger_m92_" ];

private _dress_start_phrases = ["v_", "h_", "u_b_", "u_o_", "u_c_", "u_i_", "u_ig_", "u_oi_", "u_bg_", "u_og_",
								"cup_v_", "cup_u_", "cup_i_b_", "cup_h_", "cup_o_", "tac_v_", "tryk_h_", "ef_m_"];
 
private _misc_phrases =  [ "detector", "antenna", "acre", "rope", "radio", "photo", "tripod", "_tank", "greenmag_" ];
 
private _exclusive_loot_bool = _exclusive_loot isNotEqualTo [];

private _use_bohemia_classes = _use_bohemia_classes || (!_use_bohemia_classes && !_use_mod_classes);
private _use_all_classes = _use_bohemia_classes && _use_mod_classes;

private _player_exclude_distance_sqr = _player_exclude_distance ^ 2;
private _delete_distance_sqr = (_house_distance + _player_exclude_distance) ^ 2;
private _house_distance = _house_distance + _player_exclude_distance;


//***** get all needed classes from weapons config file

if ( _assault_rifle_chance + _short_rifle_chance + _long_rifle_chance + _pistol_chance + _launcher_chance +
	 _dress_chance + _attachment_chance + _misc_chance + _basic_chance > 0 ) then
{
 _all_cfgWeapons_entries_array = ( "getNumber (_x >> 'scope') > 1" configClasses (configFile >> "cfgWeapons") ) select
 {
  _name = configName _x;

  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };

  ( "RifleCore" in _parents or "PistolCore" in _parents or "LauncherCore" in _parents or "ItemCore" in _parents or "Binocular" in _parents or
  "Item_Base_F" in _parents or "Items_base_F" in _parents ) and not ( "fake" in (toLower _name) ) and 
  {!(_name in _exclude_loot) and (!_exclusive_loot_bool or (_name in _exclusive_loot)) and 
  {(_use_bohemia_classes and ((getText (_x >> 'author')) isEqualTo "Bohemia Interactive")) or (_use_mod_classes and !((getText (_x >> 'author')) isEqualTo "Bohemia Interactive")) or _use_all_classes}}
 };
};

//***** get rifle and magazine classnames from config file

if ( _assault_rifle_chance + _short_rifle_chance + _long_rifle_chance > 0 ) then
{
 _assault_rifles_mags_array = _all_cfgWeapons_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };

   "RifleCore" in _parents and { not ( "Rifle_Long_Base_F" in _parents ) and not ("Rifle_Short_Base_F" in _parents) }
 } apply
 {
  _name = configName _x;

  _class = ( getArray ( configFile >> "CfgWeapons" >> _name >> "muzzles" ) ) select 1;
  _magazines_gl = [];
  
  if not ( isNil "_class" ) then
  {	
   _magazines_gl = getArray (configFile >> "CfgWeapons" >> _name >> _class >> "magazines") select 
   { 
    not ( "fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
   };
  };

  _magazines = getArray ( configFile >> "CfgWeapons" >> _name >> "magazines" ) select 
  { 
   not ( "fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
  };
   
  [ _name, _magazines, _magazines_gl ]
 };
};

//***** get pistol and magazine classnames from config file
if ( _pistol_chance > 0 ) then
{
 _pistols_mags_array = _all_cfgWeapons_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };

  "PistolCore" in _parents
 } apply
 {
  _name = configName _x;

  _class = ( getArray ( configFile >> "CfgWeapons" >> _name >> "muzzles" ) ) select 1;
  _magazines_gl = [];
  
  if not ( isNil "_class" ) then
  {	
   _magazines_gl = getArray (configFile >> "CfgWeapons" >> _name >> _class >> "magazines") select 
   { 
    not ( "fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
   };
  };
  
  _magazines = getArray ( configFile >> "CfgWeapons" >> _name >> "magazines" ) select 
  { 
   not ("fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
  };
   
  [ _name, _magazines, _magazines_gl ]
 };
};

//***** get long rifle and magazine classnames from config file
if ( _long_rifle_chance > 0 ) then
{
 _long_rifles_mags_array = _all_cfgWeapons_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };

  "Rifle_Long_Base_F" in _parents
 } apply
 {
  _name = configName _x;

  _class = ( getArray ( configFile >> "CfgWeapons" >> _name >> "muzzles" ) ) select 1;
  _magazines_gl = [];
  
  if not ( isNil "_class" ) then
  {	
   _magazines_gl = getArray (configFile >> "CfgWeapons" >> _name >> _class >> "magazines") select 
   { 
    not ( "fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
   };
  };
  
  _magazines = getArray ( configFile >> "CfgWeapons" >> _name >> "magazines" ) select 
  { 
   not ("fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
  };
   
  [ _name, _magazines, _magazines_gl ]
 };
};

//***** get short rifle and magazine classnames from config file
if ( _short_rifle_chance > 0 ) then
{
 _short_rifles_mags_array = _all_cfgWeapons_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };

  "Rifle_Short_Base_F" in _parents
 } apply
 {
  _name = configName _x;

  _class = ( getArray ( configFile >> "CfgWeapons" >> _name >> "muzzles" ) ) select 1;
  _magazines_gl = [];
  
  if not ( isNil "_class" ) then
  {	
   _magazines_gl = getArray (configFile >> "CfgWeapons" >> _name >> _class >> "magazines") select 
   { 
    not ( "fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
   };
  };
  
  _magazines = getArray ( configFile >> "CfgWeapons" >> _name >> "magazines" ) select 
  { 
   not ("fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
  };
   
  [ _name, _magazines, _magazines_gl ]
 };
};

//***** get launchers and rocket/grenade classnames from config file
if ( _launcher_chance > 0 ) then
{
 _launchers_mags_array = _all_cfgWeapons_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };
  
  "LauncherCore" in _parents
 } apply
 {
  _name = configName _x;

  _class = ( getArray ( configFile >> "CfgWeapons" >> _name >> "muzzles" ) ) select 1;
  _magazines_gl = [];
  
  if not ( isNil "_class" ) then
  {	
   _magazines_gl = getArray (configFile >> "CfgWeapons" >> _name >> _class >> "magazines") select 
   { 
    not ( "fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
   };
  };
  
  _magazines = getArray ( configFile >> "CfgWeapons" >> _name >> "magazines" ) select 
  { 
   not ( "fake" in (toLower _x) ) and not (_x in _exclude_loot) and (not _exclusive_loot_bool or {_x in _exclusive_loot} )
  };
  
   [ _name, _magazines, _magazines_gl ]
 };
};

//*****get all needed classes from vehicles config file
if ( _dress_chance + _attachment_chance + _misc_chance + _basic_chance + _backpack_chance + _weapon_bag_chance > 0 ) then
{
 _all_cfgVehicles_entries_array = "getNumber (_x >> 'scope') > 1" configClasses (configFile >> "CfgVehicles") select
 {
  _name = configName _x;
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };
  
  ( "ItemCore" in _parents or "Binocular" in _parents or "Item_Base_F" in _parents or "Items_base_F" in _parents or "Bag_Base" in _parents ) and
  not ( "fake" in (toLower _name) ) and
  { not (_name in _exclude_loot) and ( not _exclusive_loot_bool or { _name in _exclusive_loot } ) and 
  { ( _use_bohemia_classes and { ( getText ( _x >> 'author' ) ) isEqualTo "Bohemia Interactive" } ) or
  ( _use_mod_classes and { not ( ( getText ( _x >> 'author' ) ) isEqualTo "Bohemia Interactive" ) } ) or _use_all_classes } }
 };
};

//*****get all item classes from vehicles config array
if ( _dress_chance + _attachment_chance + _misc_chance + _basic_chance > 0 ) then
{
 _items_array = _all_cfgVehicles_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while {!isNull _class} do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };
  
  "ItemCore" in _parents or "Binocular" in _parents or "Item_Base_F" in _parents or "Items_base_F" in _parents
 };
 
 //*****get items classnames from config file
 _all_cfgWeapons_item_entries_array = _all_cfgWeapons_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };
  
  "ItemCore" in _parents or "Binocular" in _parents or "Item_Base_F" in _parents or "Items_base_F" in _parents
 };
 
 _items_array = _all_cfgVehicles_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while {!isNull _class} do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };
  
  "ItemCore" in _parents or "Binocular" in _parents or "Item_Base_F" in _parents or "Items_base_F" in _parents
 };
 
 _items_array append _all_cfgWeapons_item_entries_array;
 
 _items_array = _items_array apply
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _classname = configName _class;
   
   if not 
   ( _classname in 
     ["Default", "ItemCore", "ACE_ItemCore", "CBA_MiscItem", "Items_base_F", "ThingX", "Thing", "All", "Item_Base_F", "WeaponHolder", "ReammoBox", "Strategic", "Building", "Static"]
   ) then
   {
    _parents pushBack ( toLower _classname);
   };
   _class = inheritsFrom _class;
  };

  [ (configName _x) , _parents ]
 };

 {
  _name = _x select 0;
  _name_low = toLower _name;
 
  _parents = _x select 1;
 
  _index = _attachment_phrases findIf { _phrase = _x; _phrase in _name_low or { _parents findIf { _phrase in _x } > -1 } };
 
  if ( _index > -1 and _attachment_chance > 0 )  then { _dummy = _attachment_items_array pushBack _name; } else
  {
   _index = _dress_start_phrases findIf { ( _name_low find _x ) isEqualTo 0 };

   if ( _index > -1 and _dress_chance > 0 )  then { _dummy = _dress_items_array pushBack _name; } else
   {
    _index = _dress_phrases findIf { _phrase = _x; _phrase in _name_low or { _parents findIf { _phrase in _x } > -1 } };

    if ( _index > -1 and _dress_chance > 0 )  then { _dummy = _dress_items_array pushBack _name; } else
    {
     _index = _misc_phrases findIf { _phrase = _x; _phrase in _name_low or { _parents findIf { _phrase in _x } > -1 } };

     if (_index > -1 and _misc_chance > 0 )  then { _dummy = _misc_items_array pushBack _name; } else
     { if (_basic_chance > 0) then { _dummy = _basic_items_array pushBack _name; }; };
    };
   };
  };
 } count _items_array;
};

//*****get backpack classnames from config file
if (_backpack_chance > 0) then
{
 _backpacks_array = _all_cfgVehicles_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };

  "Bag_Base" in _parents and not ( "Weapon_Bag_Base" in _parents )
 } apply { configName _x }; 
};

//*****get weapon bag classnames from config file
if (_weapon_bag_chance > 0) then
{
 _weapon_bags_array = _all_cfgVehicles_entries_array select
 {
  _parents = [];
  _class = inheritsFrom _x;
  
  while { not isNull _class } do
  {
   _parents pushBack configName _class;
   _class = inheritsFrom _class;
  };

  "Weapon_Bag_Base" in _parents
 } apply {configName _x}; 
};

[
 _spawn_area_array, _no_spawn_area_array, _house_distance, _debug, _assault_rifles_mags_array, _assault_rifle_chance, _max_magazines_assault_rifle, _launchers_mags_array, _launcher_chance, _max_magazines_launcher, 
 _backpacks_array, _backpack_chance, _spawn_interval, _max_magazines_underbarrel_launcher, _spawn_chance, _player_exclude_distance_sqr, _delete_distance_sqr,
 _attachment_items_array, _attachment_chance, _max_attachments, _dress_items_array, _dress_chance, _max_dress, _misc_items_array, _misc_chance, _max_misc, _basic_items_array,
 _basic_chance, _max_basic, _weapon_bags_array, _weapon_bag_chance, _spawn_weapons_stripped, _pistol_chance, _max_magazines_pistol, _pistols_mags_array,
 _long_rifle_chance, _max_magazines_long_rifle, _long_rifles_mags_array, _short_rifle_chance, _max_magazines_short_rifle, _short_rifles_mags_array, _max_item_types
] spawn
{
 params 
 [
  "_spawn_area_array", "_no_spawn_area_array", "_house_distance", "_debug", "_assault_rifles_mags_array", "_assault_rifle_chance", "_max_magazines_assault_rifle", "_launchers_mags_array", "_launcher_chance", "_max_magazines_launcher",
  "_backpacks_array", "_backpack_chance", "_spawn_interval", "_max_magazines_underbarrel_launcher", "_spawn_chance", "_player_exclude_distance_sqr", "_delete_distance_sqr",
  "_attachment_items_array", "_attachment_chance", "_max_attachments", "_dress_items_array", "_dress_chance", "_max_dress", "_misc_items_array", "_misc_chance", "_max_misc", "_basic_items_array",
  "_basic_chance", "_max_basic", "_weapon_bags_array", "_weapon_bag_chance", "_spawn_weapons_stripped", "_pistol_chance", "_max_magazines_pistol", "_pistols_mags_array",
  "_long_rifle_chance", "_max_magazines_long_rifle", "_long_rifles_mags_array", "_short_rifle_chance", "_max_magazines_short_rifle", "_short_rifles_mags_array", "_max_item_types"
 ];

 private 
 [
  "_itembox", "_item", "_codes_array",
  "_rnd_house", "_spawn_chance_rnd", "_house_multiple_chance", "_houses_now_in_area", "_houses_spawn_new", "_loot_players", "_justPlayers", "_sol_1_start",
  "_plyr", "_house", "_new_house_num", "_spawned_num", "_in_area_num", "_del_house_num", "_time_act", "_runtime", "_break_time", "_sleep_delay", "_pos_array",
  "_pos_num", "_pos", "_in_no_area", "_in_area", "_spawn_start_time", "_sleep_time"
 ];
 
 private _assault_rifle_code = {};
 private _long_rifle_code = {};
 private _short_rifle_code = {};
 private _pistol_code = {};
 private _launcher_code = {};
 private _backpack_code = {};
 private _weapon_bag_code = {};
 private _optic_code = {}; 
 private _dress_code = {};
 private _misc_code = {};
 private _basic_code = {};
 
 private _houses_delete = [];
 private _last_houses_in_area = [];
 private _houses_spawned = [];

 private _sol_1_time = 0;
 private _last_time = diag_tickTime;
 private _time_before = _last_time;
 
 private _min_spawn_intervall = _spawn_interval - ( 0.1 * _spawn_interval );
 private _max_spawn_intervall = _spawn_interval + ( 0.1 * _spawn_interval );
  
 private _box_classname = "WeaponHolderSimulated_Scripted";

 if ( _assault_rifle_chance > 0 ) then
 {
  if ( _assault_rifles_mags_array isEqualTo [] ) then
  {
   _assault_rifle_chance = 0;
   _assault_rifle_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn assault rifles. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn assault rifles. Assault rifles array (_assault_rifles_mags_array) is empty. If this is intended then you could set _assault_rifle_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide assault rifles if you disabled use of vanilla stuff." );
  } else
  {
   _assault_rifle_code =
   {
    _item = selectRandom _assault_rifles_mags_array;
  
    if ( _spawn_weapons_stripped ) then
    { _itembox addWeaponWithAttachmentsCargoGlobal [ [ (_item select 0), "", "", "", [], [], ""], 1 ]; } else
    { _itembox addItemCargoGlobal [(_item select 0), 1]; };
    
    for "_i" from 1 to (ceil random _max_magazines_assault_rifle) do 
    {
     _itembox addItemCargoGlobal  [(selectRandom (_item select 1)), 1];
    };
	 
    if (count (_item select 2) > 0) then
    {
     for "_i" from 1 to (ceil random _max_magazines_underbarrel_launcher) do 
     {
      _itembox addItemCargoGlobal  [(selectRandom (_item select 2)), 1];
     };
    };
   };
  };
 };

 if ( _pistol_chance > 0 ) then
 {
  if ( _pistols_mags_array isEqualTo [] ) then
  {
   _pistol_chance = 0;
   _pistol_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn pistols. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn pistols. Pistols array (_pistols_mags_array) is empty. If this is intended then you could set _pistol_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide pistols if you disabled use of vanilla stuff." );
   
  } else
  {
   _pistol_code =
   {
    _item = selectRandom _pistols_mags_array;
  
    if ( _spawn_weapons_stripped ) then
    { _itembox addWeaponWithAttachmentsCargoGlobal [ [ (_item select 0), "", "", "", [], [], ""], 1 ]; } else
    { _itembox addItemCargoGlobal [(_item select 0), 1]; };
    
    for "_i" from 1 to (ceil random _max_magazines_pistol) do 
    {
     _itembox addItemCargoGlobal  [(selectRandom (_item select 1)), 1];
    };
	
	if (count (_item select 2) > 0) then
    {
     for "_i" from 1 to (ceil random _max_magazines_underbarrel_launcher) do 
     {
      _itembox addItemCargoGlobal  [(selectRandom (_item select 2)), 1];
     };
    };
   };
  };
 };

 if ( _long_rifle_chance > 0 ) then
 {
  if ( _long_rifles_mags_array isEqualTo [] ) then
  {
   _long_rifle_chance = 0;
   _long_rifle_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn long rifles. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn long rifles. Long rifles array (_long_rifles_mags_array) is empty. If this is intended then you could set _long_rifle_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide long rifles if you disabled use of vanilla stuff." );
  } else
  {
   _long_rifle_code =
   {
    _item = selectRandom _long_rifles_mags_array;

    if ( _spawn_weapons_stripped ) then
    { _itembox addWeaponWithAttachmentsCargoGlobal [ [ (_item select 0), "", "", "", [], [], ""], 1 ]; } else
    { _itembox addItemCargoGlobal [(_item select 0), 1]; };
    
    for "_i" from 1 to (ceil random _max_magazines_long_rifle) do 
    {
     _itembox addItemCargoGlobal  [(selectRandom (_item select 1)), 1];
    };
	
	if (count (_item select 2) > 0) then
    {
     for "_i" from 1 to (ceil random _max_magazines_underbarrel_launcher) do 
     {
      _itembox addItemCargoGlobal  [(selectRandom (_item select 2)), 1];
     };
    };
   };
  };
 };

 if ( _short_rifle_chance > 0 ) then
 {
  if ( _short_rifles_mags_array isEqualTo [] ) then
  {
   _short_rifle_chance = 0;
   _short_rifle_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn short rifles. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn short rifles. Short rifles array (_short_rifles_mags_array) is empty. If this is intended then you could set _short_rifle_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide short rifles if you disabled use of vanilla stuff." );
  } else
  {
   _short_rifle_code =
   {
    _item = selectRandom _short_rifles_mags_array;
	
    if ( _spawn_weapons_stripped ) then
    { _itembox addWeaponWithAttachmentsCargoGlobal [ [ (_item select 0), "", "", "", [], [], ""], 1 ]; } else
    { _itembox addItemCargoGlobal [(_item select 0), 1]; };
    
    for "_i" from 1 to (ceil random _max_magazines_short_rifle) do 
    {
     _itembox addItemCargoGlobal  [(selectRandom (_item select 1)), 1];
    };
	
	if (count (_item select 2) > 0) then
    {
     for "_i" from 1 to (ceil random _max_magazines_underbarrel_launcher) do 
     {
      _itembox addItemCargoGlobal  [(selectRandom (_item select 2)), 1];
     };
    };
   };
  };
 };
 
 if ( _launcher_chance > 0 ) then
 {
  if ( _launchers_mags_array isEqualTo [] ) then
  {
   _launcher_chance = 0;
   _launcher_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn launchers. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn launchers. Launcher array (_launchers_mags_array) is empty. If this is intended then you could set _launcher_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide launchers if you disabled use of vanilla stuff." );
  } else
  {
   _launcher_code =
   {
    _item = selectRandom _launchers_mags_array;
    _itembox addItemCargoGlobal  [(_item select 0), 1];
    
    for "_i" from 1 to (ceil random _max_magazines_launcher) do 
    {
     _itembox addItemCargoGlobal  [(selectRandom (_item select 1)), 1];
    };
	
	if (count (_item select 2) > 0) then
    {
     for "_i" from 1 to (ceil random _max_magazines_underbarrel_launcher) do 
     {
      _itembox addItemCargoGlobal  [(selectRandom (_item select 2)), 1];
     };
    };
   };
  };
 };

 if ( _backpack_chance > 0 ) then
 {
  if ( _backpacks_array isEqualTo [] ) then
  {
   _backpack_chance = 0;
   _backpack_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn backpacks. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn backpacks. Backpack array (_backpacks_array) is empty. If this is intended then you could set _backpack_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide backpacks if you disabled use of vanilla stuff." );
   
  } else
  {
   _backpack_code =
   {
    _item = selectRandom _backpacks_array;
    _itembox addBackpackCargoGlobal [_item, 1];
   };
  };
 };

 if ( _weapon_bag_chance > 0 ) then
 {
  if ( _weapon_bags_array isEqualTo [] ) then
  {
   _weapon_bag_chance = 0;
   _weapon_bag_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn weapon bags (statics). Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn weapon bags (statics). Weapon bags array (_weapon_bags_array) is empty. If this is intended then you could set _weapon_bag_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide weapon bags if you disabled use of vanilla stuff." );
   
  } else
  {
   _weapon_bag_code =
   {
    _item = selectRandom _weapon_bags_array;
    _itembox addBackpackCargoGlobal [_item, 1];
   };
  };
 };

 if ( _attachment_chance > 0 ) then
 {
  if ( _attachment_items_array isEqualTo [] ) then
  {
   _attachment_chance = 0;
   _optic_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn weapon attachments. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn weapon attachments. Weapon attachments array (_attachment_items_array) is empty. If this is intended then you could set _attachment_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide weapon attachments (defined in _attachment_phrases) if you disabled use of vanilla stuff." );
   
  } else
  {
   _optic_code =
   {
    for "_i" from 1 to (ceil random _max_attachments) do 
    {
     _item = selectRandom _attachment_items_array;
     _itembox addItemCargoGlobal [_item, 1];
    };
   };
  };
 };

 if ( _dress_chance > 0 ) then
 {
  if ( _dress_items_array isEqualTo [] ) then
  {
   _dress_chance = 0;
   _dress_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn dress items. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn dress items. Dress items array (_dress_items_array) is empty. If this is intended then you could set _dress_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide dress items (defined in _dress_phrases and _dress_start_phrases) if you disabled use of vanilla stuff." );
   
  } else
  {
   _dress_code =
   {
    for "_i" from 1 to (ceil random _max_dress) do 
    {
     _item = selectRandom _dress_items_array;
     _itembox addItemCargoGlobal [_item, 1];
    };
   };
  };
 };

 if ( _misc_chance > 0 ) then
 {
  if ( _misc_items_array isEqualTo [] ) then
  {
   _misc_chance = 0;
   _misc_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn misc items. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn misc items. Misc items array (_misc_items_array) is empty. If this is intended then you could set _misc_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide misc items (defined in _misc_phrases) if you disabled use of vanilla stuff." );
   
  } else
  {
   _misc_code =
   {
    for "_i" from 1 to (ceil random _max_misc) do 
    {
     _item = selectRandom _misc_items_array;
     _itembox addItemCargoGlobal [_item, 1];
    };
   };
  };
 };

 if ( _basic_chance > 0 ) then
 {
  if ( _basic_items_array isEqualTo [] ) then
  {
   _basic_chance = 0;
   _basic_code = {};
   
   if (_debug) then { systemChat "Saros Loot Spawner: Can't spawn basic items. Further information in .rpt file." };
   
   diag_log ( "SSLS: Can't spawn basic items. Basic items array (_basic_items_array) is empty. If this is intended then you could set _basic_chance to 0 to suppress this message. " + 
            "If not intended then consider changing mod/vanilla spawn options or use mods which provide basic items " + 
			"(all items which not get filtered through _attachment_phrases, _dress_phrases or _misc_phrases) if you disabled use of vanilla stuff." );
   
  } else
  { 
   _basic_code =
   {
    for "_i" from 1 to (ceil random _max_basic) do 
    {
     _item = selectRandom _basic_items_array;
     _itembox addItemCargoGlobal [_item, 1];
    };
   };
  };
 };

 if ( _assault_rifle_chance + _pistol_chance  + _long_rifle_chance + _short_rifle_chance + _launcher_chance + _backpack_chance + _weapon_bag_chance +
	  _dress_chance + _attachment_chance + _misc_chance + _basic_chance isEqualTo 0 ) exitWith 
 {
  if (_debug) then { systemChat "Unable to spawn anything. View .rpt file for further information."; };
  
  diag_log "SSLS: Can't spawn anything. All spawn chances are set to 0 maybe due to empty item arrays. Look for other entries above this one for further information.";
 };

 _codes_array =
 [
  _assault_rifle_code, _assault_rifle_chance, _pistol_code, _pistol_chance, _long_rifle_code, _long_rifle_chance, _short_rifle_code, _short_rifle_chance,
  _launcher_code, _launcher_chance, _backpack_code, _backpack_chance, _weapon_bag_code, _weapon_bag_chance, _optic_code, _attachment_chance, _dress_code, _dress_chance,
  _misc_code, _misc_chance, _basic_code, _basic_chance
 ];
 
 SSLS_script_switch_off = false;  // if you want to stop spawning loot then set this to true at any time in your mission
 
 while { not SSLS_script_switch_off } do
 {
  // split spawn chance into spawning and multiple spawning chance
  _rnd_house = random (_spawn_chance * 0.5);
  _spawn_chance_rnd = _spawn_chance * 0.5 + _rnd_house;
  _house_multiple_chance = _spawn_chance - _spawn_chance_rnd;
  
  _houses_now_in_area = [];
  _houses_spawn_new = [];

  //select all alive players which can be considered for item spawning
  _loot_players = ( allPlayers - entities "HeadlessClient_F" ) select 
  {
   _plyr = _x;

   _in_no_area = if( _no_spawn_area_array isNotEqualTo [] ) then
	{
	 _no_spawn_area_array findIf { _plyr inArea _x } > -1
	} else { false };

   _in_area = if( _spawn_area_array isNotEqualTo [] ) then 
   {
	_spawn_area_array findIf { _plyr inArea _x } > -1
   } else { true } and not _in_no_area;
   
   alive _x and isNull objectParent _x and _in_area
  };
  
  //***** get desired spawn positions for loot in the buildings close to players
  _sol_1_start = diag_tickTime;
 
  _justPlayers = [];
	
  {
   _plyr = _x;
   if ( _justPlayers findIf { (_x distanceSqr _plyr) < _player_exclude_distance_sqr } < 0) then
   {
    _dummy = _justPlayers pushBack _plyr;
   };
  } count _loot_players;

  _loot_players = _justPlayers;
 
  { _dummy =
   {
     if ( (random 100) < _spawn_chance_rnd and { not (_x in _last_houses_in_area) } ) then
	 {
      _houses_spawn_new pushBackUnique _x;         // houses where new items will spawned
	  _houses_spawned pushBackUnique _x;      // houses with already (and newly) spawned items
	 };
	 _dummy = _houses_now_in_area pushBackUnique _x;     // houses which are in area now but were not before
   } count ( ( _x nearObjects [ "building", _house_distance ] ) select { (_x buildingPos -1) isNotEqualTo [] } );
  } count _loot_players;
  
  _last_houses_in_area = _houses_now_in_area;  // remember actual houses for next while run

  _houses_delete = (_houses_spawned - _houses_now_in_area) select  // delete inside of all houses which are not in area anymore
  {
   _house = _x;
   _loot_players findIf { _house distanceSqr _x < _delete_distance_sqr } < 0
  };

  _houses_spawned = _houses_spawned - _houses_delete; // deleted houses have no spawned stuff anymore

  [_houses_delete, _box_classname] spawn
  {
   params ["_houses_delete", "_box_classname"];
   
   // delete all stuff inside of all houses marked for deletion
   { _dummy =
    { _dummy =
     {
      deleteVehicle _x;
     } count (nearestObjects [_x, [_box_classname], 2]);
    } count (_x buildingPos -1);
   } count _houses_delete;
  };
  
  //***** try to spawn loot within specified time (delay to prevent performance impact)
  _new_house_num = count _houses_spawn_new;
  _sol_1_time = diag_tickTime - _sol_1_start;

   _time_act = diag_tickTime;
   _runtime = _time_act - _time_before;
   _time_before = _time_act;
  
  if ( _runtime > _max_spawn_intervall + 0.5 ) then
  { 
   diag_log format [
   ( "SSLS: exceeded maximum main loop runtime %1. runtime was %2. If you read this message often then you should consider " + 
   "to read performance comments in script file and adjust variables for more performance. Otherwise Soft-Spawning can not be guaranteed and lags could occure during spawn process."),
   _max_spawn_intervall, _runtime ];
   };
  
  // debug things
  if(_debug) then
  {
   if ( _runtime > _max_spawn_intervall + 0.5 ) then { systemChat format ["exceeded maximum main loop runtime %1. runtime was %2. View .rpt file for further information.", _max_spawn_intervall, _runtime ] };
   
   _spawned_num = count _houses_spawned;
   _in_area_num = count _houses_now_in_area;
   _del_house_num = count _houses_delete;
   
   hint parseText format ["houses where new loot is spawned<br />houses where all loot got deleted<br />new h.: %1, del h.: %2<br /><br />
   houses where stuff is inside<br />houses which are in range of a player<br />spawned h.: %3, h. in area: %4<br /><br />
   players on server<br />players which are used for spawning<br />watched players: %5<br /><br />
   runtime of the code which does not spawn<br />full runtime<br />sol1: %6, runtime: %7<br /><br />
   chance to spawn in a house<br />chance to spawn on multiple spots in a house<br />h.chance = %8%%, mult. ch. = %9%%",
   _new_house_num, _del_house_num, _spawned_num, _in_area_num, (count _loot_players), _sol_1_time, _runtime, _spawn_chance_rnd, _house_multiple_chance];
  };

  _break_time = random [ _min_spawn_intervall, _spawn_interval, _max_spawn_intervall ]  - (diag_tickTime - _last_time);

  if ( _break_time < 0 ) then { _break_time = 0; }; 

  if (_new_house_num > 0) then
  {
   _sleep_delay = _break_time / _new_house_num;

   {
   	_spawn_start_time = diag_tickTime;
    _pos_array = _x buildingPos -1;
    _pos_num = count _pos_array;
	
    while {_pos_num > 0} do
    {
     _pos = selectRandom _pos_array;
     _pos_array = _pos_array - _pos;
     _pos_num = _pos_num - 1;
	
     _itembox = createVehicle [_box_classname, ( _pos vectorAdd [0, 0, 0.2] ), [], 0.2, "NONE"];
	 
	 for "_i" from 1 to ( ceil random _max_item_types ) do
     {
      [] call selectRandomWeighted _codes_array;
	 };

     if( random 100 >= _house_multiple_chance) then
     {
      _pos_num = 0;
     };
    };

	_sleep_time = _sleep_delay - (diag_tickTime - _spawn_start_time);
    if ( _sleep_time > 0 ) then { sleep _sleep_time; };
   } count _houses_spawn_new;
  }
  else
  {
   sleep _break_time;
  };
  _last_time = diag_tickTime;
 };
 
 _houses_delete append _houses_spawned;
 _houses_delete append _houses_now_in_area;
 _houses_delete append _houses_spawn_new;

 { _dummy =
  { _dummy =
   {
    deleteVehicle _x;
   } count (nearestObjects [_x, [_box_classname], 3]);
  } count (_x buildingPos -1);
 } count ( _houses_delete arrayIntersect _houses_delete );
};