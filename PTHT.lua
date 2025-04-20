local AuthorizedIDs = {}

local content = MakeRequest("https://raw.githubusercontent.com/DuxiiYT/BotHax-PTHT/refs/heads/main/AuthorizationIDs.txt", "GET").content

for id in content:gmatch("[^\r\n]+") do
    AuthorizedIDs[#AuthorizedIDs + 1] = tonumber(id)
end

local WindowSize = ImVec2(800, 400)
local IsMenuVisible = true
local KeybindStr = "F7"
local Key = 118
local FileName = "PthtOpts.txt"
local PlatformID = 0
local PlantDelay = 90
local HarvestDelay = 100
local UWSDelay = 500
local ReconnectDelay = 100
local PunchBlock = false
local IsPTHT
local PTHTAmount = 0
local PTHTTotal = 0
local PunchMagplant = false
local BlockMenu = false
local SendToWebhook = false
local IsNotGhosted = true
local ChangeRemote = false
local Webhook = ""
local WorldName = GetWorld().name
local PTHTLogs = {}
local MagplantPosition = {
    x = 0,
    y = 0 
}

local FarmOptions = {
    Checkboxes = {
        "Check if Missed", "Check if Unharvested", "Auto Change Remote", "Log to File"
    }
}

local FarmingStates = {}
for category, options in pairs(FarmOptions) do
    for _, option in ipairs(options) do
        FarmingStates[option] = false
    end
end

local function CLog(text)
	local var = {}
	var[0] = "OnConsoleMessage"
	var[1] = "`0[ `9@d`6u`9x`6i`9i. `0] `9" .. text
	SendVariantList(var)
end

local function FileRead(FileName)
    local file = io.open(FileName, 'r')
    if not file then return {} end
    local data = {}
    for line in file:lines() do
        table.insert(data, line)
    end
    file:close()
    return data
end

local function FileWrite(FileName, data) 
    local blacklisted = FileRead(FileName)
    for _, id in pairs(blacklisted) do
        if id == data then
            return
        end
    end
    local file = io.open(FileName, 'a')
    file:write(data .. "\n")
    file:close()
end

local function FileModify(FileName, data)
    local file = io.open(FileName, 'w')
    file:write(data .. "\n")
    file:close()
end

local function HandleSaveSettings()
    local content = ""

    for _, option in ipairs(FarmOptions.Checkboxes) do
        content = content .. option .. "=" .. tostring(FarmingStates[option]) .. "\n"
    end

	content = content .. "Webhook=" .. Webhook .. "\n"
    content = content .. "PlatformID=" .. PlatformID .. "\n"
    content = content .. "MagplantX=" .. MagplantPosition.x .. "\n"
    content = content .. "MagplantY=" .. MagplantPosition.y .. "\n"
    content = content .. "PlantDelay=" .. PlantDelay .. "\n"
    content = content .. "HarvestDelay=" .. HarvestDelay .. "\n"
    content = content .. "UWSDelay=" .. UWSDelay .. "\n"

    FileModify(FileName, content)
end

local function LoadSettings()
    local file = io.open(FileName, "r")
    if not file then
        CLog("`4Error - `9Could not open settings file.")
        return
    end

    local data = file:read("*a")
    file:close()

    if not data or data == "" then
        CLog("`4Error - `9Settings file is empty.")
        return
    end

    for line in string.gmatch(data, "[^\r\n]+") do
        local option, state = line:match("([^=]+)=(.*)")
        if option and state then
			if option == "Webhook" then
                Webhook = state
            elseif option == "PlatformID" then
                PlatformID = tonumber(state) or 0
            elseif option == "MagplantX" then
                MagplantPosition.x = tonumber(state) or 0
            elseif option == "MagplantY" then
                MagplantPosition.y = tonumber(state) or 0
            elseif option == "PlantDelay" then
                PlantDelay = tonumber(state) or 0
            elseif option == "HarvestDelay" then
                HarvestDelay = tonumber(state) or 0
            elseif option == "UWSDelay" then
                UWSDelay = tonumber(state) or 0
			end
            FarmingStates[option] = (state:lower() == "true")
        end
    end
end

local function TalkBubble(text)
    var = {}
    var[0] = "OnTalkBubble"
    var[1] = GetLocal().netid
    var[2] = text
    SendVariantList(var)
end

local function InWorld(Name)
    local Success, ReturnMessage = pcall(function()
        return string.upper(GetWorld().name) == string.upper(Name)
    end)
    return ReturnMessage or false
end

local function Overlay(text)
	local packet = {
			[0] = "OnTextOverlay",
			[1] = text,
	}
	SendVariantList(packet)
end

local function Warn(text)
	local pkt = {
			[0] = "OnAddNotification",
			[1] = "interface/atomic_button.rttex",
			[2] = text,
			[3] = 'audio/hub_open.wav',
			[4] = 0,
	}
	SendVariantList(pkt)
end

local function Place(x, y, id)
    local pkt = {}
    pkt.type = 3
    pkt.value = id
    pkt.px = x
    pkt.py = y
	pkt.x = x*32
	pkt.y = y*32
    SendPacketRaw(false, pkt)
end

local function Punch(x, y)
    pkt = {}
    pkt.type = 3
    pkt.value = 18
    pkt.x = x*32
    pkt.y = y*32
    pkt.px = x
    pkt.py = y
    SendPacketRaw(false, pkt)
    Sleep(40)
end

local function Wrench(x, y)
    pkt = {}
    pkt.type = 3
    pkt.value = 32
    pkt.px = x
    pkt.py = y
    pkt.x = x*32
    pkt.y = y*32
    SendPacketRaw(false, pkt)
    Sleep(40)
end

local function GetItem(id)
    inv = GetInventory()
    if inv[id] ~= nil then
        return inv[id].amount
    end
    return 0
end

local function RawMove(x, y)
    SendPacketRaw(false, {
        state = 32,
        px = x,
        py = y,
        x = x*32,
        y = y*32
    })
    Sleep(90)
end

local function Plant()
    local tiles = GetTiles()
    local MinX, MaxY = math.huge, -math.huge
    local MinY, MaxY = math.huge, -math.huge
    local ShouldUseUWS = false

    for _, tile in pairs(tiles) do
        if tile.fg == PlatformID then
            MinX = math.min(MinX, tile.x)
            MaxY = math.max(MaxY, tile.x)
            MinY = math.min(MinY, tile.y)
            MaxY = math.max(MaxY, tile.y)
        end
    end

    for x = MinX, MaxY, 10 do
        for y = MinY, MaxY do
            if ChangeRemote then
                FindPath(MagplantPosition.x, MagplantPosition.y - 1)
                Sleep(950)
                Wrench(MagplantPosition.x, MagplantPosition.y)
                Sleep(950)
                SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. MagplantPosition.x .. "|\ny|" .. MagplantPosition.y .. "|\nbuttonClicked|getRemote")
                Sleep(950)
                ChangeRemote = false
            end

            local tile = GetTile(x, y)
            if tile and tile.fg == PlatformID then
                local AboveTile = GetTile(x, y - 1)

                if AboveTile and AboveTile.fg == 15461 then
                    if AboveTile.extra and AboveTile.extra.progress == 1 then
                        goto continue
                    end
                    ShouldUseUWS = true
                    goto continue
                end

                RawMove(tile.x, tile.y - 1)
                Sleep(PlantDelay)
                Place(tile.x, tile.y - 1, 5640)
                ShouldUseUWS = true

                ::continue::
            end
        end
    end

    if ShouldUseUWS then
        if GetItem(12600) >= 1 then
            Sleep(750)
            SendPacket(2, "action|input\n|text|`9Using Ultra World Spray...")
            Sleep(UWSDelay)
            SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
        else
            Warn("`4You do not have any Ultra World Sprays in your inventory, stopped script...")
            return
        end
    end
end

local function Harvest()
    local tiles = GetTiles()
    local MinX, MaxX = math.huge, -math.huge
    local MinY, MaxY = math.huge, -math.huge

    for _, tile in pairs(tiles) do
        if tile.fg == PlatformID then
            MinX = math.min(MinX, tile.x)
            MaxX = math.max(MaxX, tile.x)
            MinY = math.min(MinY, tile.y)
            MaxY = math.max(MaxY, tile.y)
        end
    end

    for y = MinY, MaxY do
        local tile = GetTile(0, y)
        if tile and tile.fg == PlatformID then
            RawMove(tile.x, tile.y - 1)
            Sleep(HarvestDelay)
            Punch(tile.x, tile.y - 1)
        end
    end

    local MoreToHarvest = true
    while MoreToHarvest do
        MoreToHarvest = false
        for y = MinY, MaxY do
            for x = MinX, MaxX do
                local tile = GetTile(x, y)
                if tile and tile.fg == 15461 then
                    RawMove(x, y)
                    Sleep(HarvestDelay)
                    Punch(x, y)
                    MoreToHarvest = true
                    break
                end
            end
            if MoreToHarvest then break end
        end
    end

    SendPacket(2, "action|input\n|text|`2Successfully `9harvested all Pot O' Gems Trees!")
end

local function CheckAuthorization()
    local Authorized = false
    local UserID = GetLocal().userid
    if UserID ~= 0 then
        for _,AuthID in pairs(AuthorizedIDs) do
            if UserID == AuthID then
                Authorized = true
            end
        end
        
        if not Authorized then
            Warn("`4UNAUTHORIZED `9USER! `9Sharing the script is `4NOT `9Allowed!")
			CLog("`4Sharing the script is NOT allowed!")
            RemoveHooks()
        end
    end
end

local function SendWebhook(url, data)
    MakeRequest(url,"POST",{["Content-Type"] = "application/json"},data)
end

local KeyCodes = {
    Lbutton = 1,
    Rbutton = 2,
    Xbutton1 = 5,
    Xbutton2 = 6,
    Cancel = 3,
    Mbutton = 4,
    Back = 8,
    Tab = 9,
    Clear = 12,
    Return = 13,
    Shift = 16,
    Control = 17,
    Menu = 18,
    Pause = 19,
    Capital = 20,
    Escape = 27,
    Space = 32,
    Prior = 33,
    Next = 34,
    End = 35,
    Home = 36,
    Left = 37,
    Up = 38,
    Right = 39,
    Down = 40,
    Select = 41,
    Print = 42,
    Execute = 43,
    Snapshot = 44,
    Insert = 45,
    Delete = 46,
    Help = 47,
    Num0 = 48,
    Num1 = 49,
    Num2 = 50,
    Num3 = 51,
    Num4 = 52,
    Num5 = 53,
    Num6 = 54,
    Num7 = 55,
    Num8 = 56,
    Num9 = 57,
    A = 65,
    B = 66,
    C = 67,
    D = 68,
    E = 69,
    F = 70,
    G = 71,
    H = 72,
    I = 73,
    J = 74,
    K = 75,
    L = 76,
    M = 77,
    N = 78,
    O = 79,
    P = 80,
    Q = 81,
    R = 82,
    S = 83,
    T = 84,
    U = 85,
    V = 86,
    W = 87,
    X = 88,
    Y = 89,
    Z = 90,
    Lwin = 91,
    Rwin = 92,
    Apps = 93,
    Numpad0 = 96,
    Numpad1 = 97,
    Numpad2 = 98,
    Numpad3 = 99,
    Numpad4 = 100,
    Numpad5 = 101,
    Numpad6 = 102,
    Numpad7 = 103,
    Numpad8 = 104,
    Numpad9 = 105,
    Multiply = 106,
    Add = 107,
    Separator = 108,
    Subtract = 109,
    Decimal = 110,
    Divide = 111,
    F1 = 112,
    F2 = 113,
    F3 = 114,
    F4 = 115,
    F5 = 116,
    F6 = 117,
    F7 = 118,
    F8 = 119,
    F9 = 120,
    F10 = 121,
    F11 = 122,
    F12 = 123,
    F13 = 124,
    F14 = 125,
    F15 = 126,
    F16 = 127,
    F17 = 128,
    F18 = 129,
    F19 = 130,
    F20 = 131,
    F21 = 132,
    F22 = 133,
    F23 = 134,
    F24 = 135,
    Numlock = 144,
    Scroll = 145,
    Lshift = 160,
    Lcontrol = 162,
    Lmenu = 164,
    Rshift = 161,
    Rcontrol = 163,
    Rmenu = 165
}

local function MainMenu()
    if IsMenuVisible then
        ImGui.SetNextWindowSize(WindowSize)
        if ImGui.Begin('CreativePS - PTHT (Made by Duxii & Screamy)', true, ImGui.WindowFlags.Resize) then
            local CurrentSize = ImGui.GetWindowSize()
            if CurrentSize.x ~= WindowSize.x or CurrentSize.y ~= WindowSize.y then
                WindowSize = CurrentSize
            end

            if ImGui.BeginTabBar("tabs") then

                if ImGui.BeginTabItem("Main") then
					ImGui.Columns(2, nil, false)
                    for _, option in ipairs(FarmOptions.Checkboxes) do
                        local changed, NewValue = ImGui.Checkbox(option, FarmingStates[option])
                        if changed then
							FarmingStates[option] = NewValue 
						end
                    end

					if ImGui.Checkbox("Send to Webhook", SendToWebhook) then
						SendToWebhook = not SendToWebhook
						if SendToWebhook and Webhook == "" then
							CLog("`4ERROR `9- Webhook not set! Go to settings and set it there.")
							SendToWebhook = false
						end
					end

					if ImGui.Button("Auto Pickup Gems") then
                        SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_gems|1")
                        BlockMenu = true
                    end

                    ImGui.NewLine()

					ImGui.Text("World Type:")
					if ImGui.Button("Normal") then
						IsIslands = true
						CLog("Set World Type to `2Normal")
                    end
					ImGui.SameLine()
					if ImGui.Button("Islands") then
						IsIslands = false
						CLog("Set World Type to `2Islands")
                    end

					ImGui.NewLine()

					if IsPTHT then
						if ImGui.Button("Stop PTHT") then
							IsPTHT = false
                            return
						end
					else
						if ImGui.Button("Start PTHT") then
							WorldName = GetWorld().name
							if PlatformID == 0 then
								CLog("`4ERROR `9- You have not set the Platform ID yet!")
							elseif MagplantPosition.x == 0 or MagplantPosition.y == 0 then
								CLog("`4ERROR `9- You have not set the Magplant Position yet!")
							else
								IsPTHT = true
							end

                            if PTHTTotal == 0 then
                                PTHTTotal = 99999
                            end
						end
					end					
					
					ImGui.SameLine()
					if ImGui.Button("Set Magplant Position") then
						CLog("Punch the `2Magplant `9you want to set the positions to.")
						PunchMagplant = true
                    end

					ImGui.NextColumn()
                    ImGui.Text("Platform ID:")
                    local changed, NewPlatformID = ImGui.InputFloat("##Count", PlatformID, 1, 1, "%.0f")
                    if changed then
                        PlatformID = math.floor(NewPlatformID)
                    end

                    if ImGui.Button("Set Platform ID") then
                        if PlatformID ~= 0 then
                            PlatformID = NewPlatformID
							local PlatformName = GetItemInfo(math.floor(PlatformID)).name
                            CLog("`2Successfully `9set " .. PlatformName .. " as the Platform!")
                        else
                            CLog("`4ERROR `9- The ID `4cannot `9be `40 `9as that is not a Block")
                        end
                    end
					ImGui.SameLine()
					if ImGui.Button("Punch to Set ID") then
						CLog("Punch the `2Block `9you want to set it to.")
						PunchBlock = true
                    end

                    ImGui.Text("Amount to PTHT:")
                    local changed, NewPTHTAmount = ImGui.InputFloat("##PTHTCount", PTHTTotal, 1, 1, "%.0f")
                    if changed then
                        PTHTTotal = math.floor(NewPTHTAmount)
                    end

                    if ImGui.Button("Set Amount") then
                        if tonumber(PTHTTotal) == 0 then
                            PTHTTotal = PTHTTotal+999999
                            CLog("`2Successfully `9set Infinite as the total amount to PTHT!")
                        elseif PTHTTotal >= 1 then
                            PTHTTotal = PTHTTotal
                            CLog("`2Successfully `9set " .. PTHTTotal .. " as the total amount to PTHT!")
                        elseif PTHTTotal < 0 then
                            CLog("`4ERROR `9- The amount `4cannot `9be `4negative`9!")
                        end
                    end
                    ImGui.SameLine()
                    if ImGui.Button("Reset") then
                        PTHTTotal = 0
                    end

					ImGui.Columns(1)
                    ImGui.EndTabItem()
                end
				
                if ImGui.BeginTabItem("Settings") then
                    ImGui.Columns(2, nil, false)

					ImGui.Text("Plant Delay (milliseconds):")
                    local changed, NewPlantDelay = ImGui.InputFloat("##PlantDelay", PlantDelay, 5, 1, "%.0f")

                    if changed then
                        PlantDelay = NewPlantDelay
                    end

					if ImGui.Button("Set Plant Delay") then
						PlantDelay = NewPlantDelay
						if tonumber(PlantDelay) <= 30 then
							CLog("`4ERROR `9- Delay can not be lower than `230 `9millisecond otherwise it will crash.")
						else
							CLog("`2Successfully `9set the Plant Delay to: `c" .. math.floor(PlantDelay))
						end
                    end
					ImGui.NewLine()

					ImGui.Text("Harvest Delay (milliseconds):")
                    local changed, NewHarvestDelay = ImGui.InputFloat("##HarvestDelay", HarvestDelay, 5, 1, "%.0f")

                    if changed then
                        HarvestDelay = NewHarvestDelay
                    end

					if ImGui.Button("Set Harvest Delay") then
						HarvestDelay = NewHarvestDelay
						if tonumber(HarvestDelay) <= 30 then
							CLog("`4ERROR `9- Delay can not be lower than `230 `9millisecond otherwise it will crash.")
						else
							CLog("`2Successfully `9set the Harvest Delay to: `c" .. math.floor(HarvestDelay))
						end
                    end

					ImGui.NewLine()

					ImGui.Text("Use UWS Delay (milliseconds):")
                    local changed, NewUWSDelay = ImGui.InputFloat("##UWSDelay", UWSDelay, 5, 1, "%.0f")

                    if changed then
                        UWSDelay = NewUWSDelay
                    end

					if ImGui.Button("Set UWS Delay") then
						UWSDelay = NewUWSDelay
						if tonumber(UWSDelay) <= 30 then
							CLog("`4ERROR `9- Delay can not be lower than `230 `9millisecond otherwise it will crash.")
						else
							CLog("`2Successfully `9set the UWS Delay to: `c" .. math.floor(UWSDelay))
						end
                    end
					ImGui.NewLine()
					if ImGui.Button("Reset to default") then
						HarvestDelay = 100
						PlantDelay = 90
						UWSDelay = 500
                    end
					ImGui.NextColumn()

					ImGui.Text("Webhook URL:")
                    local changed, NewWebhook = ImGui.InputText("##WebhookURL", Webhook, 250)

                    if changed then
                        Webhook = NewWebhook
                    end

					if ImGui.Button("Set Webhook") then
						Webhook = NewWebhook
						if tostring(Webhook):find("https://discord.com/api/webhooks/") then
                        	CLog("`2Successfully `9set the Webhook URL")
						else
							CLog("`4ERROR - Failed `9to set the Webhook URL, must include the whole url such as `2'https://discord.com/api/webhooks/example'")
						end
                    end
					ImGui.SameLine()
					if ImGui.Button("Test Webhook") then
						SendWebhook(Webhook, [[{"content": "Webhook Test"}]])
						CLog("`2Successfully sent `9a Webhook request, if you did not get it then that means your Webhook is `4invalid`9.")
                    end

					ImGui.Columns(1)
                    ImGui.EndTabItem()
                end

				if ImGui.BeginTabItem("Credits") then
                    ImGui.Columns(1, nil, false)

                    ImGui.Text("Thank you for choosing our Scripts! We appreciate your trust and support. \nEnjoy a fast, secure, and seamless experience with us!")
                    if ImGui.Button("Save Settings") then
                        HandleSaveSettings()
                        CLog("`2Successfully `9saved your current settings!")
                    end

                    ImGui.SameLine()
                    if ImGui.Button("Discord Server") then
                        CLog("Discord server set to your Clipboard! >> https://discord.gg/busWsqEZdJ")
                        os.execute('echo https://discord.gg/busWsqEZdJ | clip')
                    end

					ImGui.NewLine()
					ImGui.NextColumn()
                    ImGui.Text("Open / Close Menu Keybind:")
                    local changed, NewKey = ImGui.InputText("##MenuKey", KeybindStr, 8)

                    if changed then
                        KeybindStr = NewKey
                    end

                    if IsKeySelecting then
                        ImGui.Text("Press any key to set the new keybind...")
                    end

                    if ImGui.Button("Change Keybind") then
                        IsKeySelecting = true
                    end

					ImGui.Columns(1)
                    ImGui.EndTabItem()
				end
                
                ImGui.EndTabBar()
            end

            ImGui.End()
        end
    end
end

local function VarlistHandler(varlist)
	if varlist[0] == "OnDialogRequest" then
		if varlist[1]:find("Current world:") then
            if BlockMenu then
                if not varlist[1]:find("`wGhost in the shell````") then
                    SendPacket(2, "action|input\n|text|/ghost")
                end
			    BlockMenu = false
                return true
            end
        end
	end

	if varlist[0] == "OnSDBroadcast" then
        return true
    end
	if varlist[0] == "OnDialogRequest" and varlist[1]:find("MAGPLANT 5000") then
        return true
    end
    if varlist[0] == "OnTalkBubble" and varlist[2]:match("The MAGPLANT 5000 is empty.") then
        if FarmingStates["Auto Change Remote"] and not ChangeRemote then
            MagplantPosition.x = MagplantPosition.x+1
            ChangeRemote = true
        end
        return true
    end
    if varlist[0] == "OnTalkBubble" and varlist[2]:match("Collected") then
        return true
    end
end

local function RawPacket(pkt)
	if pkt.type == 0 and (pkt.state == 2592 or pkt.state == 2608) then
		if PunchBlock then
			PlatformID = tonumber(GetTile(pkt.px, pkt.py).fg)

			if PlatformID == 0 then
				CLog("`4Failed `9to set the Platform ID! Try to Punch again.")
			else
				CLog("`2Successfully`9 set " .. GetItemInfo(PlatformID).name .. " as the Platform ID!")
				PunchBlock = false
			end
		end

		if PunchMagplant then
			BlockID = tonumber(GetTile(pkt.px, pkt.py).fg)

			if BlockID ~= 5638 then
				CLog("`4Failed `9to set the Magplant Positions! Try to Punch again.")
			else
				MagplantPosition.x = pkt.px
				MagplantPosition.y = pkt.py
				CLog("`2Successfully`9 set Magplant Positions: `2[`9" .. MagplantPosition.x .. ", " .. MagplantPosition.y .. "`2]")
				PunchMagplant = false
			end
		end
	end
end

local function InputDetector(Keys)
    if IsKeySelecting then
        for KeyName, KeyCode in pairs(KeyCodes) do
            if KeyCode == Keys then
                KeybindStr = KeyName
                Key = KeyCode
                break
            end
        end
        IsKeySelecting = false
    elseif Keys == Key then
        IsMenuVisible = not IsMenuVisible
    end
end

AddHook("OnInput", "Input Detector", InputDetector)
AddHook("onsendpacketraw", "Raw Packet Catcher", RawPacket)
AddHook('OnDraw', 'Main Menu', MainMenu)
AddHook("onvariant", "Dialog Handler", VarlistHandler)
AddHook("onsendpacket", "Packet Handler", PacketHandler)

CheckAuthorization()
LoadSettings()


local function PTHT();
    if IsPTHT then
        while PTHTAmount < PTHTTotal do
            if not GetWorld() then
                SendPacket(2, "action|input\n|text|/warp " .. WorldName)
                Sleep(2500)
            end

            if IsNotGhosted then
                SendPacket(2, "action|wrench\n|netid|" .. GetLocal().netid)
                BlockMenu = true
                Sleep(150)
                IsNotGhosted = false
            end

            if GetItem(5640) <= 0 then 
                Wrench(MagplantPosition.x, MagplantPosition.y)
                Sleep(300)
                SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. MagplantPosition.x .. "|\ny|" .. MagplantPosition.y .. "|\nbuttonClicked|getRemote")
                Sleep(950)
            end

            Plant()
            Sleep(950)
            SendPacket(2, "action|input\n|text|`2Successfully `9Planted and used Ultra World Spray, will start harvesting now!")
            Harvest()
            Sleep(1500)
            PTHTAmount = PTHTAmount + 1
            SendPacket(2, "action|input\n|text|`2Successfully `9completed " .. PTHTAmount .. " out of " .. PTHTTotal)

            if SendToWebhook then
                local PTHTPayload = [[{
                    "embeds": [
                      {
                        "title": "PTHT Information",
                        "description": "World: ]] .. GetWorld().name .. [[\nPlayer: ]] .. GetLocal().name:gsub("`.","") .. [[\nCompleted: ]] .. PTHTAmount .. [[\nGems: ]] .. GetPlayerInfo().gems .. [[\nTime: ]] .. os.date("%Y-%m-%d at %I:%M %p") .. [[",
                        "color": null
                      }
                    ]
                  }]]
                SendWebhook(Webhook, PTHTPayload)
            end

            if FarmingStates["Log to File"] then
                local PTHTFileName = "PTHT_Logs.txt"
                        
                local file = io.open(PTHTFileName, "r")
                if not file then
                    CLog("`4ERROR - `9No file found, created one instead!")
                else
                    file:close()
                end
            
                file = io.open(PTHTFileName, "a")
                if file then
                    file:write("=========================================================\nWorld: " .. GetWorld().name .. "\nPlayer: " .. GetLocal().name:gsub("`.","") .. "\nCompleted: " .. PTHTAmount .. " out of " .. PTHTTotal .. "\nGems: " .. GetPlayerInfo().gems .. "\nTime: " .. os.date("%Y-%m-%d at %I:%M %p") .. "\n=========================================================")
                    file:close()
                    CLog("`2Successfully `9saved PTHT Logs!")
                else
                    CLog("`4ERROR - `9Could not open file for writing!")
                end
                Sleep(950)
            end

            if not IsPTHT then
                while not IsPTHT do
                    Sleep(50)
                end
            end
        end

        SendPacket(2, "action|input\n|text|`2PTHT Process completed successfully!")
    end
    Sleep(500)
end

RunThread(function()
    ChangeValue("[C] Modfly", false)

    while true do
        pcall(function()
            PTHT();
        end)
        Sleep(1000)
    end
end)