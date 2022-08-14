//-----------------------------------------------------
Msg("Activating Admin System\n");

/**
 * Admin System by Rayman1103
 */

// Include the VScript Library
IncludeScript("Admin_System/VSLib");

Convars.SetValue( "precache_all_survivors", "1" );

// The admin list
::AdminSystem <-
{
	Admins = {}
	BannedPlayers = {}
	HostPlayer = {}
	SoundName = {}
	AdminsOnly = true
	DisplayMsgs = true
	EnableIdleKick = false
	IdleKickTime = 60
	AdminPassword = ""
	Vars =
	{
		IsBashDisabled = {}
		IsBashLimited = {}
		IsFreezeEnabled = {}
		IsNoclipEnabled = {}
		IsFlyingEnabled = {}
		IsGodEnabled = {}
		IsInfiniteAmmoEnabled = {}
		IsUnlimitedAmmoEnabled = {}
		IsInfiniteExplosiveAmmoEnabled = {}
		IsInfiniteIncendiaryAmmoEnabled = {}
		IsInfiniteLaserSightsEnabled = {}
		EnabledGodInfected = false
		EnabledGodSI = false
		DirectorDisabled = false
		AllowAdminsOnly = true
	}
	ZombieModels =
	[
		"common_female_tankTop_jeans"
		"common_female_tankTop_jeans_rain"
		"common_female_tshirt_skirt"
		"common_female_tshirt_skirt_swamp"
		"common_female_formal"
		"common_male_dressShirt_jeans"
		"common_male_polo_jeans"
		"common_male_tankTop_jeans"
		"common_male_tankTop_jeans_rain"
		"common_male_tankTop_jeans_swamp"
		"common_male_tankTop_overalls"
		"common_male_tankTop_overalls_rain"
		"common_male_tankTop_overalls_swamp"
		"common_male_tshirt_cargos"
		"common_male_tshirt_cargos_swamp"
		"common_male_formal"
		"common_male_biker"
		"common_male_ceda"
		"common_male_mud"
		"common_male_roadcrew"
		"common_male_roadcrew_rain"
		"common_male_fallen_survivor"
		"common_male_riot"
		"common_male_clown"
		"common_male_jimmy"
		//"common_patient_male01_l4d2"
		"common_female_nurse01"
		"common_female_rural01"
		"common_female01"
		"common_male_baggagehandler_01"
		"common_male_pilot"
		"common_male_rural01"
		"common_male_suit"
		"common_male01"
		"common_military_male01"
		"common_patient_male01"
		"common_police_male01"
		"common_surgeon_male01"
		"common_tsaagent_male01"
		"common_worker_male01"
		//"common_female_tankTop_jeans_swamp"
		"common_male_parachutist"
		"common_male02"
		"common_female01_suit"
		"common_female_baggagehandler_01"
		"common_male_baggagehandler_02"
		"common_male_mud_l4d1"
		"common_male_ceda_l4d1"
		"common_male_roadcrew_l4d1"
		"common_male_fallen_survivor_l4d1"
		"common_male_riot_l4d1"
	]
}

::AdminSystem.LoadAdmins <- function ()
{
	local fileContents = FileToString("admin system/admins.txt");
	local admins = split(fileContents, "\r\n");
	local searchForHost = true;
	
	foreach (admin in admins)
	{
		if ( admin.find("//") != null )
		{
			admin = Utils.StringReplace(admin, "//" + ".*", "");
			admin = rstrip(admin);
		}
		if ( admin.find("STEAM_0") != null )
			admin = Utils.StringReplace(admin, "STEAM_0", "STEAM_1");
		if ( admin != "" )
			::AdminSystem.Admins[admin] <- true;
		
		if ( searchForHost == true )
		{
			AdminSystem.HostPlayer[admin] <- true;
			searchForHost = false;
		}
	}
}

::AdminSystem.LoadBanned <- function ()
{
	local fileContents = FileToString("admin system/banned.txt");
	local banned = split(fileContents, "\r\n");
	
	foreach (ban in banned)
	{
		if ( ban.find("//") != null )
		{
			ban = Utils.StringReplace(ban, "//" + ".*", "");
			ban = rstrip(ban);
		}
		if ( ban.find("STEAM_0") != null )
			ban = Utils.StringReplace(ban, "STEAM_0", "STEAM_1");
		if ( ban != "" )
			::AdminSystem.BannedPlayers[ban] <- true;
	}
}

::AdminSystem.LoadCvars <- function ( file )
{
	local fileContents = FileToString("admin system/" + file);
	local cvars = split(fileContents, "\r\n");
	
	foreach (cvar in cvars)
	{
		if ( cvar.find("//") != null )
		{
			cvar = Utils.StringReplace(cvar, "//" + ".*", "");
			cvar = rstrip(cvar);
		}
		if ( cvar != "" )
		{
			local value = cvar.slice( cvar.find(" ") );
			value = Utils.StringReplace( value, " ", "" );
			value = Utils.StringReplace( value, "\"", "" );
			local command = Utils.StringReplace( cvar, value, "" );
			command = Utils.StringReplace( command, " ", "" );
			command = Utils.StringReplace( command, "\"", "" );
			
			if ( cvar.find("scripted_user_func") == null )
				Convars.SetValue( command, value );
		}
	}
}

::AdminSystem.LoadScriptedCvars <- function ( file )
{
	local fileContents = FileToString("admin system/" + file);
	local cvars = split(fileContents, "\r\n");
	
	foreach (cvar in cvars)
	{
		if ( cvar.find("//") != null )
		{
			cvar = Utils.StringReplace(cvar, "//" + ".*", "");
			cvar = rstrip(cvar);
		}
		if ( cvar != "" )
		{
			if ( cvar.find("scripted_user_func") != null )
				SendToServerConsole( cvar );
		}
	}
}

::AdminSystem.LoadSettings <- function ()
{
	local fileContents = FileToString("admin system/settings.txt");
	local settings = split(fileContents, "\r\n");
	
	foreach (setting in settings)
	{
		if ( setting.find("//") != null )
		{
			setting = Utils.StringReplace(setting, "//" + ".*", "");
			setting = rstrip(setting);
		}
		if ( setting != "" )
		{
			//setting = Utils.StringReplace(setting, "=", "<-");
			local compiledscript = compilestring("AdminSystem." + setting);
			compiledscript();
		}
	}
}

::AdminSystem.PrintClientMessage <- function ( player, str )
{
	local function PrintMessageDelay( args )
	{
		if ( args.player )
			args.player.Print( "Admin System: " + "\x01" + args.str, 5 );
		else
			ClientPrint( null, 5, "Admin System: " + "\x01" + args.str );
	}
	
	Timers.AddTimer(0.1, false, PrintMessageDelay, { player = player, str = str });
}

::AdminSystem.IsPrivileged <- function ( player )
{
	if ( Director.IsSinglePlayerGame() || player.IsServerHost() )
		return true;
	
	local steamid = player.GetSteamID();
	if (!steamid) return false;

	if ( !AdminSystem.AdminsOnly )
		AdminSystem.Vars.AllowAdminsOnly = false;
	
	if ( !(steamid in ::AdminSystem.Admins) && AdminSystem.Vars.AllowAdminsOnly )
	{
		return false;
	}

	return true;
}

::AdminSystem.IsAdmin <- function ( player )
{
	if ( Director.IsSinglePlayerGame() || player.IsServerHost() )
		return true;
	
	local steamid = player.GetSteamID();
	if (!steamid) return false;

	if ( !(steamid in ::AdminSystem.Admins) )
	{
		AdminSystem.PrintClientMessage( player, "Only Admins have access to this command." );
		return false;
	}

	return true;
}

::AdminSystem.GetID <- function ( player )
{
	if (!player || !("IsPlayerEntityValid" in player))
		return;
	else if (!player.IsPlayerEntityValid())
		return;
	
	local ID = player.GetSteamID();
	if ( ID == "BOT" )
	{
		if ( player.IsSurvivor() )
			ID = player.GetCharacterName();
	}
	
	return ID;
}

::AdminSystem.KickPlayer <- function( player )
{
	local steamid = player.GetSteamID();

	Timers.RemoveTimerByName( "KickTimer" + AdminSystem.GetID( player ).tostring() );
	if ( AdminSystem.DisplayMsgs )
		AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has been kicked for being idle too long.");
	SendToServerConsole( "kickid " + steamid + " You've been kicked for being idle too long" );
}

::AdminSystem.CalculateFly <- function ( player )
{
	if ( !player.IsEntityValid() )
		return false;
	
	if ( player.IsPressingJump() )
	{
		local vel = player.GetVelocity();
		local maxSpeed = 400.0;
		local speed = 200.0;
		
		if ( (vel.z + speed) > maxSpeed )
			vel.z = maxSpeed;
		else
			vel.z += speed;
		
		player.SetVelocity(vel);
	}
}

function EasyLogic::OnShutdown::AdminSaveData( reason, nextmap )
{
	if ( reason > 0 && reason < 4 )
	{
		SaveTable( "admin_variable_data", ::AdminSystem.Vars );
	}
}

function Notifications::OnRoundStart::AdminLoadData()
{
	RestoreTable( "admin_variable_data", ::AdminSystem.Vars );
	
	if (::AdminSystem.Vars == null)
	{
		::AdminSystem.Vars <-
		{
			IsBashDisabled = {}
			IsBashLimited = {}
			IsNoclipEnabled = {}
			IsFlyingEnabled = {}
			IsGodEnabled = {}
			IsInfiniteAmmoEnabled = {}
			IsUnlimitedAmmoEnabled = {}
			IsInfiniteExplosiveAmmoEnabled = {}
			IsInfiniteIncendiaryAmmoEnabled = {}
			IsInfiniteLaserSightsEnabled = {}
			EnabledGodInfected = false
			EnabledGodSI = false
			DirectorDisabled = false
			AllowAdminsOnly = true
		}
	}
	else
	{
		if ( AdminSystem.Vars.DirectorDisabled )
			Utils.StopDirector();
	}
}

function Notifications::OnRoundStart::AdminLoadFiles()
{
	local adminList = FileToString("admin system/admins.txt");
	local banList = FileToString("admin system/banned.txt");
	local settingList = FileToString("admin system/settings.txt");
	
	if ( adminList != null )
	{
		printf("[Admins] Loading admin list...");
		AdminSystem.LoadAdmins();
	}
	if ( banList != null )
	{
		printf("[Banned] Loading ban list...");
		AdminSystem.LoadBanned();
	}
	if ( settingList != null )
	{
		printf("[Settings] Loading settings...");
		AdminSystem.LoadSettings();
	}
	else
	{
		settingList = "AdminsOnly = true\nDisplayMsgs = true\nEnableIdleKick = false\nIdleKickTime = 60\nAdminPassword = \"\"";
		StringToFile("admin system/settings.txt", settingList);
	}
	
	local cvarList = FileToString("admin system/cvars.txt");
	local baseCvarList = FileToString("admin system/" + Director.GetGameModeBase() + "_cvars.txt");
	local modeCvarList = FileToString("admin system/" + Director.GetGameMode() + "_cvars.txt");
	
	if ( modeCvarList != null )
	{
		printf("[Cvars] Loading %s convars...", Director.GetGameMode());
		AdminSystem.LoadCvars(Director.GetGameMode() + "_cvars.txt");
		AdminSystem.LoadScriptedCvars(Director.GetGameMode() + "_cvars.txt");
	}
	else
	{
		if ( baseCvarList != null )
		{
			printf("[Cvars] Loading %s convars...", Director.GetGameModeBase());
			AdminSystem.LoadCvars(Director.GetGameModeBase() + "_cvars.txt");
			AdminSystem.LoadScriptedCvars(Director.GetGameModeBase() + "_cvars.txt");
		}
		else
		{
			if ( cvarList != null )
			{
				printf("[Cvars] Loading convars...");
				AdminSystem.LoadCvars("cvars.txt");
				AdminSystem.LoadScriptedCvars("cvars.txt");
			}
		}
	}
}

function Notifications::OnPlayerJoined::AdminBanCheck( player, name, IPAddress, SteamID, params )
{
	if ( player )
	{
		local steamid = player.GetSteamID();
		
		if ( (steamid in ::AdminSystem.BannedPlayers) )
			SendToServerConsole( "kickid " + steamid + " You're banned from this server" );
	}
}

function Notifications::OnPlayerJoined::AdminCheck( player, name, IPAddress, SteamID, params )
{
	local adminList = FileToString("admin system/admins.txt");
	if ( adminList != null )
		return;
	
	if ( player )
	{
		if ( player.IsBot() || !player.IsServerHost() )
			return;
		
		local admins = FileToString("admin system/admins.txt");
		local steamid = player.GetSteamID();
		if ( steamid == "" || steamid == "BOT" )
			return;
		admins = steamid + " //" + player.GetName();
		StringToFile("admin system/admins.txt", admins);
		AdminSystem.LoadAdmins();
	}
}

function Notifications::OnWeaponFire::AdminGiveUpgradeAmmo( player, classname, params )
{
	local ID = AdminSystem.GetID( player );
	local PlayerInv = player.GetHeldItems();
	
	if (((ID in ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID])) || (ID in ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID]))
	{
		if ( "slot0" in PlayerInv )
		{
			local wep = PlayerInv["slot0"];
			if ( ( wep ) && ( wep.GetClassname() == classname ) )
			{
				if ( wep.GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded") > 0 )
					wep.SetNetProp( "m_nUpgradedPrimaryAmmoLoaded", wep.GetMaxClip() + 1 );
			}
		}
	}
	if ((ID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteAmmoEnabled[ID]))
	{
		local wep = player.GetActiveWeapon();
		if ( wep )
			wep.SetClip( wep.GetMaxClip() + 1 );
	}
}

function Notifications::OnWeaponReload::AdminGiveUpgradeAmmo( player, manual, params )
{
	local ID = AdminSystem.GetID( player );
	local PlayerInv = player.GetHeldItems();
	
	if (((ID in ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID])) || (ID in ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled) && (::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID]))
	{
		if ( "slot0" in PlayerInv )
		{
			local wep = PlayerInv["slot0"];
			if ( wep.GetClassname() == player.GetActiveWeapon().GetClassname() )
				player.SetPrimaryAmmo( player.GetMaxPrimaryAmmo() + (wep.GetNetPropInt("m_nUpgradedPrimaryAmmoLoaded") * 2) );
		}
	}
	if ((ID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled) && (::AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID]))
	{
		player.GiveAmmo( 999 );
	}
}

function Notifications::OnItemPickup::AdminGiveUpgrade( player, classname, params )
{
	local ID = AdminSystem.GetID( player );
	local PlayerInv = player.GetHeldItems();
	
	if ( "slot0" in PlayerInv )
	{
		if ( PlayerInv["slot0"].GetClassname() == classname )
		{
			if (ID in ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled && ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
				player.Input( "CancelCurrentScene" );
			}
			else if (ID in ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled && ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
				player.Input( "CancelCurrentScene" );
			}
			if (ID in ::AdminSystem.Vars.IsInfiniteLaserSightsEnabled && ::AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_LASER_SIGHT );
				player.Input( "CancelCurrentScene" );
			}
		}
	}
}

function Notifications::OnUse::AdminGiveUpgrade( player, target, params )
{
	local ID = AdminSystem.GetID( player );
	local PlayerInv = player.GetHeldItems();
	
	if ( "slot0" in PlayerInv )
	{
		if ( PlayerInv["slot0"].GetClassname() == target.GetClassname() )
		{
			if (ID in ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled && ::AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
				player.Input( "CancelCurrentScene" );
			}
			else if (ID in ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled && ::AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
				player.Input( "CancelCurrentScene" );
			}
			if (ID in ::AdminSystem.Vars.IsInfiniteLaserSightsEnabled && ::AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID])
			{
				player.GiveUpgrade( UPGRADE_LASER_SIGHT );
				player.Input( "CancelCurrentScene" );
			}
		}
	}
}

function Notifications::OnBotReplacedPlayer::AdminStartIdleKickTimer( player, bot, params )
{
	if ( AdminSystem.EnableIdleKick && !(player.GetSteamID() in ::AdminSystem.Admins) )
		Timers.AddTimerByName( "KickTimer" + AdminSystem.GetID( player ).tostring(), AdminSystem.IdleKickTime, false, AdminSystem.KickPlayer, player );
}

function Notifications::OnPlayerReplacedBot::AdminStopIdleKickTimer( player, bot, params )
{
	if ( AdminSystem.EnableIdleKick && !(player.GetSteamID() in ::AdminSystem.Admins) )
		Timers.RemoveTimerByName( "KickTimer" + AdminSystem.GetID( player ).tostring() );
}

function EasyLogic::OnTakeDamage::AdminDamage( damageTable )
{
	if (!damageTable.Victim)
		return;
	
	local attacker = Utils.GetEntityOrPlayer(damageTable.Attacker);
	local victim = Utils.GetEntityOrPlayer(damageTable.Victim);
	local ID = AdminSystem.GetID(victim);
	
	if (ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID])
		return false; // return 0 damage
	if ( AdminSystem.Vars.EnabledGodInfected )
	{
		if ( victim.GetType() != Z_SURVIVOR )
			return false;
	}
	if ( AdminSystem.Vars.EnabledGodSI )
	{
		if ( victim.GetType() != Z_SURVIVOR && victim.GetType() != Z_COMMON && victim.GetType() != Z_WITCH )
			return false;
	}
	
	return true;
}

function EasyLogic::OnBash::AdminBash(attacker, victim)
{
	local ID = AdminSystem.GetID( attacker );
	
	if (ID in ::AdminSystem.Vars.IsBashDisabled && ::AdminSystem.Vars.IsBashDisabled[ID])
	{
		return ALLOW_BASH_NONE;
	}
	else if (ID in ::AdminSystem.Vars.IsBashLimited && ::AdminSystem.Vars.IsBashLimited[ID])
	{
		return ALLOW_BASH_PUSHONLY;
	}
}

function EasyLogic::OnUserCommand::AdminCommands(player, args, text)
{
	local Command = GetArgument(0);
	
	switch ( Command )
	{
		case "finale":
		{
			AdminSystem.FinaleCmd( player, args );
			break;
		}
		default:
			break;
	}
}

function ChatTriggers::adminmode( player, args, text )
{
	AdminSystem.AdminModeCmd( player, args );
}

function ChatTriggers::add_admin( player, args, text )
{
	AdminSystem.AddAdminCmd( player, args );
}

function ChatTriggers::remove_admin( player, args, text )
{
	AdminSystem.RemoveAdminCmd( player, args );
}

function ChatTriggers::kick( player, args, text )
{
	AdminSystem.KickCmd( player, args );
}

function ChatTriggers::ban( player, args, text )
{
	AdminSystem.BanCmd( player, args );
}

function ChatTriggers::god( player, args, text )
{
	AdminSystem.GodCmd( player, args );
}

function ChatTriggers::bash( player, args, text )
{
	AdminSystem.BashCmd( player, args );
}

function ChatTriggers::freeze( player, args, text )
{
	AdminSystem.FreezeCmd( player, args );
}

function ChatTriggers::noclip( player, args, text )
{
	AdminSystem.NoclipCmd( player, args );
}

function ChatTriggers::speed( player, args, text )
{
	AdminSystem.SpeedCmd( player, args );
}

function ChatTriggers::fly( player, args, text )
{
	AdminSystem.FlyCmd( player, args );
}

function ChatTriggers::infinite_ammo( player, args, text )
{
	AdminSystem.InfiniteAmmoCmd( player, args );
}

function ChatTriggers::unlimited_ammo( player, args, text )
{
	AdminSystem.UnlimitedAmmoCmd( player, args );
}

function ChatTriggers::infinite_upgrade( player, args, text )
{
	AdminSystem.InfiniteUpgradeCmd( player, args );
}

function ChatTriggers::cleanup( player, args, text )
{
	AdminSystem.CleanupCmd( player, args );
}

function ChatTriggers::adrenaline( player, args, text )
{
	AdminSystem.AdrenalineCmd( player, args );
}

function ChatTriggers::move( player, args, text )
{
	AdminSystem.MoveCmd( player, args );
}

function ChatTriggers::chase( player, args, text )
{
	AdminSystem.ChaseCmd( player, args );
}

function ChatTriggers::health( player, args, text )
{
	AdminSystem.HealthCmd( player, args );
}

function ChatTriggers::max_health( player, args, text )
{
	AdminSystem.MaxHealthCmd( player, args );
}

function ChatTriggers::melee( player, args, text )
{
	AdminSystem.MeleeCmd( player, args );
}

function ChatTriggers::particle( player, args, text )
{
	AdminSystem.ParticleCmd( player, args );
}

function ChatTriggers::barrel( player, args, text )
{
	AdminSystem.BarrelCmd( player, args );
}

function ChatTriggers::gascan( player, args, text )
{
	AdminSystem.GascanCmd( player, args );
}

function ChatTriggers::propanetank( player, args, text )
{
	AdminSystem.PropaneTankCmd( player, args );
}

function ChatTriggers::oxygentank( player, args, text )
{
	AdminSystem.OxygenTankCmd( player, args );
}

function ChatTriggers::fireworkcrate( player, args, text )
{
	AdminSystem.FireworkCrateCmd( player, args );
}

function ChatTriggers::minigun( player, args, text )
{
	AdminSystem.MinigunCmd( player, args );
}

function ChatTriggers::weapon( player, args, text )
{
	AdminSystem.WeaponCmd( player, args );
}

function ChatTriggers::spawn_ammo( player, args, text )
{
	AdminSystem.SpawnAmmoCmd( player, args );
}

function ChatTriggers::dummy( player, args, text )
{
	AdminSystem.DummyCmd( player, args );
}

function ChatTriggers::entity( player, args, text )
{
	AdminSystem.EntityCmd( player, args );
}

function ChatTriggers::prop( player, args, text )
{
	AdminSystem.PropCmd( player, args );
}

function ChatTriggers::door( player, args, text )
{
	AdminSystem.DoorCmd( player, args );
}

function ChatTriggers::survivor( player, args, text )
{
	AdminSystem.SurvivorCmd( player, args );
}

function ChatTriggers::l4d1_survivor( player, args, text )
{
	AdminSystem.L4D1SurvivorCmd( player, args );
}

function ChatTriggers::client( player, args, text )
{
	AdminSystem.ClientCmd( player, args );
}

function ChatTriggers::console( player, args, text )
{
	AdminSystem.ConsoleCmd( player, args );
}

function ChatTriggers::cvar( player, args, text )
{
	AdminSystem.CvarCmd( player, args );
}

function ChatTriggers::ent_fire( player, args, text )
{
	AdminSystem.EntFireCmd( player, args );
}

function ChatTriggers::script( player, args, text )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local compiledscript = compilestring(Utils.CombineArray(args));
	compiledscript();
}

function ChatTriggers::timescale( player, args, text )
{
	AdminSystem.TimescaleCmd( player, args );
}

function ChatTriggers::sound( player, args, text )
{
	AdminSystem.SoundCmd( player, args );
}

function ChatTriggers::give( player, args, text )
{
	AdminSystem.GiveCmd( player, args );
}

function ChatTriggers::remove( player, args, text )
{
	AdminSystem.RemoveCmd( player, args );
}

function ChatTriggers::drop( player, args, text )
{
	AdminSystem.DropCmd( player, args );
}

function ChatTriggers::switch_to( player, args, text )
{
	AdminSystem.SwitchToCmd( player, args );
}

function ChatTriggers::reload( player, args, text )
{
	AdminSystem.ReloadCmd( player, args );
}

function ChatTriggers::use( player, args, text )
{
	AdminSystem.UseCmd( player, args );
}

function ChatTriggers::speak( player, args, text )
{
	AdminSystem.SpeakCmd( player, args );
}

function ChatTriggers::revivecount( player, args, text )
{
	AdminSystem.ReviveCountCmd( player, args );
}

function ChatTriggers::revive( player, args, text )
{
	AdminSystem.ReviveCmd( player, args );
}

function ChatTriggers::defib( player, args, text )
{
	AdminSystem.DefibCmd( player, args );
}

function ChatTriggers::rescue( player, args, text )
{
	AdminSystem.RescueCmd( player, args );
}

function ChatTriggers::incap( player, args, text )
{
	AdminSystem.IncapCmd( player, args );
}

function ChatTriggers::kill( player, args, text )
{
	AdminSystem.KillCmd( player, args );
}

function ChatTriggers::hurt( player, args, text )
{
	AdminSystem.HurtCmd( player, args );
}

function ChatTriggers::respawn( player, args, text )
{
	AdminSystem.RespawnCmd( player, args );
}

function ChatTriggers::extinguish( player, args, text )
{
	AdminSystem.ExtinguishCmd( player, args );
}

function ChatTriggers::ignite( player, args, text )
{
	AdminSystem.IgniteCmd( player, args );
}

function ChatTriggers::vomit( player, args, text )
{
	AdminSystem.VomitCmd( player, args );
}

function ChatTriggers::stagger( player, args, text )
{
	AdminSystem.StaggerCmd( player, args );
}

function ChatTriggers::warp( player, args, text )
{
	AdminSystem.WarpCmd( player, args );
}

function ChatTriggers::warp_here( player, args, text )
{
	AdminSystem.WarpHereCmd( player, args );
}

function ChatTriggers::warp_saferoom( player, args, text )
{
	AdminSystem.WarpSaferoomCmd( player, args );
}

function ChatTriggers::warp_checkpoint( player, args, text )
{
	AdminSystem.WarpCheckpointCmd( player, args );
}

function ChatTriggers::warp_finale( player, args, text )
{
	AdminSystem.WarpFinaleCmd( player, args );
}

function ChatTriggers::warp_battlefield( player, args, text )
{
	AdminSystem.WarpBattlefieldCmd( player, args );
}

function ChatTriggers::ammo( player, args, text )
{
	AdminSystem.AmmoCmd( player, args );
}

function ChatTriggers::upgrade_add( player, args, text )
{
	AdminSystem.UpgradeAddCmd( player, args );
}

function ChatTriggers::upgrade_remove( player, args, text )
{
	AdminSystem.UpgradeRemoveCmd( player, args );
}

function ChatTriggers::netprop( player, args, text )
{
	AdminSystem.NetPropCmd( player, args );
}

function ChatTriggers::friction( player, args, text )
{
	AdminSystem.FrictionCmd( player, args );
}

function ChatTriggers::gravity( player, args, text )
{
	AdminSystem.GravityCmd( player, args );
}

function ChatTriggers::velocity( player, args, text )
{
	AdminSystem.VelocityCmd( player, args );
}

function ChatTriggers::drop_fire( player, args, text )
{
	AdminSystem.DropFireCmd( player, args );
}

function ChatTriggers::drop_spit( player, args, text )
{
	AdminSystem.DropSpitCmd( player, args );
}

function ChatTriggers::director( player, args, text )
{
	AdminSystem.DirectorCmd( player, args );
}

function ChatTriggers::finale( player, args, text )
{
	AdminSystem.FinaleCmd( player, args );
}

function ChatTriggers::restart( player, args, text )
{
	AdminSystem.RestartCmd( player, args );
}

function ChatTriggers::limit( player, args, text )
{
	AdminSystem.LimitCmd( player, args );
}

function ChatTriggers::zombie( player, args, text )
{
	AdminSystem.ZombieCmd( player, args );
}

function ChatTriggers::z_spawn( player, args, text )
{
	AdminSystem.ZSpawnCmd( player, args );
}

function ChatTriggers::exec( player, args, text )
{
	AdminSystem.ExecCmd( player, args );
}

function ChatTriggers::endgame( player, args, text )
{
	AdminSystem.EndGameCmd( player, args );
}

function ChatTriggers::alarmcar( player, args, text )
{
	AdminSystem.AlarmCarCmd( player, args );
}

function ChatTriggers::gun( player, args, text )
{
	AdminSystem.GunCmd( player, args );
}

if ( Director.GetGameMode() == "holdout" )
{
	function ChatTriggers::resource( player, args, text )
	{
		AdminSystem.ResourceCmd( player, args );
	}
}

::AdminSystem.AdminModeCmd <- function ( player, args )
{
	local AdminsOnly = GetArgument(1);

	if (!AdminSystem.IsAdmin( player ))
		return;
	
	if ( !AdminSystem.Vars.AllowAdminsOnly && (AdminsOnly == "enable" || AdminsOnly == "true" || AdminsOnly == "on") )
	{
		AdminSystem.Vars.AllowAdminsOnly = true;
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "Admin mode enabled, only Admins have access to Admin commands.");
	}
	else if ( AdminSystem.Vars.AllowAdminsOnly && (AdminsOnly == "disable" || AdminsOnly == "false" || AdminsOnly == "off") )
	{
		AdminSystem.Vars.AllowAdminsOnly = false;
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "Admin mode disabled, everyone has access to Admin commands.");
	}
}

::AdminSystem.AddAdminCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	
	if ( !Target )
		return;

	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local adminList = FileToString("admin system/admins.txt");
	if ( adminList != null )
	{
		if (!AdminSystem.IsAdmin( player ))
			return;
	}
	
	local admins = FileToString("admin system/admins.txt");
	local steamid = Target.GetSteamID();
	if ( steamid == "BOT" )
		return;
	if ( (steamid in ::AdminSystem.Admins) )
	{
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "is already an Admin.");
		return;
	}
	if ( admins == null )
		admins = steamid + " //" + Target.GetName();
	else
		admins += "\r\n" + steamid + " //" + Target.GetName();
	if ( AdminSystem.DisplayMsgs )
		AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "has been given Admin control.");
	StringToFile("admin system/admins.txt", admins);
	AdminSystem.LoadAdmins();
}

::AdminSystem.RemoveAdminCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	
	if (!Target || !AdminSystem.IsAdmin( player ))
		return;
	
	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local admins = FileToString("admin system/admins.txt");
	local steamid = Target.GetSteamID();

	if ( (steamid in ::AdminSystem.Admins) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(player, "Only the host can remove Admins.");
		return;
	}
	if ( (steamid in ::AdminSystem.HostPlayer) && (player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		return;
	}

	if ( admins == null )
		return;
	admins = Utils.StringReplace(admins, steamid, "");
	::AdminSystem.Admins = {};
	if ( AdminSystem.DisplayMsgs )
		AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "has lost Admin control.");
	StringToFile("admin system/admins.txt", admins);
	AdminSystem.LoadAdmins();
}

::AdminSystem.KickCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	local Reason = GetArgument(2);
	
	if (!Target || !AdminSystem.IsAdmin( player ))
		return;
	
	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local steamid = Target.GetSteamID();
	
	if ( (steamid in ::AdminSystem.Admins) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(player, "You can't kick an Admin.");
		return;
	}
	if ( (steamid in ::AdminSystem.HostPlayer) && (player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		return;
	}

	if ( Reason && steamid != "BOT" )
	{
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "has been kicked by \x03" + player.GetName() + "\x01 " + "due to " + Reason );
		SendToServerConsole( "kickid " + steamid + " " + Reason );
	}
	else
	{
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "has been kicked by \x03" + player.GetName() );
		if ( steamid == "BOT" )
			SendToServerConsole( "kick " + Target.GetName() );
		else
			SendToServerConsole( "kickid " + steamid );
	}
}

::AdminSystem.BanCmd <- function ( player, args )
{
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	local Reason = GetArgument(2);
	local BanPlayer = null;

	if (!AdminSystem.IsAdmin( player ))
		return;
	
	if ( Target.IsBot() && Target.IsHumanSpectating() )
		Target = Target.GetHumanSpectator();
	
	local bannedPlayers = FileToString("admin system/banned.txt");
	local steamid = Target.GetSteamID();
	
	if ( !steamid || steamid == "BOT" )
		return;
	
	if ( (steamid in ::AdminSystem.Admins) && !(player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(player, "You can't ban an Admin.");
		return;
	}
	if ( (steamid in ::AdminSystem.HostPlayer) && (player.GetSteamID() in ::AdminSystem.HostPlayer) )
	{
		return;
	}

	if ( bannedPlayers == null )
		bannedPlayers = steamid + " //" + Target.GetName();
	else
		bannedPlayers += "\r\n" + steamid + " //" + Target.GetName();
	
	StringToFile("admin system/banned.txt", bannedPlayers);
	if ( Reason )
	{
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "has been banned by \x03" + player.GetName() + "\x01 " + "due to " + Reason );
		SendToServerConsole( "kickid " + steamid + " " + Reason );
	}
	else
	{
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "has been banned by \x03" + player.GetName() );
		SendToServerConsole( "kickid " + steamid );
	}
	AdminSystem.LoadBanned();
}

::AdminSystem.GodCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[survivorID] )
				{
					AdminSystem.Vars.IsGodEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "God mode has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsGodEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "God mode has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else if ( Type == "infected" )
		{
			if ( AdminSystem.Vars.EnabledGodInfected )
			{
				AdminSystem.Vars.EnabledGodInfected = false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "God mode disabled for Infected.");
			}
			else
			{
				AdminSystem.Vars.EnabledGodInfected = true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "God mode enabled for Infected.");
			}
		}
		else if ( Type == "si" )
		{
			if ( AdminSystem.Vars.EnabledGodSI )
			{
				AdminSystem.Vars.EnabledGodSI = false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "God mode disabled for SI.");
			}
			else
			{
				AdminSystem.Vars.EnabledGodSI = true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "God mode enabled for SI.");
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[targetID] )
			{
				AdminSystem.Vars.IsGodEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "God mode has been disabled on \x03" + Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsGodEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "God mode has been enabled on \x03" + Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
		{
			AdminSystem.Vars.IsGodEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has disabled god mode.");
		}
		else
		{
			AdminSystem.Vars.IsGodEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has enabled god mode.");
		}
	}
}

::AdminSystem.BashCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Type = GetArgument(2);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "enable" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsBashDisabled[survivorID] <- false;
					AdminSystem.Vars.IsBashLimited[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Bash has been enabled on \x03" + survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsBashDisabled[targetID] <- false;
				AdminSystem.Vars.IsBashLimited[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Bash has been enabled on \x03" + Target.GetName());
			}
		}
		else if ( Type == "disable" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsBashLimited[survivorID] <- false;
					AdminSystem.Vars.IsBashDisabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Bash has been disabled on \x03" + survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsBashLimited[targetID] <- false;
				AdminSystem.Vars.IsBashDisabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Bash has been disabled on \x03" + Target.GetName());
			}
		}
		else if ( Type == "pushonly" || Type == "limit" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsBashDisabled[survivorID] <- false;
					AdminSystem.Vars.IsBashLimited[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Bash has been limited on \x03" + survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsBashDisabled[targetID] <- false;
				AdminSystem.Vars.IsBashLimited[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Bash has been limited on \x03" + Target.GetName());
			}
		}
	}
	else
	{
		if ( Survivor == "enable" )
		{
			AdminSystem.Vars.IsBashDisabled[ID] <- false;
			AdminSystem.Vars.IsBashLimited[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "Bash has been enabled on \x03" + player.GetName());
		}
		else if ( Survivor == "disable" )
		{
			AdminSystem.Vars.IsBashLimited[ID] <- false;
			AdminSystem.Vars.IsBashDisabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "Bash has been disabled on \x03" + player.GetName());
		}
		else if ( Survivor == "pushonly" || Survivor == "limit" )
		{
			AdminSystem.Vars.IsBashDisabled[ID] <- false;
			AdminSystem.Vars.IsBashLimited[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "Bash has been limited on \x03" + player.GetName());
		}
	}
}

::AdminSystem.FreezeCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsFreezeEnabled && ::AdminSystem.Vars.IsFreezeEnabled[survivorID] )
				{
					survivor.RemoveFlag(FL_FROZEN);
					AdminSystem.Vars.IsFreezeEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "\x03" + survivor.GetName() + "\x01 " + "has been thawed.");
				}
				else
				{
					survivor.AddFlag(FL_FROZEN);
					AdminSystem.Vars.IsFreezeEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "\x03" + survivor.GetName() + "\x01 " + "has been frozen.");
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsFreezeEnabled && ::AdminSystem.Vars.IsFreezeEnabled[targetID] )
			{
				Target.RemoveFlag(FL_FROZEN);
				AdminSystem.Vars.IsFreezeEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "has been thawed.");
			}
			else
			{
				Target.AddFlag(FL_FROZEN);
				AdminSystem.Vars.IsFreezeEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "\x03" + Target.GetName() + "\x01 " + "has been frozen.");
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsFreezeEnabled && ::AdminSystem.Vars.IsFreezeEnabled[ID] )
		{
			player.RemoveFlag(FL_FROZEN);
			AdminSystem.Vars.IsFreezeEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has been thawed.");
		}
		else
		{
			player.AddFlag(FL_FROZEN);
			AdminSystem.Vars.IsFreezeEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has been frozen.");
		}
	}
}

::AdminSystem.NoclipCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsNoclipEnabled && ::AdminSystem.Vars.IsNoclipEnabled[survivorID] )
				{
					survivor.SetNetProp("movetype", 2);
					AdminSystem.Vars.IsNoclipEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Noclip has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					survivor.SetNetProp("movetype", 8);
					AdminSystem.Vars.IsNoclipEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Noclip has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsNoclipEnabled && ::AdminSystem.Vars.IsNoclipEnabled[targetID] )
			{
				Target.SetNetProp("movetype", 2);
				AdminSystem.Vars.IsNoclipEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Noclip has been disabled on \x03" + Target.GetName());
			}
			else
			{
				Target.SetNetProp("movetype", 8);
				AdminSystem.Vars.IsNoclipEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Noclip has been enabled on \x03" + Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsNoclipEnabled && ::AdminSystem.Vars.IsNoclipEnabled[ID] )
		{
			player.SetNetProp("movetype", 2);
			AdminSystem.Vars.IsNoclipEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has disabled Noclip.");
		}
		else
		{
			player.SetNetProp("movetype", 8);
			AdminSystem.Vars.IsNoclipEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has enabled Noclip.");
		}
	}
}

::AdminSystem.SpeedCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Value = GetArgument(2);
	local LookingPlayer = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Value )
		Value = Value.tofloat();
	
	if ( Survivor == "!picker" )
	{
		if ( LookingPlayer != null && LookingPlayer.GetClassname() == "player" )
			LookingPlayer.SetNetProp("m_flLaggedMovementValue", Value);
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.SetNetProp("m_flLaggedMovementValue", Value);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.SetNetProp("m_flLaggedMovementValue", Value);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.SetNetProp("m_flLaggedMovementValue", Value);
		}
		else
		{
			if ( Value )
			{
				if ( !Target )
					return;
				
				Target.SetNetProp("m_flLaggedMovementValue", Value);
			}
			else
				player.SetNetProp("m_flLaggedMovementValue", Survivor.tofloat());
		}
	}
}

::AdminSystem.FlyCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsFlyingEnabled && ::AdminSystem.Vars.IsFlyingEnabled[survivorID] )
				{
					AdminSystem.Vars.IsFlyingEnabled[survivorID] <- false;
					Timers.RemoveTimerByName ( survivorID.tostring() + "Fly" );
					survivor.Input( "IgnoreFallDamageWithoutReset", 0.1 );
					survivor.Input( "EnableLedgeHang" );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Flying mode has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsFlyingEnabled[survivorID] <- true;
					Timers.AddTimerByName( survivorID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, survivor );
					survivor.Input( "IgnoreFallDamageWithoutReset", 999999 );
					survivor.Input( "DisableLedgeHang" );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Flying mode has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsFlyingEnabled && ::AdminSystem.Vars.IsFlyingEnabled[targetID] )
			{
				AdminSystem.Vars.IsFlyingEnabled[targetID] <- false;
				Timers.RemoveTimerByName ( targetID.tostring() + "Fly" );
				Target.Input( "IgnoreFallDamageWithoutReset", 0.1 );
				Target.Input( "EnableLedgeHang" );
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Flying mode has been disabled on \x03" + Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsFlyingEnabled[targetID] <- true;
				Timers.AddTimerByName( targetID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, Target );
				Target.Input( "IgnoreFallDamageWithoutReset", 999999 );
				Target.Input( "DisableLedgeHang" );
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Flying mode has been enabled on \x03" + Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsFlyingEnabled && ::AdminSystem.Vars.IsFlyingEnabled[ID] )
		{
			AdminSystem.Vars.IsFlyingEnabled[ID] <- false;
			Timers.RemoveTimerByName ( ID.tostring() + "Fly" );
			player.Input( "IgnoreFallDamageWithoutReset", 0.1 );
			player.Input( "EnableLedgeHang" );
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has disabled flying mode.");
		}
		else
		{
			AdminSystem.Vars.IsFlyingEnabled[ID] <- true;
			Timers.AddTimerByName( ID.tostring() + "Fly", 0.1, true, AdminSystem.CalculateFly, player );
			player.Input( "IgnoreFallDamageWithoutReset", 999999 );
			player.Input( "DisableLedgeHang" );
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has enabled flying mode.");
		}
	}
}

::AdminSystem.InfiniteAmmoCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite ammo has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite ammo has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite ammo has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite ammo has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite ammo has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsInfiniteAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite ammo has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[targetID] )
			{
				AdminSystem.Vars.IsInfiniteAmmoEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Infinite ammo has been disabled on \x03" + Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsInfiniteAmmoEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Infinite ammo has been enabled on \x03" + Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsInfiniteAmmoEnabled && ::AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] )
		{
			AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has disabled infinite ammo.");
		}
		else
		{
			AdminSystem.Vars.IsInfiniteAmmoEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has enabled infinite ammo.");
		}
	}
}

::AdminSystem.UnlimitedAmmoCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Unlimited ammo has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Unlimited ammo has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Unlimited ammo has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Unlimited ammo has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( survivorID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] )
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Unlimited ammo has been disabled on \x03" + survivor.GetName());
				}
				else
				{
					AdminSystem.Vars.IsUnlimitedAmmoEnabled[survivorID] <- true;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Unlimited ammo has been enabled on \x03" + survivor.GetName());
				}
			}
		}
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( targetID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[targetID] )
			{
				AdminSystem.Vars.IsUnlimitedAmmoEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Unlimited ammo has been disabled on \x03" + Target.GetName());
			}
			else
			{
				AdminSystem.Vars.IsUnlimitedAmmoEnabled[targetID] <- true;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Unlimited ammo has been enabled on \x03" + Target.GetName());
			}
		}
	}
	else
	{
		if ( ID in ::AdminSystem.Vars.IsUnlimitedAmmoEnabled && ::AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] )
		{
			AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has disabled unlimited ammo.");
		}
		else
		{
			AdminSystem.Vars.IsUnlimitedAmmoEnabled[ID] <- true;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has enabled unlimited ammo.");
		}
	}
}

::AdminSystem.InfiniteUpgradeCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Type = GetArgument(2);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type )
	{
		if ( Type == "incendiary_ammo" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite incendiary ammo has been enabled on \x03" + survivor.GetName());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite incendiary ammo has been enabled on \x03" + survivor.GetName());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite incendiary ammo has been enabled on \x03" + survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[targetID] <- false;
				AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[targetID] <- true;
				Target.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Infinite incendiary ammo has been enabled on \x03" + Target.GetName());
			}
		}
		else if ( Type == "explosive_ammo" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite explosive ammo has been enabled on \x03" + survivor.GetName());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite explosive ammo has been enabled on \x03" + survivor.GetName());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite explosive ammo has been enabled on \x03" + survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[targetID] <- false;
				AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[targetID] <- true;
				Target.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Infinite explosive ammo has been enabled on \x03" + Target.GetName());
			}
		}
		else if ( Type == "laser_sight" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite laser sights have been enabled on \x03" + survivor.GetName());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite laser sights have been enabled on \x03" + survivor.GetName());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- true;
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite laser sights have been enabled on \x03" + survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsInfiniteLaserSightsEnabled[targetID] <- true;
				Target.GiveUpgrade( UPGRADE_LASER_SIGHT );
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Infinite laser sights have been enabled on \x03" + Target.GetName());
			}
		}
		else if ( Type == "stop" || Type == "off" )
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite upgrade ammo has been disabled on \x03" + survivor.GetName());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite upgrade ammo has been disabled on \x03" + survivor.GetName());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					local survivorID = AdminSystem.GetID( survivor );
					AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[survivorID] <- false;
					AdminSystem.Vars.IsInfiniteLaserSightsEnabled[survivorID] <- false;
					if ( AdminSystem.DisplayMsgs )
						AdminSystem.PrintClientMessage(null, "Infinite upgrade ammo has been disabled on \x03" + survivor.GetName());
				}
			}
			else
			{
				if ( !Target )
					return;
				
				local targetID = AdminSystem.GetID( Target );
				AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[targetID] <- false;
				AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[targetID] <- false;
				AdminSystem.Vars.IsInfiniteLaserSightsEnabled[targetID] <- false;
				if ( AdminSystem.DisplayMsgs )
					AdminSystem.PrintClientMessage(null, "Infinite upgrade ammo has been disabled on \x03" + Target.GetName());
			}
		}
	}
	else
	{
		if ( Survivor == "incendiary_ammo" )
		{
			AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID] <- true;
			player.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has enabled infinite incendiary ammo.");
		}
		else if ( Survivor == "explosive_ammo" )
		{
			AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID] <- true;
			player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has enabled infinite explosive ammo.");
		}
		else if ( Survivor == "laser_sight" )
		{
			AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID] <- true;
			player.GiveUpgrade( UPGRADE_LASER_SIGHT );
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has enabled infinite laser sights.");
		}
		else if ( Survivor == "stop" || Survivor == "off" )
		{
			AdminSystem.Vars.IsInfiniteExplosiveAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteIncendiaryAmmoEnabled[ID] <- false;
			AdminSystem.Vars.IsInfiniteLaserSightsEnabled[ID] <- false;
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(null, "\x03" + player.GetName() + "\x01 " + "has disabled infinite upgrade ammo.");
		}
	}
}

::AdminSystem.CleanupCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	foreach(fuelparta in Objects.OfModel("models/props_industrial/barrel_fuel_parta.mdl"))
		fuelparta.Kill();
	foreach(fuelpartb in Objects.OfModel("models/props_industrial/barrel_fuel_partb.mdl"))
		fuelpartb.Kill();
	foreach( particle_system in Objects.OfName("_*_our_particles") )
		particle_system.Kill();
	foreach( entity in Objects.OfName("_*_singlesimple") )
		entity.Kill();
}

::AdminSystem.AdrenalineCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Duration = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( Duration )
	{
		Duration = Duration.tointeger();
	
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.GiveAdrenaline(Duration);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.GiveAdrenaline(Duration);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.GiveAdrenaline(Duration);
		}
		else
		{
			if ( !Target )
				return;
			
			Target.GiveAdrenaline(Duration);
		}
	}
	else
	{
		Duration = Survivor.tointeger();
		player.GiveAdrenaline(Duration);
	}
}

::AdminSystem.MoveCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Entity )
	{
		Entity = Entity.tolower();
	
		if ( Entity == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if ( survivor.IsBot() )
					survivor.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				if ( survivor.IsBot() )
					survivor.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
			{
				if ( boomer.IsBot() )
					boomer.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
			{
				if ( charger.IsBot() )
					charger.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "infected" || Entity == "common" )
		{
			foreach(infected in Objects.OfClassname("infected"))
				infected.BotMoveToLocation(EyePosition);
		}
		else if ( Entity == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
			{
				if ( hunter.IsBot() )
					hunter.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
			{
				if ( jockey.IsBot() )
					jockey.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
			{
				if ( smoker.IsBot() )
					smoker.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
			{
				if ( spitter.IsBot() )
					spitter.BotMoveToLocation(EyePosition);
			}
		}
		else if ( Entity == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
			{
				if ( tank.IsBot() )
					tank.BotMoveToLocation(EyePosition);
			}
		}
		else
		{
			if ( !Target )
				return;
			
			if ( Target.IsBot() )
				Target.BotMoveToLocation(EyePosition);
		}
	}
	else
	{
		foreach(survivor in Players.AliveSurvivors())
		{
			if ( survivor.IsBot() )
				survivor.BotMoveToLocation(EyePosition);
		}
	}
}

::AdminSystem.ChaseCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local InfectedChase = null;
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local function RemoveInfectedChase()
	{
		while( ( InfectedChase = Entities.FindByName( InfectedChase, "admin_chase" ) ) != null )
		{
			DoEntFire( "!self", "Kill", "", 0, null, InfectedChase );
		}
	}

	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( Survivor == "all" )
		{
			RemoveInfectedChase();
			foreach ( survivor in Players.AliveSurvivors() )
				local chase = Utils.SpawnEntity("info_goal_infected_chase", "admin_chase", survivor.GetLocation());
			chase.Input("Enable");
		}
		else if ( Survivor == "stop" || Survivor == "off" )
		{
			RemoveInfectedChase();
		}
		else
		{
			if ( !Target )
				return;
			
			RemoveInfectedChase();
			local chase = Utils.SpawnEntity("info_goal_infected_chase", "admin_chase", Target.GetLocation());
			Target.AttachOther(chase, true);
			chase.Input("Enable");
		}
	}
	else
	{
		RemoveInfectedChase();
		local chase = Utils.SpawnEntity("info_goal_infected_chase", "admin_chase", EyePosition);
		chase.Input("Enable");
	}
}

::AdminSystem.HealthCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Type = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Type )
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				survivor.SwitchHealth(Type);
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				survivor.SwitchHealth(Type);
			}
		}
		else
		{
			if ( !Target )
				return;
			
			Target.SwitchHealth(Type);
		}
	}
	else
	{
		player.SwitchHealth(Survivor);
	}
}

::AdminSystem.MaxHealthCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Amount = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
		{
			survivor.Input( "AddOutput", "max_health " + Amount );
			survivor.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
		{
			survivor.Input( "AddOutput", "max_health " + Amount );
			survivor.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
		{
			boomer.Input( "AddOutput", "max_health " + Amount );
			boomer.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
		{
			charger.Input( "AddOutput", "max_health " + Amount );
			charger.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
		{
			infected.Input( "AddOutput", "max_health " + Amount );
			infected.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
		{
			hunter.Input( "AddOutput", "max_health " + Amount );
			hunter.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
		{
			jockey.Input( "AddOutput", "max_health " + Amount );
			jockey.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
		{
			smoker.Input( "AddOutput", "max_health " + Amount );
			smoker.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
		{
			spitter.Input( "AddOutput", "max_health " + Amount );
			spitter.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
		{
			tank.Input( "AddOutput", "max_health " + Amount );
			tank.Input( "AddOutput", "health " + Amount );
		}
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
		{
			witch.Input( "AddOutput", "max_health " + Amount );
			witch.Input( "AddOutput", "health " + Amount );
		}
	}
	else
	{
		if ( Amount )
		{
			if ( !Target )
				return;
			
			Target.Input( "AddOutput", "max_health " + Amount );
			Target.Input( "AddOutput", "health " + Amount );
		}
		else
		{
			player.Input( "AddOutput", "max_health " + Entity );
			player.Input( "AddOutput", "health " + Entity );
		}
	}
}

::AdminSystem.MeleeCmd <- function ( player, args )
{
	local Melee = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 2;
	g_ModeScript.SpawnMeleeWeapon( Melee, EyePosition, Vector(0,0,90) );
}

::AdminSystem.ParticleCmd <- function ( player, args )
{
	local Particle = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	g_ModeScript.CreateParticleSystemAt( null, EyePosition, Particle, true );
}

::AdminSystem.BarrelCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.SpawnFuelBarrel(EyePosition);
	}
}

::AdminSystem.GascanCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 10;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.CreateEntity("prop_physics", EyePosition, QAngle(0,0,0), { model = "models/props_junk/gascan001a.mdl" });
	}
}

::AdminSystem.PropaneTankCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 10;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.CreateEntity("prop_physics", EyePosition, QAngle(0,0,0), { model = "models/props_junk/propanecanister001a.mdl" });
	}
}

::AdminSystem.OxygenTankCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 10;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.CreateEntity("prop_physics", EyePosition, QAngle(0,0,0), { model = "models/props_equipment/oxygentank01.mdl" });
	}
}

::AdminSystem.FireworkCrateCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 10;
	
	for ( local i = 0; i < Amount; i++ )
	{
		Utils.CreateEntity("prop_physics", EyePosition, QAngle(0,0,0), { model = "models/props_junk/explosive_box001.mdl" });
	}
}

::AdminSystem.MinigunCmd <- function ( player, args )
{
	local Minigun = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	GroundPosition.y = EyeAngles.y;
	
	if ( Minigun == "l4d1" )
		Utils.SpawnL4D1Minigun(EyePosition, GroundPosition);
	else
		Utils.SpawnMinigun(EyePosition, GroundPosition);
}

::AdminSystem.WeaponCmd <- function ( player, args )
{
	local Weapon = GetArgument(1);
	local Count = GetArgument(2);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,90);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Count )
		Count = Count.tointeger();
	else
		Count = 4;
	
	if ( Weapon.find("_spawn") == null )
		Weapon = Weapon + "_spawn";
	
	GroundPosition.y = EyeAngles.y;
	GroundPosition.y += 90;
	EyePosition.z += 2;
	
	Utils.SpawnWeapon(Weapon, Count, 999999, EyePosition, GroundPosition);
}

::AdminSystem.SpawnAmmoCmd <- function ( player, args )
{
	local AmmoModel = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( !AmmoModel )
		Utils.SpawnAmmo("models/props/terror/ammo_stack.mdl", EyePosition);
	else
	{
		if ( AmmoModel == "coffee" || AmmoModel == "coffeecan" )
			Utils.SpawnAmmo("models/props_unique/spawn_apartment/coffeeammo.mdl", EyePosition);
		else
			Utils.SpawnAmmo(AmmoModel, EyePosition);
	}
}

::AdminSystem.DummyCmd <- function ( player, args )
{
	local MDL = GetArgument(1);
	local Weapons = GetArgument(2);
	local Animation = GetArgument(3);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	GroundPosition.y = EyeAngles.y;
	GroundPosition.y += 180;
	
	if ( MDL == "nick" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_gambler.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "rochelle" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_producer.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "coach" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_coach.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "ellis" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_mechanic.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "bill" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_namvet.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "zoey" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_teenangst.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "francis" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_biker.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "louis" )
		Utils.SpawnCommentaryDummy( "models/survivors/survivor_manager.mdl", "weapon_pistol", "Idle_Calm_Pistol", EyePosition, GroundPosition );
	else if ( MDL == "smoker" )
		Utils.SpawnCommentaryDummy( "models/infected/smoker.mdl", "weapon_claw", "smoker_cough", EyePosition, GroundPosition );
	else if ( MDL == "boomer" )
		Utils.SpawnCommentaryDummy( "models/infected/boomer.mdl", "weapon_claw", "Idle_Standing", EyePosition, GroundPosition );
	else if ( MDL == "boomette" )
		Utils.SpawnCommentaryDummy( "models/infected/boomette.mdl", "weapon_claw", "Idle_Standing", EyePosition, GroundPosition );
	else if ( MDL == "hunter" )
		Utils.SpawnCommentaryDummy( "models/infected/hunter.mdl", "weapon_claw", "Idle_Standing_01", EyePosition, GroundPosition );
	else if ( MDL == "spitter" )
		Utils.SpawnCommentaryDummy( "models/infected/spitter.mdl", "weapon_claw", "Standing_Idle", EyePosition, GroundPosition );
	else if ( MDL == "jockey" )
		Utils.SpawnCommentaryDummy( "models/infected/jockey.mdl", "weapon_claw", "Standing_Idle", EyePosition, GroundPosition );
	else if ( MDL == "charger" )
		Utils.SpawnCommentaryDummy( "models/infected/charger.mdl", "weapon_claw", "Idle_Upper_KNIFE", EyePosition, GroundPosition );
	else if ( MDL == "witch" )
		Utils.SpawnCommentaryDummy( "models/infected/witch.mdl", "weapon_claw", "Idle_Sitting", EyePosition, GroundPosition );
	else if ( MDL == "witch_bride" )
		Utils.SpawnCommentaryDummy( "models/infected/witch_bride.mdl", "weapon_claw", "Idle_Sitting", EyePosition, GroundPosition );
	else if ( MDL == "tank" )
		Utils.SpawnCommentaryDummy( "models/infected/hulk.mdl", "weapon_claw", "Idle", EyePosition, GroundPosition );
	else if ( MDL == "tank_dlc3" )
		Utils.SpawnCommentaryDummy( "models/infected/hulk_dlc3.mdl", "weapon_claw", "Idle", EyePosition, GroundPosition );
	else
		Utils.SpawnCommentaryDummy(MDL, Weapons, Animation, EyePosition);
}

::AdminSystem.EntityCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Utils.CreateEntity(Entity, EyePosition);
}

::AdminSystem.PropCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local MDL = GetArgument(2);
	local Aimed = GetArgument(3);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	GroundPosition.y = EyeAngles.y;

	if ( Entity == "physics" )
	{
		if ( Aimed )
		{
			GroundPosition.y += 180;
			Utils.SpawnPhysicsProp( MDL, EyePosition, GroundPosition );
		}
		else
			Utils.SpawnPhysicsProp( MDL, EyePosition, GroundPosition );
	}
	else if ( Entity == "ragdoll" )
	{
		EyePosition.z += 10;
		GroundPosition.y += 180;
		if ( MDL == "nick" )
			Utils.SpawnRagdoll( "models/survivors/survivor_gambler.mdl", EyePosition, GroundPosition );
		else if ( MDL == "rochelle" )
			Utils.SpawnRagdoll( "models/survivors/survivor_producer.mdl", EyePosition, GroundPosition );
		else if ( MDL == "coach" )
			Utils.SpawnRagdoll( "models/survivors/survivor_coach.mdl", EyePosition, GroundPosition );
		else if ( MDL == "ellis" )
			Utils.SpawnRagdoll( "models/survivors/survivor_mechanic.mdl", EyePosition, GroundPosition );
		else if ( MDL == "bill" )
			Utils.SpawnRagdoll( "models/survivors/survivor_namvet.mdl", EyePosition, GroundPosition );
		else if ( MDL == "zoey" )
			Utils.SpawnRagdoll( "models/survivors/survivor_teenangst.mdl", EyePosition, GroundPosition );
		else if ( MDL == "francis" )
			Utils.SpawnRagdoll( "models/survivors/survivor_biker.mdl", EyePosition, GroundPosition );
		else if ( MDL == "louis" )
			Utils.SpawnRagdoll( "models/survivors/survivor_manager.mdl", EyePosition, GroundPosition );
		else if ( MDL == "smoker" )
			Utils.SpawnRagdoll( "models/infected/smoker.mdl", EyePosition, GroundPosition );
		else if ( MDL == "boomer" )
			Utils.SpawnRagdoll( "models/infected/boomer.mdl", EyePosition, GroundPosition );
		else if ( MDL == "boomette" )
			Utils.SpawnRagdoll( "models/infected/boomette.mdl", EyePosition, GroundPosition );
		else if ( MDL == "hunter" )
			Utils.SpawnRagdoll( "models/infected/hunter.mdl", EyePosition, GroundPosition );
		else if ( MDL == "spitter" )
			Utils.SpawnRagdoll( "models/infected/spitter.mdl", EyePosition, GroundPosition );
		else if ( MDL == "jockey" )
			Utils.SpawnRagdoll( "models/infected/jockey.mdl", EyePosition, GroundPosition );
		else if ( MDL == "charger" )
			Utils.SpawnRagdoll( "models/infected/charger.mdl", EyePosition, GroundPosition );
		else if ( MDL == "witch" )
			Utils.SpawnRagdoll( "models/infected/witch.mdl", EyePosition, GroundPosition );
		else if ( MDL == "witch_bride" )
			Utils.SpawnRagdoll( "models/infected/witch_bride.mdl", EyePosition, GroundPosition );
		else if ( MDL == "tank" )
			Utils.SpawnRagdoll( "models/infected/hulk.mdl", EyePosition, GroundPosition );
		else if ( MDL == "tank_dlc3" )
			Utils.SpawnRagdoll( "models/infected/hulk_dlc3.mdl", EyePosition, GroundPosition );
		else
			Utils.SpawnRagdoll( MDL, EyePosition, GroundPosition );
	}
	else
	{
		if ( Aimed )
		{
			GroundPosition.y += 180;
			Utils.SpawnDynamicProp( MDL, EyePosition, GroundPosition );
		}
		else
			Utils.SpawnDynamicProp( MDL, EyePosition, GroundPosition );
	}
}

::AdminSystem.DoorCmd <- function ( player, args )
{
	local DoorModel = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	GroundPosition.y = EyeAngles.y;
	
	if ( !DoorModel )
		Utils.SpawnDoor("models/props_downtown/door_interior_112_01.mdl", EyePosition, GroundPosition);
	else
	{
		EyePosition.z += 52;
		if ( DoorModel == "saferoom" || DoorModel == "checkpoint" )
			Utils.SpawnDoor("models/props_doors/checkpoint_door_02.mdl", EyePosition, GroundPosition);
		else
			Utils.SpawnDoor(DoorModel, EyePosition, GroundPosition);
	}
}

::AdminSystem.GiveCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Weapon = GetArgument(2);
	local Skin = GetArgument(3);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Skin != null )
	{
		if ( Skin >= "0" )
			Skin = Skin.tointeger();
		
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
				LookingSurvivor.Give(Weapon, Skin);
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.Give(Weapon, Skin);
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.Give(Weapon, Skin);
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.Give(Weapon, Skin);
			}
			else
			{
				if ( !Target )
					return;
				
				Target.Give(Weapon, Skin);
			}
		}
	}
	else
	{
		if ( Weapon != null )
		{
			if ( Survivor == "!picker" )
			{
				if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
					LookingSurvivor.Give(Weapon);
				else
					return;
			}
			else
			{
				if ( Survivor == "all" )
				{
					foreach(survivor in Players.AliveSurvivors())
						survivor.Give(Weapon);
				}
				else if ( Survivor == "l4d1" )
				{
					foreach(survivor in Players.L4D1Survivors())
						survivor.Give(Weapon);
				}
				else if ( Survivor == "bots" )
				{
					foreach(survivor in Players.AliveSurvivorBots())
						survivor.Give(Weapon);
				}
				else
				{
					if ( Weapon >= "0" && Weapon <= "99" )
						player.Give(Survivor, Weapon.tointeger());
					else
					{
						if ( !Target )
							return;
						
						Target.Give(Weapon);
					}
				}
			}
		}
		else
		{
			player.Give(Survivor);
		}
	}
}

::AdminSystem.RemoveCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Weapon = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
		{
			if ( Weapon >= "0" && Weapon <= "5" )
				LookingSurvivor.DropWeaponSlot(Weapon.tointeger());
			else
				LookingSurvivor.Remove(Weapon);
		}
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if ( Weapon >= "0" && Weapon <= "5" )
					survivor.DropWeaponSlot(Weapon.tointeger());
				else
					survivor.Remove(Weapon);
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				if ( Weapon >= "0" && Weapon <= "5" )
					survivor.DropWeaponSlot(Weapon.tointeger());
				else
					survivor.Remove(Weapon);
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				if ( Weapon >= "0" && Weapon <= "5" )
					survivor.DropWeaponSlot(Weapon.tointeger());
				else
					survivor.Remove(Weapon);
			}
		}
		else
		{
			if ( Weapon != null )
			{
				if ( !Target )
					return;
				
				if ( Weapon >= "0" && Weapon <= "5" )
					Target.DropWeaponSlot(Weapon.tointeger());
				else
					Target.Remove(Weapon);
			}
			else
			{
				if ( Survivor >= "0" && Survivor <= "5" )
					player.DropWeaponSlot(Survivor.tointeger());
				else
					player.Remove(Survivor);
			}
		}
	}
}

::AdminSystem.DropCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Weapon = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor != null )
		Survivor = Survivor.tolower();
	
	if ( Weapon != null )
	{
		if ( Weapon >= "0" && Weapon <= "5" )
			Weapon = Weapon.tointeger();
	}
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
		{
			if ( Weapon != null )
				LookingSurvivor.Drop(Weapon);
			else
				LookingSurvivor.Drop();
		}
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if ( Weapon != null )
					survivor.Drop(Weapon);
				else
					survivor.Drop();
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				if ( Weapon != null )
					survivor.Drop(Weapon);
				else
					survivor.Drop();
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				if ( Weapon != null )
					survivor.Drop(Weapon);
				else
					survivor.Drop();
			}
		}
		else
		{
			if ( Weapon != null )
			{
				if ( !Target )
					return;
				
				Target.Drop(Weapon);
			}
			else
			{
				if ( Survivor != null )
				{
					if ( Target )
						Target.Drop();
					else
					{
						if ( Survivor >= "0" && Survivor <= "5" )
							player.Drop(Survivor.tointeger());
						else
							player.Drop(Survivor);
					}
				}
				else
					player.Drop();
			}
		}
	}
}

::AdminSystem.SwitchToCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Weapon = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor == null )
		return;
	
	if ( Survivor >= "0" && Survivor <= "5" )
		Survivor = Survivor.tointeger();
	else
		Survivor = Survivor.tolower();
	
	if ( Weapon != null )
	{
		if ( Weapon >= "0" && Weapon <= "5" )
			Weapon = Weapon.tointeger();
	}
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
		{
			if ( Weapon != null )
				LookingSurvivor.SwitchTo(Weapon);
		}
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				if ( Weapon != null )
					survivor.SwitchTo(Weapon);
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				if ( Weapon != null )
					survivor.SwitchTo(Weapon);
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				if ( Weapon != null )
					survivor.SwitchTo(Weapon);
			}
		}
		else
		{
			if ( Weapon != null )
			{
				if ( !Target )
					return;
				
				Target.SwitchTo(Weapon);
			}
			else
			{
				player.SwitchTo(Survivor);
			}
		}
	}
}

::AdminSystem.ReloadCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor == null )
		player.GetActiveWeapon().Reload();
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
		{
			LookingSurvivor.GetActiveWeapon().Reload();
		}
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
			{
				survivor.GetActiveWeapon().Reload();
			}
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
			{
				survivor.GetActiveWeapon().Reload();
			}
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
			{
				survivor.GetActiveWeapon().Reload();
			}
		}
		else
		{
			if ( Target )
				Target.GetActiveWeapon().Reload();
		}
	}
}

::AdminSystem.SurvivorCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	else
	{
		Utils.SpawnSurvivor(null, EyePosition);
		return;
	}
	
	local function FakeZoeyResponses( args )
	{
		local zoey = Utils.GetPlayerFromName("Survivor");
		if (!zoey)
			return;
		
		zoey.Input("AddContext", "who:TeenGirl:0");
	}
	
	if ( Survivor == "bill" )
		Utils.SpawnSurvivor(BILL, EyePosition);
	else if ( Survivor == "zoey" )
	{
		Utils.SpawnSurvivor(ZOEY, EyePosition, QAngle( 0, 0, 0 ), 9);
		Timers.AddTimer(0.1, false, FakeZoeyResponses);
	}
	else if ( Survivor == "francis" )
		Utils.SpawnSurvivor(FRANCIS, EyePosition);
	else if ( Survivor == "louis" )
		Utils.SpawnSurvivor(LOUIS, EyePosition);
	else if ( Survivor == "all" )
	{
		Utils.SpawnSurvivor(BILL, EyePosition);
		Utils.SpawnSurvivor(ZOEY, EyePosition, QAngle( 0, 0, 0 ), 9);
		Utils.SpawnSurvivor(FRANCIS, EyePosition);
		Utils.SpawnSurvivor(LOUIS, EyePosition);
		Timers.AddTimer(0.1, false, FakeZoeyResponses);
	}
}

::AdminSystem.L4D1SurvivorCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Survivor == "bill" )
		Utils.SpawnL4D1Survivor(BILL, EyePosition);
	else if ( Survivor == "zoey" )
		Utils.SpawnL4D1Survivor(ZOEY, EyePosition);
	else if ( Survivor == "francis" )
		Utils.SpawnL4D1Survivor(FRANCIS, EyePosition);
	else if ( Survivor == "louis" )
		Utils.SpawnL4D1Survivor(LOUIS, EyePosition);
	else if ( Survivor == "all" )
	{
		Utils.SpawnL4D1Survivor(BILL, EyePosition);
		Utils.SpawnL4D1Survivor(ZOEY, EyePosition);
		Utils.SpawnL4D1Survivor(FRANCIS, EyePosition);
		Utils.SpawnL4D1Survivor(LOUIS, EyePosition);
	}
}

::AdminSystem.ClientCmd <- function ( player, args )
{
	local Command = GetArgument(1);
	local Value = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Utils.BroadcastClientCommand(Utils.CombineArray(args));
}

::AdminSystem.ConsoleCmd <- function ( player, args )
{
	local Command = GetArgument(1);
	local Value = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	SendToServerConsole(Utils.CombineArray(args));
}

::AdminSystem.CvarCmd <- function ( player, args )
{
	local Cvar = GetArgument(1);
	local Value = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Cvar && Value )
		Convars.SetValue( Cvar, Value );
}

::AdminSystem.EntFireCmd <- function ( player, args )
{
	local Ent = GetArgument(1);
	local Action = GetArgument(2);
	local Value = GetArgument(3);
	local Value2 = GetArgument(4);
	local Value3 = GetArgument(5);
	local Entity = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	local val = "";
	if (Value && Value2 && Value3)
		val = Value + " " + Value2 + " " + Value3;
	else if (Value && Value2)
		val = Value + " " + Value2;
	else if (Value)
		val = Value;
	
	if ( Ent == "!picker" )
	{
		if ( Entity )
			Entity.Input( Action, val );
	}
	else if ( Ent == "!self" )
	{
		player.Input( Action, val );
	}
	else
	{
		if ( Target )
		{
			Target.Input( Action, val );
		}
		else
			g_MapScript.EntFire( Ent, Action, val );
	}
}

::AdminSystem.TimescaleCmd <- function ( player, args )
{
	local DesiredTimeScale = GetArgument(1);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( DesiredTimeScale == "slow" )
	{
		Utils.ResumeTime();
		Utils.SlowTime(0.5, 2.0, 1.0, 2.0, false);
	}
	else if ( DesiredTimeScale == "fast" )
	{
		Utils.ResumeTime();
		Utils.SlowTime(1.5, 2.0, 1.0, 2.0, false);
	}
	else if ( DesiredTimeScale == "normal" || DesiredTimeScale == "resume" )
		Utils.ResumeTime();
	else
	{
		DesiredTimeScale = DesiredTimeScale.tofloat();
		if ( DesiredTimeScale < 0.1 )
		{
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(player, "You can't enter a value less than 0.1!");
			return;
		}
		else if ( DesiredTimeScale > 10.0 )
		{
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(player, "You can't enter a value greater than 10.0!");
			return;
		}
		Utils.ResumeTime();
		Utils.SlowTime(DesiredTimeScale, 2.0, 1.0, 2.0, false);
	}
}

::AdminSystem.SoundCmd <- function ( player, args )
{
	local Ent = GetArgument(1);
	local Sound = GetArgument(2);
	local Name = GetArgument(3);
	local ID = AdminSystem.GetID( player );
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Sound )
	{
		if ( Ent == "all" )
		{
			foreach(survivor in Players.Survivors())
			{
				local survivorID = AdminSystem.GetID( survivor );
				if ( Sound == "stop" || Sound == "off" )
				{
					if ( (survivorID in ::AdminSystem.SoundName) )
					{
						if ( Name )
							survivor.StopSound(Name);
						else
							survivor.StopSound(AdminSystem.SoundName[survivorID]);
					}
				}
				else
				{
					survivor.PlaySound(Sound);
					AdminSystem.SoundName[survivorID] <- Sound;
				}
			}
		}
		else if ( Ent == "stop" || Ent == "off" )
			player.StopSound(Sound);
		else
		{
			if ( !Target )
				return;
			
			local targetID = AdminSystem.GetID( Target );
			if ( Sound == "stop" || Sound == "off" )
			{
				if ( (targetID in ::AdminSystem.SoundName) )
				{
					if ( Name )
						Target.StopSound(Name);
					else
						Target.StopSound(AdminSystem.SoundName[targetID]);
				}
			}
			else
			{
				Target.PlaySound(Sound);
				AdminSystem.SoundName[targetID] <- Sound;
			}
		}
	}
	else
	{
		if ( Ent.find(".wav") != null || Ent.find(".mp3") != null )
			Utils.PlaySound(Ent);
		else
		{
			if ( Ent == "stop" || Ent == "off" )
			{
				if ( (ID in ::AdminSystem.SoundName) )
					player.StopSound(AdminSystem.SoundName[ID]);
			}
			else
			{
				player.PlaySound(Ent);
				AdminSystem.SoundName[ID] <- Ent;
			}
		}
	}
}

::AdminSystem.UseCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Entity = GetArgument(2);
	local LookingEntity = player.GetLookingEntity();
	local ent = null;
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Entity )
	{
		Entity = Entity.tolower();
		
		ent = Entities.FindByName( null, Entity );
		
		if ( !ent )
			ent = Entities.FindByClassname( null, Entity );
		
		if ( !ent )
			return;
		
		ent = ::VSLib.Entity(ent);
		
		foreach(survivor in Players.AliveSurvivors())
		{
			local t = survivor.GetHeldItems();
	
			if (t)
			{
				foreach (item in t)
				{
					if ( item.GetEntityHandle() == ent.GetEntityHandle() )
					{
						printl("Survivor holding entity, returning...");
						return;
					}
				}
			}
		}
		
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Use(ent);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.Use(ent);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Use(ent);
		}
		else
		{
			if ( Survivor )
			{
				if ( !Target )
					return;
				
				Target.Use(ent);
			}
			else
				player.Use(ent);
		}
	}
	else
	{
		if ( Survivor )
		{
			ent = Entities.FindByName( null, Survivor );
			
			if ( !ent )
				ent = Entities.FindByClassname( null, Survivor );
		}
		
		if ( ent )
		{
			player.Use(::VSLib.Entity(ent));
		}
		else
		{
			if ( !LookingEntity )
				return;
			
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.Use(LookingEntity);
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.Use(LookingEntity);
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.Use(LookingEntity);
			}
			else
			{
				if ( Survivor )
				{
					if ( !Target )
						return;
					
					Target.Use(LookingEntity);
				}
				else
					player.Use(LookingEntity);
			}
		}
	}
}

::AdminSystem.SpeakCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Scene = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	
	if ( Survivor == "!picker" )
	{
		if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.GetPlayerType() == Z_SURVIVOR )
			LookingSurvivor.Speak(Scene);
		else
			return;
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Speak(Scene);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.Speak(Scene);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Speak(Scene);
		}
		else
		{
			if ( Scene )
			{
				if ( !Target )
					return;
				
				Target.Speak(Scene);
			}
			else
				player.Speak(Survivor);
		}
	}
}

::AdminSystem.ReviveCountCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local ReviveCount = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( ReviveCount )
		ReviveCount = ReviveCount.tointeger();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetReviveCount(ReviveCount);
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.SetReviveCount(ReviveCount);
	}
	else
	{
		if ( ReviveCount )
		{
			if ( !Target )
				return;
			
			Target.SetReviveCount(ReviveCount);
		}
		else
			player.SetReviveCount(Survivor.tointeger());
	}
}

::AdminSystem.ReviveCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.Revive();
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.Revive();
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			Target.Revive();
		}
		else
			player.Revive();
	}
}

::AdminSystem.DefibCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.DeadSurvivors())
			survivor.Defib();
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.DeadSurvivorBots())
			survivor.Defib();
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			Target.Defib();
		}
		else
			player.Defib();
	}
}

::AdminSystem.RescueCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.DeadSurvivors())
			survivor.Rescue();
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.DeadSurvivorBots())
			survivor.Rescue();
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			Target.Rescue();
		}
		else
			player.Rescue();
	}
}

::AdminSystem.IncapCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
		{
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( survivor );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				survivor.SetHealthBuffer(0);
				survivor.Input( "SetHealth", "0" );
			}
		}
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
		{
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( survivor );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				survivor.SetHealthBuffer(0);
				survivor.Input( "SetHealth", "0" );
			}
		}
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( Target );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				Target.SetHealthBuffer(0);
				Target.Input( "SetHealth", "0" );
			}
		}
		else
		{
			local ID = AdminSystem.GetID( player );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			player.SetHealthBuffer(0);
			player.Input( "SetHealth", "0" );
		}
	}
}

::AdminSystem.KillCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Entity )
		Entity = Entity.tolower();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
		{
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( survivor );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				survivor.Kill();
			}
		}
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
		{
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( survivor );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				survivor.Kill();
			}
		}
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
		{
			local ID = AdminSystem.GetID( boomer );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			boomer.Kill();
		}
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
		{
			local ID = AdminSystem.GetID( charger );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			charger.Kill();
		}
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
		{
			local ID = AdminSystem.GetID( infected );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			infected.Kill();
		}
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
		{
			local ID = AdminSystem.GetID( hunter );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			hunter.Kill();
		}
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
		{
			local ID = AdminSystem.GetID( jockey );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			jockey.Kill();
		}
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
		{
			local ID = AdminSystem.GetID( smoker );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			smoker.Kill();
		}
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
		{
			local ID = AdminSystem.GetID( spitter );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			spitter.Kill();
		}
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
		{
			local ID = AdminSystem.GetID( tank );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			tank.Kill();
		}
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
		{
			local ID = AdminSystem.GetID( witch );
			if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
				AdminSystem.Vars.IsGodEnabled[ID] <- false;
			witch.Kill();
		}
	}
	else
	{
		if ( Entity )
		{
			if ( !Target )
				return;
			
			if ( Convars.GetFloat("god") == 0 )
			{
				local ID = AdminSystem.GetID( Target );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				Target.Kill();
			}
		}
		else
		{
			if ( player.GetTeam() == SURVIVORS )
			{
				if ( Convars.GetFloat("god") == 0 )
				{
					local ID = AdminSystem.GetID( player );
					if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
						AdminSystem.Vars.IsGodEnabled[ID] <- false;
					player.Kill();
				}
			}
			else
			{
				local ID = AdminSystem.GetID( player );
				if ( ID in ::AdminSystem.Vars.IsGodEnabled && ::AdminSystem.Vars.IsGodEnabled[ID] )
					AdminSystem.Vars.IsGodEnabled[ID] <- false;
				player.Kill();
			}
		}
	}
}

::AdminSystem.HurtCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Amount = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Entity = Entity.tointeger();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.Damage(Amount);
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.Damage(Amount);
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.Damage(Amount);
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.Damage(Amount);
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
			infected.Damage(Amount);
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.Damage(Amount);
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.Damage(Amount);
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.Damage(Amount);
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.Damage(Amount);
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.Damage(Amount);
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
			witch.Damage(Amount);
	}
	else
	{
		if ( Amount )
		{
			if ( !Target )
				return;
			
			Target.Damage(Amount);
		}
		else
		{
			player.Damage(Entity);
		}
	}
}

::AdminSystem.RespawnCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Location = player.GetLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.DeadSurvivors())
		{
			local SurvivorSpawnPos = survivor.GetSpawnLocation();
			
			survivor.Defib();
			if ( player.IsAlive() )
				survivor.SetLocation(Location);
			else
				survivor.SetLocation(SurvivorSpawnPos);
		}
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.DeadSurvivorBots())
		{
			local SurvivorSpawnPos = survivor.GetSpawnLocation();
			
			survivor.Defib();
			if ( player.IsAlive() )
				survivor.SetLocation(Location);
			else
				survivor.SetLocation(SurvivorSpawnPos);
		}
	}
	else
	{
		if ( Survivor )
		{
			if ( !Target )
				return;
			
			if ( !Target.IsAlive() )
			{
				Target.Defib();
				if ( player.IsAlive() )
					Target.SetLocation(Location);
				else
					Target.SetLocation(Target.GetSpawnLocation());
			}
		}
		else
		{
			if ( !player.IsAlive() )
			{
				local SpawnPos = player.GetSpawnLocation();
				player.Defib();
				player.SetLocation(SpawnPos);
			}
		}
	}
}

::AdminSystem.ExtinguishCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Entity )
		Entity = Entity.tolower();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.Extinguish();
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.Extinguish();
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.Extinguish();
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.Extinguish();
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
			infected.Extinguish();
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.Extinguish();
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.Extinguish();
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.Extinguish();
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.Extinguish();
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.Extinguish();
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
			witch.Extinguish();
	}
	else
	{
		if ( Entity )
		{
			if ( !Target )
				return;
			
			Target.Extinguish();
		}
		else
			player.Extinguish();
	}
}

::AdminSystem.IgniteCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Entity )
		Entity = Entity.tolower();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "infected" )
	{
		foreach(infected in Objects.OfClassname("infected"))
			infected.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.Input( "IgniteLifeTime", "999999" );
	}
	else if ( Entity == "witch" )
	{
		foreach(witch in Objects.OfClassname("witch"))
			witch.Input( "IgniteLifeTime", "999999" );
	}
	else
	{
		if ( Entity )
		{
			if ( !Target )
				return;
			
			Target.Input( "IgniteLifeTime", "999999" );
		}
		else
			player.Input( "IgniteLifeTime", "999999" );
	}
}

::AdminSystem.VomitCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Vomit();
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.Vomit();
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Vomit();
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.Vomit();
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.Vomit();
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.Vomit();
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.Vomit();
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.Vomit();
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.Vomit();
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.Vomit();
		}
		else
		{
			if ( !Target )
				return;
			
			Target.Vomit();
		}
	}
	else
	{
		player.Vomit();
	}
}

::AdminSystem.StaggerCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Away = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
		Survivor = Survivor.tolower();
	
	if ( Away )
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.StaggerAwayFromEntity(player);
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.StaggerAwayFromEntity(player);
		}
		else
		{
			if ( !Target )
				return;
			
			Target.StaggerAwayFromEntity(player);
		}
	}
	else
	{
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.Stagger();
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.Stagger();
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.Stagger();
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.Stagger();
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.Stagger();
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.Stagger();
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.Stagger();
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.Stagger();
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.Stagger();
		}
		else
		{
			if ( Survivor )
			{
				if ( !Target )
					return;
				
				Target.Stagger();
			}
			else
				player.Stagger();
		}
	}
}

::AdminSystem.WarpCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local OtherSurvivor = GetArgument(2);
	local Location = player.GetLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));
	local Target2 = Utils.GetPlayerFromName(GetArgument(2));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( OtherSurvivor )
		{
			OtherSurvivor = OtherSurvivor.tolower();
			
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					if ( !Target2 )
						return;
					
					survivor.SetLocation(Target2.GetLocation());
				}
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					if ( !Target2 )
						return;
					
					survivor.SetLocation(Target2.GetLocation());
				}
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					if ( !Target2 )
						return;
					
					survivor.SetLocation(Target2.GetLocation());
				}
			}
			else
			{
				if ( !Target || !Target2 )
					return;
				
				Target.SetLocation(Target2.GetLocation());
			}
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.SetLocation(Location);
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.SetLocation(Location);
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.SetLocation(Location);
			}
			else if ( Survivor == "boomer" )
			{
				foreach(boomer in Players.OfType(Z_BOOMER))
					boomer.SetLocation(Location);
			}
			else if ( Survivor == "charger" )
			{
				foreach(charger in Players.OfType(Z_CHARGER))
					charger.SetLocation(Location);
			}
			else if ( Survivor == "hunter" )
			{
				foreach(hunter in Players.OfType(Z_HUNTER))
					hunter.SetLocation(Location);
			}
			else if ( Survivor == "jockey" )
			{
				foreach(jockey in Players.OfType(Z_JOCKEY))
					jockey.SetLocation(Location);
			}
			else if ( Survivor == "smoker" )
			{
				foreach(smoker in Players.OfType(Z_SMOKER))
					smoker.SetLocation(Location);
			}
			else if ( Survivor == "spitter" )
			{
				foreach(spitter in Players.OfType(Z_SPITTER))
					spitter.SetLocation(Location);
			}
			else if ( Survivor == "tank" )
			{
				foreach(tank in Players.OfType(Z_TANK))
					tank.SetLocation(Location);
			}
			else
			{
				if ( !Target )
					return;
				
				Target.SetLocation(Location);
			}
		}
	}
	else
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetLocation(Location);
	}
}

::AdminSystem.WarpHereCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.SetLocation(EyePosition);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.SetLocation(EyePosition);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.SetLocation(EyePosition);
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.SetLocation(EyePosition);
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.SetLocation(EyePosition);
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.SetLocation(EyePosition);
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.SetLocation(EyePosition);
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.SetLocation(EyePosition);
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.SetLocation(EyePosition);
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.SetLocation(EyePosition);
		}
		else
		{
			if ( !Target )
				return;
			
			Target.SetLocation(EyePosition);
		}
	}
	else
	{
		player.SetLocation(EyePosition);
	}
}

::AdminSystem.WarpSaferoomCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Saferoom = Utils.GetSaferoomLocation();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Saferoom == null )
		return;
	
	if ( Survivor )
	{
		Survivor = Survivor.tolower();
		
		if ( Survivor == "all" )
		{
			foreach(survivor in Players.AliveSurvivors())
				survivor.SetLocation(Saferoom);
		}
		else if ( Survivor == "l4d1" )
		{
			foreach(survivor in Players.L4D1Survivors())
				survivor.SetLocation(Saferoom);
		}
		else if ( Survivor == "bots" )
		{
			foreach(survivor in Players.AliveSurvivorBots())
				survivor.SetLocation(Saferoom);
		}
		else if ( Survivor == "boomer" )
		{
			foreach(boomer in Players.OfType(Z_BOOMER))
				boomer.SetLocation(Saferoom);
		}
		else if ( Survivor == "charger" )
		{
			foreach(charger in Players.OfType(Z_CHARGER))
				charger.SetLocation(Saferoom);
		}
		else if ( Survivor == "hunter" )
		{
			foreach(hunter in Players.OfType(Z_HUNTER))
				hunter.SetLocation(Saferoom);
		}
		else if ( Survivor == "jockey" )
		{
			foreach(jockey in Players.OfType(Z_JOCKEY))
				jockey.SetLocation(Saferoom);
		}
		else if ( Survivor == "smoker" )
		{
			foreach(smoker in Players.OfType(Z_SMOKER))
				smoker.SetLocation(Saferoom);
		}
		else if ( Survivor == "spitter" )
		{
			foreach(spitter in Players.OfType(Z_SPITTER))
				spitter.SetLocation(Saferoom);
		}
		else if ( Survivor == "tank" )
		{
			foreach(tank in Players.OfType(Z_TANK))
				tank.SetLocation(Saferoom);
		}
		else
		{
			if ( !Target )
				return;
			
			Target.SetLocation(Saferoom);
		}
	}
	else
	{
		player.SetLocation(Saferoom);
	}
}

::AdminSystem.WarpCheckpointCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Director.WarpAllSurvivorsToCheckpoint();
}

::AdminSystem.WarpFinaleCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Director.WarpAllSurvivorsToFinale();
}

::AdminSystem.WarpBattlefieldCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Director.WarpAllSurvivorsToBattlefield();
}

::AdminSystem.AmmoCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Amount = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( Amount )
		Amount = Amount.tointeger();
	
	if ( Survivor == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.GiveAmmo(Amount);
	}
	else if ( Survivor == "l4d1" )
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.GiveAmmo(Amount);
	}
	else if ( Survivor == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.GiveAmmo(Amount);
	}
	else
	{
		if ( Amount )
		{
			if ( !Target )
				return;
			
			Target.GiveAmmo(Amount);
		}
		else
			player.GiveAmmo(Survivor.tointeger());
	}
}

::AdminSystem.UpgradeAddCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Upgrade = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( Upgrade )
		Upgrade = Upgrade.tolower();
	
	if ( Upgrade == "laser_sight" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.GiveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.GiveUpgrade( UPGRADE_LASER_SIGHT );
			}
		}
	}
	else if ( Upgrade == "explosive_ammo" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
		}
	}
	else if ( Upgrade == "incendiary_ammo" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
		}
	}
	else
	{
		if ( Survivor == "laser_sight" )
		{
			player.GiveUpgrade( UPGRADE_LASER_SIGHT );
		}
		else if ( Survivor == "explosive_ammo" )
		{
			player.GiveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
		}
		else if ( Survivor == "incendiary_ammo" )
		{
			player.GiveUpgrade( UPGRADE_INCENDIARY_AMMO );
		}
		else
		{
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(player, "Incorrect upgrade, valid upgrades are \"laser_sight\", \"explosive_ammo\" and \"incendiary_ammo\".");
		}
	}
}

::AdminSystem.UpgradeRemoveCmd <- function ( player, args )
{
	local Survivor = GetArgument(1);
	local Upgrade = GetArgument(2);
	local LookingSurvivor = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Survivor = Survivor.tolower();
	if ( Upgrade )
		Upgrade = Upgrade.tolower();
	
	if ( Upgrade == "laser_sight" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.RemoveUpgrade( UPGRADE_LASER_SIGHT );
			}
		}
	}
	else if ( Upgrade == "explosive_ammo" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
			}
		}
	}
	else if ( Upgrade == "incendiary_ammo" )
	{
		if ( Survivor == "!picker" )
		{
			if ( LookingSurvivor != null && LookingSurvivor.GetClassname() == "player" && LookingSurvivor.IsSurvivor() )
				LookingSurvivor.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			else
				return;
		}
		else
		{
			if ( Survivor == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
					survivor.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else if ( Survivor == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
					survivor.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else if ( Survivor == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
					survivor.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
			else
			{
				if ( !Target )
					return;
				
				Target.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
			}
		}
	}
	else
	{
		if ( Survivor == "laser_sight" )
		{
			player.RemoveUpgrade( UPGRADE_LASER_SIGHT );
		}
		else if ( Survivor == "explosive_ammo" )
		{
			player.RemoveUpgrade( UPGRADE_EXPLOSIVE_AMMO );
		}
		else if ( Survivor == "incendiary_ammo" )
		{
			player.RemoveUpgrade( UPGRADE_INCENDIARY_AMMO );
		}
		else
		{
			if ( AdminSystem.DisplayMsgs )
				AdminSystem.PrintClientMessage(player, "Incorrect upgrade, valid upgrades are \"laser_sight\", \"explosive_ammo\" and \"incendiary_ammo\".");
		}
	}
}

::AdminSystem.NetPropCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Property = GetArgument(2);
	local Value = GetArgument(3);
	local LookingEntity = player.GetLookingEntity();
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Value )
	{
		if ( Value.tolower() == "true" )
			Value = 1;
		else if ( Value.tolower() == "false" )
			Value = 0;
		
		if ( Entity == "!picker" )
		{
			if ( LookingEntity != null )
			{
				if ( LookingEntity.GetNetPropType( Property ) == "integer" )
					Value = Value.tointeger();
				else if ( LookingEntity.GetNetPropType( Property ) == "float" )
					Value = Value.tofloat();
				
				LookingEntity.SetNetProp( Property, Value );
			}
			else
				return;
		}
		else
		{
			if ( Entity == "all" )
			{
				foreach(survivor in Players.AliveSurvivors())
				{
					if ( survivor.GetNetPropType( Property ) == "integer" )
						Value = Value.tointeger();
					else if ( survivor.GetNetPropType( Property ) == "float" )
						Value = Value.tofloat();
					
					survivor.SetNetProp( Property, Value );
				}
			}
			else if ( Entity == "l4d1" )
			{
				foreach(survivor in Players.L4D1Survivors())
				{
					if ( survivor.GetNetPropType( Property ) == "integer" )
						Value = Value.tointeger();
					else if ( survivor.GetNetPropType( Property ) == "float" )
						Value = Value.tofloat();
					
					survivor.SetNetProp( Property, Value );
				}
			}
			else if ( Entity == "bots" )
			{
				foreach(survivor in Players.AliveSurvivorBots())
				{
					if ( survivor.GetNetPropType( Property ) == "integer" )
						Value = Value.tointeger();
					else if ( survivor.GetNetPropType( Property ) == "float" )
						Value = Value.tofloat();
					
					survivor.SetNetProp( Property, Value );
				}
			}
			else
			{
				if ( !Target )
					return;
				
				if ( Target.GetNetPropType( Property ) == "integer" )
					Value = Value.tointeger();
				else if ( Target.GetNetPropType( Property ) == "float" )
					Value = Value.tofloat();
				
				Target.SetNetProp( Property, Value );
			}
		}
	}
	else
	{
		if ( Property.tolower() == "true" )
			Property = 1;
		else if ( Property.tolower() == "false" )
			Property = 0;
		
		if ( player.GetNetPropType( Entity ) == "integer" )
			Property = Property.tointeger();
		else if ( player.GetNetPropType( Entity ) == "float" )
			Property = Property.tofloat();
		
		player.SetNetProp( Entity, Property );
	}
}

::AdminSystem.FrictionCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Value = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	if ( Value )
		Value = Value.tofloat();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetFriction(Value);
	}
	else if ( Entity == "l4d1" )
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.SetFriction(Value);
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.SetFriction(Value);
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.SetFriction(Value);
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.SetFriction(Value);
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.SetFriction(Value);
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.SetFriction(Value);
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.SetFriction(Value);
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.SetFriction(Value);
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.SetFriction(Value);
	}
	else
	{
		if ( Value )
		{
			if ( !Target )
				return;
			
			Target.SetFriction(Value);
		}
		else
			player.SetFriction(Entity.tofloat());
	}
}

::AdminSystem.GravityCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Value = GetArgument(2);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	if ( Value )
		Value = Value.tofloat();
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetGravity(Value);
	}
	else if ( Entity == "l4d1" )
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.SetGravity(Value);
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.SetGravity(Value);
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.SetGravity(Value);
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.SetGravity(Value);
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.SetGravity(Value);
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.SetGravity(Value);
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.SetGravity(Value);
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.SetGravity(Value);
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.SetGravity(Value);
	}
	else
	{
		if ( Value )
		{
			if ( !Target )
				return;
			
			Target.SetGravity(Value);
		}
		else
			player.SetGravity(Entity.tofloat());
	}
}

::AdminSystem.VelocityCmd <- function ( player, args )
{
	local Entity = GetArgument(1);
	local Value = GetArgument(2);
	local Value2 = GetArgument(3);
	local Value3 = GetArgument(4);
	local Target = Utils.GetPlayerFromName(GetArgument(1));

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Entity = Entity.tolower();
	local val = null;
	if ( Value3 )
		val = Vector( Value.tofloat(), Value2.tofloat(), Value3.tofloat());
	else
		val = Vector( Entity.tofloat(), Value.tofloat(), Value2.tofloat());
	
	if ( Entity == "all" )
	{
		foreach(survivor in Players.AliveSurvivors())
			survivor.SetVelocity(val);
	}
	else if ( Entity == "l4d1" )
	{
		foreach(survivor in Players.L4D1Survivors())
			survivor.SetVelocity(val);
	}
	else if ( Entity == "bots" )
	{
		foreach(survivor in Players.AliveSurvivorBots())
			survivor.SetVelocity(val);
	}
	else if ( Entity == "boomer" )
	{
		foreach(boomer in Players.OfType(Z_BOOMER))
			boomer.SetVelocity(val);
	}
	else if ( Entity == "charger" )
	{
		foreach(charger in Players.OfType(Z_CHARGER))
			charger.SetVelocity(val);
	}
	else if ( Entity == "hunter" )
	{
		foreach(hunter in Players.OfType(Z_HUNTER))
			hunter.SetVelocity(val);
	}
	else if ( Entity == "jockey" )
	{
		foreach(jockey in Players.OfType(Z_JOCKEY))
			jockey.SetVelocity(val);
	}
	else if ( Entity == "smoker" )
	{
		foreach(smoker in Players.OfType(Z_SMOKER))
			smoker.SetVelocity(val);
	}
	else if ( Entity == "spitter" )
	{
		foreach(spitter in Players.OfType(Z_SPITTER))
			spitter.SetVelocity(val);
	}
	else if ( Entity == "tank" )
	{
		foreach(tank in Players.OfType(Z_TANK))
			tank.SetVelocity(val);
	}
	else
	{
		if ( Value3 )
		{
			if ( !Target )
				return;
			
			Target.SetVelocity(val);
		}
		else
			player.SetVelocity(val);
	}
}

::AdminSystem.DropFireCmd <- function ( player, args )
{
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 16;
	DropFire( EyePosition );
}

::AdminSystem.DropSpitCmd <- function ( player, args )
{
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	EyePosition.z += 16;
	DropSpit( EyePosition );
}

::AdminSystem.DirectorCmd <- function ( player, args )
{
	local Command = GetArgument(1);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( !AdminSystem.Vars.DirectorDisabled && (Command == "stop" || Command == "off" || Command == "disable") )
	{
		AdminSystem.Vars.DirectorDisabled = true;
		Utils.StopDirector();
		foreach(si in Players.Infected())
		{
			if ( si.IsBot() )
				si.Input( "Kill" );
			else
				si.Input( "SetHealth", "0" );
		}
		foreach(infected in Objects.OfClassname("infected"))
			infected.Input( "Kill" );
		foreach(witch in Objects.OfClassname("witch"))
			witch.Input( "Kill" );
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "Disabled Director");
	}
	else if ( AdminSystem.Vars.DirectorDisabled && (Command == "start" || Command == "on" || Command == "enable") )
	{
		AdminSystem.Vars.DirectorDisabled = false;
		Utils.StartDirector();
		if ( AdminSystem.DisplayMsgs )
			AdminSystem.PrintClientMessage(null, "Enabled Director");
	}
}

::AdminSystem.FinaleCmd <- function ( player, args )
{
	local Command = GetArgument(1);
	
	if ( Command == "start" )
		Utils.StartFinale();
	else if ( Command == "rescue" )
		Utils.TriggerRescue();
}

::AdminSystem.RestartCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Utils.TriggerStage( STAGE_RESULTS, 0 );
}

::AdminSystem.LimitCmd <- function ( player, args )
{
	local Infected = GetArgument(1);
	local Value = GetArgument(2);

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Infected = Infected.tolower();
	Value = Value.tointeger();
	
	if ( Infected == "common" || Infected == "infected" )
	{
		SessionOptions.cm_CommonLimit <- Value;
		SessionOptions.CommonLimit <- Value;
	}
	else if ( Infected == "maxspecials" )
	{
		SessionOptions.cm_MaxSpecials <- Value;
		SessionOptions.MaxSpecials <- Value;
	}
	else if ( Infected == "dominator" )
		SessionOptions.cm_DominatorLimit <- Value;
	else if ( Infected == "smoker" )
		SessionOptions.SmokerLimit <- Value;
	else if ( Infected == "boomer" )
		SessionOptions.BoomerLimit <- Value;
	else if ( Infected == "hunter" )
		SessionOptions.HunterLimit <- Value;
	else if ( Infected == "spitter" )
		SessionOptions.SpitterLimit <- Value;
	else if ( Infected == "jockey" )
		SessionOptions.JockeyLimit <- Value;
	else if ( Infected == "charger" )
		SessionOptions.ChargerLimit <- Value;
	else if ( Infected == "witch" )
	{
		SessionOptions.WitchLimit <- Value;
		SessionOptions.cm_WitchLimit <- Value;
	}
	else if ( Infected == "tank" )
	{
		SessionOptions.TankLimit <- Value;
		SessionOptions.cm_TankLimit <- Value;
	}
}

::AdminSystem.ZombieCmd <- function ( player, args )
{
	local ZombieModel = GetArgument(1);
	local Amount = GetArgument(2);
	local Auto = GetArgument(3);
	local EyePosition = player.GetLookingLocation();
	local MaxDist = 2400;
	local MinDist = 1200;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( !ZombieModel )
		return;
	
	if ( Amount )
	{
		if ( Amount == "auto" )
		{
			Amount = 1;
			Auto = true;
		}
		else
			Amount = Amount.tointeger();
	}
	else
		Amount = 1;
	
	for ( local i = 0; i < Amount; i++ )
	{
		if ( ZombieModel == "ceda" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_ceda", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_ceda", EyePosition);
		}
		else if ( ZombieModel == "mud" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_mud", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_mud", EyePosition);
		}
		else if ( ZombieModel == "roadcrew" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_roadcrew", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_roadcrew", EyePosition);
		}
		else if ( ZombieModel == "roadcrew_rain" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_roadcrew_rain", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_roadcrew_rain", EyePosition);
		}
		else if ( ZombieModel == "fallen_survivor" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_fallen_survivor", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_fallen_survivor", EyePosition);
		}
		else if ( ZombieModel == "riot" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_riot", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_riot", EyePosition);
		}
		else if ( ZombieModel == "clown" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_clown", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_clown", EyePosition);
		}
		else if ( ZombieModel == "jimmy" )
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, "common_male_jimmy", MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie("common_male_jimmy", EyePosition);
		}
		else if ( ZombieModel == "random" )
		{
			local randZombie = Utils.GetRandValueFromArray(AdminSystem.ZombieModels);
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, randZombie, MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie(randZombie, EyePosition);
		}
		else
		{
			if ( Auto )
				Utils.SpawnZombieNearPlayer( player, ZombieModel, MaxDist, MinDist );
			else
				Utils.SpawnCommentaryZombie(ZombieModel, EyePosition);
		}
	}
}

::AdminSystem.ZSpawnCmd <- function ( player, args )
{
	local InfectedType = GetArgument(1);
	local Amount = GetArgument(2);
	local Auto = GetArgument(3);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Amount )
	{
		if ( Amount == "auto" )
		{
			Amount = 1;
			Auto = true;
		}
		else
			Amount = Amount.tointeger();
	}
	else
		Amount = 1;
	
	if ( AdminSystem.Vars.DirectorDisabled )
	{
		SessionOptions.cm_DominatorLimit <- 99;
		SessionOptions.cm_MaxSpecials <- 99;
		SessionOptions.MaxSpecials <- 99;
		//SessionOptions.cm_CommonLimit <- 99;
		//SessionOptions.CommonLimit <- 99;
		SessionOptions.SmokerLimit <- 99;
		SessionOptions.BoomerLimit <- 99;
		SessionOptions.HunterLimit <- 99;
		SessionOptions.SpitterLimit <- 99;
		SessionOptions.JockeyLimit <- 99;
		SessionOptions.ChargerLimit <- 99;
		SessionOptions.WitchLimit <- 99;
		SessionOptions.cm_WitchLimit <- 99;
		SessionOptions.TankLimit <- 99;
		SessionOptions.cm_TankLimit <- 99;
	}
	
	for ( local i = 0; i < Amount; i++ )
	{
		if ( InfectedType == "common" || InfectedType == "infected" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_COMMON );
			else
				Utils.SpawnZombie( Z_COMMON, EyePosition );
		}
		else if ( InfectedType == "smoker" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_SMOKER );
			else
				Utils.SpawnZombie( Z_SMOKER, EyePosition );
		}
		else if ( InfectedType == "boomer" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_BOOMER );
			else
				Utils.SpawnZombie( Z_BOOMER, EyePosition );
		}
		else if ( InfectedType == "leaker" )
		{
			if ( Auto )
				Utils.SpawnLeaker();
			else
				Utils.SpawnLeaker( EyePosition );
		}
		else if ( InfectedType == "hunter" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_HUNTER );
			else
				Utils.SpawnZombie( Z_HUNTER, EyePosition );
		}
		else if ( InfectedType == "spitter" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_SPITTER );
			else
				Utils.SpawnZombie( Z_SPITTER, EyePosition );
		}
		else if ( InfectedType == "jockey" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_JOCKEY );
			else
				Utils.SpawnZombie( Z_JOCKEY, EyePosition );
		}
		else if ( InfectedType == "charger" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_CHARGER );
			else
				Utils.SpawnZombie( Z_CHARGER, EyePosition );
		}
		else if ( InfectedType == "witch" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_WITCH );
			else
				Utils.SpawnZombie( Z_WITCH, EyePosition );
		}
		else if ( InfectedType == "tank" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_TANK );
			else
				Utils.SpawnZombie( Z_TANK, EyePosition );
		}
		else if ( InfectedType == "mob" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_MOB );
			else
				Utils.SpawnZombie( Z_MOB, EyePosition );
		}
		else if ( InfectedType == "witch_bride" )
		{
			if ( Auto )
				Utils.SpawnZombie( Z_WITCH_BRIDE );
			else
				Utils.SpawnZombie( Z_WITCH_BRIDE, EyePosition );
		}
		else if ( InfectedType == "random" )
		{
			local random_spawn = RandomInt( 0, 9 );
			
			if ( random_spawn == 9 )
				random_spawn = 11;
			
			if ( Auto )
				Utils.SpawnZombie( random_spawn );
			else
				Utils.SpawnZombie( random_spawn, EyePosition );
		}
	}
	
	if ( AdminSystem.Vars.DirectorDisabled )
	{
		SessionOptions.cm_DominatorLimit <- 0;
		SessionOptions.cm_MaxSpecials <- 0;
		SessionOptions.MaxSpecials <- 0;
		//SessionOptions.cm_CommonLimit <- 0;
		//SessionOptions.CommonLimit <- 0;
		SessionOptions.SmokerLimit <- 0;
		SessionOptions.BoomerLimit <- 0;
		SessionOptions.HunterLimit <- 0;
		SessionOptions.SpitterLimit <- 0;
		SessionOptions.JockeyLimit <- 0;
		SessionOptions.ChargerLimit <- 0;
		SessionOptions.WitchLimit <- 0;
		SessionOptions.cm_WitchLimit <- 0;
		SessionOptions.TankLimit <- 0;
		SessionOptions.cm_TankLimit <- 0;
	}
}

::AdminSystem.ExecCmd <- function ( player, args )
{
	local File = GetArgument(1);
	local fileContents = null;

	if ( File.find(".") != null )
		fileContents = FileToString("admin system/" + File);
	else
		fileContents = FileToString("admin system/" + File + ".txt");
	
	if ( !fileContents )
		return;
	
	local file = split(fileContents, "\r\n");
	
	foreach (cmd in file)
	{
		if ( cmd.find("//") != null )
		{
			cmd = Utils.StringReplace(cmd, "//" + ".*", "");
			cmd = rstrip(cmd);
		}
		if ( cmd != "" )
		{
			if ( cmd.find("scripted_user_func") != null )
				SendToServerConsole( cmd );
			else
			{
				local value = cmd.slice( cmd.find(" ") );
				value = Utils.StringReplace( value, " ", "" );
				value = Utils.StringReplace( value, "\"", "" );
				local command = Utils.StringReplace( cmd, value, "" );
				command = Utils.StringReplace( command, " ", "" );
				command = Utils.StringReplace( command, "\"", "" );
				
				if ( cmd.find("scripted_user_func") == null )
					Convars.SetValue( command, value );
			}
		}
	}
}

::AdminSystem.EndGameCmd <- function ( player, args )
{
	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	Utils.RollStatsCrawl();
}

::AdminSystem.AlarmCarCmd <- function ( player, args )
{
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	GroundPosition.y = EyeAngles.y;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	IncludeScript("Admin_System/entitygroups/admin_alarmcar_group", g_MapScript);
	
	local alarmcarEntityGroup = g_MapScript.GetEntityGroup( "AlarmCar" );
	g_MapScript.SpawnSingleAt( alarmcarEntityGroup, EyePosition + Vector(0,0,100), GroundPosition );
}

::AdminSystem.GunCmd <- function ( player, args )
{
	local Type = GetArgument(1);
	local EyePosition = player.GetLookingLocation();
	local EyeAngles = player.GetEyeAngles();
	local GroundPosition = QAngle(0,0,0);

	GroundPosition.y = EyeAngles.y;

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Type == "rifle" )
	{
		IncludeScript("Admin_System/entitygroups/auto_rifle_group", g_MapScript);
		
		local autoRifleEntityGroup = g_MapScript.GetEntityGroup( "AutoRifle" );
		g_MapScript.SpawnSingleAt( autoRifleEntityGroup, EyePosition + Vector(0,0,50), GroundPosition );
	}
	else if ( Type == "hunting_rifle" )
	{
		IncludeScript("Admin_System/entitygroups/auto_hunting_rifle_group", g_MapScript);
		
		local autoHuntingRifleEntityGroup = g_MapScript.GetEntityGroup( "AutoHuntingRifle" );
		g_MapScript.SpawnSingleAt( autoHuntingRifleEntityGroup, EyePosition + Vector(0,0,50), GroundPosition );
	}
	else if ( Type == "autoshotgun" )
	{
		IncludeScript("Admin_System/entitygroups/auto_autoshotgun_group", g_MapScript);
		
		local autoAutoShotgunEntityGroup = g_MapScript.GetEntityGroup( "AutoAutoShotgun" );
		g_MapScript.SpawnSingleAt( autoAutoShotgunEntityGroup, EyePosition + Vector(0,0,50), GroundPosition );
	}
}

::AdminSystem.ResourceCmd <- function ( player, args )
{
	local Amount = GetArgument(1);
	local EyePosition = player.GetLookingLocation();

	if (!AdminSystem.IsPrivileged( player ))
		return;
	
	if ( Amount )
		Amount = Amount.tointeger();
	else
		Amount = 1;
	
	for ( local i = 0; i < Amount; i++ )
	{
		local coinEntityGroup = g_MapScript.GetEntityGroup( "PlaceableResource" );
		g_MapScript.SpawnSingleAt( coinEntityGroup, EyePosition + Vector(0,0,16) , QAngle( 0,0,0) );
	}
}
