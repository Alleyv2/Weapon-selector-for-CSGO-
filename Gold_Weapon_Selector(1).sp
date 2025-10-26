#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <menus>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Weapon Selector",
	author = "imi-tat0r and update by Alley",
	description = "Allows players to set a preference for weapons after CS:GO inventory services got shut down.",
	version = "v2.0.1",
	url = "https://github.com/Alleyv2"
};

bool g_bPrefersR8[MAXPLAYERS + 1] = {false};
bool g_bPrefersUSP[MAXPLAYERS + 1] = {false};
bool g_bPrefersCZ[MAXPLAYERS + 1] = {false};
bool g_bPrefersM4A1S[MAXPLAYERS + 1] = {false};
int g_iPlayerNotified[MAXPLAYERS + 1] = {0};

int r8Price = 600;
int deaglePrice = 700;
int czTecPrice = 500;
int m4a1sPrice = 2900;
int m4a4Price = 3100;

public void OnPluginStart()
{
	RegConsoleCmd("sm_weapon", Command_Weapon);
	RegConsoleCmd("sm_gun", Command_Weapon);
	RegConsoleCmd("sm_w", Command_Weapon);
	RegConsoleCmd("sm_guns", Command_Weapon);
	RegConsoleCmd("sm_prefs", Command_Weapon);

	RegConsoleCmd("deagle", Command_Deagle);
	RegConsoleCmd("r8", Command_Revolver);
	RegConsoleCmd("revolver", Command_Revolver);

	RegConsoleCmd("usp", Command_USP);
	RegConsoleCmd("p2000", Command_P2000);
	RegConsoleCmd("p2k", Command_P2000);

	RegConsoleCmd("cz", Command_CZ);
	RegConsoleCmd("tec", Command_NotCZ);
	RegConsoleCmd("tec9", Command_NotCZ);
	RegConsoleCmd("fiveseven", Command_NotCZ);
	RegConsoleCmd("57", Command_NotCZ);

	RegConsoleCmd("m4a1s", Command_M4A1S);
	RegConsoleCmd("m4a4", Command_M4A4);

	HookEvent("player_spawn", Player_Spawn);
	HookEvent("item_purchase", Event_ItemPurchase);

	AutoExecConfig(true, "weapon_selector");
}

public void OnClientConnected(int client)
{
	ResetUserPreference(client);
}

public void OnClientDisconnect(int client)
{
	ResetUserPreference(client);
}

public void Player_Spawn(Event event, const char[] name, bool dB)
{
	CreateTimer(0.1, HandleSpawn, event.GetInt("userid"));
}

public Action HandleSpawn(Handle timer, any userId)
{
	int client = GetClientOfUserId(userId);
	if (!client || !IsClientInGame(client))
		return Plugin_Stop;

	if (GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return Plugin_Stop;

	if (g_iPlayerNotified[client] >= 1)
		return Plugin_Stop;

	PrintToChat(client, " \x07[\x04Alley Project\x01] Type \x07!weapon\x01 to open weapon selection menu");
	PrintToChat(client, " \x07[\x04Alley Project\x01] Quick commands: \x07!deagle\x01, \x07!r8\x01, \x07!usp\x01, \x07!p2000\x01, \x07!cz\x01, \x07!tec9\x01, \x07!m4a1s\x01, \x07!m4a4\x01");

	ShowCurrentPreferences(client);
	g_iPlayerNotified[client]++;

	return Plugin_Stop;
}

void ShowCurrentPreferences(int client)
{
	char deaglePref[64], uspPref[64], czPref[64], m4Pref[64];

	Format(deaglePref, sizeof(deaglePref), "Heavy Pistol: %s", g_bPrefersR8[client] ? "\x04R8 Revolver" : "\x04Desert Eagle");
	Format(uspPref, sizeof(uspPref), "CT Pistol: %s", g_bPrefersUSP[client] ? "\x04USP-S" : "\x04P2000");
	Format(czPref, sizeof(czPref), "Auto Pistol: %s", g_bPrefersCZ[client] ? "\x04CZ75-Auto" : "\x04Tec-9/Five-Seven");
	Format(m4Pref, sizeof(m4Pref), "M4 Rifle: %s", g_bPrefersM4A1S[client] ? "\x04M4A1-S" : "\x04M4A4");

	PrintToChat(client, " \x07[\x04Alley Project\x01] Current preferences:");
	PrintToChat(client, " \x07[\x04Alley Project\x01] %s", deaglePref);
	PrintToChat(client, " \x07[\x04Alley Project\x01] %s", uspPref);
	PrintToChat(client, " \x07[\x04Alley Project\x01] %s", czPref);
	PrintToChat(client, " \x07[\x04Alley Project\x01] %s", m4Pref);
}

public Action Command_Weapon(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	ShowMainWeaponMenu(client);
	return Plugin_Handled;
}

void ShowMainWeaponMenu(int client)
{
	Menu menu = new Menu(MainWeaponMenuHandler);
	menu.SetTitle("Alley Project - Weapon Selection\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\nCurrent Preferences:\n");

	char deaglePref[64], uspPref[64], czPref[64], m4Pref[64];

	Format(deaglePref, sizeof(deaglePref), "Heavy Pistol: %s", g_bPrefersR8[client] ? "R8 Revolver" : "Desert Eagle");
	Format(uspPref, sizeof(uspPref), "CT Pistol: %s", g_bPrefersUSP[client] ? "USP-S" : "P2000");
	Format(czPref, sizeof(czPref), "Auto Pistol: %s", g_bPrefersCZ[client] ? "CZ75-Auto" : "Tec-9/Five-Seven");
	Format(m4Pref, sizeof(m4Pref), "M4 Rifle: %s", g_bPrefersM4A1S[client] ? "M4A1-S" : "M4A4");

	menu.AddItem("", deaglePref, ITEMDRAW_DISABLED);
	menu.AddItem("", uspPref, ITEMDRAW_DISABLED);
	menu.AddItem("", czPref, ITEMDRAW_DISABLED);
	menu.AddItem("", m4Pref, ITEMDRAW_DISABLED);

	menu.AddItem("", "▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬", ITEMDRAW_DISABLED);
	menu.AddItem("heavy", "Change Heavy Pistol");
	menu.AddItem("pistol", "Change CT Pistol");
	menu.AddItem("auto", "Change Auto Pistol");
	menu.AddItem("rifle", "Change M4 Rifle");
	menu.AddItem("all", "Quick Select All");

	menu.ExitButton = true;
	menu.Display(client, 20);
}

public int MainWeaponMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(choice, info, sizeof(info));

		if (StrEqual(info, "heavy"))
		{
			ShowHeavyPistolMenu(client);
		}
		else if (StrEqual(info, "pistol"))
		{
			ShowCTPistolMenu(client);
		}
		else if (StrEqual(info, "auto"))
		{
			ShowAutoPistolMenu(client);
		}
		else if (StrEqual(info, "rifle"))
		{
			ShowM4RifleMenu(client);
		}
		else if (StrEqual(info, "all"))
		{
			ShowQuickSelectMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void ShowHeavyPistolMenu(int client)
{
	Menu menu = new Menu(HeavyPistolMenuHandler);
	menu.SetTitle("Heavy Pistol Selection\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\nChoose your preferred heavy pistol:");

	if (g_bPrefersR8[client])
	{
		menu.AddItem("deagle", "Desert Eagle");
		menu.AddItem("r8", "R8 Revolver [SELECTED]");
	}
	else
	{
		menu.AddItem("deagle", "Desert Eagle [SELECTED]");
		menu.AddItem("r8", "R8 Revolver");
	}

	menu.AddItem("back", "← Back to Main Menu");
	menu.ExitButton = true;
	menu.Display(client, 20);
}

public int HeavyPistolMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(choice, info, sizeof(info));

		if (StrEqual(info, "deagle"))
		{
			g_bPrefersR8[client] = false;
			PrintToChat(client, " \x07[\x04Alley Project\x01] Heavy pistol preference set to: \x04Desert Eagle");
			ShowHeavyPistolMenu(client);
		}
		else if (StrEqual(info, "r8"))
		{
			g_bPrefersR8[client] = true;
			PrintToChat(client, " \x07[\x04Alley Project\x01] Heavy pistol preference set to: \x04R8 Revolver");
			ShowHeavyPistolMenu(client);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void ShowCTPistolMenu(int client)
{
	Menu menu = new Menu(CTPistolMenuHandler);
	menu.SetTitle("CT Pistol Selection\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\nChoose your preferred CT pistol:");

	if (g_bPrefersUSP[client])
	{
		menu.AddItem("p2000", "P2000");
		menu.AddItem("usp", "USP-S [SELECTED]");
	}
	else
	{
		menu.AddItem("p2000", "P2000 [SELECTED]");
		menu.AddItem("usp", "USP-S");
	}

	menu.AddItem("back", "← Back to Main Menu");
	menu.ExitButton = true;
	menu.Display(client, 20);
}

public int CTPistolMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(choice, info, sizeof(info));

		if (StrEqual(info, "p2000"))
		{
			g_bPrefersUSP[client] = false;
			PrintToChat(client, " \x07[\x04Alley Project\x01] CT pistol preference set to: \x04P2000");
			ShowCTPistolMenu(client);
		}
		else if (StrEqual(info, "usp"))
		{
			g_bPrefersUSP[client] = true;
			PrintToChat(client, " \x07[\x04Alley Project\x01] CT pistol preference set to: \x04USP-S");
			ShowCTPistolMenu(client);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void ShowAutoPistolMenu(int client)
{
	Menu menu = new Menu(AutoPistolMenuHandler);
	menu.SetTitle("Auto Pistol Selection\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\nChoose your preferred auto pistol:");

	if (g_bPrefersCZ[client])
	{
		menu.AddItem("tec9", "Tec-9/Five-Seven");
		menu.AddItem("cz", "CZ75-Auto [SELECTED]");
	}
	else
	{
		menu.AddItem("tec9", "Tec-9/Five-Seven [SELECTED]");
		menu.AddItem("cz", "CZ75-Auto");
	}

	menu.AddItem("back", "← Back to Main Menu");
	menu.ExitButton = true;
	menu.Display(client, 20);
}

public int AutoPistolMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(choice, info, sizeof(info));

		if (StrEqual(info, "tec9"))
		{
			g_bPrefersCZ[client] = false;
			PrintToChat(client, " \x07[\x04Alley Project\x01] Auto pistol preference set to: \x04Tec-9/Five-Seven");
			ShowAutoPistolMenu(client);
		}
		else if (StrEqual(info, "cz"))
		{
			g_bPrefersCZ[client] = true;
			PrintToChat(client, " \x07[\x04Alley Project\x01] Auto pistol preference set to: \x04CZ75-Auto");
			ShowAutoPistolMenu(client);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void ShowM4RifleMenu(int client)
{
	Menu menu = new Menu(M4RifleMenuHandler);
	menu.SetTitle("M4 Rifle Selection\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\nChoose your preferred M4 rifle:");

	if (g_bPrefersM4A1S[client])
	{
		menu.AddItem("m4a4", "M4A4");
		menu.AddItem("m4a1s", "M4A1-S [SELECTED]");
	}
	else
	{
		menu.AddItem("m4a4", "M4A4 [SELECTED]");
		menu.AddItem("m4a1s", "M4A1-S");
	}

	menu.AddItem("back", "← Back to Main Menu");
	menu.ExitButton = true;
	menu.Display(client, 20);
}

public int M4RifleMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(choice, info, sizeof(info));

		if (StrEqual(info, "m4a4"))
		{
			g_bPrefersM4A1S[client] = false;
			PrintToChat(client, " \x07[\x04Alley Project\x01] M4 rifle preference set to: \x04M4A4");
			ShowM4RifleMenu(client);
		}
		else if (StrEqual(info, "m4a1s"))
		{
			g_bPrefersM4A1S[client] = true;
			PrintToChat(client, " \x07[\x04Alley Project\x01] M4 rifle preference set to: \x04M4A1-S");
			ShowM4RifleMenu(client);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void ShowQuickSelectMenu(int client)
{
	Menu menu = new Menu(QuickSelectMenuHandler);
	menu.SetTitle("Quick Select All\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\nChoose a preset for all weapons:");

	menu.AddItem("preset1", "Preset 1: Deagle + P2000 + Tec9/57 + M4A4");
	menu.AddItem("preset2", "Preset 2: R8 + USP-S + CZ + M4A1-S");
	menu.AddItem("preset3", "Preset 3: Deagle + USP-S + Tec9/57 + M4A4");
	menu.AddItem("preset4", "Preset 4: R8 + P2000 + CZ + M4A1-S");

	menu.AddItem("back", "← Back to Main Menu");
	menu.ExitButton = true;
	menu.Display(client, 20);
}

public int QuickSelectMenuHandler(Menu menu, MenuAction action, int client, int choice)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(choice, info, sizeof(info));

		if (StrEqual(info, "preset1"))
		{
			g_bPrefersR8[client] = false;
			g_bPrefersUSP[client] = false;
			g_bPrefersCZ[client] = false;
			g_bPrefersM4A1S[client] = false;
			PrintToChat(client, " \x07[\x04Alley Project\x01] All weapons set to: \x04Preset 1");
		}
		else if (StrEqual(info, "preset2"))
		{
			g_bPrefersR8[client] = true;
			g_bPrefersUSP[client] = true;
			g_bPrefersCZ[client] = true;
			g_bPrefersM4A1S[client] = true;
			PrintToChat(client, " \x07[\x04Alley Project\x01] All weapons set to: \x04Preset 2");
		}
		else if (StrEqual(info, "preset3"))
		{
			g_bPrefersR8[client] = false;
			g_bPrefersUSP[client] = true;
			g_bPrefersCZ[client] = false;
			g_bPrefersM4A1S[client] = false;
			PrintToChat(client, " \x07[\x04Alley Project\x01] All weapons set to: \x04Preset 3");
		}
		else if (StrEqual(info, "preset4"))
		{
			g_bPrefersR8[client] = true;
			g_bPrefersUSP[client] = false;
			g_bPrefersCZ[client] = true;
			g_bPrefersM4A1S[client] = true;
			PrintToChat(client, " \x07[\x04Alley Project\x01] All weapons set to: \x04Preset 4");
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
			return 0;
		}

		ShowMainWeaponMenu(client);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

public Action Command_Deagle(int client, int args)
{
	g_bPrefersR8[client] = false;
	PrintToChat(client, " \x07[\x04Alley Project\x01] Heavy pistol preference set to: \x04Desert Eagle");
	return Plugin_Handled;
}

public Action Command_Revolver(int client, int args)
{
	g_bPrefersR8[client] = true;
	PrintToChat(client, " \x07[\x04Alley Project\x01] Heavy pistol preference set to: \x04R8 Revolver");
	return Plugin_Handled;
}

public Action Command_USP(int client, int args)
{
	g_bPrefersUSP[client] = true;
	PrintToChat(client, " \x07[\x04Alley Project\x01] CT pistol preference set to: \x04USP-S");
	return Plugin_Handled;
}

public Action Command_P2000(int client, int args)
{
	g_bPrefersUSP[client] = false;
	PrintToChat(client, " \x07[\x04Alley Project\x01] CT pistol preference set to: \x04P2000");
	return Plugin_Handled;
}

public Action Command_CZ(int client, int args)
{
	g_bPrefersCZ[client] = true;
	PrintToChat(client, " \x07[\x04Alley Project\x01] Auto pistol preference set to: \x04CZ75-Auto");
	return Plugin_Handled;
}

public Action Command_NotCZ(int client, int args)
{
	g_bPrefersCZ[client] = false;
	PrintToChat(client, " \x07[\x04Alley Project\x01] Auto pistol preference set to: \x04Tec-9/Five-Seven");
	return Plugin_Handled;
}

public Action Command_M4A1S(int client, int args)
{
	g_bPrefersM4A1S[client] = true;
	PrintToChat(client, " \x07[\x04Alley Project\x01] M4 rifle preference set to: \x04M4A1-S");
	return Plugin_Handled;
}

public Action Command_M4A4(int client, int args)
{
	g_bPrefersM4A1S[client] = false;
	PrintToChat(client, " \x07[\x04Alley Project\x01] M4 rifle preference set to: \x04M4A4");
	return Plugin_Handled;
}

public Action CS_OnBuyCommand(int client, const char[] szWeapon)
{
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || GetEntProp(client, Prop_Send, "m_bInBuyZone") == 0)
		return Plugin_Continue;

	if(GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return Plugin_Continue;

	char str[128] = "weapon_";
	StrCat(str, sizeof(str), szWeapon);

	if (StrEqual(str, "weapon_deagle"))
		return HandleBuyEvent(client, "weapon_revolver", r8Price, g_bPrefersR8[client]);
	else if (StrEqual(str, "weapon_revolver"))
		return HandleBuyEvent(client, "weapon_deagle", deaglePrice, !g_bPrefersR8[client]);

	else if (StrEqual(str, "weapon_hkp2000"))
	{
		if (g_bPrefersUSP[client])
			return Plugin_Continue;
		else
			return Plugin_Continue;
	}
	else if (StrEqual(str, "weapon_usp_silencer"))
	{
		if (!g_bPrefersUSP[client])
			return Plugin_Continue;
		else
			return Plugin_Continue;
	}

	else if (StrEqual(str, "weapon_m4a1"))
		return HandleBuyEvent(client, "weapon_m4a1_silencer", m4a1sPrice, g_bPrefersM4A1S[client]);
	else if (StrEqual(str, "weapon_m4a1_silencer"))
		return HandleBuyEvent(client, "weapon_m4a1", m4a4Price, !g_bPrefersM4A1S[client]);

	else if (StrEqual(str, "weapon_tec9") || StrEqual(str, "weapon_fiveseven"))
		return HandleBuyEvent(client, "weapon_cz75a", czTecPrice, g_bPrefersCZ[client]);
	else if (StrEqual(str, "weapon_cz75a"))
	{
		if (GetClientTeam(client) == CS_TEAM_T)
			return HandleBuyEvent(client, "weapon_tec9", czTecPrice, !g_bPrefersCZ[client]);
		else
			return HandleBuyEvent(client, "weapon_fiveseven", czTecPrice, !g_bPrefersCZ[client]);
	}
	else
		return Plugin_Continue;
}

public void Event_ItemPurchase(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	char weapon[64];
	event.GetString("weapon", weapon, sizeof(weapon));

	if (StrEqual(weapon, "hkp2000") && g_bPrefersUSP[client])
	{
		CreateTimer(0.1, Timer_ReplaceUSP, GetClientUserId(client));
	}
	else if (StrEqual(weapon, "usp_silencer") && !g_bPrefersUSP[client])
	{
		CreateTimer(0.1, Timer_ReplaceP2000, GetClientUserId(client));
	}
}

public Action Timer_ReplaceUSP(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Stop;

	int weapon = GetPlayerWeaponSlot(client, 1);
	if (weapon != -1)
	{
		char classname[32];
		GetEntityClassname(weapon, classname, sizeof(classname));
		if (StrEqual(classname, "weapon_hkp2000"))
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);

			GivePlayerItem(client, "weapon_usp_silencer");
			PrintToChat(client, " \x07[\x04Alley Project\x01] P2000 automatically replaced with \x04USP-S");
		}
	}

	return Plugin_Stop;
}

public Action Timer_ReplaceP2000(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Stop;

	int weapon = GetPlayerWeaponSlot(client, 1);
	if (weapon != -1)
	{
		char classname[32];
		GetEntityClassname(weapon, classname, sizeof(classname));
		if (StrEqual(classname, "weapon_usp_silencer"))
		{
			RemovePlayerItem(client, weapon);
			RemoveEdict(weapon);

			GivePlayerItem(client, "weapon_hkp2000");
			PrintToChat(client, " \x07[\x04Alley Project\x01] USP-S automatically replaced with \x04P2000");
		}
	}

	return Plugin_Stop;
}

public Action CS_OnGetWeaponPrice(int client, const char[] weapon, int& price)
{
	if (StrEqual(weapon, "weapon_deagle") || StrEqual(weapon, "weapon_revolver"))
	{
		price = g_bPrefersR8[client] ? r8Price : deaglePrice;
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action HandleBuyEvent(int client, const char[] weapon_replace, int price_replace, bool prefers)
{
	if (!prefers)
		return Plugin_Continue;

	int money = GetClientMoney(client);
	if (money < price_replace)
		return Plugin_Handled;
	else if (HasPlayerWeapon(client, weapon_replace))
		return Plugin_Handled;
	else
	{
		DropSecondary(client);
		SetClientMoney(client, money - price_replace);
		GivePlayerItem(client, weapon_replace);
		return Plugin_Handled;
	}
}

public bool HasPlayerWeapon(int client, const char[] weapon)
{
	int m_hMyWeapons = FindSendPropInfo("CBasePlayer", "m_hMyWeapons");
	if(m_hMyWeapons == -1)
		return false;

	for(int offset = 0; offset < 128; offset += 4)
	{
		int weap = GetEntDataEnt2(client, m_hMyWeapons+offset);

		if(IsValidEdict(weap))
		{
			char classname[32];
			GetWeaponClassname(weap, -1, classname, sizeof(classname));

			if(StrEqual(classname, weapon))
				return true;
		}
	}

	return false;
}

public void DropSecondary(int client)
{
	int slot2 = GetPlayerWeaponSlot(client, 1);

	if (slot2 != -1)
	{
		CS_DropWeapon(client, slot2, false);
	}
}

public int GetClientMoney(int client)
{
	return GetEntProp(client, Prop_Send, "m_iAccount");
}

public void SetClientMoney(int client, int money)
{
	SetEntProp(client, Prop_Send, "m_iAccount", money);
}

public void OnMapStart()
{
	for (int i = 1; i <= MaxClients; i++)
		ResetUserPreference(i);
}

void ResetUserPreference(int client)
{
	g_bPrefersR8[client] = false;
	g_bPrefersUSP[client] = false;
	g_bPrefersCZ[client] = false;
	g_bPrefersM4A1S[client] = false;
	g_iPlayerNotified[client] = 0;
}

stock void GetWeaponClassname(int weapon, int index = -1, char[] classname, int maxLen)
{
	GetEdictClassname(weapon, classname, maxLen);

	if(index == -1)
		index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

	switch(index)
	{
		case 60: strcopy(classname, maxLen, "weapon_m4a1_silencer");
		case 61: strcopy(classname, maxLen, "weapon_usp_silencer");
		case 63: strcopy(classname, maxLen, "weapon_cz75a");
		case 64: strcopy(classname, maxLen, "weapon_revolver");
	}
}
