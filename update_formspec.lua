local S = minetest.get_translator("travelnet")

function travelnet.primary_formspec(pos, puncher_name, _)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	local is_elevator = travelnet.is_elevator(node.name)

	if not meta then
		return
	end

	local owner_name      = meta:get_string("owner")
	local station_name    = meta:get_string("station_name")
	local station_network = meta:get_string("station_network")

	if	   not owner_name
		or not station_name
		or travelnet.is_falsey_string(station_network)
	then
		if is_elevator then
			travelnet.add_target(nil, nil, pos, puncher_name, meta, owner_name)
			return
		end
		travelnet.show_message(pos, puncher_name, "Error", S("Update failed! Resetting this box on the travelnet."))
		return
	end


	local network = travelnet.get_or_create_network(owner_name, station_network)
	-- if the station got lost from the network for some reason (savefile corrupted?) then add it again
	if not travelnet.get_station(owner_name, station_network, station_name) then

		local zeit = meta:get_int("timestamp")
		if not zeit or type(zeit) ~= "number" or zeit < 100000 then
			zeit = os.time()
		end

		-- add this station
		network[station_name] = {
			pos = pos,
			timestamp = zeit
		}

		minetest.chat_send_player(owner_name,
				S("Station '@1'" .. " " ..
					"has been reattached to the network '@2'.", station_name, station_network))
		travelnet.save_data()
	end

	return travelnet.formspecs.primary({
		owner_name = owner_name,
		station_network = station_network,
		station_name = station_name,
		is_elevator = is_elevator
	})
end

function travelnet.update_formspec()
	minetest.log("warning",
		"[travelnet] the travelnet.update_formspec method is deprecated. "..
		"The formspec is now generated on each interaction.")
end
