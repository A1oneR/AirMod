#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
#include <colors>

#define L4D_TEAM_SURVIVOR 2
#define L4D_WEAPON_SLOT_PRIMARY 0

int
g_iAmmoOffset;

StringMap
g_hTrieWeaponList;

public Plugin myinfo =
{
	name = "[L4D2] Report remaining ammo",
	author = "ProjectSky",
	description = "report primary weapon remaining ammo",
	version = "0.0.7",
	url = "me@imsky.cc"
}

public void OnPluginStart()
{
	RegConsoleCmd("sm_ammo", Command_ReportAmmo);

	g_iAmmoOffset = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");

	g_hTrieWeaponList = new StringMap();
	g_hTrieWeaponList.SetString("smg", "UZI");
	g_hTrieWeaponList.SetString("smg_silenced", "SMG");
	g_hTrieWeaponList.SetString("smg_mp5", "MP5");
	g_hTrieWeaponList.SetString("shotgun_chrome", "铁喷");
	g_hTrieWeaponList.SetString("pumpshotgun", "木喷");
	g_hTrieWeaponList.SetString("autoshotgun", "XM1014");
	g_hTrieWeaponList.SetString("shotgun_spas", "SPAS12");
	g_hTrieWeaponList.SetString("rifle", "M16");
	g_hTrieWeaponList.SetString("hunting_rifle", "M14");
	g_hTrieWeaponList.SetString("rifle_ak47", "AK47");
	g_hTrieWeaponList.SetString("rifle_sg552", "SG552");
	g_hTrieWeaponList.SetString("rifle_desert", "SCAR");
	g_hTrieWeaponList.SetString("rifle_m60", "M60");
	g_hTrieWeaponList.SetString("sniper_military", "G3SG1");
	g_hTrieWeaponList.SetString("sniper_awp", "AWP");
	g_hTrieWeaponList.SetString("sniper_scout", "鸟狙");
	g_hTrieWeaponList.SetString("grenade_launcher", "榴弹发射器");
}

Action Command_ReportAmmo(int client, int args)
{
	if (client && IsClientInGame(client))
	{
		static char wName[32];
		static int clip, ammo, weapon;
		weapon = GetPlayerWeaponSlot(client, L4D_WEAPON_SLOT_PRIMARY);

		if (!IsValidEntity(weapon) || GetClientTeam(client) != L4D_TEAM_SURVIVOR || !IsPlayerAlive(client))
		{
			CPrintToChat(client, "{default}<{olive}提示{default}> 当前状态无法使用该命令!");
			return Plugin_Continue;
		}

		clip = GetWeaponClip(weapon);
		ammo = GetWeaponAmmo(client, weapon);

		FormatWeaponName(weapon, wName, sizeof(wName));
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == GetClientTeam(client))
			{
				if (clip || ammo)
				{
					CPrintToChat(i, "{blue}%N{default} : %s 剩余弹药 [{olive}%i/%i{default}]", client, wName, clip, ammo);
				}
				else
				{
					CPrintToChat(i, "{blue}%N{default} : %s 没子弹了!!", client, wName);
				}
			}
		}
	}
	return Plugin_Handled;
}

bool FormatWeaponName(int weapon, char[] buffer, int maxlen)
{
	GetEdictClassname(weapon, buffer, maxlen);

	return g_hTrieWeaponList.GetString(buffer[7], buffer, maxlen);
}

int GetWeaponClip(int weapon)
{
	return GetEntProp(weapon, Prop_Send, "m_iClip1");
}

int GetWeaponAmmo(int client, int weapon)
{
	int offset = g_iAmmoOffset + (GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType") * 4);

	return GetEntData(client, offset);
}