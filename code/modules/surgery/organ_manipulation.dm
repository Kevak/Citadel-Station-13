/datum/surgery/organ_manipulation
	name = "organ manipulation"
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/incise,
	/datum/surgery_step/manipulate_organs,
	/datum/surgery_step/prep_bone,
	/datum/surgery_step/set_bone,
	/datum/surgery_step/mend_bone,
	/datum/surgery_step/close
	)
	species = list(
	/mob/living/carbon/human,
	/mob/living/carbon/monkey
	)
	possible_locs = list("chest", "head")
	requires_organic_bodypart = TRUE
	requires_real_bodypart = TRUE
	requires_bones = TRUE
	can_cancel = FALSE
	cantbematerial = TRUE

/datum/surgery/organ_manipulation/soft
	possible_locs = list("groin", "eyes", "mouth", "l_arm", "r_arm", "l_leg", "r_leg")
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/incise,
	/datum/surgery_step/manipulate_organs,
	/datum/surgery_step/close
	)
	requires_bones = TRUE

/datum/surgery/organ_manipulation/alien
	name = "alien organ manipulation"
	possible_locs = list("chest", "head", "groin", "eyes", "mouth", "l_arm", "r_arm", "l_leg", "r_leg")
	species = list(
	/mob/living/carbon/alien/humanoid
	)
	steps = list(
	/datum/surgery_step/saw,
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/manipulate_organs,
	/datum/surgery_step/close
	)
	requires_bones = FALSE

/datum/surgery/organ_manipulation/golem
	name = "material organ manipulation"
	possible_locs = list("chest", "head", "groin", "eyes", "mouth", "l_arm", "r_arm", "l_leg", "r_leg")
	species = list(/mob/living/carbon/human/species/golem)
	steps = list(
	/datum/surgery_step/saw_material,
	/datum/surgery_step/retract_material,
	/datum/surgery_step/saw_material,
	/datum/surgery_step/retract_material,
	/datum/surgery_step/manipulate_organs,
	/datum/surgery_step/prep_material,
	/datum/surgery_step/set_material,
	/datum/surgery_step/reinforce_material,
	/datum/surgery_step/close
	)
	requires_bones = FALSE
	material_flesh = TRUE
	cantbematerial = FALSE

/datum/surgery/organ_manipulation/boneless
	name = "boneless organ manipulation"
	possible_locs = list("chest","head","groin", "eyes", "mouth", "l_arm", "r_arm", "l_leg", "r_leg")
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/incise,
	/datum/surgery_step/manipulate_organs,
	/datum/surgery_step/close
	)
	requires_organic_bodypart = TRUE
	requires_bones = FALSE
	cantbebones = TRUE

/datum/surgery_step/manipulate_organs
	time = 64
	name = "manipulate organs"
	implements = list(
	/obj/item/organ = 100,
	/obj/item/reagent_containers/food/snacks/organ = 0,
	/obj/item/organ_storage = 100
	)
	var/implements_extract = list(
	/obj/item/hemostat = 100,
	/obj/item/wirecutters = 55
	)
	var/implements_finish = list(
	/obj/item/retractor = 100,
	/obj/item/wrench = 55
	)
	var/current_type
	var/obj/item/organ/I


/datum/surgery_step/manipulate_organs/New()
	..()
	implements = implements + implements_extract + implements_finish


/datum/surgery_step/manipulate_organs/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	I = null
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='notice'>There is nothing inside [tool]!</span>")
			return FALSE
		I = tool.contents[1]
		if(!isorgan(I))
			to_chat(user, "<span class='notice'>You cannot put [I] into [target]'s [parse_zone(target_zone)]!</span>")
			return FALSE
		tool = I
	if(isorgan(tool))
		current_type = "insert"
		I = tool
		if(target_zone != I.zone || target.getorganslot(I.slot))
			to_chat(user, "<span class='notice'>There is no room for [I] in [target]'s [parse_zone(target_zone)]!</span>")
			return FALSE

		user.visible_message("[user] begins to insert [tool] into [target]'s [parse_zone(target_zone)].",
			"<span class='notice'>You begin to insert [tool] into [target]'s [parse_zone(target_zone)]...</span>")

	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/organs = target.getorganszone(target_zone)

		var/mob/living/simple_animal/borer/B = target.has_brain_worms()
		if(target.has_brain_worms())
			user.visible_message("[user] begins to extract [B] from [target]'s [parse_zone(target_zone)].",
					"<span class='notice'>You begin to extract [B] from [target]'s [parse_zone(target_zone)]...</span>")
			return TRUE

		if(!organs.len)
			to_chat(user, "<span class='notice'>There are no removeable organs in [target]'s [parse_zone(target_zone)]!</span>")
			return FALSE
		else
			for(var/obj/item/organ/O in organs)
				O.on_find(user)
				organs -= O
				organs[O.name] = O

			I = input("Remove which organ?", "Surgery", null, null) as null|anything in organs
			if(I && user && target && user.Adjacent(target) && user.get_active_held_item() == tool)
				I = organs[I]
				if(!I) return FALSE
				user.visible_message("[user] begins to extract [I] from [target]'s [parse_zone(target_zone)].",
					"<span class='notice'>You begin to extract [I] from [target]'s [parse_zone(target_zone)]...</span>")
			else
				return FALSE

	else if(implement_type in implements_finish)
		current_type = "finish"
		user.visible_message("[user] begins to pull [target]'s [parse_zone(target_zone)] flesh back into place.",
			"<span class='notice'>You begin pull [target]'s [parse_zone(target_zone)] flesh back into place...</span>")
		return TRUE

	else if(istype(tool, /obj/item/reagent_containers/food/snacks/organ))
		to_chat(user, "<span class='warning'>[tool] was bitten by someone! It's too damaged to use!</span>")
		return FALSE

/datum/surgery_step/manipulate_organs/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(current_type == "insert")
		if(istype(tool, /obj/item/organ_storage))
			I = tool.contents[1]
			tool.icon_state = "evidenceobj"
			tool.desc = "A container for holding body parts."
			tool.cut_overlays()
			tool = I
		else
			I = tool
		user.temporarilyRemoveItemFromInventory(I, TRUE)
		I.Insert(target)
		user.visible_message("[user] inserts [tool] into [target]'s [parse_zone(target_zone)]!",
			"<span class='notice'>You insert [tool] into [target]'s [parse_zone(target_zone)].</span>")
		return FALSE

	else if(current_type == "extract")
		var/mob/living/simple_animal/borer/B = target.has_brain_worms()
		if(B && B.victim == target)
			user.visible_message("[user] successfully extracts [B] from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You successfully extract [B] from [target]'s [parse_zone(target_zone)].</span>")
			add_logs(user, target, "surgically removed [B] from", addition="INTENT: [uppertext(user.a_intent)]")
			B.leave_victim()
			return FALSE
		if(I && I.owner == target)
			user.visible_message("[user] successfully extracts [I] from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You successfully extract [I] from [target]'s [parse_zone(target_zone)].</span>")
			add_logs(user, target, "surgically removed [I.name] from", addition="INTENT: [uppertext(user.a_intent)]")
			I.Remove(target)
			I.forceMove(get_turf(target))
		else
			user.visible_message("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!",
				"<span class='notice'>You can't extract anything from [target]'s [parse_zone(target_zone)]!</span>")
		return FALSE

	if(current_type == "finish")
		user.visible_message("[user] pulls the flesh in [target]'s [parse_zone(target_zone)] back into place.",
			"<span class='notice'>You pull the flesh in [target]'s [parse_zone(target_zone)] back into place.</span>")
		return TRUE
