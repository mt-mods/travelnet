
-- "basic" travelnet box in yellow
travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet",
	recipe = travelnet.travelnet_recipe,
	color = "^[multiply:#ffff00"
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_red",
	color = "^[multiply:#ff0000",
	dye = "red"
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_blue",
	color = "^[multiply:#0000ff",
	dye = "blue"
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_green",
	color = "^[multiply:#00ff00",
	dye = "green"
})

travelnet.register_travelnet_box({
	nodename = "travelnet:travelnet_black",
	color = "^[multiply:#000000",
	dye = "black",
	light_source = 0
})
