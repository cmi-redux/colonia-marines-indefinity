//------------SQUAD RIFLEMAN UNIFORM AND GEAR VENDOR---------------

GLOBAL_LIST_INIT(cm_vending_clothing_marine, list(
		list("STANDARD EQUIPMENT (TAKE ALL)", 0, null, null, null),
		list("Standard Marine Apparel", 0, list(/obj/item/clothing/under/marine, /obj/item/clothing/shoes/marine/knife, /obj/item/clothing/gloves/marine, /obj/item/device/radio/headset/almayer/marine, /obj/item/clothing/head/helmet/marine), VENDOR_CAN_BUY_UNIFORM, VENDOR_ITEM_MANDATORY),
		list("MRE", 0, /obj/item/storage/box/mre, VENDOR_CAN_BUY_MRE, VENDOR_ITEM_MANDATORY),

		list("ARMOR (CHOOSE 1)", 0, null, null, null),
		list("Light Armor", 0, /obj/item/clothing/suit/storage/marine/light, VENDOR_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),
		list("Medium Armor", 0, /obj/item/clothing/suit/storage/marine/medium, VENDOR_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),
		list("Heavy Armor", 0, /obj/item/clothing/suit/storage/marine/heavy, VENDOR_CAN_BUY_ARMOR, VENDOR_ITEM_REGULAR),

		list("BACKPACK (CHOOSE 1)", 0, null, null, null),
		list("Backpack", 0, /obj/item/storage/backpack/marine, VENDOR_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),
		list("Satchel", 0, /obj/item/storage/backpack/marine/satchel, VENDOR_CAN_BUY_BACKPACK, VENDOR_ITEM_RECOMMENDED),
		list("Shotgun Scabbard", 0, /obj/item/storage/large_holster/m37, VENDOR_CAN_BUY_BACKPACK, VENDOR_ITEM_REGULAR),

		list("BELT (CHOOSE 1)", 0, null, null, null),
		list("M276 Ammo Load Rig", 0, /obj/item/storage/belt/marine, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_RECOMMENDED),
		list("M276 General Pistol Holster Rig", 0, /obj/item/storage/belt/gun/m4a3, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 Knife Rig (Full)", 0, /obj/item/storage/belt/knifepouch, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M39 Holster Rig", 0, /obj/item/storage/belt/gun/m39, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M44 Holster Rig", 0, /obj/item/storage/belt/gun/m44, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M82F Holster Rig", 0, /obj/item/storage/belt/gun/flaregun, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 Shotgun Shell Loading Rig", 0, /obj/item/storage/belt/shotgun, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 G8-A General Utility Pouch", 0, /obj/item/storage/backpack/general_belt, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),
		list("M276 M40 Grenade Rig (Empty)", 0, /obj/item/storage/belt/grenade, VENDOR_CAN_BUY_BELT, VENDOR_ITEM_REGULAR),

		list("POUCHES (CHOOSE 2)", 0, null, null, null),
		list("Bayonet Sheath (Full)", 0, /obj/item/storage/pouch/bayonet, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("First-Aid Pouch (Refillable Injectors)", 0, /obj/item/storage/pouch/firstaid/full, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("First-Aid Pouch (Splints, Gauze, Ointment)", 0, /obj/item/storage/pouch/firstaid/full/alternate, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("First-Aid Pouch (Pill Packets)", 0, /obj/item/storage/pouch/firstaid/full/pills, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Flare Pouch (Full)", 0, /obj/item/storage/pouch/flare/full, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_RECOMMENDED),
		list("Small Document Pouch", 0, /obj/item/storage/pouch/document/small, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Magazine Pouch", 0, /obj/item/storage/pouch/magazine, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Shotgun Shell Pouch", 0, /obj/item/storage/pouch/shotgun, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Medium General Pouch", 0, /obj/item/storage/pouch/general/medium, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Pistol Magazine Pouch", 0, /obj/item/storage/pouch/magazine/pistol, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),
		list("Pistol Pouch", 0, /obj/item/storage/pouch/pistol, VENDOR_CAN_BUY_POUCH, VENDOR_ITEM_REGULAR),

		list("MASK (CHOOSE 1)", 0, null, null, null),
		list("Gas Mask", 0, /obj/item/clothing/mask/gas, VENDOR_CAN_BUY_MASK, VENDOR_ITEM_REGULAR),
		list("Heat Absorbent Coif", 0, /obj/item/clothing/mask/rebreather/scarf, VENDOR_CAN_BUY_MASK, VENDOR_ITEM_REGULAR),
		list("Rebreather", 0, /obj/item/clothing/mask/rebreather, VENDOR_CAN_BUY_MASK, VENDOR_ITEM_REGULAR),

		list("RESTRICTED FIREARMS", 0, null, null, null),
		list("VP78 Pistol", 15, /obj/item/storage/box/guncase/vp78, null, VENDOR_ITEM_REGULAR),
		list("SU-6 Smart Pistol", 15, /obj/item/storage/box/guncase/smartpistol, null, VENDOR_ITEM_REGULAR),
		list("M41AE2 Heavy Pulse Rifle", 30, /obj/item/storage/box/guncase/lmg, null, VENDOR_ITEM_REGULAR),

		list("EXPLOSIVES", 0, null, null, null),
		list("M40 HEDP High Explosive Packet (x3 grenades)", 20, /obj/item/storage/box/packet/high_explosive, null, VENDOR_ITEM_REGULAR),
		list("M40 HIDP Incendiary Packet (x3 grenades)", 20, /obj/item/storage/box/packet/incendiary, null, VENDOR_ITEM_REGULAR),
		list("M40 HPDP White Phosphorus Packet (x3 grenades)", 20, /obj/item/storage/box/packet/phosphorus, null, VENDOR_ITEM_REGULAR),
		list("M40 HSDP Smoke Packet (x3 grenades)", 10, /obj/item/storage/box/packet/smoke, null, VENDOR_ITEM_REGULAR),
		list("M74 AGM-Frag Airburst Packet (x3 airburst grenades)", 15, /obj/item/storage/box/packet/airburst_he, null, VENDOR_ITEM_REGULAR),
		list("M74 AGM-Incendiary Airburst Packet (x3 airburst grenades)", 15, /obj/item/storage/box/packet/airburst_incen, null, VENDOR_ITEM_REGULAR),
		list("M74 AGM-Smoke Airburst Packet (x3 airburst grenades)", 10, /obj/item/storage/box/packet/airburst_smoke, null, VENDOR_ITEM_REGULAR),
		list("M74 AGM-Hornet Airburst Packet (x3 airburst grenades", 15, /obj/item/storage/box/packet/hornet, null, VENDOR_ITEM_REGULAR),
		list("M20 Mine Box (x4 mines)", 20, /obj/item/storage/box/explosive_mines, null, VENDOR_ITEM_REGULAR),

		list("ARMORS", 0, null, null, null),
		list("M3 B12 Pattern Marine Armor", 30, /obj/item/clothing/suit/storage/marine/leader, null, VENDOR_ITEM_REGULAR),
		list("M4 Pattern Armor", 30, /obj/item/clothing/suit/storage/marine/rto, null, VENDOR_ITEM_REGULAR),

		list("CLOTHING ITEMS", 0, null, null, null),
		list("Webbing", 10, /obj/item/clothing/accessory/storage/webbing, null, VENDOR_ITEM_REGULAR),
		list("Brown Webbing Vest", 15, /obj/item/clothing/accessory/storage/black_vest/brown_vest, null, VENDOR_ITEM_REGULAR),
		list("Black Webbing Vest", 15, /obj/item/clothing/accessory/storage/black_vest, null, VENDOR_ITEM_REGULAR),
		list("Drop Pouch", 15, /obj/item/clothing/accessory/storage/droppouch, null, VENDOR_ITEM_REGULAR),
		list("Shoulder Holster", 15, /obj/item/clothing/accessory/storage/holster, null, VENDOR_ITEM_REGULAR),
		list("Machete Scabbard (Full)", 15, /obj/item/storage/large_holster/machete/full, null, VENDOR_ITEM_REGULAR),
		list("Machete Pouch (Full)", 15, /obj/item/storage/pouch/machete/full, null, VENDOR_ITEM_REGULAR),
		list("USCM Radio Telephone Pack", 15, /obj/item/storage/backpack/marine/satchel/rto, null, VENDOR_ITEM_REGULAR),
		list("Fuel Tank Strap Pouch", 5, /obj/item/storage/pouch/flamertank, null, VENDOR_ITEM_REGULAR),
		list("Welding Goggles", 5, /obj/item/clothing/glasses/welding, null, VENDOR_ITEM_REGULAR),
		list("Sling Pouch", 15, /obj/item/storage/pouch/sling, null, VENDOR_ITEM_REGULAR),
		list("Large General Pouch", 15, /obj/item/storage/pouch/general/large, null, VENDOR_ITEM_REGULAR),

		list("UTILITIES", 0, null, null, null),
		list("E-Tool", 5, /obj/item/tool/shovel/etool/folded, null, VENDOR_ITEM_REGULAR),
		list("Sandbags", 20, /obj/item/stack/sandbags_empty/half, null, VENDOR_ITEM_REGULAR),
		list("Roller Bed", 5, /obj/item/roller, null, VENDOR_ITEM_REGULAR),
		list("Fulton Device Stack", 5, /obj/item/stack/fulton, null, VENDOR_ITEM_REGULAR),
		list("Range Finder", 10, /obj/item/device/binoculars/range, null, VENDOR_ITEM_REGULAR),
		list("Laser Designator", 15, /obj/item/device/binoculars/range/designator, null, VENDOR_ITEM_REGULAR),
		list("Fire Extinguisher (Portable)", 5, /obj/item/tool/extinguisher/mini, null, VENDOR_ITEM_REGULAR),
		list("Motion Detector", 15, /obj/item/device/motiondetector, null, VENDOR_ITEM_REGULAR),
		list("Data Detector", 15, /obj/item/device/motiondetector/intel, null, VENDOR_ITEM_REGULAR),
		list("Whistle", 5, /obj/item/device/whistle, null, VENDOR_ITEM_REGULAR),

		list("HELMET OPTICS", 0, null, null, null),
		list("Medical Helmet Optic", 15, /obj/item/device/helmet_visor/medical, null, VENDOR_ITEM_REGULAR),
		list("Welding Visor", 5, /obj/item/device/helmet_visor/welding_visor, null, VENDOR_ITEM_REGULAR),

		list("PAMPHLETS", 0, null, null, null),
		list("JTAC Pamphlet", 15, /obj/item/pamphlet/skill/jtac, null, VENDOR_ITEM_REGULAR),
		list("Engineering Pamphlet", 15, /obj/item/pamphlet/skill/engineer, null, VENDOR_ITEM_REGULAR),

		list("RADIO KEYS", 0, null, null, null),
		list("Engineering Radio Encryption Key", 5, /obj/item/device/encryptionkey/engi, null, VENDOR_ITEM_REGULAR),
		list("Intel Radio Encryption Key", 5, /obj/item/device/encryptionkey/intel, null, VENDOR_ITEM_REGULAR),
		list("JTAC Radio Encryption Key", 5, /obj/item/device/encryptionkey/jtac, null, VENDOR_ITEM_REGULAR),
		list("Supply Radio Encryption Key", 5, /obj/item/device/encryptionkey/req, null, VENDOR_ITEM_REGULAR),
	))

/obj/structure/machinery/cm_vending/clothing/marine
	name = "\improper ColMarTech Automated Marine Equipment Rack"
	desc = "An automated rack hooked up to a colossal storage of Marine Rifleman standard-issue equipment."
	icon_state = "mar_rack"
	show_points = TRUE
	vendor_theme = VENDOR_THEME_USCM

	vendor_role = list(JOB_SQUAD_MARINE)

/obj/structure/machinery/cm_vending/clothing/marine/get_listed_products(mob/user)
	return GLOB.cm_vending_clothing_marine

/obj/structure/machinery/cm_vending/clothing/marine/alpha
	squad_tag = SQUAD_MARINE_1
	req_access = list(ACCESS_MARINE_ALPHA)
	headset_type = /obj/item/device/radio/headset/almayer/marine/alpha

/obj/structure/machinery/cm_vending/clothing/marine/bravo
	squad_tag = SQUAD_MARINE_2
	req_access = list(ACCESS_MARINE_BRAVO)
	headset_type = /obj/item/device/radio/headset/almayer/marine/bravo

/obj/structure/machinery/cm_vending/clothing/marine/charlie
	squad_tag = SQUAD_MARINE_3
	req_access = list(ACCESS_MARINE_CHARLIE)
	headset_type = /obj/item/device/radio/headset/almayer/marine/charlie

/obj/structure/machinery/cm_vending/clothing/marine/delta
	squad_tag = SQUAD_MARINE_4
	req_access = list(ACCESS_MARINE_DELTA)
	headset_type = /obj/item/device/radio/headset/almayer/marine/delta
