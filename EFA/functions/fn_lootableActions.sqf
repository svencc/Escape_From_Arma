params["_xDimension", "_yDimension"];

private _xDimensionGridCenter = _xDimension + EFA_cacheManager_gridHalfSize;
private _yDimensionGridCenter = _yDimension + EFA_cacheManager_gridHalfSize;

private _lootableObjects = nearestTerrainObjects  [
  [_xDimensionGridCenter, _yDimensionGridCenter, 0], 
  [], 
  EFA_cacheManager_gridDiagonalLength, 
  false
];
private _preparedObjects = 0; // DEBUG
systemChat format["Terrain Objects: %1", (count _lootableObjects)]; // DEBUG
{
  private _terrainObject = _x;
  private _modelInfo = getModelInfo _terrainObject;
  private _modelName = _modelInfo select 0;
  private _modelPos = _modelInfo select 3;
  private _modelWorldPos = getPos _terrainObject;
  private _modelInArea = _terrainObject inArea [
    [_xDimensionGridCenter, _yDimensionGridCenter],
    EFA_cacheManager_gridHalfSize,
    EFA_cacheManager_gridHalfSize,
    0,
    true
  ];

  // _modelInArea = true;

  if( _modelInArea && (_modelName in EFA_lootableObjects) ) then {
    _preparedObjects = _preparedObjects + 1; // DEBUG
    private _heightOffsetHelper = 0;

    private _helper = "GroundWeaponHolder_Scripted" createVehicle [0,0,0];
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
      (_modelPos select 2) + (_modelWorldPos select 2) + (_modelHeight - (_helperHeight))
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
        private _inventory = _args select 0;
        _player action ["Gear", _inventory];
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

systemChat format["lootable Objects created: %1", _preparedObjects]; // DEBUG