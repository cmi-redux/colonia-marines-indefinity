/client/proc/cmd_admin_change_custom_event()
	set name = "Setup Event Info"
	set category = "Admin.Events"

	if(!admin_holder)
		to_chat(usr, "Only administrators may use this command.")
		return

	if(!length(GLOB.custom_event_info_list))
		to_chat(usr, "custom_event_info_list is not initialized, tell a dev.")
		return

	var/list/temp_list = list()

	for(var/T in GLOB.custom_event_info_list)
		var/datum/custom_event_info/CEI = GLOB.custom_event_info_list[T]
		temp_list["[CEI.msg ? "(x) [CEI.faction_name]" : CEI.faction_name]"] = CEI.faction_name

	var/event_info_get = temp_list[tgui_input_list(usr, "Select faction. Ghosts will see only \"Global\" category message. Factions with event message set are marked with (x).", "Faction Choice", temp_list)]
	if(!event_info_get)
		return

	var/datum/custom_event_info/CEI = GLOB.custom_event_info_list[event_info_get]
	if(!CEI)
		to_chat(usr, "custom_event_info_list don't have [event_info_get] in list, tell a dev.")
		return

	var/input = input(usr, "Enter the custom event message for \"[event_info_get]\" category. Be descriptive. \nTo remove the event message, remove text and confirm.", "[event_info_get] Event Message", CEI.msg) as message|null
	if(isnull(input))
		return

	if(input == "" || !input)
		CEI.msg = ""
		message_admins("[key_name_admin(usr)] has removed the event message for \"[event_info_get]\" category.")
		return

	CEI.msg = html_encode(input)
	message_admins("[key_name_admin(usr)] has changed the event message for \"[event_info_get]\" category.")

	CEI.handle_event_info_update()

/client/proc/change_security_level()
	if(!check_rights(R_ADMIN))
		return
	var sec_level = input(usr, "It's currently code [get_security_level()].", "Select Security Level")  as null|anything in (list("green","blue","red","delta")-get_security_level())
	if(sec_level && alert("Switch from code [get_security_level()] to code [sec_level]?", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) == usr.client.auto_lang(LANGUAGE_YES))
		set_security_level(seclevel2num(sec_level))
		log_admin("[key_name(usr)] changed the security level to code [sec_level].")

/client/proc/toggle_gun_restrictions()
	if(!admin_holder || !config)
		return

	if(CONFIG_GET(flag/remove_gun_restrictions))
		to_chat(src, "<b>Enabled gun restrictions.</b>")
		message_admins("Admin [key_name_admin(usr)] has enabled WY gun restrictions.")
	else
		to_chat(src, "<b>Disabled gun restrictions.</b>")
		message_admins("Admin [key_name_admin(usr)] has disabled WY gun restrictions.")
	CONFIG_SET(flag/remove_gun_restrictions, !CONFIG_GET(flag/remove_gun_restrictions))

/client/proc/togglebuildmodeself()
	set name = "Buildmode"
	set category = "Admin.Events"
	if(!check_rights(R_ADMIN))
		return

	if(src.mob)
		togglebuildmode(src.mob)

/client/proc/drop_bomb()
	set name = "Drop Bomb"
	set desc = "Cause an explosion of varying strength at your location."
	set category = "Admin.Fun"

	var/turf/epicenter = mob.loc
	handle_bomb_drop(epicenter)

/client/proc/handle_bomb_drop(atom/epicenter)
	var/custom_limit = 5000
	var/list/choices = list("Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/list/falloff_shape_choices = list("CANCEL", "Linear", "Exponential")
	var/choice = tgui_input_list(usr, "What size explosion would you like to produce?", "Drop Bomb", choices)
	var/datum/cause_data/cause_data = create_cause_data("божественного вмешательства")
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3, 3, , , , cause_data)
		if("Medium Bomb")
			explosion(epicenter, 2, 3, 4, 4, , , , cause_data)
		if("Big Bomb")
			explosion(epicenter, 3, 5, 7, 5, , , , cause_data)
		if("Custom Bomb")
			var/power = tgui_input_number(src, "Power?", "Power?")
			if(!power)
				return

			var/falloff = tgui_input_number(src, "Falloff?", "Falloff?")
			if(!falloff)
				return

			var/shape_choice = tgui_input_list(src, "Select falloff shape?", "Select falloff shape", falloff_shape_choices)
			var/explosion_shape = EXPLOSION_FALLOFF_SHAPE_LINEAR
			switch(shape_choice)
				if("CANCEL")
					return 0
				if("Exponential")
					explosion_shape = EXPLOSION_FALLOFF_SHAPE_EXPONENTIAL

			if(power > custom_limit)
				return
			cell_explosion(epicenter, power, falloff, explosion_shape, null, cause_data)
			message_admins("[key_name(src, TRUE)] dropped a custom cell bomb with power [power], falloff [falloff] and falloff_shape [shape_choice]!")
	message_admins("[ckey] used 'Drop Bomb' at [epicenter.loc].")


/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set name = "EM Pulse"
	set category = "Admin.Fun"

	if(!check_rights(R_DEBUG|R_ADMIN))
		return

	var/heavy = input("Range of heavy pulse.", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light pulse.", text("Input"))  as num|null
	if(light == null)
		return

	if(!heavy && !light)
		return

	empulse(O, heavy, light)
	message_admins("[key_name_admin(usr)] created an EM PUlse ([heavy],[light]) at ([O.x],[O.y],[O.z])")
	return

/datum/admins/proc/admin_force_ERT_shuttle()
	set name = "Force ERT Shuttle"
	set desc = "Force Launch the ERT Shuttle."
	set category = "Admin.Shuttles"

	if (!SSticker.mode)
		return
	if(!check_rights(R_EVENT))
		return

	var/list/shuttle_map = list()
	for(var/obj/docking_port/mobile/emergency_response/ert_shuttles in SSshuttle.mobile)
		shuttle_map[ert_shuttles.name] = ert_shuttles.id
	var/tag = tgui_input_list(usr, "Which ERT shuttle should be force launched?", "Select an ERT Shuttle:", shuttle_map)
	if(!tag)
		return

	var/shuttleId = shuttle_map[tag]
	var/list/docks = SSshuttle.stationary
	var/list/targets = list()
	var/list/target_names = list()
	var/obj/docking_port/mobile/emergency_response/ert = SSshuttle.getShuttle(shuttleId)
	for(var/obj/docking_port/stationary/emergency_response/dock in docks)
		var/can_dock = ert.canDock(dock)
		if(can_dock == SHUTTLE_CAN_DOCK)
			targets += list(dock)
			target_names +=  list(dock.name)
	var/dock_name = tgui_input_list(usr, "Where on the [MAIN_SHIP_NAME] should the shuttle dock?", "Select a docking zone:", target_names)
	var/launched = FALSE
	if(!dock_name)
		return
	for(var/obj/docking_port/stationary/emergency_response/dock as anything in targets)
		if(dock.name == dock_name)
			var/obj/docking_port/stationary/target = SSshuttle.getDock(dock.id)
			ert.request(target)
			launched=TRUE
	if(!launched)
		to_chat(usr, SPAN_WARNING("Unable to launch this Distress shuttle at this moment. Aborting."))
		return

	message_admins("[key_name_admin(usr)] force launched a distress shuttle ([tag])")

/datum/admins/proc/admin_force_distress()
	set name = "Distress Beacon"
	set desc = "Call a distress beacon. This should not be done if the shuttle's already been called."
	set category = "Admin.Shuttles"

	if(!SSticker.mode)
		return

	if(!check_rights(R_EVENT)) // Seems more like an event thing than an admin thing
		return

	var/list/list_of_calls = list()
	var/list/assoc_list = list()

	for(var/datum/emergency_call/L in SSticker.mode.all_calls)
		if(L && L.name != "name")
			list_of_calls += L.name
			assoc_list += list(L.name = L)
	list_of_calls = sortList(list_of_calls)

	list_of_calls += "Randomize"

	var/ert_choice = tgui_input_list(usr, "Which distress call?", MODE_NAME_DISTRESS_SIGNAL, list_of_calls)

	if(!ert_choice)
		return

	var/datum/emergency_call/chosen_ert
	if(ert_choice == "Randomize")
		chosen_ert = SSticker.mode.get_random_call()
	else
		var/datum/emergency_call/em_call = assoc_list[ert_choice]
		chosen_ert = new em_call.type()

	if(!istype(chosen_ert))
		return

	var/is_announcing = TRUE
	var/choice = alert(src, "Would you like to announce the distress beacon to the server population? This will reveal the distress beacon to all players.", usr.client.auto_lang(LANGUAGE_DISTRESS_ANNOUNCE), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO), usr.client.auto_lang(LANGUAGE_CANCEL))
	if(choice ==usr.client.auto_lang(LANGUAGE_CANCEL))
		qdel(chosen_ert)
		return
	else if(choice == usr.client.auto_lang(LANGUAGE_NO))
		is_announcing = FALSE

	var/turf/override_spawn_loc
	choice = alert(usr, "Spawn at their assigned spawnpoints, or at your location?", usr.client.auto_lang(LANGUAGE_DISTRESS_SPAWNPOINT), usr.client.auto_lang(LANGUAGE_DISTRESS_LOC_CURRENT), usr.client.auto_lang(LANGUAGE_DISTRESS_LOC_ASSIGNED), usr.client.auto_lang(LANGUAGE_CANCEL))
	if(choice == usr.client.auto_lang(LANGUAGE_CANCEL))
		qdel(chosen_ert)
		return
	else if(choice == usr.client.auto_lang(LANGUAGE_DISTRESS_LOC_CURRENT))
		override_spawn_loc = get_turf(usr)

	chosen_ert.activate(is_announcing, override_spawn_loc)

	message_admins("[key_name_admin(usr)] admin-called a [choice == "Randomize" ? "randomized ":""]distress beacon: [chosen_ert.name]")

/datum/admins/proc/admin_force_evacuation()
	set name = "Trigger Evacuation"
	set desc = "Triggers emergency evacuation."
	set category = "Admin.Events"

	if(!SSticker.mode || !check_rights(R_ADMIN))
		return
	set_security_level(SEC_LEVEL_RED)
	SSevacuation.initiate_evacuation()

	message_admins("[key_name_admin(usr)] forced an emergency evacuation.")

/datum/admins/proc/admin_cancel_evacuation()
	set name = "Cancel Evacuation"
	set desc = "Cancels emergency evacuation."
	set category = "Admin.Events"

	if(!SSticker.mode || !check_rights(R_ADMIN))
		return
	SSevacuation.cancel_evacuation()

	message_admins("[key_name_admin(usr)] canceled an emergency evacuation.")

/datum/admins/proc/add_req_points()
	set name = "Add Requisitions Points"
	set desc = "Add points to the ship requisitions department."
	set category = "Admin.Events"
	if(!SSticker.mode || !check_rights(R_ADMIN))
		return

	var/points_to_add = tgui_input_real_number(usr, "Enter the amount of points to give, or a negative number to subtract. 1 point = $100.", "Points", 0)
	if(!points_to_add)
		return
	else if((supply_controller.points + points_to_add) < 0)
		supply_controller.points = 0
	else if((supply_controller.points + points_to_add) > 99999)
		supply_controller.points = 99999
	else
		supply_controller.points += points_to_add


	message_admins("[key_name_admin(usr)] granted requisitions [points_to_add] points.")
	if(points_to_add >= 0)
		shipwide_ai_announcement("Additional Supply Budget has been authorised for this operation.")

/datum/admins/proc/admin_force_selfdestruct()
	set name = "Self-Destruct"
	set desc = "Trigger self-destruct countdown. This should not be done if the self-destruct has already been called."
	set category = "Admin.Events"

	if(!SSticker.mode || !check_rights(R_ADMIN) || get_security_level() == "delta")
		return

	if(alert(src, "Are you sure you want to do this?", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
		return

	if(!SSevacuation.enable_self_destruct(FALSE, FALSE))
		to_chat(usr, SPAN_WARNING("You are unable to authorize the self-destruct right now!"))
	else
		message_admins("[key_name_admin(usr)] force-enabled the self-destruct system.")

	message_admins("[key_name_admin(usr)] admin-started self-destruct system.")

/client/proc/view_faxes()
	set name = "View Faxes"
	set desc = "View faxes from this round"
	set category = "Admin.Events"

	if(!admin_holder)
		return

	var/list/options = list("Weyland-Yutani", "High Command", "Provost", "Press", "Other", "Cancel")
	var/answer = tgui_input_list(src, "Which kind of faxes would you like to see?", "Faxes", options)
	switch(answer)
		if("Weyland-Yutani")
			var/body = "<body>"

			for(var/text in GLOB.WYFaxes)
				body += text
				body += "<br><br>"

			body += "<br><br></body>"
			show_browser(src, body, "Faxes to Weyland-Yutani", "wyfaxviewer", "size=300x600")
		if("High Command")
			var/body = "<body>"

			for(var/text in GLOB.USCMFaxes)
				body += text
				body += "<br><br>"

			body += "<br><br></body>"
			show_browser(src, body, "Faxes to High Command", "uscmfaxviewer", "size=300x600")
		if("Provost")
			var/body = "<body>"

			for(var/text in GLOB.ProvostFaxes)
				body += text
				body += "<br><br>"

			body += "<br><br></body>"
			show_browser(src, body, "Faxes to the Provost Office", "provostfaxviewer", "size=300x600")

		if("Press")
			var/body = "<body>"

			for(var/text in GLOB.PressFaxes)
				body += text
				body += "<br><br>"

			body += "<br><br></body>"
			show_browser(src, body, "Faxes to Press organizations", "otherfaxviewer", "size=300x600")

		if("CMB")
			var/body = "<body>"

			for(var/text in GLOB.CMBFaxes)
				body += text
				body += "<br><br>"

			body += "<br><br></body>"
			show_browser(src, body, "Faxes to the Colonial Marshal Bureau", "cmbfaxviewer", "size=300x600")

		if("Other")
			var/body = "<body>"

			for(var/text in GLOB.GeneralFaxes)
				body += text
				body += "<br><br>"

			body += "<br><br></body>"
			show_browser(src, body, "Inter-machine Faxes", "otherfaxviewer", "size=300x600")
		if("Cancel")
			return

/client/proc/award_medal()
	if(!check_rights(R_ADMIN))
		return

	give_medal_award(as_admin=TRUE)

/client/proc/award_jelly()
	if(!check_rights(R_ADMIN))
		return

	// Mostly replicated code from observer.dm.hive_status()
	var/list/datum/faction/factions = list()
	for(var/faction_to_get in FACTION_LIST_XENOMORPH)
		var/datum/faction/faction_to_set = GLOB.faction_datum[faction_to_get]
		if(!length(faction_to_set.totalMobs) && !length(faction_to_set.totalDeadMobs))
			continue
		LAZYSET(factions, faction_to_set.name, faction_to_set)

	var/choice = tgui_input_list(src, "Select which hive to award", "Hive Choice", factions, theme = "hive_status")
	if(!choice)
		return

	give_jelly_award(factions[choice], as_admin = TRUE)

/client/proc/turn_everyone_into_primitives()
	var/random_names = FALSE
	if(alert(src, "Do you want to give everyone random numbered names?", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) == usr.client.auto_lang(LANGUAGE_YES))
		random_names = TRUE
	if(alert(src, "Are you sure you want to do this? It will laaag.", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
		return
	for(var/mob/living/carbon/human/H in GLOB.human_mob_list)
		if(ismonkey(H))
			continue
		H.set_species(pick("Monkey", "Yiren", "Stok", "Farwa", "Neaera"))
		H.is_important = TRUE
		if(random_names)
			var/random_name = "[lowertext(H.species.name)] ([rand(1, 999)])"
			H.change_real_name(H, random_name)
			if(H.wear_id)
				var/obj/item/card/id/card = H.wear_id
				card.registered_name = H.real_name
				card.name = "[card.registered_name]'s ID Card ([card.assignment])"

	message_admins("Admin [key_name(usr)] has turned everyone into a primitive")

/client/proc/force_hijack()
	set name = "Force Hijack"
	set desc = "Force a dropship to be hijacked"
	set category = "Admin.Shuttles"

	var/list/shuttles = list(DROPSHIP_ALAMO, DROPSHIP_NORMANDY)
	var/tag = tgui_input_list(usr, "Which dropship should be force hijacked?", "Select a dropship:", shuttles)
	if(!tag) return

	var/obj/docking_port/mobile/marine_dropship/dropship = SSshuttle.getShuttle(tag)

	if(!dropship)
		to_chat(src, SPAN_DANGER("Error: Attempted to force a dropship hijack but the shuttle datum was null. Code: MSD_FSV_DIN"))
		log_admin("Error: Attempted to force a dropship hijack but the shuttle datum was null. Code: MSD_FSV_DIN")
		return

	if(tgui_alert(usr, "Are you sure you want to hijack [dropship]?", "Force hijack", list(usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO))) != usr.client.auto_lang(LANGUAGE_YES))
		return

	var/obj/structure/machinery/computer/shuttle/dropship/flight/computer = dropship.getControlConsole()
	computer.hijack(usr, force = TRUE)

/client/proc/cmd_admin_create_centcom_report()
	set name = "Report: Faction"
	set category = "Admin.Factions"

	if(!admin_holder || !(admin_holder.rights & R_MOD))
		to_chat(src, "Only administrators may use this command.")
		return FALSE

	var/list/datum/faction/factions = list()
	LAZYSET(factions, "All Humans", "Everyone (-Yautja)")
	for(var/faction_to_get in FACTION_LIST_HUMANOID)
		var/datum/faction/faction_to_set = GLOB.faction_datum[faction_to_get]
		LAZYSET(factions, faction_to_set.name, faction_to_set)

	var/choice = tgui_input_list(usr, "Please choose faction your announcement will be shown to.", "Faction Selection", factions)
	if(!choice)
		return FALSE

	var/input = input(usr, "Please enter announcement text. Be advised, this announcement will be heard both on Almayer and planetside by conscious humans of selected faction.", "What?", "") as message|null
	if(!input)
		return FALSE
	var/customname = input(usr, "Pick a title for the announcement. Confirm empty text for \"[choice] Update\" title.", "Title") as text|null
	if(isnull(customname))
		return FALSE
	if(!customname)
		customname = "[choice] Update"

	if(choice == "Everyone (-Yautja)")
		faction_announcement(input, customname, 'sound/AI/commandreport.ogg', choice)
	else if(choice == FACTION_MARINE)
		for(var/obj/structure/machinery/computer/almayer_control/C in machines)
			if(!(C.inoperable()))
				var/obj/item/paper/P = new /obj/item/paper(C.loc)
				P.name = "'[command_name] Update.'"
				P.info = input
				P.update_icon()
				C.messagetitle.Add("[command_name] Update")
				C.messagetext.Add(P.info)
		if(alert("Press \"Yes\" if you want to announce it to ship crew and marines. Press \"No\" to keep it only as printed report on communication console.", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) == usr.client.auto_lang(LANGUAGE_YES))
			faction_announcement(input, customname, 'sound/AI/commandreport.ogg', factions[choice])
	else
		faction_announcement(input, customname, 'sound/AI/commandreport.ogg', factions[choice])

	message_admins("[key_name_admin(src)] has created a [choice] command report")
	log_admin("[key_name_admin(src)] [choice] command report: [input]")

/client/proc/cmd_admin_xeno_report()
	set name = "Report: Queen Mother"
	set desc = "Basically a command announcement, but only for selected Xeno's Hive"
	set category = "Admin.Factions"

	if(!admin_holder || !(admin_holder.rights & R_MOD))
		to_chat(src, "Only administrators may use this command.")
		return FALSE

	var/list/datum/faction/factions = list()
	LAZYSET(factions, "All Hives", "Everyone")
	for(var/faction_to_get in FACTION_LIST_XENOMORPH)
		var/datum/faction/faction_to_set = GLOB.faction_datum[faction_to_get]
		LAZYSET(factions, faction_to_set.name, faction_to_set)

	var/choice = tgui_input_list(usr, "Please choose the hive you want to see your announcement. Selecting \"All hives\" option will change title to \"Unknown Higher Force\"", "Hive Selection", factions)
	if(!choice)
		return FALSE

	var/input = input(usr, "This should be a message from the ruler of the Xenomorph race.", "What?", "") as message|null
	if(!input)
		return FALSE

	if(choice != "All Hives")
		xeno_announcement(input, factions[choice], SPAN_ANNOUNCEMENT_HEADER_BLUE("[factions[choice].prefix][QUEEN_MOTHER_ANNOUNCE]"))
	else
		xeno_announcement(input, choice, HIGHER_FORCE_ANNOUNCE)

	message_admins("[key_name_admin(src)] has created a [choice] Queen Mother report")
	log_admin("[key_name_admin(src)] Queen Mother ([choice]): [input]")

/client/proc/cmd_admin_create_AI_report()
	set name = "Report: ARES Comms"
	set category = "Admin.Factions"

	if(!admin_holder || !(admin_holder.rights & R_MOD))
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "This is a standard message from the ship's AI. It uses Almayer General channel and won't be heard by humans without access to Almayer General channel (headset or intercom). Check with online staff before you send this. Do not use html.", "What?", "") as message|null
	if(!input)
		return FALSE

	for(var/obj/structure/machinery/computer/almayer_control/C in machines)
		if(!(C.inoperable()))
// var/obj/item/paper/P = new /obj/item/paper(C.loc)//Don't need a printed copy currently.
// P.name = "'[MAIN_AI_SYSTEM] Update.'"
// P.info = input
// P.update_icon()
			C.messagetitle.Add("[MAIN_AI_SYSTEM] Update")
			C.messagetext.Add(input)
			ai_announcement(input)
			message_admins("[key_name_admin(src)] has created an AI comms report")
			log_admin("AI comms report: [input]")
		else
			to_chat(usr, SPAN_WARNING("[MAIN_AI_SYSTEM] is not responding. It may be offline or destroyed."))

/client/proc/cmd_admin_create_AI_apollo_report()
	set name = "Report: ARES Apollo"
	set category = "Admin.Factions"

	if(!admin_holder || !(admin_holder.rights & R_MOD))
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = tgui_input_text(usr, "This is a broadcast from the ship AI to Working Joes and Maintenance Drones. Do not use html.", "What?", "")
	if(!input)
		return FALSE

	for(var/obj/structure/machinery/computer/almayer_control/console in machines)
		if(console.inoperable())
			to_chat(usr, SPAN_WARNING("[MAIN_AI_SYSTEM] is not responding. It may be offline or destroyed."))
			return
		else
			var/datum/language/apollo = GLOB.all_languages[LANGUAGE_APOLLO]
			for(var/mob/living/silicon/decoy/ship_ai/AI in ai_mob_list)
				apollo.broadcast(AI, input)
			for(var/mob/listener in (GLOB.human_mob_list + GLOB.dead_mob_list))
				if(listener.hear_apollo())//Only plays sound to mobs and not observers, to reduce spam.
					playsound_client(listener.client, sound('sound/misc/interference.ogg'), listener, vol = 45)
			message_admins("[key_name_admin(src)] has created an AI Apollo report")
			log_admin("AI Apollo report: [input]")

/client/proc/cmd_admin_create_AI_shipwide_report()
	set name = "Report: ARES Shipwide"
	set category = "Admin.Factions"

	if(!admin_holder || !(admin_holder.rights & R_MOD))
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "This is an announcement type message from the ship's AI. This will be announced to every conscious human on Almayer z-level. Be aware, this will work even if [MAIN_AI_SYSTEM] unpowered/destroyed. Check with online staff before you send this.", "What?", "") as message|null
	if(!input)
		return FALSE

	for(var/obj/structure/machinery/computer/almayer_control/C in machines)
		if(!(C.inoperable()))
// var/obj/item/paper/P = new /obj/item/paper(C.loc)//Don't need a printed copy currently.
// P.name = "'[MAIN_AI_SYSTEM] Update.'"
// P.info = input
// P.update_icon()
			C.messagetitle.Add("[MAIN_AI_SYSTEM] Shipwide Update")
			C.messagetext.Add(input)

	shipwide_ai_announcement(input)
	message_admins("[key_name_admin(src)] has created an AI shipwide report")
	log_admin("[key_name_admin(src)] AI shipwide report: [input]")

/client/proc/cmd_admin_create_predator_report()
	set name = "Report: Yautja AI"
	set category = "Admin.Factions"

	if(!admin_holder || !(admin_holder.rights & R_MOD))
		to_chat(src, "Only administrators may use this command.")
		return
	var/input = input(usr, "This is a message from the predator ship's AI. Check with online staff before you send this.", "What?", "") as message|null
	if(!input)
		return FALSE
	yautja_announcement(SPAN_YAUTJABOLDBIG(input))
	message_admins("[key_name_admin(src)] has created a predator ship AI report")
	log_admin("[key_name_admin(src)] predator ship AI report: [input]")

/client/proc/cmd_admin_world_narrate() // Allows administrators to fluff events a little easier -- TLE
	set name = "Narrate to Everyone"
	set category = "Admin.Events"

	if(!admin_holder || !(admin_holder.rights & R_MOD))
		to_chat(src, "Only administrators may use this command.")
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text

	if(!msg)
		return

	to_chat_spaced(world, html = SPAN_ANNOUNCEMENT_HEADER_BLUE(msg))
	message_admins("\bold GlobalNarrate: [key_name_admin(usr)] : [msg]")


/client
	var/remote_control = FALSE

/client/proc/toogle_door_control()
	set name = "Toggle Remote Control"
	set category = "Admin.Events"

	if(!check_rights(R_SPAWN))
		return

	remote_control = !remote_control
	message_admins("[key_name_admin(src)] has toggled remote control [remote_control? "on" : "off"] for themselves")

/client/proc/enable_event_mob_verbs()
	set name = "Mob Event Verbs - Show"
	set category = "Admin.Events"

	add_verb(src, admin_mob_event_verbs_hideable)
	remove_verb(src, /client/proc/enable_event_mob_verbs)

/client/proc/hide_event_mob_verbs()
	set name = "Mob Event Verbs - Hide"
	set category = "Admin.Events"

	remove_verb(src, admin_mob_event_verbs_hideable)
	add_verb(src, /client/proc/enable_event_mob_verbs)

// ----------------------------
// PANELS
// ----------------------------

/datum/admins/proc/event_panel()
	if(!check_rights(R_ADMIN,0))
		return

	var/dat = {"
		<B>Ship</B><BR>
		<A href='?src=\ref[src];[HrefToken()];events=securitylevel'>Set Security Level</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=distress'>Send a Distress Beacon</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=selfdestruct'>Activate Self-Destruct</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=evacuation_start'>Trigger Evacuation</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=evacuation_cancel'>Cancel Evacuation</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=disable_shuttle_console'>Disable Shuttle Control</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=add_req_points'>Add Requisitions Points</A><BR>
		<BR>
		<B>Research</B><BR>
		<A href='?src=\ref[src];[HrefToken()];events=change_clearance'>Change Research Clearance</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=give_research_credits'>Give Research Credits</A><BR>
		<BR>
		<B>Power</B><BR>
		<A href='?src=\ref[src];[HrefToken()];events=unpower'>Unpower ship SMESs and APCs</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=power'>Power ship SMESs and APCs</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=quickpower'>Power ship SMESs</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=powereverything'>Power ALL SMESs and APCs everywhere</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=powershipreactors'>Power all ship reactors</A><BR>
		<BR>
		<B>Events</B><BR>
		<A href='?src=\ref[src];[HrefToken()];events=blackout'>Break all lights</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=whiteout'>Repair all lights</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=comms_blackout'>Trigger a Communication Blackout</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=destructible_terrain'>Toggle destructible terrain</A><BR>
		<BR>
		<B>Misc</B><BR>
		<A href='?src=\ref[src];[HrefToken()];events=medal'>Award a medal</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=jelly'>Award a royal jelly</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=pmcguns'>Toggle PMC gun restrictions</A><BR>
		<A href='?src=\ref[src];[HrefToken()];events=monkify'>Turn everyone into monkies</A><BR>
		<BR>
		"}

	show_browser(usr, dat, "Events Panel", "events")
	return

/client/proc/event_panel()
	set name = "Event Panel"
	set category = "Admin.Panels"
	if(admin_holder)
		admin_holder.event_panel()
	return


/datum/admins/proc/chempanel()
	if(!check_rights(R_MOD)) return

	var/dat
	if(check_rights(R_MOD,0))
		dat += {"<A href='?src=\ref[src];[HrefToken()];chem_panel=view_reagent'>View Reagent</A><br>
				"}
	if(check_rights(R_VAREDIT,0))
		dat += {"<A href='?src=\ref[src];[HrefToken()];chem_panel=view_reaction'>View Reaction</A><br>"}
		dat += {"<A href='?src=\ref[src];[HrefToken()];chem_panel=sync_filter'>Sync Reaction</A><br>
				<br>"}
	if(check_rights(R_SPAWN,0))
		dat += {"<A href='?src=\ref[src];[HrefToken()];chem_panel=spawn_reagent'>Spawn Reagent in Container</A><br>
				<A href='?src=\ref[src];[HrefToken()];chem_panel=make_report'>Make Chem Report</A><br>
				<br>"}
	if(check_rights(R_ADMIN,0))
		dat += {"<A href='?src=\ref[src];[HrefToken()];chem_panel=create_random_reagent'>Generate Reagent</A><br>
				<br>
				<A href='?src=\ref[src];[HrefToken()];chem_panel=create_custom_reagent'>Create Custom Reagent</A><br>
				<A href='?src=\ref[src];[HrefToken()];chem_panel=create_custom_reaction'>Create Custom Reaction</A><br>
				"}

	show_browser(usr, dat, "Chem Panel", "chempanel", "size=210x300")
	return

/client/proc/chem_panel()
	set name = "Chem Panel"
	set category = "Admin.Panels"
	if(admin_holder)
		admin_holder.chempanel()
	return

/datum/admins/var/create_humans_html = null
/datum/admins/proc/create_humans(mob/user)
	if(!GLOB.gear_name_presets_list)
		return

	if(!create_humans_html)
		var/equipment_presets = jointext(GLOB.gear_name_presets_list, ";")
		create_humans_html = file2text('html/create_humans.html')
		create_humans_html = replacetext(create_humans_html, "null /* object types */", "\"[equipment_presets]\"")
		create_humans_html = replacetext(create_humans_html, "/* href token */", RawHrefToken(forceGlobal = TRUE))

	show_browser(user, replacetext(create_humans_html, "/* ref src */", "\ref[src]"), "Create Humans", "create_humans", "size=450x630")

/client/proc/create_humans()
	set name = "Create Humans"
	set category = "Admin.Events"
	if(admin_holder)
		admin_holder.create_humans(usr)

/datum/admins/var/create_xenos_html = null
/datum/admins/proc/create_xenos(mob/user)
	if(!create_xenos_html)
		var/hive_types = jointext(FACTION_LIST_XENOMORPH, ";")
		var/xeno_types = jointext(ALL_XENO_CASTES, ";")
		create_xenos_html = file2text('html/create_xenos.html')
		create_xenos_html = replacetext(create_xenos_html, "null /* hive paths */", "\"[hive_types]\"")
		create_xenos_html = replacetext(create_xenos_html, "null /* xeno paths */", "\"[xeno_types]\"")
		create_xenos_html = replacetext(create_xenos_html, "/* href token */", RawHrefToken(forceGlobal = TRUE))

	show_browser(user, replacetext(create_xenos_html, "/* ref src */", "\ref[src]"), "Create Xenos", "create_xenos", "size=450x630")

/client/proc/create_xenos()
	set name = "Create Xenos"
	set category = "Admin.Events"
	if(admin_holder)
		admin_holder.create_xenos(usr)

/client/proc/clear_mutineers()
	set name = "Clear All Mutineers"
	set category = "Admin.Events"
	if(admin_holder)
		admin_holder.clear_mutineers()
	return

/datum/admins/proc/clear_mutineers()
	if(!check_rights(R_MOD))
		return

	if(alert(usr, "Are you sure you want to change all mutineers back to normal?", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
		return

	for(var/mob/living/carbon/human/H in GLOB.human_mob_list)
		if(!H || !(H.mob_flags & MUTINEER))
			continue

		GLOB.faction_datum[FACTION_NEUTRAL].add_mob(H)
		H.hud_set_squad()

		for(var/datum/action/human_action/activable/mutineer/action in H.actions)
			action.remove_from(H)

/client/proc/cmd_fun_fire_ob()
	set category = "Admin.Fun"
	set desc = "Fire an OB warhead at your current location."
	set name = "Fire OB"

	if(!check_rights(R_ADMIN))
		return

	var/list/firemodes = list("Standard Warhead", "Custom HE", "Custom Cluster", "Custom Incendiary")
	var/mode = tgui_input_list(usr, "Select fire mode:", "Fire mode", firemodes)
	// Select the warhead.
	var/obj/structure/ob_ammo/warhead/warhead
	var/statsmessage
	var/custom = TRUE
	switch(mode)
		if("Standard Warhead")
			custom = FALSE
			var/list/warheads = subtypesof(/obj/structure/ob_ammo/warhead/)
			var/choice = tgui_input_list(usr, "Select the warhead:", "Warhead to use", warheads)
			warhead = new choice
		if("Custom HE")
			var/obj/structure/ob_ammo/warhead/explosive/OBShell = new
			OBShell.name = input("What name should the warhead have?", "Set name", "HE orbital warhead")
			if(!OBShell.name) return//null check to cancel
			OBShell.clear_power = tgui_input_number(src, "How much explosive power should the wall clear blast have?", "Set clear power", 1200, 3000)
			if(isnull(OBShell.clear_power)) return
			OBShell.clear_falloff = tgui_input_number(src, "How much falloff should the wall clear blast have?", "Set clear falloff", 400)
			if(isnull(OBShell.clear_falloff)) return
			OBShell.standard_power = tgui_input_number(src, "How much explosive power should the main blasts have?", "Set blast power", 600, 3000)
			if(isnull(OBShell.standard_power)) return
			OBShell.standard_falloff = tgui_input_number(src, "How much falloff should the main blasts have?", "Set blast falloff", 30)
			if(isnull(OBShell.standard_falloff)) return
			OBShell.clear_delay = tgui_input_number(src, "How much delay should the clear blast have?", "Set clear delay", 3)
			if(isnull(OBShell.clear_delay)) return
			OBShell.double_explosion_delay = tgui_input_number(src, "How much delay should the clear blast have?", "Set clear delay", 6)
			if(isnull(OBShell.double_explosion_delay)) return
			statsmessage = "Custom HE OB ([OBShell.name]) Stats from [key_name(usr)]: Clear Power: [OBShell.clear_power], Clear Falloff: [OBShell.clear_falloff], Clear Delay: [OBShell.clear_delay], Blast Power: [OBShell.standard_power], Blast Falloff: [OBShell.standard_falloff], Blast Delay: [OBShell.double_explosion_delay]."
			warhead = OBShell
			qdel(OBShell)
		if("Custom Cluster")
			var/obj/structure/ob_ammo/warhead/cluster/OBShell = new
			OBShell.name = input("What name should the warhead have?", "Set name", "Cluster orbital warhead")
			if(!OBShell.name) return//null check to cancel
			OBShell.total_amount = tgui_input_number(src, "How many salvos should be fired?", "Set cluster number", 60)
			if(isnull(OBShell.total_amount)) return
			OBShell.instant_amount = tgui_input_number(src, "How many shots per salvo? (Max 10)", "Set shot count", 3)
			if(isnull(OBShell.instant_amount)) return
			if(OBShell.instant_amount > 10)
				OBShell.instant_amount = 10
			OBShell.explosion_power = tgui_input_number(src, "How much explosive power should the blasts have?", "Set blast power", 300, 1500)
			if(isnull(OBShell.explosion_power)) return
			OBShell.explosion_falloff = tgui_input_number(src, "How much falloff should the blasts have?", "Set blast falloff", 150)
			if(isnull(OBShell.explosion_falloff)) return
			statsmessage = "Custom Cluster OB ([OBShell.name]) Stats from [key_name(usr)]: Salvos: [OBShell.total_amount], Shot per Salvo: [OBShell.instant_amount], Explosion Power: [OBShell.explosion_power], Explosion Falloff: [OBShell.explosion_falloff]."
			warhead = OBShell
			qdel(OBShell)
		if("Custom Incendiary")
			var/obj/structure/ob_ammo/warhead/incendiary/OBShell = new
			OBShell.name = input("What name should the warhead have?", "Set name", "Incendiary orbital warhead")
			if(!OBShell.name) return//null check to cancel
			OBShell.clear_power = tgui_input_number(src, "How much explosive power should the wall clear blast have?", "Set clear power", 1200, 3000)
			if(isnull(OBShell.clear_power)) return
			OBShell.clear_falloff = tgui_input_number(src, "How much falloff should the wall clear blast have?", "Set clear falloff", 400)
			if(isnull(OBShell.clear_falloff)) return
			OBShell.clear_delay = tgui_input_number(src, "How much delay should the clear blast have?", "Set clear delay", 3)
			if(isnull(OBShell.clear_delay)) return
			OBShell.distance = tgui_input_number(src, "How many tiles radius should the fire be? (Max 30)", "Set fire radius", 18, 30)
			if(isnull(OBShell.distance)) return
			if(OBShell.distance > 30)
				OBShell.distance = 30
			OBShell.fire_level = tgui_input_number(src, "How long should the fire last?", "Set fire duration", 70)
			if(isnull(OBShell.fire_level)) return
			OBShell.burn_level = tgui_input_number(src, "How damaging should the fire be?", "Set fire strength", 80)
			if(isnull(OBShell.burn_level)) return
			var/list/firetypes = list("white","blue","red","green","custom")
			OBShell.fire_type = tgui_input_list(usr, "Select the fire color:", "Fire color", firetypes)
			if(isnull(OBShell.fire_type)) return
			OBShell.fire_color = null
			if(OBShell.fire_type == "custom")
				OBShell.fire_type = "dynamic"
				OBShell.fire_color = input(src, "Please select Fire color.", "Fire color") as color|null
				if(isnull(OBShell.fire_color)) return
			statsmessage = "Custom Incendiary OB ([OBShell.name]) Stats from [key_name(usr)]: Clear Power: [OBShell.clear_power], Clear Falloff: [OBShell.clear_falloff], Clear Delay: [OBShell.clear_delay], Fire Distance: [OBShell.distance], Fire Duration: [OBShell.fire_level], Fire Strength: [OBShell.burn_level]."
			warhead = OBShell
			qdel(OBShell)

	if(custom)
		if(alert(usr, statsmessage, usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return
		message_admins(statsmessage)

	var/turf/target = get_turf(usr.loc)

	if(alert(usr, "Fire or Spawn Warhead?", "Mode", "Fire", "Spawn") == "Fire")
		if(alert("Are you SURE you want to do this? It will create an OB explosion!", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return
		message_admins("[key_name(usr)] has fired \an [warhead.name] at ([target.x],[target.y],[target.z]).")
		warhead.warhead_impact(target)
		QDEL_IN(warhead, OB_CRASHING_DOWN)
	else
		warhead.loc = target

/client/proc/change_taskbar_icon()
	set name = "Set Taskbar Icon"
	set desc = "Change the taskbar icon to a preset list of selectable icons."
	set category = "Admin.Events"

	if(!check_rights(R_ADMIN))
		return

	var/taskbar_icon = tgui_input_list(usr, "Select an icon you want to appear on the player's taskbar.", "Taskbar Icon", GLOB.available_taskbar_icons)
	if(!taskbar_icon)
		return

	SSticker.mode.taskbar_icon = taskbar_icon
	SSticker.set_clients_taskbar_icon(taskbar_icon)
	message_admins("[key_name_admin(usr)] has changed the taskbar icon to [taskbar_icon].")

/client/proc/cmd_admin_create_bioscan()
	set name = "Report: Bioscan"
	set category = "Admin.Factions"

	if(!admin_holder || !(admin_holder.rights & R_MOD))
		to_chat(src, "Only administrators may use this command.")
		return

	var/choice = tgui_alert(usr, "Are you sure you want to trigger a bioscan?", "Bioscan?", list("Yes", "No"))
	if(choice != "Yes")
		return
	else
		var/faction = tgui_input_list(usr, "What faction do you wish to provide a bioscan for?", "Bioscan Faction", list("Xeno","Marine","Yautja"), 20 SECONDS)
		var/variance = tgui_input_number(usr, "How variable do you want the scan to be? (+ or - an amount from truth)", "Variance", 2, 10, 0, 20 SECONDS)
		GLOB.bioscan_data.get_scan_data()
		switch(faction)
			if("Xeno")
				GLOB.bioscan_data.qm_bioscan(variance)
			if("Marine")
				GLOB.bioscan_data.ares_bioscan(FALSE, variance)
			if("Yautja")
				GLOB.bioscan_data.yautja_bioscan()

/client/proc/admin_blurb()
	set name = "Global Blurb Message"
	set category = "Admin.Events"

	if(!check_rights(R_ADMIN|R_DEBUG))
		return FALSE
	var/duration = 5 SECONDS
	var/message = "ADMIN TEST"
	var/text_input = tgui_input_text(usr, "Announcement message", "Message Contents", message, timeout = 5 MINUTES)
	message = text_input
	duration = tgui_input_number(usr, "Set the duration of the alert in deci-seconds.", "Duration", 5 SECONDS, 5 MINUTES, 5 SECONDS, 20 SECONDS)
	var/confirm = tgui_alert(usr, "Are you sure you wish to send '[message]' to all players for [(duration / 10)] seconds?", "Confirm", list("Yes", "No"), 20 SECONDS)
	if(confirm != "Yes")
		return FALSE
	show_blurb(GLOB.player_list, duration, message, TRUE, "center", "center", "#bd2020", "ADMIN")
	message_admins("[key_name(usr)] sent an admin blurb alert to all players. Alert reads: '[message]' and lasts [(duration / 10)] seconds.")
