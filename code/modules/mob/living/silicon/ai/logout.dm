/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/structure/machinery/ai_status_display/O in GLOB.machines) //change status
		O.mode = 0
	if(!isturf(loc))
		if(client)
			client.eye = loc
			client.perspective = EYE_PERSPECTIVE
	src.view_core()
	return
