/obj/item/clothing/suit/armor/bulletproof
	name = "anti-rifle vest"
	desc = "An armored vest with heavy plates to protect against ballistic projectiles."
	icon = 'icons/clothing/suit/armor/ballistic.dmi'
	valid_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA, ACCESSORY_SLOT_ARMOR_A, ACCESSORY_SLOT_ARMOR_L)
	restricted_accessory_slots = list(ACCESSORY_SLOT_INSIGNIA, ACCESSORY_SLOT_ARMOR_A, ACCESSORY_SLOT_ARMOR_L)
	body_parts_covered = SLOT_UPPER_BODY|SLOT_LOWER_BODY
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_AP,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED
		)
	starting_accessories = null
	siemens_coefficient = 0.7
	material = /decl/material/solid/metal/plasteel
	matter = list(
		/decl/material/solid/metal/titanium = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/gemstone/diamond = MATTER_AMOUNT_TRACE
		)
	origin_tech = @'{"materials":3,"engineering":1,"combat":3}'

// no accessory
/obj/item/clothing/suit/armor/bulletproof/prepared
	starting_accessories = list(/obj/item/clothing/accessory/armguards/ballistic, /obj/item/clothing/accessory/legguards/ballistic)

/obj/item/clothing/accessory/armguards/ballistic
	name = "ballistic arm guards"
	desc = "A pair of armored arm pads with heavy plates to protect against ballistic projectiles."
	icon = 'icons/clothing/accessories/armor/armguards_ballistic.dmi'
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED
		)
	color = null
	siemens_coefficient = 0.7
	material = /decl/material/solid/metal/plasteel
	matter = list(
		/decl/material/solid/metal/titanium = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/gemstone/diamond = MATTER_AMOUNT_TRACE
		)
	origin_tech = @'{"materials":3,"engineering":1,"combat":3}'

/obj/item/clothing/accessory/legguards/ballistic
	name = "ballistic leg guards"
	desc = "A pair of armored leg pads with heavy plates to protect against ballistic projectiles. Looks like they might impair movement."
	icon = 'icons/clothing/accessories/armor/legguards_ballistic.dmi'
	color = null
	armor = list(
		melee = ARMOR_MELEE_KNIVES,
		bullet = ARMOR_BALLISTIC_RIFLE,
		laser = ARMOR_LASER_SMALL,
		energy = ARMOR_ENERGY_MINOR,
		bomb = ARMOR_BOMB_PADDED
		)
	siemens_coefficient = 0.7
	slowdown = 1
	material = /decl/material/solid/metal/plasteel
	matter = list(
		/decl/material/solid/metal/titanium = MATTER_AMOUNT_REINFORCEMENT,
		/decl/material/solid/gemstone/diamond = MATTER_AMOUNT_TRACE
		)
	origin_tech = @'{"materials":3,"engineering":1,"combat":3}'