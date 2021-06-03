
-- "default" travelnet box in yellow
travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet",
	recipe = travelnet.travelnet_recipe,
	color = "#e0bb2d",
	dye = "dye:yellow"
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_red",
	color = "#ce1a1a",
	dye = "dye:red"
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_blue",
	color = "#0051c5",
	dye = "dye:blue"
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_green",
	color = "#53c41c",
	dye = "dye:green"
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_black",
	color = "#0f0f0f",
	dye = "dye:black",
	light_source = 0
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_white",
	color = "#ffffff",
	dye = "dye:white",
	light_source = 14
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_fancy",
	tiles = {
		"travelnet_fancy_front.png",
		"travelnet_fancy_back.png",
		"travelnet_fancy_side.png",
		"travelnet_top.png",
		"travelnet_bottom.png",
	},
	inventory_image = "travelnet_inv_base.png", --TODO: proper inv
	light_source = 14
})
