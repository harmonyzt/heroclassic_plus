// Function called when player is respawned by CSDM MOD !!!

public csdm_PreSpawn(player, bool:fake){
    set_user_health(player, hero_hp[player])
    msm_align_model(player);
}