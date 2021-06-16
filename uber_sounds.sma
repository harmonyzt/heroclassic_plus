/********************************************************************************
 	

[ Uber Sounds ]

cvar:

streak_mode < flags >
"a" - messages
"b" - sounds
knife_mode < flags >
"a" - messages
"b" - sounds

hs_mode < flags >
"a" - messages
"b" - sounds

lastman_mode < flags >
"a" - messages
"b" - hp "c" - sounds

*/

// Plugin Info
new const PLUGIN[]  = "Uber Sounds"
new const VERSION[] = "1.0"
new const AUTHOR[]  = "harmony"


// Includes
#include <amxmodx>


//Defines
#define KNIFEMESSAGES 5
#define MESSAGESNOHP 5
#define MESSAGESHP 5
#define LEVELS 30


//Pcvars
new streak_mode, knife_mode, hs_mode, lastman_mode

new gmsgHudSync

new kills[33] = {0,...};
new deaths[33] = {0,...};
new alone_ann = 0
new levels[30] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};

//Streak Sounds
new stksounds[30][] = {
"misc/FIRE_PLAY/3multikill",
"misc/FIRE_PLAY/4megakill",
"misc/FIRE_PLAY/5rampage",
"misc/FIRE_PLAY/6monsterkill",
"misc/FIRE_PLAY/7ultrakill",
"misc/FIRE_PLAY/8holyshit",
"misc/FIRE_PLAY/9godlike",
"misc/FIRE_PLAY/10unstoppable",
"misc/FIRE_PLAY/11ludacrisskill",
"misc/FIRE_PLAY/12wickedsick",
"misc/FIRE_PLAY/13blazeofglory",
"misc/FIRE_PLAY/14bloodbath",
"misc/FIRE_PLAY/15assassin",
"misc/FIRE_PLAY/16excellent",
"misc/FIRE_PLAY/17extermination",
"misc/FIRE_PLAY/18hattrick",
"misc/FIRE_PLAY/19headhunter",
"misc/FIRE_PLAY/20impressive",
"misc/FIRE_PLAY/21outstanding",
"misc/FIRE_PLAY/22payback",
"misc/FIRE_PLAY/23retribution",
"misc/FIRE_PLAY/24vengeance",
"misc/FIRE_PLAY/25eagleeye",
"misc/FIRE_PLAY/26termination",
"misc/FIRE_PLAY/27unreal",
"misc/FIRE_PLAY/28topgun",
"misc/FIRE_PLAY/29killingmachine",
"misc/FIRE_PLAY/30maniac",
"misc/FIRE_PLAY/31massacre",
"misc/FIRE_PLAY/32warpath"};

//Exact Messages
new stkmessages[30][] = {
"%s: Multi-Kill!",
"%s: Mega-Kill!",
"%s: Rampage!",
"%s: Monster-Kill!",
"%s: Ultra-Kill!",
"%s: Holy Shit!",
"%s: Godlike!",
"%s: Unstoppable!",
"%s: Ludacriss-Kill!",
"%s: Wicked Sick!",
"%s: BlazeOfGlory!",
"%s: Blood Bath!",
"%s: Assasin!",
"%s: Excellent!",
"%s: Extermination!",
"%s: Hat Trick!",
"%s: Head Hunter!",
"%s: Impressive!",
"%s: Outstanding!",
"%s: PayBack!",
"%s: Retribution!",
"%s: Vengeance!",
"%s: Eagleeye!",
"%s: Termination!",
"%s: Unreal!",
"%s: Topgun!",
"%s: Killing Machine!",
"%s: Maniac!",
"%s: Mssacre!",
"%s: Warpath!!!"}


new knifemessages[KNIFEMESSAGES][] = 
{
	"KNIFE_MSG_1",  
	"KNIFE_MSG_2",  
	"KNIFE_MSG_3",  
	"KNIFE_MSG_4",  
	"KNIFE_MSG_5"
}

new messagesnohp[MESSAGESNOHP][] = 
{
	"NOHP_MSG_1",  
	"NOHP_MSG_2",  
	"NOHP_MSG_3",  
	"NOHP_MSG_4",  
	"NOHP_MSG_5"
}

new messageshp[MESSAGESHP][] = 
{
	"HP_MSG_1",  
	"HP_MSG_2",  
	"HP_MSG_3",  
	"HP_MSG_4",  
	"HP_MSG_5"
}

new first_blood=0
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_cvar("ultimate_sounds",VERSION,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	register_dictionary("FIRE_PLAY.txt")
	register_event("DeathMsg","hs","a","3=1")
	register_event("DeathMsg","knife_kill","a","4&kni")
	register_event("ResetHUD", "reset_hud", "b");
	register_event("DeathMsg", "death_event", "a", "1>0");
	register_event("DeathMsg","death_msg","a")
	register_event("SendAudio","roundend_msg","a","2=%!MRAD_terwin","2=%!MRAD_ctwin","2=%!MRAD_rounddraw")
	register_event("TextMsg","roundend_msg","a","2&#Game_C","2&#Game_w")

	lastman_mode = register_cvar("lastman_mode","abc")
	streak_mode = register_cvar("streak_mode","ab")
	knife_mode = register_cvar("knife_mode","ab")
	hs_mode = register_cvar("hs_mode","ab")

	gmsgHudSync = CreateHudSyncObj()

	return PLUGIN_CONTINUE
}


get_streak()
{
	new streak[3]
	get_pcvar_string(streak_mode,streak,2)
	return read_flags(streak)
}

public death_event(id)
{
	if(first_blood == 0){
		set_hudmessage(0, 100, 200, 0.50, 0.75, 2, 0.02, 6.0, 0.01, 0.1, 3);
		ShowSyncHudMsg(0, gmsgHudSync, "<< FIRST FUCKING BLOOD >>");
		client_cmd(0, "spk misc/FIRE_PLAY/firstblood");
		first_blood = 1
	}
	new streak = get_streak()

	if ((streak&1) || (streak&2))
	{
    		new killer = read_data(1);
    		new victim = read_data(2);

    		kills[killer] += 1;
    		kills[victim] = 0;
    		deaths[killer] = 0;
    		deaths[victim] += 1;

    		for (new i = 0; i < LEVELS; i++)
		{
        		if (kills[killer] == levels[i])
			{
         	  		 announce(killer, i);
         	  		 return PLUGIN_CONTINUE;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

announce(killer, level)
{
	new streak = get_streak()

	if (streak&1)
	{
    		new name[32];

   		get_user_name(killer, name, 32);
		set_hudmessage(255, 255, 255, 0.30, 0.15, 2, 0.02, 6.0, 0.01, 0.1, 3);
		ShowSyncHudMsg(0, gmsgHudSync, stkmessages[level], name);
	}

	if (streak&2){
		for(new i=1;i<=get_maxplayers();i++) 
			if(is_user_connected(i) ==1 )
				client_cmd(i, "spk %s", stksounds[level]); 
	}
}

public reset_hud(id)
{
	new streak = get_streak()

	if (streak&1)
	{

		if (kills[id] > levels[0])

		{
		        client_print(id, print_chat,"%L", id, "KILL_STREAK", kills[id]);
		}

		else if (deaths[id] > 1)

		{
			client_print(id, print_chat,"%L", id, "DEATH_STREAK", deaths[id]);
		}
	}
}

public client_connect(id)
{
	new streak = get_streak()

	if ((streak&1) || (streak&2))
	{
		kills[id] = 0;
		deaths[id] = 0;
	}
}

public knife_kill()
{
	new knifemode[4] 
	get_pcvar_string(knife_mode,knifemode,4) 
	new knifemode_bit = read_flags(knifemode)

	if (knifemode_bit & 1)
	{
		new killer_id = read_data(1)
		new victim_id = read_data(2)
		new killer_name[33], victim_name[33]

		get_user_name(killer_id,killer_name,33)
		get_user_name(victim_id,victim_name,33)


		set_hudmessage(255, 255, 255, -1.0, 0.75, 0, 6.0, 6.0, 0.5, 0.15, 1)
		ShowSyncHudMsg(0, gmsgHudSync, "%L", LANG_PLAYER, knifemessages[ random_num(0,KNIFEMESSAGES-1) ],killer_name,victim_name)
	}

	if (knifemode_bit & 2)
	{
		for(new i=1;i<=get_maxplayers();i++) 
			if(is_user_connected(i)==1 )
				client_cmd(i,"spk misc/FIRE_PLAY/humiliation")
   	}
}


public roundend_msg(id)

	alone_ann = 0

public death_msg(id)
{

	new lmmode[8] 
	get_pcvar_string(lastman_mode,lmmode,8) 
	new lmmode_bit = read_flags(lmmode)

	new players_ct[32], players_t[32], ict, ite, last
	get_players(players_ct,ict,"ae","CT")   
	get_players(players_t,ite,"ae","TERRORIST")   

	if (ict==1&&ite==1)
	{
		new name1[32], name2[32]
		get_user_name(players_ct[0],name1,32)
		get_user_name(players_t[0],name2,32)
		set_hudmessage(255, 255, 255, -1.0, 0.75, 0, 6.0, 6.0, 0.5, 0.15, 1)

		if (lmmode_bit & 1)
		{
			if (lmmode_bit & 2)
			{
				ShowSyncHudMsg(0, gmsgHudSync, "%s (%i hp) vs. %s (%i hp)",name1,get_user_health(players_ct[0]),name2,get_user_health(players_t[0]))
			}

			else
			{
				ShowSyncHudMsg(0, gmsgHudSync, "%s vs. %s",name1,name2)
			}

			if (lmmode_bit & 4)
			{
				for(new i=1;i<=get_maxplayers();i++) 
					if( is_user_connected(i) == 1 )
						client_cmd(i,"spk misc/maytheforce")
			}
		}
	} 
	else
{   
	if (ict==1&&ite>1&&alone_ann==0&&(lmmode_bit & 4))
	{
		last=players_ct[0]
		client_cmd(last,"spk misc/FIRE_PLAY/oneandonly")
	}

	else if (ite==1&&ict>1&&alone_ann==0&&(lmmode_bit & 4))
	{
		last=players_t[0]
		client_cmd(last,"spk misc/FIRE_PLAY/oneandonly")
	}

	else
	{
		return PLUGIN_CONTINUE
	}
	alone_ann = last
	new name[32]   
	get_user_name(last,name,32)

	if (lmmode_bit & 1)
	{
		set_hudmessage(255, 255, 255, -1.0, 0.75, 0, 6.0, 6.0, 0.5, 0.15, 1)

		if (lmmode_bit & 2)
		if (lmmode_bit & 2)
		{
			ShowSyncHudMsg(0, gmsgHudSync, "%L", LANG_PLAYER, messageshp[ random_num(0,MESSAGESHP-1) ],ite ,ict ,name,get_user_health(last))
		}

		else
		{
			ShowSyncHudMsg(0, gmsgHudSync, "%L", LANG_PLAYER, messagesnohp[ random_num(0,MESSAGESNOHP-1) ],ite ,ict ,name )
		}
	}
}
	return PLUGIN_CONTINUE   
}


public hs()
{
	new hsmode[4] 
	get_pcvar_string(hs_mode,hsmode,4) 
	new hsmode_bit = read_flags(hsmode)

	if (hsmode_bit & 1)
	{
	new killer_id = read_data(1)
	new victim_id = read_data(2)
	new victim_name[33]

	get_user_name(victim_id,victim_name,33)

	set_hudmessage(200, 100, 0, -1.0, 0.30, 0, 3.0, 3.0, 0.15, 0.15, 1)
	ShowSyncHudMsg(killer_id, gmsgHudSync, "HEADSHOT",victim_name)
	}

	if (hsmode_bit & 2)
	{
		for(new i=1;i<=get_maxplayers();i++) 
			if(is_user_connected(i)==1)
				client_cmd(i,"spk misc/FIRE_PLAY/headshot")
	}
}

public plugin_precache()
{
	precache_sound("misc/FIRE_PLAY/3multikill.wav")
	precache_sound("misc/FIRE_PLAY/4megakill.wav")
	precache_sound("misc/FIRE_PLAY/5rampage.wav")
	precache_sound("misc/FIRE_PLAY/6monsterkill.wav")
	precache_sound("misc/FIRE_PLAY/7ultrakill.wav")
	precache_sound("misc/FIRE_PLAY/8holyshit.wav")
	precache_sound("misc/FIRE_PLAY/9godlike.wav")
	precache_sound("misc/FIRE_PLAY/maytheforce.wav")
	precache_sound("misc/FIRE_PLAY/10unstoppable.wav")
	precache_sound("misc/FIRE_PLAY/11ludacrisskill.wav")
	precache_sound("misc/FIRE_PLAY/12wickedsick.wav")
	precache_sound("misc/FIRE_PLAY/13blazeofglory.wav")
	precache_sound("misc/FIRE_PLAY/14bloodbath.wav")
	precache_sound("misc/FIRE_PLAY/15assassin.wav")
	precache_sound("misc/FIRE_PLAY/16excellent.wav")
	precache_sound("misc/FIRE_PLAY/17extermination.wav")
	precache_sound("misc/FIRE_PLAY/18hattrick.wav")
	precache_sound("misc/FIRE_PLAY/19headhunter.wav")
	precache_sound("misc/FIRE_PLAY/20impressive.wav")
	precache_sound("misc/FIRE_PLAY/21outstanding.wav")
	precache_sound("misc/FIRE_PLAY/22payback.wav")
	precache_sound("misc/FIRE_PLAY/23retribution.wav")
	precache_sound("misc/FIRE_PLAY/24vengeance.wav")
	precache_sound("misc/FIRE_PLAY/25eagleeye.wav")
	precache_sound("misc/FIRE_PLAY/26termination.wav")
	precache_sound("misc/FIRE_PLAY/27unreal.wav")
	precache_sound("misc/FIRE_PLAY/28topgun.wav")
	precache_sound("misc/FIRE_PLAY/29killingmachine.wav")
	precache_sound("misc/FIRE_PLAY/30maniac.wav")
	precache_sound("misc/FIRE_PLAY/31massacre.wav")
	precache_sound("misc/FIRE_PLAY/32warpath.wav")
	precache_sound("misc/FIRE_PLAY/headshot.wav")
	precache_sound("misc/FIRE_PLAY/humiliation.wav")
	precache_sound("misc/FIRE_PLAY/oneandonly.wav")
	precache_sound("misc/FIRE_PLAY/firstblood.wav")

	return PLUGIN_CONTINUE 
}
