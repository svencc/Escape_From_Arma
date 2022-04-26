// register EFA functions
if (isServer) then {
	call compile preprocessFileLineNumbers ("EFA\init.sqf");
};

MISSION_ROOT = call { 
    private "_arr"; 
    _arr = toArray __FILE__; 
    _arr resize (count _arr - 8); 
    toString _arr 
};










// This is for the demo mission
if (!isDedicated) then {
	// Give the player 10,000 starting money
	// [player, 10000] call HALs_money_fnc_addFunds;
};

private _trader1 = trader1;
if (isServer) then {
	_trader1 enableSimulationGlobal false; 
	_trader1 allowDamage false; 
	_trader1 setCaptive true;
	[_trader1, "weapon"] call HALs_store_fnc_addTrader; 
};

private _trader2_CONTAINERED_SHOP = trader2_CONTAINERED_SHOP;
if (isServer) then {
	_trader2_CONTAINERED_SHOP enableSimulationGlobal false; 
	_trader2_CONTAINERED_SHOP allowDamage false;
	_trader2_CONTAINERED_SHOP setVariable["restrictShopAccessToPlayer", true];
	_trader2_CONTAINERED_SHOP setCaptive true;
	[_trader2_CONTAINERED_SHOP, "navigation"] call HALs_store_fnc_addTrader; 
};


private _trader3 = trader3;
if (isServer) then {
	_trader3 allowDamage false;
	[_trader3, "weapon"] call HALs_store_fnc_addTrader; 
};




/*
switch ([_classname] call HALs_store_fnc_getItemType) do {
	case 1: {_container addMagazineCargoGlobal [_classname, _amount]};
	case 2: {_container addWeaponCargoGlobal [_classname, _amount]};
	case 3: {_container addBackpackCargoGlobal [_classname, _amount]};
	case 4: {_container addItemCargoGlobal [_classname, _amount]};
	default {};
};








// MAGAZINES
_magazinesCargo = getMagazineCargo test_von; 
_magazines = _magazinesCargo select 0; 
_counts = _magazinesCargo select 1;
_i = 0;
{
 	_item = _x; 
	test_zu addMagazineCargoGlobal [_item, _counts select _i];
	_i = _i + 1;
} foreach _magazines;
//clearMagazineCargoGlobal test_von;
// ---------------------------------



// WEAPONS
_weaponsCargo = getWeaponCargo test_von; 
_weapons = _weaponsCargo select 0; 
_counts = _weaponsCargo select 1;
_i = 0;
{
 	_item = _x; 
	test_zu addWeaponCargoGlobal [_item, _counts select _i];
	_i = _i + 1;
} foreach _weapons;
//clearWeaponCargoGlobal test_von;
// ---------------------------------


// BACKPACKS
_backpacksCargo = getBackpackCargo test_von; 
_backpacks = _backpacksCargo select 0; 
_counts = _backpacksCargo select 1;
_i = 0;
{
 	_item = _x; 
	test_zu addBackpackCargoGlobal [_item, _counts select _i];
	_i = _i + 1;
} foreach _backpacks;
//clearBackpackCargoGlobal test_von;
// ---------------------------------



// ITEMS
_itemsCargo = getItemCargo test_von; 
_items = _itemsCargo select 0; 
_counts = _itemsCargo select 1;
_i = 0;
{
 	_item = _x; 
	test_zu addItemCargoGlobal [_item, _counts select _i];
	_i = _i + 1;
} foreach _items;
//clearItemCargoGlobal test_von;
// ---------------------------------





clearMagazineCargoGlobal test_zu;
clearWeaponCargoGlobal test_zu;
clearBackpackCargoGlobal test_zu;
clearItemCargoGlobal test_zu;

hint str getMagazineCargo test_von;
hint str getWeaponCargo test_von;
hint str getBackpackCargo test_von;
hint str getItemCargo test_von;

*/