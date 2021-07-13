
local default_travelnets = {
	-- "default" travelnet box in yellow
	{ nodename="travelnet:travelnet", color="#e0bb2d", dye="dye:yellow", recipe=travelnet.travelnet_recipe },
	{ nodename="travelnet:travelnet_red", color="#ce1a1a", dye="dye:red" },
	{ nodename="travelnet:travelnet_orange", color="#ff8800", dye="dye:orange" },
	{ nodename="travelnet:travelnet_blue", color="#0051c5", dye="dye:blue" },
	{ nodename="travelnet:travelnet_cyan", color="#00eeee", dye="dye:cyan" },
	{ nodename="travelnet:travelnet_green", color="#53c41c", dye="dye:green" },
	{ nodename="travelnet:travelnet_dark_green", color="#33a40c", dye="dye:dark_green" },
	{ nodename="travelnet:travelnet_violet", color="#ee82ee", dye="dye:violet" },
	{ nodename="travelnet:travelnet_pink", color="#ffc0cb", dye="dye:pink" },
	{ nodename="travelnet:travelnet_magenta", color="#ff0090", dye="dye:magenta" },
	{ nodename="travelnet:travelnet_brown", color="#964b00", dye="dye:brown" },
	{ nodename="travelnet:travelnet_grey", color="#4f4f4f", dye="dye:grey" },
	{ nodename="travelnet:travelnet_dark_grey", color="#2f2f2f", dye="dye:dark_grey" },
	{ nodename="travelnet:travelnet_black", color="#0f0f0f", dye="dye:black", light_source=0 },
	{ nodename="travelnet:travelnet_whie", color="#ffffff", dye="dye:white", light_source=minetest.LIGHT_MAX },
}

for _, cfg in ipairs(default_travelnets) do
	travelnet.register_travelnet_box(cfg)
end
