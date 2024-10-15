//Here we handle weather, time, events, heat exchanging, etc.

SUBSYSTEM_DEF(planet)
	name = "Planet"
	wait = 10 SECONDS
	priority = SS_PRIORITY_PLANET
	init_order = SS_INIT_MISC_LATE

	var/list/interpolating_areas = list()
	var/surface_time = 0

	var/weather_volatility = 0
	var/weather_volatility_mod = 1

/datum/controller/subsystem/planet/Initialize(start_timeofday)
	for(var/area/serenity/A in interpolating_areas)
		if(!length(A.contents))
			interpolating_areas -= A

#define TEMPERATURE_INTERPOLATION_MOD 0.1
/datum/controller/subsystem/planet/fire(resumed)
	//first of all, handle the heating of areas
	for(var/area/serenity/A in interpolating_areas)
		var/turf/T = pick(A.contents)
		if(istype(T, /turf/simulated/wall))
			continue //yeah we'd like to not heat up a wall
		var/datum/gas_mixture/environment = T.return_air()
		var/temperature_delta = using_map.exterior_atmosphere.temperature - environment.temperature
		environment.temperature += temperature_delta * A.temperature_interpolation_coefficient * TEMPERATURE_INTERPOLATION_MOD
		environment.update_values()
#undef TEMPERATURE_INTERPOLATION_MOD

	//weather next
	weather_volatility += weather_volatility_mod
	if(weather_volatility > 3)
		if(prob(weather_volatility * 5))
			using_map.weather_system.lightning_strike()
			weather_volatility -= 3
	using_map.weather_system.favorable_wind_speed = clamp(27 * weather_volatility, 0, 370)