y1 = 175 			-- Farm limit down
itemID = 14767 		-- POG seed
amtseed = 17000 	-- Maximum Tree (Usage; UWS)
delayPlant = 40 	-- Planting Delay
delayHarvest = 100 	-- Harvesting Delay
delayUWS = 4000 	-- Delay from use uws to harvest
magplantX = 1		-- First Magplant X 
magplantY = 175 	-- First Magplant Y
delayRecon = 100        -- Delay reconnect
autoSpray = true -- true or false (Usage; Automatically use Ultra World Spray after Planting)
autoPlant = true -- true or false (Usage; Automatically Plants)
autoHarvest = true -- true or false (Usage; Automatically Harvests)
autoGhost = true -- true or false (Usage; Automatically Ghost)

worldName = "" -- Don't Touch --
nowEnable = true -- Don't Touch --
isEnable = false -- Don't Touch --
ghostState = false -- Don't Touch --
wreckWrench = true -- Don't Touch --
changeRemote = false -- Don't Touch --
magplantX = magplantX - 1 -- Don't Touch --
player = GetLocal().name -- Don't Touch --
currentWorld = GetWorld().name -- Don't Touch --

world = "island"        -- Dont Touch!!!
if world == "island" then
ex = 199
ey = y1

function path(x, y, state)
SendPacketRaw(false, {state = state,
px = x,
py = y,
x = x*32,
y = y*32})
end

function h2(x, y, id)
SendPacketRaw(false,{type = 3,
value = id,
px = x,
py = y,
x = x*32,
y= y*32})
end

AddHook("onvariant", "mommy", function(var)
    if var[0] == "OnSDBroadcast" then
        return true
    end
end)

if worldName == "" or worldName == nil then
    worldName = string.upper(GetWorld().name)
end
if GetWorld().name ~= string.upper(worldName) then
    for i = 1, 1 do
        Sleep(4500)
        RequestJoinWorld(worldName)
        Sleep(delayRecon)
    end
end

AddHook("onvariant", "mommy", function(var)
    if var[0] == "OnSDBroadcast" then
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT 5000") then
        return true
    end
    if var[0] == "OnTalkBubble" and var[2]:match("The MAGPLANT 5000 is empty.") then
        changeRemote = true
        return true
    end
    if var[0] == "OnTalkBubble" and var[2]:match("Collected") then
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("add_player_info") then
        if var[1]:find("|290|") then
            ghostState = true
        else
            ghostState = false
        end
        return true
    end
    return false
end)

local function place(id, x, y)
    if GetWorld() == nil then
        return
    end
    pkt = {}
    pkt.type = 3
    pkt.value = id
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    SendPacketRaw(false, pkt)
    Sleep(40)
end

local function punch(x, y)
    if GetWorld() == nil then
        return
    end
    pkt = {}
    pkt.type = 3
    pkt.value = 18
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    SendPacketRaw(false, pkt)
    Sleep(40)
end

local function wrench(x, y)
    if GetWorld() == nil then
        return
    end
    pkt = {}
    pkt.type = 3
    pkt.value = 32
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    SendPacketRaw(false, pkt)
end

local function hold()
    if GetWorld() == nil then
        return
    end
        local pkt = {}
        pkt.type = 0
        pkt.state = 16779296
        SendPacketRaw(pkt)
        Sleep(90)
end

local function isReady(tile)
    if GetWorld() == nil then
        return
    end
    if tile and tile.extra and tile.extra.progress and tile.extra.progress == 1.0 then
        return true
    end
    return false
end

local function findItem(id)
    count = 0
    for _, inv in pairs(GetInventory()) do
        if inv.id == id then
            count = count + inv.amount
        end
    end
    return count
end

local function FormatNumber(num)
    num = math.floor(num + 0.5)
    local formatted = tostring(num)
    local k = 3
    while k < #formatted do
        formatted = formatted:sub(1, #formatted - k) .. "," .. formatted:sub(#formatted - k + 1)
        k = k + 4
    end
    return formatted
end

local function removeColorAndSymbols(str)
    cleanedStr = string.gsub(str, "`(%S)", '')
    cleanedStr = string.gsub(cleanedStr, "`{2}|(~{2})", '')
    return cleanedStr
end
if GetWorld() == nil then
    username = removeColorAndSymbols(player)
else
    username = removeColorAndSymbols(GetLocal().name)
end

--[START WHEN START SCRIPT]-------

for i = 4, 1, -1 do
SendPacket(2,"action|input\n|text|`6[Premium Script By `b@Rebana`6] `4Leaked Script Github: `bfluffyhowl")
Sleep(1000)
end

local function warnText(text)
    text = text
    packet = {}
    packet[0] = "OnAddNotification"
    packet[1] = "interface/atomic_button.rttex"
    packet[2] = text
    packet[3] = "audio/hub_open.wav"
    packet[4] = 0
    SendVariantList(packet)
    return true
end

local function countReady()
    readyTree = 0
    for _, tile in pairs(GetTiles()) do
        if tile.fg == itemID then
            if isReady(GetTile(tile.x, tile.y)) then
                readyTree = readyTree + 1
            end
        end
    end
    return readyTree
end

local function countTree()
    if GetWorld() == nil then
        return
    end

    countTrees = 0
    for _, tile in pairs(GetTiles()) do
        if GetTile(tile.x, tile.y).fg == itemID and not isReady(GetTile(tile.x, tile.y)) then
            countTrees = countTrees + 1
        end
    end
    return countTrees
end

local function cheatSetup()
    if GetWorld() == nil then
        return
    end

    if countTree() >= 1 then
        for _, tile in pairs(GetTiles()) do
            if tile.fg == itemID and GetTile(tile.x, tile.y).collidable then
                FindPath(tile.x, tile.y, 60)
                if nowEnable then
                    Sleep(1000)
                    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autoplace|1\ncheck_gems|1")
                    isEnable = true
                    Sleep(1000)
                end
                if isEnable then
                    break
                end
            end
        end
        nowEnable = false
    end

    if countTree() == 0 then
        for _, tile in pairs(GetTiles()) do
            if tile.fg == 0 and GetTile(tile.x, tile.y).collidable then
                FindPath(tile.x, tile.y, 60)
                place(5640, 0, 0)
                if nowEnable then
                    Sleep(1000)
                    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autoplace|1\ncheck_gems|1")
                    isEnable = true
                    Sleep(1000)
                end
                if isEnable then
                    break
                end
            end
        end
        nowEnable = false
    end
end

local function takeMagplant()
    if findItem(5640) == 0 or changeRemote then
        FindPath(magplantX, magplantY - 1, 60)
        Sleep(100)
        wrench(0, 1)
        Sleep(100)
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. magplantX .."|\ny|".. magplantY .."|\nbuttonClicked|getRemote")
        Sleep(1000)
    end
    if wreckWrench then
        cheatSetup()
    end
    wreckWrench = false
    changeRemote = false
end

local function remoteCheck()
    if GetWorld() == nil then
        return
    else
        if findItem(5640) == 0 or findItem(5640) < 0 then
            Sleep(1000)
            takeMagplant()
            Sleep(1000)
        end
    end
end

local function worldNot()
    if GetWorld().name ~= (worldName:upper()) then
        LogToConsole("`4Disconnected")
        for i = 1, 1 do
            Sleep(5000)
            RequestJoinWorld(worldName)
            Sleep(5000)
            cheatSetup()
        end
        Sleep(delayRecon)
        LogToConsole("`2Reconnected")
    else
        Sleep(delayRecon)
        remoteCheck()
    end
end

local function reconnectPlayer()
    if GetWorld() == nil then
        for i = 1, 1 do
            Sleep(5000)
            RequestJoinWorld(worldName)
            Sleep(5000)
            cheatSetup()
            Sleep(1000)
            nowEnable = true
            isEnable = false
        end
        Sleep(1000)
        remoteCheck()
                Sleep(1000)
        LogToConsole("`2Reconnected")
    else
        if GetWorld().name == (worldName:upper()) then
            Sleep(1000)
            remoteCheck()
            Sleep(1000)
        end
    end
end

local function wrenchMe()
    if GetWorld() == nil then
        Sleep(1000)
        reconnectPlayer()
    else
        SendPacket(2, "action|wrench\n|netid|".. GetLocal().netid)
    end
end

--[ HARVESTING ]-------------------------------------------------------------------

function harvest()
           if autoHarvest then
                for y = ey, 0, -1 do
                    for x = 0, ex, 1 do
                        if isReady(GetTile(x,y)) then
                            path(x, y, 16779296)
                            Sleep(delayHarvest)
                            h2(x, y, 18)
                            Sleep(delayHarvest)
                        end
                        if GetWorld() == nil then
                            Sleep(delayRecon)
                            reconnectPlayer()
                            break
                        end
                    end
                end
    end
end

--[ CHECK MISS HARVEST ]-----------------------------------------------------------

function htantimiss()
        harvest()
        Sleep(1100)
        previousGem = GetPlayerInfo().gems
end

--[ PLANTING ]---------------------------------------------------------------------

local function plant()
    if autoPlant then
        if countTree() < amtseed then
              for y = ey , 0, -1 do
               for x = 0, ex,10 do
                    if GetWorld() == nil then
                        return
                    else
                        if GetTile(x, y).fg == 0  then
                            path(x, y, 32)
                            Sleep(delayPlant)
                            h2(x, y, 5640)
                            Sleep(delayPlant)
                        end
                    end
                    if GetWorld() == nil then
                        Sleep(delayRecon)
                        reconnectPlayer()
                        break
                    end
                    if changeRemote then
                        break
                    end
                end
                if GetWorld() == nil then
                    Sleep(delayRecon)
                    reconnectPlayer()
                    break
                end
                if changeRemote then
                    break
                 end
             end
         end
     end
 end

-- [ CHECK MISS PLANT ]------------------------------------------------------------

local function plantantimiss()
    if autoPlant then
        if countTree() < amtseed then
            for x = ex, 0, -10 do
                for y = ey , 0 do
                    if GetWorld() == nil then
                        return
                    else
                        if GetTile(x, y).fg == 0  then
                            path(x, y, 48)
                            Sleep(delayPlant)
                            h2(x, y, 5640)
                            Sleep(delayPlant)
                        end
                    end
                    if GetWorld() == nil then
                        Sleep(delayRecon)
                        reconnectPlayer()
                        break
                    end
                    if changeRemote then
                        break
                    end
                end
                if GetWorld() == nil then
                    Sleep(delayRecon)
                    reconnectPlayer()
                    break
                end
                if changeRemote then
                    break
                end
             end
         end
     end
end

-- [ FUNCTION UWS ]-----------------------------------------------------------------

function uws()
    if autoSpray then
      if countTree() >= amtseed then
         Sleep(5000)
          SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
        end
    end
end

--[ CHEAT MENU / ABILITY ] ---------------------------------------------------------

ChangeValue("[C] Modfly", true)

function dontdropgems()
    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_gems|1\n")
    Sleep(100)
end
dontdropgems()

--[ WHILE START CICLE ]-------------------------------------------------------------
    while true do
    wrenchMe()
    Sleep(1000)
    if not ghostState then
        Sleep(1000)
        for i = 1, 1 do
            if autoGhost then
                SendPacket(2, "action|input\ntext|/ghost")
                break
            end
        end
    end
    if findItem(5640) == 0 or findItem(5640) < 0 then
        Sleep(1000)
        takeMagplant()
    end
    remoteCheck()
    harvest()
    htantimiss()
    Sleep(1000)
    plant()

     if GetWorld() == nil then
        LogToConsole("`4Disconnected")
        Sleep(delayRecon)
        reconnectPlayer()
        Sleep(delayRecon)
    end

    if GetWorld().name == (worldName:upper()) then
        Sleep(delayRecon)
    else
        LogToConsole("`4Disconnected")
        Sleep(delayRecon)
        worldNot()
        Sleep(delayRecon)
    end

    if changeRemote then
        for i = 1, 1 do
            magplantX = magplantX + 1
        end
        Sleep(100)
        takeMagplant()
        plant()
    end

    if findItem(5640) == 0 or findItem(5640) < 0 then
        Sleep(100)
        takeMagplant()
        plant()
    end

plantantimiss()

     if GetWorld() == nil then
        LogToConsole("`4Disconnected")
        Sleep(delayRecon)
        reconnectPlayer()
        Sleep(delayRecon)
    end

    if GetWorld().name == (worldName:upper()) then
        Sleep(delayRecon)
    else
        LogToConsole("`4Disconnected")
        Sleep(delayRecon)
        worldNot()
        Sleep(delayRecon)
    end

    if changeRemote then
        for i = 1, 1 do
            magplantX = magplantX + 1
        end
        Sleep(100)
        takeMagplant()
        plantantimiss()
    end

    if findItem(5640) == 0 or findItem(5640) < 0 then
        Sleep(100)
        takeMagplant()
        plantantimiss()
    end

    Sleep(1000)
    uws()
    Sleep(100)
    plantantimiss()
    Sleep(2000)
    uws()
    Sleep(delayUWS)
end
end