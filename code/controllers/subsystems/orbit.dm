SUBSYSTEM_DEF(orbit)
	name = "Orbit"
	wait = 10 SECONDS
	priority = SS_PRIORITY_ORBIT
	flags = SS_NO_INIT | SS_NO_FIRE
	runlevels = RUNLEVEL_GAME

	var/typhos_area
	var/typhos_reached = FALSE
	var/typhos_destructing = FALSE

	var/icarus_area
	var/icarus_reached = FALSE
	var/icarus_broken_pylons = list()

/datum/controller/subsystem/orbit/proc/reach_typhos()
	if(typhos_reached)
		return
	typhos_reached = TRUE

/datum/controller/subsystem/orbit/proc/start_typhos_destruction()
	if(typhos_destructing)
		return
	typhos_destructing = TRUE

/datum/controller/subsystem/orbit/proc/can_warp()
	if(length(icarus_broken_pylons))
		return FALSE