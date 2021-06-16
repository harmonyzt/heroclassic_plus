///Did you see any errors or bugs? Write there ---> HATTRIX@yandex.ru	<--- We'll fix it!
///Last update in 05.07.2018 at 19:19
///
//////////////////////////Big thanks to///////////////////////////////
///[Arctic or Arctiq] - For original source
///[OverGame] - For comleted arctic's source (Named Evil Army :D)
///[serfreeman1337] - For code MEGA DEAGLE and MEGA GRENADE for anew
//////////////////////////////////////////////////////////////////////
///Update 8.6
///- Fixed some bugs
///- Added new cvar first_exp	(Exp for first blood)
///- Added new cvar bomb_mode	(Mode of defusing or planting bomb)
///- Added new cvar mode_lvlup	(Modes of notifications)
///- For cvar bomb_mode added:
//// Player cant plant the bomb, plugin will switch bomb to knife, or he can plant and defuse but doesnt recieve exp
///- For cvar mode_lvlup added:
//// Notification about lvl up in HUD (Down center + notification sound) or in colored chat
///- In menu anew added mega deagle and grenade with personal dmg settings
///- Server was up for 13 hours on CSDM mode and 10 hours on public server, for all this time I didn't see any bugs or errors
#include < amxmodx >
#include < amxmisc >
#include < fun >
#include < cstrike >
#include < nvault >
#include < ColorChat2 >
#include < dhudmessage >
#include < csx >
#include < fakemeta_util >	//Now I need it
#include < hamsandwich >	//And this too
#pragma tabsize 0
#define ver "9.0 FIXED"

new block=0			//For blocking bonuses anew on maps
new round			//For round counter
new players_online
new players_need
new need_kills[33]
new need_hs[33]
new players[33]
new first_blood
//Anew mega deagle and grenade
enum _:{
	NONE,
	MEGA_DEAGLE,
	MEGA_GRENADE
}
//Add your maps here for restrict anew bonuses
new const restrict_bonus[][] =
{
	"$2000$",
	"$3000$",
	"fy_pool_day"
};

new g_vault;
enum _:PlData
{
	gId,gExp,gLevel,gTempKey,g_Bonus,Streak,HeadStr
};

enum _:Cvars
{
	cost1,
	cost2,
	cost3,
	cost4,
	cost5,
	cost6,
	cost7,
	cost8,
	cost9,
	menu_str1,
	menu_str2,
	menu_str3
};
new Costs_cvar[Cvars]
new gChatTop;
new stats[8],bodyhits[8],irank;
new UserData[50][PlData];	//Data that stores in PlData (ffs, no wonder)

new gMessage[256];
new MaxPlayers,levelUp[33],gSayText;
new bool:restr_blocked;
new const gRankNames[][] = 
{
	"I_0","I_1","I_2","I_3","I_4","I_5","I_6","I_7","I_8","I_9","I_10","I_11","I_12","I_13","I_14",		
	"I_15","I_16","I_17","I_18","I_19","I_20","I_21","I_22","I_23","I_24","I_25","I_26","I_27","I_28","I_29"
};	//Counting our levels
new const gLevels[] = 
{
	0,20,40,60,120,200,370,770,1020,1520,2220,2820,3220,3920,4520,5020,5520,6020,7020,9000,12000,15000,20000,25000,30000,38000,45000,50000,80000
};	//Counting how much exp each level will be
new const gNades[][] =
{
	{0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1}
}


new gRestrictMaps,gAdminGMsg,gBonusLevel,gFlash,gSmoke,gHe,gHpbylevel,gApbylevel,
gArmyChat,gSlash,gTk,gLostXpTk,gLevelUpmsg,gAllChat,ar_bonus_knife, ar_bonus_newlvl, ar_kill_exp, ar_kill_head, ar_kill_knife,  ar_round_acc
,ar_bonus_on,ar_bonus_streak,ar_bonus_streak_head,ar_kill_counter,ar_death_notice,ar_bombplant_exp, ar_def_exp,ar_round_msgs
,anew_dmg_deagle,anew_dmg_he
new mode_lvlup
new bomb_mode
new g_iMsgIdBarTime
new first_exp
new ar_colors
public plugin_init()
{
	register_plugin("Army Bonus System", ver, "harmony");
	register_cvar("abs",ver, FCVAR_SERVER | FCVAR_SPONLY);
	register_clcmd("say /anew","anew_menu");

	set_cvar_string("abs",ver);
	register_event("SendAudio", "t_win", "a", "2&%!MRAD_terwin") 	//Win of tt trigger
	register_event("SendAudio", "ct_win", "a", "2&%!MRAD_ctwin")	//Win of ct trigger
	
	///ANEW
	anew_dmg_deagle 	= register_cvar("anew_dmg_deagle","1.3")
	anew_dmg_he	= register_cvar("anew_dmg_he","2.0")		//Yes
	///END ANEW REGISTER
	Costs_cvar[cost1]	=register_cvar("cost_anew_menu1","15")	//awp
	Costs_cvar[cost2]	=register_cvar("cost_anew_menu2","15")	//ak
	Costs_cvar[cost3]	=register_cvar("cost_anew_menu3","15")	//m4
	Costs_cvar[cost4]	=register_cvar("cost_anew_menu4","15")	//
	Costs_cvar[cost5]	=register_cvar("cost_anew_menu5","5")
	Costs_cvar[cost6]	=register_cvar("cost_anew_menu6","10")
	Costs_cvar[cost7]	=register_cvar("cost_anew_menu7","10")
	Costs_cvar[cost8]	=register_cvar("cost_anew_menu8","15")
	Costs_cvar[cost9]	=register_cvar("cost_anew_menu9","15")
	Costs_cvar[menu_str1]	=register_cvar("anew_menu1","10000")	//dollars
	Costs_cvar[menu_str2]	=register_cvar("anew_menu2","50")		//hp
	Costs_cvar[menu_str3]	=register_cvar("anew_menu3","50")		//exp
	ar_colors		=register_cvar("ar_informer_color","100 100 100")
	first_exp		=register_cvar("first_kill_exp","3")
	ar_def_exp 		= register_cvar("ar_def_exp","3")
	ar_bombplant_exp 	= register_cvar("ar_bombplant_exp","3")
	players_need 		= register_cvar("ar_players_need","5")
	ar_round_msgs 		= register_cvar("ar_round_msgs","0")
	ar_bonus_on 		= register_cvar("ar_bonus_on","1")
	ar_death_notice 		= register_cvar("ar_death_notice","0")
	ar_kill_counter 		= register_cvar("ar_kill_counter","0")
	ar_bonus_streak_head 	= register_cvar("ar_bonus_streak_head","2")
	ar_round_acc 		= register_cvar("ar_round_acc","1")
	ar_bonus_streak 		= register_cvar("ar_bonus_streak","2")
	ar_kill_exp 		= register_cvar("ar_kill_exp","1")
	ar_kill_head 		= register_cvar("ar_kill_head","2")
	ar_kill_knife		 = register_cvar("ar_bonus_head","3")
	ar_bonus_knife 		= register_cvar("ar_bonus_knife","3")
	ar_bonus_newlvl		= register_cvar("ar_bonus_newlvl","8")
	gRestrictMaps 		= register_cvar( "restrict_maps",     	"1");
	gBonusLevel		= register_cvar( "level_bonus",     	"0");
	gFlash			= register_cvar( "flash_nades",     	"0");
	gSmoke			= register_cvar( "smoke_nades",     	"1");
	gHe			= register_cvar( "he_nades",     	"1");
	gHpbylevel		= register_cvar( "hp_by_level",     	"3");
	gApbylevel		= register_cvar( "ap_by_level",     	"5");
	gChatTop		= register_cvar( "chat_top",     	"1");
	gArmyChat		= register_cvar( "army_chat",     	"1");
	gAdminGMsg		= register_cvar( "admin_color",    	"1");
	gSlash 			= register_cvar( "slash_messages",     	"1");
	gTk 			= register_cvar( "team_kill_lost_xp",   	"1");
	gLostXpTk 		= register_cvar( "lost_xp_val",     	"-1");
	gLevelUpmsg		= register_cvar( "level_up_msg",     	"1");
	gAllChat		= register_cvar( "all_chat",     	"1");	
	mode_lvlup		= register_cvar("lvlup_mode","1")
	bomb_mode		= register_cvar("ar_bomb_mode","1")	///1 - Bomb cant be planted 2 - Bomb can be planted, but without earning exp

	register_logevent( "EventRoundStart", 2, "1=Round_Start" );
	register_event( "DeathMsg","EventDeath","a");
	register_event("HLTV", "on_new_round", "a", "1=0", "2=0");
	register_message(get_user_msgid("SayText"), "msg_SayText");
	RegisterHam(Ham_TakeDamage,"player","TakeDamage")
	
	gSayText = get_user_msgid ("SayText");
	
	MaxPlayers = get_maxplayers();
	
	register_dictionary("army_bonus_system.txt");
	g_vault = nvault_open("army_bonus_system");	//opens main storage file
	if(get_pcvar_num(gArmyChat))
	{
		register_clcmd("say", "hookSay") 
		register_clcmd("say_team", "hookSayTeam");
	}
	set_task(1.0,"Info",_,_,_, "b")	//Displace our info in hud mode
	g_iMsgIdBarTime = get_user_msgid("BarTime")
	
	

if(get_pcvar_num(gRestrictMaps))
	{
		new szMapName[64];
		get_mapname(szMapName,63);
		for(new a = 0; a < sizeof restrict_bonus; a++)
		{
			if(equal(szMapName, restrict_bonus[a]))
			{
				restr_blocked = true;
				block=1
				log_amx("[ABS] Bonus menu is blocked on map [%s].",restrict_bonus[a]);
				break;
			} else {
				restr_blocked = false;
				block=0
			}	
		}
	}
}
public plugin_cfg()
{
	new szCfgDir[64], szFile[192];
	get_configsdir(szCfgDir, charsmax(szCfgDir));
	formatex(szFile,charsmax(szFile),"%s/ar/army_bonus_sys.cfg",szCfgDir);
	if(file_exists(szFile))
		server_cmd("exec %s", szFile);
}


public bomb_planting(planter){

if(players_online<=get_pcvar_num(players_need)  &&  get_pcvar_num(bomb_mode)==1)
{
client_print(planter,print_center,"%L",LANG_PLAYER,"NO_BOMB_PLANT",get_pcvar_num(players_need))
engclient_cmd(planter,"weapon_knife")	///Switching victim to knife
///Creating invisible 'planting' strip to fix bug
message_begin(MSG_ONE, g_iMsgIdBarTime, _, planter)
write_short(0)	///������������
message_end()										
}
}

public bomb_planted(planter)
{
	if(players_online<=get_pcvar_num(players_need) && get_pcvar_num(bomb_mode)==2)
	{
		ColorChat(planter,RED,"%L",LANG_PLAYER,"ENOUGH_PLAYERS",get_pcvar_num(players_need))		///Not enough players
		return 												///Maybe make a switch to a knife? Hmm ... (Already done)
	}else{
		ColorChat(planter,GREEN,"%L",LANG_PLAYER,"SUCC_BOMB_PLANT",get_pcvar_num(ar_bombplant_exp))
		UserData[planter][gExp]+=get_pcvar_num(ar_bombplant_exp)
	}
	
}


public bomb_defused(defuser)
{
	if(players_online<=get_pcvar_num(players_need))
	{
		ColorChat(defuser,RED,"%L",LANG_PLAYER,"ENOUGH_PLAYERS",get_pcvar_num(players_need))
		return 
	}else{
		ColorChat(defuser,GREEN,"%L",LANG_PLAYER,"SUCC_BOMB_DEF",get_pcvar_num(ar_def_exp))
		UserData[defuser][gExp]+=get_pcvar_num(ar_def_exp)
	}
}

public TakeDamage(victim,idinflictor,idattacker,Float:damage,damagebits){
	if(!idattacker || idattacker > get_maxplayers())
		return HAM_IGNORED
	
	if(!players[idattacker])
		return HAM_IGNORED
	
	if(0 < idinflictor <= get_maxplayers()){
		new wp = get_user_weapon(idattacker)
		
		if(wp == CSW_DEAGLE && (players[idattacker] & (1 << MEGA_DEAGLE)))
			SetHamParamFloat(4,damage * get_pcvar_float(anew_dmg_deagle))
		}else{
		new classname[32]
		pev(idinflictor,pev_classname,classname,31)
		
		if(!strcmp(classname,"grenade") && (players[idattacker] & (1 << MEGA_GRENADE))){
			set_task(0.5,"deSetNade",idattacker)
			
			SetHamParamFloat(4,damage * get_pcvar_float(anew_dmg_he))
		}
	}
	
	return HAM_IGNORED
}

public deSetNade(id)
	players[id] &= ~(1<<MEGA_GRENADE)

public t_win(id)
{
if(get_pcvar_num(ar_round_msgs)==1)
{
set_dhudmessage(255, 0, 0, -1.0, 0.2, 0, 1.0, 7.0, 0.4, 0.4, _)
show_dhudmessage(0,"%L",LANG_PLAYER,"TT_WIN")
}
}


public ct_win(id)
{
if(get_pcvar_num(ar_round_msgs)==1)
{
set_dhudmessage(0, 0, 255, -1.0, 0.2, 0, 1.0, 7.0, 0.5, 0.5, _)
show_dhudmessage(0,"%L",LANG_PLAYER,"CT_WIN")
}
}



public plugin_end()
{
nvault_close(g_vault);	//Closing storage file
}

public client_putinserver(id)
{
	players_online++
	UserData[id] = UserData[0];
	UserData[id][Streak]=0
	UserData[id][HeadStr]=0
	load_data(id);	//Loading everything we need about player
	need_kills[id]=5
	need_hs[id]=4
}

public client_disconnect(id)
{
	players_online--
	UserData[id][Streak]=0
	UserData[id][HeadStr] = 0
	save_usr(id);	//Saving info about the player
	//UserData[id] = UserData[0]; - honestly was a fix but then everything went fine
	players[id] = NONE	//Reseting conditions of super deagle and super grenade when player disconnect
}

public on_new_round(id){	
round++
first_blood=1
}

public check_level(id)
{
	if(UserData[id][gLevel] <= 0)
		UserData[id][gLevel] = 1;
		
	if(UserData[id][gExp] < 0)
		UserData[id][gExp] = 0;

	while(UserData[id][gExp] >= gLevels[UserData[id][gLevel]]) 
	{
		UserData[id][gLevel]++;
		levelUp[id] = 1;
		///Fixed two switches (hi sinner)
		switch(get_pcvar_num(mode_lvlup)){
		case 2:{
			
		if(get_pcvar_num(gLevelUpmsg)==1){
			new szName[33];
			get_user_name(id, szName, 32);
			UserData[id][g_Bonus]+=get_pcvar_num(ar_bonus_newlvl)
			static buffer[192],len;
			len = format(buffer, charsmax(buffer), "^4[^3%L^4]^1 %L ^4%s^1",LANG_PLAYER,"PRIFIX",LANG_PLAYER,"PLAYER",szName);
			len += format(buffer[len], charsmax(buffer) - len, " %L",LANG_PLAYER,"NEW_LEVEL"); 
			len += format(buffer[len], charsmax(buffer) - len, " ^4%L^1. ",LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
			len += format(buffer[len], charsmax(buffer) - len, "%L",LANG_PLAYER,"CONTR");
			ColorChat(0,NORMAL,buffer);
			
			}else{
			
			new szName[33];
			get_user_name(id, szName, 32);
			UserData[id][g_Bonus]+=get_pcvar_num(ar_bonus_newlvl)
			static buffer[192],len;
			len = format(buffer, charsmax(buffer), "^4[^3%L^4]^1 %L ^4%s^1",LANG_PLAYER,"PRIFIX",LANG_PLAYER,"PLAYER",szName);
			len += format(buffer[len], charsmax(buffer) - len, " %L",LANG_PLAYER,"NEW_LEVEL"); 
			len += format(buffer[len], charsmax(buffer) - len, " ^4%L^1. ",LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
			len += format(buffer[len], charsmax(buffer) - len, "%L",LANG_PLAYER,"CONTR");
			ColorChat(id,NORMAL,buffer);
			}
		}
		

		case 1:{
		new szName[33],mess;mess=CreateHudSyncObj()
		get_user_name(id, szName, 32);
		set_hudmessage(255, 100, 40, -1.0, 0.8, 0, 6.0, 5.0,0.7,0.7)
		ShowSyncHudMsg(0, mess, "%L",LANG_PLAYER,"NEW_LVL_HUD",szName,LANG_PLAYER,gRankNames[UserData[id][gLevel]])
		client_cmd(id,"spk abs/lvl_up")
		}
	}
}
}

public EventDeath()
{
	static iKiller,iVictim,head,wpn[32]
	iKiller = read_data(1);
	if(!is_user_connected(iKiller))	//Fix of error [Player out of range (0)] (Smacks of server crash? Yes?) Jk :)))
	return PLUGIN_HANDLED
	
	iVictim = read_data(2);
	head = read_data(3);
	read_data(4,wpn,31)
	
	if(iKiller != iVictim && is_user_connected(iKiller) && is_user_connected(iVictim) && UserData[iKiller][gLevel] <= 29)		//A bunch of all the NECESSARY checks
	{
		if(first_blood==1 && get_pcvar_num(first_exp)!=0){///First blood started
		
			new name[33]
			get_user_name(iKiller,name,32)
			UserData[iKiller][gExp]+=get_pcvar_num(first_exp)
			client_print(0,print_center,"%L",LANG_PLAYER,"FIRST_BLOOD",name,get_pcvar_num(first_exp))	
			first_blood=0
			return PLUGIN_HANDLED
		
		}
		
		if(get_pcvar_num(gTk) && get_user_team(iKiller) == get_user_team(iVictim))
		{
			UserData[iKiller][gExp] -= get_pcvar_num(gLostXpTk);
		}

		if(head){	///If it was a headshot
			UserData[iKiller][HeadStr]++	//Adding to headshot counter +1
			UserData[iKiller][gExp] += get_pcvar_num(ar_kill_head); //Gaining exp
			UserData[iVictim][Streak]=0
			UserData[iVictim][Streak]=0
			UserData[iVictim][HeadStr]=0
			UserData[iVictim][HeadStr]=0
		}
		
		players[iVictim] = NONE	//Reseting conditions of super deagle and super grenade when player dies
		set_user_rendering(iVictim,kRenderFxNone,255,255,255, kRenderNormal,16)	///Resseting invisibility of player on death too
		UserData[iKiller][Streak]++
		UserData[iKiller][gExp] += get_pcvar_num(ar_kill_exp);
		UserData[iVictim][Streak]=0
		UserData[iVictim][HeadStr]=0
		need_kills[iVictim]=5
		need_hs[iVictim]=3
		
		if(get_pcvar_num(ar_death_notice)==1)
		{
		ColorChat(iVictim,RED,"%L",LANG_PLAYER,"DEATH_NOTICE")
		}
		
		//KILLSTERAK 
		if(UserData[iKiller][Streak]>=need_kills[iKiller]){
			
			UserData[iKiller][g_Bonus]+=get_pcvar_num(ar_bonus_streak)	
			ColorChat(iKiller,GREEN,"%L",LANG_PLAYER,"STREAK",need_kills[iKiller],get_pcvar_num(ar_bonus_streak))
			need_kills[iKiller]+=5		///I myself came up with this :))) Applaud!!!
		
		return PLUGIN_CONTINUE
		}
		
		
		//HEADSTREAK
		if(UserData[iKiller][HeadStr]>=need_hs[iKiller]){
			
			UserData[iKiller][g_Bonus]+=get_pcvar_num(ar_bonus_streak_head)	
			ColorChat(iKiller,GREEN,"%L",LANG_PLAYER,"STREAK_HS",need_hs[iKiller],get_pcvar_num(ar_bonus_streak_head))
			need_hs[iKiller]+=4
			return PLUGIN_CONTINUE
			
		}
		
		//KNIFE KILL
		if(contain(wpn, "knife") != -1){
		///Made a new check because through get_user_weapon not safe :)
			UserData[iKiller][gExp] += get_pcvar_num(ar_kill_knife);
			UserData[iKiller][g_Bonus] += get_pcvar_num(ar_bonus_knife);
			ColorChat(iKiller, GREEN,"%L",LANG_PLAYER,"KNIFE_KILL",get_pcvar_num(ar_bonus_knife))
			UserData[iVictim][Streak]=0
			UserData[iVictim][Streak]=0
			UserData[iVictim][HeadStr]=0
			UserData[iVictim][HeadStr]=0
		}
		check_level(iKiller);
		
	}
	return PLUGIN_CONTINUE;
}


public EventRoundStart()
{
	for(new id = 1; id <= MaxPlayers; id++)
	{
		if(is_user_alive(id) && is_user_connected(id))
		{
			if(restr_blocked)
				return PLUGIN_CONTINUE;
			
			if(get_pcvar_num(gFlash) && gNades[0][UserData[id][gLevel]])
				give_item(id,"weapon_flashbang");
			
			if(get_pcvar_num(gSmoke) && gNades[1][UserData[id][gLevel]])
				give_item(id,"weapon_smokegrenade");
				
			if(get_pcvar_num(gHe) && gNades[2][UserData[id][gLevel]])
				give_item(id,"weapon_hegrenade");
			
			if(get_pcvar_num(gHpbylevel) != 0)
				set_user_health(id,get_user_health(id)+get_pcvar_num(gHpbylevel)*UserData[id][gLevel]);
				
			if(get_pcvar_num(gApbylevel) != 0)
				set_user_armor(id,get_user_armor(id)+get_pcvar_num(gApbylevel)*UserData[id][gLevel]);	
				
			if(levelUp[id] == 1 && get_pcvar_num(gBonusLevel))
			{
				levelUp[id] = 0;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

///
///SAVE & LOAD DATA
///
public load_data(id)
{
	new szName[33];
	get_user_name(id,szName,32);

			static data[256], timestamp;
			if(nvault_lookup(g_vault, szName, data, sizeof(data) - 1, timestamp) )
			{
				next_load_data(id, data, sizeof(data) - 1);
				return;
			} else {
				register_player(id,"");
			}
}

public next_load_data(id,data[],len)		//Loading lvl, exp, bonuses of player
{
	new szName[33];
	get_user_name(id,szName,32);

			replace_all(data,len,"|"," ");		
			new exp[5],level[5],bonus[5],rank[5];
			parse(data,exp,4,level,4,bonus,4,rank,4);
			UserData[id][gExp]= str_to_num(exp);
			UserData[id][gLevel]= str_to_num(level);
			UserData[id][g_Bonus]=str_to_num(bonus);
	if(UserData[id][gLevel] <= 0)
		UserData[id][gLevel] = 1;

	while(UserData[id][gExp] >= gLevels[UserData[id][gLevel]]) 
		UserData[id][gLevel]++;
}
public register_player(id,data[])
{
	new szName[33];
	get_user_name(id,szName,32);

			UserData[id][gExp]= 0
			UserData[id][gLevel]= 1;
			UserData[id][g_Bonus] = 0		//Registering if it's new player
			UserData[id][Streak] = 0			//Setting counter to 0, 0 exp and 1 lvl (0 lvl is allowed, but 1 is better and without bugs)
			UserData[id][HeadStr] = 0
}
public save_usr(id)
{
	new szName[33];
	get_user_name(id,szName,32);

			static data[256];
			formatex(data, 255, "|%i|%i|%i|", UserData[id][gExp],UserData[id][gLevel],UserData[id][g_Bonus]);
			nvault_set(g_vault, szName, data);
}
public hookSay(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;

	new message[192],Len;
	read_args(message, 191);
	remove_quotes(message);
	if(is_admin_msg(message))
		return PLUGIN_CONTINUE;
	
	if(is_empty_message(message))
	{
		ColorChat(id,NORMAL,"^4[^3%L^4]^1 %L",LANG_PLAYER,"PRIFIX",LANG_PLAYER,"EMPTY_MSG")
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(gSlash))
	{
		if(is_has_slash(message))
			return PLUGIN_HANDLED_MAIN
	}
	new szName[32];
	get_user_name(id,szName,31);
	irank = get_user_stats(id,stats,bodyhits)
	if(is_user_admin(id))
	{
	if(get_pcvar_num(gChatTop) == 0){
	Len = format(gMessage[Len], charsmax(gMessage) - 1, "^4[^3%L^4] ",LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
	}else
	if(get_pcvar_num(gChatTop) == 1){
	Len = format(gMessage[Len], charsmax(gMessage) - 1, "^4[^3Ранг : %d^4][^3%L^4] ",irank,LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
	}
		switch(get_pcvar_num(gAdminGMsg))
		{
			case 1:
			{
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "^3%s^4 : ",szName);
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "%s",message);
			}
			case 2:
			{
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "^3%s^4 : ",szName);
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "^3%s",message);
			}
			default:
			{
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "^3%s^4 : ",szName);
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "^1%s",message);
			}
		}
		Chat(id,0,get_pcvar_num(gAllChat));
	}
	else 
	{
	if(get_pcvar_num(gChatTop) == 0){
	Len = format(gMessage[Len], charsmax(gMessage) - 1, "^4[^3%L^4] ",LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
	}else
	if(get_pcvar_num(gChatTop) == 1){
	Len = format(gMessage[Len], charsmax(gMessage) - 1, "^4[^3Ранг : %d^4][^3%L^4] ",irank,LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
	}
		Len += format(gMessage[Len], charsmax(gMessage) - 1, "^3%s^4 : ",szName);
		Len += format(gMessage[Len], charsmax(gMessage) - 1, "^1%s",message);
		Chat(id,0,get_pcvar_num(gAllChat));
	}
	return PLUGIN_HANDLED_MAIN
}
public hookSayTeam(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;

	new message[192],Len;
	read_args(message, 191);
	remove_quotes(message);
	if(is_admin_msg(message))
		return PLUGIN_CONTINUE;
		
	if(is_empty_message(message))
	{
		ColorChat(id,GREY,"^4[^3%L^4]^1 %L",LANG_PLAYER,"PRIFIX",LANG_PLAYER,"EMPTY_MSG");
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(gSlash))
	{
		if(is_has_slash(message))
			return PLUGIN_HANDLED_MAIN
	}
	new szName[32];
	get_user_name(id,szName,31);
	if(is_user_admin(id))
	{
		Len = format(gMessage[Len], charsmax(gMessage) - 1, "^3%L^1 ^4[^3%L^4] ^3%s^4 : ",LANG_PLAYER,"SEND_TEAM",LANG_PLAYER,gRankNames[UserData[id][gLevel]],szName);		
		switch(get_pcvar_num(gAdminGMsg))
		{
			case 1:
			{
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "%s",message);
			}
			case 2:
			{
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "^3%s",message);
			}
			default:
			{
				Len += format(gMessage[Len], charsmax(gMessage) - 1, "^1%s",message);
			}
		}
		Chat(id,1,get_pcvar_num(gAllChat));
	}
	else 
	{
		Len = format(gMessage[Len], charsmax(gMessage) - 1, "^3%L^1 ^4[^3%L^4] ",LANG_PLAYER,"SEND_TEAM",LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
		Len += format(gMessage[Len], charsmax(gMessage) - 1, "^3%s^4 : ",szName);
		Len += format(gMessage[Len], charsmax(gMessage) - 1, "^1%s",message);
		Chat(id,1,get_pcvar_num(gAllChat));
	}
	return PLUGIN_HANDLED_MAIN
}
stock is_admin_msg(const Message[])
{
	if(Message[0] == '@')
		return true;
		
	return false;
}
stock is_empty_message(const Message[])
{
	if(equal(Message, "") || !strlen(Message))
		return true;
		
	return false;
}
stock Chat(id,team,chat_type)
{
	if(team)
	{
		if(chat_type)
		{
			for(new i = 1; i <= MaxPlayers; i++)
			{
				if(!is_user_connected(i))
					continue
			
				if(get_user_team(id) == get_user_team(i))
					send_message(gMessage, id, i);
			}
		} else {
			if(is_user_alive(id))
			{
				for(new i = 1; i <= MaxPlayers; i++)
				{
					if(!is_user_connected(i) || !is_user_alive(i))
						continue
				
					if(get_user_team(id) == get_user_team(i))
						send_message(gMessage, id, i);
				}
			} else if(!is_user_alive(id)){
				for(new i = 1; i <= MaxPlayers; i++)
				{
					if(!is_user_connected(i) || is_user_alive(i))
						continue
				
					if(get_user_team(id) == get_user_team(i))
						send_message(gMessage, id, i);
				}
			}
		}
	} else{
		if(chat_type)
		{
			for(new i = 1; i <= MaxPlayers; i++)
			{
				if(!is_user_connected(i))
					continue
			
				send_message(gMessage, id, i);
			}
		} else {
			if(is_user_alive(id))
			{
				for(new i = 1; i <= MaxPlayers; i++)
				{
					if(!is_user_connected(i) || !is_user_alive(i))
						continue
				
					send_message(gMessage, id, i);
				}
			} else if(!is_user_alive(id)){
				for(new i = 1; i <= MaxPlayers; i++)
				{
					if(!is_user_connected(i) || is_user_alive(i))
						continue
				
					send_message(gMessage, id, i);
				}
			}
		}
	}
}
stock send_message(const message[], const id, const i)
{
	message_begin(MSG_ONE, gSayText, {0, 0, 0}, i)
	write_byte(id)
	write_string(message)
	message_end()
}
stock is_has_slash(const Message[])
{
	if(Message[0] == '/')
		return true;
		
	return false;
}

public client_infochanged(id)
{
	new newname[32],oldname[32]
	get_user_info(id, "name", newname,31)
	get_user_name(id,oldname,31)
	if(!is_user_connected(id) || is_user_bot(id)) 
		return PLUGIN_CONTINUE
		
	if(!equali(newname, oldname))
	{
		set_user_info(id,"name",oldname);
		log_amx("[ABS] Namechange blocked.");
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}
public msg_SayText()
{
	new arg[32]
	get_msg_arg_string(2, arg, 31)
	if(containi(arg,"name")!=-1)
		return PLUGIN_HANDLED

	return PLUGIN_CONTINUE
}
public plugin_natives()
{
	register_native("get_user_exp", "native_get_user_exp", 1);
	register_native("get_user_lvl", "native_get_user_lvl", 1);
	register_native("set_user_exp", "native_set_user_exp", 1);
	register_native("set_user_lvl", "native_set_user_lvl", 1);
	register_native("get_user_rankname", "native_get_user_rankname", 1);
	register_native("get_user_bonus", "native_get_user_bonus", 1);
	register_native("set_user_bonus", "native_set_user_bonus", 1);
	register_native("get_user_expto", "native_get_user_expto", 1);		//How much expirience to new lev
	register_native("get_map_block","map_block",1)
}

public map_block(id)
{
return block	
}

public native_get_user_expto(id)
{
return gLevels[UserData[id][gLevel]]		//How much expirience to new lev
}

public native_get_user_bonus(id)
{
return UserData[id][g_Bonus]	
}

public native_set_user_bonus(id,num)
{
UserData[id][g_Bonus] = num;
}

public native_set_user_exp(id,num)
{
	UserData[id][gExp] = num;
}
public native_set_user_lvl(id,num)
{
	UserData[id][gLevel] = num;
}
public native_get_user_exp(id)
{
	return UserData[id][gExp];
}
public native_get_user_lvl(id)
{
	return UserData[id][gLevel];
}
public native_get_user_rankname(id)
{
	static szRankName[64];
	format(szRankName, charsmax(szRankName), "%L",LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
	return szRankName;
}

public Info()
{
	for(new id = 1; id <= MaxPlayers; id++)
	{
		if(!is_user_bot(id) && is_user_connected(id) && is_user_alive(id))
		{
			new Colores[12], rgb[3][4], Red, Green, Blue
			get_pcvar_string(ar_colors, Colores, charsmax(Colores))
			parse(Colores, rgb[0], 3, rgb[1], 3, rgb[2], 3)
			Red = clamp(str_to_num(rgb[0]), 0, 255)
			Green = clamp(str_to_num(rgb[1]), 0, 255)
			Blue = clamp(str_to_num(rgb[2]), 0, 255)
			
			static buffer[192], len;
			len = format(buffer, charsmax(buffer), "%L",LANG_PLAYER,"ZVANIE");
			len += format(buffer[len], charsmax(buffer) - len, " %L",LANG_PLAYER,gRankNames[UserData[id][gLevel]]);
			if(UserData[id][gLevel] <= 19)
			{
				len += format(buffer[len], charsmax(buffer) - len, "^n%L",LANG_PLAYER,"PL_XP",UserData[id][gExp],gLevels[UserData[id][gLevel]]);
			} else {
				len += format(buffer[len], charsmax(buffer) - len, "^n%L",LANG_PLAYER,"PL_MAX");
			}
			new name[33];get_user_name(id,name,32)

			set_dhudmessage(Red, Green, Blue, 0.01, 0.16, 0, 1.0, 1.0, _, _, _);
			show_dhudmessage(id,"Ник : %s^n%s",name, buffer);
			
			if(get_pcvar_num(ar_kill_counter)==1){	
			set_dhudmessage(Red, Green, Blue, 0.01, 0.85, 0, 1.0, 1.0)
			show_dhudmessage(id, "Убито : %d ^nВ голову : %d",UserData[id][Streak],UserData[id][HeadStr])	
			}
			set_dhudmessage(Red, Green, Blue,-1.0,0.90, 0, 1.0, 1.0)
			show_dhudmessage(id,"%L",LANG_PLAYER,"ANEW_INFO", UserData[id][g_Bonus])
			}
			}
	return PLUGIN_CONTINUE 	
	}
			



///Finally I made this menu looks cool
public anew_menu(id){
	
if(get_pcvar_num(ar_bonus_on)==0){
	ColorChat(id,RED,"%L",LANG_PLAYER,"BONUS_OFF")
	return PLUGIN_HANDLED
}

if(restr_blocked == true){
	ColorChat(id,RED,"%L",LANG_PLAYER,"BLOCKED_MAP_BONUS")
	return PLUGIN_HANDLED
}

if(!is_user_alive(id)){
	ColorChat(id,RED,"%L",LANG_PLAYER,"ONLY_ALIVE")	
	return PLUGIN_HANDLED
}
	
if(round <= get_pcvar_num(ar_round_acc)){
	ColorChat(id,RED,"%L",LANG_PLAYER,"ENOUGH_ROUND",get_pcvar_num(ar_round_acc))
	return PLUGIN_HANDLED	
}

		static s_menu_it[700]
		new Text[1024]
		format(s_menu_it, charsmax(s_menu_it), "%L",LANG_PLAYER,"MENU_TITLE",UserData[id][g_Bonus])
		
		new menu = menu_create(s_menu_it, "func_anew_menu")
		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost1])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_ONE",get_pcvar_num(Costs_cvar[cost1]));
			menu_additem(menu, Text,"1")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu, Text,"1")
		}

		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost2])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_TWO",get_pcvar_num(Costs_cvar[cost2]));
			menu_additem(menu, Text,"2")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu, Text,"2")
		}

		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost3])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_THREE",get_pcvar_num(Costs_cvar[cost3]));
			menu_additem(menu, Text,"3")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu, Text,"3")
		}

		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost4])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_FOUR",get_pcvar_num(Costs_cvar[menu_str1]),get_pcvar_num(Costs_cvar[cost4]));
			menu_additem(menu,Text,"4")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu,Text,"4")
		}

		if (UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost5])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_FIVE",get_pcvar_num(Costs_cvar[menu_str2]),get_pcvar_num(Costs_cvar[5]));
			menu_additem(menu,Text,"5")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu,Text,"5")	
		}
		
		
		if (UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost6])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_SIX",get_pcvar_num(Costs_cvar[menu_str3]),get_pcvar_num(Costs_cvar[cost6]));
			menu_additem(menu,Text,"6")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu,Text,"6")
		}
		
		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost7])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_SEVEN",get_pcvar_num(Costs_cvar[cost7]));
			menu_additem(menu,Text,"7")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu,Text,"7")
		}
		
		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost8])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_EIGHT",get_pcvar_num(Costs_cvar[cost8]));
			menu_additem(menu,Text,"8")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu,Text,"8")
		}
		
		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost9])){
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_NINE",get_pcvar_num(Costs_cvar[cost9]));
			menu_additem(menu,Text,"9")
		}else{
			formatex(Text, charsmax(Text), "%L", id, "MENU_HANDLE_OFF");
			menu_additem(menu,Text,"9")
		}
		
		menu_setprop(menu, MPROP_BACKNAME, "Назад")
		menu_setprop(menu, MPROP_NEXTNAME, "Далее")
		menu_setprop(menu, MPROP_EXITNAME, "Выход")
		menu_display(id,menu,0)
		return PLUGIN_HANDLED
		}







public func_anew_menu(id, menu, item)
{
    if( item == MENU_EXIT )
    {
        menu_destroy( menu );
        return PLUGIN_HANDLED;
    }
    new data[6], iName[64];
    new access, callback;
     
    menu_item_getinfo( menu, item, access, data,5, iName, 63, callback );
    new key = str_to_num( data );
    switch( key )
        {
		case 1:{
	if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost1])){
	give_item(id,"weapon_awp")
	give_item(id,"weapon_hegrenade")
	give_item(id,"weapon_flashbang")
	cs_set_user_bpammo( id, CSW_AWP, 40);
	set_user_armor(id, 100);
	ColorChat(id,TEAM_COLOR,"Вы взяли  [AWP + Комплект]")
	UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost1])
	}
	}
		case 2:{
		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost2])){
		give_item(id,"weapon_ak47");
		give_item(id,"weapon_hegrenade")
		give_item(id,"weapon_flashbang")
		give_item(id,"weapon_flashbang")
		cs_set_user_bpammo( id, CSW_AK47, 200);
		ColorChat(id,TEAM_COLOR,"Вы взяли  [AK-47 + Комплект]")
		UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost2]);
	}
	}
		case 3:{
		if(UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost3])){
		give_item(id,"weapon_m4a1");
		give_item(id,"weapon_hegrenade")
		give_item(id,"weapon_flashbang")
		give_item(id,"weapon_flashbang")
		cs_set_user_bpammo( id, CSW_M4A1, 200);
		ColorChat(id,TEAM_COLOR,"Вы взяли  [M4A1+ Комплект]")
		UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost3]);
	}
	}
		case 4:{
		if (UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost4])){
		cs_set_user_money(id,cs_get_user_money(id)+get_pcvar_num(Costs_cvar[menu_str1]),1)
		ColorChat(id,TEAM_COLOR,"Вы взяли  [%d$]",get_pcvar_num(Costs_cvar[menu_str1]))
		UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost4])
	}
	}
		case 5:{
		if (UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost5])){
		set_user_health(id,get_user_health(id) + get_pcvar_num(Costs_cvar[menu_str2]))
		ColorChat(id,TEAM_COLOR,"Вы взяли  [+%d HP]",get_pcvar_num(Costs_cvar[menu_str2]))
		UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost5]);
		
	}
	}
		
		case 6:{
		if (UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost6])){
		UserData[id][gExp] += get_pcvar_num(Costs_cvar[menu_str3])
		check_level(id)		//Checks lvl of the player, because it can be more than level have xd
		ColorChat(id,TEAM_COLOR,"Вы взяли  [%d Опыта Army Ranks]",get_pcvar_num(Costs_cvar[menu_str3]))
		UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost6]);
		
	}
	}
		
		case 7:{
		if (UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost7])){
		set_user_rendering(id,kRenderFxNone,0,0,0, kRenderTransTexture,60)	//Turning on invisibility)
		UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost7])
	}
	}
		
		case 8:{
		if (UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost8])){
		if(!user_has_weapon(id,CSW_HEGRENADE))
		fm_give_item(id,"weapon_hegrenade")
		players[id] |= (1<<MEGA_GRENADE)
		ColorChat(id,TEAM_COLOR,"Вы взяли MEGA GRENADE")
		UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost8])
	}
	}
		
		case 9:{
		if (UserData[id][g_Bonus] >= get_pcvar_num(Costs_cvar[cost9])){
		DropWeaponSlot(id,2)
		fm_give_item(id,"weapon_deagle")
		cs_set_user_bpammo(id,CSW_DEAGLE,35)
		players[id] |= (1<<MEGA_DEAGLE)
		ColorChat(id,TEAM_COLOR,"Вы взяли MEGA DEAGLE")
		UserData[id][g_Bonus] -= get_pcvar_num(Costs_cvar[cost9])
	}
	}
		///case add here please
	}
	    return PLUGIN_HANDLED
	}

DropWeaponSlot( iPlayer, iSlot ){
	static const m_rpgPlayerItems = 367;
	static const m_pNext = 42; 
	static const m_iId = 43; 
	
	if( !( 1 <= iSlot <= 2 ) )	{
		return 0;
	}
	
	new iCount;
	
	new iEntity = get_pdata_cbase( iPlayer, ( m_rpgPlayerItems + iSlot ), 5 );
	if( iEntity > 0 )	{
		new iNext;
		new szWeaponName[ 32 ];
		
		do	{
			iNext = get_pdata_cbase( iEntity, m_pNext, 4 );
			
			if( get_weaponname( get_pdata_int( iEntity, m_iId, 4 ), szWeaponName, charsmax( szWeaponName ) ) )		{
				engclient_cmd( iPlayer, "drop", szWeaponName );
				
				iCount++;
			}
		}	while( ( iEntity = iNext ) > 0 );
	}
	
	return iCount;
}

public plugin_precache(){

	precache_sound("abs/lvl_up.wav")

}
