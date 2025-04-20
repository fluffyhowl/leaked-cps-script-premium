local AuthorizedIDs = {}

local content = MakeRequest("https://raw.githubusercontent.com/DuxiiYT/BotHax-PNB/refs/heads/main/AuthorizationIDS.txt", "GET").content

for id in content:gmatch("[^\r\n]+") do
    AuthorizedIDs[#AuthorizedIDs + 1] = tonumber(id)
end

local KeybindStr = "F7"
local FileName = "PNBOpts.txt"
local Webhook = ""
local Key = 118
local WindowSize = ImVec2(800, 400)
local IsKeySelecting = false
local IsMenuVisible = true
local PunchMagplant = false
local SetFarmPosition = false
local BlockMenu = false
local ChangeRemote
local UseClover = false
local UseArroz = false
local TelephoneX
local TelephoneY
local WebhookDelay = 300
local LastWebhookTime = os.time()
local WorldName = GetWorld().name
local IsPNB = false
local IsFarming = false
local MagplantPosition = {
    x = 0,
    y = 0 
}
local FarmingPositions = {
    x = 0,
    y = 0 
}

local FarmOptions = {
    Checkboxes = {
        "Mythical Necklace", "Mythical Infinity Fist", "Legendary Infinity Fist", "Legendary Shard Sword"
    },
    Options = {
        "Auto Collect Gems", "Auto Change Remote", "Auto Consumables", "Auto Telephone", "Send to Webhook"
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
    content = content .. "WebhookDelay=" .. WebhookDelay .. "\n"
    content = content .. "MagplantX=" .. MagplantPosition.x .. "\n"
    content = content .. "MagplantY=" .. MagplantPosition.y .. "\n"
    content = content .. "FarmPosX=" .. FarmingPositions.x .. "\n"
    content = content .. "FarmPosY=" .. FarmingPositions.y .. "\n"

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
            elseif option == "WebhookDelay" then
                WebhookDelay = tonumber(state) or 0
            elseif option == "MagplantX" then
                MagplantPosition.x = tonumber(state) or 0
            elseif option == "MagplantY" then
                MagplantPosition.y = tonumber(state) or 0
            elseif option == "FarmPosX" then
                FarmingPositions.x = tonumber(state) or 0
            elseif option == "FarmPosY" then
                FarmingPositions.y = tonumber(state) or 0
			end
            FarmingStates[option] = (state:lower() == "true")
        end
    end
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

local function Use(id, x, y)
    pkt = {}
    pkt.type = 3
    pkt.value = id
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    SendPacketRaw(false, pkt)
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
local function UseTelephone()
    local tiles = GetTiles()
    
    if not tiles then return end 

    for _, tile in pairs(tiles) do
        if tile.fg == 3898 then
            TelephoneX = tile.x
            TelephoneY = tile.y
        end
    end

    if not TelephoneX or not TelephoneY then return end 

    local PlayerInfo = GetPlayerInfo()
    if not PlayerInfo then return end

    if PlayerInfo.gems >= 10800001 then
        SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. TelephoneX .. "|\ny|" .. TelephoneY .. "|\nbuttonClicked|bglconvert2")
        Sleep(150)
    end

    if PlayerInfo.gems >= 100001 then
        SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. TelephoneX .. "|\ny|" .. TelephoneY .. "|\nbuttonClicked|dlconvert")
        Sleep(150)
    end
end


local function GetItem(id)
    inv = GetInventory()
    if inv[id] ~= nil then
        return inv[id].amount
    end
    return 0
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
        if ImGui.Begin('CreativePS - PNB (Made by Duxii & Screamy)', true, ImGui.WindowFlags.Resize) then
            local CurrentSize = ImGui.GetWindowSize()
            if CurrentSize.x ~= WindowSize.x or CurrentSize.y ~= WindowSize.y then
                WindowSize = CurrentSize
            end

            if ImGui.BeginTabBar("tabs") then

                if ImGui.BeginTabItem("Main") then
					ImGui.Columns(2, nil, false)
                    ImGui.Text("Wear Item:")
                    for _, option in ipairs(FarmOptions.Checkboxes) do
                        local changed, NewValue = ImGui.Checkbox(option, FarmingStates[option])
                        if changed then
							FarmingStates[option] = NewValue 

                            if option == "Mythical Infinity Fist" then
                                FarmingStates["Legendary Infinity Fist"] = false
                                FarmingStates["Legendary Shard Sword"] = false
                                if GetItem(15730) >= 1 then
                                    pkt = {}
                                    pkt.value = 15730
                                    pkt.type = 10
                                    SendPacketRaw(false, pkt)
                                else
                                    CLog("`4ERROR - `9You do not have a Mythical Infinity Fist in your Inventory")
                                end
                            elseif option == "Legendary Infinity Fist" then
                                FarmingStates["Mythical Infinity Fist"] = false
                                FarmingStates["Legendary Shard Sword"] = false
                                if GetItem(15694) >= 1 then
                                    pkt = {}
                                    pkt.value = 15694
                                    pkt.type = 10
                                    SendPacketRaw(false, pkt)
                                else
                                    CLog("`4ERROR - `9You do not have a Legendary Infinity Fist in your Inventory")
                                end
                            elseif option == "Legendary Shard Sword" then
                                FarmingStates["Mythical Infinity Fist"] = false
                                FarmingStates["Legendary Infinity Fist"] = false
                                if GetItem(15444) >= 1 then
                                    pkt = {}
                                    pkt.value = 15444
                                    pkt.type = 10
                                    SendPacketRaw(false, pkt)
                                else
                                    CLog("`4ERROR - `9You do not have a Legendary Shard Sword in your Inventory")
                                end
                            end
						end
                    end
                    ImGui.NewLine()
                    if ImGui.Button("Set Magplant Position") then
						CLog("Punch the `2Magplant `9you want to set the positions to.")
						PunchMagplant = true
                    end
                    ImGui.SameLine()
                    if ImGui.Button("Set Farming Position") then
						CLog("`9Punch where you want it to `2start `9farming")
						SetFarmPosition = true
                    end
                    ImGui.NewLine()
					if IsPNB then
						if ImGui.Button("Stop PNB") then
							IsPNB = false
                            IsFarming = false
                            BlockMenu = true
                            SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0")
						end
					else
						if ImGui.Button("Start PNB") then
							WorldName = GetWorld().name
							if FarmingPositions.x == 0 and FarmingPositions.y == 0 then
								CLog("`4ERROR `9- You have not set the Farming Positions yet!")
							elseif MagplantPosition.x == 0 and MagplantPosition.y == 0 then
								CLog("`4ERROR `9- You have not set the Magplant Position yet!")
							else
								IsPNB = true
                                IsFarming = true
							end
						end
					end				
                    ImGui.NextColumn()
                    ImGui.Text("Options:")
                    for _, option in ipairs(FarmOptions.Options) do
                        local changed, NewValue = ImGui.Checkbox(option, FarmingStates[option])
                        if changed then
							FarmingStates[option] = NewValue

                            if option == "Auto Collect Gems" then
								if NewValue then
                                    CLog("`2Successfully `cenabled `9Auto Collect Gems")
								else
                                    CLog("`2Successfully `4disabled `9Auto Collect Gems")
								end
							end
						end
                    end
                    ImGui.Columns(1)
                    ImGui.EndTabItem()
                end

                if ImGui.BeginTabItem("Settings") then
                    ImGui.Columns(2, nil, false)
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

                    ImGui.Text("Webhook Delay (in seconds):")
                    local changed, NewWebhookDelay = ImGui.InputFloat("##WebhookDelayA", WebhookDelay, 1, 1, "%.0f")

                    if changed then
                        WebhookDelay = math.floor(NewWebhookDelay)
                    end

					if ImGui.Button("Set Webhook Delay") then
						Webhook = NewWebhook
						if WebhookDelay > 5 then
                        	CLog("`2Successfully `9set the Webhook Delay to " .. WebhookDelay .. " seconds!")
						else
							CLog("`4ERROR - Failed `9to set the Webhook Delay, it cannot be lower than 5 seconds because your Webhook will get Ratelimited")
						end
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
		        BlockMenu = false

            	if not varlist[1]:find("|528|") then
                	UseClover = true
            	end
            	if not varlist[1]:find("|4604|") then
                	UseArroz = true
            	end
                return true
            end
        end
	end

    if varlist[0] == "OnDialogRequest" then
        if varlist[1]:find("MAGPLANT 5000") then
            return true
        end
    end

	if varlist[0] == "OnSDBroadcast" then
        return true
    end

    if varlist[0] == "OnTalkBubble" then
        if varlist[2]:match("The MAGPLANT 5000 is empty.") and not ChangeRemote then
            if FarmingStates["Auto Change Remote"] then
                MagplantPosition.x = MagplantPosition.x+1
                ChangeRemote = true
            end
            return true
        end

        if varlist[2]:match("Collected") then
            return true
        end

        if varlist[2]:match("You can't punch/place") then
            return true
        end
    end
end

local function RawPacket(pkt)
	if pkt.type == 0 and (pkt.state == 2592 or pkt.state == 2608) then
		if PunchMagplant then
			BlockID = tonumber(GetTile(pkt.px, pkt.py).fg)

			if BlockID ~= 5638 then
				CLog("`4Failed `9to set the Magplant Positions! Try to Punch again.")
			else
				MagplantPosition.x = pkt.px
				MagplantPosition.y = pkt.py
				CLog("`2Successfully `9set Magplant Positions: `2[`9" .. MagplantPosition.x .. ", " .. MagplantPosition.y .. "`2]")
				PunchMagplant = false
			end
		end

        if SetFarmPosition then
            FarmingPositions.x = pkt.px
            FarmingPositions.y = pkt.py
			CLog("`2Successfully `9set Farming Position at: `2[`9" .. FarmingPositions.x .. ", " .. FarmingPositions.y .. "`2]")
			SetFarmPosition = false
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
AddHook("onvariant", "Dialog Handler", VarlistHandler)
AddHook('OnDraw', 'Main Menu', MainMenu)

CheckAuthorization()
LoadSettings()

while true do
    if IsPNB then
        if os.time() - LastWebhookTime >= WebhookDelay then
            local PNBPayload = [[{
                "embeds": [
                  {
                    "title": "PNB Information",
                    "description": "World: ]] .. GetWorld().name .. [[\nPlayer: ]] .. GetLocal().name:gsub("`.","") .. [[\nGems: ]] .. GetPlayerInfo().gems .. [[\nTime: ]] .. os.date("%Y-%m-%d at %I:%M %p") .. [[",
                    "color": null
                  }
                ]
              }]]
            SendWebhook(Webhook, PNBPayload)
            LastWebhookTime = os.time()
        end

        while not GetWorld() do
            RequestJoinWorld(WorldName)
            IsFarming = true
            Sleep(2500)
        end

        Sleep(1000)

        if GetItem(5640) <= 0 then
            FindPath(MagplantPosition.x, MagplantPosition.y - 1, 100)
            Sleep(950)
            Wrench(MagplantPosition.x, MagplantPosition.y)
            Sleep(950)
            SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. MagplantPosition.x .. "|\ny|" .. MagplantPosition.y .. "|\nbuttonClicked|getRemote")
            Sleep(950)
        end

        if ChangeRemote then
            FindPath(MagplantPosition.x, MagplantPosition.y - 1, 100)
            Sleep(950)
            Wrench(MagplantPosition.x, MagplantPosition.y)
            Sleep(950)
            SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. MagplantPosition.x .. "|\ny|" .. MagplantPosition.y .. "|\nbuttonClicked|getRemote")
            Sleep(950)
            ChangeRemote = false
        end

        Sleep(950)
        FindPath(FarmingPositions.x, FarmingPositions.y, 100)
        Sleep(950)

        if FarmingStates["Auto Consumables"] then
            BlockMenu = true
            Sleep(90)
            SendPacket(2, "action|wrench\n|netid|" .. (GetLocal() and GetLocal().netid or 0))
            Sleep(250)

            if GetItem(528) > 0 and UseClover then
                Use(528, 0, 0)
                Sleep(90)
                UseClover = false
            end
            if GetItem(4604) > 0 and UseArroz then
                Use(4604, 0, 0)
                Sleep(90)
                UseArroz = false
            end
        end

        if IsFarming then
            if math.floor(GetLocal().pos.x/32) == FarmingPositions.x and math.floor(GetLocal().pos.y/32) == FarmingPositions.y then
                if FarmingStates["Auto Collect Gems"] then
                    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_gems|1")
                else
                    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1")
                end
                IsFarming = false
            end
        end

        BlockMenu = true
        Sleep(950)

        if FarmingStates["Auto Telephone"] then
            UseTelephone()
            Sleep(90)
        end
    end
end