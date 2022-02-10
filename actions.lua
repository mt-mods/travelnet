local S = minetest.get_translator("travelnet")

travelnet.actions = {}

function travelnet.actions.navigate_page(node_info, fields, player)
	local page = 1
	local network = travelnet.get_network(node_info.props.owner_name, node_info.props.station_network)
	local station_count = 0
	for _ in pairs(network) do
		station_count = station_count+1
	end
	local page_size = 7*3
	local pages = math.ceil(station_count/page_size)

	if fields.last_page then
		page = pages
	else
		local current_page = tonumber(fields.page_number)
		if current_page then
			if fields.next_page then
				page = math.min(current_page+1, pages)
			elseif fields.prev_page then
				page = math.max(current_page-1, 1)
			end
		end
	end
	return true, { formspec = "primary", options = { page_number = page } }
end

function travelnet.actions.remove_station(node_info, fields, player)
	local player_name = player:get_player_name()

	-- abort if protected by another mod
	if	minetest.is_protected(node_info.pos, player_name)
		and not minetest.check_player_privs(player_name, { protection_bypass = true })
	then
		minetest.record_protection_violation(node_info.pos, player_name)
		return false, S("This @1 belongs to @2. You can't remove it.", node_info.props.description, node_info.props.owner_name)
	end

	-- players with travelnet_remove priv can dig the station
	if
		not minetest.check_player_privs(player_name, { travelnet_remove = true })
		-- the function travelnet.allow_dig(..) may allow additional digging
		and not travelnet.allow_dig(player_name, node_info.props.owner_name, node_info.props.station_network, node_info.pos)
		-- the owner can remove the station
		and node_info.props.owner_name ~= player_name
		-- stations without owner can be removed/edited by anybody
		and node_info.props.owner_name ~= ""
	then
		return false, S("This @1 belongs to @2. You can't remove it.", node_info.props.description, node_info.props.owner_name)
	end

	-- remove station
	local player_inventory = player:get_inventory()
	if not player_inventory:room_for_item("main", node_info.node.name) then
		return false, S("You do not have enough room in your inventory.")
	end

	-- give the player the box
	player_inventory:add_item("main", node_info.node.name)
	-- remove the box from the data structure
	travelnet.remove_box(node_info.pos, nil, node_info.meta:to_table(), player)
	-- remove the node as such
	minetest.remove_node(node_info.pos)

	return true
end

function travelnet.actions.edit_station(node_info, fields, player)
	local player_name = player:get_player_name()
	-- abort if protected by another mod
	if minetest.is_protected(node_info.pos, player_name)
	   and not minetest.check_player_privs(player_name, { protection_bypass=true })
	then
		minetest.record_protection_violation(node_info.pos, player_name)
		return false, S("This @1 belongs to @2. You can't edit it.",
				node_info.props.description,
				tostring(node_info.props.owner_name)
			)
	end

	return true, { formspec = node_info.props.is_elevator and "edit_elevator" or "edit_travelnet" }
end

function travelnet.actions.add_station(node_info, fields, player)
	return travelnet.add_target(
		fields.station_name or node_info.props.station_name,
		fields.station_network or node_info.props.station_network,
		node_info.pos,
		player:get_player_name(),
		node_info.meta,
		fields.owner or node_info.props.owner_name)
end

function travelnet.actions.update_station(node_info, fields, player)
	return travelnet.edit_box(node_info.pos, fields, node_info.meta, player:get_player_name())
end

function travelnet.actions.toggle_door(node_info, fields, player)
	travelnet.open_close_door(node_info.pos, player, "toggle")
	return true
end

function travelnet.actions.change_order(node_info, fields, player)
	local player_name = player:get_player_name()

	-- does the player want to move this station one position up in the list?
	-- only the owner and players with the travelnet_attach priv can change the order of the list
	-- Note: With elevators, only the "G"(round) marking is actually moved
	if fields and (fields.move_up or fields.move_down)
		and not travelnet.is_falsey_string(node_info.props.owner_name)
		and (
			   (node_info.props.owner_name == player_name)
			or (minetest.check_player_privs(player_name, { travelnet_attach=true }))
		)
	then
		local network = travelnet.get_network(node_info.props.owner_name, node_info.props.station_network)

		if not network then
			return false, S("This station does not have a network.")
		end
		local stations = travelnet.get_ordered_stations(node_info.props.owner_name, node_info.props.station_network, node_info.props.is_elevator)

		local current_pos = -1
		for index, k in ipairs(stations) do
			if k == node_info.props.station_name then
				current_pos = index
				break
			end
		end

		local swap_with_pos
		if fields.move_up then
			swap_with_pos = current_pos-1
		else
			swap_with_pos = current_pos+1
		end

		-- handle errors
		if swap_with_pos < 1 then
			return false, S("This station is already the first one on the list.")
		elseif swap_with_pos > #stations then
			return false, S("This station is already the last one on the list.")
		else
			local current_station = stations[current_pos]
			local swap_with_station = stations[swap_with_pos]

			-- swap the actual data by which the stations are sorted
			local old_timestamp = network[swap_with_station].timestamp
			network[swap_with_station].timestamp = network[current_station].timestamp
			network[current_station].timestamp = old_timestamp

			-- for elevators, only the "G"(round) marking is moved; no point in swapping stations
			if not node_info.props.is_elevator then
				-- actually swap the stations
				stations[swap_with_pos] = current_station
				stations[current_pos]   = swap_with_station
			end

			-- store the changed order
			travelnet.save_data()
			return true, { formspec = "primary" }
		end
	end
	return false, S("This @1 belongs to @2. You can't edit it.",
			node_info.props.description,
			tostring(node_info.props.owner_name)
		)
end

function travelnet.actions.transport_player(node_info, fields, player)

	local network = travelnet.get_network(node_info.props.owner_name, node_info.props.station_network)

	if node_info.node ~= nil and node_info.props.is_elevator then
		for k,_ in pairs(network) do
			if network[k].nr == fields.target then
				fields.target = k
				break
			end
		end
	end

	local target_station = network[fields.target]

	-- if the target station is gone
	if not target_station then
		return false, S("Station '@1' does not exist (anymore?)" ..
					" " .. "on this network.", fields.target or "?")
	end

	local player_name = player:get_player_name()

	if not travelnet.allow_travel(
		player_name,
		node_info.props.owner_name,
		node_info.props.station_network,
		node_info.props.station_name,
		fields.target
	) then
		return false, S("You are not allowed to travel to this station.")
	end
	minetest.chat_send_player(player_name, S("Initiating transfer to station '@1'.", fields.target or "?"))

	if travelnet.travelnet_sound_enabled then
		if node_info.props.is_elevator then
			minetest.sound_play("travelnet_bell", {
				pos = node_info.pos,
				gain = 0.75,
				max_hear_distance = 10
			})
		else
			minetest.sound_play("travelnet_travel", {
				pos = node_info.pos,
				gain = 0.75,
				max_hear_distance = 10
			})
		end
	end

	if travelnet.travelnet_effect_enabled then
		minetest.add_entity(vector.add(node_info.pos, { x=0, y=0.5, z=0 }), "travelnet:effect")  -- it self-destructs after 20 turns
	end

	-- close the doors at the sending station
	travelnet.open_close_door(node_info.pos, player, "close")

	-- transport the player to the target location

	-- may be 0.0 for some versions of MT 5 player model
	local player_model_bottom = tonumber(minetest.settings:get("player_model_bottom")) or -.5
	local player_model_vec = vector.new(0, player_model_bottom, 0)
	local target_pos = target_station.pos

	local top_pos = vector.add(node_info.pos, { x=0, y=1, z=0 })
	local top_node = minetest.get_node(top_pos)
	if top_node.name ~= "travelnet:hidden_top" then
		local def = minetest.registered_nodes[top_node.name]
		if def and def.buildable_to then
			minetest.set_node(top_pos, { name="travelnet:hidden_top" })
		end
	end

	minetest.load_area(target_pos)

	local tnode = minetest.get_node(target_pos)
	-- check if the box has at the other end has been removed.
	if minetest.get_item_group(tnode.name, "travelnet") == 0 and minetest.get_item_group(tnode.name, "elevator") == 0 then
		-- provide information necessary to identify the removed box
		local oldmetadata = {
			fields = {
				owner           = node_info.props.owner_name,
				station_name    = fields.target,
				station_network = node_info.props.station_network
			}
		}

		travelnet.remove_box(target_pos, nil, oldmetadata, player)
	else
		player:move_to(vector.add(target_pos, player_model_vec), false)
		travelnet.rotate_player(target_pos, player)
	end

	return true
end

function travelnet.actions.instruct_player(node_info, fields, player)
	minetest.chat_send_player(player:get_player_name(), S("Please click on the target you want to travel to."))
	return true
end
