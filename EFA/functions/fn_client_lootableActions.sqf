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

  private _helper = "GroundWeaponHolder_Scripted" createVehicle [0,0,0];
  _helper enableSimulationGlobal false;
  _helper setPos [_modelPos select 0, _modelPos select 1, (_modelPos select 2)+_heightOffsetHelper];
  _helper attachTo [_model, [0,0,0]];
  [_helper, _helper] call ace_common_fnc_claim; // hide interaction of inventory; it claims the usage by its own.
 
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