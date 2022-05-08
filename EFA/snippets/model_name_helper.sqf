private _cursorObject = cursorObject;
private _model = getModelInfo _cursorObject;
private _modelText = str (_model select 0);
private _objectType = typeOf _cursorObject;
private _out = format ["%1, // %2", _modelText, (str _objectType)];
systemChat _out;
copyToClipboard _out;