SUBSYSTEM_DEF(reactions)
	name = "Reactions"
	wait = 2 SECONDS
	priority = SS_PRIORITY_REACTIONS
	flags = SS_NO_INIT

	var/list/fusion_reactions = list()

/datum/controller/subsystem/reactions/proc/process_reactions(list/moles, temperature, heat_capacity, pressure = ONE_ATMOSPHERE, volume)
	var/has_fuel = FALSE
	var/has_oxidizer = FALSE
	var/old_temperature = temperature
	for(var/g in moles)
		var/decl/material/mat = GET_DECL(g)
		if(mat.combustion_energy)
			has_fuel = TRUE
		if(mat.oxidizer_power)
			has_oxidizer = TRUE
	if(!heat_capacity)
		heat_capacity = 0
		for(var/g in moles)
			var/decl/material/mat = GET_DECL(g)
			heat_capacity += moles[g] * mat.gas_specific_heat

	// Process combustion
	if(has_fuel && has_oxidizer)
		var/list/return_list = process_reaction_oxidation(moles, temperature, heat_capacity, pressure, volume)
		moles = return_list[1]
		temperature = return_list[2]
		heat_capacity = return_list[3]
		pressure = return_list[4]

	return list(moles, temperature, old_temperature)

#define PRE_EXPONENTIAL_FACTOR 10**7
// n = concentration * k
// concentration is in moles per liter
/datum/controller/subsystem/reactions/proc/get_reaction_rate(reactant_moles, activation_energy, temperature, volume)
	return min(reactant_moles, (reactant_moles/volume) * get_reaction_rate_constant(activation_energy, temperature))

// k = PRE_EXPONENTIAL_FACTOR * EULER**-(activation_energy/8.314*temperature)
/datum/controller/subsystem/reactions/proc/get_reaction_rate_constant(activation_energy, temperature)
	return PRE_EXPONENTIAL_FACTOR * EULER**(-(activation_energy/(8.314*temperature)))

#undef PRE_EXPONENTIAL_FACTOR

/datum/controller/subsystem/reactions/proc/process_reaction_oxidation(list/moles, temperature, heat_capacity, pressure = ONE_ATMOSPHERE, volume)
	var/list/oxidizers = list()
	var/list/oxidizers_by_power = list()
	var/list/fuels = list()
	var/thermal_energy = temperature * heat_capacity
	var/total_moles = 0
	for(var/g in moles)
		total_moles += moles[g]
		var/decl/material/mat = GET_DECL(g)
		if(mat.combustion_energy)
			fuels[g] = moles[g]
		if(mat.oxidizer_power)
			oxidizers_by_power[g] = mat.oxidizer_power

	// Sort oxidizers and use the one with the lowest oxidizer_power first.
	oxidizers_by_power = sortTim(oxidizers_by_power, /proc/cmp_numeric_asc, TRUE)
	for(var/g in oxidizers_by_power)
		oxidizers[g] = moles[g]

	// Remove all reactants from the fuel list temporarily
	moles.Remove(oxidizers, fuels)

	for(var/g in oxidizers)
		for(var/f in fuels)
			var/decl/material/fuel_mat = GET_DECL(f)
			if(thermal_energy * fuels[f] < fuel_mat.combustion_activation_energy * total_moles)
				continue
			var/need_fuel_moles = oxidizers[g] / fuel_mat.oxidizer_to_fuel_ratio
			var/actually_spent_fuel = min(fuels[f], need_fuel_moles, oxidizers_by_power[g] * get_reaction_rate(fuels[f], fuel_mat.combustion_activation_energy, temperature, volume))
			var/actually_spent_oxidizer = actually_spent_fuel * fuel_mat.oxidizer_to_fuel_ratio
			var/product
			if(fuel_mat.combustion_products[g])
				product = fuel_mat.combustion_products[g]
			else
				product = fuel_mat.combustion_products[/decl/material/gas/oxygen]
			fuels[f] -= actually_spent_fuel
			oxidizers[g] -= actually_spent_oxidizer
			moles[product] += actually_spent_fuel
			thermal_energy += actually_spent_fuel * fuel_mat.combustion_energy
			if(!oxidizers[g])
				break

	for(var/g in oxidizers)
		moles[g] += oxidizers[g]
	for(var/g in fuels)
		moles[g] += fuels[g]
	temperature = thermal_energy / heat_capacity

	return list(moles, temperature, heat_capacity, pressure)

/datum/controller/subsystem/reactions/proc/test_combustion(temperature=1150)
	return process_reactions(list(/decl/material/gas/hydrogen = 60, /decl/material/gas/oxygen = 30), temperature, 6600, volume = 1000)