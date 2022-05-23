// Function called when player is respawned by CSDM MOD !!!
public csdm_PreSpawn(player, bool:fake){
    set_user_health(player, hero_hp[player]);
    play_s_sound(player);

    // Actions on player respawn
    switch(msm_get_user_hero(player)){
        case NONE:{
            
        }
        case SL:{
            
        }
        case UNDYING:{
            
        }
        case BERSERK:{
            
        }
        case ZEUS:{

        }
        case KNIGHT:{
            recover_knight_shield(player);
        }   
    }
}
