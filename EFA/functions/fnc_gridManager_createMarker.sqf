systemChat "trigger_gridManager_createMarker execute";

params["_grid", "_xDimension", "_yDimension"];

createMarker [
  _grid, 
  [
    _xDimension * 100 + EFA_cacheManager_gridHalfSize, 
    _yDimension * 100 + EFA_cacheManager_gridHalfSize,
    0
  ]
];

_grid setMarkerShapeLocal "RECTANGLE";
_grid setMarkerBrushLocal "Grid";
_grid setMarkerColorLocal "ColorGreen";
_grid setMarkerSize [EFA_cacheManager_gridHalfSize, EFA_cacheManager_gridHalfSize];
