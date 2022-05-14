systemChat "fn_playersInGrid execute";

params["_grid"];

private _statePerPlayer = allPlayers inAreaArray _grid;
private _reducedState = false;

{
	private _playerInArea = _x;
	_reducedState = _reducedState && _playerInArea;
} forEach _statePerPlayer;

systemChat _statePerPlayer

_reducedState;
    