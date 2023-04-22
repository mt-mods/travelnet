local S = minetest.get_translator("travelnet")

local mod_data_path = minetest.get_worldpath() .. "/mod_travelnet.data"

local storage = minetest.get_mod_storage()

-- called whenever a station is added or removed
function travelnet.save_data(playername)
	if playername then
		-- only save the players travelnet data
		storage:set_string(playername, minetest.write_json(travelnet.targets[playername]))
	else
		-- save _everything_
		for save_playername, player_targets in pairs(targets) do
			storage:set_string(save_playername, minetest.write_json(player_targets))
		end
	end
end

-- migrate file-based storage to mod-storage
local function migrate_file_storage()
	local file = io.open(mod_data_path, "r")
	if not file then
		return
	end

	-- load from file
	local data = file:read("*all")
	local old_targets
	if data:sub(1, 1) == "{" then
		minetest.log("info", S("[travelnet] migrating from json-file to mod-storage"))
		old_targets = minetest.parse_json(data)
	else
		minetest.log("info", S("[travelnet] migrating from serialize-file to mod-storage"))
		old_targets = minetest.deserialize(data)
	end

	for playername, player_targets in pairs(old_targets) do
		storage:set_string(playername, minetest.write_json(player_targets))
	end

	-- rename old file
	os.rename(mod_data_path, mod_data_path .. ".bak")
end

-- migrate old data as soon as possible
migrate_file_storage()

-- returns the player's travelnets
function travelnet.get_travelnets(playername, create)
	if not travelnet.targets[playername] and create then
		-- create a new entry
		travelnet.targets[playername] = {}
	end
	return travelnet.targets[playername]
end

-- saves the player's modified travelnets
function travelnet.set_travelnets(playername, travelnets)
	travelnet.targets[playername] = travelnets
	travelnet.save_data(playername)
end