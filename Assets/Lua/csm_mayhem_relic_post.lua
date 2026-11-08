 
 
local clua=rawget(_G,"CLUA")
local H=type(clua)=="table" and clua.PushXHash or rawget(_G,"xhash")
if type(H)~="function" then return end
if rawget(_G,"CSM_MAYHEM_P1") then return end
local P={version=16};rawset(_G,"CSM_MAYHEM_P1",P)
local function pack(...)return {n=select("#",...),...}end
local function get(t,k)
    if t==nil then return nil end
    local ok,v=pcall(function()return t[k]end);if ok and v~=nil then return v,k end
    ok,v=pcall(function()return t[H(k)]end);if ok then return v,H(k)end
end
local function path(t,...)
    for _,k in ipairs({...})do t=get(t,k);if t==nil then return nil end end
    return t
end

local CS="0x0ec021cc68429ef4"
local CURSED="0x6c9c9d63be56f61d"
local function isCategory(v,hex,name)
    if v==name then return true end
    local ctor=type(clua)=="table"and clua.PushXHashAsset
    if type(ctor)~="function"then return false end
    local ok,ref=pcall(ctor,hex);return ok and v==ref
end
local function categoryNode()
    return path(rawget(_G,"_DataSources"),"0x08f73707b5922e00","0xf71428806887f67d","0xe31bc6e346e6be47","0x27bcf3f1bd325909")
end
local function currentCS(controller)
    local node=categoryNode();local f=get(node,"GetValue")
    if type(f)~="function"then return false end
    local ok,v=pcall(f,node,controller)
    return ok and isCategory(v,CS,"sat_zm_category_r_mod_survival")
end
local scope
local installed=setmetatable({},{__mode="k"})
local function wrap(owner,key,make)
    if owner==nil then return end
    if type(owner)~="table"then return end
    local original,slot=rawget(owner,key),key
    if original==nil then slot=H(key);original=rawget(owner,slot)end
    if type(original)~="function"then return end
    local marks=installed[owner]or{};installed[owner]=marks
    if marks[slot]==original then return end
    local replacement=make(original)
    local ok=pcall(function()owner[slot]=replacement end)
    if ok and rawget(owner,slot)==replacement then marks[slot]=replacement
    else
        P.hookErrors=P.hookErrors or {}
        if not P.hookErrors[key]then P.hookErrors[key]=true;end
    end
end
local function asset(v,name)
    if v==name then return true end
    local clua=rawget(_G,"CLUA");local f=get(clua,"PushXHashAsset")
    if type(f)~="function"then return false end
    local ok,h=pcall(f,name);return ok and v==h
end
local function project(value,depth)
    if type(value)~="table"or depth>4 then return value end
    local out
    for k,v in pairs(value)do
        local nextValue=v
        if (k=="gametypeAssetName"or k==H("gametypeAssetName"))and asset(v,"zm_rb_r_mod_survival")then
            if type(v)=="string"then nextValue="zm_rb_rh_mod"
            else nextValue=rawget(_G,"CLUA").PushXHashAsset("zm_rb_rh_mod")end
        elseif type(v)=="table"then nextValue=project(v,depth+1)end
        if nextValue~=v then
            if not out then out={};for key,item in pairs(value)do out[key]=item end end
            out[k]=nextValue
        end
    end
    return out or value
end
function P.projectMaps(maps,controller)
    if type(controller)~="number"or not currentCS(controller)then return maps end
    return project(maps,0)
end
local KEYS={["csm_s1_ack"]="0x22e2fd409b215382",["csm_s1_armed"]="0x4df930eb0fd35efc",["csm_s1_cancel"]="0xf22a634abfe3e1bb",["csm_s1_last_active"]="0x4be288765283c574",["csm_s1_last_load"]="0x514a6ae7e5a1e22a",["csm_s1_last_map"]="0x6277c0fb7148f4fc",["csm_s1_last_mrp"]="0x62cbd2fb71a5f387",["csm_s1_last_party"]="0x7485ca1b94ca011e",["csm_s1_last_poi"]="0xbff510fa3f524086",["csm_s1_last_selection"]="0x5d0aba59a7cb36c4",["csm_s1_load"]="0x01f81189b2a686e9",["csm_s1_map"]="0x5ab09440c3375611",["csm_s1_mrp"]="0x5a6e9a40c2eec9aa",["csm_s1_party"]="0x0d23bf2ec7903c77",["csm_s1_poi"]="0x15f18c414bfc87eb",["csm_s1_protocol"]="0x07c0ed8f289cf2f5",["csm_s1_pump"]="0xb68e349b2f55d72b",["csm_s1_ready"]="0xc4b72492e1380ab4",["csm_s1_request"]="0x3542944c39af6cb2",["csm_s1_request_load"]="0xbe33cf0ffcc5320f",["csm_s1_result"]="0x96f090ba70f3ec44",["csm_s1_route"]="0xea81657d4d8da1de",["csm_s1_seen"]="0x2cc800b7a58fdd2a",["csm_s1_selection"]="0xf541971810a2c835",["csm_s1_status"]="0xed9b0e46d505c12f",["s1_engine_load"]="0x89cdd504cc46b123",["s1_engine_gt"]="0xe65e9a96eb2ff62b",["csm_r1_active"]="0xf74a4b36f3a781b8",["csm_p1_armed"]="0x2ba0ca3d1e8f6f1f",["csm_p1_protocol"]="0x687622af114ef240",["csm_p1_selection"]="0xd0a79432776e0aba",["csm_p1_map"]="0xa88c0d1990ecd13a",["csm_p1_poi"]="0x78cdad18b29baa30",["csm_p1_party"]="0x9d678d9aee6c65d8",["csm_p1_relic"]="0x102e10b8f7a26aaf",["csm_p1_serial"]="0x804bdcd886c4d398",["csm_p1_consumed"]="0x89de0ada1dc3797a",["csm_p1_status"]="0x76e3471bac6907be"}
local NUMERIC={armed=true,protocol=true,selection=true,party=true,relic=true,serial=true,consumed=true}
local function native(owner,hex,alias)
    if type(owner)~="table"then return nil end
    local f=rawget(owner,H(hex))
    if type(f)=="function"then return f end
    if alias then f=rawget(owner,alias);if type(f)=="function"then return f end end
    return nil
end
local function key(name)
    local hex=KEYS[name];local ctor=type(clua)=="table"and clua.PushXHashDvar
    if not hex or type(ctor)~="function"then return nil end
    local ok,value=pcall(ctor,hex);if ok then return value end
    return nil
end
local function read(name)
    local k=key(name);if k==nil then return nil,"hash_unavailable"end
    local d=rawget(_G,"Dvar");local exists=native(d,"0xe1fab6d9a30481f8","DvarExists")
    if type(exists)=="function"then
        local ok,present=pcall(exists,k)
        if ok and present==false then return nil,"absent"end
        if not ok then return nil,"existence_error"end
    end
    local getString=native(d,"0x254084d7ca2317bb","GetDvarString")
    if type(getString)=="function"then
        local ok,value=pcall(getString,k)
        if ok and type(value)=="string"then return value,"present"end
    end
    if name:match("^csm_s1_")and not ({map=true,load=true,route=true,poi=true})[name:match("^csm_s1_(.+)$")] or name=="csm_r1_active"or NUMERIC[name:match("^csm_p1_(.+)$")]then
        local getInt=native(d,"0x622eaab59aa27e9b","GetDvarInt")
        if type(getInt)=="function"then
            local ok,value=pcall(getInt,k)
            if ok and type(value)=="number"then return string.format("%.0f",value),"present"end
        end
    end
    return nil,"unreadable"
end
local function write(name,value)
    local hex=KEYS[name];local k=key(name)
    if not hex or k==nil then return false end
    local text=type(value)=="number"and string.format("%.0f",value)or tostring(value)
    if #text>80 or not text:match("^[%w_:%-]+$")then return false end
    local before,presence=read(name)
    if before==text then return true end
     
     
    local setter=native(rawget(_G,"Dvar"),"0x1e3cb005036e0c0f","SetDvarString")
    if presence=="present"and type(setter)=="function"then
        pcall(setter,k,text)
        if read(name)==text then return true end
    end
    local exec=native(rawget(_G,"Engine"),"0xeb81a5136c5503e4","ExecNow")
    local returned
    if type(exec)=="function"then
         
        local ok,result=pcall(exec,'set #x3'..hex:sub(3)..' "'..text..'"',0)
        returned=ok and tostring(result)or tostring(result)
        if ok and result~=false and read(name)==text then return true end
    else returned="ExecNow_missing"end
    local after,state=read(name)
    
    return false
end
local ALLOWED={[1000000202]={map="zm_sat_firefly",poi="zone_lakefront",maxparty=1},[1000000203]={map="zm_sat_firefly",poi="zone_lakefront",maxparty=4},[1000000062]={map="zm_sat_firefly",poi="zone_farm",maxparty=1},[1000000063]={map="zm_sat_firefly",poi="zone_farm",maxparty=4},[1000000064]={map="zm_sat_firefly",poi="zone_launchpad",maxparty=1},[1000000065]={map="zm_sat_firefly",poi="zone_launchpad",maxparty=4},[1000000066]={map="zm_sat_firefly",poi="zone_exit115",maxparty=1},[1000000067]={map="zm_sat_firefly",poi="zone_exit115",maxparty=4},[1000000068]={map="zm_sat_firefly",poi="ashwood",maxparty=1},[1000000069]={map="zm_sat_firefly",poi="ashwood",maxparty=4},[1000000070]={map="zm_sat_ruby",poi="zone_temple",maxparty=1},[1000000071]={map="zm_sat_ruby",poi="zone_temple",maxparty=4},[1000000072]={map="zm_sat_mantis",poi="future",maxparty=1},[1000000073]={map="zm_sat_mantis",poi="future",maxparty=4},[1000000074]={map="zm_sat_locust",poi="zone_lighthouse",maxparty=1},[1000000075]={map="zm_sat_locust",poi="zone_lighthouse",maxparty=4},[1000000076]={map="zm_sat_hornet",poi="castle",maxparty=1},[1000000077]={map="zm_sat_hornet",poi="castle",maxparty=4}}
local function resetRestart()
    local value,state=read("csm_r1_active")
    if state=="absent"or value=="0"then return true end
    return write("csm_r1_active",0)
end
function P.reset()
    local cleared=resetRestart()
    local value,state=read("csm_p1_armed")
     
    if state=="absent"or value=="0"then return cleared end
    return write("csm_p1_armed",0)and cleared
end
function P.prepare(request)
    if type(request)~="table"or request.resume or request.asset~="zm_rb_r_mod_survival"then
         
         
        P.reset()
        return true
    end
    local relic=rawget(_G,"ZMRELIC");local getter=get(relic,"0xd2720f9b536bb057")
    local ok,chosen=false,nil
    if type(getter)=="function"then ok,chosen=pcall(getter,request.controller)end
    if not ok or chosen~=true then
        if not P.reset()then return false,"A previous Mayhem request could not be disarmed."end
        
        return true
    end
    if not P.reset()then return false,"The Mayhem handoff could not be disarmed."end
    local record=ALLOWED[request.id]
    if not record or type(request.record)~="table"or request.record.map~=record.map or
        request.record.poi~=record.poi or request.record.maxparty~=record.maxparty then
        return false,"The Cursed Survival selection does not match this prototype."
    end
    if not currentCS(request.controller)then return false,"The Cursed Survival relic context changed."end
    local serial=(tonumber((read("csm_p1_serial")))or 0)+1
    if serial>1000000 then serial=1 end
    local values={{"protocol",1},{"selection",request.id},{"map",record.map},{"poi",record.poi},
        {"party",record.maxparty},{"relic",1},{"serial",serial}}
    for _,pair in ipairs(values)do
        if not write("csm_p1_"..pair[1],pair[2])then
            P.reset();return false,"The optional Mayhem handoff failed at "..pair[1].."."
        end
    end
    if not write("csm_p1_armed",1)then return false,"The Mayhem request could not be committed."end
    
    return true
end
 
local originalReset=P.reset
local function clearSaveKey(name)
    local value,state=read(name)
    if state=="absent"or value=="0"then return true end
    return write(name,0)
end
function P.reset()
    local a=clearSaveKey("csm_s1_armed")
    local b=clearSaveKey("csm_s1_last_active")
    local c=clearSaveKey("csm_s1_ready")
    return originalReset()and a and b and c
end
local originalPrepare=P.prepare
function P.prepare(request)
    local accepted,message=originalPrepare(request)
    if accepted~=true then return accepted,message end
    if type(request)~="table"or request.asset~="zm_rb_r_mod_survival"then return true end
    local row=ALLOWED[request.id]
    if not row or type(request.record)~="table"or request.record.map~=row.map or
        (not request.resume and (request.record.poi~=row.poi or request.record.maxparty~=row.maxparty))then
        return false,"The Cursed Survival save context does not match this selection."
    end
    local token=read("s1_engine_load")
    local route=request.resume and "resume"or "fresh"
    if type(token)~="string"or not token:match(request.resume and "^1:%d+$"or "^0:%d+$")then
        return false,"The native saved-game launch token is unavailable."
    end
    local chosen=not request.resume and read("csm_p1_armed")=="1"and read("csm_p1_relic")=="1"
    local values={{"protocol",1},{"map",row.map},{"load",token},{"route",route},
        {"selection",request.resume and 0 or request.id},{"poi",request.resume and "native"or row.poi},
        {"party",request.resume and 0 or row.maxparty},{"mrp",chosen and 1 or 0}}
    for _,pair in ipairs(values)do
        if not write("csm_s1_"..pair[1],pair[2])then
            P.reset();return false,"The Cursed Survival save handoff failed at "..pair[1].."."
        end
    end
    if not write("csm_s1_armed",1)then P.reset();return false,"The save handoff could not be armed."end
    
    return true
end

local function inFrontend()
    local f=native(rawget(_G,"Engine"),"0x112586a3f4fb490e","InFrontend")
    if type(f)~="function"then return nil end
    local ok,value=pcall(f)
    if not ok or type(value)~="boolean"then return nil end
    return value
end
local function saveFailure(message)
    local pending=P.savePending;P.savePending=nil
    if pending and tonumber((read("csm_s1_ack")))~=pending.sequence then
         
         
        write("csm_s1_cancel",pending.sequence)
        if tonumber((read("csm_s1_request")))==pending.sequence then write("csm_s1_request",0)end
    end
    local k=rawget(_G,"KRONOS_RETAIL_K1")
    if type(k)=="table"then
        k.savePending=nil
        if type(k.saveError)=="function"then return k.saveError(message)end
    end
    return false
end
function P.requestCheckpointSave()
    local k=rawget(_G,"KRONOS_RETAIL_K1")
    if type(k)~="table"or not k.enabled then return false end
    if P.savePending or k.savePending then return false end
    if inFrontend()~=false or read("csm_s1_ready")~="1"or read("csm_s1_pump")~="1"then
        return saveFailure("Cursed Survival save helper is not ready. No save or quit was requested.")
    end
    if type(k.saveContextReady)~="function"or k.saveContextReady()~=true then
        return saveFailure("Kronos's native save context is unavailable. The match has not been ended.")
    end
    local close=path(rawget(_G,"LUI"),"FlowManager","RequestCloseAllMenus")
    if type(close)~="function"then return saveFailure("The original pause-menu close function is unavailable.")end
    local seq=math.max(tonumber((read("csm_s1_ack")))or 0,
        tonumber((read("csm_s1_request")))or 0,P.lastSaveRequest or 0)+1
    if seq<1 or seq>1000000 then seq=1 end
    P.lastSaveRequest=seq
    P.savePending={sequence=seq,elapsed=0,token=read("s1_engine_load")}
    k.savePending=true
    if not write("csm_s1_cancel",0)or not write("csm_s1_request_load",P.savePending.token)or
        not write("csm_s1_request",seq)then
        return saveFailure("The Cursed Survival save request could not be published.")
    end
     
     
    local ok,result=pcall(close)
    if not ok or result==false then return saveFailure("The pause menu could not be released for saving.")end
    
    return true
end
function P.installSave()
    local k=rawget(_G,"KRONOS_RETAIL_K1")
    if type(k)~="table"then return end
    P.installNativeResume(k)
    wrap(k,"dispatchSave",function(original)return function(...)
        if read("s1_engine_gt")~="zm_rb_r_mod_survival"then return original(...)end
        local status=read("csm_s1_status")
         
         
        if status=="legacy_native_resume_no_matching_companion"then return original(...)end
        return P.requestCheckpointSave()
    end end)
end
function P.pollSave()
    P.installSave()
    local status=read("csm_s1_status")
    
    local pending=P.savePending
    if not pending then return end
    local k=rawget(_G,"KRONOS_RETAIL_K1")
    if inFrontend()==true then P.savePending=nil;if type(k)=="table"then k.savePending=nil end;return end
    pending.elapsed=pending.elapsed+500
    if read("s1_engine_load")~=pending.token then return saveFailure("The saved-game context changed while saving.")end
    if tonumber((read("csm_s1_ack")))==pending.sequence then
        local result=tonumber((read("csm_s1_result")))
        if result~=1 then
            return saveFailure("The save was stopped before quitting: "..tostring(status)..". No quit was requested.")
        end
        P.savePending=nil
        if type(k)=="table"then k.savePending=true end
         
         
        local d=rawget(_G,"Dvar");local set=native(d,"0xf2414681ecab880f")
        if type(set)=="function"then pcall(set,H("0xbe9a1a5090f1172b",1),1)end
        local close=path(rawget(_G,"LUI"),"FlowManager","RequestCloseAllMenus")
        if type(close)=="function"then pcall(close)end
        
        return true
    end
    if pending.elapsed>=10000 then
        return saveFailure("The game did not confirm the save. No quit was requested; retry from the pause menu.")
    end
end

 
 
 
function P.prepareNativeResume(request)
    local k=rawget(_G,"KRONOS_RETAIL_K1")
    if type(k)~="table"or k.nativeResume~=request or not k.enabled or inFrontend()~=true then
        return false,"The native saved-game request is no longer active."
    end
    local row=type(request)=="table"and ALLOWED[request.id]
    if not row or request.asset~="zm_rb_r_mod_survival"or request.gt~="zm_rb_r_mod_survival"or
        row.map~=request.map or type(request.ownedLoad)~="string"or not request.ownedLoad:match("^1:%d+$")or
        read("s1_engine_load")~=request.ownedLoad then
        return false,"The Cursed Survival native resume identity is unavailable."
    end
    if read("csm_s1_armed")=="1"and read("csm_s1_protocol")=="1"and
        read("csm_s1_route")=="resume"and read("csm_s1_map")==request.map and
        read("csm_s1_load")==request.ownedLoad then
        P.nativeResumeOwner=request;return true
    end
     
     
    local ok,message=P.prepare({id=request.id,controller=request.controller,asset=request.asset,
        record={map=request.map},resume={map=request.map,asset=request.asset}})
    if ok~=true then return false,message end
    if read("csm_s1_armed")~="1"or read("csm_s1_route")~="resume"or
        read("csm_s1_load")~=request.ownedLoad then
        return false,"The native Cursed Survival resume handoff did not read back."
    end
    P.nativeResumeOwner=request
    
    return true
end
local function clearNativeResume(request)
    if P.nativeResumeOwner~=request then return end
    P.nativeResumeOwner=nil
    if read("csm_s1_route")=="resume"and read("csm_s1_map")==request.map and
        read("csm_s1_load")==request.ownedLoad then
        clearSaveKey("csm_s1_armed")
    end
end
function P.installNativeResume(k)
    wrap(k,"tickNativeResume",function(original)return function(request,...)
        local core=rawget(_G,"LUMEN_ZM_LOCAL_START")
        if type(request)=="table"and k.nativeResume==request and k.enabled and
            not request.inStart and not request.submitted and not (core and core.request)and
            request.asset=="zm_rb_r_mod_survival"and request.gt=="zm_rb_r_mod_survival"and
            request.ownedLoad and inFrontend()==true then
            local accepted,message=P.prepareNativeResume(request)
            if accepted~=true then
                clearNativeResume(request)
                if type(k.cancelNativeResume)=="function"then
                    return k.cancelNativeResume(request,message or "The Cursed Survival resume handoff failed.",true)
                end
                return saveFailure(message or "The Cursed Survival resume handoff failed.")
            end
        end
        return original(request,...)
    end end)
    wrap(k,"cancelNativeResume",function(original)return function(request,...)
        local result=pack(original(request,...))
        if type(request)=="table"and k.nativeResume~=request then
            if not request.submitted then clearNativeResume(request)
            elseif P.nativeResumeOwner==request then P.nativeResumeOwner=nil end
        end
        return unpack(result,1,result.n)
    end end)
end

local disabledKey
do
    local ok,reader=pcall(load,"\027\076\074\132\026\025\000\000\002\000\001\000\002\040\000\000\000\077\000\002\000\004\001\062\079\092\155\172\052\021\144\000")
    if ok and type(reader)=="function"then
        local passed,value=pcall(reader);if passed then disabledKey=value end
    end
end
function P.install()
    if P.installSave then P.installSave()end
    local relic=rawget(_G,"ZMRELIC")
    wrap(relic,"0x60e2e1c5dc3d4efa",function(original)return function(ref,...)
        if isCategory(ref,CS,"sat_zm_category_r_mod_survival")then return true end
        return original(ref,...)
    end end)
    wrap(relic,"0x2f122afcc2782c19",function(original)return function(controller,...)
        if not currentCS(controller)then return original(controller,...)end
         
         
        local disable=get(rawget(_G,"Dvar"),"0xc9e5be3b4bba4e0e")
        local condition=get(rawget(_G,"CONDITIONS"),"0x112586a3f4fb490e")
        local private=get(rawget(_G,"Lobby"),"0x96957722ef74f5d2")
        local selected=get(rawget(_G,"Playlist"),"0x97b3b2b73b53eb34")
        local maps=get(rawget(_G,"PlaylistUtils"),"0x0d5bbfe3c6067a59")
        local supported=get(rawget(_G,"PlaylistUtils"),"0xad23584c54c46f40")
        if disabledKey==nil or type(disable)~="function"or type(condition)~="function"or type(private)~="function"or
            type(selected)~="function"or type(maps)~="function"or type(supported)~="function"then
            return original(controller,...)
        end
        if disable(disabledKey,false)then return false end
        if not condition()then return true end
        if private()then return true end
        local id=selected()
        if id==0 then return true end
        local previous=scope;scope=controller
        local result=pack(pcall(function()
            local rows=maps(controller,id)
            if not rows then return true end
            return not supported(controller,rows,get(rawget(_G,"ZMRELIC"),"0xfa8ccdebae1565c1"))
        end));scope=previous
        if not result[1]then error(result[2],0)end
        return unpack(result,2,result.n)
    end end)
    wrap(rawget(_G,"PlaylistUtils"),"0x0d5bbfe3c6067a59",function(original)return function(controller,...)
        local result=pack(original(controller,...))
        if scope~=nil and scope==controller then result[1]=project(result[1],0)end
        return unpack(result,1,result.n)
    end end)
end
 
function P.poll() P.install();P.pollSave() end
function P.attach(root)
    if root==nil then
        local f=path(rawget(_G,"LUI"),"UIRoot","GetRootForControllerIndex")
        if type(f)=="function"then local ok,r=pcall(f,0);if ok then root=r end end
    end
    if root==nil then return false end
    if P.root==root and P.runner~=nil then return true end
    local make=path(rawget(_G,"LUI"),"UIElement","new");local add=get(root,"addElement")
    if type(make)~="function"or type(add)~="function"then return false end
    local ok,runner=pcall(make);if not ok or runner==nil then return false end
    if not pcall(add,root,runner)then return false end
    P.root,P.runner=root,runner
    local function tick()
        if P.runner~=runner then return end
        pcall(P.poll)
        local wait=get(runner,"Wait")
        if type(wait)=="function"then
            local made,timer=pcall(wait,runner,500)
            if made and timer~=nil then pcall(function()timer.onComplete=tick end)end
        end
    end
    tick();return true
end
local menuBuilders=setmetatable({},{__mode="k"})
local function relicMenu(ref)return ref=="RelicSelectMenu"or ref==H("0xa9dc6b835240282b")end
local function beforeRelic() P.install() end
local function hookBuilder(builder)
    if type(builder)~="table"or menuBuilders[builder]then return end
    menuBuilders[builder]=true
     
     
     
    wrap(builder,"registerType",function(original)return function(ref,constructor,...)
        if relicMenu(ref)and type(constructor)=="function"then
            local build=constructor
            constructor=function(...)beforeRelic();return build(...)end
        end
        return original(ref,constructor,...)
    end end)
    wrap(builder,"BuildRegisteredType",function(original)return function(ref,...)
        P.install();if relicMenu(ref)then beforeRelic()end
        local result=pack(original(ref,...));P.install();P.attach();return unpack(result,1,result.n)
    end end)
end
P.install()
hookBuilder(rawget(_G,"MenuBuilder"))
hookBuilder(get(rawget(_G,"LUI"),"MenuBuilder"))
wrap(path(rawget(_G,"LUI"),"UIRoot"),"new",function(original)return function(...)
    local result=pack(original(...));P.attach(result[1]);return unpack(result,1,result.n)
end end)
P.attach()



 
do
 local C={version="C5",build="C5-20261102",cards=setmetatable({},{__mode="k"}),tiers=setmetatable({},{__mode="k"}),names=setmetatable({},{__mode="k"}),tierTexts=setmetatable({},{__mode="k"}),breadcrumbs=setmetatable({},{__mode="k"}),controllers={[0]=true}}
 P.presentation=C
 local function owner(name)return rawget(_G,name)end
 local function call(t,k,...)
  local f=get(t,k);if type(f)~="function"then return false end
  return pcall(f,...)
 end
 local function front()
  local ok,v=call(owner("Engine"),"InFrontend")
  if not ok then ok,v=call(owner("Engine"),"0x112586a3f4fb490e")end
  if ok and type(v)=="boolean"then return v end
 end
 local dkeys={}
 local dnames={engine_map="0xa29c4a22748b998f",g_mapname="0x687fb8f9b7a23245",ui_mapname="0xef237da69bb64ef6",csm_c1_active="0xc275a6196ec42d5f",csm_c1_map="0x7bc9dcdec9171781"}
 local function dkey(name)
  if not dkeys[name]and type(clua)=="table"and type(clua.PushXHashDvar)=="function"then
   local ok,key=pcall(clua.PushXHashDvar,dnames[name]or name);if ok then dkeys[name]=key end
  end
  return dkeys[name]
 end
 local function dint(name)
  local k=dkey(name);if not k then return end
  local ok,v=call(owner("Dvar"),"0x622eaab59aa27e9b",k,0)
  if ok and type(v)=="number"then return v end
 end
 local function dstring(name)
  local k=dkey(name);if not k then return end
  local ok,v=call(owner("Dvar"),"0x254084d7ca2317bb",k)
  if ok and type(v)=="string"then return v end
 end
 local function clearMarker()
  local e=owner("Engine");local f=get(e,"0xeb81a5136c5503e4")or get(e,"ExecNow")
  if type(f)=="function"then
   if dint("csm_c1_active")==1 then pcall(f,"set csm_c1_active 0")end
   if dstring("csm_c1_map")and dstring("csm_c1_map")~="none"then pcall(f,"set csm_c1_map none")end
  end
 end
 local priorPrepare=P.prepare
 function P.prepare(request,...)
  local result=pack(priorPrepare(request,...))
  C.ticket=nil
  if result[1]==true and type(request)=="table"and request.asset=="zm_rb_r_mod_survival"and not request.resume then
   C.ticket={request=request,map=request.record.map,load=read("s1_engine_load"),mrp=read("csm_s1_mrp")=="1"}
  end
  return unpack(result,1,result.n)
 end
 local priorReset=P.reset
 function P.reset(...)
  C.ticket=nil
  if front()==true then clearMarker()end
  return priorReset(...)
 end
 local function committedFresh()
   
   
  if read("csm_s1_armed")~="1"or read("csm_s1_protocol")~="1"or
   read("csm_s1_route")~="fresh"or read("csm_s1_mrp")~="1"or
   read("csm_p1_armed")~="1"or read("csm_p1_protocol")~="1"or read("csm_p1_relic")~="1"then return false end
  local token=read("s1_engine_load")
  if type(token)~="string"or not token:match("^0:%d+$")or read("csm_s1_load")~=token then return false end
  local selection=read("csm_s1_selection")
  local row=ALLOWED[tonumber(selection)]
  if not row or read("csm_p1_selection")~=selection then return false end
  for _,key in ipairs({"map","poi","party"})do
   local expected=tostring(key=="party"and row.maxparty or row[key])
   if read("csm_s1_"..key)~=expected or read("csm_p1_"..key)~=expected then return false end
  end
  local serial=tonumber((read("csm_p1_serial")))
  return serial~=nil and serial>=1 and serial<=1000000 and serial%1==0
 end
 local function active(ingameOnly)
  local isfront=front()
  if not ingameOnly then
   local state=owner("LUMEN_ZM_LOCAL_START");local ticket=C.ticket
   if ticket and ticket.mrp and type(state)=="table"and state.request==ticket.request and
    ticket.request.asset=="zm_rb_r_mod_survival"and ticket.load==read("s1_engine_load")then return true end
   if committedFresh()then return true end
  end
  if isfront~=false then return false end
  local ok,mode=call(owner("Game"),"0xc99ee7ec93255cc0")
  if not ok or not C.isSurvival(mode)then return false end
  local map=dstring("engine_map")
  if type(map)~="string"or map==""then map=dstring("g_mapname")end
  if type(map)~="string"or map==""then map=dstring("ui_mapname")end
  if type(map)~="string"or map==""then return false end
  local marker=dint("csm_c1_active")
  local markerMap=dstring("csm_c1_map")
  if markerMap==map and(marker==0 or marker==1)then return marker==1 end
  if read("csm_s1_ready")=="1"and read("csm_s1_last_mrp")=="1"and
   read("csm_s1_last_map")==map and read("csm_s1_last_load")==read("s1_engine_load")then return true end
  return marker==1 and markerMap==map
 end
 C.active=active
 local ctor=type(clua)=="table"and type(clua.PushXHashAsset)=="function"and clua.PushXHashAsset
 local group=ctor and ctor("0x3a5fbf2cb25f1c61")
 local mayhem=ctor and ctor("zm_rb_rh_mod")
 local survival=ctor and ctor("zm_rb_r_mod_survival")
 local function payload(value)
  local ok,s=pcall(tostring,value);if not ok then return end
  s=string.lower(s)
  local h=s:match("#x(%x+)")
  if h and #h==17 then h=h:sub(2)end
  h=h or s:match("^0x(%x+)$")
  if h then h=h:gsub("^0+","");return h~=""and h or "0"end
 end
 function C.isSurvival(value)
  if value=="zm_rb_r_mod_survival"or value==survival then return true end
  local a,b=payload(value),payload(survival)
  return a~=nil and b~=nil and a==b
 end
 local refs=ctor and {ctor("0x0c96662543cf472e"),ctor("0x0c96652543cf457b"),ctor("0x0c96642543cf43c8")}
 local images={"sat_ftue_peeks_mayhem_1","sat_ftue_peeks_mayhem_2","sat_ftue_peeks_mayhem_3"}
 local function cardsReady()
  if not group or not refs then return false end
  local ok,bundle=call(owner("Engine"),"0xf06093d047200548",group)
  if not ok or bundle==nil then return false end
  local entries=get(bundle,"0x35a8b21c23e39065")
  if type(entries)~="table"or #entries~=#refs then return false end
  for i,ref in ipairs(refs)do
   if get(entries[i],"0xd5935c4229057eda")~=ref then return false end
   local found,card=call(owner("Engine"),"0xf06093d047200548",ref)
   if not found or card==nil or get(card,"0x2ab612888528489a")~=images[i]or
    get(card,"0x3a506cb501761960")==nil or get(card,"0x0cc44970c8397929")==nil then return false end
  end
  return true
 end
 local function tierSource()
  if C.tierSource then return C.tierSource end
  local new=path(owner("LUI"),"DataSourceFromOmnvar","new")
  if type(new)~="function"then return end
   
  local ok,ds=pcall(new,"ui_zm_relic_tier",-1)
  if ok and ds~=nil then C.tierSource=ds;return ds end
 end
 local function actualTier(controller)
  local ds=tierSource();local f=get(ds,"GetValue")
  if type(f)~="function"then return end
  local ok,v=pcall(f,ds,controller)
  if ok and type(v)=="number"and v==v and v>=0 and v<=3 and v%1==0 then return v end
 end
 C.actualTier=actualTier
 local function controllerOK(controller)
  return type(controller)=="number"and controller>=0 and controller<=7 and controller%1==0
 end
 local function numeric(value)return type(value)=="number"and value==value and value>=0 and value<math.huge end
  
  
 local function existing(t,...)
  for _,key in ipairs({...})do
   if type(t)~="table"then return end
   local v=rawget(t,key);if v==nil then v=rawget(t,H(key))end
   t=v;if t==nil then return end
  end
  return t
 end
 local function displayName()
  if not mayhem then return end
  local f=C.nativeDisplay or get(owner("GameType"),"0x5c034961620dbc3c")
  if type(f)~="function"then return end
  local ok,value=pcall(f,mayhem)
  if ok and type(value)=="string"and value~=""then return value end
 end
 local noExtraPoints={GetValue=function()return 0 end}
 local mayhemSelected={GetValue=function()return true end}
 local function mayhemMenuTier(controller)
  local factory=C.nativeTier
  if type(factory)~="function"then return end
  if C.maximumTierFactory~=factory then
   local ok,calculate=pcall(factory,noExtraPoints,mayhemSelected)
   if not ok or type(calculate)~="function"then return end
   C.maximumTierFactory=factory;C.calculateMaximumTier=calculate
  end
  local ok,value=pcall(C.calculateMaximumTier,controller)
  if ok and type(value)=="number"and value>=1 and value<math.huge and value%1==0 then return value end
 end
  
  
 local maximumMenuTier={GetValue=function(_,controller)return mayhemMenuTier(controller)or 0 end}
 local function tierText(controller)
  local factory=C.nativeTierText or get(owner("ZMRELIC"),"0x130755f075c4d836")
  if type(factory)~="function"then return end
  if C.tierTextFactory~=factory then
   local ok,formatter=pcall(factory,maximumMenuTier)
   if not ok or type(formatter)~="function"then return end
   C.tierTextFactory=factory;C.formatTierThree=formatter
  end
  local ok,value=pcall(C.formatTierThree,controller)
  if ok and type(value)=="string"and value~=""then return value end
 end
 local function ingameKind(kind)return kind=="tier"or kind=="tiertext"end
 local function replacement(kind,controller,original,...)
  if kind=="tier"then return mayhemMenuTier(controller)end
  if kind=="tiertext"then return tierText(controller)end
  if kind=="breadcrumb"then return original(controller,...)end
  return displayName()
 end
 local function syncModel(ds,controller,record,kind)
  if record.busy then return end
  local getter,setter=get(ds,"GetValue"),get(ds,"SetValue")
  if type(getter)~="function"or type(setter)~="function"then return end
  local applies=active(ingameKind(kind))
  if applies then
   local transform=get(ds,"_aggregateFunction")
   if type(transform)~="function"then return end
   if transform~=record.wrapper then
    record.original=transform
    record.wrapper=function(index,...)
     if active(ingameKind(kind))then
      local value=replacement(kind,index,transform,...);if value~=nil then return value end
     end
     return transform(index,...)
    end
    local installed=pcall(function()ds._aggregateFunction=record.wrapper end)
    if not installed or get(ds,"_aggregateFunction")~=record.wrapper then return end
   end
   local found,value=pcall(replacement,kind,controller,transform)
   if not found then return end
   if value==nil then return end
   local ok,current=pcall(getter,ds,controller);if not ok then return end
   if current~=value then
    record.busy=true;local written=pcall(setter,ds,controller,value);record.busy=false
    if written then record.applied[controller]=value end
   else record.applied[controller]=value end
  elseif record.wrapper then
   local currentTransform=get(ds,"_aggregateFunction")
   if currentTransform~=record.wrapper and currentTransform~=record.original then record.applied[controller]=nil;return end
   if currentTransform==record.wrapper then pcall(function()ds._aggregateFunction=record.original end)end
   local applied=record.applied[controller]
   if applied~=nil then
    local ok,current=pcall(getter,ds,controller)
    if ok and current==applied then
     local found,value=pcall(record.original,controller)
     if found and ((kind=="tier"and numeric(value))or(kind~="tier"and type(value)=="string"))and value~=current then
      record.busy=true;pcall(setter,ds,controller,value);record.busy=false
     end
    end
    record.applied[controller]=nil
   end
  end
 end
 local function collect(tableOfModels,model)
  if model==nil or(type(model)~="table"and type(model)~="userdata")then return end
  if not tableOfModels[model]then tableOfModels[model]={applied={}}end
 end
 local function refreshModels()
  if C.refreshing then return end
  C.refreshing=true
  local ds=owner("_DataSources")
  local relics=existing(ds,"0x08f73707b5922e00","0xfa1ec14daf3b21ad")
  collect(C.tiers,existing(relics,"0xda2bb48707949555"))
  collect(C.tiers,existing(relics,"0xe5f090504efffe51","0xb2a4145638803b03"))
  collect(C.tierTexts,existing(relics,"0xe5f090504efffe51","0xe9bd30dd97a17c3e"))
  local name=existing(ds,"0x08a25107b54a1a2f","0xc3bfe3a4fe4c13f6","0x42fcacdec5194143")
  collect(C.names,name)
  local loading=existing(ds,"0x08a94a07b5502cf8","0xc3bfe3a4fe4c13f6")
  collect(C.names,existing(loading,"0x42fcacdec5194143"))
  collect(C.breadcrumbs,existing(loading,"0xf5ced6ff17d687b0"))
  for model,record in pairs(C.tiers)do for controller in pairs(C.controllers)do syncModel(model,controller,record,"tier")end end
  for model,record in pairs(C.tierTexts)do for controller in pairs(C.controllers)do syncModel(model,controller,record,"tiertext")end end
  for model,record in pairs(C.names)do for controller in pairs(C.controllers)do syncModel(model,controller,record,"name")end end
  for model,record in pairs(C.breadcrumbs)do for controller in pairs(C.controllers)do syncModel(model,controller,record,"breadcrumb")end end
  C.refreshing=false
 end
 C.refresh=refreshModels
 local builderMarks=setmetatable({},{__mode="k"})
 local function installBuilder()
  local builder=owner("MenuBuilder")
  if type(builder)~="table"then return end
  local original=rawget(builder,"BuildRegisteredType")
   
   
  if type(original)~="function"or builderMarks[builder]then return end
  local targets={[H("0x33cfce74f0b4df49")]=true,[H("0x59701c29e664ad77")]=true}
  local wrapper=function(ref,...)
   if not targets[ref]then return original(ref,...)end
   local args=pack(...)
   local controller=get(args[1],"controllerIndex")
   if controllerOK(controller)then C.controllers[controller]=true end
   refreshModels()
   local result=pack(original(ref,unpack(args,1,args.n)))
    
    
   refreshModels()
   return unpack(result,1,result.n)
  end
  local ok=pcall(function()builder.BuildRegisteredType=wrapper end)
  if ok and rawget(builder,"BuildRegisteredType")==wrapper then builderMarks[builder]=wrapper end
 end
 local function install()
  wrap(owner("LOADING_SCREEN_HINTS"),"0xe2e5261355815723",function(original)return function(...)
   if active(false)and cardsReady()then return group end
   return original(...)
  end end)
  wrap(owner("LOADING_SCREEN_HINTS"),"GetHintGridData",function(original)return function(widget,...)
   local result=pack(original(widget,...))
   if widget~=nil then C.cards[widget]={render=original,args=pack(...),active=active(false)}end
   return unpack(result,1,result.n)
  end end)
  local gameType=owner("GameType")
  wrap(gameType,"0x5c034961620dbc3c",function(original)
   C.nativeDisplay=original
   return function(mode,...)
    if C.isSurvival(mode)and active(false)then
     local value=displayName();if value then return value end
    end
    return original(mode,...)
   end
  end)
  for _,key in ipairs({"0x615ea1db2da9249a","0xf03119e99e61a759"})do
   wrap(gameType,key,function(original)
    if key=="0x615ea1db2da9249a"then C.nativeTitle=original end
    return function(...)
    if active(false)then
     local value=displayName();if value then return value end
    end
    return original(...)
   end end)
  end
  wrap(owner("ZMRELIC"),"0xbeb0e1b952105ad5",function(original)
   C.nativeTier=original
   return function(...)
   local result=pack(original(...));local native=result[1]
   if type(native)=="function"then
    local function transformed(controller,...)
     if active(true)then local value=mayhemMenuTier(controller);if value then return value end end
     return native(controller,...)
    end
    result[1]=transformed
   end
   return unpack(result,1,result.n)
  end end)
  wrap(owner("ZMRELIC"),"0x130755f075c4d836",function(original)
   C.nativeTierText=original
   return function(...)
    local result=pack(original(...));local native=result[1]
    if type(native)=="function"then
     result[1]=function(controller,...)
      if active(true)then local value=tierText(controller);if value then return value end end
      return native(controller,...)
     end
    end
    return unpack(result,1,result.n)
   end
  end)
  wrap(owner("ZMRELIC"),"0x0acb1a9e9925838d",function(original)return function(controller,list,points,...)
   local result=pack(original(controller,list,points,...))
   if controllerOK(controller)then C.controllers[controller]=true end
   refreshModels()
   return unpack(result,1,result.n)
  end end)
  installBuilder()
 end
 local priorInstall=P.install
 function P.install(...)
  local result=pack(priorInstall(...));install();return unpack(result,1,result.n)
 end
 local priorPoll=P.poll
 function P.poll(...)
  local result=pack(priorPoll(...))
  if front()==true and not active(false)then clearMarker()end
  refreshModels()
  local now=active(false)
  for widget,record in pairs(C.cards)do
   if record.active~=now then
    record.active=now
    if not pcall(record.render,widget,unpack(record.args,1,record.args.n))then C.cards[widget]=nil end
   end
  end
  return unpack(result,1,result.n)
 end
 P.install()
end
