// These are definitions for intermediate components used in crafting. They aren't used for anything else.

// Carbon with plastic in a 3D printer, takes a long time
/obj/item/crafting_component/carbon_composite
	name = "carbon composite"
	desc = "A light plastic mesh woven with carbon fiber. It's production is long and costly, but it posesses extreme physical strength."
	matter = list(/decl/material/solid/carbon = MATTER_AMOUNT_PRIMARY, /decl/material/solid/plastic = MATTER_AMOUNT_TRACE)
	weight = 0.7

// Carbon in a 3D printer, takes a medium amount of time
/obj/item/crafting_component/carbon_fiber_roll
	name = "carbon fiber roll"
	desc = "A roll of carbon fiber."
	matter = list(/decl/material/solid/carbon = MATTER_AMOUNT_PRIMARY)
	weight = 0.3

// Blood and mutagen in a medical assembler
/obj/item/crafting_component/genetic_muscle
	name = "gen-moded muscle batch"
	desc = "A batch of genetically engineered muscle."
	weight = 0.2

// Genetic muscle + wetware interface
/obj/item/crafting_component/biomech_muscle
	name = "biomechanical muscle batch"
	desc = "A batch of genetically engineered muscle with wetware circuits for precise control."
	weight = 0.3


// CIRCUITS
/obj/item/crafting_component/silicon_crystal
	name = "silicon crystal"
	desc = "A monocrystal of silicon, ready to be cut into wafers."
	weight = 0.4

// Silicon wafer, a basic crafting component. Silicon crystal in a laser cutter
/obj/item/crafting_component/silicon_wafer
	name = "silicon wafer"
	desc = "A single piece of silicon wafer. Demands extreme sterility and can be engraved."
	weight = 0.1

// Silicon wafer in a laser engraver
/obj/item/crafting_component/system_chip_wafer
	name = "SoC wafer"
	desc = "A set of computer circuits engraved on a silicon wafer. Don't drop it."
	weight = 0.1

// Silicon wafer in a laser engraver
/obj/item/crafting_component/cpu_wafer
	name = "CPU wafer"
	desc = "A set of very powerful processing chips engraved on a silicon wafer. Don't drop it."
	weight = 0.1

// SoC wafer in a laser cutter
/obj/item/crafting_component/system_chip
	name = "SoC chip"
	desc = "A system on a chip engraved on silicon."
	weight = 0.025

// CPU wafer in a laser cutter
/obj/item/crafting_component/cpu_chip
	name = "CPU chip"
	desc = "A CPU chip engraved on silicon."
	weight = 0.025

// System on a chip + brain sample from genetics
/obj/item/crafting_component/wetware_interface
	name = "wetware interface"
	desc = "A computer that uses living neurons. Disgusting for some, but it's very compact and efficient."
	weight = 0.1