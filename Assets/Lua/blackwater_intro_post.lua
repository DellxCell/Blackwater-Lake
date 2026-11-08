-- Blackwater 0.2.125: reproduce the silent 15-second intro using five images.
-- Experimental until seen in game. The game's loading widget, movie, text,
-- timing, and other map assets remain owned by the game.
do
    if rawget(_G, "BWL_IMAGE_INTRO_125") ~= nil then return end
    local clua, engine, lui = rawget(_G,"CLUA"), rawget(_G,"Engine"), rawget(_G,"LUI")
    if type(clua)~="table" or type(clua.PushXHash)~="function" or
        type(clua.PushXHashAsset)~="function" or type(engine)~="table" or type(lui)~="table" then return end
    local state={lines=0}
    rawset(_G,"BWL_IMAGE_INTRO_125",state)
    local SCENES={
        {"blackwater_intro_01",3940,2160,100,0},
        {"blackwater_intro_02",3840,2260,0,100},
        {"blackwater_intro_03",3840,2259,0,99},
        {"blackwater_intro_04",3840,2260,0,100},
        {"blackwater_intro_05",3840,2260,0,100},
    }
    local function member(owner,name)
        if owner==nil then return nil end
        local ok,value=pcall(function() return owner[name] end)
        if ok and value~=nil then return value end
        ok,value=pcall(function() return owner[clua.PushXHash(name)] end)
        if ok then return value end
    end
    local function call(owner,name,...)
        local f=member(owner,name)
        if type(f)~="function" then error("missing "..name,0) end
        return f(owner,...)
    end
    local function log(message)
        if state.lines>=24 then return end
        state.lines=state.lines+1
        local print=rawget(_G,"DebugPrint")
        if type(print)=="function" then pcall(print,"k1 bwl intro 0.2.125: "..tostring(message)) end
    end
    local function dvar(name)
        local f=member(rawget(_G,"Dvar"),"0x254084d7ca2317bb")
        if type(f)~="function" or type(clua.PushXHashDvar)~="function" then return nil end
        local ok,value=pcall(f,clua.PushXHashDvar(name))
        if ok and type(value)=="string" then return value end
    end
    local function in_frontend()
        local f=member(engine,"InFrontend") or member(engine,"0x112586a3f4fb490e")
        if type(f)~="function" then return nil end
        local ok,value=pcall(f)
        if ok and type(value)=="boolean" then return value end
    end
    local function is_lake()
        -- Do not draw over a frontend, including another playlist's launch.
        if in_frontend()~=false then return false end
        local launcher=rawget(_G,"LUMEN_ZM_LOCAL_START")
        local request=type(launcher)=="table" and rawget(launcher,"request") or nil
        if type(request)=="table" then
            local record=rawget(request,"record")
            return type(record)=="table" and record.blackwater_lake==true
        end
        local kronos=rawget(_G,"KRONOS_RETAIL_K1")
        local resume=type(kronos)=="table" and rawget(kronos,"nativeResume") or nil
        if type(resume)=="table" then return resume.bwl_lake==true end
        return dvar("0xdddf7dca1a52e591")=="zone_lakefront" and
            (dvar("ui_mapname")=="zm_sat_firefly" or dvar("mapname")=="zm_sat_firefly")
    end
    local function screen()
        if not is_lake() then return nil end
        local class=member(lui,"LoadingScreenManager")
        local instance=member(class,"0x862bc1029dcfe464")
        if type(instance)~="function" then return nil end
        local ok,manager=pcall(instance)
        if not ok or manager==nil then return nil end
        local widget=member(manager,"_loadingScreen")
        -- Both native LoadingParallax variants expose this Bink widget.
        local video=member(widget,"0x4bb93bee689a4d0e")
        if widget~=nil and video~=nil then return widget,video end
    end
    local function clock()
        -- Same millisecond clock used by Kronos and the native game UI.
        local f=member(engine,"0x06991337ae950f99")
        if type(f)~="function" then return nil end
        local ok,value=pcall(f)
        if ok and type(value)=="number" then return value end
    end
    local function clear()
        local image=state.image
        state.image=nil;state.screen=nil;state.scene=nil
        if image~=nil then pcall(call,image,"closeTree") end
    end
    local function attach(widget,video)
        local new=member(member(lui,"UIImage"),"new")
        local register=rawget(_G,"RegisterMaterial")
        if type(new)~="function" or type(register)~="function" then error("image interface unavailable",0) end
        local materials={}
        for i,scene in ipairs(SCENES) do
            local asset=clua.PushXHashAsset(scene[1])
            if asset==nil then error("asset hash unavailable",0) end
            materials[i]=register(asset)
            if materials[i]==nil then error("material unavailable",0) end
        end
        local image=new()
        state.image=image
        call(image,"SetAnchorsAndPosition",0,0,0,0,0,0,0,0)
        pcall(call,image,"SetHandleMouse",false)
        pcall(call,image,"setFocusable",false)
        call(image,"setImage",materials[1],0)
        call(image,"SetUMin",0,0);call(image,"SetUMax",3840/3940,0)
        call(image,"SetVMin",0,0);call(image,"SetVMax",1,0)
        call(image,"SetAlpha",1,0)
        -- Native sibling order: background, Bink, then labels/hints. Inserting
        -- here covers the Bink while keeping the game's overlays above it.
        call(image,"addElementAfter",video)
        state.screen=widget;state.materials=materials;state.scene=1
        state.start=clock();state.elapsed=0;state.previous=state.start
        log("image layer attached to native loading widget; visual test pending")
    end
    local function render(waited)
        local now=clock()
        if state.start~=nil and now~=nil and now>=state.start then
            state.elapsed=now-state.start
        else
            state.elapsed=state.elapsed+waited
        end
        local t=state.elapsed%15000
        local index=math.floor(t/3000)+1
        local frame=math.min(194,math.floor((t%3000)*65/1000))
        local scene=SCENES[index]
        if state.scene~=index then
            call(state.image,"setImage",state.materials[index],0)
            state.scene=index
        end
        local x=math.floor(scene[4]*frame/194+0.5)
        local y=math.floor(scene[5]*frame/194+0.5)
        call(state.image,"SetUMin",x/scene[2],0)
        call(state.image,"SetUMax",(x+3840)/scene[2],0)
        call(state.image,"SetVMin",y/scene[3],0)
        call(state.image,"SetVMax",(y+2160)/scene[3],0)
    end
    local function tick(waited)
        local widget,video=screen()
        if state.screen~=widget then
            clear()
            if widget~=state.failedScreen then state.failedScreen=nil end
            if widget~=nil and state.failedScreen~=widget then
                local ok,err=pcall(attach,widget,video)
                if not ok then clear();state.failedScreen=widget;log("native movie retained: "..tostring(err)) end
            end
        end
        if state.image~=nil then render(waited) end
        local delay=state.image~=nil and 16 or 100
        local animation=call(state.host,"Wait",delay)
        if animation==nil then error("timer unavailable",0) end
        animation.onComplete=function()
            local ok,err=pcall(tick,delay)
            if not ok then clear();log("disabled; native movie retained: "..tostring(err)) end
        end
    end
    local ok,err=pcall(function()
        local root=member(lui,"GetRoot")
        local new=member(member(lui,"UIElement"),"new")
        if type(root)~="function" or type(new)~="function" then error("UI root unavailable",0) end
        root=root()
        if root==nil then error("UI root unavailable",0) end
        state.host=new()
        pcall(call,state.host,"SetHandleMouse",false)
        pcall(call,state.host,"setFocusable",false)
        call(root,"addElement",state.host)
        tick(0)
    end)
    if not ok then clear();log("disabled; native movie retained: "..tostring(err)) end
end
