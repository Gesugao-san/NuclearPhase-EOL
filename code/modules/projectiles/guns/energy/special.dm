/obj/item/gun/energy/ionrifle
	name = "ion rifle"
	desc = "The Mk60 EW Halicon is a man portable anti-armor weapon designed to disable mechanical threats. Not the best of its type."
	icon = 'icons/obj/guns/ion_rifle.dmi'
	icon_state = "ionrifle"
	item_state = "ionrifle"
	origin_tech = "{'combat':2,'magnets':4}"
	w_class = ITEM_SIZE_HUGE
	force = 10
	obj_flags =  OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BACK
	one_hand_penalty = 4
	charge_cost = 30
	max_shots = 8
	fire_delay = 30
	projectile_type = /obj/item/projectile/ion
	wielded_item_state = "ionrifle-wielded"
	combustion = 0

/obj/item/gun/energy/ionrifle/emp_act(severity)
	..(max(severity, 2)) //so it doesn't EMP itself, I guess

/obj/item/gun/energy/ionrifle/small
	name = "ion pistol"
	desc = "The Mk72 EW Preston is a personal defense weapon designed to disable mechanical threats."
	icon = 'icons/obj/guns/ion_pistol.dmi'
	icon_state = "ionpistol"
	item_state = "ionpistol"
	origin_tech = "{'combat':2,'magnets':4}"
	w_class = ITEM_SIZE_NORMAL
	force = 5
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	one_hand_penalty = 0
	charge_cost = 20
	max_shots = 4
	projectile_type = /obj/item/projectile/ion/small

/obj/item/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon = 'icons/obj/guns/decloner.dmi'
	icon_state = "decloner"
	item_state = "decloner"
	origin_tech = "{'combat':5,'materials':4,'powerstorage':3}"
	max_shots = 10
	projectile_type = /obj/item/projectile/energy/declone
	combustion = 0
	material = MAT_GOLD
	matter = list(MAT_URANIUM = MATTER_AMOUNT_REINFORCEMENT)

/obj/item/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon = 'icons/obj/guns/floral.dmi'
	icon_state = "floramut100"
	item_state = "floramut"
	charge_cost = 10
	max_shots = 10
	projectile_type = /obj/item/projectile/energy/floramut
	origin_tech = "{'materials':2,'biotech':3,'powerstorage':3}"
	modifystate = "floramut"
	self_recharge = 1
	material = MAT_STEEL
	matter = list(
		MAT_GLASS = MATTER_AMOUNT_REINFORCEMENT,
		MAT_URANIUM = MATTER_AMOUNT_TRACE
	)
	combustion = 0
	firemodes = list(
		list(mode_name="induce mutations", projectile_type=/obj/item/projectile/energy/floramut, modifystate="floramut"),
		list(mode_name="increase yield", projectile_type=/obj/item/projectile/energy/florayield, modifystate="florayield"),
		list(mode_name="induce specific mutations", projectile_type=/obj/item/projectile/energy/floramut/gene, modifystate="floramut"),
		)
	var/decl/plantgene/gene = null

/obj/item/gun/energy/floragun/resolve_attackby(atom/A)
	if(istype(A,/obj/machinery/portable_atmospherics/hydroponics))
		return FALSE // do afterattack, i.e. fire, at pointblank at trays.
	return ..()

/obj/item/gun/energy/floragun/afterattack(obj/target, mob/user, adjacent_flag)
	//allow shooting into adjacent hydrotrays regardless of intent
	if(adjacent_flag && istype(target,/obj/machinery/portable_atmospherics/hydroponics))
		user.visible_message("<span class='danger'>\The [user] fires \the [src] into \the [target]!</span>")
		Fire(target,user)
		return
	..()

/obj/item/gun/energy/floragun/verb/select_gene()
	set name = "Select Gene"
	set category = "Object"
	set src in view(1)

	var/genemask = input("Choose a gene to modify.") as null|anything in SSplants.plant_gene_datums

	if(!genemask)
		return

	gene = SSplants.plant_gene_datums[genemask]

	to_chat(usr, "<span class='info'>You set the [src]'s targeted genetic area to [genemask].</span>")

	return

/obj/item/gun/energy/floragun/consume_next_projectile()
	. = ..()
	var/obj/item/projectile/energy/floramut/gene/G = .
	if(istype(G))
		G.gene = gene

/obj/item/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon = 'icons/obj/guns/launchers.dmi'
	icon_state = "riotgun"
	item_state = "c20r"
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_HUGE
	projectile_type = /obj/item/projectile/meteor
	cell_type = /obj/item/cell/potato
	self_recharge = 1
	recharge_time = 5 //Time it takes for shots to recharge (in ticks)
	charge_meter = 0
	combustion = 0

/obj/item/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_BELT

/obj/item/gun/energy/mindflayer
	name = "mind flayer"
	desc = "A custom-built weapon of some kind."
	icon = 'icons/obj/guns/xray.dmi'
	icon_state = "xray"
	origin_tech = "{'combat':5,'magnets':4}"
	projectile_type = /obj/item/projectile/beam/mindflayer

/obj/item/gun/energy/toxgun
	name = "phoron pistol"
	desc = "A specialized firearm designed to fire lethal bolts of phoron."
	icon = 'icons/obj/guns/toxgun.dmi'
	icon_state = "toxgun"
	w_class = ITEM_SIZE_NORMAL
	origin_tech = "{'combat':5,'phorontech':4}"
	projectile_type = /obj/item/projectile/energy/phoron
	material = MAT_STEEL
	matter = list(
		MAT_GLASS = MATTER_AMOUNT_REINFORCEMENT,
		MAT_PHORON = MATTER_AMOUNT_TRACE
	)

/obj/item/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "A mining tool capable of expelling concentrated plasma bursts. You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	charge_meter = 0
	icon = 'icons/obj/guns/plasmacutter.dmi'
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	fire_sound = 'sound/weapons/plasma_cutter.ogg'
	slot_flags = SLOT_BELT|SLOT_BACK
	w_class = ITEM_SIZE_NORMAL
	force = 8
	origin_tech = "{'materials':4,'phorontech':4,'engineering':6,'combat':3}"
	material = MAT_STEEL
	projectile_type = /obj/item/projectile/beam/plasmacutter
	max_shots = 10
	self_recharge = 1
	material = MAT_STEEL
	matter = list(
		MAT_GLASS = MATTER_AMOUNT_REINFORCEMENT,
		MAT_GOLD = MATTER_AMOUNT_TRACE,
		MAT_PHORON = MATTER_AMOUNT_TRACE
	)
	var/datum/effect/effect/system/spark_spread/spark_system

/obj/item/gun/energy/plasmacutter/mounted
	name = "mounted plasma cutter"
	use_external_power = 1
	max_shots = 4
	has_safety = FALSE

/obj/item/gun/energy/plasmacutter/Initialize()
	. = ..()
	spark_system = new /datum/effect/effect/system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/gun/energy/plasmacutter/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/gun/energy/plasmacutter/proc/slice(var/mob/M = null)
	if(!safety() && power_supply.checked_use(charge_cost)) //consumes a shot per use
		if(M)
			M.welding_eyecheck()//Welding tool eye check
			if(check_accidents(M, "[M] loses grip on [src] from its sudden recoil!",SKILL_CONSTRUCTION, 60, SKILL_ADEPT))
				return 0
		spark_system.start()
		return 1
	handle_click_empty(M)
	return 0

/obj/item/gun/energy/plasmacutter/is_special_cutting_tool()
	return TRUE

/obj/item/gun/energy/incendiary_laser
	name = "dispersive blaster"
	desc = "The A&M 'Shayatin' was the first of a now-banned class of dispersive laser weapons which, instead of firing a focused beam, scan over a target rapidly with the goal of setting it ablaze."
	icon = 'icons/obj/guns/incendiary_laser.dmi'
	icon_state = "incen"
	item_state = "incen"
	safety_icon = "safety"
	origin_tech = "{'combat':7,'magnets':4,'esoteric':4}"
	material = MAT_ALUMINIUM
	matter = list(
		MAT_PLASTIC = MATTER_AMOUNT_REINFORCEMENT,
		MAT_DIAMOND = MATTER_AMOUNT_TRACE
	)
	projectile_type = /obj/item/projectile/beam/incendiary_laser
	max_shots = 4