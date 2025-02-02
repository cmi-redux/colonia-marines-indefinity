/obj/structure/machinery/igniter
	name = "igniter"
	desc = "It's useful for igniting flammable items."
	icon = 'icons/obj/structures/props/stationobjs.dmi'
	icon_state = "igniter1"
	plane = FLOOR_PLANE
	var/id = null
	var/on = 1
	anchored = TRUE
	use_power = USE_POWER_IDLE
	idle_power_usage = 2
	active_power_usage = 4

/obj/structure/machinery/igniter/attack_remote(mob/user as mob)
	return attack_hand(user)

/obj/structure/machinery/igniter/attack_hand(mob/user as mob)
	if(..())
		return
	add_fingerprint(user)

	use_power(50)
	on = !on
	icon_state = text("igniter[]", on)
	return

/obj/structure/machinery/igniter/process() //ugh why is this even in process()?
//	if(src.on && !(stat & NOPOWER) )
//		var/turf/location = src.loc
//		if(isturf(location))
//			location.hotspot_expose(1000,500,1)
	return FALSE

/obj/structure/machinery/igniter/Initialize(mapload, ...)
	. = ..()
	icon_state = "igniter[on]"

/obj/structure/machinery/igniter/power_change()
	..()
	if(!(stat & NOPOWER))
		icon_state = "igniter[on]"
	else
		icon_state = "igniter0"

// Wall mounted remote-control igniter.

/obj/structure/machinery/sparker
	name = "Mounted igniter"
	desc = "A wall-mounted ignition device."
	icon = 'icons/obj/structures/props/stationobjs.dmi'
	icon_state = "migniter"
	var/id = null
	var/disable = FALSE
	var/last_spark = 0
	var/base_state = "migniter"
	anchored = TRUE

/obj/structure/machinery/sparker/power_change()
	..()
	if(!(stat & NOPOWER) && !disable)

		icon_state = "[base_state]"
// src.sd_set_light(2)
	else
		icon_state = "[base_state]-p"
// src.sd_set_light(0)

/obj/structure/machinery/sparker/attackby(obj/item/W as obj, mob/user as mob)
	if(HAS_TRAIT(W, TRAIT_TOOL_SCREWDRIVER))
		add_fingerprint(user)
		disable = !disable
		if(disable)
			user.visible_message(SPAN_DANGER("[user] has disabled the [src]!"), SPAN_DANGER("You disable the connection to the [src]."))
			icon_state = "[base_state]-d"
		if(!disable)
			user.visible_message(SPAN_DANGER("[user] has reconnected the [src]!"), SPAN_DANGER("You fix the connection to the [src]."))
			if(powered())
				icon_state = "[base_state]"
			else
				icon_state = "[base_state]-p"

/obj/structure/machinery/sparker/attack_remote()
	if(anchored)
		return ignite()
	else
		return

/obj/structure/machinery/sparker/proc/ignite()
	if(!(powered()))
		return

	if((disable) || (last_spark && world.time < last_spark + 50))
		return


	flick("[base_state]-spark", src)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(2, 1, src)
	s.start()
	last_spark = world.time
	use_power(1000)
//	var/turf/location = loc
//	if(isturf(location))
//		location.hotspot_expose(1000,500,1)
	return 1

/obj/structure/machinery/sparker/emp_act(severity)
	if(inoperable())
		..(severity)
		return
	ignite()
	..(severity)

/obj/structure/machinery/ignition_switch/attack_remote(mob/user as mob)
	return attack_hand(user)

/obj/structure/machinery/ignition_switch/attack_hand(mob/user as mob)
	if(inoperable())
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/structure/machinery/sparker/M in GLOB.machines)
		if(M.id == id)
			INVOKE_ASYNC(M, TYPE_PROC_REF(/obj/structure/machinery/sparker, ignite))

	for(var/obj/structure/machinery/igniter/M in GLOB.machines)
		if(M.id == id)
			use_power(50)
			M.on = !( M.on )
			M.icon_state = text("igniter[]", M.on)

	sleep(50)

	icon_state = "launcherbtt"
	active = 0

	return
