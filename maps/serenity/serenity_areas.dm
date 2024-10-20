/area/example/first
	name = "\improper Testing Site First Floor"
	icon_state = "fsmaint"

/area/example/second
	name = "\improper Testing Site Second Floor"
	icon_state = "surgery"

/area/example/third
	name = "\improper Testing Site Third Floor"
	icon_state = "storage"

/area/turbolift/example
	name = "\improper Testing Site Elevator"
	icon_state = "shuttle"
	requires_power = FALSE
	dynamic_lighting = TRUE
	sound_env = STANDARD_STATION
	area_flags = AREA_FLAG_RAD_SHIELDED | AREA_FLAG_ION_SHIELDED
	ambience = list(
		'sound/ambience/ambigen3.ogg',
		'sound/ambience/ambigen4.ogg',
		'sound/ambience/ambigen5.ogg',
		'sound/ambience/ambigen6.ogg',
		'sound/ambience/ambigen7.ogg',
		'sound/ambience/ambigen8.ogg',
		'sound/ambience/ambigen9.ogg',
		'sound/ambience/ambigen10.ogg',
		'sound/ambience/ambigen11.ogg',
		'sound/ambience/ambigen12.ogg'
	)
	arrival_sound = null
	lift_announce_str = null

	base_turf = /turf/simulated/open

/area/turbolift/example/first
	name = "Testing Site First Floor Lift"
	base_turf = /turf/simulated/floor

/area/turbolift/example/second
	name = "Testing Site Second Floor Lift"

/area/turbolift/example/third
	name = "Testing Site Third Floor Lift"

/area/shuttle/ferry
	name = "\improper Testing Site Ferry"
	icon_state = "shuttle"

/area/serenity
	name = "'Serenity' survival shelter"
	icon_state = "dark128"
	base_turf = /turf/simulated/floor/plating
	ambience = list('sound/ambience/ominous1.ogg', 'sound/ambience/ominous2.ogg', 'sound/ambience/ominous3.ogg', 'sound/ambience/rumble1.ogg', 'sound/ambience/rumble2.ogg', 'sound/ambience/rumble3.ogg', 'sound/ambience/rumble4.ogg')
	area_flags = AREA_FLAG_RAD_SHIELDED
	is_outside = OUTSIDE_NO
	var/temperature_interpolation_coefficient = 0.004 //Will heat up 24 degrees every 10 minutes and cool 11 degrees every 10 minutes. Adjust for higher/lower areas.

/area/serenity/Initialize()
	. = ..()
	SSplanet.interpolating_areas += src
	SSpersistence.item_pool_areas += src
	START_PROCESSING(SSsound, src)

/area/serenity/has_gravity()
	return TRUE

/area/serenity/shelter/expeditionpreparation
	name = "Expedition Preparation"
	icon_state = "research_dock"
/area/serenity/shelter/garage
	name = "Vehicle Garage"
	icon_state = "mechbay"
/area/serenity/shelter/upperhall
	name = "Upper Hall"

/area/serenity/shelter/entrance_zone
	name = "Entrance Zone"
/area/serenity/shelter/entrance_zone/viewing_area
	name = "Viewing Area"

/area/serenity/shelter/staircase
	name = "Staircase"
	icon_state = "shuttle"
	temperature_interpolation_coefficient = 0.003
/area/serenity/shelter/comms
	name = "Communications"

/area/serenity/shelter/habitationdeck
	name = "Habitation Deck"
	icon_state = "dk_yellow"
	temperature_interpolation_coefficient = 0.002 //we're considerably lower
/area/serenity/shelter/habitationdeck/crew
	name = "Crew Quarters"
	icon_state = "crew_quarters"
	sound_env = MEDIUM_SOFTFLOOR
/area/serenity/shelter/habitationdeck/kitchen
	name = "Kitchen"
	icon_state = "kitchen"
/area/serenity/shelter/habitationdeck/freezer
	name = "Food Freezer"
	icon_state = "LP"
	temperature_interpolation_coefficient = 0.001 //insulated well
/area/serenity/shelter/habitationdeck/messhall
	name = "Mess Hall"
	icon_state = "bar"

/area/serenity/shelter/engineering/reactor
	sound_env = LARGE_ENCLOSED
	name = "Reactor Chamber"
	lightswitch = FALSE
	icon_state = "engine"
	background_radiation = 1.13
	temperature_interpolation_coefficient = 0.002 //insulated well

/area/serenity/shelter/engineering/reactor/power_change()
	. = ..()
	if(power_equip)
		forced_ambience = list('sound/ambience/reactorchamberfans.ogg')
		description = "You feel a heavy wind current flowing directly underneath you from several huge fans ventilating the vast space that you've entered. The entire chamber perimeter is dimly lit by small red lights, as if they were placed there specifically to be a little more sane in such an inconceivable environment. Everything below is barely visible, looks like it goes really deep..."
	else
		forced_ambience = null
		description = "You feel a strong metal smell in the still air of the vast space that you've entered. The entire chamber perimeter is dimly lit by small red lights, as if they were placed there specifically to be a little more sane in such an inconceivable environment. Everything below is completely dark, looks like it goes really deep..."

/area/serenity/shelter/engineering
	name = "Engineering"
	icon_state = "engineering"

/area/serenity/shelter/engineering/pumps_a
	name = "Pump Station A"
	icon_state = "pumpA"
	sound_env = LARGE_ENCLOSED
/area/serenity/shelter/engineering/pumps_b
	name = "Pump Station B"
	icon_state = "pumpB"
	sound_env = LARGE_ENCLOSED

/area/serenity/shelter/engineering/reactor_operations
	name = "Reactor Operations"
	icon_state = "hallC1"

/area/serenity/shelter/engineering/reactor_operations/cavern
	name = "Reactor Operations Cavern"
	icon_state = "hallC2"
	sound_env = LARGE_ENCLOSED

/area/serenity/shelter/engineering/reactor_operations/reactormonitoring
	name = "Reactor Control Room"
	area_flags = AREA_FLAG_RAD_SHIELDED
	background_radiation = 0.07

/area/serenity/shelter/engineering/reactor_operations/office
	name = "Reactor Operations Offices"
	icon_state = "heads"

/area/serenity/shelter/engineering/reactor_operations/office/chief_engineer
	name = "Chief Engineer Office"
	icon_state = "heads_ce"

/area/serenity/shelter/engineering/reactor_operations/office/senior_engineer
	name = "Senior Engineer Office"
	icon_state = "heads_ce"

/area/serenity/shelter/engineering/electrical
	name = "Electrical Centre"
	icon_state = "substation"
/area/serenity/shelter/engineering/service_tunnels
	name = "Service Tunnels"
	icon_state = "maintcentral"
/area/serenity/shelter/engineering/service_tunnels/heat_exchanger
	name = "Heat Exchanger Maintenance"
	icon_state = "heat_exchanger"
/area/serenity/shelter/engineering/atmos
	name = "Atmospheric Monitoring"
	icon_state = "atmos"
/area/serenity/shelter/engineering/atmos/climatecontrol
	name = "Climate Control"
/area/serenity/shelter/engineering/atmos/cryogenic
	name = "Cryogenic Systems"

/area/serenity/shelter/engineering/climatecontrol
	name = "Climate Control"
/area/serenity/shelter/engineering/electrical/turbinehall
	name = "Turbine Hall"
	sound_env = LARGE_ENCLOSED

/area/serenity/shelter/service_tunnels
	name = "Reactor Service Tunnels"
	ambience = list('sound/ambience/maint1.ogg', 'sound/ambience/maint2.ogg')
	temperature_interpolation_coefficient = 0.002 //they're deep

/area/serenity/shelter/maintenance
	name = "Maintenance"
	ambience = list()
	var/powered_ambience
	temperature_interpolation_coefficient = 0.002 //they're deep

/area/serenity/shelter/maintenance/power_change()
	. = ..()
	if(power_equip)
		forced_ambience = powered_ambience
	else
		forced_ambience = null

/area/serenity/shelter/maintenance/Initialize()
	. = ..()
	powered_ambience = list(pick('sound/machines/vent/running1.wav', 'sound/machines/vent/running2.wav', 'sound/machines/vent/running3.wav')) //has to be a list, sorry
	forced_ambience = powered_ambience

/area/serenity/shelter/brig
	name = "Security"
	area_flags = AREA_FLAG_SECURITY
	temperature_interpolation_coefficient = 0.002 //they're deep
/area/serenity/shelter/brig/interrogation
	name = "Security Interrogation"
/area/serenity/shelter/brig/medbay
	name = "Security Medbay"
/area/serenity/shelter/brig/office
	name = "Security Office"
/area/serenity/shelter/brig/reception
	name = "Security Reception"
/area/serenity/shelter/brig/breakroom
	name = "Security Break Room"
/area/serenity/shelter/brig/armory
	name = "Armory"
/area/serenity/shelter/brig/preparation
	name = "Security Preparations"
/area/serenity/shelter/brig/prison
	name = "Security Prison"
	area_flags = AREA_FLAG_PRISON
/area/serenity/shelter/brig/sergeantroom
	name = "Security Sergeant Room"
/area/serenity/shelter/brig/barracks
	name = "Security Barracks"

/area/serenity/shelter/command
	name = "Command"
	temperature_interpolation_coefficient = 0.001 //deep and insulated
/area/serenity/shelter/command/commcenter
	name = "Comm Center"

/area/serenity/shelter/it_operations
	name = "IT Operations"
	icon_state = "ai_foyer"

/area/serenity/shelter/it_operations/faid
	name = "FAID Office"
	icon_state = "heads_sr"

/area/serenity/shelter/it_operations/server
	name = "Server Room"
	icon_state = "ai_server"

/area/serenity/shelter/cargo/warehouse
	name = "Main Warehouse"
	name = "storage"

/area/serenity/shelter/cargo/rest_area
	name = "Supply Operations Break Room"
	icon_state = "auxstorage"

/area/serenity/shelter/labs
	name = "Laboratories"
	icon_state = "research"
/area/serenity/shelter/labs/particle_physics
	name = "Particle Physics Laboratory"
	icon_state = "devlab"

/area/serenity/shelter/labs/particle_physics/particle_accelerator
	name = "Particle Accelerator Chamber"
	background_radiation = 1.83

/area/serenity/shelter/labs/genetics
	name = "General Genetics Laboratory"
	icon_state = "toxlab"

/area/serenity/shelter/mining
	name = "Mining Preparations"
	icon_state = "outpost_mine_main"

/area/serenity/shelter/mining/processing
	name = "Mining Processing"
	icon_state = "outpost_mine_west"

/area/serenity/shelter/mining/staircase
	name = "Mining Staircase"
	icon_state = "outpost_mine_north"

/area/serenity/shelter/mining/drill
	name = "Mining Drilling Site"
	icon_state = "outpost_mine_west"

/area/serenity/shelter/medbay
	name = "Medbay"
	icon_state = "medbay3"
	temperature_interpolation_coefficient = 0.001 //deep and insulated

/area/serenity/shelter/medbay/lobby
	name = "Medbay Lobby"
	icon_state = "medbay4"

/area/serenity/shelter/medbay/therapy
	name = "Medbay Therapy"
	icon_state = "medbay"

/area/serenity/shelter/medbay/surgery
	name = "Surgery"
	icon_state = "surgery"

/area/serenity/shelter/medbay/break_room
	name = "Medbay Break Room"
	icon_state = "medbay4"

/area/serenity/shelter/medbay/office
	name = "Medbay Office"
	icon_state = "medbay"

/area/serenity/shelter/medbay/morgue
	name = "Morgue"
	icon_state = "medbay4"

/area/serenity/shelter/medbay/genetics
	name = "Genetics"
	icon_state = "medbay"

/area/serenity/shelter/factory
	name = "Factory"
	temperature_interpolation_coefficient = 0.001 //deep and insulated

/area/serenity/shelter/science
	name = "Research Labs"
	icon_state = "research"
	temperature_interpolation_coefficient = 0.001 //deep and insulated

/area/serenity/maintenance
	name = "Maintenance"
	temperature_interpolation_coefficient = 0.002
	sound_env = SMALL_ENCLOSED
	var/weight_low = 2
	var/weight_high = 4

/area/serenity/maintenance/Entered(A)
	if(!istype(A,/mob/living))	return
	var/mob/living/L = A
	if(!istype(L.lastarea, /area/serenity/maintenance))
		SSmaint_monster.mobs_to_weight[L] = 1
	. = ..()

/area/serenity/maintenance/Exited(A)
	if(!istype(A,/mob/living))	return
	var/mob/living/L = A
	if(!istype(L.lastarea, /area/serenity/maintenance))
		SSmaint_monster.mobs_to_weight -= L
	. = ..()

/area/serenity/maintenance/sublevel_one
	name = "Sublevel 1"
	temperature_interpolation_coefficient = 0.0015
	sound_env = TUNNEL_ENCLOSED
	weight_low = 4
	weight_high = 6

/area/serenity/maintenance/sublevel_two
	name = "Sublevel 2"
	temperature_interpolation_coefficient = 0.001
	sound_env = TUNNEL_ENCLOSED
	weight_low = 6
	weight_high = 8

/area/serenity/maintenance/sublevel_three
	name = "Sublevel 3"
	temperature_interpolation_coefficient = 0.0005
	sound_env = TUNNEL_ENCLOSED
	weight_low = 8
	weight_high = 10

/area/turbolift/e1
	lift_floor_label = "Tech Operations Lobby"
/area/turbolift/e2
	lift_floor_label = "Machine Hall"
/area/turbolift/e3
	lift_floor_label = "Reactor Operations"

/area/surface
	name = "Surface"
	var/list/hot_ambience = list('sound/ambience/magma.ogg')
	var/list/cold_ambience = list('sound/music/calmnight.ogg', 'sound/music/facilityoutside.ogg', 'sound/music/outside1.ogg', 'sound/music/outside2.ogg', 'sound/music/outside3.ogg')
	forced_ambience = list('sound/music/calmnight.ogg', 'sound/music/facilityoutside.ogg', 'sound/music/outside1.ogg', 'sound/music/outside2.ogg', 'sound/music/outside3.ogg')
	ambience_volume = 75
	has_gravity = TRUE
	is_outside = OUTSIDE_YES
	var/phase = 0
	base_turf = /turf/exterior/surface
	should_condense = FALSE
	area_flags = AREA_FLAG_IS_NOT_PERSISTENT | AREA_FLAG_IS_BACKGROUND
	var/list/cold_descriptions = list(
		"The most beautiful hellscape you've ever seen, something that only someone truly worthy deserves to witness. There are a ton of slow-moving cloud-like formations, are they made of liquid?",
		"You step out to the vast and barren wasteland that the world turned into. You can't help but feel sad and amazed at the same time. There is something special and romantic about these undescribable views.",
		"You witness something from your dreams, back from when you imagined how the surface looked like. It looks surprisingly beautiful and lively, is it really that bad around here?"
	)
	var/list/hot_descriptions = list()
	background_radiation = 1490

/area/surface/location //more intense
	cold_ambience = list('sound/music/lurk.ogg')

/area/surface/location/skyscraper

/area/surface/location/space_center

/area/surface/location/data_center
	cold_ambience = list('sound/music/thestorycontinues.mp3')
	requires_power = FALSE

/area/surface/Initialize()
	. = ..()
	surface_areas += src

/area/surface/do_area_blurb(mob/living/L)
	if(L?.get_preference_value(/datum/client_preference/area_info_blurb) != PREF_YES)
		return

	if(!(L.ckey in blurbed_stated_to))
		blurbed_stated_to += L.ckey
		if(phase == 1) //hot
			to_chat(L, SPAN_SUBTLE("[pick(hot_descriptions)]"))
		else
			to_chat(L, SPAN_SUBTLE("[pick(cold_descriptions)]"))

/area/surface/proc/switch_phases(var/newphase)
	if(newphase == 1) //hot
		forced_ambience = hot_ambience
	else
		forced_ambience = cold_ambience
	phase = newphase

/area/surface/has_gravity()
	return TRUE

/area/surface/Entered(mob/A)
	. = ..()
	if(ishuman(A))
		var/obj/abstract/weather_system/weather = using_map.weather_system
		weather.windloop_play_atoms += A
		surface_mobs += A
		for(var/obj/item/gun/W in A.contents)
			if(W.hot_color && phase)
				W.color = W.hot_color

/area/surface/Exited(mob/A)
	. = ..()
	if(ishuman(A))
		var/obj/abstract/weather_system/weather = using_map.weather_system
		weather.windloop_play_atoms -= A
		surface_mobs -= A
		for(var/obj/item/gun/W in A.contents)
			if(W.hot_color)
				W.color = null

/*/area/surface/do_area_blurb(mob/living/L)
	var/blurb = ""'sound/ambience/ambigen1.ogg'
	if(air.temperature > 400)
		blurb = "<span class='boldannounce'>[hot_blurb]</span>"
	else
		blurb = "<span class='boldannounce'>[cold_blurb]</span>"
	to_chat(L, blurb)*/

/area/surface/tent

/area/skyscraper
	name = "Skyscraper"
	requires_power = FALSE
	forced_ambience = list('sound/music/skyscraper_theme_1.ogg')
	should_condense = FALSE

/area/limb
	name = "Limb"
	requires_power = FALSE
	should_condense = FALSE
	area_flags = AREA_FLAG_IS_NOT_PERSISTENT | AREA_FLAG_IS_BACKGROUND
	has_gravity = TRUE
	forced_ambience = list('sound/music/ocean.mp3')

/area/ship/theseus
	name = "UN Typhos"
	has_gravity = TRUE
	forced_ambience = list('sound/ambience/weather/storm_inside.wav')
	ambience_volume = 10
	background_radiation = 211
	requires_power = 0

/area/ship/theseus/warp_drive
	background_radiation = 40309
	forced_ambience = list('sound/ambience/ambidanger4.ogg')
	ambience_volume = 45
	lightswitch = FALSE

/area/space/theseus
	name = "Gas Cloud"
	forced_ambience = list('sound/ambience/weather/storm_outside.wav')
	ambience_volume = 60

/area/ship/icarus
	name = "UN Icarus"
	icon_state = "icarus_body"
	has_gravity = FALSE
	requires_power = 0

/area/ship/icarus/ring
	has_gravity = TRUE
	icon_state = "icarus_ring"