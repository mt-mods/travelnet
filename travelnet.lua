
local yellow, red, orange, blue, cyan, green, dark_green, violet, pink, magenta, brown, grey, dark_grey, black, white = ""

if core.get_modpath("dye") then
   yellow = "dye:yellow"
   red = "dye:red"
   orange = "dye:orange"
   blue = "dye:blue"
   cyan = "dye:cyan"
   green = "dye:green"
   dark_green = "dye:dark_green"
   violet = "dye:violet"
   pink = "dye:pink"
   magenta = "dye:magenta"
   brown = "dye:brown"
   grey = "dye:grey"
   dark_grey = "dye:dark_grey"
   black = "dye:black"
   white = "dye:white"
end

if core.get_modpath("mcl_dye") then
   yellow = "mcl_dye:yellow"
   red = "mcl_dye:red"
   orange = "mcl_dye:orange"
   blue = "mcl_dye:blue"
   cyan = "mcl_dye:cyan"
   green = "mcl_dye:green"
   dark_green = "mcl_dye:dark_green"
   violet = "mcl_dye:violet"
   pink = "mcl_dye:pink"
   magenta = "mcl_dye:magenta"
   brown = "mcl_dye:brown"
   grey = "mcl_dye:grey"
   dark_grey = "mcl_dye:dark_grey"
   black = "mcl_dye:black"
   white = "mcl_dye:white"
end


local default_travelnets = {
	-- "default" travelnet box in yellow
	{ nodename="travelnet:travelnet", color="#e0bb2d", dye=yellow, recipe=travelnet.travelnet_recipe },
	{ nodename="travelnet:travelnet_red", color="#ce1a1a", dye=red },
	{ nodename="travelnet:travelnet_orange", color="#e2621b", dye=orange },
	{ nodename="travelnet:travelnet_blue", color="#0051c5", dye=blue },
	{ nodename="travelnet:travelnet_cyan", color="#00a6ae", dye=cyan },
	{ nodename="travelnet:travelnet_green", color="#53c41c", dye=green },
	{ nodename="travelnet:travelnet_dark_green", color="#2c7f00", dye=dark_green },
	{ nodename="travelnet:travelnet_violet", color="#660bb3", dye=violet },
	{ nodename="travelnet:travelnet_pink", color="#ff9494", dye=pink },
	{ nodename="travelnet:travelnet_magenta", color="#d10377", dye=magenta },
	{ nodename="travelnet:travelnet_brown", color="#572c00", dye=brown },
	{ nodename="travelnet:travelnet_grey", color="#a2a2a2", dye=grey },
	{ nodename="travelnet:travelnet_dark_grey", color="#3d3d3d", dye=dark_grey },
	{ nodename="travelnet:travelnet_black", color="#0f0f0f", dye=black, light_source=0 },
	{ nodename="travelnet:travelnet_white", color="#ffffff", dye=white, light_source=minetest.LIGHT_MAX },
}

for _, cfg in ipairs(default_travelnets) do
	travelnet.register_travelnet_box(cfg)
end
