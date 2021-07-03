/*
	Плагин: Crux Ansata
	Автор: DUKKHAZ0R | Сайт: http://aimbat.ru/plugins/
	
	Описание:
	Плагин добавляет на сервер талисман жизни, у человека имеющего его будет восстанавливаться 5 хп каждые 2 секунды.
	В начале рануда рандомному игроку выпадает талисман жизни, если человек умирает, то любой другой сможет подобрать талисман.
	Минимальное количество игроков для работы плагина, количество восстанавливаемого здоровья и интервал восстанавления можно настроить в исходнике.
*/

#include <amxmodx>
#include <engine>

// #define SCREENFADE				// Затемнять экран при регенерации здоровья
#define RENDERING					// Подсветка игрока при регенерации здоровья
#define MIN_PLAYERS 5				// Минимальное кол-во игроков для работы плагина
#define ROUND_ACCESS 3				// С какого раунда доступен талисман
#define GIVE_HEALTH 10 				// Кол-во выдаваемого здоровья
#define MAX_HEALTH 150				// Максимальное кол-во выдаваемого здоровья игроку
#define INTERVAL_REGENERATION 1.0	// Интервал между восстановлением

new const g_szModel[] = "models/Energy4000.mdl";

new g_iPlayerId, g_iRoundCounter, szName[32];

public plugin_init()
{
	register_plugin("Crux Ansata", "1.0", "DUKKHAZ0R");
	
	register_touch("Energy4000", "player", "fw_TouchEntity");
	
	register_logevent("eRoundStart", 2, "1=Round_Start");
	register_event("DeathMsg", "eDeathMsg", "a", "1>0");
	register_event("TextMsg", "eRoundRestart", "a", "2&#Game_C", "2&#Game_w");
	
	set_task(INTERVAL_REGENERATION, "RegenerationHealth", .flags="b");
}

public plugin_precache()
	precache_model(g_szModel);

public client_disconnect(id)
{
	if(g_iPlayerId == id)
		SpawnAnsata(id);
}

public eRoundRestart()
{
	g_iRoundCounter = 0;
	
	if(g_iPlayerId)
	{
#if defined RENDERING
		set_rendering(g_iPlayerId);
#endif
		g_iPlayerId = 0;
	}
}

public eRoundStart()
{
	if(++g_iRoundCounter < ROUND_ACCESS || g_iPlayerId)
		return;
	
	static iEnt;
	
	while((iEnt = find_ent_by_class(iEnt, "Energy4000")))
		remove_entity(iEnt);
	
	static iPlayers[32], iNum;
	get_players(iPlayers, iNum, "ah");
	
	if(!iNum || get_playersnum() < MIN_PLAYERS)
		return;
	
	g_iPlayerId = iPlayers[random(iNum)];
	
	get_user_name(g_iPlayerId, szName, charsmax(szName));
	ChatColor(0, "^4[Talisman] ^3%s ^1выпал талисман жизни.", szName);
	
#if defined RENDERING
	set_rendering(g_iPlayerId, kRenderFxGlowShell, 0, 140, 240, kRenderNormal, 25);
#endif
}

public eDeathMsg()
{
	if(read_data(2) != g_iPlayerId)
		return;
	
#if defined RENDERING
	set_rendering(g_iPlayerId);
#endif
	
	SpawnAnsata(g_iPlayerId);
}

public fw_TouchEntity(iEnt, id)
{
	if(!is_valid_ent(iEnt) || !is_user_alive(id))
		return;
	
	remove_entity(iEnt);
	
	get_user_name(g_iPlayerId = id, szName, charsmax(szName));
	ChatColor(0, "^4[Talisman] ^3%s ^1поднял талисман жизни.", szName);
	
#if defined RENDERING
	set_rendering(g_iPlayerId, kRenderFxGlowShell, 0, 140, 240, kRenderNormal, 25);
#endif
}

public RegenerationHealth()
{
	if(!g_iPlayerId || get_playersnum() < MIN_PLAYERS)
		return;
	
	static Float:fHealth, MsgId_Health; fHealth = entity_get_float(g_iPlayerId, EV_FL_health);
	
	if(!MsgId_Health) MsgId_Health = get_user_msgid("Health");
	
	if(fHealth > 0 && fHealth < MAX_HEALTH)
	{
		static Float:fNewHealth; fNewHealth = float_min(fHealth + GIVE_HEALTH, MAX_HEALTH.0);
		
		entity_set_float(g_iPlayerId, EV_FL_health, fNewHealth);
		
		message_begin(MSG_ONE_UNRELIABLE, MsgId_Health, _, g_iPlayerId);
		write_byte(floatround(fNewHealth));
		message_end();
		
#if defined SCREENFADE
		message_begin(MSG_ONE_UNRELIABLE, 98, _, g_iPlayerId);
		write_short(1<<10);
		write_short(1<<10);
		write_short(0x0000);
		write_byte(0);
		write_byte(255);
		write_byte(0);
		write_byte(40);
		message_end();
#endif
	}
}

stock SpawnAnsata(id)
{
	static Float:fOrigin[3];
	entity_get_vector(id, EV_VEC_origin, fOrigin);
	
	static iEnt
	iEnt = create_entity("info_target");
	
	if(!is_valid_ent(iEnt))
		return;
	
	fOrigin[2] -= 25.0;
	
	entity_set_vector(iEnt, EV_VEC_origin, fOrigin);
	entity_set_string(iEnt, EV_SZ_classname, "Energy4000");
	entity_set_int(iEnt, EV_INT_solid, SOLID_TRIGGER);
	entity_set_int(iEnt, EV_INT_movetype, MOVETYPE_NONE);
	entity_set_int(iEnt, EV_INT_effects, 8);
	
	entity_set_model(iEnt, g_szModel);
	entity_set_size(iEnt, Float:{ -2.0, -2.0, -6.0 }, Float:{ 2.0, 2.0, 6.0 });
	drop_to_floor(iEnt);
	
	entity_set_int(iEnt, EV_INT_sequence, 1);
	entity_set_float(iEnt, EV_FL_animtime, get_gametime());
	entity_set_float(iEnt, EV_FL_framerate, 1.0);
	entity_set_float(iEnt, EV_FL_frame, 0.0);
	
	get_user_name(id, szName, charsmax(szName));
	ChatColor(g_iPlayerId = 0, "^4[Talisman] ^3%s ^1потерял талисман жизни.", szName);
}

stock ChatColor(const id, const szMessage[], any:...)
{
	static szBuffer[191], iPlayers[32], iNum; iNum = 1;
	
	vformat(szBuffer, charsmax(szBuffer), szMessage, 3);
	
	if(is_user_connected(id)) iPlayers[0] = id; else get_players(iPlayers, iNum, "h");
	{
		for(new i=0; i < iNum; i++)
		{
			message_begin(MSG_ONE_UNRELIABLE, 76, .player = iPlayers[i]);
			write_byte(iPlayers[i]);
			write_string(szBuffer);
			message_end();
		}
	}
}

stock Float:float_min(Float:value1, Float:value2)
	return ((value1 < value2) ? value1 : value2);
