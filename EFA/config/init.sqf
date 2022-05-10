systemChat "config init";

[] call compile preprocessFileLineNumbers ("EFA\config\EFA_cacheManager_config.sqf");
[] call compile preprocessFileLineNumbers ("EFA\config\EFA_loot_config.sqf");
[] call compile preprocessFileLineNumbers ("EFA\config\EFA_lootableObjects_config.sqf");