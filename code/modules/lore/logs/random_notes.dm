// Must be numbered in order 1 to INFINITY.

/obj/item/paper/random_note
	name = "handwritten note"
	persist_on_init = FALSE

/obj/item/paper/random_note/Initialize(mapload, text, title, list/md)
	. = ..()
	if(prob(20))
		new /obj/item/pen(loc)

/obj/item/paper/random_note/note_1
	name = "Casey's confession"
	info = "Кейси Родригез сосал у лейтенанта."

/obj/item/paper/random_note/note_2
	name = "Psychotherapy"
	info = "Ёдрён-батон. <BR>\
			Ёкарный бабай. <BR>\
			Тысячу чертей. <BR>"

/obj/item/paper/random_note/note_3
	info = "The surface is so beautiful. The sky is just a looming ocean of colors. I only saw two stars, one of them was unusually bright, like it wasn't that far from us."

/obj/item/paper/random_note/note_4
	info = "We were very late to the shelter and nearly got blasted by the sunrise. I remember standing there, entranced by the beauty of the burning sky..."

/obj/item/paper/random_note/note_5
	info = "You lie again. How fair is this, Samuel? I risk my life for you and all I get for it is BETRAYAL?"

/obj/item/paper/random_note/note_6
	info = "False identities, <BR>\
			Lost ideals, <BR>\
			So nothing left to keep me real, <BR>\
			Paradise is waiting for me, <BR>\
			And all I need is the <b>key</b>."

/obj/item/paper/random_note/note_6/Initialize(mapload, text, title, list/md)
	. = ..()
	new /obj/item/ammo_magazine/pistol/empty(loc)

/obj/item/paper/random_note/note_7
	info = "I feel broken. Nothing's left for me here, or anywhere else on that GOD DAMN HELLHOLE OF A PLANET!"