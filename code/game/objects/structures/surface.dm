//Surface structures are structures that can have items placed on them
/obj/structure/surface
	health = 100
	var/objective_spawn = TRUE

/obj/structure/surface/Initialize()
	. = ..()
	//make sure to load landmarks for defcons
	var/turf/T = get_turf(src)
	if(objective_spawn && is_ground_level(T.z))
		var/chance = rand(1,100)
		if(chance > CLUE_OBJECTIVE)
			new /obj/effect/landmark/objective_landmark(loc)
		else if(chance > CLUE_CLOSE)
			new /obj/effect/landmark/objective_landmark/close(loc)
		else if(chance > CLUE_MEDIUM)
			new /obj/effect/landmark/objective_landmark/medium(loc)
		else if(chance > CLUE_FAR)
			new /obj/effect/landmark/objective_landmark/far(loc)
		else if(chance > CLUE_SCIENCE)
			new /obj/effect/landmark/objective_landmark/science(loc)
	return INITIALIZE_HINT_LATELOAD

/obj/structure/surface/attackby(obj/item/attacking_item, mob/user, click_data)
	if(!user.drop_inv_item_to_loc(attacking_item, loc))
		return

	auto_align(attacking_item, click_data)
	user.next_move = world.time + 2
	return TRUE

/obj/structure/surface/proc/auto_align(obj/item/new_item, click_data)
	if(!new_item.center_of_mass) // Clothing, material stacks, generally items with large sprites where exact placement would be unhandy.
		new_item.pixel_x = rand(-new_item.randpixel, new_item.randpixel)
		new_item.pixel_y = rand(-new_item.randpixel, new_item.randpixel)
		new_item.pixel_z = 0
		return

	if(!click_data)
		return

	if(!click_data["icon-x"] || !click_data["icon-y"])
		return

	// Calculation to apply new pixelshift.
	var/mouse_x = text2num(click_data["icon-x"])-1 // Ranging from 0 to 31
	var/mouse_y = text2num(click_data["icon-y"])-1

	var/cell_x = clamp(round(mouse_x/CELLSIZE), 0, CELLS-1) // Ranging from 0 to CELLS-1
	var/cell_y = clamp(round(mouse_y/CELLSIZE), 0, CELLS-1)

	var/list/center = cached_key_number_decode(new_item.center_of_mass)

	new_item.pixel_x = (CELLSIZE * (cell_x + 0.5)) - center["x"]
	new_item.pixel_y = (CELLSIZE * (cell_y + 0.5)) - center["y"]
	new_item.pixel_z = 0
