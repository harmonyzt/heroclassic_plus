// Emulating a bot randomly choosing class
public BotThink() {
    // Stop the function if n rounds didn't pass
    if(RoundCount > 3)
        return PLUGIN_HANDLED;
    
	static Players[32], Count, id_rand;
	get_players(Players, Count, "ahd");
	id_rand = random_num(0, Count - 1);
    new ran_number = random_num(1,4);

    // Bot will randomly pick a class, with a small chance of not picking anything
    new botwill = random_num(10,30);
    
    // If bot is not having any class and he's dead, assign random class
    if (hero[id_rand] == NONE && !is_user_alive(id_rand) && botwill > 15){
        switch(ran_number){
            case 1:{
                hero[id_rand] = BERSERK;
                play_s_sound(id_rand);
            }
            case 2:{
                hero[id_rand] = SLARK;
                play_s_sound(id_rand);
            }
            case 3:{
                hero[id_rand] = UNDYING;
                play_s_sound(id_rand);
            }
            case 4:{
                hero[id_rand] = KNIGHT;
                play_s_sound(id_rand);
            }
        }
    }
    
    // If bot is dying too much, make him consider to change his class
    new thinkofswitch = random_num(1,10);
    if(hero[id_rand] == NONE && !is_user_alive(id_rand) && thinkofswitch >= 2 && get_user_frags(id_rand) <= get_user_deaths(id_rand)){
        switch(random_num(1,6)){
            case 1:{
                hero[id_rand] = NONE;
                reset_all_attributes(id_rand);
            }
            case 2:{
                hero[id_rand] = SLARK;
                reset_all_attributes(id_rand);
            }
            case 3:{
                hero[id_rand] = UNDYING;
                reset_all_attributes(id_rand);
            }
            case 4:{
                hero[id_rand] = BERSERK;
                reset_all_attributes(id_rand);
            }
            case 5:{
                hero[id_rand] = ZEUS;
                reset_all_attributes(id_rand);
            }
            case 6:{
                hero[id_rand] = KNIGHT;
                reset_all_attributes(id_rand);
            }
        }
    }

    return PLUGIN_HANDLED;
}