World = "BFGBVAA" -- World For Break
BreakID = 14852 -- Block Id
Facing = "right" --right/left
Background = 12840 -- background that placed in magplant
PosBreak = {43, 194} -- -1 From X, -1 From Y
Telephone = {43, 194} --Just Put Telephone in PosBreak and Set Same Id
UseMneck = false --Mneck Mode
Autoghost = false --Automatic Ghost
Takegems = true --Take Gems/No
Suckmode = false --Take Bgems
BuyDls = true --Auto But Dls From Telephone 
EmptyS = 0
bigems = 0
Deeles = 0
--[Dont Touch]--
function cheat(num)
  SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|" .. num .. "|\ncheck_bfg|" .. num .. "\ncheck_gems|".. (Takegems and 1 or 0))
end

function GetMag()
  Mag = {}
  count = 0
  for x = 199, 0, -1 do
    for y = 0, 199, 1 do
      tile = GetTile(x,y)
      if tile.fg == 5638 and tile.bg == Background then
        count = count + 1
        Mag[count] = {x = tile.x, y = tile.y}
      end
    end
  end
end

function inv(itemid)
    for _, item in pairs(GetInventory()) do
        if item.id == itemid then
            return item.amount
        end
    end
    return 0
end


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

function takemag()
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    FindPath(Mag[count].x, Mag[count].y - 1)
    Sleep(200)
    wrench()
    Sleep(200)
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. Mag[count].x .. "|\ny|" .. Mag[count].y .. "|\nbuttonClicked|getRemote")
    acount = count - 1
    Sleep(500)
    FindPath(PosBreak[1], PosBreak[2])
    cheat(1)
  end
end

function changemag()
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    cheat(0)
    FindPath(Mag[count].x, Mag[count].y -1)
    Sleep(200) 
    wrench()
    Sleep(200) 
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. Mag[count].x .. "|\ny|" .. Mag[count].y .. "|\nbuttonClicked|getRemote")
    count = count - 1
    Sleep(500)
    FindPath(PosBreak[1], PosBreak[2])
    Sleep(250)
    cheat(1)
  end
end

function reconnect()
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
    else
      if inv(5640) == 0 then
        GetMag()
        takemag()
      end
    end
  end
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    if GetTile(PosBreak[1] + (Facing == "right" and 1 or -1), PosBreak[2] + (UseMneck == "true" and 1 or 0)).fg == BreakID then
      EmptyS = 0
    else
      EmptyS = EmptyS + 1
    end
  end
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    if EmptyS >= 50 then
      LogToConsole("`2Magplant `0{ "..Mag[count].x.." , "..Mag[count].y.." }`4 Is Empty")
      changemag()
      EmptyS = 0
    end
  end
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    if Suckmode and not Takegems then
      bigems = bigems + 1
    end
  end
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    if bigems > 200 then
      LogToConsole("`2Sucking All Black Gems In The World")
      SendPacket(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgem_suckall")
      bigems = 0
    end
  end
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    if BuyDls then
      Deeles = Deeles + 1
    end
  end
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    if Deeles >= 110 then
      LogToConsole("`2Successfully `0Changing `1Diamond Locks")
      SendPacket(2,"action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..Telephone[1].."|\ny|"..Telephone[2].."|\nbuttonClicked|dlconvert")
      Deeles = 0
    end
  end
  if GetWorldName() ~= World then
    Sleep(2000)
    LogToConsole("`4Invalid `2Warping Back To ".. World)
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(5000)
  else
    if inv(1796) > 99 then
      SendPacket(2,"action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..Telephone[1].."|\ny|"..Telephone[2].."|\nbuttonClicked|bglconvert")
    end
  end
end

SendPacket(2, "action|input\ntext|`5ADVANCED `0PNB `1By `0[ `cNier Community `0]") 
if Autoghost then
  SendPacket(2,"action|input\n|text|/ghost")
else
  LogToConsole("`2AutoGhost Is `4False")
end
while true do
  reconnect()
  Sleep(200)
end