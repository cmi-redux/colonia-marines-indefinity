/datum/admins/proc/CheckAdminHref(href, href_list)
	var/auth = href_list["admin_token"]
	. = auth && (auth == href_token || auth == GLOB.href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	message_admins("[key_name_admin(usr)] clicked an href with [msg] authorization key!")
	if(CONFIG_GET(flag/debug_admin_hrefs))
		message_admins("Debug mode enabled, call not blocked. Please ask your coders to review this round's logs.")
		log_world("UAH: [href]")
		return TRUE
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")

/datum/admins/Topic(href, href_list)
	..()
	var/choice
	if(usr.client != owner || !check_rights(0))
		message_admins("[usr.key] has attempted to override the admin panel!")
		return

	if(!CheckAdminHref(href, href_list))
		return


	if(href_list["ahelp"])
		if(!check_rights(R_ADMIN|R_MOD, TRUE))
			return

		var/ahelp_ref = href_list["ahelp"]
		var/datum/admin_help/AH = locate(ahelp_ref)
		if(AH)
			AH.Action(href_list["ahelp_action"])
		else
			to_chat(usr, "Ticket [ahelp_ref] has been deleted!", confidential = TRUE)
		return

	if(href_list["adminplayeropts"])
		var/mob/mob = locate(href_list["adminplayeropts"])
		show_player_panel(mob)
		return

	if(href_list["editrights"])
		if(!check_rights(R_PERMISSIONS))
			message_admins("[key_name_admin(usr)] attempted to edit the admin permissions without sufficient rights.")
			return

		var/adm_ckey

		var/task = href_list["editrights"]
		if(task == "add")
			var/new_ckey = ckey(input(usr,"New admin's ckey","Admin ckey", null) as text|null)
			if(!new_ckey) return
			if(new_ckey in admin_datums)
				to_chat(usr, "<font color='red'>Error: Topic 'editrights': [new_ckey] is already an admin</font>")
				return
			adm_ckey = new_ckey
			task = "rank"
		else if(task != "show")
			adm_ckey = ckey(href_list["ckey"])
			if(!adm_ckey)
				to_chat(usr, "<font color='red'>Error: Topic 'editrights': No valid ckey</font>")
				return

		var/datum/admins/D = admin_datums[adm_ckey]

		if(task == "remove")
			if(alert("Are you sure you want to remove [adm_ckey]?","Message",usr.client.auto_lang(LANGUAGE_YES),"Cancel") == usr.client.auto_lang(LANGUAGE_YES))
				if(!D)
					return
				admin_datums -= adm_ckey
				D.disassociate()

				message_admins("[key_name_admin(usr)] removed [adm_ckey] from the admins list")

		else if(task == "rank")
			var/new_rank
			if(admin_ranks.len)
				new_rank = tgui_input_list(usr, "Please select a rank", "New rank", (admin_ranks|"*New Rank*"))
			else
				new_rank = tgui_input_list(usr, "Please select a rank", "New rank", list("Game Master","Game Admin", "Trial Admin", "Admin Observer","*New Rank*"))

			var/rights = 0
			if(D)
				rights = D.rights
			switch(new_rank)
				if(null,"") return
				if("*New Rank*")
					new_rank = input("Please input a new rank", "New custom rank", null, null) as null|text
					if(CONFIG_GET(flag/admin_legacy_system))
						new_rank = ckeyEx(new_rank)
					if(!new_rank)
						to_chat(usr, "<font color='red'>Error: Topic 'editrights': Invalid rank</font>")
						return
					if(CONFIG_GET(flag/admin_legacy_system))
						if(admin_ranks.len)
							if(new_rank in admin_ranks)
								rights = admin_ranks[new_rank] //we typed a rank which already exists, use its rights
							else
								admin_ranks[new_rank] = 0 //add the new rank to admin_ranks
				else
					if(CONFIG_GET(flag/admin_legacy_system))
						new_rank = ckeyEx(new_rank)
						rights = admin_ranks[new_rank] //we input an existing rank, use its rights

			if(D)
				D.disassociate() //remove adminverbs and unlink from client
				D.rank = new_rank //update the rank
				D.rights = rights //update the rights based on admin_ranks (default: 0)
			else
				D = new /datum/admins(new_rank, rights, adm_ckey)

			var/client/C = GLOB.directory[adm_ckey] //find the client with the specified ckey (if they are logged in)
			D.associate(C) //link up with the client and add verbs

			message_admins("[key_name_admin(usr)] edited the admin rank of [adm_ckey] to [new_rank]")

		else if(task == "permissions")
			if(!D) return
			var/list/permissionlist = list()
			for(var/i=1, i<=R_HOST, i<<=1) //that <<= is shorthand for i = i << 1. Which is a left bitshift
				permissionlist[rights2text(i)] = i
			var/new_permission = tgui_input_list(usr, "Select a permission to turn on/off", "Permission toggle", permissionlist)
			if(!new_permission) return
			D.rights ^= permissionlist[new_permission]

			message_admins("[key_name_admin(usr)] toggled the [new_permission] permission of [adm_ckey]")

//======================================================
//Everything that has to do with evac and self-destruct.
//The rest of this is awful.
//======================================================
	if(href_list["evac_authority"])
		switch(href_list["evac_authority"])
			if("init_evac")
				if(!SSevacuation.initiate_evacuation())
					to_chat(usr, SPAN_WARNING("You are unable to initiate an evacuation right now!"))
				else
					message_admins("[key_name_admin(usr)] called an evacuation.")

			if("cancel_evac")
				if(!SSevacuation.cancel_evacuation())
					to_chat(usr, SPAN_WARNING("You are unable to cancel an evacuation right now!"))
				else
					message_admins("[key_name_admin(usr)] canceled an evacuation.")

			if("toggle_evac")
				SSevacuation.flags_scuttle ^= FLAGS_EVACUATION_DENY
				message_admins("[key_name_admin(usr)] has [SSevacuation.flags_scuttle & FLAGS_EVACUATION_DENY ? "forbidden" : "allowed"] ship-wide evacuation.")

			if("force_evac")
				if(!SSevacuation.begin_launch())
					to_chat(usr, SPAN_WARNING("You are unable to launch the pods directly right now!"))
				else
					message_admins("[key_name_admin(usr)] force-launched the escape pods.")

			if("init_dest")
				if(!SSevacuation.enable_self_destruct(FALSE, FALSE))
					to_chat(usr, SPAN_WARNING("You are unable to authorize the self-destruct right now!"))
				else
					message_admins("[key_name_admin(usr)] force-enabled the self-destruct system.")

			if("cancel_dest")
				if(!SSevacuation.cancel_self_destruct(TRUE, FALSE))
					to_chat(usr, SPAN_WARNING("You are unable to cancel the self-destruct right now!"))
				else
					message_admins("[key_name_admin(usr)] canceled the self-destruct system.")

			if("use_dest")

				var/confirm = alert("Are you sure you want to self-destruct the Almayer?", "Self-Destruct", usr.client.auto_lang(LANGUAGE_YES), "Cancel")
				if(confirm != usr.client.auto_lang(LANGUAGE_YES))
					return
				message_admins("[key_name_admin(usr)] forced the self-destrust system, destroying the [MAIN_SHIP_NAME].")
				SSevacuation.trigger_self_destruct()

			if("toggle_dest")
				SSevacuation.flags_scuttle ^= FLAGS_SELF_DESTRUCT_DENY
				message_admins("[key_name_admin(usr)] has [SSevacuation.flags_scuttle & FLAGS_SELF_DESTRUCT_DENY ? "forbidden" : "allowed"] the self-destruct system.")

//======================================================
//======================================================

	else if(href_list["delay_round_end"])
		if(!check_rights(R_SERVER))
			return

		SSticker.delay_end = !SSticker.delay_end
		message_admins("[key_name(usr)] [SSticker.delay_end ? "delayed the round end" : "has made the round end normally"].")

	else if(href_list["simplemake"])

		if(!check_rights(R_SPAWN))
			return

		var/mob/mob = locate(href_list["mob"])
		if(!ismob(mob))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		var/delmob = 0
		choice = alert("Delete old mob?", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO), usr.client.auto_lang(LANGUAGE_CANCEL))
		if(choice == usr.client.auto_lang(LANGUAGE_CANCEL))
			return
		else if(choice == usr.client.auto_lang(LANGUAGE_YES))
			delmob = 1

		message_admins("[key_name_admin(usr)] has used rudimentary transformation on [key_name_admin(mob)]. Transforming to [href_list["simplemake"]]; deletemob=[delmob]")

		var/mob/transformed
		var/datum/faction/faction = GLOB.faction_datum[FACTION_XENOMORPH_NORMAL]

		if(isxeno(mob))
			var/mob/living/carbon/xenomorph/xeno = mob
			faction = xeno.faction

		switch(href_list["simplemake"])
			if("observer") transformed = mob.change_mob_type( /mob/dead/observer , null, null, delmob )

			if("larva") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/larva , null, null, delmob )
			if("facehugger") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/facehugger , null, null, delmob )
			if("defender") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/defender, null, null, delmob )
			if("warrior") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/warrior, null, null, delmob )
			if("runner") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/runner , null, null, delmob )
			if("drone") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/drone , null, null, delmob )
			if("sentinel") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/sentinel , null, null, delmob )
			if("lurker") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/lurker , null, null, delmob )
			if("carrier") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/carrier , null, null, delmob )
			if("hivelord") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/hivelord , null, null, delmob )
			if("praetorian") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/praetorian , null, null, delmob )
			if("ravager") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/ravager , null, null, delmob )
			if("spitter") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/spitter , null, null, delmob )
			if("boiler") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/boiler , null, null, delmob )
			if("burrower") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/burrower , null, null, delmob )
			if("crusher") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/crusher , null, null, delmob )
			if("queen") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/queen , null, null, delmob )
			if("predalien") transformed = mob.change_mob_type( /mob/living/carbon/xenomorph/predalien , null, null, delmob )

			if("human") transformed = mob.change_mob_type( /mob/living/carbon/human , null, null, delmob, href_list["species"])
			if("monkey") transformed = mob.change_mob_type( /mob/living/carbon/human/monkey , null, null, delmob )
			if("farwa") transformed = mob.change_mob_type( /mob/living/carbon/human/farwa , null, null, delmob )
			if("neaera") transformed = mob.change_mob_type( /mob/living/carbon/human/neaera , null, null, delmob )
			if("yiren") transformed = mob.change_mob_type( /mob/living/carbon/human/yiren , null, null, delmob )
			if("robot") transformed = mob.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat") transformed = mob.change_mob_type( /mob/living/simple_animal/cat , null, null, delmob )
			if("runtime") transformed = mob.change_mob_type( /mob/living/simple_animal/cat/Runtime , null, null, delmob )
			if("corgi") transformed = mob.change_mob_type( /mob/living/simple_animal/corgi , null, null, delmob )
			if("ian") transformed = mob.change_mob_type( /mob/living/simple_animal/corgi/Ian , null, null, delmob )
			if("crab") transformed = mob.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee") transformed = mob.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot") transformed = mob.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
			if("polyparrot") transformed = mob.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )

		if(isxeno(transformed) && faction)
			var/mob/living/carbon/xenomorph/xeno = transformed
			xeno.set_hive_and_update(faction)

	/////////////////////////////////////new ban stuff
	else if(href_list["unbanf"])
		var/datum/entity/player/P = get_player_from_key(href_list["unbanf"])
		choice = alert("Are you sure you want to remove timed ban from [P.ckey]?", , usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO))
		if(choice == usr.client.auto_lang(LANGUAGE_NO))
			return
		if(!P.remove_timed_ban())
			alert(usr, "This ban has already been lifted / does not exist.", "Error", "Ok")
		unbanpanel()

	else if(href_list["warn"])
		usr.client.warn(href_list["warn"])

	else if(href_list["unbanupgradeperma"])
		if(!check_rights(R_ADMIN)) return
		UpdateTime()
		var/reason

		var/banfolder = href_list["unbanupgradeperma"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/mins = 0
		if(minutes > CMinutes)
			mins = minutes - CMinutes
		if(!mins) return
		mins = max(5255990,mins) // 10 years
		minutes = CMinutes + mins
		reason = input(usr,"Reason?","reason",reason2) as message|null
		if(!reason) return

		ban_unban_log_save("[key_name(usr)] upgraded [banned_key]'s ban to a permaban. Reason: [sanitize(reason)]")
		message_admins("[key_name_admin(usr)] upgraded [banned_key]'s ban to a permaban. Reason: [sanitize(reason)]")
		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << sanitize(reason)
		Banlist["temp"] << 0
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		unbanpanel()

	else if(href_list["unbane"])
		if(!check_rights(R_BAN)) return

		UpdateTime()
		var/reason

		var/banfolder = href_list["unbane"]
		Banlist.cd = "/base/[banfolder]"
		var/reason2 = Banlist["reason"]
		var/temp = Banlist["temp"]

		var/minutes = Banlist["minutes"]

		var/banned_key = Banlist["key"]
		Banlist.cd = "/base"

		var/duration

		var/mins = 0
		if(minutes > CMinutes)
			mins = minutes - CMinutes
		mins = tgui_input_number(usr,"How long (in minutes)? \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days \n 43800 = 1 Month","Ban time", 1440, 262800, 1)
		if(!mins) return
		mins = min(525599,mins)
		minutes = CMinutes + mins
		duration = GetExp(minutes)
		reason = input(usr,"Reason?","reason",reason2) as message|null
		if(!reason) return

		ban_unban_log_save("[key_name(usr)] edited [banned_key]'s ban. Reason: [sanitize(reason)] Duration: [duration]")
		message_admins("[key_name_admin(usr)] edited [banned_key]'s ban. Reason: [sanitize(reason)] Duration: [duration]")
		Banlist.cd = "/base/[banfolder]"
		Banlist["reason"] << sanitize(reason)
		Banlist["temp"] << temp
		Banlist["minutes"] << minutes
		Banlist["bannedby"] << usr.ckey
		Banlist.cd = "/base"
		unbanpanel()

	/////////////////////////////////////new ban stuff

	else if(href_list["jobban2"])
// if(!check_rights(R_BAN)) return
		/*
		var/mob/mob = locate(href_list["jobban2"])
		if(!ismob(mob))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(!mob.ckey) //sanity
			to_chat(usr, "This mob has no ckey")
			return
		if(!SSticker.role_authority)
			to_chat(usr, "The Role Authority is not set up!")
			return

		var/datum/entity/player/P = get_player_from_key(mob.ckey)

		var/dat = ""
		var/body
		var/jobs = ""

	/***********************************WARNING!************************************
					  The jobban stuff looks mangled and disgusting
							  But it looks beautiful in-game
										-Nodrak
	************************************WARNING!***********************************/
//Regular jobs
	//Command (Blue)
		jobs += generate_job_ban_list(mob, ROLES_CIC, "CIC", "ddddff")
		jobs += "<br>"
	// SUPPORT
		jobs += generate_job_ban_list(mob, ROLES_AUXIL_SUPPORT, "Support", "ccccff")
		jobs += "<br>"
	// MPs
		jobs += generate_job_ban_list(mob, ROLES_POLICE, "Police", "ffdddd")
		jobs += "<br>"
	//Engineering (Yellow)
		jobs += generate_job_ban_list(mob, ROLES_ENGINEERING, "Engineering", "fff5cc")
		jobs += "<br>"
	//Cargo (Yellow) //Copy paste, yada, yada. Hopefully Snail can rework this in the future.
		jobs += generate_job_ban_list(mob, ROLES_REQUISITION, "Requisition", "fff5cc")
		jobs += "<br>"
	//Medical (White)
		jobs += generate_job_ban_list(mob, ROLES_MEDICAL, "Medical", "ffeef0")
		jobs += "<br>"
	//Marines
		jobs += generate_job_ban_list(mob, ROLES_MARINES, "Marines", "ffeeee")
		jobs += "<br>"
	// MISC
		jobs += generate_job_ban_list(mob, ROLES_MISC, "Misc", "aaee55")
		jobs += "<br>"
	// Xenos (Orange)
		jobs += generate_job_ban_list(mob, ROLES_REGULAR_XENO, "Xenos", "a268b1")
		jobs += "<br>"
	//Extra (Orange)
		var/isbanned_dept = jobban_isbanned(mob, "Syndicate", P)
		jobs += "<table cellpadding='1' cellspacing='0' width='100%'>"
		jobs += "<tr bgcolor='ffeeaa'><th colspan='10'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=Syndicate;jobban4=\ref[mob]'>Extras</a></th></tr><tr align='center'>"

		//ERT
		if(jobban_isbanned(mob, "Emergency Response Team", P) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=Emergency Response Team;jobban4=\ref[mob]'><font color=red>Emergency Response Team</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=Emergency Response Team;jobban4=\ref[mob]'>Emergency Response Team</a></td>"

		//Survivor
		if(jobban_isbanned(mob, "Survivor", P) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=Survivor;jobban4=\ref[mob]'><font color=red>Survivor</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=Survivor;jobban4=\ref[mob]'>Survivor</a></td>"

		if(jobban_isbanned(mob, "Agent", P) || isbanned_dept)
			jobs += "<td width='20%'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=Agent;jobban4=\ref[mob]'><font color=red>Agent</font></a></td>"
		else
			jobs += "<td width='20%'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=Agent;jobban4=\ref[mob]'>Agent</a></td>"

		body = "<body>[jobs]</body>"
		dat = "<tt>[body]</tt>"
		show_browser(usr, dat, "Job-Ban Panel: [mob.name]", "jobban2", "size=800x490")
		return*/ // DEPRECATED
	//JOBBAN'S INNARDS
	else if(href_list["jobban3"])
		if(!check_rights(R_MOD,0) && !check_rights(R_ADMIN))  return

		var/mob/mob = locate(href_list["jobban4"])
		if(!ismob(mob))
			to_chat(usr, "This can only be used on instances of type /mob")
			return

		if(mob != usr)																//we can jobban ourselves
			if(mob.client && mob.client.admin_holder && (mob.client.admin_holder.rights & R_BAN))		//they can ban too. So we can't ban them
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return

		if(!SSticker.role_authority)
			to_chat(usr, "Role Authority has not been set up!")
			return

		var/datum/entity/player/P1 = mob.client?.player_data
		if(!P1)
			P1 = get_player_from_key(mob.ckey)

		//get jobs for department if specified, otherwise just returnt he one job in a list.
		var/list/joblist = list()
		switch(href_list["jobban3"])
			if("CICdept")
				joblist += get_job_titles_from_list(ROLES_COMMAND)
			if("Supportdept")
				joblist += get_job_titles_from_list(ROLES_AUXIL_SUPPORT)
			if("Policedept")
				joblist += get_job_titles_from_list(ROLES_POLICE)
			if("Engineeringdept")
				joblist += get_job_titles_from_list(ROLES_ENGINEERING)
			if("Requisitiondept")
				joblist += get_job_titles_from_list(ROLES_REQUISITION)
			if("Medicaldept")
				joblist += get_job_titles_from_list(ROLES_MEDICAL)
			if("Marinesdept")
				joblist += get_job_titles_from_list(ROLES_MARINES)
			if("Miscdept")
				joblist += get_job_titles_from_list(ROLES_MISC)
			if("Xenosdept")
				joblist += get_job_titles_from_list(ROLES_REGULAR_XENO)
			else
				joblist += href_list["jobban3"]

		var/list/notbannedlist = list()
		for(var/job in joblist)
			if(!jobban_isbanned(mob, job, P1))
				notbannedlist += job

		//Banning comes first
		if(notbannedlist.len)
			if(!check_rights(R_BAN))  return
			var/reason = input(usr,"Reason?","Please State Reason","") as text|null
			if(reason)
				var/datum/entity/player/P = get_player_from_key(mob.ckey)
				P.add_job_ban(reason, notbannedlist)

				href_list["jobban2"] = 1 // lets it fall through and refresh
				return 1

		//Unbanning joblist
		//all jobs in joblist are banned already OR we didn't give a reason (implying they shouldn't be banned)
		if(joblist.len) //at least 1 banned job exists in joblist so we have stuff to unban.
			for(var/job in joblist)
				var/reason = jobban_isbanned(mob, job, P1)
				if(!reason) continue //skip if it isn't jobbanned anyway
				if(alert("Job: '[job]' Reason: '[reason]' Un-jobban?","Please Confirm",usr.client.auto_lang(LANGUAGE_YES),usr.client.auto_lang(LANGUAGE_NO)) == usr.client.auto_lang(LANGUAGE_YES))
					P1.remove_job_ban(job)
				else
					continue
			href_list["jobban2"] = 1 // lets it fall through and refresh

			return 1
		return 0 //we didn't do anything!
	else if(href_list["adminplayerobservefollow"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		usr.client?.admin_follow(locate(href_list["adminplayerobservefollow"]))
	else if(href_list["boot2"])
		var/mob/mob = locate(href_list["boot2"])
		if(ismob(mob))
			if(!check_if_greater_rights_than(mob.client))
				return
			var/reason = input("Please enter reason")
			if(!reason)
				to_chat_forced(mob, SPAN_WARNING("You have been kicked from the server"))
			else
				to_chat_forced(mob, SPAN_WARNING("You have been kicked from the server: [reason]"))
			message_admins("[key_name_admin(usr)] booted [key_name_admin(mob)].")
			qdel(mob.client)

	else if(href_list["removejobban"])
		if(!check_rights(R_BAN)) return

		var/t = href_list["removejobban"]
		if(t)
			if((alert("Do you want to unjobban [t]?", "Unjobban confirmation", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) == usr.client.auto_lang(LANGUAGE_YES)) && t) //No more misclicks! Unless you do it twice.
				message_admins("[key_name_admin(usr)] removed [t]")
				jobban_remove(t)
				jobban_savebanfile()
				href_list["ban"] = 1 // lets it fall through and refresh

	else if(href_list["newban"])
		if(!check_rights(R_MOD,0) && !check_rights(R_BAN))  return

		var/mob/mob = locate(href_list["newban"])
		if(!ismob(mob)) return

		if(mob.client && mob.client.admin_holder && (mob.client.admin_holder.rights & R_MOD))
			return	//mods+ cannot be banned. Even if they could, the ban doesn't affect them anyway

		if(!mob.ckey)
			to_chat(usr, SPAN_DANGER("<B>Warning: Mob ckey for [mob.name] not found.</b>"))
			return
		var/mob_key = mob.ckey
		var/mins = tgui_input_number(usr, "How long (in minutes)? \n 1440 = 1 day \n 4320 = 3 days \n 10080 = 7 days \n 43800 = 1 Month", "Ban time", 1440, 43800, 1)
		if(!mins)
			return
		if(mins >= 525600)
			mins = 525599
		var/reason = input(usr, "Reason? \n\nPress 'OK' to finalize the ban.", "reason", "Griefer") as message|null
		if(!reason)
			return
		var/datum/entity/player/P = get_player_from_key(mob_key) // you may not be logged in, but I will find you and I will ban you
		if(P.is_time_banned && alert(usr, "Ban already exists. Proceed?", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return
		P.add_timed_ban(reason, mins)

	else if(href_list["eorgban"])
		if(!check_rights(R_MOD,0) && !check_rights(R_BAN))
			return

		var/mob/mob = locate(href_list["eorgban"])
		if(!ismob(mob)) return

		if(mob.client && mob.client.admin_holder)
			return	//admins cannot be banned. Even if they could, the ban doesn't affect them anyway

		if(!mob.ckey)
			to_chat(usr, SPAN_DANGER("<B>Warning: Mob ckey for [mob.name] not found.</b>"))
			return

		var/mins = 0
		var/reason = ""
		if(alert("Are you sure you want to EORG ban [mob.ckey]?", , usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return
		mins = 180
		reason = "EORG - Generating combat logs with, or otherwise griefing, friendly/allied players."
		var/datum/entity/player/P = get_player_from_key(mob.ckey) // you may not be logged in, but I will find you and I will ban you
		if(P.is_time_banned && alert(usr, "Ban already exists. Proceed?", usr.client.auto_lang(LANGUAGE_CONFIRM), usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return
		P.add_timed_ban(reason, mins)

	else if(href_list["xenoresetname"])
		if(!check_rights(R_MOD,0) && !check_rights(R_BAN))
			return

		var/mob/living/carbon/xenomorph/xeno = locate(href_list["xenoresetname"])
		if(!isxeno(xeno))
			to_chat(usr, SPAN_WARNING("Not a xeno"))
			return

		if(alert("Are you sure you want to reset xeno name for [xeno.ckey]?", , usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		if(!xeno.ckey)
			to_chat(usr, SPAN_DANGER("Warning: Mob ckey for [xeno.name] not found."))
			return

		message_admins("[usr.client.ckey] has reset [xeno.ckey] xeno name")

		to_chat(xeno, SPAN_DANGER("Warning: Your xeno name has been reset by [usr.client.ckey]."))

		xeno.client.xeno_prefix = "XX"
		xeno.client.xeno_postfix = ""
		xeno.client.prefs.xeno_prefix = "XX"
		xeno.client.prefs.xeno_postfix = ""

		xeno.client.prefs.save_preferences()
		xeno.generate_name()

	else if(href_list["xenobanname"])
		if(!check_rights(R_MOD,0) && !check_rights(R_BAN))
			return

		var/mob/living/carbon/xenomorph/xeno = locate(href_list["xenobanname"])
		var/mob/mob = locate(href_list["xenobanname"])

		if(ismob(mob) && xeno.client && xeno.client.xeno_name_ban)
			if(alert("Are you sure you want to UNBAN [xeno.ckey] and let them use xeno name?",usr.client.auto_lang(LANGUAGE_YES),usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
				return
			xeno.client.xeno_name_ban = FALSE
			xeno.client.prefs.xeno_name_ban = FALSE

			xeno.client.prefs.save_preferences()
			message_admins("[usr.client.ckey] has unbanned [xeno.ckey] from using xeno names")

			notes_add(xeno.ckey, "Xeno Name Unbanned by [usr.client.ckey]", usr)
			to_chat(xeno, SPAN_DANGER("Warning: You can use xeno names again."))
			return


		if(!isxeno(xeno))
			to_chat(usr, SPAN_WARNING("Not a xeno"))
			return

		if(alert("Are you sure you want to BAN [xeno.ckey] from ever using any xeno name?", , usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		if(!xeno.ckey)
			to_chat(usr, SPAN_DANGER("Warning: Mob ckey for [xeno.name] not found."))
			return

		message_admins("[usr.client.ckey] has banned [xeno.ckey] from using xeno names")

		notes_add(xeno.ckey, "Xeno Name Banned by [usr.client.ckey]|Reason: Xeno name was [xeno.name]", usr)

		to_chat(xeno, SPAN_DANGER("Warning: You were banned from using xeno names by [usr.client.ckey]."))

		xeno.client.xeno_prefix = "XX"
		xeno.client.xeno_postfix = ""
		xeno.client.xeno_name_ban = TRUE
		xeno.client.prefs.xeno_prefix = "XX"
		xeno.client.prefs.xeno_postfix = ""
		xeno.client.prefs.xeno_name_ban = TRUE

		xeno.client.prefs.save_preferences()
		xeno.generate_name()

	else if(href_list["mute"])
		if(!check_rights(R_MOD,0) && !check_rights(R_ADMIN))
			return

		var/mob/mob = locate(href_list["mute"])
		if(!ismob(mob))
			return
		if(!mob.client)
			return

		var/mute_type = href_list["mute_type"]
		if(istext(mute_type)) mute_type = text2num(mute_type)
		if(!isnum(mute_type)) return

		cmd_admin_mute(mob, mute_type)

	else if(href_list["chem_panel"])
		topic_chems(href_list["chem_panel"])

	else if(href_list["c_mode"])
		if(!check_rights(R_ADMIN)) return

		var/dat = {"<B>What mode do you wish to play?</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];c_mode2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"Now: [GLOB.master_mode]"}
		show_browser(usr, dat, "Change Gamemode", "c_mode")

	else if(href_list["f_secret"])
		if(!check_rights(R_ADMIN)) return

		if(SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(GLOB.master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		var/dat = {"<B>What game mode do you want to force secret to be? Use this if you want to change the game mode, but want the players to believe it's secret. This will only work if the current game mode is secret.</B><HR>"}
		for(var/mode in config.modes)
			dat += {"<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];f_secret2=[mode]'>[config.mode_names[mode]]</A><br>"}
		dat += {"<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];f_secret2=secret'>Random (default)</A><br>"}
		dat += {"Now: [secret_force_mode]"}
		show_browser(usr, dat, "Change Secret Gamemode", "f_secret")

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER)) return

		GLOB.master_mode = href_list["c_mode2"]
		message_admins("[key_name_admin(usr)] set the mode as [GLOB.master_mode].")
		to_world(SPAN_NOTICE("<b><i>The mode is now: [GLOB.master_mode]!</i></b>"))
		Game() // updates the main game menu
		SSticker.save_mode(GLOB.master_mode)
		.(href, list("c_mode"=1))


	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER)) return

		if(SSticker.mode)
			return alert(usr, "The game has already started.", null, null, null, null)
		if(GLOB.master_mode != "secret")
			return alert(usr, "The game mode has to be secret!", null, null, null, null)
		secret_force_mode = href_list["f_secret2"]
		message_admins("[key_name_admin(usr)] set the forced secret mode as [secret_force_mode].")
		Game() // updates the main game menu
		.(href, list("f_secret"=1))

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN)) return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		message_admins("[key_name_admin(usr)] attempting to monkeyize [key_name_admin(H)]")
		H.monkeyize()

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN)) return

		var/mob/living/carbon/human/H = locate(href_list["corgione"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		message_admins("[key_name_admin(usr)] attempting to corgize [key_name_admin(H)]")
		H.corgize()

	else if(href_list["forcespeech"])
		if(!check_rights(R_ADMIN)) return

		var/mob/mob = locate(href_list["forcespeech"])
		if(!ismob(mob))
			to_chat(usr, "this can only be used on instances of type /mob")
			return

		var/speech = input("What will [key_name(mob)] say?.", "Force speech", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)
			return
		mob.say(speech)
		speech = sanitize(speech) // Nah, we don't trust them
		message_admins("[key_name_admin(usr)] forced [key_name_admin(mob)] to say: [speech]")

	else if(href_list["zombieinfect"])
		if(!check_rights(R_ADMIN)) return
		var/mob/living/carbon/human/H = locate(href_list["zombieinfect"])
		if(!istype(H))
			to_chat(usr, "this can only be used on instances of type /human")
			return

		if(alert(usr, "Are you sure you want to infect them with a ZOMBIE VIRUS? This can trigger a major event!", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		var/datum/disease/black_goo/bg = new()
		if(alert(usr, "Make them non-symptomatic carrier?", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) == usr.client.auto_lang(LANGUAGE_YES))
			bg.carrier = TRUE
		else
			bg.carrier = FALSE

		H.AddDisease(bg, FALSE)

		message_admins("[key_name_admin(usr)] infected [key_name_admin(H)] with a ZOMBIE VIRUS")
	else if(href_list["larvainfect"])
		if(!check_rights(R_ADMIN)) return
		var/mob/living/carbon/human/H = locate(href_list["larvainfect"])
		if(!istype(H))
			to_chat(usr, "this can only be used on instances of type /human")
			return

		if(alert(usr, "Are you sure you want to infect them with a xeno larva?", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		var/list/datum/faction/factions = list()
		for(var/faction_to_get in FACTION_LIST_XENOMORPH)
			var/datum/faction/faction_to_set = GLOB.faction_datum[faction_to_get]
			LAZYSET(factions, faction_to_set.name, faction_to_set)

		choice = tgui_input_list(usr, "Select a hive", "Infect Larva", factions)
		if(!choice)
			return FALSE

		if(!H)
			to_chat(usr, "This mob no longer exists")
			return

		var/obj/item/alien_embryo/embryo = new /obj/item/alien_embryo(H)
		embryo.faction = factions[choice]

		message_admins("[key_name_admin(usr)] infected [key_name_admin(H)] with a xeno ([choice]) larva.")

	else if(href_list["makemutineer"])
		if(!check_rights(R_DEBUG|R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makemutineer"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		if(H.faction.faction_name != FACTION_MARINE)
			to_chat(usr, "This player's faction must equal '[FACTION_MARINE]' to make them a mutineer.")
			return

		var/datum/equipment_preset/other/mutineer/leader/leader_preset = new()
		leader_preset.load_status(H)

		message_admins("[key_name_admin(usr)] has made [key_name_admin(H)] into a mutineer leader.")

	else if(href_list["makecultist"] || href_list["makecultistleader"])
		if(!check_rights(R_DEBUG|R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makecultist"]) || locate(href_list["makecultistleader"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human")
			return

		var/list/datum/faction/factions = list()
		for(var/faction_to_get in FACTION_LIST_XENOMORPH)
			var/datum/faction/faction_to_set = GLOB.faction_datum[faction_to_get]
			LAZYSET(factions, faction_to_set.name, faction_to_set)

		choice = tgui_input_list(usr, "Which Hive will he belongs to", "Make Cultist", factions)
		if(!choice)
			return FALSE

		if(href_list["makecultist"])
			var/datum/equipment_preset/preset = GLOB.gear_path_presets_list[/datum/equipment_preset/other/xeno_cultist]
			preset.load_race(H, factions[choice])
			preset.load_status(H)
			message_admins("[key_name_admin(usr)] has made [key_name_admin(H)] into a cultist for [choice].")

		else if(href_list["makecultistleader"])
			var/datum/equipment_preset/preset = GLOB.gear_path_presets_list[/datum/equipment_preset/other/xeno_cultist/leader]
			preset.load_race(H, factions[choice])
			preset.load_status(H)
			message_admins("[key_name_admin(usr)] has made [key_name_admin(H)] into a cultist leader for [choice].")

		factions[choice].add_mob(H)

	else if(href_list["forceemote"])
		if(!check_rights(R_ADMIN)) return

		var/mob/mob = locate(href_list["forceemote"])
		if(!ismob(mob))
			to_chat(usr, "this can only be used on instances of type /mob")

		var/speech = input("What will [key_name(mob)] emote?.", "Force emote", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)
			return
		speech = sanitize(speech) // Nah, we don't trust them
		message_admins("[key_name_admin(usr)] forced [key_name_admin(mob)] to emote: [speech]")

	else if(href_list["sendbacktolobby"])
		if(!check_rights(R_MOD))
			return

		var/mob/mob = locate(href_list["sendbacktolobby"])

		if(!isobserver(mob))
			to_chat(usr, SPAN_NOTICE("You can only send ghost players back to the Lobby."))
			return

		if(!mob.client)
			to_chat(usr, SPAN_WARNING("[mob] doesn't seem to have an active client."))
			return

		if(alert(usr, "Send [key_name(mob)] back to Lobby?", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		message_admins("[key_name(usr)] has sent [key_name(mob)] back to the Lobby.")

		var/mob/new_player/NP = new()
		NP.ckey = mob.ckey
		qdel(mob)

	else if(href_list["tdome1"])
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Confirm?", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		var/mob/mob = locate(href_list["tdome1"])
		if(!ismob(mob))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(isAI(mob))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in mob)
			mob.drop_inv_item_on_ground(I)

		mob.apply_effect(5, PARALYZE)
		sleep(5)
		mob.forceMove(get_turf(pick(GLOB.thunderdome_one)))
		spawn(50)
			to_chat(mob, SPAN_NOTICE(" You have been sent to the Thunderdome."))
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(mob)] to the thunderdome. (Team 1)", 1)

	else if(href_list["tdome2"])
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Confirm?", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		var/mob/mob = locate(href_list["tdome2"])
		if(!ismob(mob))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(isAI(mob))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in mob)
			mob.drop_inv_item_on_ground(I)

		mob.apply_effect(5, PARALYZE)
		sleep(5)
		mob.forceMove(get_turf(pick(GLOB.thunderdome_two)))
		spawn(50)
			to_chat(mob, SPAN_NOTICE(" You have been sent to the Thunderdome."))
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(mob)] to the thunderdome. (Team 2)", 1)

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_ADMIN)) return

		if(alert(usr, "Confirm?", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		var/mob/mob = locate(href_list["tdomeadmin"])
		if(!ismob(mob))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(isAI(mob))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		mob.apply_effect(5, PARALYZE)
		sleep(5)
		mob.forceMove(get_turf(pick(GLOB.thunderdome_admin)))
		spawn(50)
			to_chat(mob, SPAN_NOTICE(" You have been sent to the Thunderdome."))
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(mob)] to the thunderdome. (Admin.)", 1)

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_ADMIN)) return

		if(alert(usr, "Confirm?", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		var/mob/mob = locate(href_list["tdomeobserve"])
		if(!ismob(mob))
			to_chat(usr, "This can only be used on instances of type /mob")
			return
		if(isAI(mob))
			to_chat(usr, "This cannot be used on instances of type /mob/living/silicon/ai")
			return

		for(var/obj/item/I in mob)
			mob.drop_inv_item_on_ground(I)

		if(istype(mob, /mob/living/carbon/human))
			var/mob/living/carbon/human/observer = mob
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket(observer), WEAR_BODY)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/black(observer), WEAR_FEET)
		mob.apply_effect(5, PARALYZE)
		sleep(5)
		mob.forceMove(get_turf(pick(GLOB.thunderdome_observer)))
		spawn(50)
			to_chat(mob, SPAN_NOTICE(" You have been sent to the Thunderdome."))
		message_admins("[key_name_admin(usr)] has sent [key_name_admin(mob)] to the thunderdome. (Observer.)", 1)

	else if(href_list["revive"])
		if(!check_rights(R_MOD))
			return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /mob/living")
			return

		L.revive()
		message_admins(WRAP_STAFF_LOG(usr, "ahealed [key_name(L)] in [get_area(L)] ([L.x],[L.y],[L.z])."), L.x, L.y, L.z)

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN)) return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.cmd_admin_alienize(H)

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN)) return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		message_admins(SPAN_DANGER("Admin [key_name_admin(usr)] AIized [key_name_admin(H)]!"), 1)
		H.AIize()

	else if(href_list["changefaction"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var/mob/living/carbon/carbon = locate(href_list["changefaction"])
		if(!istype(carbon))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/")
			return
		if(usr.client)
			usr.client.cmd_admin_change_their_faction(carbon)

	else if(href_list["makeyautja"])
		if(!check_rights(R_SPAWN)) return

		if(alert("Are you sure you want to make this person into a yautja? It will delete their old character.","Make Yautja",usr.client.auto_lang(LANGUAGE_YES),usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return

		var/mob/mob = locate(href_list["makeyautja"])

		if(!istype(mob))
			to_chat(usr, "This can only be used on mobs. How did you even do this?")
			return

		if(!usr.loc || !isturf(usr.loc))
			to_chat(usr, "Only on turfs, please.")
			return

		var/y_name = input(usr, "What name would you like to give this new Predator?","Name", "")
		if(!y_name)
			to_chat(usr, "That is not a valid name.")
			return

		var/y_gend = input(usr, "Gender?","Gender", "male")
		if(!y_gend || (y_gend != "male" && y_gend != "female"))
			to_chat(usr, "That is not a valid gender.")
			return

		var/mob/living/carbon/human/human = new(usr.loc)
		human.set_species("Yautja")
		spawn(0)
			human.gender = y_gend
			human.regenerate_icons()
			message_admins("[key_name(usr)] made [mob] into a Yautja, [human.real_name].")
			if(mob.mind)
				mob.mind.transfer_to(human)
			else
				human.key = mob.key
				if(human.client) human.client.change_view(world_view_size)

			if(human.skills)
				qdel(human.skills)
			human.skills = null //no skill restriction

			if(is_alien_whitelisted(human,"Yautja Elder"))
				mob.change_real_name(human, "Elder [y_name]")
				human.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja/hunter/full(mob), WEAR_JACKET)
				human.equip_to_slot_or_del(new /obj/item/weapon/twohanded/yautja/glaive(mob), WEAR_L_HAND)
			else
				human.change_real_name(human, y_name)
			human.name = "Unknown"	// Yautja names are not visible for oomans

			if(mob)
				qdel(mob) //May have to clear up round-end vars and such....

		return

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/human = locate(href_list["makerobot"])
		if(!istype(human))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		usr.client.cmd_admin_robotize(human)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/mob = locate(href_list["makeanimal"])
		if(istype(mob, /mob/new_player))
			to_chat(usr, "This cannot be used on instances of type /mob/new_player")
			return

		usr.client.cmd_admin_animalize(mob)



// Now isn't that much better? IT IS NOW A PROC, i.e. kinda like a big panel like unstable
	else if(href_list["playerpanelextended"])
		player_panel_extended()

	else if(href_list["adminplayerobservejump"])
		if(!check_rights(R_MOD|R_ADMIN))
			return

		var/mob/mob = locate(href_list["adminplayerobservejump"])

		var/client/client = usr.client
		if(!isobserver(usr))
			client.admin_ghost()
		sleep(2)
		client.jumptomob(mob)

	else if(href_list["adminplayerfollow"])
		if(!check_rights(R_MOD|R_ADMIN))
			return

		var/mob/mob = locate(href_list["adminplayerfollow"])

		var/client/client = usr.client
		if(!isobserver(usr))
			client.admin_ghost()
		sleep(2)
		if(isobserver(usr))
			var/mob/dead/observer/observer = usr
			observer.ManualFollow(mob)

	else if(href_list["check_antagonist"])
		check_antagonists()

	else if(href_list["adminplayerobservecoodjump"])
		if(!check_rights(R_MOD))
			return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/client = usr.client
		if(!isobserver(usr))
			client.admin_ghost()
		sleep(2)
		client.jumptocoord(x,y,z)

	else if(href_list["admincancelob"])
		if(!check_rights(R_MOD))
			return
		var/cancel_token = href_list["cancellation"]
		if(!cancel_token)
			return
		if(alert("Are you sure you want to cancel this OB?", , usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return
		orbital_cannon_cancellation["[cancel_token]"] = null
		message_admins("[owner] has cancelled the orbital strike.")

	else if(href_list["admincancelpredsd"])
		if(!check_rights(R_MOD))
			return
		var/obj/item/clothing/gloves/yautja/hunter/bracer = locate(href_list["bracer"])
		var/mob/living/carbon/victim = locate(href_list["victim"])
		if(!istype(bracer))
			return
		if(alert("Are you sure you want to cancel this pred SD?", , usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return
		bracer.exploding = FALSE
		message_admins("[owner] has cancelled the predator self-destruct sequence [victim ? "of [victim] ([victim.key])":""].")

	else if(href_list["adminspawncookie"])
		if(!check_rights(R_MOD))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		var/cookie_type = tgui_input_list(usr, "Choose cookie type:", "Give Cookie", list("cookie", "random fortune cookie", "custom fortune cookie"))
		if(!cookie_type)
			return

		var/obj/item/reagent_container/food/snacks/snack
		switch(cookie_type)
			if("cookie")
				snack = new /obj/item/reagent_container/food/snacks/cookie(H.loc)
			if("random fortune cookie")
				snack = new /obj/item/reagent_container/food/snacks/fortunecookie/prefilled(H.loc)
			if("custom fortune cookie")
				var/fortune_text = tgui_input_list(usr, "Choose fortune:", "Cookie customisation", list("Random", "Custom", "None"))
				if(!fortune_text)
					return
				if(fortune_text == "Custom")
					fortune_text = input(usr, "Enter the fortune text:", "Cookie customisation", "")
					if(!fortune_text)
						return
				var/fortune_numbers = tgui_input_list(usr, "Choose lucky numbers:", "Cookie customisation", list("Random", "Custom", "None"))
				if(!fortune_numbers)
					return
				if(fortune_numbers == "Custom")
					fortune_numbers = input(usr, "Enter the lucky numbers:", "Cookie customisation", "1, 2, 3, 4 and 5")
					if(!fortune_numbers)
						return
				if(fortune_text == "None" && fortune_numbers == "None")
					to_chat(usr, "No fortune provided, Give Cookie code crumbled!")
					return
				snack = new /obj/item/reagent_container/food/snacks/fortunecookie/prefilled(H.loc, fortune_text, fortune_numbers)

		if(!snack)
			error("Give Cookie code crumbled!")
		H.put_in_hands(snack)
		message_admins("[key_name(H)] got their [cookie_type], spawned by [key_name(owner)]")
		to_chat(H, SPAN_NOTICE(" Your prayers have been answered!! You received the <b>best cookie</b>!"))

	else if(href_list["adminalert"])
		if(!check_rights(R_MOD))
			return

		var/mob/mob = locate(href_list["adminalert"])
		usr.client.cmd_admin_alert_message(mob)

	else if(href_list["CentcommReply"])
		var/mob/living/carbon/human/H = locate(href_list["CentcommReply"])

		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return

		//unanswered_distress -= H

		if(!H.get_type_in_ears(/obj/item/device/radio/headset))
			to_chat(usr, "The person you are trying to contact is not wearing a headset")
			return

		var/input = input(owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from USCM", "")
		if(!input)
			return

		to_chat(owner, "You sent [input] to [H] via a secure channel.")
		log_admin("[owner] replied to [key_name(H)]'s USCM message with the message [input].")
		for(var/client/X in GLOB.admins)
			if((R_ADMIN|R_MOD) & X.admin_holder.rights)
				to_chat(X, SPAN_STAFF_IC("<b>ADMINS/MODS: \red [owner] replied to [key_name(H)]'s USCM message with: \blue \")[input]\"</b>"))
		to_chat(H, SPAN_DANGER("You hear something crackle in your headset before a voice speaks, please stand by for a message from USCM:\" \blue <b>\"[input]\"</b>"))

	else if(href_list["SyndicateReply"])
		var/mob/living/carbon/human/H = locate(href_list["SyndicateReply"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return
		if(!H.get_type_in_ears(/obj/item/device/radio/headset))
			to_chat(usr, "The person you are trying to contact is not wearing a headset")
			return

		var/input = input(owner, "Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from The Syndicate", "")
		if(!input)
			return

		to_chat(owner, "You sent [input] to [H] via a secure channel.")
		log_admin("[owner] replied to [key_name(H)]'s Syndicate message with the message [input].")
		to_chat(H, "You hear something crackle in your headset for a moment before a voice speaks.  \"Please stand by for a message from your benefactor.  Message as follows, agent. <b>\"[input]\"</b>  Message ends.\"")

	else if(href_list["UpdateFax"])
		var/obj/structure/machinery/faxmachine/fax = locate(href_list["originfax"])
		fax.update_departments()

	else if(href_list["PressFaxReply"])
		var/mob/living/carbon/human/H = locate(href_list["PressFaxReply"])
		var/obj/structure/machinery/faxmachine/fax = locate(href_list["originfax"])

		var/template_choice = tgui_input_list(usr, "Use which template or roll your own?", "Fax Templates", list("Template", "Custom"))
		if(!template_choice) return
		var/datum/fax/fax_message
		var/organization_type = ""
		switch(template_choice)
			if("Custom")
				var/input = input(owner, "Please enter a message to reply to [key_name(H)] via secure connection. NOTE: BBCode does not work, but HTML tags do! Use <br> for line breaks.", "Outgoing message from Press", "") as message|null
				if(!input)
					return
				fax_message = new(input)
			if("Template")
				var/subject = input(owner, "Enter subject line", "Outgoing message from Press", "") as message|null
				if(!subject)
					return
				var/addressed_to = ""
				var/address_option = tgui_input_list(usr, "Address it to the sender or custom?", "Fax Template", list("Sender", "Custom"))
				if(address_option == "Sender")
					addressed_to = "[H.real_name]"
				else if(address_option == "Custom")
					addressed_to = input(owner, "Enter Addressee Line", "Outgoing message from Press", "") as message|null
					if(!addressed_to)
						return
				else
					return
				var/message_body = input(owner, "Enter Message Body, use <p></p> for paragraphs", "Outgoing message from Press", "") as message|null
				if(!message_body)
					return
				var/sent_by = input(owner, "Enter the name and rank you are sending from.", "Outgoing message from Press", "") as message|null
				if(!sent_by)
					return
				organization_type = input(owner, "Enter the organization you are sending from.", "Outgoing message from Press", "") as message|null
				if(!organization_type)
					return

				fax_message = new(generate_templated_fax(0, organization_type, subject, addressed_to, message_body, sent_by, "Editor in Chief", organization_type))
		show_browser(usr, "<body class='paper'>[fax_message.data]</body>", "pressfaxpreview", "size=500x400")
		var/send_choice = tgui_input_list(usr, "Send this fax?", "Fax Template", list("Send", "Cancel"))
		if(send_choice != "Send")
			return
		GLOB.fax_contents += fax_message // save a copy
		var/customname = input(owner, "Pick a title for the report", "Title") as text|null

		GLOB.USCMFaxes.Add("<a href='?FaxView=\ref[fax_message]'>\[view '[customname]' from [key_name(usr)] at [time2text(world.timeofday, "hh:mm:ss")]\]</a>")

		var/msg_ghost = SPAN_NOTICE("<b><font color='#1F66A0'>PRESS REPLY: </font></b> ")
		msg_ghost += "Transmitting '[customname]' via secure connection ... "
		msg_ghost += "<a href='?FaxView=\ref[fax_message]'>view message</a>"
		announce_fax(msg_ghost = msg_ghost)
		if(!(fax.inoperable()))
			// animate! it's alive!
			flick("faxreceive", fax)
			// give the sprite some time to flick
			spawn(20)
				var/obj/item/paper/P = new /obj/item/paper(fax.loc)
				P.name = "[organization_type] - [customname]"
				P.info = fax_message.data
				P.update_icon()
				playsound(fax.loc, "sound/machines/fax.ogg", 15)
				// Stamps
				var/image/stampoverlay = image('icons/obj/items/paper.dmi')
				stampoverlay.icon_state = "paper_stamp-uscm"
				if(!P.stamped)
					P.stamped = new
				P.stamped += /obj/item/tool/stamp
				P.overlays += stampoverlay
				P.stamps += "<HR><i>This paper has been stamped by the Free Press Quantum Relay.</i>"

		to_chat(owner, "Message reply to transmitted successfully.")
		message_admins(SPAN_STAFF_IC("[key_name_admin(owner)] replied to a fax message from [key_name_admin(H)]"), 1)

	else if(href_list["USCMFaxReply"])
		var/mob/living/carbon/human/H = locate(href_list["USCMFaxReply"])
		var/obj/structure/machinery/faxmachine/fax = locate(href_list["originfax"])

		var/template_choice = tgui_input_list(usr, "Use which template or roll your own?", "Fax Templates", list("USCM High Command", "USCM Provost General", "Custom"))
		if(!template_choice) return
		var/datum/fax/fax_message
		switch(template_choice)
			if("Custom")
				var/input = input(owner, "Please enter a message to reply to [key_name(H)] via secure connection. NOTE: BBCode does not work, but HTML tags do! Use <br> for line breaks.", "Outgoing message from USCM", "") as message|null
				if(!input)
					return
				fax_message = new(input)
			if("USCM High Command", "USCM Provost General")
				var/subject = input(owner, "Enter subject line", "Outgoing message from USCM", "") as message|null
				if(!subject)
					return
				var/addressed_to = ""
				var/address_option = tgui_input_list(usr, "Address it to the sender or custom?", "Fax Template", list("Sender", "Custom"))
				if(address_option == "Sender")
					addressed_to = "[H.real_name]"
				else if(address_option == "Custom")
					addressed_to = input(owner, "Enter Addressee Line", "Outgoing message from USCM", "") as message|null
					if(!addressed_to)
						return
				else
					return
				var/message_body = input(owner, "Enter Message Body, use <p></p> for paragraphs", "Outgoing message from Weyland USCM", "") as message|null
				if(!message_body)
					return
				var/sent_by = input(owner, "Enter the name and rank you are sending from.", "Outgoing message from USCM", "") as message|null
				if(!sent_by)
					return
				var/sent_title = "Office of the Provost General"
				if(template_choice == "USCM High Command")
					sent_title = "USCM High Command"

				fax_message = new(generate_templated_fax(0, "USCM CENTRAL COMMAND", subject,addressed_to, message_body,sent_by, sent_title, "United States Colonial Marine Corps"))
		show_browser(usr, "<body class='paper'>[fax_message.data]</body>", "uscmfaxpreview", "size=500x400")
		var/send_choice = tgui_input_list(usr, "Send this fax?", "Fax Template", list("Send", "Cancel"))
		if(send_choice != "Send")
			return
		GLOB.fax_contents += fax_message // save a copy

		var/customname = input(owner, "Pick a title for the report", "Title") as text|null

		GLOB.USCMFaxes.Add("<a href='?FaxView=\ref[fax_message]'>\[view '[customname]' from [key_name(usr)] at [time2text(world.timeofday, "hh:mm:ss")]\]</a>")

		var/msg_ghost = SPAN_NOTICE("<b><font color='#1F66A0'>USCM FAX REPLY: </font></b> ")
		msg_ghost += "Transmitting '[customname]' via secure connection ... "
		msg_ghost += "<a href='?FaxView=\ref[fax_message]'>view message</a>"
		announce_fax(, msg_ghost)
		if(!(fax.inoperable()))
			// animate! it's alive!
			flick("faxreceive", fax)
			// give the sprite some time to flick
			spawn(20)
				var/obj/item/paper/P = new /obj/item/paper(fax.loc)
				P.name = "USCM High Command - [customname]"
				P.info = fax_message.data
				P.update_icon()
				playsound(fax.loc, "sound/machines/fax.ogg", 15)
				// Stamps
				var/image/stampoverlay = image('icons/obj/items/paper.dmi')
				stampoverlay.icon_state = "paper_stamp-uscm"
				if(!P.stamped)
					P.stamped = new
				P.stamped += /obj/item/tool/stamp
				P.overlays += stampoverlay
				P.stamps += "<HR><i>This paper has been stamped by the USCM High Command Quantum Relay.</i>"

		to_chat(owner, "Message reply to transmitted successfully.")
		message_admins(SPAN_STAFF_IC("[key_name_admin(owner)] replied to a fax message from [key_name_admin(H)]"), 1)

	else if(href_list["CLFaxReply"])
		var/mob/living/carbon/human/H = locate(href_list["CLFaxReply"])
		var/obj/structure/machinery/faxmachine/fax = locate(href_list["originfax"])

		var/template_choice = tgui_input_list(usr, "Use the template or roll your own?", "Fax Template", list("Template", "Custom"))
		if(!template_choice) return
		var/datum/fax/fax_message
		switch(template_choice)
			if("Custom")
				var/input = input(owner, "Please enter a message to reply to [key_name(H)] via secure connection. NOTE: BBCode does not work, but HTML tags do! Use <br> for line breaks.", "Outgoing message from Weyland-Yutani", "") as message|null
				if(!input)
					return
				fax_message = new(input)
			if("Template")
				var/subject = input(owner, "Enter subject line", "Outgoing message from Weyland-Yutani", "") as message|null
				if(!subject)
					return
				var/addressed_to = ""
				var/address_option = tgui_input_list(usr, "Address it to the sender or custom?", "Fax Template", list("Sender", "Custom"))
				if(address_option == "Sender")
					addressed_to = "[H.real_name]"
				else if(address_option == "Custom")
					addressed_to = input(owner, "Enter Addressee Line", "Outgoing message from Weyland-Yutani", "") as message|null
					if(!addressed_to)
						return
				else
					return
				var/message_body = input(owner, "Enter Message Body, use <p></p> for paragraphs", "Outgoing message from Weyland-Yutani", "") as message|null
				if(!message_body)
					return
				var/sent_by = input(owner, "Enter JUST the name you are sending this from", "Outgoing message from Weyland-Yutani", "") as message|null
				if(!sent_by)
					return
				fax_message = new(generate_templated_fax(1, "WEYLAND-YUTANI CORPORATE AFFAIRS - [MAIN_SHIP_NAME]", subject, addressed_to, message_body, sent_by, "Corporate Affairs Director", "Weyland-Yutani"))
		show_browser(usr, "<body class='paper'>[fax_message.data]</body>", "clfaxpreview", "size=500x400")
		var/send_choice = tgui_input_list(usr, "Send this fax?", "Fax Confirmation", list("Send", "Cancel"))
		if(send_choice != "Send")
			return
		GLOB.fax_contents += fax_message // save a copy

		var/customname = input(owner, "Pick a title for the report", "Title") as text|null
		if(!customname)
			return

		GLOB.WYFaxes.Add("<a href='?FaxView=\ref[fax_message]'>\[view '[customname]' from [key_name(usr)] at [time2text(world.timeofday, "hh:mm:ss")]\]</a>") //Add replies so that mods know what the hell is goin on with the RP

		var/msg_ghost = SPAN_NOTICE("<b><font color='#1F66A0'>WEYLAND-YUTANI FAX REPLY: </font></b> ")
		msg_ghost += "Transmitting '[customname]' via secure connection ... "
		msg_ghost += "<a href='?FaxView=\ref[fax_message]'>view message</a>"
		announce_fax(, msg_ghost)
		if(!(fax.inoperable()))
			// animate! it's alive!
			flick("faxreceive", fax)
			// give the sprite some time to flick
			spawn(20)
				var/obj/item/paper/P = new /obj/item/paper(fax.loc)
				P.name = "Weyland-Yutani - [customname]"
				P.info = fax_message.data
				P.update_icon()
				playsound(fax.loc, "sound/machines/fax.ogg", 15)
				// Stamps
				var/image/stampoverlay = image('icons/obj/items/paper.dmi')
				stampoverlay.icon_state = "paper_stamp-weyyu"
				if(!P.stamped)
					P.stamped = new
				P.stamped += /obj/item/tool/stamp
				P.overlays += stampoverlay
				P.stamps += "<HR><i>This paper has been stamped and encrypted by the Weyland-Yutani Quantum Relay (tm).</i>"
		to_chat(owner, "Message reply to transmitted successfully.")
		message_admins(SPAN_STAFF_IC("[key_name_admin(owner)] replied to a fax message from [key_name_admin(H)]"), 1)

	else if(href_list["CMBFaxReply"])
		var/mob/living/carbon/human/H = locate(href_list["CMBFaxReply"])
		var/obj/structure/machinery/faxmachine/fax = locate(href_list["originfax"])

		var/template_choice = tgui_input_list(usr, "Use the template or roll your own?", "Fax Template", list("Anchorpoint", "Custom"))
		if(!template_choice) return
		var/datum/fax/fax_message
		switch(template_choice)
			if("Custom")
				var/input = input(owner, "Please enter a message to reply to [key_name(H)] via secure connection. NOTE: BBCode does not work, but HTML tags do! Use <br> for line breaks.", "Outgoing message from The Colonial Marshal Bureau", "") as message|null
				if(!input)
					return
				fax_message = new(input)
			if("Anchorpoint")
				var/subject = input(owner, "Enter subject line", "Outgoing message from The Colonial Marshal Bureau, Anchorpoint Station", "") as message|null
				if(!subject)
					return
				var/addressed_to = ""
				var/address_option = tgui_input_list(usr, "Address it to the sender or custom?", "Fax Template", list("Sender", "Custom"))
				if(address_option == "Sender")
					addressed_to = "[H.real_name]"
				else if(address_option == "Custom")
					addressed_to = input(owner, "Enter Addressee Line", "Outgoing message from The Colonial Marshal Bureau", "") as message|null
					if(!addressed_to)
						return
				else
					return
				var/message_body = input(owner, "Enter Message Body, use <p></p> for paragraphs", "Outgoing message from The Colonial Marshal Bureau", "") as message|null
				if(!message_body)
					return
				var/sent_by = input(owner, "Enter JUST the name you are sending this from", "Outgoing message from The Colonial Marshal Bureau", "") as message|null
				if(!sent_by)
					return
				fax_message = new(generate_templated_fax(0, "COLONIAL MARSHAL BUREAU INCIDENT COMMAND CENTER - ANCHORPOINT STATION", subject, addressed_to, message_body, sent_by, "Supervisory Deputy Marshal", "Colonial Marshal Bureau"))
		show_browser(usr, "<body class='paper'>[fax_message.data]</body>", "PREVIEW OF CMB FAX", "size=500x400")
		var/send_choice = tgui_input_list(usr, "Send this fax?", "Fax Confirmation", list("Send", "Cancel"))
		if(send_choice != "Send")
			return
		GLOB.fax_contents += fax_message // save a copy

		var/customname = input(owner, "Pick a title for the report", "Title") as text|null
		if(!customname)
			return

		GLOB.CMBFaxes.Add("<a href='?FaxView=\ref[fax_message]'>\[view '[customname]' from [key_name(usr)] at [time2text(world.timeofday, "hh:mm:ss")]\]</a>") //Add replies so that mods know what the hell is goin on with the RP

		var/msg_ghost = SPAN_NOTICE("<b><font color='#1b748c'>COLONIAL MARSHAL BUREAU FAX REPLY: </font></b> ")
		msg_ghost += "Transmitting '[customname]' via secure connection ... "
		msg_ghost += "<a href='?FaxView=\ref[fax_message]'>view message</a>"
		announce_fax(, msg_ghost)
		if(!(fax.inoperable()))
			// animate! it's alive!
			flick("faxreceive", fax)
			// give the sprite some time to flick
			spawn(20)
				var/obj/item/paper/P = new /obj/item/paper(fax.loc)
				P.name = "Colonial Marshal Bureau - [customname]"
				P.info = fax_message.data
				P.update_icon()
				playsound(fax.loc, "sound/machines/fax.ogg", 15)
				// Stamps
				var/image/stampoverlay = image('icons/obj/items/paper.dmi')
				stampoverlay.icon_state = "paper_stamp-cmb"
				if(!P.stamped)
					P.stamped = new
				P.stamped += /obj/item/tool/stamp
				P.overlays += stampoverlay
				P.stamps += "<HR><i>This paper has been stamped by The Office of Colonial Marshals.</i>"
		to_chat(owner, "Message reply to transmitted successfully.")
		message_admins(SPAN_STAFF_IC("[key_name_admin(owner)] replied to a fax message from [key_name_admin(H)]"), 1)

	else if(href_list["customise_paper"])
		if(!check_rights(R_MOD))
			return

		var/obj/item/paper/sheet = locate(href_list["customise_paper"])
		usr.client.customise_paper(sheet)

	else if(href_list["jumpto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/mob = locate(href_list["jumpto"])
		usr.client.jumptomob(mob)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Confirm?", "Message", usr.client.auto_lang(LANGUAGE_YES), usr.client.auto_lang(LANGUAGE_NO)) != usr.client.auto_lang(LANGUAGE_YES))
			return
		var/mob/mob = locate(href_list["getmob"])
		usr.client.Getmob(mob)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/mob = locate(href_list["sendmob"])
		usr.client.sendmob(mob)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/mob = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(mob)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_MOD,0) && !check_rights(R_ADMIN))
			return

		var/mob/mob = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(mob)

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))
			return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))
			return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))
			return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))
			return
		return create_mob(usr)

	else if(href_list["send_tip"])
		if(!check_rights(R_SPAWN))
			return
		return send_tip(usr)

	else if(href_list["object_list"]) //this is the laggiest thing ever
		if(!check_rights(R_SPAWN))
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if(istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if(istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()
		var/removed_paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				removed_paths += dirty_path
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				removed_paths += dirty_path
				continue
			paths += path

		if(!paths)
			alert("The path list you sent is empty")
			return
		if(length(paths) > 5)
			alert("Select fewer object types, (max 5)")
			return
		else if(length(removed_paths))
			alert("Removed:\n" + jointext(removed_paths, "\n"))

		var/list/offset = splittext(href_list["offset"],",")
		var/number = dd_range(1, 100, text2num(href_list["object_count"]))
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/tmp_dir = href_list["object_dir"]
		var/obj_dir = tmp_dir ? text2num(tmp_dir) : 2
		if(!obj_dir || !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = 2
		var/obj_name = sanitize(href_list["object_name"])
		var/where = href_list["object_where"]
		if(!(where in list("onfloor","inhand","inmarked")))
			where = "onfloor"

		if(where == "inhand")
			to_chat(usr, "Support for inhand not available yet. Will spawn on floor.")
			where = "onfloor"

		if(where == "inhand")	//Can only give when human or monkey
			if(!(ishuman(usr)))
				to_chat(usr, "Can only spawn in hand when you're a human or a monkey.")
				where = "onfloor"
			else if(usr.get_active_hand())
				to_chat(usr, "Your active hand is full. Spawning on floor.")
				where = "onfloor"

		if(where == "inmarked")
			if(!marked_datum)
				to_chat(usr, "You don't have any datum marked. Abandoning spawn.")
				return
			else
				var/datum/D = marked_datum
				if(!D)
					return

				if(!istype(D,/atom))
					to_chat(usr, "The datum you have marked cannot be used as a target. Target must be of type /atom. Abandoning spawn.")
					return

		var/atom/target //Where the object will be spawned
		switch (where)
			if("onfloor")
				switch (href_list["offset_type"])
					if("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				var/datum/D = marked_datum
				if(!D)
					to_chat(usr, "Invalid marked datum. Abandoning.")
					return

				target = D

		if(target)
			for(var/path in paths)
				for(var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N)
							if(obj_name)
								N.name = obj_name
					else
						var/atom/O = new path(target)
						if(O)
							O.setDir(obj_dir)
							if(obj_name)
								O.name = obj_name
								if(istype(O,/mob))
									var/mob/mob = O
									mob.change_real_name(mob, obj_name)

		if(number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created a [english_list(paths)]", 1)
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]", 1)
					break
		return

	else if(href_list["create_humans_list"])
		if(!check_rights(R_SPAWN))
			return

		create_humans_list(href_list)

	else if(href_list["create_xenos_list"])
		if(!check_rights(R_SPAWN))
			return

		create_xenos_list(href_list)

	else if(href_list["events"])
		if(!check_rights(R_ADMIN))
			return

		topic_events(href_list["events"])

	else if(href_list["teleport"])
		if(!check_rights(R_MOD))
			return

		topic_teleports(href_list["teleport"])

	else if(href_list["inviews"])
		if(!check_rights(R_MOD))
			return

		topic_inviews(href_list["inviews"])

	else if(href_list["vehicle"])
		if(!check_rights(R_MOD))
			return

		topic_vehicles(href_list["vehicle"])

	// player info stuff

	if(href_list["add_player_info"])
		var/key = href_list["add_player_info"]
		var/add = input("Add Player Info") as null|message
		if(!add)
			return

		var/datum/entity/player/P = get_player_from_key(key)
		P.add_note(add, FALSE)
		player_notes_show(key)

	if(href_list["add_player_info_confidential"])
		var/key = href_list["add_player_info_confidential"]
		var/add = input("Add Confidential Player Info") as null|message
		if(!add)
			return

		var/datum/entity/player/P = get_player_from_key(key)
		P.add_note(add, TRUE)
		player_notes_show(key)

	if(href_list["remove_player_info"])
		var/key = href_list["remove_player_info"]
		var/index = text2num(href_list["remove_index"])

		var/datum/entity/player/P = get_player_from_key(key)
		P.remove_note(index)
		player_notes_show(key)

	if(href_list["notes"])
		var/ckey = href_list["ckey"]
		if(!ckey)
			var/mob/mob = locate(href_list["mob"])
			if(ismob(mob))
				ckey = mob.ckey

		switch(href_list["notes"])
			if("show")
				player_notes_show(ckey)
		return

	if(href_list["player_notes_all"])
		var/key = href_list["player_notes_all"]
		player_notes_all(key)
		return

	if(href_list["ccmark"]) // CentComm-mark. We want to let all Admins know that something is "Marked", but not let the player know because it's not very RP-friendly.
		var/mob/ref_person = locate(href_list["ccmark"])
		var/msg = SPAN_NOTICE("<b>NOTICE: <font color=red>[usr.key]</font> is responding to <font color=red>[key_name(ref_person)]</font>.</b>")

		//send this msg to all admins
		for(var/client/admin in GLOB.admins)
			if((R_ADMIN|R_MOD) & admin.admin_holder.rights)
				to_chat(admin, msg)

		//unanswered_distress -= ref_person

	if(href_list["ccdeny"]) // CentComm-deny. The distress call is denied, without any further conditions
		var/mob/ref_person = locate(href_list["ccdeny"])
		faction_announcement("The distress signal has not received a response, the launch tubes are now recalibrating.", "Distress Beacon", logging = ARES_LOG_SECURITY)
		log_game("[key_name_admin(usr)] has denied a distress beacon, requested by [key_name_admin(ref_person)]")
		message_admins("[key_name_admin(usr)] has denied a distress beacon, requested by [key_name_admin(ref_person)]", 1)

		//unanswered_distress -= ref_person

	if(href_list["distresscancel"])
		if(distress_cancel)
			to_chat(usr, "The distress beacon was either canceled, or you are too late to cancel.")
			return
		log_game("[key_name_admin(usr)] has canceled the distress beacon.")
		message_admins("[key_name_admin(usr)] has canceled the distress beacon.")
		distress_cancel = TRUE
		return

	if(href_list["distress"]) //Distress Beacon, sends a random distress beacon when pressed
		distress_cancel = FALSE
		message_admins("[key_name_admin(usr)] has opted to SEND the distress beacon! Launching in 10 seconds... (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];distresscancel=\ref[usr]'>ОТМЕНИТЬ</A>)")
		addtimer(CALLBACK(src, PROC_REF(accept_ert), usr, locate(href_list["distress"])), 10 SECONDS)
		//unanswered_distress -= ref_person

	if(href_list["distress_pmc"]) //Wey-Yu specific PMC distress signal for chem retrieval ERT
		distress_cancel = FALSE
		message_admins("[key_name_admin(usr)] has opted to SEND the distress beacon! Launching in 10 seconds... (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];distresscancel=\ref[usr]'>CANCEL</A>)")
		addtimer(CALLBACK(src, PROC_REF(accept_pmc_ert), usr, locate(href_list["distress"])), 10 SECONDS)

	if(href_list["ccdeny_pmc"]) // CentComm-deny. The distress call is denied, without any further conditions
		var/mob/ref_person = locate(href_list["ccdeny_pmc"])
		to_chat(ref_person, "The distress signal has not received a response.")
		log_game("[key_name_admin(usr)] has denied a distress beacon, requested by [key_name_admin(ref_person)]")
		message_admins("[key_name_admin(usr)] has denied a distress beacon, requested by [key_name_admin(ref_person)]", 1)

	if(href_list["destroyship"]) //Distress Beacon, sends a random distress beacon when pressed
		destroy_cancel = FALSE
		message_admins("[key_name_admin(usr)] has opted to GRANT the self destruct! Starting in 10 seconds... (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];sdcancel=\ref[usr]'>ОТМЕНИТЬ</A>)")
		spawn(100)
			if(destroy_cancel)
				return
			if(!SSevacuation.enable_self_destruct(TRUE, FALSE))
				to_chat(usr, SPAN_WARNING("You are unable to authorize the self-destruct right now!"))
			else
				var/mob/ref_person = locate(href_list["destroyship"])
				log_game("[key_name_admin(usr)] has granted self destruct, requested by [key_name_admin(ref_person)]")
				message_admins("[key_name_admin(usr)] has granted self destruct, requested by [key_name_admin(ref_person)]", 1)

	if(href_list["nukeapprove"])
		var/mob/ref_person = locate(href_list["nukeapprove"])
		if(!istype(ref_person))
			return FALSE
		var/nuketype = "Encrypted Operational Nuke"
		var/prompt = tgui_alert(usr, "Do you want the nuke to be Encrypted?", "Nuke Type", list("Encrypted", "Decrypted"), 20 SECONDS)
		if(prompt == "Decrypted")
			nuketype = "Decrypted Operational Nuke"
		prompt = tgui_alert(usr, "Are you sure you want to authorize a [nuketype] to the marines? This will greatly affect the round!", "DEFCON 1", list("No", "Yes"))
		if(prompt != "Yes")
			return

		//make ASRS order for nuke
		var/datum/supply_order/new_order = new()
		new_order.ordernum = supply_controller.ordernum
		supply_controller.ordernum++
		new_order.object = supply_controller.supply_packs[nuketype]
		new_order.orderedby = ref_person
		new_order.approvedby = "USCM High Command"
		supply_controller.shoppinglist += new_order

		//Can no longer request a nuke
		GLOB.ares_link.interface.nuke_available = FALSE

		faction_announcement("A nuclear device has been authorized by High Command and will be delivered to requisitions via ASRS.", "NUCLEAR ORDNANCE AUTHORIZED", 'sound/misc/notice2.ogg', logging = ARES_LOG_MAIN)
		log_game("[key_name_admin(usr)] has authorized a [nuketype], requested by [key_name_admin(ref_person)]")
		message_admins("[key_name_admin(usr)] has authorized a [nuketype], requested by [key_name_admin(ref_person)]")

	if(href_list["nukedeny"])
		var/mob/ref_person = locate(href_list["nukedeny"])
		if(!istype(ref_person))
			return FALSE
		faction_announcement("Your request for nuclear ordnance deployment has been reviewed and denied by USCM High Command for operational security and colonial preservation reasons. Have a good day.", "NUCLEAR ORDNANCE DENIED", 'sound/misc/notice2.ogg', logging = ARES_LOG_MAIN)
		log_game("[key_name_admin(usr)] has denied nuclear ordnance, requested by [key_name_admin(ref_person)]")
		message_admins("[key_name_admin(usr)] has dnied nuclear ordnance, requested by [key_name_admin(ref_person)]")

	if(href_list["sddeny"]) // CentComm-deny. The self-destruct is denied, without any further conditions
		var/mob/ref_person = locate(href_list["sddeny"])
		faction_announcement("The self destruct request has not received a response, [MAIN_AI_SYSTEM] is now recalculating statistics.", "Self Destruct System", logging = ARES_LOG_SECURITY)
		log_game("[key_name_admin(usr)] has denied self destruct, requested by [key_name_admin(ref_person)]")
		message_admins("[key_name_admin(usr)] has denied self destruct, requested by [key_name_admin(ref_person)]", 1)

	if(href_list["sdcancel"])
		if(destroy_cancel)
			to_chat(usr, "The self-destruct was already canceled.")
			return
		if(get_security_level() == "delta")
			to_chat(usr, "Too late! The self-destruct was started.")
			return
		log_game("[key_name_admin(usr)] has canceled the self-destruct.")
		message_admins("[key_name_admin(usr)] has canceled the self-destruct.")
		destroy_cancel = 1
		return

	if(href_list["tag_datum"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_tag = locate(href_list["tag_datum"])
		if(!datum_to_tag)
			return
		return add_tagged_datum(datum_to_tag)

	if(href_list["del_tag"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_remove = locate(href_list["del_tag"])
		if(!datum_to_remove)
			return
		return remove_tagged_datum(datum_to_remove)

	if(href_list["show_tags"])
		if(!check_rights(R_ADMIN))
			return
		return display_tags()

	if(href_list["mark_datum"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_mark = locate(href_list["mark_datum"])
		if(!datum_to_mark)
			return
		return usr.client?.mark_datum(datum_to_mark)

	if(href_list["force_event"])
		if(!check_rights(R_EVENT))
			return
		var/datum/round_event_control/E = locate(href_list["force_event"]) in SSevents.control
		if(!E)
			return
		E.admin_setup(usr)
		var/datum/round_event/event = E.run_event()
		if(event.cancel_event)
			return
		if(event.announce_when>0)
			event.processing = FALSE
			var/prompt = alert(usr, "Would you like to alert the general population?", "Alert", "Yes", "No", "Cancel")
			switch(prompt)
				if("Yes")
					event.announce_chance = 100
				if("Cancel")
					event.kill()
					return
				if("No")
					event.announce_chance = 0
			event.processing = TRUE
		message_admins("[key_name_admin(usr)] has triggered an event. ([E.name])")
		log_admin("[key_name(usr)] has triggered an event. ([E.name])")
		return

	if(href_list["viewnotes"])
		if(!check_rights(R_MOD))
			return

		var/mob/checking = locate(href_list["viewnotes"])

		player_notes_all(checking.key)

	if(href_list["AresReply"])
		var/mob/living/carbon/human/speaker = locate(href_list["AresReply"])

		if(!istype(speaker))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return FALSE

		if((!GLOB.ares_link.interface) || (GLOB.ares_link.interface.inoperable()))
			to_chat(usr, "ARES Interface offline.")
			return FALSE

		var/input = input(owner, "Please enter a message from ARES to reply to [key_name(speaker)].","Outgoing message from ARES", "")
		if(!input)
			return FALSE

		to_chat(owner, "You sent [input] to [speaker] via ARES Interface.")
		log_admin("[owner] replied to [key_name(speaker)]'s ARES message with the message [input].")
		for(var/client/staff in GLOB.admins)
			if((R_ADMIN|R_MOD) & staff.admin_holder.rights)
				to_chat(staff, SPAN_STAFF_IC("<b>ADMINS/MODS: [SPAN_RED("[owner] replied to [key_name(speaker)]'s ARES message")] with: [SPAN_BLUE(input)] </b>"))
		GLOB.ares_link.interface.response_from_ares(input, href_list["AresRef"])

	if(href_list["AresMark"])
		var/mob/living/carbon/human/speaker = locate(href_list["AresMark"])

		if(!istype(speaker))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
			return FALSE

		if((!GLOB.ares_link.interface) || (GLOB.ares_link.interface.inoperable()))
			to_chat(usr, "ARES Interface offline.")
			return FALSE

		to_chat(owner, "You marked [speaker]'s ARES message for response.")
		log_admin("[owner] marked [key_name(speaker)]'s ARES message. [owner] will be responding.")
		for(var/client/staff in GLOB.admins)
			if((R_ADMIN|R_MOD) & staff.admin_holder.rights)
				to_chat(staff, SPAN_STAFF_IC("<b>ADMINS/MODS: [SPAN_RED("[owner] marked [key_name(speaker)]'s ARES message for response.")]</b>"))

	return

/datum/admins/proc/accept_ert(mob/approver, mob/ref_person)
	if(distress_cancel)
		return
	distress_cancel = TRUE
	SSticker.mode.activate_distress()
	log_game("[key_name_admin(approver)] has sent a randomized distress beacon, requested by [key_name_admin(ref_person)]")
	message_admins("[key_name_admin(approver)] has sent a randomized distress beacon, requested by [key_name_admin(ref_person)]")

/datum/admins/proc/accept_pmc_ert(mob/approver, mob/ref_person)
	if(distress_cancel)
		return
	distress_cancel = TRUE
	SSticker.mode.get_specific_call("Weyland-Yutani PMC (Chemical Investigation Squad)", TRUE, FALSE, FALSE)
	log_game("[key_name_admin(approver)] has sent a PMC distress beacon, requested by [key_name_admin(ref_person)]")
	message_admins("[key_name_admin(approver)] has sent a PMC distress beacon, requested by [key_name_admin(ref_person)]")

/datum/admins/proc/generate_job_ban_list(mob/target_mob, datum/entity/player/P, list/roles, department, color = "ccccff")
	var/counter = 0

	var/dat = ""
	dat += "<table cellpadding='1' cellspacing='0' width='100%'>"
	dat += "<tr align='center' bgcolor='[color]'><th colspan='[length(roles)]'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=[department]dept;jobban4=\ref[target_mob]'>[department]</a></th></tr><tr align='center'>"
	for(var/jobPos in roles)
		if(!jobPos)
			continue
		var/datum/job/job = GET_MAPPED_ROLE(jobPos)
		if(!job)
			continue

		if(jobban_isbanned(target_mob, job.title, P))
			dat += "<td width='20%'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=[job.title];jobban4=\ref[target_mob]'><font color=red>[replacetext(job.title, " ", "&nbsp")]</font></a></td>"
			counter++
		else
			dat += "<td width='20%'><a href='?src=\ref[src];[HrefToken(forceGlobal = TRUE)];jobban3=[job.title];jobban4=\ref[target_mob]'>[replacetext(job.title, " ", "&nbsp")]</a></td>"
			counter++

		if(counter >= 5) //So things dont get squiiiiished!
			dat += "</tr><tr>"
			counter = 0
	dat += "</tr></table>"
	return dat

/datum/admins/proc/get_job_titles_from_list(list/roles)
	var/list/temp = list()
	for(var/jobPos in roles)
		if(!jobPos)
			continue
		var/datum/job/J = GET_MAPPED_ROLE(jobPos)
		if(!J)
			continue
		temp += J.title
	return temp
