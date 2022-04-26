player addEventHandler ["InventoryOpened", {
	params ["_unit", "_container"];
	
    player setVariable["backpack_content", backpackItems player];
	clearAllItemsFromBackpack player;


	_putHandlerIndex = player addEventHandler ["Put", {
		params ["_unit", "_container", "_item"];
		_backpackItems = backpackItems player;
		if(count _backpackItems > 0) then {
			//_container addItemCargo _item;
    		player removeItemFromBackpack _item;
		};
	}];
	player setVariable["backpack_put_handler", _putHandlerIndex];

	_takeHandlerIndex = player addEventHandler ["Take", {
		params ["_unit", "_container", "_item"];

	}];
	player setVariable["backpack_take_handler", _takeHandlerIndex];

	true;
}];


player addEventHandler ["InventoryClosed", {
	params ["_unit", "_container"];

	_putHandlerIndex = player getVariable ["backpack_put_handler", nil];
	if (isNil "_putHandlerIndex") then {
	    player removeEventHandler ["Put", _putHandlerIndex];
	};

	_takeHandlerIndex = player getVariable ["backpack_take_handler", nil];
	if (isNil "_takeHandlerIndex") then {
	    player removeEventHandler ["Take", _takeHandlerIndex];
	};

	{
		player addItemToBackpack _x;
	} forEach(player getVariable["backpack_content", []]);
}];