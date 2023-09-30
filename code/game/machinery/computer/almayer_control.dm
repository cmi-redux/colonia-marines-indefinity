#define COMMAND_SHIP_ANNOUNCE "Command Ship Announcement"

#define COMMAND_HQ_ANNOUNCE "USCM High Command Announcement"

/obj/structure/machinery/computer/almayer_control
	name = "Консоль Управления 'Алмаером'"
	desc = "Используется для управления кораблем и использованием разных функций."
	icon_state = "comm_alt"
	req_access = list(ACCESS_MARINE_SENIOR)
	unslashable = TRUE
	unacidable = TRUE

	var/controled_ship = "USS \"Almayer\""

	/// requesting a distress beacon
	COOLDOWN_DECLARE(cooldown_request)
	/// requesting evac
	COOLDOWN_DECLARE(cooldown_destruct)
	/// messaging HC (admins)
	COOLDOWN_DECLARE(cooldown_central)
	/// making a ship announcement
	COOLDOWN_DECLARE(cooldown_message)

	var/super_energetic_rele_active = TRUE

	var/list/messagetitle = list()
	var/list/messagetext = list()

	faction_to_get = FACTION_MARINE

/obj/structure/machinery/computer/almayer_control/attack_remote(mob/user as mob)
	return attack_hand(user)

/obj/structure/machinery/computer/almayer_control/attack_hand(mob/user as mob)
	if(..() || inoperable())
		return

	if(!allowed(user))
		to_chat(usr, SPAN_WARNING("Access denied."))
		return FALSE

	if(!istype(loc.loc, /area/almayer/command/cic)) //Has to be in the CIC. Can also be a generic CIC area to communicate, if wanted.
		to_chat(usr, SPAN_WARNING("Unable to establish a connection."))
		return FALSE

	tgui_interact(user)

// tgui boilerplate \\

/*
	var/dat = "<head><title>Консоль Управления [controled_ship]</title></head><body>"
	dat += "<B>Задержка связи</B>: [duration2text_hour_min_sec(GLOB.ship_hc_delay, "hh:mm:ss")]<BR>"
	dat += "<B>Статус Эвакуации</B>: [SSevacuation.get_evac_status_panel_eta()]<BR>"
	dat += "<B>Стадия Операции</B>: [SSevacuation.get_ship_operation_stage_status_panel_eta()]<BR>"
	dat += "<BR><hr>"
	switch(state)
		if(STATE_DEFAULT)
			dat += "Alert Level: <A href='?src=\ref[src];operation=changeseclevel'>[get_security_level()]</A><BR>"
			dat += "<BR><A HREF='?src=\ref[src];operation=ship_announce'>[is_announcement_active ? "Сделать Корабельное Оповещение" : "*Недоступно*"]</A>"
			dat += super_energetic_rele_active ? "<BR><A HREF='?src=\ref[src];operation=messageUSCM'>Отправить Сообщение Высшему Командыванию USCM</A>" : "<BR>USCM высокоэнергетическое реле повреждено"
			dat += "<BR><A HREF='?src=\ref[src];operation=award'>Выдать Награду</A>"

			dat += "<BR><hr>"
			if(!isnull(SSticker.mode) && !isnull(SSticker.mode.active_lz) && !isnull(SSticker.mode.active_lz.loc))
				dat += "<BR>Основная ЗВ [SSticker.mode.active_lz.loc.loc]"
			dat += "<BR>Взаимодействие с прогрессом операции:"
			switch(SSevacuation.ship_operation_stage_status)
				if(OPERATION_DECRYO)
					dat += "<BR>Поднятие морпехов из крио"
				if(OPERATION_BRIEFING)
					dat += "<BR>Проведение инструктажа"
					if(isnull(SSticker.mode.active_lz))
						dat += "<BR><A HREF='?src=\ref[src];operation=selectlz'>Выбрать Основную ЗВ</A>"
				if(OPERATION_FIRST_LANDING)
					dat += "<BR>Первая высадка"
					dat += "<BR>DEFCON [faction.objectives_controller.current_level]: [faction.objectives_controller.last_objectives_completion_percentage]%"
					dat += "<BR>Оставшийся бюджет на DEFCON активы: [faction.objectives_controller.remaining_reward_points] поинтов."
					dat += "<BR><A href='?src=\ref[src];operation=defcon'>Акивировать DEFCON Активы</A>"
					dat += "<BR><A href='?src=\ref[src];operation=defconlist'>Список DEFCON Активы</A><BR>"
				if(OPERATION_IN_PROGRESS)
					dat += "<BR>Выполнение задач операции"
					dat += "<BR><A HREF='?src=\ref[src];operation=escape'>Закончить Операцию (аварийная причина)</A><BR>"
					dat += "<BR>DEFCON [faction.objectives_controller.current_level]: [faction.objectives_controller.last_objectives_completion_percentage]%"
					dat += "<BR>Оставшийся бюджет на DEFCON активы: [faction.objectives_controller.remaining_reward_points] поинтов."
					dat += "<BR><A href='?src=\ref[src];operation=defcon'>Акивировать DEFCON Активы</A>"
					dat += "<BR><A href='?src=\ref[src];operation=defconlist'>Список DEFCON Активы</A><BR>"
					dat += "<BR><A HREF='?src=\ref[src];operation=distress'>Запустить Аварийный Маяк</A>"
					dat += "<BR><A HREF='?src=\ref[src];operation=destroy'>Активировать Самоуничтожение</A>"
					switch(SSevacuation.evac_status)
						if(EVACUATION_STATUS_STANDING_BY)
							dat += "<BR><A HREF='?src=\ref[src];operation=evacuation_start'>Начать аварийную эвакуацию</A>"
						if(EVACUATION_STATUS_INITIATING)
							dat += "<BR><A HREF='?src=\ref[src];operation=evacuation_cancel'>Отменить аварийную эвакуацию</A>"
				if(OPERATION_ENDING)
					dat += "<BR>Завершение операции"
					dat += "<BR><A HREF='?src=\ref[src];operation=escape'>Закончить Операцию Преждевременно</A>"
				if(OPERATION_LEAVING_OPERATION_PLACE)
					dat += "<BR>Покидание зоны операции"
					dat += "<A HREF='?src=\ref[src];operation=escape_cancel'>Вернуться в Зону операции</A>"
				if(OPERATION_DEBRIEFING)
					dat += "<BR>Подведение итогов"
				if(OPERATION_CRYO)
					dat += "<BR>Перемещение экипажа в крио"
*/

/obj/structure/machinery/computer/almayer_control/tgui_interact(mob/user, datum/tgui/ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlmayerControl", "[name]")
		ui.open()

/obj/structure/machinery/computer/almayer_control/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(!allowed(user))
		return UI_CLOSE
	if(!operable())
		return UI_CLOSE

/obj/structure/machinery/computer/almayer_control/ui_state(mob/user)
	return GLOB.not_incapacitated_and_adjacent_strict_state

// tgui data \\

/obj/structure/machinery/computer/almayer_control/ui_static_data(mob/user)
	var/list/data = list()

	data["cooldown_request"] = COOLDOWN_COMM_REQUEST
	data["cooldown_destruct"] = COOLDOWN_COMM_DESTRUCT
	data["cooldown_central"] = COOLDOWN_COMM_CENTRAL
	data["cooldown_message"] = COOLDOWN_COMM_MESSAGE
	data["distresstimelock"] = DISTRESS_TIME_LOCK

	return data

/obj/structure/machinery/computer/almayer_control/ui_data(mob/user)
	var/list/data = list()
	var/list/messages = list()

	data["alert_level"] = security_level

	data["time_request"] = cooldown_request
	data["time_destruct"] = cooldown_destruct
	data["time_central"] = cooldown_central
	data["time_message"] = cooldown_message

	data["worldtime"] = world.time

	data["evac_status"] = SSevacuation.evac_status
	if(SSevacuation.evac_status == EVACUATION_STATUS_INITIATING)
		data["evac_eta"] = SSevacuation.get_evac_status_panel_eta()
	data["operation_stage"] = SSevacuation.get_ship_operation_stage_status_panel_eta()
	data["operation_stage_status"] = SSevacuation.ship_operation_stage_status

	if(!messagetitle.len)
		data["messages"] = null
	else
		for(var/i in 1 to length(messagetitle))
			var/list/messagedata = list(list(
				"title" = messagetitle[i],
				"text" = messagetext[i],
				"number" = i
			))
			messages += messagedata

		data["messages"] = messages

	return data

// end tgui data \\

// tgui interact \\

/obj/structure/machinery/computer/almayer_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("award")
			print_medal(usr, src)
			. = TRUE

		// evac stuff start \\

		if("evacuation_start")
			if(security_level < SEC_LEVEL_RED)
				to_chat(usr, SPAN_WARNING("The ship must be under red alert in order to enact evacuation procedures."))
				return FALSE

			if(SSevacuation.flags_scuttle & FLAGS_EVACUATION_DENY)
				to_chat(usr, SPAN_WARNING("The USCM has placed a lock on deploying the evacuation pods."))
				return FALSE

			if(!SSevacuation.initiate_evacuation())
				to_chat(usr, SPAN_WARNING("You are unable to initiate an evacuation procedure right now!"))
				return FALSE

			log_game("[key_name(usr)] has called for an emergency evacuation.")
			message_admins("[key_name_admin(usr)] has called for an emergency evacuation.")
			var/datum/ares_link/link = GLOB.ares_link
			link.log_ares_security("Initiate Evacuation", "[usr] has called for an emergency evacuation.")
			. = TRUE

		if("evacuation_cancel")
			if(!SSevacuation.cancel_evacuation())
				to_chat(usr, SPAN_WARNING("You are unable to cancel the evacuation right now!"))
				return FALSE

			addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/machinery/computer/almayer_control, cancel_evac)), 4 SECONDS)

			log_game("[key_name(usr)] has canceled the emergency evacuation.")
			message_admins("[key_name_admin(usr)] has canceled the emergency evacuation.")
			var/datum/ares_link/link = GLOB.ares_link
			link.log_ares_security("Cancel Evacuation", "[usr] has cancelled the emergency evacuation.")
			. = TRUE

		// evac stuff end \\

		if("change_sec_level")
			var/list/alert_list = list(num2seclevel(SEC_LEVEL_GREEN), num2seclevel(SEC_LEVEL_BLUE))
			switch(security_level)
				if(SEC_LEVEL_GREEN)
					alert_list -= num2seclevel(SEC_LEVEL_GREEN)
				if(SEC_LEVEL_BLUE)
					alert_list -= num2seclevel(SEC_LEVEL_BLUE)
				if(SEC_LEVEL_DELTA)
					return

			var/level_selected = tgui_input_list(usr, "Какой уровень вы хотите установить?", "Уровень Тревоги", alert_list)
			if(!level_selected)
				return

			set_security_level(seclevel2num(level_selected), log = ARES_LOG_NONE)
			log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
			message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
			var/datum/ares_link/link = GLOB.ares_link
			link.log_ares_security("Manual Security Update", "[usr] has changed the security level to [get_security_level()].")
			. = TRUE

		if("messageUSCM")
			if(!COOLDOWN_FINISHED(src, cooldown_central))
				to_chat(usr, SPAN_WARNING("Arrays are re-cycling.  Please stand by."))
				return FALSE
			var/input = stripped_input(usr, "Please choose a message to transmit to USCM.  Please be aware that this process is very expensive, and abuse will lead to termination.  Transmission does not guarantee a response. There is a small delay before you may send another message. Be clear and concise.", "To abort, send an empty message.", "")
			if(!input || !(usr in view(1,src)) || !COOLDOWN_FINISHED(src, cooldown_central))
				return FALSE

			high_command_announce(input, usr)
			to_chat(usr, SPAN_NOTICE("Message transmitted."))
			log_announcement("[key_name(usr)] has made an USCM announcement: [input]")
			COOLDOWN_START(src, cooldown_central, COOLDOWN_COMM_CENTRAL)
			. = TRUE

		if("ship_announce")
			if(!COOLDOWN_FINISHED(src, cooldown_message))
				to_chat(usr, SPAN_WARNING("Please allow at least [COOLDOWN_TIMELEFT(src, cooldown_message)/10] second\s to pass between announcements."))
				return FALSE
			var/input = stripped_multiline_input(usr, "Please write a message to announce to the station crew.", "Priority Announcement", "")
			if(!input || !COOLDOWN_FINISHED(src, cooldown_message) || !(usr in view(1,src)))
				return FALSE

			var/signed = null
			if(ishuman(usr))
				var/mob/living/carbon/human/human_user = usr
				var/obj/item/card/id/id = human_user.wear_id
				if(istype(id))
					var/paygrade = get_paygrades(id.paygrade, FALSE, human_user.gender)
					signed = "[paygrade] [id.registered_name]"

			COOLDOWN_START(src, cooldown_message, COOLDOWN_COMM_MESSAGE)
			shipwide_ai_announcement(input, COMMAND_SHIP_ANNOUNCE, signature = signed)
			message_admins("[key_name(usr)] has made a shipwide annoucement.")
			log_announcement("[key_name(usr)] has announced the following to the ship: [input]")
			. = TRUE

		if("distress")
			if(world.time < DISTRESS_TIME_LOCK)
				to_chat(usr, SPAN_WARNING("The distress beacon cannot be launched this early in the operation. Please wait another [time_left_until(DISTRESS_TIME_LOCK, world.time, 1 MINUTES)] minutes before trying again."))
				return FALSE

			if(!SSticker.mode)
				return FALSE //Not a game mode?

			if(SSticker.mode.force_end_at == 0)
				to_chat(usr, SPAN_WARNING("ARES has denied your request for operational security reasons."))
				return FALSE

			if(!COOLDOWN_FINISHED(src, cooldown_request))
				to_chat(usr, SPAN_WARNING("The distress beacon has recently broadcast a message. Please wait."))
				return FALSE

			if(security_level == SEC_LEVEL_DELTA)
				to_chat(usr, SPAN_WARNING("The ship is already undergoing self-destruct procedures!"))
				return FALSE

			for(var/client/admin_client as anything in GLOB.admins)
				if((R_ADMIN|R_MOD) & admin_client.admin_holder.rights)
					admin_client << 'sound/effects/sos-morse-code.ogg'
			SSticker.mode.request_ert(usr)
			to_chat(usr, SPAN_NOTICE("A distress beacon request has been sent to USCM Central Command."))

			COOLDOWN_START(src, cooldown_request, COOLDOWN_COMM_REQUEST)
			. = TRUE

	// sd \\

		if("destroy")
			if(world.time < DISTRESS_TIME_LOCK)
				to_chat(usr, SPAN_WARNING("The self-destruct cannot be activated this early in the operation. Please wait another [time_left_until(DISTRESS_TIME_LOCK, world.time, 1 MINUTES)] minutes before trying again."))
				return FALSE

			if(!SSticker.mode)
				return FALSE //Not a game mode?

			if(SSticker.mode.force_end_at == 0)
				to_chat(usr, SPAN_WARNING("ARES has denied your request for operational security reasons."))
				return FALSE

			if(!COOLDOWN_FINISHED(src, cooldown_destruct))
				to_chat(usr, SPAN_WARNING("A self-destruct request has already been sent to high command. Please wait."))
				return FALSE

			if(get_security_level() == "delta")
				to_chat(usr, SPAN_WARNING("The [MAIN_SHIP_NAME]'s self-destruct is already activated."))
				return FALSE

			for(var/client/admin_client as anything in GLOB.admins)
				if((R_ADMIN|R_MOD) & admin_client.admin_holder.rights)
					admin_client << 'sound/effects/sos-morse-code.ogg'
			message_admins("[key_name(usr)] has requested Self-Destruct! [CC_MARK(usr)] (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];destroyship=\ref[usr]'>GRANT</A>) (<A HREF='?_src_=admin_holder;[HrefToken(forceGlobal = TRUE)];sddeny=\ref[usr]'>DENY</A>) [ADMIN_JMP_USER(usr)] [CC_REPLY(usr)]")
			to_chat(usr, SPAN_NOTICE("A self-destruct request has been sent to USCM Central Command."))
			COOLDOWN_START(src, cooldown_destruct, COOLDOWN_COMM_DESTRUCT)
			. = TRUE

		if("delmessage")
			var/number_of_message = params["number"]
			if(!number_of_message)
				return FALSE
			var/title = messagetitle[number_of_message]
			var/text  = messagetext[number_of_message]
			messagetitle.Remove(title)
			messagetext.Remove(text)
			. = TRUE

/obj/structure/machinery/computer/almayer_control/hq_uscm
	name = "Компьютер для удаленного управления систем"
	desc = "Повзовляет удаленно управлять система корабля."
	unslashable = TRUE
	unacidable = TRUE
	exproof = TRUE
/*
/obj/structure/machinery/computer/almayer_control/hq_uscm/attack_hand(mob/user as mob)
	if(..() || !allowed(user) || inoperable())
		return

	ui_interact(user)

/obj/structure/machinery/computer/almayer_control/hq_uscm/ui_interact(mob/user as mob)
	user.set_interaction(src)

	var/dat = "<head><title>Консоль Дистанционного Управления</title></head><body>"



	dat += "<B>Статус Эвакуации</B>: [SSevacuation.get_evac_status_panel_eta()]<BR>"
	dat += "<B>Стадия Операции</B>: [SSevacuation.get_ship_operation_stage_status_panel_eta()]<BR>"
	dat += "<BR>Контролируемый корабль [controled_ship]<BR>"

	switch(state)
		if(STATE_DEFAULT)
			dat += "<BR>DEFCON [faction.objectives_controller.current_level]: [faction.objectives_controller.last_objectives_completion_percentage]%"
			dat += "<BR>Оставшийся бюджет на DEFCON активы: [faction.objectives_controller.remaining_reward_points] поинтов."
			dat += "<BR><A href='?src=\ref[src];operation=defcon'>Акивировать DEFCON Активы</A>"
			dat += "<BR><A href='?src=\ref[src];operation=defconlist'>Список DEFCON Активы</A><BR>"
			dat += "<BR><hr>"

			dat += "<BR><A HREF='?src=\ref[src];operation=destroy'>Активировать Самоуничтожение</A>"
			switch(SSevacuation.evac_status)
				if(EVACUATION_STATUS_STANDING_BY)
					dat += "<BR><A HREF='?src=\ref[src];operation=evacuation_start'>Начать аварийную эвакуацию</A>"
				if(EVACUATION_STATUS_INITIATING)
					dat += "<BR><A HREF='?src=\ref[src];operation=evacuation_cancel'>Отменить аварийную эвакуацию</A>"

		if(STATE_EVACUATION)
			dat += "Вы уверены, что хотите эвакуировать [controled_ship]? <A HREF='?src=\ref[src];operation=evacuation_start'>Подтвердить</A>"

		if(STATE_EVACUATION_CANCEL)
			dat += "Вы уверены, что хотите отменить эвакуацию [controled_ship]? <A HREF='?src=\ref[src];operation=evacuation_cancel'>Подтвердить</A>"

		if(STATE_DESTROY)
			dat += "Вы уверены, что хотите активировать самоуничтожение? Вам придеться покинуть корабль. <A HREF='?src=\ref[src];operation=destroy'>Подтвердить</A>"

	dat += "<BR>[(state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Главное Меню</A>|" : ""]<A HREF='?src=\ref[user];mach_close=almayer_control'>Закрыть</A>"

	show_browser(user, dat, name, "almayer_control")
	onclose(user, "almayer_control")

/obj/structure/machinery/computer/almayer_control/hq_uscm/Topic(href, href_list)
	if(..())
		return FALSE

	usr.set_interaction(src)

	switch(href_list["operation"])
		if("announce")
			if(!is_announcement_active)
				to_chat(usr, SPAN_WARNING("Пожалуйста подождите [COOLDOWN_COMM_MESSAGE*0.1] секунд."))
				return FALSE
			var/input = stripped_multiline_input(usr, "Пожалуйста введите сообщение.", "Приоритетное Оповещение", "")
			if(!input || !is_announcement_active || !(usr in view(1,src)))
				return FALSE

			is_announcement_active = FALSE

			var/signed = null
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				var/obj/item/card/id/id = H.wear_id
				if(istype(id))
					var/paygrade = get_paygrades(id.paygrade, FALSE, H.gender)
					signed = "[paygrade] [id.registered_name]"

			shipwide_ai_announcement(input, COMMAND_HQ_ANNOUNCE, signature = signed)
			addtimer(CALLBACK(src, PROC_REF(reactivate_announcement), usr), COOLDOWN_COMM_MESSAGE)
			message_admins("[key_name(usr)] создал корабельное оповещение.")
			log_announcement("[key_name(usr)] создал корабельное оповещение: [input]")
*/

// end tgui interact \\

// end tgui \\

/obj/structure/machinery/computer/almayer_control/proc/cancel_evac()
	if(SSevacuation.evac_status == EVACUATION_STATUS_STANDING_BY)//nothing changed during the wait
		//if the self_destruct is active we try to cancel it (which includes lowering alert level to red)
		if(!SSevacuation.cancel_self_destruct(1))
			//if SD wasn't active (likely canceled manually in the SD room), then we lower the alert level manually.
			set_security_level(SEC_LEVEL_RED, TRUE) //both SD and evac are inactive, lowering the security level.
