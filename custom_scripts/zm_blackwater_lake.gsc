// Blackwater Lake Survival 0.2.133. Lake pump, power lever and cabin services.
// Only the Firefly/zone_lakefront selection activates this script, apart
// from the diagnostic-only Nuked probe below.
// The native Survival main, round logic, spawning, box and purchases run once.
#using scripts\common\callbacks;
#using script_2b867a98ca762b0a;
#using script_2c751cf74eafeb9a;
#using script_45e1c753917c8703;
#using script_ac28d65e8605696;
#using script_3ca070ee1ba8337c;
#using script_692b19b8e5f8f9e8;
#using script_7b92812967b04687;
#using script_4a975d4ec578d9b0;
#using script_4f24ca7a470a5fa8;
#using script_27623f7ac600060c;
#using script_7bef99a2b184bfd5;
#using script_caf1d000c52b25d;
#using script_4b576523c81e6ee3;
#using script_70a710e9c0b2022d;
#using script_46fecad419c065b2;
#using script_16ea1b94f0f381b3;
#using script_c1369b1abe9a0d1;
#using script_66cb9fe5d1bbff6;

autoexec bwl_register()
{
    if ( !bwl_selected() )
        return;

    nengine_store_set( "blackwater_lake", "version", "0.2.133" );
    nengine_store_set( "blackwater_lake", "spawned", 0 );
    nengine_store_set( "blackwater_lake", "truck_status", "not_started" );
    nengine_store_set( "blackwater_lake", "pap_status", "not_started" );
    nengine_store_set( "blackwater_lake", "pap_menu_resolved", 0 );
    nengine_store_set( "blackwater_lake", "pap_use_callback", 0 );
    nengine_store_set( "blackwater_lake", "pap_fx_status", "not_started" );
    nengine_store_set( "blackwater_lake", "wunderfizz_status", "not_started" );
    nengine_store_set( "blackwater_lake", "lake_power_override_called", 0 );
    nengine_store_set( "blackwater_lake", "lake_power_override_before", -1 );
    nengine_store_set( "blackwater_lake", "lake_power_override_after", -1 );
    nengine_store_set( "blackwater_lake", "lake_hitmarker_provider", -1 );
    nengine_store_set( "blackwater_lake", "lake_hud_status", "not_started" );
    nengine_store_set( "blackwater_lake", "lake_hud_mode", "not_checked" );
    nengine_store_set( "blackwater_lake", "lake_timer", "not_started" );
    nengine_store_set( "blackwater_lake", "lake_regrowths", 0 );
    // Farm Survival registers this native hook before the generic Survival
    // startup sets its automatic flags. Keep the normal Firefly quest path,
    // which removes the barriers, and clear only the lake power flag here.
    level namespace_60b3bdcc70f79fc6::function_de57f49b8df192cc(
        #"hash_280e25dd3ca205d4", #"hash_f3e9e6a0409b1c3e", &bwl_lake_native_power_override );
    // Load the light-only yellow effect during level load, before power-on.
    level.bwl_pap_light_fx = loadfxasset( "vfx_t10_gameplay_zm_field_trap_light_yellow" );
    nengine_store_set( "blackwater_lake", "pap_light_loaded", isdefined( level.bwl_pap_light_fx ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_light_status", "waiting_for_power" );
    // 0.2.72: the same field trap's green light, added to the orange for yellow.
    level.bwl_pap_light_green_fx = loadfxasset( "vfx_t10_gameplay_zm_field_trap_light_green" );
    nengine_store_set( "blackwater_lake", "pap_light_green_loaded", isdefined( level.bwl_pap_light_green_fx ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_light_color", "waiting_for_power" );
    // 0.2.74: a dim blue light inside the roller section.
    level.bwl_pap_blue_fx = loadfxasset( "vfx_sat_zm_firefly_mq_tme_moving_trail_blue" );
    nengine_store_set( "blackwater_lake", "pap_blue_loaded", isdefined( level.bwl_pap_blue_fx ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_blue_status", "waiting_for_power" );
    // 0.2.85: back to the earlier yellow mix.
    nengine_store_set( "blackwater_lake", "pap_scale_test", "original_unscaled_mix" );
    nengine_store_set( "blackwater_lake", "pap_sign_loaded", 0 );
    nengine_store_set( "blackwater_lake", "pap_sign_count", 0 );
    nengine_store_set( "blackwater_lake", "pap_sign_status", "small_light_test_removed" );
    nengine_store_set( "blackwater_lake", "pap_blue_side_status", "waiting_for_power" );
    // 0.2.92: one centre yellow pair again; lights rebuilt after noclip or teleport.
    nengine_store_set( "blackwater_lake", "pap_yellow_dim_method", "single_centre_pair" );
    nengine_store_set( "blackwater_lake", "pap_yellow_offset_requested", 0 );
    nengine_store_set( "blackwater_lake", "pap_light_rebuilds", 0 );
    // 0.2.97: the native lakefront spawn points are moved to the chosen spawn spot.
    nengine_store_set( "blackwater_lake", "spawn_spot", "native_points_moved" );
    nengine_store_set( "blackwater_lake", "boundary_return", 0 );
    nengine_store_set( "blackwater_lake", "spawn_calls", 0 );
    bwl_record( "registered" );
    // 0.2.127: restore the deliberately saved Rampage placement.
    bwl_rampage_load();
    // 0.2.128: observe the native Rampage enable dvar before map startup.
    nengine_store_set( "blackwater_lake", "rampage_diag_enable_at_register", getdvarint( @"hash_54d97c81fc15dc50", -1 ) );
    bwl_rampage_hold();
    bwl_define_arena();
    // 0.2.126: allow the native lake-cabin TEDD task location.
    bwl_tedd_register();
    level callback::add( #"player_spawned", &bwl_spawned );
    // 0.2.115: recognize the native Mayhem PaP return at this deck machine.
    level.bwl_pap_return_count = 0;
    nengine_store_set( "blackwater_lake", "pap_return_status", "registering" );
    nengine_store_set( "blackwater_lake", "pap_return_count", 0 );
    level callback::add( #"item_spawn_begin", &bwl_pap_return_begin );
    level thread bwl_prepare_markers();
}

// Diagnostic only (0.2.19, revised 0.2.20), on Nuked. The same late-attach check that failed
// on Firefly in 0.2.18, run where Nuked's own PaP is lit. If T10 attaches
// here, the method works and Firefly's failure is specific to that map. SAT is
// spawned alongside as a baseline. Results go to mantis_probe.json, so the
// Blackwater runtime file is left alone.
autoexec bwl_mantis_probe_register()
{
    if ( getdvar( "mapname" ) != "zm_sat_mantis" && getdvar( "ui_mapname" ) != "zm_sat_mantis" )
        return;
    nengine_store_set( "blackwater_lake", "mantis_probe_version", "0.2.133" );
    nengine_store_set( "blackwater_lake", "mantis_probe", "registered" );
    nengine_store_save( "blackwater_lake", "mantis_probe" );
    level callback::add( #"player_spawned", &bwl_mantis_probe_spawned );
}

function bwl_mantis_probe_spawned()
{
    if ( isdefined( level.bwl_mantis_probe_started ) )
        return;
    level.bwl_mantis_probe_started = 1;
    level thread bwl_mantis_probe( self.origin );
}

function bwl_mantis_probe( origin )
{
    level endon( #"game_ended" );
    wait 5;
    bwl_step_check( "mantis", "mantis_probe" );
    bwl_field_check( "mantisf", "mantis_probe" );
    nengine_store_set( "blackwater_lake", "mantis_probe", "spawning" );
    nengine_store_set( "blackwater_lake", "mantis_origin_defined", isdefined( origin ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "mantis_t10_seconds", -1 );
    nengine_store_set( "blackwater_lake", "mantis_sat_seconds", -1 );
    nengine_store_set( "blackwater_lake", "mantis_native_count", 0 );
    nengine_store_set( "blackwater_lake", "mantis_native_machine", 0 );
    nengine_store_set( "blackwater_lake", "mantis_native_t10", -1 );
    nengine_store_set( "blackwater_lake", "mantis_native_seconds", -1 );
    nengine_store_set( "blackwater_lake", "mantis_native_idle", -1 );
    nengine_store_set( "blackwater_lake", "mantis_native_sat", -1 );
    nengine_store_set( "blackwater_lake", "mantis_native_list_seconds", -1 );
    nengine_store_set( "blackwater_lake", "mantis_native_watch", "watching" );
    nengine_store_save( "blackwater_lake", "mantis_probe" );
    // 0.2.19 spawned nothing below the first player spawn; 0.2.20 uses a fixed
    // point 300 units under Nuked's own PaP struct (mapents 2016).
    spot = spawnstruct();
    spot.origin = ( 53696.1, -33060.3, -431.418 );
    spot.angles = ( 0, 0, 0 );
    nengine_store_set( "blackwater_lake", "mantis_gametype", getdvar( "g_gametype" ) );
    nengine_store_set( "blackwater_lake", "mantis_ui_gametype", getdvar( "ui_gametype" ) );
    level thread bwl_mantis_native_watch();
    t10 = namespace_2bf8af33322ac10f::function_66b9b0c7a4a77d6b( spot, "t10_zm_pap_fxanim", 1, 1 );
    sat = namespace_2bf8af33322ac10f::function_66b9b0c7a4a77d6b( spot, "sat_zm_pap_clean_fxanim", 1, 1 );
    nengine_store_set( "blackwater_lake", "mantis_t10_spawned", isdefined( t10 ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "mantis_sat_spawned", isdefined( sat ) ? 1 : 0 );
    // 0.2.19 and 0.2.20 got nothing back from the helper on Nuked. Try the
    // built-ins it wraps, so the log shows which step fails.
    nengine_store_set( "blackwater_lake", "mantis_direct_t10", -1 );
    nengine_store_set( "blackwater_lake", "mantis_direct_sat", -1 );
    if ( !isdefined( t10 ) )
    {
        t10 = spawn( "script_model", spot.origin );
        nengine_store_set( "blackwater_lake", "mantis_direct_t10", isdefined( t10 ) ? 1 : 0 );
        if ( isdefined( t10 ) )
        {
            t10.angles = spot.angles;
            t10 setmodel( "t10_zm_pap_fxanim" );
        }
    }
    if ( !isdefined( sat ) )
    {
        sat = spawn( "script_model", spot.origin );
        nengine_store_set( "blackwater_lake", "mantis_direct_sat", isdefined( sat ) ? 1 : 0 );
        if ( isdefined( sat ) )
        {
            sat.angles = spot.angles;
            sat setmodel( "sat_zm_pap_clean_fxanim" );
        }
    }
    nengine_store_set( "blackwater_lake", "mantis_probe", "polling" );
    nengine_store_save( "blackwater_lake", "mantis_probe" );
    t10_at = -1;
    sat_at = -1;
    start = gettime();
    while ( gettime() - start < 120000 && ( t10_at < 0 || sat_at < 0 ) )
    {
        if ( t10_at < 0 && isdefined( t10 ) && t10 namespace_60b3bdcc70f79fc6::function_de1f80d93273abf5() )
            t10_at = ( gettime() - start ) / 1000;
        if ( sat_at < 0 && isdefined( sat ) && sat namespace_60b3bdcc70f79fc6::function_de1f80d93273abf5() )
            sat_at = ( gettime() - start ) / 1000;
        wait 0.5;
    }
    nengine_store_set( "blackwater_lake", "mantis_t10_seconds", t10_at );
    nengine_store_set( "blackwater_lake", "mantis_sat_seconds", sat_at );
    if ( t10_at >= 0 )
    {
        idle_set = t10 namespace_60b3bdcc70f79fc6::function_7c10ea82c1e305b8( "base", "idle" );
        nengine_store_set( "blackwater_lake", "mantis_t10_idle_set", idle_set ? 1 : 0 );
    }
    nengine_store_set( "blackwater_lake", "mantis_probe", "done" );
    nengine_store_save( "blackwater_lake", "mantis_probe" );
    if ( isdefined( t10 ) )
        t10 delete();
    if ( isdefined( sat ) )
        sat delete();
    nengine_store_set( "blackwater_lake", "mantis_probe_removed", 1 );
    nengine_store_save( "blackwater_lake", "mantis_probe" );
}

function bwl_mantis_native_watch()
{
    level endon( #"game_ended" );
    // Nuked's own machine, read-only, from the native PaP list (the list the
    // Blackwater deck marker joins). Nuked's PaP struct carries power_on, so
    // it may only appear after power; watch for 20 minutes, not 2.
    start = gettime();
    seen_list = 0;
    while ( gettime() - start < 1200000 )
    {
        if ( isdefined( level.var_db52bcfd04d45a7a ) )
        {
            if ( !seen_list )
            {
                seen_list = 1;
                nengine_store_set( "blackwater_lake", "mantis_native_list_seconds", ( gettime() - start ) / 1000 );
            }
            nengine_store_set( "blackwater_lake", "mantis_native_count", level.var_db52bcfd04d45a7a.size );
            for ( i = 0; i < level.var_db52bcfd04d45a7a.size; i++ )
            {
                native = level.var_db52bcfd04d45a7a[ i ].var_370acb837a3a86c3;
                if ( !isdefined( native ) )
                    continue;
                nengine_store_set( "blackwater_lake", "mantis_native_machine", 1 );
                nengine_store_set( "blackwater_lake", "mantis_native_t10", native.model == "t10_zm_pap_fxanim" ? 1 : 0 );
                nengine_store_set( "blackwater_lake", "mantis_native_sat", native.model == "sat_zm_pap_clean_fxanim" ? 1 : 0 );
                if ( native namespace_60b3bdcc70f79fc6::function_de1f80d93273abf5() )
                {
                    nengine_store_set( "blackwater_lake", "mantis_native_seconds", ( gettime() - start ) / 1000 );
                    nengine_store_set( "blackwater_lake", "mantis_native_idle",
                        native namespace_60b3bdcc70f79fc6::function_9f2c41c1dcc8c94( "base", "idle" ) ? 1 : 0 );
                    nengine_store_set( "blackwater_lake", "mantis_native_watch", "found_scriptable" );
                    nengine_store_save( "blackwater_lake", "mantis_probe" );
                    return;
                }
            }
        }
        nengine_store_save( "blackwater_lake", "mantis_probe" );
        wait 5;
    }
    nengine_store_set( "blackwater_lake", "mantis_native_watch", "timeout_20min" );
    nengine_store_save( "blackwater_lake", "mantis_probe" );
}

function bwl_step_check( prefix, file )
{
    // Diagnostic only (0.2.23). In 0.2.22 gettime() and a bare spawn returned
    // nothing in our threads on both maps, while the deck PaP's native helper
    // call worked. Sample them immediately, after one frame and after a
    // one-second wait, to find when they stop working.
    bwl_step_sample( prefix + "_now", file );
    waitframe();
    bwl_step_sample( prefix + "_frame", file );
    wait 1;
    bwl_step_sample( prefix + "_wait", file );
    nengine_store_set( "blackwater_lake", prefix + "_step_check", "done" );
    nengine_store_save( "blackwater_lake", file );
}

function bwl_step_sample( key, file )
{
    // -1 means the value was undefined. The helper spawns a tag_origin far
    // below the map and deletes it at once.
    t = gettime();
    nengine_store_set( "blackwater_lake", key + "_time", isdefined( t ) ? t : -1 );
    ent = spawn( "script_origin", ( 0, 0, -10000 ) );
    nengine_store_set( "blackwater_lake", key + "_spawn", isdefined( ent ) ? 1 : 0 );
    if ( isdefined( ent ) )
        ent delete();
    spot = spawnstruct();
    nengine_store_set( "blackwater_lake", key + "_struct", isdefined( spot ) ? 1 : 0 );
    helper = -1;
    if ( isdefined( spot ) )
    {
        spot.origin = ( 0, 0, -10000 );
        spot.angles = ( 0, 0, 0 );
        model = namespace_2bf8af33322ac10f::function_66b9b0c7a4a77d6b( spot, "tag_origin", 1, 1 );
        helper = isdefined( model ) ? 1 : 0;
        if ( isdefined( model ) )
            model delete();
    }
    nengine_store_set( "blackwater_lake", key + "_helper", helper );
    nengine_store_set( "blackwater_lake", key + "_own_field", isdefined( level.bwl_services_started ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", key + "_pap_list", isdefined( level.var_db52bcfd04d45a7a ) ? level.var_db52bcfd04d45a7a.size : -1 );
    nengine_store_save( "blackwater_lake", file );
}

function bwl_field_check( prefix, file )
{
    // Diagnostic only (0.2.24). In 0.2.23 only values kept in local variables
    // came back undefined, even a constant. This repeats bwl_step_check with
    // every value kept in a level field instead.
    bwl_field_sample( prefix + "_now", file );
    waitframe();
    bwl_field_sample( prefix + "_frame", file );
    wait 1;
    bwl_field_sample( prefix + "_wait", file );
    nengine_store_set( "blackwater_lake", prefix + "_field_check", "done" );
    nengine_store_save( "blackwater_lake", file );
}

function bwl_field_sample( key, file )
{
    // No local variables. -1 means the value was undefined.
    level.bwl_probe_const = -1;
    nengine_store_set( "blackwater_lake", key + "_const", isdefined( level.bwl_probe_const ) ? level.bwl_probe_const : 0 );
    level.bwl_probe_time = gettime();
    nengine_store_set( "blackwater_lake", key + "_time", isdefined( level.bwl_probe_time ) ? level.bwl_probe_time : -1 );
    level.bwl_probe_ent = spawn( "script_origin", ( 0, 0, -10000 ) );
    nengine_store_set( "blackwater_lake", key + "_spawn", isdefined( level.bwl_probe_ent ) ? 1 : 0 );
    if ( isdefined( level.bwl_probe_ent ) )
        level.bwl_probe_ent delete();
    level.bwl_probe_spot = spawnstruct();
    nengine_store_set( "blackwater_lake", key + "_struct", isdefined( level.bwl_probe_spot ) ? 1 : 0 );
    level.bwl_probe_helper = -1;
    if ( isdefined( level.bwl_probe_spot ) )
    {
        level.bwl_probe_spot.origin = ( 0, 0, -10000 );
        level.bwl_probe_spot.angles = ( 0, 0, 0 );
        level.bwl_probe_model = namespace_2bf8af33322ac10f::function_66b9b0c7a4a77d6b( level.bwl_probe_spot, "tag_origin", 1, 1 );
        level.bwl_probe_helper = isdefined( level.bwl_probe_model ) ? 1 : 0;
        if ( isdefined( level.bwl_probe_model ) )
            level.bwl_probe_model delete();
    }
    nengine_store_set( "blackwater_lake", key + "_helper", isdefined( level.bwl_probe_helper ) ? level.bwl_probe_helper : -2 );
    nengine_store_save( "blackwater_lake", file );
}

function bwl_selected()
{
    return getdvar( @"hash_dddf7dca1a52e591", "null" ) == "zone_lakefront" &&
        ( getdvar( "mapname" ) == "zm_sat_firefly" ||
          getdvar( "ui_mapname" ) == "zm_sat_firefly" );
}

// The native function_6c941889993a9c8 adds its four shipped POIs to this
// dictionary without clearing it. Add our fifth POI before Survival main.
function bwl_define_arena()
{
    if ( !isdefined( level.var_3df01ce9403c6868 ) )
        level.var_3df01ce9403c6868 = spawnstruct();

    info = spawnstruct();
    info.poiname = "zone_lakefront";
    info.var_dd74fdd3de3644d3 = "bwl_spawn_set";
    info.var_2de8c99103d83ad0 = "bwl_spawn_set";
    info.var_326c1d770b75aa66 = "survival_magicbox_zone_lakefront";
    info.var_8eea21bd6e32ebf9 = "bwl_round_accelerant";
    info.var_33e5d1229cccfc7d = "zone_lakefront";
    info.var_ddac443620d59614 = [];
    names = bwl_zones();
    for ( i = 0; i < names.size; i++ )
    {
        zone = spawnstruct();
        zone.var_a7f03c100acaf3ac = names[ i ];
        info.var_ddac443620d59614[ info.var_ddac443620d59614.size ] = zone;
    }
    info.var_54f08a00e162bbf8 = [];
    info.var_756e8dcc2cfa67b4 = [];
    names = [ "power_on", "power_on2" ];
    for ( i = 0; i < names.size; i++ )
    {
        flag = spawnstruct();
        flag.var_1395ff2ff4783844 = names[ i ];
        info.var_756e8dcc2cfa67b4[ info.var_756e8dcc2cfa67b4.size ] = flag;
    }
    level.var_3df01ce9403c6868.var_8017a55ec0f64d22[ "zone_lakefront" ] = info;
}

function bwl_zones()
{
    return [ "zone_lakefront", "zone_lakefront_cabin",
        "zone_lakefront_cabin_floor2", "zone_lakefront_toolshed",
        "zone_lakefront_cliffs_north", "zone_lakefront_cliffs_south",
        "zone_lakefront_path_north", "zone_lakefront_path_south" ];
}

function bwl_is_zone( name )
{
    names = bwl_zones();
    for ( i = 0; i < names.size; i++ )
        if ( name == names[ i ] )
            return true;
    return false;
}

function bwl_record( stage )
{
    nengine_store_set( "blackwater_lake", "stage", stage );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// utility::getstruct/getstructarray read this exact native index. Synthetic
// roots point to the map's existing four-player respawn group, not guessed XYZs.
function bwl_index( name, value )
{
    level.var_7619345e0810ba9b[ "targetname" ][ name ] = [ value ];
}

function bwl_struct( name )
{
    return namespace_60b3bdcc70f79fc6::function_6141deaf935abd8f( name, "targetname" );
}

function bwl_structs( name, key )
{
    return namespace_60b3bdcc70f79fc6::function_4129ebc30c6186ec( name, key );
}

function bwl_copy( original )
{
    return structcopy( original );
}

// 0.2.124: route the native Cursed Mr. Peeks egg event to the lake.
// Positions and facing come from the retail Firefly map's Peeks spawn and
// its linked egg landing marker, not from a guessed placement.
function bwl_peeks_prepare()
{
    if ( getdvar( @"hash_da1eb79d992f0e28", "null" ) != "zm_rb_r_mod_survival" &&
         getdvar( "g_gametype" ) != "zm_rb_r_mod_survival" )
        return;
    if ( isdefined( level.bwl_peeks_marker ) )
        return;

    level.bwl_peeks_marker = spawnstruct();
    level.bwl_peeks_marker.origin = ( 13220.4, 1613, 1174.74 );
    level.bwl_peeks_marker.angles = ( 6.21, 257.96, 1.48 );
    level.bwl_peeks_marker.target = "bwl_peeks_lake_drop";
    level.bwl_peeks_drop = spawnstruct();
    level.bwl_peeks_drop.origin = ( 13201.4, 1524, 1037.74 );
    level.bwl_peeks_drop.angles = ( 0, 0, 0 );
    bwl_index( "bwl_peeks_lake_drop", level.bwl_peeks_drop );
    // The retail Survival initializer looks up POI + this native suffix in
    // the script_noteworthy index. The generic event uses the targetname key.
    level.var_7619345e0810ba9b[ "script_noteworthy" ][ "zone_lakefront" + "\x8f\xbf\v/\xd9#\xab\xb1\xab\xe8\x02\xaa\xe0" ] = [ level.bwl_peeks_marker ];
    level.var_7619345e0810ba9b[ "targetname" ][ "\x8ey\nk{\xb3\x18\x90\xb6\x9f\xcd[" ] = [ level.bwl_peeks_marker ];
    nengine_store_set( "blackwater_lake", "peeks_marker_status", "lake_marker_indexed" );
    nengine_store_set( "blackwater_lake", "peeks_marker_origin", level.bwl_peeks_marker.origin );
    nengine_store_set( "blackwater_lake", "peeks_drop_origin", level.bwl_peeks_drop.origin );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// Once the retail event is initialized, keep its selection on this one marker.
// If the native initializer returned before a marker was available, retry it
// once after its original five-second wait and 120-second flag timeout elapsed.
// The retry uses the native event, including its own round chance and rewards.
function bwl_peeks_watch()
{
    level endon( #"game_ended" );
    if ( getdvar( @"hash_da1eb79d992f0e28", "null" ) != "zm_rb_r_mod_survival" &&
         getdvar( "g_gametype" ) != "zm_rb_r_mod_survival" )
        return;
    level.bwl_peeks_watch_ticks = 0;
    wait 5;
    while ( true )
    {
        level.bwl_peeks_watch_ticks++;
        nengine_store_set( "blackwater_lake", "peeks_native_relic_tier", -1 );
        if ( isdefined( level.var_7b4a8d359bf67f40 ) )
            nengine_store_set( "blackwater_lake", "peeks_native_relic_tier", level.var_7b4a8d359bf67f40 );
        nengine_store_set( "blackwater_lake", "peeks_native_chance_percent", -1 );
        nengine_store_set( "blackwater_lake", "peeks_native_bunny_active", 0 );
        if ( isdefined( level.var_91763476a6e378fe ) && isdefined( level.var_91763476a6e378fe.entity ) )
            nengine_store_set( "blackwater_lake", "peeks_native_bunny_active", 1 );
        if ( isdefined( level.bwl_peeks_marker ) && isdefined( level.var_966e7e1f42f9a195 ) &&
             isdefined( level.var_103d11662a9d894b ) )
        {
            if ( !isdefined( level.bwl_peeks_routed ) )
            {
                level.var_103d11662a9d894b = [ level.bwl_peeks_marker ];
                level.bwl_peeks_routed = 1;
            }
            if ( isdefined( level.var_966e7e1f42f9a195.var_859c5b17acbbb729 ) )
                nengine_store_set( "blackwater_lake", "peeks_native_chance_percent", level.var_966e7e1f42f9a195.var_859c5b17acbbb729 * 100 );
            nengine_store_set( "blackwater_lake", "peeks_event_status", "native_initialized_lake_routed" );
        }
        else
        {
            nengine_store_set( "blackwater_lake", "peeks_event_status", "waiting_for_native_initializer" );
            if ( level.bwl_peeks_watch_ticks >= 26 && isdefined( level.bwl_peeks_marker ) &&
                 isdefined( level.var_7b4a8d359bf67f40 ) && !isdefined( level.bwl_peeks_retried ) )
            {
                level.bwl_peeks_retried = 1;
                nengine_store_set( "blackwater_lake", "peeks_event_status", "retrying_native_initializer" );
                level thread namespace_332bce966c069a17::function_c185f1873d783577();
            }
        }
        nengine_store_save( "blackwater_lake", "runtime" );
        wait 5;
    }
}

// 0.2.126: let the native Survival TEDD task selector use Firefly's own
// lake-cabin task marker and matching task chest. Native cadence, trials,
// interact logic, scoring and rewards are unchanged.
function bwl_tedd_register()
{
    nengine_store_set( "blackwater_lake", "tedd_filter_status", "waiting_for_native_filter" );
    nengine_store_set( "blackwater_lake", "tedd_native_pool_before", -1 );
    nengine_store_set( "blackwater_lake", "tedd_native_pool_after", -1 );
    nengine_store_set( "blackwater_lake", "tedd_hook_status", "registering" );
    if ( namespace_60b3bdcc70f79fc6::function_6af4632c5734e07e( #"hash_c322c0fabceb2f63", #"hash_f09f680a0b4acd00" ) )
    {
        nengine_store_set( "blackwater_lake", "tedd_hook_status", "existing_override_preserved" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level namespace_60b3bdcc70f79fc6::function_de57f49b8df192cc(
        #"hash_c322c0fabceb2f63", #"hash_f09f680a0b4acd00", &bwl_tedd_lake_filter, 1 );
    nengine_store_set( "blackwater_lake", "tedd_hook_status", "registered" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// The native Survival filter invokes this shared-function slot
// instead of filtering by the mismatched zone_lakefront string. Preserve only
// the retail lake-cabin entry, and use the same start-enabled flag as native
// Survival task markers. Never create a second console or move a map marker.
function bwl_tedd_lake_filter()
{
    if ( !bwl_selected() )
        return;
    if ( !isdefined( level.var_31998b7ccf36d152 ) )
    {
        nengine_store_set( "blackwater_lake", "tedd_filter_status", "native_pool_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    nengine_store_set( "blackwater_lake", "tedd_native_pool_before", level.var_31998b7ccf36d152.size );
    level.bwl_tedd_marker = level.var_31998b7ccf36d152[ "teddtask_lakecabin_house" ];
    level.var_31998b7ccf36d152 = [];
    nengine_store_set( "blackwater_lake", "tedd_native_pool_after", 0 );
    if ( !isdefined( level.bwl_tedd_marker ) )
    {
        nengine_store_set( "blackwater_lake", "tedd_filter_status", "lake_marker_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    if ( !isdefined( level.bwl_tedd_marker.var_7048dfcc1763176d ) ||
         level.bwl_tedd_marker.var_7048dfcc1763176d != "zone_lakecabin_house" ||
         !isdefined( level.bwl_tedd_marker.origin ) ||
         distancesquared( level.bwl_tedd_marker.origin, ( 13159.2, 1810.05, 1056 ) ) > 4096 )
    {
        nengine_store_set( "blackwater_lake", "tedd_filter_status", "lake_marker_mismatch" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_tedd_marker.var_e502d431f3ba8706 = 1;
    level.var_31998b7ccf36d152[ "teddtask_lakecabin_house" ] = level.bwl_tedd_marker;
    nengine_store_set( "blackwater_lake", "tedd_native_pool_after", level.var_31998b7ccf36d152.size );
    nengine_store_set( "blackwater_lake", "tedd_marker_origin", level.bwl_tedd_marker.origin );
    nengine_store_set( "blackwater_lake", "tedd_filter_status", "native_lake_marker_selected" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// Read-only progress: these fields describe engine state, not visible UI.
function bwl_tedd_watch()
{
    level endon( #"game_ended" );
    level.bwl_tedd_samples = 0;
    wait 5;
    while ( true )
    {
        level.bwl_tedd_samples++;
        nengine_store_set( "blackwater_lake", "tedd_watch_samples", level.bwl_tedd_samples );
        nengine_store_set( "blackwater_lake", "tedd_marker_start_enabled", -1 );
        if ( isdefined( level.bwl_tedd_marker ) && isdefined( level.bwl_tedd_marker.var_e502d431f3ba8706 ) )
            nengine_store_set( "blackwater_lake", "tedd_marker_start_enabled", level.bwl_tedd_marker.var_e502d431f3ba8706 );
        nengine_store_set( "blackwater_lake", "tedd_selected_marker", "none" );
        nengine_store_set( "blackwater_lake", "tedd_console_entity_defined", 0 );
        if ( isdefined( level.var_a3eb428773fa9129 ) )
        {
            if ( isdefined( level.var_a3eb428773fa9129.var_b5608a3a940478dc ) )
                nengine_store_set( "blackwater_lake", "tedd_selected_marker", level.var_a3eb428773fa9129.var_b5608a3a940478dc );
            if ( isdefined( level.var_a3eb428773fa9129.var_8fe329a6d815cd29 ) )
                nengine_store_set( "blackwater_lake", "tedd_console_entity_defined", 1 );
        }
        nengine_store_set( "blackwater_lake", "tedd_native_task_state_defined", isdefined( level.var_fd94a3cfab1edb0 ) ? 1 : 0 );
        nengine_store_save( "blackwater_lake", "runtime" );
        wait 5;
    }
}

// 0.2.127: read one deliberate mod-menu position from a fresh Blackwater
// match, persist it, and use it as the native Rampage marker on later matches.
// The menu's saved point is match-local; a restart is needed after recording.
function bwl_rampage_load()
{
    level.bwl_rampage_saved = 0;
    nengine_store_set( "blackwater_lake", "rampage_placement", "waiting_for_menu_save" );
    if ( !nengine_store_load( "blackwater_rampage", "placement" ) )
        return;
    if ( !isdefined( nengine_store_get( "blackwater_rampage", "schema" ) ) ||
         nengine_store_get( "blackwater_rampage", "schema" ) != 1 ||
         !isdefined( nengine_store_get( "blackwater_rampage", "x" ) ) ||
         !isdefined( nengine_store_get( "blackwater_rampage", "y" ) ) ||
         !isdefined( nengine_store_get( "blackwater_rampage", "z" ) ) ||
         !isdefined( nengine_store_get( "blackwater_rampage", "yaw" ) ) )
        return;
    level.bwl_rampage_x = nengine_store_get( "blackwater_rampage", "x" );
    level.bwl_rampage_y = nengine_store_get( "blackwater_rampage", "y" );
    level.bwl_rampage_z = nengine_store_get( "blackwater_rampage", "z" );
    level.bwl_rampage_yaw = nengine_store_get( "blackwater_rampage", "yaw" );
    if ( !bwl_rampage_valid() )
        return;
    level.bwl_rampage_saved = 1;
    nengine_store_set( "blackwater_lake", "rampage_placement", "saved_marker_loaded" );
}

function bwl_rampage_valid()
{
    return level.bwl_rampage_x >= 12000 && level.bwl_rampage_x <= 14500 &&
        level.bwl_rampage_y >= 1000 && level.bwl_rampage_y <= 3800 &&
        level.bwl_rampage_z >= 800 && level.bwl_rampage_z <= 1500 &&
        level.bwl_rampage_yaw >= -360 && level.bwl_rampage_yaw <= 360;
}

function bwl_rampage_capture()
{
    self endon( #"disconnect" );
    self endon( #"death" );
    while ( isdefined( self ) && !level.bwl_rampage_saved )
    {
        // The currently installed core mod menu stores its point in this
        // player struct; it does not save that point to disk itself.
        if ( isdefined( self.var_91495bd4b11aff5e ) &&
             isdefined( self.var_91495bd4b11aff5e.var_23f99b9eba104d4e ) &&
             self.var_91495bd4b11aff5e.var_23f99b9eba104d4e &&
             isdefined( self.var_91495bd4b11aff5e.var_c2f4dc5eebc704e6 ) &&
             isdefined( self.var_91495bd4b11aff5e.var_aed6e33d70eee99c ) )
        {
            level.bwl_rampage_x = self.var_91495bd4b11aff5e.var_c2f4dc5eebc704e6[ 0 ];
            level.bwl_rampage_y = self.var_91495bd4b11aff5e.var_c2f4dc5eebc704e6[ 1 ];
            level.bwl_rampage_z = self.var_91495bd4b11aff5e.var_c2f4dc5eebc704e6[ 2 ];
            level.bwl_rampage_yaw = self.var_91495bd4b11aff5e.var_aed6e33d70eee99c[ 1 ];
            if ( bwl_rampage_valid() )
            {
                nengine_store_set( "blackwater_rampage", "schema", 1 );
                nengine_store_set( "blackwater_rampage", "x", level.bwl_rampage_x );
                nengine_store_set( "blackwater_rampage", "y", level.bwl_rampage_y );
                nengine_store_set( "blackwater_rampage", "z", level.bwl_rampage_z );
                nengine_store_set( "blackwater_rampage", "yaw", level.bwl_rampage_yaw );
                nengine_store_save( "blackwater_rampage", "placement" );
                if ( nengine_store_load( "blackwater_rampage", "placement" ) &&
                     isdefined( nengine_store_get( "blackwater_rampage", "schema" ) ) &&
                     nengine_store_get( "blackwater_rampage", "schema" ) == 1 &&
                     nengine_store_get( "blackwater_rampage", "x" ) == level.bwl_rampage_x &&
                     nengine_store_get( "blackwater_rampage", "y" ) == level.bwl_rampage_y &&
                     nengine_store_get( "blackwater_rampage", "z" ) == level.bwl_rampage_z &&
                     nengine_store_get( "blackwater_rampage", "yaw" ) == level.bwl_rampage_yaw )
                {
                    level.bwl_rampage_saved = 1;
                    nengine_store_set( "blackwater_lake", "rampage_placement", "saved_restart_match" );
                    nengine_store_set( "blackwater_lake", "rampage_saved_origin", ( level.bwl_rampage_x, level.bwl_rampage_y, level.bwl_rampage_z ) );
                    nengine_store_set( "blackwater_lake", "rampage_saved_yaw", level.bwl_rampage_yaw );
                    nengine_store_save( "blackwater_lake", "runtime" );
                    self iprintlnbold( "Rampage spot saved. Start a new match." );
                    return;
                }
                nengine_store_set( "blackwater_lake", "rampage_placement", "save_readback_failed" );
                nengine_store_save( "blackwater_lake", "runtime" );
                return;
            }
        }
        wait 0.5;
    }
}

// 0.2.128: read-only inspection of native Rampage startup after the saved
// marker reached its intended coordinates but no model or prompt was seen.
function bwl_rampage_diag()
{
    level endon( #"game_ended" );
    level.bwl_rampage_diag_samples = 0;
    wait 5;
    while ( level.bwl_rampage_diag_samples < 6 )
    {
        level.bwl_rampage_diag_samples++;
        bwl_rampage_trace( "sample" );
        nengine_store_set( "blackwater_lake", "rampage_diag_samples", level.bwl_rampage_diag_samples );
        nengine_store_set( "blackwater_lake", "rampage_diag_enable", getdvarint( @"hash_54d97c81fc15dc50", -1 ) );
        nengine_store_set( "blackwater_lake", "rampage_diag_getter_registered",
            namespace_60b3bdcc70f79fc6::function_6af4632c5734e07e( #"hash_9b98b3956f94b731", #"hash_491936336da9a017" ) ? 1 : 0 );
        level.bwl_rampage_diag_marker = bwl_struct( "bwl_round_accelerant" );
        nengine_store_set( "blackwater_lake", "rampage_diag_indexed_marker", isdefined( level.bwl_rampage_diag_marker ) ? 1 : 0 );
        if ( isdefined( level.bwl_rampage_diag_marker ) && isdefined( level.bwl_rampage_diag_marker.origin ) )
            nengine_store_set( "blackwater_lake", "rampage_diag_indexed_origin", level.bwl_rampage_diag_marker.origin );
        nengine_store_set( "blackwater_lake", "rampage_diag_native_struct", isdefined( level.var_f7b4ed545fb97f9b ) ? 1 : 0 );
        nengine_store_set( "blackwater_lake", "rampage_diag_native_model", 0 );
        nengine_store_set( "blackwater_lake", "rampage_diag_native_interact", 0 );
        if ( isdefined( level.var_f7b4ed545fb97f9b ) )
        {
            if ( isdefined( level.var_f7b4ed545fb97f9b.origin ) )
                nengine_store_set( "blackwater_lake", "rampage_diag_native_origin", level.var_f7b4ed545fb97f9b.origin );
            if ( isdefined( level.var_f7b4ed545fb97f9b.angles ) )
                nengine_store_set( "blackwater_lake", "rampage_diag_native_angles", level.var_f7b4ed545fb97f9b.angles );
            if ( isdefined( level.var_f7b4ed545fb97f9b.var_9dc14f3b2f869aa5 ) )
            {
                nengine_store_set( "blackwater_lake", "rampage_diag_native_model", 1 );
                if ( isdefined( level.var_f7b4ed545fb97f9b.var_9dc14f3b2f869aa5.origin ) )
                    nengine_store_set( "blackwater_lake", "rampage_diag_model_origin", level.var_f7b4ed545fb97f9b.var_9dc14f3b2f869aa5.origin );
            }
            if ( isdefined( level.var_f7b4ed545fb97f9b.var_4cf63ec91b753a3c ) )
            {
                nengine_store_set( "blackwater_lake", "rampage_diag_native_interact", 1 );
                if ( isdefined( level.var_f7b4ed545fb97f9b.var_4cf63ec91b753a3c.origin ) )
                    nengine_store_set( "blackwater_lake", "rampage_diag_interact_origin", level.var_f7b4ed545fb97f9b.var_4cf63ec91b753a3c.origin );
            }
        }
        nengine_store_save( "blackwater_lake", "runtime" );
        wait 5;
    }
}

// 0.2.129: observe startup at the marker boundary and sample the original
// Survival getter. The native flag, FX, entities and callbacks are not changed.
function bwl_rampage_trace( phase )
{
    nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_enable", getdvarint( @"hash_54d97c81fc15dc50", -1 ) );
    nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_firefly_main", isdefined( level.var_b9b5070bae70d850 ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_flag", -1 );
    if ( isdefined( level.var_f0bb112fe637e41c ) )
        nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_flag", namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa9\xec\x12\x9b\xd8NK\xc1\xd1\x85&\x8d\xca\xb9\xfa'+,\x8c\xe5" ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_fx", 0 );
    if ( isdefined( level.var_d1e5f36ab9f106 ) )
        nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_fx", isdefined( level.var_d1e5f36ab9f106[ "\x9f\x10\x18:\xd8\xdf\x80\x98\x17\xcf\xdf\x1a5\xd4[>H\xe2N\x1d\xf5H\xa8\xc2\xdf\x15" ] ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_native_struct", isdefined( level.var_f7b4ed545fb97f9b ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_getter_registered", namespace_60b3bdcc70f79fc6::function_6af4632c5734e07e( #"hash_9b98b3956f94b731", #"hash_491936336da9a017" ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_getter_result", -1 );
    if ( isdefined( level.poiname ) && level.poiname == "zone_lakefront" &&
         isdefined( level.var_3df01ce9403c6868 ) &&
         isdefined( level.var_3df01ce9403c6868.var_8017a55ec0f64d22[ level.poiname ] ) &&
         isdefined( level.var_3df01ce9403c6868.var_8017a55ec0f64d22[ level.poiname ].var_8eea21bd6e32ebf9 ) &&
         isdefined( bwl_struct( "bwl_round_accelerant" ) ) &&
         namespace_60b3bdcc70f79fc6::function_6af4632c5734e07e( #"hash_9b98b3956f94b731", #"hash_491936336da9a017" ) )
    {
        level.bwl_rampage_trace_result = namespace_60b3bdcc70f79fc6::function_81557bcd4ddf6a05( #"hash_9b98b3956f94b731", #"hash_491936336da9a017" );
        nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_getter_result", isdefined( level.bwl_rampage_trace_result ) ? 1 : 0 );
        if ( isdefined( level.bwl_rampage_trace_result ) && isdefined( level.bwl_rampage_trace_result.origin ) )
            nengine_store_set( "blackwater_lake", "rampage_trace_" + phase + "_getter_origin", level.bwl_rampage_trace_result.origin );
    }
}

// 0.2.130: briefly hold the native Rampage enable dvar during Blackwater
// startup. Resume the game's initializer only after the saved marker exists.
function bwl_rampage_hold()
{
    level.bwl_rampage_holding = 0;
    nengine_store_set( "blackwater_lake", "rampage_start_status", "not_held" );
    if ( !level.bwl_rampage_saved || getdvarint( @"hash_54d97c81fc15dc50", -1 ) != 1 )
        return;

    // Native init loads this FX. Preload it during autoexec, while assets are
    // available, before delaying the rest of native Rampage initialization.
    level.bwl_rampage_preloaded_fx = loadfxasset( "\x82\x11/.\xff\xe3\x19HS\x90\xd7\x82\x13\xf0w\xc9\x0fr\xf83\xee\xb9\x8fsZQ#7`\x8b\x1eY\to\xfc\xa3p\x8bV\x95\xa5_\xcc\xf7gJ\x01sM" );
    if ( !isdefined( level.bwl_rampage_preloaded_fx ) )
    {
        nengine_store_set( "blackwater_lake", "rampage_start_status", "fx_preload_failed" );
        return;
    }
    setdvar( @"hash_54d97c81fc15dc50", 0 );
    if ( getdvarint( @"hash_54d97c81fc15dc50", -1 ) != 0 )
    {
        nengine_store_set( "blackwater_lake", "rampage_start_status", "hold_failed" );
        return;
    }
    level.bwl_rampage_holding = 1;
    nengine_store_set( "blackwater_lake", "rampage_start_status", "holding_for_marker" );
    level thread bwl_rampage_release_on_end();
}

// Release only a hold owned by this map. If restoring the dvar fails, retain
// ownership so the game-ended cleanup can try again.
function bwl_rampage_release( reason )
{
    if ( !isdefined( level.bwl_rampage_holding ) || !level.bwl_rampage_holding )
        return;
    if ( getdvarint( @"hash_54d97c81fc15dc50", -1 ) == 0 )
    {
        setdvar( @"hash_54d97c81fc15dc50", 1 );
        if ( getdvarint( @"hash_54d97c81fc15dc50", -1 ) == 0 )
        {
            nengine_store_set( "blackwater_lake", "rampage_start_status", reason + "_restore_failed" );
            nengine_store_save( "blackwater_lake", "runtime" );
            return;
        }
    }
    level.bwl_rampage_holding = 0;
    nengine_store_set( "blackwater_lake", "rampage_start_status", reason );
    nengine_store_set( "blackwater_lake", "rampage_start_enable_after_release", getdvarint( @"hash_54d97c81fc15dc50", -1 ) );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_rampage_release_on_end()
{
    level waittill( #"game_ended" );
    bwl_rampage_release( "game_ended_before_start" );
}

function bwl_rampage_start_after_marker()
{
    level endon( #"game_ended" );
    if ( !isdefined( level.bwl_rampage_holding ) || !level.bwl_rampage_holding )
        return;
    level.bwl_rampage_start_attempt = 0;
    while ( level.bwl_rampage_start_attempt < 600 )
    {
        if ( isdefined( level.var_b9b5070bae70d850 ) &&
             isdefined( level.poiname ) && level.poiname == "zone_lakefront" &&
             isdefined( bwl_struct( "bwl_round_accelerant" ) ) &&
             namespace_60b3bdcc70f79fc6::function_6af4632c5734e07e( #"hash_9b98b3956f94b731", #"hash_491936336da9a017" ) )
            break;
        level.bwl_rampage_start_attempt++;
        waitframe();
    }
    if ( level.bwl_rampage_start_attempt >= 600 )
    {
        bwl_rampage_release( "startup_timeout" );
        return;
    }
    // If the setting changed or the original native initializer ran anyway,
    // do not register its callbacks a second time.
    if ( getdvarint( @"hash_54d97c81fc15dc50", -1 ) != 0 ||
         isdefined( level.var_f7b4ed545fb97f9b ) ||
         ( isdefined( level.var_d1e5f36ab9f106 ) && isdefined( level.var_d1e5f36ab9f106[ "\x9f\x10\x18:\xd8\xdf\x80\x98\x17\xcf\xdf\x1a5\xd4[>H\xe2N\x1d\xf5H\xa8\xc2\xdf\x15" ] ) ) )
    {
        bwl_rampage_release( "native_already_started_or_dvar_changed" );
        return;
    }
    setdvar( @"hash_54d97c81fc15dc50", 1 );
    if ( getdvarint( @"hash_54d97c81fc15dc50", -1 ) != 1 )
    {
        bwl_rampage_release( "enable_restore_failed" );
        return;
    }
    level.bwl_rampage_holding = 0;
    nengine_store_set( "blackwater_lake", "rampage_start_status", "native_init_requested" );
    nengine_store_save( "blackwater_lake", "runtime" );
    level namespace_9f30f5390242b251::function_84fea488c9cd2064();
}

function bwl_prepare_markers()
{
    bwl_record( "waiting_for_native_structs" );
    // The native index and its respawn roots arrive during map startup.
    // Bound the worker; a missing marker produces a persistent diagnostic.
    for ( attempt = 0; attempt < 1200; attempt++ )
    {
        if ( isdefined( level.var_7619345e0810ba9b ) )
        {
            bwl_peeks_prepare();
            groups = bwl_structs( "player_respawn_point", "targetname" );
            for ( group_index = 0; group_index < groups.size; group_index++ )
            {
                group = groups[ group_index ];
                name = group.var_92781bc7d418ab8a;
                if ( !isdefined( name ) )
                    name = group.script_zone_name;
                // Prefer an outdoor group for the initial spawn.
                if ( name != "zone_lakefront" )
                    continue;
                if ( !isdefined( group.target ) )
                    continue;
                points = bwl_structs( group.target, "targetname" );
                if ( points.size < 4 )
                    continue;
                bwl_create_markers( group, points );
                return;
            }
        }
        waitframe();
    }
    bwl_rampage_release( "spawn_group_missing" );
    bwl_record( "missing_lakefront_four_player_spawn_group" );
}

function bwl_create_markers( group, points )
{
    root = bwl_copy( group );
    root.targetname = "bwl_spawn_set";
    bwl_index( "bwl_spawn_set", root );
    nengine_store_set( "blackwater_lake", "spawn_points", points.size );
    nengine_store_set( "blackwater_lake", "spawn_origin", points[ 0 ].origin );
    nengine_store_set( "blackwater_lake", "spawn_group_zone", "zone_lakefront" );

    level.bwl_front_spawn = bwl_copy( points[ 0 ] );
    // Keep the existing Rampage marker. The standalone PaP is initialized
    // after the first player has spawned.
    bwl_machine_marker( "survival_round_accelerant_zone_farm", "bwl_round_accelerant",
        points[ 0 ], ( 128, 0, 0 ) );
    boxes = bwl_structs( "survival_magicbox_zone_lakefront", "script_noteworthy" );
    nengine_store_set( "blackwater_lake", "native_box_markers", boxes.size );
    bwl_move_spawn_points( points );
    // 0.2.113: the round-based Mayhem rows start at the plaza group instead.
    if ( bwl_round_based_mayhem() )
        bwl_mayhem_start_points();
    bwl_record( "markers_prepared" );
}

function bwl_machine_marker( source, name, anchor, offset )
{
    if ( name == "bwl_round_accelerant" )
        bwl_rampage_trace( "before_marker" );
    original = bwl_struct( source );
    if ( !isdefined( original ) )
    {
        if ( name == "bwl_round_accelerant" )
            bwl_rampage_release( "source_marker_missing" );
        nengine_store_set( "blackwater_lake", name + "_status", "source_marker_missing" );
        return;
    }
    marker = bwl_copy( original );
    marker.targetname = name;
    marker.origin = anchor.origin + offset;
    marker.angles = anchor.angles;
    // The native Rampage system consumes this struct during startup.
    if ( name == "bwl_round_accelerant" && level.bwl_rampage_saved )
    {
        // 0.2.131: center on the nearby wooden barrel and raise the base
        // to the estimated top, keeping the saved point itself unchanged.
        marker.origin = ( level.bwl_rampage_x, level.bwl_rampage_y, level.bwl_rampage_z ) + ( -1.62, -5.71, 3.5 );
        marker.angles = ( 0, level.bwl_rampage_yaw, 0 );
    }
    marker.var_b5608a3a940478dc = name;
    marker.script_zone_name = "zone_lakefront";
    marker.var_92781bc7d418ab8a = "zone_lakefront";
    // Detach the new marker from the source area's prefab ownership chain.
    marker.target = undefined;
    marker.a = undefined;
    marker.var_dc6c7b2795de1a08 = undefined;
    // A copied marker must not carry an initialized PaP instance.
    marker.var_370acb837a3a86c3 = undefined;
    bwl_index( name, marker );
    if ( name == "bwl_round_accelerant" )
    {
        bwl_rampage_trace( "after_marker" );
        level thread bwl_rampage_start_after_marker();
    }
    nengine_store_set( "blackwater_lake", name + "_status", "marker_prepared" );
    nengine_store_set( "blackwater_lake", name + "_origin", marker.origin );
}

function bwl_spawned( params )
{
    if ( !bwl_selected() )
        return;
    // Capture one mod-menu save only when no Rampage position exists yet.
    self thread bwl_rampage_capture();
    self thread bwl_spawn_spot_log();
    nengine_store_set( "blackwater_lake", "spawned", 1 );
    nengine_store_set( "blackwater_lake", "player_origin", self.origin );
    nengine_store_set( "blackwater_lake", "poi", level.var_a76045f3136660f9 );
    bwl_record( "player_spawned" );
    // 0.2.105: the boundary check that warned and teleported players back is removed.
    if ( !isdefined( level.bwl_services_started ) )
    {
        level.bwl_services_started = 1;
        // Guard against a later startup setter, before our service workers.
        nengine_store_set( "blackwater_lake", "lake_power_on1_before_spawn_clear",
            level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" ) ? 1 : 0 );
        level namespace_60b3bdcc70f79fc6::function_bb43e9471feff54e( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" );
        nengine_store_set( "blackwater_lake", "lake_power_on1_after_spawn_clear",
            level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" ) ? 1 : 0 );
        nengine_store_save( "blackwater_lake", "runtime" );
        level thread bwl_lake_power();
        level thread bwl_auto_wunderfizz();
        level thread bwl_deck_pap();
        // 0.2.111 diagnostic: Kronos Cursed Survival Mayhem state.
        level thread bwl_csm_diag();
        // 0.2.124: watch the native Cursed Mr. Peeks egg event.
        level thread bwl_peeks_watch();
        // 0.2.126: read-only native TEDD task diagnostics.
        level thread bwl_tedd_watch();
        // 0.2.128: inspect native Rampage initialization without changing it.
        level thread bwl_rampage_diag();
        // 0.2.120: sample Klaus setup and the native summon station.
        level thread bwl_klaus_diag();
        // 0.2.121: repair the existing lake Klaus station when native setup is ready.
        level thread bwl_klaus_repair();
        // 0.2.122: inspect first-summon Klaus combat without changing it.
        level thread bwl_klaus_combat_diag();
        // Register the native item observer once its registry is ready.
        level thread bwl_pap_return_register();
        // 0.2.113: the round-based Mayhem rows enable the lake zones.
        if ( bwl_round_based_mayhem() )
            self thread bwl_mayhem_zones();
    }
}

// 0.2.122: read-only sampling of Klaus's native combat state.
// Uses retail hashes for can_think, enemy, owner, team and ammunition fields.
function bwl_klaus_combat_diag()
{
    level endon( #"game_ended" );
    level.bwl_klaus_combat_samples = 0;
    level.bwl_klaus_combat_active_samples = 0;
    level.bwl_klaus_combat_enemy_samples = 0;
    level.bwl_klaus_combat_near_peak = 0;
    wait 5;
    while ( true )
    {
        bwl_klaus_combat_sample();
        wait 2;
    }
}

function bwl_klaus_combat_sample()
{
    level.bwl_klaus_combat_samples++;
    nengine_store_set( "blackwater_lake", "klaus_combat_samples", level.bwl_klaus_combat_samples );
    nengine_store_set( "blackwater_lake", "klaus_combat_status", "waiting_for_active_actor" );
    nengine_store_set( "blackwater_lake", "klaus_combat_can_think", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_owner_defined", 0 );
    nengine_store_set( "blackwater_lake", "klaus_combat_owner_same_team", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_enemy_defined", 0 );
    nengine_store_set( "blackwater_lake", "klaus_combat_enemy_same_team", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_enemy_is_player", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_enemy_distance_sq", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_round_enemy_count", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_nearby_round_enemies", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_weapon_defined", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_weapon_null", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_clip_size", -1 );
    nengine_store_set( "blackwater_lake", "klaus_combat_bullets_in_clip", -1 );
    if ( !isdefined( level.europa ) || !isdefined( level.europa.europa ) ||
         !isdefined( level.europa.europa.activated ) || !level.europa.europa.activated )
    {
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    if ( !isai( level.europa ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_combat_status", "active_actor_not_ai" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_klaus_combat_active_samples++;
    nengine_store_set( "blackwater_lake", "klaus_combat_status", "active_ai_sampled" );
    nengine_store_set( "blackwater_lake", "klaus_combat_active_samples", level.bwl_klaus_combat_active_samples );
    if ( isdefined( level.europa.europa.var_23cd7b201182ed4f ) )
        nengine_store_set( "blackwater_lake", "klaus_combat_can_think", level.europa.europa.var_23cd7b201182ed4f );
    if ( isdefined( level.europa.var_733dc6b133ffcbe2 ) )
        nengine_store_set( "blackwater_lake", "klaus_combat_bullets_in_clip", level.europa.var_733dc6b133ffcbe2 );
    if ( isdefined( level.europa.europa.var_e43ea20cd212ff51 ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_combat_owner_defined", 1 );
        if ( isdefined( level.europa.var_e91aa3800490c167 ) &&
             isdefined( level.europa.europa.var_e43ea20cd212ff51.var_e91aa3800490c167 ) )
        {
            if ( level.europa.var_e91aa3800490c167 == level.europa.europa.var_e43ea20cd212ff51.var_e91aa3800490c167 )
                nengine_store_set( "blackwater_lake", "klaus_combat_owner_same_team", 1 );
            else
                nengine_store_set( "blackwater_lake", "klaus_combat_owner_same_team", 0 );
        }
    }
    if ( isdefined( level.europa.var_fbf8b9e27ac5cb5e ) )
    {
        level.bwl_klaus_combat_enemy_samples++;
        nengine_store_set( "blackwater_lake", "klaus_combat_enemy_defined", 1 );
        nengine_store_set( "blackwater_lake", "klaus_combat_enemy_is_player", isplayer( level.europa.var_fbf8b9e27ac5cb5e ) );
        if ( isdefined( level.europa.origin ) && isdefined( level.europa.var_fbf8b9e27ac5cb5e.origin ) )
            nengine_store_set( "blackwater_lake", "klaus_combat_enemy_distance_sq", distancesquared( level.europa.origin, level.europa.var_fbf8b9e27ac5cb5e.origin ) );
        if ( isdefined( level.europa.var_e91aa3800490c167 ) && isdefined( level.europa.var_fbf8b9e27ac5cb5e.var_e91aa3800490c167 ) )
        {
            if ( level.europa.var_e91aa3800490c167 == level.europa.var_fbf8b9e27ac5cb5e.var_e91aa3800490c167 )
                nengine_store_set( "blackwater_lake", "klaus_combat_enemy_same_team", 1 );
            else
                nengine_store_set( "blackwater_lake", "klaus_combat_enemy_same_team", 0 );
        }
    }
    nengine_store_set( "blackwater_lake", "klaus_combat_enemy_samples", level.bwl_klaus_combat_enemy_samples );

    level.bwl_klaus_combat_weapon = level.europa getcurrentweapon();
    if ( isdefined( level.bwl_klaus_combat_weapon ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_combat_weapon_defined", 1 );
        if ( isnullweapon( level.bwl_klaus_combat_weapon ) )
            nengine_store_set( "blackwater_lake", "klaus_combat_weapon_null", 1 );
        else
        {
            nengine_store_set( "blackwater_lake", "klaus_combat_weapon_null", 0 );
            nengine_store_set( "blackwater_lake", "klaus_combat_clip_size", weaponclipsize( level.bwl_klaus_combat_weapon ) );
        }
    }
    else
        nengine_store_set( "blackwater_lake", "klaus_combat_weapon_defined", 0 );

    // This is the same read-only native round-enemy collection used by Klaus's attack condition.
    level.bwl_klaus_combat_enemies = namespace_60b3bdcc70f79fc6::function_81557bcd4ddf6a05( #"zombie", #"get_round_enemies" );
    if ( isdefined( level.bwl_klaus_combat_enemies ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_combat_round_enemy_count", level.bwl_klaus_combat_enemies.size );
        level.bwl_klaus_combat_near = 0;
        level.bwl_klaus_combat_i = 0;
        while ( level.bwl_klaus_combat_i < level.bwl_klaus_combat_enemies.size )
        {
            if ( isdefined( level.bwl_klaus_combat_enemies[ level.bwl_klaus_combat_i ] ) &&
                 isdefined( level.bwl_klaus_combat_enemies[ level.bwl_klaus_combat_i ].origin ) &&
                 isdefined( level.europa.origin ) &&
                 distancesquared( level.europa.origin, level.bwl_klaus_combat_enemies[ level.bwl_klaus_combat_i ].origin ) < 1000000 )
                level.bwl_klaus_combat_near++;
            level.bwl_klaus_combat_i++;
        }
        if ( level.bwl_klaus_combat_near > level.bwl_klaus_combat_near_peak )
            level.bwl_klaus_combat_near_peak = level.bwl_klaus_combat_near;
        nengine_store_set( "blackwater_lake", "klaus_combat_nearby_round_enemies", level.bwl_klaus_combat_near );
        nengine_store_set( "blackwater_lake", "klaus_combat_nearby_peak", level.bwl_klaus_combat_near_peak );
    }
    bwl_klaus_phase_sample();
    nengine_store_save( "blackwater_lake", "runtime" );
}

// 0.2.123: read-only comparison of Klaus's summon round and later rounds.
// Invoked by the existing two-second combat sampler while the native AI is active.
function bwl_klaus_phase_sample()
{
    level.bwl_klaus_phase_round = namespace_a1db93989e602280::function_9decc18afd3e3683();
    if ( !isdefined( level.bwl_klaus_phase_call ) || level.bwl_klaus_phase_call != level.bwl_klaus_use_calls )
    {
        level.bwl_klaus_phase_call = level.bwl_klaus_use_calls;
        level.bwl_klaus_phase_start_round = level.bwl_klaus_phase_round;
        level.bwl_klaus_phase_same_samples = 0;
        level.bwl_klaus_phase_same_enemy = 0;
        level.bwl_klaus_phase_same_visible = 0;
        level.bwl_klaus_phase_same_scripted = 0;
        level.bwl_klaus_phase_same_command = 0;
        level.bwl_klaus_phase_same_smash = 0;
        level.bwl_klaus_phase_after_samples = 0;
        level.bwl_klaus_phase_after_enemy = 0;
        level.bwl_klaus_phase_after_visible = 0;
        level.bwl_klaus_phase_after_scripted = 0;
        level.bwl_klaus_phase_after_command = 0;
        level.bwl_klaus_phase_after_smash = 0;
    }
    level.bwl_klaus_phase_scripted = 0;
    if ( level.europa namespace_ab79a58f6058c6f0::function_530565df45250d79() )
        level.bwl_klaus_phase_scripted = 1;
    level.bwl_klaus_phase_command = 0;
    if ( isdefined( level.europa.europa.var_33035175224a3984 ) )
        level.bwl_klaus_phase_command = level.europa.europa.var_33035175224a3984.size;
    level.bwl_klaus_phase_smash = 0;
    if ( isdefined( level.europa.europa.var_d0790221c4a1313e ) && level.europa.europa.var_d0790221c4a1313e )
        level.bwl_klaus_phase_smash = 1;
    level.bwl_klaus_phase_enemy = 0;
    level.bwl_klaus_phase_visible = 0;
    if ( isdefined( level.europa.var_fbf8b9e27ac5cb5e ) )
    {
        level.bwl_klaus_phase_enemy = 1;
        if ( level.europa cansee( level.europa.var_fbf8b9e27ac5cb5e ) )
            level.bwl_klaus_phase_visible = 1;
    }
    nengine_store_set( "blackwater_lake", "klaus_phase_call", level.bwl_klaus_phase_call );
    nengine_store_set( "blackwater_lake", "klaus_phase_round", level.bwl_klaus_phase_round );
    nengine_store_set( "blackwater_lake", "klaus_phase_first_active_round", level.bwl_klaus_phase_start_round );
    nengine_store_set( "blackwater_lake", "klaus_phase_scripted", level.bwl_klaus_phase_scripted );
    nengine_store_set( "blackwater_lake", "klaus_phase_command_count", level.bwl_klaus_phase_command );
    nengine_store_set( "blackwater_lake", "klaus_phase_ground_smash", level.bwl_klaus_phase_smash );
    nengine_store_set( "blackwater_lake", "klaus_phase_enemy_visible", level.bwl_klaus_phase_visible );
    if ( isdefined( level.europa.var_6542440bedf013f ) )
        nengine_store_set( "blackwater_lake", "klaus_phase_aim_flag", level.europa.var_6542440bedf013f );
    else
        nengine_store_set( "blackwater_lake", "klaus_phase_aim_flag", -1 );
    if ( level.bwl_klaus_phase_round == level.bwl_klaus_phase_start_round )
    {
        level.bwl_klaus_phase_same_samples++;
        if ( level.bwl_klaus_phase_enemy )
            level.bwl_klaus_phase_same_enemy++;
        if ( level.bwl_klaus_phase_visible )
            level.bwl_klaus_phase_same_visible++;
        if ( level.bwl_klaus_phase_scripted )
            level.bwl_klaus_phase_same_scripted++;
        if ( level.bwl_klaus_phase_command > 0 )
            level.bwl_klaus_phase_same_command++;
        if ( level.bwl_klaus_phase_smash )
            level.bwl_klaus_phase_same_smash++;
    }
    else if ( level.bwl_klaus_phase_round > level.bwl_klaus_phase_start_round )
    {
        level.bwl_klaus_phase_after_samples++;
        if ( level.bwl_klaus_phase_enemy )
            level.bwl_klaus_phase_after_enemy++;
        if ( level.bwl_klaus_phase_visible )
            level.bwl_klaus_phase_after_visible++;
        if ( level.bwl_klaus_phase_scripted )
            level.bwl_klaus_phase_after_scripted++;
        if ( level.bwl_klaus_phase_command > 0 )
            level.bwl_klaus_phase_after_command++;
        if ( level.bwl_klaus_phase_smash )
            level.bwl_klaus_phase_after_smash++;
    }
    nengine_store_set( "blackwater_lake", "klaus_phase_same_samples", level.bwl_klaus_phase_same_samples );
    nengine_store_set( "blackwater_lake", "klaus_phase_same_enemy", level.bwl_klaus_phase_same_enemy );
    nengine_store_set( "blackwater_lake", "klaus_phase_same_visible", level.bwl_klaus_phase_same_visible );
    nengine_store_set( "blackwater_lake", "klaus_phase_same_scripted", level.bwl_klaus_phase_same_scripted );
    nengine_store_set( "blackwater_lake", "klaus_phase_same_command", level.bwl_klaus_phase_same_command );
    nengine_store_set( "blackwater_lake", "klaus_phase_same_smash", level.bwl_klaus_phase_same_smash );
    nengine_store_set( "blackwater_lake", "klaus_phase_after_samples", level.bwl_klaus_phase_after_samples );
    nengine_store_set( "blackwater_lake", "klaus_phase_after_enemy", level.bwl_klaus_phase_after_enemy );
    nengine_store_set( "blackwater_lake", "klaus_phase_after_visible", level.bwl_klaus_phase_after_visible );
    nengine_store_set( "blackwater_lake", "klaus_phase_after_scripted", level.bwl_klaus_phase_after_scripted );
    nengine_store_set( "blackwater_lake", "klaus_phase_after_command", level.bwl_klaus_phase_after_command );
    nengine_store_set( "blackwater_lake", "klaus_phase_after_smash", level.bwl_klaus_phase_after_smash );
}

// 0.2.121: prepare only Blackwater's existing native Klaus summon station.
// Keep the real Klaus actor, native summon callback, native cost and cooldown.
function bwl_klaus_repair()
{
    level endon( #"game_ended" );
    level.bwl_klaus_repair_wait = 0;
    level.bwl_klaus_use_calls = 0;
    nengine_store_set( "blackwater_lake", "klaus_repair_status", "waiting" );
    nengine_store_set( "blackwater_lake", "klaus_use_calls", 0 );
    nengine_store_save( "blackwater_lake", "runtime" );
    // The read-only sampler locates the native station after five seconds.
    while ( level.bwl_klaus_repair_wait < 120 &&
        ( !isdefined( level.bwl_klaus_nearest ) || !isdefined( level.europa ) ||
          !isdefined( level.europa.europa ) || !isdefined( level.var_ea75f2b6e20c0384 ) ||
          !isdefined( level.var_ea75f2b6e20c0384.europa ) ||
          !isdefined( level.var_ea75f2b6e20c0384.summon_devices ) ) )
    {
        level.bwl_klaus_repair_wait++;
        wait 1;
    }
    if ( !isdefined( level.bwl_klaus_nearest ) || !isdefined( level.europa ) ||
         !isdefined( level.europa.europa ) || !isdefined( level.var_ea75f2b6e20c0384 ) ||
         !isdefined( level.var_ea75f2b6e20c0384.europa ) ||
         !isdefined( level.var_ea75f2b6e20c0384.summon_devices ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_repair_status", "native_setup_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_klaus_station = level.bwl_klaus_nearest;
    if ( !isdefined( level.bwl_klaus_station.origin ) ||
         distancesquared( level.bwl_klaus_station.origin, ( 13642, 2910, 1057.5 ) ) > 4096 ||
         level.europa != level.var_ea75f2b6e20c0384.europa )
    {
        nengine_store_set( "blackwater_lake", "klaus_repair_status", "station_or_actor_mismatch" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    if ( isdefined( level.bwl_klaus_station.interact ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_repair_status", "native_interaction_present" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    if ( !isdefined( level.europa.europa.activated ) || level.europa.europa.activated ||
         ( isdefined( level.europa.europa.onchair ) && !level.europa.europa.onchair ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_repair_status", "actor_not_ready" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_klaus_in_native_list = 0;
    level.bwl_klaus_list_i = 0;
    while ( level.bwl_klaus_list_i < level.var_ea75f2b6e20c0384.summon_devices.size )
    {
        if ( level.var_ea75f2b6e20c0384.summon_devices[ level.bwl_klaus_list_i ] == level.bwl_klaus_station )
            level.bwl_klaus_in_native_list = 1;
        level.bwl_klaus_list_i++;
    }
    if ( !level.bwl_klaus_in_native_list )
    {
        nengine_store_set( "blackwater_lake", "klaus_repair_status", "station_not_in_native_list" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    if ( !isdefined( level.var_ea75f2b6e20c0384.var_e2ea5c9302351a97 ) )
        level.var_ea75f2b6e20c0384.var_e2ea5c9302351a97 = 2000;
    level.bwl_klaus_station.var_fe6d648dc993577d = #"essence";
    level.bwl_klaus_station.interact = namespace_7fc982453bce8e6a::function_8120aea9aaf48bfa(
        level.bwl_klaus_station, 64, &bwl_klaus_summon_used,
        &namespace_6a69763416b9116f::function_f636bd9519c020d7, undefined, undefined, undefined,
        "\x9c\x11\fHc\xa63\xe1v\x15\xb3Ao\x86" );
    if ( !isdefined( level.bwl_klaus_station.interact ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_repair_status", "interaction_creation_failed" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    // Survival's original initializer waits for another area's power before
    // doing this. Set only Klaus's on-chair state and separate ready flag.
    level.europa.europa.onchair = 1;
    level namespace_60b3bdcc70f79fc6::function_36488e0e5a90d20f( "\x8f[!\x8d5\x8b\xa8\xa9\x16\xa1h(K\xaaif\x1f\xcb\x8ds\xaeos\xc3\xfd\xda\xa9X\x12\x05k\xbbSu\x1d" );
    level.bwl_klaus_station sethintonobstruction( "\x81\xcc\x05\xd3/\xb5\xbf" );
    level.bwl_klaus_station sethintdisplayrange( 64 );
    level.bwl_klaus_station setscriptablepartstate( "\x8f)\a\xdc\xb1\x93Y\x95\xb9", "\xa5\x19\x04s\xf7T" );
    level.bwl_klaus_station setscriptablepartstate( "\x84+\n\xde1\xd4\xcal\xe8K\xd9\xca", "\x92\t\n3\x7f\xb3CHa\x1b\xa1\x99" );
    level.bwl_klaus_station thread namespace_6a69763416b9116f::function_209d79ecfa55b44d();
    nengine_store_set( "blackwater_lake", "klaus_repair_status", "native_station_registered" );
    nengine_store_set( "blackwater_lake", "klaus_repair_station_origin", level.bwl_klaus_station.origin );
    nengine_store_set( "blackwater_lake", "klaus_repair_cost", level.var_ea75f2b6e20c0384.var_e2ea5c9302351a97 );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// Preserve the game's original summon, price, half-buy and cooldown logic.
function bwl_klaus_summon_used( player, half_buy )
{
    if ( !bwl_selected() )
        return;
    level.bwl_klaus_use_calls++;
    nengine_store_set( "blackwater_lake", "klaus_use_calls", level.bwl_klaus_use_calls );
    nengine_store_save( "blackwater_lake", "runtime" );
    self namespace_6a69763416b9116f::function_8bde35a2d8cc0e7f( player, half_buy );
}


// 0.2.120: read-only sampling of the native Klaus actor and summon devices.
// It never creates actors, enables interactions, sets flags, or changes cost.
function bwl_klaus_diag()
{
    level endon( #"game_ended" );
    level.bwl_klaus_diag_samples = 0;
    wait 5;
    while ( true )
    {
        bwl_klaus_sample();
        wait 15;
    }
}

function bwl_klaus_sample()
{
    level.bwl_klaus_diag_samples++;
    nengine_store_set( "blackwater_lake", "klaus_diag_samples", level.bwl_klaus_diag_samples );
    nengine_store_set( "blackwater_lake", "klaus_data_defined", isdefined( level.var_ea75f2b6e20c0384 ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "klaus_global_actor_defined", isdefined( level.europa ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "klaus_global_actor_state_defined",
        isdefined( level.europa ) && isdefined( level.europa.europa ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "klaus_quest_actor_defined",
        isdefined( level.var_ea75f2b6e20c0384 ) && isdefined( level.var_ea75f2b6e20c0384.europa ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "klaus_scene_anchor_defined",
        isdefined( level.var_ea75f2b6e20c0384 ) && isdefined( level.var_ea75f2b6e20c0384.var_15bcb3e0fb9f42a7 ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "klaus_unlock_device_defined",
        isdefined( level.var_ea75f2b6e20c0384 ) && isdefined( level.var_ea75f2b6e20c0384.unlock_device ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "klaus_native_list_count",
        isdefined( level.var_ea75f2b6e20c0384 ) && isdefined( level.var_ea75f2b6e20c0384.summon_devices ) ? level.var_ea75f2b6e20c0384.summon_devices.size : -1 );
    nengine_store_set( "blackwater_lake", "klaus_native_cost",
        isdefined( level.var_ea75f2b6e20c0384 ) && isdefined( level.var_ea75f2b6e20c0384.var_e2ea5c9302351a97 ) ? level.var_ea75f2b6e20c0384.var_e2ea5c9302351a97 : -1 );
    nengine_store_set( "blackwater_lake", "klaus_actor_active",
        isdefined( level.europa ) && isdefined( level.europa.europa ) && isdefined( level.europa.europa.activated ) ? level.europa.europa.activated : -1 );
    nengine_store_set( "blackwater_lake", "klaus_actor_on_chair",
        isdefined( level.europa ) && isdefined( level.europa.europa ) && isdefined( level.europa.europa.onchair ) ? level.europa.europa.onchair : -1 );
    if ( isdefined( level.europa ) && isdefined( level.europa.origin ) )
        nengine_store_set( "blackwater_lake", "klaus_actor_origin", level.europa.origin );
    if ( isdefined( level.var_ea75f2b6e20c0384 ) &&
         isdefined( level.var_ea75f2b6e20c0384.var_15bcb3e0fb9f42a7 ) &&
         isdefined( level.var_ea75f2b6e20c0384.var_15bcb3e0fb9f42a7.origin ) )
        nengine_store_set( "blackwater_lake", "klaus_scene_anchor_origin", level.var_ea75f2b6e20c0384.var_15bcb3e0fb9f42a7.origin );

    // These two encrypted literals are copied byte-for-byte from Firefly's
    // native summon_devices getentarray call and checked in the build.
    level.bwl_klaus_devices = getentarray( "\x80\\\x0e\x1a\xe0\xad\x9d\x83\x11\x98C]\xa9\xb8\xb7e", "\x8f\xed\x12;b\x9b\xfb\xc8[\x1f\xe5\xef\\G\xa8\xb03\xab\xd0\xe2" );
    nengine_store_set( "blackwater_lake", "klaus_world_device_count",
        isdefined( level.bwl_klaus_devices ) ? level.bwl_klaus_devices.size : -1 );
    level.bwl_klaus_nearest = undefined;
    level.bwl_klaus_nearest_distance = 999999999;
    level.bwl_klaus_i = 0;
    if ( isdefined( level.bwl_klaus_devices ) )
    {
        while ( level.bwl_klaus_i < level.bwl_klaus_devices.size )
        {
            if ( isdefined( level.bwl_klaus_devices[ level.bwl_klaus_i ] ) &&
                 isdefined( level.bwl_klaus_devices[ level.bwl_klaus_i ].origin ) &&
                 distancesquared( level.bwl_klaus_devices[ level.bwl_klaus_i ].origin, ( 13613, 2377, 1056 ) ) < level.bwl_klaus_nearest_distance )
            {
                level.bwl_klaus_nearest = level.bwl_klaus_devices[ level.bwl_klaus_i ];
                level.bwl_klaus_nearest_distance = distancesquared( level.bwl_klaus_nearest.origin, ( 13613, 2377, 1056 ) );
            }
            level.bwl_klaus_i++;
        }
    }
    nengine_store_set( "blackwater_lake", "klaus_nearest_device_defined", isdefined( level.bwl_klaus_nearest ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "klaus_nearest_device_interact",
        isdefined( level.bwl_klaus_nearest ) && isdefined( level.bwl_klaus_nearest.interact ) ? 1 : 0 );
    if ( isdefined( level.bwl_klaus_nearest ) )
    {
        nengine_store_set( "blackwater_lake", "klaus_nearest_device_origin", level.bwl_klaus_nearest.origin );
        nengine_store_set( "blackwater_lake", "klaus_nearest_device_distance_sq", level.bwl_klaus_nearest_distance );
    }
    nengine_store_save( "blackwater_lake", "runtime" );
}


// 0.2.111 diagnostic (Mayhem did not load). Read-only: records the
// Kronos Cursed Survival Mayhem handoff (the csm_* dvars that
// csm_mayhem_relic_post.lua writes and csm_survival.gscc reads) and
// csm_survival's own level state, at the first spawn and 15 seconds later.
// It changes no dvar, entity or gameplay value.
function bwl_csm_diag()
{
    level endon( #"game_ended" );
    nengine_store_set( "blackwater_lake", "csm_spawn_p1_armed", getdvar( @"hash_2ba0ca3d1e8f6f1f", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_p1_serial", getdvar( @"hash_804bdcd886c4d398", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_p1_selection", getdvar( @"hash_d0a79432776e0aba", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_p1_poi", getdvar( @"hash_78cdad18b29baa30", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_p1_relic", getdvar( @"hash_102e10b8f7a26aaf", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_s1_armed", getdvar( @"hash_4df930eb0fd35efc", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_s1_mrp", getdvar( @"hash_5a6e9a40c2eec9aa", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_s1_route", getdvar( @"hash_ea81657d4d8da1de", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_s1_selection", getdvar( @"hash_f541971810a2c835", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_s1_status", getdvar( @"hash_ed9b0e46d505c12f", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_s1_ready", getdvar( @"hash_c4b72492e1380ab4", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_c1_active", getdvar( @"hash_c275a6196ec42d5f", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_c1_map", getdvar( @"hash_7bc9dcdec9171781", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_r1_active", getdvar( @"hash_f74a4b36f3a781b8", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_engine_load", getdvar( @"hash_89cdd504cc46b123", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_gsc_84fb", getdvar( @"hash_84fb1bc615045e72", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_gsc_da1e", getdvar( @"hash_da1eb79d992f0e28", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_spawn_csm_loaded", isdefined( level.var_11c90d8820dc7f81 ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_spawn_mayhem_started", isdefined( level.var_8a0ea43002bdec1c ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_spawn_session_defined", isdefined( level.var_7d6dd80d20d65e17 ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_spawn_session_active", ( isdefined( level.var_7d6dd80d20d65e17 ) && isdefined( level.var_7d6dd80d20d65e17.active ) ) ? level.var_7d6dd80d20d65e17.active : -1 );
    nengine_store_set( "blackwater_lake", "csm_spawn_mode_defined", isdefined( level.var_7ebad24685cd9f8c ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_spawn_mode_gametype", ( isdefined( level.var_7ebad24685cd9f8c ) && isdefined( level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7 ) ) ? level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7 : "undefined" );
    nengine_store_set( "blackwater_lake", "csm_spawn_mode_flag", ( isdefined( level.var_7ebad24685cd9f8c ) && isdefined( level.var_7ebad24685cd9f8c.var_2a42ba6a1a4e260d ) ) ? level.var_7ebad24685cd9f8c.var_2a42ba6a1a4e260d : -1 );
    nengine_store_set( "blackwater_lake", "csm_spawn_save_defined", isdefined( level.var_7d7b480d20e568ec ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_spawn_save_armed", ( isdefined( level.var_7d7b480d20e568ec ) && isdefined( level.var_7d7b480d20e568ec.var_2adfb465c9c4b744 ) ) ? level.var_7d7b480d20e568ec.var_2adfb465c9c4b744 : -1 );
    nengine_store_set( "blackwater_lake", "csm_spawn_save_route", ( isdefined( level.var_7d7b480d20e568ec ) && isdefined( level.var_7d7b480d20e568ec.var_313a800b52f3c19b ) ) ? level.var_7d7b480d20e568ec.var_313a800b52f3c19b : "undefined" );
    nengine_store_set( "blackwater_lake", "csm_spawn_level_map", isdefined( level.var_dfeae4b8b3d59217 ) ? level.var_dfeae4b8b3d59217 : "undefined" );
    nengine_store_set( "blackwater_lake", "csm_spawn_level_poi", isdefined( level.var_a76045f3136660f9 ) ? level.var_a76045f3136660f9 : "undefined" );
    nengine_store_save( "blackwater_lake", "runtime" );
    wait 15;
    nengine_store_set( "blackwater_lake", "csm_later_p1_armed", getdvar( @"hash_2ba0ca3d1e8f6f1f", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_p1_serial", getdvar( @"hash_804bdcd886c4d398", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_p1_selection", getdvar( @"hash_d0a79432776e0aba", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_p1_poi", getdvar( @"hash_78cdad18b29baa30", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_p1_relic", getdvar( @"hash_102e10b8f7a26aaf", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_s1_armed", getdvar( @"hash_4df930eb0fd35efc", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_s1_mrp", getdvar( @"hash_5a6e9a40c2eec9aa", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_s1_route", getdvar( @"hash_ea81657d4d8da1de", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_s1_selection", getdvar( @"hash_f541971810a2c835", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_s1_status", getdvar( @"hash_ed9b0e46d505c12f", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_s1_ready", getdvar( @"hash_c4b72492e1380ab4", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_c1_active", getdvar( @"hash_c275a6196ec42d5f", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_c1_map", getdvar( @"hash_7bc9dcdec9171781", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_r1_active", getdvar( @"hash_f74a4b36f3a781b8", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_engine_load", getdvar( @"hash_89cdd504cc46b123", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_gsc_84fb", getdvar( @"hash_84fb1bc615045e72", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_gsc_da1e", getdvar( @"hash_da1eb79d992f0e28", "null" ) );
    nengine_store_set( "blackwater_lake", "csm_later_csm_loaded", isdefined( level.var_11c90d8820dc7f81 ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_later_mayhem_started", isdefined( level.var_8a0ea43002bdec1c ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_later_session_defined", isdefined( level.var_7d6dd80d20d65e17 ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_later_session_active", ( isdefined( level.var_7d6dd80d20d65e17 ) && isdefined( level.var_7d6dd80d20d65e17.active ) ) ? level.var_7d6dd80d20d65e17.active : -1 );
    nengine_store_set( "blackwater_lake", "csm_later_mode_defined", isdefined( level.var_7ebad24685cd9f8c ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_later_mode_gametype", ( isdefined( level.var_7ebad24685cd9f8c ) && isdefined( level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7 ) ) ? level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7 : "undefined" );
    nengine_store_set( "blackwater_lake", "csm_later_mode_flag", ( isdefined( level.var_7ebad24685cd9f8c ) && isdefined( level.var_7ebad24685cd9f8c.var_2a42ba6a1a4e260d ) ) ? level.var_7ebad24685cd9f8c.var_2a42ba6a1a4e260d : -1 );
    nengine_store_set( "blackwater_lake", "csm_later_save_defined", isdefined( level.var_7d7b480d20e568ec ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "csm_later_save_armed", ( isdefined( level.var_7d7b480d20e568ec ) && isdefined( level.var_7d7b480d20e568ec.var_2adfb465c9c4b744 ) ) ? level.var_7d7b480d20e568ec.var_2adfb465c9c4b744 : -1 );
    nengine_store_set( "blackwater_lake", "csm_later_save_route", ( isdefined( level.var_7d7b480d20e568ec ) && isdefined( level.var_7d7b480d20e568ec.var_313a800b52f3c19b ) ) ? level.var_7d7b480d20e568ec.var_313a800b52f3c19b : "undefined" );
    nengine_store_set( "blackwater_lake", "csm_later_level_map", isdefined( level.var_dfeae4b8b3d59217 ) ? level.var_dfeae4b8b3d59217 : "undefined" );
    nengine_store_set( "blackwater_lake", "csm_later_level_poi", isdefined( level.var_a76045f3136660f9 ) ? level.var_a76045f3136660f9 : "undefined" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_lake_native_power_override()
{
    nengine_store_set( "blackwater_lake", "lake_power_override_called", 1 );
    nengine_store_set( "blackwater_lake", "lake_power_override_before",
        level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" ) ? 1 : 0 );
    level namespace_60b3bdcc70f79fc6::function_bb43e9471feff54e( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" );
    nengine_store_set( "blackwater_lake", "lake_power_override_after",
        level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" ) ? 1 : 0 );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// Recreate the lake generator quest without replacing Firefly's shared
// Survival initializer: that initializer also removes the wooden barriers.
// All mutable state and loop counters live on level because ACTS local
// assignments are unreliable in this game.
function bwl_lake_power()
{
    level endon( #"game_ended" );
    level.bwl_lake = spawnstruct();
    level.bwl_lake.stage = "waiting_for_native_props";
    level.bwl_lake.gen_origin = ( 12283.8, 1996, 1022.75 );
    level.bwl_lake.gen_angles = ( 0, 298.06, 0 );
    level.bwl_lake.lever_origin = ( 12838, 2146, 1229.5 );
    level.bwl_lake.lever_angles = ( 0, 33.59, 0 );
    level.bwl_lake.cylinders = [];
    level.bwl_lake.pustules = [];
    level.bwl_lake.pustule_health = [];
    level.bwl_lake.lever_busy = 0;
    nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
    nengine_store_set( "blackwater_lake", "lake_power_on", 0 );
    nengine_store_set( "blackwater_lake", "lake_power_fallback", "none" );
    nengine_store_set( "blackwater_lake", "lake_generator_source", "not_checked" );
    nengine_store_set( "blackwater_lake", "lake_switch_source", "not_checked" );
    nengine_store_set( "blackwater_lake", "lake_cylinders_native", -1 );
    nengine_store_set( "blackwater_lake", "lake_cylinders_spawned", -1 );
    nengine_store_set( "blackwater_lake", "lake_pump_zone", "unknown" );
    nengine_store_set( "blackwater_lake", "lake_lever_zone", "unknown" );
    nengine_store_set( "blackwater_lake", "lake_pustule_count", -1 );
    nengine_store_set( "blackwater_lake", "lake_pustules_left", -1 );
    nengine_store_set( "blackwater_lake", "lake_core_health", -1 );
    nengine_store_set( "blackwater_lake", "lake_perks_start_on", -1 );
    nengine_store_set( "blackwater_lake", "lake_wunderfizz_start_override", -1 );
    nengine_store_set( "blackwater_lake", "lake_arsenal_status", "waiting_for_native_setup" );
    nengine_store_set( "blackwater_lake", "lake_arsenal_initially_enabled", -1 );
    nengine_store_set( "blackwater_lake", "lake_arsenal_start_on", -1 );
    nengine_store_set( "blackwater_lake", "lake_arsenal_after_disable", -1 );
    nengine_store_set( "blackwater_lake", "lake_arsenal_after_enable", -1 );
    nengine_store_set( "blackwater_lake", "lake_power_on1_before_setup", -1 );
    nengine_store_set( "blackwater_lake", "lake_global_power_flag_before_setup", -1 );
    nengine_store_set( "blackwater_lake", "lake_power_on1_at_start",
        level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "lake_global_power_flag_at_start",
        level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\x88\xb7\f\x1f\x03\x92\xf01\xa3\x8f\xb3\xc9\xb5\x9d" ) ? 1 : 0 );
    nengine_store_save( "blackwater_lake", "runtime" );
    level thread bwl_lake_arsenal_guard();

    // The same flag releases the native ON-prop workers. Bound the wait so
    // an unavailable map startup cannot leave the cabin services locked.
    level.bwl_lake.start_wait = 0;
    while ( !level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa9\xec\x12\x9b\xd8NK\xc1\xd1\x85&\x8d\xca\xb9\xfa'+,\x8c\xe5" ) &&
        level.bwl_lake.start_wait < 180 )
    {
        level.bwl_lake.start_wait = level.bwl_lake.start_wait + 1;
        wait 0.5;
    }
    if ( !level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa9\xec\x12\x9b\xd8NK\xc1\xd1\x85&\x8d\xca\xb9\xfa'+,\x8c\xe5" ) )
    {
        bwl_lake_fallback( "native_start_timeout" );
        return;
    }
    wait 3;
    nengine_store_set( "blackwater_lake", "lake_power_on1_before_setup",
        level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "lake_global_power_flag_before_setup",
        level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\x88\xb7\f\x1f\x03\x92\xf01\xa3\x8f\xb3\xc9\xb5\x9d" ) ? 1 : 0 );
    if ( isdefined( level.var_63a203e154ffeca0 ) )
    {
        level.bwl_lake.pump_zone = namespace_63a203e154ffeca0::function_90e5c3e2272b0130( level.bwl_lake.gen_origin );
        level.bwl_lake.lever_zone = namespace_63a203e154ffeca0::function_90e5c3e2272b0130( level.bwl_lake.lever_origin );
    }
    nengine_store_set( "blackwater_lake", "lake_pump_zone",
        isdefined( level.bwl_lake.pump_zone ) && isdefined( level.bwl_lake.pump_zone.var_92781bc7d418ab8a ) ? level.bwl_lake.pump_zone.var_92781bc7d418ab8a : "unknown" );
    nengine_store_set( "blackwater_lake", "lake_lever_zone",
        isdefined( level.bwl_lake.lever_zone ) && isdefined( level.bwl_lake.lever_zone.var_92781bc7d418ab8a ) ? level.bwl_lake.lever_zone.var_92781bc7d418ab8a : "unknown" );
    nengine_store_save( "blackwater_lake", "runtime" );

    // Locate only the authored generator model, so another script_model at
    // the same coordinates is never changed by accident.
    level.bwl_lake.models = getentarray( "script_model", "classname" );
    level.bwl_lake.scan_i = 0;
    while ( level.bwl_lake.scan_i < level.bwl_lake.models.size )
    {
        if ( isdefined( level.bwl_lake.models[ level.bwl_lake.scan_i ].origin ) &&
            distancesquared( level.bwl_lake.models[ level.bwl_lake.scan_i ].origin, level.bwl_lake.gen_origin ) <= 256 &&
            ( level.bwl_lake.models[ level.bwl_lake.scan_i ].model == "sat_zm_aether_energy_generator_main_on_fxanim" ||
              level.bwl_lake.models[ level.bwl_lake.scan_i ].model == "sat_zm_aether_energy_generator_main_fxanim" ) )
        {
            level.bwl_lake.gen = level.bwl_lake.models[ level.bwl_lake.scan_i ];
            break;
        }
        level.bwl_lake.scan_i = level.bwl_lake.scan_i + 1;
        if ( level.bwl_lake.scan_i % 128 == 0 )
            waitframe();
    }
    // 0.2.101 (the pump played its pumping animation before the vines were
    // removed): the map's pump runs with fx "on", the only fx state with
    // animation events, and "off" does not stop it. Like the native quest, use a
    // fresh pump for the infested stage at the native pump's exact place; the
    // running native pump is deleted once the fresh one's scriptable exists.
    if ( isdefined( level.bwl_lake.gen ) )
    {
        level.bwl_lake.gen_native = level.bwl_lake.gen;
        level.bwl_lake.gen = spawn( "script_model", level.bwl_lake.gen_native.origin );
        if ( isdefined( level.bwl_lake.gen ) )
            level.bwl_lake.gen.angles = level.bwl_lake.gen_native.angles;
    }
    else
    {
        level.bwl_lake.gen = spawn( "script_model", level.bwl_lake.gen_origin );
        if ( isdefined( level.bwl_lake.gen ) )
            level.bwl_lake.gen.angles = level.bwl_lake.gen_angles;
    }
    if ( !isdefined( level.bwl_lake.gen ) )
    {
        bwl_lake_fallback( "generator_spawn_failed" );
        return;
    }
    nengine_store_set( "blackwater_lake", "lake_generator_source", isdefined( level.bwl_lake.gen_native ) ? "fresh_replaces_native" : "spawned" );
    level.bwl_lake.gen setmodel( %"sat_zm_aether_energy_generator_main_fxanim" );
    level.bwl_lake.frames = 0;
    while ( !level.bwl_lake.gen namespace_60b3bdcc70f79fc6::function_de1f80d93273abf5() && level.bwl_lake.frames < 40 )
    {
        level.bwl_lake.frames = level.bwl_lake.frames + 1;
        waitframe();
    }
    if ( !level.bwl_lake.gen namespace_60b3bdcc70f79fc6::function_de1f80d93273abf5() )
    {
        // 0.2.101: keep the native pump if the fresh one has no scriptable.
        if ( isdefined( level.bwl_lake.gen_native ) )
        {
            level.bwl_lake.gen delete();
            level.bwl_lake.gen = level.bwl_lake.gen_native;
        }
        bwl_lake_fallback( "generator_scriptable_missing" );
        return;
    }
    if ( isdefined( level.bwl_lake.gen_native ) )
    {
        level.bwl_lake.gen_native delete();
        nengine_store_set( "blackwater_lake", "lake_generator_native_removed", 1 );
    }

    level.bwl_lake.near_lever = getentitylessscriptablearray( undefined, undefined, level.bwl_lake.lever_origin, 32 );
    level.bwl_lake.scan_i = 0;
    while ( level.bwl_lake.scan_i < level.bwl_lake.near_lever.size )
    {
        if ( level.bwl_lake.near_lever[ level.bwl_lake.scan_i ].type == %"zm_sat_firefly_pap_power_switch_lake" )
        {
            level.bwl_lake.lever = level.bwl_lake.near_lever[ level.bwl_lake.scan_i ];
            break;
        }
        level.bwl_lake.scan_i = level.bwl_lake.scan_i + 1;
    }
    if ( isdefined( level.bwl_lake.lever ) )
        nengine_store_set( "blackwater_lake", "lake_switch_source", "native" );
    else
    {
        level.bwl_lake.lever = spawnscriptable( %"zm_sat_firefly_pap_power_switch_lake", level.bwl_lake.lever_origin, level.bwl_lake.lever_angles );
        nengine_store_set( "blackwater_lake", "lake_switch_source", "spawned" );
    }
    if ( !isdefined( level.bwl_lake.lever ) )
    {
        bwl_lake_fallback( "switch_spawn_failed" );
        return;
    }
    level.bwl_lake.lever setscriptablepartstate( "\x9f<\x0f+\x1b\x95\xc6\xa3'\xb4\xd8\xb0\xd8\xeb&\xf6\x87", "\xb7\x19\x04\xf63\x99" );

    // Match cylinders to the OFF model's three tag positions; reuse the
    // native ON instances when present and spawn only a missing cylinder.
    level.bwl_lake.near_gen = getentitylessscriptablearray( undefined, undefined, level.bwl_lake.gen_origin, 256 );
    level.bwl_lake.cyl_native = 0;
    level.bwl_lake.cyl_spawned = 0;
    level.bwl_lake.cyl_i = 1;
    while ( level.bwl_lake.cyl_i <= 3 )
    {
        level.bwl_lake.tag = "\xa2\n\x10\x04\xb3H\xa1\xe7\xcdH\xda\xb3\xb1\x9d\x0f\"1\xb9" + int( level.bwl_lake.cyl_i );
        level.bwl_lake.cyl_origin = level.bwl_lake.gen gettagorigin( level.bwl_lake.tag );
        level.bwl_lake.cyl_angles = level.bwl_lake.gen gettagangles( level.bwl_lake.tag );
        if ( !isdefined( level.bwl_lake.cyl_origin ) || !isdefined( level.bwl_lake.cyl_angles ) )
        {
            bwl_lake_fallback( "generator_tag_missing" );
            return;
        }
        level.bwl_lake.cyl = undefined;
        level.bwl_lake.cyl_best_distance = 1025;
        level.bwl_lake.scan_i = 0;
        while ( level.bwl_lake.scan_i < level.bwl_lake.near_gen.size )
        {
            if ( level.bwl_lake.near_gen[ level.bwl_lake.scan_i ].type == %"zm_sat_firefly_pap_aether_generator_cylinder" &&
                isdefined( level.bwl_lake.near_gen[ level.bwl_lake.scan_i ].origin ) &&
                distancesquared( level.bwl_lake.near_gen[ level.bwl_lake.scan_i ].origin, level.bwl_lake.cyl_origin ) < level.bwl_lake.cyl_best_distance &&
                !arraycontains( level.bwl_lake.cylinders, level.bwl_lake.near_gen[ level.bwl_lake.scan_i ] ) )
            {
                level.bwl_lake.cyl = level.bwl_lake.near_gen[ level.bwl_lake.scan_i ];
                level.bwl_lake.cyl_best_distance = distancesquared( level.bwl_lake.cyl.origin, level.bwl_lake.cyl_origin );
            }
            level.bwl_lake.scan_i = level.bwl_lake.scan_i + 1;
        }
        if ( isdefined( level.bwl_lake.cyl ) )
            level.bwl_lake.cyl_native = level.bwl_lake.cyl_native + 1;
        else
        {
            level.bwl_lake.cyl = spawnscriptable( %"zm_sat_firefly_pap_aether_generator_cylinder", level.bwl_lake.cyl_origin, level.bwl_lake.cyl_angles );
            level.bwl_lake.cyl_spawned = level.bwl_lake.cyl_spawned + 1;
        }
        if ( !isdefined( level.bwl_lake.cyl ) )
        {
            bwl_lake_fallback( "cylinder_spawn_failed" );
            return;
        }
        if ( level.bwl_lake.cyl_i == 2 )
            level.bwl_lake.cyl setscriptablepartstate( "\x9bB\a\x1bZ\x8b\xea\xd2\x8c", "\xb6\b\t\xb1\x01:\xc8\xeb\xcbW\v" );
        if ( level.bwl_lake.cyl_i == 3 )
            level.bwl_lake.cyl setscriptablepartstate( "\x9bB\a\x1bZ\x8b\xea\xd2\x8c", "\xaa\b\tm\xcfy-;\x91BK" );
        level.bwl_lake.cylinders[ level.bwl_lake.cylinders.size ] = level.bwl_lake.cyl;
        level.bwl_lake.cyl_i = level.bwl_lake.cyl_i + 1;
    }
    nengine_store_set( "blackwater_lake", "lake_cylinders_native", level.bwl_lake.cyl_native );
    nengine_store_set( "blackwater_lake", "lake_cylinders_spawned", level.bwl_lake.cyl_spawned );
    nengine_store_save( "blackwater_lake", "runtime" );
    bwl_lake_prepare_infestation();
}

function bwl_lake_arsenal_guard()
{
    level endon( #"game_ended" );
    // The real Arsenal initializer uses this flag before it enables or
    // disables its interaction. Let it finish before applying the lake gate.
    level.bwl_lake.arsenal_start_wait = 0;
    while ( !level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\x8b\x99\x17\xf7 x,\xa9\xa3^\xb2/HKR\xff\x81\xc8oo\xe0sy\xd2\xe5" ) &&
        level.bwl_lake.arsenal_start_wait < 180 )
    {
        level.bwl_lake.arsenal_start_wait = level.bwl_lake.arsenal_start_wait + 1;
        wait 0.5;
    }
    if ( !level namespace_60b3bdcc70f79fc6::function_f0bb112fe637e41c( "\x8b\x99\x17\xf7 x,\xa9\xa3^\xb2/HKR\xff\x81\xc8oo\xe0sy\xd2\xe5" ) )
    {
        nengine_store_set( "blackwater_lake", "lake_arsenal_status", "native_start_timeout" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    wait 1;
    level.bwl_lake.arsenal_attempt = 0;
    while ( level.bwl_lake.arsenal_attempt < 120 )
    {
        if ( isdefined( level.var_52e94a468e66d601 ) )
        {
            level.bwl_lake.arsenal_i = 0;
            while ( level.bwl_lake.arsenal_i < level.var_52e94a468e66d601.size )
            {
                if ( isdefined( level.var_52e94a468e66d601[ level.bwl_lake.arsenal_i ] ) &&
                    isdefined( level.var_52e94a468e66d601[ level.bwl_lake.arsenal_i ].origin ) &&
                    distancesquared( level.var_52e94a468e66d601[ level.bwl_lake.arsenal_i ].origin, ( 13294.5, 2375.65, 1184 ) ) <= 4096 &&
                    isdefined( level.var_52e94a468e66d601[ level.bwl_lake.arsenal_i ].var_ed56d91af64d44bc ) &&
                    isdefined( level.var_52e94a468e66d601[ level.bwl_lake.arsenal_i ].var_ed56d91af64d44bc.interact ) &&
                    level.var_52e94a468e66d601[ level.bwl_lake.arsenal_i ].var_ed56d91af64d44bc namespace_60b3bdcc70f79fc6::function_de1f80d93273abf5() )
                {
                    level.bwl_lake.arsenal = level.var_52e94a468e66d601[ level.bwl_lake.arsenal_i ];
                    break;
                }
                level.bwl_lake.arsenal_i = level.bwl_lake.arsenal_i + 1;
            }
        }
        if ( isdefined( level.bwl_lake.arsenal ) )
            break;
        level.bwl_lake.arsenal_attempt = level.bwl_lake.arsenal_attempt + 1;
        wait 0.5;
    }
    if ( !isdefined( level.bwl_lake.arsenal ) )
    {
        nengine_store_set( "blackwater_lake", "lake_arsenal_status", "cabin_arsenal_not_found" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    nengine_store_set( "blackwater_lake", "lake_arsenal_initially_enabled",
        isdefined( level.bwl_lake.arsenal.var_5929513b9515fde7 ) && level.bwl_lake.arsenal.var_5929513b9515fde7 ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "lake_arsenal_start_on",
        isdefined( level.bwl_lake.arsenal.var_e502d431f3ba8706 ) ? level.bwl_lake.arsenal.var_e502d431f3ba8706 : -1 );
    if ( level.bwl_lake.stage != "power_on" && level.bwl_lake.stage != "fallback" )
    {
        level.bwl_lake.arsenal namespace_dc529560fdc5ad58::function_182ec13cd5fecb87( 1 );
        nengine_store_set( "blackwater_lake", "lake_arsenal_after_disable",
            isdefined( level.bwl_lake.arsenal.var_5929513b9515fde7 ) && level.bwl_lake.arsenal.var_5929513b9515fde7 ? 1 : 0 );
        nengine_store_set( "blackwater_lake", "lake_arsenal_status", "disable_requested" );
        nengine_store_save( "blackwater_lake", "runtime" );
        while ( level.bwl_lake.stage != "power_on" && level.bwl_lake.stage != "fallback" )
            wait 0.25;
    }
    // The native power waiter may already have enabled it on the flag.
    waitframe();
    if ( !isdefined( level.bwl_lake.arsenal.var_5929513b9515fde7 ) || !level.bwl_lake.arsenal.var_5929513b9515fde7 )
    {
        level.bwl_lake.arsenal namespace_dc529560fdc5ad58::function_d4fbd08eea07ad38( 1 );
        nengine_store_set( "blackwater_lake", "lake_arsenal_status", "enable_requested" );
    }
    else
        nengine_store_set( "blackwater_lake", "lake_arsenal_status", "native_enabled" );
    nengine_store_set( "blackwater_lake", "lake_arsenal_after_enable",
        isdefined( level.bwl_lake.arsenal.var_5929513b9515fde7 ) && level.bwl_lake.arsenal.var_5929513b9515fde7 ? 1 : 0 );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_lake_prepare_infestation()
{
    level.bwl_lake.positions = [
        ( 12270.3, 2021.73, 1121.02 ), ( 12243.2, 2044.7, 1067.65 ),
        ( 12357, 1971.74, 1104.02 ), ( 12254.7, 2001.87, 1098.98 ),
        ( 12256, 1978.72, 1071.57 ), ( 12264.2, 1922.59, 1102.82 ),
        ( 12248, 2068.58, 1066.09 ), ( 12258, 1933.11, 1063.58 ),
        ( 12360.2, 1959.61, 1078.47 ), ( 12270.5, 1912.37, 1068.87 ),
        ( 12293.2, 2024.44, 1108.83 ), ( 12281.3, 2024.1, 1074.54 ),
        ( 12254.3, 1982.05, 1127.23 ), ( 12296.7, 1963.35, 1074.62 ),
        ( 12317, 2005.34, 1121.95 ), ( 12365.5, 1978.87, 1061.66 ),
        ( 12311, 2012.6, 1081.23 ), ( 12309.7, 1971.2, 1116.39 )
    ];
    level.bwl_lake.angles = [
        ( 35.94, 200.17, 91.3 ), ( 11.03, 107.07, -102.22 ),
        ( 6.26, 15.58, -5.24 ), ( 14.93, 73.49, -107.51 ),
        ( 337.87, 295.84, 90.75 ), ( 2.1, 154.22, -11.27 ),
        ( 332.68, 202.11, 91.54 ), ( 357.86, 229.12, 90.99 ),
        ( 9.63, 194.35, -89.01 ), ( 359.34, 222.56, -91.76 ),
        ( 358.13, 343.43, -90.37 ), ( 357.09, 8.25, -90.87 ),
        ( 35.68, 72.24, -119.88 ), ( 57.08, 189.58, -105.97 ),
        ( 54.65, 140.53, 116.11 ), ( 1.14, 126.71, 89.52 ),
        ( 298.66, 128.21, 89.04 ), ( 353.52, 212.8, -87.84 )
    ];
    level.bwl_lake.labels = [ 1, 2, 3, 1, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 3, 1, 1 ];
    level.bwl_lake.indices = [];
    level.bwl_lake.spawn_i = 0;
    while ( level.bwl_lake.spawn_i < level.bwl_lake.positions.size )
    {
        if ( level.bwl_lake.labels[ level.bwl_lake.spawn_i ] == 1 )
            level.bwl_lake.pustule = spawnscriptable( %"zm_sat_firefly_pap_aether_generator_pustule_01", level.bwl_lake.positions[ level.bwl_lake.spawn_i ], level.bwl_lake.angles[ level.bwl_lake.spawn_i ] );
        else if ( level.bwl_lake.labels[ level.bwl_lake.spawn_i ] == 2 )
            level.bwl_lake.pustule = spawnscriptable( %"zm_sat_firefly_pap_aether_generator_pustule_02", level.bwl_lake.positions[ level.bwl_lake.spawn_i ], level.bwl_lake.angles[ level.bwl_lake.spawn_i ] );
        else
            level.bwl_lake.pustule = spawnscriptable( %"zm_sat_firefly_pap_aether_generator_pustule_03", level.bwl_lake.positions[ level.bwl_lake.spawn_i ], level.bwl_lake.angles[ level.bwl_lake.spawn_i ] );
        if ( !isdefined( level.bwl_lake.pustule ) )
        {
            bwl_lake_fallback( "pustule_spawn_failed" );
            return;
        }
        level.bwl_lake.pustules[ level.bwl_lake.spawn_i ] = level.bwl_lake.pustule;
        level.bwl_lake.pustule_health[ level.bwl_lake.spawn_i ] = 0;
        level.bwl_lake.indices[ level.bwl_lake.spawn_i ] = level.bwl_lake.spawn_i;
        level.bwl_lake.spawn_i = level.bwl_lake.spawn_i + 1;
    }
    level.bwl_lake.core = spawnscriptable( %"zm_sat_firefly_pap_aether_generator_infestation_core", level.bwl_lake.gen_origin, level.bwl_lake.gen_angles );
    level.bwl_lake.vines = spawnscriptable( %"zm_sat_firefly_pap_aether_generator_infestation_core_vines", level.bwl_lake.gen_origin, level.bwl_lake.gen_angles );
    if ( !isdefined( level.bwl_lake.core ) || !isdefined( level.bwl_lake.vines ) )
    {
        bwl_lake_fallback( "core_spawn_failed" );
        return;
    }
    bwl_lake_extra_vines( "spawn" );
    level.bwl_lake.core setscriptablepartstate( "\xb7\xb5\as\xf8\xf9\xb4\x9b1", "\x89s\x0eK\xce\xb9\xde\x9c\x95\xbe2\x16\xb6\x16\xb3Y" );

    level.bwl_lake.player_count = level.players.size;
    if ( level.bwl_lake.player_count == 2 )
    {
        level.bwl_lake.count = randomintrange( 10, 12 );
        level.bwl_lake.total_health = 1000;
        level.bwl_lake.core_health = 750;
    }
    else if ( level.bwl_lake.player_count == 3 )
    {
        level.bwl_lake.count = randomintrange( 11, 13 );
        level.bwl_lake.total_health = 1100;
        level.bwl_lake.core_health = 1000;
    }
    else if ( level.bwl_lake.player_count >= 4 )
    {
        level.bwl_lake.count = randomintrange( 12, 14 );
        level.bwl_lake.total_health = 1100;
        level.bwl_lake.core_health = 1250;
    }
    else
    {
        level.bwl_lake.count = randomintrange( 9, 11 );
        level.bwl_lake.total_health = 800;
        level.bwl_lake.core_health = 500;
    }
    level.bwl_lake.core_health_max = level.bwl_lake.core_health;
    level.bwl_lake.timer_running = 0;
    level.bwl_lake.regrowths = 0;
    level.bwl_lake.remaining = level.bwl_lake.count;
    level.bwl_lake.indices = arrayrandomize( level.bwl_lake.indices );
    level.bwl_lake.gen setscriptablepartstate( "\x81\x8c\x06\x9b-O\x18\xf8", "\x92%\x10\xdf\xf9\xbb\xeao(\xb3!rI@\xa0\xd2\fu" );
    level.bwl_lake.setup_i = 0;
    while ( level.bwl_lake.setup_i < level.bwl_lake.cylinders.size )
    {
        level.bwl_lake.cylinders[ level.bwl_lake.setup_i ] setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\x9b]\x13\x96\xdc3\xac\x9b:\v\x1dK\xed\xdc\xeb\xb0\xc6\xd1\xb4;\xb2" );
        level.bwl_lake.setup_i = level.bwl_lake.setup_i + 1;
    }
    level.bwl_lake.setup_i = 0;
    while ( level.bwl_lake.setup_i < level.bwl_lake.count )
    {
        level.bwl_lake.active_index = level.bwl_lake.indices[ level.bwl_lake.setup_i ];
        level.bwl_lake.pustule_health[ level.bwl_lake.active_index ] = level.bwl_lake.total_health / level.bwl_lake.count;
        level.bwl_lake.pustules[ level.bwl_lake.active_index ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\x89\x18\x05sC\x9f\xe3" );
        level.bwl_lake.pustules[ level.bwl_lake.active_index ] setscriptablepartstate( "\xb7\xb5\as\xf8\xf9\xb4\x9b1", "\x9aV\x0e\x99Nu\x10\xacrW\xf9\xf3\x93\x1a\xe6\xc0" );
        level.bwl_lake.setup_i = level.bwl_lake.setup_i + 1;
    }

    level.bwl_lake.hint_none = spawnstruct();
    level.bwl_lake.hint_none.var_26bbd300351fde34 = 0;
    level.bwl_lake.hint_none.string = &"";
    level.bwl_lake.hint_none.type = "\x89\x7f\x0e\x84)\x93\xa2\xf5'z\t\xaa\xa2\xa8\xa7\x93";
    level.bwl_lake.hint_ready = spawnstruct();
    level.bwl_lake.hint_ready.icon = "\xb9\xea$x\xf2\xfbWCW\xa7K\xb6\x7f\xa3\xce\xc5e\xb9\x60@\x9a\xd7E\x98G\xbf\xcf\xb8_\xd7\x13\xc7J\xc3\x98P\",";
    level.bwl_lake.hint_ready.var_a5310c00a7e1f58a = &"hash_5a838ee3b01e9b09";
    level.bwl_lake.hint_ready.description = &"hash_5383cf93521d9741";
    level.bwl_lake.hint_ready.title = &"hash_5c370da21d1b65a6";
    level.bwl_lake.hint_ready.type = "\x9c\x11\fHc\xa63\xe1v\x15\xb3Ao\x86";
    level.bwl_lake.interact = namespace_7fc982453bce8e6a::function_2558ae94964fd952(
        level.bwl_lake.lever, &bwl_lake_lever_use, undefined, undefined, &bwl_lake_lever_hint );
    if ( !isdefined( level.bwl_lake.interact ) )
    {
        bwl_lake_fallback( "switch_interaction_missing" );
        return;
    }
    namespace_6434f4d7be44b03d::function_2b996342b152b257( &bwl_lake_damaged );
    level.bwl_lake.stage = "pustules";
    level thread bwl_lake_hud_watch();
    nengine_store_set( "blackwater_lake", "lake_player_count", level.bwl_lake.player_count );
    nengine_store_set( "blackwater_lake", "lake_pustule_count", level.bwl_lake.count );
    nengine_store_set( "blackwater_lake", "lake_pustules_left", level.bwl_lake.remaining );
    nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// 0.2.53: the cylinders show their own vines. The pump vines copied onto them
// in the previous build flared out like umbrellas (that model is wider than a cylinder;
// they need to hug the water pump). The cylinder scriptable has the
// same "body" part as the pump vines, and its states "off" and "on" hide bone
// j_vine_side while "default" leaves it (names recovered from the zone's
// FNV-1a hashes). So each cylinder's body goes to "default" while the pump is
// infested, and back on free: "on" if it was "on" before, else "off". One
// copy of the native pump vines stays 60 lower around the middle of the pump
// body (in game that band hugs the pump). Everything
// follows level.bwl_lake.vines (spawn, open with the core, regrow, free).
// Cosmetic only: never a fallback. runtime.json gets lake_extra_vines and each
// cylinder's body state before and after the switch.
// 0.2.54 (the same vines added to the main body): the generator scriptable has the same kind of vines on bone
// J_vine; its "fx" part hides J_vine in "activate", "on", "cleared" and the
// pulse state but not in "off", "failed" or the small-dissolve state (names
// from the zone hashes). The pump starts with them hidden, so its fx part goes
// to "off" on spawn. The native steps keep driving it after that (core open,
// "failed" on regrow, "cleared" with the dissolve effect when the pump is
// cleared). On free the old fx state comes back, unless "cleared" is already
// set. runtime.json gets lake_gen_fx_before and lake_gen_fx_after.
function bwl_lake_extra_vines( state )
{
    if ( !isdefined( level.bwl_lake ) )
        return;
    if ( state == "spawn" )
    {
        level.bwl_lake.extra_vines = [];
        level.bwl_lake.extra_vine = spawnscriptable( %"zm_sat_firefly_pap_aether_generator_infestation_core_vines",
            level.bwl_lake.gen_origin + ( 0, 0, -60 ), level.bwl_lake.gen_angles );
        if ( isdefined( level.bwl_lake.extra_vine ) )
            level.bwl_lake.extra_vines[ level.bwl_lake.extra_vines.size ] = level.bwl_lake.extra_vine;
        level.bwl_lake.cylinder_body_on = [];
        level.bwl_lake.extra_vines_i = 0;
        while ( level.bwl_lake.extra_vines_i < level.bwl_lake.cylinders.size )
        {
            level.bwl_lake.cylinder_body_on[ level.bwl_lake.extra_vines_i ] = 0;
            if ( level.bwl_lake.cylinders[ level.bwl_lake.extra_vines_i ] getscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^" ) == "on" )
                level.bwl_lake.cylinder_body_on[ level.bwl_lake.extra_vines_i ] = 1;
            nengine_store_set( "blackwater_lake", "lake_cylinder_body_before_" + level.bwl_lake.extra_vines_i,
                level.bwl_lake.cylinders[ level.bwl_lake.extra_vines_i ] getscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^" ) );
            level.bwl_lake.cylinders[ level.bwl_lake.extra_vines_i ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "default" );
            nengine_store_set( "blackwater_lake", "lake_cylinder_body_after_" + level.bwl_lake.extra_vines_i,
                level.bwl_lake.cylinders[ level.bwl_lake.extra_vines_i ] getscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^" ) );
            level.bwl_lake.extra_vines_i = level.bwl_lake.extra_vines_i + 1;
        }
        if ( isdefined( level.bwl_lake.gen ) )
        {
            level.bwl_lake.gen_fx_before = level.bwl_lake.gen getscriptablepartstate( "\xae\a\x03\xf6\xc8" );
            if ( isdefined( level.bwl_lake.gen_fx_before ) )
            {
                nengine_store_set( "blackwater_lake", "lake_gen_fx_before", level.bwl_lake.gen_fx_before );
                level.bwl_lake.gen setscriptablepartstate( "\xae\a\x03\xf6\xc8", "off" );
                nengine_store_set( "blackwater_lake", "lake_gen_fx_after", level.bwl_lake.gen getscriptablepartstate( "\xae\a\x03\xf6\xc8" ) );
            }
        }
        nengine_store_set( "blackwater_lake", "lake_extra_vines", level.bwl_lake.extra_vines.size );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    if ( !isdefined( level.bwl_lake.extra_vines ) )
        return;
    level.bwl_lake.extra_vines_i = 0;
    while ( level.bwl_lake.extra_vines_i < level.bwl_lake.extra_vines.size )
    {
        if ( state == "free" )
            level.bwl_lake.extra_vines[ level.bwl_lake.extra_vines_i ] freescriptable();
        else
            level.bwl_lake.extra_vines[ level.bwl_lake.extra_vines_i ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", state );
        level.bwl_lake.extra_vines_i = level.bwl_lake.extra_vines_i + 1;
    }
    if ( state == "free" )
    {
        level.bwl_lake.extra_vines_i = 0;
        while ( level.bwl_lake.extra_vines_i < level.bwl_lake.cylinders.size )
        {
            if ( level.bwl_lake.cylinder_body_on[ level.bwl_lake.extra_vines_i ] )
                level.bwl_lake.cylinders[ level.bwl_lake.extra_vines_i ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "on" );
            else
                level.bwl_lake.cylinders[ level.bwl_lake.extra_vines_i ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "off" );
            level.bwl_lake.extra_vines_i = level.bwl_lake.extra_vines_i + 1;
        }
        if ( isdefined( level.bwl_lake.gen ) && isdefined( level.bwl_lake.gen_fx_before ) )
        {
            if ( level.bwl_lake.gen getscriptablepartstate( "\xae\a\x03\xf6\xc8" ) != "cleared" )
                level.bwl_lake.gen setscriptablepartstate( "\xae\a\x03\xf6\xc8", level.bwl_lake.gen_fx_before );
        }
        level.bwl_lake.extra_vines = undefined;
    }
}

function bwl_lake_damaged( einflictor, eattacker, instance, idamage, idflags, smeansofdeath, objweapon, vdir, vpoint, modelindex, partname )
{
    if ( !isdefined( level.bwl_lake ) || !isdefined( instance ) ||
        !isdefined( eattacker ) || !isplayer( eattacker ) || !isdefined( idamage ) || idamage <= 0 )
        return;
    if ( level.bwl_lake.stage == "pustules" )
    {
        level.bwl_lake.hit_i = 0;
        while ( level.bwl_lake.hit_i < level.bwl_lake.pustules.size )
        {
            if ( instance == level.bwl_lake.pustules[ level.bwl_lake.hit_i ] &&
                level.bwl_lake.pustule_health[ level.bwl_lake.hit_i ] > 0 )
            {
                level.bwl_lake.pustule_health[ level.bwl_lake.hit_i ] = level.bwl_lake.pustule_health[ level.bwl_lake.hit_i ] - idamage;
                // Feedback is separate from the damage and power callbacks.
                eattacker thread bwl_lake_hitmarker( level.bwl_lake.pustule_health[ level.bwl_lake.hit_i ] <= 0, undefined );
                if ( !level.bwl_lake.timer_running )
                {
                    level.bwl_lake.timer_running = 1;
                    level.bwl_lake.timer_deadline = gettime() + 30000;
                    level thread bwl_lake_timer();
                }
                if ( level.bwl_lake.pustule_health[ level.bwl_lake.hit_i ] <= 0 )
                {
                    instance setscriptablepartstate( "\xb7\xb5\as\xf8\xf9\xb4\x9b1", "\x89s\x0eK\xce\xb9\xde\x9c\x95\xbe2\x16\xb6\x16\xb3Y" );
                    instance setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\x84\x1d\b\xaa mZS\xd1E" );
                    level.bwl_lake.remaining = level.bwl_lake.remaining - 1;
                    nengine_store_set( "blackwater_lake", "lake_pustules_left", level.bwl_lake.remaining );
                    if ( level.bwl_lake.remaining <= 0 )
                    {
                        level.bwl_lake.stage = "opening_core";
                        nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
                        level thread bwl_lake_expose_core();
                    }
                    nengine_store_save( "blackwater_lake", "runtime" );
                }
                return;
            }
            level.bwl_lake.hit_i = level.bwl_lake.hit_i + 1;
        }
    }
    else if ( level.bwl_lake.stage == "core" && instance == level.bwl_lake.core )
    {
        level.bwl_lake.core_health = level.bwl_lake.core_health - idamage;
        eattacker thread bwl_lake_hitmarker( undefined, 1 );
        if ( level.bwl_lake.core_health <= 0 )
        {
            level.bwl_lake.stage = "clearing_core";
            nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
            nengine_store_save( "blackwater_lake", "runtime" );
            level thread bwl_lake_ready();
        }
    }
}

// This is the same shared hitmarker route used by another Firefly object.
// The wrapper safely returns when the shared provider is not registered.
function bwl_lake_hitmarker( killed, critical )
{
    level.bwl_lake.hitmarker_provider = 0;
    if ( isdefined( level.var_9e5c1a9e0a29d3ce ) &&
        isdefined( level.var_9e5c1a9e0a29d3ce[ #"hash_b4b7b1d36be480e0" ] ) &&
        isdefined( level.var_9e5c1a9e0a29d3ce[ #"hash_b4b7b1d36be480e0" ][ #"hash_4dbce457da44a993" ] ) )
        level.bwl_lake.hitmarker_provider = 1;
    if ( !isdefined( level.bwl_lake.hitmarker_checked ) ||
        level.bwl_lake.hitmarker_checked != level.bwl_lake.hitmarker_provider )
    {
        level.bwl_lake.hitmarker_checked = level.bwl_lake.hitmarker_provider;
        nengine_store_set( "blackwater_lake", "lake_hitmarker_provider", level.bwl_lake.hitmarker_provider );
        nengine_store_save( "blackwater_lake", "runtime" );
    }
    if ( level.bwl_lake.hitmarker_provider )
        self namespace_9d8e359c3b1041e5::function_e8726718c32d7534( "\x81\xae\t/@\xc9\x86\xaa3\xce\xe7", killed, critical, 0, undefined );
}

// The timer begins on the first valid hit and runs through the exposed core.
function bwl_lake_timer()
{
    level endon( #"game_ended" );
    nengine_store_set( "blackwater_lake", "lake_timer", "running" );
    nengine_store_save( "blackwater_lake", "runtime" );
    while ( level.bwl_lake.timer_running &&
        ( level.bwl_lake.stage == "pustules" || level.bwl_lake.stage == "opening_core" || level.bwl_lake.stage == "core" ) )
    {
        if ( gettime() >= level.bwl_lake.timer_deadline )
        {
            level.bwl_lake.timer_running = 0;
            level.bwl_lake.stage = "regrowing";
            nengine_store_set( "blackwater_lake", "lake_timer", "expired" );
            nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
            nengine_store_save( "blackwater_lake", "runtime" );
            level thread bwl_lake_regrow();
            return;
        }
        wait 0.1;
    }
    level.bwl_lake.timer_running = 0;
    nengine_store_set( "blackwater_lake", "lake_timer", "cleared" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// The shipped reset retracts the infestation, waits for the next round, then
// restores the pump and a player-count-dependent selection of pustules.
function bwl_lake_regrow()
{
    level endon( #"game_ended" );
    level.bwl_lake.core setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\xb6i\t\xc9}\xc7\xc8\x9dBg\x1d" );
    level.bwl_lake.core setscriptablepartstate( "\xb7\xb5\as\xf8\xf9\xb4\x9b1", "\x89s\x0eK\xce\xb9\xde\x9c\x95\xbe2\x16\xb6\x16\xb3Y" );
    level.bwl_lake.vines setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\xa4i\bg7\xdc\xb2\x92\xf0Y" );
    bwl_lake_extra_vines( "\xa4i\bg7\xdc\xb2\x92\xf0Y" );
    level.bwl_lake.gen setscriptablepartstate( "\x81\x8c\x06\x9b-O\x18\xf8", "\xaa\x11\rw\xc3\xc9@`]\x8bY\xcb\xb2\xca\x19" );
    // Native keeps each retracted pustule in its active list and re-activates
    // it at regrowth, so remember which ones retracted here.
    level.bwl_lake.retracted = [];
    level.bwl_lake.regrow_i = 0;
    while ( level.bwl_lake.regrow_i < level.bwl_lake.pustules.size )
    {
        level.bwl_lake.retracted[ level.bwl_lake.regrow_i ] = 0;
        if ( level.bwl_lake.pustule_health[ level.bwl_lake.regrow_i ] > 0 )
        {
            level.bwl_lake.pustules[ level.bwl_lake.regrow_i ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\x83\xad\x06\x92\xac\xb7\xda\x1a" );
            level.bwl_lake.retracted[ level.bwl_lake.regrow_i ] = 1;
        }
        level.bwl_lake.pustule_health[ level.bwl_lake.regrow_i ] = 0;
        level.bwl_lake.regrow_i = level.bwl_lake.regrow_i + 1;
    }
    level.bwl_lake.gen setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\xa2F\a\x86\xe7k\x94\xbd\x1b" );
    level.bwl_lake.regrow_i = 0;
    while ( level.bwl_lake.regrow_i < level.bwl_lake.cylinders.size )
    {
        level.bwl_lake.cylinders[ level.bwl_lake.regrow_i ] setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\xa2F\a\x86\xe7k\x94\xbd\x1b" );
        level.bwl_lake.regrow_i = level.bwl_lake.regrow_i + 1;
    }
    // Wait for the same round event the native reset waits for. If Survival
    // never sends it, a logged five-minute fallback keeps power obtainable.
    level.bwl_lake.regrow_trigger = "waiting";
    level.bwl_lake.regrow_deadline = gettime() + 300000;
    nengine_store_set( "blackwater_lake", "lake_regrow_trigger", level.bwl_lake.regrow_trigger );
    nengine_store_save( "blackwater_lake", "runtime" );
    level thread bwl_lake_round_watch();
    while ( level.bwl_lake.regrow_trigger == "waiting" && gettime() < level.bwl_lake.regrow_deadline )
        wait 0.25;
    level notify( #"bwl_lake_round_watch_end" );
    if ( level.bwl_lake.regrow_trigger == "waiting" )
        level.bwl_lake.regrow_trigger = "timeout";
    nengine_store_set( "blackwater_lake", "lake_regrow_trigger", level.bwl_lake.regrow_trigger );
    if ( level.bwl_lake.stage != "regrowing" )
        return;
    level.bwl_lake.player_count = level.players.size;
    if ( level.bwl_lake.player_count == 2 )
    {
        level.bwl_lake.count = randomintrange( 10, 12 );
        level.bwl_lake.total_health = 1000;
        level.bwl_lake.core_health_max = 750;
    }
    else if ( level.bwl_lake.player_count == 3 )
    {
        level.bwl_lake.count = randomintrange( 11, 13 );
        level.bwl_lake.total_health = 1100;
        level.bwl_lake.core_health_max = 1000;
    }
    else if ( level.bwl_lake.player_count >= 4 )
    {
        level.bwl_lake.count = randomintrange( 12, 14 );
        level.bwl_lake.total_health = 1100;
        level.bwl_lake.core_health_max = 1250;
    }
    else
    {
        level.bwl_lake.count = randomintrange( 9, 11 );
        level.bwl_lake.total_health = 800;
        level.bwl_lake.core_health_max = 500;
    }
    // Every retracted pustule comes back, so none is left grey; if more
    // retracted than the new target, all of them are active this attempt.
    level.bwl_lake.regrow_carried = 0;
    level.bwl_lake.regrow_i = 0;
    while ( level.bwl_lake.regrow_i < level.bwl_lake.retracted.size )
    {
        if ( level.bwl_lake.retracted[ level.bwl_lake.regrow_i ] )
            level.bwl_lake.regrow_carried = level.bwl_lake.regrow_carried + 1;
        level.bwl_lake.regrow_i = level.bwl_lake.regrow_i + 1;
    }
    if ( level.bwl_lake.regrow_carried > level.bwl_lake.count )
        level.bwl_lake.count = level.bwl_lake.regrow_carried;
    level.bwl_lake.core_health = level.bwl_lake.core_health_max;
    level.bwl_lake.remaining = level.bwl_lake.count;
    level.bwl_lake.gen setscriptablepartstate( "\x81\x8c\x06\x9b-O\x18\xf8", "\x92%\x10\xdf\xf9\xbb\xeao(\xb3!rI@\xa0\xd2\fu" );
    level.bwl_lake.regrow_i = 0;
    while ( level.bwl_lake.regrow_i < level.bwl_lake.cylinders.size )
    {
        level.bwl_lake.cylinders[ level.bwl_lake.regrow_i ] setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\x9b]\x13\x96\xdc3\xac\x9b:\v\x1dK\xed\xdc\xeb\xb0\xc6\xd1\xb4;\xb2" );
        level.bwl_lake.regrow_i = level.bwl_lake.regrow_i + 1;
    }
    level.bwl_lake.regrow_i = 0;
    while ( level.bwl_lake.regrow_i < level.bwl_lake.retracted.size )
    {
        if ( level.bwl_lake.retracted[ level.bwl_lake.regrow_i ] )
        {
            level.bwl_lake.pustule_health[ level.bwl_lake.regrow_i ] = level.bwl_lake.total_health / level.bwl_lake.count;
            level.bwl_lake.pustules[ level.bwl_lake.regrow_i ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\x89\x18\x05sC\x9f\xe3" );
            level.bwl_lake.pustules[ level.bwl_lake.regrow_i ] setscriptablepartstate( "\xb7\xb5\as\xf8\xf9\xb4\x9b1", "\x9aV\x0e\x99Nu\x10\xacrW\xf9\xf3\x93\x1a\xe6\xc0" );
            level.bwl_lake.retracted[ level.bwl_lake.regrow_i ] = 0;
        }
        level.bwl_lake.regrow_i = level.bwl_lake.regrow_i + 1;
    }
    // Top up with random pustules that are not already active.
    level.bwl_lake.indices = arrayrandomize( level.bwl_lake.indices );
    level.bwl_lake.regrow_i = 0;
    while ( level.bwl_lake.regrow_carried < level.bwl_lake.count && level.bwl_lake.regrow_i < level.bwl_lake.indices.size )
    {
        level.bwl_lake.regrow_index = level.bwl_lake.indices[ level.bwl_lake.regrow_i ];
        if ( level.bwl_lake.pustule_health[ level.bwl_lake.regrow_index ] <= 0 )
        {
            level.bwl_lake.pustule_health[ level.bwl_lake.regrow_index ] = level.bwl_lake.total_health / level.bwl_lake.count;
            level.bwl_lake.pustules[ level.bwl_lake.regrow_index ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\x89\x18\x05sC\x9f\xe3" );
            level.bwl_lake.pustules[ level.bwl_lake.regrow_index ] setscriptablepartstate( "\xb7\xb5\as\xf8\xf9\xb4\x9b1", "\x9aV\x0e\x99Nu\x10\xacrW\xf9\xf3\x93\x1a\xe6\xc0" );
            level.bwl_lake.regrow_carried = level.bwl_lake.regrow_carried + 1;
        }
        level.bwl_lake.regrow_i = level.bwl_lake.regrow_i + 1;
    }
    level.bwl_lake.regrowths = level.bwl_lake.regrowths + 1;
    level.bwl_lake.stage = "pustules";
    nengine_store_set( "blackwater_lake", "lake_timer", "ready" );
    nengine_store_set( "blackwater_lake", "lake_regrowths", level.bwl_lake.regrowths );
    nengine_store_set( "blackwater_lake", "lake_regrow_active", level.bwl_lake.regrow_carried );
    nengine_store_set( "blackwater_lake", "lake_pustule_count", level.bwl_lake.count );
    nengine_store_set( "blackwater_lake", "lake_pustules_left", level.bwl_lake.remaining );
    nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// One watcher per regrowth; it ends with the wait so a later round cannot
// satisfy the next regrowth early.
function bwl_lake_round_watch()
{
    level endon( #"game_ended" );
    level endon( #"bwl_lake_round_watch_end" );
    level waittill( #"hash_a0f483493d68ed58" );
    level.bwl_lake.regrow_trigger = "round_event";
}

// Use only the already-initialized quest HUD: never start the native quest,
// its map setup, its additional zombie spawns, or its power logic.
function bwl_lake_hud_watch()
{
    level endon( #"game_ended" );
    level.bwl_lake.hud_mode = "unavailable";
    level.bwl_lake.hud_wait = 0;
    while ( level.bwl_lake.hud_wait < 120 && level.bwl_lake.hud_mode == "unavailable" &&
        ( level.bwl_lake.stage == "pustules" || level.bwl_lake.stage == "opening_core" || level.bwl_lake.stage == "core" || level.bwl_lake.stage == "regrowing" ) )
    {
        if ( isdefined( level.var_d5276f667352396b ) && isdefined( level.var_7cdd031e33789da7 ) &&
            isdefined( level.var_bf3c2011b07eba63 ) && isdefined( level.var_bf3c2011b07eba63.var_d7fbbaf3bb95b689 ) &&
            isdefined( level.var_bf3c2011b07eba63.var_d7fbbaf3bb95b689.var_eed55fc032130c6a ) )
        {
            if ( isdefined( level.var_d5276f667352396b[ #"firefly_pap_quest" ] ) &&
                !level.var_d5276f667352396b[ #"firefly_pap_quest" ].var_f932d7ebb6cec30e &&
                isdefined( level.var_7cdd031e33789da7[ #"firefly_pap_quest" ] ) &&
                isdefined( level.var_7cdd031e33789da7[ #"firefly_pap_quest" ][ #"hash_77439cafa364fc99" ] ) &&
                isdefined( level.var_7cdd031e33789da7[ #"firefly_pap_quest" ][ #"hash_cadac07a2223c10b" ] ) )
            {
                level.bwl_lake.hud_quest = #"firefly_pap_quest";
                level.bwl_lake.hud_setup = #"hash_77439cafa364fc99";
                level.bwl_lake.hud_active = #"hash_cadac07a2223c10b";
                level.bwl_lake.hud_mode = "native_main_quest";
            }
            else if ( isdefined( level.var_d5276f667352396b[ #"hash_6da5e0cc8bfa9384" ] ) &&
                !level.var_d5276f667352396b[ #"hash_6da5e0cc8bfa9384" ].var_f932d7ebb6cec30e &&
                isdefined( level.var_7cdd031e33789da7[ #"hash_6da5e0cc8bfa9384" ] ) &&
                isdefined( level.var_7cdd031e33789da7[ #"hash_6da5e0cc8bfa9384" ][ #"clear_infestation_setup" ] ) &&
                isdefined( level.var_7cdd031e33789da7[ #"hash_6da5e0cc8bfa9384" ][ #"clear_infestation" ] ) )
            {
                level.bwl_lake.hud_quest = #"hash_6da5e0cc8bfa9384";
                level.bwl_lake.hud_setup = #"clear_infestation_setup";
                level.bwl_lake.hud_active = #"clear_infestation";
                level.bwl_lake.hud_mode = "native_farm_quest";
            }
        }
        if ( level.bwl_lake.hud_mode == "unavailable" )
        {
            level.bwl_lake.hud_wait = level.bwl_lake.hud_wait + 1;
            wait 0.25;
        }
    }
    nengine_store_set( "blackwater_lake", "lake_hud_mode", level.bwl_lake.hud_mode );
    nengine_store_set( "blackwater_lake", "lake_hud_status", level.bwl_lake.hud_mode );
    nengine_store_save( "blackwater_lake", "runtime" );
    if ( level.bwl_lake.hud_mode == "unavailable" )
        return;
    level.bwl_lake.hud_cooldown_available = isdefined( level.var_d5276f667352396b[ #"hash_cda4e7df69dd352a" ] ) &&
        !level.var_d5276f667352396b[ #"hash_cda4e7df69dd352a" ].var_f932d7ebb6cec30e &&
        isdefined( level.var_7cdd031e33789da7[ #"hash_cda4e7df69dd352a" ] ) &&
        isdefined( level.var_7cdd031e33789da7[ #"hash_cda4e7df69dd352a" ][ #"generator_cooldown" ] );
    level.bwl_lake.hud_current_quest = undefined;
    level.bwl_lake.hud_current_step = undefined;
    // The native quest keeps the setup step queued while it is pending rather
    // than toggling it by distance, which avoided objective flicker at a radius.
    while ( level.bwl_lake.stage == "pustules" || level.bwl_lake.stage == "opening_core" || level.bwl_lake.stage == "core" || level.bwl_lake.stage == "regrowing" )
    {
        level.bwl_lake.hud_next_quest = undefined;
        level.bwl_lake.hud_next_step = undefined;
        if ( level.bwl_lake.stage == "regrowing" && level.bwl_lake.hud_cooldown_available )
        {
            level.bwl_lake.hud_next_quest = #"hash_cda4e7df69dd352a";
            level.bwl_lake.hud_next_step = #"generator_cooldown";
        }
        else if ( level.bwl_lake.stage != "regrowing" && level.bwl_lake.timer_running )
        {
            level.bwl_lake.hud_next_quest = level.bwl_lake.hud_quest;
            level.bwl_lake.hud_next_step = level.bwl_lake.hud_active;
        }
        else if ( level.bwl_lake.stage == "pustules" )
        {
            level.bwl_lake.hud_next_quest = level.bwl_lake.hud_quest;
            level.bwl_lake.hud_next_step = level.bwl_lake.hud_setup;
        }
        if ( isdefined( level.bwl_lake.hud_current_step ) != isdefined( level.bwl_lake.hud_next_step ) ||
            ( isdefined( level.bwl_lake.hud_current_step ) &&
              ( level.bwl_lake.hud_current_step != level.bwl_lake.hud_next_step || level.bwl_lake.hud_current_quest != level.bwl_lake.hud_next_quest ) ) )
        {
            if ( isdefined( level.bwl_lake.hud_current_step ) )
            {
                // 0.2.106 (failing showed "Objective update"): as the
                // native pump does, mark the timed step failed (status 3) when
                // the timer runs out, before the cooldown step replaces it.
                if ( level.bwl_lake.stage == "regrowing" && level.bwl_lake.hud_current_step == level.bwl_lake.hud_active )
                {
                    level namespace_74b2d1dbce2fe39a::function_fb3af5600f6a9441( 3, 1, level.bwl_lake.hud_current_quest, level.bwl_lake.hud_current_step );
                    nengine_store_set( "blackwater_lake", "lake_hud_status", "objective_failed" );
                    nengine_store_save( "blackwater_lake", "runtime" );
                    wait 2.5;
                }
                level namespace_74b2d1dbce2fe39a::function_fba942a1cfd85f5d( 0, 1, level.bwl_lake.hud_current_quest, level.bwl_lake.hud_current_step );
            }
            level.bwl_lake.hud_current_quest = level.bwl_lake.hud_next_quest;
            level.bwl_lake.hud_current_step = level.bwl_lake.hud_next_step;
            if ( isdefined( level.bwl_lake.hud_current_step ) )
            {
                level namespace_74b2d1dbce2fe39a::function_fba942a1cfd85f5d( 1, 1, level.bwl_lake.hud_current_quest, level.bwl_lake.hud_current_step );
                level namespace_74b2d1dbce2fe39a::function_fb3af5600f6a9441( 2, 1, level.bwl_lake.hud_current_quest, level.bwl_lake.hud_current_step );
            }
            if ( level.bwl_lake.stage == "regrowing" )
                nengine_store_set( "blackwater_lake", "lake_hud_status", level.bwl_lake.hud_cooldown_available ? "regrowth_prompt" : "regrowth_entry_unavailable" );
            else if ( level.bwl_lake.timer_running )
                nengine_store_set( "blackwater_lake", "lake_hud_status", "timed_prompt" );
            else
                nengine_store_set( "blackwater_lake", "lake_hud_status", "setup_prompt" );
            nengine_store_save( "blackwater_lake", "runtime" );
        }
        if ( level.bwl_lake.timer_running && isdefined( level.bwl_lake.hud_current_step ) &&
            level.bwl_lake.hud_current_step == level.bwl_lake.hud_active )
        {
            level.bwl_lake.hud_milliseconds = level.bwl_lake.timer_deadline - gettime();
            if ( level.bwl_lake.hud_milliseconds < 0 )
                level.bwl_lake.hud_milliseconds = 0;
            if ( level.bwl_lake.stage == "pustules" )
                level.bwl_lake.hud_percent = 20 + 80.0 * level.bwl_lake.remaining / level.bwl_lake.count;
            else
                level.bwl_lake.hud_percent = 20.0 * level.bwl_lake.core_health / level.bwl_lake.core_health_max;
            if ( level.bwl_lake.hud_percent < 0 )
                level.bwl_lake.hud_percent = 0;
            level namespace_74b2d1dbce2fe39a::function_612a9ad0db22c29c( level.bwl_lake.hud_milliseconds, 1, level.bwl_lake.hud_quest, level.bwl_lake.hud_active );
            level namespace_74b2d1dbce2fe39a::function_9f49b2a045ece8ae( int( level.bwl_lake.hud_percent ), 1, level.bwl_lake.hud_quest, level.bwl_lake.hud_active );
        }
        wait 0.25;
    }
    // Show the cleared step as complete with an empty bar before removing it
    // from the queue. 0.2.106 (success showed "Objective failed"):
    // complete is status 4, as in the native quests; 3 is failed.
    if ( isdefined( level.bwl_lake.hud_current_step ) && level.bwl_lake.hud_current_step == level.bwl_lake.hud_active &&
        level.bwl_lake.stage != "fallback" )
    {
        level namespace_74b2d1dbce2fe39a::function_9f49b2a045ece8ae( 0, 1, level.bwl_lake.hud_current_quest, level.bwl_lake.hud_current_step );
        level namespace_74b2d1dbce2fe39a::function_fb3af5600f6a9441( 4, 1, level.bwl_lake.hud_current_quest, level.bwl_lake.hud_current_step );
        nengine_store_set( "blackwater_lake", "lake_hud_status", "objective_complete" );
        nengine_store_save( "blackwater_lake", "runtime" );
        wait 2.5;
    }
    if ( isdefined( level.bwl_lake.hud_current_step ) )
        level namespace_74b2d1dbce2fe39a::function_fba942a1cfd85f5d( 0, 1, level.bwl_lake.hud_current_quest, level.bwl_lake.hud_current_step );
    nengine_store_set( "blackwater_lake", "lake_hud_status", "infestation_cleared" );
    nengine_store_save( "blackwater_lake", "runtime" );
}


function bwl_lake_expose_core()
{
    level endon( #"game_ended" );
    waitframe();
    if ( level.bwl_lake.stage != "opening_core" )
        return;
    level.bwl_lake.core setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\x89\x18\x05sC\x9f\xe3" );
    level.bwl_lake.core setscriptablepartstate( "\xb7\xb5\as\xf8\xf9\xb4\x9b1", "\x9aV\x0e\x99Nu\x10\xacrW\xf9\xf3\x93\x1a\xe6\xc0" );
    level.bwl_lake.vines setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\x81\xcc\x05\xd3/\xb5\xbf" );
    bwl_lake_extra_vines( "\x81\xcc\x05\xd3/\xb5\xbf" );
    level.bwl_lake.gen setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\xa5c\x10\x1bX/\xb2\xe4\xd7\x91V\xb9:\xe4\xb7^\xb2F" );
    level.bwl_lake.gen setscriptablepartstate( "\x81\x8c\x06\x9b-O\x18\xf8", "\xb9\xf5\r\xe6:\xa5\xcd\x9d\x95\xc9}6\xde'+" );
    level.bwl_lake.transition_i = 0;
    while ( level.bwl_lake.transition_i < level.bwl_lake.pustules.size )
    {
        level.bwl_lake.pustules[ level.bwl_lake.transition_i ] setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\xb9\xdf\a\x86ZF#\x95s" );
        level.bwl_lake.transition_i = level.bwl_lake.transition_i + 1;
    }
    level.bwl_lake.transition_i = 0;
    while ( level.bwl_lake.transition_i < level.bwl_lake.cylinders.size )
    {
        level.bwl_lake.cylinders[ level.bwl_lake.transition_i ] setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\xa5c\x10\x1bX/\xb2\xe4\xd7\x91V\xb9:\xe4\xb7^\xb2F" );
        level.bwl_lake.transition_i = level.bwl_lake.transition_i + 1;
    }
    level.bwl_lake.stage = "core";
    nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
    nengine_store_set( "blackwater_lake", "lake_core_health", level.bwl_lake.core_health );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_lake_ready()
{
    level endon( #"game_ended" );
    level.bwl_lake.gen setscriptablepartstate( "\x81\x8c\x06\x9b-O\x18\xf8", "\x8e\xf3\x10\xa3\x1b##G\x88M\xef\xcb+\xd0\x0ewV\x93" );
    level.bwl_lake.gen setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\x80\x1c\b\x9e\\\xa7\x19\xddg\x02" );
    level.bwl_lake.transition_i = 0;
    while ( level.bwl_lake.transition_i < level.bwl_lake.cylinders.size )
    {
        level.bwl_lake.cylinders[ level.bwl_lake.transition_i ] setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\x80\x1c\b\x9e\\\xa7\x19\xddg\x02" );
        level.bwl_lake.transition_i = level.bwl_lake.transition_i + 1;
    }
    level.bwl_lake.core setscriptablepartstate( "\xad\x9b\x05\xc4\xdeF^", "\x84\x1d\b\xaa mZS\xd1E" );
    level.bwl_lake.vines freescriptable();
    bwl_lake_extra_vines( "free" );
    level.bwl_lake.transition_i = 0;
    while ( level.bwl_lake.transition_i < level.bwl_lake.pustules.size )
    {
        level.bwl_lake.pustules[ level.bwl_lake.transition_i ] freescriptable();
        level.bwl_lake.transition_i = level.bwl_lake.transition_i + 1;
    }
    level.bwl_lake.lever setscriptablepartstate( "\xbe\x9b\x05P\xc73\x91", "\x99m\af\xc3\xca1\xf8\xb3" );
    level.bwl_lake.stage = "lever_ready";
    nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
    nengine_store_save( "blackwater_lake", "runtime" );
    wait 4.5;
    if ( isdefined( level.bwl_lake.core ) )
        level.bwl_lake.core freescriptable();
}

function bwl_lake_lever_hint( interact, player )
{
    if ( isdefined( player ) && player.interactions_disabled )
        return level.bwl_lake.hint_none;
    if ( level.bwl_lake.stage == "lever_ready" )
        return level.bwl_lake.hint_ready;
    return level.bwl_lake.hint_none;
}

function bwl_lake_lever_use( player )
{
    level endon( #"game_ended" );
    if ( isdefined( player ) && player.interactions_disabled )
        return;
    if ( level.bwl_lake.lever_busy || level.bwl_lake.stage == "powering" || level.bwl_lake.stage == "power_on" || level.bwl_lake.stage == "fallback" )
        return;
    if ( level.bwl_lake.stage != "lever_ready" )
    {
        level.bwl_lake.lever_busy = 1;
        level.bwl_lake.lever setscriptablepartstate( "\x9f<\x0f+\x1b\x95\xc6\xa3'\xb4\xd8\xb0\xd8\xeb&\xf6\x87", "\x87\xe4\x12\x1f\v\x0e\xc9\n#\x81{\xe8\x193\xdf=/\x93\xa2\xa0" );
        wait 0.75;
        level.bwl_lake.lever_busy = 0;
        return;
    }
    level.bwl_lake.stage = "powering";
    nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
    nengine_store_save( "blackwater_lake", "runtime" );
    level.bwl_lake.lever setscriptablepartstate( "\x9f<\x0f+\x1b\x95\xc6\xa3'\xb4\xd8\xb0\xd8\xeb&\xf6\x87", "\x82\a\x03\xa5\xb0" );
    level.bwl_lake.gen setmodel( %"sat_zm_aether_energy_generator_main_on_fxanim" );
    level.bwl_lake.gen setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\xa2\xad\t\xb07\xcc\x98]\xba\xbb-" );
    level.bwl_lake.power_i = 0;
    while ( level.bwl_lake.power_i < level.bwl_lake.cylinders.size )
    {
        level.bwl_lake.cylinders[ level.bwl_lake.power_i ] setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\x82\a\x03\xa5\xb0" );
        level.bwl_lake.power_i = level.bwl_lake.power_i + 1;
    }
    wait 5;
    level namespace_60b3bdcc70f79fc6::function_36488e0e5a90d20f( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" );
    activateworldevent( "\xb7\xb2\x16\x0f\xf8>\xb4\xaa\tH\xf2-D\xc33\x7f\xc0H7\xd7\x601\xf9B" );
    level namespace_60b3bdcc70f79fc6::function_36488e0e5a90d20f( "\xa7\xd3\x10\a\xb7\xbbY9\xbe\x1b,\xd6+\xcc\x9c\xde\xe6\xa3" );
    level.bwl_lake.stage = "power_on";
    nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
    nengine_store_set( "blackwater_lake", "lake_power_on", 1 );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_lake_fallback( reason )
{
    level.bwl_lake.stage = "fallback";
    nengine_store_set( "blackwater_lake", "lake_power_fallback", reason );
    nengine_store_set( "blackwater_lake", "lake_stage", level.bwl_lake.stage );
    if ( isdefined( level.bwl_lake.gen ) )
        level.bwl_lake.gen setmodel( %"sat_zm_aether_energy_generator_main_on_fxanim" );
    if ( isdefined( level.bwl_lake.lever ) )
        level.bwl_lake.lever setscriptablepartstate( "\x9f<\x0f+\x1b\x95\xc6\xa3'\xb4\xd8\xb0\xd8\xeb&\xf6\x87", "\x82\a\x03\xa5\xb0" );
    level.bwl_lake.fail_i = 0;
    while ( level.bwl_lake.fail_i < level.bwl_lake.cylinders.size )
    {
        level.bwl_lake.cylinders[ level.bwl_lake.fail_i ] setscriptablepartstate( "\xae\a\x03\xf6\xc8", "\x82\a\x03\xa5\xb0" );
        level.bwl_lake.fail_i = level.bwl_lake.fail_i + 1;
    }
    level.bwl_lake.fail_i = 0;
    while ( level.bwl_lake.fail_i < level.bwl_lake.pustules.size )
    {
        level.bwl_lake.pustules[ level.bwl_lake.fail_i ] freescriptable();
        level.bwl_lake.fail_i = level.bwl_lake.fail_i + 1;
    }
    if ( isdefined( level.bwl_lake.core ) )
        level.bwl_lake.core freescriptable();
    if ( isdefined( level.bwl_lake.vines ) )
        level.bwl_lake.vines freescriptable();
    bwl_lake_extra_vines( "free" );
    level namespace_60b3bdcc70f79fc6::function_36488e0e5a90d20f( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" );
    activateworldevent( "\xb7\xb2\x16\x0f\xf8>\xb4\xaa\tH\xf2-D\xc33\x7f\xc0H7\xd7\x601\xf9B" );
    nengine_store_set( "blackwater_lake", "lake_power_on", 1 );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_deck_pap()
{
    level endon( #"game_ended" );
    // The lower-deck shutter is at (13609.32, 2356.21), facing 80 degrees;
    // the adjacent barbecue and deck establish the floor at z=1056. The
    // shipped cabin Speed Cola marker is (13728, 2144, 1183.5); use it as
    // an anchor, producing the same deck position as the previous build.
    // Our compiled local assignments are unreliable (0.2.23/0.2.24), so the
    // anchor, marker and machine are kept in level fields throughout.
    wait 5;
    if ( !bwl_selected() || !isdefined( level.bwl_front_spawn ) )
        return;
    level.bwl_pap_native = undefined;
    level.bwl_pap_attempt = 0;
    while ( level.bwl_pap_attempt < 12 )
    {
        level.bwl_pap_native = bwl_speed_cola_marker();
        if ( isdefined( level.bwl_pap_native ) )
            break;
        level.bwl_pap_attempt = level.bwl_pap_attempt + 1;
        wait 5;
    }
    if ( !isdefined( level.bwl_pap_native ) )
    {
        nengine_store_set( "blackwater_lake", "pap_status", "cabin_anchor_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_deck_pap = spawnstruct();
    // The 0.2.29 move 64 units out from the wall made no visible difference,
    // so the machine is back at the original deck position.
    level.bwl_deck_pap.origin = level.bwl_pap_native.origin + ( -115, 233, -127.5 );
    level.bwl_deck_pap.angles = vectortoangles( ( 0.173648, 0.984808, 0 ) );
    level.bwl_deck_pap.targetname = "bwl_deck_pap";
    level.bwl_deck_pap.name = "bwl_deck_pap";
    level.bwl_deck_pap.radius = 80;
    level.bwl_deck_pap.var_8a1bbd1390cd5db6 = "zone_lakefront";
    level.bwl_deck_pap.var_b6a23cbbca5942d8 = "packapunch_sat_zm";
    level.bwl_deck_pap.var_e502d431f3ba8706 = 1;
    level.bwl_deck_pap.var_e68d3e406ad885f7 = "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89";
    nengine_store_set( "blackwater_lake", "pap_origin", level.bwl_deck_pap.origin );
    nengine_store_set( "blackwater_lake", "pap_angles", level.bwl_deck_pap.angles );
    nengine_store_set( "blackwater_lake", "pap_model_bundle", "packapunch_sat_zm" );
    nengine_store_set( "blackwater_lake", "pap_origin_defined", isdefined( level.bwl_deck_pap.origin ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_angles_defined", isdefined( level.bwl_deck_pap.angles ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_status", "spawning_native_model" );
    nengine_store_save( "blackwater_lake", "runtime" );
    if ( !isdefined( level.bwl_deck_pap.origin ) || !isdefined( level.bwl_deck_pap.angles ) )
    {
        nengine_store_set( "blackwater_lake", "pap_status", "deck_transform_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }

    // Nuked's map entry spawns this classic model; t10_zm_pap_fxanim is only
    // its bundle name, and that bundle differs from packapunch_sat_zm in
    // nothing but the model. Nuked in game shows the
    // classic machine, so the T10 model tried in 0.2.27 is removed.
    level.bwl_pap_machine = namespace_2bf8af33322ac10f::function_66b9b0c7a4a77d6b(
        level.bwl_deck_pap, "sat_zm_pap_clean_fxanim", 1, 1 );
    nengine_store_set( "blackwater_lake", "pap_model", "sat_zm_pap_clean_fxanim" );
    nengine_store_set( "blackwater_lake", "pap_fx_status", "nuked_classic_model" );
    if ( !isdefined( level.bwl_pap_machine ) )
    {
        nengine_store_set( "blackwater_lake", "pap_status", "native_model_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_deck_pap.var_370acb837a3a86c3 = level.bwl_pap_machine;
    level.bwl_pap_machine.var_2b2422344b2c733d = namespace_167cc53cd3a6c3cc::function_870d519a9b809a9c( level.bwl_pap_machine.origin );
    nengine_store_set( "blackwater_lake", "pap_model_origin", level.bwl_pap_machine.origin );
    nengine_store_set( "blackwater_lake", "pap_menu_resolved", isdefined( level.bwl_pap_machine.var_2b2422344b2c733d ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_status", "native_model_created" );
    nengine_store_save( "blackwater_lake", "runtime" );

    // Put the raised interaction in front of the machine, clear of its collision.
    // 0.2.103 (the Open prompt reached too far; it showed from
    // the balcony and the sides): 40 units out instead of 64 (the machine's
    // front ends near 25) and radius 64 instead of 96.
    // 0.2.104 (target: just in front of the roller opening,
    // below its lip; 40 out and 48 up was still too far): 28 out, 36 up.
    level.bwl_pap_interact_origin = level.bwl_pap_machine.origin +
        anglestoforward( level.bwl_pap_machine.angles ) * 28 + ( 0, 0, 36 );
    level.bwl_pap_machine.interact = namespace_7fc982453bce8e6a::function_8120aea9aaf48bfa(
        level.bwl_pap_interact_origin, 64, &bwl_deck_pap_use, undefined, undefined, undefined,
        undefined, "\x9c\x11\fHc\xa63\xe1v\x15\xb3Ao\x86" );
    if ( isdefined( level.bwl_pap_machine.interact ) )
        nengine_store_set( "blackwater_lake", "pap_interact_placement", "front_raised" );
    else
    {
        // If the front trigger cannot be created, retain the original use.
        nengine_store_set( "blackwater_lake", "pap_interact_placement", "machine_fallback" );
        level.bwl_pap_machine.interact = namespace_7fc982453bce8e6a::function_8120aea9aaf48bfa(
        level.bwl_pap_machine, level.bwl_deck_pap.radius, &bwl_deck_pap_use, undefined, undefined, undefined,
        undefined, "\x9c\x11\fHc\xa63\xe1v\x15\xb3Ao\x86" );
    }
    if ( !isdefined( level.bwl_pap_machine.interact ) )
    {
        nengine_store_set( "blackwater_lake", "pap_status", "native_interaction_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_pap_machine.interact namespace_7fc982453bce8e6a::function_316e9b54139e4683(
        &namespace_167cc53cd3a6c3cc::function_12c315c07c36db97 );
    level.bwl_pap_machine.interact setusefov( 130 );
    level.bwl_pap_machine.interact.var_9f9432741e058419 = level.bwl_deck_pap;
    level.bwl_pap_machine.interact.var_ed181a9a078b70e1 = level.bwl_deck_pap;
    level.bwl_pap_machine.interact setusableenabled( 1 );
    nengine_store_set( "blackwater_lake", "pap_interact_origin", level.bwl_pap_machine.interact.origin );
    if ( !isdefined( level.var_db52bcfd04d45a7a ) )
        level.var_db52bcfd04d45a7a = [];
    level.var_db52bcfd04d45a7a = arraycombineunique( level.var_db52bcfd04d45a7a, [ level.bwl_deck_pap ] );
    nengine_store_set( "blackwater_lake", "pap_status", "native_interaction_registered" );
    nengine_store_save( "blackwater_lake", "runtime" );

    // Wait for the model's scriptable, then let the native routine wait for
    // power_on1 and play the ordinary animated power-on.
    level.bwl_pap_frames = 0;
    while ( !level.bwl_pap_machine namespace_60b3bdcc70f79fc6::function_de1f80d93273abf5() && level.bwl_pap_frames < 40 )
    {
        level.bwl_pap_frames = level.bwl_pap_frames + 1;
        waitframe();
    }
    nengine_store_set( "blackwater_lake", "pap_scriptable", level.bwl_pap_machine namespace_60b3bdcc70f79fc6::function_de1f80d93273abf5() ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_scriptable_frames", level.bwl_pap_frames );
    level.bwl_deck_pap thread namespace_167cc53cd3a6c3cc::function_6bef4f03bfe01f85();
    nengine_store_set( "blackwater_lake", "pap_status", "waiting_for_lake_power" );
    nengine_store_save( "blackwater_lake", "runtime" );
    level.bwl_deck_pap thread bwl_pap_native_setup( level.bwl_pap_machine );
    level thread bwl_deck_pap_power_check();
}

function bwl_deck_pap_power_check()
{
    // Read-only: allow the native animated power-on time to finish.
    level endon( #"game_ended" );
    level namespace_60b3bdcc70f79fc6::function_fb7b1af19016b7f4( "\xa5\xcb\n\a\xde\xbbY9\xd7\xbd\xb9\x89" );
    wait 6;
    nengine_store_set( "blackwater_lake", "pap_power_a", level.bwl_pap_machine namespace_60b3bdcc70f79fc6::function_9f2c41c1dcc8c94( "\xbe\x9b\x05P\xc73\x91", "\x81\xb0\t '\xd0vK\xd2\x955" ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_power_b", level.bwl_pap_machine namespace_60b3bdcc70f79fc6::function_9f2c41c1dcc8c94( "\x85\x98\r[K\xb9-\xad\x16\x83\xfa\xb4\xc6\xed7", "\x8b\v\aI\xb7\xa4b\xe0\xef" ) ? 1 : 0 );
    nengine_store_set( "blackwater_lake", "pap_status", "power_check_completed" );
    nengine_store_save( "blackwater_lake", "runtime" );
    level thread bwl_pap_power_look();
    level thread bwl_pap_blue_light();
    level thread bwl_pap_blue_sides();
    level thread bwl_pap_light_watch();
}

// 0.2.74: a very dim blue light inside the PaP roller
// section. The Firefly blue trail effect has one light, RGB (0.31, 0.61, 1),
// size 60, with no occlusion query, plus tiny sparkles within 5 units and
// trails that only draw while moving. Its cup anchor sits inside the middle
// roller (model roller axis 6.7 forward and 24.7 up from the origin), so the
// roller hides the cup and sparkles while the light shines across the rollers.
// The global FX-light scale (0.15) dims it too. The yellow light is untouched.
function bwl_pap_blue_light()
{
    level endon( #"game_ended" );
    if ( !isdefined( level.bwl_pap_machine ) )
        return;
    if ( !isdefined( level.bwl_pap_blue_fx ) )
    {
        nengine_store_set( "blackwater_lake", "pap_blue_status", "not_loaded" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_pap_blue_spot = spawnstruct();
    level.bwl_pap_blue_spot.origin = level.bwl_pap_machine.origin +
        anglestoforward( level.bwl_pap_machine.angles ) * 6.7 + ( 0, 0, 22.7 );
    level.bwl_pap_blue_spot.angles = level.bwl_pap_machine.angles;
    level.bwl_pap_blue_anchor = namespace_2bf8af33322ac10f::function_66b9b0c7a4a77d6b(
        level.bwl_pap_blue_spot, "food_trash_cup_soda_lrg_01a", 0, 1 );
    if ( !isdefined( level.bwl_pap_blue_anchor ) )
    {
        nengine_store_set( "blackwater_lake", "pap_blue_status", "anchor_failed" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_pap_blue_anchor notsolid();
    if ( level.bwl_pap_blue_anchor tagexists( "tag_origin" ) )
    {
        playfxontag( level.bwl_pap_blue_fx, level.bwl_pap_blue_anchor, "tag_origin" );
        bwl_pap_track_cup( level.bwl_pap_blue_anchor );
        nengine_store_set( "blackwater_lake", "pap_blue_status", "roller_requested" );
        nengine_store_set( "blackwater_lake", "pap_blue_anchor_origin", level.bwl_pap_blue_anchor.origin );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_pap_blue_anchor delete();
    nengine_store_set( "blackwater_lake", "pap_blue_status", "tag_missing" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// The working yellow light was attached to the machine's floor-level origin.
// A small, non-solid model inside the machine carries the same light higher.
// If that anchor or its tag is unavailable, retain the working base light.
function bwl_pap_power_look()
{
    level endon( #"game_ended" );
    if ( !isdefined( level.bwl_pap_machine ) )
        return;
    if ( !isdefined( level.bwl_pap_light_fx ) )
    {
        nengine_store_set( "blackwater_lake", "pap_light_status", "not_loaded" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_pap_light_spot = spawnstruct();
    level.bwl_pap_light_spot.origin = level.bwl_pap_machine.origin + ( 0, 0, 73 );
    level.bwl_pap_light_spot.angles = level.bwl_pap_machine.angles;
    level.bwl_pap_light_anchor = namespace_2bf8af33322ac10f::function_66b9b0c7a4a77d6b(
        level.bwl_pap_light_spot, "food_trash_cup_soda_lrg_01a", 0, 1 );
    if ( isdefined( level.bwl_pap_light_anchor ) )
    {
        level.bwl_pap_light_anchor notsolid();
        if ( level.bwl_pap_light_anchor tagexists( "tag_origin" ) )
        {
            bwl_pap_light_play( level.bwl_pap_light_anchor );
            bwl_pap_track_cup( level.bwl_pap_light_anchor );
            level thread bwl_pap_fx_dim();
            nengine_store_set( "blackwater_lake", "pap_light_status", "raised_tag_requested" );
            nengine_store_set( "blackwater_lake", "pap_light_anchor_origin", level.bwl_pap_light_anchor.origin );
            nengine_store_save( "blackwater_lake", "runtime" );
            return;
        }
        level.bwl_pap_light_anchor delete();
    }
    if ( level.bwl_pap_machine tagexists( "tag_origin" ) )
    {
        bwl_pap_light_play( level.bwl_pap_machine );
        level thread bwl_pap_fx_dim();
        nengine_store_set( "blackwater_lake", "pap_light_status", "machine_tag_fallback" );
    }
    else
        nengine_store_set( "blackwater_lake", "pap_light_status", "machine_tag_missing" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// 0.2.91 (after noclip and the return to the map the lights were gone;
// runtime boundary_return=1). Effects attached to the light cups were lost and
// never came back, yellow and blue alike. Every PaP light cup is tracked so the
// lights can be rebuilt exactly as at power-on: deleting the old cups first
// keeps effects from doubling if they had in fact survived.
function bwl_pap_track_cup( cup )
{
    if ( !isdefined( level.bwl_pap_light_cups ) )
        level.bwl_pap_light_cups = [];
    level.bwl_pap_light_cups[ level.bwl_pap_light_cups.size ] = cup;
}

// Once a second: a player more than 1500 units away (beyond the lights' 1300
// spawn range) or jumping more than 600 units in a second (noclip flight or a
// boundary teleport) marks the lights as possibly lost. When no player is far
// any more and one is within 1000 units, rebuild them once.
function bwl_pap_light_watch()
{
    level endon( #"game_ended" );
    level.bwl_pap_watch_away = 0;
    level.bwl_pap_light_rebuilds = 0;
    while ( isdefined( level.bwl_pap_machine ) )
    {
        wait 1;
        level.bwl_pap_watch_far = 0;
        level.bwl_pap_watch_near = 0;
        level.bwl_pap_watch_i = 0;
        while ( level.bwl_pap_watch_i < level.players.size )
        {
            level.bwl_pap_watch_player = level.players[ level.bwl_pap_watch_i ];
            if ( isdefined( level.bwl_pap_watch_player ) )
            {
                if ( isdefined( level.bwl_pap_watch_player.bwl_pap_last_origin ) &&
                     distancesquared( level.bwl_pap_watch_player.origin, level.bwl_pap_watch_player.bwl_pap_last_origin ) > 360000 )
                    level.bwl_pap_watch_far = 1;
                if ( distancesquared( level.bwl_pap_watch_player.origin, level.bwl_pap_machine.origin ) > 2250000 )
                    level.bwl_pap_watch_far = 1;
                else if ( distancesquared( level.bwl_pap_watch_player.origin, level.bwl_pap_machine.origin ) < 1000000 )
                    level.bwl_pap_watch_near = 1;
                level.bwl_pap_watch_player.bwl_pap_last_origin = level.bwl_pap_watch_player.origin;
            }
            level.bwl_pap_watch_i = level.bwl_pap_watch_i + 1;
        }
        if ( level.bwl_pap_watch_far )
            level.bwl_pap_watch_away = 1;
        else if ( level.bwl_pap_watch_away && level.bwl_pap_watch_near )
        {
            level.bwl_pap_watch_away = 0;
            bwl_pap_light_rebuild();
        }
    }
}

function bwl_pap_light_rebuild()
{
    if ( isdefined( level.bwl_pap_light_cups ) )
    {
        level.bwl_pap_clear_i = 0;
        while ( level.bwl_pap_clear_i < level.bwl_pap_light_cups.size )
        {
            if ( isdefined( level.bwl_pap_light_cups[ level.bwl_pap_clear_i ] ) )
                level.bwl_pap_light_cups[ level.bwl_pap_clear_i ] delete();
            level.bwl_pap_clear_i = level.bwl_pap_clear_i + 1;
        }
    }
    level.bwl_pap_light_cups = [];
    waitframe();
    level.bwl_pap_light_rebuilds = level.bwl_pap_light_rebuilds + 1;
    nengine_store_set( "blackwater_lake", "pap_light_rebuilds", level.bwl_pap_light_rebuilds );
    bwl_pap_power_look();
    bwl_pap_blue_light();
    bwl_pap_blue_sides();
    nengine_store_save( "blackwater_lake", "runtime" );
}

// 0.2.83: reuse the already visible blue effect from inside the middle roller.
// Two more anchors lie inside the outer roller centres (left +/-18.7). Their
// spheres can reach the marked side panels and upper lip; this also increases
// blue spill and brightness, which has to be checked in game.
function bwl_pap_blue_sides()
{
    level endon( #"game_ended" );
    if ( !isdefined( level.bwl_pap_machine ) || !isdefined( level.bwl_pap_blue_fx ) )
    {
        nengine_store_set( "blackwater_lake", "pap_blue_side_status", "not_available" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_pap_blue_side_count = 0;
    bwl_pap_blue_side( -18.7 );
    bwl_pap_blue_side( 18.7 );
    // 0.2.102 (the same blue light on the
    // green inner side walls): the same blue at the outer ends of the outer
    // rollers, still hidden inside them, right next to each side wall.
    bwl_pap_blue_side( -22.5 );
    bwl_pap_blue_side( 22.5 );
    nengine_store_set( "blackwater_lake", "pap_blue_side_count", level.bwl_pap_blue_side_count );
    nengine_store_set( "blackwater_lake", "pap_blue_side_status", level.bwl_pap_blue_side_count == 4 ? "rollers_and_walls_requested" : "partial_or_no_points" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_pap_blue_side( left )
{
    level.bwl_pap_blue_side_spot = spawnstruct();
    level.bwl_pap_blue_side_spot.origin = level.bwl_pap_machine.origin +
        anglestoforward( level.bwl_pap_machine.angles ) * 6.7 +
        anglestoforward( level.bwl_pap_machine.angles + ( 0, 90, 0 ) ) * left + ( 0, 0, 22.7 );
    level.bwl_pap_blue_side_spot.angles = level.bwl_pap_machine.angles;
    level.bwl_pap_blue_side_anchor = namespace_2bf8af33322ac10f::function_66b9b0c7a4a77d6b(
        level.bwl_pap_blue_side_spot, "food_trash_cup_soda_lrg_01a", 0, 1 );
    if ( !isdefined( level.bwl_pap_blue_side_anchor ) )
        return;
    level.bwl_pap_blue_side_anchor notsolid();
    if ( level.bwl_pap_blue_side_anchor tagexists( "tag_origin" ) )
    {
        playfxontag( level.bwl_pap_blue_fx, level.bwl_pap_blue_side_anchor, "tag_origin" );
        bwl_pap_track_cup( level.bwl_pap_blue_side_anchor );
        level.bwl_pap_blue_side_count = level.bwl_pap_blue_side_count + 1;
        return;
    }
    level.bwl_pap_blue_side_anchor delete();
}

// 0.2.72: the PaP light made yellow, same position and brightness.
// The "yellow" field-trap light is orange-red in game, RGB (1, 0.47, 0). 0.2.71's
// two red plus one green still looked orange-red and brighter: the lit logs are
// red-brown and turn warm light orange. The same two emitters in green
// (0.08, 1, 0), added once to the orange on the same tag, give the most green
// these lights allow, about (1.08, 1.47, 0). If green failed to load, play the
// original light unchanged.
function bwl_pap_light_play( anchor )
{
    if ( isdefined( level.bwl_pap_light_green_fx ) )
    {
        playfxontag( level.bwl_pap_light_fx, anchor, "tag_origin" );
        playfxontag( level.bwl_pap_light_green_fx, anchor, "tag_origin" );
        nengine_store_set( "blackwater_lake", "pap_light_color", "yellow_mix_orange_green" );
        return;
    }
    playfxontag( level.bwl_pap_light_fx, anchor, "tag_origin" );
    nengine_store_set( "blackwater_lake", "pap_light_color", "original_orange" );
}

// Dim VFX lights for this Blackwater match only, after the PaP glow starts.
// This global scale can affect other VFX lights.
// Restore the saved value on the game-ended event if it is still our setting.
function bwl_pap_fx_dim()
{
    if ( isdefined( level.bwl_pap_fx_dim_started ) )
        return;
    level.bwl_pap_fx_dim_started = 1;
    level.bwl_pap_fx_dim_original = getdvarfloat( @"fx_lights_intensity_scale", -1.0 );
    nengine_store_set( "blackwater_lake", "pap_fx_dim_original", level.bwl_pap_fx_dim_original );
    if ( level.bwl_pap_fx_dim_original <= 0 )
    {
        nengine_store_set( "blackwater_lake", "pap_fx_dim_status", "unavailable" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    // 0.2.72 (dimmed globally to ~0.22): orange plus green is about
    // 2.3 times the 0.2.70 light, so the scale drops from half to 0.22.
    // 0.2.73 (yellow kept, lighting dimmed a bit more): 0.15.
    // 0.2.75: a 0.2.74 runtime read original 0.15 (the game_ended restore never
    // ran), so the scale compounded to 0.0225. A fixed target cannot compound.
    level.bwl_pap_fx_dim_target = 0.15;
    setdvar( @"fx_lights_intensity_scale", level.bwl_pap_fx_dim_target );
    level.bwl_pap_fx_dim_after = getdvarfloat( @"fx_lights_intensity_scale", -1.0 );
    nengine_store_set( "blackwater_lake", "pap_fx_dim_target", level.bwl_pap_fx_dim_target );
    nengine_store_set( "blackwater_lake", "pap_fx_dim_after", level.bwl_pap_fx_dim_after );
    if ( level.bwl_pap_fx_dim_after < level.bwl_pap_fx_dim_target - 0.001 ||
         level.bwl_pap_fx_dim_after > level.bwl_pap_fx_dim_target + 0.001 )
    {
        if ( level.bwl_pap_fx_dim_after >= 0 )
            setdvar( @"fx_lights_intensity_scale", level.bwl_pap_fx_dim_original );
        nengine_store_set( "blackwater_lake", "pap_fx_dim_status", "not_applied" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    nengine_store_set( "blackwater_lake", "pap_fx_dim_status", "applied" );
    nengine_store_save( "blackwater_lake", "runtime" );
    level waittill( #"game_ended" );
    level.bwl_pap_fx_dim_current = getdvarfloat( @"fx_lights_intensity_scale", -1.0 );
    if ( level.bwl_pap_fx_dim_current >= level.bwl_pap_fx_dim_target - 0.001 &&
         level.bwl_pap_fx_dim_current <= level.bwl_pap_fx_dim_target + 0.001 )
    {
        setdvar( @"fx_lights_intensity_scale", level.bwl_pap_fx_dim_original );
        nengine_store_set( "blackwater_lake", "pap_fx_dim_status", "restore_requested" );
    }
    else
        nengine_store_set( "blackwater_lake", "pap_fx_dim_status", "changed_elsewhere" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// 0.2.115: Firefly's animated PaP puts the return behind its machine.  Only
// recognize a matched preview/return from the Blackwater deck PaP in the
// active Cursed Mayhem session.  Keep the native weapon and ownership.
function bwl_pap_return_mayhem_active()
{
    return bwl_selected() && isdefined( level.var_7d6dd80d20d65e17 ) &&
        isdefined( level.var_7d6dd80d20d65e17.active ) && level.var_7d6dd80d20d65e17.active &&
        isdefined( level.var_7ebad24685cd9f8c ) &&
        isdefined( level.var_7ebad24685cd9f8c.var_2a42ba6a1a4e260d ) &&
        level.var_7ebad24685cd9f8c.var_2a42ba6a1a4e260d;
}

function bwl_pap_return_register()
{
    level endon( #"game_ended" );
    level.bwl_pap_return_wait = 0;
    while ( !isdefined( level.var_721d42b2281bab28 ) && level.bwl_pap_return_wait < 600 )
    {
        wait 0.1;
        level.bwl_pap_return_wait++;
    }
    if ( !isdefined( level.var_721d42b2281bab28 ) )
    {
        nengine_store_set( "blackwater_lake", "pap_return_status", "item_registry_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    namespace_49c55e3e8683c53f::function_9c9e4c71569f3ae8( &bwl_pap_return_item );
    nengine_store_set( "blackwater_lake", "pap_return_status", "watching" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_pap_return_begin( params )
{
    if ( !bwl_pap_return_mayhem_active() || !isdefined( self ) || !isplayer( self ) ||
         !isdefined( self.var_73e2de392faa52c6 ) || !self.var_73e2de392faa52c6 ||
         !isdefined( level.bwl_pap_machine ) || !isdefined( level.bwl_pap_machine.origin ) ||
         !isdefined( level.bwl_pap_machine.angles ) || !isdefined( params ) ||
         !isdefined( params.spawnoptions ) || !isdefined( params.spawnoptions.weapon ) ||
         !params.spawnoptions.var_8d4f327170228364 || !params.spawnoptions.var_9161cf0784b6951d ||
         params.spawnoptions.var_4b7b74e325a723b6 != 1 || !isdefined( params.spawnoptions.baseorigin ) )
        return;
    // Native Firefly's preview and return are about 140 units behind the
    // machine. Do not act on a different machine, a box item or a floor drop.
    if ( distancesquared( params.spawnoptions.baseorigin, level.bwl_pap_machine.origin ) > 40000 )
        return;
    if ( params.spawnoptions.var_8bb8a5f40b911466 )
    {
        if ( distancesquared( self.origin, level.bwl_pap_machine.origin ) > 25600 )
            return;
        self.bwl_pap_preview_buyer_origin = self.origin;
        self.bwl_pap_preview_origin = params.spawnoptions.baseorigin;
        self.bwl_pap_preview_time = gettime();
        self.bwl_pap_preview_carrier = undefined;
        params.spawnoptions.bwl_pap_preview_buyer = self;
        params.spawnoptions.bwl_pap_preview_time = self.bwl_pap_preview_time;
        nengine_store_set( "blackwater_lake", "pap_return_status", "preview_seen" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    if ( !isdefined( self.bwl_pap_preview_time ) || !isdefined( self.bwl_pap_preview_origin ) ||
         !isdefined( self.bwl_pap_preview_buyer_origin ) )
        return;
    if ( gettime() - self.bwl_pap_preview_time < 0 || gettime() - self.bwl_pap_preview_time > 60000 ||
         distancesquared( params.spawnoptions.baseorigin, self.bwl_pap_preview_origin ) > 16384 )
    {
        self.bwl_pap_preview_time = undefined;
        return;
    }
    self.bwl_pap_return_forward = anglestoforward( ( 0, level.bwl_pap_machine.angles[ 1 ], 0 ) );
    self.bwl_pap_return_depth =
        ( self.bwl_pap_preview_buyer_origin[ 0 ] - params.spawnoptions.baseorigin[ 0 ] ) * self.bwl_pap_return_forward[ 0 ] +
        ( self.bwl_pap_preview_buyer_origin[ 1 ] - params.spawnoptions.baseorigin[ 1 ] ) * self.bwl_pap_return_forward[ 1 ];
    self.bwl_pap_return_side =
        ( self.bwl_pap_preview_buyer_origin[ 0 ] - params.spawnoptions.baseorigin[ 0 ] ) * self.bwl_pap_return_forward[ 1 ] -
        ( self.bwl_pap_preview_buyer_origin[ 1 ] - params.spawnoptions.baseorigin[ 1 ] ) * self.bwl_pap_return_forward[ 0 ];
    if ( self.bwl_pap_return_depth <= 120 || self.bwl_pap_return_depth >= 300 ||
         self.bwl_pap_return_side * self.bwl_pap_return_side >= 6400 )
    {
        self.bwl_pap_preview_time = undefined;
        return;
    }
    params.spawnoptions.bwl_pap_return_buyer = self;
    self.bwl_pap_return_target = params.spawnoptions.baseorigin + self.bwl_pap_return_forward * 163 + ( 0, 0, 3 );
    nengine_store_set( "blackwater_lake", "pap_return_native_origin", params.spawnoptions.baseorigin );
    nengine_store_set( "blackwater_lake", "pap_return_target", self.bwl_pap_return_target );
    // If the preview's carrier is already known, native creates and links the
    // return in front immediately; otherwise the spawned-item watcher repairs it.
    if ( isdefined( self.bwl_pap_preview_carrier ) && isdefined( self.bwl_pap_preview_carrier.origin ) &&
         distancesquared( self.bwl_pap_preview_carrier.origin, params.spawnoptions.baseorigin ) <= 4 )
    {
        self.bwl_pap_preview_carrier unlink();
        self.bwl_pap_preview_carrier.origin = self.bwl_pap_return_target;
        params.spawnoptions.baseorigin = self.bwl_pap_return_target;
        nengine_store_set( "blackwater_lake", "pap_return_status", "spawn_set_in_front" );
    }
    else
        nengine_store_set( "blackwater_lake", "pap_return_status", "return_tagged" );
    self.bwl_pap_preview_time = undefined;
    self.bwl_pap_preview_carrier = undefined;
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_pap_return_item( params )
{
    if ( !bwl_pap_return_mayhem_active() || !isdefined( params ) ||
         !isdefined( params.item ) || !isdefined( params.spawnoptions ) )
        return;
    if ( isdefined( params.spawnoptions.bwl_pap_preview_buyer ) &&
         isdefined( params.spawnoptions.bwl_pap_preview_time ) )
    {
        level thread bwl_pap_capture_carrier( params.item, params.spawnoptions.bwl_pap_preview_buyer,
            params.spawnoptions.bwl_pap_preview_time );
        return;
    }
    if ( isdefined( params.spawnoptions.bwl_pap_return_buyer ) )
        level thread bwl_pap_return_watch( params.item );
}

function bwl_pap_capture_carrier( item, buyer, preview_time )
{
    waittillframeend();
    if ( !isdefined( item ) || !isdefined( buyer ) )
        return;
    buyer.bwl_pap_preview_wait = 0;
    while ( isdefined( item ) && isdefined( buyer ) &&
            isdefined( buyer.bwl_pap_preview_time ) && buyer.bwl_pap_preview_time == preview_time &&
            buyer.bwl_pap_preview_wait < 60 )
    {
        if ( isdefined( item.var_1328f4e72fb3c3b7 ) )
        {
            buyer.bwl_pap_preview_carrier = item.var_1328f4e72fb3c3b7;
            return;
        }
        buyer.bwl_pap_preview_wait++;
        waitframe();
    }
}

function bwl_pap_return_watch( item )
{
    if ( !isdefined( item ) )
        return;
    item.bwl_pap_return_wait = 0;
    while ( isdefined( item ) && !isdefined( item.var_1328f4e72fb3c3b7 ) && item.bwl_pap_return_wait < 30 )
    {
        waitframe();
        if ( !isdefined( item ) )
            return;
        item.bwl_pap_return_wait++;
    }
    if ( !isdefined( item ) || !isdefined( level.bwl_pap_machine ) ||
         !isdefined( level.bwl_pap_machine.origin ) || !isdefined( level.bwl_pap_machine.angles ) )
        return;
    if ( !isdefined( item.var_1328f4e72fb3c3b7 ) )
    {
        nengine_store_set( "blackwater_lake", "pap_return_status", "carrier_missing" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    item.bwl_pap_return_forward = anglestoforward( ( 0, level.bwl_pap_machine.angles[ 1 ], 0 ) );
    item.bwl_pap_return_depth =
        ( item.origin[ 0 ] - level.bwl_pap_machine.origin[ 0 ] ) * item.bwl_pap_return_forward[ 0 ] +
        ( item.origin[ 1 ] - level.bwl_pap_machine.origin[ 1 ] ) * item.bwl_pap_return_forward[ 1 ];
    nengine_store_set( "blackwater_lake", "pap_return_depth", item.bwl_pap_return_depth );
    nengine_store_set( "blackwater_lake", "pap_return_origin_before", item.origin );
    if ( item.bwl_pap_return_depth >= 0 && item.bwl_pap_return_depth <= 80 )
    {
        level.bwl_pap_return_count++;
        nengine_store_set( "blackwater_lake", "pap_return_count", level.bwl_pap_return_count );
        nengine_store_set( "blackwater_lake", "pap_return_status", "front_spawn_confirmed" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    if ( item.bwl_pap_return_depth <= -220 || item.bwl_pap_return_depth >= -80 )
    {
        nengine_store_set( "blackwater_lake", "pap_return_status", "unexpected_depth_preserved" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    item.bwl_pap_return_carrier = item.var_1328f4e72fb3c3b7;
    item.bwl_pap_return_target = item.origin + item.bwl_pap_return_forward * 163 + ( 0, 0, 3 );
    nengine_store_set( "blackwater_lake", "pap_return_target", item.bwl_pap_return_target );
    nengine_store_set( "blackwater_lake", "pap_return_status", "moving_carrier" );
    nengine_store_save( "blackwater_lake", "runtime" );
    item.bwl_pap_return_carrier unlink();
    item.bwl_pap_return_carrier function_76f2d24725300b2a( item.bwl_pap_return_target, 0.05 );
    wait 0.15;
    if ( !isdefined( item ) || !isdefined( item.bwl_pap_return_carrier ) )
        return;
    item namespace_60b3bdcc70f79fc6::function_dc59c25c0d5dee10();
    item namespace_60b3bdcc70f79fc6::function_56905463b80f128d( item.bwl_pap_return_carrier );
    level.bwl_pap_return_count++;
    nengine_store_set( "blackwater_lake", "pap_return_count", level.bwl_pap_return_count );
    nengine_store_set( "blackwater_lake", "pap_return_origin_after", item.origin );
    nengine_store_set( "blackwater_lake", "pap_return_status", "carrier_relinked" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_pap_native_setup( machine )
{
    // The native initializer also gives the PaP part its region setup.
    // Keep this isolated from the already-working purchase interaction.
    namespace_60b3bdcc70f79fc6::function_81557bcd4ddf6a05(
        #"hash_e69dbe0110e4d52e", #"hash_10d5e3bb8a551724", machine,
        "\x85\x98\r[K\xb9-\xad\x16\x83\xfa\xb4\xc6\xed7", 0 );
    nengine_store_set( "blackwater_lake", "pap_native_setup", "requested" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_deck_pap_use( player )
{
    if ( !bwl_selected() )
        return;
    nengine_store_set( "blackwater_lake", "pap_use_callback", 1 );
    nengine_store_save( "blackwater_lake", "runtime" );
    self namespace_167cc53cd3a6c3cc::function_8ff137553260336f( player );
}

function bwl_front_of_house()
{
    result = spawnstruct();
    start = level.bwl_front_spawn;
    result.origin = start.origin;
    result.outward = anglestoforward( start.angles ) * -1;
    result.outward = vectornormalize( ( result.outward[ 0 ], result.outward[ 1 ], 0 ) );
    result.source = "native_lakefront_spawn";
    nearest = 999999999;
    // Survival can skip door purchases entirely, leaving a_s_doorbuys empty.
    // The authored cabin marker remains in the native struct index.
    candidates = bwl_structs( "cabin_db", "targetname" );
    candidates = arraycombineunique( candidates, bwl_structs( "cabin_db", "script_noteworthy" ) );
    candidates = arraycombineunique( candidates,
        bwl_structs( "doorbuy_lakefront_cabin_bought", "script_flag_set" ) );
    // The purchased-door record survives when its minimap ping is removed.
    // Its interact/sub-door origins give a native anchor at the cabin front.
    if ( isdefined( level.a_s_doorbuys ) )
        candidates = arraycombineunique( candidates, level.a_s_doorbuys );

    for ( i = 0; i < candidates.size; i++ )
    {
        door = candidates[ i ];
        if ( door.script_flag_set != "doorbuy_lakefront_cabin_bought" &&
            door.script_noteworthy != "cabin_db" && door.targetname != "cabin_db" )
            continue;
        candidate = undefined;
        if ( isdefined( door.origin ) )
            candidate = door.origin;
        else if ( isdefined( door.interact.origin ) )
            candidate = door.interact.origin;
        else if ( isdefined( door.interact.doors[ 0 ].origin ) )
            candidate = door.interact.doors[ 0 ].origin;
        if ( !isdefined( candidate ) )
            continue;
        separation = distancesquared( start.origin, candidate );
        if ( separation >= nearest )
            continue;
        outward = start.origin - candidate;
        outward = ( outward[ 0 ], outward[ 1 ], 0 );
        if ( length( outward ) < 32 )
            continue;
        nearest = separation;
        result.origin = candidate;
        result.outward = vectornormalize( outward );
        result.source = "native_cabin_front_door";
    }
    result.side = ( result.outward[ 1 ] * -1, result.outward[ 0 ], 0 );
    // Clear the stair-side snowbank seen in 0.2.
    // The nose faces the cabin; the rear PaP faces the open yard.
    result.truck_origin = bwl_ground( result.origin + result.outward * 620 );
    result.truck_angles = vectortoangles( result.outward * -1 );
    return result;
}

function bwl_ground( proposed )
{
    // BO7 physicstrace returns the hit position directly (not a BO3 trace map).
    hit = physicstrace( proposed + ( 0, 0, 256 ), proposed - ( 0, 0, 1024 ) );
    if ( isdefined( hit ) && hit[ 2 ] > proposed[ 2 ] - 900 )
        return hit + ( 0, 0, 4 );
    return proposed;
}

function bwl_pap_truck( placement )
{
    // Use the actual shipped PaP composite, not the plain base truck. Its
    // child list includes veh_sat_wc_truck_pluto_pap_attach (verified offline).
    asset = %"hash_62a07b56f29782f5";
    if ( !namespace_4405f49908c9f83e::function_496007c7bc197ad2( asset ) )
        namespace_4405f49908c9f83e::function_5300c9f6397abc02( asset );
    data = spawnstruct();
    data.origin = placement.truck_origin;
    data.angles = placement.truck_angles;
    data.targetname = "bwl_pap_truck";
    data.script_vehiclebundle = asset;
    data.script_modelname = %"xcomp_veh_sat_wc_truck_pluto_pap";
    data.script_godmode = 1;
    failure = spawnstruct();
    truck = namespace_4405f49908c9f83e::function_ac1de876a784eb7b( asset, data, failure );
    if ( !isdefined( truck ) )
    {
        nengine_store_set( "blackwater_lake", "truck_status", "native_spawn_failed" );
        nengine_store_set( "blackwater_lake", "truck_failure", failure.fail ?? "not_reported" );
        nengine_store_save( "blackwater_lake", "runtime" );
        return;
    }
    level.bwl_pap_truck = truck;
    namespace_77161734a39a9f49::function_6639b0395ddfe1b( truck, 0 );
    truck vehphys_parkingbrake( 1 );
    nengine_store_set( "blackwater_lake", "truck_status", "spawned_parked" );
    nengine_store_set( "blackwater_lake", "truck_origin", truck.origin );
    nengine_store_set( "blackwater_lake", "truck_angles", truck.angles );
    nengine_store_set( "blackwater_lake", "truck_model", "xcomp_veh_sat_wc_truck_pluto_pap" );
    // A base/composite vehicle has no linked scriptable in this Survival POI.
    // Create and register the native invisible PaP interaction directly.
    truck bwl_activate_truck_pap();
    nengine_store_set( "blackwater_lake", "pap_menu_resolved", isdefined( truck.var_2b2422344b2c733d ) ? 1 : 0 );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_activate_truck_pap()
{
    // Preserve the native attachment transform from pluto_upgrades.gsc.
    origin = self.origin + rotatevector( ( -134, 0, 26 ), self.angles );
    self.pap_sbl = spawnscriptable( %"veh_sat_firefly_pluto_pap_part_invisible",
        origin, self.angles + ( 0, 180, 0 ) );
    if ( !isdefined( self.pap_sbl ) )
    {
        nengine_store_set( "blackwater_lake", "pap_status", "native_interaction_spawn_failed" );
        return;
    }
    self.pap_sbl namespace_60b3bdcc70f79fc6::function_56905463b80f128d( self, ( -134, 0, 26 ), ( 0, 180, 0 ) );
    self.pap_sbl.interact = namespace_7fc982453bce8e6a::function_2558ae94964fd952(
        self.pap_sbl, &bwl_truck_pap_use );
    self.pap_sbl.interact namespace_7fc982453bce8e6a::function_316e9b54139e4683(
        &namespace_167cc53cd3a6c3cc::function_12c315c07c36db97 );
    self.var_370acb837a3a86c3 = self.pap_sbl;
    self.var_ed181a9a078b70e1 = self;
    self.var_2b2422344b2c733d = namespace_167cc53cd3a6c3cc::function_870d519a9b809a9c( self.origin );
    self.pap_sbl.var_ed181a9a078b70e1 = self;
    self.pap_sbl.var_2b2422344b2c733d = self.var_2b2422344b2c733d;
    self.pap_sbl namespace_60b3bdcc70f79fc6::function_7c10ea82c1e305b8(
        "\x93\x97\v\xd3\xf67)\xad*\xd95$\x97", "\x83?\bp\x80\xdbQ\x95\\\x05" );
    // Same client availability state and zombie callback as the native truck.
    setomnvar( "\x85\x89\x1a\vky@Uk\x11_\xf7:\x03\xef\xbf6`\xa7\xcd\xe5\x85\x87\xd9\xbd\x9a\x1f\xd4", 1 );
    self.pap_sbl namespace_60b3bdcc70f79fc6::function_81557bcd4ddf6a05(
        #"zombie", #"hash_896b88a46f6a4c15", "\x8e\x19\x048X\xe0" );
    nengine_store_set( "blackwater_lake", "pap_status", "native_interaction_registered" );
    nengine_store_set( "blackwater_lake", "pap_origin", self.pap_sbl.origin );
}

function bwl_truck_pap_use( player )
{
    if ( !bwl_selected() || !isdefined( level.bwl_pap_truck ) )
        return;
    if ( self != level.bwl_pap_truck.pap_sbl )
        return;
    nengine_store_set( "blackwater_lake", "pap_use_callback", 1 );
    nengine_store_save( "blackwater_lake", "runtime" );
    self namespace_167cc53cd3a6c3cc::function_8ff137553260336f( player );
}

// Map structs are indexed by native fields such as target and targetname,
// not necessarily by script_noteworthy. Scan both indices if the direct
// lookup is unavailable. Use the game's actual script_noteworthy hash: ACTS
// otherwise emits a zero field for named script_* fields in this compiler.
function bwl_consider_speed_marker( result, candidate )
{
    if ( !isdefined( candidate ) || !isdefined( candidate.origin ) ||
        !isdefined( candidate.angles ) || !isdefined( candidate.var_94650194e2160349 ) )
        return;
    if ( candidate.var_94650194e2160349 != "specialty_speedcola" )
        return;
    distance2 = distancesquared( candidate.origin, level.bwl_front_spawn.origin );
    if ( distance2 < result.distance2 )
    {
        result.distance2 = distance2;
        result.marker = candidate;
    }
}

function bwl_speed_cola_marker()
{
    result = spawnstruct();
    result.distance2 = 2048 * 2048;
    direct = bwl_structs( "specialty_speedcola", "script_noteworthy" );
    for ( i = 0; i < direct.size; i++ )
        bwl_consider_speed_marker( result, direct[ i ] );

    if ( !isdefined( result.marker ) && isdefined( level.var_7619345e0810ba9b ) )
    {
        fields = [ "targetname", "target" ];
        for ( i = 0; i < fields.size; i++ )
        {
            index = level.var_7619345e0810ba9b[ fields[ i ] ];
            if ( !isdefined( index ) )
                continue;
            keys = getarraykeys( index );
            for ( key_index = 0; key_index < keys.size; key_index++ )
            {
                if ( key_index > 0 && key_index % 128 == 0 )
                    waitframe();
                group = index[ keys[ key_index ] ];
                if ( !isarray( group ) )
                    continue;
                for ( group_index = 0; group_index < group.size; group_index++ )
                    bwl_consider_speed_marker( result, group[ group_index ] );
            }
        }
    }
    return result.marker;
}

function bwl_auto_wunderfizz()
{
    level endon( #"game_ended" );
    wait 3;
    if ( !bwl_selected() || !isdefined( level.bwl_front_spawn ) )
        return;
    nengine_store_set( "blackwater_lake", "wunderfizz_status", "finding_cabin_marker" );
    nengine_store_save( "blackwater_lake", "runtime" );
    for ( attempt = 0; attempt < 12; attempt++ )
    {
        native = bwl_speed_cola_marker();
        if ( isdefined( native ) )
        {
            // The Wunderfizz model sits forward of Speed Cola at the same
            // marker. Move it toward the wall while retaining its facing.
            marker = spawnstruct();
            marker.origin = native.origin - anglestoforward( native.angles ) * 24;
            marker.angles = native.angles;
            nengine_store_set( "blackwater_lake", "wunderfizz_native_origin", native.origin );
            nengine_store_set( "blackwater_lake", "wunderfizz_anchor_source", "native_speed_cola" );
            nengine_store_set( "blackwater_lake", "wunderfizz_status", "native_cabin_marker_found" );
            nengine_store_save( "blackwater_lake", "runtime" );
            bwl_wunderfizz( marker );
            return;
        }
        wait 5;
    }
    nengine_store_set( "blackwater_lake", "wunderfizz_status", "native_cabin_marker_missing" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_wunderfizz( source )
{
    level.bwl_wunderfizz = spawnstruct();
    level.bwl_wunderfizz.origin = source.origin;
    level.bwl_wunderfizz.angles = source.angles;
    level.bwl_wunderfizz.targetname = "bwl_wunderfizz";
    level.bwl_wunderfizz.var_94650194e2160349 = "specialty_wunderfizz";
    level.bwl_wunderfizz.var_8a1bbd1390cd5db6 = "zone_lakefront_cabin";
    level.bwl_wunderfizz.radius = 80;
    level.bwl_wunderfizz.var_e502d431f3ba8706 = 1;
    level.bwl_wunderfizz.var_5479a569b6dacec7 = 1;
    level.bwl_wunderfizz_instance = spawnstruct();
    level.bwl_wunderfizz_instance.var_fe6d648dc993577d = #"essence";
    nengine_store_set( "blackwater_lake", "wunderfizz_angles", level.bwl_wunderfizz.angles );
    nengine_store_set( "blackwater_lake", "wunderfizz_origin", level.bwl_wunderfizz.origin );
    nengine_store_set( "blackwater_lake", "wunderfizz_status", "initializing_native_machine" );
    nengine_store_save( "blackwater_lake", "runtime" );
    // Wait for the same prerequisite as the native initializer before
    // temporarily changing the shared perk-start setting.
    level namespace_60b3bdcc70f79fc6::function_fb7b1af19016b7f4( "\xa5^\x1e\xd4\xd1X\xc9\xe8\xa3\v\xad+*^\x0e+\xa1\x16c\xb1\x98X\x8d[#\xd2\xdc\x96n\xa1\xca\x8c" );
    level.bwl_perks_start_on = level.var_49f0f335e954bf2a;
    nengine_store_set( "blackwater_lake", "lake_perks_start_on",
        isdefined( level.bwl_perks_start_on ) ? level.bwl_perks_start_on : -1 );
    nengine_store_set( "blackwater_lake", "lake_wunderfizz_start_override",
        isdefined( level.var_1d3d915cc555bf38 ) && isdefined( level.var_1d3d915cc555bf38[ "\x88\r\x11\xf3\x9b\x0f&\xd8\xd6\xe4i\x8b/\xbe\x18\xf8\xe7\x02\x89" ] ) ?
        level.var_1d3d915cc555bf38[ "\x88\r\x11\xf3\x9b\x0f&\xd8\xd6\xe4i\x8b/\xbe\x18\xf8\xe7\x02\x89" ] : -1 );
    nengine_store_save( "blackwater_lake", "runtime" );
    level.var_49f0f335e954bf2a = 0;
    level.bwl_wunderfizz namespace_34fc1661493f2405::function_e3d3bfcc06c89350( level.bwl_wunderfizz_instance );
    // Its native power worker is threaded by the initializer; let that
    // worker observe the temporary setting before restoring it.
    waitframe();
    level.var_49f0f335e954bf2a = level.bwl_perks_start_on;
    nengine_store_set( "blackwater_lake", "wunderfizz_status",
        isdefined( level.bwl_wunderfizz.var_b69810c6c14b1634 ) ? "native_machine_created" : "native_machine_missing" );
    nengine_store_save( "blackwater_lake", "runtime" );
}

// 0.2.97: spawn point set to a spot recorded in game. Script
// teleports at spawn (0.2.94-0.2.96) did not reach the position the game uses,
// so the spawn structs themselves get the spot saved in 0.2.93. Called after the
// Rampage marker is placed; level.bwl_front_spawn is a copy of the original.
// 0.2.113 (both test rows spawned in Ashes of the Damned). The Mayhem test rows run the game's own Mr. Peeks Mayhem
// (zm_rb_rh_mod), which is round-based: it has no Survival POI and starts the
// players at the town plaza respawn group (zone_jplaza). Only in that game type
// that group is moved to the lake spot as well, and the lake zones are enabled
// at the first spawn as native Survival enables its arena zones.
function bwl_round_based_mayhem()
{
    return getdvar( @"hash_da1eb79d992f0e28", "null" ) == "zm_rb_rh_mod" || getdvar( "g_gametype" ) == "zm_rb_rh_mod";
}

function bwl_mayhem_start_points()
{
    nengine_store_set( "blackwater_lake", "mayhem_round_based", 1 );
    nengine_store_set( "blackwater_lake", "mayhem_start_points_moved", -1 );
    level.bwl_mayhem_groups = bwl_structs( "player_respawn_point", "targetname" );
    for ( level.bwl_mayhem_index = 0; level.bwl_mayhem_index < level.bwl_mayhem_groups.size; level.bwl_mayhem_index++ )
    {
        level.bwl_mayhem_group = level.bwl_mayhem_groups[ level.bwl_mayhem_index ];
        level.bwl_mayhem_name = level.bwl_mayhem_group.var_92781bc7d418ab8a;
        if ( !isdefined( level.bwl_mayhem_name ) )
            level.bwl_mayhem_name = level.bwl_mayhem_group.script_zone_name;
        if ( !isdefined( level.bwl_mayhem_name ) || level.bwl_mayhem_name != "zone_jplaza" || !isdefined( level.bwl_mayhem_group.target ) )
            continue;
        level.bwl_mayhem_points = bwl_structs( level.bwl_mayhem_group.target, "targetname" );
        if ( level.bwl_mayhem_points.size < 1 )
            continue;
        bwl_move_spawn_points( level.bwl_mayhem_points );
        nengine_store_set( "blackwater_lake", "mayhem_start_points_moved", level.bwl_mayhem_points.size );
        return;
    }
}

function bwl_mayhem_zones()
{
    self endon( #"disconnect" );
    level endon( #"game_ended" );
    level.bwl_mayhem_zone = namespace_63a203e154ffeca0::get_zone_struct( "zone_lakefront" );
    nengine_store_set( "blackwater_lake", "mayhem_lake_zone_before",
        ( isdefined( level.bwl_mayhem_zone ) && isdefined( level.bwl_mayhem_zone.is_enabled ) ) ? ( level.bwl_mayhem_zone.is_enabled ? 1 : 0 ) : -1 );
    level.bwl_mayhem_zone_names = bwl_zones();
    level.bwl_mayhem_zones_enabled = 0;
    for ( level.bwl_mayhem_index = 0; level.bwl_mayhem_index < level.bwl_mayhem_zone_names.size; level.bwl_mayhem_index++ )
    {
        if ( !isdefined( namespace_63a203e154ffeca0::get_zone_struct( level.bwl_mayhem_zone_names[ level.bwl_mayhem_index ] ) ) )
            continue;
        namespace_63a203e154ffeca0::set_zone_enabled( level.bwl_mayhem_zone_names[ level.bwl_mayhem_index ], 1 );
        level.bwl_mayhem_zones_enabled++;
    }
    level.bwl_mayhem_zone = namespace_63a203e154ffeca0::get_zone_struct( "zone_lakefront" );
    nengine_store_set( "blackwater_lake", "mayhem_lake_zone_after",
        ( isdefined( level.bwl_mayhem_zone ) && isdefined( level.bwl_mayhem_zone.is_enabled ) ) ? ( level.bwl_mayhem_zone.is_enabled ? 1 : 0 ) : -1 );
    nengine_store_set( "blackwater_lake", "mayhem_zones_enabled", level.bwl_mayhem_zones_enabled );
    nengine_store_save( "blackwater_lake", "runtime" );
    wait 3;
    level.bwl_mayhem_player_zone = namespace_63a203e154ffeca0::function_90e5c3e2272b0130( self.origin + ( 0, 0, 32 ) );
    nengine_store_set( "blackwater_lake", "mayhem_player_zone",
        ( isdefined( level.bwl_mayhem_player_zone ) && isdefined( level.bwl_mayhem_player_zone.var_92781bc7d418ab8a ) ) ? level.bwl_mayhem_player_zone.var_92781bc7d418ab8a : "none" );
    nengine_store_set( "blackwater_lake", "mayhem_player_origin", self.origin );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_move_spawn_points( points )
{
    offsets = [ ( 0, 0, 0 ), ( 48, 0, 0 ), ( 0, 48, 0 ), ( 48, 48, 0 ) ];
    for ( i = 0; i < points.size; i++ )
    {
        if ( i < 4 )
            points[ i ].origin = ( 14208.8115, 3050.59668, 866 ) + offsets[ i ];
        else
            points[ i ].origin = ( 14208.8115, 3050.59668, 866 );
        // 0.2.99: view tilted up 20 degrees (0.2.98 used 12).
        points[ i ].angles = ( -20, 122.635284, 0 );
    }
    nengine_store_set( "blackwater_lake", "spawn_points_moved", points.size );
    nengine_store_set( "blackwater_lake", "spawn_points_moved_origin", points[ 0 ].origin );
}

// 0.2.97: where the player is 20, 100 and 600 frames after each spawn.
function bwl_spawn_spot_log()
{
    self endon( #"disconnect" );
    self endon( #"death" );
    self notify( #"bwl_spawn_spot_restart" );
    self endon( #"bwl_spawn_spot_restart" );
    if ( !isdefined( level.bwl_spawn_calls ) )
        level.bwl_spawn_calls = 0;
    level.bwl_spawn_calls++;
    nengine_store_set( "blackwater_lake", "spawn_calls", level.bwl_spawn_calls );
    frames = 0;
    while ( frames < 600 )
    {
        waitframe();
        frames++;
        if ( frames == 20 )
        {
            // 0.2.100: the spawn structs' pitch is ignored (0.2.98/0.2.99), so set the view here.
            self setplayerangles( ( -20, 122.635284, 0 ) );
            nengine_store_set( "blackwater_lake", "spawn_spot_frame20", self.origin );
            nengine_store_set( "blackwater_lake", "spawn_view_pitch_set", -20 );
        }
        if ( frames == 100 )
        {
            nengine_store_set( "blackwater_lake", "spawn_spot_frame100", self.origin );
            nengine_store_save( "blackwater_lake", "runtime" );
        }
    }
    nengine_store_set( "blackwater_lake", "spawn_spot_after_hold", self.origin );
    nengine_store_save( "blackwater_lake", "runtime" );
}
