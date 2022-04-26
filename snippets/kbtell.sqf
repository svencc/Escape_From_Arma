["TopicFirstContact", "Chapter01FirstContact"] spawn bis_fnc_kbtell;
["TopicFirstContact", "Chapter01FirstContact", nil, false, nil, nil, 10, true] spawn bis_fnc_kbtell;
["TopicFirstContact", "Chapter01FirstContact"] spawn bis_fnc_kbtellLocal;
["TopicFirstContact", "Chapter01FirstContact", nil, "Direct", nil, nil, 10, true] spawn bis_fnc_kbtell;
l

[topic, container, section, radioMode, code, speakers, soundVolume, radioProtocol] spawn BIS_fnc_kbTell



missionNamespace setVariable ["TASK_TALKED_TO_TAYO", true, true];
["TopicFirstContact", "Chapter01FirstContact"] spawn bis_fnc_kbtell;




["TopicFirstContact", "Chapter01FirstContact"] remoteExec ["bis_fnc_kbtell",  2];






