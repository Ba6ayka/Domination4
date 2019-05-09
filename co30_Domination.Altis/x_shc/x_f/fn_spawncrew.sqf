// by Xeno
//#define __DEBUG__
#define THIS_FILE "fn_spawncrew.sqf"
#include "..\..\x_setup.sqf"

params ["_vec", "_grp", ["_nocargo", false]];

createVehicleCrew _vec;
private _crew = crew _vec;
if (count _crew > 0) then {
	private _grp_old = group (_crew # 0);
	_crew joinSilent _grp;
	deleteGroup _grp_old;
	
	private _subskill = if (diag_fps > 29) then {
		(0.1 + (random 0.2))
	} else {
		(0.12 + (random 0.04))
	};
	
	if (!_nocargo) then {
#ifdef __IFA3LITE__
		if (random 100 > 80 && {_vec isKindOf "Wheeled_APC" || {_vec isKindOf "Wheeled_APC_F" || {_vec isKindOf "Tracked_APC"}}}) then {
#else
		if (random 100 > 49 && {_vec isKindOf "Wheeled_APC" || {_vec isKindOf "Wheeled_APC_F" || {_vec isKindOf "Tracked_APC"}}}) then {
#endif
			private _counter = _vec emptyPositions "cargo";
			__TRACE_2("","typeOf _vec","_counter")
			if (_counter > 0) then {
				_counter = (ceil (random _counter)) min 6;
				if (_counter > 0) then {
					private _munits = ["allmen", side _grp] call d_fnc_getunitlistm;
					__TRACE_1("","_munits")
					if !(_munits isEqualTo []) then {
						private _addus = [];
						private _pos = getPos _vec;
						private _nightorfog = call d_fnc_nightfograin;
						for "_i" from 1 to _counter do {
							private _one_unit = _grp createUnit [selectRandom _munits, _pos, [], 10, "NONE"];
							[_one_unit] joinSilent _grp;
							_one_unit moveInCargo _vec;
							_one_unit setUnitAbility ((d_skill_array # 0) + (random (d_skill_array # 1)));
							_one_unit setSkill ["aimingAccuracy", _subskill];
							_one_unit setSkill ["spotTime", _subskill];
							_one_unit call d_fnc_removenvgoggles_fak;
							[_one_unit, _nightorfog, true] call d_fnc_changeskill;
#ifdef __TT__
							_one_unit addEventHandler ["Killed", {[[15, 3, 2, 1], _this # 1, _this # 0] remoteExecCall ["d_fnc_AddKills", 2]}];
#endif
							if (d_with_ai && {d_with_ranked}) then {
								_one_unit addEventHandler ["Killed", {
									[1, _this select 1] remoteExecCall ["d_fnc_addkillsai", 2];
									(_this select 0) removeAllEventHandlers "Killed";
								}];
							};
							if (d_with_dynsim == 0) then {
								_one_unit spawn {
									scriptName "spawn spawncrew dyn";
									sleep 15;
									_this enableDynamicSimulation true;
								};
							};
#ifdef __GROUPDEBUG__
							// does not subtract if a unit dies!
							if (side _grp == d_side_enemy) then {
								d_infunitswithoutleader = d_infunitswithoutleader + 1;
							};
#endif
							_addus pushBack _one_unit;
						};
						_crew append _addus;
					};
				};
			};
		};
	};
	
	{
		_x call d_fnc_removenvgoggles_fak;
#ifdef __TT__
		_x addEventHandler ["Killed", {[[15, 3, 2, 1], _this # 1, _this # 0] remoteExecCall ["d_fnc_AddKills", 2]}];
#endif
		if (d_with_ai && {d_with_ranked}) then {
			_x addEventHandler ["Killed", {
				[1, _this select 1] remoteExecCall ["d_fnc_addkillsai", 2];
				(_this select 0) removeAllEventHandlers "Killed";
			}];
		};
		_x setUnitAbility ((d_skill_array # 0) + (random (d_skill_array # 1)));
		_x setSkill ["aimingAccuracy", _subskill];
		_x setSkill ["spotTime", 0.4 + _subskill];
	} forEach _crew;
	if !(isNull (driver _vec)) then {(driver _vec) setRank "LIEUTENANT"};
	if !(isNull (gunner _vec)) then {(gunner _vec) setRank "SERGEANT"};
	if !(isNull (effectiveCommander _vec)) then {(effectiveCommander _vec) setRank "CORPORAL"};
};

__TRACE_1("","fullCrew _vec")

_crew
