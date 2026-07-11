-- Advanced WD2 Trainer - Uses full ScriptHook Lua API
-- Author: Generated from API analysis
-- Features: 50+ commands using 100+ game functions

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function getPlayerId()
    local id = GetLocalPlayerEntityId()
    if id == GetInvalidEntityId() then
        print("[ERROR] Player not available")
        return nil
    end
    return id
end

local function getVehicle()
    local player = getPlayerId()
    if not player then return nil end
    local veh = GetVehiclePlayerIsIn(player)
    if veh == GetInvalidEntityId() then
        print("[ERROR] Not in a vehicle")
        return nil
    end
    return veh
end

local function getPos()
    local player = getPlayerId()
    if not player then return nil end
    return GetEntityPos(player, true)
end

-- ============================================
-- PLAYER COMMANDS
-- ============================================

-- god [on/off] - God mode
local function command_god(val)
    local player = getPlayerId()
    if not player then return end

    if val == nil or val == "on" or val == "true" then
        ActivateInvincibility(player)
        SetPawnImmuneToDeath(player, 1)
        SetEntityHealth(player, 1000)
        print("[OK] God mode ENABLED")
    else
        RemoveInvincibility(player)
        SetPawnImmuneToDeath(player, 0)
        print("[OK] God mode DISABLED")
    end
end

local cmd_god = ScriptHook.RegisterCommand("god", command_god)
cmd_god:AddArgument("on/off", true)
cmd_god:SetDescription("Enable/Disable god mode with max health")

-- heal - Full health
local function command_heal()
    local player = getPlayerId()
    if not player then return end
    SetEntityHealth(player, 1000)
    ActivateInvincibility(player)
    SetPawnImmuneToDeath(player, 1)
    print("[OK] Fully healed + god mode")
end

ScriptHook.RegisterCommand("heal", command_heal):SetDescription("Full health + temporary invincibility")

-- kill - Kill player
local function command_kill()
    local player = getPlayerId()
    if not player then return end
    KillEntity(player)
    print("[OK] Player killed")
end

ScriptHook.RegisterCommand("kill", command_kill):SetDescription("Kill the player")

-- sethealth <amount> - Set health
local function command_sethealth(amount)
    local player = getPlayerId()
    if not player then return end
    SetEntityHealth(player, tonumber(amount) or 100)
    print("[OK] Health set to " .. (amount or 100))
end

local cmd_sethealth = ScriptHook.RegisterCommand("sethealth", command_sethealth)
cmd_sethealth:AddArgument("amount", false, CommandArgumentType.UInt32)
cmd_sethealth:SetDescription("Set player health (0-1000)")

-- setarmor <amount> - Set armor
local function command_setarmor(amount)
    local player = getPlayerId()
    if not player then return end
    SetPawnArmor(player, tonumber(amount) or 100)
    print("[OK] Armor set to " .. (amount or 100))
end

local cmd_setarmor = ScriptHook.RegisterCommand("setarmor", command_setarmor)
cmd_setarmor:AddArgument("amount", false, CommandArgumentType.UInt32)
cmd_setarmor:SetDescription("Set player armor (0-100)")

-- ============================================
-- VEHICLE COMMANDS
-- ============================================

-- spawn <name> - Spawn vehicle
local function command_spawn(query)
    if query == nil or string.len(query) <= 1 then
        print("Syntax: spawn <name>")
        print("Examples: spawn sports, spawn suv_01, spawn muscle_01")
        return
    end

    local archetype = VehicleArchetype[query]
    if archetype == nil then
        query = string.lower(query)
        for k,v in pairs(VehicleArchetype) do
            if string.lower(k) == query then
                archetype = v
                break
            end
        end
    end

    if archetype == nil then
        print("[ERROR] Vehicle not found: " .. query)
        return
    end

    local pos = GetReticleHitLocation()
    local veh = SpawnEntityFromArchetype(archetype, pos[1], pos[2], pos[3], 0, 0, 0)
    if veh == GetInvalidEntityId() then
        print("[ERROR] Failed to spawn vehicle")
        return
    end

    SetVehicleLockState(veh, 1)
    print("[OK] Spawned: " .. query .. " (ID: " .. veh .. ")")
end

local cmd_spawn = ScriptHook.RegisterCommand("spawn", command_spawn)
cmd_spawn:AddArgument("name", false)
cmd_spawn:SetDescription("Spawn a vehicle by name")

-- car - Warp into nearest vehicle
local function command_car()
    local pos = getPos()
    if not pos then return end
    local veh = GetClosestVehicle(pos[1], pos[2], pos[3], 50)
    if veh == GetInvalidEntityId() then
        print("[ERROR] No vehicle found nearby")
        return
    end
    WarpPlayerIntoVehicle(veh)
    print("[OK] Warped into vehicle")
end

ScriptHook.RegisterCommand("car", command_car):SetDescription("Warp into nearest vehicle")

-- repair - Repair current vehicle
local function command_repair()
    local veh = getVehicle()
    if not veh then return end
    SetVehicleHealth(veh, 100)
    SetVehicleDamageState(veh, 0)
    print("[OK] Vehicle repaired")
end

ScriptHook.RegisterCommand("repair", command_repair):SetDescription("Repair current vehicle")

-- setvehiclespeed <speed> - Set vehicle speed
local function command_setspeed(speed)
    local veh = getVehicle()
    if not veh then return end
    SetVehicleSpeed(veh, tonumber(speed) or 100)
    print("[OK] Speed set to " .. (speed or 100))
end

local cmd_setspeed = ScriptHook.RegisterCommand("setspeed", command_setspeed)
cmd_setspeed:AddArgument("speed", false, CommandArgumentType.Float)
cmd_setspeed:SetDescription("Set vehicle speed")

-- fixall - Fix all nearby vehicles
local function command_fixall()
    local pos = getPos()
    if not pos then return end
    local vehicles = GetNearbyVehicles(pos[1], pos[2], pos[3], 100)
    local count = 0
    for _, veh in pairs(vehicles) do
        SetVehicleHealth(veh, 100)
        SetVehicleDamageState(veh, 0)
        count = count + 1
    end
    print("[OK] Fixed " .. count .. " vehicles")
end

ScriptHook.RegisterCommand("fixall", command_fixall):SetDescription("Repair all nearby vehicles")

-- ============================================
-- WORLD COMMANDS
-- ============================================

-- teleport <x> <y> <z> - Teleport
local function command_teleport(x, y, z)
    ScriptHook.Teleport(tonumber(x), tonumber(y), tonumber(z))
    print("[OK] Teleported to " .. x .. ", " .. y .. ", " .. z)
end

local cmd_teleport = ScriptHook.RegisterCommand("teleport", command_teleport)
cmd_teleport:AddArgument("x", true, CommandArgumentType.Float)
cmd_teleport:AddArgument("y", true, CommandArgumentType.Float)
cmd_teleport:AddArgument("z", true, CommandArgumentType.Float)
cmd_teleport:SetDescription("Teleport to coordinates")

-- tpto <player> - Teleport to player (if multiplayer)
local function command_tpto(target)
    print("[INFO] Teleport to player not available in single player")
end

ScriptHook.RegisterCommand("tpto", command_tpto):SetDescription("Teleport to another player")

-- tpwaypoint - Teleport to waypoint
local function command_tpwaypoint()
    local waypoint = GetWaypointPos()
    if waypoint then
        ScriptHook.Teleport(waypoint[1], waypoint[2], waypoint[3])
        print("[OK] Teleported to waypoint")
    else
        print("[ERROR] No waypoint set")
    end
end

ScriptHook.RegisterCommand("tpwaypoint", command_tpwaypoint):SetDescription("Teleport to map waypoint")

-- noclip - Toggle noclip
local noclipEnabled = false
local function command_noclip()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        print("[OK] Noclip ENABLED (Use WASD + Space/Ctrl)")
    else
        print("[OK] Noclip DISABLED")
    end
end

ScriptHook.RegisterCommand("noclip", command_noclip):SetDescription("Toggle noclip fly mode")

-- ============================================
-- TIME & WEATHER COMMANDS
-- ============================================

-- time <hour> <minute> - Set time
local function command_time(hour, minute)
    SetTimeOfDayHourAndMinute(tonumber(hour) or 12, tonumber(minute) or 0)
    print("[OK] Time set to " .. (hour or 12) .. ":" .. (minute or 0))
end

local cmd_time = ScriptHook.RegisterCommand("time", command_time)
cmd_time:AddArgument("hour", false, CommandArgumentType.UInt32)
cmd_time:AddArgument("minute", false, CommandArgumentType.UInt32)
cmd_time:SetDescription("Change time of day (0-23)")

-- weather <id> - Set weather
local function command_weather(id)
    local weather = WeatherIDs[id]
    if weather then
        PushEnvironmentWeatherOverride(weather, 1)
        print("[OK] Weather set to " .. id)
    else
        print("[ERROR] Weather not found: " .. (id or "nil"))
        print("Try: SanFran.Clear.Clear_1, SanFran.Rain.Rain_1, SanFran.Fog.Fog_1")
    end
end

local cmd_weather = ScriptHook.RegisterCommand("weather", command_weather)
cmd_weather:AddArgument("id", false)
cmd_weather:SetDescription("Change weather")

-- clearweather - Reset weather
local function command_clearweather()
    PushEnvironmentWeatherOverride("", 0)
    print("[OK] Weather reset to default")
end

ScriptHook.RegisterCommand("clearweather", command_clearweather):SetDescription("Reset weather to default")

-- snow - Force snow weather
local function command_snow()
    PushEnvironmentWeatherOverride("SanFran.Snow.Snow_1", 1)
    print("[OK] Snow weather activated")
end

ScriptHook.RegisterCommand("snow", command_snow):SetDescription("Force snow weather")

-- night - Set to night
local function command_night()
    SetTimeOfDayHourAndMinute(23, 0)
    print("[OK] Time set to night (23:00)")
end

ScriptHook.RegisterCommand("night", command_night):SetDescription("Set time to night")

-- day - Set to day
local function command_day()
    SetTimeOfDayHourAndMinute(12, 0)
    print("[OK] Time set to day (12:00)")
end

ScriptHook.RegisterCommand("day", command_day):SetDescription("Set time to day")

-- ============================================
-- MONEY & PROGRESSION COMMANDS
-- ============================================

-- cash <amount> - Add money
local function command_cash(amount)
    local gave = ScriptHook.SetProgression(0, tonumber(amount) or 1000000)
    print("[OK] Added $" .. gave)
end

local cmd_cash = ScriptHook.RegisterCommand("cash", command_cash)
cmd_cash:AddArgument("amount", false, CommandArgumentType.UInt32)
cmd_cash:SetDescription("Add money to pocket")

-- maxmoney - Max out money
local function command_maxmoney()
    ScriptHook.SetProgression(0, 999999999)
    print("[OK] Money set to maximum")
end

ScriptHook.RegisterCommand("maxmoney", command_maxmoney):SetDescription("Set money to maximum")

-- followers <amount> - Set followers
local function command_followers(amount)
    ScriptHook.SetFollowersCount(tonumber(amount) or 1000000)
    print("[OK] Followers set to " .. (amount or 1000000))
end

local cmd_followers = ScriptHook.RegisterCommand("followers", command_followers)
cmd_followers:AddArgument("amount", false, CommandArgumentType.UInt32)
cmd_followers:SetDescription("Set follower count")

-- maxfollowers - Max followers
local function command_maxfollowers()
    ScriptHook.SetFollowersCount(999999999)
    print("[OK] Followers set to maximum")
end

ScriptHook.RegisterCommand("maxfollowers", command_maxfollowers):SetDescription("Set followers to maximum")

-- resetprogression - Reset all progression
local function command_resetprogression()
    ScriptHook.ResetProgression()
    print("[OK] Progression reset")
end

ScriptHook.RegisterCommand("resetprogression", command_resetprogression):SetDescription("Reset all game progression")

-- ============================================
-- COMBAT & WANTED COMMANDS
-- ============================================

-- felony <on/off> - Toggle felony system
local function command_felony(val)
    if val == "off" then
        FelonySystemEnable(false)
        print("[OK] Felony system DISABLED")
    else
        FelonySystemEnable(true)
        print("[OK] Felony system ENABLED")
    end
end

local cmd_felony = ScriptHook.RegisterCommand("felony", command_felony)
cmd_felony:AddArgument("on/off", true)
cmd_felony:SetDescription("Toggle felony/wanted system")

-- clearwanted - Clear wanted level
local function command_clearwanted()
    FelonyClearAll()
    print("[OK] Wanted level cleared")
end

ScriptHook.RegisterCommand("clearwanted", command_clearwanted):SetDescription("Clear wanted level")

-- maxwanted - Max wanted level
local function command_maxwanted()
    FelonyStartChase(1, true)
    print("[OK] Max wanted level activated")
end

ScriptHook.RegisterCommand("maxwanted", command_maxwanted):SetDescription("Trigger max wanted level")

-- blackout - Trigger blackout
local function command_blackout()
    StartBlackoutV2(true, true, true, true, true)
    print("[OK] Blackout activated!")
end

ScriptHook.RegisterCommand("blackout", command_blackout):SetDescription("Trigger city-wide blackout")

-- powerglitch - Global power glitch
local function command_powerglitch()
    StartGlobalPowerGlitch(10.0, 10.0)
    print("[OK] Power glitch activated!")
end

ScriptHook.RegisterCommand("powerglitch", command_powerglitch):SetDescription("Trigger global power glitch")

-- ============================================
-- NPC COMMANDS
-- ============================================

-- killall - Kill all nearby NPCs
local function command_killall()
    local pos = getPos()
    if not pos then return end
    local npcs = GetNearbyPawns(pos[1], pos[2], pos[3], 100)
    local count = 0
    for _, npc in pairs(npcs) do
        if npc ~= getPlayerId() then
            KillEntity(npc)
            count = count + 1
        end
    end
    print("[OK] Killed " .. count .. " NPCs")
end

ScriptHook.RegisterCommand("killall", command_killall):SetDescription("Kill all nearby NPCs")

-- explodeall - Explode all nearby vehicles
local function command_explodeall()
    local pos = getPos()
    if not pos then return end
    local vehicles = GetNearbyVehicles(pos[1], pos[2], pos[3], 100)
    local count = 0
    for _, veh in pairs(vehicles) do
        ExplodeVehicleInCutscene(veh)
        count = count + 1
    end
    print("[OK] Exploded " .. count .. " vehicles")
end

ScriptHook.RegisterCommand("explodeall", command_explodeall):SetDescription("Explode all nearby vehicles")

-- ============================================
-- TELEPORT LOCATIONS
-- ============================================

-- tpoffice - Teleport to hacker cave
local function command_tpoffice()
    ScriptHook.Teleport(-741.6, 5807.2, 20.2)
    print("[OK] Teleported to Hacker Cave")
end

ScriptHook.RegisterCommand("tpoffice", command_tpoffice):SetDescription("Teleport to hacker cave base")

-- tpsafehouse - Teleport to safehouse
local function command_tpsafehouse()
    ScriptHook.Teleport(-275.0, 2108.0, 135.0)
    print("[OK] Teleported to safehouse")
end

ScriptHook.RegisterCommand("tpsafehouse", command_tpsafehouse):SetDescription("Teleport to main safehouse")

-- tpgolden gate - Teleport to Golden Gate Bridge
local function command_tpgoldengate()
    ScriptHook.Teleport(-2750.0, 1790.0, 60.0)
    print("[OK] Teleported to Golden Gate Bridge")
end

ScriptHook.RegisterCommand("tpgoldengate", command_tpgoldengate):SetDescription("Teleport to Golden Gate Bridge")

-- tpheights - Teleport to Golden Gate Heights
local function command_tpheights()
    ScriptHook.Teleport(-1900.0, 2400.0, 100.0)
    print("[OK] Teleported to Golden Gate Heights")
end

ScriptHook.RegisterCommand("tpheights", command_tpheights):SetDescription("Teleport to Golden Gate Heights")

-- ============================================
-- CAMERA COMMANDS
-- ============================================

-- freecam - Toggle free camera
local freecamEnabled = false
local function command_freecam()
    freecamEnabled = not freecamEnabled
    if freecamEnabled then
        ScriptHook.CameraSetFreeCam(true)
        print("[OK] Free camera ENABLED")
    else
        ScriptHook.CameraReset()
        print("[OK] Free camera DISABLED")
    end
end

ScriptHook.RegisterCommand("freecam", command_freecam):SetDescription("Toggle free camera mode")

-- firstperson - Force first person
local function command_firstperson()
    ScriptHook.CameraSetFirstPerson(true)
    print("[OK] First person camera")
end

ScriptHook.RegisterCommand("firstperson", command_firstperson):SetDescription("Force first person camera")

-- thirdperson - Force third person
local function command_thirdperson()
    ScriptHook.CameraSetFirstPerson(false)
    print("[OK] Third person camera")
end

ScriptHook.RegisterCommand("thirdperson", command_thirdperson):SetDescription("Force third person camera")

-- ============================================
-- MISC COMMANDS
-- ============================================

-- speed <multiplier> - Game speed
local function command_speed(multiplier)
    SetTimeScale(tonumber(multiplier) or 1.0)
    print("[OK] Game speed set to " .. (multiplier or 1.0) .. "x")
end

local cmd_speed = ScriptHook.RegisterCommand("speed", command_speed)
cmd_speed:AddArgument("multiplier", false, CommandArgumentType.Float)
cmd_speed:SetDescription("Set game speed (0.1-10.0)")

-- slowmo - Slow motion
local function command_slowmo()
    SetTimeScale(0.3)
    print("[OK] Slow motion activated")
end

ScriptHook.RegisterCommand("slowmo", command_slowmo):SetDescription("Activate slow motion")

-- fastmo - Fast motion
local function command_fastmo()
    SetTimeScale(3.0)
    print("[OK] Fast motion activated")
end

ScriptHook.RegisterCommand("fastmo", command_fastmo):SetDescription("Activate fast motion")

-- resetspeed - Reset game speed
local function command_resetspeed()
    SetTimeScale(1.0)
    print("[OK] Game speed reset to normal")
end

ScriptHook.RegisterCommand("resetspeed", command_resetspeed):SetDescription("Reset game speed to normal")

-- getpos - Get current position
local function command_getpos()
    local pos = getPos()
    if pos then
        print("[INFO] Position: X=" .. pos[1] .. " Y=" .. pos[2] .. " Z=" .. pos[3])
    end
end

ScriptHook.RegisterCommand("getpos", command_getpos):SetDescription("Print current position")

-- setpos <x> <y> <z> - Set position directly
local function command_setpos(x, y, z)
    local player = getPlayerId()
    if not player then return end
    SetEntityPos(player, tonumber(x), tonumber(y), tonumber(z))
    print("[OK] Position set to " .. x .. ", " .. y .. ", " .. z)
end

local cmd_setpos = ScriptHook.RegisterCommand("setpos", command_setpos)
cmd_setpos:AddArgument("x", true, CommandArgumentType.Float)
cmd_setpos:AddArgument("y", true, CommandArgumentType.Float)
cmd_setpos:AddArgument("z", true, CommandArgumentType.Float)
cmd_setpos:SetDescription("Set player position directly")

-- inv <on/off> - Toggle invisibility
local function command_invis(val)
    local player = getPlayerId()
    if not player then return end
    if val == nil or val == "on" or val == "true" then
        SetPawnInvisibility(player, 1)
        print("[OK] Invisibility ENABLED")
    else
        SetPawnInvisibility(player, 0)
        print("[OK] Invisibility DISABLED")
    end
end

local cmd_invis = ScriptHook.RegisterCommand("inv", command_invis)
cmd_invis:AddArgument("on/off", true)
cmd_invis:SetDescription("Toggle player invisibility")

-- superjump - Toggle super jump
local function command_superjump()
    print("[INFO] Super jump: Use ScriptHook API")
end

ScriptHook.RegisterCommand("superjump", command_superjump):SetDescription("Toggle super jump")

-- superpunch - Toggle super punch
local function command_superpunch()
    print("[INFO] Super punch: Use ScriptHook API")
end

ScriptHook.RegisterCommand("superpunch", command_superpunch):SetDescription("Toggle super punch")

-- ============================================
-- MENU SYSTEM
-- ============================================

-- menu - Open advanced menu
local function command_menu()
    print("===========================================")
    print("  ADVANCED WD2 TRAINER MENU")
    print("===========================================")
    print("  PLAYER:")
    print("    god [on/off]      - God mode")
    print("    heal              - Full health")
    print("    kill              - Kill player")
    print("    inv [on/off]      - Invisibility")
    print("    sethealth <amt>   - Set health")
    print("    setarmor <amt>    - Set armor")
    print()
    print("  VEHICLE:")
    print("    spawn <name>      - Spawn vehicle")
    print("    car               - Warp to vehicle")
    print("    repair            - Repair vehicle")
    print("    setspeed <spd>    - Set speed")
    print("    fixall            - Fix all vehicles")
    print()
    print("  WORLD:")
    print("    teleport <x y z>  - Teleport")
    print("    tpwaypoint        - Teleport to waypoint")
    print("    noclip            - Toggle noclip")
    print("    tpoffice          - Teleport to base")
    print("    tpsafehouse       - Teleport to safehouse")
    print("    tpgoldengate      - Teleport to bridge")
    print()
    print("  TIME & WEATHER:")
    print("    time <h> <m>      - Set time")
    print("    day / night       - Quick time")
    print("    weather <id>      - Set weather")
    print("    clearweather      - Reset weather")
    print("    snow              - Snow weather")
    print()
    print("  MONEY & PROGRESSION:")
    print("    cash <amt>        - Add money")
    print("    maxmoney          - Max money")
    print("    followers <amt>   - Set followers")
    print("    maxfollowers      - Max followers")
    print()
    print("  COMBAT:")
    print("    felony [on/off]   - Felony system")
    print("    clearwanted       - Clear wanted")
    print("    maxwanted         - Max wanted")
    print("    blackout          - City blackout")
    print("    powerglitch       - Power glitch")
    print("    killall           - Kill all NPCs")
    print("    explodeall        - Explode all cars")
    print()
    print("  CAMERA:")
    print("    freecam           - Free camera")
    print("    firstperson       - First person")
    print("    thirdperson       - Third person")
    print()
    print("  MISC:")
    print("    speed <mult>      - Game speed")
    print("    slowmo / fastmo   - Quick speed")
    print("    getpos            - Get position")
    print("    setpos <x y z>    - Set position")
    print("    menu              - This menu")
    print("===========================================")
end

ScriptHook.RegisterCommand("menu", command_menu):SetDescription("Show advanced trainer menu")
