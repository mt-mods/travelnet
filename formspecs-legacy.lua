local S = minetest.get_translator("travelnet")

local travelnet_form_name = "travelnet:show"

local player_formspec_data = travelnet.player_formspec_data

-- minetest.chat_send_player is sometimes not so well visible
function travelnet.show_message(pos, player_name, title, message)
	if not pos or not player_name or not message then
		return
	end
	local formspec = travelnet.formspecs.error_message({
		title = title,
		message = message
	})
	travelnet.show_formspec(player_name, formspec)
end

-- show the player the formspec they would see when right-clicking the node;
-- needs to be simulated this way as calling on_rightclick would not do
function travelnet.show_current_formspec(pos, _, player_name)
	travelnet.page_formspec(pos, player_name)
end

-- a player clicked on something in the formspec hse was manually shown
-- (back from help page, moved travelnet up or down etc.)
function travelnet.form_input_handler(player, formname, fields)
	if formname ~= travelnet_form_name then return end
	if fields then
		-- back button leads back to the main menu
		if fields.back and fields.back ~= "" then
			local player_name = player:get_player_name()
			local pos = player_formspec_data[player_name] and player_formspec_data[player_name].pos
			if not pos then
				return
			end

			local meta = minetest.get_meta(pos)
			local station_network = meta:get_string("station_network")

			if travelnet.is_falsey_string(station_network) then
				local node = minetest.get_node(pos)
				local is_elevator = travelnet.is_elevator(node.name)
				if is_elevator then
					return travelnet.show_formspec(player_name, travelnet.formspecs.edit_elevator())
				else
					return travelnet.show_formspec(player_name, travelnet.formspecs.edit_travelnet())
				end
			else
				return travelnet.show_current_formspec(pos, nil, player_name)
			end
		end
		return travelnet.on_receive_fields(nil, formname, fields, player)
	end
end

-- most formspecs the travelnet uses are stored in the travelnet node itself,
-- but some may require some "back"-button functionality (i.e. help page,
-- move up/down etc.)
minetest.register_on_player_receive_fields(travelnet.form_input_handler)


function travelnet.reset_formspec()
	minetest.log("warning",
		"[travelnet] the travelnet.reset_formspec method is deprecated. "..
		"Run meta:set_string('station_network', '') to reset the travelnet.")
end


function travelnet.edit_formspec(pos, meta, player_name)
	if not pos or not meta or not player_name then
		return
	end

	local node = minetest.get_node_or_nil(pos)
	if not node then return end
	if travelnet.is_elevator(node.name) then
		return travelnet.edit_formspec_elevator(pos, meta, player_name)
	end

	local owner = meta:get_string("owner")
	local station_name = meta:get_string("station_name")
	local station_network = meta:get_string("station_network")

	-- request changed data
	local formspec = travelnet.formspecs.edit_travelnet({
		owner_name = owner,
		station_network = station_network,
		station_name = station_name
	})

	-- show the formspec manually
	travelnet.show_formspec(player_name, formspec)
end


function travelnet.edit_formspec_elevator(pos, meta, player_name)
	if not pos or not meta or not player_name then
		return
	end

	local station_name = meta:get_string("station_name")

	-- request changed data
	local formspec = travelnet.formspecs.edit_elevator({ station_name = station_name })

	-- show the formspec manually
	travelnet.show_formspec(player_name, formspec)
end

function travelnet.show_formspec(player_name, formspec)
	if formspec then
		minetest.show_formspec(player_name, travelnet_form_name, formspec)
		return true
	else
		minetest.show_formspec(player_name, "", "")
		return false
	end
end

function travelnet.page_formspec(pos, player_name, page)
	local formspec = travelnet.primary_formspec(pos, player_name, nil, page)
	if formspec then
		travelnet.show_formspec(player_name, formspec)
		return
	end
end
