/obj/structure/machinery/door/window
	name = "Glass door"
	desc = "A window, that is also a door. A windoor if you will."
	icon = 'icons/obj/structures/doors/windoor.dmi'
	icon_state = "left"
	plane = GAME_PLANE
	layer = WINDOW_LAYER
	var/base_state = "left"
	damage_cap = 150 //If you change this, consiter changing ../door/window/brigdoor/ damage_cap at the bottom of this .dm file
	visible = 0
	use_power = USE_POWER_NONE
	flags_atom = ON_BORDER
	opacity = FALSE
	var/obj/item/circuitboard/airlock/electronics = null
	air_properties_vary_with_direction = 1

/obj/structure/machinery/door/window/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(update_icon)), 1)
	if(src.req_access && src.req_access.len)
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state

/obj/structure/machinery/door/window/Destroy()
	QDEL_NULL(electronics)
	density = FALSE
	playsound(src, "windowshatter", 50, 1)
	. = ..()

/obj/structure/machinery/door/window/initialize_pass_flags(datum/pass_flags_container/PF)
	..()
	if(PF)
		PF.flags_can_pass_all = PASS_GLASS

//Enforces perspective layering like it's contemporary; windows.
/obj/structure/machinery/door/window/update_icon(loc, direction)
	if(direction)
		setDir(direction)
	switch(dir)
		if(NORTH)
			layer = ABOVE_TABLE_LAYER
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
		else
			layer = initial(layer)

/obj/structure/machinery/door/window/Collided(atom/movable/AM)
	if(!( ismob(AM) ))
		var/obj/structure/machinery/bot/bot = AM
		if(istype(bot))
			if(density && src.check_access(bot.botcard))
				open()
				sleep(50)
				close()
		return
	var/mob/M = AM // we've returned by here if M is not a mob
	if(src.operating)
		return
	if(src.density && M.mob_size > MOB_SIZE_SMALL && src.allowed(AM))
		open()
		if(src.check_access(null))
			sleep(50)
		else //secure doors close faster
			sleep(20)
		close()
	return

/obj/structure/machinery/door/window/open()
	if(operating) //doors can still open when emag-disabled
		return FALSE

	operating = TRUE
	flick(text("[]opening", base_state), src)
	playsound(loc, 'sound/machines/windowdoor.ogg', 25, 1)
	icon_state = text("[]open", base_state)

	addtimer(CALLBACK(src, PROC_REF(finish_open)), openspeed)
	return TRUE

/obj/structure/machinery/door/window/finish_open()
	density = FALSE

	if(operating) //emag again
		operating = FALSE

/obj/structure/machinery/door/window/close()
	if(operating)
		return FALSE

	operating = TRUE
	flick(text("[]closing", src.base_state), src)
	playsound(loc, 'sound/machines/windowdoor.ogg', 25, 1)
	icon_state = base_state
	density = TRUE

	addtimer(CALLBACK(src, PROC_REF(finish_close)), openspeed)
	return TRUE

/obj/structure/machinery/door/window/finish_close()
	operating = FALSE

/obj/structure/machinery/door/window/deconstruct(disassembled = TRUE)
	if(!disassembled)
		new /obj/item/shard(loc)
		var/obj/item/circuitboard/airlock/ae
		if(!electronics)
			ae = new/obj/item/circuitboard/airlock(loc)
			if(!req_access)
				check_access()
			if(req_access.len)
				ae.conf_access = req_access
			else if(req_one_access && req_one_access.len)
				ae.conf_access = req_one_access
				ae.one_access = 1
		else
			ae = electronics
			electronics = null
			ae.forceMove(loc)
		if(operating == -1)
			ae.fried = TRUE
			ae.update_icon()
	return ..()

//When an object is thrown at the window
/obj/structure/machinery/door/window/hitby(atom/movable/AM)

	..()
	visible_message(SPAN_DANGER("<B>The glass door was hit by [AM].</B>"), null, null, 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
	take_damage(tforce)
	//..() //Does this really need to be here twice? The parent proc doesn't even do anything yet. - Nodrak
	return


/obj/structure/machinery/door/window/attack_remote(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/machinery/door/window/attack_hand(mob/user)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
			visible_message(SPAN_DANGER("<B>[user] smashes against the [src.name].</B>"), 1)
			take_damage(25)
			return
	return try_to_activate_door(user)

/obj/structure/machinery/door/window/attackby(obj/item/I, mob/user)

	//If it's in the process of opening/closing, ignore the click
	if(src.operating == 1)
		return

	//If it's emagged, crowbar can pry electronics out.
	if (src.operating == -1 && HAS_TRAIT(I, TRAIT_TOOL_CROWBAR))
		playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
		user.visible_message("[user] removes the electronics from the windoor.", "You start to remove electronics from the windoor.")
		if(do_after(user, 40, INTERRUPT_ALL, BUSY_ICON_BUILD))
			to_chat(user, SPAN_NOTICE(" You removed the windoor electronics!"))

			var/obj/structure/windoor_assembly/wa = new/obj/structure/windoor_assembly(src.loc)
			if(istype(src, /obj/structure/machinery/door/window/brigdoor))
				wa.secure = "secure_"
				wa.name = "Secure Wired Windoor Assembly"
			else
				wa.name = "Wired Windoor Assembly"
			if(src.base_state == "right" || src.base_state == "rightsecure")
				wa.facing = "r"
			wa.setDir(src.dir)
			wa.state = "02"
			wa.update_icon()

			var/obj/item/circuitboard/airlock/ae
			if(!electronics)
				ae = new/obj/item/circuitboard/airlock( src.loc )
				if(!src.req_access)
					src.check_access()
				if(src.req_access.len)
					ae.conf_access = src.req_access
				else if(src.req_one_access.len)
					ae.conf_access = src.req_one_access
					ae.one_access = 1
			else
				ae = electronics
				electronics = null
				ae.forceMove(src.loc)
			ae.fried = TRUE
			ae.update_icon()

			operating = 0
			qdel(src)
			return

	if(!(I.flags_item & NOBLUDGEON) && I.force && density) //trying to smash windoor with item
		var/aforce = I.force
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 25, 1)
		visible_message(SPAN_DANGER("<B>[src] was hit by [I].</B>"))
		if(I.damtype == BRUTE || I.damtype == BURN)
			take_damage(aforce)
		return 1
	else
		return try_to_activate_door(user)

/obj/structure/machinery/door/window/brigdoor
	name = "Secure glass door"
	desc = "A thick chunk of tempered glass on metal track. Probably more robust than you."
	req_access = list(ACCESS_MARINE_BRIG)
	damage_cap = 300 //Stronger doors for prison (regular window door damage_cap is 150)


/obj/structure/machinery/door/window/northleft
	dir = NORTH

/obj/structure/machinery/door/window/eastleft
	dir = EAST

/obj/structure/machinery/door/window/westleft
	dir = WEST

/obj/structure/machinery/door/window/southleft
	dir = SOUTH

/obj/structure/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/structure/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/structure/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/structure/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/structure/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

/obj/structure/machinery/door/window/tinted
	opacity = TRUE

/obj/structure/machinery/door/window/ultra
	name = "Ultra-reinforced glass door"
	desc = "A window, that is also a door. A windoor if you will. It is indestructible."

/obj/structure/machinery/door/window/ultra/Initialize(mapload, ...)
	. = ..()
	GLOB.hijack_deletable_windows += src

/obj/structure/machinery/door/window/ultra/Destroy()
	GLOB.hijack_deletable_windows -= src
	return ..()

// No damage taken.
/obj/structure/machinery/door/window/ultra/attackby(obj/item/I, mob/user)
	return try_to_activate_door(user)
