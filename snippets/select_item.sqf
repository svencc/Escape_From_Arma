_keep = 2;

_shuffled = (synchronizedObjects thisTrigger) call BIS_fnc_arrayShuffle;
 
_toDelete = [_shuffled, _keep] call BIS_fnc_subSelect;
{
    deleteVehicle _x;
} forEach _toDelete;

deleteVehicle thisTrigger;