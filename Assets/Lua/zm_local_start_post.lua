do
(function()

rawset(_G,"KRONOS_SAVE_TRANSPORT",function(command)
 return command=="status" or command=="activate" or command=="save_status" or command=="clear" or command=="configure"
end)
do
pcall(function()
 if rawget(_G,"LUMEN_DEAD_OPS_HUD_REPAIR")then return end
 local clua=rawget(_G,"CLUA")
 if type(clua)~="table"or type(clua.PushXHash)~="function"or type(clua.PushXHashAsset)~="function"then return end
 local function pack(...)return {n=select("#",...),...}end
 local keys={}
 local function hx(name)
  if type(name)~="string"or not string.match(name,"^0x%x+$")then return end
  if not keys[name]then keys[name]=clua.PushXHash(name)end
  return keys[name]
 end
 local function slot(owner,name)
  if type(owner)~="table"then return end
  local value=rawget(owner,name);if value~=nil then return value,name end
  local key=hx(name);if key then return rawget(owner,key),key end
 end
 local observer={context=false,seen_ingame=false}
 local function launch_request()
  local state=rawget(_G,"LUMEN_ZM_LOCAL_START");local request=state and state.request
  if request then return request end
  local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
  request=observer.native_saved_request
  if request and type(compatibility)=="table" and compatibility.enabled==true
   and compatibility.nativeResume==request then return request end
 end
 local current={}
 local context_depth=0
 local function context(frontend_value,force_map)
  if frontend_value==nil then
   local f=slot(rawget(_G,"Engine"),"InFrontend")
   if type(f)=="function"then
    context_depth=context_depth+1;local ok,value=pcall(f);context_depth=context_depth-1
    if ok then frontend_value=value end
   end
  end
  if current.frontend~=frontend_value or force_map then current.map=nil end
  current.frontend=frontend_value
  if frontend_value==false and current.map==nil then
   local f=slot(rawget(_G,"Dvar"),"0x254084d7ca2317bb")
   if type(f)=="function"and type(clua.PushXHashDvar)=="function"then
    local ok,value=pcall(f,clua.PushXHashDvar("ui_mapname"));if ok then current.map=value end
   end
  end
 end
 local function doa_context()
  if observer.context_suppressed then return false end
  if current and current.frontend==false and current.map=="zm_sat_ztron4"then observer.context=true;observer.seen_ingame=true end
  local request=launch_request()
  if request then return request.asset=="zm_ztron"end
  if current and current.frontend==false then
   if current.map~="zm_sat_ztron4"then return false end
   observer.context=true;observer.seen_ingame=true
  elseif current and current.frontend==true then return false end
  return observer.context==true
 end
    local h3={depth=0,busy=false,attempted=false,local_owned=false}
    local H3_GATE="0x86eea359658a736e"
    local H3_OWNER="0x562362367be547a1"
    local H3_TAG="H3_DOA_HUD_V1"
    local H3_SELECTIONS={[64]=true,[73]=true,[74]=true,[111]=true,[241]=true,[308]=true,[309]=true,
        [328]=true,[329]=true,[330]=true,[331]=true,[478]=true,[479]=true,[480]=true,[481]=true}
    local function h3_one(owner,key,...)
        local f=slot(owner,key)
        if type(f)~="function" then return false,nil end
        local r=pack(pcall(f,...))
        if r[1]~=true or r.n~=2 then return false,nil end
        return true,r[2]
    end
    local function h3_payload(value)
        if type(value)~="xhash" then return end
        local text=string.lower(tostring(value))
        local token=string.match(text,"#x(%x+)")
        if token and #token==17 then return string.sub(token,2) end
        return token or string.match(text,"0x(%x+)")
    end
    local function h3_keys()
        local clua=rawget(_G,"CLUA")
        if type(clua)~="table" or type(clua.PushXHashDvar)~="function" then return false end
        if h3.gate==nil then h3.gate=clua.PushXHashDvar(H3_GATE) end
        if h3.owner==nil then h3.owner=clua.PushXHashDvar(H3_OWNER) end
        return h3_payload(h3.gate)==string.sub(H3_GATE,3) and h3_payload(h3.owner)==string.sub(H3_OWNER,3)
    end
    local function h3_exists(key)
        local ok,value=h3_one(rawget(_G,"Dvar"),"0xe1fab6d9a30481f8",key)
        return ok and type(value)=="boolean",value
    end
    local function h3_type(key) return h3_one(rawget(_G,"Dvar"),"0x0ba3d5f4206fb752",key) end
    local function h3_string(key) return h3_one(rawget(_G,"Dvar"),"0x254084d7ca2317bb",key) end
    local function h3_owner_state()
        local ok,exists=h3_exists(h3.owner)
        if not ok then return "unreadable" end
        if not exists then return "absent" end
        local typed,t=h3_type(h3.owner);local text,s=h3_string(h3.owner)
        if typed and t==10 and text and s==H3_TAG then return "owned" end
        return "foreign"
    end
    local function h3_exec(key,value,quoted)
        local engine=rawget(_G,"Engine")
        local f=slot(engine,"0xeb81a5136c5503e4")
        if type(f)~="function" then f=slot(engine,"ExecNow") end
        if type(f)~="function" then error("H3 original Engine.ExecNow unavailable",0) end
        local command="set #x3"..string.sub(key,3).." "..(quoted and ('"'..value..'"') or value)
        if h3.controller==nil then return f(command) end
        return f(command,h3.controller)
    end
    local function h3_gate_value()
        local ok,exists=h3_exists(h3.gate)
        if not ok or not exists then return false,nil,nil end
        local typed,t=h3_type(h3.gate);local text,s=h3_string(h3.gate)
        if not typed or(t~=5 and t~=10)or not text or(s~="0"and s~="1")then return false,t,s end
        return true,t,s
    end
    local function h3_cleanup(reason)
        if not h3_keys() then return end
        if not h3.local_owned and h3_owner_state()~="owned" then return end
        local valid,t,s=h3_gate_value()
        if not valid then
            return
        end
        if s=="1" then h3_exec(H3_GATE,"0",false) end
        h3_gate_value()
    end
    local function h3_enter(self)
        if h3.depth==0 then
            h3.attempted=false;h3.local_owned=false;h3.controller=self and self._controllerIndex
        end
        h3.used_hud=true
        h3.depth=h3.depth+1
    end
    local function h3_prepare(key,original_boolean)
        if h3.busy or not h3.preparing_request or h3.attempted then return end
        if h3_payload(key)~=string.sub(H3_GATE,3)or not doa_context() then return end
        h3.attempted=true
        local active,asset=h3_one(rawget(_G,"Game"),"0xc99ee7ec93255cc0")
        if not active or h3_payload(asset)~="2221eb5207966ab5" then
            return
        end
        local bundle_ok,bundle=h3_one(rawget(_G,"Game"),"0x2c70896f97c4d9fb")
        local field_ok,name,gate_field=pcall(function()
            return bundle and bundle[hx("0x3793df38a163f5dd")],bundle and bundle[hx("0x848c60e95ef1c998")]
        end)
        if not bundle_ok or not field_ok or name~="ZtronHUD" or h3_payload(gate_field)~=string.sub(H3_GATE,3) then
            return
        end
        if type(h3.controller)~="number"or h3.controller<0 or h3.controller~=math.floor(h3.controller)or
            h3.controller==math.huge or not h3_keys() then
            return
        end
        local dvar=rawget(_G,"Dvar")
        if type((slot(dvar,"0x0ba3d5f4206fb752")))~="function" or
            type((slot(dvar,"0x254084d7ca2317bb")))~="function" then
            return
        end
        local readable,exists=h3_exists(key);local owner=h3_owner_state()
        if not readable or owner=="unreadable"or owner=="foreign" then
            return
        end
        if exists and owner~="owned" then
            return
        end
        h3.busy=true
        pcall(function()
            if not exists then
                local checked,present=h3_exists(key)
                if not checked or present then return end
                h3.local_owned=true
                h3_exec(H3_GATE,"1",false)
            else
                local valid,_,s=h3_gate_value()
                if not valid then return end
                if s=="0" then h3_exec(H3_GATE,"1",false) end
            end
            local valid,t,s=h3_gate_value()
            local actual=pack(pcall(original_boolean,key))
            if not valid or s~="1"or actual[1]~=true or actual.n~=2 or actual[2]~=true then
                return
            end
            if owner=="absent" then
                local check,present=h3_exists(h3.owner)
                if not check or present then return end
                h3_exec(H3_OWNER,H3_TAG,true)
            end
            if h3_owner_state()~="owned" then return end
        end)
        h3.busy=false
    end
    local function h3_finish(original_succeeded)
        h3.depth=math.max(0,h3.depth-1)
        if h3.depth~=0 or h3.busy then return end
        h3.busy=true
        pcall(function()
            if not h3_keys() then return end
            if not original_succeeded or h3_owner_state()~="owned" then
                h3_cleanup("constructor_error_or_owner_commit_failure")
            end
        end)
        h3.busy=false;h3.local_owned=false
    end
    local function h3_frontend(result)
        if result[1]~=true or h3.depth~=0 or h3.busy then return end
        local request=launch_request()
        if request and request.asset=="zm_ztron" and not observer.seen_ingame and not h3.used_hud then return end
        h3.busy=true
        pcall(h3_cleanup,"frontend_recovery")
        h3.busy=false
    end
    local function h3_new_start(request)
        h3.used_hud=false
        if(request and request.asset=="zm_ztron")or h3.busy then return end
        h3.busy=true
        pcall(h3_cleanup,"non_DeadOps_start")
        h3.busy=false
    end
    local function h3_before_request(command)
        if command~="xpartygo"or h3.busy then return end
        local request=launch_request()
        if not request or request.asset~="zm_ztron" or not H3_SELECTIONS[request.id] then return end
        h3.controller=request.controller;h3.attempted=false;h3.local_owned=false
        h3.preparing_request=true
        pcall(function()
            if not h3_keys() then return end
            local f=slot(rawget(_G,"Dvar"),"0xc9e5be3b4bba4e0e")
            if type(f)~="function" then return end
            h3_prepare(h3.gate,f)
        end)
        h3.preparing_request=false
        if h3.local_owned and h3_owner_state()~="owned" then
            pcall(h3_cleanup,"pre_request_owner_failure")
        end
        h3.local_owned=false
    end
 local wrapped={}
 local function wrap(owner,name,id,make)
  local original,key=slot(owner,name)
  if original==nil and type(owner)=="table"then
   local ok,value=pcall(clua.PushXHash,name)
   if ok and value~=nil then key=value;original=rawget(owner,key)end
  end
  if type(original)~="function"then return end
  local records=wrapped[owner]or{};wrapped[owner]=records
  local prior=records[key]
  if prior and (prior==original or id=="exec"or id=="builder")then return end
  local replacement=make(original);records[key]=replacement;rawset(owner,key,replacement)
 end
 local refresh
 refresh=function()
  wrap(rawget(_G,"Engine"),"ExecNow","exec",function(original)return function(command,...)
   if command=="xstartprivateparty"then
    local request=launch_request()
    pcall(h3_new_start,request)
    observer.context=type(request)=="table"and request.asset=="zm_ztron"
    observer.context_suppressed=not observer.context;observer.seen_ingame=false
   end
   pcall(h3_before_request,command)
   return original(command,...)
  end end)
  wrap(rawget(_G,"Engine"),"InFrontend","frontend",function(original)return function(...)
   local result=pack(original(...));if context_depth>0 then return unpack(result,1,result.n)end
   pcall(context,result[1]);pcall(h3_frontend,result)
   if result[1]==false and doa_context()then observer.seen_ingame=true end
   if result[1]==true and observer.seen_ingame then observer.context=false;observer.context_suppressed=true end
   return unpack(result,1,result.n)
  end end)
  local lui=rawget(_G,"LUI");local builder=rawget(_G,"MenuBuilder")or slot(lui,"MenuBuilder")
  for _,name in ipairs({"BuildRegisteredType","LoadFile","registerType"})do
   wrap(builder,name,name=="BuildRegisteredType"and"builder"or name,function(original)return function(...)
    pcall(refresh);pcall(context)
    local result=pack(pcall(original,...));pcall(refresh)
    if not result[1]then error(result[2],0)end
    return unpack(result,2,result.n)
   end end)
  end
  wrap(slot(lui,"HudManager"),"CreateHud","hud",function(original)return function(self,...)
   pcall(context,nil,true)
   if not doa_context()then return original(self,...)end
   pcall(h3_enter,self);local result=pack(pcall(original,self,...));pcall(h3_finish,result[1])
   if not result[1]then error(result[2],0)end
   return unpack(result,2,result.n)
  end end)
 end
 
 
 local function native_saved_context()
  local engine=rawget(_G,"Engine")
  local f=slot(engine,"InFrontend") or slot(engine,"0x112586a3f4fb490e")
  if type(f)~="function" then return end
  context_depth=context_depth+1
  local ok,value=pcall(f)
  context_depth=context_depth-1
  if not ok or type(value)~="boolean" then return end
  context(value)
  return value
 end
 local function begin_native_saved(request)
  local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
  local state=rawget(_G,"LUMEN_ZM_LOCAL_START")
  if type(request)~="table" or type(compatibility)~="table" or compatibility.enabled~=true
   or compatibility.nativeResume~=request or (state and state.request)
   or request.asset~="zm_ztron" or request.map~="zm_sat_ztron4" or not H3_SELECTIONS[request.id]
   or type(request.entry)~="table" or request.entry.cont~=true
   or type(request.controller)~="number" or request.controller<0
   or request.controller~=math.floor(request.controller) or request.controller==math.huge then return false end
  if observer.native_saved_request and observer.native_saved_request~=request then return false end
  if native_saved_context()~=true then return false end
  observer.native_saved_request=request
  observer.context=true;observer.context_suppressed=false;observer.seen_ingame=false
  h3.used_hud=false;h3.attempted=false;h3.controller=request.controller
  return true
 end
 local function prepare_native_saved(request)
  if observer.native_saved_request~=request or launch_request()~=request then return false end
  if native_saved_context()~=true then return false end
  local active,asset=h3_one(rawget(_G,"Game"),"0xc99ee7ec93255cc0")
  if not active or h3_payload(asset)~="2221eb5207966ab5" then return false end
  local bundle_ok,bundle=h3_one(rawget(_G,"Game"),"0x2c70896f97c4d9fb")
  local field_ok,name,gate=pcall(function()
   return bundle and bundle[hx("0x3793df38a163f5dd")],bundle and bundle[hx("0x848c60e95ef1c998")]
  end)
  if not bundle_ok or not field_ok or name~="ZtronHUD" or h3_payload(gate)~=string.sub(H3_GATE,3) then return false end
  h3_before_request("xpartygo")
  local valid,_,value=h3_gate_value()
  local ok,actual=h3_one(rawget(_G,"Dvar"),"0xc9e5be3b4bba4e0e",h3.gate)
  return valid and value=="1" and ok and actual==true and h3_owner_state()=="owned"
 end
 local function finish_native_saved(request,loaded)
  if observer.native_saved_request~=request then return false end
  local frontend=native_saved_context()
  if loaded==true and frontend==false then
   observer.seen_ingame=true;observer.context=true
   observer.native_saved_request=nil
   return true
  end
  local state=rawget(_G,"LUMEN_ZM_LOCAL_START")
  local next_request=state and state.request
  if not next_request or next_request.asset~="zm_ztron" then
   h3_cleanup("native_saved_cancelled")
   if current.frontend==true then observer.context=false;observer.context_suppressed=true end
  end
  observer.native_saved_request=nil
  return true
 end
 rawset(_G,"LUMEN_DEAD_OPS_HUD_REPAIR",{version="H3.1-production",refresh=refresh,
  nativeSaveBridgeVersion="K10",beginNativeSavedGame=begin_native_saved,
  prepareNativeSavedGame=prepare_native_saved,finishNativeSavedGame=finish_native_saved})
 pcall(context);refresh()
end)
end
;
(function()
    if rawget(_G,"LUMEN_ZM_SAVE_GUARD") then return end
    local clua=rawget(_G,"CLUA")
    if type(clua)~="table" or type(clua.PushXHash)~="function" then return end
    local data={["confirmations"]={{["owner"]="END_GAME",["key"]="0x6bd0f388600a1cda",["prototype"]=39}},["events"]={{["key"]="0x76055c55456f05df",["event"]="save_and_end_game",["source"]="END_GAME p39 original confirmed Save & Quit; event parameter77"}}}
    local guard={actions={},wrapped={}}
    local function pack(...) return {n=select("#",...),...} end
    local function slot(owner,name)
        if type(owner)~="table" then return end
        local fn=rawget(owner,name);if fn~=nil then return fn,name end
        local key=clua.PushXHash(name);return rawget(owner,key),key
    end
    local function ready()
        local transport=rawget(_G,"KRONOS_SAVE_TRANSPORT")
        if type(transport)~="function" then return false end
        local ok,value=pcall(transport,"status")
        return ok and value==true
    end
    local function refuse()
        local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
        if type(compatibility)=="table" and type(compatibility.allowSaveDispatch)=="function" then
            local ok,allowed=pcall(compatibility.allowSaveDispatch)
            if ok and allowed==true then
                compatibility.saveGuardPassed=true
                return false
            end
        end
        if ready() then return false end
        local lui=rawget(_G,"LUI");local flow=slot(lui,"FlowManager")
        local popup=slot(flow,"RequestErrorPopup")
        local start=rawget(_G,"LUMEN_ZM_LOCAL_START")
        local controller=type(start)=="table" and start.controller or 0
        if type(popup)=="function" then pcall(popup,controller,"Save & Quit",
            "Local saving is unavailable in this session. You are still in the match.") end
        return true
    end
    local function arguments(...)
        local args=pack(...)
        for index=1,args.n do
            local value=args[index]
            if type(value)=="table" then
                local replacement=guard.actions[rawget(value,"yes_action")]
                if replacement then
                    local copy={};for k,v in pairs(value) do copy[k]=v end
                    local meta=getmetatable(value);if type(meta)=="table" then setmetatable(copy,meta) end
                    copy.yes_action=replacement;args[index]=copy
                end
            end
        end
        return unpack(args,1,args.n)
    end
    local function confirmations()
        for _,spec in ipairs(data.confirmations) do
            local owner=rawget(_G,spec.owner);local fn,key=slot(owner,spec.key)
            if type(fn)=="function" and guard.wrapped[spec.key]~=fn then
                local wrapper=function(...)
                    if refuse() then return end
                    return fn(...)
                end
                guard.actions[fn]=wrapper;guard.wrapped[spec.key]=wrapper;rawset(owner,key,wrapper)
            end
        end
    end
    local engine=rawget(_G,"Engine")
    for _,spec in ipairs(data.events) do
        local original,key=slot(engine,spec.key)
        if type(original)=="function" then rawset(engine,key,function(...)
            local relevant=select(1,...)==spec.event
            if relevant then
                if refuse() then return end
                local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
                local kronos=type(compatibility)=="table" and compatibility.saveGuardPassed==true
                local transport=rawget(_G,"KRONOS_SAVE_TRANSPORT")
                if not kronos and type(transport)=="function" then pcall(transport,"save_status") end
            end
            local result=pack(original(...))
            return unpack(result,1,result.n)
        end) end
    end
    local lui=rawget(_G,"LUI")
    local builder=rawget(_G,"MenuBuilder") or slot(lui,"MenuBuilder")
    local original,key=slot(builder,"BuildRegisteredType")
    if type(original)=="function" then rawset(builder,key,function(...)
        confirmations()
        local result=pack(original(arguments(...)))
        confirmations();return unpack(result,1,result.n)
    end) end
    confirmations();guard.refresh=confirmations
    rawset(_G,"LUMEN_ZM_SAVE_GUARD",guard)
end)()
;
if type(CLUA)~="table" or type(CLUA.PushXHash)~="function"
    or type(CLUA.PushXHashAsset)~="function" or type(CLUA.PushXHashDvar)~="function" then return end
if rawget(_G,"LUMEN_ZM_LOCAL_START") then return end
local data=(function()local c={};c[1]=function()return{key="0x0ca480c2570e0d4b",console_key="#x3ca480c2570e0d4b",kind="int",value=32,required=false}end;c[2]=function()return{key="0x0e4ee199928e3c65",console_key="#x3e4ee199928e3c65",kind="string",value="sat_lb_events_s1_daisy",required=false}end;c[3]=function()return{value=1,key="0x12202845e7a09a61",kind="int",console_key="#x312202845e7a09a61",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=0,required=false}end;c[4]=function()return{key="0x1518d3d7c58ff588",console_key="#x31518d3d7c58ff588",kind="int",value=1,required=false}end;c[5]=function()return{value=0,key="0x311ace67d8fa9823",kind="int",console_key="#x3311ace67d8fa9823",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=1,required=false}end;c[6]=function()return{key="0x330ea57ea86fcb72",console_key="#x3330ea57ea86fcb72",kind="int",value=1,required=false}end;c[7]=function()return{key="0x35111ff27cb16e60",console_key="#x335111ff27cb16e60",kind="int",value=1,required=false}end;c[8]=function()return{key="0x3c5523a5cba2bffa",console_key="#x33c5523a5cba2bffa",kind="int",value=0,required=false}end;c[9]=function()return{key="0x4b1e1d9cce83386d",console_key="#x34b1e1d9cce83386d",kind="int",value=1,required=false}end;c[10]=function()return{key="0x542648c49493c45b",console_key="#x3542648c49493c45b",kind="int",value=0,required=false}end;c[11]=function()return{value=0,key="0x5f1035b22c47683c",kind="int",console_key="#x35f1035b22c47683c",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=0,required=false}end;c[12]=function()return{key="0x607f3a4f730abeab",console_key="#x3607f3a4f730abeab",kind="int",value=1,required=false}end;c[13]=function()return{key="0x60e53c1534cc563c",console_key="#x360e53c1534cc563c",kind="int",value=0,required=false}end;c[14]=function()return{value=860,key="0x64f5af1fdb8525dd",kind="int",console_key="#x364f5af1fdb8525dd",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=750,required=false}end;c[15]=function()return{value=1,key="0x6a7f8c09d1c4c848",kind="int",console_key="#x36a7f8c09d1c4c848",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=0,required=false}end;c[16]=function()return{key="0x6c9a9e8c1f68b43b",console_key="#x36c9a9e8c1f68b43b",kind="int",value=0,required=false}end;c[17]=function()return{value=500,key="0x73690070f5640b94",kind="int",console_key="#x373690070f5640b94",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=350,required=false}end;c[18]=function()return{key="0x7444c1f208994cc5",console_key="#x37444c1f208994cc5",kind="int",value=1,required=true}end;c[19]=function()return{key="0x74c4dfe328b54c6a",console_key="#x374c4dfe328b54c6a",kind="int",value=1,required=false}end;c[20]=function()return{key="0x7bdf6d033065ef17",console_key="#x37bdf6d033065ef17",kind="int",value=0,required=false}end;c[21]=function()return{key="0x7c7dc4000124bca6",console_key="#x37c7dc4000124bca6",kind="int",value=0,required=false}end;c[22]=function()return{key="0x818c699a5caaee4f",console_key="#x3818c699a5caaee4f",kind="int",value=1,required=true}end;c[23]=function()return{key="0x829c6290156b4d13",console_key="#x3829c6290156b4d13",kind="int",value=0,required=false}end;c[24]=function()return{key="0x846217518982c8e4",console_key="#x3846217518982c8e4",kind="int",value=0,required=false}end;c[25]=function()return{key="0x8466137c0cc23466",console_key="#x38466137c0cc23466",kind="int",value=500,required=false}end;c[26]=function()return{key="0x86eea359658a736e",console_key="#x386eea359658a736e",kind="int",value=1,required=false}end;c[27]=function()return{key="0x9b383028dfd6542d",console_key="#x39b383028dfd6542d",value=0,kind="int",consumer_default=0,required=false}end;c[28]=function()return{key="0x9c790ecb6ccef79a",console_key="#x39c790ecb6ccef79a",value=150,kind="int",consumer_default=150,required=false}end;c[29]=function()return{key="0x9ce3cdf1c317d867",console_key="#x39ce3cdf1c317d867",kind="int",value=0,required=false}end;c[30]=function()return{key="0xa34fffc543c970ac",console_key="#x3a34fffc543c970ac",kind="int",value=1,required=false}end;c[31]=function()return{key="0xb89aa3fa4a8b1e2b",console_key="#x3b89aa3fa4a8b1e2b",kind="string",value="sat_defaultsuit_ztron",required=false}end;c[32]=function()return{key="0xbaab65d95adecc36",console_key="#x3baab65d95adecc36",kind="int",value=1,required=false}end;c[33]=function()return{value=0,key="0xc0e1c1320b98600e",kind="int",console_key="#x3c0e1c1320b98600e",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=1,required=false}end;c[34]=function()return{value=0,key="0xd3d5686da05c3c43",kind="int",console_key="#x3d3d5686da05c3c43",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=0,required=false}end;c[35]=function()return{key="0xdc0bb4713769e889",console_key="#x3dc0bb4713769e889",kind="int",value=1,required=false}end;c[36]=function()return{default_evidence="Original explicit getdvarint reader fallback; selected native DOA value unchanged.",key="0xdca6c5032ce96fa0",value=1,console_key="#x3dca6c5032ce96fa0",kind="int",consumer_default=0,required=false}end;c[37]=function()return{key="0xe190ea2f1d70f89f",console_key="#x3e190ea2f1d70f89f",kind="int",value=1,required=false}end;c[38]=function()return{key="0xe742008972155619",console_key="#x3e742008972155619",kind="int",value=0,required=false}end;c[39]=function()return{key="0xf23617f4fc3e538f",console_key="#x3f23617f4fc3e538f",kind="float",value=2,required=false}end;c[40]=function()return{key="0xf4c88a16269942c0",console_key="#x3f4c88a16269942c0",kind="int",value=0,required=false}end;c[41]=function()return{key="0xfe95dec32139474d",console_key="#x3fe95dec32139474d",kind="string",value="zm_ztron",required=false}end;c[42]=function()return{key="0x1851db151f127033",console_key="#x31851db151f127033",kind="int",value=15,required=false}end;c[43]=function()return{key="0x27d7e2d0e2e501ea",console_key="#x327d7e2d0e2e501ea",value=1,kind="int",consumer_default=0,required=false}end;c[44]=function()return{key="0x27d7efd0e2e51e81",console_key="#x327d7efd0e2e51e81",value=1,kind="int",consumer_default=0,required=false}end;c[45]=function()return{key="0x435b8b54a1919cbb",console_key="#x3435b8b54a1919cbb",kind="int",value=1,required=false}end;c[46]=function()return{key="0x479863b4738da210",console_key="#x3479863b4738da210",kind="float",value=-240,required=false}end;c[47]=function()return{key="0x4f5db955e1b6ee9a",console_key="#x34f5db955e1b6ee9a",kind="float",value=5,required=false}end;c[48]=function()return{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",value=1,kind="int",consumer_default=0,required=false}end;c[49]=function()return{key="0x56c1e5374b115ae9",console_key="#x356c1e5374b115ae9",value=0,kind="int",consumer_default=1,required=false}end;c[50]=function()return{key="0x5f0836c6f2287300",console_key="#x35f0836c6f2287300",value=0,kind="int",consumer_default=1,required=false}end;c[51]=function()return{key="0x739bbd49f9779978",console_key="#x3739bbd49f9779978",kind="int",value=1,required=false}end;c[52]=function()return{key="0x90e0d6a242bfc176",console_key="#x390e0d6a242bfc176",kind="int",value=0,required=false}end;c[53]=function()return{key="0x966271b977a0a5a2",console_key="#x3966271b977a0a5a2",kind="string",value="zm_sat_firefly_exit115",required=false}end;c[54]=function()return{key="0xa1461e779d78662a",console_key="#x3a1461e779d78662a",kind="int",value=1,required=false}end;c[55]=function()return{key="0xa51b2866600a0be5",console_key="#x3a51b2866600a0be5",kind="float",value=30,required=false}end;c[56]=function()return{key="0xc5a3ce6529ef6314",console_key="#x3c5a3ce6529ef6314",value=1,kind="int",consumer_default=0,required=false}end;c[57]=function()return{key="0xdddf7dca1a52e591",console_key="#x3dddf7dca1a52e591",value="zone_exit115",kind="string",consumer_default="null",required=true}end;c[58]=function()return{key="0xf7c13201f7e94b73",console_key="#x3f7c13201f7e94b73",value=1,kind="int",consumer_default=0,required=false}end;c[59]=function()return{key="0xfc0433fd5e334486",console_key="#x3fc0433fd5e334486",value=0,kind="int",consumer_default=1,required=false}end;c[60]=function()return{value=4000,key="0x139e934315e6cf5e",kind="float",console_key="#x3139e934315e6cf5e",default_evidence="Original Farm boundary getdvarfloat read fallback; selected native radius unchanged.",consumer_default=0,required=false}end;c[61]=function()return{key="0x966271b977a0a5a2",console_key="#x3966271b977a0a5a2",kind="string",value="zm_sat_firefly_farm",required=false}end;c[62]=function()return{key="0xdddf7dca1a52e591",console_key="#x3dddf7dca1a52e591",value="zone_farm",kind="string",consumer_default="null",required=true}end;c[63]=function()return{key="0x818c699a5caaee4f",console_key="#x3818c699a5caaee4f",kind="int",value=4,required=true}end;c[64]=function()return{key="0x966271b977a0a5a2",console_key="#x3966271b977a0a5a2",kind="string",value="zm_sat_firefly_launchpad",required=false}end;c[65]=function()return{key="0xdddf7dca1a52e591",console_key="#x3dddf7dca1a52e591",value="zone_launchpad",kind="string",consumer_default="null",required=true}end;c[66]=function()return{value=0,key="0x12202845e7a09a61",kind="int",console_key="#x312202845e7a09a61",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=0,required=false}end;c[67]=function()return{value=0,key="0x6a7f8c09d1c4c848",kind="int",console_key="#x36a7f8c09d1c4c848",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=0,required=false}end;c[68]=function()return{value=1,key="0xc0e1c1320b98600e",kind="int",console_key="#x3c0e1c1320b98600e",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=1,required=false}end;c[69]=function()return{value=1,key="0xd3d5686da05c3c43",kind="int",console_key="#x3d3d5686da05c3c43",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=0,required=false}end;c[70]=function()return{value=3,key="0xecf2c670b066f427",kind="int",console_key="#x3ecf2c670b066f427",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=3,required=false}end;c[71]=function()return{key="0x072e4d6b8f8afa03",console_key="#x372e4d6b8f8afa03",value=0,kind="int",consumer_default=0,required=false}end;c[72]=function()return{key="0x29d6c9bed7b8174e",console_key="#x329d6c9bed7b8174e",value=1,kind="int",consumer_default=1,required=false}end;c[73]=function()return{key="0x9a70e6e01d1021d9",console_key="#x39a70e6e01d1021d9",kind="float",value=0.3,required=false}end;c[74]=function()return{console_key="#x3c5a3ce6529ef6314",required=false,consumer_default=0,value=1,kind="int",semantic_name="enable_zm_powerups_ee",key="0xc5a3ce6529ef6314"}end;c[75]=function()return{console_key="#x3dfe5227c40e9c4e0",required=false,consumer_default=0,value=1,kind="int",semantic_name="enable_firefly_sq",key="0xdfe5227c40e9c4e0"}end;c[76]=function()return{console_key="#x3e0113e7c411a68da",required=false,consumer_default=0,value=1,kind="int",semantic_name="enable_firefly_mq",key="0xe0113e7c411a68da"}end;c[77]=function()return{console_key="#x3e0341a7c41406166",required=false,consumer_default=0,value=1,kind="int",semantic_name="enable_firefly_ee",key="0xe0341a7c41406166"}end;c[78]=function()return{required=false,consumer_default=0,key="0x4564bbcd614eb648",console_key="#x34564bbcd614eb648",value=1,kind="int",semantic_name="enable_rh",local_normal_content=true}end;c[79]=function()return{required=false,consumer_default=0,key="0x7ae1c9d5cf785e78",console_key="#x37ae1c9d5cf785e78",value=0,kind="int",semantic_name="skip_zm_rh_validation",local_normal_content=true}end;c[80]=function()return{value=1,key="0x5f1035b22c47683c",kind="int",console_key="#x35f1035b22c47683c",default_evidence="Original typed GSC reader fallback; registration default not claimed.",consumer_default=0,required=false}end;c[81]=function()return{console_key="#x31851db151f127033",kind="int",key="0x1851db151f127033",value=15}end;c[82]=function()return{console_key="#x3479863b4738da210",kind="float",key="0x479863b4738da210",value=-240}end;c[83]=function()return{console_key="#x34f5db955e1b6ee9a",kind="float",key="0x4f5db955e1b6ee9a",value=5}end;c[84]=function()return{console_key="#x3739bbd49f9779978",kind="int",key="0x739bbd49f9779978",value=1}end;c[85]=function()return{console_key="#x390e0d6a242bfc176",kind="int",key="0x90e0d6a242bfc176",value=0}end;c[86]=function()return{console_key="#x3a1461e779d78662a",kind="int",key="0xa1461e779d78662a",value=1}end;c[87]=function()return{console_key="#x3a51b2866600a0be5",kind="float",key="0xa51b2866600a0be5",value=30}end;c[88]=function()return{key="0xf7c13201f7e94b73",console_key="#x3f7c13201f7e94b73",kind="int",consumer_default=0,value=1}end;c[89]=function()return{required=true,consumer_default=0,key="0xbb4d4e9d5661c0f9",console_key="#x3bb4d4e9d5661c0f9",value=1,kind="int",semantic_name="enable_mantis_ee",local_normal_content=true}end;c[90]=function()return{required=true,consumer_default=0,key="0xbb70729d568857dd",console_key="#x3bb70729d568857dd",value=1,kind="int",semantic_name="enable_mantis_mq",local_normal_content=true}end;c[91]=function()return{required=true,consumer_default=0,key="0xbb9c6e9d56b8b577",console_key="#x3bb9c6e9d56b8b577",value=1,kind="int",semantic_name="enable_mantis_sq",local_normal_content=true}end;c[92]=function()return{required=false,consumer_default=0,key="0xc5a3ce6529ef6314",console_key="#x3c5a3ce6529ef6314",value=1,kind="int",semantic_name="enable_zm_powerups_ee",local_normal_content=true}end;c[93]=function()return{required=true,console_key="#x354d97c81fc15dc50",semantic_name="enable_rampage_inducer",policy_source="same-mode original playlist 58",key="0x54d97c81fc15dc50",value=1,kind="int",consumer_default=0,local_normal_content=true}end;c[94]=function()return{required=true,consumer_default=0,key="0x42cdb7fc777fae63",console_key="#x342cdb7fc777fae63",value=1,kind="int",semantic_name="enable_locust_ee",local_normal_content=true}end;c[95]=function()return{required=true,consumer_default=0,key="0x42aabbfc77596f77",console_key="#x342aabbfc77596f77",value=1,kind="int",semantic_name="enable_locust_mq",local_normal_content=true}end;c[96]=function()return{required=true,consumer_default=0,key="0x427ebffc772911dd",console_key="#x3427ebffc772911dd",value=1,kind="int",semantic_name="enable_locust_sq",local_normal_content=true}end;c[97]=function()return{required=true,consumer_default=0,key="0xa848de4270c1778d",console_key="#x3a848de4270c1778d",value=1,kind="int",semantic_name="enable_hornet_ee",local_normal_content=true}end;c[98]=function()return{required=true,consumer_default=0,key="0xa825ba42709ae0a9",console_key="#x3a825ba42709ae0a9",value=1,kind="int",semantic_name="enable_hornet_mq",local_normal_content=true}end;c[99]=function()return{required=true,consumer_default=0,key="0xa7e7c6427056574b",console_key="#x3a7e7c6427056574b",value=1,kind="int",semantic_name="enable_hornet_sq",local_normal_content=true}end;c[100]=function()return{key="0xdddf7dca1a52e591",console_key="#x3dddf7dca1a52e591",value="ashwood",kind="string",consumer_default="null",required=true}end;c[101]=function()return{key="0x58c986d5afe9fa0e",console_key="#x358c986d5afe9fa0e",value="zone_temple",kind="string",consumer_default="null",required=true}end;c[102]=function()return{key="0x2adc89ffac1de1a6",console_key="#x32adc89ffac1de1a6",value="future",kind="string",consumer_default="null",required=true}end;c[103]=function()return{key="0xfcdbf400811969f0",console_key="#x3fcdbf400811969f0",value="zone_lighthouse",kind="string",consumer_default="null",required=true}end;c[104]=function()return{key="0xab460fa6a1b88d4a",console_key="#x3ab460fa6a1b88d4a",value="castle",kind="string",consumer_default="null",required=true}end;c[105]=function()return{required=true,console_key="#x354d97c81fc15dc50",semantic_name="enable_rampage_inducer",policy_source="same-mode original playlist 172",key="0x54d97c81fc15dc50",value=1,kind="int",consumer_default=0,local_normal_content=true}end;c[106]=function()return{required=true,console_key="#x354d97c81fc15dc50",semantic_name="enable_rampage_inducer",policy_source="same-mode original playlist 417",key="0x54d97c81fc15dc50",value=1,kind="int",consumer_default=0,local_normal_content=true}end;c[107]=function()return{required=true,consumer_default=0,key="0xbb9c6e9d56b8b577",console_key="#x3bb9c6e9d56b8b577",value=0,kind="int",semantic_name="enable_mantis_sq",local_normal_content=true}end;c[108]=function()return{required=false,consumer_default=0,key="0x4564bbcd614eb648",console_key="#x34564bbcd614eb648",value=0,kind="int",semantic_name="enable_rh",local_normal_content=true}end;c[109]=function()return{required=true,console_key="#x354d97c81fc15dc50",semantic_name="enable_rampage_inducer",policy_source="same-mode original playlist 289",key="0x54d97c81fc15dc50",value=0,kind="int",consumer_default=0,local_normal_content=true}end;c[110]=function()return{required=true,consumer_default=0,key="0x427ebffc772911dd",console_key="#x3427ebffc772911dd",value=0,kind="int",semantic_name="enable_locust_sq",local_normal_content=true}end;c[111]=function()return{required=true,consumer_default=0,key="0xa7e7c6427056574b",console_key="#x3a7e7c6427056574b",value=0,kind="int",semantic_name="enable_hornet_sq",local_normal_content=true}end;c[112]=function()return{required=true,consumer_default=0,key="0x1389eb7dad9f9d83",console_key="#x31389eb7dad9f9d83",value=1,kind="int",semantic_name="enable_scarab_ee",local_normal_content=true}end;c[113]=function()return{required=true,consumer_default=0,key="0x1339f37dad46cdfd",console_key="#x31339f37dad46cdfd",value=1,kind="int",semantic_name="enable_scarab_sq",local_normal_content=true}end;c[114]=function()return{required=false,consumer_default=0,key="0x1384da7dad994f49",console_key="#x31384da7dad994f49",value=0,kind="int",semantic_name="enable_scarab_br",local_normal_content=true}end;c[115]=function()return{key="0xd0fb5140c8aff08e",semantic_name="enable_ncfd_pedestal",required=true,value=1,console_key="#x3d0fb5140c8aff08e",kind="int",consumer_default=0,local_normal_content=true}end;c[116]=function()return{required=true,consumer_default=0,key="0x1339f37dad46cdfd",console_key="#x31339f37dad46cdfd",value=0,kind="int",semantic_name="enable_scarab_sq",local_normal_content=true}end;c[117]=function()return{required=false,console_key="#x3355264c46b268345",policy="Rogue-only availability of original Curse Inducer; original map producer, world structs, vote and relic consumers remain authoritative.",consumer_default=0,key="0x355264c46b268345",value=1,kind="int",constructed_local_policy=true,local_normal_content=true}end;c[118]=function()return{value=1,consumer_default=1,required=true,local_variant_policy=true,console_key="#x32216f1745cf4ca17",kind="int",semantic_name="scr_zm_rb_echo_difficulty",key="0x2216f1745cf4ca17"}end;c[119]=function()return{value=0,consumer_default=0,required=true,local_variant_policy=true,console_key="#x36b4b2a2350b69461",kind="int",semantic_name="original Echo target selector",key="0x6b4b2a2350b69461"}end;c[120]=function()return{key="0xdddf7dca1a52e591",required=true,value="zone_farm",kind="string",consumer_default="null",console_key="#x3dddf7dca1a52e591"}end;c[121]=function()return{key="0xdddf7dca1a52e591",required=true,value="zone_launchpad",kind="string",consumer_default="null",console_key="#x3dddf7dca1a52e591"}end;c[122]=function()return{key="0xdddf7dca1a52e591",required=true,value="zone_exit115",kind="string",consumer_default="null",console_key="#x3dddf7dca1a52e591"}end;c[123]=function()return{key="0xdddf7dca1a52e591",required=true,value="ashwood",kind="string",consumer_default="null",console_key="#x3dddf7dca1a52e591"}end;c[124]=function()return{key="0x2adc89ffac1de1a6",required=true,value="future",kind="string",consumer_default="null",console_key="#x32adc89ffac1de1a6"}end;c[125]=function()return{key="0xfcdbf400811969f0",required=true,value="zone_lighthouse",kind="string",consumer_default="null",console_key="#x3fcdbf400811969f0"}end;c[126]=function()return{key="0xab460fa6a1b88d4a",required=true,value="castle",kind="string",consumer_default="null",console_key="#x3ab460fa6a1b88d4a"}end;c[127]=function()return{value=3,consumer_default=1,required=true,local_variant_policy=true,console_key="#x32216f1745cf4ca17",kind="int",semantic_name="scr_zm_rb_echo_difficulty",key="0x2216f1745cf4ca17"}end;c[128]=function()return{value=2,consumer_default=1,required=true,local_variant_policy=true,console_key="#x32216f1745cf4ca17",kind="int",semantic_name="scr_zm_rb_echo_difficulty",key="0x2216f1745cf4ca17"}end;c[129]=function()return{value=1,consumer_default=0,required=true,local_variant_policy=true,console_key="#x36b4b2a2350b69461",kind="int",semantic_name="original Echo target selector",key="0x6b4b2a2350b69461"}end;c[130]=function()return{value=2,consumer_default=0,required=true,local_variant_policy=true,console_key="#x36b4b2a2350b69461",kind="int",semantic_name="original Echo target selector",key="0x6b4b2a2350b69461"}end;c[131]=function()return{value=3,consumer_default=0,required=true,local_variant_policy=true,console_key="#x36b4b2a2350b69461",kind="int",semantic_name="original Echo target selector",key="0x6b4b2a2350b69461"}end;c[132]=function()return{value=4,consumer_default=0,required=true,local_variant_policy=true,console_key="#x36b4b2a2350b69461",kind="int",semantic_name="original Echo target selector",key="0x6b4b2a2350b69461"}end;c[133]=function()return{console_key="#x33a9ff30b9c2ea1f1",required=false,consumer_default=0,value=1,kind="int",semantic_name="enable_ruby_ee",key="0x3a9ff30b9c2ea1f1"}end;c[134]=function()return{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",value=0,kind="int",consumer_default=0,required=false}end;c[135]=function()return{key="0x74ff1b9b1efcff27",console_key="#x374ff1b9b1efcff27",kind="float",value=0.1,required=false}end;c[136]=function()return{supplier_evidence="Preserved native global preset 1; Ruby keypad reader fallback 0. This does not validate or complete a code.",key="0xcc6142f2bf8a87b7",required=false,console_key="#x3cc6142f2bf8a87b7",kind="int",consumer_default=0,value=1}end;c[137]=function()return{console_key="#x3dfe5227c40e9c4e0",required=false,consumer_default=0,value=0,kind="int",semantic_name="enable_firefly_sq",key="0xdfe5227c40e9c4e0"}end;c[138]=function()return{required=true,console_key="#x354d97c81fc15dc50",semantic_name="enable_rampage_inducer",policy_source="same-mode original playlist 288",key="0x54d97c81fc15dc50",value=0,kind="int",consumer_default=0,local_normal_content=true}end;c[139]=function()return{key="0xdfe5227c40e9c4e0",console_key="#x3dfe5227c40e9c4e0",value=1,kind="int",consumer_default=0,required=false}end;c[140]=function()return{key="0xe0113e7c411a68da",console_key="#x3e0113e7c411a68da",value=0,kind="int",consumer_default=0,required=false}end;c[141]=function()return{key="0xe0341a7c41406166",console_key="#x3e0341a7c41406166",value=1,kind="int",consumer_default=0,required=false}end;c[142]=function()return{required=true,console_key="#x354d97c81fc15dc50",semantic_name="enable_rampage_inducer",policy_source="same-mode original playlist 197",key="0x54d97c81fc15dc50",value=1,kind="int",consumer_default=0,local_normal_content=true}end;c[143]=function()return{required=true,console_key="#x354d97c81fc15dc50",semantic_name="enable_rampage_inducer",policy_source="same-mode original playlist 24",key="0x54d97c81fc15dc50",value=1,kind="int",consumer_default=0,local_normal_content=true}end;c[144]=function()return{required=true,console_key="#x354d97c81fc15dc50",semantic_name="enable_rampage_inducer",policy_source="same-mode original playlist 290",key="0x54d97c81fc15dc50",value=0,kind="int",consumer_default=0,local_normal_content=true}end;c[145]=function()return{key="0x58c986d5afe9fa0e",required=true,value="zone_temple",kind="string",consumer_default="null",console_key="#x358c986d5afe9fa0e"}end;c[146]=function()return{key="0x3a9ff30b9c2ea1f1",console_key="#x33a9ff30b9c2ea1f1",value=1,kind="int",consumer_default=0,required=false}end;c[147]=function()return{key="0x81bdf630f92c116e",console_key="#x381bdf630f92c116e",kind="int",value=1,required=false}end;return {text_observers={"Localize","0x07d3158a9539a355","0xaed84c33ec5f01ea"},menus={zmmatchsettings="0xdaab7b8cbabe4aac",zmpubliclobby="0x5581b8d8a3324627",relicselectmenu="0xa9dc6b835240282b",zmmapselection="0xb87e923e71d969f0",zmmatchselection="0x6f25f1422590a999",zmloadoutconfirmation="0x51330ed90c8b545d",zmmainmenu="0x89e9918304f5ed42"},native_id_queries={{owner="Playlist",key="0x1e40f2ffb7028b4f",source="SAVELOAD p5 lines77..79"},{owner="Playlist",source="Original PLAY_MENU p181 ID predicates",key="0xd51bd000e00a13d3"},{owner="Playlist",source="Original PLAY_MENU p181 filtered ID list",key="0x17cdecc3c164db74"},{owner="Playlist",source="Original PLAY_MENU p181 selected ID",key="0xda0db94230b1afc2"},{owner="Playlist",source="Original PLAY_MENU p198 start-time query",key="0xa4080cd0cd5b8677"},{owner="Playlist",source="Original PlaylistUtils p93 ID required packs",key="0x9669ba476167bbfc"},{key="0x3ea93feae1aa4d9e",projection="map_list",source="Original PLAY_MENU p178/p179 map-reference array",owner="Playlist"},{key="0xda449b9851cf679e",projection="map_records",source="Original PlaylistUtils p129 gametypeAssetName source",owner="Playlist"}},save_gates={{prototype=3,owner="SAVELOAD",key="0x67ad77359c50a1b9"},{prototype=4,owner="SAVELOAD",key="0xc84c1d7864022eae"},{prototype=5,owner="SAVELOAD",key="0x5e9317881b24d095"}},save_observers={{key="0x454f4cdccb251fcc",label="native-save-context"},{key="0x8b37a78320f86d95",label="native-save-context-ready"},{key="0x18fcc97344571dc0",label="original-resume-context-selection"}},get_type="0xc99ee7ec93255cc0",party_queries={{owner="Engine",key="0x8f668a3b8e44ed0a",source="MenuUtils p140 lines2220..2221; true enters original access-warning popup"}},save_actions={{event="save_and_end_game",source="END_GAME p39 original confirmed Save & Quit; event parameter77",key="0x76055c55456f05df"}},quest_event_key="0x76055c55456f05df",category_fields={"index","name","disabled","type","desc","image","playMenuRef","tags","startTime","endTime"},save_catalogue_compatible=false,additions={{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",category_ref="sat_zm_category_classic",id=1000000000,image_key="0x1a03af08b21e93ad",card_hash="77b1722b40063b3f",native_validated=false,template_id=58,image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",eligibility="Locally defined Standard membership; shipped map root + shared zm_rb startup"},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",category_ref="sat_zm_category_classic",id=1000000001,image_key="0x1a03af08b21e93ad",card_hash="77b1722b40063b3f",native_validated=false,template_id=24,image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",eligibility="Locally defined Standard membership; shipped map root + shared zm_rb startup"},{map="zm_sat_locust",play_menu_ref="sat_zm_locust",category_ref="sat_zm_category_classic",id=1000000002,image_key="0x1a03af08b21e93ad",card_hash="26a18343e72a4989",native_validated=false,template_id=58,image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",eligibility="Locally defined Standard membership; shipped map root + shared zm_rb startup"},{map="zm_sat_locust",play_menu_ref="sat_zm_locust",category_ref="sat_zm_category_classic",id=1000000003,image_key="0x1a03af08b21e93ad",card_hash="26a18343e72a4989",native_validated=false,template_id=24,image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",eligibility="Locally defined Standard membership; shipped map root + shared zm_rb startup"},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",category_ref="sat_zm_category_classic",id=1000000004,image_key="0x1a03af08b21e93ad",card_hash="7fe13f91c1ac8183",native_validated=false,template_id=58,image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",eligibility="Locally defined Standard membership; shipped map root + shared zm_rb startup"},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",category_ref="sat_zm_category_classic",id=1000000005,image_key="0x1a03af08b21e93ad",card_hash="7fe13f91c1ac8183",native_validated=false,template_id=24,image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",eligibility="Locally defined Standard membership; shipped map root + shared zm_rb startup"},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",category_ref="sat_zm_category_classic",id=1000000006,image_key="0x1a03af08b21e93ad",card_hash="04a45d86de36893d",native_validated=false,template_id=58,image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",eligibility="Locally defined Standard membership; shipped map root + shared zm_rb startup"},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",category_ref="sat_zm_category_classic",id=1000000007,image_key="0x1a03af08b21e93ad",card_hash="04a45d86de36893d",native_validated=false,template_id=24,image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",eligibility="Locally defined Standard membership; shipped map root + shared zm_rb startup"},{map="zm_sat_firefly",poi="ashwood",category_ref="sat_zm_category_survival",id=1000000008,image_key="0x1a03af08b21e93ad",card_hash="7faf6c835207d342",native_validated=false,template_id=59,play_menu_ref="sat_zm_firefly_ashwood",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_firefly",poi="ashwood",category_ref="sat_zm_category_survival",id=1000000009,image_key="0x1a03af08b21e93ad",card_hash="7faf6c835207d342",native_validated=false,template_id=54,play_menu_ref="sat_zm_firefly_ashwood",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_ruby",poi="zone_temple",category_ref="sat_zm_category_survival",id=1000000010,image_key="0x1a03af08b21e93ad",card_hash="3265febabdd1cbcd",native_validated=false,template_id=59,play_menu_ref="sat_zm_ruby_mars",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_ruby",poi="zone_temple",category_ref="sat_zm_category_survival",id=1000000011,image_key="0x1a03af08b21e93ad",card_hash="3265febabdd1cbcd",native_validated=false,template_id=54,play_menu_ref="sat_zm_ruby_mars",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_mantis",poi="future",category_ref="sat_zm_category_survival",id=1000000012,image_key="0x1a03af08b21e93ad",card_hash="7ae7f9405f8582ef",native_validated=false,template_id=59,play_menu_ref="sat_zm_mantis_future",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_mantis",poi="future",category_ref="sat_zm_category_survival",id=1000000013,image_key="0x1a03af08b21e93ad",card_hash="7ae7f9405f8582ef",native_validated=false,template_id=54,play_menu_ref="sat_zm_mantis_future",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_locust",poi="zone_lighthouse",category_ref="sat_zm_category_survival",id=1000000014,image_key="0x1a03af08b21e93ad",card_hash="3f9d733f3e4cecf6",native_validated=false,template_id=59,play_menu_ref="sat_zm_locust_lighthouse",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_locust",poi="zone_lighthouse",category_ref="sat_zm_category_survival",id=1000000015,image_key="0x1a03af08b21e93ad",card_hash="3f9d733f3e4cecf6",native_validated=false,template_id=54,play_menu_ref="sat_zm_locust_lighthouse",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_hornet",poi="castle",category_ref="sat_zm_category_survival",id=1000000016,image_key="0x1a03af08b21e93ad",card_hash="06ccf8007789eb60",native_validated=false,template_id=59,play_menu_ref="sat_zm_hornet_castle",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_hornet",poi="castle",category_ref="sat_zm_category_survival",id=1000000017,image_key="0x1a03af08b21e93ad",card_hash="06ccf8007789eb60",native_validated=false,template_id=54,play_menu_ref="sat_zm_hornet_castle",eligibility="Shipped zmsurvivalsettings POI + original play-menu header"},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",category_ref="sat_zm_category_r_mod",id=1000000018,image_key="0x1a03af08b21e93ad",card_hash="77b1722b40063b3f",native_validated=false,template_id=172,image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",category_ref="sat_zm_category_r_mod",id=1000000019,image_key="0x1a03af08b21e93ad",card_hash="77b1722b40063b3f",native_validated=false,template_id=197,image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",category_ref="sat_zm_category_r_mod",id=1000000020,image_key="0x1a03af08b21e93ad",card_hash="77b1722b40063b3f",native_validated=false,template_id=417,image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",category_ref="sat_zm_category_guided",id=1000000021,image_key="0x1a03af08b21e93ad",card_hash="77b1722b40063b3f",native_validated=false,template_id=288,image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",category_ref="sat_zm_category_guided",id=1000000022,image_key="0x1a03af08b21e93ad",card_hash="77b1722b40063b3f",native_validated=false,template_id=289,image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",category_ref="sat_zm_category_guided",id=1000000023,image_key="0x1a03af08b21e93ad",card_hash="77b1722b40063b3f",native_validated=false,template_id=290,image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_locust",play_menu_ref="sat_zm_locust",category_ref="sat_zm_category_r_mod",id=1000000024,image_key="0x1a03af08b21e93ad",card_hash="26a18343e72a4989",native_validated=false,template_id=172,image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_locust",play_menu_ref="sat_zm_locust",category_ref="sat_zm_category_r_mod",id=1000000025,image_key="0x1a03af08b21e93ad",card_hash="26a18343e72a4989",native_validated=false,template_id=197,image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_locust",play_menu_ref="sat_zm_locust",category_ref="sat_zm_category_r_mod",id=1000000026,image_key="0x1a03af08b21e93ad",card_hash="26a18343e72a4989",native_validated=false,template_id=417,image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_locust",play_menu_ref="sat_zm_locust",category_ref="sat_zm_category_guided",id=1000000027,image_key="0x1a03af08b21e93ad",card_hash="26a18343e72a4989",native_validated=false,template_id=288,image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_locust",play_menu_ref="sat_zm_locust",category_ref="sat_zm_category_guided",id=1000000028,image_key="0x1a03af08b21e93ad",card_hash="26a18343e72a4989",native_validated=false,template_id=289,image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_locust",play_menu_ref="sat_zm_locust",category_ref="sat_zm_category_guided",id=1000000029,image_key="0x1a03af08b21e93ad",card_hash="26a18343e72a4989",native_validated=false,template_id=290,image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",category_ref="sat_zm_category_r_mod",id=1000000030,image_key="0x1a03af08b21e93ad",card_hash="7fe13f91c1ac8183",native_validated=false,template_id=172,image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",category_ref="sat_zm_category_r_mod",id=1000000031,image_key="0x1a03af08b21e93ad",card_hash="7fe13f91c1ac8183",native_validated=false,template_id=197,image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",category_ref="sat_zm_category_r_mod",id=1000000032,image_key="0x1a03af08b21e93ad",card_hash="7fe13f91c1ac8183",native_validated=false,template_id=417,image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",category_ref="sat_zm_category_guided",id=1000000033,image_key="0x1a03af08b21e93ad",card_hash="7fe13f91c1ac8183",native_validated=false,template_id=288,image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",category_ref="sat_zm_category_guided",id=1000000034,image_key="0x1a03af08b21e93ad",card_hash="7fe13f91c1ac8183",native_validated=false,template_id=289,image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",category_ref="sat_zm_category_guided",id=1000000035,image_key="0x1a03af08b21e93ad",card_hash="7fe13f91c1ac8183",native_validated=false,template_id=290,image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",category_ref="sat_zm_category_r_mod",id=1000000036,image_key="0x1a03af08b21e93ad",card_hash="04a45d86de36893d",native_validated=false,template_id=172,image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",category_ref="sat_zm_category_r_mod",id=1000000037,image_key="0x1a03af08b21e93ad",card_hash="04a45d86de36893d",native_validated=false,template_id=197,image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",category_ref="sat_zm_category_r_mod",id=1000000038,image_key="0x1a03af08b21e93ad",card_hash="04a45d86de36893d",native_validated=false,template_id=417,image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",category_ref="sat_zm_category_guided",id=1000000039,image_key="0x1a03af08b21e93ad",card_hash="04a45d86de36893d",native_validated=false,template_id=288,image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",category_ref="sat_zm_category_guided",id=1000000040,image_key="0x1a03af08b21e93ad",card_hash="04a45d86de36893d",native_validated=false,template_id=289,image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",category_ref="sat_zm_category_guided",id=1000000041,image_key="0x1a03af08b21e93ad",card_hash="04a45d86de36893d",native_validated=false,template_id=290,image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",eligibility="Shipped mode tuning/consumer + original mode/profile filter; local membership"},{map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_starting_room",category_ref="sat_zm_category_starting_room",id=1000000042,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=58},{map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_starting_room",category_ref="sat_zm_category_starting_room",id=1000000043,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=24},{map="zm_sat_ruby",play_menu_ref="sat_zm_ruby_starting_room",category_ref="sat_zm_category_starting_room",id=1000000044,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=58},{map="zm_sat_ruby",play_menu_ref="sat_zm_ruby_starting_room",category_ref="sat_zm_category_starting_room",id=1000000045,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=24},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis_starting_room",category_ref="sat_zm_category_starting_room",id=1000000046,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=58},{map="zm_sat_mantis",play_menu_ref="sat_zm_mantis_starting_room",category_ref="sat_zm_category_starting_room",id=1000000047,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=24},{map="zm_sat_locust",play_menu_ref="sat_zm_locust_starting_room",category_ref="sat_zm_category_starting_room",id=1000000048,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=58},{map="zm_sat_locust",play_menu_ref="sat_zm_locust_starting_room",category_ref="sat_zm_category_starting_room",id=1000000049,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=24},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet_starting_room",category_ref="sat_zm_category_starting_room",id=1000000050,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=58},{map="zm_sat_hornet",play_menu_ref="sat_zm_hornet_starting_room",category_ref="sat_zm_category_starting_room",id=1000000051,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=24},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab_starting_room",category_ref="sat_zm_category_starting_room",id=1000000052,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=58},{map="zm_sat_scarab",play_menu_ref="sat_zm_scarab_starting_room",category_ref="sat_zm_category_starting_room",id=1000000053,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s5_5_zm_scarab",native_validated=false,mode="zm_rb_startroom",eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",template_id=24},{map="zm_sat_mantis",play_menu_ref="lumen_zm_rogue_card_345872dd354a7fe3",category_ref="sat_zm_category_echo",id=1000000054,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",native_validated=false,rogue_variant="Paradox Junction Casual",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_mantis",play_menu_ref="lumen_zm_rogue_card_345872dd354a7fe3",category_ref="sat_zm_category_echo",id=1000000055,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",native_validated=false,rogue_variant="Paradox Junction Casual",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_hornet",play_menu_ref="lumen_zm_rogue_card_175e7e687baf35ff",category_ref="sat_zm_category_echo",id=1000000056,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",native_validated=false,rogue_variant="Kowakujo Casual",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_hornet",play_menu_ref="lumen_zm_rogue_card_175e7e687baf35ff",category_ref="sat_zm_category_echo",id=1000000057,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",native_validated=false,rogue_variant="Kowakujo Casual",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_09f6261fd8a91a5e",category_ref="sat_zm_category_echo",id=1000000058,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="Endurance",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_09f6261fd8a91a5e",category_ref="sat_zm_category_echo",id=1000000059,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="Endurance",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_45f7e2545aa1b65b",category_ref="sat_zm_category_echo",id=1000000060,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,rogue_variant="Astra Malorum Casual",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_45f7e2545aa1b65b",category_ref="sat_zm_category_echo",id=1000000061,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,rogue_variant="Astra Malorum Casual",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_firefly",poi="zone_farm",category_ref="sat_zm_category_r_mod_survival",id=1000000062,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_firefly_farm",template_id=197},{map="zm_sat_firefly",poi="zone_farm",category_ref="sat_zm_category_r_mod_survival",id=1000000063,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_firefly_farm",template_id=172},{map="zm_sat_firefly",poi="zone_launchpad",category_ref="sat_zm_category_r_mod_survival",id=1000000064,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_firefly_launchpad",template_id=197},{map="zm_sat_firefly",poi="zone_launchpad",category_ref="sat_zm_category_r_mod_survival",id=1000000065,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_firefly_launchpad",template_id=172},{map="zm_sat_firefly",poi="zone_exit115",category_ref="sat_zm_category_r_mod_survival",id=1000000066,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_firefly_exit115",template_id=197},{map="zm_sat_firefly",poi="zone_exit115",category_ref="sat_zm_category_r_mod_survival",id=1000000067,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_firefly_exit115",template_id=172},{map="zm_sat_firefly",poi="ashwood",category_ref="sat_zm_category_r_mod_survival",id=1000000068,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_firefly_ashwood",template_id=197},{map="zm_sat_firefly",poi="ashwood",category_ref="sat_zm_category_r_mod_survival",id=1000000069,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_firefly_ashwood",template_id=172},{map="zm_sat_ruby",poi="zone_temple",category_ref="sat_zm_category_r_mod_survival",id=1000000070,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_ruby_mars",template_id=197},{map="zm_sat_ruby",poi="zone_temple",category_ref="sat_zm_category_r_mod_survival",id=1000000071,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_ruby_mars",template_id=172},{map="zm_sat_mantis",poi="future",category_ref="sat_zm_category_r_mod_survival",id=1000000072,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_mantis_future",template_id=197},{map="zm_sat_mantis",poi="future",category_ref="sat_zm_category_r_mod_survival",id=1000000073,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_mantis_future",template_id=172},{map="zm_sat_locust",poi="zone_lighthouse",category_ref="sat_zm_category_r_mod_survival",id=1000000074,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_locust_lighthouse",template_id=197},{map="zm_sat_locust",poi="zone_lighthouse",category_ref="sat_zm_category_r_mod_survival",id=1000000075,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s3_5_zm_lofoten",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_locust_lighthouse",template_id=172},{map="zm_sat_hornet",poi="castle",category_ref="sat_zm_category_r_mod_survival",id=1000000076,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_hornet_castle",template_id=197},{map="zm_sat_hornet",poi="castle",category_ref="sat_zm_category_r_mod_survival",id=1000000077,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",native_validated=false,eligibility="Explicit local catalogue; shipped mode bundle, original card and original mode consumer. No official playlist ID or checksum.",mode="zm_rb_r_mod_survival",play_menu_ref="sat_zm_hornet_castle",template_id=172},{map="zm_sat_hornet",play_menu_ref="lumen_zm_rogue_card_14721d593df86cf3",category_ref="sat_zm_category_echo",id=1000000078,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",native_validated=false,rogue_variant="Kowakujo Hardcore",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_hornet",play_menu_ref="lumen_zm_rogue_card_14721d593df86cf3",category_ref="sat_zm_category_echo",id=1000000079,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s4_5_zm_hornet",native_validated=false,rogue_variant="Kowakujo Hardcore",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_mantis",play_menu_ref="lumen_zm_rogue_card_68d2d4ee6946f777",category_ref="sat_zm_category_echo",id=1000000080,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",native_validated=false,rogue_variant="Paradox Junction Hardcore",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_mantis",play_menu_ref="lumen_zm_rogue_card_68d2d4ee6946f777",category_ref="sat_zm_category_echo",id=1000000081,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_s2_5_zm_nuketown",native_validated=false,rogue_variant="Paradox Junction Hardcore",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_6d30db53dfc85895",category_ref="sat_zm_category_echo",id=1000000082,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,rogue_variant="Astra Malorum Normal",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_6d30db53dfc85895",category_ref="sat_zm_category_echo",id=1000000083,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,rogue_variant="Astra Malorum Normal",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_50be99eafb07791f",category_ref="sat_zm_category_echo",id=1000000084,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,rogue_variant="Astra Malorum Hardcore",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_50be99eafb07791f",category_ref="sat_zm_category_echo",id=1000000085,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_ruby",native_validated=false,rogue_variant="Astra Malorum Hardcore",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_209eb6266574682b",category_ref="sat_zm_category_echo",id=1000000086,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="Target: Luci",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_209eb6266574682b",category_ref="sat_zm_category_echo",id=1000000087,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="Target: Luci",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_5e4dcf2688b0e8a5",category_ref="sat_zm_category_echo",id=1000000088,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="Target: Mal",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_5e4dcf2688b0e8a5",category_ref="sat_zm_category_echo",id=1000000089,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="Target: Mal",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_474c0333fc6ce76f",category_ref="sat_zm_category_echo",id=1000000090,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="Target: Mo",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_474c0333fc6ce76f",category_ref="sat_zm_category_echo",id=1000000091,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="Target: Mo",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_294a6f26226a80d8",category_ref="sat_zm_category_echo",id=1000000092,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="All Targets",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=58},{map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_294a6f26226a80d8",category_ref="sat_zm_category_echo",id=1000000093,image_key="0x1a03af08b21e93ad",image="ui_menu_codhq_tile_whatshot_bo7_zm_firefly",native_validated=false,rogue_variant="All Targets",mode="zm_rb_echo",eligibility="Original card and original Echo map producer/consumers; local playlist identity. Full service preset not recovered.",template_id=24}},asset_refs={lumen_zm_rogue_card_294a6f26226a80d8="0x294a6f26226a80d8",lumen_zm_rogue_card_09f6261fd8a91a5e="0x09f6261fd8a91a5e",lumen_zm_rogue_card_209eb6266574682b="0x209eb6266574682b",lumen_zm_rogue_card_474c0333fc6ce76f="0x474c0333fc6ce76f",lumen_zm_rogue_card_5e4dcf2688b0e8a5="0x5e4dcf2688b0e8a5",lumen_zm_rogue_card_45f7e2545aa1b65b="0x45f7e2545aa1b65b",lumen_zm_rogue_card_6d30db53dfc85895="0x6d30db53dfc85895",lumen_zm_rogue_card_50be99eafb07791f="0x50be99eafb07791f",lumen_zm_rogue_card_175e7e687baf35ff="0x175e7e687baf35ff",lumen_zm_rogue_card_14721d593df86cf3="0x14721d593df86cf3",lumen_zm_rogue_card_345872dd354a7fe3="0x345872dd354a7fe3",lumen_zm_rogue_card_68d2d4ee6946f777="0x68d2d4ee6946f777"},save_confirmations={{prototype=39,owner="END_GAME",key="0x6bd0f388600a1cda"}},category_additions={{image_key="0x1a03af08b21e93ad",ref="sat_zm_category_starting_room",index=1000001000,template_ref="sat_zm_category_classic"},{image_key="0x1a03af08b21e93ad",ref="sat_zm_category_echo",index=1000001001,template_ref="sat_zm_category_classic"},{image_key="0x1a03af08b21e93ad",ref="sat_zm_category_r_mod_survival",index=1000001002,template_ref="sat_zm_category_r_mod"}},native_pair_queries={{source="original prototype 28, constant 4",index=1,key="0xa641409e07f9c356",category=2},{source="original prototype 83, constant 9",index=1,key="0xdf579c6143f5718d",category=2},{source="original prototype 88, constant 4",index=1,key="0xa1e9a4ccd95dc9df",category=2},{source="original prototype 89, constant 4",index=1,key="0xe205a42faf897169",category=2},{source="original prototype 145, constant 4",index=2,key="0x193406d9932d0cb5",category=1},{source="original prototype 145, constant 24",index=1,key="0xac6d2203effd8bd0",category=2},{source="Original MPPublicLobby p14 line129 / MatchmakingReadyUp p4 line77",index=2,key="0xe55d7805da008136",category=1},{source="Original PlaylistUtils p37 result1=categoryIndex/result2=playlistIndex",index=2,key="0x3d9394bfc73475c8",category=1},{source="Original PlaylistUtils p37 line892",index=1,key="0x6d07a860e0b6a3bd",category=2},{source="Original PlaylistUtils p37 line894",index=1,key="0x1376b8609be6b44c",category=2},{source="Original PlaylistUtils p77 line1598",index=1,key="0xe6a4b10f04aaeafb",category=2},{source="Original PlaylistUtils p77; PLAY_MENU p129 passes ID/categoryIndex/playlistIndex/controller",index=2,key="0x6df9b927aad62953",category=1}},fields={"name","desc","mapName","subCategoryName","image","index","minPlayerSize","maxPlayerSize","minPartySize","maxPartySize","timeLimit","scoreLimit","numRounds","isNew","isFeatured","gamemodekey","xpScale","weaponXpScale","battlePassXpScale","isLimitedTime","ID","playMenuRef","tags","missionName","startTime","endTime","isTimerHidden","isOneParty","isRestrictF2P","isCasualQuickplay","isZMSurvivalPlaylist","ZMCursedTierMin","ZMCursedTierMax","isOpen","isPersistentLobby","isExternal","attestationPolicy"},records={[309]={map="zm_sat_ztron4",maxparty=1,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[3](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[15](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[22](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[33](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="35d0d7f59e151df3dd64105d6c21480234e666c51b3e75bcd26ea2cc86378a10"},[219]={map="zm_sat_firefly",maxparty=1,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[42](),c[43](),c[44](),c[6](),c[45](),c[46](),c[47](),c[48](),c[49](),c[50](),c[51](),c[18](),c[22](),c[52](),c[53](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[57](),c[58](),c[59]()},source_sha256="b5f5f58725a9f5a6f85e9b25c697eeb64b8a71c116782dd1f3badc015de6473a"},[59]={map="zm_sat_firefly",maxparty=1,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[60](),c[42](),c[43](),c[6](),c[45](),c[46](),c[47](),c[48](),c[49](),c[50](),c[51](),c[18](),c[22](),c[52](),c[61](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[62](),c[58](),c[59]()},source_sha256="dae194f0d48de02806ecb373f2755709c3a68d1f64d582e5926fe1c123b5cb6d"},[66]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[42](),c[43](),c[6](),c[45](),c[46](),c[47](),c[48](),c[50](),c[51](),c[18](),c[63](),c[52](),c[64](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[65](),c[58](),c[59]()},source_sha256="144860d87a9c29f7daa41ec96eabf68615ae36ce0d6aaf7dc9c87627bd7e582f"},[74]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[69](),c[35](),c[36](),c[37](),c[38](),c[70](),c[39](),c[40](),c[41]()},source_sha256="a51f44c38c2fd494daf97d6847837350e50b1f548bde2cc38144a43b71141e23"},[172]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_r_mod",asset="zm_rb_r_mod",command="zm_rb_r_mod",local_record=false,configuration={c[71](),c[2](),c[42](),c[72](),c[6](),c[46](),c[47](),c[48](),c[51](),c[18](),c[63](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[75](),c[76](),c[77](),c[58](),c[78](),c[79]()},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874"},[220]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[42](),c[43](),c[44](),c[6](),c[45](),c[46](),c[47](),c[48](),c[50](),c[51](),c[18](),c[63](),c[52](),c[53](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[57](),c[58](),c[59]()},source_sha256="0e9f2fd91fd16e9453de03d154baf0a7f7bec8af859337147df4dfe8c432a4a9"},[328]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[3](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[80](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[33](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="98ac75e88d220e6c1620031d9e85c4b86921033d2adacceac14421dae7a1152e"},[1000000000]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",template_id=58,local_record=true,asset="sat_zm_rb",source_gametype="p_gametype_sat_rb",maxparty=1,command="zm_rb",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[89](),c[90](),c[91](),c[92](),c[78](),c[79](),c[93]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772"},[1000000002]={map="zm_sat_locust",play_menu_ref="sat_zm_locust",template_id=58,local_record=true,asset="sat_zm_rb",source_gametype="p_gametype_sat_rb",maxparty=1,command="zm_rb",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[94](),c[95](),c[96](),c[92](),c[78](),c[79](),c[93]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772"},[1000000004]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",template_id=58,local_record=true,asset="sat_zm_rb",source_gametype="p_gametype_sat_rb",maxparty=1,command="zm_rb",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[97](),c[98](),c[99](),c[92](),c[78](),c[79](),c[93]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772"},[329]={map="zm_sat_ztron4",maxparty=1,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[3](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[80](),c[12](),c[13](),c[14](),c[15](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[22](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[33](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="591c18749ac80a030420d1c61e70289eb4920411729757044832a0aeed87ba40"},[1000000008]={map="zm_sat_firefly",poi="ashwood",template_id=59,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=1,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[100](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="dae194f0d48de02806ecb373f2755709c3a68d1f64d582e5926fe1c123b5cb6d",play_menu_ref="sat_zm_firefly_ashwood"},[1000000010]={map="zm_sat_ruby",poi="zone_temple",template_id=59,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=1,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[101](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="dae194f0d48de02806ecb373f2755709c3a68d1f64d582e5926fe1c123b5cb6d",play_menu_ref="sat_zm_ruby_mars"},[1000000012]={map="zm_sat_mantis",poi="future",template_id=59,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=1,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[102](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="dae194f0d48de02806ecb373f2755709c3a68d1f64d582e5926fe1c123b5cb6d",play_menu_ref="sat_zm_mantis_future"},[1000000014]={map="zm_sat_locust",poi="zone_lighthouse",template_id=59,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=1,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[103](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="dae194f0d48de02806ecb373f2755709c3a68d1f64d582e5926fe1c123b5cb6d",play_menu_ref="sat_zm_locust_lighthouse"},[1000000016]={map="zm_sat_hornet",poi="castle",template_id=59,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=1,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[104](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="dae194f0d48de02806ecb373f2755709c3a68d1f64d582e5926fe1c123b5cb6d",play_menu_ref="sat_zm_hornet_castle"},[1000000018]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",template_id=172,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=4,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[89](),c[90](),c[91](),c[92](),c[78](),c[79](),c[105]()},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874"},[1000000020]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",template_id=417,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=4,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[89](),c[90](),c[91](),c[92](),c[78](),c[79](),c[106]()},source_sha256="69230cb2430178cc7b8439415a6070768df17bf0cb40ff9c8865fe3d67101ff3"},[1000000022]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",template_id=289,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=4,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[89](),c[90](),c[107](),c[92](),c[108](),c[79](),c[109]()},source_sha256="53c449ce64032d79cb253bbfec86739a00b5163f0be70d01abfe412836dc78f0"},[1000000024]={map="zm_sat_locust",play_menu_ref="sat_zm_locust",template_id=172,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=4,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[94](),c[95](),c[96](),c[92](),c[78](),c[79](),c[105]()},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874"},[1000000026]={map="zm_sat_locust",play_menu_ref="sat_zm_locust",template_id=417,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=4,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[94](),c[95](),c[96](),c[92](),c[78](),c[79](),c[106]()},source_sha256="69230cb2430178cc7b8439415a6070768df17bf0cb40ff9c8865fe3d67101ff3"},[1000000028]={map="zm_sat_locust",play_menu_ref="sat_zm_locust",template_id=289,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=4,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[94](),c[95](),c[110](),c[92](),c[108](),c[79](),c[109]()},source_sha256="53c449ce64032d79cb253bbfec86739a00b5163f0be70d01abfe412836dc78f0"},[1000000030]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",template_id=172,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=4,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[97](),c[98](),c[99](),c[92](),c[78](),c[79](),c[105]()},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874"},[1000000032]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",template_id=417,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=4,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[97](),c[98](),c[99](),c[92](),c[78](),c[79](),c[106]()},source_sha256="69230cb2430178cc7b8439415a6070768df17bf0cb40ff9c8865fe3d67101ff3"},[1000000034]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",template_id=289,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=4,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[97](),c[98](),c[111](),c[92](),c[108](),c[79](),c[109]()},source_sha256="53c449ce64032d79cb253bbfec86739a00b5163f0be70d01abfe412836dc78f0"},[1000000036]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",template_id=172,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=4,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[112](),c[113](),c[92](),c[78](),c[79](),c[114](),c[115](),c[105]()},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874"},[330]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[80](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="303f7276b79353e92d158e59928ce85033b83e65b69721b0aa0fb7e62acd8671"},[1000000040]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",template_id=289,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=4,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[112](),c[116](),c[92](),c[108](),c[79](),c[114](),c[115](),c[109]()},source_sha256="53c449ce64032d79cb253bbfec86739a00b5163f0be70d01abfe412836dc78f0"},[1000000042]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_starting_room",template_id=58,local_record=true,configuration={c[18](),c[22]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000044]={map="zm_sat_ruby",play_menu_ref="sat_zm_ruby_starting_room",template_id=58,local_record=true,configuration={c[18](),c[22]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000046]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis_starting_room",template_id=58,local_record=true,configuration={c[18](),c[22]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000048]={map="zm_sat_locust",play_menu_ref="sat_zm_locust_starting_room",template_id=58,local_record=true,configuration={c[18](),c[22]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000050]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet_starting_room",template_id=58,local_record=true,configuration={c[18](),c[22]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000052]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab_starting_room",template_id=58,local_record=true,configuration={c[18](),c[22]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000054]={map="zm_sat_mantis",play_menu_ref="lumen_zm_rogue_card_345872dd354a7fe3",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[118](),c[119]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Paradox Junction Casual",mode_override=true,original_card_asset="345872dd354a7fe3",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000056]={map="zm_sat_hornet",play_menu_ref="lumen_zm_rogue_card_175e7e687baf35ff",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[118](),c[119]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Kowakujo Casual",mode_override=true,original_card_asset="175e7e687baf35ff",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000058]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_09f6261fd8a91a5e",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[118](),c[119]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Endurance",mode_override=true,original_card_asset="09f6261fd8a91a5e",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000060]={map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_45f7e2545aa1b65b",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[118](),c[119]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Astra Malorum Casual",mode_override=true,original_card_asset="45f7e2545aa1b65b",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000062]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_farm",template_id=197,local_record=true,configuration={c[18](),c[22](),c[120](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc",maxparty=1,mode_contract_hash="1883a7c30b6a6229",poi="zone_farm",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000064]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_launchpad",template_id=197,local_record=true,configuration={c[18](),c[22](),c[121](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc",maxparty=1,mode_contract_hash="1883a7c30b6a6229",poi="zone_launchpad",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000066]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_exit115",template_id=197,local_record=true,configuration={c[18](),c[22](),c[122](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc",maxparty=1,mode_contract_hash="1883a7c30b6a6229",poi="zone_exit115",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000068]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_ashwood",template_id=197,local_record=true,configuration={c[18](),c[22](),c[123](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc",maxparty=1,mode_contract_hash="1883a7c30b6a6229",poi="ashwood",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[331]={map="zm_sat_ztron4",maxparty=1,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[80](),c[12](),c[13](),c[14](),c[15](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[22](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="5b6ee62d2559775e74bb6e54c2ca5a01765b276611867ed1e5c5bc329d690357"},[1000000072]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis_future",template_id=197,local_record=true,configuration={c[18](),c[22](),c[124](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc",maxparty=1,mode_contract_hash="1883a7c30b6a6229",poi="future",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000074]={map="zm_sat_locust",play_menu_ref="sat_zm_locust_lighthouse",template_id=197,local_record=true,configuration={c[18](),c[22](),c[125](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc",maxparty=1,mode_contract_hash="1883a7c30b6a6229",poi="zone_lighthouse",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000076]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet_castle",template_id=197,local_record=true,configuration={c[18](),c[22](),c[126](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc",maxparty=1,mode_contract_hash="1883a7c30b6a6229",poi="castle",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000078]={map="zm_sat_hornet",play_menu_ref="lumen_zm_rogue_card_14721d593df86cf3",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[127](),c[119]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Kowakujo Hardcore",mode_override=true,original_card_asset="14721d593df86cf3",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000080]={map="zm_sat_mantis",play_menu_ref="lumen_zm_rogue_card_68d2d4ee6946f777",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[127](),c[119]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Paradox Junction Hardcore",mode_override=true,original_card_asset="68d2d4ee6946f777",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000082]={map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_6d30db53dfc85895",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[128](),c[119]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Astra Malorum Normal",mode_override=true,original_card_asset="6d30db53dfc85895",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[222]={map="zm_sat_firefly",maxparty=1,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[42](),c[43](),c[6](),c[45](),c[46](),c[47](),c[48](),c[49](),c[50](),c[51](),c[18](),c[22](),c[52](),c[64](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[65](),c[58](),c[59]()},source_sha256="4b1b751da16b02324bc7de7f033f589f074263a780069eaf56da66d77e8d09d7"},[1000000086]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_209eb6266574682b",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[118](),c[129]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Target: Luci",mode_override=true,original_card_asset="209eb6266574682b",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000088]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_5e4dcf2688b0e8a5",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[118](),c[130]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Target: Mal",mode_override=true,original_card_asset="5e4dcf2688b0e8a5",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000090]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_474c0333fc6ce76f",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[118](),c[131]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Target: Mo",mode_override=true,original_card_asset="474c0333fc6ce76f",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000092]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_294a6f26226a80d8",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[118](),c[132]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="All Targets",mode_override=true,original_card_asset="294a6f26226a80d8",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[24]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb",asset="sat_zm_rb",command="zm_rb",local_record=false,configuration={c[2](),c[42](),c[6](),c[45](),c[46](),c[47](),c[48](),c[51](),c[18](),c[63](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[75](),c[76](),c[77](),c[58](),c[78](),c[79]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696"},[285]={map="zm_sat_ruby",maxparty=4,source_gametype="p_gametype_sat_rb_directed",asset="sat_zm_guided",command="zm_guided",local_record=false,configuration={c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[134](),c[51](),c[18](),c[135](),c[63](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[58](),c[92](),c[108](),c[79](),c[136]()},source_sha256="1ee516d4282befd97368e931b50c35dd28c4c7d68c7e5a6bb04634c7787a6c0f"},[50]={map="zm_sat_ruby",maxparty=4,source_gametype="p_gametype_sat_rb",asset="sat_zm_rb",command="zm_rb",local_record=false,configuration={c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[48](),c[51](),c[18](),c[135](),c[63](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[58](),c[78](),c[79](),c[136]()},source_sha256="e7cdba7213bf5cd04e73846966ea4d8fa3a826481e4efa17b8ad82212790ff47"},[54]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[60](),c[42](),c[43](),c[6](),c[45](),c[46](),c[47](),c[48](),c[50](),c[51](),c[18](),c[63](),c[52](),c[61](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[62](),c[58](),c[59]()},source_sha256="43554f5b8bc9b814bd582396d9e152627648d5927b287a6487fd3963b59b31fa"},[223]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb",asset="sat_zm_rb",command="zm_rb",local_record=false,configuration={c[2](),c[42](),c[6](),c[45](),c[46](),c[47](),c[48](),c[51](),c[18](),c[63](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[75](),c[76](),c[77](),c[58](),c[78](),c[79]()},source_sha256="63ca485710ed652f717ec2701635fba0cd7dd9fed3b8b527abf4e8ef97405bfd"},[58]={map="zm_sat_firefly",maxparty=1,source_gametype="p_gametype_sat_rb",asset="sat_zm_rb",command="zm_rb",local_record=false,configuration={{key="0x072e4d6b8f8afa03",console_key="#x372e4d6b8f8afa03",value=1,kind="int",consumer_default=0,required=false},c[2](),c[42](),c[6](),c[45](),c[46](),c[47](),c[48](),c[49](),c[51](),c[18](),c[22](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[75](),c[76](),c[77](),c[58](),c[78](),c[79]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772"},[247]={map="zm_sat_firefly",maxparty=1,source_gametype="p_gametype_sat_rb_training_course",asset="sat_zm_training_course",command="zm_training_course",local_record=false,configuration={{key="0x08f346cd186641d5",console_key="#x38f346cd186641d5",value=0,kind="int",consumer_default=1,required=false},c[2](),{key="0x0ee0e5c147b44222",console_key="#x3ee0e5c147b44222",value=1,kind="int",consumer_default=0,required=false},c[42](),c[6](),c[46](),c[47](),{key="0x58b6c6f19581070c",console_key="#x358b6c6f19581070c",kind="int",value=1,required=false},c[50](),c[51](),c[18](),c[22](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[58](),{key="0xfad294eacb78070c",console_key="#x3fad294eacb78070c",value=0,kind="int",consumer_default=1,required=false}},source_sha256="9fb15fa0363c21bbcbaf84ae4f2dc9ccf81240199adba38690c850784fdf126b"},[64]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="c8a7f6dcdd931272739e201788240f93664124318c72fcea1c4db88328274fb9"},[286]={map="zm_sat_ruby",maxparty=4,source_gametype="p_gametype_sat_rb_directed",asset="sat_zm_guided",command="zm_guided",local_record=false,configuration={c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[134](),c[51](),c[18](),c[135](),c[63](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[58](),c[92](),c[108](),c[79](),c[136]()},source_sha256="ca0fbf898e601bd4209bc40824702cc58e864d3f911e4bb8e2104570d3a3bb14"},[414]={map="zm_sat_ruby",maxparty=4,source_gametype="p_gametype_sat_rb_r_mod",asset="zm_rb_r_mod",command="zm_rb_r_mod",local_record=false,configuration={c[71](),c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[48](),c[51](),c[18](),c[135](),c[63](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[58](),c[78](),c[79](),c[136]()},source_sha256="932411f62e782c78cbfdb1481bc53d5bfef4dc9a7b13fe24bf31de1dacb0ee27"},[478]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[80](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="09f2295692b868ced5752c4477a2af71df43b725cf01eaa6676e41a585679f94"},[287]={map="zm_sat_ruby",maxparty=1,source_gametype="p_gametype_sat_rb_directed",asset="sat_zm_guided",command="zm_guided",local_record=false,configuration={c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[134](),c[49](),c[51](),c[18](),c[135](),c[22](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[58](),c[92](),c[108](),c[79](),c[136]()},source_sha256="8280e2105fc48b5aaeba8d50239b6377b1117d73306e809ee1ac9d09706f8450"},[415]={map="zm_sat_ruby",maxparty=4,source_gametype="p_gametype_sat_rb_r_mod",asset="zm_rb_r_mod",command="zm_rb_r_mod",local_record=false,configuration={c[71](),c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[48](),c[51](),c[18](),c[135](),c[63](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[58](),c[78](),c[79](),c[136]()},source_sha256="70bda254e246e2c2e03325a81d442b14059957577e76bc835a2e4ec5c29f02f1"},[224]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[60](),c[42](),c[43](),c[6](),c[45](),c[46](),c[47](),c[48](),c[50](),c[51](),c[18](),c[63](),c[52](),c[61](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[62](),c[58](),c[59]()},source_sha256="893f1a2c5d97d5d87c7624a491ef7bc2e5b69cdefa62baf006b85deeaf28b46a"},[479]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[3](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[33](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="292a25cbb4afc13ac7e980e17d3c4b74ea0e47f25af02dc8f209dd3aaf8d5195"},[288]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_directed",asset="sat_zm_guided",command="zm_guided",local_record=false,configuration={c[2](),c[42](),c[6](),c[46](),c[47](),c[134](),c[51](),c[18](),c[63](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[137](),c[76](),c[77](),c[58](),c[108](),c[79]()},source_sha256="757c3200c7d261dbfdc1d6864dd1a5ec44574e91c50b58ee4a6c8551d225f60b"},[417]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_r_mod",asset="zm_rb_r_mod",command="zm_rb_r_mod",local_record=false,configuration={c[71](),c[2](),c[42](),c[72](),c[6](),c[46](),c[47](),c[48](),c[51](),c[18](),c[63](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[75](),c[76](),c[77](),c[58](),c[78](),c[79]()},source_sha256="69230cb2430178cc7b8439415a6070768df17bf0cb40ff9c8865fe3d67101ff3"},[221]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[42](),c[43](),c[6](),c[45](),c[46](),c[47](),c[48](),c[50](),c[51](),c[18](),c[63](),c[52](),c[64](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[65](),c[58](),c[59]()},source_sha256="a0fa3d8c9bb4b1c207b18a468ee6881841ae31488f20db8619107254b293883a"},[416]={map="zm_sat_ruby",maxparty=1,source_gametype="p_gametype_sat_rb_r_mod",asset="zm_rb_r_mod",command="zm_rb_r_mod",local_record=false,configuration={c[71](),c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[48](),c[49](),c[51](),c[18](),c[135](),c[22](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[58](),c[78](),c[79](),c[136]()},source_sha256="576e1b0034eb71f6035badf9500b2bf59f77e68a6d19ab2098254700b83c4d8a"},[1000000021]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",template_id=288,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=4,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[89](),c[90](),c[107](),c[92](),c[108](),c[79](),c[138]()},source_sha256="757c3200c7d261dbfdc1d6864dd1a5ec44574e91c50b58ee4a6c8551d225f60b"},[448]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_daisy",asset="zm_rb_daisy",local_record=false,configuration={c[2](),c[42](),c[6](),c[46](),c[47](),c[48](),c[51](),c[18](),c[63](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[139](),c[140](),c[141](),c[58]()},source_sha256="9c305dc0685b53da719ab7f1985e7e762b930c44d34c710f7c73d33c52e719bb"},[241]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="7313c421ba4937a4491e15df58e762afa1f261aa3957f1904a762a6aa1aff6e9"},[480]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[3](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[80](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[33](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="aecab7ba371c4c64c9f60ee6f2cf1f3a1860a17dadf7beca34a477ea04e1a1bc"},[1000000025]={map="zm_sat_locust",play_menu_ref="sat_zm_locust",template_id=197,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=1,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[94](),c[95](),c[96](),c[92](),c[78](),c[79](),c[142]()},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc"},[450]={map="zm_sat_firefly",maxparty=1,source_gametype="p_gametype_sat_rb_daisy",asset="zm_rb_daisy",local_record=false,configuration={c[2](),c[42](),c[6](),c[46](),c[47](),c[48](),c[49](),c[51](),c[18](),c[22](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[139](),c[140](),c[141](),c[58]()},source_sha256="c1022e6babcdf72f2bcd7ed86221c226811d346e867f7d58593a473b55c98bab"},[72]={map="zm_sat_ruby",maxparty=1,source_gametype="p_gametype_sat_rb",asset="sat_zm_rb",command="zm_rb",local_record=false,configuration={c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[48](),c[49](),c[51](),c[18](),c[135](),c[22](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[58](),c[78](),c[79](),c[136]()},source_sha256="c015720772f6b25bd31a0c50c338e47d4a3222fcc6e90c52a68fa5374931f0fe"},[289]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_directed",asset="sat_zm_guided",command="zm_guided",local_record=false,configuration={c[2](),c[42](),c[6](),c[46](),c[47](),c[134](),c[51](),c[18](),c[63](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[137](),c[76](),c[77](),c[58](),c[108](),c[79]()},source_sha256="53c449ce64032d79cb253bbfec86739a00b5163f0be70d01abfe412836dc78f0"},[1000000003]={map="zm_sat_locust",play_menu_ref="sat_zm_locust",template_id=24,local_record=true,asset="sat_zm_rb",source_gametype="p_gametype_sat_rb",maxparty=4,command="zm_rb",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[94](),c[95](),c[96](),c[92](),c[78](),c[79](),c[143]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696"},[1000000005]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",template_id=24,local_record=true,asset="sat_zm_rb",source_gametype="p_gametype_sat_rb",maxparty=4,command="zm_rb",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[97](),c[98](),c[99](),c[92](),c[78](),c[79](),c[143]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696"},[1000000007]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",template_id=24,local_record=true,asset="sat_zm_rb",source_gametype="p_gametype_sat_rb",maxparty=4,command="zm_rb",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[112](),c[113](),c[92](),c[78](),c[79](),c[114](),c[115](),c[143]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696"},[1000000009]={map="zm_sat_firefly",poi="ashwood",template_id=54,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=4,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[100](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="43554f5b8bc9b814bd582396d9e152627648d5927b287a6487fd3963b59b31fa",play_menu_ref="sat_zm_firefly_ashwood"},[1000000011]={map="zm_sat_ruby",poi="zone_temple",template_id=54,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=4,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[101](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="43554f5b8bc9b814bd582396d9e152627648d5927b287a6487fd3963b59b31fa",play_menu_ref="sat_zm_ruby_mars"},[1000000013]={map="zm_sat_mantis",poi="future",template_id=54,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=4,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[102](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="43554f5b8bc9b814bd582396d9e152627648d5927b287a6487fd3963b59b31fa",play_menu_ref="sat_zm_mantis_future"},[1000000015]={map="zm_sat_locust",poi="zone_lighthouse",template_id=54,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=4,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[103](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="43554f5b8bc9b814bd582396d9e152627648d5927b287a6487fd3963b59b31fa",play_menu_ref="sat_zm_locust_lighthouse"},[1000000017]={map="zm_sat_hornet",poi="castle",template_id=54,local_record=true,asset="sat_zm_rb_survival",source_gametype="p_gametype_sat_rb_survival",maxparty=4,command="zm_rb_survival",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[104](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="43554f5b8bc9b814bd582396d9e152627648d5927b287a6487fd3963b59b31fa",play_menu_ref="sat_zm_hornet_castle"},[217]={map="zm_sat_ruby",maxparty=4,source_gametype="p_gametype_sat_rb",asset="sat_zm_rb",command="zm_rb",local_record=false,configuration={c[2](),c[42](),c[6](),c[133](),c[46](),c[47](),c[48](),c[51](),c[18](),c[135](),c[63](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[58](),c[78](),c[79](),c[136]()},source_sha256="2fc4598e2bf29094cc24ee8fa678f7c1f14f41fe60c8fb6256cd9370cc21eb4c"},[449]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_daisy",asset="zm_rb_daisy",local_record=false,configuration={c[2](),c[42](),c[6](),c[46](),c[47](),c[48](),c[51](),c[18](),c[63](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[139](),c[140](),c[141](),c[58]()},source_sha256="bc25bec3a0c69ba1e72e4d05d0423bb12bc12ede90db1fea166dbedb3f50d73c"},[1000000023]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",template_id=290,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=1,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[89](),c[90](),c[107](),c[92](),c[108](),c[79](),c[144]()},source_sha256="232e25b70a637d996e2977207997d2d120eee55769253c5a78a43a71bc9b1513"},[481]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[69](),c[35](),c[36](),c[37](),c[38](),c[70](),c[39](),c[40](),c[41]()},source_sha256="67febd43d1b9f560a46171dafced5d1645e148fc95c81b2033ed4813f5fb6dad"},[1000000027]={map="zm_sat_locust",play_menu_ref="sat_zm_locust",template_id=288,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=4,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[94](),c[95](),c[110](),c[92](),c[108](),c[79](),c[138]()},source_sha256="757c3200c7d261dbfdc1d6864dd1a5ec44574e91c50b58ee4a6c8551d225f60b"},[1000000029]={map="zm_sat_locust",play_menu_ref="sat_zm_locust",template_id=290,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=1,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[94](),c[95](),c[110](),c[92](),c[108](),c[79](),c[144]()},source_sha256="232e25b70a637d996e2977207997d2d120eee55769253c5a78a43a71bc9b1513"},[1000000031]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",template_id=197,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=1,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[97](),c[98](),c[99](),c[92](),c[78](),c[79](),c[142]()},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc"},[290]={map="zm_sat_firefly",maxparty=1,source_gametype="p_gametype_sat_rb_directed",asset="sat_zm_guided",command="zm_guided",local_record=false,configuration={c[2](),c[42](),c[6](),c[46](),c[47](),c[134](),c[49](),c[51](),c[18](),c[22](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[137](),c[76](),c[77](),c[58](),c[108](),c[79]()},source_sha256="232e25b70a637d996e2977207997d2d120eee55769253c5a78a43a71bc9b1513"},[1000000035]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",template_id=290,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=1,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[97](),c[98](),c[111](),c[92](),c[108](),c[79](),c[144]()},source_sha256="232e25b70a637d996e2977207997d2d120eee55769253c5a78a43a71bc9b1513"},[1000000037]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",template_id=197,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=1,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[112](),c[113](),c[92](),c[78](),c[79](),c[114](),c[115](),c[142]()},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc"},[1000000039]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",template_id=288,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=4,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[112](),c[116](),c[92](),c[108](),c[79](),c[114](),c[115](),c[138]()},source_sha256="757c3200c7d261dbfdc1d6864dd1a5ec44574e91c50b58ee4a6c8551d225f60b"},[1000000041]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",template_id=290,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=1,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[112](),c[116](),c[92](),c[108](),c[79](),c[114](),c[115](),c[144]()},source_sha256="232e25b70a637d996e2977207997d2d120eee55769253c5a78a43a71bc9b1513"},[1000000043]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_starting_room",template_id=24,local_record=true,configuration={c[18](),c[63]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000045]={map="zm_sat_ruby",play_menu_ref="sat_zm_ruby_starting_room",template_id=24,local_record=true,configuration={c[18](),c[63]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000047]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis_starting_room",template_id=24,local_record=true,configuration={c[18](),c[63]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000049]={map="zm_sat_locust",play_menu_ref="sat_zm_locust_starting_room",template_id=24,local_record=true,configuration={c[18](),c[63]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000051]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet_starting_room",template_id=24,local_record=true,configuration={c[18](),c[63]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000053]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab_starting_room",template_id=24,local_record=true,configuration={c[18](),c[63]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="45f6ed29006f5733",mode_override=true,source_gametype="local_zm_rb_startroom",asset="sat_zm_rb_startroom"},[1000000055]={map="zm_sat_mantis",play_menu_ref="lumen_zm_rogue_card_345872dd354a7fe3",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[118](),c[119]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Paradox Junction Casual",mode_override=true,original_card_asset="345872dd354a7fe3",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000057]={map="zm_sat_hornet",play_menu_ref="lumen_zm_rogue_card_175e7e687baf35ff",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[118](),c[119]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Kowakujo Casual",mode_override=true,original_card_asset="175e7e687baf35ff",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000059]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_09f6261fd8a91a5e",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[118](),c[119]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Endurance",mode_override=true,original_card_asset="09f6261fd8a91a5e",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000061]={map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_45f7e2545aa1b65b",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[118](),c[119]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Astra Malorum Casual",mode_override=true,original_card_asset="45f7e2545aa1b65b",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000063]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_farm",template_id=172,local_record=true,configuration={c[18](),c[63](),c[120](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874",maxparty=4,mode_contract_hash="1883a7c30b6a6229",poi="zone_farm",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000065]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_launchpad",template_id=172,local_record=true,configuration={c[18](),c[63](),c[121](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874",maxparty=4,mode_contract_hash="1883a7c30b6a6229",poi="zone_launchpad",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000067]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_exit115",template_id=172,local_record=true,configuration={c[18](),c[63](),c[122](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874",maxparty=4,mode_contract_hash="1883a7c30b6a6229",poi="zone_exit115",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000069]={map="zm_sat_firefly",play_menu_ref="sat_zm_firefly_ashwood",template_id=172,local_record=true,configuration={c[18](),c[63](),c[123](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874",maxparty=4,mode_contract_hash="1883a7c30b6a6229",poi="ashwood",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000071]={map="zm_sat_ruby",play_menu_ref="sat_zm_ruby_mars",template_id=172,local_record=true,configuration={c[18](),c[63](),c[145](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874",maxparty=4,mode_contract_hash="1883a7c30b6a6229",poi="zone_temple",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000073]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis_future",template_id=172,local_record=true,configuration={c[18](),c[63](),c[124](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874",maxparty=4,mode_contract_hash="1883a7c30b6a6229",poi="future",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000075]={map="zm_sat_locust",play_menu_ref="sat_zm_locust_lighthouse",template_id=172,local_record=true,configuration={c[18](),c[63](),c[125](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874",maxparty=4,mode_contract_hash="1883a7c30b6a6229",poi="zone_lighthouse",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000077]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet_castle",template_id=172,local_record=true,configuration={c[18](),c[63](),c[126](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="c3cb2f2f12fe79928eef553dc51d382ce299752872656cc3c3ad190c8cee5874",maxparty=4,mode_contract_hash="1883a7c30b6a6229",poi="castle",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[1000000079]={map="zm_sat_hornet",play_menu_ref="lumen_zm_rogue_card_14721d593df86cf3",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[127](),c[119]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Kowakujo Hardcore",mode_override=true,original_card_asset="14721d593df86cf3",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000081]={map="zm_sat_mantis",play_menu_ref="lumen_zm_rogue_card_68d2d4ee6946f777",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[127](),c[119]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Paradox Junction Hardcore",mode_override=true,original_card_asset="68d2d4ee6946f777",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000083]={map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_6d30db53dfc85895",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[128](),c[119]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Astra Malorum Normal",mode_override=true,original_card_asset="6d30db53dfc85895",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000085]={map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_50be99eafb07791f",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[127](),c[119]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Astra Malorum Hardcore",mode_override=true,original_card_asset="50be99eafb07791f",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000087]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_209eb6266574682b",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[118](),c[129]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Target: Luci",mode_override=true,original_card_asset="209eb6266574682b",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000089]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_5e4dcf2688b0e8a5",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[118](),c[130]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Target: Mal",mode_override=true,original_card_asset="5e4dcf2688b0e8a5",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000091]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_474c0333fc6ce76f",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[118](),c[131]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="Target: Mo",mode_override=true,original_card_asset="474c0333fc6ce76f",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[1000000093]={map="zm_sat_firefly",play_menu_ref="lumen_zm_rogue_card_294a6f26226a80d8",local_variant_policy=true,template_id=24,local_record=true,configuration={c[18](),c[63](),c[117](),c[118](),c[132]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696",maxparty=4,mode_contract_hash="12dd2112a3636d24",rogue_variant="All Targets",mode_override=true,original_card_asset="294a6f26226a80d8",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[65]={map="zm_sat_firefly",maxparty=4,source_gametype="p_gametype_sat_rb_survival",asset="sat_zm_rb_survival",command="zm_rb_survival",local_record=false,configuration={c[2](),c[42](),c[43](),c[44](),c[6](),c[45](),c[46](),c[47](),c[48](),c[50](),c[51](),c[18](),c[63](),c[52](),c[53](),c[27](),c[28](),c[54](),c[55](),c[32](),c[56](),c[57](),c[58](),c[59]()},source_sha256="6addeb4e3467f713c54e096a38d308e71b9615cf9987f9ddf662f12cf7ce37df"},[1000000001]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",template_id=24,local_record=true,asset="sat_zm_rb",source_gametype="p_gametype_sat_rb",maxparty=4,command="zm_rb",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[89](),c[90](),c[91](),c[92](),c[78](),c[79](),c[143]()},source_sha256="3c9db117003b936f574e740c6e392cca235fa9c5485bf3d24b2393893591f696"},[308]={map="zm_sat_ztron4",maxparty=1,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[15](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[22](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[69](),c[35](),c[36](),c[37](),c[38](),c[70](),c[39](),c[40](),c[41]()},source_sha256="542606943cf0a7bb585881f1888245d95d5851000bd69d946b49582c7ad0086b"},[1000000033]={map="zm_sat_hornet",play_menu_ref="sat_zm_hornet",template_id=288,local_record=true,asset="sat_zm_guided",source_gametype="p_gametype_sat_rb_directed",maxparty=4,command="zm_guided",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[97](),c[98](),c[111](),c[92](),c[108](),c[79](),c[138]()},source_sha256="757c3200c7d261dbfdc1d6864dd1a5ec44574e91c50b58ee4a6c8551d225f60b"},[1000000006]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",template_id=58,local_record=true,asset="sat_zm_rb",source_gametype="p_gametype_sat_rb",maxparty=1,command="zm_rb",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[112](),c[113](),c[92](),c[78](),c[79](),c[114](),c[115](),c[93]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772"},[1000000038]={map="zm_sat_scarab",play_menu_ref="sat_zm_scarab",template_id=417,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=4,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[63](),c[85](),c[86](),c[87](),c[88](),c[18](),c[112](),c[113](),c[92](),c[78](),c[79](),c[114](),c[115](),c[106]()},source_sha256="69230cb2430178cc7b8439415a6070768df17bf0cb40ff9c8865fe3d67101ff3"},[1000000070]={map="zm_sat_ruby",play_menu_ref="sat_zm_ruby_mars",template_id=197,local_record=true,configuration={c[18](),c[22](),c[145](),{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",kind="int",value=1,consumer_default=0,required=false}},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc",maxparty=1,mode_contract_hash="1883a7c30b6a6229",poi="zone_temple",mode_override=true,source_gametype="local_zm_rb_r_mod_survival",asset="zm_rb_r_mod_survival"},[197]={map="zm_sat_firefly",maxparty=1,source_gametype="p_gametype_sat_rb_r_mod",asset="zm_rb_r_mod",command="zm_rb_r_mod",local_record=false,configuration={c[71](),c[2](),c[42](),c[72](),c[6](),c[46](),c[47](),c[48](),c[49](),c[51](),c[18](),c[22](),c[52](),c[73](),c[27](),c[28](),c[54](),c[55](),c[32](),c[74](),c[75](),c[76](),c[77](),c[58](),c[78](),c[79]()},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc"},[499]={map="zm_sat_ruby",maxparty=4,source_gametype="p_gametype_sat_rb_daisy",asset="zm_rb_daisy",local_record=false,configuration={c[2](),c[42](),c[6](),c[146](),c[46](),c[47](),c[48](),c[51](),c[18](),c[135](),c[63](),c[147](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[58](),c[136]()},source_sha256="8b8e2272ce8a6d54fcd73a875a980da83ffc0db11bb8974311c715871ae4a7fa"},[451]={map="zm_sat_ruby",maxparty=4,source_gametype="p_gametype_sat_rb_daisy",asset="zm_rb_daisy",local_record=false,configuration={c[2](),c[42](),c[6](),c[146](),c[46](),c[47](),c[48](),c[51](),c[18](),c[135](),c[63](),c[147](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[58](),c[136]()},source_sha256="28793e820f9884f4e22280610a87ad540d63e8353d1d4fee8838e53972f01fc1"},[73]={map="zm_sat_ztron4",maxparty=4,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[3](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[67](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[63](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[33](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="bedd8b77f3ae040ed05f3e21c5ec22dd86f2b803efd1d87b4afa5b9132321b4d"},[452]={map="zm_sat_ruby",maxparty=1,source_gametype="p_gametype_sat_rb_daisy",asset="zm_rb_daisy",local_record=false,configuration={c[2](),c[42](),c[6](),c[146](),c[46](),c[47](),c[48](),c[49](),c[51](),c[18](),c[135](),c[22](),c[147](),c[52](),c[27](),c[28](),c[54](),c[55](),c[32](),c[58](),c[136]()},source_sha256="0ce1e2ccf55313f551f1c41bedd5471da960c4b8140ac699dfd92c13c31fc787"},[1000000019]={map="zm_sat_mantis",play_menu_ref="sat_zm_mantis",template_id=197,local_record=true,asset="zm_rb_r_mod",source_gametype="p_gametype_sat_rb_r_mod",maxparty=1,command="zm_rb_r_mod",configuration={c[81](),c[82](),c[83](),c[84](),c[22](),c[85](),c[86](),c[87](),c[88](),c[18](),c[89](),c[90](),c[91](),c[92](),c[78](),c[79](),c[142]()},source_sha256="e70d0b9233d5cfd3fa169683b9c2d4243a75a9b5efeaa9eb67ac78c0ca32afcc"},[1000000084]={map="zm_sat_ruby",play_menu_ref="lumen_zm_rogue_card_50be99eafb07791f",local_variant_policy=true,template_id=58,local_record=true,configuration={c[18](),c[22](),c[117](),c[127](),c[119]()},source_sha256="502f251362c7704412dae687bfe94de8702da7e765cb3c22d86526385d487772",maxparty=1,mode_contract_hash="12dd2112a3636d24",rogue_variant="Astra Malorum Hardcore",mode_override=true,original_card_asset="50be99eafb07791f",asset="zm_rb_echo",source_gametype="local_zm_rb_echo"},[111]={map="zm_sat_ztron4",maxparty=1,source_gametype="p_gametype_sat_ztron4",asset="zm_ztron",local_record=false,configuration={c[1](),c[2](),c[66](),c[4](),c[5](),c[6](),c[7](),c[8](),c[9](),c[10](),c[11](),c[12](),c[13](),c[14](),c[15](),c[16](),c[17](),c[18](),c[19](),c[20](),c[21](),c[22](),c[23](),c[24](),c[25](),c[26](),c[27](),c[28](),c[29](),c[30](),c[31](),c[32](),c[68](),c[34](),c[35](),c[36](),c[37](),c[38](),c[39](),c[40](),c[41]()},source_sha256="50fb0477c3de2df8e57cf3593d87fbd3f35edf2c367a471c281722f462dde9a3"}},native_category_queries={{key="0x3fb66cb9a9ee287d",card=false},{key="0x1c4a2d1e3a874211",card=false},{key="0x529dc19b8ca68312",card=false},{key="0x7bd15906e76ecf16",card=false},{key="0x1c6c271e3aa41e45",card=false},{key="0xb3670bba6c58b32b",card=true},{key="0x39b487a789846f47",card=false},{key="0x941517228d21054f",card=false},{key="0x919ee05d6fc32b3e",card=false},{key="0x4222c03529e12ec9",card=false},{key="0x76822d16acd1e4ff",card=false},{key="0xb77db836a85e0d82",card=false},{key="0x0b1392a22642d500",card=false},{key="0xb0fc3a36ae2b54fe",card=false},{key="0x00f8218ca2f27d19",metadata=true},{key="0x01f8c84e462ab74a",list=true}},reset_defaults={{key="0x072e4d6b8f8afa03",console_key="#x372e4d6b8f8afa03",value=0,kind="int",consumer_default=0,required=false},{key="0x08f346cd186641d5",console_key="#x38f346cd186641d5",value=0,kind="int",consumer_default=1,required=false},{key="0x0ee0e5c147b44222",console_key="#x3ee0e5c147b44222",value=1,kind="int",consumer_default=0,required=false},{required=true,consumer_default=0,key="0x1339f37dad46cdfd",console_key="#x31339f37dad46cdfd",value=0,kind="int",semantic_name="enable_scarab_sq",local_normal_content=true},{required=false,consumer_default=0,key="0x1384da7dad994f49",console_key="#x31384da7dad994f49",value=0,kind="int",semantic_name="enable_scarab_br",local_normal_content=true},{required=true,consumer_default=0,key="0x1389eb7dad9f9d83",console_key="#x31389eb7dad9f9d83",value=1,kind="int",semantic_name="enable_scarab_ee",local_normal_content=true},{key="0x27d7e2d0e2e501ea",console_key="#x327d7e2d0e2e501ea",value=1,kind="int",consumer_default=0,required=false},{key="0x27d7efd0e2e51e81",console_key="#x327d7efd0e2e51e81",value=1,kind="int",consumer_default=0,required=false},{key="0x29d6c9bed7b8174e",console_key="#x329d6c9bed7b8174e",value=1,kind="int",consumer_default=1,required=false},{key="0x2adc89ffac1de1a6",console_key="#x32adc89ffac1de1a6",value="future",kind="string",consumer_default="null",required=true},{key="0x3a9ff30b9c2ea1f1",console_key="#x33a9ff30b9c2ea1f1",value=1,kind="int",consumer_default=0,required=false},{required=true,consumer_default=0,key="0x427ebffc772911dd",console_key="#x3427ebffc772911dd",value=0,kind="int",semantic_name="enable_locust_sq",local_normal_content=true},{required=true,consumer_default=0,key="0x42aabbfc77596f77",console_key="#x342aabbfc77596f77",value=1,kind="int",semantic_name="enable_locust_mq",local_normal_content=true},{required=true,consumer_default=0,key="0x42cdb7fc777fae63",console_key="#x342cdb7fc777fae63",value=1,kind="int",semantic_name="enable_locust_ee",local_normal_content=true},{required=false,consumer_default=0,key="0x4564bbcd614eb648",console_key="#x34564bbcd614eb648",value=0,kind="int",semantic_name="enable_rh",local_normal_content=true},{key="0x54d97c81fc15dc50",console_key="#x354d97c81fc15dc50",value=1,kind="int",consumer_default=0,required=false},{key="0x56c1e5374b115ae9",console_key="#x356c1e5374b115ae9",value=1,kind="int",consumer_default=1,required=false},{key="0x58c986d5afe9fa0e",console_key="#x358c986d5afe9fa0e",value="zone_temple",kind="string",consumer_default="null",required=true},{key="0x5f0836c6f2287300",console_key="#x35f0836c6f2287300",value=0,kind="int",consumer_default=1,required=false},{required=false,consumer_default=0,key="0x7ae1c9d5cf785e78",console_key="#x37ae1c9d5cf785e78",value=0,kind="int",semantic_name="skip_zm_rh_validation",local_normal_content=true},{key="0x9b383028dfd6542d",console_key="#x39b383028dfd6542d",value=0,kind="int",consumer_default=0,required=false},{key="0x9c790ecb6ccef79a",console_key="#x39c790ecb6ccef79a",value=150,kind="int",consumer_default=150,required=false},{required=true,consumer_default=0,key="0xa7e7c6427056574b",console_key="#x3a7e7c6427056574b",value=0,kind="int",semantic_name="enable_hornet_sq",local_normal_content=true},{required=true,consumer_default=0,key="0xa825ba42709ae0a9",console_key="#x3a825ba42709ae0a9",value=1,kind="int",semantic_name="enable_hornet_mq",local_normal_content=true},{required=true,consumer_default=0,key="0xa848de4270c1778d",console_key="#x3a848de4270c1778d",value=1,kind="int",semantic_name="enable_hornet_ee",local_normal_content=true},{key="0xab460fa6a1b88d4a",console_key="#x3ab460fa6a1b88d4a",value="castle",kind="string",consumer_default="null",required=true},{required=true,consumer_default=0,key="0xbb4d4e9d5661c0f9",console_key="#x3bb4d4e9d5661c0f9",value=1,kind="int",semantic_name="enable_mantis_ee",local_normal_content=true},{required=true,consumer_default=0,key="0xbb70729d568857dd",console_key="#x3bb70729d568857dd",value=1,kind="int",semantic_name="enable_mantis_mq",local_normal_content=true},{required=true,consumer_default=0,key="0xbb9c6e9d56b8b577",console_key="#x3bb9c6e9d56b8b577",value=0,kind="int",semantic_name="enable_mantis_sq",local_normal_content=true},{required=false,consumer_default=0,key="0xc5a3ce6529ef6314",console_key="#x3c5a3ce6529ef6314",value=1,kind="int",semantic_name="enable_zm_powerups_ee",local_normal_content=true},{key="0xdddf7dca1a52e591",console_key="#x3dddf7dca1a52e591",value="ashwood",kind="string",consumer_default="null",required=true},{key="0xdfe5227c40e9c4e0",console_key="#x3dfe5227c40e9c4e0",value=1,kind="int",consumer_default=0,required=false},{key="0xe0113e7c411a68da",console_key="#x3e0113e7c411a68da",value=0,kind="int",consumer_default=0,required=false},{key="0xe0341a7c41406166",console_key="#x3e0341a7c41406166",value=1,kind="int",consumer_default=0,required=false},{key="0xf7c13201f7e94b73",console_key="#x3f7c13201f7e94b73",kind="int",consumer_default=0,value=1},{key="0xfad294eacb78070c",console_key="#x3fad294eacb78070c",value=0,kind="int",consumer_default=1,required=false},{key="0xfc0433fd5e334486",console_key="#x3fc0433fd5e334486",value=0,kind="int",consumer_default=1,required=false},{key="0xfcdbf400811969f0",console_key="#x3fcdbf400811969f0",value="zone_lighthouse",kind="string",consumer_default="null",required=true},{key="0xd0fb5140c8aff08e",console_key="#x3d0fb5140c8aff08e",kind="int",consumer_default=0,value=0},{required=false,console_key="#x3355264c46b268345",policy="Rogue-only availability of original Curse Inducer; original map producer, world structs, vote and relic consumers remain authoritative.",consumer_default=0,key="0x355264c46b268345",value=0,kind="int",constructed_local_policy=true,local_normal_content=true},{value=1,required=false,local_variant_policy=true,console_key="#x32216f1745cf4ca17",kind="int",consumer_default=1,key="0x2216f1745cf4ca17"},{value=0,required=false,local_variant_policy=true,console_key="#x36b4b2a2350b69461",kind="int",consumer_default=0,key="0x6b4b2a2350b69461"},{value=0,key="0x12202845e7a09a61",kind="int",console_key="#x312202845e7a09a61",default_evidence="Original Dead Ops reader fallback; reset a persistent inapplicable selector.",consumer_default=0,required=false},{value=0,key="0xd3d5686da05c3c43",kind="int",console_key="#x3d3d5686da05c3c43",default_evidence="Original Dead Ops reader fallback; reset a persistent inapplicable selector.",consumer_default=0,required=false},{value=0,key="0x5f1035b22c47683c",kind="int",console_key="#x35f1035b22c47683c",default_evidence="Original Dead Ops reader fallback; reset a persistent inapplicable selector.",consumer_default=0,required=false},{value=0,key="0x6a7f8c09d1c4c848",kind="int",console_key="#x36a7f8c09d1c4c848",default_evidence="Original Dead Ops reader fallback; reset a persistent inapplicable selector.",consumer_default=0,required=false},{value=1,key="0x311ace67d8fa9823",kind="int",console_key="#x3311ace67d8fa9823",default_evidence="Original Dead Ops reader fallback; reset a persistent inapplicable selector.",consumer_default=1,required=false},{value=1,key="0xc0e1c1320b98600e",kind="int",console_key="#x3c0e1c1320b98600e",default_evidence="Original Dead Ops reader fallback; reset a persistent inapplicable selector.",consumer_default=1,required=false},{value=0,key="0x139e934315e6cf5e",kind="float",console_key="#x3139e934315e6cf5e",default_evidence="Original Survival radius read fallback; do not retain Farm radius for another selection.",consumer_default=0,required=false},{default_evidence="Original generic passive-spawn reader fallback outside original DOA preset.",key="0xdca6c5032ce96fa0",required=false,console_key="#x3dca6c5032ce96fa0",kind="int",consumer_default=0,value=0}},root_get="0x3ee6f69fea944b13",int_reader="0x622eaab59aa27e9b",availability_queries={"0x1c4a2d1e3a874211","0x39b487a789846f47","0x4222c03529e12ec9"},root_uri="0xaf63a34c86018bb1",quest_observers={{prototype=1,owner="ZMQUEST",key="0x3413866e33092d9b"},{prototype=24,owner="ZMQUEST",key="0xadaadf7a440913c3"},{prototype=25,owner="ZMQUEST",key="0x5c3beeada0f76828"}},card_aliases={{reference="lumen_zm_rogue_card_294a6f26226a80d8",lookup_hash="0x2cf8e19004a7b14b",asset_hash="0x294a6f26226a80d8",original_name_recovered=false},{reference="lumen_zm_rogue_card_09f6261fd8a91a5e",lookup_hash="0x6ad178328eeac54e",asset_hash="0x09f6261fd8a91a5e",original_name_recovered=false},{reference="lumen_zm_rogue_card_209eb6266574682b",lookup_hash="0x7d8c73011512b164",asset_hash="0x209eb6266574682b",original_name_recovered=false},{reference="lumen_zm_rogue_card_474c0333fc6ce76f",lookup_hash="0x45d4f112f4803f7f",asset_hash="0x474c0333fc6ce76f",original_name_recovered=false},{reference="lumen_zm_rogue_card_5e4dcf2688b0e8a5",lookup_hash="0x0f844cba283bd4ae",asset_hash="0x5e4dcf2688b0e8a5",original_name_recovered=false},{reference="lumen_zm_rogue_card_45f7e2545aa1b65b",lookup_hash="0x24da9caa5742399d",asset_hash="0x45f7e2545aa1b65b",original_name_recovered=false},{reference="lumen_zm_rogue_card_6d30db53dfc85895",lookup_hash="0x145aee9d4d011a5d",asset_hash="0x6d30db53dfc85895",original_name_recovered=false},{reference="lumen_zm_rogue_card_50be99eafb07791f",lookup_hash="0x310c6c84bb3a3bfa",asset_hash="0x50be99eafb07791f",original_name_recovered=false},{reference="lumen_zm_rogue_card_175e7e687baf35ff",lookup_hash="0x53c925ae7f6aad9e",asset_hash="0x175e7e687baf35ff",original_name_recovered=false},{reference="lumen_zm_rogue_card_14721d593df86cf3",lookup_hash="0x01d0a959a4071a06",asset_hash="0x14721d593df86cf3",original_name_recovered=false},{reference="lumen_zm_rogue_card_345872dd354a7fe3",lookup_hash="0x7fb718ceb1264035",asset_hash="0x345872dd354a7fe3",original_name_recovered=false},{reference="lumen_zm_rogue_card_68d2d4ee6946f777",lookup_hash="0x5ed258da5c825d8c",asset_hash="0x68d2d4ee6946f777",original_name_recovered=false}}} end)()
-- Blackwater Lake is a new local Survival selection. Existing records are not edited.
-- 0.2.109: it is also a Cursed Survival selection, cloned from the local Ashwood
-- Cursed Survival records (same map, mode and controls; only the POI changes).
do
    local function clone(value)
        if type(value) ~= "table" then return value end
        local result = {}
        for key, item in pairs(value) do result[key] = clone(item) end
        return result
    end
    for _, spec in ipairs({
        {id=1000000200, source=1000000008, template=59, party=1, category="sat_zm_category_survival"},
        {id=1000000201, source=1000000009, template=54, party=4, category="sat_zm_category_survival"},
        {id=1000000202, source=1000000068, template=197, party=1, category="sat_zm_category_r_mod_survival"},
        {id=1000000203, source=1000000069, template=172, party=4, category="sat_zm_category_r_mod_survival"}
    }) do
        assert(data.records[spec.id] == nil, "Blackwater Lake playlist ID is occupied")
        local record = clone(assert(data.records[spec.source]))
        record.poi = "zone_lakefront"
        record.play_menu_ref = "sat_zm_firefly"
        record.blackwater_lake = true
        local found = false
        for _, entry in ipairs(record.configuration) do
            if entry.key == "0xdddf7dca1a52e591" then
                entry.value = "zone_lakefront"
                found = true
            end
        end
        assert(found, "Native Firefly Survival POI control is missing")
        data.records[spec.id] = record
        data.additions[#data.additions+1] = {
            id=spec.id, template_id=spec.template,
            category_ref=spec.category,
            play_menu_ref="sat_zm_firefly", map="zm_sat_firefly",
            poi="zone_lakefront", image_key="0x1a03af08b21e93ad",
            -- 0.2.49: the playlist row's picture (map list card and lobby
            -- panel) is the pyramid PNG Kronos loads from Assets/Images, by its
            -- plain name as the native string slot expects. The launcher reads
            -- image_override first (build.py replacement); image_key stays as
            -- the fallback.
            image_override="blackwater_lake_save",
            title="Blackwater Lake",
            description="Survive at the lake, cabin, and surrounding cliffs.",
            native_validated=false,
            eligibility="Custom arena; native Firefly geometry and Survival systems"
        }
    end
end

-- Blackwater Lake display name. The lake selection reuses Ashes of the Damned's
-- sat_zm_firefly play-menu card, so native screens localize that card's name.
-- Rename it only where it can only mean Blackwater Lake: the standard Survival
-- category (no native Survival entry uses that card; Ashwood has its own), a
-- selected Blackwater playlist, and a match launched from one. In game a match
-- also counts when the Survival POI and map dvars say Blackwater, the same rule
-- the gameplay script uses. Round-based Ashes of the Damned and every other
-- text stay native.
-- 0.2.109: the same holds for the Cursed Survival category (its native Firefly
-- rows use the Farm, Launchpad, Exit 115 and Ashwood cards) and its two
-- Blackwater rows.
-- 0.2.112: the two Mayhem test rows (1000000204/205) count as Blackwater too.
;(function()
    local clua=rawget(_G,"CLUA")
    local engine=rawget(_G,"Engine")
    if type(clua)~="table" or type(clua.PushXHash)~="function" or type(engine)~="table" then return end
    if rawget(_G,"BWL_LAKE_NAMES")~=nil then return end
    local NAME="Blackwater Lake"
    local FALLBACK="ashes of the damned"
    local ids={[1000000200]=true,[1000000201]=true,[1000000202]=true,[1000000203]=true,
        [1000000204]=true,[1000000205]=true}
    local unpack=rawget(_G,"unpack") or table.unpack
    local stats={wrapped={},renamed=0,frontend_renamed=0,game_renamed=0,game_calls=0,game_seen=0,title=nil}
    rawset(_G,"BWL_LAKE_NAMES",stats)
    local function pack(...) return {n=select("#",...),...} end
    local function slot(owner,name)
        if type(owner)~="table" then return end
        local v=rawget(owner,name);if v~=nil then return v,name end
        local key=clua.PushXHash(name);v=rawget(owner,key);if v~=nil then return v,key end
    end
    local function member(owner,name)
        local v=slot(owner,name);if v~=nil then return v end
        if type(owner)~="table" and type(owner)~="userdata" then return end
        local ok;ok,v=pcall(function() return owner[name] end)
        if ok and v~=nil then return v end
        ok,v=pcall(function() return owner[clua.PushXHash(name)] end);if ok then return v end
    end
    local function path(owner,...)
        for i=1,select("#",...) do owner=member(owner,select(i,...));if owner==nil then return end end
        return owner
    end
    local function payload(value)
        local s=string.lower(tostring(value))
        local token=string.match(s,"#x(%x+)")
        if token and #token==17 then return string.sub(token,2) end
        return token or string.match(s,"0x(%x+)") or s
    end
    local survival={}
    for _,name in ipairs({"sat_zm_category_survival","sat_zm_category_r_mod_survival"}) do
        survival[name]=true
        survival[payload(clua.PushXHash(name))]=true
        if type(clua.PushXHashAsset)=="function" then survival[payload(clua.PushXHashAsset(name))]=true end
    end
    local function get(ds,controller)
        local f=member(ds,"GetValue")
        if type(f)~="function" then return end
        local ok,value=pcall(f,ds,controller)
        if ok then return value end
    end
    local front_key
    local function frontend()
        local f
        if front_key~=nil then f=rawget(engine,front_key) end
        if type(f)~="function" then
            f,front_key=slot(engine,"InFrontend")
            if type(f)~="function" then f,front_key=slot(engine,"0x112586a3f4fb490e") end
        end
        if type(f)~="function" then return true end
        local ok,value=pcall(f)
        return not ok or value~=false
    end
    local function start_state()
        local s=rawget(_G,"LUMEN_ZM_LOCAL_START")
        if type(s)=="table" then return s end
    end
    local function request_is_lake()
        local s=start_state();local r=s and s.request
        return type(r)=="table" and type(r.record)=="table" and r.record.blackwater_lake==true
    end
    local function controller()
        local s=start_state()
        return s and s.controller or 0
    end
    local function selected_id(c)
        return get(path(rawget(_G,"_DataSources"),"0xf71428806887f67d","0x1ccae3b6ef72f533","0xe14ec899fcdc838f"),c)
    end
    local function selected_reference(c)
        return get(path(rawget(_G,"_DataSources"),"0x08f73707b5922e00","0xf71428806887f67d","0xe31bc6e346e6be47","0x27bcf3f1bd325909"),c)
    end
    local dvars=rawget(_G,"Dvar")
    local function dvar_string(name)
        if type(clua.PushXHashDvar)~="function" then return end
        local key=clua.PushXHashDvar(name)
        local exists=slot(dvars,"0xe1fab6d9a30481f8")
        if type(exists)=="function" then
            local ok,present=pcall(exists,key)
            if ok and present~=true then return end
        end
        local get=slot(dvars,"0x254084d7ca2317bb")
        if type(get)~="function" then return end
        local ok,value=pcall(get,key)
        if ok and type(value)=="string" then return value end
    end
    -- The gameplay script's own rule (bwl_selected): Survival POI dvar and map.
    local function poi_lake()
        return dvar_string("0xdddf7dca1a52e591")=="zone_lakefront" and
            (dvar_string("ui_mapname")=="zm_sat_firefly" or dvar_string("mapname")=="zm_sat_firefly")
    end
    -- A Blackwater launch is latched when the game leaves the frontend, because
    -- the launcher may cancel its request during loading or in-game navigation.
    local was_frontend,launch_lake,game_lake=true,false,false
    local function update()
        local fe=frontend()
        if fe then
            if not was_frontend then game_lake=false end
            local s=start_state();local r=s and s.request
            if request_is_lake() then launch_lake=true
            elseif type(r)=="table" then launch_lake=false
            else
                local id=selected_id(controller())
                if ids[id] then launch_lake=true elseif id~=nil then launch_lake=false end
            end
        else
            if was_frontend then game_lake=launch_lake or request_is_lake() end
            if not game_lake and request_is_lake() then game_lake=true end
        end
        was_frontend=fe
        return fe
    end
    local original_localize
    local title_tries,in_titles=0,false
    local function titles()
        if stats.title==nil and not in_titles and title_tries<20 and type(original_localize)=="function" then
            title_tries=title_tries+1;in_titles=true
            local ok,value=pcall(function()
                local card_get=slot(rawget(_G,"PLAY_MENU"),"0x15b97d8cf426b333")
                if type(card_get)~="function" then return end
                local card=card_get("sat_zm_firefly")
                local label=member(card,"name")
                if label==nil then return end
                return original_localize(label)
            end)
            in_titles=false
            if ok and type(value)=="string" and value~="" then stats.title=string.lower(value) end
        end
        return stats.title or FALLBACK
    end
    -- 0.2.40: a 3rd launcher match in one session ran out of Lua memory while
    -- building menus. Look for the needle case-insensitively without a
    -- lowercased copy of every localized string; copy only on a match.
    local pattern_needle,pattern
    local function find_needle(text,needle)
        if needle~=pattern_needle then
            local parts={}
            for i=1,#needle do
                local ch=string.sub(needle,i,i)
                if string.find(ch,"%a") then parts[i]="["..string.lower(ch)..string.upper(ch).."]"
                elseif string.find(ch,"%w") then parts[i]=ch
                else parts[i]="%"..ch end
            end
            pattern_needle,pattern=needle,table.concat(parts)
        end
        return string.find(text,pattern)~=nil
    end
    local fallback_pattern
    local function find_fallback(text)
        if fallback_pattern==nil then
            local parts={}
            for i=1,#FALLBACK do
                local ch=string.sub(FALLBACK,i,i)
                parts[i]=string.find(ch,"%a") and ("["..ch..string.upper(ch).."]") or ("%"..ch)
            end
            fallback_pattern=table.concat(parts)
        end
        return string.find(text,fallback_pattern)~=nil
    end
    local function shaped(segment)
        if segment==string.upper(segment) then return string.upper(NAME) end
        if segment==string.lower(segment) then return string.lower(NAME) end
        return NAME
    end
    local function replace(text,lower,needle)
        local out,at,changed={},1,false
        while true do
            local s,e=string.find(lower,needle,at,true)
            if not s then break end
            out[#out+1]=string.sub(text,at,s-1)
            out[#out+1]=shaped(string.sub(text,s,e))
            at=e+1;changed=true
        end
        if not changed then return end
        out[#out+1]=string.sub(text,at)
        return table.concat(out)
    end
    local function adjust(text)
        local fe=update()
        if not fe then stats.game_calls=stats.game_calls+1 end
        if #text<6 then return end
        local needle=titles()
        if not find_needle(text,needle) then
            if needle==FALLBACK or not find_fallback(text) then return end
            needle=FALLBACK
        end
        local lower=string.lower(text)
        local whole=lower==needle
        if not fe then
            -- In game the launcher's request may already be gone. Use the
            -- gameplay script's own rule, the Survival POI dvar and the map.
            stats.game_seen=stats.game_seen+1
            if not (game_lake or poi_lake()) then return end
            stats.game_renamed=stats.game_renamed+1
            local result=replace(text,lower,needle)
            if result then stats.renamed=stats.renamed+1 end
            return result
        end
        local c=controller()
        if ids[selected_id(c)] or request_is_lake() then
            -- A selected or launching Blackwater playlist: any mention is ours.
        else
            local ref=selected_reference(c)
            if not (whole and ref~=nil and survival[payload(ref)]) then return end
        end
        stats.frontend_renamed=stats.frontend_renamed+1
        local result=replace(text,lower,needle)
        if result then stats.renamed=stats.renamed+1 end
        return result
    end
    local function wrap(owner,name)
        local original,key=slot(owner,name)
        if type(original)~="function" then return end
        if stats.wrapped[tostring(key)] then return end
        -- No table per call (0.2.40): the results pass through as varargs.
        local function finish(...)
            local first=...
            if type(first)~="string" then return ... end
            local ok,changed=pcall(adjust,first)
            if ok and type(changed)=="string" then return changed,select(2,...) end
            return ...
        end
        local replacement=function(...)
            return finish(original(...))
        end
        rawset(owner,key,replacement)
        if rawget(owner,key)==replacement then stats.wrapped[tostring(key)]=name end
        return original
    end
    original_localize=wrap(engine,"Localize")
    wrap(engine,"0x07d3158a9539a355")
    for _,name in ipairs({"LocalizeToUpperString","LocalizeIntoString","LocalizeToLowerString"}) do
        wrap(_G,name)
    end
end)()

-- Menu diagnostic (0.2.38, output route fixed in 0.2.39). After any launcher match the Zombies menu comes
-- back without the launcher's added categories (Starting Room, Rogue Run,
-- Cursed Survival) and DOA4 moves tab. Record what the launcher decided when
-- the game returned to the frontend: its request and phase, the private-party
-- recovery, the leftover-lobby checks, catalogue errors and the category model.
-- Output goes only through DebugPrint. Kronos copies a DebugPrint line into
-- cod25\poi_reg.log only when it starts with "k1 " (as the launcher's own
-- "k1 exec:" lines do); the 0.2.38 "bwl menu diag" lines never reached it.
-- Read-only: never runs a command, opens a menu or writes a model; Exec and
-- Localize are passed through unchanged.
-- 0.2.40: the 3rd launcher match of one session hit "not enough memory" while
-- the in-game UI was built. The Localize pass-through allocates nothing now,
-- and a read-only Lua heap reading (collectgarbage "count", never a collection)
-- is logged at install, on leaving and returning to the frontend, and in game
-- after 500/2000/5000/10000/20000/40000 Localize calls.
;(function()
    local clua=rawget(_G,"CLUA")
    local engine=rawget(_G,"Engine")
    if type(clua)~="table" or type(clua.PushXHash)~="function" or type(engine)~="table" then return end
    if rawget(_G,"BWL_MENU_DIAG")~=nil then return end
    local diag={version="0.2.133",count=0,execs=0,returns=0,calls=0,lines={}}
    rawset(_G,"BWL_MENU_DIAG",diag)
    local MAX_LINES,MAX_EXECS,EVERY=150,60,25
    local unpack=rawget(_G,"unpack") or table.unpack
    local function pack(...) return {n=select("#",...),...} end
    local function slot(owner,name)
        if type(owner)~="table" then return end
        local v=rawget(owner,name);if v~=nil then return v,name end
        local key=clua.PushXHash(name);v=rawget(owner,key);if v~=nil then return v,key end
    end
    local function member(owner,name)
        local v=slot(owner,name);if v~=nil then return v end
        if type(owner)~="table" and type(owner)~="userdata" then return end
        local ok;ok,v=pcall(function() return owner[name] end)
        if ok and v~=nil then return v end
        ok,v=pcall(function() return owner[clua.PushXHash(name)] end);if ok then return v end
    end
    local function out(text)
        if diag.count>=MAX_LINES then return end
        diag.count=diag.count+1
        local line="k1 bwl menu diag "..diag.version.." #"..diag.count..": "..string.sub(tostring(text),1,700)
        diag.lines[#diag.lines+1]=line
        if #diag.lines>30 then table.remove(diag.lines,1) end
        local print=rawget(_G,"DebugPrint")
        if type(print)=="function" then pcall(print,line) end
    end
    -- Heap size only; "count" never triggers or steps a collection.
    local function heap()
        local cg=rawget(_G,"collectgarbage")
        if type(cg)=="function" then
            local ok,kb=pcall(cg,"count")
            if ok and type(kb)=="number" then return "mem="..tostring(math.floor(kb)).."KB" end
            return "mem=err"
        end
        local gi=rawget(_G,"gcinfo")
        if type(gi)=="function" then
            local ok,kb=pcall(gi)
            if ok and type(kb)=="number" then return "mem="..tostring(math.floor(kb)).."KB" end
        end
        return "mem=n/a"
    end
    local function mem()
        local ok,text=pcall(heap)
        if ok and type(text)=="string" then return text end
        return "mem=err"
    end
    local MEM_AT={500,2000,5000,10000,20000,40000}
    local function payload(value)
        local s=string.lower(tostring(value))
        local token=string.match(s,"#x(%x+)")
        if token and #token==17 then return string.sub(token,2) end
        return token or string.match(s,"0x(%x+)") or s
    end
    local known={}
    for _,name in ipairs({"sat_zm_category_classic","sat_zm_category_guided","sat_zm_category_survival",
        "sat_zm_category_r_mod","sat_zm_category_r_mod_survival","sat_zm_category_starting_room",
        "sat_zm_category_echo","sat_zm_category_daisy"}) do
        local short=string.sub(name,17)
        known[name]=short;known[payload(clua.PushXHash(name))]=short
        if type(clua.PushXHashAsset)=="function" then known[payload(clua.PushXHashAsset(name))]=short end
    end
    local function ref_name(ref)
        if ref==nil then return "nil" end
        return known[ref] or known[payload(ref)] or payload(ref)
    end
    local function query(owner,name)
        local f=slot(owner,name)
        if type(f)~="function" then return "nofn" end
        local ok,value=pcall(f)
        if not ok then return "err" end
        return tostring(value)
    end
    local lui=rawget(_G,"LUI")
    local lobby=rawget(_G,"Lobby")
    local function read(path)
        local constructor=member(member(lui,"DataSourceInGlobalModel"),"new")
        if type(constructor)~="function" then return nil end
        local ok,ds=pcall(constructor,path)
        if not ok or ds==nil then return nil end
        local get=member(ds,"GetValue")
        if type(get)~="function" then return nil end
        local ok2,value=pcall(get,ds,0)
        if ok2 then return value end
    end
    local function field(t,name)
        if type(t)~="table" then return "-" end
        local v=rawget(t,name)
        if v==nil then return "-" end
        return string.gsub(string.sub(tostring(v),1,60),"[%c|]","_")
    end
    local function launcher()
        local s=rawget(_G,"LUMEN_ZM_LOCAL_START")
        if type(s)~="table" then return "launcher=absent" end
        local r=rawget(s,"request")
        local req=type(r)=="table" and ("id="..field(r,"id").." touched="..field(r,"touched")) or "none"
        local pr=rawget(s,"party_recovery")
        local parts={
            "phase="..field(s,"phase"),"req="..req,"menu="..field(s,"menu"),"ctx="..field(s,"context"),
            "gen="..field(s,"generation"),
            "| pr status="..field(pr,"status"),"reset="..field(pr,"reset_reason"),
            "why="..field(pr,"recovery_reason"),"attempted="..field(pr,"attempted"),
            "party="..field(pr,"private_party_query_value"),"host="..field(pr,"host_before"),
            "after="..field(pr,"native_after"),"cmd="..field(pr,"command_ok"),"err="..field(pr,"error")}
        local c=rawget(s,"catalogue")
        if type(c)=="table" then
            local errors={}
            if type(rawget(c,"last_errors"))=="table" then
                for ref,why in pairs(c.last_errors) do
                    errors[#errors+1]=ref_name(ref).."="..string.gsub(string.sub(tostring(why),1,80),"[%c|]","_")
                end
            end
            table.sort(errors)
            local added={}
            if type(rawget(c,"categories"))=="table" then
                for index in pairs(c.categories) do added[#added+1]=tostring(index) end
            end
            table.sort(added)
            parts[#parts+1]="| cat pubs="..field(c,"publications").." publishing="..field(c,"publishing")..
                " added="..table.concat(added,",").." errors="..(#errors>0 and table.concat(errors,";") or "none")
        else
            parts[#parts+1]="| cat=absent"
        end
        return table.concat(parts," ")
    end
    local function menu_state()
        local parts={"| lobby party="..query(lobby,"0xf63537242f1d48ff"),
            "host="..query(lobby,"0x96957722ef74f5d2"),
            "gamelobby="..query(lobby,"0xbf1d2956b0c99df6"),
            "searching="..query(engine,"0x88ff0f1c5b20321e")}
        local k1=rawget(_G,"KRONOS_RETAIL_K1")
        parts[#parts+1]="resume="..tostring(type(k1)=="table" and rawget(k1,"nativeResume")~=nil)
        local base="frontEnd.playlists.category"
        local count=read(base..".count")
        local rows={}
        if type(count)=="number" and count>=0 and count<=64 then
            for c=0,count-1 do
                rows[#rows+1]=ref_name(read(base..".playMenuRef."..c)).."/"..tostring(read(base..".index."..c))..
                    "/"..tostring(read(base.."."..c..".playlist.count"))
            end
        end
        parts[#parts+1]="| model n="..tostring(count).." ["..table.concat(rows," ").."]"
        return table.concat(parts," ")
    end
    local in_frontend=slot(engine,"InFrontend")
    local was_fe,since,last,busy=nil,0,nil,false
    local game,next_mem=0,1
    local function tick()
        if busy or type(in_frontend)~="function" then return end
        busy=true
        diag.calls=diag.calls+1
        local ok,fe=pcall(in_frontend)
        if ok and fe==false then
            if was_fe~=false then out("left frontend: "..mem().." "..launcher());game=0;next_mem=1 end
            was_fe=false
            game=game+1
            if game==MEM_AT[next_mem] then
                next_mem=next_mem+1
                out("game mem: calls="..game.." "..mem())
            end
        elseif ok and fe==true then
            local label
            if was_fe==false then diag.returns=diag.returns+1;label="returned "..diag.returns..": ";since=0
            elseif was_fe==nil then label="first menu: ";since=0 end
            was_fe=true;since=since+1
            if label or since%EVERY==0 then
                local snapshot=launcher().." "..menu_state()
                if label then out(label..mem().." "..snapshot)
                elseif snapshot~=last then out("menu: "..snapshot) end
                last=snapshot
            end
        end
        busy=false
    end
    -- No table per call (0.2.40): the results pass through as varargs.
    local function after(...)
        pcall(tick)
        busy=false
        return ...
    end
    local localize,localize_key=slot(engine,"Localize")
    if type(localize)=="function" then
        rawset(engine,localize_key,function(...)
            return after(localize(...))
        end)
    end
    local exec,exec_key=slot(engine,"Exec")
    if type(exec)=="function" then
        rawset(engine,exec_key,function(command,...)
            if diag.execs<MAX_EXECS then
                diag.execs=diag.execs+1
                pcall(out,"exec: "..string.sub(tostring(command),1,160))
            end
            return exec(command,...)
        end)
    end
    out("installed; Localize="..tostring(type(localize)=="function").." Exec="..tostring(type(exec)=="function")..
        " InFrontend="..tostring(type(in_frontend)=="function").." "..mem())
end)()

-- Menu cache guard (0.2.42; replaces the 0.2.41 category refresh, which never
-- ran: frontEnd.playlists.updated reads nil when the launcher installs).
-- After a launcher match the Zombies menu comes back without Starting Room,
-- Rogue Run and Cursed Survival, and DOA4 changes tab, for the rest of the
-- session. The Zombies menu rows come from Lobby[0x837a1ca9e92f5696]
-- (controller), which returns a module-level cache when it has one. Only on a
-- miss does it run PLAY_MENU FillPlayMenu, whose row builders read the
-- category list (PlaylistUtils[0xeda10385e76d30fe]) and each category's
-- playlist count live, through the launcher's filter hooks. Natively the cache
-- is cleared only by Lobby[0x7c5c586b9c0d0f8e]() when the online playlist
-- version changes. On the return from a match the rows are evidently built and
-- cached while the launcher is still installing (native rows only, or added
-- categories with no playlists yet), and that copy then serves every visit.
-- The launcher calls BWL_CATEGORY_REFRESH once, right after it has installed.
-- It wraps Lobby[0x837a1ca9e92f5696]: in the frontend, with no launch request
-- and the catalogue not publishing, a call first runs the native cache clear
-- whenever the launcher's catalogue.publications counter differs from the
-- value at the last clear (always on the first such call in a Lua VM), then
-- passes the call through unchanged. Once the counter settles the native cache
-- works as before. Never writes a model itself. At most 12 "k1 " lines per VM
-- (Kronos copies only "k1 " DebugPrint lines into cod25\poi_reg.log).
;(function()
    if rawget(_G,"BWL_CATEGORY_REFRESH")~=nil then return end
    local VERSION="0.2.133"
    local MAX_LINES=12
    local lines,clears,installed,seen,busy=0,0,false,nil,false
    local function say(text)
        if lines>=MAX_LINES then return end
        lines=lines+1
        local line="k1 bwl menu cache "..VERSION.." #"..lines..": "..string.sub(tostring(text),1,400)
        rawset(_G,"BWL_CATEGORY_REFRESH_RESULT",line)
        local print=rawget(_G,"DebugPrint")
        if type(print)=="function" then pcall(print,line) end
    end
    local function slot(owner,name)
        if type(owner)~="table" then return end
        local v=rawget(owner,name);if v~=nil then return v,name end
        local clua=rawget(_G,"CLUA")
        if type(clua)~="table" or type(clua.PushXHash)~="function" then return end
        local ok,key=pcall(clua.PushXHash,name)
        if ok and key~=nil then
            v=rawget(owner,key);if v~=nil then return v,key end
        end
    end
    -- The publication count when a clear is due, otherwise nil.
    local in_frontend
    local function due()
        if type(in_frontend)~="function" then return end
        local ok,fe=pcall(in_frontend)
        if not ok or fe~=true then return end
        local state=rawget(_G,"LUMEN_ZM_LOCAL_START")
        if type(state)~="table" or state.request~=nil then return end
        -- 0.2.43: never while Kronos is loading a saved game. In the 0.2.42
        -- test a clear during the saved-lobby build was followed straight away
        -- by LeavePublicLobby, and that resume was cancelled.
        local k1=rawget(_G,"KRONOS_RETAIL_K1")
        if type(k1)=="table" and rawget(k1,"nativeResume")~=nil then return end
        local c=state.catalogue
        if type(c)~="table" or c.publishing then return end
        local pubs=c.publications
        if type(pubs)~="number" or pubs==seen then return end
        return pubs
    end
    rawset(_G,"BWL_CATEGORY_REFRESH",function()
        if installed then return end
        installed=true
        local ok,why=pcall(function()
            local lobby=rawget(_G,"Lobby")
            local get,get_key=slot(lobby,"0x837a1ca9e92f5696")
            local clear=slot(lobby,"0x7c5c586b9c0d0f8e")
            in_frontend=slot(rawget(_G,"Engine"),"InFrontend")
            if type(get)~="function" or type(clear)~="function" or type(in_frontend)~="function" then
                say("skipped: native functions unavailable rows="..type(get).." clear="..type(clear)..
                    " InFrontend="..type(in_frontend))
                return
            end
            local function guard()
                if busy then return end
                local found,pubs=pcall(due)
                if not found or pubs==nil then return end
                busy=true
                seen=pubs
                local cleared,err=pcall(clear)
                busy=false
                clears=clears+1
                say("cleared native menu cache "..clears.." at pubs="..pubs..
                    (cleared and "" or " err="..string.sub(tostring(err),1,200)))
            end
            rawset(lobby,get_key,function(...)
                guard()
                return get(...)
            end)
            local state=rawget(_G,"LUMEN_ZM_LOCAL_START")
            local c=type(state)=="table" and state.catalogue or nil
            say("installed: guard on Lobby 0x837a1ca9e92f5696 pubs="..
                tostring(type(c)=="table" and c.publications or nil))
        end)
        if not ok then say("failed: "..tostring(why)) end
    end)
end)()

-- Blackwater saved games (0.2.43; marker fixed in 0.2.44, kept in 0.2.45;
-- custom save image in 0.2.46; right picture and row tile split in 0.2.47).
-- Kronos keeps one saved game per map and mode. Blackwater Lake is Ashes of the
-- Damned (zm_sat_firefly) Survival with the Survival POI dvar set to
-- zone_lakefront, so its save shares the native Ashes Survival slot. Nothing in
-- the save records the POI: the save list names it "Ashes of the Damned -
-- Survival", the launcher matches it to the native playlist, and loading it
-- keeps whatever POI the last launch left (zone_exit115 after an Exit 115 match).
-- This block never edits Kronos files. It wraps Kronos's own functions through
-- the KRONOS_RETAIL_K1 table:
--   in game:   dispatchSave. When Kronos accepts Save & Quit on zm_sat_firefly,
--              the marker dvar #x36e2b94f1a7c35d08 becomes zone_lakefront for a
--              Blackwater match (the gameplay script's rule: POI dvar and map)
--              or "other" for any other Ashes match;
--   frontend:  the launcher's resolveSavedGame maps a marked Ashes Survival save
--              to the Blackwater playlist; savedEntries names that row
--              "Blackwater Lake - Survival"; resumeEntry sets zone_lakefront
--              before Kronos builds the saved lobby, and tickNativeResume keeps
--              it set until the saved match starts.
-- The marker is a plain dvar: it lasts for the game session, not across a
-- restart. Without it every save behaves exactly as before.
-- 0.2.44: in 0.2.43 the marker was "set bwl_save_poi ..." through Engine.Exec and
-- never read back (log: "marked nil"). Every dvar command that works in the
-- logs goes through Kronos's Engine[0xeb81a5136c5503e4] (ExecNow, echoed by the
-- DLL as "k1 exec: ...") with a "#x3<16 hex>" name, read back with
-- PushXHashDvar("0x<16 hex>"), as the launcher's own H3 HUD gate does. The
-- marker and the POI commands now use that path and that name form.
-- 0.2.45: in the 0.2.44 test the next menu read the marker at install, then it
-- was cleared during the menu's return-from-match setup (lobby reset,
-- "exec default_online_mp.cfg", ...) before Continue Saved Game ran. This VM
-- now keeps the value it read; when the dvar is gone it uses that copy and
-- writes the dvar again (at most MAX_RESTORES times per VM).
-- 0.2.50: the lobby's "MATCH IS ABOUT TO BEGIN..." panel shows the pyramid for
-- a Blackwater lobby (see panel_wrap below).
-- 0.2.109: the panel also knows the two Cursed Survival rows. Cursed saves stay
-- native: Kronos's Cursed save helper is not armed for the Blackwater rows.
-- 0.2.112: the panel also knows the two Mayhem test rows (1000000204/205).
-- Logs "k1 bwl save 0.2.133 #n: ..." (at most 12 per VM).
;(function()
    if rawget(_G,"BWL_SAVE_OWNER")~=nil then return end
    local VERSION="0.2.133"
    local MAX_RESTORES=3
    local MAX_LINES=12
    -- Every Exec is copied into poi_reg.log by Kronos; bound the re-sets.
    local MAX_REASSERTS=20
    local MAP="zm_sat_firefly"
    local POI="zone_lakefront"
    local POI_DVAR="0xdddf7dca1a52e591"
    local POI_SET='set #x3dddf7dca1a52e591 "zone_lakefront"'
    -- A hash of our own (not in Kronos's Lua or the logs), written the
    -- launcher's way: set with "#x3"..hex, read with "0x"..hex.
    local MARKER="0x6e2b94f1a7c35d08"
    local MARKER_SET="set #x36e2b94f1a7c35d08 "
    -- Right-hand picture (pyramid) and row tile (main cabin), by PNG file stem.
    local IMAGE="blackwater_lake_save"
    local TILE="blackwater_lake_save_tile"
    local IDS={1000000201,1000000200}
    local LOBBY_IDS={[1000000200]=true,[1000000201]=true,[1000000202]=true,[1000000203]=true,
        [1000000204]=true,[1000000205]=true}
    local SURVIVAL={sat_zm_rb_survival=true,zm_rb_survival=true}
    local lines=0
    local stats={installed=false,frontend=false,game=false,wrapped={},marked=nil,resumes=0,reasserts=0,cached=nil,restores=0}
    local function say(text)
        if lines>=MAX_LINES then return end
        lines=lines+1
        local line="k1 bwl save "..VERSION.." #"..lines..": "..string.sub(tostring(text),1,400)
        rawset(_G,"BWL_SAVE_OWNER_RESULT",line)
        local print=rawget(_G,"DebugPrint")
        if type(print)=="function" then pcall(print,line) end
    end
    local function slot(owner,name)
        if type(owner)~="table" then return end
        local v=rawget(owner,name);if v~=nil then return v,name end
        local clua=rawget(_G,"CLUA")
        if type(clua)~="table" or type(clua.PushXHash)~="function" then return end
        local ok,key=pcall(clua.PushXHash,name)
        if ok and key~=nil then
            v=rawget(owner,key);if v~=nil then return v,key end
        end
    end
    -- Always returns exactly one value (nil when unreadable), so it is safe
    -- inside tostring().
    local function dvar(name)
        local clua=rawget(_G,"CLUA")
        if type(clua)~="table" or type(clua.PushXHashDvar)~="function" then return nil end
        local dvars=rawget(_G,"Dvar")
        local ok,key=pcall(clua.PushXHashDvar,name)
        if not ok or key==nil then return nil end
        local exists=slot(dvars,"0xe1fab6d9a30481f8")
        if type(exists)=="function" then
            local found,present=pcall(exists,key)
            if found and present~=true then return nil end
        end
        local get=slot(dvars,"0x254084d7ca2317bb")
        if type(get)~="function" then return nil end
        local read,value=pcall(get,key)
        if read and type(value)=="string" then return value end
        return nil
    end
    -- Kronos's own command function first (ExecNow, as Kronos and the launcher
    -- call it), then the name, then Engine.Exec as a last resort.
    local function exec(command,controller)
        local engine=rawget(_G,"Engine")
        local f=slot(engine,"0xeb81a5136c5503e4")
        if type(f)~="function" then f=slot(engine,"ExecNow") end
        if type(f)~="function" then f=slot(engine,"Exec") end
        if type(f)~="function" then return false end
        local ok=pcall(f,command,type(controller)=="number" and controller or 0)
        return ok
    end
    -- The marker as this VM knows it: the dvar when it is readable (that value
    -- is kept), else the kept copy, which is written back to the dvar.
    local function owner()
        local value=dvar(MARKER)
        if value~=nil then stats.cached=value;return value end
        local kept=stats.cached
        if kept==nil then return nil end
        if stats.restores<MAX_RESTORES then
            stats.restores=stats.restores+1
            exec(MARKER_SET..'"'..kept..'"')
            say("marker cleared since install; restored "..kept.." from this VM's copy, reads "..
                tostring(dvar(MARKER)).." (restore "..stats.restores.." of "..MAX_RESTORES..")")
        end
        return kept
    end
    -- What the marker name hashes to here; in game it should print
    -- #x36e2b94f1a7c35d08 (the launcher's H3 gate checks its keys the same way).
    local function marker_key()
        local clua=rawget(_G,"CLUA")
        if type(clua)~="table" or type(clua.PushXHashDvar)~="function" then return "none" end
        local ok,key=pcall(clua.PushXHashDvar,MARKER)
        if not ok or key==nil then return "none" end
        return string.lower(tostring(key))
    end
    local function lake_poi() return dvar(POI_DVAR)==POI end
    local function on_map()
        return dvar("ui_mapname")==MAP or dvar("mapname")==MAP
    end
    -- Sets the Blackwater POI the same ways Kronos and the launcher do.
    local function set_poi(controller)
        exec("set playlist_reset_dvars_on_switch 0",controller)
        exec(POI_SET,controller)
        exec("set scr_"..MAP.."_survival_poi "..POI,controller)
        return lake_poi()
    end
    local function wrap(owner_table,name,make)
        local original=rawget(owner_table,name)
        if type(original)~="function" or stats.wrapped[name]==original then return false end
        local replacement=make(original)
        rawset(owner_table,name,replacement)
        stats.wrapped[name]=replacement
        return true
    end
    local function install_game(k)
        if stats.game then return end
        stats.game=wrap(k,"dispatchSave",function(original)
            return function(...)
                local result=original(...)
                if result==true then
                    local ok,why=pcall(function()
                        if not on_map() then return "not "..MAP end
                        local value=lake_poi() and POI or "other"
                        exec(MARKER_SET..'"'..value..'"')
                        stats.marked=dvar(MARKER)
                        -- Never keep an older copy past a new save.
                        stats.cached=stats.marked
                        return "marked "..tostring(stats.marked).." (wanted "..value..")"
                    end)
                    say("save accepted: "..tostring(why))
                end
                return result
            end
        end)
    end
    local function resolve_wrap(state)
        local original=state.resolveSavedGame
        if type(original)~="function" or stats.wrapped.resolveSavedGame==original then return end
        local replacement=function(map,gametype,...)
            local record=original(map,gametype,...)
            if type(record)~="table" or map~=MAP or not SURVIVAL[record.asset] or owner()~=POI then return record end
            local c=state.catalogue
            local by_id=type(c)=="table" and c.by_id or nil
            for _,id in ipairs(IDS) do
                if type(by_id)~="table" or by_id[id] then
                    record.id=id;record.blackwater_lake=true
                    break
                end
            end
            return record
        end
        state.resolveSavedGame=replacement
        stats.wrapped.resolveSavedGame=replacement
    end
    -- 0.2.46/0.2.47: the save screen images. Kronos's display() sets two of
    -- them from the play menu page after savedEntries returns:
    --   entry.icon        the row tile under "Save File" (0.2.46 test: our
    --                     image showed there);
    --   entry.background  the large picture on the right (the native
    --                     ZMSaveSelectionMenu subscribes element #96da7fff580d4746
    --                     to detail field #44d35ec7c8da72bf, which Kronos fills
    --                     from entry.background).
    -- A Blackwater row keeps both keys out of its own fields and answers them
    -- from a metatable: each native value is dropped (logged once per slot),
    -- our image is read instead. Each image is a PNG Kronos loads from
    -- Assets/Images, named by its file stem.
    local SLOTS={{"icon",TILE},{"background",IMAGE}}
    local function image(stem)
        stats.images=stats.images or {}
        if stats.images[stem]==nil then
            local clua=rawget(_G,"CLUA")
            local ok,value=false,nil
            if type(clua)=="table" and type(clua.PushXHashAsset)=="function" then ok,value=pcall(clua.PushXHashAsset,stem) end
            stats.images[stem]=(ok and value~=nil) and value or false
            if stats.images[stem]==false then say("save image: no asset hash for "..stem.."; native image kept") end
        end
        return stats.images[stem] or nil
    end
    local function keep_image(row)
        if getmetatable(row)~=nil then return end
        local custom,stems,any={},{},false
        for _,spec in ipairs(SLOTS) do
            local value=image(spec[2])
            if value~=nil then custom[spec[1]]=value;stems[spec[1]]=spec[2];any=true end
        end
        if not any then return end
        for key in pairs(custom) do rawset(row,key,nil) end
        stats.image_logged=stats.image_logged or {}
        setmetatable(row,{
            __index=function(_,key) return custom[key] end,
            __newindex=function(t,key,value)
                if custom[key]~=nil then
                    if not stats.image_logged[key] then
                        stats.image_logged[key]=true
                        say("save image: "..key.."="..stems[key].." ("..tostring(custom[key])..", "..type(custom[key])..
                            ") kept over native "..tostring(value).." ("..type(value)..")")
                    end
                    return
                end
                rawset(t,key,value)
            end})
    end
    -- 0.2.50: the lobby panel ("MATCH IS ABOUT TO BEGIN... BLACKWATER LAKE").
    -- The native LobbyMap widget (6eb3d9f6c3e4c9ea, proto 3) looks up
    -- Lobby[#d09afe8ce7a0ee8a] on every update, takes (title, image, extra) from
    -- it and calls RegisterMaterial(image). That image comes from the shared
    -- Ashes play-menu card or the map table, never from the playlist row, so
    -- 0.2.49's row.image could not reach it. For a Blackwater lobby only, the
    -- second result becomes the pyramid; every other lobby gets the native
    -- results unchanged, with all of its arguments and return values.
    local LOBBY_PANEL="0xd09afe8ce7a0ee8a"
    -- The party playlist getter. The launcher hooks it to return 1000000200/201
    -- only while its own selection is Blackwater and the party holds its template.
    local PARTY_PLAYLIST="0x4b92da1948edb47d"
    local unpack=rawget(_G,"unpack") or table.unpack
    local function pack(...) return {n=select("#",...),...} end
    -- Why this lobby is Blackwater, or nil. A launcher request decides on its
    -- own; then a saved Blackwater resume (resumeEntry above marks it); then the
    -- party playlist.
    local function lake_lobby()
        local state=rawget(_G,"LUMEN_ZM_LOCAL_START")
        local request=type(state)=="table" and state.request or nil
        if type(request)=="table" then
            if type(request.record)=="table" and request.record.blackwater_lake==true then return "request" end
            return nil
        end
        local k=rawget(_G,"KRONOS_RETAIL_K1")
        local resume=type(k)=="table" and rawget(k,"nativeResume") or nil
        if type(resume)=="table" and resume.bwl_lake==true then return "resume" end
        local lobby=rawget(_G,"Lobby")
        local get=slot(lobby,PARTY_PLAYLIST)
        local field=slot(slot(lobby,"PartyUIData"),"PLAYLIST_ID")
        if type(get)~="function" or field==nil then return nil end
        local ok,id=pcall(get,field)
        if ok and LOBBY_IDS[id] then return "playlist "..tostring(id) end
        return nil
    end
    local function panel_wrap()
        local lobby=rawget(_G,"Lobby")
        local original,key=slot(lobby,LOBBY_PANEL)
        if type(original)~="function" then return false end
        if stats.wrapped.lobby_panel==original then return true end
        local replacement=function(...)
            local result=pack(original(...))
            if result.n>=2 then
                local ok,why=pcall(function()
                    local lake=lake_lobby()
                    if not lake then return end
                    local value=image(IMAGE)
                    if value==nil then return end
                    if not stats.panel_logged then
                        stats.panel_logged=true
                        say("lobby panel: image="..IMAGE.." ("..tostring(value)..", "..type(value)..") over native "..
                            tostring(result[2]).." ("..type(result[2])..") for "..lake)
                    end
                    result[2]=value
                end)
                if not ok and not stats.panel_error then
                    stats.panel_error=true
                    say("lobby panel: native image kept, error "..tostring(why))
                end
            end
            return unpack(result,1,result.n)
        end
        rawset(lobby,key,replacement)
        stats.wrapped.lobby_panel=replacement
        return true
    end
    local function install_frontend(k,state)
        resolve_wrap(state)
        local any=false
        any=wrap(k,"savedEntries",function(original)
            return function(...)
                local rows=original(...)
                if type(rows)=="table" then
                    for _,row in ipairs(rows) do
                        if type(row)=="table" and type(row.record)=="table" and row.record.blackwater_lake then
                            row.label="Blackwater Lake - "..tostring(row.record.label or "Survival")
                            keep_image(row)
                        end
                    end
                end
                return rows
            end
        end) or any
        any=wrap(k,"resumeEntry",function(original)
            return function(entry,controller,...)
                local lake=type(entry)=="table" and entry.map==MAP and SURVIVAL[entry.gt]==true and owner()==POI
                if lake then
                    stats.resumes=stats.resumes+1
                    say("resume "..stats.resumes..": Blackwater save, poi before="..tostring(dvar(POI_DVAR))..
                        " set="..tostring(set_poi(controller)))
                end
                local result=original(entry,controller,...)
                if lake then
                    local request=rawget(k,"nativeResume")
                    if type(request)=="table" then request.bwl_lake=true end
                    say("resume "..stats.resumes..": started="..tostring(result).." request="..
                        tostring(type(request)=="table").." poi="..tostring(dvar(POI_DVAR)))
                end
                return result
            end
        end) or any
        any=wrap(k,"tickNativeResume",function(original)
            return function(request,...)
                if type(request)=="table" and request.bwl_lake and not request.bwl_launched then
                    if stats.reasserts<MAX_REASSERTS and dvar(POI_DVAR)~=POI then
                        stats.reasserts=stats.reasserts+1
                        local ok=set_poi(request.controller)
                        if stats.reasserts<=3 then say("resume: poi reset by the lobby, set again ok="..tostring(ok)) end
                    end
                    local before=request.submitted
                    local result=original(request,...)
                    if request.submitted and not before then
                        request.bwl_launched=true
                        say("resume: saved launch submitted poi="..tostring(dvar(POI_DVAR))..
                            " resets="..stats.reasserts)
                    end
                    return result
                end
                return original(request,...)
            end
        end) or any
        if any then stats.frontend=true end
    end
    rawset(_G,"BWL_SAVE_OWNER_STATS",stats)
    rawset(_G,"BWL_SAVE_OWNER",function()
        local ok,why=pcall(function()
            local panel_ok,panel=pcall(panel_wrap)
            stats.panel=panel_ok and panel==true
            local k=rawget(_G,"KRONOS_RETAIL_K1")
            local state=rawget(_G,"LUMEN_ZM_LOCAL_START")
            if type(k)~="table" then
                if not stats.installed then say("skipped: KRONOS_RETAIL_K1 unavailable") end
                stats.installed=true
                return
            end
            stats.installed=true
            -- Both sets, in every VM: InFrontend can still read true while the
            -- game VM loads, and each wrapper only acts where it applies
            -- (dispatchSave runs only in game, the save list only in the frontend).
            install_game(k)
            if type(state)=="table" then install_frontend(k,state) end
            -- Read (and keep) the marker now: in the 0.2.44 log this read
            -- comes before the menu's setup clears the dvar.
            local seen=owner()
            if not stats.logged then
                stats.logged=true
                local w=stats.wrapped
                say("installed: dispatchSave="..tostring(w.dispatchSave~=nil).." resolve="..tostring(w.resolveSavedGame~=nil)..
                    " savedEntries="..tostring(w.savedEntries~=nil).." resumeEntry="..tostring(w.resumeEntry~=nil)..
                    " tick="..tostring(w.tickNativeResume~=nil).." panel="..tostring(stats.panel)..
                    " marker="..tostring(seen).." key="..marker_key())
            end
        end)
        if not ok then say("failed: "..tostring(why)) end
    end)
end)()

local function hash(s) return CLUA.PushXHash(s) end
local function asset_hash(s) return CLUA.PushXHashAsset(s) end
local function dvar_hash(s) return CLUA.PushXHashDvar(s) end
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
local function is(v,name) return v==name or v==hash(data.menus[name] or name) end
local engine,lobby,playlist=rawget(_G,"Engine"),rawget(_G,"Lobby"),rawget(_G,"Playlist")
local lui=rawget(_G,"LUI")
local flow=slot(lui,"FlowManager")
local builder=rawget(_G,"MenuBuilder") or slot(lui,"MenuBuilder")
local exec,frontend=slot(engine,"ExecNow"),slot(engine,"InFrontend")
local save_transport=rawget(_G,"KRONOS_SAVE_TRANSPORT")
local save_connected=false
local function connect_save_transport()
    if data.save_catalogue_compatible==false then
        return false
    end
    if save_connected then return true end
    if type(save_transport)~="function" or type(frontend)~="function" or frontend()~=true then return false end
    local ok,value=pcall(save_transport,"activate")
    save_connected=ok and value==true
    return save_connected
end
connect_save_transport()
local root_get=slot(engine,data.root_get)
local read_type=slot(rawget(_G,"Game"),data.get_type)
local set_type=slot(rawget(_G,"GameType"),"0xc0631ab43ba10119")
local leave=slot(lobby,"0xeb13ed1e0091356f")
local popup=slot(flow,"RequestErrorPopup")
local queue_uri=slot(rawget(_G,"MenuNavigator"),"QueueURIXHash")
local state={version="6.4-gameplay-development",request=nil,generation=0,lease=0,
    host=nil,context=false,menu="other",scope=nil,phase="idle",elapsed=0}
local changes={}
local refresh_profile_initializers=function()end
local refresh_mrp_filter=function()end
local refresh_party_recovery=function()end
local refresh_squad_catalogue=function()end
local function hook(owner,name,make)
    local original,key=slot(owner,name)
    if type(original)~="function" then error("missing original hook: "..name) end
    local replacement=make(original)
    changes[#changes+1]={owner=owner,key=key,original=original}
    rawset(owner,key,replacement)
    if rawget(owner,key)~=replacement then error("original table rejected hook: "..name) end
end
for _,v in ipairs({{engine,"ExecNow"},{engine,"InFrontend"},{playlist,"DoPlaylistId"},
    {builder,"BuildRegisteredType"},{flow,"RequestAddMenu"},{lobby,"0xeb13ed1e0091356f"},
    {rawget(_G,"ZM"),"0x4e33201f7d71283a"},{lobby,"0x315b13c5fed7234e"},{lobby,"0x922bb4eaa6147f67"}}) do
    if type((slot(v[1],v[2])))~="function" then return end
end
local card_aliases_ready=not data.card_aliases or #data.card_aliases==0
if data.card_aliases and #data.card_aliases>0 then
    if type((slot(engine,"0xf06093d047200548")))=="function" then
        local aliases={}
        for _,entry in ipairs(data.card_aliases) do
            local key=asset_hash(entry.lookup_hash)
            if aliases[key]~=nil then error("duplicate local card alias") end
            aliases[key]=asset_hash(entry.asset_hash)
        end
        hook(engine,"0xf06093d047200548",function(original)
            return function(reference,...)
                return original(aliases[reference] or reference,...)
            end
        end)
        card_aliases_ready=true
    end
end
local hidden_ids={[448]=true,[449]=true,[450]=true,[451]=true,[452]=true,[499]=true}
local hidden_category_ref="sat_zm_category_daisy"
local function hidden_menu_row(row)
    if type(row)~="table" then return false end
    local ref=member(row,"playlistRef")
    if ref==hidden_category_ref or ref==asset_hash(hidden_category_ref) then return true end
    return hidden_ids[member(row,"playlistID")]==true
end
local function filter_menu_rows(rows)
    if type(rows)~="table" then return rows end
    local kept,removed={},false
    for _,row in ipairs(rows) do
        if hidden_menu_row(row) then removed=true
        else
            local item=row
            if type(row)=="table" and type(row.rowData)=="table" then
                local filtered=filter_menu_rows(row.rowData)
                if filtered~=row.rowData then
                    removed=true
                    if #filtered==0 then item=nil
                    else item={};for k,v in pairs(row) do item[k]=v end;item.rowData=filtered end
                end
            end
            if item~=nil then kept[#kept+1]=item end
        end
    end
    if not removed then return rows end
    for key,value in pairs(rows) do
        if type(key)~="number" then kept[key]=value end
    end
    local mt=getmetatable(rows)
    if type(mt)=="table" then setmetatable(kept,mt) end
    return kept
end
local menu_filters={}
local function refresh_menu_filter()
    refresh_mrp_filter()
    refresh_party_recovery()
    local owner=rawget(_G,"PLAY_MENU")
    for _,key in ipairs({"0xe6b778578fd0ceca","0x8bd23c233e881a48","0x07a629ebdf95b4b3"}) do
        local current=slot(owner,key)
        if type(current)=="function" and menu_filters[key]~=current then
            local grouped=key~="0xe6b778578fd0ceca"
            hook(owner,key,function(original)
                return function(...)
                    local result=pack(original(...))
                    if grouped then
                        local self=select(1,...)
                        local rows=self and self._modifiedMenuData
                        if type(rows)=="table" then
                            local filtered=filter_menu_rows(rows)
                            if filtered~=rows then
                                for i=#rows,1,-1 do rows[i]=nil end
                                for i,row in ipairs(filtered) do rows[i]=row end
                            end
                        end
                    else result[1]=filter_menu_rows(result[1]) end
                    return unpack(result,1,result.n)
                end
            end)
            menu_filters[key]=slot(owner,key)
        end
    end
    local category_key="0x6c04ce0f78723cd7"
    local category_current=slot(lobby,category_key)
    if type(category_current)=="function" and menu_filters[category_key]~=category_current then
        hook(lobby,category_key,function(original)
            return function(...)
                local result=pack(original(...))
                local filtered=filter_menu_rows(result[1])
                result[1]=filtered
                return unpack(result,1,result.n)
            end
        end)
        menu_filters[category_key]=slot(lobby,category_key)
    end
end
refresh_menu_filter()
if type((slot(builder,"LoadFile")))=="function" then
    hook(builder,"LoadFile",function(original)
        return function(...)
            local result=pack(original(...))
            refresh_menu_filter()
            return unpack(result,1,result.n)
        end
    end)
end
local function selected(controller)
    local ds=path(rawget(_G,"_DataSources"),"0xf71428806887f67d","0x1ccae3b6ef72f533","0xe14ec899fcdc838f")
    local get=member(ds,"GetValue");if type(get)=="function" then return get(ds,controller) end
end
local function mrp_choice(controller)
    local ds=path(rawget(_G,"_DataSources"),"0x08f73707b5922e00","0xfa1ec14daf3b21ad","0x2c0fbd4577b10b54")
    local get=member(ds,"GetValue");if type(get)=="function" then return get(ds,controller) end
end
local function validated_mrp(controller)
    local relic=rawget(_G,"ZMRELIC")
    local predicate=slot(relic,"0x60e2e1c5dc3d4efa")
    local getter=slot(relic,"0xd2720f9b536bb057")
    local ds=path(rawget(_G,"_DataSources"),"0x08f73707b5922e00","0xf71428806887f67d",
        "0xe31bc6e346e6be47","0x27bcf3f1bd325909")
    local get=member(ds,"GetValue")
    if type(predicate)~="function" or type(getter)~="function" or type(get)~="function" then return nil end
    local ref=get(ds,controller);if type(ref)=="string" then ref=asset_hash(ref) end
    if predicate(ref)~=true then return nil end
    local enabled=getter(controller)
    if type(enabled)=="boolean" then return enabled end
end
local mrp_filter_scope
local mrp_filter_wrapped
local function project_mrp_maps(maps)
    if type(maps)~="table" then return maps end
    local enabled
    if mrp_filter_scope~=nil then
        local getter=slot(rawget(_G,"ZMRELIC"),"0xd2720f9b536bb057")
        if type(getter)=="function" then
            local ok,value=pcall(getter,mrp_filter_scope)
            if ok and type(value)=="boolean" then enabled=value end
        end
    else
        if not state.context then return maps end
        enabled=validated_mrp(state.controller or 0)
    end
    if enabled~=true then return maps end
    local csm=rawget(_G,"CSM_MAYHEM_P1")
    if type(csm)=="table" and type(csm.projectMaps)=="function" then
        maps=csm.projectMaps(maps,mrp_filter_scope or state.controller or 0)
    end
    local projected
    for index,row in ipairs(maps) do
        local value=member(row,"gametypeAssetName")
        if value=="zm_rb_r_mod" or value==asset_hash("zm_rb_r_mod") then
            if not projected then projected={};for k,v in pairs(maps) do projected[k]=v end end
            local result={};for k,v in pairs(row) do result[k]=v end
            local _,key=slot(row,"gametypeAssetName")
            result[key or "gametypeAssetName"]=type(value)=="string" and "zm_rb_rh_mod" or asset_hash("zm_rb_rh_mod")
            projected[index]=result
        end
    end
    return projected or maps
end
refresh_mrp_filter=function()
    local owner=rawget(_G,"PlaylistUtils")
    local current=slot(owner,"0xad23584c54c46f40")
    if type(current)~="function" or current==mrp_filter_wrapped then return end
    hook(owner,"0xad23584c54c46f40",function(original)
        return function(...)
            local args=pack(...)
            local controller,wanted=args[1],args[3]
            local previous=mrp_filter_scope
            mrp_filter_scope=nil
            if wanted==asset_hash("zm_rb_rh_mod") and type(controller)=="number"
                and controller>=0 and controller%1==0 then
                mrp_filter_scope=controller
            end
            local result=pack(pcall(original,unpack(args,1,args.n)))
            mrp_filter_scope=previous
            if not result[1] then error(result[2],0) end
            return unpack(result,2,result.n)
        end
    end)
    mrp_filter_wrapped=slot(owner,"0xad23584c54c46f40")
end
local catalogue = {by_id={}, by_pair={}, unavailable_pairs={}, categories={}, selected=nil, publications=0}
local function ref_value(ref)
    return data.asset_refs and data.asset_refs[ref] and asset_hash(data.asset_refs[ref]) or ref
end
local function copy(t)
    local out={}; for k,v in pairs(t) do out[k]=v end; return out
end
local function put(t,name,value)
    local _,key=slot(t,name)
    rawset(t,key or hash(name),value)
end
local function pair(c,p) return tostring(c)..":"..tostring(p) end
local function project_map_records(value,row)
    if type(value)~="table" then return value end
    local source=data.records[row.template_id];local selected=data.records[row.id]
    local result=copy(value)
    for i,item in ipairs(value) do
        if type(item)=="table" then
            result[i]=copy(item)
            for k,v in pairs(item) do
                if v==source.map then result[i][k]=selected.map
                elseif v==asset_hash(source.map) then result[i][k]=asset_hash(selected.map) end
            end
            if selected.mode_override then
                local current=member(item,"gametypeAssetName")
                if current~=nil then put(result[i],"gametypeAssetName",current==source.asset and selected.asset or asset_hash(selected.asset)) end
            end
        elseif item==source.map then result[i]=selected.map
        elseif item==asset_hash(source.map) then result[i]=asset_hash(selected.map) end
    end
    return result
end
local squad_templates={[1000000001]=223,[1000000003]=223,[1000000005]=223,[1000000007]=223,[1000000009]=224,[1000000011]=224,[1000000013]=224,[1000000015]=224,[1000000017]=224,[1000000043]=223,[1000000045]=223,[1000000047]=223,[1000000049]=223,[1000000051]=223,[1000000053]=223,[1000000055]=223,[1000000057]=223,[1000000059]=223,[1000000061]=223,[1000000063]=417,[1000000065]=417,[1000000067]=417,[1000000069]=417,[1000000071]=417,[1000000073]=417,[1000000075]=417,[1000000077]=417,[1000000079]=223,[1000000081]=223,[1000000083]=223,[1000000085]=223,[1000000087]=223,[1000000089]=223,[1000000091]=223,[1000000093]=223}
local function install_catalogue()
    local squad_one_party=true
    local dsclass=member(lui,"DataSourceInGlobalModel")
    local constructor=member(dsclass,"new")
    local byid=slot(playlist,"0xcf9235692c85c724")
    local maps=slot(playlist,"0x2d93afc74cfe7ce0")
    local pair_set=slot(playlist,"0xe415d7bbba2b8a82")
    local producer=slot(lobby,"0x10ee58fa8f81e28a")
    local party_set=slot(lobby,"0xbe6e03a0292da533")
    local party_get=slot(lobby,"0x78044687f2800104")
    local party_id=member(member(lobby,"PartyUIData"),"PLAYLIST_ID")
    local card_get=slot(rawget(_G,"PLAY_MENU"),"0x15b97d8cf426b333")
    local localize=slot(engine,"Localize")
    if type(constructor)~="function" or type(byid)~="function" or type(maps)~="function"
        or type(pair_set)~="function" or type(producer)~="function" or type(card_get)~="function"
        or type(localize)~="function" or type(party_set)~="function" or type(party_get)~="function" or party_id==nil then
        return false
    end
    local function model(path) return constructor(path) end
    local function read(path)
        local ds=model(path);local get=member(ds,"GetValue")
        if type(get)~="function" then error("original global model reader unavailable") end
        return get(ds,0)
    end
    local function write(path,value)
        if value==nil then return end
        local ds=model(path);local set=member(ds,"SetValue")
        if type(set)~="function" then error("original global model writer unavailable") end
        set(ds,0,value)
    end
    local function prepare_categories(base)
        if base~="frontEnd.playlists.category" or frontend()~=true then return end
        local count=read(base..".count")
        if type(count)~="number" or count<1 or count>256 then return end
        for _,spec in ipairs(data.category_additions or {}) do
            local source,position,foreign
            for c=0,count-1 do
                local ref=read(base..".playMenuRef."..c)
                if ref==spec.template_ref or ref==asset_hash(spec.template_ref) then source=c end
                if read(base..".index."..c)==spec.index then
                    if ref~=ref_value(spec.ref) then error("local category identity conflict") end
                    position=c
                end
                if ref==ref_value(spec.ref) and read(base..".index."..c)~=spec.index then foreign=true end
            end
            if foreign then
            elseif source~=nil then
                local native_index=read(base..".index."..source)
                local card=card_get(ref_value(spec.ref))
                local name,description=member(card,"name"),member(card,"description")
                if type(native_index)~="number" or name==nil then error("original mode category source unavailable") end
                if position==nil then position=count end
                local undo={};local function commit(path,value)
                    if value==nil or read(path)==value then return end
                    undo[#undo+1]={path=path,value=read(path)};write(path,value)
                end
                local old=catalogue.categories[spec.index]
                catalogue.categories[spec.index]={native_index=native_index,position=position,spec=spec}
                local ok,why=pcall(function()
                    for _,field in ipairs(data.category_fields) do
                        local value=read(base.."."..field.."."..source)
                        if field=="index" then value=spec.index
                        elseif field=="playMenuRef" then value=ref_value(spec.ref)
                        elseif field=="name" then value=localize(name)
                        elseif field=="desc" and description~=nil then value=localize(description)
                        elseif field=="image" then value=member(card,spec.image_key) or value end
                        commit(base.."."..field.."."..position,value)
                    end
                    if position==count then
                        commit(base.."."..position..".playlist.count",0)
                        commit(base..".count",count+1)
                    end
                end)
                if not ok then
                    catalogue.categories[spec.index]=old
                    for i=#undo,1,-1 do local item=undo[i];pcall(member(model(item.path),"SetValue"),model(item.path),0,item.value) end
                    error(why,0)
                end
                if position==count then count=count+1 end
            end
        end
    end
    local cursed_tier_ids={[172]=true,[197]=true,[414]=true,[415]=true,[416]=true,[417]=true}
    local function repair_cursed_tiers(base,count)
        local pending
        for c=0,count-1 do
            local ref=read(base..".playMenuRef."..c)
            if ref=="sat_zm_category_r_mod" or ref==asset_hash("sat_zm_category_r_mod") then
                local prefix=base.."."..c..".playlist"
                local n=read(prefix..".count")
                if type(n)~="number" or n<0 or n>512 or n%1~=0 then error("invalid original Cursed row count") end
                for p=0,n-1 do
                    if cursed_tier_ids[read(prefix..".ID."..p)] then
                        local low=prefix..".ZMCursedTierMin."..p
                        local high=prefix..".ZMCursedTierMax."..p
                        if read(low)==-1 and read(high)==-1 then
                            pending=pending or {}
                            pending[#pending+1]={path=low,value=0}
                            pending[#pending+1]={path=high,value=3}
                        end
                    end
                end
            end
        end
        if not pending then return end
        local written=0
        local ok,why=pcall(function()
            for i,item in ipairs(pending) do
                if read(item.path)~=-1 then error("Cursed tier source changed during publication") end
                written=i;write(item.path,item.value)
                if read(item.path)~=item.value then error("Cursed tier model write was not retained") end
            end
        end)
        if not ok then
            for i=written,1,-1 do
                local ds=model(pending[i].path);pcall(member(ds,"SetValue"),ds,0,-1)
            end
            error(why,0)
        end
    end
    local function publish(base,category_ref)
        if base~="frontEnd.playlists.category" then return end
        if frontend()~=true then return end
        local count=read(base..".count")
        if type(count)~="number" or count<1 or count>256 then
            return
        end
        if category_ref=="sat_zm_category_r_mod" or category_ref=="sat_zm_category_r_mod_survival" then
            repair_cursed_tiers(base,count)
        end
        local additions={}
        for _,addition in ipairs(data.additions) do
            if addition.category_ref==category_ref then
                local template=not squad_one_party and squad_templates[addition.id]
                if template then addition=copy(addition);addition.template_id=template end
                additions[#additions+1]=addition
            end
        end
        local targets={};local wanted={};local category_refs={};local occupied={};local local_ids={}
        local category_spec
        for _,spec in ipairs(data.category_additions or {}) do if spec.ref==category_ref then category_spec=spec end end
        for _,addition in ipairs(additions) do
            wanted[addition.template_id]=true;category_refs[category_spec and category_spec.template_ref or addition.category_ref]=true;local_ids[addition.id]=true
        end
        if not card_aliases_ready then
            for _,addition in ipairs(additions) do
                if data.asset_refs and data.asset_refs[addition.play_menu_ref] then
                    return
                end
            end
        end
        for c=0,count-1 do
            local ref=read(base..".playMenuRef."..c)
            local all_prefix=base.."."..c..".playlist"
            local all_count=read(all_prefix..".count")
            if all_count~=nil then
                if type(all_count)~="number" or all_count<0 or all_count>512 or all_count%1~=0 then
                    error("invalid original category row count")
                end
                for p=0,all_count-1 do
                    local id=read(all_prefix..".ID."..p)
                    if local_ids[id] then
                        if occupied[id] then error("duplicate local catalogue ID across original categories: "..id) end
                        occupied[id]={prefix=all_prefix,position=p}
                    end
                end
            end
            local relevant=false
            for name in pairs(category_refs) do if ref==name or ref==asset_hash(name) then relevant=true end end
            if relevant then
                local prefix=base.."."..c..".playlist"
                local n=read(prefix..".count")
                local category=read(base..".index."..c)
                if type(n)~="number" or type(category)~="number" or n<0 or n>512 or n%1~=0 then
                    error("original category schema differs from recovered source")
                end
                for p=0,n-1 do
                    local id=read(prefix..".ID."..p)
                    if wanted[id] then
                        if targets[id] then error("ambiguous original template ID: "..id) end
                        targets[id]={prefix=prefix,count=n,category=category,position=p,
                            playlist_index=read(prefix..".index."..p)}
                    end
                end
            end
        end
        for id in pairs(wanted) do if not targets[id] then
            return
        end end
        if category_spec then
            local category=catalogue.categories[category_spec.index]
            if not category then return end
            local prefix=base.."."..category.position..".playlist"
            local n=read(prefix..".count")
            if type(n)~="number" or n<0 or n>512 or n%1~=0 then error("invalid local mode row count") end
            for _,target in pairs(targets) do
                target.source_prefix=target.prefix;target.source_category=target.category
                target.prefix=prefix;target.count=n;target.category=category_spec.index
            end
        end
        for _,addition in ipairs(additions) do
            local existing_row=occupied[addition.id]
            if existing_row and existing_row.prefix~=targets[addition.template_id].prefix then
                error("local catalogue ID conflict in another category: "..addition.id)
            end
        end
        local pending={};local counts={};local existing={}
        for _,target in pairs(targets) do
            if not existing[target.prefix] then
                local positions={};existing[target.prefix]=positions
                for p=0,target.count-1 do
                    local id=read(target.prefix..".ID."..p)
                    if id~=nil then
                        if positions[id]~=nil then error("duplicate catalogue ID in original model: "..id) end
                        positions[id]=p
                    end
                end
            end
        end
        local function validate_existing(addition,template,position)
            if position==nil then return end
            for _,field in ipairs({"mapName","playMenuRef","maxPartySize","minPartySize","gamemodekey",
                                    "isOneParty","ZMCursedTierMin","ZMCursedTierMax","isZMSurvivalPlaylist"}) do
                local actual=read(template.prefix.."."..field.."."..position)
                local expected
                if field=="mapName" then expected=addition.map
                elseif field=="playMenuRef" then expected=addition.play_menu_ref
                elseif field=="isZMSurvivalPlaylist" and data.records[addition.id].source_gametype=="local_zm_rb_r_mod_survival" then expected=true
                else expected=read((template.source_prefix or template.prefix).."."..field.."."..template.position) end
                if actual~=expected then
                    local previous=catalogue.by_id[addition.id]
                    if field~="isOneParty" or not squad_templates[addition.id] or not previous
                        or actual~=previous.row[field] or type(actual)~="boolean" or type(expected)~="boolean"
                        or read(template.prefix..".lumenLocalOwner."..position)~="v6-local-catalogue" then
                        error("local catalogue ID conflict "..addition.id.." field="..field)
                    end
                end
            end
            if read(template.prefix..".index."..position)~=position then
                error("local catalogue ID conflict "..addition.id.." field=index")
            end
        end
        local complete=true
        for _,addition in ipairs(additions) do
            local target=targets[addition.template_id]
            validate_existing(addition,target,existing[target.prefix][addition.id])
            if not catalogue.by_id[addition.id] or existing[target.prefix][addition.id]==nil
                or catalogue.by_id[addition.id].template_id~=addition.template_id then complete=false;break end
        end
        if complete then return end
        for _,addition in ipairs(additions) do
            local template=targets[addition.template_id]
            local prefix=template.prefix
            local raw=byid(addition.template_id)
            local original_maps=maps(template.source_category or template.category,template.playlist_index)
            local card=card_get(ref_value(addition.play_menu_ref))
            local label=member(card,"name")
            local description=member(card,"description")
            if type(raw)~="table" or type(original_maps)~="table" or #original_maps~=1 or label==nil then
                error("local catalogue source unavailable for "..addition.map.." raw="..type(raw)
                    .." maps="..type(original_maps).." card="..type(card).." name="..type(label))
            end
            local title=addition.title or localize(label)
            if type(title)~="string" or title=="" then error("original map localization unavailable: "..addition.map) end
            local row={}
            for _,field in ipairs(data.fields) do
                row[field]=read((template.source_prefix or template.prefix).."."..field.."."..template.position)
            end
            local position=existing[prefix][addition.id]
            validate_existing(addition,template,position)
            if position==nil then
                position=counts[prefix] or template.count
                counts[prefix]=position+1
            end
            row.ID=addition.id;row.index=position;row.mapName=addition.map
            row.playMenuRef=addition.play_menu_ref;row.name=title
            if data.records[addition.id].source_gametype=="local_zm_rb_r_mod_survival" then row.isZMSurvivalPlaylist=true end
            if addition.description then row.desc=addition.description elseif description~=nil then row.desc=localize(description) end
            row.image=addition.image_override or member(card,addition.image_key) or addition.image
            if type(row.image)~="string" then error("original map image unavailable: "..addition.play_menu_ref) end
            if row.missionName==data.records[addition.template_id].map then row.missionName=addition.map end
            local metadata=copy(raw)
            for _,field in ipairs({"ID","mapName","playMenuRef","name","desc","image","missionName","isZMSurvivalPlaylist"}) do
                if row[field]~=nil then put(metadata,field,row[field]) end
            end
            local map_rows={}
            for k,v in pairs(original_maps) do map_rows[k]=v end
            map_rows[1]=copy(original_maps[1])
            local source_map=data.records[addition.template_id].map
            for k,v in pairs(map_rows[1]) do
                if v==source_map then map_rows[1][k]=addition.map
                elseif v==asset_hash(source_map) then map_rows[1][k]=asset_hash(addition.map) end
            end
            pending[#pending+1]={id=addition.id,template_id=addition.template_id,
                category=template.category,playlist_index=position,template_index=template.playlist_index,
                source_category=template.source_category or template.category,
                prefix=prefix,row=row,metadata=metadata,maps=map_rows}
        end
        local next_ids,next_pairs={},{}
        for id,entry in pairs(catalogue.by_id) do
            if entry.category_ref~=category_ref then next_ids[id]=entry end
        end
        for key,entry in pairs(catalogue.by_pair) do
            if entry.category_ref~=category_ref then next_pairs[key]=entry end
        end
        for _,entry in ipairs(pending) do
            entry.category_ref=category_ref
            next_ids[entry.id]=entry
            next_pairs[pair(entry.category,entry.playlist_index)]=entry
            catalogue.unavailable_pairs[pair(entry.category,entry.playlist_index)]=nil
        end
        local previous_ids,previous_pairs=catalogue.by_id,catalogue.by_pair
        catalogue.by_id=next_ids;catalogue.by_pair=next_pairs
        local undo={}
        local function commit(path,value)
            if value==nil or read(path)==value then return end
            undo[#undo+1]={path=path,value=read(path)}
            write(path,value)
        end
        local committed,why=pcall(function()
            for _,entry in ipairs(pending) do
                for _,field in ipairs(data.fields) do
                    if field~="ID" then commit(entry.prefix.."."..field.."."..entry.playlist_index,entry.row[field]) end
                end
                commit(entry.prefix..".lumenLocalOwner."..entry.playlist_index,"v6-local-catalogue")
                commit(entry.prefix..".ID."..entry.playlist_index,entry.id)
            end
            for path,n in pairs(counts) do commit(path..".count",n) end
        end)
        if not committed then
            catalogue.by_id=previous_ids;catalogue.by_pair=previous_pairs
            for i=#undo,1,-1 do
                local item=undo[i];local ds=model(item.path);local set=member(ds,"SetValue")
                pcall(set,ds,0,item.value)
            end
            error(why,0)
        end
        catalogue.publications=catalogue.publications+1
    end
    local function attempt_publish(base)
        if catalogue.publishing then return end
        catalogue.publishing=true
        pcall(prepare_categories,base)
        local categories={}
        catalogue.last_errors=catalogue.last_errors or {}
        for _,addition in ipairs(data.additions) do categories[addition.category_ref]=true end
        for ref in pairs(categories) do
            local ok,reason=pcall(publish,base,ref)
            if not ok then
                for id,row in pairs(catalogue.by_id) do
                    if row.category_ref==ref then catalogue.by_id[id]=nil end
                end
                for key,row in pairs(catalogue.by_pair) do
                    if row.category_ref==ref then catalogue.unavailable_pairs[key]=true;catalogue.by_pair[key]=nil end
                end
                if catalogue.selected and not catalogue.by_id[catalogue.selected] then catalogue.selected=nil end
                reason=tostring(reason)
                if catalogue.last_errors[ref]~=reason then end
                catalogue.last_errors[ref]=reason
            else catalogue.last_errors[ref]=nil end
        end
        catalogue.publishing=false
    end
    refresh_squad_catalogue=function(controller)
        if state.request or catalogue.publishing or frontend()~=true then return end
        local node=path(rawget(_G,"_DataSources"),"0xf71428806887f67d","0x1ccae3b6ef72f533","0x28e0e5d4a481226e")
        local getter=member(node,"GetValue")
        if type(getter)~="function" then return end
        local ok,value=pcall(getter,node,type(controller)=="number" and controller or state.controller or 0)
        if ok and type(value)=="boolean" and value~=squad_one_party then
            squad_one_party=value;attempt_publish("frontEnd.playlists.category")
        end
    end
    hook(lobby,"0x10ee58fa8f81e28a",function(original)
        return function(base,...)
            local result=pack(original(base,...))
            attempt_publish(base)
            return unpack(result,1,result.n)
        end
    end)
    local utils=rawget(_G,"PlaylistUtils")
    if type((slot(utils,"0xeda10385e76d30fe")))=="function" then
        hook(utils,"0xeda10385e76d30fe",function(original)
            return function(...)
                local result=pack(original(...));attempt_publish("frontEnd.playlists.category")
                return unpack(result,1,result.n)
            end
        end)
    end
    hook(playlist,"0xcf9235692c85c724",function(original)
        return function(id,...)
            local row=catalogue.by_id[id]
            if row then return copy(row.metadata) end
            if data.records[id] and data.records[id].local_record then return nil end
            return original(id,...)
        end
    end)
    hook(playlist,"0x2d93afc74cfe7ce0",function(original)
        return function(category,index,...)
            local row=catalogue.by_pair[pair(category,index)]
            if not row and catalogue.unavailable_pairs[pair(category,index)] then error("unpublished local map query refused",0) end
            local result
            if row then
                result=pack(original(row.source_category,row.template_index,...))
                if type(result[1])=="table" then
                    local projected=copy(result[1])
                    local source_map=data.records[row.template_id].map
                    local destination=data.records[row.id].map
                    for i,map_row in ipairs(result[1]) do
                        projected[i]=copy(map_row)
                        for k,v in pairs(map_row) do
                            if v==source_map then projected[i][k]=destination
                            elseif v==asset_hash(source_map) then projected[i][k]=asset_hash(destination) end
                        end
                        local record=data.records[row.id]
                        if record.mode_override then
                            put(projected[i],"gametypeAssetName",asset_hash(record.asset))
                        end
                    end
                    result[1]=projected
                end
            else result=pack(original(category,index,...)) end
            result[1]=project_mrp_maps(result[1])
            return unpack(result,1,result.n)
        end
    end)
    hook(playlist,"0xe415d7bbba2b8a82",function(original)
        return function(category,index,...)
            local row=catalogue.by_pair[pair(category,index)]
            if not row and catalogue.unavailable_pairs[pair(category,index)] then error("unpublished local selection refused",0) end
            if row then
                local result=pack(original(row.source_category,row.template_index,...))
                catalogue.selected=row.id
                return unpack(result,1,result.n)
            end
            local result=pack(original(category,index,...))
            catalogue.selected=nil
            return unpack(result,1,result.n)
        end
    end)
    for _,spec in ipairs(data.native_pair_queries or {}) do
        if type((slot(playlist,spec.key)))=="function" then
            hook(playlist,spec.key,function(original)
                return function(...)
                    local args=pack(...)
                    local row=catalogue.by_pair[pair(args[spec.category],args[spec.index])]
                    if not row and catalogue.unavailable_pairs[pair(args[spec.category],args[spec.index])] then error("unpublished local query refused",0) end
                    if row then args[spec.category]=row.source_category;args[spec.index]=row.template_index end
                    return original(unpack(args,1,args.n))
                end
            end)
        end
    end
    for _,spec in ipairs(data.native_category_queries or {}) do
        if type((slot(playlist,spec.key)))=="function" then
            hook(playlist,spec.key,function(original)
                return function(category,...)
                    local row=catalogue.categories[category]
                    if row and spec.card then return ref_value(row.spec.ref) end
                    local result=pack(original(row and row.native_index or category,...))
                    if row and spec.metadata and type(result[1])=="table" then
                        result[1]=copy(result[1])
                        for _,field in ipairs(data.category_fields) do
                            local value=read("frontEnd.playlists.category."..field.."."..row.position)
                            if value~=nil then put(result[1],field,value) end
                        end
                    elseif spec.list and type(result[1])=="table" then
                        local projected=row and {} or copy(result[1])
                        for _,entry in pairs(catalogue.by_id) do
                            if entry.category==category then
                                local template
                                for _,item in ipairs(result[1]) do
                                    if member(item,"playlistID")==entry.template_id then template=item;break end
                                end
                                if type(template)~="table" then error("original category list template unavailable",0) end
                                local item=copy(template);put(item,"playlistID",entry.id)
                                projected[entry.playlist_index+1]=item
                            end
                        end
                        result[1]=projected
                    end
                    return unpack(result,1,result.n)
                end
            end)
        end
    end
    if type((slot(playlist,"0x3d78924ad23de66b")))=="function" then
        hook(playlist,"0x3d78924ad23de66b",function(original)
            return function(...)
                local result=pack(original(...));local row=catalogue.by_id[catalogue.selected]
                if row and catalogue.categories[row.category] and result[1]==row.source_category then result[1]=row.category end
                return unpack(result,1,result.n)
            end
        end)
    end
    hook(lobby,"0xbe6e03a0292da533",function(original)
        return function(field,value,...)
            local row=field==party_id and catalogue.by_id[value]
            if field==party_id and data.records[value] and data.records[value].local_record and not row then
                error("unpublished local catalogue selection refused before native party write",0)
            end
            if row then
                local result=pack(original(field,row.template_id,...))
                catalogue.selected=row.id
                return unpack(result,1,result.n)
            end
            local result=pack(original(field,value,...))
            if field==party_id then catalogue.selected=nil end
            return unpack(result,1,result.n)
        end
    end)
    hook(lobby,"0x78044687f2800104",function(original)
        return function(...)
            local result=pack(original(...))
            local row=catalogue.by_id[catalogue.selected]
            if row and result[1]==row.template_id then result[1]=row.id end
            return unpack(result,1,result.n)
        end
    end)
    if type((slot(lobby,"0x4b92da1948edb47d")))=="function" then
        hook(lobby,"0x4b92da1948edb47d",function(original)
            return function(field,...)
                local result=pack(original(field,...));local row=catalogue.by_id[catalogue.selected]
                if field==party_id and row and result[1]==row.template_id then result[1]=row.id end
                return unpack(result,1,result.n)
            end
        end)
    end
    hook(playlist,"0x97b3b2b73b53eb34",function(original)
        return function(...)
            local result=pack(original(...))
            local row=catalogue.by_id[catalogue.selected]
            if row and result[1]==row.template_id then result[1]=row.id end
            return unpack(result,1,result.n)
        end
    end)
    if type((slot(playlist,"0x57e993d31db33676")))=="function" then
        hook(playlist,"0x57e993d31db33676",function(original)
            return function(id,...)
                local row=catalogue.by_id[id]
                return original(row and row.template_id or id,...)
            end
        end)
    end
    for _,spec in ipairs(data.native_id_queries or {}) do
        if type((slot(playlist,spec.key)))=="function" then
            hook(playlist,spec.key,function(original)
                return function(id,...)
                    local row=catalogue.by_id[id]
                    if data.records[id] and data.records[id].local_record and not row then
                        error("unpublished local ID refused before original playlist query",0)
                    end
                    local result=pack(original(row and row.template_id or id,...))
                    if row and spec.projection then result[1]=project_map_records(result[1],row) end
                    if spec.projection=="map_records" then result[1]=project_mrp_maps(result[1]) end
                    return unpack(result,1,result.n)
                end
            end)
        end
    end
    catalogue.publish=attempt_publish
    return true
end
local config={owned={},order={}}
local dvars=rawget(_G,"Dvar")
local exists=slot(dvars,"0xe1fab6d9a30481f8")
local readers={string=slot(dvars,"0x254084d7ca2317bb"),
    float=slot(dvars,"0x2edcfc612b39e0c0")}
readers.int=slot(dvars,data.int_reader)
local boolean=slot(dvars,"0xc9e5be3b4bba4e0e")
local function read_native(fn,key)
    if type(fn)~="function" then return nil end
    local ok,value=pcall(fn,key);if ok then return value end
end
local function config_read(entry)
    if type(exists)~="function" or exists(dvar_hash(entry.key))~=true then return nil end
    local key=dvar_hash(entry.key)
    if entry.external then
        local text=read_native(readers.string,key)
        if entry.kind=="string" and type(text)=="string" then return text end
        if type(text)=="string" and tonumber(text)~=nil then return tonumber(text) end
    end
    local reader=readers[entry.kind]
    local v=read_native(reader,key)
    if type(v)=="boolean" then return v and 1 or 0 end
    if v==nil then
        local text=read_native(readers.string,key)
        if entry.kind=="string" then v=text
        elseif type(text)=="string" then v=tonumber(text) end
    end
    if v==nil and entry.kind=="int" and (entry.value==0 or entry.value==1) and type(boolean)=="function" then
        local b=read_native(boolean,key);if type(b)=="boolean" then return b and 1 or 0 end
    end
    if entry.kind~="string" and type(v)=="string" then v=tonumber(v) end
    return v
end
local function config_command(entry,value)
    if type(value)=="string" then
        if string.find(value,'[\r\n;"\\]') then error("unsupported native configuration string") end
        value='"'..value..'"'
    elseif type(value)=="number" and value==value and math.abs(value)<math.huge then value=tostring(value)
    else error("invalid native configuration value") end
    return "set "..entry.console_key.." "..value
end
local function restore_config(controller)
    local csm=rawget(_G,"CSM_MAYHEM_P1")
    if type(csm)=="table" and type(csm.reset)=="function" then pcall(csm.reset) end
    for i=#config.order,1,-1 do
        local key=config.order[i];local item=config.owned[key]
        pcall(exec,config_command(item.entry,item.before),controller)
    end
    config.owned={};config.order={}
end
local function apply_config(request)
    restore_config(request.controller)
    local selected_keys={}
    for _,entry in ipairs(request.record.configuration) do selected_keys[entry.key]=true end
    for _,entry in ipairs(data.reset_defaults) do
        if state.request~=request then return end
        if not selected_keys[entry.key] and config_read(entry)~=nil then
            exec(config_command(entry,entry.consumer_default),request.controller)
        end
    end
    request.written={};request.skipped={}
    for _,entry in ipairs(request.record.configuration) do
        if state.request~=request then return end
        local before=config_read(entry)
        if before==nil then before=entry.consumer_default end
        if before==nil then
            request.skipped[#request.skipped+1]=entry.key
            if entry.required then error("selected control has no local configuration source: "..entry.key) end
        else
            if type(exists)=="function" and exists(dvar_hash(entry.key))~=true then entry.external=true end
            config.owned[entry.key]={entry=entry,before=before}
            config.order[#config.order+1]=entry.key
            exec(config_command(entry,entry.value),request.controller)
            request.written[#request.written+1]=entry
        end
    end
    if #request.skipped>0 then end
end


local function isolate_standard_relics(request)
    if request.resume or request.asset~="sat_zm_rb" then return end
    if state.request~=request or frontend()~=true then error("Standard relic request cancelled",0) end
    local entry={key="0x70ef86ad43e08120",console_key="#x370ef86ad43e08120",
        kind="int",value=0,required=true}
    local before=config_read(entry)
    if before==nil then
        if type(exists)~="function" or exists(dvar_hash(entry.key))~=false then
            error("Standard relic setting is unreadable",0)
        end
        before=0
        entry.external=true
    end
    if type(before)~="number" or before~=before or math.abs(before)==math.huge then
        error("Standard relic setting has unsupported storage",0)
    end
    if not config.owned[entry.key] then
        config.owned[entry.key]={entry=entry,before=before}
        config.order[#config.order+1]=entry.key
    end
    exec(config_command(entry,0),request.controller)
    request.written[#request.written+1]=entry
end

local function observe_config(request)
    local mismatches={};local required={}
    for _,entry in ipairs(request.written or {}) do
        local actual=config_read(entry)
        local rex_expected=request.rex_expected and request.rex_expected[entry.key]
        local expected=rex_expected and rex_expected.value or entry.value
        local equal=actual==expected
        if not equal and entry.kind=="float" and type(actual)=="number" and actual==actual
            and math.abs(actual)<math.huge then
            equal=math.abs(actual-entry.value)<=math.max(1,math.abs(entry.value))*2^-22
        end
        if not equal then
            mismatches[#mismatches+1]=entry.key
            if entry.required then required[#required+1]=entry.key end
        end
    end
    request.config_mismatches=mismatches
    return #required==0,table.concat(required,",")
end
local rex_keys={
 enable_rh="0x4564bbcd614eb648",skip_zm_rh_validation="0x7ae1c9d5cf785e78",
 enable_scarab_br="0x1384da7dad994f49",enable_firefly_rh="0xdfe1457c40e61c02",
 enable_ruby_rh="0x3a67100b9bf066cd",enable_mantis_rh="0xbba15b9d56beb485",
 enable_locust_rh="0x4283bcfc772f341b",enable_hornet_rh="0xa7ecb342705c5659",
 enable_scarab_rh="0x133ef07dad4cf03b",enable_scarab_ee="0x1389eb7dad9f9d83",
 enable_scarab_sq="0x1339f37dad46cdfd",enable_zm_relics="0x70ef86ad43e08120",
 enable_ee_headphones="0x81bdf630f92c116e",enable_ncfd_pedestal="0xd0fb5140c8aff08e"}
local rex_flags={"enable_rh","skip_zm_rh_validation","enable_scarab_rh","enable_scarab_br",
 "enable_zm_relics","enable_firefly_rh","enable_ruby_rh","enable_mantis_rh","enable_locust_rh","enable_hornet_rh"}
local rex_super={"enable_rh","skip_zm_rh_validation","enable_scarab_br","enable_firefly_rh",
 "enable_ruby_rh","enable_mantis_rh","enable_locust_rh","enable_hornet_rh","enable_scarab_rh",
 "enable_scarab_ee","enable_scarab_sq"}
local function rex_scope(request)
 return request.record.map=="zm_sat_scarab" and
  (request.asset=="sat_zm_rb" or request.asset=="zm_rb_r_mod" or request.asset=="zm_rb_rh_mod")
end
local function rex_entry(name,value)
 local key=assert(rex_keys[name]);return {key=key,console_key="#x3"..string.sub(key,3),kind="int",value=value,external=true}
end
local rex_journal_key="0xf87e12bfa828b510"
local rex_journal_token="#x3f87e12bfa828b510"
local rex_journal_tag="M7REXSUPER1:"
local rex_owned
local function rex_journal(text,controller)
 local command="set "..rex_journal_token..' "'..text..'"'
 exec(command,controller)
 local actual=read_native(readers.string,dvar_hash(rex_journal_key))
 if actual~=text then error("Rex runtime ownership journal did not verify",0) end
end
local function rex_restore(controller)
 local rows=rex_owned
 if not rows then
  if type(exists)~="function" or exists(dvar_hash(rex_journal_key))~=true then return end
  local text=read_native(readers.string,dvar_hash(rex_journal_key))
  if text=="" then return end
  if type(text)~="string" or string.sub(text,1,#rex_journal_tag)~=rex_journal_tag then return end
  rows={};local seen={};local payload=string.sub(text,#rex_journal_tag+1)
  for item in string.gmatch(payload,"[^,]+") do
   local name,value=string.match(item,"^([%w_]+)=([%d%.eE%+%-]+)$")
   value=tonumber(value)
   if not name or not rex_keys[name] or seen[name] or not value or value~=value or math.abs(value)==math.huge then
    error("Rex runtime ownership journal is malformed",0)
   end
   seen[name]=true;rows[#rows+1]={name=name,value=value}
  end
  for name in pairs(rex_keys)do
   if name~="enable_ee_headphones"and not seen[name]then error("Rex runtime ownership journal is incomplete",0)end
  end
 end
 for i=#rows,1,-1 do
  local row=rows[i];local entry=rex_entry(row.name,row.value)
  exec(config_command(entry,row.value),controller)
  if config_read(entry)~=row.value then error("Rex restore rejected: "..row.name,0)end
 end
 rex_journal("",controller);rex_owned=nil
end
local rex_cleanup_ok,rex_cleanup_error=true,nil
local original_restore_config=restore_config
restore_config=function(controller)
 original_restore_config(controller)
 rex_cleanup_ok,rex_cleanup_error=pcall(rex_restore,controller)
end
if frontend()==true then rex_cleanup_ok,rex_cleanup_error=pcall(rex_restore,0)end
local function rex_claim(request)
 if not rex_cleanup_ok then error(rex_cleanup_error,0)end
 if type(exists)~="function"then error("Rex original existence interface unavailable",0)end
 if exists(dvar_hash(rex_journal_key))==true then
  local text=read_native(readers.string,dvar_hash(rex_journal_key))
  if text~=""then error("Rex runtime ownership journal is not available",0)end
 end
 local names={};for name in pairs(rex_keys)do
  if name~="enable_ee_headphones"or request.asset=="sat_zm_rb"then names[#names+1]=name end
 end;table.sort(names)
 local rows,text={},{}
 for _,name in ipairs(names)do
  local entry=rex_entry(name,0);local owned=config.owned[entry.key]
  local before=owned and owned.before or config_read(entry)
  if before==nil then
   if type(exists)~="function" or exists(dvar_hash(entry.key))~=false then
    error("Rex original setting unreadable: "..name,0)
   end
   before=name=="enable_ee_headphones"and 1 or 0
  end
  if type(before)~="number" or before~=before or math.abs(before)==math.huge then
   error("Rex original setting has unsupported storage: "..name,0)
  end
  rows[#rows+1]={name=name,value=before};text[#text+1]=name.."="..tostring(before)
 end
 rex_journal(rex_journal_tag..table.concat(text,","),request.controller);rex_owned=rows
 request.rex_expected={}
end
local function rex_write(request,name,value)
 if state.request~=request or frontend()~=true then error("Rex request cancelled",0)end
 local entry=rex_entry(name,value)
 local command=config_command(entry,value).."\n"
 local immediate=slot(engine,"ExecNow");local ok=false
 if type(immediate)=="function" then ok=pcall(immediate,command,request.controller)end
 if not ok then
  local queued=slot(engine,"Exec")
  if type(queued)~="function" then error("Rex queued native command unavailable",0)end
  queued(command,request.controller)
 end
 request.rex_expected[entry.key]=entry
end
local function rex_ones(request,names)
 for _,name in ipairs(names)do rex_write(request,name,1)end
end
local function rex_prepare(request)
 rex_claim(request)
 rex_write(request,"enable_zm_relics",request.asset=="sat_zm_rb" and 0 or 1)
 for _,name in ipairs(rex_flags)do if name~="enable_zm_relics"then rex_write(request,name,0)end end
 rex_write(request,"enable_ncfd_pedestal",0);rex_write(request,"enable_ncfd_pedestal",1)
 if request.asset=="sat_zm_rb" then
  for _,name in ipairs(rex_flags)do rex_write(request,name,0)end
  rex_ones(request,{"enable_ee_headphones","enable_scarab_ee","enable_scarab_sq","enable_ncfd_pedestal"})
  rex_ones(request,rex_super)
 else
  rex_ones(request,{"enable_scarab_ee","enable_scarab_sq","enable_scarab_rh","enable_scarab_br"})
 end
end
local function rex_finalize(request)
 if request.asset~="sat_zm_rb"then rex_ones(request,rex_super);rex_write(request,"enable_zm_relics",1)end
end
local function rex_verify(request)
 if not request.rex_expected then return end
 for key,entry in pairs(request.rex_expected)do
  if config_read(entry)~=entry.value then error("Rex launch setting rejected: "..key,0)end
 end
 request.rex_configuration_verified=true
end
local timer_event=hash("lumen_zm_local_start_tick")
local function detach(request)
    state.lease=state.lease+1
    if request and request.host then
        local remove=member(request.host,"RemoveEventTimer")
        if type(remove)=="function" then pcall(remove,request.host,timer_event) end
        request.host=nil
    end
end
local function home(controller)
    if type(queue_uri)=="function" then queue_uri({hash(data.root_uri)},controller) end
end



local preserve_shared_preparation
local function preparation_cancel_allowed(reason)
 if reason=="original Back/Cancel"or reason=="original Back command"then return true end
 local active=member(rawget(_G,"GameModesUtils"),"0x589367a5b3c4aa7f")
 if type(active)~="function"then return false end
 local ok,zm=pcall(active)
 return ok and zm==true
end
local function cancel(reason,navigate,show,keepParty)
    local request=state.request
    if keepParty==nil and request and preserve_shared_preparation and preparation_cancel_allowed(reason)then
        local ok,keep=pcall(preserve_shared_preparation,request)
        keepParty=ok and keep==true
        
    end
    
    local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
    if request and type(compatibility)=="table" and type(compatibility.cancelSaveLaunch)=="function" then
        pcall(compatibility.cancelSaveLaunch,request)
    end
    if frontend()==true then
        if save_connected then pcall(save_transport,"clear") end
    end
    state.request=nil;state.generation=state.generation+1;state.phase="idle"
    detach(request)
    if not request then return end
    if request.touched and not keepParty then
        pcall(leave,request.controller,true)
    end
    restore_config(request.controller)
    if navigate then home(request.controller) end
    if show and type(popup)=="function" then popup(request.controller,"Local Zombies",reason) end
end
local party_recovery={busy=false,attempted=false,reset_reason="first_Zombies_entry_this_VM"}
state.party_recovery=party_recovery
local function private_party_count(controller)
    local ds=path(rawget(_G,"DataSources"),"alwaysLoaded","privateParty","count")
    local getter=member(ds,"GetValue")
    if type(getter)~="function" then return nil,"missing_count_source" end
    local result=pack(pcall(getter,ds,controller))
    if not result[1] then return nil,"count_read_error" end
    local value=result[2]
    if result.n~=2 or type(value)~="number" or value~=value or value<0 or value%1~=0 or value==math.huge then
        return nil,"unreadable_count"
    end
    return value,"count_read"
end
local function native_party_boolean(key,label)
    local getter=slot(lobby,key)
    if type(getter)~="function" then return nil,"missing_"..label,0 end
    local result=pack(pcall(getter))
    if not result[1] then return nil,label.."_error",0 end
    if result.n~=2 or type(result[2])~="boolean" then return nil,label.."_unreadable",result.n-1 end
    return result[2],label.."_read",1
end
local function private_party_state() return native_party_boolean("0xf63537242f1d48ff","native_party_query") end
local function private_party_host() return native_party_boolean("0x96957722ef74f5d2","native_host_query") end
local squads_rs1={version="RS1",status="waiting_for_native_bridge"}
state.squadsRS1=squads_rs1
local ready_handoff={version="RP3",phase=0}
local function squad_bridge()
 
 local getter=slot(rawget(_G,"Dvar"),"0x254084d7ca2317bb")
 if type(getter)~="function"then return end
 local ok,key=pcall(dvar_hash,"kronos_squad_rs1")
 if not ok or key==nil then return end
 local r=pack(pcall(getter,key))
 if r[1]~=true or r.n~=2 or type(r[2])~="string"then return end
 local text=r[2]
 
 if text:sub(1,4)=="rp2:"then squads_rs1.rp2=true end
 if squads_rs1.text==text then return squads_rs1.snapshot end
 local seq,pending,result,members,ready=text:match("^rs1:(%x%x%x%x%x%x%x%x):([01]):([0-3]):(%x%x%x%x%x%x%x%x):(%x%x%x%x%x%x%x%x)$")
 local flags,target
 if not seq then seq,pending,result,members,ready,flags,target=text:match("^rp2:(%x%x%x%x%x%x%x%x):([01]):([0-3]):(%x%x%x%x%x%x%x%x):(%x%x%x%x%x%x%x%x):(%x%x%x%x%x%x%x%x):(%x%x%x%x%x%x%x%x)$")end
 if flags then
  flags,target=tonumber(flags,16),tonumber(target,16)
  if flags>33685503 or target>256 then return end
 end
 if not seq then return end
 seq,members,ready=tonumber(seq,16),tonumber(members,16),tonumber(ready,16)
 if seq%2~=0 or members>256 or ready>members then return end
 local snapshot={sequence=seq,pending=pending=="1",result=tonumber(result),members=members,ready=ready}
 if flags then
  snapshot.retail=true;snapshot.connected=ready;snapshot.target_members=target
  snapshot.armed=flags%2==1;snapshot.all_ready=math.floor(flags/2)%2==1
  snapshot.start_mask=math.floor(flags/4)%16;snapshot.epoch=math.floor(flags/64)%256
  snapshot.context=math.floor(flags/16384)%2;snapshot.setup=math.floor(flags/32768)%4
  snapshot.ready_members=math.floor(flags/131072)
 end
 squads_rs1.text,squads_rs1.snapshot=text,snapshot
 if not squads_rs1.active then
  squads_rs1.active=true;squads_rs1.status="active"
  
  
 end
 return snapshot
end
local function squad_join_end(outcome,show)
 local intent=squads_rs1.intent
 squads_rs1.intent=nil;squads_rs1.status=outcome
 if intent and show and type(popup)=="function"then
  popup(intent.controller,"Party",show)
 end
end
function state.rs1PollParty(controller,elapsed)
 local b=squad_bridge();if not b then return end
 local intent=squads_rs1.intent
 if not intent then return b end
 if b.pending then squads_rs1.status="native_join_in_progress";return b end
 if b.sequence~=intent.sequence then
  if b.result==1 then squad_join_end("native_preparation_rejected","The engine could not prepare this party connection. No squad connection was confirmed.")
  elseif b.result==3 then squad_join_end("native_join_input_rejected")
  elseif b.result==2 then
   if b.members>1 then squad_join_end("native_join_finished")
   else squad_join_end("native_join_ended_without_members","The party join ended without a connected squad.")end
  end
 elseif elapsed==500 and frontend()==true then
  intent.waited=(intent.waited or 0)+elapsed
  if intent.waited>=120000 then squad_join_end("join_not_submitted","The party request did not reach the engine. You can try joining again.")end
 end
 return b
end
function state.rs1BeginPartyJoin(controller,id,name)
 local b=state.rs1PollParty(controller)
 if not b then return true end
 if b.pending or squads_rs1.intent then
  if type(popup)=="function"then popup(controller,"Party","A party join is already in progress. Cancel that join before choosing another party.")end
  return false
 end
 if state.request and frontend()==true then cancel("joining another party",false,false,false)end
 squads_rs1.intent={controller=controller,id=id,name=name,sequence=b.sequence}
 squads_rs1.status="join_requested"
 return true
end
function state.rs1ObservePartyNotice(note)
 local b=state.rs1PollParty(state.controller or 0)
 if type(note)=="table"and note.kind=="follow"and b and(b.ready<2 or b.pending)then return false end
 return true
end
local function squad_start_state(controller,record)
 local b=state.rs1PollParty(controller)
 if not b then
  if squads_rs1.rp2 then
   
   if type(popup)=="function"then popup(controller,"Party","The native party state is not available yet. Please try Start again.")end
   return false
  end
  return true,false
 end
 if b.pending or squads_rs1.intent then
  
  if type(popup)=="function"then popup(controller,"Party","Wait for the party join to finish before starting a match.")end
  return false
 end
 if b.members>1 then
  local host=private_party_host()
  if host~=true then
   
   if type(popup)=="function"then popup(controller,"Party","Only the party leader can start the match.")end
   return false
  end
  if type(record.maxparty)=="number"and b.members>record.maxparty then
   
   if type(popup)=="function"then popup(controller,"Party","This selection does not support the current party size. Choose a Squad playlist.")end
   return false
  end
  return true,true,b.members
 end
 return true,false
end
preserve_shared_preparation=function(request)
 if state.request~=request or state.phase~="preparing" or request.rs1_shared_party~=true or frontend()~=true then return false end
 local b=state.rs1PollParty(request.controller)
 if not b or not b.retail or b.pending or squads_rs1.intent or b.context~=0 or b.start_mask~=7 then return false end
 local n=b.members
 if type(n)~="number"or n<2 or n>4 or n%1~=0 or n~=request.rs2_expected_members then return false end
 if b.target_members~=n or b.ready_members~=n or b.connected~=n or private_party_host()~=true then return false end
 return true
end
local shared_back_route
local shared_back_declines={}
local function shared_back_declined(reason,controller)
 if not reason or shared_back_declines[reason]then return end
 shared_back_declines[reason]=true
 
end
local function shared_back_controller(controller)
 if type(controller)=="string"and string.match(controller,"^%s*%d+%s*$")then
  local n=tonumber(controller)
  if n and n>=0 and n%1==0 then return n end
 end
 return controller
end
local function shared_back_party(controller)
 if state.request or state.phase~="idle"then return nil,"launch_not_idle"end
 if frontend()~=true then return nil,"not_frontend"end
 local active=member(rawget(_G,"GameModesUtils"),"0x589367a5b3c4aa7f")
 if type(active)~="function"then return nil,"active_zm_query_missing"end
 local ok,zm=pcall(active)
 if not ok then return nil,"active_zm_query_error"end
 if zm~=true then return nil,"active_mode_not_zombies"end
 if type(controller)~="number"or controller~=shared_back_controller(state.controller or 0)then return nil,"controller_mismatch"end
 if private_party_count(controller)~=1 then return nil,"private_party_count_not_one"end
 if private_party_host()~=true then return nil,"native_host_not_true"end
 local b=state.rs1PollParty(controller)
 if not b or not b.retail then return nil,"retail_bridge_unavailable"end
 if b.pending or squads_rs1.intent then return nil,"join_pending"end
 if b.context~=0 or b.start_mask~=7 then return nil,"native_context_or_start_mask"end
 local n=b.members
 if type(n)~="number"or n<2 or n>4 or n%1~=0 or b.target_members~=n or b.connected~=n then return nil,"native_roster_not_shared"end
 return b
end
local function preserve_shared_back(controller)
 controller=shared_back_controller(controller)
 if shared_back_route and not shared_back_route.allowed then return false end
 local ok,b,reason=pcall(shared_back_party,controller)
 if not ok or not b then shared_back_declined(ok and reason or "party_query_error",controller);return false end
 
 if shared_back_route then shared_back_route.navigate=true
 else home(controller)end
 return true
end


function ready_handoff.capture(attempt)
 local b=squad_bridge()
 if not b or not b.retail or b.pending or squads_rs1.intent or b.members<=1 or b.ready_members~=b.members or private_party_host()~=true then return end
 local id=selected(attempt.controller)
 local record=data.records[id]
 if not record or type(record.maxparty)~="number"or record.maxparty<b.members then return end
 attempt.approval={id=id,controller=attempt.controller,members=b.members,sequence=b.sequence,context=b.context,epoch=b.epoch,phase=ready_handoff.phase}
 
end
function ready_handoff.valid(request,b)
 local a=request.rs3_handoff
 return a and a.consumed==true and a.phase==ready_handoff.phase and a.id==request.id and a.controller==request.controller and a.members==b.members and a.members==b.ready_members and a.sequence==b.sequence and a.context==b.context and(b.epoch==a.epoch or b.epoch==0)
end
function ready_handoff.install()
 if type((slot(lobby,"0x121d7f0f0eb95be7")))~="function"or type((slot(lobby,"0xda70fde57a75b032")))~="function"or type((slot(lobby,"0xfe7a3816525739ef")))~="function"then
  return
 end
 hook(lobby,"0x121d7f0f0eb95be7",function(original)
  return function(...)
   local result=pack(original(...))
   
   local attempt=ready_handoff.attempt
   if attempt then
    if result.n==1 and result[1]==true then pcall(ready_handoff.capture,attempt)
    else attempt.approval=nil;if attempt.request then attempt.request.rs3_handoff=nil end end
   end
   return unpack(result,1,result.n)
  end
 end)
 hook(lobby,"0xda70fde57a75b032",function(original)
  return function(enabled,...)
   local result=pack(original(enabled,...))
   
   if not(result.n>0 and result[1]==false)then
    if enabled==true then ready_handoff.phase=ready_handoff.phase+1
    elseif enabled==false then
     local attempt=ready_handoff.attempt
     local request=attempt and attempt.request
     if request and state.request==request and attempt.approval and request.rs3_handoff==attempt.approval then
      request.rs3_handoff.consumed=true
      
     end
    end
   end
   return unpack(result,1,result.n)
  end
 end)
 
 
 
end
local function squad_request_ready_original(request,step)
 if not request.rs1_shared_party then return true end
 local b=state.rs1PollParty(request.controller)
 request.rp2_observed_snapshot=b;
 request.rp2_observed_host=nil;request.rp2_observed_current=nil
 if not b then squads_rs1.status="waiting_for_native_party_state";return false end
 local host=private_party_host()
 request.rp2_observed_host=host
 if host==false then
  cancel("party leadership changed",false,true,true)
  return false
 end
 if host~=true or b.pending then squads_rs1.status="waiting_for_party_leader";return false end
 if b.retail and request.rs2_expected_members and b.members<request.rs2_expected_members then
  cancel("party membership changed",false,true,true);return false
 end
 if step and step.kind=="start"then
  if b.retail then
   local expected=math.max(request.rs2_expected_members or 0,b.members)
   if b.target_members<expected then squads_rs1.status="waiting_for_native_party_transfer";return false end
   if b.ready_members<expected then squads_rs1.status="waiting_for_retail_party_members";return false end
   if b.start_mask~=7 then squads_rs1.status="waiting_for_native_lobby_start";return false end
   if not b.armed and not b.all_ready and ready_handoff.valid(request,b)then
    local phase=native_party_boolean("0xfe7a3816525739ef","retail_ready_phase")
    if phase~=false then squads_rs1.status="waiting_for_current_retail_ready_phase";return false end
    
    return true
   end
   if not b.all_ready then
    squads_rs1.status=b.armed and"waiting_for_retail_ready_acknowledgements"or"waiting_for_retail_ready_initialization";return false
   end
   local current=native_party_boolean("0x121d7f0f0eb95be7","retail_start_readiness")
   request.rp2_observed_current=current
   if current~=true then squads_rs1.status="waiting_for_current_retail_readiness";return false end
  elseif b.ready<b.members then squads_rs1.status="waiting_for_party_members";return false end
 end
 return true
end
local function squad_request_ready(request,step)
 local ready=squad_request_ready_original(request,step)
 if request.rs1_shared_party and state.request==request then end
 return ready
end
local function observe_frontend(value)
    if type(value)~="boolean" then return end
    if value==false and party_recovery.last_frontend~=false then
        party_recovery.attempted=false;party_recovery.attempted_generation=nil
        party_recovery.reset_reason="observed_match_return_unconditional"
    end
    party_recovery.last_frontend=value
end
local function party_message(status) party_recovery.status=status end
local function ensure_private_party(controller,reason)
    if type(controller)~="number" or controller~=controller or controller==math.huge or controller<0 or controller%1~=0 then return end
    local ok,in_frontend=pcall(frontend)
    if not ok or type(in_frontend)~="boolean" then return end
    observe_frontend(in_frontend)
    if not in_frontend then return end
    if state.request then
        if state.phase=="loading" then cancel("returned to original Zombies frontend",false,false)
        else return end
    end
    local active,native_status,native_returns=private_party_state()
    local host,host_status,host_returns=private_party_host()
    local count,count_status=private_party_count(controller)
    party_recovery.private_party_query_ok=active~=nil;party_recovery.private_party_query_value=active
    party_recovery.private_party_query_returns=native_returns;party_recovery.native_status=native_status
    party_recovery.host_before=host;party_recovery.host_status=host_status;party_recovery.host_returns=host_returns
    party_recovery.count_status=count_status;party_recovery.observed_count=count
    local bridge=state.rs1PollParty(controller)
    if squads_rs1.rp2 and not bridge then party_message("RP2_native_state_unavailable");return end
    if bridge and(bridge.pending or squads_rs1.intent)then
        party_message("RS1_join_preserved");return
    end
    if bridge and bridge.members>1 then
        party_message("RS1_shared_party_preserved");return
    end
    local recovery_reason=party_recovery.reset_reason
    if party_recovery.attempted then
        party_message("recovery_already_attempted",reason,count,nil,active,nil,host,nil);return
    end
    party_recovery.attempted=true;party_recovery.attempted_generation=state.generation
    party_recovery.recovery_reason=recovery_reason
    
    
    
    local queued=slot(engine,"Exec")
    local result=pack(pcall(type(queued)=="function" and queued or exec,"xstartprivateparty",controller))
    party_recovery.command_ok=result[1];party_recovery.command_returns=result.n-1;party_recovery.command_value=result[2]
    local native_after,after_status,after_returns=private_party_state()
    local host_after,host_after_status,host_after_returns=private_party_host()
    local after,read_status=private_party_count(controller)
    party_recovery.native_after=native_after;party_recovery.native_after_status=after_status
    party_recovery.native_after_returns=after_returns;party_recovery.observed_count=after
    party_recovery.host_after=host_after;party_recovery.host_after_status=host_after_status
    party_recovery.host_after_returns=host_after_returns;party_recovery.readback_status=read_status
    local status
    if not result[1] then party_recovery.command_error=result[2];status="command_error"
    elseif result.n>1 and result[2]==false then status="command_returned_false"
    else status="reset_command_returned" end
    party_message(status,reason..":"..recovery_reason,count,after,active,native_after,host,host_after)
end
local function recover_private_party(controller,reason)
    if party_recovery.busy then return end
    party_recovery.busy=true
    local ok,why=pcall(ensure_private_party,controller,reason)
    party_recovery.busy=false
    if not ok then
        party_message("recovery_error",reason,nil,nil,nil,nil,nil,nil);party_recovery.error=why
    end
end
local party_map_filter_wrapped,frontend_monitor_wrapped,attach
refresh_party_recovery=function()
    if not frontend_monitor_wrapped then
        hook(engine,"InFrontend",function(original)
            return function(...)
                local result=pack(original(...));pcall(observe_frontend,result[1])
                if result[1]==true and state.request and type(attach)=="function" then pcall(attach,state.request) end
                return unpack(result,1,result.n)
            end
        end)
        frontend_monitor_wrapped=slot(engine,"InFrontend")
    end
    local ok,value=pcall(frontend);if ok then pcall(observe_frontend,value) end
    local key="0x0abec982187838da"
    local current=slot(lobby,key)
    if type(current)=="function" and current~=party_map_filter_wrapped then
        hook(lobby,key,function(original)
            return function(...)
                local args=pack(...);recover_private_party(args[1],"original_Zombies_map_list")
                pcall(refresh_squad_catalogue,args[1])
                return original(unpack(args,1,args.n))
            end
        end)
        party_map_filter_wrapped=slot(lobby,key)
    end
end
local function fail(request,reason)
    if state.request~=request then return end
    cancel(reason,true,true)
end
local function submit(request,command)
    if state.request~=request then return end
    if command=="xpartygo"then end
    request.touched=true;exec(command,request.controller)
    if command=="xpartygo"then end
end
local function original_lobby_present()
    local in_stack=slot(flow,"IsInStack")
    if type(in_stack)=="function" then
        local ok,present=pcall(in_stack,hash(data.menus.zmpubliclobby))
        if ok and type(present)=="boolean" then return present end
    end
    if not state.host or type(root_get)~="function" then return false end
    local get=member(state.host,"getRoot") or member(state.host,"GetRoot")
    if type(get)~="function" then return false end
    local ok,root=pcall(get,state.host)
    return ok and root~=nil and root==root_get()
end
local function tick(request)
    if state.request~=request then return end
    state.elapsed=state.elapsed+100
    local in_frontend=frontend()
    if in_frontend==nil then return end
    if in_frontend==false then
        party_recovery.attempted_generation=nil;party_recovery.attempted=false
        if state.phase~="loading" then
            if request.close_frontend_on_transition and in_frontend==false then
                request.close_frontend_on_transition=false
                
                local current=type(root_get)=="function" and root_get() or nil
                if current~=nil and current==request.host then
                    local close=slot(flow,"RequestCloseAllMenus")
                    if type(close)=="function" then pcall(close) end
                end
            end
            local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
            if type(compatibility)=="table" and type(compatibility.acceptSaveLaunch)=="function" then
                pcall(compatibility.acceptSaveLaunch,request)
            end
            state.phase="loading";
            
        end
        return
    elseif state.phase=="loading" then
        cancel("returned from gameplay",false,false);return
    end
    if state.elapsed-request.started>120000 then fail(request,"The local start request did not leave the frontend. See the v6 capture for its last native request.");return end
    if request.remaining>0 then request.remaining=request.remaining-100;return end
    local step=request.steps[request.step]
    if not step then
        if not request.rp2_post_start_at or state.elapsed-request.rp2_post_start_at>=5000 then
            request.rp2_post_start_at=state.elapsed
            
        end
        return
    end
    if not squad_request_ready(request,step)then return end
    request.step=request.step+1;request.remaining=step.delay or 0
    if step.command then submit(request,step.command)
    elseif step.kind=="original_lobby" then
        if original_lobby_present() then
        else submit(request,"luiOpenMenu zmpubliclobby") end
    elseif step.kind=="gametype" then
        local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
        local kronos=type(compatibility)=="table" and compatibility.enabled==true
        if request.record.command and not kronos then submit(request,"setgametype "..request.record.command)
        elseif type(set_type)=="function" then
            local name=kronos and request.record.command or nil
            if not name then
                local get_name=member(rawget(_G,"GameType"),"GetGameTypeNameKey")
                if type(get_name)~="function" then error("original GameType.GetGameTypeNameKey unavailable") end
                name=get_name(asset_hash(request.asset))
            end
            
            local names={}
            if type(name)=="string" and name~="" then names[#names+1]=name end
            names[#names+1]=(string.gsub(request.asset,"^sat_",""));names[#names+1]=request.asset
            for _,candidate in ipairs(names) do
                pcall(set_type,candidate)
                local actual=type(read_type)=="function" and read_type()
                if kronos then
                    request.native_type_name=candidate
                    request.native_type_after_set=actual
                    request.native_type_after_set_kind=type(actual)
                end
                if actual==request.asset or actual==asset_hash(request.asset) then break end
            end
        else error("original GameType.Set unavailable for selected asset") end
    elseif step.kind=="party_map" then
        local setter=slot(dvars,"0x1e3cb005036e0c0f")
        if type(setter)~="function" then fail(request,"The original native map setter is unavailable.");return end
        local before=config_read({key="ui_mapname",kind="string"})
        setter(dvar_hash("ui_mapname"),request.record.map)
        local after=config_read({key="ui_mapname",kind="string"})
        
    elseif step.kind=="configuration" then
        if request.resume then request.written={};request.skipped={} else apply_config(request);isolate_standard_relics(request) end
    elseif step.kind=="rex_prepare" then rex_prepare(request)
    elseif step.kind=="rex_finalize" then rex_finalize(request)
    elseif step.kind=="start" then
        local map=config_read({key="ui_mapname",kind="string"})
        if map~=request.record.map then
            
            fail(request,"The selected map was not accepted by the native configuration.");return
        end
        if type(read_type)~="function" then fail(request,"Original native game-type readback is unavailable.");return end
        local actual=read_type()
        if actual~=request.asset and actual~=asset_hash(request.asset) then
            local message="The selected game type was not accepted by the native configuration."
            local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
            if type(compatibility)=="table" and compatibility.enabled==true then
                message=message.."\nMap: "..tostring(request.record.map).." | selection: "..tostring(request.id)
                    .."\nRequested asset: "..tostring(request.asset).." | setter name: "..tostring(request.native_type_name)
                    .."\nAfter setter ("..tostring(request.native_type_after_set_kind).."): "..tostring(request.native_type_after_set)
                    .."\nBefore launch ("..type(actual).."): "..tostring(actual)
            end
            fail(request,message);return
        end
        local consistent,keys=observe_config(request)
        if not consistent then fail(request,"The selected setting was not accepted by the native configuration: "..keys);return end
        if not save_connected then connect_save_transport() end
        if save_connected then
            local context=string.format('{"id":%d,"asset":"%s"}',request.id,request.asset)
            pcall(save_transport,"configure",context)
        end
        rex_verify(request)
        local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
        if type(compatibility)=="table" and compatibility.enabled and type(compatibility.prepareSaveContext)=="function" then
            local ok,accepted=pcall(compatibility.prepareSaveContext,request.record.map,request.asset,request.resume)
            if not ok or accepted~=true then
                fail(request,"Kronos save context was not accepted; the match was not started.")
                return
            end
        end
        local csm=rawget(_G,"CSM_MAYHEM_P1")
        if type(csm)=="table" and type(request.record)=="table" and request.record.blackwater_lake==true and request.asset=="zm_rb_r_mod_survival" then
            -- Blackwater Lake 0.2.110: Kronos accepts Blackwater's real Cursed rows. With the
            -- Mayhem relic chosen, a fresh Blackwater Cursed start arms it with the actual lake row
            -- (same map, POI and party size); without the relic, or on a resume, it stays disarmed.
            -- 0.2.111: one "k1 bwl csm" line in poi_reg.log records the relic reading and Kronos's answer.
            local bwl_proxy=({[1000000202]=1000000202,[1000000203]=1000000203})[request.id]
            local bwl_relic=slot(rawget(_G,"ZMRELIC"),"0xd2720f9b536bb057")
            local bwl_ok,bwl_chosen=false,nil
            if type(bwl_relic)=="function" then bwl_ok,bwl_chosen=pcall(bwl_relic,request.controller) end
            -- The relic menu's own selection model, read with globals and slot only (no new launcher upvalues).
            local bwl_choice="none"
            local bwl_ds=slot(slot(slot(rawget(_G,"_DataSources"),"0x08f73707b5922e00"),"0xfa1ec14daf3b21ad"),"0x2c0fbd4577b10b54")
            if bwl_ds~=nil then
                local cok,cvalue=pcall(function() return bwl_ds:GetValue(request.controller) end)
                bwl_choice=cok and tostring(cvalue) or "error"
            end
            local function bwl_log(note)
                local print=rawget(_G,"DebugPrint")
                if type(print)=="function" then
                    pcall(print,"k1 bwl csm 0.2.111: id="..tostring(request.id).." proxy="..tostring(bwl_proxy)..
                        " relic_fn="..type(bwl_relic).." relic_ok="..tostring(bwl_ok).." chosen="..tostring(bwl_chosen)..
                        " choice="..bwl_choice.." resume="..tostring(request.resume and true or false).." "..note)
                end
            end
            if bwl_proxy and not request.resume and bwl_ok and bwl_chosen==true and type(csm.prepare)=="function" then
                local ok,accepted,message=pcall(csm.prepare,{id=bwl_proxy,controller=request.controller,asset=request.asset,
                    record={map=request.record.map,poi="zone_lakefront",maxparty=request.record.maxparty}})
                local note="prepare ok="..tostring(ok).." accepted="..tostring(accepted).." message="..tostring(message)
                local presentation=csm.presentation
                if type(presentation)=="table" and type(presentation.active)=="function" then
                    local aok,active=pcall(presentation.active,false)
                    note=note.." active="..tostring(aok and active)
                end
                bwl_log(note)
                if not ok or accepted~=true then
                    if type(csm.reset)=="function" then pcall(csm.reset) end
                    fail(request,type(message)=="string" and message or "Cursed Survival Mayhem handoff failed.")
                    return
                end
            else
                bwl_log("reset")
                if type(csm.reset)=="function" then pcall(csm.reset) end
            end
        elseif type(csm)=="table" and type(csm.prepare)=="function" then
            local ok,accepted,message=pcall(csm.prepare,request)
            if not ok or accepted~=true then
                fail(request,type(message)=="string" and message or "Cursed Survival Mayhem handoff failed.")
                return
            end
        end
        state.phase="starting"
        request.close_frontend_on_transition=true
        submit(request,"xpartygo")
    end
end
attach=function(request,menu)
    if state.request~=request then return end
    local host=menu or (type(root_get)=="function" and root_get()) or state.host
    local root=member(host,"getRoot") or member(host,"GetRoot")
    if type(root)=="function" then
        local ok,value=pcall(root,host);if ok and value~=nil then host=value end
    end
    local create=member(host,"CreateEventTimer")
    if type(create)~="function" or type(member(host,"RemoveEventTimer"))~="function" then return end
    if request.host==host then return end
    detach(request);request.host=host;state.lease=state.lease+1
    local lease=state.lease
    create(host,timer_event,100,{immediate=false,callbackFunc=function()
        if state.request~=request or state.lease~=lease then return end
        local ok,reason=pcall(tick,request)
        if not ok then fail(request,"Local request error: "..tostring(reason)) end
    end})
end
local function begin(controller,id,resume)
    if ready_handoff.attempt then
        local party=state.rs1PollParty(controller)
        if party and party.retail and party.context==0 and party.setup==0 and party.start_mask==6 and not party.pending and not squads_rs1.intent and party.members>1 then
            
            return
        end
    end
    if state.request then return end
    
    local record=data.records[id]
    if not record then
        
        if type(popup)=="function" then popup(controller,"Local Zombies","This selection is absent from the recovered catalogue.") end
        return
    end
    if record.local_record and not catalogue.by_id[id] then return end
    if type(controller)~="number" or frontend()~=true or selected(controller)~=id then return end
    local asset=record.asset;local effective=record
    local mrp
    if resume then
        if type(resume)~="table" or resume.id~=id or resume.map~=record.map then return end
        effective=copy(record);effective.command=resume.command;asset=resume.asset
        if record.source_gametype=="p_gametype_sat_rb_r_mod" then mrp=asset=="zm_rb_rh_mod" end
    elseif record.source_gametype=="p_gametype_sat_rb_r_mod" then
        mrp=validated_mrp(controller)
        if mrp==nil then
            
            if type(popup)=="function" then popup(controller,"Local Zombies","Confirm the original Cursed/relic selection before Start.") end
            return
        end
        if mrp then effective=copy(record);effective.command="zm_rb_rh_mod";asset="zm_rb_rh_mod" end
    end
    local accepted,shared,expected_members=squad_start_state(controller,effective)
    if not accepted then return end
    restore_config(controller)
    local request={id=id,controller=controller,record=effective,asset=asset,mrp=mrp,resume=resume,rs1_shared_party=shared,rs2_expected_members=expected_members,
        step=1,remaining=0,started=state.elapsed,steps={
            {command="xstartprivateparty",delay=1500},
            {command="xstartlobby_patched",delay=4000},
            {kind="original_lobby",delay=1500},
            {command="ui_mapname "..record.map,delay=1500},
            {kind="gametype",delay=1500},
            {kind="configuration",delay=500},
            {kind="start"}}}
    if shared then
        request.steps[1]={delay=request.steps[1].delay}
        if not resume then
            request.steps[4],request.steps[5]=request.steps[5],request.steps[4]
            request.steps[5]={kind="party_map",delay=request.steps[5].delay}
        end
    end
    if not resume and rex_scope(request) then
        table.insert(request.steps,#request.steps,{kind="rex_prepare",delay=100})
        table.insert(request.steps,#request.steps,{kind="rex_finalize",delay=100})
    end
    local attempt=ready_handoff.attempt
    local approval=attempt and attempt.approval
    if shared and approval and approval.id==id and approval.controller==controller and approval.members==expected_members then
        request.rs3_handoff=approval;attempt.request=request
    end
    state.request=request;state.generation=state.generation+1;state.phase="preparing"
    
    attach(request,state.host)
    if resume then return request end
end
local party_limit_entry,party_limit_rows
local party_host_wraps={}
local function wrap_party_host(owner,name)
    local original,key=slot(owner,name)
    if type(original)~="function" or party_host_wraps[original] then return end
    local wrapped=function(...)
        if original(...) then return true end
        return config_read({key="kronos_party_host",kind="string"})=="1"
    end
    party_host_wraps[wrapped]=true
    rawset(owner,key,wrapped)
end
local function refresh_party_limit()
    wrap_party_host(rawget(_G,"Lobby"),"0x96957722ef74f5d2")
    wrap_party_host(rawget(_G,"Social"),"0x85038770483500ce")
    local utils=rawget(_G,"PlaylistUtils")
    local rows,key=slot(utils,"0x24e6190b80b69d7f")
    if type(rows)=="function" and rows~=party_limit_rows then
        party_limit_rows=function() return function() return false end end
        rawset(utils,key,party_limit_rows)
    end
    local owner=rawget(_G,"Lobby")
    local ids=type(owner)=="table" and rawget(owner,"GameModeAndLobbyStartButtonConditions")
    local entries=type(owner)=="table" and rawget(owner,"GameModeAndLobbyStartButtonConditionsData")
    local id=type(ids)=="table" and ids.PARTY_TOO_LARGE
    local entry=type(entries)=="table" and id~=nil and entries[id]
    if type(entry)~="table" or entry==party_limit_entry then return end
    entry.IsDisabled=function() return false end
    entry.Subscription=function() end
    party_limit_entry=entry
end
local ok,reason=pcall(function()
ready_handoff.install()
local gum_wrapped={}
refresh_profile_initializers=function()
    local owner=rawget(_G,"GOBBLEGUM")
    local original=slot(owner,"0xf5d2afc57ab57213")
    if type(original)~="function" or gum_wrapped[owner]==original then return end
    hook(owner,"0xf5d2afc57ab57213",function(fn)
        local wrapped=function(controller,...)
            local group=slot(rawget(_G,"LOADOUT"),"0x1f3d4120102d8bb3")
            local io=slot(rawget(_G,"PlayerData"),"0x08b73907b55c4d71")
            if type(group)=="function" and type(io)=="function" then
                local selected_group=group()
                if io(controller,selected_group)==nil then
                    return false
                end
            end
            return fn(controller,...)
        end
        gum_wrapped[owner]=wrapped
        return wrapped
    end)
end
refresh_profile_initializers()
local battlepass_wrapped={}
local function refresh_battlepass_profile()
    local owner=rawget(_G,"PAGEDBATTLEPASS")
    local original=slot(owner,"0xcd17c64795fd18d9")
    if type(original)~="function" or battlepass_wrapped[owner]==original then return end
    hook(owner,"0xcd17c64795fd18d9",function(fn)
        local wrapped=function(controller,...)
            local get=slot(rawget(_G,"PLAYER_DATA"),"0xa9ab47a1cad21257")
            if type(get)=="function" then
                if get(controller)==nil then
                    return
                end
            end
            return fn(controller,...)
        end
        battlepass_wrapped[owner]=wrapped
        return wrapped
    end)
end
local refresh_inventory_profile=refresh_profile_initializers
refresh_profile_initializers=function(...)
    refresh_inventory_profile(...)
    refresh_battlepass_profile()
end
refresh_battlepass_profile()
    refresh_mrp_filter()
    refresh_party_recovery()
    local catalogue_installed=install_catalogue()
    if not catalogue_installed and type((slot(playlist,"0x2d93afc74cfe7ce0")))=="function" then
        hook(playlist,"0x2d93afc74cfe7ce0",function(original)
            return function(...)
                local result=pack(original(...));result[1]=project_mrp_maps(result[1]);return unpack(result,1,result.n)
            end
        end)
    end
    hook(playlist,"DoPlaylistId",function(original)
        return function(id,...)
            if hidden_ids[id] then return end
            local start_route=state.scope~=nil or state.menu=="confirmation" or state.menu=="start_lobby"
            if start_route and (state.context or data.records[id]) then
                begin(state.scope or state.controller or 0,id)
                return
            end
            if data.records[id] and data.records[id].local_record then
                return
            end
            return original(id,...)
        end
    end)
    for _,input in ipairs({{rawget(_G,"ZM"),"0x4e33201f7d71283a"},{lobby,"0x315b13c5fed7234e"}}) do
        hook(input[1],input[2],function(original)
            return function(controller,...)
                if state.request then return end
                local id=selected(controller);local record=data.records[id]
                if record and record.local_record and not catalogue.by_id[id] then
                    if type(popup)=="function" then popup(controller,"Local Zombies","The map catalogue changed. Return to map selection before starting.") end
                    return
                end
                local previous=state.scope;state.scope=controller;state.controller=controller
                local previous_attempt=ready_handoff.attempt
                ready_handoff.attempt={controller=controller}
                
                local result=pack(pcall(original,controller,...));state.scope=previous
                
                ready_handoff.attempt=previous_attempt
                if not result[1] then cancel("original Start error",false,false);error(result[2],0) end
                return unpack(result,2,result.n)
            end
        end)
    end
    hook(builder,"BuildRegisteredType",function(original)
        return function(name,...)
            refresh_menu_filter()
            refresh_profile_initializers()
            pcall(refresh_party_limit)
            if is(name,"zmmainmenu") then recover_private_party(state.controller,"original_Zombies_root_construction") end
            local args=pack(...)
            local result=pack(original(name,unpack(args,1,args.n)))
            refresh_menu_filter()
            refresh_profile_initializers(is(name,"zmmainmenu") and result[1] or nil)
            if is(name,"zmpubliclobby") then state.host=result[1] end
            if state.request and frontend()==true then attach(state.request,result[1]) end
            return unpack(result,1,result.n)
        end
    end)
    hook(flow,"RequestAddMenu",function(original)
        return function(name,parent,controller,...)
            for _,social in ipairs({"0x5316484ab074ce4b","0x46f87d8d09d8d838","0x73dca256a602d8d4",
                "0x2412b99f186f76cb","0xc23d8ae2a3707580","0x2a94569bff026cb0","0xdbbbb37bc3c1a2cf"}) do
                if is(name,social) then return original(name,parent,controller,...) end
            end
            if state.request then
                state.context=true;state.menu="start_lobby"
            elseif is(name,"zmmainmenu") then
                cancel("Zombies root entered",false,false);state.context=true;state.menu="other"
                catalogue.selected=nil
            elseif is(name,"zmpubliclobby") then
                state.context=true
                if state.menu=="confirmation" or state.scope~=nil or state.request then state.menu="start_lobby" end
            else
                state.menu=is(name,"zmloadoutconfirmation") and "confirmation" or "other"
                if not is(name,"zmmatchselection") and not is(name,"zmmapselection")
                    and not is(name,"zmmatchsettings") and not is(name,"zmloadoutconfirmation")
                    and not is(name,"relicselectmenu") then state.context=false end
            end
            if controller~=nil then state.controller=controller end
            if is(name,"zmmainmenu") then recover_private_party(controller,"original_Zombies_root_navigation") end
            return original(name,parent,controller,...)
        end
    end)
    hook(lobby,"0x922bb4eaa6147f67",function(original)
        return function(...)
            if state.request then cancel("original Back/Cancel",true,false);return end
            local controller=(...)
            if controller==nil then controller=state.controller or 0 end
            controller=shared_back_controller(controller)
            local ok,b,reason=pcall(shared_back_party,controller)
            if not ok or not b then shared_back_declined(ok and reason or "party_query_error",controller)end
            local previous=shared_back_route
            local route={controller=controller,allowed=ok and b~=nil}
            shared_back_route=route
            if not route.allowed then squads_rs1.intent=nil end
            local result=pack(pcall(original,...))
            shared_back_route=previous
            if not result[1]then error(result[2],0)end
            if route.navigate then home(controller)end
            return unpack(result,2,result.n)
        end
    end)
    local back_exec_keys={}
    for _,name in ipairs({"ExecNow","Exec","0xeb81a5136c5503e4"}) do
        local original,key=slot(engine,name)
        if type(original)=="function"and not back_exec_keys[key]then
            back_exec_keys[key]=true
            hook(engine,name,function(original)
                return function(command,...)
                    if (state.context or state.scope~=nil) and command=="uploadstats" then
                        return
                    end
                    local back="xstopmatchmaking Lobby.@LeavePublicLobby"
                    if type(command)=="string" and string.sub(command,1,#back)==back then
                        if state.request then cancel("original Back command",true,false);return end
                        local suffix=string.sub(command,#back+1,#back+1)
                        if suffix==""or suffix=="."or string.match(suffix,"%s")then
                            local controller=shared_back_route and shared_back_route.controller or (...)
                            if controller==nil then controller=state.controller or 0 end
                            if preserve_shared_back(controller)then return end
                        end
                    end
                    return original(command,...)
                end
            end)
        end
    end
end)
if not ok then
    for i=#changes,1,-1 do local c=changes[i];pcall(rawset,c.owner,c.key,c.original) end
    return
end

if catalogue.publish then catalogue.publish("frontEnd.playlists.category") end
state.catalogue=catalogue
function state.resolveSavedGame(map,gametype)
    if type(map)~="string" or type(gametype)~="string" then return nil end
    local aliases={zm_rb="sat_zm_rb",sat_zm_rb="sat_zm_rb",zm_guided="sat_zm_guided",sat_zm_guided="sat_zm_guided",
        zm_rb_r_mod="zm_rb_r_mod",zm_rb_rh_mod="zm_rb_rh_mod",zm_rb_echo="zm_rb_echo",
        zm_rb_survival="sat_zm_rb_survival",sat_zm_rb_survival="sat_zm_rb_survival",
        zm_rb_r_mod_survival="zm_rb_r_mod_survival",zm_rb_startroom="sat_zm_rb_startroom",
        sat_zm_rb_startroom="sat_zm_rb_startroom",ztron="zm_ztron",zm_ztron="zm_ztron",
        zm_ztron4="zm_ztron",ztron4="zm_ztron",doa="zm_ztron",zm_doa="zm_ztron",doa4="zm_ztron",zm_doa4="zm_ztron"}
    local asset=aliases[gametype]
    if not asset then return nil end
    local best,best_id
    for id,record in pairs(data.records) do
        local record_asset=asset=="zm_rb_rh_mod" and "zm_rb_r_mod" or asset
        if record.map==map and record.asset==record_asset and not hidden_ids[id]
            and (not record.local_record or catalogue.by_id[id]) then
            if not best or record.maxparty>best.maxparty or (record.maxparty==best.maxparty and id<best_id) then
                best=record;best_id=id
            end
        end
    end
    if not best then return nil end
    local labels={sat_zm_rb="Standard",sat_zm_guided="Directed",zm_rb_r_mod="Cursed",zm_rb_rh_mod="Mr. Peeks Mayhem",
        sat_zm_rb_survival="Survival",zm_rb_r_mod_survival="Cursed Survival",zm_rb_echo="Rogue Run",
        sat_zm_rb_startroom="Starting Room",zm_ztron="Dead Ops Arcade 4"}
    local command=asset=="zm_rb_rh_mod" and "zm_rb_rh_mod" or best.command
    return {id=best_id,map=map,asset=asset,command=command,savedgt=gametype,label=labels[asset] or gametype,
        mrp=asset=="zm_rb_rh_mod" and true or nil}
end
function state.resumeSavedGame(controller,map,gametype,beforeStart)
    local compatibility=rawget(_G,"KRONOS_RETAIL_K1")
    if not (type(compatibility)=="table" and compatibility.enabled==true) then return false,"Kronos compatibility is unavailable." end
    if state.request then return false,"A match is already being started." end
    if type(controller)~="number" or controller<0 or controller%1~=0 or frontend()~=true then return false,"The frontend controller is unavailable." end
    local saved=state.resolveSavedGame(map,gametype)
    if not saved then return false,"This saved map or game type is unavailable in the catalogue." end
    if type(compatibility.savedEntries)~="function" then return false,"The native save list is unavailable." end
    local found=false
    for _,entry in ipairs(compatibility.savedEntries()) do
        if entry.map==map and entry.gt==gametype then found=true;break end
    end
    if not found then return false,"The saved-game entry changed." end
    local ds=path(rawget(_G,"_DataSources"),"0xf71428806887f67d","0x1ccae3b6ef72f533","0xe14ec899fcdc838f")
    local set=member(ds,"SetValue")
    if type(set)~="function" then return false,"The original playlist selection source is unavailable." end
    if type(beforeStart)=="function" then beforeStart() end
    local party_set=slot(lobby,"0xbe6e03a0292da533")
    local party_data=member(lobby,"PartyUIData")
    if type(party_set)=="function" and member(party_data,"PLAYLIST_ID")~=nil then
        party_set(member(party_data,"PLAYLIST_ID"),saved.id)
    end
    set(ds,controller,saved.id)
    if selected(controller)~=saved.id then return false,"The original playlist selection did not accept the saved match." end
    local native_set=slot(playlist,"0x5276715c8f8a5887")
    if type(native_set)=="function" then native_set(saved.id) end
    state.controller=controller;state.context=true;state.menu="confirmation"
    local request=begin(controller,saved.id,saved)
    if not request or state.request~=request then return false,"The saved match could not be scheduled." end
    return true
end
rawset(_G,"LUMEN_ZM_LOCAL_START",state)
if type(rawget(_G,"BWL_CATEGORY_REFRESH"))=="function" then pcall(rawget(_G,"BWL_CATEGORY_REFRESH")) end
if type(rawget(_G,"BWL_SAVE_OWNER"))=="function" then pcall(rawget(_G,"BWL_SAVE_OWNER")) end

end)()
end
do
(function()
if rawget(_G,"RETAIL_GUEST_GG1") then return end
local C=rawget(_G,"CLUA")
local hash=type(C)=="table" and C.PushXHash or rawget(_G,"xhash")
if type(hash)~="function" then return end
local function H(s)return hash("0x"..s)end
local function member(t,name)
  if type(t)~="table" then return end
  return rawget(t,name),name
end
local S={version="GG1",owners=setmetatable({},{__mode="k"}),redirects=0}
rawset(_G,"RETAIL_GUEST_GG1",S)
local prefix={H("be991042123f73f7"),H("39cc1eaa62a04dc6"),H("d8e4dcc3a93fa75e"),H("84969a183afbee03")}
local lobby=H("f97f0e2148e5f80c")
local zombies={H("be991042123f73f7"),H("39cc1eaa62a04dc6"),H("d0193ff2a7549dd9"),H("89e9918304f5ed42")}

local function zombiesFrontend()
  local front=member(rawget(_G,"Engine"),"InFrontend")
  if type(front)~="function" then
    local e=rawget(_G,"Engine")
    front=type(e)=="table" and e[H("112586a3f4fb490e")]
  end
  if type(front)~="function" then return false end
  local ok,value=pcall(front)
  if not ok or value~=true then return false end
  local modes=rawget(_G,"GameModesUtils")
  local active=type(modes)=="table" and modes[H("589367a5b3c4aa7f")]
  if type(active)~="function" then return false end
  ok,value=pcall(active)
  if not ok or value~=true then return false end
  return true
end
local function affected(uri)
  if type(uri)~="table" then return false end
  local count=0
  for k in pairs(uri)do
    if type(k)~="number" or k%1~=0 or k<1 or k>5 then return false end
    count=count+1
  end
  if count~=4 and count~=5 then return false end
  for i=1,4 do if rawget(uri,i)~=prefix[i] then return false end end
  return count==4 or rawget(uri,5)==lobby
end
local function arm()
  local nav=rawget(_G,"MenuNavigator")
  if type(nav)~="table" or S.owners[nav] then return end
  local old,key=member(nav,"QueueURIXHash")
  if type(old)~="function" then return end
  local function queue(uri,controller,...)
    if affected(uri) and zombiesFrontend() then
      uri={zombies[1],zombies[2],zombies[3],zombies[4]}
      S.redirects=S.redirects+1
      if S.redirects<=8 then end
    end
    return old(uri,controller,...)
  end
  S.owners[nav]={original=old,wrapper=queue,key=key}
  rawset(nav,key,queue)
  
end
arm()
local original=rawget(_G,"requirexhash")
if type(original)=="function" then
  local function finish(...)
    arm()
    return ...
  end
  rawset(_G,"requirexhash",function(...)return finish(original(...))end)
end

end)()
end
