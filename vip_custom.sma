// Copyright 2015 Vaqtincha

/** V.I.P Custom Weapons
*
*	Last update:
*	  25/10/2015
*	
*	Cvars:
*	vip_give_deagle - Giving Deagle on new round (def. 0)
*	vip_give_equip - Giving HE/FG/SG/Defuser/Armor on new round (def. 1)
*	vip_allchat_viewer - Set whether vip's see or not all messages 
*	(Alive, dead and team-only) (def. 0)
*
*
*	Cmds:
*	weaponmenu or (say /wm) - Free guns menu
*	
*	Credits:
*	- Safety1st - for plugin "Weapon Menu Hardcoded" (edited by me)
*	- Eg@r4$il - for plugin "Admins are VIPs + grenades + kevlar" (edited by me)
*	- Arion - for plugin "Admin Tag and Colors" (optimized & fixed by me)
*	- xPaw - for code "scoreBoard "VIP" string"
*	- MrBone - for pieces of advice
*	- c-s.net.ua members
*/

/*----------------------------------------- CONFIG START ------------------------------*/

#define ACCESS_FLAG ADMIN_LEVEL_H  		// flag 'n' by default
#define VIPTAG 						// uncomment to enable scoreBoard "VIP" string			
#define PREFIXVIP ""			// comment to disable [V.I.P] chat prefix and green chat ( team color,  green,  default)
#define VIPINFO							// comment to disable VIP connected info, help
#define PLANTER							// comment to disable "removing the speed limit while planting"

#define HPARMOR							// comment to disable hp & ar menu item
#define EQUIPMENT_ITEM					// comment to disable eq menu item
const giAllowedRoundEqDgl = 2			// round when items Equip/Deagle become available
const giAllowedRoundFM = 2         		// round when items Famas/Galil become available
const giAllowedRoundM4AK = 3			// round when items M4A1/AK47 become available
const giAllowedRoundAWP = 4				// round when items AWP/Equipment become available

const giAllowedRoundShopMenu = 2		// round when item "Weapons Shop" become available

/*------------------------------------------ CONFIG END -------------------------------*/

#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <ColorChat>


#define PLUGIN_NAME "V.I.P Custom Weapons"
#define PLUGIN_VERSION "0.0.5"
#define PLUGIN_AUTHOR "Vaqtincha"

// macro; %1 - variable being modified, %2 - player id
#define CheckFlag(%1,%2)  (%1 &   (1 << (%2 & 31)))
#define SetFlag(%1,%2)    (%1 |=  (1 << (%2 & 31)))
#define ClearFlag(%1,%2)  (%1 &= ~(1 << (%2 & 31)))

#define CHECK_ALIVE is_user_alive
#define CHECK_ACCESS get_user_flags
const MENUKEYS = MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0

new give_equip, give_dgl
new gbIsUsed
new giCounter

new g_iM4A1PluginId, g_iM4A1Give
new g_iAK47PluginId, g_iAK47Give
new g_iAWPPluginId, g_iAWPGive




public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	
#if defined VIPTAG	
	register_message( get_user_msgid("ScoreAttrib"), "msgScoreAttrib" )
#endif

	new mapname[4]
	get_mapname(mapname, 3)
	if(equali(mapname, "de_") || equali(mapname, "cs_") || equali(mapname,"$"))
	{
		// Cvars
		give_dgl = register_cvar("vip_give_deagle","0")
		give_equip = register_cvar("vip_give_equip","1")
		
		// Cmds
		register_clcmd( "weaponmenu", "MenuCommand" )
		register_clcmd( "say /wm", "MenuCommand" )
		register_menucmd( register_menuid( "WeaponMenu" ),MENUKEYS, "MenuHandler" )
		register_menucmd( register_menuid( "ExtrasMenu" ),MENUKEYS, "MenuHandlerExtras" )
		register_menucmd( register_menuid( "ShopMenu" ),MENUKEYS, "MenuHandlerShop" )

		// Events
		RegisterHam(Ham_Spawn, "player", "playerspawned", 1)
#if defined PLANTER
		register_event("BarTime", "bomb_planting", "be", "1=3")
#endif
		register_event( "HLTV", "Event_NewRound", "a", "1=0", "2=0" )
		register_event( "TextMsg", "Event_NewGame", "a", "2=#Game_will_restart_in", "2=#Game_Commencing" )
	}
}

public plugin_cfg()
{
	g_iM4A1PluginId = is_plugin_loaded("V.I.P Custom M4A1");
	if( g_iM4A1PluginId > 0 )
	{
		g_iM4A1Give = get_func_id("buyM4a1", g_iM4A1PluginId);
	}
	
	g_iAK47PluginId = is_plugin_loaded("V.I.P Custom AK-47");
	if( g_iAK47PluginId > 0 )
	{
		g_iAK47Give = get_func_id("buyAk47", g_iAK47PluginId);
	}

	g_iAWPPluginId = is_plugin_loaded("V.I.P Custom AWP");
	if( g_iAWPPluginId > 0 )
	{
		g_iAWPGive = get_func_id("buyAwp", g_iAWPPluginId);
	}
	
}

public Event_NewRound(id)
{
	gbIsUsed = 0
	giCounter++
	if(is_user_bot(id))
	{
	g_iAK47Give
	}
}

public Event_NewGame()
{
	giCounter = 0
}

#if defined VIPTAG
	// ScoreBoard "VIP" String

public msgScoreAttrib(const MsgId, const MsgType, const MsgDest)
{
	if(get_msg_arg_int(2) || !(CHECK_ACCESS(get_msg_arg_int(1)) & ACCESS_FLAG))
		return
	set_msg_arg_int(2, ARG_BYTE, (1<<2))
}
#endif


#if defined VIPINFO
	// vip connected info/help
public client_authorized(id)
{
	set_task(1.0, "vip_connected", id)
}

public vip_connected(id)
{
	if(CHECK_ACCESS(id) & ACCESS_FLAG )
	{
		new name[32];
		get_user_name(id, name, 31);
		ColorChat(0, RED, "[Ultimate Weapons]Присоединился V.I.P - %s", name);
	}
}

	// Color chat code
	
stock Color_Print(const id, const input[], any:...)
{
   new count = 1, players[32], i
   static msg[191]
   vformat(msg, 190, input, 3)
     
   replace_all(msg, 190, "!g", "^4") // Green Color
   replace_all(msg, 190, "!n", "^1") // Default Color
   replace_all(msg, 190, "!t", "^3") // Team Color
   
   if(id)players[0] = id; else get_players(players, count, "h")
   {
      for(i = 0; i < count; i++)
      {
         if(is_user_connected(players[i]))
         {
            message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i])
            write_byte(players[i]);
            write_string(msg);
            message_end();
         }
      }
   }
}
#endif

#if defined PREFIXVIP
	// [V.I.P] prefix and green chat

public client_connect(id)
{

}

public client_disconnect(id)
{
}

public avoid_duplicated (msgId, msgDest, receiver)
{
	return PLUGIN_HANDLED
}


#endif


#if defined PLANTER
// COOL TERRORIST Planter  :D
public bomb_planting(id)
{
	if(CHECK_ALIVE(id) && CHECK_ACCESS(id) & ACCESS_FLAG)
		set_user_maxspeed(id,240.0)
}
#endif

public playerspawned(id)
{
	set_task(0.5, "GIVEITEM", id + 6910)
}

	// Equip/Deagle giving

public GIVEITEM(TaskID)
{
	new id = TaskID - 6910

	if( !( CHECK_ACCESS(id) & ACCESS_FLAG ) || !CHECK_ALIVE(id) || giCounter < giAllowedRoundEqDgl)
	{
		return PLUGIN_HANDLED
	}
	else
	{
		if(get_pcvar_num(give_dgl))
		{
			if(user_has_weapon(id,CSW_DEAGLE))
			{
				ExecuteHamB(Ham_GiveAmmo, id, 35, "50ae", 35)
			}
			else
			{
				drop_weapons(id, 2)
				give_item(id,"weapon_deagle")
				ExecuteHamB(Ham_GiveAmmo, id, 35, "50ae", 35)
			}
		}
		if(get_pcvar_num(give_equip))
		{
			give_item(id,"weapon_hegrenade")
			give_item(id,"weapon_flashbang")
			give_item(id,"weapon_flashbang")
			give_item(id,"weapon_smokegrenade")
			give_item(id,"item_assaultsuit")
			set_user_armor(id,100)
			// set_user_health(id,1000) :D
			
			if(get_user_team(id) == 2)
			{
				give_item(id,"item_thighpack")
			}
			
		}
	}

	return PLUGIN_CONTINUE
}

	// Weapon Menu
	
public MenuCommand(id)
{
	new szMenu[512] 		// it is maximum allowed menu size
	new iKeys
	new iLen = formatex( szMenu, charsmax(szMenu), "\yWeapons Menu^n^n" )
	
	new iItemsDisabled
	if( !( CHECK_ACCESS(id) & ACCESS_FLAG ) || !CHECK_ALIVE(id) || CheckFlag( gbIsUsed, id ))
		iItemsDisabled = 1
		
		
	if( iItemsDisabled || giCounter < giAllowedRoundFM )
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d1. \dFamas^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wFamas^n")
			iKeys |= MENU_KEY_1
		}
	if( iItemsDisabled  || giCounter < giAllowedRoundM4AK )
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d2. \dM4A1^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wM4A1^n")
			iKeys |= MENU_KEY_2
		}
		
	if( iItemsDisabled  || giCounter < giAllowedRoundM4AK )
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d3. \dAK-47^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \wAK-47^n")
			iKeys |= MENU_KEY_3
		}
	if( iItemsDisabled  || giCounter < giAllowedRoundAWP )
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d4. \dAWP^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \wAWP^n")
			iKeys |= MENU_KEY_4
		}
	iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "^n")
	if( !( CHECK_ACCESS(id) & ACCESS_FLAG ) || !CHECK_ALIVE(id) || giCounter <giAllowedRoundShopMenu )
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d5. \dWeapons Shop^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y5. \wWeapons Shop^n")
			iKeys |= MENU_KEY_5	
		}
	if( !( CHECK_ACCESS(id) & ACCESS_FLAG ) || !CHECK_ALIVE(id))
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d6. \dExtras Menu^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y6. \wExtras Menu^n")
			iKeys |= MENU_KEY_6	
		}
	formatex( szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \rExit" )
	iKeys |=  MENU_KEY_0|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9
	show_menu( id, iKeys, szMenu, .title = "WeaponMenu" )

	return PLUGIN_HANDLED
}

	// Custom Menu
	
public MenuCommandCustom(id)
{
	new szMenu[512] 		// it is maximum allowed menu size
	new iKeys
	new iLen = formatex( szMenu, charsmax(szMenu), "\yWeapons Shop^n^n" )
	
	new iItemsDisabled
	if( !( CHECK_ACCESS(id) & ACCESS_FLAG ) || !CHECK_ALIVE(id) /*|| CheckFlag( gbIsUsed, id )*/)
		iItemsDisabled = 1
		
	if( iItemsDisabled || g_iM4A1PluginId < 0)
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d1. \dCustom M4A1^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wCustom M4A1^n")
			iKeys |= MENU_KEY_1
		}
	if( iItemsDisabled  || g_iAK47PluginId < 0)
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d2. \dCustom AK-47^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wCustom AK-47^n")
			iKeys |= MENU_KEY_2
		}
	if( iItemsDisabled || g_iAWPPluginId < 0 )
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d3. \dCustom AWP^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \wCustom AWP^n")
			iKeys |= MENU_KEY_3
		}
	iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "^n")
	if( !( CHECK_ACCESS(id) & ACCESS_FLAG ) || !CHECK_ALIVE(id))
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d4. \dBack^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \wBack^n")
			iKeys |= MENU_KEY_4
		}
		
	formatex( szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \rExit" )
	iKeys |=  MENU_KEY_0|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9
	show_menu( id, iKeys, szMenu, .title = "ShopMenu" )

	return PLUGIN_HANDLED
}

	// Extras Menu

public MenuCommandExtras(id)
{
	new szMenu[512] 		// it is maximum allowed menu size
	new iKeys
	new iLen = formatex( szMenu, charsmax(szMenu), "\yExtras Menu^n^n" )
	
	new iItemsDisabled
	if( !( CHECK_ACCESS(id) & ACCESS_FLAG ) || !CHECK_ALIVE(id) || CheckFlag( gbIsUsed, id ))
		iItemsDisabled = 1
	
	if( iItemsDisabled)
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d1. \dAmmoPack^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y1. \wAmmoPack^n")
			iKeys |= MENU_KEY_1
		}
#if defined EQUIPMENT_ITEM
	if( iItemsDisabled)
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d2. \dEquipment^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y2. \wEquipment^n")
			iKeys |= MENU_KEY_2
		}
#endif
#if defined HPARMOR
	if( iItemsDisabled)
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d3. \d50HP & 50AR^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y3. \w50HP & 50AR^n")
			iKeys |= MENU_KEY_3
		}
#endif
	iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "^n")
	if( !( CHECK_ACCESS(id) & ACCESS_FLAG ) || !CHECK_ALIVE(id))
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\d4. \dBack^n")
		}
		else
		{
			iLen += formatex( szMenu[iLen], charsmax(szMenu) - iLen, "\y4. \wBack^n")
			iKeys |= MENU_KEY_4
		}

	formatex( szMenu[iLen], charsmax(szMenu) - iLen, "^n\y0. \rExit" )
	iKeys |=  MENU_KEY_0|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9
	show_menu( id, iKeys, szMenu, .title = "ExtrasMenu" )

	return PLUGIN_HANDLED
}

	// Weapon Menu Func

public MenuHandler(id, key)
{
	if(!CHECK_ALIVE(id))
		return PLUGIN_HANDLED

	switch(key)
	{
		case 0:
		{
			if(user_has_weapon(id,CSW_FAMAS))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cstrike_Already_Own_Weapon")
			}
			else
			{
				drop_weapons(id, 1)
				give_item(id,"weapon_famas")
				ExecuteHamB(Ham_GiveAmmo, id, 90, "556nato", 90)
				SetFlag( gbIsUsed, id )
			}
		}
		case 1:
		{
			if(user_has_weapon(id,CSW_M4A1))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cstrike_Already_Own_Weapon")
			}
			else
			{
				drop_weapons(id, 1)
				give_item(id,"weapon_m4a1")
				ExecuteHamB(Ham_GiveAmmo, id, 90, "556nato", 90)
				SetFlag( gbIsUsed, id )
			}
		}
		case 2:
		{
			if(user_has_weapon(id,CSW_AK47))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cstrike_Already_Own_Weapon")
			}
			else
			{
				drop_weapons(id, 1)
				give_item(id,"weapon_ak47")
				ExecuteHamB(Ham_GiveAmmo, id, 90, "762nato", 90)
				SetFlag( gbIsUsed, id )
			}
		}

		case 3: 
		{
			if(user_has_weapon(id,CSW_AWP))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cstrike_Already_Own_Weapon")
			}
			else
			{
				drop_weapons(id, 1)
				give_item(id,"weapon_awp")
				ExecuteHamB(Ham_GiveAmmo, id, 30, "338magnum", 30)
				SetFlag( gbIsUsed, id )
			}
		}
		case 4:
		{
			MenuCommandCustom(id)
		}
		case 5:
		{
			MenuCommandExtras(id)
		}

	}
	return PLUGIN_HANDLED
}

	// Custom Menu func
	
public MenuHandlerShop(id, key)
{
	if(!CHECK_ALIVE(id))
		return PLUGIN_HANDLED

	switch(key)
	{
		case 0:
		{
			if(user_has_weapon(id,CSW_M4A1))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cstrike_Already_Own_Weapon")
			}
			else
			{
				if(g_iM4A1PluginId > 0 && g_iM4A1Give > 0)
				{
					
					callfunc_begin_i(g_iM4A1Give, g_iM4A1PluginId)
					callfunc_push_int(id);
					callfunc_end();
					// SetFlag( gbIsUsed, id )
				}
			}
		}
		case 1:
		{
			if(user_has_weapon(id,CSW_AK47))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cstrike_Already_Own_Weapon")
			}
			else
			{
				if(g_iAK47PluginId > 0 && g_iAK47Give > 0)
				{
					
					callfunc_begin_i(g_iAK47Give, g_iAK47PluginId)
					callfunc_push_int(id);
					callfunc_end();
					// SetFlag( gbIsUsed, id )
				}
			}
		}

		case 2: 
		{
			if(user_has_weapon(id,CSW_AWP))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cstrike_Already_Own_Weapon")
			}
			else
			{
				if(g_iAWPPluginId > 0 && g_iAWPGive > 0)
				{
					
					callfunc_begin_i(g_iAWPGive, g_iAWPPluginId)
					callfunc_push_int(id);
					callfunc_end();
					// SetFlag( gbIsUsed, id )
				}
			}
		}
		case 3:
		{
			MenuCommand(id)
		}
	}
	return PLUGIN_HANDLED
}

	// Extras Menu Func	

public MenuHandlerExtras(id, key)
{
	if(!CHECK_ALIVE(id))
		return PLUGIN_HANDLED

	switch(key)
	{
		case 0:
		{
			giveammo(id)
		}
#if defined EQUIPMENT_ITEM
		case 1:
		{
			give_item(id,"weapon_hegrenade")
			give_item(id,"weapon_flashbang")
			give_item(id,"weapon_flashbang")
			give_item(id,"weapon_smokegrenade")
			SetFlag( gbIsUsed, id )
		}
#endif
#if defined HPARMOR
		case 2:
		{
			set_user_health(id,min(get_user_health(id)+50,100))
			set_user_armor(id,min(get_user_armor(id)+50,100))
			SetFlag( gbIsUsed, id )
		}
#endif
		case 3:
		{
			MenuCommand(id)
		}
	}

	return PLUGIN_HANDLED
}

	// give ammo code

// Max BP ammo for weapons
new const MAXBPAMMO[31] = { -1, 52, -1, 90, 1, 32, 1, 100, 90, 1, 120, 100, 100, 90, 90, 90, 100, 120, 30, 120, 200, 32, 90, 120, 90, 2, 35, 90, 90, -1, 100 };

// Ammo Type Names for weapons
new const AMMOTYPE[][] = { "", "357sig", "", "762nato", "", "buckshot", "", "45acp", "556nato", "", "9mm", "57mm", "45acp", "556nato", "556nato", "556nato", "45acp", "9mm", "338magnum", "9mm", "556natobox", 
"buckshot", "556nato", "9mm", "762nato", "", "50ae", "556nato", "762nato", "", "57mm" };	

stock giveammo(id)
{
	new weap_ids[32], num_weaps
	get_user_weapons(id, weap_ids, num_weaps)
	for (new i = 0; i < num_weaps; i++)
	{
		new weap_id = weap_ids[i]
		new ammo = MAXBPAMMO[weap_id]
		ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[weap_id], AMMOTYPE[weap_id], MAXBPAMMO[weap_id], ammo)
	}
	return PLUGIN_CONTINUE
}

	// "Drop" code
	
const PRIMARY_WEAPONS_BIT_SUM = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)
const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i, weaponid
	num = 0
	get_user_weapons(id, weapons, num)

	for (i = 0; i < num; i++)
	{
		weaponid = weapons[i]
		if((dropwhat == 1 && ((1<<weaponid) & PRIMARY_WEAPONS_BIT_SUM)) || (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM)))
		{
			static wname[32]
			get_weaponname(weaponid, wname, charsmax(wname))
			engclient_cmd(id, "drop", wname)
		}
	}
}

