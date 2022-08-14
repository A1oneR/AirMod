//-------------------------------------------------------
// Autogenerated from 'auto_rifle.vmf'
//-------------------------------------------------------
AutoRifle <-
{
	//-------------------------------------------------------
	// Required Interface functions
	//-------------------------------------------------------
	function GetPrecacheList()
	{
		local precacheModels =
		[
			EntityGroup.SpawnTables.Admin_auto_rifle,
		]
		return precacheModels
	}

	//-------------------------------------------------------
	function GetSpawnList()
	{
		local spawnEnts =
		[
			EntityGroup.SpawnTables.Admin_auto_rifle_weaponfire,
			EntityGroup.SpawnTables.Admin_auto_rifle,
		]
		return spawnEnts
	}

	//-------------------------------------------------------
	function GetEntityGroup()
	{
		return EntityGroup
	}

	//-------------------------------------------------------
	// Table of entities that make up this group
	//-------------------------------------------------------
	EntityGroup =
	{
		SpawnTables =
		{
			Admin_auto_rifle = 
			{
				SpawnInfo =
				{
					classname = "prop_dynamic_override"
					angles = Vector( 0, 0, 0 )
					fademindist = "-1"
					fadescale = "1"
					glowbackfacemult = "1.0"
					glowcolor = "0 0 0"
					MaxAnimTime = "10"
					MinAnimTime = "5"
					model = "models/w_models/weapons/w_rifle_m16a2.mdl"
					renderamt = "255"
					rendercolor = "255 255 255"
					skin = "0"
					solid = "0" //6
					targetname = "Admin_auto_rifle"
					origin = Vector( -34.0002, 2.66125, -17 )
				}
			}
			Admin_auto_rifle_weaponfire = 
			{
				SpawnInfo =
				{
					classname = "env_weaponfire"
					angles = Vector( 0, 0, 0 )
					DamageMod = "1.0"
					TargetArc = "40"
					TargetRange = "3600"
					TargetTeam = "3"
					WeaponType = "1"
					StartDisabled = "0"
					targetname = "Admin_auto_rifle_weaponfire"
					origin = Vector( -3, 3, -13.0036 )
				}
			}
		} // SpawnTables
	} // EntityGroup
} // AutoRifle

RegisterEntityGroup( "AutoRifle", AutoRifle )
