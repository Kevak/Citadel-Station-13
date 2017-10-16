/datum/surgery/embedded_removal
	name = "removal of embedded objects"
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/remove_object,
	/datum/surgery_step/close
	)
	possible_locs = list("r_arm","l_arm","r_leg","l_leg","chest","head")
	requires_bodypart_type = (BODYPART_ORGANIC) || (BODYPART_FLUBBER)

/datum/surgery/embedded_removal/golem
	name = "material removal of embedded objects"
	steps = list(
	/datum/surgery_step/saw_material,
	/datum/surgery_step/retract_material,
	/datum/surgery_step/remove_object,
	/datum/surgery_step/prep_material,
	/datum/surgery_step/set_material,
	/datum/surgery_step/reinforce_material,
	/datum/surgery_step/close
	)
	requires_bodypart_type = BODYPART_MATERIAL


/datum/surgery_step/remove_object
	name = "remove embedded objects"
	time = 32
	accept_hand = TRUE
	var/obj/item/bodypart/L


/datum/surgery_step/remove_object/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	L = surgery.operated_bodypart
	if(L)
		user.visible_message("[user] looks for objects embedded in [target]'s [parse_zone(user.zone_selected)].", "<span class='notice'>You look for objects embedded in [target]'s [parse_zone(user.zone_selected)]...</span>")
	else
		user.visible_message("[user] looks for [target]'s [parse_zone(user.zone_selected)].", "<span class='notice'>You look for [target]'s [parse_zone(user.zone_selected)]...</span>")


/datum/surgery_step/remove_object/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(L)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			var/objects = 0
			for(var/obj/item/I in L.embedded_objects)
				objects++
				I.loc = get_turf(H)
				L.embedded_objects -= I
			if(!H.has_embedded_objects())
				H.clear_alert("embeddedobject")

			if(objects > 0)
				user.visible_message("[user] successfully removes [objects] objects from [H]'s [L]!", "<span class='notice'>You successfully remove [objects] objects from [H]'s [L.name].</span>")
			else
				to_chat(user, "<span class='warning'>You find no objects embedded in [H]'s [L]!</span>")

	else
		to_chat(user, "<span class='warning'>You can't find [target]'s [parse_zone(user.zone_selected)], let alone any objects embedded in it!</span>")

	return TRUE