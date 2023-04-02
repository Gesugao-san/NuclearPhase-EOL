/datum/event/grid_check	//NOTE: Times are measured in master controller ticks!
	announceWhen		= 5

/datum/event/grid_check/start()
	power_failure(0, severity, affecting_z)

/datum/event/grid_check/announce()
	command_announcement.Announce(replacetext(global.using_map.grid_check_message, "%STATION_NAME%", station_name()), "Power Failure", new_sound = global.using_map.grid_check_sound, zlevels = affecting_z)
