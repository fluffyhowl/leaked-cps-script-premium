--[[==============================]]--
AmountLoop = "unli" -- "unli" or number For Loop
Mode = "PTHT" -- Set Mode "PTHT/PT/HT"
PlantID = 5640 -- Dont Touch This Is Magplant Remote
TreeID = 15159 -- Pot O' Gems Seed
delayPT = 10 -- Recommend 10
delayHT = 20 -- Recommend 20
--[[==============================]]--

px = 199
py = math.floor(GetLocal().posY / 32)

EditToggle("AntiLag", true)

function sendText(str)
   SendPacket(2, "action|input\ntext|" .. str)
end

SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_gems|1")

function akira(x, y, state)
  SendPacketRaw(false, {state = state, px = x, py = y, x = x*32, y = y*32})
end

function Tolay(str)
   SendVariant({ v0 = "OnTextOverlay", v1 = str })
end

function akiraP(x, y, id)
  SendPacketRaw(false, {type = 3, value = id, px = x, py = y, x = x*32, y = y*32})
end

function akiraTree()
  count = 0
  for y = py, 0, -1 do
    for x = 0, px, 1 do
      if GetTile(x, y).fg == 0 and (GetTile(x, y + 1).fg ~= 0 and GetTile(x, y + 1).fg % 2 == 0) then
        count = count + 1
      end
    end
  end
  return count
end

function akiraReady()
  ready = 0
  for y = py, 0, -1 do
    for x = 0, px, 1 do
      if GetTile(x, y).fg == TreeID and GetTile(x, y).readyharvest then
        ready = ready + 1
      end
    end
  end
  return ready
end

function akiHT()
  if akiraReady() > 0 then
   Tolay("`1Harvesting...")
    for y = py, 0, -1 do
      if y % 2 ~= 0 then
        LogToConsole("`0[`^" .. os.date("%H:%M:%S") .. "``]`1Harvest Line : `9"..y)
      end
      for x = 0, px, 1 do
        if GetTile(x, y).fg == TreeID and GetTile(x, y).readyharvest then
          akira(x, y, PlantID)
          Sleep(50)
          akiraP(x, y, 18)
          Sleep(delayHT * 10)
        end
      end
    end
  end
end

function akiPT()
  if akiraReady() < 20000 then
   Tolay("`1Planting...")
    for y = py, 0, -1 do
      if y % 2 ~= 0 then
        LogToConsole("`0[`^" .. os.date("%H:%M:%S") .. "``]`1Planting Line : `9"..y)
      end
      for x = 0, px, 10 do
        if GetTile(x, y).fg == 0 and (GetTile(x, y + 1).fg ~= 0 and GetTile(x, y + 1).fg % 2 == 0) then
          akira(x, y, 32)
          Sleep(delayPT * 10)
          akiraP(x, y, PlantID)
          Sleep(50)
        end
      end
      for x = px, 0, -1 do
        if GetTile(x, y).fg == 0 and (GetTile(x, y + 1).fg ~= 0 and GetTile(x, y + 1).fg % 2 == 0) then
          akira(x, y, 48)
          Sleep(60)
          akiraP(x, y, PlantID)
          Sleep(delayPT * 10)
        end
      end
    end
  end
end

for i = 1, 1 do
sendText("`cPTHT Premium `0by `bNier Community")
Sleep(2000)
end

function main()
  if Mode == "PTHT" then
    if AmountLoop == "unli" then
      countLoop = 0
      while true do
      countLoop = countLoop + 1
        for i = 1, 3 do
          akiHT()
          Sleep(500)
        end
        for i = 1, 3 do
          akiPT()
          Sleep(500)
        end
        if akiraTree() == 0 then
          SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
          Sleep(5000)
          for i = 1, 3 do
            akiHT()
            Sleep(500)
          end
        end
        sendText("`cFinished Loop `0" .. countLoop)
      end
    else
      for j = 1, AmountLoop do
        for i = 1, 3 do
          akiHT()
          Sleep(500)
        end
        for i = 1, 3 do
          akiPT()
          Sleep(500)
        end
        if akiraTree() == 0 then
          SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
          Sleep(5000)
          for i = 1, 3 do
            akiHT()
            Sleep(500)
          end
        end
        sendText("`cFinished `0" .. Mode:upper() .. " `0[`b" .. j .. "`0/``" .. AmountLoop .. "`0]")
      end
    end
  elseif Mode == "PT" then
    for i = 1, 3 do
      akiPT()
      Sleep(500)
    end
    if akiraTree() == 0 then
      SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
      Sleep(5000)
    end
    sendText("`cFinished `0" .. Mode:upper())
  elseif Mode == "HT" then
    for i = 1, 3 do
      akiHT()
      Sleep(500)
    end
    sendText("`cFinished `0" .. Mode:upper())
  end
end

local success, message = pcall(main)

if not success then
  LogToConsole("`rError: " .. message)
end