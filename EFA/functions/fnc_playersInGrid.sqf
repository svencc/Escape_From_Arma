systemChat "fn_playersInGrid execute";

params["_grid"];

private _playersInGrid = allPlayers inAreaArray _grid;
if ( (count _playersInGrid) == 0 ) exitWith {
	false;
};

true;