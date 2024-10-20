//This is for roundstart starting
/datum/reactor_control_system/proc/autostart()
	var/obj/machinery/reactor_button/rswitch/current_switch
	current_switch = reactor_buttons["T-CP 1V-IN"]
	current_switch.do_action()
	current_switch = reactor_buttons["T-CP 1V-EX"]
	current_switch.do_action()
	current_switch = reactor_buttons["F-CP 1V-IN"]
	current_switch.do_action()
	current_switch = reactor_buttons["F-CP 1V-EX"]
	current_switch.do_action()
	current_switch = reactor_buttons["perimeter"] //lights
	current_switch.do_action()

	var/obj/machinery/atmospherics/binary/passive_gate/current_gate
	current_gate = reactor_valves["T-COOLANT V-IN"]
	current_gate.unlocked = TRUE
	current_gate = reactor_valves["T-COOLANT V-OUT"]
	current_gate.unlocked = TRUE

	var/obj/machinery/atmospherics/binary/pump/adv/P
	P = rcontrol.reactor_pumps["T-CP 1"]
	P.rpm = REACTOR_PUMP_RPM_MAX
	P.mode = REACTOR_PUMP_MODE_MAX
	P = rcontrol.reactor_pumps["T-CP 2"]
	P.rpm = REACTOR_PUMP_RPM_MAX
	P.mode = REACTOR_PUMP_MODE_MAX
	P.air2.adjust_gas_temp(/decl/material/liquid/water, 800000, 350) //add wotah to the loop
	P = rcontrol.reactor_pumps["F-CP 1"]
	P.rpm = REACTOR_PUMP_RPM_MAX
	P.mode = REACTOR_PUMP_MODE_MAX
	P = rcontrol.reactor_pumps["F-CP 2"]
	P.rpm = REACTOR_PUMP_RPM_MAX
	P.mode = REACTOR_PUMP_MODE_MAX

	var/obj/machinery/reactor_button/current_button
	current_button = reactor_buttons["T-CP 1"]
	current_button.icon_state = "switch3-max"
	current_button = reactor_buttons["F-CP 1"]
	current_button.icon_state = "switch3-max"

	var/obj/machinery/power/hybrid_reactor/R = reactor_components["core"]
	R.containment_field.adjust_gas(/decl/material/gas/hydrogen/deuterium, 100, 0)
	R.containment_field.adjust_gas(/decl/material/gas/hydrogen/tritium, 30, 0)
	R.containment_field.adjust_gas(/decl/material/gas/xenon, 30)
	R.containment_field.temperature = 95 MEGAKELVIN
	R.fast_neutrons = 70
	R.moderator_position = 0.05

	turbine1.kin_energy = 94298145000.0
	turbine1.feeder_valve_openage = 0.2
	turbine1.air1.adjust_gas_temp(/decl/material/liquid/water, 150000, 741)
	mode = REACTOR_CONTROL_MODE_SEMIAUTO

	spawn(30 SECONDS)
		current_switch = reactor_buttons["AUTOSCRAM"]
		current_switch.do_action()
		current_switch = reactor_buttons["BATTERY CHARGER"]
		current_switch.do_action()
		current_switch = reactor_buttons["generator1"]
		current_switch.do_action()