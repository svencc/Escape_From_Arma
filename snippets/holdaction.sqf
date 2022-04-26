_target = kasim;
_title = "Talk: Kasims Plan ...";
_script = {
    params ["_target", "_caller", "_actionId"];
    missionNamespace setVariable ["TASK_TALKED_TO_KASIM_POST_EXTRACT", true];
};
_arguments = nil;
_priority = 1.5;
_showWindow = true;
_hideOnUse = true;
_shortcut = "";
_condition = "true";
_radius = 5;
_unconscious = false;
_selection = "";
_memoryPoint = "";


_target = kasim; 
_title = "Talk: Der Plan";
_idleIcon = "\a3\missions_f_oldman\data\img\holdactions\holdAction_talk_ca.paa";
_progressIcon = "\a3\missions_f_oldman\data\img\holdactions\holdAction_talk_ca.paa";
_conditionShow = "true";
_conditionProgress = "true";
_codeStart = {};
_codeProgress = {};
_codeCompleted = {missionNamespace setVariable ["TASK_TALKED_TO_KASIM_POST_EXTRACT", true]; ["TopicKasimsPlan", "Chapter02SparksInTheDry"] call bis_fnc_kbtell;};
_codeInterrupted = {};
_arguments = [];
_duration = 2;
_priority = 0;
_removeCompleted = true;
_showUnconscious = false;
_showWindow = true;
[_target, _title, _idleIcon, _progressIcon, _conditionShow, _conditionProgress, _codeStart, _codeProgress, _codeCompleted, _codeInterrupted, _arguments, _duration, _priority, _removeCompleted, _showUnconscious, _showWindow] call BIS_fnc_holdActionAdd;


missionNamespace getVariable ["TASK_TALKED_TO_KASIM_POST_EXTRACT", false];