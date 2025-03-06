function set_vehicle_last_ship(vehic_array, empty = false){
	if (empty =false){
		var _last_ship_data = {
			uid : obj_ini.veh_lid[vehic_array[0]][vehic_array[1]],
			name : obj_ini.veh_lid[vehic_array[0]][vehic_array[1]],
		}
	} else {
		var _last_ship_data = {
			uid : "",
			name : "",
		}		
	}
	obj_ini.last_ship[vehic_array[0]][vehic_array[1]] = _last_ship_data;
}