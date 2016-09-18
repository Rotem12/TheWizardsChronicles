/*
 * Copyright � 2014 Duncan Fairley
 * Distributed under the GNU Affero General Public License, version 3.
 * Your changes must be made public.
 * For the full license text, see LICENSE.txt.
 */
var/list/clanwars_schedule  = list()
var/list/autoclass_schedule = list()

proc/time_until(day, hour)

	var/http[] = world.Export("http://wizardschronicles.com/time_functions.php?day=[day]&hour=[hour]")

	if(!http) return -1

	var/F = http["CONTENT"]
	if(F)
		return text2num(file2text(F))

	return -1

var/DropRateModifier = 1
mob/GM/verb
	Clan_Wars_Schedule(var/Event/e in clanwars_schedule)
		set category = "Staff"
		switch(alert(src, "What do you want to do?", "Events", "Cancel Event", "Check Time", "Nothing"))
			if("Cancel Event")
				scheduler.cancel(clanwars_schedule[e])
				clanwars_schedule.Remove(e)
				src << infomsg("Event cancelled.")
			if("Check Time")
				var/ticks = scheduler.time_to_fire(clanwars_schedule[e])
				src << infomsg("[comma(ticks)] ticks until event starts.")

	AutoClass_Schedule(var/Event/e in autoclass_schedule)
		set category = "Staff"
		switch(alert(src, "What do you want to do?", "Events", "Cancel Event", "Check Time", "Nothing"))
			if("Cancel Event")
				scheduler.cancel(autoclass_schedule[e])
				autoclass_schedule.Remove(e)
				src << infomsg("Event cancelled.")
			if("Check Time")
				var/ticks = scheduler.time_to_fire(autoclass_schedule[e])
				src << infomsg("[comma(ticks)] ticks until event starts.")

	Add_AutoClass(var/day as text, var/hour as text)
		set category = "Staff"
		var/date = add_autoclass(day, hour)
		if(date != -1)
			usr << infomsg("Auto class scheduled ([comma(date)])")
		else
			usr << errormsg("Could not schedule auto class.")

	Weather(var/effect in worldData.weather_effects, var/prob as num)
		set category = "Staff"
		worldData.weather_effects[effect] = prob
		src << infomsg("[effect] has [prob] probability to occur.")

	Events(var/RandomEvent/e in worldData.events, var/prob as num)
		set category = "Events"
		e.chance = prob
		src << infomsg("[e] has [e.chance] probability to occur.")

	Set_Drop_Rate(var/rate as num)
		set category = "Staff"
		DropRateModifier = rate
		src << infomsg("Drop rate modifier set to [rate]")

	Set_Price_Modifier(var/modifier as num)
		set category = "Staff"
		shopPriceModifier = modifier
		src << infomsg("Drop rate modifier set to [modifier]")

	Schedule_Clanwars(var/day as text, var/hour as text)
		set category = "Staff"
		var/date = add_clan_wars(day, hour)
		if(date != -1)
			usr << infomsg("Clan wars scheduled ([comma(date)])")
		else
			usr << errormsg("Could not schedule clan wars.")

	Start_Random_Event(var/RandomEvent/event in worldData.events+"random")
		if(event == "random")
			var/RandomEvent/e = pickweight(worldData.events)
			e.start()
		else
			event.start()

	Toggle_GiftOpening()
		set category = "Staff"
		worldData.allowGifts = !worldData.allowGifts
		usr << infomsg("Gifts [worldData.allowGifts ? "can" : "can't"] be opened.")

proc
	add_clan_wars(var/day, var/hour)
		var/date = time_until(day, hour)
		if(date != -1)
			var/Event/ClanWars/e = new
			clanwars_schedule["[day] - [hour]"] = e
			scheduler.schedule(e, world.tick_lag * 10 * date)
		return date
	add_autoclass(var/day, var/hour)
		var/date = time_until(day, hour)
		if(date != -1)
			var/Event/AutoClass/e = new
			autoclass_schedule["[day] - [hour]"] = e
			scheduler.schedule(e, world.tick_lag * 10 * date)
		return date

mob/test/verb/Movement_Queue()
	move_queue = !move_queue
	src << infomsg("Movement queue toggled [move_queue ? "on" : "off"].")