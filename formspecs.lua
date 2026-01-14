local S = minetest.get_translator("travelnet")

local player_formspec_data = travelnet.player_formspec_data

travelnet.formspecs = {}

function travelnet.formspecs.current(options, player_name)
	local current_form = player_formspec_data[player_name] and player_formspec_data[player_name].current_form
	if current_form then
		return current_form(options, player_name)
	end
	if travelnet.is_falsey_string(options.station_network) then
		-- request initinal data
		if options.is_elevator then
			return travelnet.formspecs.edit_elevator(options, player_name)
		else
			return travelnet.formspecs.edit_travelnet(options, player_name)
		end
	else
		return travelnet.formspecs.primary(options, player_name)
	end
end

function travelnet.formspecs.error_message(options)
	if not options then options = {} end
	return ([[
			formspec_version[6]
			size[10,4]
			bgcolor[#1e1e2ecc]
			box[0.3,0.2;9.4,0.8;#c01c28]
			label[4.2,0.6;%s]
			box[0.3,1.2;9.4,1.8;#3d3846]
			textarea[0.5,1.4;9.0,1.4;;%s;]
			style[back;bgcolor=#1a5fb4;textcolor=#ffffff]
			style[station_exit;bgcolor=#77767b;textcolor=#ffffff]
			button[3.0,3.2;2.0,0.6;back;%s]
			button[5.2,3.2;2.0,0.6;station_exit;%s]
		]]):format(
			minetest.formspec_escape(options.title or S("Error")),
			minetest.formspec_escape(options.message or "- nothing -"),
			S("Back"),
			S("Back")
		)
end

function travelnet.formspecs.edit_travelnet(options)
	if not options then options = {} end

	return ([[
		formspec_version[6]
		size[12,10]
		bgcolor[#1e1e2ecc]
		box[0.5,0.3;11,1.2;#1a5fb4]
		label[3.5,0.9;%s]
		style[station_dig;bgcolor=#c01c28;textcolor=#ffffff]
		button[9.2,0.4;2.3,1.0;station_dig;%s]

		box[0.5,1.7;11,2.0;#3d3846]
		label[0.7,1.9;%s]
		field[0.7,2.4;10.6,0.8;station_name;;%s]
		field_close_on_enter[station_name;false]
		label[0.7,3.4;%s]

		box[0.5,3.9;11,2.0;#3d3846]
		label[0.7,4.1;%s]
		field[0.7,4.6;10.6,0.8;station_network;;%s]
		field_close_on_enter[station_network;false]
		label[0.7,5.6;%s]

		box[0.5,6.1;11,2.0;#3d3846]
		label[0.7,6.3;%s]
		field[0.7,6.8;10.6,0.8;owner_name;;%s]
		field_close_on_enter[owner_name;false]
		label[0.7,7.8;%s]

		style[station_set;bgcolor=#26a269;textcolor=#ffffff]
		style[station_exit;bgcolor=#77767b;textcolor=#ffffff]
		button[3.0,8.5;2.8,1.2;station_set;%s]
		button[6.0,8.5;2.8,1.2;station_exit;%s]
	]]):format(
		S("Configure this travelnet station"),
		S("Delete"),
		S("Name of this station:"),
		minetest.formspec_escape(options.station_name or ""),
		S("Example: \"my house\", \"mine\", \"shop\"..."),
		S("Assign to network:"),
		minetest.formspec_escape(
			travelnet.is_falsey_string(options.station_network)
				and travelnet.default_network
				or options.station_network
		),
		S("If unsure, use \"@1\".", travelnet.default_network),
		S("Owned by:"),
		minetest.formspec_escape(options.owner_name or ""),
		S("Leave this as is unless you know what you're doing."),
		S("Save"),
		S("Back")
	)
end

function travelnet.formspecs.edit_elevator(options)
	if not options then options = {} end
	return ([[
		formspec_version[6]
		size[12,5.2]
		bgcolor[#1e1e2ecc]
		box[0.5,0.3;11,1.2;#1a5fb4]
		label[3.8,0.9;%s]
		style[station_dig;bgcolor=#c01c28;textcolor=#ffffff]
		button[9.2,0.4;2.3,1.0;station_dig;%s]

		box[0.5,1.7;11,1.6;#3d3846]
		label[0.7,1.9;%s]
		field[0.7,2.4;10.6,0.7;station_name;;%s]
		field_close_on_enter[station_name;false]

		style[station_set;bgcolor=#26a269;textcolor=#ffffff]
		style[station_exit;bgcolor=#77767b;textcolor=#ffffff]
		button[3.0,3.8;2.8,1.2;station_set;%s]
		button[6.0,3.8;2.8,1.2;station_exit;%s]
	]]):format(
		S("Configure this elevator station"),
		S("Delete"),
		S("Name of this station:"),
		minetest.formspec_escape(options.station_name or ""),
		S("Save"),
		S("Back")
	)
end

function travelnet.formspecs.primary(options, player_name)
	if not options then options = {} end
	-- add name of station + network + owner + update-button
	local formspec = ([[
			formspec_version[6]
			size[12,%s]
			bgcolor[#1e1e2ecc]
			box[0.2,0.2;11.6,1.8;#3d3846]
			style_type[label;textcolor=#ffffff]
			label[4.5,0.4;%s]
			label[0.4,0.7;%s]
			label[5.0,0.7;%s]
			label[0.4,1.0;%s]
			label[5.0,1.0;%s]
			label[0.4,1.3;%s]
			label[5.0,1.3;%s]
			label[4.0,1.7;%s]
			style[station_exit;bgcolor=#77767b;textcolor=#ffffff]
			button[10.5,0.3;1.3,0.6;station_exit;%s]
			style_type[button;bgcolor=#1a5fb4;textcolor=#ffffff]
		]]):format(
			tostring(options.height or 10),
			options.is_elevator and S("Elevator:") or S("Travelnet-Box:"),
			S("Name of this station:"),
			minetest.formspec_escape(options.station_name or "?"),
			S("Assigned to Network:"),
			minetest.formspec_escape(options.station_network or "?"),
			S("Owned by:"),
			minetest.formspec_escape(options.owner_name or "?"),
			S("Click on target to travel there:"),
			S("Back")
		)

	local x = 0
	local y = 0
	local i = 0

	-- collect all station names in a table
	local stations = travelnet.get_ordered_stations(options.owner_name, options.station_network, options.is_elevator)
	-- if there are only 8 stations (plus this one), center them in the formspec
	if #stations < 10 then
		x = 4
	end
	local paging = (
			travelnet.MAX_STATIONS_PER_NETWORK == 0
			or travelnet.MAX_STATIONS_PER_NETWORK > 24
		) and (#stations > 24)

	local column_size = paging and 7 or 8
	local page_size = column_size*3
	local pages = math.ceil(#stations/page_size)
	local page_number = options.page_number
	if not page_number then
		page_number = 1
		if paging then
			for number,k in ipairs(stations) do
				if k == options.station_name then
					page_number = math.ceil(number/page_size)
					break
				end
			end
		end
	end

	for n=((page_number-1)*page_size)+1,(page_number*page_size) do
		local k = stations[n]
		if not k then break end
		i = i+1

		-- new column
		if y == column_size then
			x = x + 4
			y = 0
		end

		-- check if there is an elevator door in front that needs to be opened
		if k == options.station_name then
			formspec = formspec ..
				("style[open_door;bgcolor=#26a269;textcolor=#ffffff]button[%f,%f;4,0.5;open_door;%s]")
						:format(x, y + 2.5, minetest.formspec_escape(k) .. " *")
		elseif options.is_elevator then
			local travelnets = travelnet.get_travelnets(options.owner_name)
			local network = travelnets[options.station_network]
			if not network then
				travelnet.log("action", "creating new elevator network for '" .. options.owner_name ..
					"' and station '" .. options.station_network .. "'")
				travelnets[options.station_network] = {}
				travelnet.set_travelnets(options.owner_name, travelnets)
			end

			formspec = formspec ..
				("button[%f,%f;1,0.5;target;%s]label[%f,%f;%s]")
						:format(x, y + 2.5, minetest.formspec_escape(tostring(network[k].nr)), x + 0.9, y + 2.35, k)
		else
			formspec = formspec ..
				("button[%f,%f;4,0.5;target;%s]")
						:format(x, y + 2.5, minetest.formspec_escape(k))
		end

		y = y+1
	end

	if player_name == options.owner_name
	or minetest.get_player_privs(player_name)[travelnet.attach_priv]
	then
		formspec = formspec .. ([[
				label[7.5,1.7;%s]
				style[move_up;bgcolor=#26a269;textcolor=#ffffff]
				style[move_down;bgcolor=#e66100;textcolor=#ffffff]
				button[9.2,1.55;1.2,0.5;move_up;%s]
				button[10.5,1.55;1.2,0.5;move_down;%s]
			]]):format(
				S("Position:"),
				S("Up"),
				S("Down")
			)
	end

	if player_name == options.owner_name
	or minetest.get_player_privs(player_name)[travelnet.remove_priv]
	or travelnet.allow_dig(player_name, options.owner_name, options.station_network, player_formspec_data[player_name].pos)
	then
		formspec = formspec .. ([[
				style[station_edit;bgcolor=#9141ac;textcolor=#ffffff]
				button[9.8,0.95;2.0,0.6;station_edit;%s]
			]]):format(
				S("Edit")
			)
	end

	if paging then
		if page_number > 2 then
			formspec = formspec .. ("button[0,9.2;2,1;first_page;%s]"):format(minetest.formspec_escape(S("<<")))
		end
		if page_number > 1 then
			formspec = formspec .. ("button[2,9.2;2,1;prev_page;%s]"):format(minetest.formspec_escape(S("<")))
		end
		formspec = formspec
			.. ("label[5,9.4;%s]"):format(minetest.formspec_escape(S("Page @1/@2", page_number, pages)))
			.. ("field[20,20;0.1,0.1;page_number;Page;%i]"):format(page_number)
		if page_number < pages then
			formspec = formspec .. ("button[8,9.2;2,1;next_page;%s]"):format(minetest.formspec_escape(S(">")))
		end
		if page_number < pages-1 then
			formspec = formspec .. ("button[10,9.2;2,1;last_page;%s]"):format(minetest.formspec_escape(S(">>")))
		end
	end

	return formspec
end
