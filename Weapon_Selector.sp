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
	version = "v2.0.3",
	url = "https://github.com/Alleyv2"
};

bool g_bPrefersR8[MAXPLAYERS + 1] = {false};
bool g_bPrefersUSP[MAXPLAYERS + 1] = {true};
bool g_bPrefersCZ[MAXPLAYERS + 1] = {false};
bool g_bPrefersM4A1S[MAXPLAYERS + 1] = {false};
int g_iPlayerNotified[MAXPLAYERS + 1] = {0};

int r8Price = 600;
int deaglePrice = 700;
int czTecPrice = 500;
int uspP2000Price = 200;
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

	LoadTranslations("weapon_selector.phrases");
	LoadTranslations("common.phrases");
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
	CreateTimer(0.5, HandleSpawn, event.GetInt("userid"));
}

public Action HandleSpawn(Handle timer, any userId)
{
	int client = GetClientOfUserId(userId);
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Stop;

	if (GetClientTeam(client) <= CS_TEAM_SPECTATOR)
		return Plugin_Stop;

	ReplaceWeaponsByPreference(client);

	if (g_iPlayerNotified[client] >= 1)
		return Plugin_Stop;

	SetGlobalTransTarget(client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Spawn_Menu_Info");
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Spawn_Quick_Commands");

	ShowCurrentPreferences(client);
	g_iPlayerNotified[client]++;

	return Plugin_Stop;
}

void ReplaceWeaponsByPreference(int client)
{
	int team = GetClientTeam(client);

	if (team == CS_TEAM_CT)
	{
		int pistolSlot = GetPlayerWeaponSlot(client, 1);
		if (pistolSlot != -1)
		{
			char classname[32];
			GetEntityClassname(pistolSlot, classname, sizeof(classname));

			if (StrEqual(classname, "weapon_hkp2000") && g_bPrefersUSP[client])
			{
				RemovePlayerItem(client, pistolSlot);
				RemoveEdict(pistolSlot);
				GivePlayerItem(client, "weapon_usp_silencer");
			}
			else if (StrEqual(classname, "weapon_usp_silencer") && !g_bPrefersUSP[client])
			{
				RemovePlayerItem(client, pistolSlot);
				RemoveEdict(pistolSlot);
				GivePlayerItem(client, "weapon_hkp2000");
			}
		}
	}

	if (team == CS_TEAM_CT)
	{
		int rifleSlot = GetPlayerWeaponSlot(client, 0);
		if (rifleSlot != -1)
		{
			char classname[32];
			GetEntityClassname(rifleSlot, classname, sizeof(classname));

			if (StrEqual(classname, "weapon_m4a1") && g_bPrefersM4A1S[client])
			{
				RemovePlayerItem(client, rifleSlot);
				RemoveEdict(rifleSlot);
				GivePlayerItem(client, "weapon_m4a1_silencer");
			}
			else if (StrEqual(classname, "weapon_m4a1_silencer") && !g_bPrefersM4A1S[client])
			{
				RemovePlayerItem(client, rifleSlot);
				RemoveEdict(rifleSlot);
				GivePlayerItem(client, "weapon_m4a1");
			}
		}
	}

	int heavyPistolSlot = GetPlayerWeaponSlot(client, 1);
	if (heavyPistolSlot != -1)
	{
		char classname[32];
		GetEntityClassname(heavyPistolSlot, classname, sizeof(classname));

		if (StrEqual(classname, "weapon_deagle") && g_bPrefersR8[client])
		{
			RemovePlayerItem(client, heavyPistolSlot);
			RemoveEdict(heavyPistolSlot);
			GivePlayerItem(client, "weapon_revolver");
		}
		else if (StrEqual(classname, "weapon_revolver") && !g_bPrefersR8[client])
		{
			RemovePlayerItem(client, heavyPistolSlot);
			RemoveEdict(heavyPistolSlot);
			GivePlayerItem(client, "weapon_deagle");
		}
	}

	int autoPistolSlot = GetPlayerWeaponSlot(client, 1);
	if (autoPistolSlot != -1)
	{
		char classname[32];
		GetEntityClassname(autoPistolSlot, classname, sizeof(classname));

		if (team == CS_TEAM_T)
		{
			if (StrEqual(classname, "weapon_tec9") && g_bPrefersCZ[client])
			{
				RemovePlayerItem(client, autoPistolSlot);
				RemoveEdict(autoPistolSlot);
				GivePlayerItem(client, "weapon_cz75a");
			}
			else if (StrEqual(classname, "weapon_cz75a") && !g_bPrefersCZ[client])
			{
				RemovePlayerItem(client, autoPistolSlot);
				RemoveEdict(autoPistolSlot);
				GivePlayerItem(client, "weapon_tec9");
			}
		}
		else if (team == CS_TEAM_CT)
		{
			if (StrEqual(classname, "weapon_fiveseven") && g_bPrefersCZ[client])
			{
				RemovePlayerItem(client, autoPistolSlot);
				RemoveEdict(autoPistolSlot);
				GivePlayerItem(client, "weapon_cz75a");
			}
			else if (StrEqual(classname, "weapon_cz75a") && !g_bPrefersCZ[client])
			{
				RemovePlayerItem(client, autoPistolSlot);
				RemoveEdict(autoPistolSlot);
				GivePlayerItem(client, "weapon_fiveseven");
			}
		}
	}
}

void ShowCurrentPreferences(int client)
{
	SetGlobalTransTarget(client);

	char deaglePref[128], uspPref[128], czPref[128], m4Pref[128];

	char sHeavyPistol[64], sCTPistol[64], sAutoPistol[64], sM4Rifle[64];
	char sDeagle[32], sR8[32], sUSP[32], sP2000[32], sTec9[32], sCZ[32], sM4A4[32], sM4A1S[32];

	Format(sHeavyPistol, sizeof(sHeavyPistol), "%T", "Heavy_Pistol", client);
	Format(sCTPistol, sizeof(sCTPistol), "%T", "CT_Pistol", client);
	Format(sAutoPistol, sizeof(sAutoPistol), "%T", "Auto_Pistol", client);
	Format(sM4Rifle, sizeof(sM4Rifle), "%T", "M4_Rifle", client);

	Format(sDeagle, sizeof(sDeagle), "%T", "Desert_Eagle", client);
	Format(sR8, sizeof(sR8), "%T", "R8_Revolver", client);
	Format(sUSP, sizeof(sUSP), "%T", "USP_S", client);
	Format(sP2000, sizeof(sP2000), "%T", "P2000", client);
	Format(sTec9, sizeof(sTec9), "%T", "Tec9_FiveSeven", client);
	Format(sCZ, sizeof(sCZ), "%T", "CZ75_Auto", client);
	Format(sM4A4, sizeof(sM4A4), "%T", "M4A4", client);
	Format(sM4A1S, sizeof(sM4A1S), "%T", "M4A1_S", client);

	Format(deaglePref, sizeof(deaglePref), "%s: \x0C%s", sHeavyPistol, g_bPrefersR8[client] ? sR8 : sDeagle);
	Format(uspPref, sizeof(uspPref), "%s: \x0C%s", sCTPistol, g_bPrefersUSP[client] ? sUSP : sP2000);
	Format(czPref, sizeof(czPref), "%s: \x0C%s", sAutoPistol, g_bPrefersCZ[client] ? sCZ : sTec9);
	Format(m4Pref, sizeof(m4Pref), "%s: \x0C%s", sM4Rifle, g_bPrefersM4A1S[client] ? sM4A1S : sM4A4);

	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Current_Preferences");
	PrintToChat(client, " \x0C[LEGION PUB] \x01%s", deaglePref);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%s", uspPref);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%s", czPref);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%s", m4Pref);
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

	SetGlobalTransTarget(client);

	char sTitle[256];
	char sMenuTitle[64], sCurrentPrefs[64], sChangeHeavy[64], sChangeCTPistol[64], sChangeAuto[64], sChangeM4[64], sQuickSelect[64];
	char sDeaglePref[128], sUSPPref[128], sCZPref[128], sM4Pref[128];
	char sDeagle[32], sR8[32], sUSP[32], sP2000[32], sTec9[32], sCZ[32], sM4A4[32], sM4A1S[32];
	char sExit[32];

	Format(sMenuTitle, sizeof(sMenuTitle), "%T", "Menu_Title", client);
	Format(sCurrentPrefs, sizeof(sCurrentPrefs), "%T", "Current_Preferences", client);
	Format(sChangeHeavy, sizeof(sChangeHeavy), "%T", "Change_Heavy_Pistol", client);
	Format(sChangeCTPistol, sizeof(sChangeCTPistol), "%T", "Change_CT_Pistol", client);
	Format(sChangeAuto, sizeof(sChangeAuto), "%T", "Change_Auto_Pistol", client);
	Format(sChangeM4, sizeof(sChangeM4), "%T", "Change_M4_Rifle", client);
	Format(sQuickSelect, sizeof(sQuickSelect), "%T", "Quick_Select_All", client);
	Format(sExit, sizeof(sExit), "%T", "Exit", client);

	Format(sDeagle, sizeof(sDeagle), "%T", "Desert_Eagle", client);
	Format(sR8, sizeof(sR8), "%T", "R8_Revolver", client);
	Format(sUSP, sizeof(sUSP), "%T", "USP_S", client);
	Format(sP2000, sizeof(sP2000), "%T", "P2000", client);
	Format(sTec9, sizeof(sTec9), "%T", "Tec9_FiveSeven", client);
	Format(sCZ, sizeof(sCZ), "%T", "CZ75_Auto", client);
	Format(sM4A4, sizeof(sM4A4), "%T", "M4A4", client);
	Format(sM4A1S, sizeof(sM4A1S), "%T", "M4A1_S", client);

	Format(sDeaglePref, sizeof(sDeaglePref), "%s", g_bPrefersR8[client] ? sR8 : sDeagle);
	Format(sUSPPref, sizeof(sUSPPref), "%s", g_bPrefersUSP[client] ? sUSP : sP2000);
	Format(sCZPref, sizeof(sCZPref), "%s", g_bPrefersCZ[client] ? sCZ : sTec9);
	Format(sM4Pref, sizeof(sM4Pref), "%s", g_bPrefersM4A1S[client] ? sM4A1S : sM4A4);

	int money = GetClientMoney(client);

	Format(sTitle, sizeof(sTitle), "%s\n$%d\n\n%s:", sMenuTitle, money, sCurrentPrefs);
	menu.SetTitle(sTitle);

	char sDisplay[128];
	Format(sDisplay, sizeof(sDisplay), "1. %s", sDeaglePref);
	menu.AddItem("", sDisplay, ITEMDRAW_DISABLED);

	Format(sDisplay, sizeof(sDisplay), "2. %s", sUSPPref);
	menu.AddItem("", sDisplay, ITEMDRAW_DISABLED);

	Format(sDisplay, sizeof(sDisplay), "3. %s", sCZPref);
	menu.AddItem("", sDisplay, ITEMDRAW_DISABLED);

	Format(sDisplay, sizeof(sDisplay), "4. %s", sM4Pref);
	menu.AddItem("", sDisplay, ITEMDRAW_DISABLED);

	menu.AddItem("", "5.", ITEMDRAW_SPACER);
	menu.AddItem("heavy", sChangeHeavy);
	menu.AddItem("pistol", sChangeCTPistol);
	menu.AddItem("auto", sChangeAuto);
	menu.AddItem("rifle", sChangeM4);
	menu.AddItem("all", sQuickSelect);

	menu.AddItem("", "8.", ITEMDRAW_SPACER);
	menu.AddItem("exit", sExit);

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
		else if (StrEqual(info, "exit"))
		{
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

	SetGlobalTransTarget(client);

	char sTitle[256];
	char sMenuTitle[64], sChooseHeavy[64], sBack[64], sExit[32];
	char sDeagle[32], sR8[32], sSelected[16];

	Format(sMenuTitle, sizeof(sMenuTitle), "%T", "Heavy_Pistol_Selection", client);
	Format(sChooseHeavy, sizeof(sChooseHeavy), "%T", "Choose_Heavy_Pistol", client);
	Format(sBack, sizeof(sBack), "%T", "Back_To_Main", client);
	Format(sExit, sizeof(sExit), "%T", "Exit", client);
	Format(sDeagle, sizeof(sDeagle), "%T", "Desert_Eagle", client);
	Format(sR8, sizeof(sR8), "%T", "R8_Revolver", client);
	Format(sSelected, sizeof(sSelected), "%T", "Selected", client);

	Format(sTitle, sizeof(sTitle), "%s\n\n%s:", sMenuTitle, sChooseHeavy);
	menu.SetTitle(sTitle);

	if (g_bPrefersR8[client])
	{
		menu.AddItem("deagle", sDeagle);
		char sR8Selected[64];
		Format(sR8Selected, sizeof(sR8Selected), "%s (%s)", sR8, sSelected);
		menu.AddItem("r8", sR8Selected);
	}
	else
	{
		char sDeagleSelected[64];
		Format(sDeagleSelected, sizeof(sDeagleSelected), "%s (%s)", sDeagle, sSelected);
		menu.AddItem("deagle", sDeagleSelected);
		menu.AddItem("r8", sR8);
	}

	menu.AddItem("back", sBack);
	menu.AddItem("exit", sExit);

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
			SetGlobalTransTarget(client);

			char sWeapon[32];
			Format(sWeapon, sizeof(sWeapon), "%T", "Desert_Eagle", client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_Heavy", sWeapon);
			ShowHeavyPistolMenu(client);
		}
		else if (StrEqual(info, "r8"))
		{
			g_bPrefersR8[client] = true;
			SetGlobalTransTarget(client);

			char sWeapon[32];
			Format(sWeapon, sizeof(sWeapon), "%T", "R8_Revolver", client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_Heavy", sWeapon);
			ShowHeavyPistolMenu(client);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
		}
		else if (StrEqual(info, "exit"))
		{
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

	SetGlobalTransTarget(client);

	char sTitle[256];
	char sMenuTitle[64], sChooseCT[64], sBack[64], sExit[32];
	char sUSP[32], sP2000[32], sSelected[16];

	Format(sMenuTitle, sizeof(sMenuTitle), "%T", "CT_Pistol_Selection", client);
	Format(sChooseCT, sizeof(sChooseCT), "%T", "Choose_CT_Pistol", client);
	Format(sBack, sizeof(sBack), "%T", "Back_To_Main", client);
	Format(sExit, sizeof(sExit), "%T", "Exit", client);
	Format(sUSP, sizeof(sUSP), "%T", "USP_S", client);
	Format(sP2000, sizeof(sP2000), "%T", "P2000", client);
	Format(sSelected, sizeof(sSelected), "%T", "Selected", client);

	Format(sTitle, sizeof(sTitle), "%s\n\n%s:", sMenuTitle, sChooseCT);
	menu.SetTitle(sTitle);

	if (g_bPrefersUSP[client])
	{
		menu.AddItem("p2000", sP2000);
		char sUSPSelected[64];
		Format(sUSPSelected, sizeof(sUSPSelected), "%s (%s)", sUSP, sSelected);
		menu.AddItem("usp", sUSPSelected);
	}
	else
	{
		char sP2000Selected[64];
		Format(sP2000Selected, sizeof(sP2000Selected), "%s (%s)", sP2000, sSelected);
		menu.AddItem("p2000", sP2000Selected);
		menu.AddItem("usp", sUSP);
	}

	menu.AddItem("back", sBack);
	menu.AddItem("exit", sExit);

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
			SetGlobalTransTarget(client);

			char sWeapon[32];
			Format(sWeapon, sizeof(sWeapon), "%T", "P2000", client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_CT", sWeapon);
			ShowCTPistolMenu(client);
		}
		else if (StrEqual(info, "usp"))
		{
			g_bPrefersUSP[client] = true;
			SetGlobalTransTarget(client);

			char sWeapon[32];
			Format(sWeapon, sizeof(sWeapon), "%T", "USP_S", client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_CT", sWeapon);
			ShowCTPistolMenu(client);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
		}
		else if (StrEqual(info, "exit"))
		{
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

	SetGlobalTransTarget(client);

	char sTitle[256];
	char sMenuTitle[64], sChooseAuto[64], sBack[64], sExit[32];
	char sTec9[64], sCZ[32], sSelected[16];

	Format(sMenuTitle, sizeof(sMenuTitle), "%T", "Auto_Pistol_Selection", client);
	Format(sChooseAuto, sizeof(sChooseAuto), "%T", "Choose_Auto_Pistol", client);
	Format(sBack, sizeof(sBack), "%T", "Back_To_Main", client);
	Format(sExit, sizeof(sExit), "%T", "Exit", client);
	Format(sTec9, sizeof(sTec9), "%T", "Tec9_FiveSeven", client);
	Format(sCZ, sizeof(sCZ), "%T", "CZ75_Auto", client);
	Format(sSelected, sizeof(sSelected), "%T", "Selected", client);

	Format(sTitle, sizeof(sTitle), "%s\n\n%s:", sMenuTitle, sChooseAuto);
	menu.SetTitle(sTitle);

	if (g_bPrefersCZ[client])
	{
		menu.AddItem("tec9", sTec9);
		char sCZSelected[64];
		Format(sCZSelected, sizeof(sCZSelected), "%s (%s)", sCZ, sSelected);
		menu.AddItem("cz", sCZSelected);
	}
	else
	{
		char sTec9Selected[64];
		Format(sTec9Selected, sizeof(sTec9Selected), "%s (%s)", sTec9, sSelected);
		menu.AddItem("tec9", sTec9Selected);
		menu.AddItem("cz", sCZ);
	}

	menu.AddItem("back", sBack);
	menu.AddItem("exit", sExit);

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
			SetGlobalTransTarget(client);

			char sWeapon[32];
			Format(sWeapon, sizeof(sWeapon), "%T", "Tec9_FiveSeven", client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_Auto", sWeapon);
			ShowAutoPistolMenu(client);
		}
		else if (StrEqual(info, "cz"))
		{
			g_bPrefersCZ[client] = true;
			SetGlobalTransTarget(client);

			char sWeapon[32];
			Format(sWeapon, sizeof(sWeapon), "%T", "CZ75_Auto", client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_Auto", sWeapon);
			ShowAutoPistolMenu(client);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
		}
		else if (StrEqual(info, "exit"))
		{
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

	SetGlobalTransTarget(client);

	char sTitle[256];
	char sMenuTitle[64], sChooseM4[64], sBack[64], sExit[32];
	char sM4A4[32], sM4A1S[32], sSelected[16];

	Format(sMenuTitle, sizeof(sMenuTitle), "%T", "M4_Rifle_Selection", client);
	Format(sChooseM4, sizeof(sChooseM4), "%T", "Choose_M4_Rifle", client);
	Format(sBack, sizeof(sBack), "%T", "Back_To_Main", client);
	Format(sExit, sizeof(sExit), "%T", "Exit", client);
	Format(sM4A4, sizeof(sM4A4), "%T", "M4A4", client);
	Format(sM4A1S, sizeof(sM4A1S), "%T", "M4A1_S", client);
	Format(sSelected, sizeof(sSelected), "%T", "Selected", client);

	Format(sTitle, sizeof(sTitle), "%s\n\n%s:", sMenuTitle, sChooseM4);
	menu.SetTitle(sTitle);

	if (g_bPrefersM4A1S[client])
	{
		menu.AddItem("m4a4", sM4A4);
		char sM4A1SSelected[64];
		Format(sM4A1SSelected, sizeof(sM4A1SSelected), "%s (%s)", sM4A1S, sSelected);
		menu.AddItem("m4a1s", sM4A1SSelected);
	}
	else
	{
		char sM4A4Selected[64];
		Format(sM4A4Selected, sizeof(sM4A4Selected), "%s (%s)", sM4A4, sSelected);
		menu.AddItem("m4a4", sM4A4Selected);
		menu.AddItem("m4a1s", sM4A1S);
	}

	menu.AddItem("back", sBack);
	menu.AddItem("exit", sExit);

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
			SetGlobalTransTarget(client);

			char sWeapon[32];
			Format(sWeapon, sizeof(sWeapon), "%T", "M4A4", client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_M4", sWeapon);
			ShowM4RifleMenu(client);
		}
		else if (StrEqual(info, "m4a1s"))
		{
			g_bPrefersM4A1S[client] = true;
			SetGlobalTransTarget(client);

			char sWeapon[32];
			Format(sWeapon, sizeof(sWeapon), "%T", "M4A1_S", client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_M4", sWeapon);
			ShowM4RifleMenu(client);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
		}
		else if (StrEqual(info, "exit"))
		{
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

	SetGlobalTransTarget(client);

	char sTitle[256];
	char sMenuTitle[64], sChoosePreset[64], sBack[64], sExit[32];
	char sPreset1[128], sPreset2[128], sPreset3[128], sPreset4[128];
	char sDeagle[32], sR8[32], sUSP[32], sP2000[32], sTec9[64], sCZ[32], sM4A4[32], sM4A1S[32];

	Format(sMenuTitle, sizeof(sMenuTitle), "%T", "Quick_Select_Title", client);
	Format(sChoosePreset, sizeof(sChoosePreset), "%T", "Choose_Preset", client);
	Format(sBack, sizeof(sBack), "%T", "Back_To_Main", client);
	Format(sExit, sizeof(sExit), "%T", "Exit", client);

	Format(sDeagle, sizeof(sDeagle), "%T", "Desert_Eagle", client);
	Format(sR8, sizeof(sR8), "%T", "R8_Revolver", client);
	Format(sUSP, sizeof(sUSP), "%T", "USP_S", client);
	Format(sP2000, sizeof(sP2000), "%T", "P2000", client);
	Format(sTec9, sizeof(sTec9), "%T", "Tec9_FiveSeven", client);
	Format(sCZ, sizeof(sCZ), "%T", "CZ75_Auto", client);
	Format(sM4A4, sizeof(sM4A4), "%T", "M4A4", client);
	Format(sM4A1S, sizeof(sM4A1S), "%T", "M4A1_S", client);

	Format(sTitle, sizeof(sTitle), "%s\n\n%s:", sMenuTitle, sChoosePreset);
	menu.SetTitle(sTitle);

	Format(sPreset1, sizeof(sPreset1), "%T %d: %s + %s + %s + %s", "Preset", client, 1, sDeagle, sP2000, sTec9, sM4A4);
	Format(sPreset2, sizeof(sPreset2), "%T %d: %s + %s + %s + %s", "Preset", client, 2, sR8, sUSP, sCZ, sM4A1S);
	Format(sPreset3, sizeof(sPreset3), "%T %d: %s + %s + %s + %s", "Preset", client, 3, sDeagle, sUSP, sTec9, sM4A4);
	Format(sPreset4, sizeof(sPreset4), "%T %d: %s + %s + %s + %s", "Preset", client, 4, sR8, sP2000, sCZ, sM4A1S);

	menu.AddItem("preset1", sPreset1);
	menu.AddItem("preset2", sPreset2);
	menu.AddItem("preset3", sPreset3);
	menu.AddItem("preset4", sPreset4);

	menu.AddItem("back", sBack);
	menu.AddItem("exit", sExit);

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
			SetGlobalTransTarget(client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "All_Weapons_Set", "Preset", 1);
		}
		else if (StrEqual(info, "preset2"))
		{
			g_bPrefersR8[client] = true;
			g_bPrefersUSP[client] = true;
			g_bPrefersCZ[client] = true;
			g_bPrefersM4A1S[client] = true;
			SetGlobalTransTarget(client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "All_Weapons_Set", "Preset", 2);
		}
		else if (StrEqual(info, "preset3"))
		{
			g_bPrefersR8[client] = false;
			g_bPrefersUSP[client] = true;
			g_bPrefersCZ[client] = false;
			g_bPrefersM4A1S[client] = false;
			SetGlobalTransTarget(client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "All_Weapons_Set", "Preset", 3);
		}
		else if (StrEqual(info, "preset4"))
		{
			g_bPrefersR8[client] = true;
			g_bPrefersUSP[client] = false;
			g_bPrefersCZ[client] = true;
			g_bPrefersM4A1S[client] = true;
			SetGlobalTransTarget(client);
			PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "All_Weapons_Set", "Preset", 4);
		}
		else if (StrEqual(info, "back"))
		{
			ShowMainWeaponMenu(client);
			return 0;
		}
		else if (StrEqual(info, "exit"))
		{
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
	SetGlobalTransTarget(client);

	char sWeapon[32];
	Format(sWeapon, sizeof(sWeapon), "%T", "Desert_Eagle", client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_Heavy", sWeapon);
	return Plugin_Handled;
}

public Action Command_Revolver(int client, int args)
{
	g_bPrefersR8[client] = true;
	SetGlobalTransTarget(client);

	char sWeapon[32];
	Format(sWeapon, sizeof(sWeapon), "%T", "R8_Revolver", client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_Heavy", sWeapon);
	return Plugin_Handled;
}

public Action Command_USP(int client, int args)
{
	g_bPrefersUSP[client] = true;
	SetGlobalTransTarget(client);

	char sWeapon[32];
	Format(sWeapon, sizeof(sWeapon), "%T", "USP_S", client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_CT", sWeapon);
	return Plugin_Handled;
}

public Action Command_P2000(int client, int args)
{
	g_bPrefersUSP[client] = false;
	SetGlobalTransTarget(client);

	char sWeapon[32];
	Format(sWeapon, sizeof(sWeapon), "%T", "P2000", client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_CT", sWeapon);
	return Plugin_Handled;
}

public Action Command_CZ(int client, int args)
{
	g_bPrefersCZ[client] = true;
	SetGlobalTransTarget(client);

	char sWeapon[32];
	Format(sWeapon, sizeof(sWeapon), "%T", "CZ75_Auto", client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_Auto", sWeapon);
	return Plugin_Handled;
}

public Action Command_NotCZ(int client, int args)
{
	g_bPrefersCZ[client] = false;
	SetGlobalTransTarget(client);

	char sWeapon[32];
	Format(sWeapon, sizeof(sWeapon), "%T", "Tec9_FiveSeven", client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_Auto", sWeapon);
	return Plugin_Handled;
}

public Action Command_M4A1S(int client, int args)
{
	g_bPrefersM4A1S[client] = true;
	SetGlobalTransTarget(client);

	char sWeapon[32];
	Format(sWeapon, sizeof(sWeapon), "%T", "M4A1_S", client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_M4", sWeapon);
	return Plugin_Handled;
}

public Action Command_M4A4(int client, int args)
{
	g_bPrefersM4A1S[client] = false;
	SetGlobalTransTarget(client);

	char sWeapon[32];
	Format(sWeapon, sizeof(sWeapon), "%T", "M4A4", client);
	PrintToChat(client, " \x0C[LEGION PUB] \x01%t", "Pref_Set_M4", sWeapon);
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
        return HandleBuyEvent(client, "weapon_revolver", r8Price, g_bPrefersR8[client], 1);
    else if (StrEqual(str, "weapon_revolver"))
        return HandleBuyEvent(client, "weapon_deagle", deaglePrice, !g_bPrefersR8[client], 1);

    else if (StrEqual(str, "weapon_hkp2000"))
    {
        if (g_bPrefersUSP[client])
            return HandleBuyEvent(client, "weapon_usp_silencer", uspP2000Price, true, 1);
        else
            return Plugin_Continue;
    }
    else if (StrEqual(str, "weapon_usp_silencer"))
    {
        if (!g_bPrefersUSP[client])
            return HandleBuyEvent(client, "weapon_hkp2000", uspP2000Price, true, 1);
        else
            return Plugin_Continue;
    }

    else if (StrEqual(str, "weapon_m4a1"))
    {
        if (g_bPrefersM4A1S[client])
            return HandleBuyEvent(client, "weapon_m4a1_silencer", m4a1sPrice, true, 0);
        else
            return Plugin_Continue;
    }
    else if (StrEqual(str, "weapon_m4a1_silencer"))
    {
        if (!g_bPrefersM4A1S[client])
            return HandleBuyEvent(client, "weapon_m4a1", m4a4Price, true, 0);
        else
            return Plugin_Continue;
    }

    else if (StrEqual(str, "weapon_tec9") || StrEqual(str, "weapon_fiveseven"))
    {
        if (g_bPrefersCZ[client])
            return HandleBuyEvent(client, "weapon_cz75a", czTecPrice, true, 1);
        else
            return Plugin_Continue;
    }
    else if (StrEqual(str, "weapon_cz75a"))
    {
        if (!g_bPrefersCZ[client])
        {
            if (GetClientTeam(client) == CS_TEAM_T)
                return HandleBuyEvent(client, "weapon_tec9", czTecPrice, true, 1);
            else
                return HandleBuyEvent(client, "weapon_fiveseven", czTecPrice, true, 1);
        }
        else
            return Plugin_Continue;
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

public Action HandleBuyEvent(int client, const char[] weapon_replace, int price_replace, bool prefers, int slot)
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
		DropWeaponSlot(client, slot);
		SetClientMoney(client, money - price_replace);
		GivePlayerItem(client, weapon_replace);
		return Plugin_Handled;
	}
}

void DropWeaponSlot(int client, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (weapon != -1)
	{
		CS_DropWeapon(client, weapon, false);
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
	g_bPrefersUSP[client] = true;
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
