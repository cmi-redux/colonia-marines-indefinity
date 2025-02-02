/datum/admins/proc/topic_teleports(href)
	switch(href)
		if("jump_to_area")
			var/area/choice = tgui_input_list(owner, "Pick an area to jump to:", "Jump", return_sorted_areas())
			if(QDELETED(choice))
				return

			owner.jump_to_area(choice)

		if("jump_to_turf")
			var/turf/choice = tgui_input_list(owner, "Pick a turf to jump to:", "Jump", GLOB.turfs)
			if(QDELETED(choice))
				return

			owner.jump_to_turf(choice)

		if("jump_to_mob")
			var/mob/choice = tgui_input_list(owner, "Pick a mob to jump to:", "Jump", GLOB.mob_list)
			if(QDELETED(choice))
				return

			owner.jumptomob(choice)

		if("jump_to_coord")
			var/targ_x = tgui_input_number(owner, "Jump to x from 0 to [world.maxx].", "Jump to X", 0, world.maxx, 0)
			if(!targ_x || targ_x < 0)
				return
			var/targ_y = tgui_input_number(owner, "Jump to y from 0 to [world.maxy].", "Jump to Y", 0, world.maxy, 0)
			if(!targ_y || targ_y < 0)
				return
			var/targ_z = tgui_input_number(owner, "Jump to z from 0 to [world.maxz].", "Jump to Z", 0, world.maxz, 0)
			if(!targ_z || targ_z < 0)
				return

			owner.jumptocoord(targ_x, targ_y, targ_z)

		if("jump_to_offset_coord")
			var/targ_x = tgui_input_real_number(owner, "Jump to X coordinate.")
			if(!targ_x)
				return
			var/targ_y = tgui_input_real_number(owner, "Jump to Y coordinate.")
			if(!targ_y)
				return

			owner.jumptooffsetcoord(targ_x, targ_y)

		if("jump_to_obj")
			var/list/obj/targets = list()
			for(var/obj/O in world)
				targets += O
			var/obj/choice = tgui_input_list(owner, "Pick an object to jump to:", "Jump", targets)
			if(QDELETED(choice))
				return

			owner.jump_to_object(choice)

		if("jump_to_key")
			owner.jumptokey()

		if("get_mob")
			var/mob/choice = tgui_input_list(owner, "Pick a mob to teleport here:","Get Mob", GLOB.mob_list)
			if(QDELETED(choice))
				return

			owner.Getmob(choice)

		if("get_key")
			owner.Getkey()

		if("teleport_mob_to_area")
			var/mob/choice = tgui_input_list(owner, "Pick a mob to an area:","Teleport Mob", sortmobs())
			if(QDELETED(choice))
				return

			owner.sendmob(choice)

		if("teleport_mobs_in_range")
			var/collect_range = tgui_input_number(owner, "Enter range from 0 to 7 tiles. All alive /living mobs within selected range will be marked for teleportation.", "Mass-teleportation", 0, 7, 0)
			if(collect_range < 0 || collect_range > 7)
				to_chat(owner, SPAN_ALERT("Incorrect range. Aborting."))
				return
			var/list/targets = list()
			for(var/mob/living/M in range(collect_range, owner.mob))
				if(M.stat != DEAD)
					targets.Add(M)
			if(targets.len < 1)
				to_chat(owner, SPAN_ALERT("No alive /living mobs found. Aborting."))
				return
			if(alert(owner, "[targets.len] mobs were marked for teleportation. Pressing \"TELEPORT\" will teleport them to your location at the moment of pressing button.", owner.auto_lang(LANGUAGE_CONFIRM), owner.auto_lang(LANGUAGE_YES), owner.auto_lang(LANGUAGE_NO)) != owner.auto_lang(LANGUAGE_YES))
				return
			for(var/mob/M in targets)
				if(!M)
					continue
				M.on_mob_jump()
				M.forceMove(get_turf(owner.mob))

			message_admins(WRAP_STAFF_LOG(owner.mob, "mass-teleported [targets.len] mobs in [collect_range] tiles range to themselves in [get_area(owner.mob)] ([owner.mob.x],[owner.mob.y],[owner.mob.z])."), owner.mob.x, owner.mob.y, owner.mob.z)

		if("teleport_mobs_by_faction")
			var/list/datum/faction/factions = list()
			for(var/faction_to_get in FACTION_LIST_ALL)
				var/datum/faction/faction_to_set = GLOB.faction_datums[faction_to_get]
				LAZYSET(factions, faction_to_set.name, faction_to_set)

			var/choice = tgui_input_list(owner, "Select faction you want to teleport to your location. Mobs in Thunderdome/CentComm areas won't be included.", "Faction Choice", factions)
			if(!choice)
				return

			var/list/targets = factions[choice].totalMobs
			for(var/mob/living/carbon/mob in targets)
				var/area/area = get_area(mob)
				if(mob.stat == DEAD || area.statistic_exempt)
					targets.Remove(mob)

			if(!length(targets))
				to_chat(owner, SPAN_ALERT("No alive /human mobs of [choice] faction were found. Aborting."))
				return

			if(alert(owner, "[targets.len] humanoids of [choice] faction were marked for teleportation. Pressing \"TELEPORT\" will teleport them to your location at the moment of pressing button.", owner.auto_lang(LANGUAGE_CONFIRM), owner.auto_lang(LANGUAGE_YES), owner.auto_lang(LANGUAGE_NO)) != owner.auto_lang(LANGUAGE_YES))
				return

			for(var/mob/mob in targets)
				if(!mob)
					continue
				mob.on_mob_jump()
				mob.forceMove(get_turf(owner.mob))

			message_admins(WRAP_STAFF_LOG(owner.mob, "mass-teleported [length(targets)] mobs of [choice] faction to themselves in [get_area(owner.mob)] ([owner.mob.x],[owner.mob.y],[owner.mob.z])."), owner.mob.x, owner.mob.y, owner.mob.z)

		if("teleport_corpses")
			if(GLOB.dead_mob_list.len < 0)
				to_chat(owner, SPAN_ALERT("No corpses found. Aborting."))
				return

			if(alert(owner, "[GLOB.dead_mob_list.len] corpses are marked for teleportation. Pressing \"YES\" will teleport them to your location at the moment of pressing button.", owner.auto_lang(LANGUAGE_CONFIRM), owner.auto_lang(LANGUAGE_YES), owner.auto_lang(LANGUAGE_NO)) != owner.auto_lang(LANGUAGE_YES))
				return
			for(var/mob/M in GLOB.dead_mob_list)
				if(!M)
					continue
				M.on_mob_jump()
				M.forceMove(get_turf(owner.mob))
			message_admins(WRAP_STAFF_LOG(owner.mob, "mass-teleported [GLOB.dead_mob_list.len] corpses to themselves in [get_area(owner.mob)] ([owner.mob.x],[owner.mob.y],[owner.mob.z])."), owner.mob.x, owner.mob.y, owner.mob.z)

		if("teleport_items_by_type")
			var/item = input(owner,"What item?", "Item Fetcher","") as text|null
			if(!item)
				return

			var/list/types = typesof(/obj)
			var/list/matches = new()

			//Figure out which object they might be trying to fetch
			for(var/path in types)
				if(findtext("[path]", item))
					matches += path

			if(matches.len==0)
				return

			var/choice
			if(matches.len==1)
				choice = matches[1]
			else
				//If we have multiple options, let them select which one they meant
				choice = tgui_input_list(usr, "Select an object type", "Find Object", matches)

			if(!choice)
				return

			//Find all items in the world
			var/list/targets = list()
			for(var/obj/item/M in world)
				if(istype(M, choice))
					targets += M

			if(targets.len < 1)
				to_chat(owner, SPAN_ALERT("No items of type [choice] were found. Aborting."))
				return

			if(alert(owner, "[targets.len] items are marked for teleportation. Pressing \"YES\" will teleport them to your location at the moment of pressing button.", owner.auto_lang(LANGUAGE_CONFIRM), owner.auto_lang(LANGUAGE_YES), owner.auto_lang(LANGUAGE_NO)) != owner.auto_lang(LANGUAGE_YES))
				return

			//Fetch the items
			for(var/obj/item/M in targets)
				if(!M)
					continue
				M.forceMove(get_turf(owner.mob))

			message_admins(WRAP_STAFF_LOG(owner.mob, "mass-teleported [targets.len] items of type [choice] to themselves in [get_area(owner.mob)] ([owner.mob.x],[owner.mob.y],[owner.mob.z])."), owner.mob.x, owner.mob.y, owner.mob.z)
