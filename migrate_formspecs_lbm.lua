
core.register_lbm({
    label = "Migrate travelnet formspecs from meta to rightclick/punch-only",
    name = "travelnet:migrate_formspecs",
    nodenames = {"group:travelnet"},
    action = function(pos)
        -- clear formspec meta-field
        core.get_meta(pos):set_string("formspec", "")
    end
})