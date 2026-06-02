-- simple smoketests and node registration verifications

mtt.emerge_area({x=0,y=0,z=0}, {x=32,y=32,z=32})

mtt.validate_nodenames(minetest.get_modpath("travelnet") .. "/test/nodenames.txt")

mtt.check_recipes("travelnet")

local function contains_plain(haystack, needle)
    return haystack:find(needle, 1, true) ~= nil
end

mtt.register("formspec escapes station names", function(callback)
    local owner_name = "formspec_escape_test"
    local station_name = "test ;D"
    local escaped_station_name = minetest.formspec_escape(station_name)

    travelnet.set_travelnets(owner_name, {
        ["test net"] = {
            [station_name] = {
                pos = { x = 0, y = 0, z = 0 },
                timestamp = 1
            }
        }
    })

    local formspec = travelnet.formspecs.primary({
        owner_name = owner_name,
        station_network = "test net",
        station_name = station_name,
        is_elevator = false
    }, owner_name)

    assert(contains_plain(formspec, escaped_station_name))
    assert(not contains_plain(formspec, "label[4.900000,2.350000;" .. station_name .. "]"))

    travelnet.set_travelnets(owner_name, {
        ["test elevator"] = {
            ["ground"] = {
                pos = { x = 0, y = 0, z = 0 },
                timestamp = 1
            },
            [station_name] = {
                pos = { x = 0, y = 1, z = 0 },
                timestamp = 2
            }
        }
    })

    local elevator_formspec = travelnet.formspecs.primary({
        owner_name = owner_name,
        station_network = "test elevator",
        station_name = "ground",
        is_elevator = true
    }, owner_name)

    assert(contains_plain(elevator_formspec, escaped_station_name))
    assert(not contains_plain(elevator_formspec, "label[4.900000,2.350000;" .. station_name .. "]"))

    callback()
end)
