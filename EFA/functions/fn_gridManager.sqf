systemChat "fn_gridManager loaded";


/*
systemChat format["Grid %1", mapGridPosition player];
https://community.bistudio.com/wiki/HashMap
*/

// TEST :
private _fn_draw_marker = {
  params["_gridName", "_xDimension", "_yDimension"];

  private _gridSize = 50;

  systemchat format["%1-%2", _xDimension,_yDimension];
  private _marker = createMarker [_gridName, [(parseNumber _xDimension)*100+_gridSize, (parseNumber _yDimension)*100+_gridSize]];
  _marker setMarkerShapeLocal "RECTANGLE";
  _marker setMarkerBrushLocal "Grid";
  _marker setMarkerColorLocal "ColorGreen";
  _marker setMarkerSize [_gridSize, _gridSize];
};

private _playersGrid = mapGridPosition player;
private _xDimension = [_playersGrid, 0, 2] call BIS_fnc_trimString;
private _yDimension = [_playersGrid, 3, 5] call BIS_fnc_trimString;
private _playersGridName = format["%1-%2", _xDimension, _yDimension];
[str time, _xDimension, _yDimension] call _fn_draw_marker;

// : TEST




fn_draw_marker = {
  params["_gridName", "_xDimension", "_yDimension"];

  private _gridSize = 50;
  private _marker = createMarker [_gridName, [(parseNumber _xDimension)*100+_gridSize, (parseNumber _yDimension)*100+_gridSize]];
  _marker setMarkerShapeLocal "RECTANGLE";
  _marker setMarkerBrushLocal "Grid";
  _marker setMarkerColorLocal "ColorGreen";
  _marker setMarkerSize [_gridSize, _gridSize];
};

EFA_fn_gridManager = {
  {
    private _aPlayer = _x;
    private _playersGrid = mapGridPosition _aPlayer;

    private _playersGrid = mapGridPosition player;
    private _xDimension = [_playersGrid, 0, 2] call BIS_fnc_trimString;
    private _yDimension = [_playersGrid, 3, 5] call BIS_fnc_trimString;
    private _playersGridName = format["%1-%2", _xDimension, _yDimension];


    if (EFA_gridCache getOrDefault [_playersGridName, true]) then {
      EFA_gridCache set [_playersGridName, true];
      [_playersGridName, _xDimension, _yDimension] call fn_draw_marker;
      systemChat format["%1 has been entered!", _playersGridName];
    } else {
      systemChat format["%1 has been visited already ...", _playersGridName];
    };
  } forEach allPlayers;
};

"if (!isServer) exitWith {}";
if (isNil "EFA_gridCache") then {
  EFA_gridCache = createHashMap;
};

  private _gridManagerTrigger = createTrigger["EmptyDetector", [0,0], false];
_gridManagerTrigger setTriggerInterval 1;
_gridManagerTrigger setTriggerStatements [
  "
    thistrigger call EFA_fn_gridManager;
    false
  ",
  "",
  ""
];









/*

weiß in einer HashMap welches Grid geladen ist.
das Grid, in welchem sich ein Spieler befindet, ist geladen.
  betrifft der Spieler ein neues 2er Grid; wird das nächste Grid geladen.
  der Spieler muss zu Fuß sein, damit ein Grid geladen wird.

  Grids werden nach 24 Stunden ungültig
  Grids in denen der Spieler sich gerade befindet werden auch ungültig; werden aber nicht gelöscht so lange er sich darin aufhält!

*/