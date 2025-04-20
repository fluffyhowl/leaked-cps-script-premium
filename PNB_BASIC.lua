takegems = true -- take gems true/false
lonely = false -- lonely true/false
bg = 14


World = GetWorldName() 
if takegems then
dbg = 1
else
dbg = 0
end
if lonely then
lnl = 1
else
lnl = 0
end

EditToggle("Anti Lag", true)
Autoconsume = true
xawal = math.floor(GetLocal().posX/32)
yawal = math.floor(GetLocal().posY/32)

nono = true

function main()
-- FUNCTION
-- FUNCTION FOR COUNTDOWN
function log(str)
LogToConsole("`7[`8Script starting"..str)
end

-- CONSUME
function consum(str)
    pkt = {}
        pkt.type = 3
        pkt.value = str
        pkt.flags = 8390688
        pkt.px = GetLocal().posX//32
        pkt.py = GetLocal().posY//32
        pkt.x = GetLocal().posX
        pkt.y = GetLocal().posY
        SendPacketRaw(false,pkt)
end

-- ONTEXT
function ontext(str)
    on = {}
    on.v0 = "OnTextOverlay"
    on.v1 = str
    SendVariant(on)
end

-- WRENCH
function wrench()
    pkt = {}
    pkt.type = 3
    pkt.value = 32
    pkt.state = 8
    pkt.px = Mag[count].x
    pkt.py = Mag[count].y
    pkt.x = GetLocal().posX
    pkt.y = GetLocal().posY
    SendPacketRaw(false, pkt)
end

-- GETMAG Normal
function GetMagN()
    Mag = {}
    count = 0
    for _, tile in pairs(GetTiles()) do
        if (tile.fg == 5638) and (tile.bg == bg) then
            count = count + 1
            Mag[count] = {x = tile.x, y = tile.y}
        end
    end
end

-- GETMAG Island
function GetMag()
    Mag = {}
    count = 0
    for x = 0, 199 do
        for y = 0, 199 do
            tile = GetTile(x, y)
            if (tile.fg == 5638) and (tile.bg == bg) then
                count = count + 1
                Mag[count] = {x = tile.x, y = tile.y}
            end
        end
    end
end

-- AUTO CHECK ISLAND OR NOT
local status , err = pcall(GetMag)
if not status then
    iorn = "Normal"
Sleep(1000)
    GetMagN()
else
    iorn = "Island"
end

-- CHEATS
function scheat()
    if (cheats == true) and (math.floor(GetLocal().posX/32) == xawal) and (math.floor(GetLocal().posY/32) == yawal) then
        Sleep(1000)
        SendPacket(2,"action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_lonely|"..lnl.."\ncheck_gems|"..dbg.."\n")
        Sleep(1000)
        cheats = false
    end
end

function fmag()
    if FindPath(Mag[count].x , Mag[count].y - 1) == false then
        Sleep(200)
        FindPath(Mag[count].x , Mag[count].y - 1)
        ontext("`cCari Magplant...")
        Sleep(300)
        findmag = false
        takeremote = true
    else
        LogToConsole("`8[ `bError 404 `8]")
        SendVariant({v0 = "OnTalkBubble", v1 = GetLocal().netID, v2 = "`4Jalankan ulang !!!"})
        findmag = false
    end
end

-- TAKE REMOTE
function tremote()
    Sleep(500)
    if (takeremote  == true) then
        if math.floor(GetLocal().posX/32) == Mag[count].x and math.floor(GetLocal().posY/32) == Mag[count].y - 1 then
            Sleep(300)
            wrench()
            Sleep(100)
        if nono == false then
            ontext("`8[ `cSuccess Take Remote `8]")
            SendPacket(2,"action|dialog_return\ndialog_name|magplant_edit\nx|"..Mag[count].x.."|\ny|"..Mag[count].y.."|\nbuttonClicked|getRemote\n\n")
            takeremote = false
        elseif nono == true then
            ontext("`cLoading...")
            nono = false
            takeremote = false
            findmag = true
        end
        else
            ontext("`4Jangan Gerak !!!")
            SendVariant({v0 = "OnTalkBubble", v1 = GetLocal().netID, v2 = "Please Re run the script"})
            takeremote = false
        end
    end
end

-- ADDHOOK
function var(var)
    if var.v1 == "OnConsoleMessage" and var.v2:find("World Locked") then
        findmag = true
        return true
    end
    if var.v1 == "OnConsoleMessage" and var.v2:find("Where would you like to go?") then
        getworld = true
        return true
    end
    if var.v1 == "OnTalkBubble" and var.v3:find("You received a MAGPLANT 5000 Remote.") then
        FindPath(xawal,yawal)
        cheats = true
        return true
    end
    if var.v1 == "OnTalkBubble" and var.v3:find("The MAGPLANT 5000 is empty.") then
        empty = true
        return true
    end
    if var.v1 == "OnDialogRequest" and var.v2:find("The machine is currently empty!") then
        nothing = true
        nono = true
        return true
    end
    if var.v1 == "OnDialogRequest" and var.v2:find("The machine contains") then
        return true
    end
    return false
end

AddHook(var,"OnVariant")

-- START SCRIPT
log("`2 in : `43`7]")
Sleep(1000)
log("`2 in : `42`7]")
Sleep(1000)
log("`2 in : `41`7]")
Sleep(1000)
-- SEND DIALOG
opening = [[
add_label_with_icon|big|`2PNB ADVANCE |left|]] .. 9740 ..[[|
add_spacer|small|
add_textbox|`0Hello `2]]..GetLocal().name..[[ `0Thanks For Buying This Script |left|
add_spacer|small|
add_textbox|`9Script Info & Rules:|left|
add_label_with_icon|small|`0Do not `4Resell `0or `4Share `0My Script|left|7190|
add_label_with_icon|small|`0World Types       : `2]]..iorn..[[|left|3802|
add_label_with_icon|small|`0World Name      : `2]]..World..[[|left|10078|
add_label_with_icon|small|`0Mags Counted  : `2]]..count..[[|left|5638|
add_spacer|small|
end_dialog|itro|Close|                   OKE                   |
]]
s = {}
s.v0 = "OnDialogRequest"
s.v1 = opening
SendVariant(s)
Sleep(3000)
SendPacket(2,"action|input\n|text|`wSCRIPT `cPNB ADVANCE `wBY `0[`9Lantaaa#6854`w]") 
Sleep(3000)
-- WHILE LOOP
fmag()
while true do
    Sleep(2000)
    if count > 0 then
        if (getworld == true) then
            ontext("`8[ `cMasuk ke `8"..World.." `c]")
            SendPacket(3, "action|join_request\nname|"..World.."\ninvitedWorld|0")
            Sleep(2300)
            getworld = false
        end
        if (findmag == true) then
            Sleep(100)
            fmag()
        end
        if (cheats == true) then
            Sleep(100)
            scheat()
        end
        if (takeremote == true) then
            tremote()
            Sleep(500)
        end
        if (empty == true) then
            SendPacket(2,"action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0")
            Sleep(700)
            count = count - 1
            empty = false
            findmag = true
        end
        if (nothing == true) then
            Sleep(400)
            count = count - 1
            nothing = false
            findmag = true
        end
    else
        ontext("All magplant empety")
    end
end
end
main()