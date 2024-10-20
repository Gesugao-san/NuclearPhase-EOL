#define WHITELIST_PLACEHOLDER "exadv1"

GLOBAL_GETTER_PROTECTED(connect_whitelist, /datum/whitelist/connection, new)
GLOBAL_GETTER_PROTECTED(job_whitelist, /datum/whitelist/job, new)

#define WHITELIST_ASSOC 1
#define WHITELIST_DATA 2

/datum/whitelist
	var/name = "Meta whitelist"
	var/filename = null
	var/stat = 0

	var/list/datalist = list()
	var/list/list/assoclist = list()

	var/list/panels = list()

/datum/whitelist/New()
	. = ..()
	get_from_file()

/datum/whitelist/proc/get_from_file()
	datalist = list()
	assoclist = list()
	if(!filename)
		return
	switch(stat)
		if(0)
			return
		if(WHITELIST_ASSOC)
			var/list/entries = file2list(filename)
			for(var/entry in entries)
				if(!entry)
					continue
				entry = trim(entry)
				if(!length(entry))
					continue
				var/list/data = splittext(entry, "=")
				var/path = replacetext(data[1], " ", "")
				check_and_place_if_list_dosnt_have_entry(assoclist, path)
				if(!data[2])
					continue
				var/list/users = splittext(data[2], ";")
				for(var/user in users)
					assoclist[path] += ckey(user)
		if(WHITELIST_DATA)
			var/list/entries = file2list(filename)
			for(var/entry in entries)
				if(!entry)
					continue
				entry = trim(entry)
				datalist += ckey(entry)


/datum/whitelist/proc/add_entry(var/value)
	datalist += value

/datum/whitelist/proc/add_assoc_entry(var/key, var/value)
	check_and_place_if_list_dosnt_have_entry(assoclist, key)
	assoclist[key] += value

/datum/whitelist/proc/check_entry(var/key)
	return key in datalist

/datum/whitelist/proc/check_entry_assoc(var/key, var/value)
	return (key in assoclist) ? (value in assoclist[key]) : FALSE

/datum/whitelist/job/check_entry_assoc(var/key, var/value)
	var/datum/job/job = SSjobs.get_by_path(text2path(key))
	if(!job.required_whitelists)
		return TRUE
	for(var/whitelist_decl_type in job.required_whitelists)
		whitelist_decl_type = "[whitelist_decl_type]" // path to string
		if(!(whitelist_decl_type in assoclist))
			continue
		if(!(value in assoclist[whitelist_decl_type]))
			return FALSE
	return TRUE

/datum/whitelist/Topic(href, href_list, state)
	if(!check_rights(R_VAREDIT | R_DEBUG))
		return

	if(href_list["datalist"])
		if(href_list["addnew"])
			var/text = input(usr, "Enter value...", "Whitelist") as text|null
			if(!text)
				return

			datalist += ckey(text)

			message_admins(SPAN_INFO("[usr] added new entry to [src]!"))

		else if(href_list["data"])
			if(alert(usr, "Are you sure you want to delete it?", href_list["data"], "Yes, remove that already", "No, thanks...") == "Yes, remove that already")
				datalist -= href_list["data"]
				message_admins(SPAN_INFO("[usr] removed key from [src]!"))

	else if(href_list["assoclist"])
		if(href_list["addnewkey"])
			var/text = input(usr, "Enter key...", "Whitelist") as text|null
			if(!text)
				return

			check_and_place_if_list_dosnt_have_entry(assoclist, text)

			message_admins(SPAN_INFO("[usr] added new key to [src]!"))

		else if(href_list["addnewval"])
			var/key = href_list["key"]
			if(!key)
				return

			var/text = input(usr, "Enter value...", "Whitelist") as text|null
			if(!text)
				return

			check_and_place_if_list_dosnt_have_entry(assoclist, key)
			assoclist[key] += ckey(text)

			message_admins(SPAN_INFO("[usr] added new value to [src]!"))
		else if(href_list["value"])
			var/key = href_list["key"]
			if(!key)
				return

			if(alert(usr, "Are you sure you want to delete it?", href_list["data"], "Yes, remove that already", "No, thanks...") == "Yes, remove that already")
				assoclist[key] -= href_list["data"]
				message_admins(SPAN_INFO("[usr] removed value from [src]!"))

		else if(href_list["key"])
			var/key = href_list["data"]
			switch(alert(usr, "Choose option", , "Delete key", "Rename key", "Close"))
				if("Delete key")
					if(alert(usr, "Are you sure about to delete a key and all values?", key, "Yes", "No...") == "No")
						return
					assoclist -= key
					message_admins(SPAN_INFO("[usr] deleted key from [src]!"))
				if("Rename key")
					var/text = input(usr, "Enter new name of key...", "Whitelist") as text|null
					if(!text)
						return
					var/list/old_values = assoclist[key]
					assoclist -= key
					check_and_place_if_list_dosnt_have_entry(assoclist, text)
					assoclist[text] = old_values
					message_admins(SPAN_INFO("[usr] renamed key in [src]!"))

				if("Close")
					return

	var/datum/browser/popup = panels["\ref[usr.client]"]
	if(popup)
		popup.update()

/datum/whitelist/proc/get_panel_data()
	var/msg = list()

	if(length(datalist))
		msg += "<table><tr><th>Num.</th><th>Data list</th></tr>"
		var/num = 0
		for (var/i in datalist)
			msg += "<tr>"
			msg += "<td>[num]</td>"
			if(i != WHITELIST_PLACEHOLDER)
				msg += "<td><a href='?src=\ref[src];data=[i];datalist=1'>[i]</a></td>"
			else
				msg += "<td>EMPTY</td>"
			num += 1
			msg += "</tr>"
		msg += "<tr><td></td><td><a class='bad' href='?src=\ref[src];addnew=1;datalist=1;'>ADD NEW ENTRY</a></td></tr>"
		msg += "</table>"
	if(length(assoclist))
		msg += "<table><tr><th>Key</th><th>Value</th></tr>"
		for(var/key in assoclist)
			msg += "<tr>"
			msg += "<td><a href='?src=\ref[src];data=[key];assoclist=1;key=1'>[key]</a></td><td>"
			for(var/value in assoclist[key])
				if(value != WHITELIST_PLACEHOLDER)
					msg += "<a href='?src=\ref[src];data=[value];key=[key];assoclist=1;value=1'>[value]</a><br>"
				else
					msg += "EMPTY<br>"
			msg += "<a class='bad' href='?src=\ref[src];addnewval=1;key=[key];assoclist=1;'>ADD NEW VALUE ENTRY</a>"
			msg += "</td></tr>"
		msg += "<tr><td><a class='bad' href='?src=\ref[src];addnewkey=1;assoclist=1;'>ADD NEW KEY</a></td><td></td></tr>"
		msg += "</table>"
	return msg

/datum/whitelist/connection
	name = "Connection whitelist"
	filename = "whitelist/join.txt"
	stat = WHITELIST_DATA

/datum/whitelist/job
	name = "Job whitelist"
	filename = "whitelist/jobs.txt"
	stat = WHITELIST_ASSOC

/datum/browser/whitelist_debug
	var/datum/whitelist/source

/datum/browser/whitelist_debug/New(nuser, nwindow_id, ntitle, nwidth, nheight, nref)
	. = ..(nuser, nwindow_id, ntitle, nwidth, nheight, nref)
	source = nref

/datum/browser/whitelist_debug/get_content()
	content = JOINTEXT(source.get_panel_data())
	. = ..()

/client/proc/debug_whitelist()
	set name = "Debug Whitelist"
	set category = "Debug"

	if(!check_rights(R_VAREDIT | R_DEBUG))
		return

	var/datum/whitelist/choosen = input("Select whitelist type") as null|anything in list(get_global_job_whitelist(), get_global_connect_whitelist())
	if(!choosen)
		return

	switch(alert(usr, "Which option you would to use?", , "VV", "Panel"))
		if("VV")
			debug_variables(choosen)
		if("Panel")
			var/datum/browser/whitelist_debug/popup = new(mob, "whitelist", "Whitelist edit", 370, 700, choosen)
			popup.add_stylesheet("wl", 'html/browser/wl.css')
			choosen.panels["\ref[src]"] = popup
			popup.open()

/client
	var/is_wl = FALSE

/client/Topic(href, href_list, hsrc)
	. = ..()
	if(href_list["close"] && istype(hsrc, /datum/whitelist))
		var/datum/whitelist/W = hsrc
		W.panels -= "\ref[src]"

/client/New()
	show_lore_entry()
	var/datum/whitelist/wl = get_global_connect_whitelist()
	if(!wl.check_entry(ckey(key)))
		src << link("https://discord.gg/d9qmWD7w35")
		message_admins(SPAN_CUMZONE("[src] joined without a whitelist."))
		show_browser(src, "Вас нет в вайтлисте. Вам будет доступна только одна роль, почти не покрывающая широкий геймплей нашего сервера. Для получения доступа к остальным ролям зайдите в наш дискорд сервер(https://discord.gg/d9qmWD7w35) и пройдите верификацию. Приятной смерти.", "window=whitelisted;size=900x480")
	else //хуй был тут
		is_wl = TRUE
	. = ..()

/client/proc/show_lore_entry()
	var/text = "\
				Год 2207-й. <BR>\
				Человечество успешно колонизировало Альфу Центавра и Сириус.<BR>\
				Единственная колония на Сириусе пострадала от неизвестного климатического катаклизма, сделав поверхность совершенно непригодной для жизни из-за температурных условий.<BR>\
				Несколько подземных сооружений были переоборудованы для длительного выживания в таких условиях.<BR>\
				ESS « Serenity» - одно из них. Вы - один из его обитателей.<BR>\
				Варп-перемещение еще не разработано, никто на Альфе Центавра и Соле не знает о случившемся. Вы одни.<BR><BR>\
				The year is 2207. <BR>\
				Humanity has successfully colonized Alpha Centauri and Sirius.<BR>\
				The only colony in Sirius was hit by an unknown climate cataclysm, rendering the surface completely uninhabitable from temperature conditions.<BR>\
				Several underground facilities were retrofitted to allow long-term survival in such conditions.<BR>\
				ESS ‘Serenity’ is one of them. You are one of its inhabitants.<BR>\
				Faster-Than-Light warp travel isn’t developed yet, no one in Alpha Centauri or Sol knows about the calamity. You are alone.<BR>\
				"
	show_browser(src, text, "window=loreentry;size=900x480")

/decl/whitelist/medical_low
/decl/whitelist/medical_high
/decl/whitelist/engineering_low
/decl/whitelist/engineering_high
/decl/whitelist/command_ceo
/decl/whitelist/command_executive
/decl/whitelist/command_beginner
/decl/whitelist/security_management