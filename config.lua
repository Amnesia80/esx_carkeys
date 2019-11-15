Config                            = {}
Config.DrawDistance               = 100.0
Config.MarkerColor                = { r = 120, g = 120, b = 240 }
Config.Locale                     = 'fr'

Config.enableLimitKeys 			  = true -- False si on ne veut pas de limite de clé
Config.maxCreateKeys              = 5    -- si Config.enableLimitKeys = true 

Config.EnablePed				  = true -- False pour ne plus avoir de pop de NPC sur la zone
Config.Ped						  = 'g_m_y_ballaeast_01'
Config.PedData 					  = {
	["ballas"] = {	
		id 			= 1,
		VoiceName   = "GENERIC_HI_RANDOM", 
		Ambiance    ="AMMUCITY", 
		modelHash   ="g_m_y_ballaeast_01", 
		heading 	= 133.68167114,
		Pos 		= { x = 170.159591, y = -1799.635498, z = 29.315976, h = 320.89810180 }
	},
}

Config.Locksmiths = {
	["centre_ville"] = {
		Pos     = { x = 170.320526, y = -1799.37779, z = 28.315877 },
		Size    = { x = 1.5, y = 1.5, z = 1.0 },
		Type    = -1,
		PedDataKey = 'ballas',
		blip    = true
	},	
}
