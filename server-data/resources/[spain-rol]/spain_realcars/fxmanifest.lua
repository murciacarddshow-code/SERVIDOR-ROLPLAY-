fx_version 'cerulean'
game 'gta5'

author 'Spain Rol v2.0 - Flota de Vehiculos Reales'
description 'Pack de Vehiculos Reales Oficiales (Audi, BMW, Mercedes-Benz, Porsche, Ferrari, Lamborghini, Nissan, Ford, Chevrolet, etc.)'
version '1.0.0'

files {
    'data/**/*.meta',
    'data/**/*.xml',
    'data/**/*.dat',
    'data/**/*.ytyp'
}

data_file 'HANDLING_FILE'               'data/**/handling*.meta'
data_file 'VEHICLE_LAYOUTS_FILE'       'data/**/vehiclelayouts*.meta'
data_file 'VEHICLE_METADATA_FILE'       'data/**/vehicles*.meta'
data_file 'CARCOLS_FILE'               'data/**/carcols*.meta'
data_file 'VEHICLE_VARIATION_FILE'     'data/**/carvariations*.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'data/**/*unlocks.meta'
data_file 'PTFXASSETINFO_FILE'         'data/**/ptfxassetinfo.meta'

client_scripts {
    'vehicle_names.lua'
}
