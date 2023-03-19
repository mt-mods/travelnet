local S = minetest.get_translator("travelnet")

minetest.register_on_mods_loaded(function()
	if not minetest.registered_privileges[travelnet.attach_priv] then
		minetest.register_privilege(travelnet.attach_priv, {
			description = S("allows to attach travelnet boxes to travelnets of other players"),
			give_to_singleplayer = false
		})
	end

	if not minetest.registered_privileges[travelnet.remove_priv] then
		minetest.register_privilege(travelnet.attach_priv, {
			description = S("allows to dig travelnet boxes which belog to nets of other players"),
			give_to_singleplayer = false
		})
	end
end)
