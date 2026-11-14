// Blackwater Lake 0.3.3: skip the exfil screen at the lake, as Kronos does on
// its own Survival POIs. Kronos' custom_scripts/exfilfix.gscc arms only for
// zone_farm, zone_exit115, zone_launchpad and ashwood on Firefly (and one POI
// per other map); at zone_lakefront it stops with "scope_skipped", so after a
// successful exfil the host stays on the exfil screen. This is the same
// sequence for Blackwater Lake only: after the native zm_exfil_success, once
// the host's exfil presentation is up and no other player is still playing,
// it requests the game's own end of match with the native winner and
// objective-completed reason. It never arms when Kronos' fix is armed, outside
// Firefly/zone_lakefront Survival or Cursed Survival, or when the game has its
// own post-game exfil option on. Kronos' file is not changed. Separate script:
// if a Kronos or game update breaks it, only this skip stops linking.
// script_4c770a9a4ad7659c is scripts\common\callbacks (callback::add).
#using script_44cd18225e55c2ac;
#using script_4c770a9a4ad7659c;

autoexec bwl_exfil_register()
{
    if ( getdvar( "mapname" ) != "zm_sat_firefly" && getdvar( "ui_mapname" ) != "zm_sat_firefly" )
        return;
    if ( isdefined( level.bwl_exfil ) )
        return;
    level.bwl_exfil = spawnstruct();
    level.bwl_exfil.armed = 0;
    level.bwl_exfil.ready = 0;
    level.bwl_exfil.watching = 0;
    level.bwl_exfil.requested = 0;
    level.bwl_exfil.closed = 0;
    level.bwl_exfil.changes = 0;
    level.bwl_exfil.status = "boot";
    level thread bwl_exfil_arm( level.bwl_exfil );
}

function bwl_exfil_current( c )
{
    return isdefined( c ) && isdefined( level.bwl_exfil ) && level.bwl_exfil == c;
}

function bwl_exfil_survival( gametype )
{
    return gametype == "zm_rb_survival" || gametype == "zm_rb_r_mod_survival";
}

function bwl_exfil_record( c )
{
    nengine_store_set( "blackwater_lake", "exfil_status", c.status );
    nengine_store_save( "blackwater_lake", "runtime" );
}

function bwl_exfil_arm( c )
{
    for ( i = 0; i <= 480; i++ )
    {
        if ( !bwl_exfil_current( c ) )
            return;
        if ( isdefined( level.var_7ebad24685cd9f8c ) && isdefined( level.var_dfeae4b8b3d59217 ) &&
             isdefined( level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7 ) && isdefined( level.var_a76045f3136660f9 ) )
            break;
        if ( i < 480 )
            wait 0.25;
    }
    if ( !isdefined( level.var_7ebad24685cd9f8c ) || !isdefined( level.var_dfeae4b8b3d59217 ) ||
         !isdefined( level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7 ) || !isdefined( level.var_a76045f3136660f9 ) )
    {
        c.status = "startup_timeout";
        return;
    }
    if ( level.var_dfeae4b8b3d59217 != "zm_sat_firefly" || level.var_a76045f3136660f9 != "zone_lakefront" ||
         !bwl_exfil_survival( level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7 ) )
    {
        c.status = "not_blackwater";
        return;
    }
    if ( isdefined( level.var_4809ad834dd4fef4 ) && isdefined( level.var_4809ad834dd4fef4.armed ) && level.var_4809ad834dd4fef4.armed )
    {
        c.status = "kronos_fix_armed";
        bwl_exfil_record( c );
        return;
    }
    c.map = level.var_dfeae4b8b3d59217;
    c.gametype = level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7;
    c.poi = level.var_a76045f3136660f9;
    level callback::add( "zm_exfil_success", &bwl_exfil_success, c );
    level callback::add( #"hash_bc4ea9104977fb01", &bwl_exfil_player_change, c );
    level callback::add( #"hash_757dcfc448247cf3", &bwl_exfil_disconnect, c );
    level callback::add( #"hash_f3759b516e1143d5", &bwl_exfil_death, c );
    level callback::add( #"hash_d08e8fedeb7ed0e5", &bwl_exfil_finalizing, c );
    level callback::add( #"hash_8ae9b61daf6f8f94", &bwl_exfil_ended, c );
    c.armed = 1;
    c.status = "armed";
    bwl_exfil_record( c );
}

function bwl_exfil_close( c, why )
{
    if ( !bwl_exfil_current( c ) )
        return;
    c.closed = 1;
    c.ready = 0;
    c.watching = 0;
    c.host = undefined;
    c.status = why;
    bwl_exfil_record( c );
}

function bwl_exfil_ended( params, c )
{
    bwl_exfil_close( c, "original_game_ended" );
}

function bwl_exfil_finalizing( params, c )
{
    bwl_exfil_close( c, "original_finalization_started" );
}

function bwl_exfil_player_change( params, c )
{
    if ( !bwl_exfil_current( c ) )
        return;
    c.changes++;
    bwl_exfil_watch( c );
}

function bwl_exfil_disconnect( params, c )
{
    if ( !bwl_exfil_current( c ) )
        return;
    if ( isdefined( c.host ) && self == c.host )
    {
        bwl_exfil_close( c, "host_disconnected" );
        return;
    }
    c.changes++;
    bwl_exfil_watch( c );
}

function bwl_exfil_death( params, c )
{
    if ( !bwl_exfil_current( c ) )
        return;
    if ( isdefined( c.host ) && self == c.host )
        bwl_exfil_close( c, "host_died" );
}

function bwl_exfil_success( params, c )
{
    if ( !bwl_exfil_current( c ) || !c.armed || c.closed || c.requested )
        return;
    if ( !isdefined( params ) || !function_cfebf1a31085d52b( params ) || !isdefined( params.var_957e9d25e3f9e03 ) )
        return;
    if ( !function_58736ce92359fa07( params.var_957e9d25e3f9e03 ) )
        return;
    for ( i = 0; i < params.var_957e9d25e3f9e03.size; i++ )
    {
        player = params.var_957e9d25e3f9e03[ i ];
        if ( !isdefined( player ) || !function_503f9a7fd00943c7( player ) )
            continue;
        if ( !player function_b36623eefe0028c8() )
            continue;
        if ( player.var_1a98782093ca2c08 != 1 || player.var_472e2d036e427d3b != 1 )
            continue;
        if ( isdefined( c.host ) && c.host != player )
        {
            bwl_exfil_close( c, "host_identity_changed" );
            return;
        }
        c.host = player;
        c.ready = 1;
    }
    c.status = "exfil_success_seen";
    bwl_exfil_record( c );
    bwl_exfil_watch( c );
}

function bwl_exfil_watch( c )
{
    if ( !bwl_exfil_current( c ) || !c.armed || !c.ready || c.closed || c.requested || c.watching )
        return;
    c.watching = 1;
    level thread bwl_exfil_finish( c );
}

function bwl_exfil_live( c )
{
    return bwl_exfil_current( c ) && c.armed && c.ready && !c.closed && !c.requested;
}

function bwl_exfil_pause( c, why )
{
    if ( !bwl_exfil_current( c ) )
        return;
    c.watching = 0;
    c.status = why;
    bwl_exfil_record( c );
}

function bwl_exfil_original_ending()
{
    return level.var_9ff6e401c5578760 || level.var_a725b8d28bb8c67e || level.var_e3805050a2c5f924 ||
        level.var_c5c2570873b080b2 || level.var_41e82ca9c2b4c55a;
}

function bwl_exfil_context( c )
{
    if ( level.var_dfeae4b8b3d59217 != c.map || game[ "state" ] != "playing" )
        return false;
    if ( level.var_7ebad24685cd9f8c.var_53486d8d1bcaeac7 != c.gametype || level.var_a76045f3136660f9 != c.poi )
        return false;
    if ( isdefined( level.var_61515efa4249e355 ) || isdefined( level.var_519fe94beba8d651 ) )
        return false;
    level.bwl_exfil_post_game = function_8d35635fa0f5f852( "commonOption", "postGameExfil" );
    if ( !isdefined( level.bwl_exfil_post_game ) || level.bwl_exfil_post_game || !isdefined( level.postGameExfil ) || level.postGameExfil )
        return false;
    return true;
}

function bwl_exfil_host_ok( player )
{
    if ( !isdefined( player ) || !function_503f9a7fd00943c7( player ) )
        return false;
    if ( player.var_176b6ae22ca10468 || !player function_b36623eefe0028c8() || !function_52d4872ae95d8bb7( player ) )
        return false;
    if ( player.var_948fe687565941e7 != "playing" )
        return false;
    return player.var_1a98782093ca2c08 == 1 && player.var_472e2d036e427d3b == 1;
}

function bwl_exfil_presenting( player )
{
    return player.var_3417dc9429b05c62 == 1 && player function_939eb64accd1e612( "post_game_state" ) == 1 &&
        player function_939eb64accd1e612( "ui_dmz_extract_successful" ) == 1 &&
        player function_939eb64accd1e612( "ui_br_squad_eliminated_active" ) == 1;
}

// -1 unknown roster, 0 host alone, 1 everyone else is already out, 2 waiting.
function bwl_exfil_roster( host )
{
    if ( !isdefined( level.var_10f4ff41c4b7f0ac ) || !function_58736ce92359fa07( level.var_10f4ff41c4b7f0ac ) ||
         level.var_10f4ff41c4b7f0ac.size < 1 )
        return -1;
    found = 0;
    others = 0;
    out = 1;
    for ( i = 0; i < level.var_10f4ff41c4b7f0ac.size; i++ )
    {
        player = level.var_10f4ff41c4b7f0ac[ i ];
        if ( !isdefined( player ) || !function_503f9a7fd00943c7( player ) )
            return -1;
        if ( player == host )
        {
            found = 1;
            continue;
        }
        others++;
        if ( player.var_176b6ae22ca10468 != 1 )
            out = 0;
    }
    if ( !found )
        return -1;
    if ( !others )
        return 0;
    return out ? 1 : 2;
}

function bwl_exfil_still_ok( c, changes )
{
    if ( !bwl_exfil_live( c ) || c.changes != changes || bwl_exfil_original_ending() )
        return false;
    if ( !bwl_exfil_context( c ) || !bwl_exfil_host_ok( c.host ) || !bwl_exfil_presenting( c.host ) )
        return false;
    if ( bwl_exfil_roster( c.host ) != 0 )
        return false;
    return bwl_exfil_live( c ) && c.changes == changes && !bwl_exfil_original_ending();
}

function bwl_exfil_finish( c )
{
    for ( i = 0; i < 120; i++ )
    {
        if ( !bwl_exfil_live( c ) )
            return;
        if ( bwl_exfil_original_ending() )
        {
            bwl_exfil_close( c, "original_ending_seen" );
            return;
        }
        if ( !bwl_exfil_context( c ) )
        {
            bwl_exfil_pause( c, "incompatible_context" );
            return;
        }
        if ( !bwl_exfil_host_ok( c.host ) )
        {
            bwl_exfil_close( c, "host_context_invalid" );
            return;
        }
        if ( bwl_exfil_presenting( c.host ) )
        {
            level.bwl_exfil_roster = bwl_exfil_roster( c.host );
            if ( level.bwl_exfil_roster == -1 )
            {
                bwl_exfil_pause( c, "roster_unknown" );
                return;
            }
            if ( level.bwl_exfil_roster == 2 )
            {
                bwl_exfil_pause( c, "waiting_other_players" );
                return;
            }
            if ( level.bwl_exfil_roster == 0 )
            {
                level.bwl_exfil_changes = c.changes;
                if ( i > 112 )
                {
                    bwl_exfil_pause( c, "readiness_timeout_no_endgame_requested" );
                    return;
                }
                wait 1.75;
                i += 7;
                if ( !bwl_exfil_live( c ) )
                    return;
                if ( bwl_exfil_original_ending() )
                {
                    bwl_exfil_close( c, "original_ending_seen" );
                    return;
                }
                if ( !bwl_exfil_context( c ) || !bwl_exfil_host_ok( c.host ) )
                {
                    bwl_exfil_close( c, "context_changed_during_presentation" );
                    return;
                }
                if ( level.bwl_exfil_changes == c.changes && bwl_exfil_presenting( c.host ) && bwl_exfil_roster( c.host ) == 0 )
                {
                    if ( !isdefined( game[ "end_reason" ] ) || !isdefined( game[ "end_reason" ][ "objective_completed" ] ) )
                    {
                        bwl_exfil_pause( c, "original_end_reason_unavailable" );
                        return;
                    }
                    level.bwl_exfil_winner = getdvar( @"hash_aea3ac32a07685ba", "allies" );
                    if ( !isdefined( level.bwl_exfil_winner ) || level.bwl_exfil_winner == "" )
                    {
                        bwl_exfil_pause( c, "original_winner_unavailable" );
                        return;
                    }
                    if ( !bwl_exfil_still_ok( c, level.bwl_exfil_changes ) )
                        continue;
                    c.requested = 1;
                    c.ready = 0;
                    c.watching = 0;
                    c.status = "requesting_original_endgame";
                    bwl_exfil_record( c );
                    level namespace_2c0a06b7d96890b6::function_61515efa4249e355( level.bwl_exfil_winner, game[ "end_reason" ][ "objective_completed" ] );
                    return;
                }
            }
            else
                c.status = "waiting_disconnect_cleanup";
        }
        else
            c.status = "waiting_host_presentation";
        wait 0.25;
    }
    bwl_exfil_pause( c, "readiness_timeout_no_endgame_requested" );
}
