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
                hero[id_rand] = SL;
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

    return PLUGIN_HANDLED;
}