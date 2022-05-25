// Function called when round starts
public round_start(){
    RoundCount += 1;
    isFirstBlood = 0;
    for(new id = 1; id <= get_maxplayers(); id++){
        set_user_health(id, hero_hp[id]);
        switch(msm_get_user_hero(id)){
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
            recover_knight_shield(id);
            }   
        }
    }
}
