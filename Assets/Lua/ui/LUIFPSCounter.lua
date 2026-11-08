local __ORIG = "\27\76\74\132\24\114\0\2\6\0\5\0\12\12\6\3\55\2\0\0\60\2\1\2\60\2\2\2\60\2\3\2\18\4\0\0\18\5\1\0\69\2\3\1\18\4\0\0\60\2\4\0\18\5\1\0\69\2\3\1\78\0\1\0\21\83\101\116\117\112\70\80\83\67\111\117\110\116\101\114\10\105\110\105\116\11\115\117\112\101\114\18\85\73\70\80\83\67\111\117\110\116\101\114\9\76\85\73\1\1\1\1\1\1\1\2\2\2\2\3\146\1\3\0\4\0\8\0\16\16\0\11\55\0\0\0\55\1\0\0\60\1\2\1\55\3\0\0\60\3\3\3\69\1\2\2\64\1\1\0\55\0\0\0\60\0\1\0\52\1\5\0\64\1\4\0\55\0\0\0\60\0\1\0\39\1\7\0\64\1\6\0\78\0\1\0\19\76\85\73\70\80\83\67\111\117\110\116\101\114\8\105\100\0\10\105\110\105\116\15\85\73\69\108\101\109\101\110\116\11\67\108\97\115\115\18\85\73\70\80\83\67\111\117\110\116\101\114\9\76\85\73\3\3\3\3\3\3\3\6\6\9\6\11\11\11\11\11\0"
local __ARGS = {...}
do
local function L(s) end
local function uleb(n) local t = {} repeat local b = n % 128; n = math.floor(n / 128); if n > 0 then b = b + 128 end; t[#t+1] = string.char(b) until n == 0; return table.concat(t) end
local HC = {}
local function H(hex, kind)
  kind = kind or 0
  local ck = hex .. ":" .. kind
  if HC[ck] then return HC[ck] end
  local h = hex:gsub("^0*", ""); h = string.rep("0", 16 - #h) .. h
  local b8 = {}
  for i = 8, 1, -1 do b8[#b8+1] = string.char(tonumber(h:sub(i*2-1, i*2), 16)) end
  local kgc = string.char(4, kind) .. table.concat(b8)
  local bc = string.char(0x28, 0, 0, 0) .. string.char(0x4d, 0, 2, 0)
  local body = string.char(0, 0, 2, 0) .. uleb(1) .. uleb(0) .. uleb(2) .. bc .. kgc
  local chunk = string.char(27) .. "LJ" .. string.char(0x84) .. uleb(0x1a) .. uleb(#body) .. body .. string.char(0)
  local f = assert(load(chunk))
  HC[ck] = f()
  return HC[ck]
end
local function HREF(kind)
  local bc = string.char(0x28, 0, 0, 0) .. string.char(0x4d, 0, 2, 0)
  local body = string.char(0, 0, 2, 0) .. uleb(1) .. uleb(0) .. uleb(2) .. bc .. string.char(4, 0x80 + kind)
  local chunk = string.char(27) .. "LJ" .. string.char(0x84) .. uleb(0x1a) .. uleb(#body) .. body .. string.char(0)
  return assert(load(chunk))()
end
local EXEC = "eb81a5136c5503e4"
local CTRL = 0
local function exec(cmd)
  L("exec(" .. tostring(CTRL) .. ") " .. cmd)
  pcall(DebugPrint, "k1 kronos exec: " .. cmd)
  local ok, e = pcall(function()
    local request = KRONOS_RETAIL_K1.nativeResume
    if request and request.hudRepair and cmd == "xstartprivateparty;xstartlobby_patched" then
      if Engine[H(EXEC)]("xstartprivateparty", CTRL) == false then error("Private party setup was rejected.") end
      return Engine[H(EXEC)]("xstartlobby_patched", CTRL)
    end
    return Engine[H(EXEC)](cmd, CTRL)
  end)
  if not ok then L("exec err " .. tostring(e)) end
end

local DV_MAP, DV_GT, DV_SET, DV_GET = "ef237da69bb64ef6", "e65e9a96eb2ff62b", "1e3cb005036e0c0f", "254084d7ca2317bb"
local function setDvar(hx, v)
  local ok, e = pcall(function() Dvar[H(DV_SET)](H(hx, 1), v) end)
  if not ok then L("setDvar err " .. tostring(e)) end
end
local function getDvar(hx)
  local ok, v = pcall(function() return Dvar[H(DV_GET)](H(hx, 1)) end)
  return ok and tostring(v) or ("err " .. tostring(v))
end
_G.KRONOS_RETAIL_K1 = rawget(_G, "KRONOS_RETAIL_K1") or {}
KRONOS_RETAIL_K1.enabled = true
do
local stability = { version = "R1", operatorBusy = false }
KRONOS_RETAIL_K1.stability = stability
function stability.frontendIdle()
  local E = rawget(_G, "Engine")
  local query = type(E) == "table" and E[H("112586a3f4fb490e")]
  if type(query) ~= "function" then return false end
  local ok, value = pcall(query)
  if not ok or value ~= true then return false end
  local start = rawget(_G, "LUMEN_ZM_LOCAL_START")
  if type(start) == "table" and start.request ~= nil then return false end
  return getDvar("a8c1223b05ea8444") ~= "0"
end
function stability.season()
  local E = rawget(_G, "Engine")
  local query = type(E) == "table" and E[H("112586a3f4fb490e")]
  if type(query) ~= "function" then return end
  local ok, frontend = pcall(query)
  if not ok or frontend ~= true then return end
  local D = rawget(_G, "Dvar")
  if type(D) ~= "table" then return end
  local setInt, setFloat, setBool = D[H("f2414681ecab880f")], D[H("d14b6102841ab394")], D[H("78ea06eedb58d872")]
  local getInt, getFloat, getBool = D[H("622eaab59aa27e9b")], D[H("2edcfc612b39e0c0")], D[H("c9e5be3b4bba4e0e")]
  stability.seasonApplied = false
  if type(setInt) ~= "function" or type(setFloat) ~= "function" or type(setBool) ~= "function"
    or type(getInt) ~= "function" or type(getFloat) ~= "function" or type(getBool) ~= "function" then return end
  local current, precise, store = H("71ef9b867531fea1", 1), H("c804bf7eae3d0887", 1), H("575967277da75beb", 1)
  local readInt, intValue = pcall(getInt, current)
  local readFloat, floatValue = pcall(getFloat, precise)
  local readBool, boolValue = pcall(getBool, store)
  if readInt and intValue == 7 and readFloat and floatValue == 7 and readBool and boolValue == true then
    stability.seasonApplied = true
    return
  end
  if not readInt or intValue ~= 7 then pcall(setInt, current, 7) end
  if not readFloat or floatValue ~= 7 then pcall(setFloat, precise, 7) end
  if not readBool or boolValue ~= true then pcall(setBool, store, true) end
  readInt, intValue = pcall(getInt, current)
  readFloat, floatValue = pcall(getFloat, precise)
  readBool, boolValue = pcall(getBool, store)
  stability.seasonApplied = readInt and intValue == 7 and readFloat and floatValue == 7 and readBool and boolValue == true
end
local noticeWrapped = setmetatable({}, { __mode = "k" })
local function noticeStatus(value) stability.noticeStatus = value end
function stability.entryNotice()
  local M = rawget(_G, "MenuUtils")
  local key = H("491f32f6432696e1")
  local original = type(M) == "table" and M[key]
  if type(original) ~= "function" then noticeStatus("waiting_for_original_popup_handler"); return end
  if noticeWrapped[original] then return end
  local busy = false
  local wrapper = function(...)
    local menu, controller, action, ref = ...
    if busy or type(action) ~= "function" then return end
    busy = true
    noticeStatus("Mode_entry_without_popup")
    local ok, err = pcall(action, menu, controller, { ref = ref })
    busy = false
    if not ok then error(err, 0) end
    return
  end
  noticeWrapped[wrapper] = true
  M[key] = wrapper
  noticeStatus("popup_handler_installed")
end
local previewWrapped = setmetatable({}, { __mode = "k" })
function stability.weaponPreview()
  local W = rawget(_G, "WEAPON_OFFSET")
  local key = H("68a890d13b5c3f5a")
  local original = type(W) == "table" and W[key]
  if type(original) ~= "function" or previewWrapped[original] then return end
  local inspect = rawget(_G, "debug") and debug.getinfo
  if type(inspect) ~= "function" then return end
  local ok, info = pcall(inspect, original, "S")
  if not ok or type(info) ~= "table" or type(info.source) ~= "string"
    or not info.source:lower():find("66739232c67d3b71", 1, true)
    or info.linedefined ~= 328 or info.lastlinedefined ~= 337 then return end
  local stateKey, vectorKey = H("19b8f5ad1f7ab671"), H("c57292a7d6643b4e")
  local offsetKey = H("0268b0f8129435ca")
  local originKey, anglesKey, rotationKey = H("b9eae4fe785a14cf"), H("02ee4f6156933171"), H("f2f330cebcb24df9")
  local setOrigin, setAngles, setRotation = H("e8b8a4e0355df0c0"), H("8f17a7b95cfab6e4"), H("9d45c6a2fd89fddc")
  local wrapper = function(weapon, controller, data)
    if not KRONOS_RETAIL_K1.enabled then return original(weapon, controller, data) end
    local state = data or WEAPON_OFFSET[stateKey](weapon)
    local offset = state[offsetKey]
    local x, y, z = WEAPON_OFFSET[vectorKey](offset[originKey], controller)
    local ax, ay, az = WEAPON_OFFSET[vectorKey](offset[anglesKey], controller)
    local rx, ry, rz = WEAPON_OFFSET[vectorKey](offset[rotationKey], controller)
    if x == nil or y == nil or z == nil or ax == nil or ay == nil or az == nil
      or rx == nil or ry == nil or rz == nil then return end
    ClientWeapon[setOrigin](weapon, x, y, z)
    ClientWeapon[setAngles](weapon, ax, ay, az)
    ClientWeapon[setRotation](weapon, rx, ry, rz)
  end
  previewWrapped[wrapper] = true
  W[key] = wrapper
end
local historyWrapped = setmetatable({}, { __mode = "k" })
function stability.historyCondition()
  stability.entryNotice()
  stability.weaponPreview()
  local C = rawget(_G, "CONDITIONS")
  local key = H("01240bd280c9182f")
  local original = type(C) == "table" and C[key]
  if type(original) ~= "function" or historyWrapped[original] then return end
  local function finish(ok, ...)
    if ok then return ... end
    local err = ...
    local missing = type(err) == "string" and
      (err == "#x43a35fac483296bdf:2647: attempt to index a nil value" or
       err:match("^#x43a35fac483296bdf:2647: attempt to index .- %(a nil value%)$") ~= nil)
    if KRONOS_RETAIL_K1.enabled == true and missing then
      local E = rawget(_G, "Engine")
      local query = type(E) == "table" and E[H("112586a3f4fb490e")]
      if type(query) == "function" then
        local ready, frontend = pcall(query)
        if ready and frontend == true then return false end
      end
    end
    error(err, 0)
  end
  local wrapper = function(...) return finish(pcall(original, ...)) end
  historyWrapped[wrapper] = true
  C[key] = wrapper
end
function stability.operators(ops, skins, execs, sel)
  if sel ~= 0 and sel ~= 1 then return false end
  local none = HREF(3)
  for i = 0, 1 do
    if ops[i] == nil or ops[i] == none or skins[i] == nil or skins[i] == none
      or execs[i] == nil then return false end
  end
  return true
end
stability.season()
stability.historyCondition()
end
function KRONOS_RETAIL_K1.deadOps()
  return KRONOS_RETAIL_K1.enabled and getDvar(DV_MAP) == "zm_sat_ztron4"
end
local function mapMode()
  if getDvar("b2d6f347952c7d99") ~= "1" then return "frontend" end
  local m = getDvar(DV_MAP)
  return m:match("^zm_") and "zm" or "mp"
end
do
  local queue, seq = {}, 0
  L = function(s)
    seq = seq + 1
    table.insert(queue, 1, seq .. "\t" .. tostring(s):gsub("[\t\n\r]", " "):sub(1, 180))
    if #queue > 10 then queue[11] = nil end
    pcall(function() Dvar[H(DV_SET)](H("67730584afc6ee3d", 1), table.concat(queue, "\n")) end)
  end
end
local probeN = {}
local debugN, debugOn = 0, false
local function debugLog()
  debugN = debugN - 1
  if debugN <= 0 then debugN = 200; debugOn = getDvar("8c1ebc67a94d9786") == "1" end
  return debugOn
end
local function probe(name, id, res)
  if not debugLog() then return end
  local n = (probeN[name] or 0) + 1
  probeN[name] = n
  if n <= 3 or n == 10 or n == 100 or n == 1000 or n == 10000 then
    L(name .. " #" .. n .. ": " .. tostring(id) .. " (" .. type(id) .. ") -> " .. tostring(res))
  end
end
pcall(function()
  local F = LUI and LUI.FlowManager
  if type(F) ~= "table" or rawget(_G, "__kronosPopupTrace") then return end
  _G.__kronosPopupTrace = true
  for _, name in ipairs({ "RequestErrorPopup", "RequestPopupMenu", "RequestAddMenu", "RequestLeaveMenu" }) do
    local orig = F[name]
    if type(orig) == "function" then
      F[name] = function(...)
        local parts = {}
        for i = 1, select("#", ...) do parts[#parts + 1] = tostring((select(i, ...))) end
        local text = table.concat(parts, " | ")
        if name == "RequestErrorPopup" or text:lower():find("rror", 1, true) or text:find("1014a03d46f49f13", 1, true) then
          pcall(DebugPrint, "k1 popup " .. name .. ": " .. text .. " " .. debug.traceback("", 2):gsub("%s+", " "))
        end
        return orig(...)
      end
    end
  end
end)
do
  local K = rawget(_G, "KRONOS") or {}
  _G.KRONOS = K
  K.version = K.version or 1
  K.libs = K.libs or {}
  K.provide = K.provide or function(name, lib) K.libs[name] = lib end
  K.require = K.require or function(name) return K.libs[name] end
  K.hud = K.hud or {}
  K.hud.themes = K.hud.themes or {}
  K.H = H
  K.ctrl = function() return CTRL end
  K.dvar = getDvar
  K.gametype = function() return getDvar(DV_GT) end
  K.map = function() return getDvar(DV_MAP) end
  K.mode = function() return mapMode() end
  K.log = function(s) pcall(DebugPrint, "k1 mod: " .. tostring(s)) end
end
local relicPending = false
local modeChosen = false
local goCmd
local launching = false
local MAPS = {
  { "zm_sat_firefly", "Ashes of the Damned" },
  { "zm_sat_ruby", "Astra Malorum" },
  { "zm_sat_mantis", "Paradox Junction" },
  { "zm_sat_locust", "Totenreich" },
  { "zm_sat_hornet", "Kowakujo" },
  { "zm_sat_scarab", "Rex Infernus" },
}
local MODES = {
  { img = "zm_sat_firefly", "Standard", "zm_rb", asset = "sat_zm_rb" },
  { img = "zm_sat_firefly_farm", "Survival", "zm_rb_survival", asset = "sat_zm_rb_survival", maps = { { "zm_sat_firefly", "Vandorn Farm (Ashes)", poi = "zone_farm", img = "zm_sat_firefly_farm", poidv = "dddf7dca1a52e591" }, { "zm_sat_firefly", "Exit 115 (Ashes)", poi = "zone_exit115", img = "zm_sat_firefly_exit115", poidv = "dddf7dca1a52e591" }, { "zm_sat_firefly", "Zarya Cosmodrome? (Ashes)", poi = "zone_launchpad", img = "zm_sat_firefly_launchpad", poidv = "dddf7dca1a52e591" }, { "zm_sat_firefly", "Ashwood (Ashes)", poi = "ashwood", img = "zm_sat_firefly_ashwood", poidv = "dddf7dca1a52e591" }, { "zm_sat_mantis", "Paradox: Future", poi = "future", poidv = "2adc89ffac1de1a6" }, { "zm_sat_mantis", "Paradox: Past", poi = "past", poidv = "2adc89ffac1de1a6" }, { "zm_sat_locust", "Eidskallen Lighthouse (Totenreich)", poi = "zone_lighthouse", poidv = "fcdbf400811969f0" }, { "zm_sat_hornet", "Tenshu (Kowakujo)", poi = "castle", poidv = "ab460fa6a1b88d4a" } } },
  { img = "zm_sat_hornet", "Directed", "zm_guided", asset = "sat_zm_guided" },
  { img = "zm_sat_locust", "Cursed", "zm_rb_r_mod", asset = "zm_rb_r_mod", relics = true },
  { img = "zm_sat_mantis", "Rogue Run", "zm_rb_echo", asset = "zm_rb_echo", maps = { { "zm_sat_firefly", "Ashes of the Damned" }, { "zm_sat_ruby", "Astra Malorum" }, { "zm_sat_mantis", "Paradox Junction" }, { "zm_sat_hornet", "Kowakujo" } } },
  { img = "zm_sat_ruby", "Zombies Battle", "zm_rb_battle", asset = "zm_rb_battle" },
  { img = "zm_sat_ztron4", "Dead Ops Arcade 4", "zm_ztron", asset = "zm_ztron", alts = {"ztron", "zm_ztron4", "ztron4", "doa", "zm_doa", "doa4", "zm_doa4"}, maps = { { "zm_sat_ztron4", "Dead Ops Arcade 4" } } },
}
local function ensureLobby() end
local DV_ASSET = "fe95dec32139474d"
local ASSET_HASH = {sat_zm_rb = "75505f81616168a7", sat_zm_rb_survival = "052dfe30a2cbf4de", sat_zm_guided = "3e64bb1e257bd3e3", sat_zm_rb_classic = "36184f450b76ac38", zm_rb_r_mod = "20c86e6d6006eba6", zm_ztron = "2221eb5207966ab5"}
local SAVEDV = { slot = "a29c4a22748b998f", load = "89cdd504cc46b123", gt = "da1eb79d992f0e28" }
local SAVEMAP = {
  ["zm_sat_firefly"] = "8edb5112575b1bf7",
  ["zm_sat_ruby"] = "90e854c3f73136fa",
  ["zm_sat_mantis"] = "6181b008e01c0962",
  ["zm_sat_locust"] = "8c6dca1e7cd781bc",
  ["zm_sat_hornet"] = "751316ee50dbd986",
  ["zm_sat_scarab"] = "69c1d49dd96ad59c",
  ["zm_sat_ztron4"] = "c6699114a2aa48cd",
}
local SAVENAMES = {
  ["zm_sat_firefly"] = "Ashes of the Damned",
  ["zm_sat_ruby"] = "Astra Malorum",
  ["zm_sat_mantis"] = "Paradox Junction",
  ["zm_sat_locust"] = "Totenreich",
  ["zm_sat_hornet"] = "Kowakujo",
  ["zm_sat_scarab"] = "Rex Infernus",
  ["zm_sat_ztron4"] = "Dead Ops Arcade 4",
}
local SAVEORDER = { "zm_sat_firefly", "zm_sat_ruby", "zm_sat_mantis", "zm_sat_locust", "zm_sat_hornet", "zm_sat_scarab", "zm_sat_ztron4" }
local QUEST_DVARS = {
  zm_sat_firefly = "set enable_firefly_ee 1;set enable_firefly_mq 1;set enable_firefly_sq 1;set enable_firefly_sq_c 1;set enable_firefly_sq_v 1;set enable_firefly_rh 1;",
  zm_sat_ruby = "set enable_ruby_ee 1;set enable_ruby_rh 1;",
  zm_sat_mantis = "set enable_mantis_ee 1;set enable_mantis_mq 1;set enable_mantis_sq 1;set enable_mantis_rh 1;",
  zm_sat_locust = "set enable_locust_ee 1;set enable_locust_mq 1;set enable_locust_sq 1;set enable_locust_rh 1;"
    .. "set scr_locust_gnomes_enabled 1;set scr_locust_robot_head_powerups_enabled 1;set scr_locust_viking_helmets_enabled 1;"
    .. "set scr_locust_big_mouth_enabled 1;set scr_locust_richtofen_enabled 1;",
  zm_sat_hornet = "set enable_hornet_ee 1;set enable_hornet_mq 1;set enable_hornet_sq 1;set enable_hornet_rh 1;"
    .. "set enable_hornet_ee_pew 1;set enable_hornet_ee_neigh 1;set enable_hornet_ee_cafe 1;set enable_hornet_ee_jump 1;"
    .. "set enable_hornet_ee_nya 1;set enable_hornet_ee_roll 1;set enable_hornet_ee_bat 1;set enable_hornet_ee_rocker 1;",
  zm_sat_scarab = "set enable_scarab_ee 1;set enable_scarab_sq 1;set enable_scarab_rh 1;set enable_scarab_br 1;",
}
local QUEST_COMMON = "set enable_rh 1;set skip_zm_rh_validation 1;set enable_zm_relics 0;"
local function start(map, gt, asset, alts, entry)
  local okH, host = pcall(function() return Lobby[H("96957722ef74f5d2")]() end)
  if okH and host == false and (tonumber(getDvar("5012c838382353c1")) or 0) > 1 then
    local F = rawget(_G, "__kronosFRN")
    if F then
      F.leaderNotes = (F.leaderNotes or 0) + 1
      pcall(F.toast, { kind = "leader", from = "Party", id = "", seq = tostring(50000000 + F.leaderNotes) })
    end
    L("start blocked: party member")
    return
  end
  if KRONOS_RETAIL_K1.enabled then
    local request = KRONOS_RETAIL_K1.nativeResume
    if not (request and request.inStart and request.entry == entry and entry.cont == true) then return end
  end
  local cont = entry and entry.cont
  modeChosen = false
  setDvar(DV_MAP, map); setDvar(DV_GT, gt)
  if (tonumber(getDvar("5012c838382353c1")) or 0) <= 1 then exec("xstartprivateparty;xstartlobby_patched") end
  setDvar(DV_MAP, map); setDvar(DV_GT, gt)
  local names = {gt, asset}
  for _, a in ipairs(alts or {}) do names[#names+1] = a end
  local got
  for _, name in ipairs(names) do
    local ok, e = pcall(function() GameType[H("c0631ab43ba10119")](name) end)
    local cur = getDvar(DV_GT)
    L("SetGameType(" .. tostring(name) .. ") ok=" .. tostring(ok) .. " err=" .. tostring(e) .. " gt=" .. cur .. " asset=" .. getDvar(DV_ASSET))
    if ok and cur ~= "" and cur ~= "nil" then got = name; break end
  end
  if not got then
    L("no valid gametype name for " .. tostring(gt) .. ", aborting launch")
    pcall(function() GameType[H("c0631ab43ba10119")]("zm_rb") end)
    return
  end
  setDvar(DV_MAP, map)
  setDvar("bcf6d292629632eb", map)
  setDvar(SAVEDV.slot, map); setDvar(SAVEDV.gt, got or gt); local gen = (tonumber(getDvar(SAVEDV.load):match(":(%d+)$")) or 0) + 1; setDvar(SAVEDV.load, (cont and "1" or "0") .. ":" .. gen)
  L("save slot=" .. map .. " gt=" .. tostring(got or gt) .. " load=" .. (cont and "1" or "0"))
  if entry and entry.poi then
    setDvar(entry.poidv, entry.poi)
    L("poi dvar " .. entry.poidv .. " = " .. getDvar(entry.poidv))
    exec("set playlist_reset_dvars_on_switch 0")
    exec("set scr_" .. map .. "_survival_poi " .. entry.poi)
  end
  L("before go map=" .. getDvar(DV_MAP) .. " gt=" .. getDvar(DV_GT) .. " asset=" .. getDvar(DV_ASSET))
  local priv = ""
  for name, hx in pairs({ xblive_privatematch = "485ef1ed1d39d3a3", systemlink = "a3ddb961100b5f47" }) do
    local v = getDvar(hx)
    if v == "true" or v == "1" then v = "1" elseif v == "false" or v == "0" then v = "0" else v = nil end
    if v then priv = priv .. "set " .. name .. " " .. v .. ";" end
  end
  local ee = QUEST_DVARS[map]
  if ee then
    ee = ee .. QUEST_COMMON
    exec(ee)
    priv = ee .. priv
  end
  if entry and entry.poi then
    goCmd = priv .. "xpartygo;set scr_" .. map .. "_survival_poi " .. entry.poi
  else
    goCmd = priv .. "xpartygo"
  end
  L("go command " .. goCmd)
  exec("luiOpenMenu ZMPublicLobby")
  local bots = tonumber(getDvar("09b8247922d2800f")) or 0
  if bots > 0 and not rawget(_G, "__kronosBotsAdded") then
    _G.__kronosBotsAdded = true
    local ok, e = pcall(function() Lobby[H("f45add213e99c39e")](CTRL, bots, 1) end)
    L("test bots: add " .. bots .. " ok=" .. tostring(ok) .. " err=" .. tostring(e))
  end
end
local GBL = "bd85f85cf196c234"
local function popup(controller, data)
  data.controllerIndex = controller
  local ok, e = pcall(function() LUI.FlowManager.RequestPopupMenu(nil, H(GBL), true, controller, false, data) end)
  if not ok then L("popup err " .. tostring(e)) end
end
local selectedMode = nil
local LB_REQ, LB_STATE = "0416f40d37cdbf39", "38f280d50e3226d4"
local LB_PARTS = { "cc8595ec042c9160", "cc8596ec042c9393", "cc8597ec042c95c6", "cc8598ec042c97f9", "cc8599ec042c9a2c",
  "cc859aec042c9c5f", "cc859bec042c9e92", "cc859cec042ca0c5", "cc859dec042ca2f8", "cc859eec042ca52b", "f65e8c0d2e08af79",
  "f65e8b0d2e08ad46", "f65e8a0d2e08ab13", "f65e890d2e08a8e0", "f65e900d2e08b845", "f65e8f0d2e08b612" }
local lbSerial = 0
local function lbRefresh() lbSerial = lbSerial + 1; setDvar(LB_REQ, "refresh|" .. lbSerial) end
local function lbRead()
  local status, parts = getDvar(LB_STATE):match("^[^\t]*\t([^\t]*)\t(%d+)")
  if status ~= "ok" then return nil, status or "waiting for version.dll" end
  local text = {}
  for i = 1, math.min(tonumber(parts), #LB_PARTS) do text[i] = getDvar(LB_PARTS[i]) end
  local boards, rows, game = {}, {}, {}
  for line in table.concat(text):gmatch("[^\n]+") do
    local f = {}
    for x in (line .. "\t"):gmatch("([^\t]*)\t") do f[#f + 1] = x end
    if f[1] == "B" then
      boards[#boards + 1] = { map = f[2], mode = f[3], players = tonumber(f[4]) or 0, best = tonumber(f[5]) or 0 }
    elseif f[1] == "T" or f[1] == "M" then
      local key = f[2] .. "|" .. f[3]
      rows[key] = rows[key] or { top = {} }
      local r = { rank = tonumber(f[4]) or 0, name = f[5], round = tonumber(f[6]) or 0, time_ms = tonumber(f[7]) or 0 }
      if f[1] == "M" then rows[key].me = r else table.insert(rows[key].top, r) end
    elseif f[1] == "G" or f[1] == "N" then
      game[f[2]] = game[f[2]] or { top = {} }
      local r = { rank = tonumber(f[3]) or 0, name = f[4], cols = {} }
      for i = 6, #f do r.cols[#r.cols + 1] = tonumber(f[i]) or 0 end
      if f[1] == "N" then game[f[2]].me = r else table.insert(game[f[2]].top, r) end
    end
  end
  return boards, rows, game
end
local LBG_MAX_AGE, LBG_TIMEOUT = 60000, 15000
local lbg = { hooks = {} }
local function lbgNow()
  local ok, t = pcall(function() return Engine[H("06991337ae950f99")]() end)
  return ok and tonumber(t) or 0
end
local function lbgRow(r) return { rank = r.rank - 1, gamertag = r.name, unoID = "", percentileRank = "", cols = r.cols } end
local function lbgResult(uri)
  local boards, _, game = lbRead()
  if not boards then return nil end
  local b = game[uri] or game[uri:match("^zm:[^:]+") or uri] or { top = {} }
  local ranks = {}
  for i, r in ipairs(b.top) do ranks[i] = lbgRow(r) end
  local me = b.me and lbgRow(b.me) or { rank = "", gamertag = "You", percentileRank = "", cols = {} }
  me.unoID = nil
  return { leaderboardUri = uri, ranks = ranks, userRank = me, nextPageToken = "", columns = { "sort" }, sortColumn = "sort" }
end
local function gameLeaderboards()
  local ok, e = pcall(function()
    local S, E = rawget(_G, "Stats"), rawget(_G, "Enum")
    if type(S) ~= "table" or type(E) ~= "table" or type(E[H("f4011ff9866ef22c")]) ~= "table" then return end
    local ST = E[H("f4011ff9866ef22c")]
    local FETCHING, SUCCESS, FAILED = ST[H("34de6fb9a3e33495")], ST[H("b7ee36b5cb9717bb")], ST[H("dbd905f48646fbff")]
    local function wrap(t, hex, make)
      local k = H(hex); local cur = t[k]
      if type(cur) ~= "function" or cur == lbg.hooks[hex] then return end
      lbg.hooks[hex] = make(cur); t[k] = lbg.hooks[hex]
    end
    wrap(S, "1d24ede854b53ecb", function(orig) return function(c, filter, uri, ...)
      if type(uri) ~= "string" or uri:sub(1, 3) ~= "zm:" then lbg.uri = nil; return orig(c, filter, uri, ...) end
      lbg.uri, lbg.result, lbg.since = uri, nil, lbgNow()
      if not lbg.asked or lbg.since - lbg.asked > LBG_MAX_AGE then lbRefresh(); lbg.asked = lbg.since end
      return true
    end end)
    wrap(S, "f06cdbb580b1a439", function(orig) return function(c, ...)
      if not lbg.uri then return orig(c, ...) end
      if lbg.result then return SUCCESS end
      local okR, res = pcall(lbgResult, lbg.uri)
      if not okR then L("leaderboard: game board error " .. tostring(res)); return FAILED end
      if res then
        lbg.result = res
        L("leaderboard: game board " .. lbg.uri .. ", " .. #res.ranks .. " rows")
        return SUCCESS
      end
      if lbgNow() - lbg.since < LBG_TIMEOUT then return FETCHING end
      L("leaderboard: game board " .. lbg.uri .. ": no copy from version.dll (" .. tostring(select(2, lbRead())) .. ")")
      return FAILED
    end end)
    wrap(S, "53e081a3ee1be404", function(orig) return function(c, ...)
      if not lbg.uri then return orig(c, ...) end
      return lbg.result or { leaderboardUri = lbg.uri, ranks = {}, nextPageToken = "", columns = { "sort" }, sortColumn = "sort",
        userRank = { rank = "", gamertag = "You", unoID = "", percentileRank = "", cols = {} } }
    end end)
    wrap(S, "b91daf9d62c7a043", function(orig) return function(c, ...)
      if not lbg.uri then return orig(c, ...) end
      lbg.uri = nil
    end end)
    local LB = rawget(_G, "Leaderboards")
    if type(LB) == "table" then
      wrap(LB, "a728a8f2eab3f92a", function(orig) return function(c, unoID, ...)
        if unoID == nil or unoID == "" then return end
        return orig(c, unoID, ...)
      end end)
    end
  end)
  if not ok then L("game leaderboards hook err " .. tostring(e)) end
end
local FR_REQ, FR_STATE = "9d0f7a31faeb97b7", "28aa402db82e5e1a"
local FR_PARTS = { "d1475e36a74d2b6a", "d1475f36a74d2d9d", "d1475c36a74d2704", "d1475d36a74d2937", "d1475a36a74d229e",
  "d1475b36a74d24d1", "d1475836a74d1e38", "d1475936a74d206b" }
local frSerial = 0
local function frRead()
  local status, parts = getDvar(FR_STATE):match("^[^\t]*\t([^\t]*)\t(%d+)")
  if status ~= "ok" then return nil, status or "connecting to friends" end
  local text = {}
  for i = 1, math.min(tonumber(parts), #FR_PARTS) do text[i] = getDvar(FR_PARTS[i]) end
  local friends, notes = {}, {}
  for line in table.concat(text):gmatch("[^\n]+") do
    local f = {}
    for x in (line .. "\t"):gmatch("([^\t]*)\t") do f[#f + 1] = x end
    if f[1] == "F" then
      friends[#friends + 1] = { id = f[2], name = f[3], status = f[4], source = f[5], flags = f[6] or "", map = f[7] or "",
        gametype = f[8] or "" }
    elseif f[1] == "N" then
      notes[#notes + 1] = { kind = f[2], from = f[3], id = f[4] or "", seq = f[5] or "" }
    end
  end
  return friends, notes
end
local function frRequest(verb, f)
  local retail=rawget(_G,"LUMEN_ZM_LOCAL_START")
  if verb=="join" and type(retail)=="table" and type(retail.rs1BeginPartyJoin)=="function" then
    if retail.rs1BeginPartyJoin(CTRL,f.id,f.name)==false then return end
  end
  frSerial = frSerial + 1
  setDvar(FR_REQ, frSerial .. "|" .. verb .. "|" .. f.id)
  L("friends: " .. verb .. " " .. f.name)
end
local function frStatus(f)
  if f.flags:find("s", 1, true) then return "In your party" end
  if f.flags:find("i", 1, true) then return "Invited you to their party" end
  if f.map ~= "" then return "Playing " .. f.map .. (f.gametype ~= "" and (" (" .. f.gametype .. ")") or "") end
  if f.status == "online" then return "In a game" end
  if f.status == "idle" then return "In menus" end
  return "Offline"
end
local function frRank(f)
  if f.flags:find("s", 1, true) then return 0 end
  if f.flags:find("[jo]") then return 1 end
  return ({ online = 2, idle = 3 })[f.status] or 4
end
local FRN = { hooks = {}, byXuid = {}, active = false, count = 0 }
local function frSteamId(id)
  local h1, h2 = 7, 13
  for i = 1, #id do local b = id:byte(i); h1 = (h1 * 131 + b) % 1000003; h2 = (h2 * 137 + b) % 999983 end
  local account = 3900000000 + (h1 * 389 + h2) % 390000000
  local low = 960265728 + account
  return string.format("%d%09d", 76561197 + math.floor(low / 1e9), low % 1e9)
end
local function frXuidOf(...)
  for i = 1, select("#", ...) do
    local v = select(i, ...)
    if v ~= nil then
      local f = FRN.byXuid[type(v) == "string" and v or tostring(v)]
      if f then return f end
    end
  end
end
local function frNativeList()
  local friends = frRead()
  if not friends then return {} end
  table.sort(friends, function(a, b)
    local ra, rb = frRank(a), frRank(b)
    if ra ~= rb then return ra < rb end
    return a.name:lower() < b.name:lower()
  end)
  FRN.byXuid = {}
  for _, f in ipairs(friends) do f.xuid = frSteamId(f.id); FRN.byXuid[f.xuid] = f end
  return friends
end
local function frPlayers()
  local S = rawget(_G, "_DataSources") and _DataSources[H("023986b8399c4f32")]
  local list = S and S[H("7af61f6290d6dc40")]
  return list and list[H("f802a0b8e27c421e")]
end
local function frWriteRows(c)
  local ok, e = pcall(function()
    local P = frPlayers(); if not P then return end
    local friends = frNativeList()
    for i, f in ipairs(friends) do
      P[i][H("4580fab03b7eb9c0")][H("eb5c735486fc7ccb")]:SetValue(c, f.xuid)
    end
    FRN.count = #friends
    P[H("b1e5e28e4479a274")]:SetValue(c, #friends)
    L("friends tab: " .. #friends .. " friends written")
  end)
  if not ok then L("friends tab write err " .. tostring(e)) end
end
local function frWatchCount(m, c)
  pcall(function()
    frPlayers()[H("b1e5e28e4479a274")]:AddSubscriber(m, c, function(v)
      if FRN.active and tonumber(v) ~= FRN.count then frWriteRows(c) end
    end)
  end)
end
local function frDetailsActions(c, opts)
  local D = _DataSources[H("023986b8399c4f32")][H("ebe5735a48aa5dac")]
  local f = frXuidOf(D[H("ffd60394ddeb1817")]:GetValue(c))
  if not f then return false end
  local acts = {}
  local inParty = f.flags:find("s", 1, true)
  if not inParty and f.flags:find("[jo]") then acts[#acts + 1] = { "Join " .. f.name, function() frRequest("join", f) end } end
  if not inParty then acts[#acts + 1] = { "Invite to Party", function() frRequest("invite", f) end } end
  D[H("b46c349f002e781e")]:SetValue(c, { xuid = f.xuid, platformId = D[H("b094c06a3023e566")]:GetValue(c), controllerIndex = c })
  local list = D[H("7ee316bc0b00a4d5")]
  for i, a in ipairs(acts) do
    local entry = list[i]
    entry[H("0fa3391db68e4425")]:SetValue(c, false)
    entry[H("6568640b035a56df")]:SetValue(c, a[2])
    entry[H("66655dca2c3e8a12")]:SetValue(c, LUI.Commands.Social.PlayerDetailsAction)
    entry[H("39f7fcec8fcb623d")]:SetValue(c, a[1])
    entry[H("dbff4cc56c2092f0")]:SetValue(c, nil)
    entry[H("18a25faa2525b6fb")]:SetValue(c, false)
    entry[H("153fd749bce2f6ee")]:SetValue(c, false)
    entry[H("96b1d28104a3113f")]:SetValue(c, "")
  end
  list[H("b1e5e28e4479a274")]:SetValue(c, #acts)
  L("friends tab: details for " .. f.name .. ", " .. #acts .. " actions")
  return true
end
FRN.noteText = { invite = "Invited you to their party", sent = "Party invite sent",
  noparty = "Start a party before inviting", failed = "Invite could not be sent",
  cfwd = "Parties are off while carry-forward is on (launcher)",
  queued = "Invite will be sent when your party is ready", joining = "Joining their party when you're back in the menu",
  follow = "Following the party leader", leader = "Only the party leader can start a match" }
function FRN.toast(n)
  local retail=rawget(_G,"LUMEN_ZM_LOCAL_START")
  if type(retail)=="table" and type(retail.rs1ObservePartyNotice)=="function" then
    if retail.rs1ObservePartyNotice(n)==false then return end
  end
  local T = LUI.ToastManager
  local join = n.kind == "invite"
  local desc = FRN.noteText[n.kind]
  local data = T.StandardEmphasisToast(n.from, desc, T.ToastNotificationType.Player, nil, join)
  local act = join and T.ToastAction("Join", function() frRequest("join", { id = n.id, name = n.from }) end, false) or nil
  local opts = { controllerIndex = CTRL, length = join and 15000 or 6000, handle = 900000000 + tonumber(n.seq),
    title = n.from, body = desc }
  T.SetupToastData(opts, data, act, nil)
  if join then
    opts.toastActions = { { actionName = "Join", actionFunction = function() frRequest("join", { id = n.id, name = n.from }) end } }
  end
  local feed = T.GetActiveFeed()
  if not feed then
    local mgr = T.GetInstance()
    if mgr then mgr:InitLayer() mgr.layerEnabled = true end
    feed = T.GetActiveFeed()
    L("friends: toast layer enabled by us, feed=" .. tostring(feed ~= nil))
  end
  local r = feed and feed:CreateToastNotification(opts)
  L(string.format("friends: toast %s %s feed=%s r=%s q=%s cur=%s max=%s paused=%s", n.kind, n.from, tostring(feed ~= nil),
    tostring(r), tostring(feed and feed.notificationQueue and #feed.notificationQueue), tostring(feed and feed.currentNotifications),
    tostring(feed and feed.maxNotifications), tostring(feed and feed.pauseNotifications)))
end
_G.__kronosFRN = FRN
FRN.seen = rawget(_G, "__kronosFrSeen") or {}
_G.__kronosFrSeen = FRN.seen
function FRN.toastTimer()
  local t = rawget(_G, "__kronosFrTimer")
  if t and t:getParent() then return end
  t = LUI.UIElement.new()
  LUI.GetRoot():addElement(t)
  _G.__kronosFrTimer = t
  local function tick()
    local retail=rawget(_G,"LUMEN_ZM_LOCAL_START")
    if type(retail)=="table" and type(retail.rs1PollParty)=="function" then pcall(retail.rs1PollParty,CTRL,500)end
    local okR, friends, notes = pcall(frRead)
    local okF, front = pcall(function() return Engine[H("112586a3f4fb490e")]() end)
    if okR and friends and not FRN.seen.ready then
      for _, n in ipairs(notes) do FRN.seen[n.seq] = true end
      FRN.seen.ready = true
    end
    local list, done = okR and friends and okF and notes or {}, {}
    for i = #list, 1, -1 do
      local n = list[i]
      if n.kind == "sent" or n.kind == "failed" or n.kind == "noparty" then done[n.id] = tonumber(n.seq) end
    end
    for i = #list, 1, -1 do
      local n = list[i]
      if n.kind == "queued" and (done[n.id] or 0) > (tonumber(n.seq) or 0) then FRN.seen[n.seq] = true end
      if n.seq ~= "" and FRN.noteText[n.kind] and not FRN.seen[n.seq] and (front or n.kind ~= "invite") then
        FRN.seen[n.seq] = true
        local ok, e = xpcall(function() return _G.__kronosFRN.toast(n) end, (rawget(_G, "debug") and debug.traceback) or tostring)
        if not ok then L("friends: toast err " .. (tostring(e):gsub("%s*\n%s*", " | "))) end
      end
    end
    t:Wait(500).onComplete = tick
  end
  tick()
end
local function frNativeHooks()
  pcall(FRN.toastTimer)
  local ok, e = pcall(function()
    local S = rawget(_G, "SOCIAL"); if type(S) ~= "table" then return end
    local function wrap(hex, make)
      local k = H(hex); local cur = S[k]
      if type(cur) ~= "function" or cur == FRN.hooks[hex] then return end
      FRN.hooks[hex] = make(cur); S[k] = FRN.hooks[hex]
    end
    wrap("f4c9049554a392fc", function(orig) return function(...)
      local f = frXuidOf(...)
      if f then return f.name end
      return orig(...)
    end end)
    wrap("b67c6f8f33becd65", function(orig) return function(...)
      local f = frXuidOf(...)
      if f then return frStatus(f) end
      return orig(...)
    end end)
    wrap("ab8e7ff8b0700817", function(orig) return function(...)
      if frXuidOf(...) then return true end
      return orig(...)
    end end)
    wrap("ec2dd5c1fc3d4e27", function(orig) return function(c, ...)
      local okD, handled = pcall(frDetailsActions, c, ...)
      if not okD then L("friends tab details err " .. tostring(handled)) end
      if okD and handled then return end
      return orig(c, ...)
    end end)
    wrap("3a0bb73de9c5cd06", function(orig) return function(c, ...)
      if orig(c, ...) then return true end
      local okM, menu = pcall(S[H("4b83b8b916257748")])
      local okK, osk = pcall(function() return OSK[H("a736af74410e3002")]() end)
      return okM and menu ~= nil and not LUI.FlowManager.IsInStack(menu) and not (okK and osk)
    end end)
  end)
  if not ok then L("friends tab hook err " .. tostring(e)) end
end
local FR_TABS = { [tostring(H("83ec04ea1979d9be"))] = true, [tostring(H("77491d054d639e15"))] = true }
local FR_OTHER_TABS = { [tostring(H("26abcfcc1d4a947d"))] = true, [tostring(H("faf84d28d84b3794"))] = true,
  [tostring(H("c303b8db3f6a0833"))] = true, [tostring(H("09ed1c41bb507cab"))] = true,
  [tostring(H("2a94569bff026cb0"))] = true, [tostring(H("bb08256242603eb8"))] = true }
local function mapsData(controller)
  CTRL = controller or 0
  local mode = selectedMode or MODES[1]
  local buttons = {}
  if mode.relics then
    buttons[#buttons+1] = { label = "Choose Relics", action = function() relicPending = true; exec("luiOpenMenu RelicSelectMenu") end }
  end
  for _, m in ipairs(mode.maps or MAPS) do
    buttons[#buttons+1] = { label = m[2], img = m.img or m[1], action = function() start(m[1], m.savedgt or mode[2], m.savedgt and nil or mode.asset, m.savedgt and nil or mode.alts, m) end }
  end
  return { controllerIndex = controller, title = mode[1], buttons = buttons }
end
local function savedList()
  local saved = {}
  for _, mp in ipairs(SAVEORDER) do
    local g = getDvar(SAVEMAP[mp])
    if g and g ~= "" and g ~= "nil" then saved[#saved+1] = { mp, (SAVENAMES[mp] or mp) .. " (" .. g .. ")", cont = true, savedgt = g } end
  end
  return saved
end
local function openSaves()
  local saved = savedList()
  L("open saves: " .. #saved)
  if #saved == 0 then return false end
  selectedMode = { "Continue Saved Game", "zm_rb", img = saved[1][1], maps = saved }
  exec("luiOpenMenu ZMModeMaps")
  return true
end
local function modesData(controller)
  CTRL = controller or 0
  ensureLobby()
  local buttons = {}
  local saved = savedList()
  for _, mp in ipairs({}) do
    local g = getDvar(SAVEMAP[mp])
    if g and g ~= "" and g ~= "nil" then saved[#saved+1] = { mp, (SAVENAMES[mp] or mp) .. " (" .. g .. ")", cont = true, savedgt = g } end
  end
  if #saved > 0 then
    local cm = { "Continue Saved Game", "zm_rb", img = saved[1][1], maps = saved }
    buttons[#buttons+1] = { label = cm[1], img = cm.img, action = function() selectedMode = cm; exec("luiOpenMenu ZMModeMaps") end }
  end
  for _, mode in ipairs(MODES) do
    buttons[#buttons+1] = { label = mode[1], img = mode.img, action = function()
      selectedMode = mode
      modeChosen = true
      if mode.relicsFirst then relicPending = true; exec("luiOpenMenu RelicSelectMenu") else exec("luiOpenMenu ZMModeMaps") end
    end }
  end
  return { controllerIndex = controller, title = "Zombies", buttons = buttons }
end

local function hashHex(v)
  if type(v) == "number" then return string.format("%x", v) end
  local s = tostring(v):match("#x(%x+)")
  return s and s:sub(2) or "0"
end
local function loadoutOperators(od)
  local none, ops, skins, execs = HREF(3), {}, {}, {}
  for i = 0, 1 do
    ops[i] = od[H("393afe43e4ba46d7")](od, i)
    skins[i] = od[H("3fdddcd9963f2abe")](od, i, ops[i])
    if skins[i] == none then skins[i] = OPERATOR[H("98ea1faf122a218e")](ops[i]) end
    execs[i] = od[H("9d3e682a67fe4c9f")](od, i, ops[i])
  end
  return ops, skins, execs, od[H("4d632dddc8fd466a")](od)
end
local function currentLoadoutGroup()
  local ok, g = pcall(function() return LOADOUT[H("1f3d4120102d8bb3")]() end)
  if ok and g ~= nil then return g end
  return CoD.StatsGroup.RankedLoadouts
end
local lastOperatorDvar
local function pushOperators(ops, skins, execs, sel)
  local p = {}
  for i = 0, 1 do p[#p + 1] = hashHex(ops[i]) .. " " .. hashHex(skins[i]) .. " " .. tostring(tonumber(execs[i]) or 0) end
  local v = table.concat(p, " ") .. " " .. tostring(sel)
  if v ~= lastOperatorDvar then
    setDvar("457444bded5e68a5", v)
    if getDvar("457444bded5e68a5") == v then lastOperatorDvar = v end
  end
end
local operatorSynced, operatorSyncErr = false, false
local function syncOperatorProfile(c)
  if KRONOS_RETAIL_K1.stability.operatorBusy or not KRONOS_RETAIL_K1.stability.frontendIdle() then return end
  KRONOS_RETAIL_K1.stability.operatorBusy = true
  local ok, e = pcall(function()
    local OD, UP, OP = rawget(_G, "OperatorData"), rawget(_G, "UserProfiles"), rawget(_G, "OPERATOR")
    if type(OD) ~= "table" or type(UP) ~= "table" or type(OP) ~= "table" or not (CoD and CoD.StatsGroup) then return end
    local list = OP[H("5d5ce8fcfbfea515")]
    if type(list) ~= "function" or not list() then return end
    local prof = UP[H("f4562b9dd21873d8")](c, 2)
    local ctx = prof and prof.context
    if not ctx then return end
    local group = currentLoadoutGroup()
    local od = OD.new(c, nil, nil, group)
    if not (od and od[H("296e1ad6c0c05ba1")](od)) then return end
    local none = HREF(3)
    local function copy(dst, v, skip)
      if dst == nil or v == nil or v == skip or v == dst:get() then return end
      dst:set(v)
    end
    local ops, skins, execs, sel = loadoutOperators(od)
    if not KRONOS_RETAIL_K1.stability.operators(ops, skins, execs, sel) then return end
    copy(ctx.selectedOperatorIndexPublic, sel, -1)
    copy(ctx.selectedOperatorIndexPrivate, sel, -1)
    for k = 0, 2 do
      local okSet, set = pcall(function() return ctx.customizationSets[k] end)
      if okSet and set then
        for i = 0, 1 do
          copy(set.operatorRef[i], ops[i], none)
          copy(set.skinRef[i], skins[i], none)
          copy(set.execution[i], execs[i], 0)
        end
      end
    end
    for _, mpGroup in ipairs(group == CoD.StatsGroup.RankedLoadouts and { CoD.StatsGroup.RankedLoadouts, CoD.StatsGroup.PrivateLoadouts } or {}) do
      pcall(function()
        local cust = PLAYER_DATA[H("08b73907b55c4d71")](c, mpGroup).customizations
        for i = 0, 1 do
          copy(cust.operators[i].operatorRef, ops[i], none)
          copy(cust.operators[i].skinRef, skins[i], none)
        end
      end)
    end
    pushOperators(ops, skins, execs, sel)
    if not operatorSynced then operatorSynced = true; L("operator profile synced from loadout stats") end
  end)
  KRONOS_RETAIL_K1.stability.operatorBusy = false
  if not ok and not operatorSyncErr then operatorSyncErr = true; L("operator sync error: " .. tostring(e)) end
end

local memberWraps = setmetatable({}, { __mode = "k" })
rawset(_G, "__kronosBo6LobbyHook", function()
  local O = rawget(_G, "OPERATOR"); if type(O) ~= "table" then return end
  local w = rawget(_G, "__kronosBo6MenuWraps")
  if not w or w.o ~= O then
    w = { o = O, n = 0, keys = {}, logged = 0, missing = false }
    rawset(_G, "__kronosBo6MenuWraps", w)
  end
  if not w.makers then
    local function log(s)
      w.logged = w.logged + 1
      if w.logged <= 24 then L("BO6 operators: " .. s) end
    end
    local function engineFind(ref)
      local OP = rawget(_G, "Operator")
      return OP and OP[H("72145c734039267f")](ref)
    end
    w.check = function()
      local OP = rawget(_G, "Operator")
      if OP == nil then return end
      local ready = OP[H("b21a22bf262a7e5e")](H("35cf6bdd18484fb2", 3)) ~= nil
      if not ready then
        w.missing = true
        return
      end
      if not w.missing then return end
      w.missing = false
      local E = rawget(_G, "Engine")
      local okF, front = pcall(function() return E[H("112586a3f4fb490e")]() end)
      if not (okF and front == true) then return end
      local P = rawget(_G, "PROJECT")
      if type(P) == "table" and type(P[H("a5a05e13ac947c99")]) == "table" then
        P[H("a5a05e13ac947c99")] = {}
      end
      O[H("d027dc265c99e256")] = nil
      w.resets = (w.resets or 0) + 1
      if w.resets <= 6 then log("BO6 data back - menu data rebuilt with it (BO6 blueprints, operators)") end
    end
    local function listCheck()
      w.n = w.n + 1
      if w.n % 10 == 1 then w.check() end
    end
    w.makers = {
      list1 = function(f) return function(...) pcall(listCheck); return f(...) end end,
      list2 = function(f) return function(...) pcall(listCheck); return f(...) end end,
      find = function(f)
        return function(ref, ...)
          local r = f(ref, ...)
          if r == nil and ref ~= nil and type(ref) ~= "table" then
            local ok, e = pcall(engineFind, ref)
            if ok and e ~= nil then return e end
          end
          return r
        end
      end,
      data = function(f)
        return function(ref, ...)
          local r = f(ref, ...)
          if r == nil and ref ~= nil and type(ref) ~= "table" then
            local ok, e = pcall(engineFind, ref)
            if ok and e ~= nil then return e end
          end
          return r
        end
      end,
      new = function(f)
        return function(ctrl, ref, ...)
          local ok, r = pcall(f, ctrl, ref, ...)
          if ok then return r end
          log("new-item check failed for " .. tostring(ref) .. ": " .. tostring(r))
          return false
        end
      end,
    }
    w.want = { list1 = "5d5ce8fcfbfea515", list2 = "fb56f77e699f514b", find = "72145c734039267f", new = "13d8bd2b211db6cc",
      data = "8155bd07932c396b" }
  end
  pcall(w.check)
  local missing = false
  for name in pairs(w.want) do
    if not w.keys[name] then missing = true end
  end
  if missing then
    for kk in pairs(O) do
      local s = tostring(kk)
      for name, hx in pairs(w.want) do
        if not w.keys[name] and s:find(hx, 1, true) then w.keys[name] = kk end
      end
    end
  end
  for name, make in pairs(w.makers) do
    local k = w.keys[name]
    local f = k and O[k]
    if type(f) == "function" and f ~= w[name] then
      local wrapped = make(f)
      w[name] = wrapped
      O[k] = wrapped
    end
  end
  local CC = rawget(_G, "ClientCharacter")
  local cs = rawget(_G, "__kronosBo6Preview")
  if not cs or cs.t ~= CC then
    cs = { t = CC, fails = 0 }
    rawset(_G, "__kronosBo6Preview", cs)
  end
  if type(CC) == "table" then
    if not cs.key then
      for kk in pairs(CC) do
        if tostring(kk):find("6b5ede08e0d57b44", 1, true) then cs.key = kk end
      end
    end
    local f = cs.key and CC[cs.key]
    if type(f) == "function" and f ~= cs.wrapped then
      local orig = f
      cs.wrapped = function(c, name, ...)
        local ok, e = pcall(orig, c, name, ...)
        if ok then return e end
        cs.fails = cs.fails + 1
        if cs.fails <= 12 then
          L("BO6 operators: character preview refused " .. tostring(name) .. " (" .. tostring(e) .. ") - shown without it")
        end
        pcall(orig, c, "", ...)
      end
      CC[cs.key] = cs.wrapped
      L("BO6 operators: character preview guarded")
    end
  end
end)
rawset(_G, "__kronosBo6Start", function()
  pcall(function() rawget(_G, "__kronosBo6LobbyHook")() end)
  pcall(function()
    local t = rawget(_G, "__kronosBo6Timer")
    if t and t:getParent() then return end
    t = LUI.UIElement.new()
    LUI.GetRoot():addElement(t)
    rawset(_G, "__kronosBo6Timer", t)
    local function tick()
      pcall(function() rawget(_G, "__kronosBo6LobbyHook")() end)
      t:Wait(250).onComplete = tick
    end
    tick()
  end)
end)
pcall(function() rawget(_G, "__kronosBo6Start")() end)
local function hookMemberOperator()
  local LB = rawget(_G, "Lobby"); if type(LB) ~= "table" then return end
  pcall(function() rawget(_G, "__kronosBo6LobbyHook")() end)
  local k
  for kk in pairs(LB) do if tostring(kk):find("c7a4448d4bcb7e3", 1, true) then k = kk end end
  local orig = k and LB[k]
  if type(orig) ~= "function" or memberWraps[orig] then return end
  local logged = false
  local wrap = function(ctrl, member, ...)
    local data = orig(ctrl, member, ...)
    if KRONOS_RETAIL_K1.stability.operatorBusy then return data end
    KRONOS_RETAIL_K1.stability.operatorBusy = true
    pcall(function()
      if not (type(data) == "table" and member and member.isMyPlayer and member.isMyPlayer:GetValue(ctrl)) then return end
      if not KRONOS_RETAIL_K1.stability.frontendIdle() then return end
      local od = OperatorData.new(ctrl, nil, nil, currentLoadoutGroup())
      if not (od and od[H("296e1ad6c0c05ba1")](od)) then return end
      local ops, skins, execs, sel = loadoutOperators(od)
      if not KRONOS_RETAIL_K1.stability.operators(ops, skins, execs, sel) then return end
      if sel and sel ~= -1 and member.selectedOperatorIndex then member.selectedOperatorIndex:SetValue(ctrl, sel) end
      pushOperators(ops, skins, execs, sel)
      data.operatorWest, data.operatorEast = ops[0], ops[1]
      data.skinWest, data.skinEast = skins[0], skins[1]
      data.execWest, data.execEast = execs[0], execs[1]
      if not logged then logged = true; L("lobby: local operator from loadout stats " .. tostring(ops[0]) .. " / " .. tostring(ops[1]) .. " side " .. tostring(sel)) end
    end)
    KRONOS_RETAIL_K1.stability.operatorBusy = false
    return data
  end
  memberWraps[wrap] = true
  LB[k] = wrap
  L("Lobby member operator hooked")
end
pcall(hookMemberOperator)

local selectPending = false
local lobbyStarted = false
local navWrapped = false
local function wrapNav()
  if navWrapped then return end
  local MN = rawget(_G, "MenuNavigator")
  if type(MN) ~= "table" or type(MN.QueueURIXHash) ~= "function" then return end
  navWrapped = true
  local orig = MN.QueueURIXHash
  MN.QueueURIXHash = function(uri, ctrl, ...)
    local parts = {}
    if type(uri) == "table" then for _, v in ipairs(uri) do parts[#parts+1] = tostring(v) end else parts[1] = tostring(uri) end
    local desc = table.concat(parts, " ")
    if KRONOS_RETAIL_K1.enabled and KRONOS_RETAIL_K1.inFrontend()
      and desc:find("89e9918304f5ed42", 1, true) then
      if getDvar("a8c1223b05ea8444") == "0" then
        KRONOS_RETAIL_K1.stability.zombiesDeferred = (KRONOS_RETAIL_K1.stability.zombiesDeferred or 0) + 1
        return
      end
    end
    syncOperatorProfile(type(ctrl) == "number" and ctrl or CTRL)
    if KRONOS_RETAIL_K1.enabled then
      if KRONOS_RETAIL_K1.inFrontend() and KRONOS_RETAIL_K1.isSavedRoute(uri) then
        if not KRONOS_RETAIL_K1.prepareRetailSaves(ctrl) then return KRONOS_RETAIL_K1.saveError("The original retail saved-game list is unavailable.") end
      end
      return orig(uri, ctrl, ...)
    end
    if desc:find("5581b8d8a3324627", 1, true) then return orig(uri, ctrl, ...) end
    if not lobbyStarted and desc:find("89e9918304f5ed42", 1, true) then
      local okf, fe = pcall(function() return Engine[H("112586a3f4fb490e")]() end)
      if okf and fe then
        local ready = getDvar("a8c1223b05ea8444")
        if getDvar("1a7df4fd209f52df") == "1" then lobbyStarted = true
        elseif ready ~= "0" then lobbyStarted = true; exec("xstartprivateparty")
        else L("private party waits for the online services (zm_party_ready 0)") end
      end
    end
    if desc:find("28569b8ec3df6286", 1, true) then selectPending = true end
    if desc:find("6f25f1422590a999", 1, true) then selectPending = true end
    if relicPending then
      relicPending = false
      L("relic nav -> ZMModeMaps")
      exec("luiOpenMenu ZMModeMaps")
      return
    end
    if desc:find("9085615e5535752", 1, true) then
      if goCmd or launching then
        L("save selection nav swallowed (in lobby)")
        return
      end
      if modeChosen then
        modeChosen = false
        L("save selection nav swallowed (mode already chosen)")
        return
      end
      if openSaves() then return end
    end
    if selectPending and not USE_REAL then
      selectPending = false
      L("Select Match -> ZMModes")
      exec("luiOpenMenu ZMModes")
      return
    end
    return orig(uri, ctrl, ...)
  end
  local LK = H("648aaac93d066f47")
  local origLeave = MN[LK]
  if type(origLeave) == "function" then
    MN[LK] = function(...)
      if KRONOS_RETAIL_K1.enabled then return origLeave(...) end
      local r = origLeave(...)
      if relicPending then
        relicPending = false
        L("relics confirmed -> ZMModeMaps")
        exec("luiOpenMenu ZMModeMaps")
      end
      return r
    end
  end
  L("MenuNavigator.QueueURIXHash wrapped")
end

USE_REAL = true
pcall(function()
  local k
  for kk in pairs(Lobby) do if tostring(kk):find("0be6e03a0292da533", 1, true) then k = kk end end
  if k then
    local origSet = Lobby[k]
    Lobby[k] = function(field, val, ...)
      local PD = Lobby.PartyUIData
      if PD and field == PD.PLAYLIST_ID then selectPending = true; wrapNav() end
      return origSet(field, val, ...)
    end
    L("Lobby playlist setter hooked")
  end
end)
function KRONOS_RETAIL_K1.inFrontend()
  local fn = Engine and (Engine.InFrontend or Engine[H("112586a3f4fb490e")])
  if type(fn) ~= "function" then return false end
  local ok, value = pcall(fn)
  return ok and value == true
end
function KRONOS_RETAIL_K1.savedEntries()
  local rows = {}
  local start = rawget(_G, "LUMEN_ZM_LOCAL_START")
  if not (KRONOS_RETAIL_K1.enabled and KRONOS_RETAIL_K1.inFrontend()
    and type(start) == "table" and type(start.resolveSavedGame) == "function") then return rows end
  for _, map in ipairs(SAVEORDER) do
    local gt = getDvar(SAVEMAP[map])
    if gt ~= "" and gt ~= "nil" and gt:match("^[%w_]+$") then
      local ok, record = pcall(start.resolveSavedGame, map, gt)
      if ok and type(record) == "table" then
        rows[#rows + 1] = { map = map, gt = gt, record = record,
          label = (SAVENAMES[map] or map) .. " - " .. (record.label or gt) }
      end
    end
  end
  return rows
end
function KRONOS_RETAIL_K1.resumeDeadOpsEntry(entry, controller)
  local K = KRONOS_RETAIL_K1
  if not K.inFrontend() then return K.saveError("Return to the Zombies menu before resuming a save.") end
  if type(entry) ~= "table" or not SAVEMAP[entry.map] or getDvar(SAVEMAP[entry.map]) ~= entry.gt then
    return K.saveError("This saved-game entry changed. Open Continue Saved Game again.")
  end
  local start = rawget(_G, "LUMEN_ZM_LOCAL_START")
  if type(start) ~= "table" or type(start.resumeSavedGame) ~= "function" then
    return K.saveError("The M7 resume adapter is not ready.")
  end
  if start.request then return K.saveError("A match is already being started.") end
  controller = controller or CTRL
  L("K8 save selected map=" .. entry.map .. " gt=" .. entry.gt)
  local previousHost = start.host
  local ok, accepted, reason = pcall(start.resumeSavedGame, controller, entry.map, entry.gt,
    function()
      local getRoot = Engine and Engine[H("3ee6f69fea944b13")]
      local host = type(getRoot) == "function" and getRoot()
      if host == nil or type(host.CreateEventTimer) ~= "function" or type(host.RemoveEventTimer) ~= "function" then
        error("The live frontend timer is unavailable; no match was started.", 0)
      end
      start.host = host
    end)
  if not ok or accepted ~= true then
    start.host = previousHost
    return K.saveError("The saved match was not started. " .. tostring(reason or accepted or ""))
  end
  local request = start.request
  local ordered, lobbyStep = {}, nil
  for _, step in ipairs(request.steps) do
    if step.kind == "original_lobby" then lobbyStep = step
    else
      ordered[#ordered + 1] = step
      if step.kind == "gametype" and lobbyStep then
        ordered[#ordered + 1] = lobbyStep; lobbyStep = nil
      end
    end
  end
  request.steps = ordered
  local traced, traceError = pcall(K.traceResume, request)
  if not traced then L("K8 resume trace unavailable: " .. tostring(traceError)) end
  L("K8 resume queued; live_timer=" .. tostring(request.host ~= nil))
  return true
end
function KRONOS_RETAIL_K1.prepareResumeLobby(request)
  local K = KRONOS_RETAIL_K1
  local start = rawget(_G, "LUMEN_ZM_LOCAL_START")
  if not start or start.request ~= request or not request.resume or not K.inFrontend() then return false end
  if getDvar(DV_MAP) ~= request.record.map then return false end
  local previousMap = getDvar("bcf6d292629632eb")
  setDvar("bcf6d292629632eb", request.record.map)
  if getDvar("bcf6d292629632eb") ~= request.record.map then return false end
  if not K.prepareSaveContext(request.record.map, request.asset, request.resume) then
    setDvar("bcf6d292629632eb", previousMap)
    return false
  end
  if K.saveLaunch.previousGmap == nil then K.saveLaunch.previousGmap = previousMap end
  L("K8 native saved context ready before lobby; load=" .. getDvar(SAVEDV.load))
  return true
end
function KRONOS_RETAIL_K1.traceResume(request)
  local K = KRONOS_RETAIL_K1
  local start = rawget(_G, "LUMEN_ZM_LOCAL_START")
  local host, event = request.host, H("82f4819713fc9cb4")
  if not host then return end
  local last, elapsed = nil, 0
  host:CreateEventTimer(event, 500, { immediate = false, callbackFunc = function()
    elapsed = elapsed + 500
    local state = start.request == request and (tostring(start.phase) .. ":" .. tostring(request.step)) or "ended"
    if state ~= last then L("K8 resume state=" .. state .. " load=" .. getDvar(SAVEDV.load)); last = state end
    if state == "ended" or not K.inFrontend() or elapsed >= 121000 then host:RemoveEventTimer(event) end
  end })
end


function KRONOS_RETAIL_K1.cancelNativeResume(request, reason, show)
  local K = KRONOS_RETAIL_K1
  if K.nativeResume ~= request then return end
  if request.inStart then
    request.cancelledReason = reason
    request.cancelledShow = show
    L("K9 native setup interrupted: " .. tostring(reason))
    return
  end
  if request.hudRepair then
    pcall(request.hudRepair.finishNativeSavedGame, request, request.loaded == true)
  end
  K.nativeResume = nil
  if request.host then pcall(request.host.RemoveEventTimer, request.host, H("82f4819713fc9cb4")) end
  if not request.submitted and request.ownedLoad and getDvar(SAVEDV.slot) == request.map
    and getDvar(SAVEDV.load) == request.ownedLoad then
    setDvar(SAVEDV.slot, request.previous[1]); setDvar(SAVEDV.gt, request.previous[2]); setDvar(SAVEDV.load, request.previous[3])
    if getDvar("bcf6d292629632eb") == request.map then setDvar("bcf6d292629632eb", request.previous[4]) end
  end
  goCmd = nil
  L("K9 resume ended: " .. tostring(reason))
  if show then K.saveError(reason) end
end
function KRONOS_RETAIL_K1.armNativeResume(request)
  local K = KRONOS_RETAIL_K1
  if K.nativeResume ~= request then return false end
  local getter = Engine and Engine[H("3ee6f69fea944b13")]
  local host = type(getter) == "function" and getter()
  if host == nil or type(host.CreateEventTimer) ~= "function" or type(host.RemoveEventTimer) ~= "function" then return false end
  if request.host == host then return true end
  if request.host then pcall(request.host.RemoveEventTimer, request.host, H("82f4819713fc9cb4")) end
  request.host = host
  host:CreateEventTimer(H("82f4819713fc9cb4"), 100, { immediate = false, callbackFunc = function()
    if K.nativeResume ~= request or request.host ~= host then return end
    local ok, errorMessage = pcall(K.tickNativeResume, request)
    if not ok then K.cancelNativeResume(request, "Saved-game launch error: " .. tostring(errorMessage), true) end
  end })
  return true
end
function KRONOS_RETAIL_K1.tickNativeResume(request)
  local K = KRONOS_RETAIL_K1
  if K.nativeResume ~= request or request.inStart then return end
  request.elapsed = request.elapsed + 100
  if not K.inFrontend() then
    if request.submitted then
      K.savePending = nil; request.loaded = true
      K.cancelNativeResume(request, "Native saved launch left the frontend.", false)
    else K.cancelNativeResume(request, "Another match left the frontend.", false) end
    return
  end
  local core = rawget(_G, "LUMEN_ZM_LOCAL_START")
  if not K.enabled or (core and core.request) then K.cancelNativeResume(request, "A different match was selected.", false); return end
  if request.submitted then
    if request.elapsed >= 120000 then K.cancelNativeResume(request, "The native saved launch stayed in the lobby. See poi_reg.log.", true) end
    return
  end
  if getDvar(SAVEMAP[request.map]) ~= request.gt then K.cancelNativeResume(request, "The saved-game entry changed.", true); return end
  local readType = Game and Game[H("c99ee7ec93255cc0")]
  local actual = type(readType) == "function" and readType()
  local expected = type(CLUA) == "table" and type(CLUA.PushXHashAsset) == "function" and CLUA.PushXHashAsset(request.asset)
  local ready = request.lobbyBuilt and getDvar(DV_MAP) == request.map and
    getDvar("bcf6d292629632eb") == request.map and getDvar(SAVEDV.slot) == request.map and
    getDvar(SAVEDV.gt) == getDvar(DV_GT) and getDvar(SAVEDV.load) == request.ownedLoad and
    (actual == request.asset or (expected ~= false and expected ~= nil and actual == expected))
  if ready and request.elapsed >= 6000 then request.stable = request.stable + 100 else request.stable = 0 end
  if request.stable >= 500 then
    local command = request.command
    if request.hudRepair then
      local prefix = command:match("^(.-)xpartygo$")
      if prefix == nil then
        K.cancelNativeResume(request, "Unexpected Dead Ops saved launch command; no match was started.", true); return
      end
      if prefix ~= "" and Engine[H(EXEC)](prefix, request.controller) == false then
        K.cancelNativeResume(request, "Dead Ops saved launch preparation was rejected.", true); return
      end
      local ok, accepted = pcall(request.hudRepair.prepareNativeSavedGame, request)
      if not ok or accepted ~= true then
        K.cancelNativeResume(request, "The original Dead Ops HUD gate could not be prepared; no match was started.", true); return
      end
      command = "xpartygo"
    end
    request.submitted = true; launching = true
    L("K10 native saved launch: map=" .. request.map .. " load=" .. request.ownedLoad)
    local result = Engine[H(EXEC)](command, request.controller)
    if result == false then request.submitted = false; K.cancelNativeResume(request, "The native Start Match command was rejected.", true) end
  elseif request.elapsed >= 30000 then
    K.cancelNativeResume(request, "The saved lobby did not become ready. map=" .. getDvar(DV_MAP) .. " type=" .. tostring(actual) .. " load=" .. getDvar(SAVEDV.load), true)
  end
end
function KRONOS_RETAIL_K1.resumeEntry(entry, controller)
  local K = KRONOS_RETAIL_K1
  if not K.inFrontend() then return K.saveError("Return to the Zombies menu before resuming a save.") end
  if type(entry) ~= "table" or not SAVEMAP[entry.map] or getDvar(SAVEMAP[entry.map]) ~= entry.gt then
    return K.saveError("This saved-game entry changed. Open Continue Saved Game again.")
  end
  local core = rawget(_G, "LUMEN_ZM_LOCAL_START")
  if K.nativeResume or (core and core.request) then return K.saveError("A match is already being started.") end
  local record = core and type(core.resolveSavedGame) == "function" and core.resolveSavedGame(entry.map, entry.gt)
  if not record then return K.saveError("This saved map or mode is unavailable.") end
  local request = { id = record.id, map = entry.map, gt = entry.gt, asset = record.asset, controller = controller or CTRL,
    entry = { cont = true }, elapsed = 0, stable = 0, inStart = false,
    previous = { getDvar(SAVEDV.slot), getDvar(SAVEDV.gt), getDvar(SAVEDV.load), getDvar("bcf6d292629632eb") } }
  K.nativeResume = request; CTRL = request.controller; goCmd = nil
  if request.asset == "zm_ztron" then
    local repair = rawget(_G, "LUMEN_DEAD_OPS_HUD_REPAIR")
    local ok, accepted = pcall(function()
      return repair and type(repair.beginNativeSavedGame) == "function" and repair.beginNativeSavedGame(request)
    end)
    if not ok or accepted ~= true then
      K.cancelNativeResume(request, "The Dead Ops saved-HUD bridge is unavailable. Update both K10 Lua files.", true)
      return false
    end
    request.hudRepair = repair
  end
  if not K.armNativeResume(request) then
    K.cancelNativeResume(request, "The live frontend timer is unavailable; no match was started.", true)
    return false
  end
  L("K9 original Kronos saved start: map=" .. request.map .. " gt=" .. request.gt)
  request.inStart = true
  local ok, errorMessage = pcall(start, request.map, request.gt, nil, nil, request.entry)
  request.inStart = false
  request.command = goCmd; goCmd = nil
  local load = getDvar(SAVEDV.load)
  if getDvar(SAVEDV.slot) == request.map and load:match("^1:%d+$") then request.ownedLoad = load end
  if K.nativeResume ~= request then return false end
  if request.cancelledReason then
    K.cancelNativeResume(request, request.cancelledReason, request.cancelledShow)
    return false
  end
  if not ok or not request.command or not request.ownedLoad then
    K.cancelNativeResume(request, "Kronos could not prepare the saved match. " .. tostring(errorMessage or ""), true)
    return false
  end
  K.savePending = nil
  L("K9 native context prepared: slot=" .. request.map .. " load=" .. request.ownedLoad)
  return true
end

function KRONOS_RETAIL_K1.isSavedRoute(uri)
  local wanted = H("39085615e5535752")
  if type(uri) == "table" then
    for _, value in ipairs(uri) do if value == wanted then return true end end
    return false
  end
  return uri == wanted
end
do
  local K = KRONOS_RETAIL_K1
  local hooks = K.retailSaveHooks or {}
  K.retailSaveHooks = hooks
  hooks.rows = hooks.rows or {}
  hooks.aggregate = hooks.aggregate or setmetatable({}, { __mode = "k" })
  local function active() return K.enabled == true and K.inFrontend() end
  local function member(object, key)
    if object == nil then return nil end
    local ok, value = pcall(function() return object[key] end)
    return ok and value or nil
  end
  local function part(object, hex) return member(object, H(hex)) end
  local function value(source, controller)
    local get = member(source, "GetValue")
    if type(get) ~= "function" then return nil end
    local ok, result = pcall(get, source, controller)
    return ok and result or nil
  end
  local function put(source, controller, result)
    local set = member(source, "SetValue")
    if type(set) ~= "function" then return false end
    local ok = pcall(set, source, controller, result)
    return ok
  end
  local function root()
    return part(part(part(rawget(_G, "_DataSources"), "f71428806887f67d"),
      "1ccae3b6ef72f533"), "bd833b0a045cd479")
  end
  local function selected(controller)
    local detail = part(root(), "57451b55f9f57278")
    local index = value(part(detail, "e6c9a28b6b34cf30"), controller)
    local rows = hooks.rows[controller]
    return type(index) == "number" and rows and rows[index] or nil
  end
  local function display(entry, controller)
    local query = part(rawget(_G, "PlaylistUtils"), "0d5bbfe3c6067a59")
    local info
    if type(query) == "function" then
      local ok, result = pcall(query, controller, entry.record.id)
      if ok then info = result end
    end
    entry.playMenuRef = value(member(info, "playMenuRef"), controller) or ""
    entry.mapValue = value(member(info, "mapName"), controller) or entry.map
    local getInfo = part(rawget(_G, "PLAY_MENU"), "15b97d8cf426b333")
    local page
    if entry.playMenuRef ~= "" and type(getInfo) == "function" then
      local ok, result = pcall(getInfo, entry.playMenuRef)
      if ok then page = result end
    end
    local sl = rawget(_G, "SAVELOAD")
    for _, spec in ipairs({ { "icon", "e59edf4aa63ee0ff" }, { "background", "0e56ceb4f33001f3" } }) do
      local fn = part(sl, spec[2])
      local ok, result = false, nil
      if type(fn) == "function" then ok, result = pcall(fn, page) end
      entry[spec[1]] = ok and result or part(rawget(_G, "CoD"), "661ab9581e6bcb7e") or H("0000000000000000")
    end
    return entry
  end
  local fields = {
    { "89f104c229d41151", function(entry) return entry and entry.record.label or "" end },
    { "534fdb3db03de428", function() return "" end },
    { "39f7fcec8fcb623d", function(entry) return entry and entry.label or "" end },
    { "89d7d53c87433307", function(entry) return entry and entry.mapValue or H("0000000000000000") end },
    { "27bcf3f1bd325909", function(entry) return entry and entry.playMenuRef or "" end },
    { "44d35ec7c8da72bf", function(entry) return entry and entry.background or H("0000000000000000") end },
  }
  local function bind(detail)
    for _, spec in ipairs(fields) do
      local source = part(detail, spec[1])
      local original = member(source, "_aggregateFunction")
      if source == nil or type(original) ~= "function" or type(member(source, "SetValue")) ~= "function" then return false end
      local previous = hooks.aggregate[source]
      if not previous or original ~= previous.wrapper then
        local reader = spec[2]
        local wrapper = function(controller, ...)
          if active() then return reader(selected(controller)) end
          return original(controller, ...)
        end
        local ok = pcall(function() source._aggregateFunction = wrapper end)
        if not ok or member(source, "_aggregateFunction") ~= wrapper then return false end
        hooks.aggregate[source] = { original = original, wrapper = wrapper }
      end
    end
    return true
  end
  function K.selectRetailSave(controller, index)
    if not active() then return false end
    local rows = hooks.rows[controller]
    local detail = part(root(), "57451b55f9f57278")
    if not rows or not detail or (index ~= 0 and not rows[index]) then return false end
    local entry = rows[index]
    if entry and getDvar(SAVEMAP[entry.map]) ~= entry.gt then return false end
    if not put(part(detail, "e6c9a28b6b34cf30"), controller, index) then return false end
    for _, spec in ipairs(fields) do
      if not put(part(detail, spec[1]), controller, spec[2](entry)) then return false end
    end
    put(part(detail, "f59c40e341ae6f97"), controller, false)
    return true
  end
  function K.prepareRetailSaves(controller)
    if not active() then return false end
    controller = type(controller) == "number" and controller or CTRL
    if hooks.preparing then return false end
    hooks.preparing = true
    local ok, result = pcall(function()
      local parent = root()
      local detail = part(parent, "57451b55f9f57278")
      local array = part(parent, "09baebde664a4829")
      local count = part(array, "b1e5e28e4479a274")
      if not parent or not array or not detail or type(member(count, "SetValue")) ~= "function" or not bind(detail) then return false end
      local rows = K.savedEntries()
      local old = selected(controller)
      local previous = hooks.rows[controller] or {}
      local makeCommand = LUI and LUI.Command and LUI.Command.new
      if type(makeCommand) ~= "function" then return false end
      local rowSources = {}
      local keys = { "c12270a26097e1c0", "dbff4cc56c2092f0", "39f7fcec8fcb623d", "51573f49a6333a48", "66655dca2c3e8a12" }
      for index = 1, math.max(#rows, #previous) do
        local row = member(array, index)
        if not row then return false end
        for _, key in ipairs(keys) do
          if type(member(part(row, key), "SetValue")) ~= "function" then return false end
        end
        rowSources[index] = row
      end
      for _, entry in ipairs(rows) do display(entry, controller) end
      hooks.rows[controller] = rows
      local first = #rows > 0 and 1 or 0
      for index, row in ipairs(rowSources) do
        local entry = rows[index]
        local command, focus
        if entry then
          local chosen = entry
          command = makeCommand(function() return K.resumeEntry(chosen, controller) end, function()
            local start = rawget(_G, "LUMEN_ZM_LOCAL_START")
            return active() and getDvar(SAVEMAP[chosen.map]) == chosen.gt and not (start and start.request) and not K.nativeResume
          end)
          focus = function() return K.selectRetailSave(controller, index) end
          if old and old.map == entry.map and old.gt == entry.gt then first = index end
        else
          command = makeCommand(function() return false end, function() return false end)
        end
        if not put(part(row, "c12270a26097e1c0"), controller, H("0000000000000000"))
          or not put(part(row, "dbff4cc56c2092f0"), controller, entry and entry.icon or H("0000000000000000"))
          or not put(part(row, "39f7fcec8fcb623d"), controller, entry and entry.label or "")
          or not put(part(row, "51573f49a6333a48"), controller, focus)
          or not put(part(row, "66655dca2c3e8a12"), controller, command) then return false end
      end
      if not K.selectRetailSave(controller, first) then return false end
      if not put(part(parent, "0e8e41824485f602"), controller, #rows > 0) then return false end
      local list = part(array, "3eb72f3d9e8ec417")
      local setCount = member(list, "SetCount")
      if type(setCount) == "function" then
        setCount(list, controller, #rows)
      elseif not put(count, controller, #rows) then return false end
      if value(count, controller) ~= #rows then return false end
      for index, entry in ipairs(rows) do
        if value(part(rowSources[index], "39f7fcec8fcb623d"), controller) ~= entry.label then return false end
      end
      return true
    end)
    hooks.preparing = nil
    if not ok then L("K5 retail saves data error: " .. tostring(result)) end
    return ok and result == true
  end
  function K.openSavedGames(controller)
    if not active() then return false end
    controller = type(controller) == "number" and controller or CTRL
    K.installSaveNavigation()
    if not K.prepareRetailSaves(controller) then return K.saveError("The original retail saved-game data sources are not ready. No match was started.") end
    local navigator = rawget(_G, "MenuNavigator")
    local queue = member(navigator, "QueueURIXHash")
    if type(queue) ~= "function" then return K.saveError("The original saved-game navigation is unavailable.") end
    local ok, result = pcall(queue, { H("af63a34c86018bb1"), H("39085615e5535752") }, controller)
    if not ok or result == false then return K.saveError("The original retail saved-game screen could not be opened.") end
    L("K5 original ZMSaveSelectionMenu requested")
    return true
  end
  hooks.completed = hooks.completed or setmetatable({}, { __mode = "k" })
  function K.completeRetailSaveScreen(page, controller)
    if not active() or page == nil then return false end
    if hooks.completed[page] then return true end
    controller = type(controller) == "number" and controller or CTRL
    if not K.prepareRetailSaves(controller) then return K.saveError("The saved-game list did not finish updating. No match was started.") end
    local dispatch = member(page, "processEvent")
    if type(dispatch) ~= "function" then return K.saveError("The original saved-game refresh handler is unavailable.") end
    local event = { name = H("585180e0288bc796"), controller = controller }
    local makeTimer = LUI and LUI.UITimer and LUI.UITimer.new
    local add = member(page, "addElement")
    if type(makeTimer) == "function" and type(add) == "function" then
      local ok, reason = pcall(function()
        local timer = makeTimer({ interval = 50, broadcastToRoot = false,
          disposable = true, event = event, eventTarget = page })
        if timer == nil then error("The saved-game refresh timer was not created.") end
        add(page, timer)
      end)
      if not ok then return K.saveError("The original saved-game refresh could not be scheduled. " .. tostring(reason)) end
      hooks.completed[page] = true
      L("K6 retail saved-game completion event queued; rows=" .. tostring(#(hooks.rows[controller] or {})))
      return true
    end
    local ok, reason = pcall(dispatch, page, event)
    if not ok then return K.saveError("The original saved-game refresh failed. " .. tostring(reason)) end
    hooks.completed[page] = true
    L("K6 retail saved-game completion event dispatched")
    return true
  end
  local function wrap(sl, key, replacement)
    local original = part(sl, key)
    local record = hooks[key]
    if type(original) ~= "function" or (record and original == record.wrapper) then return end
    local wrapper = function(...)
      if active() then return replacement(...) end
      return original(...)
    end
    hooks[key] = { original = original, wrapper = wrapper }
    sl[H(key)] = wrapper
  end
  function K.installSaveNavigation()
    local sl = rawget(_G, "SAVELOAD")
    if type(sl) == "table" then
      local commandKey = H("0287dc1b88142872")
      local makeCommand = LUI and LUI.Command and LUI.Command.new
      if K.enabled and type(makeCommand) == "function" and (not hooks.continueCommand or sl[commandKey] ~= hooks.continueCommand) then
        hooks.originalContinue = sl[commandKey]
        hooks.continueCommand = makeCommand(function(controller) return K.openSavedGames(controller) end,
          function() return active() and #K.savedEntries() > 0 end)
        sl[commandKey] = hooks.continueCommand
      elseif not K.enabled and hooks.continueCommand and sl[commandKey] == hooks.continueCommand then
        sl[commandKey] = hooks.originalContinue
      end
      wrap(sl, "4774a7cb1af5f010", function(controller)
        controller = type(controller) == "number" and controller or CTRL
        local rows = K.savedEntries()
        local cached = hooks.rows[controller]
        local changed = cached and #cached ~= #rows
        if cached and not changed then
          for index, entry in ipairs(rows) do
            if cached[index].map ~= entry.map or cached[index].gt ~= entry.gt then changed = true; break end
          end
        end
        if changed and not hooks.preparing then K.prepareRetailSaves(controller) end
        return #rows > 0
      end)
      wrap(sl, "148368799cba5b75", K.openSavedGames)
      wrap(sl, "99e8289745364225", function(controller)
        if not K.prepareRetailSaves(controller) then return K.saveError("The retail saved-game list could not be updated.") end
      end)
      wrap(sl, "141d8979cd7d7f02", function(controller)
        if not K.prepareRetailSaves(controller) then return false end
        return #K.savedEntries() == 0
      end)
    end
    local builder = rawget(_G, "MenuBuilder") or (LUI and LUI.MenuBuilder)
    local build = builder and builder.BuildRegisteredType
    if type(build) == "function" and build ~= hooks.buildMenu then
      local function pack(...) return { n = select("#", ...), ... } end
      hooks.buildMenu = function(name, options, ...)
        K.stability.season()
        K.stability.historyCondition()
        local request = K.nativeResume
        local savedLobby = request and active() and
          (name == H("5581b8d8a3324627") or name == "zmpubliclobby" or name == "ZMPublicLobby")
        if savedLobby then
          local result = pack(pcall(build, name, options, ...))
          if not result[1] then
            K.cancelNativeResume(request, "Original lobby construction failed: " .. tostring(result[2]), false)
            error(result[2], 0)
          end
          request.lobbyBuilt = result[2] ~= nil
          K.armNativeResume(request)
          L("K9 original saved lobby built")
          return unpack(result, 2, result.n)
        end
        local start = rawget(_G, "LUMEN_ZM_LOCAL_START")
        local request = type(start) == "table" and start.request
        local resumeLobby = request and request.resume and active() and
          (name == H("5581b8d8a3324627") or name == "zmpubliclobby" or name == "ZMPublicLobby")
        if resumeLobby then
          if not K.prepareResumeLobby(request) then error("K8 saved lobby preparation was rejected.", 0) end
          local result = pack(pcall(build, name, options, ...))
          if not result[1] then
            L("K8 lobby build failed: " .. tostring(result[2]))
            error(result[2], 0)
          end
          L("K8 original saved lobby built")
          return unpack(result, 2, result.n)
        end
        local result = pack(build(name, options, ...))
        if K.isSavedRoute(name) and active() and result[1] ~= nil then
          local controller = member(options, "controllerIndex") or CTRL
          K.completeRetailSaveScreen(result[1], controller)
        end
        return unpack(result, 1, result.n)
      end
      builder.BuildRegisteredType = hooks.buildMenu
    end
    local flow = LUI and LUI.FlowManager
    local original = flow and flow.RequestAddMenu
    if type(original) == "function" and original ~= hooks.addMenu then
      hooks.addMenu = function(name, parent, controller, ...)
        if active() and K.isSavedRoute(name) then
          if not K.prepareRetailSaves(controller) then return K.saveError("The original retail saved-game list is unavailable.") end
        end
        local pending = K.nativeResume
        if pending and not pending.inStart and not pending.submitted and
          (name == H("89e9918304f5ed42") or name == "zmmainmenu" or name == "ZMMainMenu") then
          K.cancelNativeResume(pending, "Returned to the Zombies menu.", false)
        end
        return original(name, parent, controller, ...)
      end
      flow.RequestAddMenu = hooks.addMenu
    end
  end
end

function KRONOS_RETAIL_K1.prepareSaveContext(map, asset, resume)
  if not KRONOS_RETAIL_K1.enabled then return true end
  if type(map) ~= "string" or getDvar(DV_MAP) ~= map then return false end
  if not SAVEMAP[map] then return not resume end -- ported maps have no native save slot
  local gt = getDvar(DV_GT)
  if gt == "" or gt == "nil" or not gt:match("^[%w_]+$") then return false end
  if resume and (type(resume) ~= "table" or resume.map ~= map or resume.asset ~= asset
    or not SAVEMAP[map] or getDvar(SAVEMAP[map]) ~= resume.savedgt) then return false end
  local previous = { getDvar(SAVEDV.slot), getDvar(SAVEDV.gt), getDvar(SAVEDV.load) }
  local owned = KRONOS_RETAIL_K1.saveLaunch
  if resume and owned and owned.resume == resume and owned.map == map and owned.asset == asset
    and owned.gt == gt and owned.load == previous[3] and previous[1] == map and previous[2] == gt then return true end
  local generation = tonumber(previous[3]:match(":(%d+)$")) or 0
  if generation >= 2147483646 then generation = 0 end
  generation = generation + 1
  local load = (resume and "1:" or "0:") .. generation
  setDvar(SAVEDV.slot, map); setDvar(SAVEDV.gt, gt); setDvar(SAVEDV.load, load)
  if getDvar(SAVEDV.slot) ~= map or getDvar(SAVEDV.gt) ~= gt or getDvar(SAVEDV.load) ~= load then
    setDvar(SAVEDV.slot, previous[1]); setDvar(SAVEDV.gt, previous[2]); setDvar(SAVEDV.load, previous[3])
    return false
  end
  KRONOS_RETAIL_K1.saveLaunch = { map = map, asset = asset, gt = gt, load = load, previous = previous, resume = resume }
  KRONOS_RETAIL_K1.savePending = nil
  L("K4 save context slot=" .. map .. " gt=" .. gt .. " load=" .. load)
  return true
end
function KRONOS_RETAIL_K1.cancelSaveLaunch(request)
  local owned = KRONOS_RETAIL_K1.saveLaunch
  if not owned or type(request) ~= "table" or request.record.map ~= owned.map or request.asset ~= owned.asset then return end
  if getDvar(SAVEDV.slot) == owned.map and getDvar(SAVEDV.gt) == owned.gt and getDvar(SAVEDV.load) == owned.load then
    setDvar(SAVEDV.slot, owned.previous[1]); setDvar(SAVEDV.gt, owned.previous[2]); setDvar(SAVEDV.load, owned.previous[3])
    if owned.resume and owned.previousGmap ~= nil and getDvar("bcf6d292629632eb") == owned.map then
      setDvar("bcf6d292629632eb", owned.previousGmap)
    end
  end
  KRONOS_RETAIL_K1.saveLaunch = nil
end
function KRONOS_RETAIL_K1.acceptSaveLaunch(request)
  local owned = KRONOS_RETAIL_K1.saveLaunch
  if owned and type(request) == "table" and request.record.map == owned.map and request.asset == owned.asset then
    KRONOS_RETAIL_K1.saveLaunch = nil
  end
end
function KRONOS_RETAIL_K1.saveContextReady()
  if not KRONOS_RETAIL_K1.enabled or mapMode() ~= "zm" then return false end
  local map, gt, load = getDvar(DV_MAP), getDvar(DV_GT), getDvar(SAVEDV.load)
  return SAVEMAP[map] ~= nil and gt ~= "" and gt ~= "nil" and gt:match("^[%w_]+$") ~= nil
    and getDvar(SAVEDV.slot) == map and getDvar(SAVEDV.gt) == gt and load:match("^[01]:%d+$") ~= nil
end
function KRONOS_RETAIL_K1.allowSaveDispatch()
  return KRONOS_RETAIL_K1.saveDispatch == true and KRONOS_RETAIL_K1.saveContextReady()
end
function KRONOS_RETAIL_K1.saveError(message)
  L("K4 saved game: " .. tostring(message))
  pcall(function() LUI.FlowManager.RequestErrorPopup(CTRL, "Saved Game", message) end)
  return false
end
function KRONOS_RETAIL_K1.dispatchSave()
  if KRONOS_RETAIL_K1.savePending or KRONOS_RETAIL_K1.saveDispatch then return false end
  if not KRONOS_RETAIL_K1.saveContextReady() then
    return KRONOS_RETAIL_K1.saveError("Kronos save context is unavailable. The match has not been ended.")
  end
  KRONOS_RETAIL_K1.saveDispatch = true
  KRONOS_RETAIL_K1.saveGuardPassed = false
  local ok, result = pcall(function() return Engine[H("76055c55456f05df")]("save_and_end_game", 77) end)
  KRONOS_RETAIL_K1.saveDispatch = nil
  local guard = rawget(_G, "LUMEN_ZM_SAVE_GUARD")
  local passed = not guard or KRONOS_RETAIL_K1.saveGuardPassed == true
  KRONOS_RETAIL_K1.saveGuardPassed = nil
  if not ok or result == false or not passed then
    return KRONOS_RETAIL_K1.saveError("The save request was not accepted. The match has not been ended. " .. tostring(result or ""))
  end
  KRONOS_RETAIL_K1.savePending = true
  local flagOk, flagError = pcall(function() Dvar[H("f2414681ecab880f")](H("be9a1a5090f1172b", 1), 1) end)
  local flagValue = getDvar("be9a1a5090f1172b")
  if not flagOk or (flagValue ~= "1" and flagValue ~= "true") then
    return KRONOS_RETAIL_K1.saveError("The save request was sent, but the end-game flag could not be confirmed. " .. tostring(flagError or ""))
  end
  L("K4 native Save & Quit requested")
  LUI.FlowManager.RequestCloseAllMenus()
  return true
end
local zmSaveCmd
local function forceSaveAndQuit()
  pcall(KRONOS_RETAIL_K1.installSaveNavigation)
  if not KRONOS_RETAIL_K1.deadOps() then
  pcall(function()
    local G = rawget(_G, "GameType")
    local key = H("a8243313b1df0892")
    if type(G) ~= "table" or type(G[key]) ~= "function" or G[key] == _G.__squadSizeFn then return end
    if mapMode() ~= "zm" then return end
    local orig = G[key]
    _G.__squadSizeFn = function(...)
      if KRONOS_RETAIL_K1.deadOps() then return orig(...) end
      return math.max(tonumber(orig(...)) or 0, 4)
    end
    G[key] = _G.__squadSizeFn
    L("zm hud: squad size at least 4 for the team HUD")
  end)
  pcall(function()
    local C = rawget(_G, "CONDITIONS")
    local key = H("1bf28872ec613d75")
    if type(C) ~= "table" or type(C[key]) ~= "function" or C[key] == _G.__coopPauseFn then return end
    local orig = C[key]
    _G.__coopPauseFn = function(...)
      if KRONOS_RETAIL_K1.deadOps() then return orig(...) end
      if (tonumber(getDvar("5012c838382353c1")) or 0) > 1 then return false end
      return orig(...)
    end
    C[key] = _G.__coopPauseFn
    L("pause menu no longer pauses with more than one player")
  end)
  pcall(function()
    if mapMode() ~= "zm" then return end
    local essence = {}
    local function essenceOf(slot)
      local ds = essence[slot]
      if ds == nil then
        local ok, made = pcall(function() return LUI.DataSourceFromOmnvar.new("ui_zm_essence_squad_index_" .. slot) end)
        ds = ok and made or false
        essence[slot] = ds
      end
      if not ds then return 0 end
      local ok, v = pcall(function() return ds:GetValue(CTRL) end)
      return ok and tonumber(v) or 0
    end
    _G.__kronosTeam = function()
      local raw = getDvar("06ee0d4dce670d44") or ""
      local self = tonumber(getDvar("d47661d31ca7537b")) or -1
      local others, slot = {}, 0
      for score, name in raw:gmatch("(%-?%d+)|([^;]*);") do
        local sc = tonumber(score) or -1
        local tag, op = name:match("^(.*)/([^/]*)$")
        if op == "" then op = nil end
        if sc >= 0 and slot ~= self then others[#others + 1] = { slot = slot, score = essenceOf(slot), name = tag or name, op = op, client = sc } end
        slot = slot + 1
      end
      return others
    end
    local t = rawget(_G, "__kronosTeamFeed")
    if t and t:getParent() then return end
    t = LUI.UIElement.new()
    LUI.GetRoot():addElement(t)
    _G.__kronosTeamFeed = t
    local last, widget
    local searches = 0
    local function find(e)
      if type(e.RebuildSquadWidgetData) == "function" then return e end
      local c = e:getFirstChild()
      while c do
        local hit = find(c)
        if hit then return hit end
        c = c:getNextSibling()
      end
    end
    local function tick()
      local ok, e = pcall(function()
        if KRONOS_RETAIL_K1.deadOps() then return end
        local tl = DataSources.inGame.player.teamList
        if not tl then return end
        local others = _G.__kronosTeam()
        local sig = ""
        for k = 1, 3 do local o = others[k] sig = sig .. (o and (o.slot .. o.name .. (o.op or "")) or "-") .. ";" end
        local fresh = false
        if not (widget and widget:getParent()) then
          searches = searches + 1
          widget = nil
          if searches % 10 == 1 then
            widget = find(LUI.GetRoot())
            fresh = widget ~= nil
          end
        end
        if sig == last and not fresh then return end
        last = sig
        for k = 1, 3 do
          local it = tl:GetDataSourceAtIndex(k - 1, CTRL)
          local o = others[k]
          it.gamerTag:SetValue(CTRL, o and o.name or "")
          it.squadIndex:SetValue(CTRL, o and o.slot or -1)
          if o and o.op then pcall(function() it.operatorRef:SetValue(CTRL, o.op) end) end
          pcall(function() it.clientNum:SetValue(CTRL, o and o.client or -1) end)
        end
        if widget then
          if widget._maxNumGridWidgets ~= 3 then
            local grid = widget[H("ccc42d0a965f0703")]
            widget._maxNumGridWidgets = 3
            grid:SetNumChildren(3, { shouldRemoveExcessChildren = true })
            grid:RefreshContent()
            widget._gridChildren = grid:GetBuiltChildren()
          end
          widget:RebuildSquadWidgetData()
        end
        L("zm hud: stock team rows " .. sig .. (widget and "" or " (no widget)"))
      end)
      if not ok then L("zm hud: stock team err " .. tostring(e)) end
      t:Wait(500).onComplete = tick
    end
    tick()
  end)
  end
  pcall(function()
    local SL = rawget(_G, "SAVELOAD")
    local EG = rawget(_G, "END_GAME")
    if type(SL) ~= "table" or type(EG) ~= "table" then return end
    if mapMode() ~= "zm" then return end
    local key = H("13a25fc31db8a642")
    local always = function() return true end
    SL[H("71050d376465e61d")] = function() return always end
    pcall(function()
      local parent = _DataSources[H("08f73707b5922e00")][H("95ee2f82995715a1")][H("d6094a4e04d339f7")]
      if _G.__zmLockParent == parent then return end
      local mt = getmetatable(parent)
      if not (mt and mt._initTable) then return end
      Lazy.Table.OverrideValue(parent, H("e708541630a80c28"), function()
        return LUI.AggregateDataSource.new(_DataSources[H("2da4734042348c9b")],
          { parent[H("875dfb635ac2a96b")], parent[H("eb1cde058e11dbea")], parent[H("1a358417a0c26ea9")] },
          { H("08f73707b5922e00"), H("95ee2f82995715a1"), H("d6094a4e04d339f7"), H("e708541630a80c28") }, always, false)
      end)
      _G.__zmLockParent = parent
      L("save lock aggregate overridden")
    end)
    if zmSaveCmd and SL[key] == zmSaveCmd then return end
    zmSaveCmd = LUI.Command.new(function(a, b)
      L("Save & Quit pressed")
      if KRONOS_RETAIL_K1.enabled then return KRONOS_RETAIL_K1.dispatchSave() end
      local ok1, e1 = pcall(function() Engine[H("76055c55456f05df")]("save_and_end_game", 77) end)
      local ok2, e2 = pcall(function() Dvar[H("f2414681ecab880f")](H("be9a1a5090f1172b", 1), 1) end)
      L("save_and_end_game sent ok=" .. tostring(ok1) .. " " .. tostring(e1) .. " dvar ok=" .. tostring(ok2) .. " " .. tostring(e2))
      LUI.FlowManager.RequestCloseAllMenus()
    end, function()
      if KRONOS_RETAIL_K1.enabled then return KRONOS_RETAIL_K1.saveContextReady() and not KRONOS_RETAIL_K1.savePending end
      return true
    end)
    SL[key] = zmSaveCmd
    SL[H("5e9317881b24d095")] = function()
      if KRONOS_RETAIL_K1.enabled then return KRONOS_RETAIL_K1.saveContextReady() and not KRONOS_RETAIL_K1.savePending end
      return true
    end
    L("SaveAndQuit forced available")
  end)
end
forceSaveAndQuit()
local ZMH = "a9693ae853fd0ee0"
local ZMMAPS = "755a0b129cf11f10"
local registered = {}
local origRequire = requirexhash
local function buildWith(hex, dataFn)
  return function(menu, data)
    local c = (data and data.controllerIndex) or 0
    pcall(origRequire, H(GBL))
    local m = LUI.UIMenu.new(data)
    m.id = H(hex)
    local d = dataFn(c)
    local el = MenuBuilder.BuildRegisteredType(H(GBL), d)
    local ok1, e1 = pcall(function() el:SetAnchorsAndPosition(0, 1, 0, 1, 96, 520, 170, 1000) end)
    if not ok1 then L("list pos err " .. tostring(e1)) end
    m:addElement(el)
    return m
  end
end

local DESC = {
  ["Standard"] = "Classic round-based Zombies. Survive escalating rounds, open up the map and chase the main quest.",
  ["Survival"] = "Hold out in a compact arena carved from a larger map. No quests, just you and your squad surviving for as long as you can.",
  ["Directed"] = "A guided main-quest experience. Objectives are laid out step by step so you can focus on the story.",
  ["Cursed"] = "Round-based Zombies with Relics. Equip curses for a tougher run and bigger rewards. Equip the golden Mister Peeks relic for Mister Peeks Mayhem.",
  ["Mister Peeks Mayhem"] = "Opens the Relic screen first: SELECT THE GOLDEN MISTER PEEKS RELIC, then Confirm to pick your map. Without it you die on spawn.",
  ["Rogue Run"] = "A roguelike run through the map with randomized upgrades between objectives.",
  ["Zombies Battle"] = "A competitive Zombies mode.",
  ["Dead Ops Arcade 4"] = "The top-down twin-stick arcade shooter returns.",
  ["Continue Saved Game"] = "Resume a match you saved with Save & Quit. Saves are stored locally, one per map.",
  ["Invite to Party"] = "Ask this friend to join your party. They accept in CB Launcher.",
  ["Choose Relics"] = "Pick the Relics for this run before choosing a map.",
  ["Ashes of the Damned"] = "A sprawling, ash-choked stretch of the Dark Aether, connected by roads. Travel between areas in the Wonder Vehicle.",
  ["Astra Malorum"] = "The Thurston Planetarium, pulled into the Dark Aether and lodged inside a skull-shaped asteroid among the rings of Saturn.",
  ["Kowakujo"] = "A feudal Japanese castle town in the shadow of an erupting volcano.",
  ["Rex Infernus"] = "A molten underworld fortress of fire and stone.",
  ["Paradox Junction"] = "A crossroads where past and future collide.",
  ["Totenreich"] = "A frozen Norwegian fishing village watched over by a lighthouse.",
  ["Dead Ops Arcade 4"] = "The top-down twin-stick arcade shooter returns.",
}
local function descFor(label)
  if DESC[label] then return DESC[label] end
  if label:find("%(Ashes%)") then return "Survival location on Ashes of the Damned." end
  if label:find("Tenshu") then return "Survival location in Kowakujo's castle." end
  if label:find("Eidskallen") then return "Survival location around Totenreich's lighthouse." end
  if label:find("Paradox") then return "Survival location in Paradox Junction." end
  return ""
end
local function buildStyled(hex, dataFn)
  local plain = buildWith(hex, dataFn)
  return function(menu, data)
    local c = (data and data.controllerIndex) or 0
    local d = dataFn(c)
    pcall(origRequire, H("6f25f1422590a999")); pcall(origRequire, H("3246871af1e086b7"))
    local ok, m = pcall(MenuBuilder.BuildRegisteredType, H("6f25f1422590a999"), { controllerIndex = c })
    if not ok or not m then L("styled base err " .. tostring(m)); return plain(menu, data) end
    m.id = H(hex)
    pcall(function() local g = m[H("31ac5f176c33564f")]; if g then g:SetAlpha(0); g:SetVisible(false) end end)
    pcall(function() local k = H("e7207fad9cee4361"); local t = m[k]; if t then t:closeTree(); m[k] = nil end end)
    local EBU = ElementAndButtonUtils
    local link, dirs
    pcall(function() link = EBU[H("042b31d442266478c")]; dirs = EBU[H("075992a095c731b0c")] end)
    local prev, first
    for i, b in ipairs(d.buttons) do
      local okb, eb = pcall(function()
        local btn
        local okL = pcall(function()
          pcall(origRequire, H("160b3fb9e4ab2e09"))
          local dc = _DataSources[H("f71428806887f67d")][H("1ccae3b6ef72f533")][H("05d757d4f38c9d14b")]
          btn = MenuBuilder.BuildRegisteredType(H("160b3fb9e4ab2e09"), { controllerIndex = c, dataContext = dc })
        end)
        local isLPSB = okL and btn ~= nil
        if not isLPSB then btn = MenuBuilder.BuildRegisteredType(H("3246871af1e086b7"), { controllerIndex = c }) end
        local y = 192 + (i - 1) * 72
        btn:SetAnchorsAndPosition(0, 1, 0, 1, 87, 511, y, y + 64)
        local lib = isLPSB and btn[H("e005326e765debe5")] or nil
        local function setLabel(t)
          local done = false
          for _, holder in ipairs({ btn, lib }) do
            if holder then
              for _, key in ipairs({ "69f6cc5b1a5cbb83", "39f7fcec8fcb623d" }) do
                local el = holder[H(key)]
                if el then pcall(function() el:setText(t); el.setText = function() end; done = true end) end
              end
            end
          end
          if not done then L("no label element on tile") end
        end
        setLabel(b.label)
        if b.img then
          local oki, ei = pcall(function()
            local prevMap = getDvar(DV_MAP)
            local mapFor = b.img:match("^(zm_sat_%a+%d*)") or b.img
            setDvar(DV_MAP, b.img)
            local img = PRIVATE_MATCH[H("540686b6aa3667cc")](b.img)
            if type(img) == "function" then
              local ok1, r1 = pcall(img, b.img)
              if ok1 and r1 ~= nil and type(r1) ~= "function" then img = r1 else local ok2, r2 = pcall(img); if ok2 and r2 ~= nil then img = r2 end end
              if type(img) == "function" then local ok3, r3 = pcall(img, nil, b.img); if ok3 and r3 ~= nil then img = r3 end end
            end
            if type(img) == "table" and img.GetValue then img = img:GetValue(c) end
            if prevMap and prevMap ~= "nil" then setDvar(DV_MAP, prevMap) end
            local mat = RegisterMaterial(img)
            if lib then
              pcall(function() local e = lib[H("2ab612888528489a")]; e:setImage(mat); e.setImage = function() end end)
              pcall(function() local e = lib[H("0903fb68fc0fde7e2")]; e:setImage(mat); e.setImage = function() end end)
            else
              btn[H("08eb42961d7f71157")]:setImage(mat)
            end
          end)
          if not oki then L("img err " .. tostring(b.img) .. ": " .. tostring(ei)) end
        end
        local lastFire = -1
        local function fire(tag)
          local clk = (type(os) == "table" and os.clock) and os.clock() or nil
          if clk then if clk - lastFire < 0.4 then return end; lastFire = clk end
          L("tile press via " .. tag .. " -> " .. b.label)
          b.action()
        end
        for _, ev in ipairs({ "e7eefe998522ec88" }) do
          for _, tgt in ipairs({ btn, isLPSB and btn[H("e005326e765debe5")] or nil }) do
            if tgt then pcall(function() tgt:addEventHandler(H(ev), function() fire(ev) end) end) end
          end
        end
        btn:addEventHandler(H("b0a3c7cac3e03af5"), function()
          pcall(function()
            local ip = m[H("aa46274a3a5996e5")]
            pcall(function() ip[H("3a506cb501761960")][H("c4bcadba8e631b86")]:setText(string.upper(b.label)) end)
            pcall(function() ip[H("4caca94f968abe27")]:setText(descFor(b.label)) end)
          end)
        end)
        m:addElement(btn)
        if prev and link and dirs then
          pcall(link, prev, btn, dirs[H("dc04126761bb7455")])
          pcall(link, btn, prev, dirs[H("08c43a07b566d980")])
        end
        prev = btn
        first = first or btn
      end)
      if not okb then L("styled btn err " .. tostring(eb)) end
    end
    if first then pcall(function() m:SetDefaultFocusToElement(first) end) end
    L("styled menu built with " .. #d.buttons .. " buttons")
    return m
  end
end
local function register(hex, dataFn)
  if registered[hex] then return true end
  local ok, err = pcall(function() MenuBuilder.registerType(H(hex), buildStyled(hex, dataFn)) end)
  L("register " .. hex .. " ok=" .. tostring(ok) .. " err=" .. tostring(err))
  registered[hex] = ok
  return ok
end
local function makeStartTile(c)
  local btn, lib
  local okL = pcall(function()
    pcall(origRequire, H("160b3fb9e4ab2e09"))
    local dc = _DataSources[H("f71428806887f67d")][H("1ccae3b6ef72f533")][H("05d757d4f38c9d14b")]
    btn = MenuBuilder.BuildRegisteredType(H("160b3fb9e4ab2e09"), { controllerIndex = c, dataContext = dc })
  end)
  if okL and btn then
    lib = btn[H("e005326e765debe5")]
  else
    pcall(origRequire, H("3246871af1e086b7"))
    btn = MenuBuilder.BuildRegisteredType(H("3246871af1e086b7"), { controllerIndex = c })
  end
  btn:SetAnchorsAndPosition(0, 1, 1, 0, 88, 512, -152, -88)
  for _, holder in ipairs({ btn, lib }) do
    for _, key in ipairs({ "69f6cc5b1a5cbb83", "39f7fcec8fcb623d" }) do
      local el = holder and holder[H(key)]
      if el then pcall(function() el:setText("Start Match"); el.setText = function() end end) end
    end
  end
  local function go(tag)
    if KRONOS_RETAIL_K1.nativeResume then return end
    if not goCmd then return end
    local cmd = goCmd; goCmd = nil; launching = true
    L("start match via " .. tag)
    exec(cmd)
  end
  for _, tgt in ipairs({ btn, lib }) do
    if tgt then pcall(function() tgt:addEventHandler(H("e7eefe998522ec88"), function() go("e7eefe998522ec88") end) end) end
  end
  return btn
end
local keepWeaponsTab
do
local tabDvarWrapped = setmetatable({}, { __mode = "k" })
keepWeaponsTab = function()
  pcall(function()
    local D = rawget(_G, "Dvar"); if type(D) ~= "table" then return end
    local k = H("0f2414681ecab880f"); local orig = D[k]
    if type(orig) ~= "function" or tabDvarWrapped[orig] then return end
    local weaponsTab = tostring(H("140dc94b0e5bde1a0"))
    local wrap = function(name, value, ...)
      if tostring(name) == weaponsTab and value == 2 then return end
      return orig(name, value, ...)
    end
    tabDvarWrapped[wrap] = true
    D[k] = wrap
  end)
end
end
local function addStartTile(w, c)
  if KRONOS_RETAIL_K1.enabled then return end
  local btn = makeStartTile(c)
  w:addElement(btn)
  pcall(function() w:SetDefaultFocusToElement(btn) end)
  L("start tile added")
end
local gobbleWrapped = setmetatable({}, { __mode = "k" })
local function guardGobbleInit()
  pcall(function()
    local G = rawget(_G, "GOBBLEGUM"); if type(G) ~= "table" or gobbleWrapped[G] then return end
    local k = H("f5d2afc57ab57213"); local init = G[k]; if type(init) ~= "function" then return end
    gobbleWrapped[G] = true
    G[k] = function(c, ...)
      if not G[H("a988866c889eaad")](c) then
        local loadout = LOADOUT[H("6c551cb02f0d21dd")](c)
        local data = PlayerData[H("08b73907b55c4d71")](c, LOADOUT[H("1f3d4120102d8bb3")]())
        if not data or not loadout then return false end
      end
      return init(c, ...)
    end
  end)
end

local augmentWrapped = setmetatable({}, { __mode = "k" })
local function bonusAugmentSlot()
  local ok, e = pcall(function()
    local Z = rawget(_G, "ZMAUGMENT"); if type(Z) ~= "table" or augmentWrapped[Z] then return end
    local kr = H("16539fa974381dd4"); local research = Z[kr]
    if type(research) ~= "function" then return end
    augmentWrapped[Z] = true
    Z[kr] = function(c, data, perk, ...)
      local r = research(c, data, perk, ...)
      pcall(function()
        local key = Z[H("a1a352e6a40ee2f0")][perk]
        local entry = key ~= nil and Z[H("d847872560dcd8e4")][key]
        if entry then entry.isResearchComplete = true end
      end)
      return r
    end
    pcall(function()
      for _, entry in pairs(Z[H("d847872560dcd8e4")]) do
        if type(entry) == "table" then entry.isResearchComplete = true end
      end
    end)
    local kf = H("a9347275f6f8fcea")
    if type(Z[kf]) == "function" then Z[kf] = function() return true end end
    local krf = H("52e47d640bf4ca01"); local refresh = Z[krf]
    if type(refresh) == "function" then
      local kprog = H("f9909144862249c6")
      Z[krf] = function(c, ...)
        local r = refresh(c, ...)
        if getDvar("890bdbcdc0a1091c") == "1" or getDvar("a1f01871dd473e79") == "1" then
          pcall(function()
            for _, entry in pairs(Z[H("d847872560dcd8e4")]) do
              if type(entry) == "table" then
                for i = 1, #entry do if type(entry[i]) == "table" then entry[i][kprog] = 1 end end
                entry.isUnlocked = true
                entry.isResearchComplete = true
                entry.totalProgress = 100
                if #entry > 0 then entry.currentTier = #entry end
              end
            end
          end)
        end
        return r
      end
    end
    L("augment research marked complete")
  end)
  if not ok then L("augment wrap err " .. tostring(e)) end
end

local augExtra = {}
do
  local DV_X, DV_MAJ, DV_MIN = "960584f6756454ca", "a5d3dab009ba642c", "e4644f6a59df80e0"
  local K = { eq = "348b7ddbf9e80091", cust = "9d4e390d3af2a061", res = "d847872560dcd8e4", fill = "b0cb2030105b43ff",
    zm = "08f73707b5922e00", fe = "f71428806887f67d", lists = "4c6b47851c61594d", major = "933808a8de957383",
    minor = "3f937278aa507b87", loot = "dab83a8cc61e6325", count = "b1e5e28e4479a274", item = "2841a0c596d6f426", focus = "9969055e85235372", ref = "89e9c01960f4c582",
    equipped = "200b683c98b9b2a3", base = "70095edf07506af0", check = "0658ffc8bfaeb8171", border = "dce2af03fa4e881f", slot = "03bdacc8f7bb1884" }
  augExtra.detailKey = tostring(H("1cf0ccf77f04440e"))
  augExtra.buttonKey = tostring(H("ec547dab38004440"))
  local wrapped = setmetatable({}, { __mode = "k" })
  local buttons = setmetatable({}, { __mode = "k" })
  local panel, curItem, listItem, fillOrig
  local function limit(major)
    return math.max(0, math.min(3, tonumber(getDvar(major and DV_MAJ or DV_MIN)) or 0))
  end
  local function keyOf(item) return (tostring(item):gsub("[,|]", "_")) end
  local function read()
    local t = {}
    for kind, loot, item in getDvar(DV_X):gmatch("([Mm])|(%d+)|([^,]+)") do
      t[#t + 1] = { major = kind == "M", loot = tonumber(loot), item = item }
    end
    return t
  end
  local function write(t)
    local s = {}
    for _, e in ipairs(t) do s[#s + 1] = (e.major and "M" or "m") .. "|" .. e.loot .. "|" .. e.item end
    setDvar(DV_X, table.concat(s, ","))
  end
  local function forItem(t, key, major)
    local r, lim = {}, limit(major)
    for _, e in ipairs(t) do if e.item == key and e.major == major and #r < lim then r[#r + 1] = e end end
    return r
  end
  local function isEmpty(v) return v == nil or v == 0 or v == LOOT.emptyID end
  local function entryFor(c, major, loot)
    local list = _DataSources[H(K.zm)][H(K.fe)][H(K.lists)][H(major and K.major or K.minor)]
    local n = tonumber(list[H(K.count)]:GetValue(c)) or 0
    for i = 1, n do
      local e = list[i] and list[i][H(K.item)]
      local l = e and e[H(K.loot)]
      if l and tonumber(l:GetValue(c)) == loot then return e end
    end
  end
  local function focusRef(c)
    local ok, v = pcall(function()
      return _DataSources[H(K.zm)][H(K.fe)][H(K.lists)][H(K.focus)][H(K.ref)]:GetValue(c)
    end)
    if ok and v ~= nil and v ~= "" then return v end
    return curItem
  end
  local function isExtra(loot)
    local key = curItem ~= nil and keyOf(curItem)
    if not key or not loot then return false end
    local t = read()
    for _, major in ipairs({ true, false }) do
      for _, e in ipairs(forItem(t, key, major)) do if e.loot == loot then return true end end
    end
    return false
  end
  local function updateButtons()
    for b in pairs(buttons) do
      for _, el in ipairs({ b[H(K.base)], b[H(K.border)] }) do pcall(function() el:UpdateAnimationState() end) end
      local chk = b[H(K.check)]
      if chk and chk.kronosVisible then pcall(chk.kronosVisible, CTRL) end
    end
  end
  local function proxy(b)
    local gds = b and b.GetDataSource
    if type(gds) ~= "function" then return end
    b.GetDataSource = function(self, ...)
      local ds = gds(self, ...)
      if ds == nil then return ds end
      local real = ds[H(K.equipped)]
      if real == nil then return ds end
      local fake = setmetatable({}, { __index = function(_, k)
        local v = real[k]
        if type(v) == "function" then return function(_, ...) return v(real, ...) end end
        return v
      end })
      fake.GetValue = function(_, c, ...)
        local v = real and real:GetValue(c, ...)
        if v then return v end
        local ok, l = pcall(function() return tonumber(ds[H(K.item)][H(K.loot)]:GetValue(c)) end)
        return ok and isExtra(l) or v
      end
      return setmetatable({ [H(K.equipped)] = fake }, { __index = ds })
    end
  end
  function augExtra.button(b)
    buttons[b] = true
    for _, el in ipairs({ b, b[H(K.base)], b[H(K.border)], b[H(K.slot)] }) do proxy(el) end
    local chk = b[H(K.check)]
    local sv = chk and chk.SetVisible
    if type(sv) ~= "function" then return end
    chk.SetVisible = function(self, v, ...)
      if not v then
        local ok, l = pcall(function() return tonumber(b:GetDataSource()[H(K.item)][H(K.loot)]:GetValue(CTRL)) end)
        if ok and isExtra(l) then v = true end
      end
      return sv(self, v, ...)
    end
    chk.kronosVisible = function(c)
      local ok, l = pcall(function() return tonumber(b:GetDataSource()[H(K.item)][H(K.loot)]:GetValue(c)) end)
      local okV, real = pcall(function() return b:GetDataSource()[H(K.equipped)]:GetValue(c) end)
      sv(chk, (okV and real == true) or (ok and isExtra(l)))
    end
  end
  function augExtra.refresh(c, keep)
    if not keep and curItem == nil then curItem = focusRef(c) end
    pcall(updateButtons)
    if not panel or curItem == nil then return end
    if fillOrig and listItem ~= curItem then listItem = curItem; pcall(fillOrig, c, curItem) end
    for _, r in ipairs(panel.rows) do pcall(function() r:closeTree() end) end
    panel.rows = {}
    local t, key, y = read(), keyOf(curItem), 500
    for _, major in ipairs({ true, false }) do
      for _, e in ipairs(forItem(t, key, major)) do
        local ok, err = pcall(function()
          local ds = entryFor(c, major, e.loot)
          if not ds then return end
          local w = MenuBuilder.BuildRegisteredType(H(K.slot), { controllerIndex = c, dataContext = ds })
          w:SetAnchorsAndPosition(0, 1, 0, 1, -11, 468, y, y + 80)
          panel.el:addElement(w)
          panel.rows[#panel.rows + 1] = w
          y = y + 80
        end)
        if not ok then L("aug extra row err " .. tostring(err)) end
      end
    end
  end
  function augExtra.built(m, data)
    local c = (data and data.controllerIndex) or CTRL
    panel = { el = m, rows = {} }
    local sds = m.SetDataSource
    if type(sds) == "function" then
      m.SetDataSource = function(self, ds, ...)
        local r = { sds(self, ds, ...) }
        pcall(function()
          local v = ds and ds[H(K.ref)] and ds[H(K.ref)]:GetValue(c)
          if v ~= nil and v ~= "" then curItem = v end
        end)
        pcall(augExtra.refresh, c, true)
        return unpack(r)
      end
    end
    augExtra.refresh(c)
  end
  function augExtra.hook()
    local ok, e = pcall(function()
      local Z = rawget(_G, "ZMAUGMENT"); if type(Z) ~= "table" then return end
      local kf = H(K.fill); local fill = Z[kf]
      if type(fill) == "function" and not wrapped[fill] then
        fillOrig = fill
        local wf = function(c, item, ...)
          local r = { fill(c, item, ...) }
          curItem = item; listItem = item
          pcall(augExtra.refresh, c)
          return unpack(r)
        end
        wrapped[wf] = true; Z[kf] = wf
      end
      local k = H(K.eq); local orig = Z[k]
      if type(orig) ~= "function" or wrapped[orig] then return end
      local w = function(c, idx, aug, item, cat, isMajor, ...)
        local okE, done = pcall(function()
          local major = isMajor and true or false
          local key, loot = keyOf(item), tonumber(aug)
          if not loot or isEmpty(aug) then return false end
          local t = read()
          for i, x in ipairs(t) do
            if x.item == key and x.loot == loot then table.remove(t, i); write(t); return true end
          end
          local lim = limit(major); if lim == 0 then return false end
          local cu = Z[H(K.cust)](c, cat, item); if not cu then return false end
          local full
          if major then
            local m = cu.majorAugment:get()
            full = not isEmpty(m) and m ~= aug
          else
            local m, b = cu.minorAugment:get(), cu.bonusMinorAugment:get()
            if m == aug or b == aug then return false end
            local r = Z[H(K.res)][item]
            full = not isEmpty(m) and (not (r and r.isResearchComplete) or not isEmpty(b))
          end
          if not full or #forItem(t, key, major) >= lim then return false end
          t[#t + 1] = { major = major, loot = loot, item = key }
          write(t)
          return true
        end)
        if not okE then L("aug extra err " .. tostring(done)) end
        if okE and done then pcall(augExtra.refresh, c); return end
        return orig(c, idx, aug, item, cat, isMajor, ...)
      end
      wrapped[w] = true; Z[k] = w
    end)
    if not ok then L("aug extra hook err " .. tostring(e)) end
  end
end
local oskWrapped = setmetatable({}, { __mode = "k" })
local function offlineTextEntry()
  local ok, e = pcall(function()
    local O = rawget(_G, "OSK"); if type(O) ~= "table" or oskWrapped[O] then return end
    local k = H("8c1c15c14b75864c"); local f = O[k]; if type(f) ~= "function" then return end
    oskWrapped[O] = true
    O[k] = function(c, title, default, maxLen, verify, profanity, ...)
      return f(c, title, default, maxLen, false, false, ...)
    end
    L("osk verify off")
  end)
  if not ok then L("osk wrap err " .. tostring(e)) end
end

local progressionWrapped = setmetatable({}, { __mode = "k" })
local iconWrapped = setmetatable({}, { __mode = "k" })
local function localProgressionXP()
  local ok, e = pcall(function()
    local P = rawget(_G, "PROGRESSION"); if type(P) ~= "table" or progressionWrapped[P] then return end
    local k = H("5fef2db65e53362e"); if type(P[k]) ~= "function" then return end
    progressionWrapped[P] = true
    P[k] = function(c)
      local ds = rawget(_G, "_DataSources")[H("dffc2cf2d66f1248")][H("c7091fb2a7344c70")][H("08f14807b58ddf35")]
      return ds:GetValue(c) or 0
    end
    L("level xp read from the local progression")
  end)
  if not ok then L("progression wrap err " .. tostring(e)) end
  pcall(function()
    local OP = rawget(_G, "OnlineProgression"); if type(OP) ~= "table" or progressionWrapped[OP] then return end
    local k = H("5d1f780ad35bbec3"); if type(OP[k]) ~= "function" then return end
    progressionWrapped[OP] = true
    OP[k] = function() return tonumber(getDvar("703f4ce774962899")) or 0 end
    L("prestige read from the local progression")
  end)
  pcall(function()
    local PR, P = rawget(_G, "PRESTIGE"), rawget(_G, "PROGRESSION")
    if type(PR) ~= "table" or type(P) ~= "table" or (progressionWrapped[PR] and iconWrapped[P]) then return end
    local kGet, kIcon, kAlt = H("ea81c9a19805c833"), H("d9c6922557618920"), H("a875e1668a34631f")
    local icon = P[kIcon]
    if type(PR[kGet]) ~= "function" or type(icon) ~= "function" or type(PR[kAlt]) ~= "function" then return end
    if not progressionWrapped[PR] then
      progressionWrapped[PR] = true
      PR[kGet] = function() return tonumber(getDvar("703f4ce774962899")) or 0 end
    end
    if iconWrapped[P] then return end
    iconWrapped[P] = true
    P[kIcon] = function(rank, prestige, a3, a4, ...)
      local p = tonumber(prestige) or 0
      if p >= 11 and a3 and a4 then
        local okc, id = pcall(function() return PLAYERPROFILE[H("2e251e8212678573")](a3, a4) end)
        if okc and id and id ~= 0 then
          local oki, img = pcall(function() return LEVEL_ICON[H("f7e7a7a4e7e58c7d")](id) end)
          if oki and img and img ~= CoD.ERROR_TEXTURE then return img end
        end
      end
      if p > 0 then
        local okm, master = pcall(PR[H("797cae625c716f19")], rank)
        if not (okm and master) then
          local ok, img = pcall(PR[kAlt], p)
          if ok and img and img ~= "" and img ~= CoD.PLACEHOLDER_TEXTURE_STR then return img end
        end
      end
      return icon(rank, prestige, a3, a4, ...)
    end
    L("prestige icons shown offline")
  end)
end

local rankWatched = false
local function watchRankUps()
  if rankWatched then return end
  local ok, e = pcall(function()
    local DS, P, CH = rawget(_G, "_DataSources"), rawget(_G, "PROGRESSION"), rawget(_G, "Challenge")
    if type(DS) ~= "table" or type(P) ~= "table" or type(CH) ~= "table" or not LUI.GetRoot then return end
    local prog = DS[H("dffc2cf2d66f1248")]; prog = prog and prog[H("c7091fb2a7344c70")]
    local rankDS, prestigeDS = prog and prog[H("6db3201fd1eb3847")], prog and prog[H("847d5beda159d298")]
    local root = LUI.GetRoot()
    if not (rankDS and root) then return end
    rankWatched = true
    local last
    rankDS:AddSubscriber(root, CTRL, function(rank)
      rank = tonumber(rank)
      if not rank then return end
      if last and rank > last then
        pcall(function()
          local prestige = prestigeDS and tonumber(prestigeDS:GetValue(CTRL)) or 0
          LUI.UIRoot.ProcessEvent(root, { name = H("25564e1b4a11d758"), controller = CTRL,
            kind = CH[H("db2cb8b8af90d9ce")](H("2b5b9f37d66c7e1a")), id = P[H("4532b25cb07b9597")](),
            progress = { rank = rank, prestige = prestige } })
        end)
        L("level up splash for rank " .. rank)
      end
      last = rank
    end)
  end)
  if not ok then L("rank watch err " .. tostring(e)) end
end

local timeWrapped = setmetatable({}, { __mode = "k" })
local function localUtcTime()
  pcall(function()
    local C = rawget(_G, "CoD"); if type(C) ~= "table" or timeWrapped[C] then return end
    local k = H("793b964b6e5d8841"); local orig = C[k]; if type(orig) ~= "function" then return end
    timeWrapped[C] = true
    C[k] = function(...)
      local t = orig(...)
      if not t or t == 0 then t = math.floor(Engine[H("6463e9b7ec03726f")]() * 1000) end
      return t
    end
    L("utc time falls back to the system clock")
  end)
end

local CH = { rec = {}, locked = {}, gums = {} }
local DV_CH_VER = "e621c4c8cb4b6a1d"
local DV_CH_PARTS = {
  "1a2f59e42a21e7f3", "1a2f58e42a21e5c0", "1a2f5be42a21ec59", "1a2f5ae42a21ea26",
  "1a2f5de42a21f0bf", "1a2f5ce42a21ee8c", "1a2f5fe42a21f525", "1a2f5ee42a21f2f2",
  "1a2f61e42a21f98b", "1a2f60e42a21f758", "b8066dc8a88caed0", "b8066ec8a88cb103",
  "b8066fc8a88cb336", "b80670c8a88cb569", "b80671c8a88cb79c", "b80672c8a88cb9cf",
  "b80673c8a88cbc02", "b80674c8a88cbe35", "b80675c8a88cc068", "b80676c8a88cc29b",
  "b8137fc8a89aeaeb", "b8137ec8a89ae8b8", "b81381c8a89aef51", "b81380c8a89aed1e",
  "b81383c8a89af3b7", "b81382c8a89af184", "b81385c8a89af81d", "b81384c8a89af5ea",
  "b81377c8a89ad953", "b81376c8a89ad720", "b80ef9c8a895ce62", "b80efac8a895d095",
  "b80ef7c8a895c9fc", "b80ef8c8a895cc2f", "b80ef5c8a895c596", "b80ef6c8a895c7c9",
  "b80ef3c8a895c130", "b80ef4c8a895c363", "b80f01c8a895dffa", "b80f02c8a895e22d",
  "b81c0bc8a8a40a7d", "b81c0ac8a8a4084a", "b81c09c8a8a40617", "b81c08c8a8a403e4",
  "b81c07c8a8a401b1", "b81c06c8a8a3ff7e", "b81c05c8a8a3fd4b", "b81c04c8a8a3fb18",
  "b81c03c8a8a3f8e5", "b81c02c8a8a3f6b2", "b81805c8a8a00774", "b81806c8a8a009a7",
  "b81807c8a8a00bda", "b81808c8a8a00e0d", "b81801c8a89ffea8", "b81802c8a8a000db",
  "b81803c8a8a0030e", "b81804c8a8a00541", "b817fdc8a89ff5dc", "b817fec8a89ff80f",
  "b824f7c8a8adfd2f", "b824f6c8a8adfafc", "b824f9c8a8ae0195", "b824f8c8a8adff62",
  "b824f3c8a8adf463", "b824f2c8a8adf230", "b824f5c8a8adf8c9", "b824f4c8a8adf696",
  "b824ffc8a8ae0ec7", "b824fec8a8ae0c94", "b82071c8a8a8e0a6", "b82072c8a8a8e2d9",
  "b8206fc8a8a8dc40", "b82070c8a8a8de73", "b82075c8a8a8e972", "b82076c8a8a8eba5",
  "b82073c8a8a8e50c", "b82074c8a8a8e73f", "b82079c8a8a8f23e", "b8207ac8a8a8f471",
  "b82e03c8a8b83641", "b82e02c8a8b8340e", "b82e01c8a8b831db", "b82e00c8a8b82fa8",
  "b82e07c8a8b83f0d", "b82e06c8a8b83cda", "b82e05c8a8b83aa7", "b82e04c8a8b83874",
  "b82dfbc8a8b824a9", "b82dfac8a8b82276", "b8297dc8a8b319b8", "b8297ec8a8b31beb",
  "b8297fc8a8b31e1e", "b82980c8a8b32051", "b82981c8a8b32284", "b82982c8a8b324b7"
}
local function chVer()
  local ok, ver = pcall(function() return tostring(Dvar[H(DV_GET)](H(DV_CH_VER, 1))) end)
  return ok and ver or nil
end
local function chSync()
  local ver = chVer()
  if not ver or ver == CH.ver then return end
  local n = tonumber(ver:match("^%d+:(%d+)$"))
  if not n or n > #DV_CH_PARTS then return end
  local parts = {}
  for i = 1, n do
    local ok, part = pcall(function() return tostring(Dvar[H(DV_GET)](H(DV_CH_PARTS[i], 1))) end)
    if not ok then return end
    parts[i] = part
  end
  if chVer() ~= ver then return end
  local s = table.concat(parts)
  local rec, locked, gums, intel, daily, weekly, weapons = {}, {}, {}, {}, {}, nil, {}
  for line in s:gmatch("[^\n]+") do
    local t = line:sub(1, 1)
    if t == "c" then
      local id, k, p, st, tg, dn, pr, pg, w = line:match("^c(%d+) (%d+) (%d+) (%d+) (%d+) ?(%d*) ?(%d*) ?(%d*) ?(%d*)")
      if id then
        rec[tonumber(id)] = { tonumber(k), tonumber(p), tonumber(st), tonumber(tg), tonumber(dn) or 0, tonumber(pr) or 0,
          tonumber(pg) or 0 }
        if w ~= "" then weapons[tonumber(w)] = tonumber(id) end
      end
    elseif t == "l" then
      locked[tonumber(line:sub(2))] = true
    elseif t == "g" then
      local id, c = line:match("^g(%d+) (%-?%d+)")
      if id then gums[tonumber(id)] = tonumber(c) end
    elseif t == "i" then
      intel[#intel + 1] = line:sub(2)
    elseif t == "d" then
      local slot, id = line:match("^d(%d) (%d+)")
      if slot then daily[tonumber(slot)] = id end
    elseif t == "w" then
      local id, season, week = line:match("^w(%d+) (%d+) (%d+)")
      if id then weekly = { id = tonumber(id), season = tonumber(season), week = tonumber(week) } end
    end
  end
  CH.rec, CH.locked, CH.gums, CH.intel, CH.daily, CH.weekly, CH.weapons, CH.ver = rec, locked, gums, intel, daily, weekly,
    weapons, ver
  local nr, nl, ng = 0, 0, 0
  for _ in pairs(rec) do nr = nr + 1 end
  for _ in pairs(locked) do nl = nl + 1 end
  for _ in pairs(gums) do ng = ng + 1 end
  L("challenge state " .. ver .. ": " .. #s .. " bytes, " .. nr .. " challenges, " .. nl .. " locked, " .. ng .. " gums")
end
local function levelRecord(id)
  local ok, pid = pcall(function() return PROGRESSION[H("4532b25cb07b9597")]() end)
  if not ok or pid == nil or tostring(pid) ~= tostring(id) then return nil end
  local function n(hx) return tonumber(getDvar(hx)) or 0 end
  local ok2, kind = pcall(function() return Challenge[H("db2cb8b8af90d9ce")](H("2b5b9f37d66c7e1a")) end)
  return { id = tostring(id), kind = ok2 and kind or nil, status = 1, numCompletions = 0,
    progress = { rank = n("a9e6b907229d534e"), xp = n("f4bb97895b995476"), prestige = n("703f4ce774962899"), default = n("f4bb97895b995476") } }
end
local function chRecord(id)
  local lv = levelRecord(id)
  if lv then return lv end
  chSync()
  local r = CH.rec[tonumber(id) or -1]
  if not r then return nil end
  local progress = { default = r[2], default_target = r[4] }
  if r[1] == 398 then progress.rank, progress.xp, progress.prestige, progress.prestiging = r[5], r[2], r[6], r[7] end
  if CH.weekly and CH.weekly.id == tonumber(id) then progress.season, progress.week = CH.weekly.season, CH.weekly.week end
  return { id = tostring(tonumber(id)), kind = r[1], status = r[3], numCompletions = r[3] == 3 and 1 or 0,
    progress = progress }
end
local intelVer
local function syncIntel(c)
  chSync()
  if not CH.intel or intelVer == CH.ver then return end
  local ok, e = pcall(function()
    if not Engine[H("112586a3f4fb490e")]() then return end
    local PD = rawget(_G, "PLAYER_DATA"); if type(PD) ~= "table" then return end
    local pd = PD[H("3702ae6da42b1557")](c)
    local zi = pd and pd.zombieIntel
    if not zi then return end
    local gsb, kRef = Engine[H("f06093d047200548")], H("89e9c01960f4c582")
    local n, missing = 0, 0
    for _, hex in ipairs(CH.intel) do
      local okI, wrote = pcall(function()
        local b = gsb(H(hex))
        local entry = b and b[kRef] ~= nil and zi[b[kRef]]
        if not entry then return nil end
        if entry:get() == 0 then entry:set(1); return true end
        return false
      end)
      if not okI or wrote == nil then missing = missing + 1 elseif wrote then n = n + 1 end
    end
    intelVer = CH.ver
    if n > 0 or missing > 0 then L("intel: " .. n .. " picked-up items written to zombieIntel, " .. missing .. " without an entry") end
  end)
  if not ok then intelVer = CH.ver; L("intel sync error: " .. tostring(e)) end
end
local DAILY_KEYS = { "d7a272c250331b8f", "d7a271c2503319dc", "d7a274c250331ef5", "68fdb7dbc253e0c4" }
local dailyWrapped = setmetatable({}, { __mode = "k" })
local function localDailies()
  pcall(function()
    local OP, CHL = rawget(_G, "OnlineProgression"), rawget(_G, "Challenge")
    local k = H("a82011d283698aa4")
    if type(OP) ~= "table" or type(OP[k]) ~= "function" or OP[k] == dailyWrapped[OP] or type(CHL) ~= "table" then return end
    local nameOf = CHL[H("e42ea32389c5bbae")]
    if type(nameOf) ~= "function" then return end
    local slots, names = {}, {}
    for i, hx in ipairs(DAILY_KEYS) do
      local ok, nm = pcall(nameOf, H(hx))
      if ok and nm ~= nil then slots[tostring(nm)] = i; names[#names + 1] = tostring(nm) end
    end
    if #names == 0 then return end
    if dailyWrapped[OP] then L("daily user state was replaced; wrapped again") end
    local orig = OP[k]
    OP[k] = function(c, keys, ...)
      local res = orig(c, keys, ...)
      chSync()
      if type(keys) == "table" and CH.daily then
        for _, key in pairs(keys) do
          local id = CH.daily[slots[tostring(key)] or 0]
          if id then
            if type(res) ~= "table" then res = {} end
            res[key] = id
          end
        end
      end
      return res
    end
    dailyWrapped[OP] = OP[k]
    L("dailies answered locally for user-state keys " .. table.concat(names, ", "))
  end)
end
local DV_WPRESTIGE = "5a7f21d1d3df7819"
local EV_WEAPON_PRESTIGE = 956
local sendWrapped = setmetatable({}, { __mode = "k" })
local sendSeen, prestigeSerial = {}, 0
local function localWeaponPrestige()
  pcall(function()
    local CS = rawget(_G, "Challenges")
    local k = H("e636d3bf423fd414")
    if type(CS) ~= "table" or type(CS[k]) ~= "function" or CS[k] == sendWrapped[CS] then return end
    if sendWrapped[CS] then L("achievement event send was replaced; wrapped again") end
    local orig = CS[k]
    CS[k] = function(c, ev, n, ...)
      local id = tonumber(tostring(ev))
      if id and not sendSeen[id] then sendSeen[id] = true; L("achievement event " .. id .. " sent by the menu") end
      if id == EV_WEAPON_PRESTIGE then
        local weapon = tonumber(tostring((select(2, ...))))
        chSync()
        local row = weapon and CH.weapons and CH.weapons[weapon]
        local r = row and CH.rec[row]
        if r then
          prestigeSerial = prestigeSerial + 1
          setDvar(DV_WPRESTIGE, weapon .. " " .. r[6] .. " " .. prestigeSerial)
        else
          L("weapon prestige asked for " .. tostring(weapon) .. ", which has no local level record")
        end
      end
      return orig(c, ev, n, ...)
    end
    sendWrapped[CS] = CS[k]
    L("weapon prestige requests go to the local progression")
  end)
end
local chWrapped = setmetatable({}, { __mode = "k" })
local function chNeedsWrap(T, k, what)
  if type(T) ~= "table" or type(T[k]) ~= "function" or T[k] == chWrapped[T] then return false end
  if chWrapped[T] then L(what .. " was replaced; wrapped again") end
  return true
end
local privWrapped = setmetatable({}, { __mode = "k" })
local function localUnlockRule()
  pcall(function()
    local P = rawget(_G, "PROGRESSION")
    local k = H("1d92619de07147b5")
    if type(P) ~= "table" or type(P[k]) ~= "function" or P[k] == privWrapped[P] then return end
    if privWrapped[P] then L("private match unlock rule was replaced; overridden again") end
    P[k] = function() return false end
    privWrapped[P] = P[k]
    L("private match unlock-all rule off: weapons and attachments follow ownership")
  end)
  pcall(function()
    local P = rawget(_G, "PROGRESSION"); if type(P) ~= "table" then return end
    local k = H("33568d3533d63f69")
    local o = P[k]
    if type(o) ~= "function" or privWrapped[o] then return end
    local w = function(c, loot, ...)
      chSync()
      local n = tonumber(loot)
      if n and CH.locked[n] then probe("progression owned (locked)", n, false); return false end
      local r = o(c, loot, ...)
      probe("progression owned", loot, r)
      return r
    end
    privWrapped[w] = true
    P[k] = w
    L("weapon and attachment unlocks follow the local progression")
  end)
  pcall(function()
    local P = rawget(_G, "PROGRESSION"); if type(P) ~= "table" then return end
    for _, e in ipairs({ { "13d8bd2b211db6cc", "progression isUnlocked", 3 }, { "d261f5c903836da1", "progression unlock exception", 1 } }) do
      local k, name, arg = H(e[1]), e[2], e[3]
      local o = P[k]
      if type(o) == "function" and not (privWrapped[o]) then
        local w = function(...)
          local r = o(...)
          probe(name, tostring((select(arg, ...))), r)
          return r
        end
        privWrapped[w] = true
        P[k] = w
      end
    end
  end)
end
local function localChallenges()
  localUnlockRule()
  pcall(function()
    local OC = rawget(_G, "OnlineChallenges")
    local kRec, kDef, kSt, kBatch, kKind = H("31eee6570ef4bb8b"), H("c077167a1140d536"), H("7f76b36d35a1a81d"), H("51c3622c9015185a"), H("45aff5ca0a9ffc57")
    if not chNeedsWrap(OC, kRec, "challenge progress") then return end
    local oRec, oDef, oSt, oBatch, oKind = OC[kRec], OC[kDef], OC[kSt], OC[kBatch], OC[kKind]
    OC[kRec] = function(c, id, ...)
      local r = chRecord(id)
      probe("challenge record", id, r and r.status)
      if r then return r end
      return oRec(c, id, ...)
    end
    chWrapped[OC] = OC[kRec]
    if type(oDef) == "function" then
      OC[kDef] = function(c, id, ...)
        chSync()
        local r = CH.rec[tonumber(id) or -1]
        if r then return r[2] end
        return oDef(c, id, ...)
      end
    end
    if type(oSt) == "function" then
      OC[kSt] = function(c, id, ...)
        chSync()
        local r = CH.rec[tonumber(id) or -1]
        probe("challenge status", id, r and r[3])
        if r then return r[3] end
        return oSt(c, id, ...)
      end
    end
    if type(oBatch) == "function" then
      OC[kBatch] = function(c, ids, ...)
        local res = oBatch(c, ids, ...)
        if type(ids) == "table" then
          for _, id in pairs(ids) do
            local r = chRecord(id)
            if r then res = res or {}; res[r.id] = r end
          end
        end
        return res
      end
    end
    if type(oKind) == "function" then
      OC[kKind] = function(c, kind, ...)
        local res = oKind(c, kind, ...)
        chSync()
        for id, r in pairs(CH.rec) do
          if r[1] == tonumber(kind) then res = res or {}; res[tostring(id)] = chRecord(id) end
        end
        return res
      end
    end
    L("challenge progress read locally")
  end)
  pcall(function()
    local LT = rawget(_G, "LOOT")
    local kOwned, kCount = H("33568d3533d63f69"), H("50a99e04e868c330")
    if not chNeedsWrap(LT, kOwned, "loot ownership") then return end
    local oOwned, oCount = LT[kOwned], LT[kCount]
    LT[kOwned] = function(c, id, ...)
      chSync()
      local locked = CH.locked[tonumber(id) or -1]
      probe("loot owned", id, not locked)
      if locked then probe("loot owned (locked)", id, false); return false end
      return oOwned(c, id, ...)
    end
    chWrapped[LT] = LT[kOwned]
    if type(oCount) == "function" then
      LT[kCount] = function(c, id, ...)
        chSync()
        probe("loot count", id, CH.locked[tonumber(id) or -1] and 0)
        if CH.locked[tonumber(id) or -1] then return 0 end
        return oCount(c, id, ...)
      end
    end
    L("challenge rewards owned only when earned")
  end)
  pcall(function()
    local LO = rawget(_G, "Loot")
    local k = H("0b7d304f1f31158e")
    if not chNeedsWrap(LO, k, "loot item count") then return end
    local o = LO[k]
    LO[k] = function(c, id, ...)
      chSync()
      local n = tonumber(id) or -1
      probe("loot item count", id, CH.gums[n] or (CH.locked[n] and 0))
      if CH.gums[n] then return CH.gums[n] end
      if CH.locked[n] then return 0 end
      return o(c, id, ...)
    end
    chWrapped[LO] = LO[k]
    L("GobbleGum counts read locally")
  end)
end

local CUT_CAMOS = "MWII:12212;12120;12199;12087;12128;12205;12096;12190;12082;12043;12200;12033;12133;12092;12213;12184;12111;12109;12060;12065;12191;12035;12223;12154;12158;12055;12203;12135;12214;12046;12110;12163;12219;12089;12143;12052;12058;12112;12173;12077;12114;12028;12106;12021;12150;12234;12241;12251;12253;12231;12255;12246;12230;12235;12242;12250;12257;12232;12244,12607,12610,12613,12614,12615,12617,12620,12622,12626,12627,12628,12629,12631,12635,12636,12637,12653,12655,12660,12664,12665,12667,12668,12675,12677,12680,12682,12690,12691,12692,12695,12697,12700,12707,12708,12712,12719,12722,12731,12735,12736,12746,12753,12757,12759,12760,12761,12763,12764,12765,12766,12772,12773,12775,12776,12778,12786,20795,21358,21362,21379,24631,26126,26129,27981,27984,30029,30032,30834,34393,34657,34966,37460,37764,38526,38924,38927,38930;12256,12612,12619,12623,12625,12630,12633,12634,12638,12640,12641,12642,12643,12649,12663,12666,12669,12672,12674,12676,12678,12681,12683,12694,12698,12699,12702,12705,12710,12711,12715,12720,12721,12723,12724,12725,12726,12728,12729,12734,12740,12742,12743,12747,12750,12752,12755,12756,12758,12769,12770,12774,12779,12780,12781,12782,12783,12785,20796,21359,21363,21380,24632,26127,26130,27982,27985,30030,30033,30835,34394,34658,34967,37461,37765,38527,38925,38928,38931;12247,12608,12609,12611,12616,12618,12621,12624,12639,12644,12645,12646,12647,12648,12650,12651,12652,12654,12656,12657,12658,12659,12662,12670,12671,12673,12679,12685,12686,12687,12688,12693,12696,12701,12703,12706,12709,12713,12716,12717,12718,12727,12732,12733,12737,12738,12739,12741,12744,12745,12748,12749,12751,12754,12767,12771,12777,12784,20797,21360,21364,21381,24633,26128,26131,27983,27986,30031,30034,30836,34395,34659,34968,37462,37766,38528,38926,38929,38932;12237;12224;12148;12196;12049;12170;12166;12179;12085;12101;12017;12174;12116;12132;12118;12075;12053;12139;12157;12220;12036;12090;12042;12066;12192;12172;12022;12208;12097;12131;12126;12029;12054;12093;12094;12152;12030;12081;12091;12032;12144;12047;12069;12168;12034;12079;12107;12067;12108;12084;12115;12181;12195;12182;12123;12156;12119;12104;12041;12209;12098;12024;12225;12221;12040;12167;12048;12178;12068;12211;12129;12019;12226;12201;12127;12180;12146;12193;12177;12202;12102;12121;12210;12037;12169;12137;12023;12204;12151;12155;12165;12183;12061;12086;12141;12125;12026;12188;12044;12095;12039;12142;12222;12215;12057;12189;12078;12171;12138;12159;12045;12122;12134;12113;12062;12076;12088;12073;12147;12050;12160;12105;12136;12064;12218;12216;12027;12063;12187;12186;12072;12103;12099;12070;12074;12083;12176;12056;12124;12206;12185;12038;12197;12194;12020;12149;12140;12145;12153;12031;12175;12207;12117;12071;12164;12080;12059;12130;12162,24144,24145,24146,24147,24148,24149,24150,24151,24152,24153;12198;12018;12025;12217;12100;12051;12161;12239;12243;12238;12258;12236;12254;12227;12228;12248;12252;12233;12240;12229;12249;12245;26104;26105;26106;26107;26108;26109;26110;26111;29335;29336;29337;29338;29339;29340;29341;29355;29356;29357;27971,27972,27973,27974,27975,27976,27977,27978,27979,27980,29358;29359;29360;29361;29362;29363;29364;29365;29366;29367;29368;29369;19764;26112;29342;29343;29344;29345;29346;29347;29348;29349;29350;29351;29352,37484,37485,37486,37487,37488,37489,37490,37491,37492,37493;29353;29370;29371;29372;29373;29374;29375;29376;29377;29378;29379;29380;29381,33289,33290,33291,33292,33293,33294,33295,33296,33297,33298;29382;29383;29384;30180;30181;30182;30183;30184;30185;30186;30187;30188;30189;30190;30191;30192;30193;30194;30195;30196;30197;30198;30199;30200;30201;30202;30203;30204;30205;30206;30207;30208;30209;30210;30211;30212;30213;30214;30215;30216;30217;30226|MWIII:32117;32118;32122;32121;32120;32119;33347;33348;33349;33350;33351;33352;33353;33354;53827;32930;32931;32932;32933;32934;32935;32936;32937;32938;32939;32517;32518;32519;32520;32521;32522;32523;32566;32567;32568;32940;32524;32525;32526;32527;32528;32529;32530;32531;32532;32535;32536;32537;32538;32539;32540;32541;32542;32543;32544;32545;32546;32547;32548;32549;32550;32551;32552;32569;32570;32571;32572;32573;32574;51912;51913;32957;32958;32959;32960;32961;32962;32964;32965;32966;32967;32968;51917;32133;32134;32135;32136;32137;32138;32139;32140;32141;32142;32143;32144;32969;32553;32554;32555;32556;32557;32558;32575;32576;32577;32578;32579;32580;32581;32146;32147;32148;32149;32150;32151;51915;32981;32982;32983;32984;32985;32559;32560;32561;32562;32563;32564;32565;32582;32583;32584;32585;32586;45910;32993;32995;32996;32997;33000;34329;34330;34331;34332;34333;34334;34335;34336;33362;33365;33366;33367;32152;32153;32154;32155;32156;32157;51923,53824;51914;32158;32159;32160;53825;53826;53641;53955;36833,32483,32484,32485,32486,32487,32488,32489,32490,32491,32492,32718,32724,32727,32730,32735,32736,32739,32742,32745,32748,32751,32754,32757,32760,32763,32766,32769,32772,32775,32778,32781,34105,35792,35793,35799,36050,36053,45970,46086,46087,48560,48567,49703,53543,53546,54015,57617,57618,57619,57627,63279,63286,63293,63300,70816,70817,70818,70819,81709,81715;36834,32493,32494,32495,32496,32497,32498,32499,32500,32501,32502,32719,32725,32728,32731,32733,32737,32740,32743,32746,32749,32752,32755,32758,32761,32764,32767,32770,32773,32776,32780,32782,34104,35794,35795,36051,36054,36222,45971,46088,46089,48561,48566,49704,53544,53547,54016,57620,57621,57622,57628,63280,63287,63294,63301,70820,70821,70822,70823,81710,81716;36835,32503,32504,32505,32506,32507,32508,32509,32510,32511,32512,32720,32726,32729,32732,32734,32738,32741,32744,32747,32750,32753,32756,32759,32762,32765,32768,32771,32774,32777,32779,32783,34106,35796,35797,35800,36052,36055,45973,46090,46091,48562,48568,49705,53545,53548,54017,57623,57624,57625,57629,63281,63288,63295,63302,70824,70825,70826,70827,81711,81717;32513;44180;51924;51925;51926;51927;51928;45912;46048;46049;46050;45913;46051;46052;46053;46054;46055;46056;46057;46058;46060;48108;48109;48110;48111;48112;48113;48115;48116;45902;45903;45904;45905;45906;45907;45908;45909;53912;54834;56474;56473;56472;56471;56470;56469;56468;56466;56467;57053;56465;56464;56462;56463;56734;56733;56732;56731;56730;57054;57616;57615;57614;56729;56728;56727;58726;56736;56451;56450;56449;56448;56447;56446;56452;56475;56443;56444;56735;58017,58018,58021,58022,58023;56439;56438;56437;57626;58303;62079;62626;62625;62624;62623;62622;62621;62620;62619;62640;62639;62638;62637;62636;62618;62617;62616;62615;62614;62613;62612;62611;62635;62634;62633;62632;62631;62629;62628;62627;57664;65342;57663;65340;57661;57660;57659;57658;57657;57656;57655;57646;57645;57644;57738;57632;57631;57630;62630;65343;65345;65344;69212;69213;69214;68810;68809;68808;68807;68806;68805;68804;68803;70844;70843;68818;68817;68816;68815;68814;68813;68812;68811;68824;68823;68822;68821;68820;68819;68825;68826;68831;79899;79900;79901;70840;68830;68835;68829;68828;68836;68679;68827;68834;68833;68832;70842;83048;82102;82101;82100;82099;82098;82097;82096;82095;82108;82107;82106;82105;82104;82103;82109;82115;82114;82113;82112;82111;82110;82116;70096;82117;82118;82831;82122;82121;82119;82833;82832;82120;81723;81724;81725;82094;83044;83045;83046;83047;39274;39275;39276;39277;39278;39279;39280;39281;39282;39283;39284;39285;39286;39287;53831;39310;39311;39312;39313;39314;39315;39316;39317;39318;39319;39320;39321;39322;39323;39324;39325;39326;39327;39328;39329;39330;39338;39339;39340;39341;39342;39343;39344;39345;39346;39349;39350;39351;39352;39353;39354;39355;39356;39357;39358;39359;39360;39361;39362;39363;39364;39365;39366;39367;39368;39369;39370;39371;39372;52300;52301;39382;39383;39384;39385;39386;39387;39389;39390;39391;39392;39393;52297;39394;39395;39396;39397;39398;39399;39400;39401;39402;39403;39404;39405;39407;39419;39420;39421;39422;39423;39424;39425;39426;39427;39428;39429;39430;39431;39432;39433;39434;39435;39436;39437;53828;39438;39439;39440;39441;39442;39445;39446;39447;39448;39449;39450;39451;39452;39453;39454;39455;39456;45911;39460;39462;39463;39464;39467;39723;39724;39725;39726;39727;39728;39729;39730;39475;39478;39479;39480;39481;39482;39483;39484;39485;39486;45882;52302;39487;39488;39489;52304;53829;53830;45992,39495,39496,39497,39498,39499,39500,39501,39502,39503,39504,39505,39506,39507,39508,39509,39510,39511,39512,39513,39515,39516,39517,39518,39519,39520,39521,39522,39523,39524,39525,39526,45974,45975,45976,45977,45978,45979,47127,47405,47406,48563,48569,49706,54164,54165,54166,58812,58813,58814,60347,63282,63289,63296,63303,70828,70829,70830,70831,81712,81718;45993,39527,39528,39529,39530,39531,39532,39533,39534,39535,39536,39537,39538,39539,39540,39541,39542,39543,39544,39545,39547,39548,39549,39550,39551,39552,39553,39554,39555,39556,39557,39558,45980,45981,45982,45983,45984,45985,47128,47407,47408,48564,48570,49707,54167,54168,54169,58815,58816,58817,60348,63283,63290,63297,63304,70832,70833,70834,70835,81713,81719;45994,39559,39560,39561,39562,39563,39564,39565,39566,39567,39568,39569,39570,39571,39572,39573,39574,39575,39576,39577,39579,39580,39581,39582,39583,39584,39585,39586,39587,39588,39589,39590,45986,45987,45988,45989,45990,45991,47129,47409,47410,48565,48571,49708,54170,54171,54172,58818,58819,58820,60349,63284,63291,63298,63305,70836,70837,70838,70839,81714,81720;39591;43784;43785;43786;43787;43788;43789;43790;43791;43792;43793;43794;43795;43796;43797;43798;43799;43800;43802;43803;43805;43807;43808;43809;43810;43811;43812;43813;43814;43815;43816;43817;43818;43819;43820;43821;43822;43823;43825;43826;43828;43830;43831;43832;43833;43834;43835;43836;43837;43838;43839;43840;43841;43842;43843;43844;43845;43846;43847;43849;43851;43853;43854;43855;43856;43857;43858;43859;43860;43861;43862;43863;43864;43865;43866;43867;43868;43869;43872;43874;43876;43877;43878;43879;43880;43881;43882;43883;43884;43885;43886;43887;43888;43890;43891;43892;43895;43897;43899;43900;43901;43902;43903;43904;43905;43906;43907;43908;43909;43910;43911;43914;43915;43918;43919;43920;43922;43923;43924;43925;43926;43927;43928;43929;43930;43931;43932;43933;43934;43935;43936;43937;43938;43940;43941;43942;43943;43944;43945;43946;43947;43948;43949;43950;43951;43952;43953;43954;43955;43956;43957;43958;43959;43960;43963;43964;43966;43968;43969;43970;43971;43972;43973;43974;43975;43976;43977;43978;43979;43980;43981;43982;43983;43986;43987;43989;43991;43992;43993;43994;43995;43996;43997;43998;43999;44000;44001;44002;44003;44004;44005;44006;44009;44010;44012;44014;44015;44016;44017;44018;44019;44020;44021;44022;44023;44024;44025;44026;44027;44028;44029;44032;44033;44035;44037;44038;44039;44040;44041;44042;44043;44044;44045;44046;44047;44048;44049;44050;44051;44052;44055;44056;44058;44060;44061;44062;44063;44064;44065;44066;44067;44068;44069;44070;44071;44072;44073;44074;44075;44078;44079;44081;44083;44084;44085;44086;44087;44088;44089;44090;44091;44092;44093;44094;44095;44097;44101;44102;44104;44106;44107;44108;44109;44110;44111;44112;44113;44114;44115;44116;44117;44118;44120;44121;44124;44125;44127;45471,45472,45473,45474,45475,45476,45477,45478,45479,45480,45481,45482,45483,45484,45485,45486,45487,45488,45490,45491,45492,45493,45494,45495,45496,45497,45498,45499,45500,45501,45502,45503,45504,45505,45506,45507,45508,45509,45510,45511,45512,45513,45514,45516,45518,45519,45520,45521,45522,45523,45524,45525,45526,45527,45528,45529,45530,45531,45532,45533,45534,45535,45536,45537,45538,45539,45540,45541,45542,45543,45544,45545,45546,45547,45548,45549,45550,45551;45552,45553,45554,45555,45556,45557,45558,45559,45560,45561,45562,45563,45564,45565,45566,45567,45568,45569,45571,45572,45573,45574,45575,45576,45577,45578,45579,45580,45581,45582,45583,45584,45585,45586,45587,45588,45589,45590,45591,45592,45593,45594,45595,45597,45599,45600,45601,45602,45603,45604,45605,45606,45607,45608,45609,45610,45611,45612,45613,45614,45615,45616,45617,45618,45619,45620,45621,45622,45623,45624,45625,45626,45627,45628,45629,45630,45631,45632;45633,45634,45635,45636,45637,45638,45639,45640,45641,45642,45643,45644,45645,45646,45647,45648,45649,45650,45652,45653,45654,45655,45656,45657,45658,45659,45660,45661,45662,45663,45664,45665,45666,45667,45668,45669,45670,45671,45672,45673,45674,45675,45676,45678,45680,45681,45682,45683,45684,45685,45686,45687,45688,45689,45690,45691,45692,45693,45694,45695,45696,45697,45698,45699,45700,45701,45702,45703,45704,45705,45706,45707,45708,45709,45710,45711,45712,45713;45714;70846;70845;81722;81721;61305,58313,58314,58315,62742,62743,62744,62745,62746,62747,62748,62749,62750,62751,62752,62753,62754,62755,62756,62757,62758,62759,62760,62761,62762,62763,62764,62765,62766,62767,62768,62769,62770,62771,62772,62773,62774,62775,62776,62777,62778,62779,62780,62781,62782,62783,62784,62785,62786,62787,62788,63285,63292,63299,63306,63797,63798,63799,63800,63801,63802,63803,63804,63805,63806,63807,63808,63809,63810,63811,63812,63813,63814,63815,63816,63817,63818,63819,63820,63821,63822,63823,63824,63825,63826,63827,63828,63829,63830,63831,63832,63833,63834,63835,63836,63837,63838,63839,63840,63841,63842,63843,63844,63845,63846,63847,63848,63849,63850,63851,63852,63853,63854,63855,63856,63857,63858,63859,63860,63861,63862,63863,63864,63865,63866,63867,63868,63869,63870,63871,63872,63873,63874,63875,68275,68276,68281,68282,81701,81705;63955,63876,63877,63878,63879,63880,63881,63882,63883,63884,63885,63886,63887,63888,63889,63890,63891,63892,63893,63894,63895,63896,63897,63898,63899,63900,63901,63902,63903,63904,63905,63906,63907,63908,63909,63910,63911,63912,63913,63914,63915,63916,63917,63918,63919,63920,63921,63922,63923,63924,63925,63926,63927,63928,63929,63930,63931,63932,63933,63934,63935,63936,63937,63938,63939,63940,63941,63942,63943,63944,63945,63946,63947,63948,63949,63950,63951,63952,63953,63954,63956,63957,63958,63959,63960,63961,63962,63963,63964,63965,63966,63967,63968,63969,63970,63971,63972,63973,63974,63975,63976,63977,63978,63979,63980,63981,63982,63983,63984,63985,63986,63987,63988,63989,63990,63991,63992,63993,63994,63995,63996,63997,63998,63999,64000,64001,64002,64003,64004,64005,64006,64007,64008,64009,68277,68278,68283,68284,81702,81706;68140,68142,68143,68144,68145,68146,68147,68148,68149,68150,68151,68152,68153,68154,68155,68156,68157,68158,68159,68160,68161,68162,68163,68164,68165,68166,68167,68168,68169,68170,68171,68172,68173,68174,68175,68176,68177,68178,68179,68180,68181,68182,68183,68184,68185,68186,68187,68188,68189,68190,68191,68192,68193,68194,68195,68196,68197,68198,68199,68200,68201,68202,68203,68204,68205,68206,68207,68208,68209,68210,68211,68212,68213,68214,68215,68216,68217,68218,68219,68220,68221,68222,68223,68224,68225,68226,68227,68228,68229,68230,68231,68232,68233,68234,68235,68236,68237,68238,68239,68240,68241,68242,68243,68244,68245,68246,68247,68248,68249,68250,68251,68252,68253,68254,68255,68256,68257,68258,68259,68260,68261,68262,68263,68264,68265,68266,68267,68268,68269,68270,68271,68272,68273,68274,68279,68280,68285,68286,81703,81707;68141,68287,68288,68289,68290,68291,68292,68293,68294,68295,68296,68297,68298,68299,68300,68301,68302,68303,68304,68305,68306,68307,68308,68309,68310,68311,68312,68313,68314,68315,68316,68317,68318,68319,68320,68321,68322,68323,68324,68325,68326,68327,68328,68329,68330,68331,68332,68333,68334,68335,68336,68337,68338,68339,68340,68341,68342,68343,68344,68345,68346,68347,68348,68349,68350,68351,68352,68353,68354,68355,68356,68357,68358,68359,68360,68361,68362,68363,68364,68365,68366,68367,68368,68369,68370,68371,68372,68373,68374,68375,68376,68377,68378,68379,68380,68381,68382,68383,68384,68385,68386,68387,68388,68389,68390,68391,68392,68393,68394,68395,68396,68397,68398,68399,68400,68401,68402,68403,68404,68405,68406,68407,68408,68409,68410,68411,68412,68413,68414,68415,68416,68417,68418,68419,68420,68421,68422,68423,81704,81708;45883;45884;45885;45886;45887;45888;45889;45890;45891;45892;45893;45894;52045;52150;52151;52152;52153;52154;52155;52156;52157;53555;44179;47672;50228;51713;52142;52143;52144;52145;52147;52148;52149;52291;52292;52293;52295;53551;53552;53553;53554|BO6:63032;70654;70655;70656;70657;70658;70659;70660;70661;70662;70663;70664;70665;70666;70667;70668;70669;70670;70671;70672;70673;70674;70675;70676;90144;90168;90192;90145;90169;90193;90146;90170;90194;90147;90171;90195;90148;90172;90196;90149;90173;90197;90150;90174;90198;72073,65310,65319,72233,72234,72235,72236,72237,72238,72239,72240,72241,72242,72243,72244,72245,72246,72247,72248,72249,72250,72251,72252,72253,72254,72255,72256,72257,72258,72259,72260,72261,72262,72263,72264,87879,87880,87881,87882,87883,87884,87885,92548,92564,92570,92575,92633,92653,92725,92732,92759,95776,95806,95822,95874,95922,95933,96586,101271,101304,101321,107796,107816,114021,114032,114040,120298,120350,120367,120375;72074,72265,72266,72267,72268,72269,72270,72271,72272,72273,72274,72275,72276,72277,72278,72279,72280,72281,72282,72283,72284,72285,72286,72287,72288,72289,72290,72291,72292,72293,72294,72295,72296,72297,72298,87886,87887,87888,87889,87890,87891,87892,92573,92585,92627,92650,92675,92687,92723,92733,92743,95784,95813,95852,95865,95909,95960,96595,101279,101300,101302,107749,107787,113947,113999,114025,120285,120320,120349,120360;72075,72299,72300,72301,72302,72303,72304,72305,72306,72307,72308,72309,72310,72311,72312,72313,72314,72315,72316,72317,72318,72319,72320,72321,72322,72323,72324,72325,72326,72327,72328,72329,72330,72331,72332,87893,87894,87895,87896,87897,87898,87899,92519,92529,92533,92591,92604,92656,92679,92689,92724,95783,95788,95796,95888,95889,95903,96589,101312,101320,101331,107783,107790,113959,113993,114011,120262,120323,120335,120372;72076,65311,65320,72333,72334,72335,72336,72337,72338,72339,72340,72341,72342,72343,72344,72345,72346,72347,72348,72349,72350,72351,72352,72353,72354,72355,72356,72357,72358,72359,72360,72361,72362,72363,72364,87900,87901,87902,87903,87904,87905,87906,92544,92598,92611,92616,92625,92628,92635,92644,92664,95789,95795,95835,95917,95964,95982,96563,101281,101339,101347,107779,107818,113952,113974,114035,120244,120257,120280,120297;72077,72365,72366,72367,72368,72369,72370,72371,72372,72373,72374,72375,72376,72377,72378,72379,72380,72381,72382,72383,72384,72385,72386,72387,72388,72389,72390,72391,72392,72393,72394,72395,72396,72397,72398,87907,87908,87909,87910,87911,87912,87913,92550,92552,92580,92594,92607,92641,92704,92718,92734,95772,95785,95794,95885,95928,95992,96558,101298,101344,101351,107770,107824,113938,113971,113997,120266,120272,120330,120354;72078,72399,72400,72401,72402,72403,72404,72405,72406,72407,72408,72409,72410,72411,72412,72413,72414,72415,72416,72417,72418,72419,72420,72421,72422,72423,72424,72425,72426,72427,72428,72429,72430,72431,72432,87914,87915,87916,87917,87918,87919,87920,92528,92534,92576,92578,92584,92590,92619,92634,92683,95819,95834,95836,95839,95845,95862,96594,101314,101323,101345,107748,107750,113933,113954,114016,120319,120321,120326,120358;72079,65312,65321,72433,72434,72435,72436,72437,72438,72439,72440,72441,72442,72443,72444,72445,72446,72447,72448,72449,72450,72451,72452,72453,72454,72455,72456,72457,72458,72459,72460,72461,72462,72463,72464,87921,87922,87923,87924,87925,87926,87927,92549,92583,92597,92700,92701,92716,92717,92737,92756,95763,95782,95863,95976,95977,95979,96584,101276,101295,101307,107755,107804,113984,114000,114015,120252,120312,120355,120384;72080,72465,72466,72467,72468,72469,72470,72471,72472,72473,72474,72475,72476,72477,72478,72479,72480,72481,72482,72483,72484,72485,72486,72487,72488,72489,72490,72491,72492,72493,72494,72495,72496,72497,72498,87928,87929,87930,87931,87932,87933,87934,92526,92530,92582,92596,92623,92676,92677,92706,92710,95768,95779,95857,95879,95916,95971,96570,101329,101333,101350,107753,107766,113949,114029,114036,120278,120314,120378,120382;72081,72499,72500,72501,72502,72503,72504,72505,72506,72507,72508,72509,72510,72511,72512,72513,72514,72515,72516,72517,72518,72519,72520,72521,72522,72523,72524,72525,72526,72527,72528,72529,72530,72531,72532,87935,87936,87937,87938,87939,87940,87941,92562,92610,92617,92662,92693,92695,92705,92727,92754,95854,95880,95915,95919,95955,95990,96567,101286,101288,101340,107764,107773,113934,113957,114001,120289,120300,120340,120343;72082,65313,65322,72533,72534,72535,72536,72537,72538,72539,72540,72541,72542,72543,72544,72545,72546,72547,72548,72549,72550,72551,72552,72553,72554,72555,72556,72557,72558,72559,72560,72561,72562,72563,72564,87942,87943,87944,87945,87946,87947,87948,92521,92531,92532,92587,92609,92640,92673,92684,92726,95810,95828,95841,95886,95913,95974,96574,101280,101301,101319,107761,107793,113936,114030,114045,120287,120311,120356,120369;72083,72565,72566,72567,72568,72569,72570,72571,72572,72573,72574,72575,72576,72577,72578,72579,72580,72581,72582,72583,72584,72585,72586,72587,72588,72589,72590,72591,72592,72593,72594,72595,72596,72597,72598,87949,87950,87951,87952,87953,87954,87955,92542,92560,92563,92569,92574,92600,92602,92703,92713,95797,95825,95896,95910,95948,95950,96569,101294,101305,101324,107768,107819,113945,113969,113998,120254,120294,120346,120386;72084,72599,72600,72601,72602,72603,72604,72605,72606,72607,72608,72609,72610,72611,72612,72613,72614,72615,72616,72617,72618,72619,72620,72621,72622,72623,72624,72625,72626,72627,72628,72629,72630,72631,72632,87956,87957,87958,87959,87960,87961,87962,92546,92579,92608,92666,92670,92688,92712,92722,92758,95769,95855,95908,95929,95942,95962,96587,101272,101290,101332,107780,107825,113960,113991,114038,120258,120292,120368,120392;72085,65314,65323,72633,72634,72635,72636,72637,72638,72639,72640,72641,72642,72643,72644,72645,72646,72647,72648,72649,72650,72651,72652,72653,72654,72655,72656,72657,72658,72659,72660,72661,72662,72663,72664,87963,87964,87965,87966,87967,87968,87969,92536,92539,92595,92620,92655,92658,92720,92735,92761,95766,95815,95869,95957,95980,95983,96571,101336,101341,101346,107781,107786,113966,114004,114049,120255,120265,120270,120296;72086,72665,72666,72667,72668,72669,72670,72671,72672,72673,72674,72675,72676,72677,72678,72679,72680,72681,72682,72683,72684,72685,72686,72687,72688,72689,72690,72691,72692,72693,72694,72695,72696,72697,72698,87970,87971,87972,87973,87974,87975,87976,92522,92554,92601,92612,92636,92708,92742,92745,92749,95759,95765,95895,95906,95968,95988,96564,101274,101275,101325,107797,107799,113979,113985,114006,120259,120286,120331,120376;72087,72699,72700,72701,72702,72703,72704,72705,72706,72707,72708,72709,72710,72711,72712,72713,72714,72715,72716,72717,72718,72719,72720,72721,72722,72723,72724,72725,72726,72727,72728,72729,72730,72731,72732,87977,87978,87979,87980,87981,87982,87983,92520,92540,92577,92588,92592,92622,92691,92748,92757,95871,95890,95892,95946,95958,95986,96592,101291,101308,101338,107772,107794,113995,114026,114041,120301,120307,120313,120347;72088,65315,65324,72733,72734,72735,72736,72737,72738,72739,72740,72741,72742,72743,72744,72745,72746,72747,72748,72749,72750,72751,72752,72753,72754,72755,72756,72757,72758,72759,72760,72761,72762,72763,72764,87984,87985,87986,87987,87988,87989,87990,92524,92541,92553,92558,92639,92660,92663,92685,92750,95767,95902,95932,95934,95938,95984,96576,101278,101306,101315,107758,107778,113951,114005,114042,120261,120348,120377,120387;72089,72765,72766,72767,72768,72769,72770,72771,72772,72773,72774,72775,72776,72777,72778,72779,72780,72781,72782,72783,72784,72785,72786,72787,72788,72789,72790,72791,72792,72793,72794,72795,72796,72797,72798,87991,87992,87993,87994,87995,87996,87997,92547,92566,92603,92615,92624,92669,92681,92714,92736,95787,95793,95807,95867,95952,95978,96568,101283,101303,101327,107771,107785,113982,114027,114034,120309,120316,120338,120388;72090,72799,72800,72801,72802,72803,72804,72805,72806,72807,72808,72809,72810,72811,72812,72813,72814,72815,72816,72817,72818,72819,72820,72821,72822,72823,72824,72825,72826,72827,72828,72829,72830,72831,72832,87998,87999,88000,88001,88002,88003,88004,92523,92527,92545,92645,92648,92715,92738,92739,92740,95762,95770,95792,95824,95830,95944,96590,101287,101309,101348,107760,107798,113943,113989,114019,120267,120304,120381,120394;72091,65316,65325,72833,72834,72835,72836,72837,72838,72839,72840,72841,72842,72843,72844,72845,72846,72847,72848,72849,72850,72851,72852,72853,72854,72855,72856,72857,72858,72859,72860,72861,72862,72863,72864,88005,88006,88007,88008,88009,88010,88011,92613,92614,92629,92647,92661,92671,92686,92702,92711,95805,95809,95846,95898,95904,95923,96560,101285,101317,101326,107754,107814,113992,114044,114047,120276,120332,120334,120351;72092,72865,72866,72867,72868,72869,72870,72871,72872,72873,72874,72875,72876,72877,72878,72879,72880,72881,72882,72883,72884,72885,72886,72887,72888,72889,72890,72891,72892,72893,72894,72895,72896,72897,72898,88012,88013,88014,88015,88016,88017,88018,92559,92567,92586,92651,92657,92692,92698,92741,92744,95771,95803,95914,95926,95935,95970,96566,101297,101311,101342,107751,107809,113963,113994,114022,120274,120336,120371,120393;72093,72899,72900,72901,72902,72903,72904,72905,72906,72907,72908,72909,72910,72911,72912,72913,72914,72915,72916,72917,72918,72919,72920,72921,72922,72923,72924,72925,72926,72927,72928,72929,72930,72931,72932,88019,88020,88021,88022,88023,88024,88025,92556,92581,92606,92694,92719,92730,92747,92752,92753,95781,95786,95832,95840,95844,95851,96581,101273,101330,101337,107752,107765,113986,114014,114046,120273,120328,120341,120353;72094,65317,65326,72933,72934,72935,72936,72937,72938,72939,72940,72941,72942,72943,72944,72945,72946,72947,72948,72949,72950,72951,72952,72953,72954,72955,72956,72957,72958,72959,72960,72961,72962,72963,72964,88026,88027,88028,88029,88030,88031,88032,92535,92572,92589,92599,92618,92631,92665,92672,92721,95823,95837,95873,95924,95981,95987,96562,101277,101289,101343,107784,107815,113944,113953,114002,120284,120361,120363,120385;72095,72965,72966,72967,72968,72969,72970,72971,72972,72973,72974,72975,72976,72977,72978,72979,72980,72981,72982,72983,72984,72985,72986,72987,72988,72989,72990,72991,72992,72993,72994,72995,72996,72997,72998,88033,88034,88035,88036,88037,88038,88039,92551,92557,92565,92571,92643,92649,92654,92680,92707,95778,95881,95912,95927,95931,95959,96579,101316,101318,101334,107774,107800,113975,114013,114037,120253,120281,120282,120379;72096,72999,73000,73001,73002,73003,73004,73005,73006,73007,73008,73009,73010,73011,73012,73013,73014,73015,73016,73017,73018,73019,73020,73021,73022,73023,73024,73025,73026,73027,73028,73029,73030,73031,73032,88040,88041,88042,88043,88044,88045,88046,92537,92555,92593,92621,92637,92668,92678,92682,92690,95884,95897,95925,95956,95985,95991,96565,101299,101328,101349,107805,107821,114008,114023,114033,120306,120337,120357,120362;72097,65318,65327,73033,73034,73035,73036,73037,73038,73039,73040,73041,73042,73043,73044,73045,73046,73047,73048,73049,73050,73051,73052,73053,73054,73055,73056,73057,73058,73059,73060,73061,73062,73063,73064,88047,88048,88049,88050,88051,88052,88053,92525,92543,92568,92626,92632,92652,92674,92728,92755,95764,95821,95826,95901,95930,95943,96578,101282,101284,101310,107756,107807,113956,113970,113973,120263,120288,120352,120383;72098,73065,73066,73067,73068,73069,73070,73071,73072,73073,73074,73075,73076,73077,73078,73079,73080,73081,73082,73083,73084,73085,73086,73087,73088,73089,73090,73091,73092,73093,73094,73095,73096,73097,73098,88054,88055,88056,88057,88058,88059,88060,92561,92638,92646,92667,92697,92699,92709,92729,92760,95808,95843,95847,95918,95939,95945,96572,101292,101293,101322,107767,107810,113955,114007,114039,120277,120291,120329,120391;72099,73099,73100,73101,73102,73103,73104,73105,73106,73107,73108,73109,73110,73111,73112,73113,73114,73115,73116,73117,73118,73119,73120,73121,73122,73123,73124,73125,73126,73127,73128,73129,73130,73131,73132,88061,88062,88063,88064,88065,88066,88067,92538,92605,92630,92642,92659,92696,92731,92746,92751,95868,95883,95937,95949,95954,95975,96591,101296,101313,101335,107762,107812,113942,113990,114003,120243,120271,120322,120342;63033;70678;70679;70680;70681;70682;70683;70684;70685;70686;70687;70688;70689;70690;70691;70692;70693;70694;70695;70696;70697;70698;70699;70700;90152;90176;90200;90153;90177;90201;90154;90178;90202;90155;90179;90203;90156;90180;90204;63034;70701;70702;70703;70704;70705;70706;70707;70708;70709;70710;70711;70712;70713;70714;70715;70716;70717;70718;70719;70720;70721;70722;70723;90160;90184;90208;90161;90185;90209;90162;90186;90210;90163;90187;90211;90164;90188;90212;90165;90189;90213;90166;90190;90214;72158,65328,65332,73177,73178,73179,73180,73181,73182,73183,73184,73185,73186,73187,73188,73189,73190,73191,73192,73193,73194,73195,73196,73197,73198,73199,73200,73201,73202,73203,73204,73205,73206,73207,73208,88754,88755,88756,88757,88758,88759,88760,93099,93109,93137,93149,93158,93163,93179,93202,93203,95773,95780,95856,95891,95907,95940,96580,101399,101412,101421,107775,107795,113961,113987,114010,120279,120310,120345,120390;72159,73209,73210,73211,73212,73213,73214,73215,73216,73217,73218,73219,73220,73221,73222,73223,73224,73225,73226,73227,73228,73229,73230,73231,73232,73233,73234,73235,73236,73237,73238,73239,73240,73241,73242,88761,88762,88763,88764,88765,88766,88767,93110,93117,93118,93160,93161,93167,93171,93190,93193,95791,95818,95853,95911,95920,95951,96577,101401,101415,101419,107806,107813,113958,113967,113983,120251,120256,120374,120380;72160,73243,73244,73245,73246,73247,73248,73249,73250,73251,73252,73253,73254,73255,73256,73257,73258,73259,73260,73261,73262,73263,73264,73265,73266,73267,73268,73269,73270,73271,73272,73273,73274,73275,73276,88768,88769,88770,88771,88772,88773,88774,93129,93132,93142,93147,93155,93170,93175,93194,93198,95777,95814,95858,95866,95941,95947,96596,101394,101403,101418,107757,107820,113935,114012,120283,120305,120327,120339;72161,65329,65333,73277,73278,73279,73280,73281,73282,73283,73284,73285,73286,73287,73288,73289,73290,73291,73292,73293,73294,73295,73296,73297,73298,73299,73300,73301,73302,73303,73304,73305,73306,73307,73308,88775,88776,88777,88778,88779,88780,88781,93100,93101,93108,93139,93151,93159,93187,93201,93206,95817,95820,95838,95877,95953,95972,96585,101407,101411,101424,107777,107788,113948,113968,120245,120365,120370,120389;72162,73309,73310,73311,73312,73313,73314,73315,73316,73317,73318,73319,73320,73321,73322,73323,73324,73325,73326,73327,73328,73329,73330,73331,73332,73333,73334,73335,73336,73337,73338,73339,73340,73341,73342,88782,88783,88784,88785,88786,88787,88788,93105,93115,93116,93119,93128,93144,93153,93164,93176,95804,95827,95894,95900,95966,95967,96582,101398,101405,101414,107776,107817,113981,114009,120250,120308,120317,120395;72163,73343,73344,73345,73346,73347,73348,73349,73350,73351,73352,73353,73354,73355,73356,73357,73358,73359,73360,73361,73362,73363,73364,73365,73366,73367,73368,73369,73370,73371,73372,73373,73374,73375,73376,88789,88790,88791,88792,88793,88794,88795,93103,93121,93127,93156,93168,93178,93181,93183,93191,95790,95811,95831,95848,95860,95878,96593,101396,101397,101420,107759,107808,113965,113996,120246,120318,120333,120373;72164,65330,65334,73377,73378,73379,73380,73381,73382,73383,73384,73385,73386,73387,73388,73389,73390,73391,73392,73393,73394,73395,73396,73397,73398,73399,73400,73401,73402,73403,73404,73405,73406,73407,73408,88796,88797,88798,88799,88800,88801,88802,93102,93134,93136,93162,93173,93180,93192,93197,93205,95760,95842,95861,95887,95936,95989,96561,101392,101416,101426,107791,107811,113937,113978,120290,120293,120344,120366;72165,73409,73410,73411,73412,73413,73414,73415,73416,73417,73418,73419,73420,73421,73422,73423,73424,73425,73426,73427,73428,73429,73430,73431,73432,73433,73434,73435,73436,73437,73438,73439,73440,73441,73442,88803,88804,88805,88806,88807,88808,88809,93106,93122,93125,93131,93135,93138,93157,93188,93200,95798,95799,95801,95812,95872,95875,96573,101393,101404,101427,107769,107801,114028,114048,120247,120269,120275,120295;72166,73443,73444,73445,73446,73447,73448,73449,73450,73451,73452,73453,73454,73455,73456,73457,73458,73459,73460,73461,73462,73463,73464,73465,73466,73467,73468,73469,73470,73471,73472,73473,73474,73475,73476,88810,88811,88812,88813,88814,88815,88816,93107,93111,93113,93141,93166,93169,93174,93195,93199,95833,95849,95859,95905,95921,95973,96583,101400,101410,101417,107763,107803,113950,113962,120268,120303,120359,120364;72167,65331,65335,73477,73478,73479,73480,73481,73482,73483,73484,73485,73486,73487,73488,73489,73490,73491,73492,73493,73494,73495,73496,73497,73498,73499,73500,73501,73502,73503,73504,73505,73506,73507,73508,88817,88818,88819,88820,88821,88822,88823,93114,93124,93140,93145,93146,93148,93165,93184,93196,95774,95800,95802,95850,95864,95961,96588,101413,101422,101423,107789,107802,113941,113946,120241,120264,120299,120325;72168,73509,73510,73511,73512,73513,73514,73515,73516,73517,73518,73519,73520,73521,73522,73523,73524,73525,73526,73527,73528,73529,73530,73531,73532,73533,73534,73535,73536,73537,73538,73539,73540,73541,73542,88824,88825,88826,88827,88828,88829,88830,93104,93123,93130,93133,93177,93185,93186,93189,93204,95761,95775,95816,95829,95870,95882,96559,101402,101406,101408,107782,107823,113976,114017,120248,120302,120315,120324;72169,73543,73544,73545,73546,73547,73548,73549,73550,73551,73552,73553,73554,73555,73556,73557,73558,73559,73560,73561,73562,73563,73564,73565,73566,73567,73568,73569,73570,73571,73572,73573,73574,73575,73576,88831,88832,88833,88834,88835,88836,88837,93112,93120,93126,93143,93150,93152,93154,93172,93182,95876,95893,95899,95963,95965,95969,96575,101395,101409,101425,107792,107822,113964,114031,120240,120242,120249,120260;63035;70724;70725;70726;70727;70728;70729;70730;70731;70732;70733;70734;70735;70736;70737;70738;70739;70740;70741;70742;70743;70744;70745;70746;90254;90278;90302;90255;90279;90303;90256;90280;90304;63036;70747;70748;70749;70750;70751;70752;70753;70754;70755;70756;70757;70758;70759;70760;70761;70762;70763;70764;70765;70766;70767;70768;70769;90262;90286;90310;90263;90287;90311;90264;90288;90312;90265;90289;90313;90266;90290;90314;63037;71778;71779;71780;71781;71782;71783;71784;71785;71786;71787;71788;71789;71790;71791;71792;71793;71794;71795;71796;71797;71798;71799;71800;90270;90294;90318;90271;90295;90319;63038;71834;71835;71836;71837;71856;71838;71839;71840;71841;71842;71843;71844;71845;71846;71847;71848;71849;71850;71851;71852;71853;71854;71855;90413;90437;90461;90414;90438;90462;90415;90439;90463;90416;90440;90464;63039;71973;71974;71975;71976;71977;71978;71979;71980;71981;71982;71983;71984;71985;71986;71987;71988;71989;71990;71991;71992;71993;71994;71995;90421;90445;90469;90422;90446;90470;81434;99388;101184;63040;71996;71997;71998;71999;72000;72001;72002;72003;72004;72005;72006;72007;72008;72009;72010;72011;72012;72013;72014;72015;72016;72017;72018;90429;90453;90477;90430;90454;90478;90431;90455;90479;90432;90456;90480;63041;72019;72020;72021;72022;72023;72024;72025;72026;72027;72028;72029;72030;72031;72032;72033;72034;72035;72036;72037;72038;63042;72042;72043;72044;72045;72046;72047;72048;72049;72050;72051;72052;72053;72054;72055;72056;72057;72058;72059;72060;72061;63043;90784;90800;90769;90785;90801;90770;90786;90802;90771;90787;90803;90772;90788;90804;90773;90789;90805;90774;90790;90806;90775;90791;90807;90776;90792;90808;63044;90831;90847;90816;90832;90848;90817;90833;90849;90818;90834;90850;58117;58118;58119;90125;90127;90128;90129;90130;90131;90132;101785;101787;101782;101783;101784;101786;119434;119430;119435;119432;119433;119431;90126;90135;90136;90137;90138;90139;90140;93392;96347;97618;99729;99728;85052;85051;85043;85054;85050;85048;85042;85045;85053;85047;85046;85049;85044;99702;99701;120024;120026;120023;120027;120025;107613;107612;116364|BO7 Cut Content:105220,105266,105283,105291,105295,105313,105322,105358,105360,105371,105380,105422,105433,105479,105496,105527,105528,105544,105556,105575,105651,105686,105696,105717,105745,105756,105795,105877,105882,107255,107269,123809,123862,123887,123981,124032,124035,124043,127488,127497,127511,127522,127597,127671,128697,131532,131536,131605,131669,131676,131700,141853,141869,141878,141929,142903,142985,148089,148133,148155,149720,150974,150988,151002,151009;105239,105285,105303,105375,105389,105395,105410,105455,105477,105503,105507,105549,105552,105596,105622,105634,105691,105703,105714,105744,105750,105762,105798,105843,105866,105894,105904,105916,105924,107220,107274,123869,123871,123896,123923,123948,123998,124017,127475,127509,127524,127531,127601,127646,128680,131541,131629,131675,131707,131710,131713,141855,141935,141939,141965,142952,142991,148109,148149,148172,149760,150913,150922,150944,150994;105202,105335,105343,105363,105392,105394,105396,105411,105412,105414,105439,105443,105448,105486,105545,105565,105620,105629,105653,105683,105713,105729,105783,105785,105786,105807,105809,105812,105901,107265,107288,123819,123888,123902,123925,123967,124024,124033,127503,127512,127595,127627,127649,127678,128679,131544,131606,131663,131684,131709,131711,141865,141907,141914,141925,142910,142981,148099,148106,148124,149734,150891,150898,150914,150966;105214,105268,105301,105305,105312,105321,105350,105464,105476,105500,105501,105502,105567,105585,105607,105645,105694,105710,105754,105827,105828,105832,105849,105888,105898,105902,105909,105915,105923,107211,107219,123804,123832,123872,123881,123882,123898,123904,127525,127541,127545,127618,127626,127673,128649,131516,131545,131570,131576,131620,131704,141877,141879,141886,141936,142938,142989,148098,148175,148180,149725,150928,150951,150971,150976;105240,105279,105281,105302,105310,105311,105323,105338,105404,105415,105463,105518,105580,105586,105597,105601,105668,105704,105716,105727,105758,105759,105765,105782,105838,105842,105856,105867,105889,107215,107293,123811,123851,123858,123891,123920,123978,124003,127538,127571,127624,127643,127664,127675,128653,131530,131571,131590,131619,131689,131696,141954,141964,141970,141991,142930,142983,148080,148090,148145,149761,150895,150940,150943,150996;105180,105274,105293,105304,105325,105326,105330,105385,105408,105505,105521,105524,105541,105583,105605,105630,105643,105664,105678,105697,105751,105760,105781,105790,105847,105848,105868,105878,105899,107214,107228,123850,123868,123895,123932,123951,123957,123969,127489,127520,127540,127568,127570,127598,128695,131633,131638,131687,131693,131712,131717,141895,141904,141927,141976,142978,142982,148091,148122,148125,149759,150905,150910,150953,150986;105187,105258,105270,105397,105438,105453,105462,105546,105587,105592,105626,105640,105644,105659,105679,105687,105692,105702,105735,105737,105748,105771,105774,105857,105891,105895,105906,105907,105926,107217,107263,123810,123831,123876,123900,123983,123994,124044,127478,127514,127546,127555,127621,127647,128662,131547,131566,131578,131621,131640,131724,141850,141862,141868,141932,142904,142956,148127,148140,148176,149722,150877,150907,150947,150961;105234,105292,105345,105367,105374,105386,105387,105442,105511,105540,105550,105553,105579,105588,105624,105707,105712,105726,105742,105787,105801,105815,105822,105831,105871,105875,105910,105919,105929,107249,107279,123901,123944,123959,123988,123992,124022,124040,127492,127530,127532,127650,127662,127669,128639,131514,131552,131556,131614,131658,131708,141858,141900,141941,141975,142926,142928,148096,148170,148177,149768,150892,150967,150989,151004;105241,105261,105280,105306,105320,105328,105364,105368,105369,105388,105420,105458,105473,105498,105536,105542,105578,105631,105663,105665,105690,105731,105738,105768,105784,105789,105814,105837,105921,107199,107294,123847,123867,123916,123921,123972,123999,124029,127483,127484,127527,127608,127619,127660,128657,131527,131538,131579,131674,131682,131697,141849,141871,141897,141940,142933,142966,148135,148158,148173,149776,150881,150945,150959,150995;105221,105332,105346,105349,105391,105429,105447,105459,105488,105514,105532,105538,105569,105649,105652,105654,105661,105736,105743,105788,105792,105800,105817,105821,105841,105851,105874,105892,105912,107206,107243,123889,123915,123966,123970,123973,123990,124039,127505,127528,127552,127584,127658,127682,128661,131611,131631,131642,131661,131664,131715,141915,141957,141960,141969,142963,142980,148094,148104,148121,149717,150909,150948,150979,151019;105179,105390,105403,105418,105431,105451,105452,105489,105492,105515,105533,105558,105655,105680,105705,105711,105746,105761,105766,105776,105802,105833,105834,105846,105852,105880,105884,105900,105917,107230,107296,123800,123817,123824,123827,123828,123854,124048,127487,127559,127564,127592,127606,127633,128696,131517,131557,131568,131678,131718,131725,141861,141881,141946,141967,142906,143002,148116,148144,148157,149765,150911,150984,151005,151015;105235,105297,105339,105351,105366,105417,105424,105446,105467,105472,105483,105491,105508,105520,105522,105526,105568,105606,105616,105637,105650,105709,105721,105749,105757,105773,105775,105825,105829,107227,107242,123826,123874,123897,124030,124036,124045,124046,127485,127558,127586,127617,127637,127657,128704,131534,131564,131583,131627,131690,131698,141866,141884,141921,141959,142907,142994,148075,148123,148161,149728,150883,150886,150985,150990;105181,105259,105267,105276,105286,105314,105370,105382,105393,105401,105402,105416,105466,105499,105519,105608,105614,105627,105635,105662,105685,105715,105753,105793,105839,105869,105896,105908,105925,107175,107179,123884,123893,123937,123980,123987,124001,124026,127573,127576,127613,127630,127644,127668,128694,131598,131647,131665,131671,131716,131722,141911,141912,141974,141978,142927,142976,148132,148141,148164,149767,150919,150929,150991,150992;105209,105263,105318,105324,105362,105372,105399,105425,105432,105434,105454,105494,105530,105642,105658,105673,105681,105693,105740,105763,105767,105770,105780,105805,105810,105813,105873,105897,105911,107185,107198,123820,123852,123859,123865,123907,123931,124025,127494,127513,127534,127554,127588,127629,128670,131528,131549,131624,131656,131714,131726,141859,141883,141902,141992,142940,142946,148119,148150,148167,149757,150885,150931,150977,151001;105182,105260,105272,105294,105296,105315,105317,105333,105342,105357,105423,105449,105465,105468,105475,105529,105539,105561,105571,105572,105574,105610,105617,105657,105804,105819,105860,105920,105922,107257,107276,123834,123899,123919,123953,123965,124010,124014,127472,127477,127523,127551,127652,127685,128652,131548,131623,131630,131637,131667,131699,141916,141943,141984,141988,142937,142954,148082,148129,148136,149729,150880,150889,150927,150993;105222,105273,105289,105307,105309,105319,105398,105426,105456,105495,105584,105600,105602,105618,105628,105636,105639,105656,105669,105700,105701,105724,105739,105826,105844,105850,105865,105872,105883,107233,107253,123802,123875,123880,123908,123946,123985,123986,127566,127567,127589,127616,127635,127636,128664,131513,131540,131554,131560,131609,131618,141852,141856,141867,141872,142943,142950,148105,148142,148147,149752,150878,150933,150950,150952;105219,105288,105327,105331,105344,105355,105405,105428,105435,105440,105482,105493,105537,105555,105557,105566,105589,105612,105638,105728,105730,105734,105796,105803,105820,105858,105885,105918,105928,107213,107224,123814,123863,123873,123926,123949,123977,123991,127491,127574,127577,127582,127615,127663,128644,131523,131524,131546,131562,131679,131702,141891,141901,141933,141989,142969,142974,148084,148097,148162,149777,150912,150935,151017,151018;105228,105308,105334,105337,105352,105359,105361,105407,105421,105457,105481,105490,105504,105523,105573,105611,105671,105676,105698,105733,105755,105777,105778,105794,105799,105806,105816,105863,105886,107203,107216,123825,123833,123929,123942,123974,124007,124038,127536,127560,127561,127632,127676,127680,128647,131559,131582,131601,131612,131692,131723,141923,141930,141955,141962,142902,142998,148081,148107,148181,149735,150893,150894,150903,150916;105195,105275,105282,105284,105298,105299,105347,105378,105400,105470,105480,105487,105497,105535,105560,105576,105581,105599,105604,105609,105646,105695,105699,105752,105769,105824,105862,105890,105903,107180,107254,123857,123894,123918,123934,123989,124013,124023,127479,127486,127490,127539,127556,127641,128699,131551,131553,131567,131585,131646,131668,141851,141863,141971,141990,142975,142999,148168,148171,148178,149718,150882,150901,150956,151020;105226,105269,105271,105329,105340,105341,105376,105381,105383,105413,105436,105471,105484,105512,105554,105564,105577,105623,105632,105660,105674,105684,105689,105772,105853,105854,105876,105887,105913,107186,107280,123806,123807,123837,123848,123979,124042,124047,127493,127548,127600,127609,127625,127661,128640,131512,131581,131607,131610,131626,131694,141906,141947,141982,141985,142918,142947,148114,148128,148148,149769,150902,150960,150973,151000;105210,105287,105290,105300,105316,105356,105460,105469,105478,105485,105506,105510,105517,105547,105562,105570,105582,105591,105593,105648,105672,105688,105779,105797,105808,105811,105870,105893,105905,107247,107297,123830,123864,123935,123952,124002,124004,124019,127498,127517,127537,127550,127639,127648,128673,131519,131520,131596,131599,131695,131703,141890,141913,141937,141950,142921,142925,148110,148115,148143,149738,150921,150939,150941,150942;105231,105262,105264,105365,105373,105377,105384,105406,105430,105437,105516,105531,105534,105563,105594,105619,105621,105667,105708,105720,105725,105732,105818,105823,105830,105855,105861,105864,105881,107173,107178,123822,123836,123936,123975,123982,124000,124008,127495,127533,127594,127620,127654,127665,128698,131572,131586,131593,131632,131677,131685,141908,141909,141919,141948,142920,142992,148111,148156,148174,149712,150924,150936,150946,150968;105183,105277,105353,105354,105409,105450,105461,105509,105513,105548,105551,105590,105595,105625,105633,105647,105675,105677,105706,105718,105722,105723,105764,105791,105835,105836,105840,105879,105927,107172,107259,123812,123823,123845,123909,123958,124009,124015,127504,127542,127580,127610,127674,127684,128702,131535,131561,131569,131634,131645,131651,141873,141887,141918,141966,142916,142964,148083,148095,148102,149764,150918,150978,151003,151006;105224,105265,105278,105336,105348,105379,105419,105427,105441,105444,105445,105474,105525,105543,105559,105598,105603,105613,105615,105641,105666,105670,105682,105719,105741,105747,105845,105859,105914,107187,107261,123849,123910,123913,123971,123993,124016,124020,127474,127515,127521,127549,127653,127679,128650,131604,131613,131666,131701,131706,131719,141920,141928,141958,141987,142917,142922,148101,148138,148165,149733,150932,150955,150963,150999;105197,105978,105979,106002,106003,106008,106028,106035,106038,106059,106060,106063,106073,106094,106104,106122,106124,106132,106140,106145,106156,106162,106173,106198,106209,106215,106229,106232,106265,107209,107260,123843,123853,123878,123905,123911,123941,124005,127510,127547,127553,127562,127579,127602,128705,131539,131558,131589,131650,131654,131686,141874,141949,141972,141986,142934,142997,148113,148159,148160,149745,150900,150958,150987,151014;105207,105955,105967,105971,105980,105985,105987,106044,106046,106049,106061,106072,106097,106116,106118,106119,106134,106148,106180,106187,106194,106208,106211,106214,106217,106227,106236,106261,106264,107240,107246,123799,123840,123856,123922,123996,124006,124037,127500,127501,127529,127583,127605,127677,128646,131511,131577,131602,131628,131649,131688,141860,141880,141882,141896,142924,142967,148085,148092,148103,149763,150915,150937,150998,151008;105225,105943,105951,105954,105959,105962,105973,105994,105995,105997,106022,106025,106037,106039,106071,106091,106092,106121,106147,106155,106178,106192,106226,106233,106237,106238,106256,106258,106272,107184,107250,123813,123841,123860,123866,123945,123950,124041,127473,127480,127543,127591,127622,127666,128643,131525,131574,131580,131588,131641,131672,141864,141889,141903,141961,142953,142959,148077,148146,148152,149744,150897,150906,150965,151013;105192,105942,105960,105964,105998,106009,106016,106017,106018,106036,106050,106058,106075,106087,106093,106095,106096,106101,106105,106123,106168,106171,106190,106199,106207,106216,106251,106260,106273,107189,107256,123805,123906,123927,123930,123938,123968,124018,127516,127535,127593,127612,127623,127686,128645,131518,131522,131555,131622,131652,131659,141922,141968,141973,141980,142931,142973,148100,148130,148137,149748,150890,150896,150938,150970;105211,105956,105958,105965,105974,105981,105996,106031,106040,106051,106065,106070,106078,106080,106081,106086,106090,106099,106125,106137,106146,106203,106205,106213,106224,106249,106250,106266,106275,107194,107225,123885,123947,123954,123964,123976,124011,124028,127502,127508,127572,127604,127667,127683,128663,131515,131521,131600,131615,131635,131648,141875,141888,141894,141898,142936,142941,148086,148117,148131,149775,150887,150964,150980,150982;105185,105947,105948,105957,105982,105984,105990,105999,106004,106005,106007,106014,106033,106047,106079,106113,106114,106129,106149,106164,106165,106166,106175,106184,106195,106230,106259,106269,106274,107182,107271,123842,123890,123917,123984,123995,123997,124049,127507,127544,127569,127651,127656,127672,128660,131594,131595,131636,131657,131670,131720,141857,141876,141979,141981,142962,142979,148079,148151,148169,149731,150917,150934,151010,151011;105178,105969,105975,105989,106000,106019,106032,106041,106052,106055,106083,106085,106102,106115,106117,106131,106135,106139,106141,106150,106154,106159,106183,106218,106219,106225,106252,106257,106268,107195,107262,123803,123861,123903,123912,123928,123933,123955,127499,127587,127634,127638,127655,127681,128701,131529,131550,131608,131643,131662,131683,141905,141931,141953,141977,142908,142961,148120,148153,148163,149756,150923,150957,150997,151016;105201,105946,105952,105970,106010,106011,106030,106042,106056,106057,106066,106067,106082,106084,106098,106133,106151,106174,106181,106189,106191,106206,106220,106231,106234,106239,106240,106243,106246,107207,107286,123816,123838,123855,123870,123879,123883,123956,127481,127526,127578,127590,127599,127642,128678,131542,131543,131565,131644,131653,131655,141917,141926,141942,141983,142901,142935,148074,148126,148179,149751,150920,150930,150954,150981;105200,105941,105944,105983,105992,106012,106020,106021,106024,106034,106074,106076,106107,106108,106142,106143,106160,106169,106179,106188,106200,106212,106221,106235,106242,106247,106248,106253,106254,107241,107273,123801,123815,123846,123886,123939,124034,124050,127519,127563,127603,127607,127611,127614,128666,131533,131573,131575,131603,131705,131721,141854,141938,141944,141952,142990,142995,148076,148108,148134,149730,150879,150899,150962,150969;105218,105949,105950,105953,105976,105977,105988,106006,106023,106027,106029,106045,106068,106089,106103,106110,106128,106163,106167,106170,106172,106182,106185,106186,106202,106204,106228,106244,106263,107192,107270,123835,123877,123914,123924,123963,124027,124031,127565,127596,127640,127645,127659,127670,128654,131526,131591,131597,131617,131680,131681,141910,141934,141945,141951,142919,142988,148112,148118,148139,149743,150888,150904,150908,151012;105206,105945,105961,105968,105972,105991,105993,106043,106053,106062,106069,106106,106111,106112,106126,106127,106130,106152,106157,106176,106193,106197,106201,106241,106245,106262,106270,106271,106276,107232,107295,123808,123818,123940,123943,123960,123962,124012,127506,127518,127557,127575,127581,127631,128684,131537,131584,131592,131616,131639,131673,141870,141893,141899,141963,142948,142972,148078,148093,148154,149754,150884,150925,150949,151007;105238,105963,105966,105986,106001,106013,106015,106026,106048,106054,106064,106077,106088,106100,106109,106120,106136,106138,106144,106153,106158,106161,106177,106196,106210,106222,106223,106255,106267,107200,107251,123821,123829,123839,123844,123892,123961,124021,127471,127476,127482,127496,127585,127628,128642,131531,131563,131587,131625,131660,131691,141885,141892,141924,141956,142912,142914,148087,148088,148166,149721,150926,150972,150975,150983;105203,106332,106337,106360,106363,106373,106389,106398,106409,106429,106467,106483,106484,106504,106506,106513,106603,106605,106608,106628,106652,106657,106678,106687,106697,106710,106712,106718,106722,107272,107277,124497,124540,124541,124572,124575,124579,124638,128370,128383,128398,128406,128442,128452,128651,132859,132864,132875,132893,132902,132910,142113,142115,142159,142161,143000,143001,147727,147734,147739,149724,151077,151079,151100,151139;105196,106320,106323,106324,106329,106345,106354,106371,106374,106379,106443,106474,106491,106509,106520,106541,106546,106558,106564,106592,106593,106629,106650,106686,106700,106714,106717,106731,106737,107236,107267,124509,124511,124513,124516,124535,124604,124625,128373,128385,128397,128409,128427,128445,128690,132853,132860,132877,132903,132913,132927,142116,142140,142150,142157,142945,143003,147724,147729,147738,149750,151129,151141,151151,151166;105215,106294,106327,106330,106347,106350,106359,106400,106402,106404,106440,106448,106485,106487,106490,106493,106500,106526,106542,106572,106621,106635,106636,106665,106675,106724,106728,106730,106736,107208,107223,124464,124467,124478,124522,124576,124642,124664,128393,128396,128423,128425,128436,128457,128648,132837,132847,132868,132872,132882,132890,135686,142104,142125,142135,142162,142939,147711,147752,147754,149771,151082,151105,151111,151132;105229,106299,106300,106301,106303,106309,106312,106340,106387,106418,106424,106425,106438,106449,106507,106508,106511,106514,106555,106568,106570,106578,106614,106645,106672,106688,106694,106701,106729,107204,107248,124510,124521,124564,124587,124591,124595,124601,128365,128386,128387,128408,128414,128451,128641,132894,132897,132916,132919,132925,132926,142117,142118,142142,142144,142909,142932,147722,147723,147731,149770,151086,151104,151122,151187;105186,106296,106310,106317,106318,106322,106342,106411,106414,106416,106431,106444,106461,106502,106503,106515,106516,106536,106543,106551,106559,106563,106581,106597,106602,106620,106624,106669,106726,107171,107284,124490,124519,124558,124570,124609,124662,124672,128368,128377,128381,128389,128417,128431,128655,132834,132838,132849,132851,132854,132886,142131,142132,142147,142149,142955,142993,147710,147728,147744,149762,151118,151124,151152,151161;105190,106297,106308,106338,106348,106381,106388,106392,106401,106426,106442,106447,106472,106489,106495,106533,106560,106594,106601,106604,106626,106627,106632,106643,106667,106674,106676,106713,106725,107176,107289,124475,124501,124514,124573,124594,124650,124670,128374,128390,128407,128421,128434,128456,128681,132857,132870,132898,132900,132920,132922,142103,142112,142130,142139,142915,142968,147709,147714,147716,149742,151084,151091,151155,151178;105204,106336,106341,106346,106378,106386,106393,106403,106410,106415,106421,106430,106434,106435,106455,106460,106480,106492,106497,106498,106523,106576,106586,106589,106668,106684,106699,106705,106723,107222,107291,124483,124525,124547,124567,124599,124617,124636,128371,128384,128418,128438,128439,128455,128667,132835,132863,132869,132879,132883,132888,142111,142123,142128,142160,142913,142929,147726,147743,147751,149739,151085,151149,151159,151171;105184,106302,106305,106361,106367,106385,106406,106428,106433,106436,106451,106462,106476,106532,106537,106567,106587,106588,106599,106631,106648,106661,106663,106670,106677,106689,106696,106703,106707,107190,107287,124480,124528,124552,124554,124584,124598,124603,128395,128399,128428,128437,128440,128460,128674,132833,132866,132867,132885,132887,132909,142114,142152,142154,142156,142949,142965,147735,147749,147750,149719,151087,151117,151123,151177;105188,106314,106315,106319,106331,106335,106357,106369,106377,106395,106408,106419,106446,106452,106478,106517,106519,106529,106549,106550,106565,106615,106618,106623,106637,106653,106664,106698,106719,107235,107239,124481,124605,124611,124621,124675,124678,124679,128367,128369,128415,128419,128447,128458,128685,132836,132850,132880,132907,132917,132923,142109,142136,142146,142164,142957,142960,147730,147733,147746,149737,151072,151125,151147,151189;105237,106339,106365,106370,106390,106391,106397,106412,106453,106463,106470,106479,106527,106530,106534,106580,106585,106600,106613,106616,106617,106647,106655,106660,106671,106685,106716,106727,106740,107229,107281,124495,124517,124589,124596,124614,124616,124658,128382,128401,128430,128443,128446,128448,128687,132840,132841,132846,132852,132861,132906,142120,142122,142145,142158,142905,142970,147718,147736,147756,149773,151071,151083,151107,151135;105205,106307,106358,106364,106380,106383,106394,106439,106456,106459,106464,106469,106494,106524,106540,106557,106575,106577,106579,106610,106622,106646,106651,106682,106709,106715,106721,106732,106733,107264,107283,124465,124486,124533,124577,124619,124628,124643,128372,128402,128412,128432,128450,128454,128682,132856,132884,132904,132905,132918,132921,142108,142124,142129,142165,142923,142996,147732,147737,147740,149753,151116,151173,151175,151186;105208,106304,106316,106321,106343,106351,106355,106356,106376,106413,106473,106505,106512,106525,106538,106556,106561,106566,106571,106591,106595,106625,106640,106642,106662,106702,106704,106706,106708,107226,107282,124466,124529,124569,124592,124612,124646,124653,128391,128403,128416,128424,128426,128429,128672,132839,132848,132865,132881,132908,132911,142105,142107,142134,142148,142951,142987,147720,147747,147748,149766,151089,151130,151133,151137;105216,106298,106353,106372,106375,106407,106420,106422,106423,106445,106465,106466,106481,106499,106501,106522,106545,106553,106583,106584,106630,106633,106638,106656,106658,106673,106680,106690,106739,107177,107275,124463,124520,124590,124593,124622,124630,124671,128376,128388,128392,128405,128441,128444,128659,132842,132855,132874,132889,132891,132914,142102,142141,142155,142163,142944,142986,147712,147715,147755,149758,151090,151102,151153,151156;105213,106293,106306,106311,106325,106328,106349,106362,106366,106399,106475,106482,106486,106531,106535,106539,106548,106574,106596,106609,106611,106644,106649,106659,106666,106692,106711,106720,106735,107196,107231,124471,124499,124503,124606,124632,124639,124661,128378,128380,128394,128404,128411,128422,128688,132832,132844,132858,132871,132895,132915,142119,142121,142126,142137,142911,142977,147713,147721,147742,149714,151073,151101,151114,151188;105189,106295,106326,106334,106368,106396,106417,106427,106450,106454,106457,106488,106510,106521,106528,106544,106547,106552,106554,106573,106606,106634,106639,106641,106654,106679,106681,106691,106695,107244,107290,124488,124494,124504,124532,124559,124578,124610,128375,128379,128400,128413,128453,128459,128675,132843,132845,132873,132876,132892,132896,142106,142138,142143,142151,142958,142971,147719,147741,147745,149723,151081,151134,151169,151179;105191,106313,106333,106344,106352,106382,106384,106405,106432,106437,106441,106458,106468,106471,106477,106496,106518,106562,106569,106582,106590,106598,106607,106612,106619,106683,106693,106734,106738,107218,107258,124473,124474,124498,124531,124557,124608,124633,128366,128410,128420,128433,128435,128449,128671,132862,132878,132899,132901,132912,132924,142110,142127,142133,142153,142942,142984,147717,147725,147753,149749,151075,151110,151138,151148;123085;124311;124314,129607,129611,129614,129616,129620,129624,129627,129631,129637,130364;124313;124315;124306,129606,129608,129609,129612,129630,129633,129638,129640,129641,130365;124309;124316,129613,129615,129621,129628,129629,129632,129635,129636,129639,130366;124308;124317,129610,129617,129618,129619,129622,129623,129625,129626,129634,130367;129281;132639;132633;130616;130618;130615;130617;140932;140936;134442;134440;134441;134453;134459;134455,143560,143561,143571,143584,143589,143602,143612,143618,143630,143633;134454,143553,143568,143576,143619,143631,143639,143652,143655,143672,143674;134439,143569,143572,143582,143585,143593,143653,143658,143663,143665,143677;134451,143564,143565,143570,143600,143601,143603,143641,143650,143661,143669;134444;134460;144327;144326;147437;147436;144325;144329;149051;149045,151226,151232,151236,151244,151247,151248,151254,151257,151258,151260;149053,151227,151229,151233,151238,151241,151245,151246,151251,151253,151261;149047,151225,151231,151237,151239,151240,151242,151249,151250,151252,151259;149049,151228,151230,151234,151235,151243,151255,151256,151262,151263,151264;149048;149042;149050;149043;124292;124287;124280;124276;124286;124277;124285;124282;124279;124275;124281;124291;132612;132610;132606;132608;132616;132611;132609;132613;132617;132615;132607;132605;140804;140799;140806;140801;140810;140802;140803;140808;140807;140809;140800;140805;143291;143302;143314;143310;143312;143285;143296;143300;143289;143308;143304;143299;152328;152309;152312;152304;152329;152325;152321;152310;152318;152305;152307;152323;130851;130849;130848;130842;130850;130844;130841;130845;130852;130843;130846;130847;132628;132630;132629;132636;132627;132640;132637;132632;132631;132641;132635;132642;140935;140940;140938;140933;140934;140930;140929;140931;140937;140928;140927;140939;143286;143297;143293;143303;143311;143288;143294;143305;143306;143292;143309;143290;152316;152302;152303;152308;152311;152326;152301;152322;152300;152319;152324;152313;119491;119492;121517;119496;119489;121515;121509;119494;119498;126190;126188;126189;126185;126187;126186;124307;124318;124312;124310;125104;125103;134486;134487;150642;109725;109731;109723;109729;109730;109726;109727;109728;109722;109724;134448;121516;139098;139097;116505;116514;116535;116579;116503;116534;116532;116508;116516;116522;116518;116524;116533;116520;116515;116511;116517;116521;116502;113244;107450;107431;107600;107501;107524;107482;107580;107532;107489;107492;107500;107479;107555;107494;107610;107465;107574;107477;107469;107590;107516;107468;107449;107597;107571;107553;107437;107564;107606;107430;107588;107562;107499;107528;107487;107493;107545;107550;107456;107506;107522;107508;107589;107478;107552;107453;107525;107556;107554;107586;107526;107495;107441;107587;107541;107448;107498;107579;107608;107544;107584;107598;107472;107510;107533;107521;107504;107596;107601;107470;107513;107497;107568;107432;107566;107463;107536;107446;107433;107459;107520;107509;107455;107567;107428;107429;107560;107444;107457;107527;107534;107483;107460;107569;107519;107518;107435;107481;107585;107514;107471;107563;107515;107591;107547;107523;107548;107578;107543;107507;107438;107582;107603;107505;107445;107473;107474;107594;107565;107558;107529;107442;107546;107502;107595;107447;107467;107540;107485;107517;107530;107464;107581;107592;107607;107609;107451;107434;107454;107496;107551;107440;107462;107537;107476;107593;107583;107575;107503;107549;107488;107573;107557;107486;107561;107443;107436;107466;107599;107542;107490;107439;107452;107511;107512;107461;107605;107570;107484;107475;107538;107480;107559;107602;107576;107604;107535;107458;107539;107572;107577;107531;107491;116581;116578;116577;116583;116576;116575;116580;116582;116574;120864;122976;126734;126735;126733;126736;130758;128253;128255;128251;128256;128576;136244;136245;132614;133723;130613;130614;128249;128254;132194;132193;128258;128248;136162;129280;129277;129284;129285;129282;129278;141767;141769;141768;141766;136381;136379;141770;142362;134435;134449;128250;128259;134450;134458;128252;128257;135676;134445;134437;134443;134457;134452;134447;135675;143298;143307;143295;143287;143301;143313;135678;143214;143211;143218;143216;143222;143210;144361;144356;144355;144363;150693;144359;144362;135677;144358;144364;144360;144354;144353;144357;121521;121507;121503;121522;121525;121524;121519;121518;121502;121513;121506;121511;124273;124274;124284;124272;124288;124289;124283;130510;130509;130512;130508;130511;130507;134436;134438;134446;134461;134456;134462;143217;143219;143212;143221;143213;143223;152317;152327;152320;152306;152315;152314;124758;124740;124739;124745;124757;124756;124767;124750;124761;124749;124751;124764;124755;124763;124748;124769;124753;124766;124759;124747;124743;124744;124754;124760;124765;124742;124752;124741;124746;124768;124762;116504;116528;116513;116531;116527;116523;116506;116512;116510;116501;116526;116500;116509;116529;116525;121659;121669;121662;121661;121668;121665;121658;121664;121667;121663;121657;121666;121660;105198,106796,106800,106807,106815,106828,106841,106860,106866,106887,106892,106915,106916,106944,106951,106953,106959,106974,106978,106997,107020,107040,107066,107068,107071,107075,107084,107110,107116,107181,107202,124472,124500,124505,124563,124645,124651,124665,128266,128272,128287,128321,128331,128337,128686,132699,132715,132736,132749,132770,132775,142034,142039,142066,142078,143069,143072,147875,147889,147894,149746,151069,151092,151165,151174;105236,106787,106811,106816,106835,106864,106872,106890,106894,106895,106941,106960,106963,106969,106983,106993,106998,106999,107013,107019,107027,107035,107036,107085,107088,107091,107114,107117,107122,107197,107201,124484,124530,124566,124582,124602,124647,124669,128268,128281,128299,128324,128343,128348,128677,132708,132721,132723,132759,132761,132767,142060,142080,142083,142084,143057,143065,147859,147862,147903,149715,151093,151095,151163,151168;105194,106814,106844,106845,106848,106850,106883,106886,106902,106904,106908,106911,106918,106932,106934,106943,106961,106975,106981,106992,107007,107014,107041,107055,107059,107076,107092,107093,107106,107193,107252,124536,124549,124555,124586,124626,124656,124674,128265,128280,128296,128304,128330,128347,128658,132697,132702,132729,132735,132747,132758,142049,142057,142068,142091,143055,143076,147873,147883,147890,149711,151067,151096,151150,151172;105223,106805,106806,106812,106822,106829,106839,106846,106871,106873,106879,106907,106924,106929,106930,106935,106950,106977,107001,107003,107025,107030,107047,107048,107074,107095,107104,107105,107120,107183,107212,124476,124491,124568,124585,124613,124640,124644,128279,128295,128305,128310,128318,128344,128665,132704,132711,132756,132771,132774,132777,142051,142052,142055,142056,143056,143071,147882,147887,147892,149741,151068,151106,151136,151143;105193,106799,106804,106819,106821,106826,106832,106838,106853,106862,106863,106874,106900,106909,106914,106919,106920,106925,106976,106988,107002,107009,107028,107031,107056,107062,107072,107079,107082,107234,107268,124485,124502,124539,124550,124565,124615,124629,128271,128300,128308,128316,128336,128353,128700,132700,132706,132731,132738,132772,132781,142050,142059,142061,142089,143051,143054,147870,147880,147901,149716,151127,151144,151164,151176;105199,106790,106820,106833,106836,106842,106843,106858,106865,106884,106889,106917,106956,106970,106971,106984,106987,106990,107005,107008,107015,107017,107051,107070,107078,107100,107109,107111,107119,107245,107266,124479,124523,124526,124527,124534,124537,124545,128269,128282,128283,128293,128322,128333,128669,132717,132718,132744,132745,132782,132783,142040,142062,142075,142079,143058,143067,147869,147878,147885,149732,151103,151108,151160,151170;105212,106794,106802,106803,106817,106878,106888,106913,106921,106926,106947,106948,106949,106954,106962,106967,106972,106996,107006,107016,107026,107034,107039,107043,107061,107065,107089,107102,107121,107210,107298,124507,124542,124588,124655,124666,124668,124673,128267,128275,128294,128313,128339,128352,128692,132712,132726,132733,132739,132784,132785,142073,142074,142088,142092,143074,143075,147863,147884,147898,149736,151076,151142,151180,151184;105232,106795,106808,106809,106813,106825,106847,106868,106875,106876,106898,106899,106903,106923,106933,106939,106940,106958,106980,106991,107018,107021,107022,107038,107080,107098,107101,107112,107113,107205,107221,124468,124508,124543,124562,124580,124631,124667,128286,128288,128290,128303,128329,128335,128668,132696,132709,132724,132755,132776,132778,142043,142046,142076,142085,143059,143060,147879,147886,147895,149727,151128,151131,151146,151154;105217,106788,106823,106824,106837,106854,106856,106867,106897,106905,106906,106922,106931,106955,106965,106973,106985,106989,107004,107010,107024,107046,107049,107050,107058,107060,107064,107073,107087,107278,107285,124477,124489,124524,124544,124607,124652,124677,128306,128311,128323,128326,128327,128340,128676,132698,132701,132719,132740,132742,132764,142048,142069,142070,142086,143048,143064,147860,147868,147876,149755,151099,151112,151115,151183;105227,106789,106810,106818,106831,106840,106851,106859,106870,106877,106893,106910,106937,106945,106946,106952,106957,106966,106994,107029,107042,107044,107052,107053,107054,107057,107083,107097,107108,107174,107188,124506,124548,124560,124571,124623,124637,124676,128309,128315,128319,128332,128334,128346,128656,132713,132730,132732,132752,132763,132768,142037,142042,142054,142081,143052,143053,147872,147896,147900,149713,151097,151098,151113,151181;105230,106792,106827,106830,106849,106852,106855,106857,106880,106882,106891,106912,106928,106942,106964,106968,106979,106995,107000,107012,107023,107032,107033,107037,107045,107067,107096,107103,107115,107191,107238,124515,124556,124561,124574,124624,124635,124660,128274,128277,128284,128285,128289,128341,128689,132705,132714,132727,132748,132757,132773,142035,142058,142063,142067,143049,143066,147871,147877,147891,149772,151074,151088,151109,151126;105233,106791,106793,106797,106798,106801,106834,106861,106869,106881,106885,106896,106901,106927,106936,106938,106982,106986,107011,107063,107069,107077,107081,107086,107090,107094,107099,107107,107118,107237,107292,124512,124518,124551,124553,124597,124600,124649,128264,128273,128278,128317,128325,128342,128691,132707,132710,132716,132762,132766,132779,142041,142045,142082,142087,143068,143070,147861,147865,147866,149774,151094,151119,151120,151157;113261,113233,113234,113235,113236,113238,113239,113242,113252,113254,113258,113262,113264,113268,113269,113270,113272,113276,113283,113286,113292,113296,113299,113301,113308,113312,113316,113320,113322,113324,113326,124469,124470,124492,124583,124641,124654,124663,128270,128298,128301,128302,128307,128351,128703,132741,132746,132750,132751,132765,132780,142038,142047,142053,142090,143061,143063,147867,147893,147897,149740,151078,151080,151182,151185;113259,113240,113243,113246,113248,113249,113251,113257,113260,113267,113275,113278,113279,113280,113285,113288,113289,113291,113294,113297,113298,113302,113304,113305,113306,113307,113311,113317,113318,113323,113325,124482,124538,124546,124618,124627,124634,124659,128292,128297,128312,128320,128328,128338,128693,132703,132722,132725,132734,132743,132754,142036,142071,142072,142077,143062,143073,147874,147888,147899,149747,151070,151145,151158,151167;113273,113237,113241,113245,113247,113250,113253,113255,113256,113263,113265,113266,113271,113274,113277,113281,113282,113284,113287,113290,113293,113295,113300,113303,113309,113310,113313,113314,113315,113319,113321,124487,124493,124496,124581,124620,124648,124657,128276,128291,128314,128345,128349,128350,128683,132720,132728,132737,132753,132760,132769,142044,142064,142065,142093,143050,143077,147864,147881,147902,149726,151066,151121,151140,151162"
local CUT_LIST = "7ec25b6a55f4fc10"
local CUT_PREVIEW = 5
local cutSections
local cutLookup
local cutBundles = {}
local cutByWeapon = {}
local cutRecent = {}
local cutHooked = {}
cutSections = {}
for name, list in CUT_CAMOS:gmatch("([^:|]+):([^|]*)") do
  local section = { name = name, groups = {}, bundle = {} }
  for g in list:gmatch("[^;]+") do
    local ids = {}
    for id in g:gmatch("%d+") do ids[#ids + 1] = tonumber(id) end
    section.groups[#section.groups + 1] = ids
  end
  cutSections[#cutSections + 1] = section
end
local cutIndexes = {}
local function camoCutContent()
  pcall(function()
    local WC, WCC, E = rawget(_G, "WEAPON_CAMO"), rawget(_G, "WEAPON_CAMO_CATEGORY"), rawget(_G, "Engine")
    if type(WC) ~= "table" or type(WCC) ~= "table" or type(E) ~= "table" then return end
    local kIter, kChal, kLoot, kByLoot = H("bf898c4e41d3372b"), H("b31cc9599692e6fd"), H("8028887f70bf5eba"), H("9d1e6b704f84cf8b")
    local kBundle, kCamoData = H("f06093d047200548"), H("3b25e2943a880b09")
    local kTiles, kTileList, kCatCamos, kCats = H("5edef36c87c43df4"), H("2931b7f8ff93f2af"), H("a5b4e3922e70bfe6"), H("2a8c635988bcbb7f")
    local kIndex = H("9a9d38f26b83d305")
    local oChal, oTiles, oCatCamos = WC[kChal], WCC[kTiles], WCC[kCatCamos]
    if type(oChal) ~= "function" or type(oTiles) ~= "function" or type(oCatCamos) ~= "function"
      or type(WC[kIter]) ~= "function" or type(WCC[kCats]) ~= "function" then return end
    if oChal == cutHooked.chal and oTiles == cutHooked.tiles and oCatCamos == cutHooked.cat then return end
    if cutHooked.cat then L("camo category functions were replaced; cut content added again") end
    local function cutCamos(c, weapon)
      local key = tostring(weapon)
      if cutByWeapon[key] then
        for i, recent in ipairs(cutRecent) do
          if recent == key then table.remove(cutRecent, i); break end
        end
        cutRecent[#cutRecent + 1] = key
        return cutByWeapon[key]
      end
      local listed, cut, missing, total = {}, {}, 0, 0
      local function mark(camo) if type(camo) == "table" and camo[kLoot] then listed[tonumber(camo[kLoot])] = true end end
      WC[kIter](c, mark, weapon)
      for _, b in ipairs(WCC[kCats](c) or {}) do
        local ok, camos = pcall(oCatCamos, c, b, weapon)
        if ok and type(camos) == "table" then for _, camo in ipairs(camos) do mark(camo) end end
      end
      if cutLookup == nil then
        cutLookup = false
        local ok, r = pcall(function()
          local list = E[kBundle](H(CUT_LIST, 3))
          if type(list) ~= "table" then return "camo list is " .. type(list) end
          local camos = list[H("f0afac2d7743a20e")]
          if type(camos) ~= "table" then return "camo list's camos are " .. type(camos) end
          local index = camos[H("0bbd1f110b4fb37d")]
          if type(index) ~= "function" then return "camo list index is " .. type(index) end
          local t = index(camos, H("fbe1b0ea1816d9da"))
          return type(t) == "table" and t or ("index gave " .. type(t))
        end)
        if ok and type(r) == "table" then cutLookup = r else L("cut content: list of every camo not found: " .. tostring(r)) end
      end
      local byLoot = rawget(_G, "WEAPON") and WEAPON[kByLoot]
      if cutLookup then
        local lookup = cutLookup
        byLoot = function(id) local e = lookup[id]; return e and E[kBundle](e[kCamoData]) end
      end
      for i, section in ipairs(cutSections) do
        local list = {}
        for _, g in ipairs(section.groups) do
          local has = false
          for _, id in ipairs(g) do if listed[id] then has = true; break end end
          if not has then
            local b = cutBundles[g[1]]
            if b == nil then
              local ok, r = false, nil
              if type(byLoot) == "function" then ok, r = pcall(byLoot, g[1]) end
              b = ok and type(r) == "table" and r or false
              cutBundles[g[1]] = b
            end
            if b then list[#list + 1] = b else missing = missing + 1 end
          end
        end
        cut[i] = list
        total = total + #list
      end
      if missing > 0 then probe("cut content camos without a bundle", key, missing) end
      probe("cut content camos", key, total)
      if #cutRecent == 4 then
        cutByWeapon[table.remove(cutRecent, 1)] = nil
      end
      cutByWeapon[key] = cut
      cutRecent[#cutRecent + 1] = key
      return cut
    end
    if oCatCamos ~= cutHooked.cat then
      WCC[kCatCamos] = function(c, bundle, weapon, ...)
        local n
        for i, section in ipairs(cutSections) do if bundle == section.bundle then n = i end end
        if not n then return oCatCamos(c, bundle, weapon, ...) end
        local ok, cut = pcall(cutCamos, c, weapon)
        if not ok then L("cut content error: " .. tostring(cut)); return {} end
        local copy = {}
        for i, camo in ipairs(cut[n]) do copy[i] = camo end
        return copy
      end
      cutHooked.cat = WCC[kCatCamos]
    end
    if oTiles ~= cutHooked.tiles then
      WCC[kTiles] = function(c, mode, ...)
        oTiles(c, mode, ...)
        cutIndexes = {}
        local ok, err = pcall(function()
          local LD, LT = rawget(_G, "LOADOUT"), rawget(_G, "LOOT")
          local tiles = WCC[kTileList]
          if type(tiles) ~= "table" then L("cut content: no category tile list"); return end
          local weapon = LD[H("5332ce251602c7a1")](c, LD[H("77d09d94b38f7ab0")](c))
          local cut = cutCamos(c, weapon)
          local commands = WCC[H("3cc8bf892e4522d3")]
          local owns, itemRef = LT[H("33568d3533d63f69")], LT[H("3d5d69ba555e016d")]
          local n = 0
          for _, t in ipairs(tiles) do if t.bundle ~= nil then n = n + 1 end end
          local made = {}
          for i, section in ipairs(cutSections) do
            local list = cut[i]
            if #list > 0 then
              local tile = { name = section.name, bundle = section.bundle, isPremium = false, isLocked = false,
                command = commands and commands[H("fad04c07dcf2e30b")], camoData = { count = 0 } }
              local owned = 0
              for _, camo in ipairs(list) do
                local id = camo[kLoot]
                if owns(c, id) then owned = owned + 1 end
                if tile.camoData.count < CUT_PREVIEW then
                  tile.camoData[tile.camoData.count + 1] = { ref = itemRef(id), itemBundle = camo, lootID = id }
                  tile.camoData.count = tile.camoData.count + 1
                end
              end
              tile.totalCount, tile.unlockedCount = #list, owned
              tile.countDescription = E[H("aed84c33ec5f01ea")](H("4589b9d3130dd7a5", 3), owned, #list)
              tiles[#tiles + 1] = tile
              n = n + 1
              cutIndexes[n] = section.bundle
              made[#made + 1] = section.name .. " " .. #list
            end
          end
          L("camo categories: cut content tiles " .. (#made > 0 and table.concat(made, ", ") or ("none for " .. tostring(weapon))))
        end)
        if not ok then L("cut content tile error: " .. tostring(err)) end
      end
      cutHooked.tiles = WCC[kTiles]
    end
    local oIndex = WCC[kIndex]
    if type(oIndex) == "function" and oIndex ~= cutHooked.index then
      WCC[kIndex] = function(c, i, ...)
        if cutIndexes[i] then return cutIndexes[i] end
        return oIndex(c, i, ...)
      end
      cutHooked.index = WCC[kIndex]
    end
    if oChal ~= cutHooked.chal then
      WC[kChal] = function(c, camo, weapon, opts, ...) return oChal(c, camo, weapon, opts or {}, ...) end
      cutHooked.chal = WC[kChal]
    end
    L("camo categories: CUT CONTENT added")
  end)
end

local freeAttachments
do
  local wrapped
  local maxCapValue = 17
  local function maxCap() return maxCapValue end
  local function ownSlot() return false end
  local function noConflict() return false end
  freeAttachments = function()
    pcall(function()
      local G = rawget(_G, "GUNSMITH"); local kb = H("1ea00bd3e3b2ce6e")
      if type(G) == "table" and type(G[kb]) == "function" and G[kb] ~= ownSlot then G[kb] = ownSlot end
      local W = rawget(_G, "WEAPON")
      local cap = W and tonumber(W.maxAttachmentsPerWeapon) or 17
      for _, hx in ipairs({ "43d7cd21cbd52dba", "e12cffa30ec66e46", "d231320254e937d6" }) do
        local kk = H(hx)
        if type(G) == "table" and type(G[kk]) == "function" and G[kk] ~= maxCap then G[kk] = maxCap end
      end
      maxCapValue = cap
      local GS = rawget(_G, "Gunsmith"); local kx = H("055fa853e79cfa5d")
      if type(GS) == "table" and type(GS[kx]) == "function" and GS[kx] ~= noConflict then GS[kx] = noConflict end
    end)
    pcall(function()
      local A = rawget(_G, "ATTACHMENT"); if type(A) ~= "table" then return end
      local k = H("920d5d11bba23309"); local o = A[k]
      if type(o) ~= "function" or o == wrapped then return end
      local function clear(e)
        if type(e) ~= "table" or e.isBlocked == nil and e.isIncompatible == nil then return end
        e.isBlocked = false; e.isIncompatible = false; e.incompatibleReason = nil
        e.blockedBy = nil; e.blockedByRef = nil; e.blockedByCategory = nil; e.blockedByCategoryRef = nil
      end
      wrapped = function(...)
        local r = { o(...) }
        for _, a in ipairs({ ... }) do
          if type(a) == "table" then
            clear(a)
            for _, e in pairs(a) do clear(e) end
          end
        end
        return unpack(r)
      end
      A[k] = wrapped
      local kc = H("d2f6b1c6576f25f6")
      if type(A[kc]) == "function" then A[kc] = function() return {} end end
      L("gunsmith: attachment restrictions removed")
    end)
  end
end

local enableWonderClass
do
local wonderBundleWrapped
enableWonderClass = function()
  pcall(function()
    local E = rawget(_G, "Engine")
    local k = H("f06093d047200548")
    local o = type(E) == "table" and E[k]
    local OPR = rawget(_G, "OPERATOR")
    local ko = H("b134e3c4caf5caf8")
    if type(OPR) == "table" and type(OPR[ko]) == "function" and OPR[ko] ~= _G.__kronosOpSkinSafe then
      local orig = OPR[ko]
      _G.__kronosOpSkinSafe = function(...)
        local ok, r = pcall(orig, ...)
        if ok then return r end
        if not rawget(_G, "__kronosOpSkinErr") then
          rawset(_G, "__kronosOpSkinErr", true)
          L("operator skin lookup failed before stats loaded, treated as none: " .. tostring(r))
        end
        return nil
      end
      OPR[ko] = _G.__kronosOpSkinSafe
    end
    if getDvar("970a7a4f1d271a37") == "1" then
      local W = rawget(_G, "WEAPON")
      local gwd = H("8c7e51e321588bbf")
      if type(W) == "table" and type(W[gwd]) == "function" and W[gwd] ~= _G.__kronosBo6Gwd then
        local orig = W[gwd]
        _G.__kronosBo6Gwd = function(ref, ...)
          local r = orig(ref, ...)
          if r == nil and type(ref) ~= "string" and (_G.__kronosGwdHashLog or 0) < 8 then
            _G.__kronosGwdHashLog = (_G.__kronosGwdHashLog or 0) + 1
            L("create a class: GetWeaponData nil for " .. type(ref) .. " " .. tostring(ref))
          end
          if r ~= nil or type(ref) ~= "string" or not ref:match("^t10_%a%a_p%d+_%w+$") then return r end
          local ok, wb = pcall(E[H("f06093d047200548")], H("31705bf9ed477170", 3) .. ref)
          if not ok or type(wb) ~= "table" then return r end
          local LOOT, id, kImg = rawget(_G, "LOOT"), wb[H("8028887f70bf5eba")], H("2ab612888528489a")
          return setmetatable({}, { __index = function(_, key)
            if key == kImg and LOOT and id then
              local okI, img = pcall(LOOT[H("ffa7ac7cb1a8d0c6")], id)
              if okI and img then return img end
            end
            return wb[key]
          end })
        end
        W[gwd] = _G.__kronosBo6Gwd
      end
      local WB = rawget(_G, "WeaponBuildUtils")
      local bl = H("e83d4a622712e69b")
      if type(WB) == "table" and type(WB[bl]) == "function" and WB[bl] ~= _G.__kronosBo6Builds then
        local orig = WB[bl]
        _G.__kronosBo6Builds = function(...)
          local r = { pcall(orig, ...) }
          if r[1] then return unpack(r, 2, table.maxn(r)) end
          if not _G.__kronosBuildErr then
            _G.__kronosBuildErr = true
            L("create a class: build list error " .. tostring(r[2]))
          end
          return (select(2, ...)) or {}
        end
        WB[bl] = _G.__kronosBo6Builds
        L("create a class: build list wrapped")
      end
      local GS = rawget(_G, "GUNSMITH")
      local ga = H("8e3803581e0b70da")
      if type(GS) == "table" and type(GS[ga]) == "function" and GS[ga] ~= _G.__kronosBo6Attach then
        local orig = GS[ga]
        _G.__kronosBo6Attach = function(...)
          local r = orig(...)
          if r == nil then
            if not _G.__kronosAttachNil then
              _G.__kronosAttachNil = true
              L("create a class: gunsmith attachments nil, using an empty table")
            end
            return {}
          end
          return r
        end
        GS[ga] = _G.__kronosBo6Attach
      end
      local gc = H("24e55d1a4c4ed4d5")
      if type(GS) == "table" and type(GS[gc]) == "function" and GS[gc] ~= _G.__kronosBo6ItemCheck then
        local orig = GS[gc]
        _G.__kronosBo6ItemCheck = function(...)
          local ok, r = pcall(orig, ...)
          if ok then return r end
          if not _G.__kronosItemCheckErr then
            _G.__kronosItemCheckErr = true
            L("create a class: gunsmith item check failed, treated as not applicable: " .. tostring(r))
          end
          return false
        end
        GS[gc] = _G.__kronosBo6ItemCheck
      end
      local gm = H("8994cc5b8b8f847c")
      if type(GS) == "table" and type(GS[gm]) == "function" and GS[gm] ~= _G.__kronosBo6MenuCheck then
        local orig = GS[gm]
        _G.__kronosBo6MenuCheck = function(...)
          local ok, r = pcall(orig, ...)
          if ok then return r end
          if not _G.__kronosMenuCheckErr then
            _G.__kronosMenuCheckErr = true
            L("create a class: gunsmith menu check failed, treated as none: " .. tostring(r))
          end
          return nil
        end
        GS[gm] = _G.__kronosBo6MenuCheck
      end
      local LT = rawget(_G, "LOOT")
      if type(LT) == "table" and type(LT.itemTypes) == "table" and type(LT.typeNames) == "table" then
        local weaponType = LT.typeNames[LT.itemTypes.WEAPON]
        _G.__kronosBo6Loot = _G.__kronosBo6Loot or {}
        local function bo6Id(ref)
          if type(ref) ~= "string" or ref:sub(1, 4) ~= "t10_" then return nil end
          local okB, wb = pcall(E[H("f06093d047200548")], H("31705bf9ed477170", 3) .. ref)
          local id = okB and type(wb) == "table" and wb[H("8028887f70bf5eba")] or nil
          if id ~= nil then _G.__kronosBo6Loot[tostring(id)] = ref end
          return id
        end
        local kId, kType, kItem = H("c36548909cff94cd"), H("f9ce6de13c94e065"), H("40e51b2533705bbe")
        if type(LT[kId]) == "function" and LT[kId] ~= _G.__kronosBo6LootId then
          local orig = LT[kId]
          _G.__kronosBo6LootId = function(ref, ...)
            return bo6Id(ref) or orig(ref, ...)
          end
          LT[kId] = _G.__kronosBo6LootId
        end
        if type(LT[kType]) == "function" and LT[kType] ~= _G.__kronosBo6LootType then
          local orig = LT[kType]
          _G.__kronosBo6LootType = function(id, ...)
            if _G.__kronosBo6Loot[tostring(id)] then return weaponType end
            return orig(id, ...)
          end
          LT[kType] = _G.__kronosBo6LootType
        end
        if type(LT[kItem]) == "function" and LT[kItem] ~= _G.__kronosBo6LootItem then
          local orig = LT[kItem]
          _G.__kronosBo6LootItem = function(id, ...)
            local r = orig(id, ...)
            local ref = _G.__kronosBo6Loot[tostring(id)]
            if ref and (type(r) ~= "table" or r.itemRef ~= ref) then
              return setmetatable({ category = weaponType, itemRef = ref }, { __index = type(r) == "table" and r or nil })
            end
            return r
          end
          LT[kItem] = _G.__kronosBo6LootItem
          L("create a class: BO6 loot ids saved and loaded")
        end
      end
      local PG = rawget(_G, "PROGRESSION")
      local kLv, kMax = H("1ecc84a5fc79659f"), H("2a9e585873521d77")
      if not rawget(_G, "__kronosBo6LevelOnce") and type(PG) == "table" and type(PG[kLv]) == "function"
        and type(PG[kMax]) == "function" then
        local orig, maxOf = PG[kLv], PG[kMax]
        rawset(_G, "__kronosBo6Level", function(c, ref, ...)
          local s = tostring(ref)
          if s:sub(1, 4) == "t10_" or rawget(_G, "__kronosBo6Loot") and _G.__kronosBo6Loot[s] then
            local ok, m = pcall(maxOf, ref)
            if ok and tonumber(m) then return m end
          end
          return orig(c, ref, ...)
        end)
        PG[kLv] = rawget(_G, "__kronosBo6Level")
        rawset(_G, "__kronosBo6LevelOnce", true)
        L("bo6 weapon level: shown as max")
      end
      local ke = H("78478447ff871e3f")
      if type(W) == "table" and type(W[ke]) == "function" and W[ke] ~= _G.__kronosBo6Equip then
        local orig = W[ke]
        _G.__kronosBo6Equip = function(lw, build, ...)
          pcall(function()
            local ref = tostring(build.weapon or "")
            local v = tonumber(build.variantID)
            if ref:sub(1, 4) == "t10_" and v and v >= 0 and v % 1 == 0 then _G.__kronosBo6Pending[ref] = string.format("%d", v) end
            if ref:sub(1, 4) == "t10_" then
              local names, variants = {}, {}
              if (build.isCustom == true or build.isBlueprintIntact == false) and type(build.attachments) == "table" then
                local seenE = {}
                for _, a in pairs(build.attachments) do
                  local n = type(a) == "string" and a or type(a) == "table" and a.ref or nil
                  if type(n) == "string" and n ~= "" and n ~= "none" and not seenE[n] then
                    seenE[n] = true
                    names[#names + 1] = n
                    variants[#variants + 1] = string.format("%d", tonumber(type(a) == "table" and a.variantID) or 0)
                  end
                end
              end
              if #names > 0 then pcall(_G.__kronosBo6Irons, ref, names, variants) end
              _G.__kronosBo6Pending[ref .. "@a"] = table.concat(names, ",")
              _G.__kronosBo6Pending[ref .. "@v"] = table.concat(variants, ",")
              if type(_G.__kronosBo6AttSlots) == "table" then _G.__kronosBo6AttSlots[ref] = nil end
              L("bo6 equip: " .. ref .. " blueprint " .. tostring(build.variantID) .. " custom " .. tostring(build.isCustom) .. " intact " .. tostring(build.isBlueprintIntact) .. " attachments " .. #names)
            end
            if ref:match("^%a+%d*_me_") then
              _G.__kronosBo6Pending.melee = ref:sub(1, 4) == "t10_" and ref or ""
            end
            if ref:sub(1, 4) == "t10_" then
              local c = type(build.camo) == "string" and build.camo or ""
              _G.__kronosBo6Pending[ref .. "@c"] = (c ~= "none" and c ~= "camo_none") and c or ""
            end
            pcall(_G.__kronosBo6FlushVariants)
          end)
          rawset(_G, "__kronosBo6InEquip", true)
          local function pack(...) return { n = select("#", ...), ... } end
          local r = pack(pcall(orig, lw, build, ...))
          rawset(_G, "__kronosBo6InEquip", false)
          if not r[1] then error(r[2], 0) end
          return unpack(r, 2, r.n)
        end
        W[ke] = _G.__kronosBo6Equip
      end
      local gn = H("9ae1e225e2dd2df4")
      if type(W) == "table" and type(W[gn]) == "function" and W[gn] ~= _G.__kronosBo6Name then
        local orig = W[gn]
        _G.__kronosBo6Name = function(ref, ...)
          local ok, name = pcall(orig, ref, ...)
          local gl = _G.__kronosGnSeen or {}
          _G.__kronosGnSeen = gl
          if not gl[tostring(ref)] then
            gl[tostring(ref)] = true
            L("create a class: GetName(" .. tostring(ref) .. ") -> " .. tostring(ok) .. " " .. tostring(name))
          end
          if ok and name ~= "" and name ~= nil and not (type(ref) == "string" and ref:sub(1, 4) == "t10_") then return name end
          if type(ref) == "string" and ref:sub(1, 4) == "t10_" then
            local okB, wb = pcall(E[H("f06093d047200548")], H("31705bf9ed477170", 3) .. ref)
            local key = okB and type(wb) == "table" and wb[H("c4bcadba8e631b86")]
            local okL, txt = pcall(Engine[H("aed84c33ec5f01ea")], key)
            if okL and type(txt) == "string" and txt ~= "" then return txt end
          end
          if not ok then
            local seen = _G.__kronosNameErr or {}
            _G.__kronosNameErr = seen
            if not seen[tostring(ref)] then
              seen[tostring(ref)] = true
              L("create a class: weapon name failed for " .. tostring(ref) .. ": " .. tostring(name))
            end
          end
          return ok and name or ""
        end
        W[gn] = _G.__kronosBo6Name
        L("create a class: GetName wrapped")
      end
      local LOOT = rawget(_G, "LOOT")
      _G.__kronosBo6Loot = _G.__kronosBo6Loot or {}
      local function bo6Bundle(id)
        local ref = _G.__kronosBo6Loot[tostring(id)]
        if not ref then return nil end
        local okB, wb = pcall(E[H("f06093d047200548")], H("31705bf9ed477170", 3) .. ref)
        return okB and type(wb) == "table" and wb or nil
      end
      local function rowBundle(m, c)
        if type(m) ~= "table" then return nil end
        local okV, id = pcall(function() return m:GetValue(c) end)
        local byId = okV and id ~= nil and bo6Bundle(id)
        if byId then return byId end
        local parent
        for kk, vv in pairs(m) do if vv == "_parent" then parent = kk end end
        local ok, ref = pcall(function() return parent[H("86d696ad252f1cb1")]:GetValue(c) end)
        if false then
          _G.__kronosRowLog = (_G.__kronosRowLog or 0) + 1
          L("create a class: row ref " .. tostring(parent ~= nil) .. " " .. tostring(ok) .. " " .. tostring(ref))
        end
        if not ok or type(ref) ~= "string" or ref:sub(1, 4) ~= "t10_" then return nil end
        local okB, wb = pcall(E[H("f06093d047200548")], H("31705bf9ed477170", 3) .. ref)
        return okB and type(wb) == "table" and wb or nil
      end
      local sr = H("f3f53f4d84af5cfc")
      local dv, dvGet, dvSet = H("9501b5803b01ae76", 1), H("254084d7ca2317bb"), H("1e3cb005036e0c0f")
      _G.__kronosBo6Pending = _G.__kronosBo6Pending or {}
      _G.__kronosBo6Irons = function(ref, names, variants)
        if ref:match("^t10_me_") then return end
        for _, n in ipairs(names) do
          for _, k in ipairs({ "irons", "reddot", "reflex", "holo", "scope", "optic", "acog", "thermal", "lpvo", "magnif",
            "sight", "varizoom", "zoom", "hybrid" }) do
            if n:find(k, 1, true) then return end
          end
          if n:find("%ax0%d") then return end
        end
        local gun = ref:match("^t10_%a+_p%d+_(.+)$")
        if gun then
          names[#names + 1] = "t10_ironsdefault_" .. gun
          variants[#variants + 1] = "0"
        end
      end
      _G.__kronosBo6FlushVariants = function()
        local pending = _G.__kronosBo6Pending
        if next(pending) == nil then return end
        local xd = rawget(_G, "xhashdvar")
        local named = type(xd) == "function" and xd("kronos_bo6_var") or dv
        local cur = tostring(Dvar[dvGet](named) or "")
        _G.__kronosBo6Pending = {}
        local order, vals = {}, {}
        for entry in cur:gmatch("[^;]+") do
          local k, v = entry:match("^(.-)=(.*)$")
          if k and vals[k] == nil then order[#order + 1] = k; vals[k] = v end
        end
        if vals.cap == nil and cur == "" then
          local cap = 900
          for _, n in ipairs({ 4000, 2000, 1200 }) do
            local probe = string.rep("x", n)
            pcall(Dvar[dvSet], named, probe)
            if tostring(Dvar[dvGet](named) or "") == probe then cap = n - 100 break end
          end
          pcall(Dvar[dvSet], named, "")
          vals.cap = tostring(cap)
          order[#order + 1] = "cap"
          L("bo6 handoff: dvar holds up to " .. cap .. " chars")
        end
        local function remove(k) for i = #order, 1, -1 do if order[i] == k then table.remove(order, i) end end end
        for k, v in pairs(pending) do
          remove(k)
          local sub = k:match("@[avc]$")
          if v == "" and sub then
            vals[k] = nil
          elseif k:sub(-2) == "@v" and v:match("^[0,]*$") then
            vals[k] = nil
          else
            vals[k] = v ~= "" and v or "-"
            order[#order + 1] = k
          end
        end
        for k in pairs(pending) do
          local base = k:gsub("@[avc]$", "")
          for _, kk in ipairs({ base, base .. "@a", base .. "@v", base .. "@c" }) do
            if vals[kk] ~= nil then remove(kk); order[#order + 1] = kk end
          end
        end
        local function joined()
          local t = {}
          for _, k in ipairs(order) do t[#t + 1] = k .. "=" .. vals[k] .. ";" end
          return table.concat(t)
        end
        local cap = math.min(1000, math.max(900, tonumber(vals.cap) or 900))
        local out = joined()
        while #out > cap do
          local drop
          local inClass = rawget(_G, "__kronosBo6InClass") or {}
          for _, k in ipairs(order) do
            local base = k:gsub("@[avc]$", "")
            if k ~= "melee" and k ~= "cap" and not inClass[base] then drop = base break end
          end
          if not drop then
            for _, k in ipairs(order) do if k ~= "melee" and k ~= "cap" then drop = k:gsub("@[avc]$", "") break end end
          end
          if not drop then break end
          for _, kk in ipairs({ drop, drop .. "@a", drop .. "@v", drop .. "@c" }) do remove(kk) end
          out = joined()
          L("bo6 handoff: full, dropped oldest gun " .. drop)
        end
        if out == cur then return end
        local okW, eW = pcall(Dvar[dvSet], named, out)
        if named ~= dv then pcall(Dvar[dvSet], dv, out) end
        local back = tostring(Dvar[dvGet](named) or "")
        if back ~= out then
          L("bo6 handoff: NOT STORED (" .. tostring(okW and "refused" or eW) .. ") " .. #out .. " chars, dvar has " .. #back)
        end
      end
      _G.__kronosBo6HookSetRef = function()
        local LWD = rawget(_G, "_LoadoutWeaponData")
        if rawget(_G, "__kronosSetRefOnce") or type(LWD) ~= "table" or type(LWD[sr]) ~= "function" or LWD[sr] == _G.__kronosBo6SetRef then return end
        local orig = LWD[sr]
        _G.__kronosBo6SetRef = function(self, ref, variant, ...)
          local value = type(ref) == "string" and ref:sub(1, 4) == "t10_" and tonumber(variant)
          if value then
            local inClass = rawget(_G, "__kronosBo6InClass") or {}
            inClass[ref] = true
            rawset(_G, "__kronosBo6InClass", inClass)
            pcall(function()
              local xd = rawget(_G, "xhashdvar")
              local cur = ";" .. tostring(Dvar[dvGet](type(xd) == "function" and xd("kronos_bo6_var") or dv) or "")
              local have = cur:match(";" .. ref:gsub("%p", "%%%0") .. "=([^;]*);")
              if value > 0 and value % 1 == 0 and have ~= string.format("%d", value) then
                _G.__kronosBo6Pending[ref] = string.format("%d", value)
              end
            end)
          end
          return orig(self, ref, variant, ...)
        end
        LWD[sr] = _G.__kronosBo6SetRef
        rawset(_G, "__kronosSetRefOnce", true)
        L("bo6 pick: SetRef wrapped")
      end
      _G.__kronosBo6HookAttSetRef = function()
        local LWA = rawget(_G, "_LoadoutWeaponAttachment")
        if rawget(_G, "__kronosAttSetRefOnce") or type(LWA) ~= "table" or type(LWA[sr]) ~= "function" or LWA[sr] == _G.__kronosBo6AttSetRef then return end
        local orig = LWA[sr]
        _G.__kronosBo6AttSlots = _G.__kronosBo6AttSlots or {}
        _G.__kronosBo6AttSetRef = function(self, att, variant, ...)
          local function pack(...) return { n = select("#", ...), ... } end
          local r = pack(orig(self, att, variant, ...))
          pcall(function()
            local weapon = tostring(self.__weaponRef or "")
            if weapon:sub(1, 4) ~= "t10_" then return end
            local slot = tostring(self.__attachmentRoot)
            local tick = rawget(_G, "__kronosBo6Tick") or 0
            local slots = _G.__kronosBo6AttSlots[weapon]
            if not slots or slots.__tick ~= tick then
              slots = { __tick = tick }
              _G.__kronosBo6AttSlots[weapon] = slots
            end
            local name = tostring(att or "")
            slots[slot] = (name ~= "" and name ~= "none") and { name, string.format("%d", tonumber(variant) or 0) } or nil
            local names, variants = {}, {}
            local seen = {}
            for k, a in pairs(slots) do
              if k ~= "__tick" and not seen[a[1]] then
                seen[a[1]] = true
                names[#names + 1] = a[1]
                variants[#variants + 1] = a[2]
              end
            end
            if #names > 0 then pcall(_G.__kronosBo6Irons, weapon, names, variants) end
            _G.__kronosBo6Pending[weapon .. "@a"] = table.concat(names, ",")
            _G.__kronosBo6Pending[weapon .. "@v"] = table.concat(variants, ",")
            pcall(_G.__kronosBo6FlushVariants)
          end)
          return unpack(r, 1, r.n)
        end
        LWA[sr] = _G.__kronosBo6AttSetRef
        rawset(_G, "__kronosAttSetRefOnce", true)
        L("bo6 attachments: slot SetRef wrapped")
      end
      _G.__kronosBo6HookCamo = function()
        local LWD = rawget(_G, "_LoadoutWeaponData")
        local kc, kg = H("606bdb297adec84f"), H("e8d8971e4e50aed8")
        if rawget(_G, "__kronosCamoOnce") or type(LWD) ~= "table" or type(LWD[kc]) ~= "function" or LWD[kc] == _G.__kronosBo6CamoSet then return end
        local orig = LWD[kc]
        _G.__kronosBo6CamoSet = function(self, camo, ...)
          local function pack(...) return { n = select("#", ...), ... } end
          local r = pack(orig(self, camo, ...))
          pcall(function()
            if type(camo) ~= "string" or rawget(_G, "__kronosBo6InEquip") then return end
            local ref = tostring(LWD[kg](self) or "")
            if ref:sub(1, 4) ~= "t10_" then return end
            _G.__kronosBo6Pending[ref .. "@c"] = (camo ~= "" and camo ~= "none" and camo ~= "camo_none") and camo or ""
            if (rawget(_G, "__kronosCamoLog") or 0) < 20 then
              rawset(_G, "__kronosCamoLog", (rawget(_G, "__kronosCamoLog") or 0) + 1)
              L("bo6 camo: " .. ref .. " = " .. camo)
            end
            pcall(_G.__kronosBo6FlushVariants)
          end)
          return unpack(r, 1, r.n)
        end
        LWD[kc] = _G.__kronosBo6CamoSet
        rawset(_G, "__kronosCamoOnce", true)
        L("bo6 camo: setter wrapped")
      end
      pcall(_G.__kronosBo6HookSetRef)
      pcall(_G.__kronosBo6HookAttSetRef)
      pcall(_G.__kronosBo6HookCamo)
      _G.__kronosBo6FillRows = function()
        local arr = _DataSources[H("8a94a07b5502cf8")][H("41cbd901b87fabb6")][H("f5e2f4190ce482de")][H("8c58f68f1b37dd22")][H("5ecb1da7ca511fb8")]
        local n = tonumber(arr[H("b1e5e28e4479a274")]:GetValue(0)) or 0
        for i = 0, n do
          local row = arr[i]
          local ok, ref = pcall(function() return row[H("535bd91b0bf933c4")]:GetValue(0) end)
          if ok and type(ref) == "string" and ref:sub(1, 4) == "t10_" then
            local okB, wb = pcall(E[H("f06093d047200548")], H("31705bf9ed477170", 3) .. ref)
            local id = okB and type(wb) == "table" and wb[H("8028887f70bf5eba")]
            local gd = row[H("4171ce3b7cadb207")]
            local nm = gd[H("2d21d7cd66bd5a5d")]
            local cur = nm:GetValue(0)
            if id then
              if cur == nil or cur == "" then
                local okL, txt = pcall(Engine[H("aed84c33ec5f01ea")], wb[H("c4bcadba8e631b86")])
                local okS, eS = pcall(function() nm:SetValue(0, okL and txt or ref) end)
                if (_G.__kronosRowNamed or 0) < 3 then
                  _G.__kronosRowNamed = (_G.__kronosRowNamed or 0) + 1
                  L("create a class: row " .. i .. " " .. ref .. " name " .. tostring(okL and txt) .. " set " .. tostring(okS) .. " " .. tostring(eS) .. " now " .. tostring(nm:GetValue(0)))
                end
              end
              local okI, img = pcall(LOOT[H("ffa7ac7cb1a8d0c6")], id)
              local im = gd[H("2ab612888528489a")]
              local ci = im:GetValue(0)
              if ci == nil or ci == "" then pcall(function() im:SetValue(0, okI and img or wb[H("2ab612888528489a")]) end) end
            end
          end
        end
      end
      local t = rawget(_G, "__kronosBo6RowTimer")
      if not (t and t:getParent()) and LUI and LUI.UIElement then
        pcall(function()
          t = LUI.UIElement.new()
          LUI.GetRoot():addElement(t)
          _G.__kronosBo6RowTimer = t
          local function tick()
            pcall(_G.__kronosBo6HookSetRef)
            pcall(_G.__kronosBo6HookAttSetRef)
            pcall(_G.__kronosBo6HookCamo)
            rawset(_G, "__kronosBo6Tick", (rawget(_G, "__kronosBo6Tick") or 0) + 1)
            pcall(_G.__kronosBo6FlushVariants)
            local okF, eF = pcall(_G.__kronosBo6FillRows)
            if not okF and _G.__kronosRowErr ~= tostring(eF) then _G.__kronosRowErr = tostring(eF); L("create a class: row fill " .. tostring(eF)) end
            t:Wait(500).onComplete = tick
          end
          tick()
        end)
      end
      local ln = H("176a0a7173b6d911")
      if type(LOOT) == "table" and type(LOOT[ln]) == "function" and LOOT[ln] ~= _G.__kronosBo6LootName then
        local orig = LOOT[ln]
        _G.__kronosBo6LootName = function(...)
          local g, m = orig(...), (...)
          if type(g) ~= "function" then return g end
          return function(v, ...)
            local r = g(v, ...)
            if r ~= nil and r ~= "" then return r end
            local wb = rowBundle(m, v)
            local okL, txt = pcall(Engine[H("aed84c33ec5f01ea")], wb and wb[H("c4bcadba8e631b86")])
            if wb and okL and type(txt) == "string" and txt ~= "" then return txt end
            return r
          end
        end
        LOOT[ln] = _G.__kronosBo6LootName
      end
      local wi = H("88ec23607b53add1")
      if type(W) == "table" and type(W[wi]) == "function" and W[wi] ~= _G.__kronosBo6Image then
        local orig = W[wi]
        _G.__kronosBo6Image = function(...)
          local g, m = orig(...), (...)
          if type(g) ~= "function" then return g end
          return function(v, ...)
            local r = g(v, ...)
            if r ~= nil and r ~= "" then return r end
            local wb = rowBundle(m, v)
            if not wb then return r end
            local okI, img = pcall(LOOT[H("ffa7ac7cb1a8d0c6")], wb[H("8028887f70bf5eba")])
            if okI and img ~= nil and img ~= "" then return img end
            return wb[H("2ab612888528489a")] or r
          end
        end
        W[wi] = _G.__kronosBo6Image
        L("create a class: grid name/image wrapped")
      end
    end
    if type(o) ~= "function" or o == wonderBundleWrapped or rawget(_G, "__kronosWonderBundleOnce") then return end
    local kMenu, kFlag = H("1d49626c84a5882c"), H("fcaac3893b4b0135")
    local EXTRA = { sat_sm_mammoth = "sat_sm_hyena", sat_sm_stoat = "sat_sm_hyena", sat_sh_terrier = "sat_sh_akita",
      sat_dm_tasman = "sat_dm_kara", sat_me_elnath = "sat_me_knife" }
    local MELEE_WONDER = { sat_ww_locust = "sat_me_knife" }
    local kList, kData, kRef = H("41cbd901b87fabb6"), H("86d696ad252f1cb1"), H("89e9c01960f4c582")
    local kOrder, kHide, kMenuClass, kClass = H("e4fb3c98aeeab347"), H("8aed63dfe5400760"), H("556143152458180a"), H("100edb64644d9b07")
    local PREFIX = H("31705bf9ed477170", 3)
    local patched = setmetatable({}, { __mode = "kv" })
    local patchedByName = setmetatable({}, { __mode = "v" })
    local donors = {}
    local BO6 = { "t10_ar_p01_coslo723", "t10_ar_p02_aking74", "t10_ar_p04_clove", "t10_ar_p05_fable",
      "t10_ar_p05_rmary2", "t10_ar_p06_asvalor", "t10_ar_p22_able18", "t10_ar_p23_love85", "t10_ar_p28_saug",
      "t10_ar_p34_tbaker", "t10_ar_p45_kent", "t10_ar_p47_gilroy", "t10_ar_p49_fresno", "t10_ar_p54_aspen",
      "t10_ar_p56_milan", "t10_dm_p01_sroger25", "t10_dm_p02_aeasy", "t10_dm_p03_sgeorge550", "t10_dm_p05_falove",
      "t10_dm_p09_svalor", "t10_dm_p50_erie", "t10_la_p17_pable3", "t10_la_p18_stisaac", "t10_lm_p01_aroger10",
      "t10_lm_p02_puncle21", "t10_lm_p07_ksugar58", "t10_lm_p33_uxray", "t10_lm_p53_mesa", "t10_me_p15_knife",
      "t10_me_p16_bat", "t10_me_p30_cleaver", "t10_me_p31_drill", "t10_me_p36_skateboard", "t10_me_p37_katanas",
      "t10_me_p38_sais", "t10_me_p39_nunchaku", "t10_me_p39_nunchucku", "t10_me_p40_bostaff", "t10_me_p48_keene",
      "t10_me_p51_pickaxe", "t10_me_p55_bgloves", "t10_me_p59_chainsaw", "t10_me_p59_csaw", "t10_pi_p12_paris30",
      "t10_pi_p13_usugar9", "t10_pi_p14_mable", "t10_pi_p14_stiger", "t10_pi_p14_striger", "t10_pi_p42_pyork",
      "t10_sh_p10_moslo500", "t10_sh_p11_olove", "t10_sh_p25_uncle12", "t10_sh_p27_jhavana", "t10_sl_p29_goslo",
      "t10_sl_p35_blauncher", "t10_sl_p44_napa", "t10_sl_p58_artifact", "t10_sl_p58_wand", "t10_sm_p02_geasy9",
      "t10_sm_p02_s4blk", "t10_sm_p03_safox", "t10_sm_p04_chuck9", "t10_sm_p06_sroger3", "t10_sm_p12_roger31",
      "t10_sm_p21_pparis90", "t10_sm_p28_saug", "t10_sm_p41_perth", "t10_sm_p43_schuck", "t10_sm_p52_lisbon",
      "t10_sm_p57_mpug40", "t10_sn_p01_sroger25", "t10_sn_p08_ultiger", "t10_sn_p09_droger", "t10_sn_p24_love96",
      "t10_sn_p26_mary82", "t10_sn_p46_hugo" }
    local function addHidden(list)
      local have, donorData = {}, {}
      for _, e in ipairs(list) do
        local wd = e[kData]
        local wb = wd and o(PREFIX .. wd)
        local r = type(wb) == "table" and tostring(wb[kRef]) or nil
        if r then
          have[r] = true
          for _, d in pairs(EXTRA) do if d == r then donorData[d] = wd; donors[d] = wb end end
        end
      end
      for ref, donor in pairs(EXTRA) do
        local dwd = donorData[donor]
        if not have[ref] and type(dwd) == "string" then
          local wd = dwd:gsub(donor, ref)
          if type(o(PREFIX .. wd)) == "table" then
            list[#list + 1] = { [kData] = wd }
          end
        end
      end
      for _, ref in ipairs(getDvar("970a7a4f1d271a37") == "1" and BO6 or {}) do
        local ok, wb = pcall(o, PREFIX .. ref)
        if not have[ref] and ok and type(wb) == "table" then
          list[#list + 1] = { [kData] = ref, [H("1a8f1706b0f16d97")] = true }
          have[ref] = true
          local id = wb[H("8028887f70bf5eba")]
          if id ~= nil then _G.__kronosBo6Loot[tostring(id)] = ref end
        end
      end
    end
    E[k] = function(...)
      if (...) == nil then return nil end
      local b = o(...)
      if type(b) ~= "table" then return b end
      local melee = donors[MELEE_WONDER[tostring(b[kRef])]]
      if b[kMenu] == "weapon_wonder" and not b[kFlag] then
        local w = { [kFlag] = true }
        if melee then w[kMenuClass], w[kClass] = melee[kMenuClass], melee[kClass] end
        return setmetatable(w, { __index = b })
      end
      if melee and not b[kFlag] then
        return setmetatable({ [kMenuClass] = melee[kMenuClass], [kClass] = melee[kClass] }, { __index = b })
      end
      local list = b[kList]
      if type(list) == "table" and type(list[1]) == "table" and list[1][kData] then
        local listName = tostring((...))
        local copy = patched[list] or patchedByName[listName]
        if not copy then
          copy = {}
          for i, e in ipairs(list) do copy[i] = e end
          local okA, eA = pcall(addHidden, copy)
          if not okA then L("create a class: list patch error " .. tostring(eA)) end
          local conv = H("0bbd1f110b4fb37d")
          setmetatable(copy, { __index = function(_, key)
            if key ~= conv then return list[key] end
            return function(_, kind, ...)
              local r = list[conv](list, kind, ...)
              if not _G.__kronosConvShape then
                _G.__kronosConvShape = true
                local function try(f)
                  local okT, v = pcall(f)
                  return okT and tostring(v) or ("err " .. tostring(v))
                end
                local mtx = try(function()
                  local mt = getmetatable(r)
                  if type(mt) ~= "table" then return type(mt) .. " " .. tostring(mt) end
                  local ks = {}
                  for kk, vv in pairs(mt) do ks[#ks + 1] = tostring(kk) .. ":" .. type(vv) end
                  return table.concat(ks, " ")
                end)
                L("create a class: converted list type " .. type(r) .. " mt {" .. mtx .. "} len " .. try(function() return #r end) ..
                  " [0] " .. try(function() return type(r[0]) end) .. " [1] " .. try(function() return type(r[1]) end) ..
                  " [hawk] " .. try(function() return type(r["sat_ar_hawk"]) end))
              end
              return r
            end
          end })
          patched[list] = copy
          patchedByName[listName] = copy
        end
        return setmetatable({ [kList] = copy }, { __index = b })
      end
      if tostring(b[kRef]):sub(1, 4) == "t10_" and b[kHide] then
        return setmetatable({ [kHide] = false }, { __index = b })
      end
      local donor = EXTRA[tostring(b[kRef])]
      local d = donor and donors[donor]
      if d then
        local order = tonumber(b[kOrder]) or 0
        return setmetatable({ [kHide] = false, [kOrder] = order > 0 and order or (tonumber(d[kOrder]) or 1) + 1,
          [kMenuClass] = b[kMenuClass] or d[kMenuClass], [kClass] = b[kClass] or d[kClass] }, { __index = b })
      end
      return b
    end
    wonderBundleWrapped = E[k]
    rawset(_G, "__kronosWonderBundleOnce", true)
    L("create a class: wonder weapon class enabled")
  end)
end
end

local CAMO_DONOR = { ar = "sat_ar_kiwi", ww = "sat_ar_kiwi", sm = "sat_sm_hyena", sh = "sat_sh_akita", dm = "sat_dm_kara",
  sn = "sat_sn_aden", lm = "sat_lm_hades", pi = "sat_pi_alcor", me = "sat_me_knife", la = "sat_la_fang", sl = "sat_sl_crossbow" }
local camoDonorWrapped
local camoDonorOf = {}
function camoDonorOf.bo6Data(od, ref)
  if type(ref) ~= "string" then return nil end
  local cls = ref:match("^t10_(%a+)_p%d+_")
  local donor = cls and CAMO_DONOR[cls]
  if not donor then return nil end
  local cached = camoDonorOf["bo6 " .. ref]
  if cached then return cached end
  local okD, dd = pcall(od, donor)
  if not okD or type(dd) ~= "table" then return nil end
  local function bundle(r)
    local okB, wb = pcall(Engine[H("f06093d047200548")], H("31705bf9ed477170", 3) .. r)
    return okB and type(wb) == "table" and wb or nil
  end
  local wb = bundle(ref) or bundle(ref:match("^(t10_%a+_p%d+_%w+)") or ref) or {}
  local kName, kImg = H("c4bcadba8e631b86"), H("2ab612888528489a")
  local data = setmetatable({
    [H("89e9c01960f4c582")] = ref,
    [H("8028887f70bf5eba")] = wb[H("8028887f70bf5eba")],
    [kName] = wb[kName],
    [kImg] = wb[kImg],
    [H("9ae1e225e2dd2df4")] = function()
      local okN, name = pcall(Engine[H("aed84c33ec5f01ea")], wb[kName])
      return okN and type(name) == "string" and name ~= "" and name or ref
    end,
  }, { __index = function(_, k)
    local v = wb[k]
    if v == nil then v = dd[k] end
    return v
  end })
  camoDonorOf["bo6 " .. ref] = data
  pcall(L, "weapon data: " .. ref .. " gaps filled from " .. donor)
  return data
end
local function weaponCamos()
  pcall(function()
    local W = rawget(_G, "WEAPON")
    local kd, kn, kr = H("138b9350dc5be603"), H("9ae1e225e2dd2df4"), H("89e9c01960f4c582")
    if type(W) ~= "table" or type(W[kd]) ~= "function" or W[kd] == camoDonorOf.dataWrapped then return end
    local od = W[kd]
    camoDonorOf.dataWrapped = function(...)
      local data = od(...)
      if data == nil and getDvar("970a7a4f1d271a37") == "1" then data = camoDonorOf.bo6Data(od, ...) end
      if type(data) == "table" and type(data[kn]) == "function" and not rawget(data, kn) then
        local g = data[kn]
        data[kn] = function(self, ...)
          local ok, v = pcall(g, self, ...)
          if ok then return v end
          if not camoDonorOf["named " .. tostring(self[kr])] then
            camoDonorOf["named " .. tostring(self[kr])] = true
            pcall(L, "weapon name: " .. tostring(self[kr]) .. " has none, using its ref")
          end
          return tostring(self[kr])
        end
      end
      return data
    end
    W[kd] = camoDonorOf.dataWrapped
    L("weapon name fallback installed")
  end)
  pcall(function()
    local G, W = rawget(_G, "GUNSMITH"), rawget(_G, "WEAPON")
    local kc = H("276e1342b82e8bd6")
    if type(G) ~= "table" or type(G[kc]) ~= "function" or G[kc] == camoDonorOf.setWrapped then return end
    local oc = G[kc]
    camoDonorOf.setWrapped = function(loot, name, ...)
      local r = { pcall(oc, loot, name, ...) }
      if r[1] then return unpack(r, 2) end
      local ref = type(name) == "string" and name:match("^sat_") and name
      if not ref then
        local okR, rr = pcall(LOOT[H("3d5d69ba555e016d")], loot)
        ref = okR and type(rr) == "string" and rr or nil
      end
      local cls = ref and ref:match("^sat_(%a+)_")
      local d = cls and CAMO_DONOR[cls]
      if d and d ~= ref then
        local ok, dd = pcall(W[H("138b9350dc5be603")], d)
        if ok and dd then
          pcall(L, "camo set: " .. ref .. " uses " .. d .. "'s")
          return oc(dd[H("8028887f70bf5eba")], type(dd[H("9ae1e225e2dd2df4")]) == "function" and dd[H("9ae1e225e2dd2df4")](dd) or d, ...)
        end
      end
      error(r[2], 0)
    end
    G[kc] = camoDonorOf.setWrapped
    L("camo set fallback installed")
  end)
  pcall(function()
    local WC = rawget(_G, "WEAPON_CAMO")
    local k = H("bf898c4e41d3372b")
    if type(WC) ~= "table" or type(WC[k]) ~= "function" or WC[k] == camoDonorWrapped then return end
    local o = WC[k]
    local function count(c, weapon)
      local n = 0
      local ok = pcall(o, c, function() n = n + 1 end, weapon)
      return ok and n or 0
    end
    local function donor(c, weapon)
      if type(weapon) ~= "string" then return weapon end
      camoDonorOf.last = weapon
      local d = camoDonorOf[weapon]
      if d then return d end
      d = weapon
      if count(c, weapon) == 0 then
        local base = weapon:match("^(sat_%a+_%a+)exotic$")
        local cls = weapon:match("^sat_(%a+)_")
        if base and count(c, base) > 0 then d = base
        elseif cls and CAMO_DONOR[cls] and count(c, CAMO_DONOR[cls]) > 0 then d = CAMO_DONOR[cls]
        else return weapon end
        L(weapon .. " has no camos; it shows " .. d .. "'s")
      end
      camoDonorOf[weapon] = d
      return d
    end
    WC[k] = function(c, fn, weapon, ...) return o(c, fn, donor(c, weapon), ...) end
    camoDonorWrapped = WC[k]
    L("weapons without camos show their base weapon's or a class weapon's")
  end)
end


local crWrapped = setmetatable({}, { __mode = "k" })
local function localCombatRecord()
  local ok, e = pcall(function()
    local CR, S = rawget(_G, "CombatRecordStats"), rawget(_G, "Stats")
    if type(CR) ~= "table" or type(S) ~= "table" or crWrapped[CR] then return end
    local kFetch, kState, kStatus = H("3fdb272a1dd67630"), H("bfbdb3ce196558d6"), H("64371ef0d96f5762")
    local orig = CR[kFetch]
    if type(orig) ~= "function" or type(S[kStatus]) ~= "function" then return end
    crWrapped[CR] = true
    CR[kFetch] = function(menu, c, mode, scope, a4, a5, a6, a7)
      if S[kStatus](c, mode, scope, a6, a7) == 3 then
        pcall(function()
          local R = rawget(_G, "RECORDS")
          if R[H("0226fb964a4b0a51")]() then
            R[H("819677aba31370ad")](c, mode)
            R[H("ad417c9ee74732c0")](c, a7 or false)
          end
        end)
        CR[kState](c, 3)
        pcall(function()
          rawget(_G, "_DataSources")[H("e7c7727daf3ffe34")][H("7273b3efa87c2905")]:SetValue(c, mode)
        end)
        return true
      end
      return orig(menu, c, mode, scope, a4, a5, a6, a7)
    end
    L("combat record read locally")
  end)
  if not ok then L("combat record wrap err " .. tostring(e)) end
end

local hookEndGame
do
  local endGameHooks = {}
  local function offlineMatch()
    local ok, pm = pcall(function() return IsPrivateMatch() or IsSystemLink() end)
    return mapMode() == "mp" and ok and pm
  end
  local function hostEndGame()
    pcall(function() Engine[H("76055c55456f05df")]("end_game", 1) end)
    pcall(function() Dvar[H("f2414681ecab880f")](H("be9a1a5090f1172b", 1), 1) end)
    pcall(function() LUI.FlowManager.RequestCloseAllMenus() end)
    L("end game sent to the server")
  end
  hookEndGame = function()
    pcall(function()
      local EG, E = rawget(_G, "END_GAME"), rawget(_G, "Engine")
      local function wrap(t, hex)
        local k = H(hex); local cur = type(t) == "table" and t[k]
        if type(cur) ~= "function" or cur == endGameHooks[hex] then return end
        endGameHooks[hex] = function(...)
          if offlineMatch() then return hostEndGame() end
          return cur(...)
        end
        t[k] = endGameHooks[hex]
      end
      wrap(EG, "0325b604ab0d6cb6")
      wrap(E, "f0a98e9884853762")
    end)
    pcall(function()
      local PD, AAR = rawget(_G, "PLAYER_DATA"), rawget(_G, "AAR")
      if type(PD) ~= "table" then return end
      local function hasData(c)
        local ok, has = pcall(function()
          return PD[H("3702ae6da42b1557")](c)[H("d3063621573060d9")] ~= nil and PD[H("dad956649ef11755")](c).round ~= nil
        end)
        return ok and has
      end
      local init = rawget(_G, "InitAARDataSources")
      if type(init) == "function" and init ~= endGameHooks.aarInit then
        endGameHooks.aarInit = function(c, ...)
          if not hasData(c) then return end
          return init(c, ...)
        end
        rawset(_G, "InitAARDataSources", endGameHooks.aarInit)
      end
      local k = H("4b4e578ab9e1b66f")
      local show = type(AAR) == "table" and AAR[k]
      if type(show) == "function" and show ~= endGameHooks.aarShow then
        endGameHooks.aarShow = function(c, ...)
          if not hasData(c) then return false end
          return show(c, ...)
        end
        AAR[k] = endGameHooks.aarShow
      end
    end)
  end
end
rawset(_G, "__kronosBo6Ops", {
  { "Adler", { "Umbra", "Vibrant Serpent", "Archie Atom", "Dadler", "Truth Chaser", "Truth Chaser BlackCell", "Herald of the Hay", "Outdoorsman", "Nuketown Mayor" }, "77f27320a94a4323", { "4f5ebc3012cdc104", "5207bae5b61dd1c2", "23c6b6ade7db443b", "1fa5c7a00f810b08", "06f37819b7e9748b", "403be66dba872f6b", "61da0fda8896d20d", "4a30fc2f4b8e9481", "330b7002f893fcac" } },
  { "All Dolled Up", { "All Dolled Up" }, "76314540268bdcf6", { "69fdc7ff3ff5e71a" } },
  { "Alvarez", { "Reverb", "Get Bent", "Flight Path", "Unleash the Truth", "Cruiser", "Speedtrap", "Polyphonic", "Arcana Conquerer", "Vacation Vibes", "Nikoniko", "Merc Test", "Mad Whistler", "La Jaguar", "Wilder", "Neovira", "Lady-quinn", "Scavvy" }, "060bb66b72586c94", { "21ef1a6f323c93e6", "7ac7d1ae2af04097", "42a9fb52d37ee2a9", "40ebd35736d619f3", "07ebcbb39045584f", "75acb6c79715fc71", "477eab95e551e308", "0e3e7d09b5cf3630", "3cdcea77dec3fb22", "368156b33193e688", "4f7fd9da37e13e71", "1665547c5a235a4a", "03d94d279db6a9dc", "73419bf603b5f3c2", "7db1f3bb857f175f", "0a1f1b88fc4901bd", "0f4f15d11c6c4e67" } },
  { "Bailey", { "Recon", "Aero", "Anarchist", "Subterfuge", "All Smiles", "Art of War", "Velocity", "Pixel", "Smoking Gun", "Foot Clan", "Queen of Hearts", "Data Cipher", "Nocturnal Scout", "Nocturnal Scout BlackCell", "Star Reader", "Low Tide" }, "3717a8a0491a802f", { "5b391213613b62e7", "1cdd7d2553ad466b", "60849bf216ec7939", "3b2baf3456c3dc47", "35479b8f2eaf2465", "0afefe04649de236", "20f8e33d9a74740a", "67b1fc36dbac0c70", "4e54fa247575b963", "6e3ded9083efadc2", "22720a1ce83e4ab6", "4b9234bb576d8e99", "72e684c85fddb879", "66d6de772f32df79", "7b44300a9f395cbe", "5895fbf1d2e59214" } },
  { "Bayan", { "Maverick", "Quiet", "Drifter", "Divine Malice", "Jack", "Cauterize", "Black Diamond", "Wrap", "Pure Grin", "Carton Robo", "Armored Wreck", "Upended" }, "374e1f894515f658", { "70df2dc9a3a67b73", "21dc3c5ddfae3963", "79a3caf69349164f", "257c78420bd1ba25", "173847fdaab29848", "0336da4762fa3834", "2c3a8d2268c0a7de", "7b11c09348c85487", "01b45c9fd0a1ac13", "40422c4293facbe3", "66d7d5378920fd2e", "30eda477f65acc61" } },
  { "Beavis", { "Beavis", "Recon Beavis" }, "014fa87f362e43cb", { "488f7652cd297617", "0fbe6b5c1d5a5fd3" } },
  { "Brutus", { "Warden of Alcatraz", "Calamity", "Tackle", "Decayed Bronze", "Geophase", "Dreadwarden", "Dreadwarden BlackCell" }, "3fb631500d3d2b4c", { "077dd24ea0307ed0", "312745b3e9d473d8", "3969b45ced9c0a9d", "1668d605015e7670", "493d447cdfdac3b7", "3abd1e33310c341e", "41c2a35a9b63e40c" } },
  { "Butt-Head", { "Butt-Head", "Infil Butt-Head" }, "76f4c7ce2409ca17", { "64155b7406cfd763", "4c756ab5e29c9d60" } },
  { "Caine", { "Coyote", "Ride-N-Die", "Future Combatant", "Major Za", "The Bull", "Swordmaster", "No Love", "Falconer", "Trail Blazer", "Honed Ravager", "Bearserker", "Combat Flannel", "Star Player", "Veiled", "Daggered", "Zeus", "High Altitude", "Chow Time", "Chow Time BlackCell", "Cunning Thievery", "Hades", "Ruthless Jock" }, "595c0db38d26e3c5", { "2996408319f6a6c6", "10b6fd9ffdf6c215", "4bfb2d68aec72ce9", "6b5474dccc7c600a", "4c274581c57b9c17", "08d6e588c0f6cfea", "77fadc383253744a", "260a2c267d2ffce0", "38573b5a222834cb", "37601781b5e911d0", "189d4569e9de54c0", "172fc344f8cd406a", "36168f0ec23a6861", "1cda01b622bbca69", "068fde9b83b786fd", "6f2d4e2ef0ceba1d", "7c5421b1edbe7080", "3af368d5e8ad61ad", "370c062ed1a1b3fd", "25cbab8ad2e4f843", "17b6b2d3a71dca09", "2e59fa269afbe429" } },
  { "Carver", { "Unshaken", "Tarnished", "Bloke Biter", "Host", "Expedition", "Strict Policy", "The Monk", "The Monk BlackCell", "Elementalist" }, "02930f777705bcfe", { "48b13611aae51813", "2cb0908a1f9815a1", "74f307e9036c75f0", "5eaad192ea2c4b5a", "667611abf81cef57", "62d75551a67ba26a", "4370d8e6974192a8", "4d43b71b3ced2a8e", "05d69d0771619fb0" } },
  { "Coach Buzzcut", { "Coach Buzzcut" }, "41c7749edcbe490d", { "248d6e6bfbeb1b7d" } },
  { "Competitor", { "2025 CDL Home", "WZ Ranked Competitor" }, "307737d1cef8686c", { "556fe4e3e6fed83c", "6857d1537b9a43c2" } },
  { "Dek", { "Dek with Mask" }, "41eab140c3d51f96", { "33d0bf711f2accba" } },
  { "Domino", { "Domino" }, "13f3a6a4e3ee9761", { "194cdb2c727a7191" } },
  { "Donatello", { "Donatello" }, "0f14711fa228b1ee", { "4bbedaf1c1dcf5a2" } },
  { "Dread", { "Dread" }, "2a11f64aba7384fc", { "27825a8026721a0c" } },
  { "Eve Macarro", { "Eve Macarro", "Ruska Rogue" }, "1b1d2543ffe7bb67", { "3011df9f36e381b9", "5c3ad242b4429eed" } },
  { "Feral Predator", { "Feral Predator", "Feral Predator BlackCell" }, "6be320a121f57981", { "6b6b4e6047d40aaa", "4b3f36c10b9fb388" } },
  { "Front Man", { "Front Man" }, "4b94743107daa5c5", { "4e16599bf6dbfac5" } },
  { "Goliath", { "Goliath" }, "4f13c316d224a460", { "6c4e56cb91a88186" } },
  { "Grey", { "Frayed", "Exterminator", "Astro-Chick", "Vocator", "Samantha's PJs", "Toxigenic", "Toxigenic BlackCell", "Bounty", "Quarantine Officer", "Wolf Skinner", "Wolf Skinner BlackCell" }, "1044fee70a2600cc", { "6bdf8882055b528d", "22c886025cf69def", "0bfd5bd59ea7010d", "52ba9e0c3cb08237", "098406f16a172706", "3c45cf95013d99c9", "1517e07d5c48c982", "79a19f7ad29175b1", "1f3c8da57805d53d", "21f1a49692d632e9", "1975bf898626d9e9" } },
  { "Hudson", { "Hudson", "Icebreaker", "Icebreaker BlackCell", "Hudson BlackCell" }, "2d067e5df50750f2", { "272f8a00d3f63135", "31d59d6fc4289dd6", "7aa5d21feaa1ebe4", "0970e9a4ad402f65" } },
  { "Jack", { "Jack", "Random Skin" }, "4c56f8020460f7ba", { "38d853a524ec9db6", "0bbbbef014511653" } },
  { "Jason", { "Jason", "Tactical Jason" }, "7ee7f4399ea9ce15", { "260899ecc476afd5", "6534ce1080e8e2d9" } },
  { "Jay", { "Jay", "Chronic" }, "299235f344080dd5", { "7a05431404157895", "1f5f3520f455259b" } },
  { "Jill", { "Jill" }, "1b4c998079e1f934", { "118cdab19b279e7c" } },
  { "John Black Ops", { "[REDACTED]" }, "1f2151367d44cff4", { "1d2a884bf55b7f34" } },
  { "Klaus", { "Reborn", "Ref", "Robo Rocker", "Steel Butler", "Stovepipe", "Powerhouse" }, "71d7bc48a427edc0", { "2b6f656a6b655626", "6704965753be7856", "7c3c3a2212d26e07", "7efa3de2d64a1141", "3a81f9ef8041c2ab", "5e5df2a5f47068ba" } },
  { "Leonardo", { "Leonardo" }, "03db737b53a3b503", { "01cdd32ee0ab0e3f" } },
  { "Mace", { "Mace", "Mace BlackCell", "Apocalypse King", "Apocalypse King BlackCell" }, "6fc6e9fad211e49f", { "4681472f1aad46bb", "0a85da197457ca5b", "0b743c7c9374f4be", "162c1483d9c87c6c" } },
  { "Marshall", { "Sandman", "Watchdog", "Bout It", "Attrition", "Sitting Bull Reborn", "Irradiated", "Sleetburn", "Heist", "Unseen", "Kingmaker", "Kingmaker BlackCell", "Hazard Prep", "Hazard Prep BlackCell", "Deadtide", "Shivers", "Mile Die", "Unexpired" }, "7fc5dbf6ee1791cb", { "4f39f4982bd25272", "1a630d7236025d7d", "1794e80e7249e91d", "11677160e8b707d0", "2bbd272b534c36bd", "6b89b26367ab8f68", "3175eaaea0f3549d", "36e8c7cd853575cf", "506a417177725045", "159ecc539a2b8178", "62849a5f1cd3b40a", "35206c8d54017e15", "1f3a530eb2f10c85", "50f7ae7fcce4ffcc", "156edca18a0cca9e", "60135d349e1898a9", "3afafa2e9b72233d" } },
  { "Maya", { "Joyride", "Underground", "Knitted Out", "Player 115", "Specialist Fan", "Crimson Chaos", "Aetherella", "Mr. Peeks", "Rogue Archer", "Rogue Archer BlackCell", "Dead Thrash", "Asphalt", "Asphalt BlackCell", "Runner", "Pro for Hire" }, "60a944573bd16b2a", { "412ed83b5babff1b", "7cc42db148938e2e", "76de4194c5d0a296", "6381adf01138d166", "5060e24a6fa7ceec", "0305825fa4fa9187", "50e050badb203abe", "2aa254e5e608e60b", "4794a71bc075091f", "356d0cb77b16574f", "3d49f4a22425502c", "4a24cdc56d8f01b8", "1393d7845343d2de", "5be1ce195f23b0b5", "212444c2af4157b0" } },
  { "Michelangelo", { "Michelangelo" }, "67871f4add7ea85f", { "3c9b832e51f13d7b" } },
  { "Mil-Sim USEF", { "Mil-Sim USEF" }, "032f71e07db7bf44", { "2b077f2ff2908404" } },
  { "My Tiffany", { "My Tiffany" }, "5168af5851c0df54", { "79a5c8bbba858794" } },
  { "Nazir", { "Renegade", "Clear Cut", "Dapper", "Slick Style", "Hella Chill", "Merciless", "Gold Dipped", "Mongoose", "Solitude", "Stop Motion", "Shrub Wise", "Mall Police", "Skate Rat", "Khnum" }, "398b487ab3ab3604", { "59beb72003fef47c", "76b473f77713fbbc", "211ffdf27908ed9f", "693ec3596f773c74", "4ea6cefdd97d6747", "24731adeac791b49", "0f7aaa22b3d13786", "201f946009884816", "0c09cec264348a95", "5de9fc4d168ca294", "2d16544aafe5ad27", "589774a131057b82", "283ca35c7f121a6b", "69c1dc496d1d1e26" } },
  { "Niran", { "Ranger", "Machetero", "Big Slick", "Raccoon Goon", "Sleet", "Player 006", "Haxor", "Mech Enthusiast", "Paranoiac", "Stained Hunter", "Detective", "Detective BlackCell" }, "5e6d59344db26859", { "5aaedd1925b73999", "4ec0684a9771e501", "5e0b57fe1491f7a1", "3591744cf9941b8d", "62cf90b6f751cce0", "788b21d5663cc8a1", "66a317ba75c055f0", "5432aa88269cf97d", "6418b07eb45dce5b", "09fdd6ef3d350739", "4545c6d62a845748", "4e466d0151b3c86e" } },
  { "Nocturne", { "Maul", "Bladesmith", "Divine Enforcer", "Gekido sita Oni" }, "4c603a78fb07d9c7", { "75a3351ac165257e", "651be170bf54a8c9", "686108c7eb68fd85", "37fccd0384d1a794" } },
  { "Omen", { "Omen" }, "67921f77a4625d95", { "31c594fa41269b55" } },
  { "Park", { "Oblivion", "Fortune Possessed", "Fluid Fury", "Survivor's Guile", "Survivor's Guile BlackCell", "Survivor's Grit", "Survivor's Grit BlackCell", "Leftenant", "Stratus", "Forest Shadow" }, "39950f5858ad2edf", { "67a16e9dfbcf3061", "2f6f3735a85519f2", "66f0f20ce07fa612", "038031fa56d9bb4f", "72fbb9f46393db79", "70a647daeae8c872", "17260e0c81efeb30", "3d9aa31d52e994b8", "678f41bb9a3437b3", "060eaa4fb4d44b5f" } },
  { "Payne", { "Safeguard", "Spirit Pumpkin", "Fixer", "SC1", "My Name Is...", "Plasmic", "Verdansk Fan", "Wardens Fan", "Wizard of COD", "Disavowed", "Die-ceratops", "Treasure Seeker", "Uniform", "Uniform BlackCell", "Stallion", "Hotshot", "SAS Directive", "Hippie Free", "Mischief of Commensals", "Paranormal Investigator" }, "6d693e82226caf3c", { "2c9a3b48676f1937", "0036d741f18a0e40", "02b0a34e3094679e", "6807efdf90d4eea0", "5d2eae4019ebfe5f", "2e90345dc89e824d", "391a233a34fe6fb9", "5a7358dbf63c226f", "29cd56c28ae9b612", "64d258dacf5297fe", "214c33e0c3d14847", "3c4b84228969cd5a", "5e1206ffd4ba1eca", "5e2841d3d8b6d3e8", "0555fc0d9fc86dde", "47f1bd9d903eb9e3", "1e1980d618e03f5d", "2548c33cccee850f", "003f672da9ebca93", "13660b6d99d77688" } },
  { "Predator", { "Jungle Hunter", "Jungle Hunter BlackCell" }, "350f5ffaf94efd9a", { "3e4d86bb84b83c8e", "748eac64a6a6317c" } },
  { "R0-Z3", { "R0-Z3" }, "3d5927f4b59f3a93", { "7b7167eeb00850cf" } },
  { "Raphael", { "Raphael" }, "001225aa45b7f70e", { "44b31c502b7b3b42" } },
  { "Reznov", { "SOG Reznov", "Stalingrad Reznov", "Memory Reznov" }, "6aa83088893431a8", { "12039a93e5b74b54", "3378fd65c50aea5f", "174e50fefb522277" } },
  { "Roger", { "Roger", "Ricky Spanish", "Jeannie Gold" }, "450e69d63609a7d8", { "413c555ddf437298", "296f4338206519c1", "38b6db615bb1af12" } },
  { "Rossi", { "Covert", "The Cleaner", "Mean Streets", "Gunsmoke", "Volatile", "Brightrider", "Unavowed", "Smirk Merc", "Gunsmoke BlackCell", "Grim Reef", "Hardtop", "Moss Cryptid", "Moss Cryptid BlackCell", "Sky Traveler" }, "7b174d5bcd462460", { "4f2f7fb4827008e6", "7346752bf0ceb8bc", "260679c57e07a034", "3279a38ce85e98a9", "6b8a882a18666421", "4d292981a6164b59", "5df413f3548c50b8", "1906a7bed9704032", "4d54a2d1189cbe70", "2371457f379a854a", "7c821d77f98a8a63", "6024e5764346e51d", "18aa55e11513bd6d", "397d2429a31f2c61" } },
  { "Seth Rogen", { "Fired Up", "Host Rogen" }, "46051793adb64ee1", { "27b89bb4a61804d0", "0ea4ade05accc511" } },
  { "Sev", { "Sev", "Opulent", "Paradox", "Weedstronaut", "Urban Shortfin", "Gear Jockey", "Timetrotter" }, "42b60637ba62e816", { "480a75eb6ce82c1d", "51468b6cd7b439ee", "0ff283a128f3bf27", "4b91f94a741598d0", "755f008a0c1d084c", "3c5c158f9cc90197", "3d27c566a574b2ae" } },
  { "Silent Bob", { "Silent Bob", "Bluntman" }, "40b38385a6946b00", { "71590e1c7234c590", "5a119c4421a6dbb4" } },
  { "Sims", { "Stogie", "Stogie BlackCell", "Envenomate", "Envenomate BlackCell" }, "6b4ddbedadd0b93d", { "411f1453dcd0fced", "26a42617dda7003d", "5e87d989f6f5862a", "58939480b0063208" } },
  { "Solace", { "Solace" }, "629fd1ef8406277a", { "049fe0304ae840ee" } },
  { "Splinter", { "Splinter" }, "2703b478111207ce", { "2d71cdb986d34402" } },
  { "Stan Smith", { "Stan Smith" }, "4befb758cbd115f9", { "4577910174151e59" } },
  { "Stitch", { "Supermax", "Supermax BlackCell", "Yard Dog", "Yard Dog BlackCell" }, "603c7668bc5bfd75", { "2e65c17976192735", "4846817ba4ae8165", "77f2f099a1aeeff8", "10d82259c9542f1e" } },
  { "Stone", { "Faceless", "Zip Tie", "Deco", "Blunty", "Snowdrift", "Shadow Work BlackCell", "Shadow Work", "Siphon", "Bulldog", "Not Enough Bacon", "All Terrain", "All Terrain BlackCell", "H2O", "Casual Ops", "5H4DOW", "5H4DOW BlackCell", "Dark Whisper", "Card Master" }, "6c87d14c8bcfbc20", { "51bdbca15a2d8a52", "0f2b24102e3c8bce", "1b23613b4c355b04", "7da0874567057a03", "0c899adb2a21957b", "425736aad8162567", "1826b4e0d3da7d44", "406ffce53a83b93b", "151c7737445ee4c6", "113f8a9d71adc0d0", "7bd47a027565e6fd", "7eac80e528cf058d", "5ca3285299d80121", "1513e7a90d058674", "1c1ceb030a8a038c", "170e52c0929aeb62", "383bec898765137a", "02893c9f475c4b14" } },
  { "T-800", { "Model T-800", "Endo Titanium Core" }, "30faf2fceaebc15c", { "1c667d4306ad63ec", "1214e7eb1d8d5d0e" } },
  { "The Fisherman", { "The Fisherman" }, "6d124712f1a1144b", { "64ed936b2897ea97" } },
  { "The Replacer", { "The Replacer (BO6)", "The Replacer BlackCell", "Replacer Racer", "Strike Force", "Replacer Reanimated", "Replacement Warrior", "Squad Replacer" }, "605cc7886d5c7566", { "659b8dc8a85d23dd", "42c1881a47092c2d", "26a6a04998e0ca74", "5103920f0b40c4ab", "79f68a2dcf37bd90", "64d9cd87c5a012c9", "6785c65cd5ac2c4a" } },
  { "Todd", { "Todd" }, "2abb18d783087fc4", { "1e33a792d8286884" } },
  { "Toro", { "Heavyweight", "Toy Man", "Bladesman", "Daddy Claus", "Duster", "Flow State BlackCell", "Flow State", "Saltwater", "Undying Radiation", "Goloso", "Undead Foot Clan", "The Champ", "Jug-o-Not", "Jug-o-Not BlackCell", "Early Release", "Print Master", "Armordillo", "TKO", "TKO BlackCell", "Mariachi" }, "4ce150e94bd139f1", { "56104da86f1b5041", "17631dba838fa088", "38ae188d63982b9d", "42f9c8d2b0380fc1", "5ca942124d6a0327", "686437a21450299b", "77ead54d8ea33c24", "7d38ef0241866255", "6f82d256c23a624c", "2e0f83674f6fb6b1", "4137259a082453ec", "76d2db8d1bf65f9c", "4f0e398f6bf5b7ce", "416fbdc8c932c8bc", "478b510bfb30c403", "5503cb4669811c5c", "507a5686b48a033b", "373b2b9447be6ed4", "59f915513f17640a", "3ac8abc3ee9aab45" } },
  { "Vortex", { "Vortex" }, "188a1bf1c27b76c4", { "168093ce64bed784" } },
  { "Weaver", { "Timber", "Repairman", "Pullover", "Nacht Raider", "Guerilla", "Detonator", "Hardboiled", "Reinforcer", "Barb Wired", "Barb Wired BlackCell" }, "2aa0c21c82b46ff0", { "35cf6bdd18484fb2", "5d82329484c55038", "31ab11233d70c6d0", "7164a2b5afab38c2", "7513165ae2650f94", "5bbcc2bbad74e59e", "43b40f53b842e1e1", "3e0efee627430def", "3d78b21108163fc5", "486bee00aa67be75" } },
  { "Westpoint", { "Off Grid", "Dune Wraith", "Dragon Knight", "Squish", "Squash", "Sinslayer", "Folia Brasileira", "Bog Banshee", "Shieldmaiden", "Sitrep", "Planetary Matriarch", "Paramedic", "Mechanized Brain", "Dusty Venture" }, "4c852d9621b4e298", { "4e4dd5c1e37eae80", "744c36f9e88e0495", "573dbad1d35812b2", "2e5ce2d36c86b6f4", "553fb8a4b6c481fc", "50ce9ccbf93b8751", "4b3ef9e4faae0c3f", "2711663f80d7d63e", "23e53ebc6efbcc74", "0c4e811c111b2fdf", "53928faae9571784", "2f6dd1f41e393c17", "6e310f5e14170865", "47366ec17f4e8efa" } },
  { "Woods", { "Classic Woods", "Zombie Woods", "Numbers Woods", "Valorous", "Sea Rogue", "Winter Guise", "Winter Guise BlackCell", "Billie Baller", "Thrill Guide", "Bellerophon", "Molten Creation", "Molten Creation BlackCell" }, "2e229ded16855d29", { "76390385755b45b4", "0743330ee24e1a50", "03402c291fd3ffea", "7798ebcfc0c777c3", "34404ad0ff7bcff0", "00db9da7a62db1b1", "1ced0a9a836e1851", "597cb558a322dfcb", "6487ea89543f2811", "408bb5c990dc504a", "5145b934914ddc5d", "57aa0e66326369ad" } },
  { "Young-Hee", { "Young-hee" }, "46107b93bf26e953", { "0bca2db6f12e3a8f" } },
})
local DBG_OPTS = {
  { id = "5a6d0000000000a1", kind = "toggle", dv = "890bdbcdc0a1091c", name = "Unlock Everything",
    desc = "Every item unlocked (Saturn's behavior). Off: each switch below decides." },
  { id = "5a6d0000000000a2", kind = "toggle", dv = "32505ff5f2194656", name = "Unlock Camos",
    desc = "All camos and weapon mastery badges. Off: earn them through their challenges; store, battle pass and event camos stay locked." },
  { id = "5a6d0000000000a3", kind = "toggle", dv = "c78566f4e820a79c", name = "Unlock Calling Cards",
    desc = "All calling cards. Off: earn them through their challenges; store, battle pass and event cards stay locked." },
  { id = "5a6d0000000000a4", kind = "toggle", dv = "f8523b067c4e3f14", name = "Unlock Reticles",
    desc = "All reticles. Off: earn them with aiming-down-sights kills; store and battle pass reticles stay locked." },
  { id = "5a6d0000000000a5", kind = "toggle", dv = "286d0036956508a1", name = "Unlock Blueprints",
    desc = "All weapon blueprints. Most are store or battle pass items that cannot be earned in Zombies." },
  { id = "5a6d0000000000a9", kind = "toggle", dv = "165cca71d6e0eb6e", name = "Unlock Weapons",
    desc = "Every weapon usable at any player level. Weapon levels and the attachments they unlock still progress." },
  { id = "5a6d0000000000ad", kind = "toggle", dv = "4c049454b7712009", name = "Unlock Attachments",
    desc = "Every attachment usable. Off: attachments unlock with weapon levels (the levels progress either way)." },
  { id = "5a6d0000000000ae", kind = "toggle", dv = "3acc9a19a6b040c2", name = "Unlock Operators",
    desc = "All operators and skins. Off: starter operators, level and prestige rewards and completed challenges only; store and battle pass skins stay locked." },
  { id = "5a6d0000000000af", kind = "toggle", dv = "ce9adf10ba02bb32", name = "Unlock Perks",
    desc = "All perks. Off: perks unlock with your level." },
  { id = "5a6d0000000000b0", kind = "toggle", dv = "7e5d04902d53d21f", name = "Unlock Equipment",
    desc = "All lethal and tactical equipment. Off: equipment unlocks with your level." },
  { id = "5a6d0000000000b1", kind = "toggle", dv = "b971eb8bfec6de98", name = "Unlock Scorestreaks",
    desc = "All scorestreaks and their overclocks. Off: they unlock with your level and their challenges." },
  { id = "5a6d0000000000b2", kind = "toggle", dv = "a344192ed5de617a", name = "Unlock Field Upgrades",
    desc = "All field upgrades. Off: they unlock with your level and their challenges." },
  { id = "5a6d0000000000b3", kind = "toggle", dv = "5f47471d85315b6c", name = "Unlock Wildcards",
    desc = "All wildcards. Off: wildcards unlock with your level." },
  { id = "5a6d0000000000b4", kind = "toggle", dv = "e0170191f9aa8be2", name = "Unlock Ammo Mods",
    desc = "All ammo mods. Off: ammo mods unlock with your level." },
  { id = "5a6d0000000000b5", kind = "toggle", dv = "a925cabe4331f8a0", name = "Unlock Emblems",
    desc = "All emblems. Off: starter emblems and earned ones only; store, battle pass and event emblems stay locked." },
  { id = "5a6d0000000000b6", kind = "toggle", dv = "5c5111ff0950f1fa", name = "Unlock Finishing Moves",
    desc = "All finishing moves. Off: starter and earned ones only; store and battle pass ones stay locked." },
  { id = "5a6d0000000000b7", kind = "toggle", dv = "1692842991d67298", name = "Unlock Emotes",
    desc = "All emotes and gestures. Off: starter and earned ones only; store and battle pass ones stay locked." },
  { id = "5a6d0000000000b8", kind = "toggle", dv = "25046c1acf9f2af3", name = "Unlock Sprays",
    desc = "All sprays. Off: starter and earned ones only; store and battle pass ones stay locked." },
  { id = "5a6d0000000000b9", kind = "toggle", dv = "83133744125494c1", name = "Unlock Weapon Charms",
    desc = "All weapon charms. Off: earned ones only; store and battle pass charms stay locked." },
  { id = "5a6d0000000000ba", kind = "toggle", dv = "dc48a78d56842305", name = "Unlock Stickers",
    desc = "All weapon stickers. Off: earned ones only; store and battle pass stickers stay locked." },
  { id = "5a6d0000000000bb", kind = "toggle", dv = "6772e6850b0397d0", name = "Unlock Loading Screens",
    desc = "All loading screens. Off: starter and earned ones only; store and battle pass ones stay locked." },
  { id = "5a6d0000000000bc", kind = "toggle", dv = "a1f01871dd473e79", name = "Unlock Augments",
    desc = "Every Zombies augment researched to its last tier. Off: augments are researched by playing." },
  { id = "5a6d0000000000bd", kind = "list", dv = "a5d3dab009ba642c", name = "Extra Major Augment Slots",
    desc = "Extra major augments per perk, ammo mod and field upgrade. Pick past the normal slot to fill them; pick one again to remove it.",
    values = { "0", "1", "2", "3" } },
  { id = "5a6d0000000000be", kind = "list", dv = "e4644f6a59df80e0", name = "Extra Minor Augment Slots",
    desc = "Extra minor augments per perk, ammo mod and field upgrade. Pick past the normal slots to fill them; pick one again to remove it.",
    values = { "0", "1", "2", "3" } },
  { id = "5a6d0000000000a6", kind = "toggle", dv = "9fab694ee3b3dac5", name = "Unlock GobbleGums",
    desc = "99 of every GobbleGum. Off: gums are used up and earned over round time." },
  { id = "5a6d0000000000a7", kind = "gumset", dv = "de6bae2dda1e3534", name = "GobbleGum Count",
    desc = "Set every GobbleGum to this amount.", values = { "-", "0", "1", "3", "5", "10", "25", "50", "99" } },
  { id = "5a6d0000000000a8", kind = "list", dv = "82767ec4659c223d", name = "GobbleGum Earn Rate",
    desc = "Minutes of round time per earned GobbleGum (online is 15).", values = { "1", "5", "10", "15", "20", "30", "45", "60" },
    suffix = " min" },
  { id = "5a6d0000000000ab", kind = "prestige", name = "Prestige",
    desc = "Your prestige. Below Prestige Master the level stops at 55.",
    values = { "None", "Prestige 1", "Prestige 2", "Prestige 3", "Prestige 4", "Prestige 5", "Prestige 6", "Prestige 7",
      "Prestige 8", "Prestige 9", "Prestige 10", "Prestige Master" } },
  { id = "5a6d0000000000ac", kind = "level", name = "Level",
    desc = "Your level: 1 to 55, up to 1000 at Prestige Master (reopen this page after changing prestige)." },
  { id = "5a6d0000000000bf", kind = "list", dv = "09b8247922d2800f", name = "Zombies Test Bots",
    desc = "Bots added to your Zombies lobby (stock private match bots), for testing co-op on your own.", values = { "0", "1", "2", "3" } },
  { id = "5a6d0000000000c0", kind = "list", dv = "4d9298260a67304f", create = "zm_box_weapons", name = "Mystery Box Weapons",
    desc = "Guns the Zombies Mystery Box gives: BO7 and BO6 mixed, BO7 only or BO6 only. Wonder weapons are not affected. Applies from the next spin.",
    values = { "0", "1", "2" }, labels = { "BO7 + BO6", "BO7 Only", "BO6 Only" } },
  { id = "5a6d0000000000c2", kind = "toggle", dv = "3614a28eb790a498", name = "Memory Pools Overlay",
    desc = "Shows live memory use in the top right: LUI heap, GSC memory and the fullest asset pools (used, capacity, fill and peak)." },
  { id = "5a6d0000000000c1", kind = "list", dv = "09c5347922e0b7c4", create = "zm_test_boss", name = "Spawn Test Boss",
    desc = "Spawns a boss merged in from another map beside you shortly after you spawn, to test ported assets.",
    values = { "0", "1" }, labels = { "Off", "Dravakar" } },
  { id = "5a6d0000000000c3", kind = "list", dv = "cb7d90266f73c49e", create = "bo6_operator", name = "BO6 Operator",
    desc = "During a match (Multiplayer and Zombies, not Dead Ops Arcade): switch to this BO6 operator right away. Every match starts Off, so you load in as the operator picked in Operators. Off: back to that operator from the next spawn. Reopen this page after changing it to see the operator's skins. Needs BO6 operators on in the launcher.",
    dyn = function(o)
      local d = rawget(_G, "__kronosBo6Ops") or {}
      o.values, o.labels = { "0" }, { "Off" }
      if getDvar("22ff539d4e061c4c") ~= "1" then o.labels[1] = "Off (launcher)"; return end
      for i, op in ipairs(d) do o.values[i + 1] = tostring(i); o.labels[i + 1] = op[1] end
    end,
    after = function()
      setDvar("7e3dc9d77c5db1f2", "1")
      if getDvar("7e3dc9d77c5db1f2") ~= "1" then exec("set bo6_operator_skin 1") end
    end },
  { id = "5a6d0000000000c4", kind = "list", dv = "7e3dc9d77c5db1f2", create = "bo6_operator_skin", name = "BO6 Operator Skin",
    desc = "Skin for the BO6 operator above. The list follows the operator picked when this page opened (reopen the page after changing the operator).",
    dyn = function(o)
      local d = rawget(_G, "__kronosBo6Ops") or {}
      local op = d[tonumber(getDvar("cb7d90266f73c49e")) or 0]
      o.values, o.labels = {}, {}
      for i, s in ipairs(op and op[2] or { "-" }) do o.values[i] = tostring(i); o.labels[i] = s end
    end },
  { id = "5a6d0000000000aa", kind = "toggle", dv = "8c1ebc67a94d9786", name = "Debug Log",
    desc = "Write the menu's debug lines (item lookups, camo errors) to cod25\\poi_reg.log." },
}
local DEAD_UNLOCK_ALL = "3f58d23122dd68ae"
local LV_XP = { 0, 4500, 9500, 15000, 20500, 26500, 33000, 40000, 47500, 55500, 64000, 73000, 82500, 92500, 103000,
  114000, 125500, 137500, 150000, 163000, 176500, 191000, 206000, 221500, 237500, 254500, 272000, 290000, 309000, 328500,
  348500, 369500, 391000, 413500, 437000, 461000, 486000, 512000, 538500, 566000, 594500, 624000, 654500, 686000, 718500,
  752000, 786500, 822000, 858500, 896500, 935500, 976000, 1018000, 1061500, 1106500, 1153000, 1200000 }
local DV_XP, DV_RANK, DV_PRESTIGE = "f4bb97895b995476", "a9e6b907229d534e", "703f4ce774962899"
local PRESTIGE_MASTER, LEVEL_CAP, LEVEL_MAX = 11, 55, 1000
local function levelXP(level)
  if level <= #LV_XP then return LV_XP[level] end
  return LV_XP[#LV_XP] + (level - #LV_XP) * 48000
end
local function topLevel() return (tonumber(getDvar(DV_PRESTIGE)) or 0) >= PRESTIGE_MASTER and LEVEL_MAX or LEVEL_CAP end
local function setLevel(level)
  level = math.max(1, math.min(math.floor(level + 0.5), topLevel()))
  setDvar(DV_RANK, tostring(level - 1)); setDvar(DV_XP, tostring(levelXP(level)))
end
local OK = { id = "08b72e07b55c3ac0", sb = "7228576e3216368b", type = "a79439ef7bfa9c2d", name = "c4bcadba8e631b86",
  desc = "0cc44970c8397929", labels = "4bc513f856980a8a", value = "7ce4fd9430e80cea", action = "6568640b035a56df",
  def = "1230e315819fab00", list = "de7843f98867b161", autoId = "488ca93aa60dc466" }
local gumSetSerial, gumSetLast = 0, 1
local function autoXHash(t)
  local X = rawget(_G, "XHash")
  if type(X) == "table" and X.SetAutoXHashMetatable then return X.SetAutoXHashMetatable(t, 0) or t end
  return t
end
local function dbgOptionData(o)
  local t, id = {}, H(o.id, 3)
  t[H(OK.id)] = id; t[H(OK.sb)] = id; t[H(OK.name)] = o.name; t[H(OK.desc)] = o.desc; t[H(OK.def)] = 1
  if o.kind == "toggle" then
    t[H(OK.type)] = "ToggleButton"; t[H(OK.labels)] = { "Off", "On" }
    t[H(OK.value)] = function(c) return getDvar(o.dv) == "1" and 2 or 1 end
    t[H(OK.action)] = function(c, v) setDvar(o.dv, v == 2 and "1" or "0") end
  elseif o.kind == "level" then
    t[H(OK.type)] = "SliderBarWithEditBox"
    t[H("ea4f419cc129e9e6")] = 1; t[H("914593b1fcd3cc98")] = topLevel
    t[H("088a01d1c318c8ac")] = 1; t[H("a4b76d37c317bf49")] = 1; t[H("92bde76887ce454b")] = 0
    t[H(OK.value)] = function(c) return (tonumber(getDvar(DV_RANK)) or 0) + 1 end
    t[H(OK.action)] = function(c, v) setLevel(tonumber(v) or 1) end
  elseif o.kind == "prestige" then
    t[H(OK.type)] = "Dropdown"; t[H(OK.labels)] = o.values
    t[H(OK.value)] = function(c) return math.min((tonumber(getDvar(DV_PRESTIGE)) or 0) + 1, #o.values) end
    t[H(OK.action)] = function(c, v)
      setDvar(DV_PRESTIGE, tostring((v or 1) - 1))
      local lv = (tonumber(getDvar(DV_RANK)) or 0) + 1
      if (v or 1) - 1 >= PRESTIGE_MASTER then lv = math.max(lv, LEVEL_CAP + 1) end
      setLevel(lv)
    end
  else
    if o.dyn then o.dyn(o) end
    local lab = {}
    for i, s in ipairs(o.labels or o.values) do lab[i] = s .. ((o.suffix and s ~= "-") and o.suffix or "") end
    t[H(OK.type)] = "Dropdown"; t[H(OK.labels)] = lab
    if o.kind == "gumset" then
      t[H(OK.value)] = function(c) return gumSetLast end
      t[H(OK.action)] = function(c, v)
        gumSetLast = v
        if v > 1 then gumSetSerial = gumSetSerial + 1; setDvar(o.dv, o.values[v] .. ":" .. gumSetSerial) end
      end
    else
      t[H(OK.value)] = function(c)
        local cur = getDvar(o.dv)
        for i, s in ipairs(o.values) do if s == cur then return i end end
        return 1
      end
      t[H(OK.action)] = function(c, v)
        local val = o.values[v] or o.values[1]
        setDvar(o.dv, val)
        if o.create and getDvar(o.dv) ~= val then exec("set " .. o.create .. " " .. val) end
        if o.after then o.after() end
      end
    end
  end
  return autoXHash(t)
end
local dbgById, dbgHooks = nil, {}
local function hookDebugOptions()
  local ok, e = pcall(function()
    local O = rawget(_G, "OPTIONS")
    if type(O) ~= "table" or type(O.TabIds) ~= "table" or O.TabIds.DEBUG == nil then return end
    if not dbgById then
      dbgById = {}
      for _, o in ipairs(DBG_OPTS) do dbgById[H(o.id, 3)] = o end
    end
    local function wrap(hex, make)
      local k = H(hex); local cur = O[k]
      if type(cur) ~= "function" or cur == dbgHooks[hex] then return end
      dbgHooks[hex] = make(cur); O[k] = dbgHooks[hex]
    end
    wrap("48ae2d737a67eea6", function() return function() return true end end)
    wrap("e7686f7a9907efd8", function(orig) return function(sb, ...)
      local o = sb ~= nil and dbgById[sb]
      if o then return dbgOptionData(o) end
      return orig(sb, ...)
    end end)
    wrap("9f6c4b08602983fb", function(orig) return function(sb, c, ...)
      local o = sb ~= nil and dbgById[sb]
      if o then return dbgOptionData(o) end
      return orig(sb, c, ...)
    end end)
    wrap("7bf7f57679e8d050", function(orig) return function(tab, c, idx, ...)
      if not (type(tab) == "table" and tab[H(OK.id)] == O.TabIds.DEBUG) then return orig(tab, c, idx, ...) end
      local okS, secs = pcall(function()
        local stock = orig(tab, c)
        local s1 = stock and stock[1]
        local g1 = s1 and s1[H(OK.list)] and s1[H(OK.list)][1]
        local items = {}
        for _, o in ipairs(DBG_OPTS) do items[#items + 1] = autoXHash({ [H(OK.sb)] = H(o.id, 3) }) end
        local dead = tostring(H(DEAD_UNLOCK_ALL, 3))
        if g1 then
          for _, it in ipairs(g1[H(OK.list)] or {}) do
            local sb = it[H(OK.sb)]
            if tostring(sb) ~= dead then items[#items + 1] = autoXHash({ [H(OK.sb)] = sb }) end
          end
        end
        local group = autoXHash({ [H(OK.name)] = g1 and g1[H(OK.name)], [H(OK.list)] = items })
        return { autoXHash({ [H(OK.name)] = s1 and s1[H(OK.name)], [H(OK.autoId)] = (s1 and s1[H(OK.autoId)]) or "debug",
          [H(OK.list)] = { group } }) }
      end)
      if not okS then L("debug options err " .. tostring(secs)); return orig(tab, c, idx, ...) end
      if idx then return secs[idx] and secs[idx][H(OK.list)] end
      return secs
    end end)
  end)
  if not ok then L("debug options hook err " .. tostring(e)) end
end
local OPTIONS_MENUS = { [tostring(H("62fef28ef5004504"))] = true, [tostring(H("8b6bb2344d54f08f"))] = true }

local lobbyWrapped = false
local findMatchKey
local pendingPrivate
local lastPmLog
local frameWrapped = setmetatable({}, { __mode = "k" })
do
  local P=rawget(_G,"KRONOS_MATCH_SELECTION_MS1")
  if type(P)~="table"or P.version~="MS1"then
    P={version="MS1",getters=0,corrections=0}
    rawset(_G,"KRONOS_MATCH_SELECTION_MS1",P)
  end
  local function pack(...)return{n=select("#",...),...}end
  local function call(owner,key,...)
    local f=type(owner)=="table"and owner[H(key)]
    if type(f)~="function"then return nil end
    local ok,value=pcall(f,...)
    if ok then return value end
  end
  function P.authority()
    local k=rawget(_G,"KRONOS_RETAIL_K1")
    local s=rawget(_G,"LUMEN_ZM_LOCAL_START")
    if type(k)~="table"or k.enabled~=true or type(k.inFrontend)~="function"or type(s)~="table"then return nil end
    local ok,front=pcall(k.inFrontend)
    if not ok or front~=true or call(rawget(_G,"GameModesUtils"),"589367a5b3c4aa7f")~=true then return nil end
    if s.phase~="idle"or s.request~=nil or k.nativeResume~=nil then return nil end
    local rs=s.squadsRS1
    if type(rs)~="table"or rs.intent~=nil then return nil end
    local clua=rawget(_G,"CLUA")
    if P.bridgeKey==nil then
      local hash=type(clua)=="table"and clua.PushXHashDvar
      if type(hash)~="function"then return nil end
      local good,key=pcall(hash,"kronos_squad_rs1")
      if not good or key==nil then return nil end
      P.bridgeKey=key
    end
    local text=call(rawget(_G,"Dvar"),"254084d7ca2317bb",P.bridgeKey)
    if type(text)~="string"then return nil end
    if text~=P.bridgeText then
      P.bridgeText=text;P.bridge=nil
      local sequence,pending,result,members,ready=text:match("^rs1:(%x%x%x%x%x%x%x%x):([01]):([0-3]):(%x%x%x%x%x%x%x%x):(%x%x%x%x%x%x%x%x)$")
      if not sequence then sequence,pending,result,members,ready=text:match("^rp2:(%x%x%x%x%x%x%x%x):([01]):([0-3]):(%x%x%x%x%x%x%x%x):(%x%x%x%x%x%x%x%x):(%x%x%x%x%x%x%x%x):(%x%x%x%x%x%x%x%x)$")end
      if sequence then
        sequence,members,ready=tonumber(sequence,16),tonumber(members,16),tonumber(ready,16)
        if sequence%2==0 and members>0 and members<=256 and ready<=256 then P.bridge={pending=pending=="1"}end
      end
    end
    if not P.bridge or P.bridge.pending then return nil end
    local lobby=rawget(_G,"Lobby")
    if call(lobby,"f63537242f1d48ff")~=true then return nil end
    local host=call(lobby,"96957722ef74f5d2")
    if type(host)=="boolean"then return host end
  end
  function P.install()
    local lobby=rawget(_G,"Lobby")
    local owner=type(lobby)=="table"and lobby[H("9c4f784aa5ce135f")]
    if type(owner)~="table"then return false end
    local key=H("37b1bd26ceaec6a6")
    local old=owner[key]
    if type(old)~="function"then return false end
    if old==P.wrapper then return true end
    local wrapper=function(index,source,filtered,selection,...)
      local ok,get=pcall(function()return source and source.GetValue end)
      if not ok or type(get)~="function"then return old(index,source,filtered,selection,...)end
      local proxy=setmetatable({GetValue=function(self,...)
        local values=pack(get(source,...))
        P.getters=P.getters+1
        if type(values[1])=="boolean"then
          local host=P.authority()
          if type(host)=="boolean"and(not host)~=values[1]then
            values[1]=not host;P.corrections=P.corrections+1
          end
        end
        return unpack(values,1,values.n)
      end},{__index=function(self,k)
        local value=source[k]
        if type(value)=="function"then return function(self,...)return value(source,...)end end
        return value
      end})
      return old(index,proxy,filtered,selection,...)
    end
    owner[key]=wrapper;P.wrapper=wrapper
    
    return true
  end
  function P.attach()
    local ok,active=pcall(P.install)
    local ui=rawget(_G,"LUI")
    local flow=type(ui)=="table"and ui.FlowManager
    local old=type(flow)=="table"and flow.AutomaticNavigationFrame
    if type(old)=="function"and old~=P.frame then
      local wrapper=function(...)
        local values=pack(old(...))
        pcall(P.install)
        return unpack(values,1,values.n)
      end
      flow.AutomaticNavigationFrame=wrapper;P.frame=wrapper
    end
    return ok and active==true
  end
end
local function runPendingPrivate()
  local FM = rawget(_G, "LUI") and LUI.FlowManager
  if type(FM) ~= "table" or frameWrapped[FM] then return end
  local k = "AutomaticNavigationFrame"
  local orig = FM[k]; if type(orig) ~= "function" then return end
  frameWrapped[FM] = true
  FM[k] = function(...)
    local r1, r2 = orig(...)
    pcall(hookMemberOperator)
    if debugLog() then
      local clk = (type(os) == "table" and os.clock) and os.clock() or nil
      if clk and (not lastPmLog or clk - lastPmLog > 2) then
        lastPmLog = clk
        pcall(function()
          local function v(f) local ok, r = pcall(f); return ok and tostring(r) or "err" end
          local LB = rawget(_G, "Lobby")
          local function m(path) return v(function() return LUI.DataSourceInGlobalModel.new(path):GetValue(CTRL) end) end
          L("pm state partyHost=" .. v(function() return LB[H("96957722ef74f5d2")]() end)
            .. " matchHost=" .. v(function() return LB[H("1918cfc897096203")]() end)
            .. " gameHost=" .. m("frontEnd.lobby.areWeGameHost")
            .. " setup=" .. m("frontEnd.lobby.isPrivateMatchLobbySetup")
            .. " partyHostModel=" .. m("frontEnd.lobby.isPrivatePartyHost")
            .. " syslink=" .. v(function() return CONDITIONS[H("9b0deef2e040633c")]() end))
        end)
      end
    end
    if pendingPrivate then
      local c = pendingPrivate; pendingPrivate = nil
      local ok, e = pcall(PLAY_MENU[H("8d6c500994a5cc9a")], nil, c)
      L("find a match -> private match ok=" .. tostring(ok) .. " err=" .. tostring(e))
    end
    return r1, r2
  end
end
local function findMatchToPrivate(btn, c)
  if getDvar(DV_GT):match("^zm") then return end
  runPendingPrivate()
  pcall(function()
    local set = btn.registerEventHandler or btn.addEventHandler
    set(btn, H("e7eefe998522ec88"), function()
      L("find a match clicked")
      pendingPrivate = c
      return true
    end)
    L("find a match button opens private match")
  end)
end
do
  local RPC, published = "0dd030aa00ea69cc", nil
  local function clean(s)
    return type(s) == "string" and s:gsub("[\t\r\n]", " ") or ""
  end
  function KRONOS_RETAIL_K1.publishPresence()
    if mapMode() ~= "mp" then return end
    local map, gt = getDvar(DV_MAP), getDvar(DV_GT)
    local id = map .. "\t" .. gt
    if id == published then return end
    local ok, mode, name = pcall(function()
      return GameType[H("615ea1db2da9249a")](), MapInfo[H("5c034961620dbc3c")](map)
    end)
    mode, name = clean(mode), clean(name)
    if not ok or mode == "" or name == "" then return end
    published = id
    setDvar(RPC, id .. "\t" .. mode .. "\t" .. name)
  end
end
local hudThemes = (function()
  local T = {}
  T.THEMES = KRONOS.hud.themes
  local function refOf(t)
    if t.ref == nil then t.ref = H(t.refHex, 4) end
    return t.ref
  end
  local K_THEME, K_LOOT, K_NAME = H("9137a84365526f04"), H("8028887f70bf5eba"), H("c4bcadba8e631b86")
  local K_IMAGE, K_UNLOCK, K_GETNAME = H("2ab612888528489a"), H("0303083a60947f08"), H("9ae1e225e2dd2df4")
  local K_DESC = H("0cc44970c8397929")
  local K_GSB = H("f06093d047200548")
  local K_LIST, K_BYFIELD, K_ID = H("32f1961b503c019d"), H("0bbd1f110b4fb37d"), H("3db314f9e32f3485")
  local defaultRef, gsb = nil, nil
  local capturing, captured = false, nil
  local fakes = {}
  local mine = setmetatable({}, { __mode = "k" })
  local function same(a, b) return a ~= nil and b ~= nil and tostring(a) == tostring(b) end
  local function byId(id)
    for _, t in ipairs(T.THEMES) do if t.id == id then return t end end
  end
  local function byRef(ref)
    for _, t in ipairs(T.THEMES) do if same(ref, refOf(t)) then return t end end
  end
  local function isFake(b)
    if b == nil then return false end
    for _, f in pairs(fakes) do if rawequal(b, f) then return true end end
    return type(b) == "table" and byId(b[K_LOOT]) ~= nil
  end
  local function append(list)
    if type(list) ~= "table" then return list end
    local out, entries = {}, {}
    for i = 1, #list do
      local e = list[i]
      if type(e) == "table" and not defaultRef then defaultRef = e[K_THEME] end
      out[i] = e
    end
    for _, t in ipairs(T.THEMES) do
      local entry = { [K_THEME] = refOf(t), [K_ID] = t.id }
      entries[#entries + 1] = entry
      out[#out + 1] = entry
    end
    out[K_BYFIELD] = function(_, field, ...)
      local m = list[K_BYFIELD](list, field, ...)
      local res = {}
      pcall(function() for k, v in pairs(m) do res[k] = v end end)
      if m ~= nil then setmetatable(res, { __index = m }) end
      for _, entry in ipairs(entries) do
        if entry[field] ~= nil then res[entry[field]] = entry end
      end
      return res
    end
    return out
  end
  local function fakeBundle(t)
    if fakes[t.id] then return fakes[t.id] end
    local base = defaultRef and gsb(defaultRef)
    if type(base) ~= "table" then return nil end
    local b = {}
    setmetatable(b, { __index = function(_, k)
      local v = base[k]
      if type(v) ~= "function" then return v end
      return function(self, ...)
        if rawequal(self, b) then return v(base, ...) end
        return v(self, ...)
      end
    end })
    b[K_LOOT] = t.id
    b[K_NAME] = t.name
    b[K_DESC] = t.desc or ""
    b[K_IMAGE] = H("057043a98ecb7cdd", 3)
    b[K_UNLOCK] = nil
    b[K_GETNAME] = function() return refOf(t) end
    fakes[t.id] = b
    return b
  end
  local function wrap(tbl, key, make)
    local orig = type(tbl) == "table" and tbl[key]
    if type(orig) ~= "function" or mine[orig] then return false end
    local w = make(orig)
    mine[w] = true
    tbl[key] = w
    return true
  end
  local function listWrap(orig)
    return function(...)
      local r = orig(...)
      local ok, out = pcall(append, r)
      if not ok then return r end
      return out
    end
  end
  local function ownedWrap(orig)
    return function(a, b, ...)
      if isFake(a) or isFake(b) or byId(a) or byId(b) then return true end
      return orig(a, b, ...)
    end
  end
  T.install = function()
    local G, HE, LO = rawget(_G, "GAMEMODE_SCRIPTBUNDLE_UTILS"), rawget(_G, "HUDEDITOR"), rawget(_G, "LOOT")
    local n = 0
    if not gsb and wrap(Engine, K_GSB, function(orig)
      gsb = orig
      return function(ref, ...)
        if capturing and captured == nil then captured = ref end
        local t = byRef(ref)
        if t then
          local ok, b = pcall(fakeBundle, t)
          return ok and b or nil
        end
        return gsb(ref, ...)
      end
    end) then n = n + 1 end
    if wrap(G, K_LIST, listWrap) then n = n + 1 end
    if wrap(HE, H("db1be56cbbe0bb56"), ownedWrap) then n = n + 1 end
    if wrap(HE, H("62838e4a8a47483f"), ownedWrap) then n = n + 1 end
    if wrap(LO, H("849c84827a5b974e"), ownedWrap) then n = n + 1 end
    if n > 0 then
      if not defaultRef and type(G) == "table" then pcall(function() G[K_LIST]() end) end
      L("theme: bo3 hud theme hooks (" .. n .. ")")
    end
  end
  T.capture = function(f, ...)
    capturing, captured = true, nil
    local r = { pcall(f, ...) }
    capturing = false
    if captured ~= nil then T.applied = byRef(captured) or false end
    return r
  end
  T.stored = function(ctrl)
    ctrl = ctrl or CTRL
    local HE = rawget(_G, "HUDEDITOR")
    local useOptions = type(HE) == "table" and HE[H("1765ff8e158f7308")]
    if type(useOptions) == "function" and not useOptions() then
      return Engine[H("47b17d94988fd5d0")]("appliedhudthemeid_mp", ctrl)
    end
    return OPTIONS[H("08b03778e36f133d")](ctrl, "appliedhudthemeid", false, true)
  end
  T.current = function(ctrl)
    if T.applied ~= nil then return T.applied or nil end
    local ok, v = pcall(T.stored, ctrl)
    return ok and byId(v) or nil
  end
  T.byId = byId
  T.active = function(ctrl) return T.current(ctrl) ~= nil end
  return T
end)()
local perkIcons = (function()
  local P = {}
  local K_FILL, K_HOVER, K_APPLY = H("fa242b00e1652426"), H("4c622eacf3cd9fab"), H("c05a6cb4b61c83f1")
  local K_ROW_LOCKED, K_ROW_NEW, K_ROW_UNLOCK, K_ROW_BUNDLE = H("44b612ba739b38f0"), H("f0f6d92ac60f219f"), H("3f5ec959aa4ca6ce"), H("111dd94498209eab")
  local K_ROW_EQUIPPED = H("6acf854f2b6a81d7")
  local K_NAME, K_IMAGE, K_DESC, K_LOOT = H("c4bcadba8e631b86"), H("2ab612888528489a"), H("0cc44970c8397929"), H("8028887f70bf5eba")
  local KINDS = {
    { label = "PERK ICONS", sets = "b8b090b459d6a818", sel = "53802ac1d1e4a801", root = "perks", loot = 990500, what = "Perk",
      grid = { "ui_icon_perks_zm_juggernaut", "ui_icon_perks_zm_quickrevive", "ui_icon_perks_double_tap", "ui_icon_perks_zm_speedloader",
        "ui_icon_perks_zm_staminup", "ui_icon_perks_zm_phdslider", "ui_icon_perks_zm_deadshot", "ui_icon_perks_zm_mulekick" } },
    { label = "POWER-UP ICONS", sets = "c45cd10046a888a0", sel = "cc175f12f59d7a69", root = "powerups", loot = 990600, what = "Power-up",
      grid = { "sat_ui_hud_zm_powerup_icon_instakill", "sat_ui_hud_zm_powerup_icon_doublepoints", "sat_ui_hud_zm_powerup_icon_firesale" } },
  }
  local mode, hovered = nil, nil
  local mine = setmetatable({}, { __mode = "k" })
  local function sets()
    local out = {}
    for s in tostring(getDvar(mode.sets)):gmatch("[^|]+") do out[#out + 1] = s end
    if #out == 0 then out[1] = "Black Ops 7" end
    return out
  end
  local function current(list)
    local cur = getDvar(mode.sel)
    for i, s in ipairs(list) do if s == cur then return i end end
    return 1
  end
  local function mat(n) return RegisterMaterial(CLUA.PushXHashAsset(n)) end
  local native
  local function nativeBundle()
    if native == nil then
      native = false
      pcall(function()
        local l = GAMEMODE_SCRIPTBUNDLE_UTILS[H("32f1961b503c019d")]()
        native = Engine[H("f06093d047200548")](l[1][H("9137a84365526f04")]) or false
      end)
    end
    return native or nil
  end
  local function imageFor(icon)
    local nb = nativeBundle()
    local nat = nb and nb[K_IMAGE]
    if type(nat) == "string" then return icon end
    local cands = { mat(icon), CLUA.PushXHashAsset(icon) }
    for _, c in ipairs(cands) do
      if c ~= nil and type(c) == type(nat) and tostring(c):sub(1, 9) == tostring(nat):sub(1, 9) then return c end
    end
    return cands[1]
  end
  local function bundleFor(i, name)
    local stem = mode.grid[1]
    if i == 1 then mat(stem) end
    local icon = mode.root .. "/" .. (i == 1 and "default" or name) .. "/" .. stem
    local b = {}
    local nb = nativeBundle()
    if nb then pcall(function() for k, v in pairs(nb) do if type(v) ~= "function" then b[k] = v end end end) end
    b[K_NAME] = name
    b[K_IMAGE] = imageFor(icon)
    b[K_LOOT] = mode.loot + i
    b[K_DESC] = mode.what .. " icons from " .. name .. "."
    if nb then
      local me = tostring(nb)
      for k, v in pairs(b) do if type(v) == "table" and tostring(v) == me then b[k] = b end end
    end
    return b
  end
  local function fill(ctrl)
    local cz = _DataSources[H("3cffc2429205c95e")][H("65bd4931568b0af6")]
    local list = sets()
    local cur = current(list)
    for i, name in ipairs(list) do
      local row = cz[i]
      if row then
        row[K_ROW_EQUIPPED]:SetValue(ctrl, i == cur)
        row[K_ROW_LOCKED]:SetValue(ctrl, false)
        row[K_ROW_NEW]:SetValue(ctrl, false)
        row[K_ROW_UNLOCK]:SetValue(ctrl, "")
        row[K_NAME]:SetValue(ctrl, name)
        row[K_ROW_BUNDLE]:SetValue(ctrl, bundleFor(i, name))
      end
    end
    cz[H("b1e5e28e4479a274")]:SetValue(ctrl, #list)
    rawget(_G, "HUDEDITOR")[H("9de543933e6e703a")][H("581730ca38e4bb91")]:SetValue(ctrl, current(list))
  end
  local function wrap(tbl, key, make)
    local orig = type(tbl) == "table" and tbl[key]
    if type(orig) ~= "function" or mine[orig] then return false end
    local w = make(orig)
    mine[w] = true
    tbl[key] = w
    L("perk icons: hooked " .. tostring(key))
    return true
  end
  local soeView
  local function hideGrids()
    for _, k in ipairs(KINDS) do
      if k.view and k ~= mode then pcall(k.view.root.SetAlpha, k.view.root, 0, 0) end
    end
    if soeView then pcall(soeView.SetAlpha, soeView, 0, 0) end
  end
  local function fillWrap(orig)
    return function(ctrl, ...)
      hideGrids()
      if not mode then return orig(ctrl, ...) end
      local ok, e = pcall(fill, ctrl)
      if not ok then L("perk icons: fill err " .. tostring(e)); return orig(ctrl, ...) end
    end
  end
  local function showPreview(idx)
    hideGrids()
    local grid = mode and mode.view
    if not grid then return end
    local list = sets()
    local name = list[idx or current(list)]
    grid.root:SetAlpha(name and 1 or 0, 0)
    if not name then return end
    local base = mode.root .. "/" .. (name == list[1] and "default" or name) .. "/"
    for i, stem in ipairs(mode.grid) do
      if name == list[1] then mat(stem) end
      pcall(function() grid.icons[i]:setImage(mat(base .. stem), 0) end)
    end
  end
  local function attach(m)
    local root = LUI.UIElement.new()
    root:SetAnchorsAndPosition(0, 1, 0, 1, 1046, 1815, 485, 905)
    local back = LUI.UIImage.new()
    back:SetAnchorsAndPosition(0, 1, 0, 1, 0, 769, 0, 420)
    pcall(function() back:setImage(mat("soe_white"), 0) end)
    back:SetRGB(1316379, 0)
    root:addElement(back)
    local icons = {}
    for i = 1, #mode.grid do
      local e = LUI.UIImage.new()
      local x, y = ((i - 1) % 4) * 192 + 16, math.floor((i - 1) / 4) * 210 + 25
      e:SetAnchorsAndPosition(0, 1, 0, 1, x, x + 160, y, y + 160)
      root:addElement(e)
      icons[i] = e
    end
    m:addElement(root)
    mode.view = { root = root, icons = icons, host = m }
    L("perk icons: preview attached " .. mode.root)
  end
  local GRID_ID = tostring(H("8883a428689368d0"))
  local function hostFrom(btn)
    local p = btn
    for _ = 1, 15 do
      p = p and p:getParent()
      if not p then return nil end
      if tostring(p.id) == GRID_ID or p.SetGridDataSource then return p:getParent() end
    end
  end
  local function ensureGrid(btn)
    local host = hostFrom(btn)
    if host and (not mode.view or mode.view.host ~= host) then attach(host) end
  end
  local function showSoE(btn, idx)
    local row = _DataSources[H("3cffc2429205c95e")][H("65bd4931568b0af6")][idx]
    local b = row and row[K_ROW_BUNDLE]:GetValue(CTRL)
    local t = type(b) == "table" and hudThemes.byId(b[K_LOOT])
    local host = hostFrom(btn)
    if t and host and (not soeView or soeView.host ~= host) then
      soeView = LUI.UIImage.new()
      soeView:SetAnchorsAndPosition(0, 1, 0, 1, 1046, 1815, 485, 905)
      soeView.host = host
      host:addElement(soeView)
    end
    if soeView and t then soeView:setImage(mat(t.preview), 0) end
    if soeView then soeView:SetAlpha(t and 1 or 0, 0) end
  end
  local apply
  local pressHooked = setmetatable({}, { __mode = "k" })
  local function hookPress(btn)
    if pressHooked[btn] then return end
    pressHooked[btn] = true
    btn:addEventHandler(H("e7eefe998522ec88"), function()
      if mode then pcall(apply) end
      return mode and true or nil
    end)
  end
  P.built = function() end
  local function hoverWrap(orig)
    return function(btn, ...)
      local cols = Engine[H("112586a3f4fb490e")]() and 1 or 2
      if not mode then
        local r = orig(btn, ...)
        pcall(showSoE, btn, (btn[H("5e49dd623e25104b")] or 0) * cols + (btn[H("5400ca39603858cb")] or 0) + 1)
        return r
      end
      if not hovered then pcall(fill, CTRL) end
      hovered = (btn[H("5e49dd623e25104b")] or 0) * cols + (btn[H("5400ca39603858cb")] or 0) + 1
      pcall(hookPress, btn)
      pcall(ensureGrid, btn)
      pcall(showPreview, hovered)
    end
  end
  apply = function()
    local name = hovered and sets()[hovered]
    if not name then return end
    setDvar(mode.sel, name)
    L("perk icons: " .. name)
    pcall(fill, CTRL)
    pcall(showPreview, hovered)
  end
  local function applyWrap(orig)
    return function(...)
      if not mode then return orig(...) end
      apply()
    end
  end
  local function is(name, hex) return tostring(name):sub(-#hex) == hex end
  local function addTab(list)
    local themes, layouts
    for _, t in ipairs(list) do
      if t.name == KINDS[1].label then return end
      if is(t.name, "314eaea082efdb88") then themes = t elseif is(t.name, "ecaf6700e27d105") then layouts = t end
    end
    if not themes or not layouts or type(themes.focusFunction) ~= "function" then return end
    local show = themes.focusFunction
    for _, t in ipairs(list) do
      local f = t.focusFunction
      if type(f) == "function" then t.focusFunction = function(...) mode = nil; return f(...) end end
    end
    for _, k in ipairs(KINDS) do
      list[#list + 1] = { type = themes.type, index = #list + 1, name = k.label, buildCondition = themes.buildCondition,
        useTextWidthBasedSizing = themes.useTextWidthBasedSizing,
        focusFunction = function(...) mode = k; hovered = nil; return show(...) end }
    end
    L("perk icons: tab added")
  end
  local function setTabsWrap(orig)
    return function(self, list, ...)
      pcall(addTab, list)
      return orig(self, list, ...)
    end
  end
  P.install = function()
    wrap(LUI.TabManager, "SetTabs", setTabsWrap)
    local HE = rawget(_G, "HUDEDITOR")
    if type(HE) ~= "table" then return end
    wrap(HE, K_FILL, fillWrap)
    wrap(HE, K_HOVER, hoverWrap)
    wrap(HE, K_APPLY, applyWrap)
  end
  return P
end)()
local zmHud = (function()
  local zmHud = {}
  local SQUAD, PERKS, ROUND = "f34f8750c67ba329", "fb7c1d32eeb344a0", "e7da34cbc8066689"
  local LOADOUT, MINIMAP = "05671cb57eb82497", "c973fead0481b104"
  local GUMLIST, SCOREBOARD = "91ac3e89b457d0b1", "849e44d7e67e2975"
  local TABSMENU, QUEST = "b77b78aaf5b5d1d1", "5985ec6e703283a7"
  local GUMITEM = "2b865f045351bbd5"
  local COMPASS = "56cd14a086232b2f"
  local WHITE, GREY = 16777215, 11842740
  local NEVER = { AddSubscriber = function() end, GetValue = function() return false end }
  local LAYOUT = {
    [PERKS] = { leftAnchor = 0, rightAnchor = 1, topAnchor = 1, bottomAnchor = 0, horizontalOffset = 195, verticalOffset = 39, width = 930, height = 54 },
    [LOADOUT] = { leftAnchor = 0, rightAnchor = 0, topAnchor = 0, bottomAnchor = 0, horizontalOffset = 0, verticalOffset = 0, width = 1920, height = 1080 },
    [MINIMAP] = { buildWhen = NEVER },
  }
  local byKey
  local function layoutFor(name)
    if not byKey then
      byKey = {}
      for hx, o in pairs(LAYOUT) do byKey[tostring(H(hx))] = o end
    end
    return byKey[tostring(name)]
  end
  local function is(t, hx) return tostring(t) == tostring(H(hx)) end
  local addWidgetMine, isEnabledMine, placeMine, applyMine
  local editorOff, rebuilding, waiting, gameplayMenus, hudBuilt = false, false, false, nil, false
  local panels = setmetatable({}, { __mode = "k" })
  local function themeKey(ctrl)
    local t = hudThemes.current(ctrl)
    return t and t.id or 0
  end
  local function builtKey()
    local hud = LUI.HudManager.GetInstance().activeHud
    if not hud then return nil end
    for p in pairs(panels) do
      local e = p
      while e do
        if rawequal(e, hud) then return p.kronosTheme end
        e = e:getParent()
      end
    end
    return 0
  end
  local function openMenus()
    local n = 0
    for _, info in ipairs(Engine[H("3ee6f69fea944b13")]().flowManager.menuInfoStack) do
      if info.menu then n = n + 1 end
    end
    return n
  end
  local function queueRebuild()
    if waiting then return end
    waiting = true
    L("zm hud: theme rebuild queued, menus " .. tostring(openMenus()) .. " gameplay " .. tostring(gameplayMenus))
    local root = rawget(_G, "__kronosHudTimer")
    if not (root and root:getParent()) then
      root = LUI.UIElement.new()
      LUI.GetRoot():addElement(root)
      _G.__kronosHudTimer = root
    end
    local function tick()
      local okM, n = pcall(openMenus)
      if not okM then
        waiting = false
        L("zm hud: menu check err " .. tostring(n))
        return
      end
      if gameplayMenus and n < gameplayMenus then gameplayMenus = n end
      if gameplayMenus and n > gameplayMenus then
        root:Wait(250).onComplete = tick
        return
      end
      waiting = false
      local built = builtKey()
      if rebuilding or built == nil or built == themeKey() then
        L("zm hud: theme rebuild skipped, built " .. tostring(built) .. " now " .. tostring(themeKey()))
        return
      end
      rebuilding = true
      local ok, e = pcall(function() LUI.HudManager.GetInstance():CreateHud() end)
      rebuilding = false
      L("zm hud: theme changed, hud rebuilt " .. tostring(ok) .. " " .. tostring(e) .. " at menus " .. tostring(n))
    end
    root:Wait(250).onComplete = tick
  end
  local function hookAddWidget()
    local HU = rawget(_G, "HUDUtils")
    if type(HU) ~= "table" then return end
    local k = H("c156d9425a4ece68")
    local orig = HU[k]
    if type(orig) ~= "function" or orig == addWidgetMine then return end
    addWidgetMine = function(hud, name, options, ...)
      local o = layoutFor(name)
      if o and type(options) == "table" and mapMode() == "zm" and hudThemes.active() then
        local c = {}
        for key, v in pairs(options) do c[key] = v end
        for key, v in pairs(o) do c[key] = v end
        options = c
      end
      return orig(hud, name, options, ...)
    end
    HU[k] = addWidgetMine
    L("zm hud: AddWidget layout hooked")
  end
  local function hookEditor()
    local HE = rawget(_G, "HUDEDITOR")
    if type(HE) ~= "table" then return end
    local k, kPlace = H("c84c1d7864022eae"), H("1a3a9ed30cc96c4f")
    local orig, place = HE[k], HE[kPlace]
    if type(orig) == "function" and orig ~= isEnabledMine then
      isEnabledMine = function(...)
        if editorOff then return false end
        return orig(...)
      end
      HE[k] = isEnabledMine
    end
    if type(place) == "function" and place ~= placeMine then
      placeMine = function(...)
        if mapMode() ~= "zm" or not hudThemes.active() then return place(...) end
        editorOff = true
        local ok, e = pcall(place, ...)
        editorOff = false
        if not ok then error(e, 0) end
      end
      HE[kPlace] = placeMine
      L("zm hud: HUD editor positions off for bo3 huds")
    end
    local kApply = H("e3f7ea73b883dac7")
    local apply = HE[kApply]
    if type(apply) == "function" and apply ~= applyMine then
      applyMine = function(...)
        if not hudBuilt then
          local r = { pcall(apply, ...) }
          if not r[1] then error(r[2], 0) end
          return unpack(r, 2, table.maxn(r))
        end
        local r = hudThemes.capture(apply, ...)
        if not rebuilding and mapMode() == "zm" then pcall(queueRebuild) end
        if not r[1] then error(r[2], 0) end
        return unpack(r, 2, table.maxn(r))
      end
      HE[kApply] = applyMine
    end
  end
  zmHud.hook = function()
    if KRONOS_RETAIL_K1.deadOps() then return end
    pcall(hookAddWidget)
    pcall(hookEditor)
    pcall(hudThemes.install)
    pcall(perkIcons.install)
  end
  local function buildPerksLeft(orig, t, data, ...)
    local cls = LUI[H("671573e84386c1b7")]
    local new = type(cls) == "table" and cls.new
    if type(new) ~= "function" then return orig(t, data, ...) end
    local set = pcall(function()
      cls.new = function(menu, opts, ...)
        pcall(function()
          opts[H("d1a03e026a4b52c7")][H("51acbd6e0dc3e830")] = Enum[H("b88d11a90acc8165")][H("24b070ada2041cb0")]
        end)
        return new(menu, opts, ...)
      end
    end)
    local r = { pcall(orig, t, data, ...) }
    if set then cls.new = new end
    if not r[1] then error(r[2], 0) end
    return unpack(r, 2, table.maxn(r))
  end
  local function text(font, size, align, rgb)
    local t = LUI.UIStyledText.new()
    t:SetFont(font)
    t:SetFontSize(size * _PT)
    t:SetMinFontSize(size * _PT)
    t:SetWordWrap(false)
    t:SetAlignment(align)
    t:SetRGB(rgb or WHITE, 0)
    t:SetShadowAngle(225, 0)
    t:SetShadowDistance(0.02, 0)
    t:SetShadowSize(0.06, 0)
    t:SetShadowRGB(0, 0)
    t:SetShadowOpacity(0.6, 0)
    return t
  end
  local function gumRoot()
    return _DataSources[H("08f73707b5922e00")][H("da540426d753409c")][H("95ee2f82995715a1")]
  end
  local function value(node, ctrl)
    local ok, v = pcall(function() return node:GetValue(ctrl) end)
    if ok then return v end
  end
  local HIDE_GUM_MENU = false
  local function hudGumsOnActivate(m, ctrl)
    local anchor = m.SetAnchorsAndPosition
    m.SetAnchorsAndPosition = function(self, la, ra, ta, ba, l, r, t, b)
      return anchor(self, la, ra, ta, ba, l, r, (t or 0) - 120, (b or 0) - 120)
    end
    m:SetAnchorsAndPosition(0, 0, 0, 0, 0, 0, 0, 0)
    if not HIDE_GUM_MENU then
      m:SetAlpha(1, 0)
      L("zm hud: gum menu always visible")
      return
    end
    local st = gumRoot()[H("c79f52deef151ec9")]
    local function apply() m:SetAlpha(value(st, ctrl) == 1 and 1 or 0, 150) end
    apply()
    m:SubscribeToModel(st:GetModel(ctrl), apply)
    L("zm hud: gums shown only on activation")
  end
  local function gumItemGlow(m, ctrl)
    local okT, t = pcall(hudThemes.current, ctrl)
    if not okT or not t or not t.gumGlow then return end
    local AMBER = t.gumColor or 16743708
    local g = LUI.UIImage.new()
    g:SetAnchorsAndPosition(0, 1, 0, 1, 70, 395, -14, 77)
    g:setImage(RegisterMaterial(CLUA.PushXHashAsset(t.gumGlow)), 0)
    g:SetRGB(AMBER, 0)
    g:SetAlpha(0, 0)
    local B = rawget(_G, "BLEND_MODE")
    if B then g:SetBlendMode(B.addWithAlpha) end
    local first = m:getFirstChild()
    if first then g:addElementBefore(first) else m:addElement(g) end
    pcall(function() m[H("145c2bcafda159f3")][H("a4a1027212bb6fbc")]:SetRGB(AMBER, 0) end)
    local ok = pcall(function()
      local st = gumRoot()[H("c79f52deef151ec9")]
      local function apply() g:SetAlpha(value(st, ctrl) == 1 and 0.45 or 0, 150) end
      apply()
      m:SubscribeToModel(st:GetModel(ctrl), apply)
    end)
    if not ok then g:SetAlpha(0.45, 0) end
  end
  local function fillGumPacks(ctrl)
    local D = GOBBLEGUM[H("855b556730a34a05")]
    for _, k in ipairs({ "bbb65cfd95508858", "1d31147c3e8c4373", "cbd684c67840a2eb", "a665df9cd614fabb" }) do pcall(D[H(k)], ctrl) end
    local packs = D[H("5423c89aa6a34fc5")](ctrl) or {}
    local root = _DataSources[H("08f73707b5922e00")][H("da540426d753409c")][H("b4d82eeefb96ed8e")]
    for i, pk in ipairs(packs) do
      local pds = root[i]
      pds[H("c4bcadba8e631b86")]:SetValue(ctrl, pk.name)
      for j, ref in ipairs(pk.gum_refs or {}) do
        D[H("e735c918698c0b28")](pds[H("da540426d753409c")][j], ref, ctrl, j)
      end
    end
    return #packs
  end
  local function scoreboardInfo(menu, ctrl)
    local n = fillGumPacks(ctrl)
    local ld = rawget(_G, "LOADOUT")[H("6c551cb02f0d21dd")](ctrl)
    local node = ld and ld.equippedPackIndex
    local idx = node and tonumber(type(node) == "userdata" and node:get() or node)
    if idx == nil then L("zm hud: no equipped gum pack") return end
    local pack = _DataSources[H("08f73707b5922e00")][H("da540426d753409c")][H("b4d82eeefb96ed8e")][idx + 1]
    local w = MenuBuilder.BuildRegisteredType(H("009a50d1c6985c32"), { controllerIndex = ctrl, dataContext = pack })
    w:SetAnchorsAndPosition(0.5, 0.5, 0, 1, -435, 435, 290, 470)
    menu:addElement(w)
    L("zm hud: scoreboard gum pack " .. tostring(idx) .. " of " .. tostring(n))
  end
  local function scoreboardExtras(menu, ctrl)
    local ok, e = pcall(scoreboardInfo, menu, ctrl)
    if not ok then L("zm hud: scoreboard info err " .. tostring(e)) end
  end
  local function lockHidden(e)
    local alpha = e.SetAlpha
    e.SetAlpha = function(self) return alpha(self, 0, 0) end
    e.SetVisible = function() end
    alpha(e, 0, 0)
  end
  local function compassLocation(m)
    local cd = m[H("dd1a75b992b1fd93")]
    local lc = cd and cd[H("02bb694a8a1c1c5e")]
    lockHidden(m)
    if not lc then L("zm hud: no location callout") return end
    local function move()
      local hud = m:getParent()
      if not hud then m:Wait(100).onComplete = move return end
      while hud:getParent() do hud = hud:getParent() end
      lc:RemoveFromParent()
      lc:SetAlignment(0)
      lc:SetAnchorsAndPosition(0, 1, 0, 1, 24, 624, 29, 55)
      local rgb = lc.SetRGB
      lc.SetRGB = function(self) return rgb(self, 16777215, 0) end
      lc:SetRGB()
      hud:addElement(lc)
      L("zm hud: compass hidden, location top left")
    end
    m:Wait(1).onComplete = function()
      local ok, e = pcall(move)
      if not ok then L("zm hud: location move err " .. tostring(e)) end
    end
  end
  local function hideRound(m) m:SetAlpha(0, 0) end
  local function hideSquad(m) m:SetAlpha(0, 0) end
  local questForTab = false
  local function hideQuest(m)
    if questForTab then return end
    -- Blackwater: keep the native Restore Power tracker on the HUD.
    if getDvar(DV_MAP) == "zm_sat_firefly" and getDvar("dddf7dca1a52e591") == "zone_lakefront" then
      pcall(DebugPrint, "k1 bwl quest HUD 0.2.133: native tracker retained")
      return
    end
    local anchor, alpha = m.SetAnchorsAndPosition, m.SetAlpha
    m.SetAnchorsAndPosition = function(self, la, ra, ta, ba, l, r, t, b)
      return anchor(self, la, ra, ta, ba, (l or 0) - 5000, (r or 0) - 5000, t, b)
    end
    m.SetAlpha = function(self) return alpha(self, 0, 0) end
    m:SetAnchorsAndPosition(0, 0, 0, 0, 0, 0, 0, 0)
    m:SetAlpha(0, 0)
    L("zm hud: quest tracker hidden on hud")
  end
  local function showObjective(ref, ctrl)
    local m = ref.menu
    if not ref.panel then
      local p = LUI.UIElement.new()
      p:SetAnchorsAndPosition(0, 0, 0, 0, 0, 0, 0, 0)
      m:addElement(p)
      questForTab = true
      local okq, q = pcall(MenuBuilder.BuildRegisteredType, H(QUEST), { controllerIndex = ctrl })
      questForTab = false
      if not okq then error(q, 0) end
      pcall(ACTIONS.AnimateSequence, q, H("883e2ea4918b7840"))
      pcall(ACTIONS.AnimateSequence, q, H("1a9a6c8e92045d4c"))
      q:SetAnchorsAndPosition(0.5, 0.5, 0, 1, -225, 225, 260, 435)
      q:SetScale(0.6, 0)
      p:addElement(q)
      ref.panel = p
    end
    ref.panel:SetAlpha(1, 0)
  end
  local function buildScoreboardTabs(orig, t, data, ...)
    local TM = LUI.TabManager
    local set = type(TM) == "table" and TM.SetTabs
    if type(set) ~= "function" then return orig(t, data, ...) end
    local ref = {}
    local function hidePanel() if ref.panel then ref.panel:SetAlpha(0, 0) end end
    local function withObjective(self, list, ...)
      pcall(function()
        for _, d in ipairs(list) do
          local f = d.focusFunction
          if type(f) == "function" then d.focusFunction = function(...) hidePanel(); return f(...) end end
        end
        list[#list + 1] = { name = "OBJECTIVE", useTextWidthBasedSizing = true, disabled = false,
          focusFunction = function(el, ctrl, idx, ftype)
            if ftype == FocusType.MenuFlow or not ref.menu then return end
            local m = ref.menu
            pcall(m.HideTacMap, m)
            pcall(m.HideMetaScreen, m)
            pcall(function() m._scoreboardLayer:HideScoreboard() end)
            pcall(function() TAB[H("9e25032400200d33")](m, TAB.CURRENT_ACTIVE_WIDGET) end)
            local ok, e = pcall(showObjective, ref, ctrl)
            if not ok then L("zm hud: objective tab err " .. tostring(e)) end
          end }
      end)
      self.SetTabs = withObjective
      return set(self, list, ...)
    end
    TM.SetTabs = withObjective
    local r = { pcall(orig, t, data, ...) }
    TM.SetTabs = set
    if not r[1] then error(r[2], 0) end
    ref.menu = r[2]
    L("zm hud: objective tab added")
    return unpack(r, 2, table.maxn(r))
  end
  local KINDS = { { PERKS }, { TABSMENU }, { QUEST, hideQuest }, { ROUND, hideRound }, { GUMLIST, hudGumsOnActivate }, { SCOREBOARD, scoreboardExtras },
    { LOADOUT }, { SQUAD, hideSquad }, { GUMITEM, gumItemGlow }, { COMPASS, compassLocation } }
  zmHud.build = function(orig, t, data, ...)
    if KRONOS_RETAIL_K1.deadOps() then return orig(t, data, ...) end
    local kind
    for _, k in ipairs(KINDS) do
      if is(t, k[1]) then kind = k break end
    end
    if not kind or mapMode() ~= "zm" then return orig(t, data, ...) end
    zmHud.hook()
    local okM, n = pcall(openMenus)
    if okM and (gameplayMenus == nil or n < gameplayMenus) then gameplayMenus = n end
    if kind[1] == LOADOUT then
      hudBuilt = true
      local okS, s = pcall(hudThemes.stored, (data and data.controllerIndex) or CTRL)
      L("zm hud: building with stored theme " .. tostring(okS) .. " " .. tostring(s))
    end
    local always = kind[1] == TABSMENU or kind[1] == SCOREBOARD
    if not always and not hudThemes.active((data and data.controllerIndex) or CTRL) then return orig(t, data, ...) end
    if kind[1] == PERKS then return buildPerksLeft(orig, t, data, ...) end
    if kind[1] == TABSMENU then return buildScoreboardTabs(orig, t, data, ...) end
    if kind[1] == LOADOUT then
      local ctrl = (data and data.controllerIndex) or CTRL
      local theme = hudThemes.current(ctrl)
      local ok, p = pcall(theme.build, ctrl, H(LOADOUT))
      if ok and p then
        p.kronosTheme = themeKey(ctrl)
        panels[p] = true
        return p
      end
      L("zm hud: " .. tostring(theme.name) .. " build err " .. tostring(p))
      return orig(t, data, ...)
    end
    local m = orig(t, data, ...)
    if not m then return m end
    local ctrl = (data and data.controllerIndex) or CTRL
    local ok, e = pcall(kind[2], m, ctrl)
    if not ok then L("zm hud: build err " .. tostring(e)) end
    return m
  end
  return zmHud
end)()
local lobbyTabPending, lobbyTab = false, nil
local function wrapLobbyBuild()
  if lobbyWrapped then return end
  local ok, e = pcall(function()
    local MB = rawget(_G, "MenuBuilder"); if type(MB) ~= "table" then return end
    local orig = MB.BuildRegisteredType; if type(orig) ~= "function" then return end
    local lobbyKey = tostring(H("5581b8d8a3324627"))
    findMatchKey = tostring(H("7440db132e41f482"))
    lobbyWrapped = true
    MB.BuildRegisteredType = function(t, data, ...)
      KRONOS_RETAIL_K1.stability.weaponPreview()
      if OPTIONS_MENUS[tostring(t)] then hookDebugOptions() end
      pcall(perkIcons.install)
      pcall(KRONOS_RETAIL_K1.publishPresence)
      camoCutContent()
      local ts = tostring(t)
      if FR_TABS[ts] then frNativeHooks(); FRN.active = true
      elseif FR_OTHER_TABS[ts] then FRN.active = false end
      if ts == lobbyKey then lobbyTabPending = true end
      local m = zmHud.build(orig, t, data, ...)
      if m then pcall(perkIcons.built, t, m) end
      if m and ts == augExtra.detailKey then pcall(augExtra.built, m, data) end
      if m and ts == augExtra.buttonKey then pcall(augExtra.button, m) end
      if m and ts == findMatchKey then findMatchToPrivate(m, (data and data.controllerIndex) or CTRL) end
      if FR_TABS[ts] and m then
        local c = (data and data.controllerIndex) or 0
        frWriteRows(c); frWatchCount(m, c)
      end
      if lobbyTabPending and ts ~= lobbyKey and type(data) == "table" and data.tabIndex ~= nil then
        lobbyTabPending = false; lobbyTab = ts
      end
      if goCmd and m and lobbyTab and ts == lobbyTab then
        local okT, eT = pcall(addStartTile, m, (data and data.controllerIndex) or 0)
        if not okT then L("start tile err " .. tostring(eT)) end
      end
      return m
    end
  end)
  if not ok then L("lobby wrap err " .. tostring(e)) end
end


local ok, err = pcall(function()
  local orig = origRequire
  local k1, k2 = tostring(H(ZMH)), tostring(H(ZMMAPS))
  rawset(_G, "requirexhash", function(h, ...)
    wrapNav()
    forceSaveAndQuit()
    local t = tostring(h)
    if not KRONOS_RETAIL_K1.enabled and t == k1 then register(ZMH, modesData); return true end
    if not KRONOS_RETAIL_K1.enabled and t == k2 then register(ZMMAPS, mapsData); return true end
    local r1, r2, r3 = orig(h, ...)
    KRONOS_RETAIL_K1.stability.season()
    KRONOS_RETAIL_K1.stability.historyCondition()
    forceSaveAndQuit()
    guardGobbleInit()
    offlineTextEntry()
    bonusAugmentSlot()
    augExtra.hook()
    localProgressionXP()
    watchRankUps()
    localUtcTime()
    localChallenges()
    localDailies()
    localWeaponPrestige()
    syncIntel(CTRL)
    camoCutContent()
    enableWonderClass()
    freeAttachments()
    weaponCamos()
    gameLeaderboards()
    localCombatRecord()
    hookEndGame()
    zmHud.hook()
    wrapLobbyBuild()
    keepWeaponsTab()
    hookDebugOptions()
    frNativeHooks()
    pcall(function() rawget(_G, "__kronosBo6Start")() end)
    return r1, r2, r3
  end)
end)
L("requirexhash hook ok=" .. tostring(ok) .. " err=" .. tostring(err))
pcall(function()
  local oreq = rawget(_G, "require")
  if type(oreq) ~= "function" then return end
  rawset(_G, "require", function(...)
    local r = { oreq(...) }
    KRONOS_RETAIL_K1.stability.historyCondition()
    pcall(function() KRONOS_MATCH_SELECTION_MS1.attach() end)
    localChallenges()
    localDailies()
    localWeaponPrestige()
    camoCutContent()
    enableWonderClass()
    freeAttachments()
    weaponCamos()
    gameLeaderboards()
    frNativeHooks()
    pcall(function() rawget(_G, "__kronosBo6Start")() end)
    hookEndGame()
    pcall(hudThemes.install)
    pcall(perkIcons.install)
    return unpack(r)
  end)
end)
pcall(function()
  local orq = rawget(_G, "requireUnlessHotload")
  if type(orq) ~= "function" then return end
  rawset(_G, "requireUnlessHotload", function(...)
    local r = { orq(...) }
    KRONOS_RETAIL_K1.stability.historyCondition()
    pcall(function() KRONOS_MATCH_SELECTION_MS1.attach() end)
    pcall(hudThemes.install)
    pcall(perkIcons.install)
    return unpack(r)
  end)
end)
hookDebugOptions()
pcall(function() KRONOS_MATCH_SELECTION_MS1.attach() end)

end
local __ld = loadstring or load
local __f = assert(__ld(__ORIG, "=ui/LUIFPSCounter.lua"))
return __f(unpack(__ARGS))
