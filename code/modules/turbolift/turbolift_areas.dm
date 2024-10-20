// Used for creating the exchange areas.
/area/turbolift
	name = "Turbolift"
	base_turf = /turf/simulated/open
	requires_power = 0
	sound_env = SMALL_ENCLOSED
	is_outside = OUTSIDE_NO

	var/lift_floor_label = null
	var/lift_floor_name = null
	var/lift_announce_str = "Ding!"
	var/arrival_sound = 'sound/machines/ding.ogg'

/area/turbolift/avalon/main
	name = "Main Shelter Elevator"

/area/turbolift/avalon/main/a1
/area/turbolift/avalon/main/a2
	lift_floor_label = "Sector F"
	lift_floor_name = "Factory, Mining"
/area/turbolift/avalon/main/a3
/area/turbolift/avalon/main/a4
/area/turbolift/avalon/main/a5
/area/turbolift/avalon/main/a6
	lift_floor_label = "Sector E"
	lift_floor_name = "Medbay, Laboratories, Hydroponics"
/area/turbolift/avalon/main/a7
/area/turbolift/avalon/main/a8
	lift_floor_label = "Sector D"
	lift_floor_name = "Security, Administration"
/area/turbolift/avalon/main/a9
/area/turbolift/avalon/main/a10
	lift_floor_label = "Sector C"
	lift_floor_name = "Life Support, Reactor Unit, Engineering"
/area/turbolift/avalon/main/a11
/area/turbolift/avalon/main/a12
	lift_floor_label = "Sector B"
	lift_floor_name = "Habitation, Mess Hall"
/area/turbolift/avalon/main/a13
/area/turbolift/avalon/main/a14
	lift_floor_label = "Sector A"
	lift_floor_name = "Surface, Communications"

/area/turbolift/avalon/medbay
	name = "Medbay Elevator"

/area/turbolift/avalon/medbay/a1
	lift_floor_label = "1"
	lift_floor_name = "Surgery, Morgue, Patient Ward"
/area/turbolift/avalon/medbay/a2
	lift_floor_label = "2"
	lift_floor_name = "Intensive Care, Storage, Break Room"

/area/turbolift/avalon/factory
	name = "Manufacturing Elevator"
/area/turbolift/avalon/factory/a1
	lift_floor_label = "1"
	lift_floor_name = "Production Halls"
/area/turbolift/avalon/factory/a2
	lift_floor_label = "2"
	lift_floor_name = "Break Room, Changing Room"

/area/turbolift/serenity/personnel
	name = "Personnel Elevator"

/area/turbolift/serenity/personnel/a3
	lift_floor_label = "3"
	lift_floor_name = "Entrance; Administration"

/area/turbolift/serenity/personnel/a2
	lift_floor_label = "2"
	lift_floor_name = "Laboratories; Reactor Ops."

/area/turbolift/serenity/personnel/a2/one
/area/turbolift/serenity/personnel/a2/two
/area/turbolift/serenity/personnel/a3/one
/area/turbolift/serenity/personnel/a3/two

/area/turbolift/serenity/main
	name = "Personnel Elevator"

/area/turbolift/serenity/main/a2
	lift_floor_label = "2"
	lift_floor_name = "Entrance; Administration"

/area/turbolift/serenity/main/a1
	lift_floor_label = "1"
	lift_floor_name = "Laboratories; Reactor Ops."

/area/turbolift/serenity/main/a1/one
/area/turbolift/serenity/main/a1/two
/area/turbolift/serenity/main/a2/one
/area/turbolift/serenity/main/a2/two

/area/turbolift/serenity/ro_staircase
	name = "RO Elevator"

/area/turbolift/serenity/ro_staircase/a2
	lift_floor_label = "2"
	lift_floor_name = "RO Entrance; Atmos Annex"

/area/turbolift/serenity/ro_staircase/a1
	lift_floor_label = "1"
	lift_floor_name = "RO Offices; Main Catwalks"

/area/turbolift/serenity/ro_control
	name = "RO Elevator"

/area/turbolift/serenity/ro_control/a2
	lift_floor_label = "2"
	lift_floor_name = "RO Main Catwalks; Pump Station A"

/area/turbolift/serenity/ro_control/a1
	lift_floor_label = "1"
	lift_floor_name = "Reactor Control Station"

/area/turbolift/serenity/ro_electrical
	name = "RO Elevator"

/area/turbolift/serenity/ro_electrical/a2
	lift_floor_label = "2"
	lift_floor_name = "Reactor Maintenance Tunnels"

/area/turbolift/serenity/ro_electrical/a1
	lift_floor_label = "1"
	lift_floor_name = "Electrical Station; Turbine Hall"

/area/turbolift/serenity/reactor
	name = "RO Elevator"

/area/turbolift/serenity/reactor/a2
	lift_floor_label = "2"
	lift_floor_name = "Fuel Port Access"

/area/turbolift/serenity/reactor/a1
	lift_floor_label = "1"
	lift_floor_name = "Chamber Entrance"

/area/turbolift/serenity/entrance
	name = "Entrance Elevator"

/area/turbolift/serenity/entrance/a3
	lift_floor_label = "3"
	lift_floor_name = "Facility Exit"
/area/turbolift/serenity/entrance/a2
/area/turbolift/serenity/entrance/a1
	lift_floor_label = "1"
	lift_floor_name = "Entrance Zone"

/area/turbolift/serenity/main_staircase
	name = "Staircase Elevator"

/area/turbolift/serenity/main_staircase/a4
	lift_floor_label = "4"
	lift_floor_name = "Atmospherics"
/area/turbolift/serenity/main_staircase/a3
/area/turbolift/serenity/main_staircase/a2
	lift_floor_label = "2"
	lift_floor_name = "Cargo Entrance"
/area/turbolift/serenity/main_staircase/a1
	lift_floor_label = "1"
	lift_floor_name = "Cargo Storage; Security"

/area/turbolift/serenity/mining
	name = "Personnel Elevator"

/area/turbolift/serenity/mining/a5
	lift_floor_label = "5"
	lift_floor_name = "Mining Preparations"

/area/turbolift/serenity/mining/a4
/area/turbolift/serenity/mining/a3
/area/turbolift/serenity/mining/a2

/area/turbolift/serenity/mining/a1
	lift_floor_label = "1"
	lift_floor_name = "Mining; Ore Processing"

/area/turbolift/serenity/labs
	name = "Personnel Elevator"

/area/turbolift/serenity/labs/a3
	lift_floor_label = "3"
	lift_floor_name = "Laboratories Entrance"

/area/turbolift/serenity/labs/a2

/area/turbolift/serenity/labs/a1
	lift_floor_label = "1"
	lift_floor_name = "Main Laboratories"

/area/turbolift/serenity/charlie
	name = "Personnel Elevator"

/area/turbolift/serenity/charlie/a1
	lift_floor_label = "1"
	lift_floor_name = "Lab Charlie"

/area/turbolift/serenity/charlie/a2
	lift_floor_label = "2"
	lift_floor_name = "Main Laboratories"