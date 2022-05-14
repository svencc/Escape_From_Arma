systemChat "trigger_gridManager execute";

if (!isServer) exitWith {};
if (isNil "EFA_gridCache") then {
  EFA_gridCache = createHashMap;
};

EFA_fn_gridManager = {
  {
    private _aPlayer = _x;
    private _playersGrid = mapGridPosition _aPlayer;

    private _playersGrid = mapGridPosition player;
    private _xDimension = parseNumber ([_playersGrid, 0, 2] call BIS_fnc_trimString);
    private _yDimension = parseNumber ([_playersGrid, 3, 5] call BIS_fnc_trimString);
    private _playersGridName = format["%1-%2", _xDimension, _yDimension];


    if ( !(_playersGrid in EFA_gridCache) && (isNull objectParent player) ) then {
      EFA_gridCache set [_playersGrid, (serverTime + EFA_cacheManager_invalidateGridTime)];
      //[_playersGrid, _xDimension, _yDimension] call fn_draw_marker;
      [_playersGrid, _xDimension, _yDimension] call EFA_fnc_gridManager_createMarker;
      // [_xDimension * 100, _yDimension * 100] call EFA_fnc_lootableActions;
      [_playersGrid] call EFA_fnc_lootableActions_v2;
      systemChat format["%1 has been entered by %2!", _playersGridName, name _aPlayer];
    };
  } forEach allPlayers;
};


private _gridManagerTrigger = createTrigger["EmptyDetector", [0,0], false];
_gridManagerTrigger setTriggerInterval EFA_cacheManager_interval;
_gridManagerTrigger setTriggerStatements [
  "
    thistrigger call EFA_fn_gridManager;
    false
  ",
  "",
  ""
];