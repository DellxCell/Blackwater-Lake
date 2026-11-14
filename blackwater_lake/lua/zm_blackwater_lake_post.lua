-- Blackwater Lake 1.0 as a Kronos mod (mods/blackwater_lake), without editing
-- any Kronos file (Kronos workshop rules: https://github.com/Divity/kronos-data/wiki).
-- Up to 0.2.133 Blackwater patched four Kronos files (launcher, HUD, and both
-- Cursed Survival Mayhem allowlists), which the launcher reported as Outdated.
-- Everything here goes through what Kronos and the game already make public:
--   * menu rows: the same method Veytharion's Gauntlet (rex_arena) uses. After
--     each launcher publish, the launcher's Ashwood rows are copied as
--     "Blackwater Lake": Survival 1000000008/09 -> 1000000200/201 and Cursed
--     Survival 1000000068/69 -> 1000000202/203. Starting one runs the
--     launcher's own Ashwood start; on that start's public request the record
--     is replaced by a copy whose POI setting (0xdddf7dca1a52e591) is
--     zone_lakefront, as the old launcher patch did. The launcher's records are
--     never changed.
--   * Cursed Survival with the Mayhem relic: Kronos' CSM_MAYHEM_P1.prepare (a
--     public table) is wrapped for Blackwater requests only. With the relic it
--     arms Mayhem as Kronos' own Ashwood Cursed row (POI ashwood) and sets the
--     Blackwater route dvar 0x4bd1a7c0e93f2b56 to "mayhem". The POI dvar stays
--     zone_lakefront (0.3.2: so the loading screen is the lake's); in the match
--     zm_blackwater_lake_mayhem.gsc sets ashwood only while it runs Kronos'
--     csm_survival check, then sets the lake again before Survival main.
--     Without the relic the match is plain Cursed Survival at the lake (0.2.109).
--   * HUD: Kronos' HUD hides the quest tracker (hideQuest). During a Blackwater
--     match only, while the quest widget is built, the KINDS handler for the
--     quest widget is skipped, so the native Restore Power tracker stays.
-- Lines go to poi_reg.log as "lua: blackwater: ..." (KRONOS.log).
do
local G=_G
local old=rawget(G,"BLACKWATER_LAKE_MOD")
if type(old)=="table" and old.installed then return end
local C=rawget(G,"CLUA")
local hash=type(C)=="table" and C.PushXHash or rawget(G,"xhash")
if type(hash)~="function" then return end

local A={version="1.0",installed=false,logged={},publishing=false,card_sources={},card_titles={}}
rawset(G,"BLACKWATER_LAKE_MOD",A)

local function log(message)
    local K=rawget(G,"KRONOS")
    if type(K)=="table" and type(K.log)=="function" and pcall(K.log,"blackwater: "..message) then return end
    local debug_print=rawget(G,"DebugPrint")
    if type(debug_print)=="function" then pcall(debug_print,"k1 blackwater: "..message) end
end
local function once(key,message)
    if A.logged[key]~=message then A.logged[key]=message;log(message) end
end
A.log=log

-- id: our row; source: the launcher row we copy and whose start runs.
local ROWS={{id=1000000200,source=1000000008,cursed=false},{id=1000000201,source=1000000009,cursed=false},
    {id=1000000202,source=1000000068,cursed=true},{id=1000000203,source=1000000069,cursed=true}}
local SOURCE,ROW_OF={},{}
for _,spec in ipairs(ROWS) do SOURCE[spec.id]=spec.source;ROW_OF[spec.source]=spec.id end
A.ROWS=ROWS
local OWNER="blackwater_lake_mod"
local TITLE="Blackwater Lake"
local DESC="Survive at the lake, cabin, and surrounding cliffs."
local IMAGE="blackwater_lake_save"
local CARD_PREFIX="blackwater_lake_mod_card_"
local MAP="zm_sat_firefly"
local POI_KEY,POI,ASHWOOD="0xdddf7dca1a52e591","zone_lakefront","ashwood"
local ROUTE_KEY="0x4bd1a7c0e93f2b56"
local CURSED_ASSET="zm_rb_r_mod_survival"
local BASE="frontEnd.playlists.category"
-- The launcher's playlist row fields (its data.fields).
local FIELDS={"name","desc","mapName","subCategoryName","image","index","minPlayerSize","maxPlayerSize",
    "minPartySize","maxPartySize","timeLimit","scoreLimit","numRounds","isNew","isFeatured","gamemodekey",
    "xpScale","weaponXpScale","battlePassXpScale","isLimitedTime","ID","playMenuRef","tags","missionName",
    "startTime","endTime","isTimerHidden","isOneParty","isRestrictF2P","isCasualQuickplay",
    "isZMSurvivalPlaylist","ZMCursedTierMin","ZMCursedTierMax","isOpen","isPersistentLobby","isExternal",
    "attestationPolicy"}

local unpack=rawget(G,"unpack") or table.unpack
local function slot(t,s)
    if type(t)~="table" then return end
    local v=rawget(t,s);if v~=nil then return v,s end
    local k=hash(s);v=rawget(t,k);if v~=nil then return v,k end
end
local function member(t,s)
    local v=slot(t,s);if v~=nil then return v end
    if type(t)~="table" and type(t)~="userdata" then return end
    local ok;ok,v=pcall(function() return t[s] end)
    if ok and v~=nil then return v end
    ok,v=pcall(function() return t[hash(s)] end);if ok then return v end
end
local function path(t,...)
    for i=1,select("#",...) do t=member(t,select(i,...));if t==nil then return end end
    return t
end
local function pack(...) return {n=select("#",...),...} end
local function copy(t)
    local out={};for k,v in pairs(t) do out[k]=v end;return out
end
local function put(t,name,value)
    local _,key=slot(t,name)
    rawset(t,key or hash(name),value)
end
local function pair(c,p) return tostring(c)..":"..tostring(p) end
local function hook(owner,name,make)
    local original,key=slot(owner,name)
    if type(original)~="function" then error("missing original hook: "..name) end
    local replacement=make(original)
    rawset(owner,key,replacement)
    if rawget(owner,key)~=replacement then error("original table rejected hook: "..name) end
end
local function mine(entry) return type(entry)=="table" and entry.category_ref==OWNER end

local function dvar_text(name)
    local get=slot(rawget(G,"Dvar"),"0x254084d7ca2317bb")
    local push=type(C)=="table" and C.PushXHashDvar
    if type(get)~="function" or type(push)~="function" then return nil end
    local ok,value=pcall(function() return get(push(name)) end)
    if ok and type(value)=="string" then return value end
end
A.dvar_text=dvar_text
-- The launcher's and Kronos' own way to write a dvar: ExecNow "set #x3<16 hex>".
local function set_dvar(key,value)
    local engine=rawget(G,"Engine")
    local exec=slot(engine,"0xeb81a5136c5503e4") or slot(engine,"ExecNow")
    if type(exec)~="function" then return false,"ExecNow unavailable" end
    local ok,why=pcall(exec,"set #x3"..string.sub(key,3).." \""..value.."\"",0)
    local now=dvar_text(key)
    return now==value,(ok and "" or tostring(why).." ").."now "..tostring(now)
end
A.set_dvar=set_dvar
local function in_frontend()
    local f=slot(rawget(G,"Engine"),"InFrontend")
    if type(f)~="function" then return nil end
    local ok,value=pcall(f)
    if ok and type(value)=="boolean" then return value end
end
local function launcher_request()
    local launcher=rawget(G,"LUMEN_ZM_LOCAL_START")
    local request=type(launcher)=="table" and rawget(launcher,"request") or nil
    if type(request)=="table" then return request end
end
-- A Blackwater match: our start request (the launcher keeps it until it
-- returns from gameplay), otherwise the gameplay script's own rule.
local function lake_match()
    if in_frontend()~=false then return false,"frontend" end
    local request=launcher_request()
    if request and request.blackwater_lake==true then return true,"request" end
    local map=dvar_text("ui_mapname")==MAP or dvar_text("mapname")==MAP
    if map and dvar_text(POI_KEY)==POI then return true,"poi" end
    if map and dvar_text(ROUTE_KEY)=="used" then return true,"route" end
    return false,"other"
end
A.lake_match=lake_match

-- A copy of the launcher's Ashwood record with the lake POI, as the old
-- launcher patch made it. The launcher's own record is not changed.
local function lake_record(record)
    if type(record)~="table" or record.map~=MAP or type(record.configuration)~="table" then
        error("unexpected Ashwood record")
    end
    local result=copy(record);local configuration={};local found=0
    for i,entry in ipairs(record.configuration) do
        if type(entry)=="table" and entry.key==POI_KEY then
            local changed=copy(entry);changed.value=POI;configuration[i]=changed;found=found+1
        else configuration[i]=entry end
    end
    if found~=1 then error("expected one POI setting in the Ashwood record, found "..found) end
    result.configuration=configuration;result.poi=POI;result.blackwater_lake=true
    return result
end
A.lake_record=lake_record

-- [blackwater names begin]
-- In-match and loading-screen map name (Rex Arena's proven hooks): MapInfo
-- 0x615ea1db2da9249a (loading screen title) and 0x5c034961620dbc3c (the game's
-- map-name lookup) answer "Blackwater Lake" for zm_sat_firefly during a
-- Blackwater match.
local function hook_loading_name()
    if A.loading_hooked then return true end
    local mapinfo=rawget(G,"MapInfo")
    local original,key=slot(mapinfo,"0x615ea1db2da9249a")
    if type(original)~="function" then return false end
    local replacement=function(...)
        local result=pack(original(...))
        local yes,why=lake_match()
        if yes and type(result[1])=="string" and result[1]~="" then
            once("loadname","loading screen map name "..TITLE.." ("..why..", was "..result[1]..")")
            result[1]=TITLE
        end
        return unpack(result,1,result.n)
    end
    rawset(mapinfo,key,replacement)
    A.loading_hooked=rawget(mapinfo,key)==replacement
    once("loadhook",A.loading_hooked and "loading screen name hook on" or "loading screen name hook rejected")
    return A.loading_hooked
end
local function hook_map_lookup()
    if A.map_lookup_hooked then return true end
    local mapinfo=rawget(G,"MapInfo")
    local original,key=slot(mapinfo,"0x5c034961620dbc3c")
    if type(original)~="function" then return false end
    local replacement=function(map,...)
        local result=pack(original(map,...))
        if map==MAP and type(result[1])=="string" and result[1]~="" then
            local yes,why=lake_match()
            if yes then
                once("lookup","map name lookup "..TITLE.." ("..why..", was "..result[1]..")")
                result[1]=TITLE
            end
        end
        return unpack(result,1,result.n)
    end
    rawset(mapinfo,key,replacement)
    A.map_lookup_hooked=rawget(mapinfo,key)==replacement
    once("lookuphook",A.map_lookup_hooked and "map name lookup hook on" or "map name lookup hook rejected")
    return A.map_lookup_hooked
end
A.hook_loading_name=hook_loading_name
A.hook_map_lookup=hook_map_lookup
pcall(hook_loading_name)
pcall(hook_map_lookup)
-- [blackwater names end]

-- [blackwater hud begin]
-- Kronos' HUD (Assets/Lua/ui/LUIFPSCounter.lua, unchanged) wraps
-- MenuBuilder.BuildRegisteredType; for the quest widget (5985ec6e703283a7) it
-- looks up its handler with the global ipairs over its KINDS table and calls
-- hideQuest, which moves the native tracker off screen. During a Blackwater
-- match this outer wrapper swaps ipairs only for the duration of that one
-- build: in a table holding the quest and scoreboard-tabs entries, the quest
-- handler is replaced by a no-op and put back right after. Other widgets,
-- maps and the scoreboard Objective tab keep Kronos' behavior.
local QUEST,TABS="5985ec6e703283a7","b77b78aaf5b5d1d1"
local function bypass() end
local function quest_kind(t)
    return t~=nil and string.find(string.lower(tostring(t)),QUEST,1,true)~=nil
end
local function keep_tracker(original)
    return function(t,...)
        if not quest_kind(t) then
            if (A.hud_seen or 0)<3 and in_frontend()==false then
                A.hud_seen=(A.hud_seen or 0)+1
                log("in-match widget type form #"..A.hud_seen..": "..tostring(t))
            end
            return original(t,...)
        end
        local lake,why=lake_match()
        if not lake then return original(t,...) end
        local previous=rawget(G,"ipairs")
        if type(previous)~="function" then return original(t,...) end
        local changed={}
        local wrapper=function(value,...)
            if type(value)=="table" then
                local quest,tabs
                for i=1,32 do
                    local entry=rawget(value,i)
                    if entry==nil then break end
                    if type(entry)=="table" then
                        if rawget(entry,1)==QUEST and type(rawget(entry,2))=="function" then quest=entry end
                        if rawget(entry,1)==TABS then tabs=true end
                    end
                end
                if quest and tabs and rawget(quest,2)~=bypass then
                    changed[#changed+1]={entry=quest,previous=rawget(quest,2)}
                    rawset(quest,2,bypass)
                end
            end
            return previous(value,...)
        end
        rawset(G,"ipairs",wrapper)
        local result=pack(pcall(original,t,...))
        if rawget(G,"ipairs")==wrapper then rawset(G,"ipairs",previous) end
        for i=#changed,1,-1 do
            local item=changed[i]
            if rawget(item.entry,2)==bypass then rawset(item.entry,2,item.previous) end
        end
        A.hud_builds=(A.hud_builds or 0)+1
        once("hudkeep","quest tracker kept on the HUD ("..why..", Kronos hide step skipped: "..tostring(#changed>0)..")")
        if not result[1] then error(result[2],0) end
        return unpack(result,2,result.n)
    end
end
A.keep_tracker=keep_tracker
local function hook_hud()
    local builder=rawget(G,"MenuBuilder")
    local current=type(builder)=="table" and rawget(builder,"BuildRegisteredType")
    if type(current)~="function" then return false end
    if current==A.hud_wrapper then return true end
    local wrapped=keep_tracker(current)
    rawset(builder,"BuildRegisteredType",wrapped)
    if rawget(builder,"BuildRegisteredType")~=wrapped then once("hudhook","HUD hook rejected");return false end
    A.hud_wrapper=wrapped
    A.hud_layers=(A.hud_layers or 0)+1
    once("hudhook","HUD quest hook on (layer "..A.hud_layers..")")
    return true
end
A.hook_hud=hook_hud
pcall(hook_hud)
-- [blackwater hud end]

-- [blackwater mayhem begin]
-- Kronos' Cursed Survival Mayhem module (Assets/Lua/csm_mayhem_relic_post.lua,
-- unchanged) accepts only its own 16 rows. Its prepare is wrapped here for
-- Blackwater requests only (request.record.blackwater_lake); every other
-- request goes to Kronos untouched.
local function relic_chosen(controller)
    local getter=slot(rawget(G,"ZMRELIC"),"0xd2720f9b536bb057")
    if type(getter)~="function" then return false,"relic getter unavailable" end
    local ok,chosen=pcall(getter,controller)
    return ok and chosen==true,tostring(ok)..":"..tostring(chosen)
end
local function lake_prepare(original,csm,request,...)
    if request.resume or request.asset~=CURSED_ASSET then
        return original(request,...)
    end
    local row=ROW_OF[request.id] or request.id
    local chosen,reading=relic_chosen(request.controller)
    if not chosen then
        if type(csm.reset)=="function" then pcall(csm.reset) end
        log("Cursed start "..tostring(row).." without the Mayhem relic ("..reading.."): plain Cursed Survival at the lake")
        return true
    end
    local proxy=copy(request)
    proxy.record={map=request.record.map,poi=ASHWOOD,maxparty=request.record.maxparty}
    local ok,accepted,message=pcall(original,proxy,...)
    if not ok or accepted~=true then
        if type(csm.reset)=="function" then pcall(csm.reset) end
        log("Cursed start "..tostring(row).." with the Mayhem relic: Kronos refused the Ashwood handoff: "
            ..tostring(ok and message or accepted))
        return false,type(message)=="string" and message or "Blackwater Lake Mayhem handoff failed."
    end
    -- 0.3.2: the POI dvar stays zone_lakefront (lake loading screen); the
    -- gameplay helper sets ashwood only around Kronos' own in-match check.
    local route_ok,route_note=set_dvar(ROUTE_KEY,"mayhem")
    if not route_ok then
        if type(csm.reset)=="function" then pcall(csm.reset) end
        set_dvar(ROUTE_KEY,"none")
        log("Cursed start "..tostring(row).." with the Mayhem relic: route dvar not set ("..route_note..")")
        return false,"Blackwater Lake Mayhem could not be armed."
    end
    request.bwl_mayhem=true
    log("Cursed start "..tostring(row).." with the Mayhem relic: armed as Kronos' Ashwood row "..tostring(request.id)
        ..", POI stays the lake")
    return true
end
local function wrap_csm()
    local csm=rawget(G,"CSM_MAYHEM_P1")
    if type(csm)~="table" or type(rawget(csm,"prepare"))~="function" then return false end
    if rawget(csm,"prepare")==A.csm_prepare then return true end
    local original=rawget(csm,"prepare")
    local wrapped=function(request,...)
        if type(request)~="table" or type(request.record)~="table" or request.record.blackwater_lake~=true then
            return original(request,...)
        end
        return lake_prepare(original,csm,request,...)
    end
    rawset(csm,"prepare",wrapped)
    A.csm_prepare=wrapped
    once("csmhook","Mayhem prepare wrapped for Blackwater (module version "..tostring(rawget(csm,"version"))..")")
    return true
end
A.wrap_csm=wrap_csm
pcall(wrap_csm)
-- Every start clears a route left from an earlier start.
local function clear_route(why)
    local value=dvar_text(ROUTE_KEY)
    if value~=nil and value~="" and value~="none" then
        local ok,note=set_dvar(ROUTE_KEY,"none")
        once("routeclear","route dvar "..value.." cleared before "..why..": "..tostring(ok).." "..note)
    end
end
A.clear_route=clear_route
-- [blackwater mayhem end]

local function install()
    if A.installed then return true end
    if rawget(G,"BLACKWATER_LAKE_MOD")~=A then return false end
    local state=rawget(G,"LUMEN_ZM_LOCAL_START")
    local catalogue=type(state)=="table" and rawget(state,"catalogue")
    if type(catalogue)~="table" or type(catalogue.by_id)~="table" or type(catalogue.by_pair)~="table"
        or type(catalogue.publish)~="function" then
        return false
    end
    local engine,lobby,playlist=rawget(G,"Engine"),rawget(G,"Lobby"),rawget(G,"Playlist")
    local play_menu=rawget(G,"PLAY_MENU")
    local constructor=member(member(rawget(G,"LUI"),"DataSourceInGlobalModel"),"new")
    local frontend=slot(engine,"InFrontend")
    local party_id=member(member(lobby,"PartyUIData"),"PLAYLIST_ID")
    local required={{lobby,"0x10ee58fa8f81e28a"},{playlist,"DoPlaylistId"},{playlist,"0x2d93afc74cfe7ce0"},
        {lobby,"0xbe6e03a0292da533"},{play_menu,"0x15b97d8cf426b333"},
        {play_menu,"0x9ae1e225e2dd2df4"},{play_menu,"0x2792b7f52ad7cc62"}}
    for _,item in ipairs(required) do
        if type((slot(item[1],item[2])))~="function" then
            once("install","not installed: "..item[2].." is unavailable");return false
        end
    end
    if type(constructor)~="function" or type(frontend)~="function" or party_id==nil then
        once("install","not installed: model, frontend or party ID is unavailable");return false
    end

    local function read(p)
        local ds=constructor(p);local get=member(ds,"GetValue")
        if type(get)~="function" then error("global model reader unavailable") end
        return get(ds,0)
    end
    local function write(p,value)
        if value==nil then return end
        local ds=constructor(p);local set=member(ds,"SetValue")
        if type(set)~="function" then error("global model writer unavailable") end
        set(ds,0,value)
    end

    local function publish(base)
        if base~=BASE or A.publishing or frontend()~=true then return end
        A.publishing=true
        local ok,why=pcall(function()
            local by_id,by_pair=catalogue.by_id,catalogue.by_pair
            for _,spec in ipairs(ROWS) do
                local source=by_id[spec.source]
                local current=by_id[spec.id]
                if type(source)~="table" or mine(source) or type(source.row)~="table"
                    or type(source.metadata)~="table" then
                    if mine(current) then
                        by_id[spec.id]=nil
                        local key=pair(current.category,current.playlist_index)
                        if by_pair[key]==current then by_pair[key]=nil end
                    end
                    once("row"..spec.id,"row "..spec.id.." waiting for the launcher's "..spec.source)
                elseif current~=nil and not mine(current) then
                    once("row"..spec.id,"row "..spec.id.." is taken by another entry; not added")
                else
                    local prefix=source.prefix
                    local n=read(prefix..".count")
                    if type(n)~="number" or n<0 or n>512 or n%1~=0 then error("invalid row count at "..tostring(prefix)) end
                    local at
                    for p=0,n-1 do
                        if read(prefix..".ID."..p)==spec.id then
                            if at~=nil then error("duplicate row "..spec.id) end
                            at=p
                        end
                    end
                    local card_ref=CARD_PREFIX..spec.id
                    local source_ref=source.row.playMenuRef
                    if source_ref==nil or source_ref==card_ref then error("source card unavailable") end
                    A.card_sources[card_ref]=source_ref;A.card_titles[card_ref]=TITLE
                    local fresh=at~=nil and current~=nil and current.prefix==prefix and current.playlist_index==at
                        and current.template_id==source.template_id and current.category==source.category
                        and read(prefix..".name."..at)==TITLE and read(prefix..".playMenuRef."..at)==card_ref
                    if not fresh then
                        local position=at or n
                        local row={}
                        for _,field in ipairs(FIELDS) do row[field]=source.row[field] end
                        row.ID=spec.id;row.index=position;row.name=TITLE;row.desc=DESC;row.playMenuRef=card_ref
                        row.mapName=source.row.mapName;row.image=IMAGE
                        local metadata=copy(source.metadata)
                        put(metadata,"ID",spec.id);put(metadata,"name",TITLE);put(metadata,"desc",DESC)
                        put(metadata,"playMenuRef",card_ref)
                        for _,field in ipairs(FIELDS) do
                            if field~="ID" then write(prefix.."."..field.."."..position,row[field]) end
                        end
                        write(prefix..".lumenLocalOwner."..position,OWNER)
                        write(prefix..".ID."..position,spec.id)
                        if position>=n then write(prefix..".count",position+1) end
                        if mine(current) then
                            local key=pair(current.category,current.playlist_index)
                            if by_pair[key]==current then by_pair[key]=nil end
                        end
                        local entry={id=spec.id,source_id=spec.source,menu_id=spec.source,template_id=source.template_id,
                            category=source.category,playlist_index=position,template_index=source.template_index,
                            source_category=source.source_category,prefix=prefix,row=row,metadata=metadata,
                            maps=source.maps,category_ref=OWNER}
                        by_id[spec.id]=entry
                        by_pair[pair(source.category,position)]=entry
                        if type(catalogue.unavailable_pairs)=="table" then
                            catalogue.unavailable_pairs[pair(source.category,position)]=nil
                        end
                        once("row"..spec.id,"row "..spec.id.." written at "..tostring(prefix).." #"..position
                            .." beside "..spec.source.." (template "..tostring(source.template_id)..")")
                    end
                end
            end
        end)
        A.publishing=false
        if not ok then once("publish","publish failed: "..tostring(why)) else A.logged.publish=nil end
    end
    A.publish=publish

    -- The launcher's map queries read data.records[row.id], which holds only
    -- its own IDs. During those calls our entry is shown with the source ID.
    local function shielded_pair(original)
        return function(category,index,...)
            local by_pair=catalogue.by_pair;local key=pair(category,index);local entry=by_pair[key]
            if not mine(entry) then return original(category,index,...) end
            local proxy=copy(entry);proxy.id=entry.source_id;by_pair[key]=proxy
            local result=pack(pcall(original,category,index,...))
            if catalogue.by_pair[key]==proxy then catalogue.by_pair[key]=entry end
            if not result[1] then error(result[2],0) end
            return unpack(result,2,result.n)
        end
    end
    local function shielded_id(original)
        return function(id,...)
            local by_id=catalogue.by_id;local entry=by_id[id]
            if not mine(entry) then return original(id,...) end
            local proxy=copy(entry);proxy.id=entry.source_id;by_id[id]=proxy
            local result=pack(pcall(original,id,...))
            if catalogue.by_id[id]==proxy then catalogue.by_id[id]=entry end
            if not result[1] then error(result[2],0) end
            return unpack(result,2,result.n)
        end
    end

    local function select_playlist(controller,id)
        local ds=path(rawget(G,"_DataSources"),"0xf71428806887f67d","0x1ccae3b6ef72f533","0xe14ec899fcdc838f")
        local set=member(ds,"SetValue")
        if type(set)~="function" then error("playlist selection source unavailable") end
        local party_set=slot(lobby,"0xbe6e03a0292da533")
        party_set(party_id,id)
        set(ds,controller,id)
    end

    -- The Ashwood card supplies artwork and other data; our private ref gives
    -- a view of it titled Blackwater Lake.
    hook(play_menu,"0x15b97d8cf426b333",function(original)
        return function(ref,...)
            local source_ref=A.card_sources[ref]
            if source_ref==nil then return original(ref,...) end
            local card=original(source_ref,...)
            if type(card)~="table" and type(card)~="userdata" then return card end
            return setmetatable({blackwater_lake_card=true,blackwater_lake_title=A.card_titles[ref]},
                {__index=function(_,key) return card[key] end})
        end
    end)
    hook(play_menu,"0x9ae1e225e2dd2df4",function(original)
        return function(card,...)
            if type(card)=="table" and rawget(card,"blackwater_lake_card")==true then return rawget(card,"blackwater_lake_title") or TITLE end
            return original(card,...)
        end
    end)
    hook(play_menu,"0x2792b7f52ad7cc62",function(original)
        return function(card,...)
            if type(card)=="table" and rawget(card,"blackwater_lake_card")==true then return DESC end
            return original(card,...)
        end
    end)

    hook(playlist,"DoPlaylistId",function(original)
        return function(id,...)
            local source=SOURCE[id]
            if not source or not mine(catalogue.by_id[id]) then
                if not (type(state.request)=="table") then pcall(clear_route,"start "..tostring(id)) end
                return original(id,...)
            end
            pcall(clear_route,"Blackwater start "..tostring(id))
            pcall(wrap_csm)
            local controller=state.scope or state.controller or 0
            local ok,why=pcall(select_playlist,controller,source)
            if not ok then once("start","start not redirected: "..tostring(why));return end
            local before=state.request
            local result=pack(original(source,...))
            local request=state.request
            if type(request)=="table" and request~=before and request.id==source then
                local changed,record=pcall(lake_record,request.record)
                if changed then
                    request.record=record;request.blackwater_lake=true;request.blackwater_row=id
                    log("start "..id.." -> launcher Ashwood "..source.." with POI "..POI)
                else log("start "..id.." left as plain Ashwood: "..tostring(record)) end
            else
                pcall(select_playlist,controller,id)
                log("start "..id.." was not scheduled by the launcher")
            end
            return unpack(result,1,result.n)
        end
    end)
    local function lake_row()
        local request=state.request
        if type(request)=="table" and request.blackwater_lake==true then return ROW_OF[request.id],request.id,request end
    end
    -- The lobby's game type, as the mode line reads it.
    local function lobby_gametype(controller)
        local conditions=rawget(G,"CONDITIONS")
        local online=slot(conditions,"0x112586a3f4fb490e")
        if type(online)=="function" then
            local ok,yes=pcall(online)
            if ok and yes then
                local ds=path(rawget(G,"DataSources"),"frontEnd","lobby","gameType")
                local get=member(ds,"GetValue")
                if type(get)=="function" then
                    local got,value=pcall(get,ds,controller)
                    if got then return value,"lobby" end
                end
            end
        end
        local current=slot(lobby,"0xcfc38819ea2193ba")
        if type(current)=="function" then
            local got,value=pcall(current)
            if got then return value,"current" end
        end
        return nil,"none"
    end
    local function start_type(value,request)
        local record=request.record
        local asset=type(record)=="table" and record.asset
        if value==nil or type(asset)~="string" then return false end
        if value==asset or tostring(value)==asset then return true end
        local push=type(C)=="table" and C.PushXHashAsset
        if type(push)=="function" then
            local ok,h=pcall(push,asset)
            if ok and h~=nil then
                if value==h or tostring(h)==tostring(value) then return true end
                local digits=string.match(string.lower(tostring(h)),"(%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x)$")
                if digits and string.sub(string.lower(tostring(value)),-#digits)==digits then return true end
            end
        end
        return false
    end
    if type((slot(play_menu,"0x38eb2c388629179b")))=="function" then
        hook(play_menu,"0x38eb2c388629179b",function(original)
            return function(controller,...)
                local row,source,request=lake_row()
                if row and start_type(lobby_gametype(controller),request) then
                    local get=slot(play_menu,"0x15b97d8cf426b333")
                    local card=type(get)=="function" and get(CARD_PREFIX..row)
                    if card~=nil then
                        once("lobbycard","lobby card titled "..TITLE.." for start "..tostring(source))
                        return card
                    end
                    once("lobbycard","lobby card for start "..tostring(source).." unavailable")
                else A.logged.lobbycard=nil end
                return original(controller,...)
            end
        end)
    else
        once("lobbyhook","lobby card query unavailable; the about-to-begin name stays the game's")
    end
    local mp=rawget(G,"MP")
    if type((slot(mp,"0xa781132808ca573a")))=="function" then
        hook(mp,"0xa781132808ca573a",function(original)
            return function(controller,...)
                local result=pack(original(controller,...))
                local row,source,request=lake_row()
                if row and start_type((lobby_gametype(controller)),request) and type(result[1])=="string" and result[1]~="" then
                    once("lobbyname","lobby map name "..TITLE.." for start "..tostring(source))
                    result[1]=TITLE
                end
                return unpack(result,1,result.n)
            end
        end)
    else
        once("lobbyname","lobby map name query unavailable")
    end
    -- The lobby card's picture: while our start runs and the card reads our
    -- name, the picture is the Blackwater pyramid (images/blackwater_lake_save.png).
    local function card_picture()
        if A.card_picture~=nil then return A.card_picture end
        local asset=rawget(G,"xhashasset") or (type(C)=="table" and C.PushXHashAsset)
        local register=rawget(G,"RegisterMaterial")
        if type(asset)~="function" or type(register)~="function" then
            once("lobbypicture","lobby card picture kept: image interface unavailable");return nil
        end
        local named,value=pcall(asset,IMAGE)
        if not named or value==nil then
            once("lobbypicture","lobby card picture kept: "..IMAGE.." not named: "..tostring(value));return nil
        end
        local made,why=pcall(register,value)
        if not made then
            once("lobbypicture","lobby card picture kept: "..IMAGE.." unavailable: "..tostring(why));return nil
        end
        A.card_picture=value
        return value
    end
    if type((slot(lobby,"0xd09afe8ce7a0ee8a")))=="function" then
        hook(lobby,"0xd09afe8ce7a0ee8a",function(original)
            return function(...)
                local result=pack(original(...))
                if result[1]==TITLE and lake_row() then
                    local picture=card_picture()
                    if picture~=nil then
                        result[2]=picture
                        if result.n<2 then result.n=2 end
                        once("lobbypicture","lobby card picture "..IMAGE)
                    end
                end
                return unpack(result,1,result.n)
            end
        end)
    else
        once("lobbypicture","lobby card picture query unavailable; the game's picture stays")
    end
    hook(playlist,"0x2d93afc74cfe7ce0",shielded_pair)
    for _,key in ipairs({"0x3ea93feae1aa4d9e","0xda449b9851cf679e"}) do
        if type((slot(playlist,key)))=="function" then hook(playlist,key,shielded_id) end
    end
    hook(lobby,"0x10ee58fa8f81e28a",function(original)
        return function(base,...)
            local result=pack(original(base,...))
            publish(base)
            return unpack(result,1,result.n)
        end
    end)
    local utils=rawget(G,"PlaylistUtils")
    if type((slot(utils,"0xeda10385e76d30fe")))=="function" then
        hook(utils,"0xeda10385e76d30fe",function(original)
            return function(...)
                local result=pack(original(...))
                publish(BASE)
                return unpack(result,1,result.n)
            end
        end)
    end
    -- Squad rows (Rex Arena 0.6.5): when the party setting changes, the
    -- launcher re-makes its own rows from another template just before the map
    -- list is built; ours are re-made before the list and, if the launcher's
    -- rows changed while it was built, the list is built again.
    local function menu_templates()
        local key=""
        for _,spec in ipairs(ROWS) do
            local source=catalogue.by_id[spec.source]
            key=key..tostring(type(source)=="table" and source.template_id or "none")..";"
        end
        return key
    end
    if type((slot(lobby,"0x0abec982187838da")))=="function" then
        hook(lobby,"0x0abec982187838da",function(original)
            return function(...)
                local args=pack(...)
                publish(BASE)
                local before=menu_templates()
                local result=pack(original(unpack(args,1,args.n)))
                local after=menu_templates()
                if after~=before then
                    publish(BASE)
                    once("squadlist","map list built again: the launcher's rows changed template ("..before.." -> "..after..")")
                    result=pack(original(unpack(args,1,args.n)))
                end
                return unpack(result,1,result.n)
            end
        end)
    else
        once("squadlist","map list query unavailable; the squad rows follow the launcher on category refresh only")
    end
    A.installed=true
    log(A.version.." installed on launcher "..tostring(rawget(state,"version")))
    publish(BASE)
    return true
end
A.install=install

local function try_install()
    local ok,result=pcall(install)
    if not ok then once("install","install failed: "..tostring(result));return false end
    return result
end
A.try_install=try_install

local K=rawget(G,"KRONOS")
if type(K)=="table" and type(K.onRequire)=="function" then
    K.onRequire(function()
        if not A.loading_hooked then pcall(hook_loading_name) end
        if not A.map_lookup_hooked then pcall(hook_map_lookup) end
        pcall(hook_hud)
        pcall(wrap_csm)
        if not A.installed then try_install() end
    end)
end
if not try_install() then once("wait","waiting for the Kronos launcher") end
end
