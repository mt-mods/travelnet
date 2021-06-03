local S = minetest.get_translator("travelnet")

-- minetest.chat_send_player is sometimes not so well visible
travelnet.show_message = function( pos, player_name, title, message )
	if( not( pos ) or not( player_name ) or not( message )) then
		return;
	end
	local formspec = "size[8,3]"..
		"label[3,0;"..minetest.formspec_escape( title or S("Error")).."]"..
		"textlist[0,0.5;8,1.5;;"..minetest.formspec_escape( message or "- nothing -")..";]"..
		"button_exit[3.5,2.5;1.0,0.5;back;"..S("Back").."]"..
		"button_exit[6.8,2.5;1.0,0.5;station_exit;"..S("Exit").."]"..
		"field[20,20;0.1,0.1;pos2str;Pos;".. minetest.pos_to_string( pos ).."]";
	minetest.show_formspec(player_name, "travelnet:show", formspec);
end

-- show the player the formspec he would see when right-clicking the node;
-- needs to be simulated this way as calling on_rightclick would not do
travelnet.show_current_formspec = function( pos, meta, player_name )
	if( not( pos ) or not( meta ) or not( player_name )) then
		return;
	end
	-- we need to supply the position of the travelnet box
	local formspec = meta:get_string("formspec")..
		"field[20,20;0.1,0.1;pos2str;Pos;".. minetest.pos_to_string( pos ).."]";
	-- show the formspec manually
	minetest.show_formspec(player_name, "travelnet:show", formspec);
end

-- a player clicked on something in the formspec he was manually shown
-- (back from help page, moved travelnet up or down etc.)
travelnet.form_input_handler = function( player, formname, fields)
        if(formname == "travelnet:show" and fields and fields.pos2str) then
		local pos = minetest.string_to_pos( fields.pos2str );
		if not pos then
			return
		end

		-- back button leads back to the main menu
		if( fields.back and fields.back ~= "" ) then
			return travelnet.show_current_formspec( pos,
					minetest.get_meta( pos ), player:get_player_name());
		end
		return travelnet.on_receive_fields(pos, formname, fields, player);
        end
end

-- most formspecs the travelnet uses are stored in the travelnet node itself,
-- but some may require some "back"-button functionality (i.e. help page,
-- move up/down etc.)
minetest.register_on_player_receive_fields( travelnet.form_input_handler );

