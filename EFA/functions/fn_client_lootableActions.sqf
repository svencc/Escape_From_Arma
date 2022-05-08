/*
private _lootableObjects = nearestTerrainObjects [getPos player, EFA_lootableObjects, 5000, false];  
{ 
  private _model = _x;

  // create helper and attach to model
  private _helper = "GroundWeaponHolder_Scripted" createVehicleLocal [0,0,0]; 
  _helper attachTo [_model, [0,0,0]];

  // create inventory and attach to model
  private _inventory = "Land_PlasticCase_01_small_gray_F" createVehicle position _helper; 
  _inventory attachTo [_helper, [0,0,0]];

  // create search-loot action
  private _lootAction = [  
    format["lootAction_%1", position _model],
    "<t color='#000000'>Search</t>", 
    "\A3\ui_f\data\igui\cfg\simpleTasks\types\search_ca.paa", 
    {  
      params ["_target", "_player", "_args"];  
      private _inventory = _args select 0;  
      //_inventory setpos position _target;  
      _player action ["Gear", _inventory];  
        
    },  
    {true},  
    {},  
    [_inventory],  
    nil,  
    5  
  ] call ace_interact_menu_fnc_createAction;
  // add action to lootable model
  [_helper, 0, [], _lootAction] call ace_interact_menu_fnc_addActionToObject;
} forEach _lootableObjects;
*/



/*
private _lootableObjects = nearestTerrainObjects [getPos player, [], 20, false];
nearestObjects

private _lootableObjects = nearestTerrainObjects  [getPos player, [], 50, false];
systemChat str count _lootableObjects;
{ 
  private _model = _x;
  if (isPlayer _model) then {
		systemChat "is player - EXIT!";
    continue;
	};

  private _modelPos = getPos _model;
  private _heightOffsetHelper = -0.45;
  private _heightOffsetContainer = 10;
 
  private _helper = "GroundWeaponHolder_Scripted" createVehicleLocal [0,0,0]; 
  _helper enableSimulationGlobal false;
  "hideObjectGlobal _helper";

  _helper setPos [_modelPos select 0, _modelPos select 1, (_modelPos select 2)+_heightOffsetHelper];
  _helper attachTo [_model, [0,0,0]];
  systemChat "x";
  "[_helper, _helper] call ace_common_fnc_claim";
  systemChat "y";

  "private _inventory = "Land_PlasticCase_01_small_gray_F" createVehicle [0,0,0]""; 
  "_inventory enableSimulationGlobal false";
  "_inventory setPos position _helper";
  "hideObjectGlobal _inventory";
  "_inventory allowDamage false";
  "_inventory setPos [_modelPos select 0, _modelPos select 1, (_modelPos select 2) + _heightOffsetContainer]";
  "_inventory attachTo [_model, [0,0,0]]";
  
  private _lootAction = [  
    format["lootAction_%1", position _model],
    "<t color='#FFFFFF'>Search</t>", 
    "\A3\ui_f\data\igui\cfg\simpleTasks\types\search_ca.paa", 
    {  
      params ["_target", "_player", "_args"];  
      "private _inventory = _args select 0";  
      _player action ["Gear", _helper];  
        
    },  
    {true},  
    {},  
    [_helper],  
    nil,  
    20  
  ] call ace_interact_menu_fnc_createAction;

  [_helper, 0, [], _lootAction] call ace_interact_menu_fnc_addActionToObject;
} forEach _lootableObjects;


  private _helper = "GroundWeaponHolder_Scripted" createVehicleLocal [0,0,0]; 
    "private _inventory = "Land_PlasticCase_01_small_gray_F" createVehicle position _helper"; 


*/










/*
x skript über alle lootbaren MODELS
x  jedes MODEL bekommt einen GroundWeaponHolder (erstellen vorher)
x  der GroundWeaponHolder wird attached zu 0,0,0
x  GroundWeaponHolder bekommt ace action
x    ace action LOOT:
x    action prüft: ist ein container da?
x      wenn ja container öffnen
x        move to player
x        action open gear
      wenn nein container erstellen; inhalt generieren; container öffnen
        move to player
        action open gear
*/
private _lootableObjects = nearestTerrainObjects  [getPos player, [], 50, false];
systemChat str count _lootableObjects;
{ 
  private _model = _x;
  private _modelPos = getPos _model;
  private _heightOffsetHelper = -0.6;
 
  private _helper = "GroundWeaponHolder_Scripted" createVehicleLocal [0,0,0]; 
  _helper enableSimulationGlobal false;
  _helper setPos [_modelPos select 0, _modelPos select 1, (_modelPos select 2)+_heightOffsetHelper];
  _helper attachTo [_model, [0,0,0]];
  [_helper, _helper] call ace_common_fnc_claim;
  
  private _lootAction = [  
    format["lootAction_%1", position _model],
    "<t color='#FFFFFF'>Search</t>", 
    "\A3\ui_f\data\igui\cfg\simpleTasks\types\search_ca.paa", 
    {  
      params ["_target", "_player", "_args"];  
      "private _inventory = _args select 0";  
      _player action ["Gear", _helper];  
        
    },  
    {true},  
    {},  
    [_helper],  
    nil,  
    20  
  ] call ace_interact_menu_fnc_createAction;

  [_helper, 0, [], _lootAction] call ace_interact_menu_fnc_addActionToObject;
} forEach _lootableObjects;