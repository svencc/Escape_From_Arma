HG_fnc_nightskillFactor = compile "
	_sunriseTimeTupel = date call BIS_fnc_sunriseSunsetTime;
	_sunriseTime =  _sunriseTimeTupel select 0;
	_sunsetTime = _sunriseTimeTupel select 1;
	_currentTime = dayTime;
	_sunOrMoon = sunOrMoon;

	if (_currentTime < _sunriseTime) exitWith {
		if(_sunOrMoon > 0) then {
			[""TWILIGHT: UM SONNENAUFGANG | x 0.25""] remoteExec [""systemChat"", 0];
			0.25;
		} else {
			[""DARK: VOR SONNENAUFGANG | x 0.1""] remoteExec [""systemChat"", 0];
			0.1;

		}
	};

	if (_currentTime > _sunsetTime) exitWith {
		if(_sunOrMoon > 0) then {
			[""TWILIGHT: UM SONNENUNTERGANG | x 0.25""] remoteExec [""systemChat"", 0];
			0.25;
		} else {
			[""DARK: NACH SONNENUNTERGANG | x 0.1""] remoteExec [""systemChat"", 0];
			0.1;
		};
	};	

	if ((_sunriseTime <= _currentTime) && (_currentTime <= _sunsetTime) ) exitWith {
		[""DAYLIGHT: TAGESLICHT | x 1.0""] remoteExec [""systemChat"", 0];
		1;
	};

	[""UPS: UNDEFINED BKRIGHTNESS | x 1.0""] remoteExec [""systemChat"", 0];
	1
";

_aimingAccuracy = _x skill "aimingAccuracy";
_aimingShake = _x skill "aimingShake";
_aimingSpeed = _x skill "aimingSpeed";
_spotDistance = _x skill "spotDistance";
_spotTime = _x skill "spotTime";
_nightSkillFactor = call HG_fnc_nightskillFactor;

{
	if ((side _x) == east) then {
		_x setSkill ["aimingAccuracy", Vcm_AISkills_General_AimingAccuracy * _nightSkillFactor];
		_x setSkill ["aimingShake", Vcm_AISkills_General_aimingShake * _nightSkillFactor];
		_x setSkill ["aimingSpeed", Vcm_AISkills_General_aimingSpeed * _nightSkillFactor];
		_x setSkill ["spotDistance", Vcm_AISkills_General_spotDistance * _nightSkillFactor];
		_x setSkill ["spotTime", Vcm_AISkills_General_spotTime * _nightSkillFactor];
		_x setSkill ["general", Vcm_AISkills_General_general * _nightSkillFactor];
	};
} forEach allUnits;

["NIGHTSKILL EXECUTED on " + str count allUnits ] remoteExec ["systemChat", 0];

false;










-------------------------------------------------

Vcm_AISkills_General_AimingAccuracy = 0.25;
Vcm_AISkills_General_aimingShake = 0.15;
Vcm_AISkills_General_aimingSpeed = 0.35;
Vcm_AISkills_General_commanding = 0.85;
Vcm_AISkills_General_courage = 0.5;
Vcm_AISkills_General_general = 0.5;
Vcm_AISkills_General_reloadSpeed = 1;
Vcm_AISkills_General_spotDistance = 0.85;
Vcm_AISkills_General_spotTime = 0.85;











systemChat "dayTime";
systemChat dayTime;
systemChat "sunOrMoon ";
systemchat str sunOrMoon;
//systemChat "moonPhase ";
//systemchat str moonPhase date;
//systemChat "moonIntensity ";
//systemchat str moonIntensity;

systemchat "sunrise time";
systemchat str (date call BIS_fnc_sunriseSunsetTime);

// 10:30 = 1
// 15:30 = 1
// 17:00 = 1
// 18:00 = 1
// 18:30 = 1
// 19:00 = 1
// 19:07 = 1 (ist schon ziemlich dunkel)
// 19:13 = 0.618223
// 19:30 = 0




// 05:00 = 1

// spätestens Bei sunOrMoon = 0 ist die Sonne aus; Die Sonne beginnt aber schon unterzugenen nach der sunriseTime


// Wenn später sunriseTime aber sunOrMoon = 1; dann ZWIELICHT
// Wenn sunOrMoon bereits wieder 1; aber unterhalb der sunriseTime, dann wieder ZWIELICHT

/*
###MODEL

Wenn sunOrMoon = 0; dann DUNKEL
Wenn Sonne aufgeht (sunOrMoon = 1); aber Uhrzeit noch kleiner Sonnenaufgangszeit, dann ZWIELICHT
Wenn Uhrzeit > Sonnenaufgangszeut; dann HELL
Hell ist es solange wie sunOrMoon = 1 ist
Wenn Sonne untergeht (sunOrMoon < 1); aber Uhrzeit noch kleiner Sonnenuntergangszeit, dann ZWIELICHT


*/