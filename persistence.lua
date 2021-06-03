local S = minetest.get_translator("travelnet")

local mod_data_path = minetest.get_worldpath().."/mod_travelnet.data"
local travelnet_data = {}

-- TODO: deprecate (use get/set_networks below)
-- TODO: check if "travelnet.save_data" is used in other mods (jumpdrive?)
local function save_data()
   local data = minetest.serialize(travelnet_data)

   local success = minetest.safe_file_write(mod_data_path, data)
   if not success then
      print(S("[Mod travelnet] Error: Savefile '@1' could not be written.", mod_data_path))
   end
end

-- loads all the travelnets
-- TODO: deprecate (use get/set_networks below)
function travelnet.restore_data()
   local file = io.open(mod_data_path, "r")
   if not file then
      print(S("[Mod travelnet] Error: Savefile '@1' not found.", mod_data_path))
      return
   end

   local data = file:read("*all")
   travelnet_data = minetest.deserialize(data)

   if not travelnet_data then
       local backup_file = mod_data_path..".bak"
       print(S("[Mod travelnet] Error: Savefile '@1' is damaged." .. " " ..
         "Saved the backup as '@2'.", mod_data_path, backup_file))

       minetest.safe_file_write( backup_file, data )
       travelnet_data = {}
   end
   file:close()
end

-- accessor function for player travelnet-data
-- TODO: load data on-demand
function travelnet.get_networks(owner_name)
   return travelnet_data[owner_name]
end

-- setter function for player travelnets
-- TODO: save on demand
function travelnet.set_networks(owner_name, networks)
   travelnet_data[owner_name] = networks
   save_data() --TODO: remove afterwards
end