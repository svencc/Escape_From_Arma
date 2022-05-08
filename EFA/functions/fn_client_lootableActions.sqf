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
/*private _lootableObjects = nearestTerrainObjects  [
  [worldSize / 2, worldSize / 2],
  [],
  worldSize * sqrt 2 / 2,
  false
];*/
private _lootableObjects = nearestTerrainObjects  [getPos player, [], 5, false];
private _preparedObjects = 0;
systemChat format["Terrain Objects: %1", count _lootableObjects];
{
  private _terrainObject = _x;
  private _modelInfo = getModelInfo _terrainObject;
  private _modelName = _modelInfo select 0;
  private _modelPos = _modelInfo select 3;
  private _modelWorldPos = getPos _terrainObject;

systemChat format["%1",_modelPos];

    if(_modelName in EFA_lootableObjects) then {
    _preparedObjects = _preparedObjects + 1;
    private _heightOffsetHelper = 0;

    private _helper = "Land_VR_Shape_01_cube_1m_F" createVehicle [0,0,0];
    "Land_VR_Shape_01_cube_1m_F";
    "GroundWeaponHolder_Scripted";
    
    _helper enableSimulationGlobal false;

    private _helperBoundingBox = boundingBoxReal _helper;
    private _helperP1 = _helperBoundingBox select 0;
    private _helperP2 = _helperBoundingBox select 1;
    private _helperHeight = abs ((_helperP2 select 2) - (_helperP1 select 2));
    systemChat format["hh %1", _helperHeight];

    private _modelBoundingBox = boundingBoxReal _terrainObject;
    private _modelP1 = _modelBoundingBox select 0;
    private _modelP2 = _modelBoundingBox select 1;
    private _modelHeight = abs ((_modelP2 select 2) - (_modelP1 select 2));

    _helper setPos [
      (_modelPos select 0) + (_modelWorldPos select 0), 
      (_modelPos select 1) + (_modelWorldPos select 1),
      (_modelPos select 2) + ((_modelWorldPos select 2) + _modelHeight - (_helperHeight))
    ];
    systemChat format["_modelPos %1", _modelPos];
    systemChat format["_modelWorldPos %1", _modelWorldPos];
    systemChat format["_modelHeight %1", _modelHeight];
    systemChat format["_helperHeight %1", _helperHeight];
    _helper setVectorDir (vectorDir _terrainObject);
    
    [_helper, _helper] call ace_common_fnc_claim;
  
    private _lootAction = [
      format["lootAction_%1", position _terrainObject],
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
      [0,0,0],
      10
    ] call ace_interact_menu_fnc_createAction;
    [_helper, 0, [], _lootAction] call ace_interact_menu_fnc_addActionToObject;
  };
} forEach _lootableObjects;

systemChat format["Prepared Objects: %1", _preparedObjects];








(_modelPos select 2) + ((_modelWorldPos select 2) + _modelHeight - (_helperHeight/2))