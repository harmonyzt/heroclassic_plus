// Choosing random player to give a class (usually a bot)
public BotThink() {
	static Players[32], Count, id_rand;
	get_players(Players, Count, "ahd");
	id_rand = random_num(0, Count - 1);
    new ran_number = random_num(1,3);

    if (hero[id_rand] != NONE)
        return PLUGIN_HANDLED;

    switch(ran_number){
        case 1:{
            hero[id_rand] = BERSERK;
        }
        case 2:{
            hero[id_rand] = SL;
        }
        case 3:{
            hero[id_rand] = UNDYING;
        }
    }
    return PLUGIN_HANDLED;
}