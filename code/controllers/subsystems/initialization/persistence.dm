#define ITEM_POOL_PATH "data/item_pool.txt"

SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = SS_INIT_PERSISTENCE
	flags = SS_NO_FIRE | SS_NEEDS_SHUTDOWN

	var/elevator_fall_path = "data/elevator_falls_tracking.txt"
	var/elevator_fall_shifts = -1 // This is snowflake, but oh well.
	var/list/tracking_values = list()

	var/list/loaded_item_pool = null //An actual item pool loaded from the previous round in Initialize(). Null if there isn't one
	var/list/item_pool_areas = list() //Areas which should be used when creating an item pool
	var/list/item_pool_blacklist = list(/obj/item/paper,
										/obj/item/paper_bin,
										/obj/item/toy,
										/obj/item/kitchen,
										/obj/item/flashlight/lamp,
										/obj/item/book,
										/obj/item/stool,
										/obj/item/pen,
										/obj/item/wrapping_paper,
										/obj/item/stock_parts,
										/obj/item/stack/package_wrap,
										/obj/item/stack/tape_roll/barricade_tape/toilet, //infinite toilet paper
										/obj/item/stack/material, //for now ---
										/obj/item/stack/cable_coil,
										/obj/item/stack/net_cable_coil,
										/obj/item/chems,
										/obj/item/co2filter/large,
										/obj/item/cell/crap,
										/obj/item/extinguisher,
										/obj/item/tank/firefighting,
										/obj/item/chems/condiment,
										/obj/item/storage/mirror,
										/obj/item/storage/lockbox/vials,
										/obj/item/chems/drinks/glass2,
										/obj/item/chems/drinks/shaker,
										/obj/random/mre,
										/obj/item/clothing, //for now
										/obj/item/hand_labeler,
										/obj/item/wrench,
										/obj/item/sticky_pad,
										/obj/item/clipboard,
										/obj/item/ammo_casing,
										/obj/item/storage/internal, //how
										/obj/item/towel) //Blacklisted items
	var/list/item_pool_spawners = list() //An associative list of item pool spawners. Should look like this:
										 //item_pool_spawners[type] = amount_of_spawners_of_that_type

/datum/controller/subsystem/persistence/Initialize()
	. = ..()

	decls_repository.get_decls_of_subtype(/decl/persistence_handler) // Initialize()s persistence categories.

	// Begin snowflake.
	var/elevator_file = safe_file2text(elevator_fall_path, FALSE)
	if(elevator_file)
		elevator_fall_shifts = text2num(elevator_file)
	else
		elevator_fall_shifts = initial(elevator_fall_shifts)
	if(isnull(elevator_fall_shifts))
		elevator_fall_shifts = initial(elevator_fall_shifts)
	elevator_fall_shifts++
	// End snowflake.

	//Load the item pool
	if(fexists(ITEM_POOL_PATH))
		loaded_item_pool = list()
		var/list/extracted_list = file2list(ITEM_POOL_PATH, ", ") //This is a list of STRING but we need PATH
		for(var/string in extracted_list)
			loaded_item_pool += text2path(string)

/datum/controller/subsystem/persistence/Shutdown()
	var/list/all_persistence_datums = decls_repository.get_decls_of_subtype(/decl/persistence_handler)
	for(var/thing in all_persistence_datums)
		var/decl/persistence_handler/P = all_persistence_datums[thing]
		P.Shutdown()

	// Refer to snowflake above.
	if(fexists(elevator_fall_path))
		fdel(elevator_fall_path)
	text2file("[elevator_fall_shifts]", elevator_fall_path)

	make_item_pool()

/datum/controller/subsystem/persistence/proc/track_value(var/atom/value, var/track_type)

	var/turf/T = get_turf(value)
	if(!T)
		return

	var/area/A = get_area(T)
	if(!A || (A.area_flags & AREA_FLAG_IS_NOT_PERSISTENT))
		return

	if(!isStationLevel(T.z))
		return

	if(!tracking_values[track_type])
		tracking_values[track_type] = list()
	tracking_values[track_type] |= value

/datum/controller/subsystem/persistence/proc/is_tracking(var/atom/value, var/track_type)
	. = (value in tracking_values[track_type])

/datum/controller/subsystem/persistence/proc/forget_value(var/atom/value, var/track_type)
	if(tracking_values[track_type])
		tracking_values[track_type] -= value

/datum/controller/subsystem/persistence/proc/show_info(var/mob/user)

	if(!check_rights(R_INVESTIGATE, C = user))
		return

	var/list/dat = list("<table width = '100%'>")
	var/can_modify = check_rights(R_ADMIN, 0, user)
	var/list/all_persistence_datums = decls_repository.get_decls_of_subtype(/decl/persistence_handler)
	for(var/thing in all_persistence_datums)
		var/decl/persistence_handler/P = all_persistence_datums[thing]
		if(P.has_admin_data)
			dat += P.GetAdminSummary(user, can_modify)
	dat += "</table>"

	var/datum/browser/popup = new(user, "admin_persistence", "Persistence Data")
	popup.set_content(jointext(dat, null))
	popup.open()

/datum/controller/subsystem/persistence/proc/make_item_pool()
	var/text_to_write = jointext(collect_item_pool(), ", ")
	fdel(ITEM_POOL_PATH)
	text2file(text_to_write, ITEM_POOL_PATH)

/datum/controller/subsystem/persistence/proc/collect_item_pool()
	var/list/return_list = list()
	for(var/area/A in item_pool_areas)
		for(var/obj/item/I in A.contents)
			try_pool_item(I, return_list)
			for(var/obj/item/IC in I.contents)
				try_pool_item(IC, return_list)
				for(var/obj/item/ICC in IC.contents)
					try_pool_item(ICC, return_list)

		for(var/obj/structure/closet/C in A.contents)
			for(var/obj/item/I in C.contents)
				try_pool_item(I, return_list)
				for(var/obj/item/IC in I.contents)
					try_pool_item(IC, return_list)
					for(var/obj/item/ICC in IC.contents)
						try_pool_item(ICC, return_list)
	return return_list

/datum/controller/subsystem/persistence/proc/try_pool_item(obj/item/I, list/return_list)
	if(istype(I.loc, /obj/machinery)) //Machinery components shouldn't be saved
		return
	if(I.anchored) //Mines, etc
		return
	for(var/b_type in item_pool_blacklist)
		if(istype(I, b_type))
			return
	return_list += I.type