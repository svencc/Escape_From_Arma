/*
	Function: EFA_fnc_transfer_cargo
	Author: Tonic
	Transfers contents from one container to another

	Argument(s):
	0: Source <OBJECT>
	1: Target <OBJECT>

	Return Value:
	None

	Example:
	[sourceBox, targetBox] call EFA_fnc_transfer_cargo;
__________________________________________________________________*/
params [
	["_source", objNull, [objNull]],
	["_target", objNull, [objNull]]
];



// MAGAZINES
_magazinesCargo = getMagazineCargo _source; 
_magazines = _magazinesCargo select 0; 
_counts = _magazinesCargo select 1;
_i = 0;
{
 	_item = _x; 
	_target addMagazineCargoGlobal [_item, _counts select _i];
	_i = _i + 1;
} foreach _magazines;
clearMagazineCargoGlobal _source;
// ---------------------------------



// WEAPONS
_weaponsCargo = getWeaponCargo _source; 
_weapons = _weaponsCargo select 0; 
_counts = _weaponsCargo select 1;
_i = 0;
{
 	_item = _x; 
	_target addWeaponCargoGlobal [_item, _counts select _i];
	_i = _i + 1;
} foreach _weapons;
clearWeaponCargoGlobal _source;
// ---------------------------------


// BACKPACKS
_backpacksCargo = getBackpackCargo _source; 
_backpacks = _backpacksCargo select 0; 
_counts = _backpacksCargo select 1;
_i = 0;
{
 	_item = _x; 
	_target addBackpackCargoGlobal [_item, _counts select _i];
	_i = _i + 1;
} foreach _backpacks;
clearBackpackCargoGlobal _source;
// ---------------------------------



// ITEMS
_itemsCargo = getItemCargo _source; 
_items = _itemsCargo select 0; 
_counts = _itemsCargo select 1;
_i = 0;
{
 	_item = _x; 
	_target addItemCargoGlobal [_item, _counts select _i];
	_i = _i + 1;
} foreach _items;
clearItemCargoGlobal _source;
// ---------------------------------