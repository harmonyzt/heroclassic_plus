// Copyright 2015 Vaqtincha

/** V.I.P Custom Weapons
*	
*	Original plugin "Golden Ak-47" 1.0 by AlejandroSk
*	w_model added by Shidla
*
*	changelog:
*
* 	"CurWeapon" removed
*	Added czbot support
*	Fixed damage bug
*	Added mapchecker
*	Optimized & rewrited by SISA (thanks very much!)
*/


/*--------------------------- CONFIG START -----------------------------*/

#define DAMAGE 1.2							// damage float
const	COST = 12000						// cost m4a1 12000$
const	VIPCOST = 6000						// cost m4a1 6000$ for VIPs
const giAllowedRound = 2					// round when m4a1 become available
// #define INBUYZONE 						// uncomment to enable check if the player is in the buyzone
// #define BUYTIME							// uncomment to enable check buying time ("mp_buytime")
#define BUYCMD							// uncomment to enable buying command
#define ACCESS_FLAG ADMIN_LEVEL_H  			// flag 'n' by default

new M4A1_V_MODEL[] = "models/custom/v_m4a1.mdl" // view weapon model
new M4A1_P_MODEL[] = "models/custom/p_m4a1.mdl"	// player weapon model
new M4A1_W_MODEL[] = "models/custom/w_m4a1.mdl"	// world weapon model

/*---------------------------- CONFIG END ------------------------------*/


#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <colorchat2>

new bool:g_HasM4a1[33] = false
new bool:g_bHasGA[33] = false
new g_is_connected[33]
new bool: g_BotsRegistered
new giCounter

#if defined BUYTIME
new Float:g_GameTime
#endif

#define is_valid_player(%1) (1 <= %1 <= 32)
#define M4 4444

// offsets
const XO_WEAPON = 4
const XO_CBASEPLAYER = 5
const MAX_ITEM_TYPES = 6
const m_pPlayer = 41
const m_pNext = 42
const m_iId = 43
const m_rgpPlayerItems_CWeaponBox = 34
const m_rgpPlayerItems_CBasePlayer = 367

#define PLUGIN_NAME "V.I.P Custom M4A1"		// don't change this!
#define PLUGIN_VERSION "0.0.5"	  			// version for "V.I.P Custom Weapons" 
#define PLUGIN_AUTHOR "Vaqtincha" 			// don't change this!

public plugin_precache()
{
	precache_model(M4A1_V_MODEL);
	precache_model(M4A1_P_MODEL);
	precache_model(M4A1_W_MODEL);
}

public plugin_init()
{

	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	
	// mapcheck
	new mapname[4]
	get_mapname(mapname, 3)
	if(equali(mapname, "de_") || equali(mapname, "cs_") || equali(mapname,"$"))
	{
#if defined BUYCMD
		register_clcmd( "say /m4", "buyM4a1")
#endif	
		register_event( "TextMsg", "Event_NewGame", "a", "2=#Game_will_restart_in", "2=#Game_Commencing" )
		register_event ( "HLTV", "ev_RoundStart", "a", "1=0", "2=0" )
		register_event("DeathMsg", "Death", "a")

		register_forward(FM_SetModel, "fw_SetModel")

		RegisterHam(Ham_Item_Deploy, "weapon_m4a1" , "Fwd_ItemDeploy_Weap_Post", .Post = 1 )
		RegisterHam(Ham_Item_AttachToPlayer, "weapon_m4a1", "fw_Item_AttachToPlayer" )
		RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	}
	else
		pause("a")
}
public client_connect(id)
{
	g_HasM4a1[id] = false
	g_bHasGA[id] = false
	g_is_connected[id] = true
}

public client_disconnect(id)
{
	g_HasM4a1[id] = false
	g_bHasGA[id] = false
	g_is_connected[id] = false
}

public Event_NewGame()
{
	new iPlayers[32], iNum
	get_players ( iPlayers, iNum )

	for ( --iNum; iNum >= 0; --iNum )
	{
		g_HasM4a1[iPlayers[iNum]] = false
		g_bHasGA[iPlayers[iNum]] = false
	}
	giCounter = 0
}

public ev_RoundStart ()
{
	new iPlayers[32], iNum
	get_players ( iPlayers, iNum )

	for ( --iNum; iNum >= 0; --iNum )
		g_bHasGA[iPlayers[iNum]] = false
#if defined BUYTIME
	g_GameTime = get_gametime()
#endif
	giCounter++
}

// register CZ bots with ham

public client_authorized(id)
{
	if(!g_BotsRegistered && is_user_bot(id))
	{
		set_task(0.1, "register_bots", id);
	}
}

public register_bots(id)
{
	if(!g_BotsRegistered && g_is_connected[id])
	{
		RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage");
		g_BotsRegistered = true;
	}
}

public Death()
{
	g_HasM4a1[read_data(2)] = false
	g_bHasGA[read_data(2)] = false
}

public buyM4a1(id)
{
// check if the player is in the buyzone
#if defined INBUYZONE
	if(!cs_get_user_buyzone(id))
	{
		client_print(id, print_center,"You have to be outside buyzone!")
		return PLUGIN_HANDLED
	}
#endif
// check buying time
#if defined BUYTIME
	new Float:buytime = get_cvar_float("mp_buytime") * 60.0;
	new Float:timepassed = get_gametime() - g_GameTime;

	if(floatcmp(timepassed , buytime) == 1)
	{
		client_print(id, print_center,"%0.f seconds have passed. You can't buy anything now!",buytime)
		return PLUGIN_HANDLED
	}
#endif
	if(giCounter < giAllowedRound)
	{
		ColorChat(id, RED, "[Ultimate Weapons]В этом раунде оружие недоступно.");
		return PLUGIN_HANDLED
	}
	else
	{
		if(get_user_flags(id)& ACCESS_FLAG )
		{
			if(cs_get_user_money(id) < VIPCOST )
			{
				ColorChat(id, RED, "[Ultimate Weapons]Нехватает денег!");
				return PLUGIN_HANDLED
			}
			else
				{
					new name[32];get_user_name(id,name,31)
					cs_set_user_money(id , cs_get_user_money(id) - VIPCOST , 1);
					givem4a1(id)
					ColorChat(0,RED,"Игрок ...:::%s:::... взял [M4A1 Gold]",name)
				}
		}
		else
			{
				if(cs_get_user_money(id) < COST )
				{
					ColorChat(id, RED, "[Ultimate Weapons]Нехватает денег!");
					return PLUGIN_HANDLED
				}
				else
					{
						cs_set_user_money(id , cs_get_user_money(id) - COST , 1);
						givem4a1(id)
					}
			}
	}	
	return PLUGIN_CONTINUE
}

public givem4a1(id)
{
	Player_DropWeapons (id, 1)
	g_HasM4a1[id] = true
	ham_give_weapon(id, "weapon_m4a1")
	
	engclient_cmd(id, "weapon_m4a1")
}

public Fwd_ItemDeploy_Weap_Post(ent)
{
	new iPlayer = get_pdata_cbase(ent, m_pPlayer, XO_WEAPON);

	if (g_HasM4a1[iPlayer])
	{
		set_pev(iPlayer, pev_viewmodel2, M4A1_V_MODEL)
		set_pev(iPlayer, pev_weaponmodel2, M4A1_P_MODEL)
	}

	return HAM_IGNORED;
}

public fw_Item_AttachToPlayer (ent, id)
{
	if ( pev (ent, pev_impulse)==M4)
		g_HasM4a1[id] = true

	Fwd_ItemDeploy_Weap_Post(ent )
	return HAM_IGNORED
}

public fw_SetModel ( ent, model[] )
{
	if ( pev_valid ( ent ) != 2 )
		return FMRES_IGNORED

	if ( strlen ( model ) < 8 )
		return FMRES_IGNORED

	if ( model[7] != 'w' || model[8] != '_' )
		return FMRES_IGNORED

	static sClassName[32]
	pev ( ent, pev_classname, sClassName, charsmax ( sClassName ) )
	
	if ( !equal ( sClassName, "weaponbox" ) )
		return FMRES_IGNORED

	new id = pev ( ent, pev_owner )

	if ( pev_valid ( id ) != 2 )
		return FMRES_IGNORED
	
	for (new i, iItem; i < MAX_ITEM_TYPES; i++)
	{
		iItem = get_pdata_cbase ( ent, m_rgpPlayerItems_CWeaponBox + i, XO_WEAPON )
		
		if ( pev_valid ( iItem ) == 2 && pev(iItem, pev_impulse)==M4)
		{
			g_HasM4a1[id] = false
			engfunc ( EngFunc_SetModel, ent, M4A1_W_MODEL )
			return FMRES_SUPERCEDE
		}
	}
	return FMRES_IGNORED
}


public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_bits)
{
	if(!g_is_connected[attacker])
		return HAM_IGNORED;

	if (!(damage_bits & DMG_BULLET))
		return HAM_IGNORED;

	if (pev_valid(victim) != 2)
		return HAM_IGNORED;

	if(get_user_weapon(attacker) != CSW_M4A1)
		return HAM_IGNORED;

	if(g_HasM4a1[attacker])
		SetHamParamFloat(4, damage * DAMAGE);

	return HAM_IGNORED;
}

stock Player_DropWeapons(const iPlayer, const iSlot)
{
	new szWeaponName[32], iItem = get_pdata_cbase(iPlayer, m_rgpPlayerItems_CBasePlayer + iSlot, XO_CBASEPLAYER);

	while (pev_valid(iItem) == 2)
	{
		pev(iItem, pev_classname, szWeaponName, charsmax(szWeaponName));
		engclient_cmd(iPlayer, "drop", szWeaponName);

		iItem = get_pdata_cbase(iItem, m_pNext, XO_WEAPON);
	}
}

stock ham_give_weapon(id,weapon[])
{
	if(!equal(weapon,"weapon_",7)) return 0;

	new wEnt = engfunc(EngFunc_CreateNamedEntity,engfunc(EngFunc_AllocString,weapon));
	if(!pev_valid(wEnt)) return 0;

	set_pev(wEnt,pev_spawnflags,SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn,wEnt);
    
	if(!ExecuteHamB(Ham_AddPlayerItem,id,wEnt))
	{
		if(pev_valid(wEnt)) set_pev(wEnt,pev_flags,pev(wEnt,pev_flags) | FL_KILLME);
		return 0;
	}

	ExecuteHamB(Ham_Item_AttachToPlayer,wEnt,id);

	ExecuteHamB(Ham_GiveAmmo, id, 90, "556nato", 90);

	set_pev(wEnt, pev_impulse, M4)

	return 1;
}
