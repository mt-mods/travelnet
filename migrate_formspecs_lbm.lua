
minetest.register_lbm({
    label = "Migrate travelnet formspecs from meta to rightclick/punch-only",
    name = "travelnet:migrate_formspecs",
    nodenames = {"group:travelnet"},
    action = function(pos)
        -- check formspec meta-field and clear it
        local meta = minetest.get_meta(pos)
        local legacy_formspec = meta:get_string("formspec")
        if not travelnet.is_falsey_string(legacy_formspec) then
            meta:set_string("formspec", "")
        end
    end
})