public Bot_Think() {
	static Players[32], Count, id_rand;
	get_players(Players, Count, "ah");
	id_rand = random_num(0, Count - 1);

    if(hero[id_rand] == hero[msm_boss])
        return PLUGIN_HANDLED;
    
    switch(random_num(1,3)){
        case 1:{
            hero[id_rand] = BERSERK
            ColorChat(0, RED, "Someone took berserk!")
        }
        case 2:{
            hero[id_rand] = SL
            ColorChat(0, RED, "Someone took slark!")
        }
        case 3:{
            hero[id_rand] = UNDYING
            ColorChat(0, RED, "Someone took undying!")
        }
    }
    return PLUGIN_HANDLED
}