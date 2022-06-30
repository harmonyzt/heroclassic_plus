// Welcoming player
public client_putinserver(id){
    set_task(2.5,"welcomepl",id);
    hero[id] = NONE;
    hero_hp[id] = 600;

    // Start loading data from file
    load_data(id); 
}

// Loading data
public load_data(id){
	new Name[33];
		get_user_name(id,Name,32);

		static data[256], timestamp;
		if(nvault_lookup(msm_vault, Name, data, sizeof(data) - 1, timestamp) )
		{
			next_load_data(id, data, sizeof(data) - 1);
			return;
		} else {
            // Registering new player in database if not found
			register_player(id,"");
		}
}

//  Start loading data from database
public next_load_data(id,data[],len){
	new Name[33];
	get_user_name(id,Name,32);
	replace_all(data,len,"|"," ");		
	new user_score[10], user_hasVampiricHelmet[10], user_hasGloriousArmor[10];
	parse(data, user_score,9, user_hasVampiricHelmet,9, user_hasGloriousArmor,9);
	info[id][score]= str_to_num(user_score);
	info[id][hasVampiricHelmet]= str_to_num(user_hasVampiricHelmet);
	info[id][hasGloriousArmor]= str_to_num(user_hasGloriousArmor);
}

public register_player(id,data[]){
	new Name[33];
	get_user_name(id,Name,32);

    //Setting everything to 0 for new player
    info[id][score] = 0;
    info[id][hasVampiricHelmet] = 0;
    info[id][hasGloriousArmor] = 0;
    info[id][kills] = 0;
    info[id][headshots] = 0;
}

// On disconnect
public client_disconnect(id){
    new dcName[32]
    if( msm_active == 1 && id == msm_boss ) {    //Checking if boss left or not and announcing next one.
		msm_boss = 0;
		msm_active = 0;
		ColorChat(0, RED, "%L", LANG_PLAYER, "BOSS_LEFT", get_user_name(id,dcName,31));
	}

    // Reseting all attributes if player disconnects
    attribute[id][sl_leashstack] = 0;
    attribute[id][sl_selfstack] = 0;
    attribute[id][undying_hpstack] = 0;
    attribute[id][undying_hpstolen_timed] = 0;
    attribute[id][poisoned_from_undying] = 0;
    hero[id] = NONE;

    // Saving all of the info of user to the file
    save_user(id)
    return PLUGIN_CONTINUE;
}

public save_user(id){
	new Name[33];
	get_user_name(id,Name,32);

	static data[256];
	formatex(data, 255, "|%i|%i|%i|", info[id][score], info[id][hasVampiricHelmet], info[id][hasGloriousArmor]);
	nvault_set(msm_vault, Name, data);
}