// Blackwater Lake 0.3.2: Cursed Survival Mayhem at the lake, without changing
// any Kronos file. A Blackwater Cursed start with the Mayhem relic is armed in
// the menu as Kronos' own Ashwood Cursed row and marked with the route dvar
// 0x4bd1a7c0e93f2b56 = mayhem; the POI dvar stays zone_lakefront, so the
// loading screen is Blackwater's. Kronos' csm_survival decides Mayhem once, in
// its autoexec, from the POI dvar. This script runs that autoexec itself (0.3.1
// showed it runs first: route_result helper_ran_csm, fresh_context_ready) with
// the POI dvar reading ashwood only for that call, then sets the lake again
// before Survival main builds the POI. Kronos' guard level.var_11c90d8820dc7f81
// stops its autoexec from running twice. This script is separate so that, should
// a Kronos update rename that function, only the Mayhem route stops linking.
#using script_7b40423219e7a186;

autoexec bwl_csm_route()
{
    if ( getdvar( @"hash_4bd1a7c0e93f2b56", "" ) != "mayhem" )
        return;
    if ( getdvar( "mapname" ) != "zm_sat_firefly" && getdvar( "ui_mapname" ) != "zm_sat_firefly" )
        return;
    level.bwl_route_poi_before = getdvar( @"hash_dddf7dca1a52e591", "null" );
    if ( level.bwl_route_poi_before != "zone_lakefront" && level.bwl_route_poi_before != "ashwood" )
        return;
    level.bwl_route_helper = 1;
    level.bwl_route_helper_csm_before = isdefined( level.var_11c90d8820dc7f81 ) ? 1 : 0;
    if ( !level.bwl_route_helper_csm_before )
    {
        setdvar( @"hash_dddf7dca1a52e591", "ashwood" );
        namespace_72f24af86aefd63a::function_5c2fcf9dda67fce4();
        level.bwl_route_result = "helper_ran_csm";
    }
    else
        level.bwl_route_result = "csm_ran_first";
    setdvar( @"hash_dddf7dca1a52e591", "zone_lakefront" );
    setdvar( @"hash_4bd1a7c0e93f2b56", "used" );
    level.bwl_route_helper_csm_status = getdvar( @"hash_ed9b0e46d505c12f", "null" );
    level.bwl_route_helper_session = isdefined( level.var_7d6dd80d20d65e17 ) ? 1 : 0;
    level.bwl_route_poi_after = getdvar( @"hash_dddf7dca1a52e591", "null" );
    level.bwl_route_poi_defined = isdefined( level.var_a76045f3136660f9 ) ? 1 : 0;
}
