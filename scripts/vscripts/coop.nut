//-----------------------------------------------------------------------------------------------------------------------------
// SETTINGS loaded at the start of the game
//-----------------------------------------------------------------------------------------------------------------------------
DirectorOptions <-
{
	ActiveChallenge 				= 1
	cm_AggressiveSpecials 			= true
	cm_ShouldHurry 					= 1
	ShouldAllowSpecialsWithTank 	= 1
	ShouldAllowMobsWithTank 		= 0
	cm_SpecialRespawnInterval 		= 1 //Time for an SI spawn slot to become available
	SpecialInitialSpawnDelayMin 	= 0 //Time between spawns in any particular SI class
	SpecialInitialSpawnDelayMax 	= 0
	cm_SpecialSlotCountdownTime 	= 0
	PreferredSpecialDirection 		= 4
	cm_HeadshotOnly 				= 0

	RelaxMaxInterval 				= 1 //Maximum time to spend in the RELAX tempo.
	RelaxMinInterval 				= 1 //Minimum time to spend in the RELAX tempo.


	DominatorLimit 			= 4
	cm_BaseSpecialLimit 	= 8
	cm_MaxSpecials 			= 8
	BoomerLimit 			= 1
	SpitterLimit 			= 1
	HunterLimit 			= 2
	JockeyLimit 			= 2
	ChargerLimit 			= 1
	SmokerLimit 			= 1
}

MapData <-{
	g_nSI 	= 6
	g_nTime = 2
}

function update_diff()
{
	local difficulty = Convars.GetStr("das_fakedifficulty");
	local timer = Convars.GetStr("ast_sitimer");
	switch (difficulty) {
		case "1":
			DirectorOptions.HunterLimit = 3
			DirectorOptions.SmokerLimit = 1
			DirectorOptions.BoomerLimit = 0
			DirectorOptions.SpitterLimit = 0
			DirectorOptions.JockeyLimit = 3
			DirectorOptions.ChargerLimit = 1
			DirectorOptions.PreferredSpecialDirection = 4
			//MapData.g_nSI = 3
			//MapData.g_nTime = 3
			switch (timer) {
				case "0":
					MapData.g_nTime = 6
					MapData.g_nSI = 1
					break;
				case "1":
					MapData.g_nTime = 3
					MapData.g_nSI = 5
					break;
				case "2":
					MapData.g_nTime = 2
					MapData.g_nSI = 5
					break;
				case "3":
					MapData.g_nTime = 0
					MapData.g_nSI = 5
					break;
				default:
					MapData.g_nTime = 3
					MapData.g_nSI = 5
					break;
			}
			break;
		case "2":
			DirectorOptions.HunterLimit = 3
			DirectorOptions.SmokerLimit = 1
			DirectorOptions.BoomerLimit = 1
			DirectorOptions.SpitterLimit = 1
			DirectorOptions.JockeyLimit = 3
			DirectorOptions.ChargerLimit = 1
			DirectorOptions.PreferredSpecialDirection = 4
			//MapData.g_nSI = 4
			//MapData.g_nTime = 6
			switch (timer) {
				case "0":
					MapData.g_nTime = 4
					MapData.g_nSI = 6
					break;
				case "1":
					MapData.g_nTime = 2
					MapData.g_nSI = 6
					break;
				case "2":
					MapData.g_nTime = 1
					MapData.g_nSI = 6
					break;
				case "3":
					MapData.g_nTime = 0
					MapData.g_nSI = 6
					break;
				default:
					MapData.g_nTime = 2
					MapData.g_nSI = 6
					break;
			}
			break;
		case "3":
			DirectorOptions.HunterLimit = 5
			DirectorOptions.SmokerLimit = 1
			DirectorOptions.BoomerLimit = 1
			DirectorOptions.SpitterLimit = 1
			DirectorOptions.JockeyLimit = 3
			DirectorOptions.ChargerLimit = 2
			DirectorOptions.PreferredSpecialDirection = 1
			MapData.g_nSI = 7
			//MapData.g_nTime = 22
			switch (timer) {
				case "0":
					MapData.g_nTime = 14
					break;
				case "1":
					MapData.g_nTime = 12
					break;
				case "2":
					MapData.g_nTime = 6
					break;
				case "3":
					MapData.g_nTime = 0
					break;
				default:
					MapData.g_nTime = 12
					break;
			}
			break;
		case "4":
			DirectorOptions.HunterLimit = 4
			DirectorOptions.SpitterLimit = 1
			DirectorOptions.SmokerLimit = 4
			DirectorOptions.BoomerLimit = 1
			DirectorOptions.JockeyLimit = 4
			DirectorOptions.ChargerLimit = 4
			DirectorOptions.PreferredSpecialDirection = 1
			MapData.g_nSI = 8
			//MapData.g_nTime = 17
			switch (timer) {
				case "0":
					MapData.g_nTime = 14
					break;
				case "1":
					MapData.g_nTime = 12
					break;
				case "2":
					MapData.g_nTime = 6
					break;
				case "3":
					MapData.g_nTime = 0
					break;
				default:
					MapData.g_nTime = 12
					break;
			}
			break;
		default:
			DirectorOptions.HunterLimit = 3
			DirectorOptions.SmokerLimit = 1
			DirectorOptions.BoomerLimit = 0
			DirectorOptions.SpitterLimit = 0
			DirectorOptions.JockeyLimit = 3
			DirectorOptions.ChargerLimit = 1
			MapData.g_nSI = 4
			MapData.g_nTime = 4
			break;
	}
	DirectorOptions.cm_BaseSpecialLimit 					= MapData.g_nSI
	DirectorOptions.cm_MaxSpecials 							= MapData.g_nSI
	DirectorOptions.DominatorLimit 							= MapData.g_nSI
	DirectorOptions.cm_SpecialRespawnInterval 		= MapData.g_nTime
	DirectorOptions.cm_SpecialSlotCountdownTime 	= MapData.g_nTime
}
update_diff();
g_ModeScript.update_diff();
