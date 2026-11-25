local S = core.get_translator("travelnet")
local F = core.formspec_escape

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
			size[10,4.2]
			label[0.4,0.5;%s]
			box[0.3,0.9;9.4,2.0;#00000040]
			textarea[0.5,1.1;9.0,1.6;;%s;]
			button[2.8,3.2;2.0,0.8;back;%s]
			button[5.2,3.2;2.0,0.8;station_exit;%s]
		]]):format(
			F(options.title or S("Error")),
			F(options.message or "- nothing -"),
			S("Back"),
			S("Exit")
		)
end

function travelnet.formspecs.edit_travelnet(options)
	if not options then options = {} end

	return ([[
		formspec_version[6]
		size[12,9.4]
		label[0.5,0.8;%s]
		style[station_dig;bgcolor=#c01c28;textcolor=#ffffff]
		button[9.2,0.4;2.3,0.8;station_dig;%s]

		box[0.5,1.5;11,2.0;#00000040]
		label[0.7,1.8;%s]
		field[0.7,2.1;10.6,0.8;station_name;;%s]
		field_close_on_enter[station_name;false]
		label[0.7,3.2;%s]

		box[0.5,3.7;11,2.0;#00000040]
		label[0.7,4.0;%s]
		field[0.7,4.3;10.6,0.8;station_network;;%s]
		field_close_on_enter[station_network;false]
		label[0.7,5.4;%s]

		box[0.5,5.9;11,2.0;#00000040]
		label[0.7,6.2;%s]
		field[0.7,6.5;10.6,0.8;owner_name;;%s]
		field_close_on_enter[owner_name;false]
		label[0.7,7.6;%s]

		button[3.0,8.3;2.8,0.8;station_set;%s]
		button[6.2,8.3;2.8,0.8;station_exit;%s]
	]]):format(
		S("Configure this travelnet station"),
		S("Delete"),
		S("Name of this station:"),
		F(options.station_name or ""),
		S("Example: \"my house\", \"mine\", \"shop\"..."),
		S("Assign to network:"),
		F(
			travelnet.is_falsey_string(options.station_network)
				and travelnet.default_network
				or options.station_network
		),
		S("If unsure, use \"@1\".", travelnet.default_network),
		S("Owned by:"),
		F(options.owner_name or ""),
		S("Leave this as is unless you know what you're doing."),
		S("Save"),
		S("Exit")
	)
end

function travelnet.formspecs.edit_elevator(options)
	if not options then options = {} end
	return ([[
		formspec_version[6]
		size[12,4.8]
		label[0.5,0.8;%s]
		style[station_dig;bgcolor=#c01c28;textcolor=#ffffff]
		button[9.2,0.4;2.3,0.8;station_dig;%s]

		box[0.5,1.5;11,1.6;#00000040]
		label[0.7,1.8;%s]
		field[0.7,2.1;10.6,0.8;station_name;;%s]
		field_close_on_enter[station_name;false]

		button[3.0,3.6;2.8,0.8;station_set;%s]
		button[6.2,3.6;2.8,0.8;station_exit;%s]
	]]):format(
		S("Configure this elevator station"),
		S("Delete"),
		S("Name of this station:"),
		F(options.station_name or ""),
		S("Save"),
		S("Exit")
	)
end

-- layout of the station list (formspec_version 6 coordinates)
local list_x = 0.3        -- left edge of the first column
local list_y = 3.2        -- top of the first row
local column_width = 4.85 -- distance between columns
local button_width = 4.65
local row_height = 0.9    -- distance between rows
local button_height = 0.8
local nr_width = 0.9      -- width of the elevator floor-number button

function travelnet.formspecs.primary(options, player_name)
	if not options then options = {} end

	-- collect all station names in a table
	local stations = travelnet.get_ordered_stations(options.owner_name, options.station_network, options.is_elevator)
	local paging = (
			travelnet.MAX_STATIONS_PER_NETWORK == 0
			or travelnet.MAX_STATIONS_PER_NETWORK > 24
		) and (#stations > 24)

	local column_size = paging and 7 or 8
	local list_bottom = list_y + column_size * row_height
	local height = paging and (list_bottom + 1.3) or (list_bottom + 0.2)

	-- add name of station + network + owner + exit-button
	local formspec = ([[
			formspec_version[6]
			size[15,%s]
			box[0.3,0.3;14.4,1.9;#00000040]
			label[0.6,0.65;%s]
			label[0.6,1.1;%s]
			label[4.6,1.1;%s]
			label[0.6,1.5;%s]
			label[4.6,1.5;%s]
			label[0.6,1.9;%s]
			label[4.6,1.9;%s]
			label[0.4,2.75;%s]
			button[12.7,0.45;1.8,0.7;station_exit;%s]
		]]):format(
			tostring(options.height or height),
			options.is_elevator and S("Elevator:") or S("Travelnet-Box:"),
			S("Name of this station:"),
			F(options.station_name or "?"),
			S("Assigned to Network:"),
			F(options.station_network or "?"),
			S("Owned by:"),
			F(options.owner_name or "?"),
			S("Click on target to travel there:"),
			S("Exit")
		)

	local column = 0
	local row = 0

	-- if there are only 8 stations (plus this one), center them in the formspec
	if #stations < 10 then
		column = 1
	end

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

	local network
	if options.is_elevator then
		local travelnets = travelnet.get_travelnets(options.owner_name)
		network = travelnets[options.station_network]
		if not network then
			travelnet.log("action", "creating new elevator network for '" .. options.owner_name ..
				"' and station '" .. options.station_network .. "'")
			network = {}
			travelnets[options.station_network] = network
			travelnet.set_travelnets(options.owner_name, travelnets)
		end
	end

	formspec = formspec .. "style[open_door;font=bold]"

	for n=((page_number-1)*page_size)+1,(page_number*page_size) do
		local k = stations[n]
		if not k then break end

		-- new column
		if row == column_size then
			column = column + 1
			row = 0
		end

		local x = list_x + column * column_width
		local y = list_y + row * row_height
		local nr = network and network[k] and network[k].nr

		if k == options.station_name then
			-- the current station: toggles the elevator door (if any) in front of it
			local label = nr and (tostring(nr) .. "   " .. k) or k
			formspec = formspec .. ("button[%f,%f;%f,%f;open_door;%s]")
				:format(x, y, button_width, button_height, F(label))
		elseif nr then
			-- elevator: floor number and station name, both clickable and on the same line
			formspec = formspec .. ("button[%f,%f;%f,%f;target;%s]button[%f,%f;%f,%f;target_station;%s]")
				:format(
					x, y, nr_width, button_height, F(tostring(nr)),
					x + nr_width + 0.1, y, button_width - nr_width - 0.1, button_height, F(k)
				)
		else
			formspec = formspec .. ("button[%f,%f;%f,%f;target;%s]")
				:format(x, y, button_width, button_height, F(k))
		end

		row = row + 1
	end

	if player_name == options.owner_name
	or core.get_player_privs(player_name)[travelnet.attach_priv]
	then
		formspec = formspec .. ([[
				label[9.0,2.75;%s]
				button[10.9,2.45;1.7,0.6;move_up;%s]
				button[12.8,2.45;1.7,0.6;move_down;%s]
			]]):format(
				S("Position:"),
				S("Up"),
				S("Down")
			)
	end

	if player_name == options.owner_name
	or core.get_player_privs(player_name)[travelnet.remove_priv]
	or travelnet.allow_dig(player_name, options.owner_name, options.station_network, player_formspec_data[player_name].pos)
	then
		formspec = formspec .. ([[
				button[12.7,1.35;1.8,0.7;station_edit;%s]
			]]):format(
				S("Edit")
			)
	end

	if paging then
		local py = list_bottom + 0.3
		if page_number > 2 then
			formspec = formspec .. ("button[0.3,%f;2,0.8;first_page;%s]"):format(py, F(S("<<")))
		end
		if page_number > 1 then
			formspec = formspec .. ("button[2.5,%f;2,0.8;prev_page;%s]"):format(py, F(S("<")))
		end
		formspec = formspec
			.. ("label[6.7,%f;%s]"):format(py + 0.4, F(S("Page @1/@2", page_number, pages)))
			.. ("field[20,20;0.1,0.1;page_number;Page;%i]"):format(page_number)
		if page_number < pages then
			formspec = formspec .. ("button[10.5,%f;2,0.8;next_page;%s]"):format(py, F(S(">")))
		end
		if page_number < pages-1 then
			formspec = formspec .. ("button[12.7,%f;2,0.8;last_page;%s]"):format(py, F(S(">>")))
		end
	end

	return formspec
end
