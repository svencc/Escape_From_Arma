// Executed locally when player joins mission (includes both mission start and JIP). 

// Task					Applies To		JIP		Related To		Exec Environment	Notes
// initServer.sqf		Server			-		Event Scripts	Scheduled			-	
// initPlayerLocal.sqf	Client			+		Event Scripts	Scheduled			-
// initPlayerServer.sqf Server			+		Event Scripts	Scheduled			-
// init.sqf				All				-		-				-					-	

/*
 *	player	Object
 *	didJIP	Boolean
 */
params ["_player", "_didJIP"];

(group _player) setVariable ["lambs_danger_disableGroupAI", true];
_player setVariable ["lambs_danger_disableAI", true];
(group _player) setVariable ["Vcm_Disable",true];