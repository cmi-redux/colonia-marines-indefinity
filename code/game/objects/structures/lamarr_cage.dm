/obj/structure/lamarr
	name = "Lab Cage"
	icon = 'icons/obj/structures/props/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = TRUE
	anchored = TRUE
	unacidable = FALSE
	health = 30
	var/occupied = TRUE
	var/destroyed = FALSE

/obj/structure/lamarr/ex_act(severity)
	switch(severity)
		if(0 to EXPLOSION_THRESHOLD_LOW)
			if(prob(50))
				health -= 5
				healthcheck()
		if(EXPLOSION_THRESHOLD_LOW to EXPLOSION_THRESHOLD_MEDIUM)
			if(prob(50))
				health -= 15
				healthcheck()
		if(EXPLOSION_THRESHOLD_MEDIUM to INFINITY)
			new /obj/item/shard(loc)
			Break()
			deconstruct(FALSE)


/obj/structure/lamarr/bullet_act(obj/item/projectile/proj)
	health -= proj.damage
	..()
	healthcheck()
	return TRUE

/obj/structure/lamarr/proc/healthcheck()
	if(health <= 0)
		if(!(destroyed))
			density = FALSE
			destroyed = TRUE
			new /obj/item/shard(loc)
			playsound(src, "shatter", 25, 1)
			Break()
	else
		playsound(loc, 'sound/effects/Glasshit.ogg', 25, 1)
	return

/obj/structure/lamarr/update_icon()
	if(destroyed)
		icon_state = "labcageb[occupied]"
	else
		icon_state = "labcage[occupied]"
	return


/obj/structure/lamarr/attackby(obj/item/W as obj, mob/user as mob)
	health -= W.force
	healthcheck()
	..()
	return

/obj/structure/lamarr/attack_hand(mob/user as mob)
	if(destroyed)
		return
	else
		to_chat(user, SPAN_NOTICE("You kick the lab cage."))
		for(var/mob/O in oviewers())
			if((O.client && !( O.blinded )))
				to_chat(O, SPAN_DANGER("[user] kicks the lab cage."))
		health -= 2
		healthcheck()
		return

/obj/structure/lamarr/proc/Break()
	if(occupied)
		new /obj/item/clothing/mask/facehugger/lamarr(loc)
		occupied = FALSE
	update_icon()
	return

/obj/item/clothing/mask/facehugger/lamarr
	name = "Lamarr"
	desc = "The worst she might do is attempt to... couple with your head."//hope we don't get sued over a harmless reference, rite?
	sterile = TRUE
	gender = FEMALE
	black_market_value = 50

/obj/item/clothing/mask/facehugger/lamarr/die()
	if(stat == DEAD)
		return

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD

	visible_message("[icon2html(src, viewers(src))] <span class='danger'>\The [src] curls up into a ball!</span>")
	playsound(src.loc, 'sound/voice/alien_facehugger_dies.ogg', 25, 1)

	if(ismob(loc)) //Make it fall off the person so we can update their icons. Won't update if they're in containers thou
		var/mob/M = loc
		M.drop_inv_item_on_ground(src)

	layer = BELOW_MOB_LAYER //so dead hugger appears below live hugger if stacked on same tile.
	//override function prevents Lamarr from decaying like other huggers so you can keep it in your helmet, otherwise the code is identical.
