local S = minetest.get_translator("travelnet")

local player_formspec_data = travelnet.player_formspec_data

local function validate_travelnet(pos, meta)
	local owner_name      = meta:get_string("owner")
	local station_network = meta:get_string("station_network")
	local station_name    = meta:get_string("station_name")

	-- if there is something wrong with the data
	if not owner_name or not station_network or not station_name then
		minetest.chat_send_player(name, S("Error") .. ": " ..
				S("There is something wrong with the configuration of this station.") ..
					" DEBUG DATA: owner: " .. (owner_name or "?") ..
					" station_name: " .. (station_name or "?") ..
					" station_network: " .. (station_network or "?") .. "."
		)
		print(
			"ERROR: The travelnet at " .. minetest.pos_to_string(pos) .. " has a problem: " ..
			" DATA: owner: " .. (owner_name or "?") ..
			" station_name: " .. (station_name or "?") ..
			" station_network: " .. (station_network or "?") .. "."
		)
		return false
	end

	-- TODO: This check seems odd, re-think this. Don't get node twice, don't hard-code node names.
	local description = travelnet.node_description(pos)
	if not description then
		minetest.chat_send_player(name, "Error: Unknown node.")
		return false
	end

	return true, {
		description = description,
		owner_name = owner_name,
		station_network = station_network,
		station_name = station_name
	}
end

local function decide_action(fields, props)
	if (travelnet.MAX_STATIONS_PER_NETWORK == 0 or travelnet.MAX_STATIONS_PER_NETWORK > 24)
		and fields.page_number
		and (
			fields.next_page
			or fields.prev_page
			or fields.last_page
			or fields.first_page
		)
	then
		return travelnet.actions.navigate_page
	end

	-- the player wants to remove the station
	if fields.station_dig then
		return travelnet.actions.remove_station
	end

	if fields.station_edit then
		return travelnet.actions.edit_station
	end

	-- if the box has not been configured yet
	if travelnet.is_falsey_string(props.station_network) then
		return travelnet.actions.add_station
	end

	-- save pressed after editing
	if fields.station_set then
		return travelnet.actions.update_station
	end

	if fields.open_door then
		return travelnet.actions.toggle_door
	end

	-- the owner or players with the travelnet_attach priv can move stations up or down in the list
	if fields.move_up or fields.move_down then
		return travelnet.actions.change_order
	end

	if not fields.target then
		return travelnet.actions.instruct_player
	end

	local network = travelnet.get_network(props.owner_name, props.station_network)
	if not network then
		return travelnet.actions.add_station
	end

	return travelnet.actions.transport_player
end

function travelnet.on_receive_fields(pos, _, fields, player)
	local name = player:get_player_name()
	player_formspec_data[name] = player_formspec_data[name] or {}
	if pos then
		player_formspec_data[name].pos = pos
	else
		pos = player_formspec_data[name].pos
	end

	if not pos or not player then
		travelnet.set_formspec(name, "")
		return
	end

	-- the player wants to quit/exit the formspec; do not save/update anything
	if fields and ((fields.station_exit and fields.station_exit ~= "") or (fields.quit and fields.quit ~= "")) then
		travelnet.set_formspec(name, "")
		return
	end

	local meta = minetest.get_meta(pos)
	local valid, props = validate_travelnet(pos, meta)
	if not valid then
		travelnet.set_formspec(name, "")
		return
	end

	local action = decide_action(fields, props)
	if not action then
		travelnet.set_formspec(name, "")
		return
	end

	local node = minetest.get_node(pos)
	props.is_elevator = travelnet.is_elevator(node.name)

	local success, result = action({
		node = node,
		props = props,
		meta = meta,
		pos = pos
	}, fields, player)

	if success then
		if result and result.formspec then
			if result.options then
				for k,v in pairs(result.options) do
					props[k] = v
				end
			end
			travelnet.set_formspec(name, travelnet.formspecs[result.formspec](props))
		else
			travelnet.set_formspec(name, "")
		end
	else
		travelnet.set_formspec(name, travelnet.formspecs.error_message({ message = result }))
	end

	if fields.quit or closed then
		player_formspec_data[name] = nil
	end
end
