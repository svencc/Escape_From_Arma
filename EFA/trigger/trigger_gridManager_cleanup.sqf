systemChat "trigger_gridManager_cleanup execute";

// CLEANUP
EFA_fn_gridManager_cleanup = {
  {
    private _grid = _x;
    private _gridInvalidationTime = _y;

    if (serverTime > _gridInvalidationTime) then {
      if ( !([_grid] call EFA_fnc_playersInGrid) ) then {
        systemChat format["%1 has been cleared!", _grid];
        private _deletableObjectCandidates = (getMarkerPos _grid) nearObjects["GroundWeaponHolder_Scripted", EFA_cacheManager_gridDiagonalLength];
        
        _grid setMarkerColorLocal "ColorRed";
        EFA_gridCache deleteAt _grid;
      };
    }

  } forEach EFA_gridCache;
};

private _gridManagerCleanupTrigger = createTrigger["EmptyDetector", [0,0], false];
_gridManagerCleanupTrigger setTriggerInterval EFA_cacheManager_cleanup_interval;
_gridManagerCleanupTrigger setTriggerStatements [
  "
    thistrigger call EFA_fn_gridManager_cleanup;
    false
  ",
  "",
  ""
];