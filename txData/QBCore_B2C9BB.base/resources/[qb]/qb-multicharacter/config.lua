Config = {}
Config.Interior = vector3(-1037.86, -2737.95, 20.17)              -- Interior to load where characters are previewed (Aeropuerto LSIA)
Config.DefaultSpawn = vector4(-1037.86, -2737.95, 20.17, 327.42)         -- Default spawn coords at Airport terminal
Config.PedCoords = vector4(-1037.86, -2737.95, 20.17, 327.42)   -- Create preview ped at Airport terminal
Config.HiddenCoords = vector4(-1045.0, -2750.0, 15.0, 0.0) -- Hides your actual ped while you are in selection
Config.CamCoords = vector4(-1035.6, -2734.5, 20.6, 147.42)        -- Camera coordinates for character preview screen
Config.EnableDeleteButton = true                                      -- Define if the player can delete the character or not
Config.customNationality = false                                      -- Defines if Nationality input is custom of blocked to the list of Countries
Config.SkipSelection = true                                          -- Skip the spawn selection and spawns the player at the last location / airport

Config.DefaultNumberOfCharacters = 5                                  -- Define maximum amount of default characters (maximum 5 characters defined by default)
Config.PlayersNumberOfCharacters = {                                  -- Define maximum amount of player characters by rockstar license (you can find this license in your server's database in the player table)
    { license = 'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', numberOfChars = 2 },
}
