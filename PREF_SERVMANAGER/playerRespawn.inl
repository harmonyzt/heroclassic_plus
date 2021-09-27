public csdm_PreSpawn(player, bool:fake){
    set_hero_attribute(player)
}

//public player_respawn(id){
//    set_hero_attribute(id)
//}
// Removing stolen attributes
public set_hero_attribute(id){
switch(msm_get_user_hero(id)){
    case NONE:{
        set_user_health(id, hero_hp[id])
        }

    case SL:{
        set_user_health(id, hero_hp[id])
        }

    case UNDYING:{
        set_user_health(id, hero_hp[id])
        }

    }
}