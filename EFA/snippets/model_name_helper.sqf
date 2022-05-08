private _cursorObject = cursorObject;
private _model = getModelInfo _cursorObject;
private _modelText = str (_model select 0);
private _objectType = typeOf _cursorObject;
private _out = format ["%1, // %2", _modelText, (str _objectType)];
systemChat _out;
copyToClipboard _out;





    private _modelCenter = boundingCenter _cursorObject;
    private _modelBoundingBox = boundingBox _cursorObject;
    private _p1 = _modelBoundingBox select 0;
    private _p2 = _modelBoundingBox select 1;
    private _modelHeight = abs ((_p2 select 2) - (_p1 select 2));

	systemchat format["center %1", _modelCenter select 0];
	systemchat format["bounding box %1",_modelBoundingBox];
	systemchat format["model height %1",_modelHeight];