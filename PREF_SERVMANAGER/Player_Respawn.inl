// Function called when player is respawned by CSDM MOD !!!
public csdm_PreSpawn(player, bool:fake){
    set_user_health(player, hero_hp[player]);
    recover_knight_shield(player);
    play_s_sound(player);
}