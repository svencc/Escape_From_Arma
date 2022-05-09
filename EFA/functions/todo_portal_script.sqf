"PORTAL -> BASEMENT PORTAL:";
private _basementPortal = this;
private _basementPortalPosition = getPos _basementPortal;
private _basementMainActionItemName = format["basement_%1", _basementPortalPosition];
private _basementMainActionItem = [
  _basementMainActionItemName,
  "Infiltrate to ...",
  "jk_tarkov_markers\data\extraction_point.paa",
  {},
  {true},
  {},
  [],
  nil,
  2
] call ace_interact_menu_fnc_createAction;
[_basementPortal, 0, [], _basementMainActionItem] call ace_interact_menu_fnc_addActionToObject;

private _newBasementMarker = createMarker[
  format["basement_marker_%1", _basementPortalPosition],
  _basementPortalPosition
];
_newBasementMarker setMarkerColorLocal "ColorRed";
_newBasementMarker setMarkerType "jk_extraction";


"PORTAL -> INFILTRATION PORTALS:";
_portals = nearestObjects [portal, ["Land_Calvary_03_F"], 20000];
{
  if (_x getVariable ["isInfiltrationPortal", false]) then {
    private _infilPortalPosition = getPos _x;

    private _newMarker = createMarker[
      format["infil_marker_%1_%2", _infilPortalPosition, time],
      _infilPortalPosition
    ];
    _newMarker setMarkerType "jk_extraction";

    private _portalsInfilAction = [
      format["infil_%1_%2", _infilPortalPosition, time],
      format["... location near %1", text nearestLocation [_infilPortalPosition,"nameVillage"]],
      "jk_tarkov_markers\data\extraction_point.paa",
      {
        params ["_target", "_player", "_args"];
        _player setPos (_args select 0);
      },
      {true},
      {},
      [_infilPortalPosition],
      nil,
      2
    ] call ace_interact_menu_fnc_createAction;
    [_basementPortal, 0, [_basementMainActionItemName], _portalsInfilAction] call ace_interact_menu_fnc_addActionToObject;
  }
} forEach _portals;



"EXILTRATION PORTALS -> PORTAL:";
{   
  if (_x getVariable ["isExfiltrationPortal", false]) then {
    private _homePortal = _basementPortal;
    private _homePortalPosition = getPos _homePortal;
    private _exfilPortal = _x;
    private _exfilPortalPosition = getPos _x;
 
    private _exfilMainActionItemName = format["exfil_%1", _exfilPortalPosition];
    private _exfilMainActionItem = [
      _exfilMainActionItemName,
      "Exfiltrate to ...",
      "jk_tarkov_markers\data\extraction_point.paa",
      {},
      {true},
      {},
      [],
      nil,
      2
    ] call ace_interact_menu_fnc_createAction;
    [_exfilPortal, 0, [], _exfilMainActionItem] call ace_interact_menu_fnc_addActionToObject;


    private _portalsExfilAction = [
      format["exfil_%1_%2", _homePortalPosition, time],
      format["... location near %1", text nearestLocation [_homePortalPosition,"nameVillage"]],
      "jk_tarkov_markers\data\extraction_point.paa",
      {
        params ["_target", "_player", "_args"];
        _player setPos (_args select 0);
      },
      {true},
      {},
      [_homePortalPosition],
      nil,
      2
    ] call ace_interact_menu_fnc_createAction;
    [_exfilPortal, 0, [_exfilMainActionItemName], _portalsExfilAction] call ace_interact_menu_fnc_addActionToObject;
  }
} forEach _portals;



/*

Beispielportal
Class: "Land_Calvary_03_F"

init:
this setVariable ["isInfiltrationPortal", true, true];
this setVariable ["isExfiltrationPortal", true, true];

*/