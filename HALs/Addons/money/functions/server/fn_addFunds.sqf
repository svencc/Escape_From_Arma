/*
	Function: HALs_money_fnc_addFunds
	Author: HallyG

	Arguments(s):
	0: Unit <OBJECT>
	1: Funds <NUMBER>

	Return Value:
	None

	Example:
	[player, 100] call HALs_money_fnc_addFunds;
__________________________________________________________________*/
params [
	["_unit", objNull, [objNull]],
	["_funds", 0, [0]]
];

if (!local _unit) exitWith {
	[_unit, _funds] remoteExec ["HALs_money_fnc_addFunds", _unit, false]
};

[_unit, (([_unit] call grad_moneymenu_fnc_addFunds) + _funds) max 0] call grad_moneymenu_fnc_setFunds;

// original ...
// _unit setVariable ["dmpPlayerCash", ((_unit getVariable ["dmpPlayerCash", 0]) + _funds) max 0, true];