_itemToPlace = nil;
_positions = [];
_syncedObjects = (synchronizedObjects thisTrigger);

{ if (_x isKindOf "VR_Helper_base_F") then {_positions = _positions + [_x]};} forEach _syncedObjects;
{ if (!(_x isKindOf "VR_Helper_base_F")) then {_itemToPlace = _x};} forEach _syncedObjects;

_selectedPosition = (_positions call BIS_fnc_arrayShuffle) select 0;

if (!(isNil "_itemToPlace")) then {
	_itemToPlace setDir (getDir _selectedPosition);
	_itemToPlace setPos (getPos _selectedPosition);
};

{
    deleteVehicle _x;
} forEach _positions;

deleteVehicle thisTrigger;