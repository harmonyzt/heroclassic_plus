#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <presents_guns>
#include <WPMGPrintChatColor>

#define is_entity_player(%1) (1<=%1<=g_maxPlayers)
#define is_headshot(%0) (get_pdata_int(%0, 75, 5) == HIT_HEAD)
#define PRESENT_CLASSNAME "gift"

#define MODEL_PRESENT "models/presents.mdl"
#define MODEL_SKINS 3
#define MODEL_SUBMODELS 5

#define MAX_MONEY 16000 	// Максимальное кол-во денег
#define MAX_ARMOR 100 	// Максимальное кол-во брони
#define MAX_HEALTH 100 	// Максимальное кол-во здоровья

#if cellbits == 32
#define OFFSET_CSMONEY 115
#else
#define OFFSET_CSMONEY 140
#endif

new
	g_msgMoney,
	g_infoTarget,
	g_maxPlayers,
	bool: g_registration

public plugin_precache()
{
	precache_model(MODEL_PRESENT)
}

public plugin_init()
{
	register_plugin("Presents", "0.8", "Psycrow & ropblHbl4 & 3BEPb")

	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	// 0 - убрает подарок.
	register_cvar("dp_gift_money_min","1000") 	// Минимальная количество денег за собрынный подарок.
	register_cvar("dp_gift_money_max","5000") 	// Максимальная количество денег за собрынный подарок.
	register_cvar("dp_gift_armor","50") 		// Сколько Брони можно получить в подарке.
	register_cvar("dp_gift_health","30") 		// Сколько Здоровья можно получить в подарке.
	register_cvar("dp_gift_HE","1") 			// Сколько Осколочных гранат можно получить в подарке.
	register_cvar("dp_gift_gun","1") 			// Выдавать Пушку в подарке.
	register_cvar("dp_gift_fake","1") 			// Пустой подарок.
	
	register_cvar("dp_only_hs","0") 			// Подарок выпадет только после HeadShot'а (если 1).

	g_infoTarget = engfunc(EngFunc_AllocString, "info_target")
}

public fw_PlayerKilled(iVictim)
{
	if( get_cvar_num("dp_only_hs") )
		if( !is_headshot(iVictim) )
			return HAM_IGNORED
		
	new iVictimLoc[3]
	new Float:fVictimLoc[3]
	
	get_user_origin(iVictim, iVictimLoc)
	IVecFVec(iVictimLoc, fVictimLoc)
	
	create_gift(fVictimLoc)
	
	return HAM_IGNORED
}

public create_gift(const Float: fOrigin[3])
{
	new ent = engfunc(EngFunc_CreateNamedEntity, g_infoTarget)
	if(!pev_valid(ent)) return
	
	if(!g_registration)
	{
		RegisterHamFromEntity(Ham_Touch, ent, "fw_TouchGift")

		g_maxPlayers = get_maxplayers()
		g_msgMoney = get_user_msgid("Money")

		g_registration = true
	}

	engfunc(EngFunc_SetModel, ent, MODEL_PRESENT)
	set_pev(ent, pev_origin, fOrigin)
	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_movetype, MOVETYPE_FLY)
	set_pev(ent, pev_gravity, 1.0)
	set_pev(ent, pev_classname, PRESENT_CLASSNAME)
	set_pev(ent, pev_skin, random_num(0, MODEL_SKINS - 1))
	set_pev(ent, pev_body, random_num(0, MODEL_SUBMODELS - 1))
	engfunc(EngFunc_DropToFloor, ent)
	engfunc(EngFunc_SetSize, ent, Float:{-15.0, -15.0, 0.0}, Float:{15.0, 15.0, 30.0})
	fm_set_rendering(ent, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
}

public fw_TouchGift(ent, id)
{	
	if(!is_entity_player(id))
		return

	if(!is_user_alive(id) || !pev_valid(ent))
		return

	static className[32]
	pev(ent, pev_classname, className, 31)
	if(!equal(className, PRESENT_CLASSNAME))
		return

	engfunc(EngFunc_SetModel, ent, MODEL_PRESENT)
	set_pev(ent, pev_skin, random_num(0, MODEL_SKINS - 1))
	set_pev(ent, pev_body, random_num(0, MODEL_SUBMODELS - 1))

	engfunc(EngFunc_RemoveEntity, ent)
	give_gift(id)
}

give_gift(id) // Выдает случайный подарок.
{
	static loopDestroy
	loopDestroy++

	if(loopDestroy > 20)
	{
		PrintChatColor(id, PRINT_COLOR_PLAYERTEAM, "!g[Подарки] !tПодарок оказался пустым!")
		loopDestroy = 0
		return
	}

	new max_random_gift = 6 //Сколько видов подарков.
	switch(random_num(1, max_random_gift))
	{
		case 1:
		{
			new reward = random_num(get_cvar_num("dp_gift_money_min"), get_cvar_num("dp_gift_money_max"))
			new curr_money = get_pdata_int(id, OFFSET_CSMONEY)
			if(curr_money + reward > MAX_MONEY)
				reward = MAX_MONEY - curr_money

			if(reward)
			{
				set_pdata_int(id, OFFSET_CSMONEY, curr_money + reward)

				message_begin(MSG_ONE, g_msgMoney, _, id)
				write_long(curr_money + reward)
				write_byte(1)
				message_end()

				PrintChatColor(id, PRINT_COLOR_PLAYERTEAM, "!g[Подарки] !tВы получаете !g$%d!", reward)
				loopDestroy = 0
			}
			else give_gift(id)
		}
		case 2:
		{
			new armor = get_cvar_num("dp_gift_armor")
			new curr_armor = get_user_armor(id)
			if(curr_armor + armor > MAX_ARMOR)
				armor = MAX_ARMOR - curr_armor
			
			if(armor)
			{
				fm_set_user_armor(id, get_user_armor(id) + armor)
				PrintChatColor(id, PRINT_COLOR_PLAYERTEAM, "!g[Подарки] !tВы получаете !g%d Брони!", armor)
				loopDestroy = 0
			}
			else give_gift(id)
		}
		case 3:
		{
			new health = get_cvar_num("dp_gift_health")
			new curr_health = get_user_health(id)
			if(curr_health + health > MAX_HEALTH)
				health = MAX_HEALTH - curr_health
			
			if(health)
			{
				fm_set_user_health(id, pev(id, pev_health) + health)
				PrintChatColor(id, PRINT_COLOR_PLAYERTEAM, "!g[Подарки] !tВы получаете !g%d Здоровья!", health)
				loopDestroy = 0
			}
			else give_gift(id)
		}
		case 4:
		{
			new hes = get_cvar_num("dp_gift_HE")
			if(hes)
			{
				if(!user_has_weapon(id, CSW_HEGRENADE))
				{
					fm_give_item(id, "weapon_hegrenade")
					cs_set_user_bpammo(id, CSW_HEGRENADE, hes)
				}
				else cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE) + hes)

				PrintChatColor(id, PRINT_COLOR_PLAYERTEAM, "!g[Подарки] !tВы получаете !g%d Осколочную гранату!", hes)
				loopDestroy = 0
			}
			else give_gift(id)
		}
		case 5:
		{
			new gun = get_cvar_num("dp_gift_gun")
			if(gun)
			{
				give_fglauncher(id)
				PrintChatColor(id, PRINT_COLOR_PLAYERTEAM, "!g[Подарки] !tВы получаете !gФейерверк-Пушку!")
				loopDestroy = 0
			}
			else give_gift(id)
		}
		case 6:
		{
			new fake = get_cvar_num("dp_gift_fake")
			if(fake)
			{
				PrintChatColor(id, PRINT_COLOR_PLAYERTEAM, "!g[Подарки] !tПодарок оказался пустым!")
				loopDestroy = 0
			}
			else give_gift(id)
		}
	}
}