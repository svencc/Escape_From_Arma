_keep = 7;

_shuffled = (synchronizedObjects thisTrigger) call BIS_fnc_arrayShuffle;
 
_toDelete = [_shuffled, _keep] call BIS_fnc_subSelect;
{
    if (_x isKindOf "Man") then {
        {
            deleteVehicle _x;
        } forEach (units _x);
    };
} forEach _toDelete;

deleteVehicle thisTrigger;