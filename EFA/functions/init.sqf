systemChat "functions init";

EFA_fnc_lootableActions 			= compile preprocessFileLineNumbers ("EFA\functions\fn_lootableActions.sqf");
EFA_fnc_lootableActions_cleanup 	= compile preprocessFileLineNumbers ("EFA\functions\fn_lootableActions_cleanup.sqf");
EFA_fnc_lootableActions_create 		= compile preprocessFileLineNumbers ("EFA\functions\fn_lootableActions_create.sqf");

EFA_fnc_gridManager		 			= compile preprocessFileLineNumbers ("EFA\functions\fn_gridManager.sqf"); 
[] call EFA_fnc_gridManager;

EFA_fnc_transferCargo 				= compile preprocessFileLineNumbers ("EFA\functions\fn_transfer_cargo.sqf");
systemChat "compiled functions";