// Executed locally when player joins mission (includes both mission start and JIP). 

// Task					Applies To		JIP		Related To		Exec Environment	Notes
// initServer.sqf		Server			-		Event Scripts	Scheduled			-	
// initPlayerLocal.sqf	Client			+		Event Scripts	Scheduled			-
// onPlayerRespawn.sqf	Client			+		Event Scripts	Scheduled			-
// initPlayerServer.sqf Server			+		Event Scripts	Scheduled			-
// init.sqf				All				-		-				-					-	

/*
 *	_newUnit	Object
 *	_oldUnit	Object
 *	_respawn	Number
 *	_respawnDelay	Number
 */
params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

(group _newUnit) setVariable ["lambs_danger_disableGroupAI", true];
_newUnit setVariable ["lambs_danger_disableAI", true];
(group _newUnit) setVariable ["Vcm_Disable",true];