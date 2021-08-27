public plugin_natives (){
    register_native("msm_get_hero_name", "native_get_hero_name", 1);
    register_native("msm_get_user_headshots", "native_get_headshots", 1);
    register_native("msm_get_user_kills", "native_get_kills", 1);
};

public native_get_hero_name(id){
    return hero[id];
};

public native_get_headshots(id){
    return info[id][headshots];
};

public native_get_kills(id){
    return info[id][kills];
};