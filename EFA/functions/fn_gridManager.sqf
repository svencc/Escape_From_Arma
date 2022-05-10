systemChat "fn_gridManager execute";

fn_draw_marker = {
  params["_gridName", "_xDimension", "_yDimension"];

  private _marker = createMarker [
    _gridName, 
    [
      _xDimension * 100 + EFA_cacheManager_gridHalfSize, 
      _yDimension * 100 + EFA_cacheManager_gridHalfSize,
      0
    ]
  ];

  _marker setMarkerShapeLocal "RECTANGLE";
  _marker setMarkerBrushLocal "Grid";
  _marker setMarkerColorLocal "ColorGreen";
  _marker setMarkerSize [EFA_cacheManager_gridHalfSize, EFA_cacheManager_gridHalfSize];
};

EFA_fn_gridManager = {
  {
    private _aPlayer = _x;
    private _playersGrid = mapGridPosition _aPlayer;

    private _playersGrid = mapGridPosition player;
    private _xDimension = parseNumber ([_playersGrid, 0, 2] call BIS_fnc_trimString);
    private _yDimension = parseNumber ([_playersGrid, 3, 5] call BIS_fnc_trimString);
    private _playersGridName = format["%1-%2", _xDimension, _yDimension];


    if ( !(_playersGrid in EFA_gridCache) ) then {
      EFA_gridCache set [_playersGrid, (serverTime + EFA_cacheManager_invalidateGridTime)];
      [_playersGrid, _xDimension, _yDimension] call fn_draw_marker;
      [_xDimension * 100, _yDimension * 100] call EFA_fnc_lootableActions;
      systemChat format["%1 has been entered!", _playersGridName];
    } else {
      "systemChat format[""%1 has been visited already ..."", _playersGridName]";
    };
  } forEach allPlayers;
};

"if (!isServer) exitWith {}";
if (isNil "EFA_gridCache") then {
  EFA_gridCache = createHashMap;
};

  private _gridManagerTrigger = createTrigger["EmptyDetector", [0,0], false];
_gridManagerTrigger setTriggerInterval 0.5;
_gridManagerTrigger setTriggerStatements [
  "
    thistrigger call EFA_fn_gridManager;
    false
  ",
  "",
  ""
];









/*

x weiß in einer HashMap welches Grid geladen ist.
x das Grid, in welchem sich ein Spieler befindet, ist geladen.
x  betrifft der Spieler ein neues 2er Grid; wird das nächste Grid geladen.
  der Spieler muss zu Fuß sein, damit ein Grid geladen wird.

  Grids werden nach 24 Stunden ungültig
  Grids in denen der Spieler sich gerade befindet werden auch ungültig; werden aber nicht gelöscht so lange er sich darin aufhält!

*/