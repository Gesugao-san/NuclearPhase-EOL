/decl/material/liquid/fuel
	name = "welding fuel"
	lore_text = "A stable hydrazine-based compound whose exact manufacturing specifications are a closely-guarded secret. One of the most common fuels in human space. Extremely flammable."
	taste_description = "gross metal"
	color = "#660000"
	touch_met = 5
	fuel_value = 1
	burn_product = /decl/material/gas/carbon_monoxide
	gas_flags = XGM_GAS_FUEL
	combustion_energy = 70000
	exoplanet_rarity = MAT_RARITY_UNCOMMON
	uid = "chem_fuel"

	glass_name = "welder fuel"
	glass_desc = "Unless you are an industrial tool, this is probably not safe for consumption."
	value = 1.5

/decl/material/liquid/fuel/affect_blood(var/mob/living/M, var/removed, var/datum/reagents/holder)
	M.adjustToxLoss(2 * removed)

/decl/material/liquid/fuel/explosion_act(obj/item/chems/holder, severity)
	. = ..()
	if(.)
		var/volume = REAGENT_VOLUME(holder?.reagents, type)
		if(volume <= 50)
			return
		var/turf/T = get_turf(holder)
		var/datum/gas_mixture/products = new(_temperature = 5 * FLAMMABLE_GAS_FLASHPOINT)
		var/gas_moles = 3 * volume
		products.adjust_multi(/decl/material/gas/nitricoxide, 0.1 * gas_moles, /decl/material/gas/nitrodioxide, 0.1 * gas_moles, /decl/material/gas/nitrogen, 0.6 * gas_moles, /decl/material/gas/hydrogen, 0.02 * gas_moles)
		T.assume_air(products)
		if(volume > 500)
			explosion(T,1,2,4)
		else if(volume > 100)
			explosion(T,0,1,3)
		else if(volume > 50)
			explosion(T,-1,1,2)
		holder?.reagents?.remove_reagent(type, volume)

/decl/material/liquid/fuel/hydrazine
	name = "hydrazine"
	lore_text = "A toxic, colorless, flammable liquid with a strong ammonia-like odor, in hydrate form."
	taste_description = "sweet tasting metal"
	color = "#808080"
	metabolism = REM * 0.2
	touch_met = 5
	value = 1.2
	fuel_value = 1.2
	uid = "chem_hydrazine"



/decl/material/liquid/pentaborane
	name = "pentaborane"
	lore_text = "Pentaborane is an extremely toxic, extremely flammable, corrosive substance. Its second name is 'Green Dragon' because of its flame color."
	taste_description = "sour milk"
	color = "#ffffff"
	touch_met = 5
	fuel_value = 4
	fire_color = "#1ef002"
	fire_alpha = 220
	toxicity = 8
	burn_product = /decl/material/liquid/acid/boric
	gas_flags = XGM_GAS_FUEL
	combustion_energy = 4284
	exoplanet_rarity = MAT_RARITY_UNCOMMON
	uid = "pentaborane"
	glass_name = "fiery death"
	glass_desc = "If you see this, you are probably already engulfed in green flames."
	value = 1.5
	ignition_point = 305

/decl/material/liquid/pentaborane/affect_ingest(mob/living/carbon/human/H, removed, datum/reagents/holder) //stomach temperature is enough, WE COMBUST
	. = ..()
	H.adjust_fire_stacks(removed * 10)
	H.IgniteMob()
	H.visible_message(SPAN_DANGER("Green flames rush out of [H]'s mouth!"))

/decl/material/gas/diborane
	name = "diborane"
	lore_text = "Diborane, is the chemical compound with the formula B2H6. It is a toxic, colorless, and pyrophoric gas with a repulsively sweet odor."
	taste_description = "repulsive sweetness"
	color = "#ffffff"
	touch_met = 5
	fuel_value = 2
	fire_color = "#cbee8a"
	fire_alpha = 140
	toxicity = 4
	burn_product = /decl/material/liquid/acid/boric
	heating_products = list(/decl/material/liquid/pentaborane = 0.7, /decl/material/solid/boron = 0.3)
	heating_point = 470
	gas_flags = XGM_GAS_FUEL
	combustion_energy = 3067
	exoplanet_rarity = MAT_RARITY_UNCOMMON
	uid = "diborane"
	value = 1.3
	ignition_point = 346