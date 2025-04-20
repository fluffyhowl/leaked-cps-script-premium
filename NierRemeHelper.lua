local notif = false
local sdb = false
local pull = false
local reme = false
local qeme = false
local logcollect = ""
local logdrop = ""
local autopull = false
local cbgl = false
local tablelogspin = {}
local cvwl = false
local tpdisplay = false
local fasttrash = false

function GetItemCount(id)
	for _, inv in pairs(GetInventory()) do
		if inv.id == id then
			return inv.amount
		end
	end
	return 0
end

function OnBoxUpdated(boolean)
   local hasil = ""
   if boolean then
	   hasil = "1"
   else
       hasil = "0"
   end
   return hasil
end

function OnWear(id)
	SendPacketRaw(false, { type = 10, value = id })
end

function OnTextOverlay(str)
	SendVariant({ v0 = "OnTextOverlay", v1 = str })
end

function OnTalkBubble(str)
	SendVariant({ v0 = "OnTalkBubble", v1 = GetLocal().netID, v2 = str })
end

function OnConsoleMessage(str)
	LogToConsole("`w[`@hopp.to/nier`w] `b"..str)
end

function OnDroppedItem(id,amount)
	SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..id.."|\nitem_count|"..amount)
end

function OnWarning(str)
	SendVariant({ v0 = "OnAddNotification", v1 = "interface/atomic_button.rttex", v2 = str, v3 = "audio/hub_open.wav" })
end

function ProxyOpen()
opening = [[
add_label_with_icon|big|`bProxy Gazette``                                                            |left|11550|
add_spacer|small|
add_textbox|`9Welcome Back, ]]..GetLocal().name..[[|
add_textbox|`9Thanks For Purchase This Script|
add_textbox|`9Enjoy Proxy Made By: `w[`5Nier`w]|
add_textbox|`9Leaked Proxy: `w[`5fluffyhowl`w]|
add_spacer|small|
add_label_with_icon|small|`3Information``|left|8224|
add_textbox|`9/help `w(`7Show all commands`w)|
add_spacer|small|
add_label_with_icon|small|`3Change Log``|left|6128|
add_smalltext|`9Version: `21.4|
add_textbox|`w[`2+`w] `9Added Fast Trash Options|
add_textbox|`w[`2+`w] `9Added Command `2/exit|
add_textbox|`w[`2+`w] `9Added Command `2/res|
add_spacer|small|
add_label_with_icon|small|`3Our Website``|left|6128|
add_url_button||`9Click Here!!|noflags|https://hopp.to/nier|Launch to our website?|0|0|
add_url_button||`9Click Here!!|noflags|https://github.com/fluffyhowl|Launch to our website?|0|0|
add_quick_exit||
end_dialog|cmdend|Okey|
]]
SendVariant({ v0 = "OnDialogRequest", v1 = opening })
end
ProxyOpen()

function ProxyCommand()
cmd = [[
add_label_with_icon|big|`@Commands                                                         |left|7188|
add_spacer|small|
add_label_with_icon|small|`3Information``|left|8224|
add_textbox|`8/help `w(`7Show all commands`w)|
add_textbox|`2/web `w(`7Official Website`w)|
add_spacer|small|
add_label_with_icon|small|`3Customize``|left|9474|
add_textbox|`9/options `w(`7Toggles selectable features`w)|
add_spacer|small|
add_label_with_icon|small|`3Main Commands``|left|5772|
add_textbox|`9/logs `w(`7Log options`w)|
add_textbox|`9/blue `w(`bBlack `9>> `1Blue`w)|
add_textbox|`9/black `w(`1Blue `9>> `bBlack`w)|
add_textbox|`9/weather `w(`4Random `9W`8e`7a`6t`5h`4e`3r`w)|left|
add_textbox|`9/wp `w(`7[`2On`0/`4Off`7] Ez Pull Mode (cool)`w)|
add_textbox|`9/drop `w[`2id`w] [`2amount`w] (`7Drop `4VISUAL ITEM`w)|
add_textbox|`9/tp `w(`7[`2ON`0/`4OFF`0] Find x,y`w)|
add_textbox|`9/exit `w(`0[`4EXIT`0] `0World`w)|
add_textbox|`9/res `w(`2Respawn`w)|
add_spacer|small|
add_label_with_icon|small|`3Host Commands``|left|758|
add_textbox|`9/reme `w(`7[`2ON`0/`4OFF`0] reme spin checker`w)|
add_textbox|`9/qeme `w(`7[`2ON`0/`4OFF`0] qeme spin checker`w)|
add_textbox|`9/wd `w[`2amount`w] (`7Custom drop `9WL`w)|
add_textbox|`9/dd `w[`2amount`w] (`7Custom drop `1DL`w)|
add_textbox|`9/bd `w[`2amount`w] (`7Custom drop `cBGL`w)|
add_textbox|`9/bb `w[`2amount`w] (`7Custom drop `bBLACK`w)|
add_textbox|`9/wd3 `w[`2amount`w] (`7Custom drop X3 `9WL`w)|
add_textbox|`9/dd3 `w[`2amount`w] (`7Custom drop X3 `1DL`w)|
add_textbox|`9/bd3 `w[`2amount`w] (`7Custom drop X3 `cBGL`w)|
add_textbox|`9/bb3 `w[`2amount`w] (`7Custom drop X3 `bBLACK`w)|
add_spacer|small|
add_label|small|`3[BGL BANK Commands``|left|
add_textbox|`9/draw `w[`2amount`w] `7// `9/dw `w[`2amount`w] `w(`7Withdraw BGL from bank`w)|
add_textbox|`9/depo `w[`2amount`w] `7// `9/dp `w[`2amount`w] `w(`7Deposit BGL to bank`w)|
add_textbox|`9/drawall `w[`2amount`w] `7// `9/dwall `w(`7Withdraw all BGL from bank`w)|
add_textbox|`9/depoall `w[`2amount`w] `7// `9/dpall `w(`7Deposit all BGL to Bank `w)|
add_quick_exit||
add_spacer|small|
end_dialog|cmdend|Cancel|
]]
SendVariant({ v0 = "OnDialogRequest", v1 = cmd, })
end

function MenuLog()
logm = [[
add_label_with_icon|big|`bLogs Options``    |left|1436|
add_spacer|small|
add_button|spin|`wRoulette Wheel|noflags|0|
add_button|drop|`wDropped|noflags|0|
add_button|coll|`wCollected|noflags|0|
add_spacer|small|
add_button|resetall|`4Reset All|noflags|0|
add_spacer|small|
add_quick_exit||
end_dialog|ah|Cancel||
]]
SendVariant({ v0 = "OnDialogRequest", v1 = logm })
end

function DropLog()
DialogDrop = [[
add_label_with_icon|big|`bDropped Logs|left|1436|
add_spacer|small|
add_button|resetd|`4Reset|noflags|0|
]]..logdrop..[[
add_spacer|small|
add_quick_exit||
end_dialog|logah|Close||
]]
SendVariant({ v0 = "OnDialogRequest", v1 = DialogDrop })
end

function CollectLog()
DialogCollect = [[
add_label_with_icon|big|`bCollected Logs|left|1436|
add_spacer|small|
add_button|resetc|`4Reset|noflags|0|
]]..logcollect..[[
add_spacer|small|
add_quick_exit||
end_dialog|logah|Close||
]]
SendVariant({ v0 = "OnDialogRequest", v1 = DialogCollect })
end

function isQeme(number)
    if number >= 10 then
        hasil = string.sub(number, -1)
    else
        hasil = number
    end
    return hasil
end

function getGame(num)
    if reme and not qeme then
        return "`9[`5REME: `6"..isReme(tonumber(num)).."`9]"
    elseif not reme and qeme then
        return "`9[`5QEME: `6"..isQeme(tonumber(num)).."`9]"
    else
        return ""
    end
end

function isReme(number)
    if number == 19 or number == 28 or number == 0 then
        hasil = 0
    else
        num1 = math.floor(number / 10)
        num2 = number % 10
        hasil = string.sub(tostring(num1 + num2), -1)
    end
    return hasil
end

function GetPlayerName(id)
	for _, peler in pairs(GetPlayerList()) do
		if peler.netID == id then
			return peler.name
		end
	end
end

function pelerspin(id)
	filterLog = {}
	for _, log in pairs(tablelogspin) do
		if log.netid == id then
			table.insert(filterLog,"\nadd_label_with_icon|small|"..log.spin.."|left|758|\n")
		end
	end
	SendVariant({
		v0 = "OnDialogRequest",
		v1 = [[
add_label_with_icon|big|]]..GetPlayerName(id)..[[ `bLogs|left|1436|
add_spacer|small|
]]..table.concat(filterLog)..[[
add_spacer|small|
add_quick_exit||
end_dialog|spinfilter|Close||
		]]
	})
end

function SpinLog()
    dialogSpin = {}
    for _,spin in pairs(tablelogspin) do
        table.insert(dialogSpin,spin.spin)
    end
    SendVariant({
    	v0 = "OnDialogRequest",
	    v1 = [[
add_label_with_icon|big|`bRoulette Logs|left|1436|
add_spacer|small|
add_button|resets|`4Reset|noflags|0|
add_smalltext|`9It Will Auto `4Reset `9When You Exit The `2World|
add_smalltext|`9Click The Wheel Button To View Specific Player Logs|
]]..table.concat(dialogSpin)..[[
add_spacer|small|
add_quick_exit||
end_dialog|logah|Close||
		]]
    })
end

function cmd(type,str)
	if str:find("/help") then
		LogToConsole("`6/help")
		ProxyCommand()
		return true
	elseif str:find("/web") then
	    return true
	elseif str:find("/logs") then
		LogToConsole("`6/logs")
		MenuLog()
		return true
	elseif str:find("buttonClicked|spin") then
		SpinLog()
		return true
	elseif str:find("buttonClicked|drop") then
		DropLog()
		return true
	elseif str:find("buttonClicked|coll") then
		CollectLog()
		return true
	elseif str:find("buttonClicked|resetall") then
		tablelogspin = {}
		logdrop = ""
		logcollect = ""
		OnTextOverlay("`4Reset `wAll Logs")
		return true
	elseif str:find("buttonClicked|resets") then
		tablelogspin = {}
		OnTextOverlay("`wRoulette Logs Has Been `4Reset")
		return true
	elseif str:find("buttonClicked|resetd") then
		logdrop = ""
		OnTextOverlay("`wDropped Logs Has Been `4Reset")
		return true
	elseif str:find("buttonClicked|resetc") then
		logcollect = ""
		OnTextOverlay("`wCollected Logs Has Been `4Reset")
		return true
	end
	
	if str:find("action|wrench\n|netid|(%d+)") then 
	idcoy = str:match("action|wrench\n|netid|(%d+)")
		if pull == true then
			for _, player in pairs(GetPlayerList()) do
				if player.netID == tonumber(idcoy) and tonumber(idcoy) ~= GetLocal().netID then
					SendPacket(2,"action|dialog_return\ndialog_name|popup\nnetID|"..idcoy.."|\nbuttonClicked|pull")
					OnTextOverlay("`wSuccessfully `5Pulling "..player.name)
					return true
				end
			end
		end
	end
	
	if str:find("/wd (%d+)") then
	count = str:match("/wd (%d+)")
	LogToConsole("`6/wd "..count)
		s = tonumber(count)
		if GetItemCount(242) < s then
			OnWear(1796)
		end
		OnDroppedItem(242,count)
		OnConsoleMessage("`9Dropped `2"..count.. " `9World Lock")
		OnTextOverlay("`2Successfully `9Dropped `2"..count.." `9World Lcok")
		logdrop = logdrop.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Dropped `2"..count.." `9World Lock|left|242|\n"
		return true
	elseif str:find("/dd (%d+)") then
	count = str:match("/dd (%d+)")
	LogToConsole("`6/dd "..count)
	s = tonumber(count)
		if GetItemCount(1796) < s then
			OnWear(242)
			OnWear(7188)
		end
		OnDroppedItem(1796,count)
		OnConsoleMessage("`9Dropped `2"..count.. " `9Diamond Lock")
		OnTextOverlay("`2Successfully `9Dropped `2"..count.." `9Diamond Lcok")
		logdrop = logdrop.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Dropped `2"..count.." `9Diamond Lock|left|1796|\n"
		return true
	elseif str:find("/bd (%d+)") then
	count = str:match("/bd (%d+)")
	LogToConsole("`6/bd "..count)
		OnDroppedItem(7188,count)
		OnConsoleMessage("`9Dropped `2"..count.. " `9Blue Gem Lock")
		OnTextOverlay("`9Successfully Dropped `2"..count.." `9Blue Gem Lcok")
		logdrop = logdrop.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Dropped `2"..count.." `9Blue Gem Lock|left|7188|\n"
		return true
	elseif str:find("/bb (%d+)") then
	count = str:match("/bb (%d+)")
	LogToConsole("`6/bb "..count)
		OnDroppedItem(11550,count)
		OnConsoleMessage("`9Dropped `2"..count.. " `9Black Gem Lock")
		OnTextOverlay("`2Successfully `9Dropped `2"..count.." `9Black Gem Lcok")
		logdrop = logdrop.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Dropped `2"..count.." `9Black Gem Lock|left|11550|\n"
		return true
	elseif str:find("/wd3 (%d+)") then
	count = str:match("/wd3 (%d+)")
	LogToConsole("`6/wd3 "..count)
	count3 = count * 3
	s = tonumber(count)
		if GetItemCount(242) < s then
			OnWear(1796)
		end
		OnDroppedItem(242,count3)
		OnConsoleMessage("`w(`2"..count.." `9x `23`w) `9Dropped `2"..count3.." `9World Lock")
		OnTextOverlay("`2Successfully `9Dropped `2"..count3.." `9World Lcok")
		logdrop = logdrop.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Dropped `2"..count3.." `9World Lock|left|242|\n"
		return true
	elseif str:find("/dd3 (%d+)") then
	count = str:match("/dd3 (%d+)")
	LogToConsole("`6/dd3 "..count)
	count3 = count * 3
	s = tonumber(count)
		if GetItemCount(1796) < s then
			OnWear(7188)
			OnWear(242)
		end
		OnDroppedItem(1796,count3)
		OnConsoleMessage("`w(`2"..count.." `9x `23`w) `9Dropped `2"..count3.." `9Diamond Lock")
		OnTextOverlay("`2Successfully `9Dropped `2"..count3.." `9Diamond Lcok")
		logdrop = logdrop.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Dropped `2"..count3.." `9Diamond Lock|left|1796|\n"
		return true
	elseif str:find("/bd3 (%d+)") then
	count = str:match("/bd3 (%d+)")
	LogToConsole("`6/bd3 "..count)
	count3 = count * 3
		OnDroppedItem(7188,count3)
		OnConsoleMessage("`w(`2"..count.." `9x `23`w) `9Dropped `2"..count3.." `9Blue Gem Lock")
		OnTextOverlay("`2Successfully `9Dropped `2"..count3.." `9Blue Gem Lcok")
		logdrop = logdrop.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Dropped `2"..count3.." `9Blue Gem Lock|left|7188|\n"
		return true
	elseif str:find("/bb3 (%d+)") then
	count = str:match("/bb3 (%d+)")
	LogToConsole("`6/bb3 "..count)
	count3 = count * 3
		OnDroppedItem(11550,count3)
		OnConsoleMessage("`w(`2"..count.." `9x `23`w) `9Dropped `2"..count3.." `9Black Gem Lock")
		OnTextOverlay("`2Successfully `9Dropped `2"..count3.." `9Black Gem Lcok")
		logdrop = logdrop.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Dropped `2"..count3.." `9Black Gem Lock|left|11550|\n"
		return true
	elseif str:find("/drop (%d+)%s(%d+)") then
	itemid,itemamount = str:match("(%d+)%s(%d+)")
	LogToConsole("`6/drop "..itemid.." "..itemamount)
		itemid = tonumber(itemid)
		itemamount = tonumber(itemamount)
		SendPacket(2, "action|input\n|text|/spawn "..itemid.." "..itemamount)
		OnConsoleMessage("`9Spawning Item")
		OnConsoleMessage("`9ID: `2"..itemid)
		OnConsoleMessage("`9Amount: `2"..itemamount)
		return true
	end
	
	if str:find("/wp") then
	LogToConsole("`6/wp")
		if pull == false then
			pull = true
			OnTextOverlay("`2Enabled `wWrench `5Pull")
			return true
		else
			pull = false
			OnTextOverlay("`4Disabled `wWrench `5Pull")
			return true
		end
	end
	
	if str:find("/weather") then
	LogToConsole("`6/weather")
		weatherid = math.random(1,66)
		SendVariant({ v0 = "OnSetCurrentWeather", v1 = weatherid })
		return true
	end
	
	if str:find("/exit") then
		SendPacket(3, "action|join_request\nname|exit")
		return true
	elseif str:find("/res") then
		SendPacket(2, "action|respawn")
		return true
	end
	
	if str:find("/blue") then
		if GetItemCount(7188) < 100 then
			OnConsoleMessage("`9You Don't Have Enough `eBlue Gem Locks")
			return true
		else
			LogToConsole("`6/blue")
			SendPacket(2,"action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_blue_gem_lock")
			OnConsoleMessage("`9You Compressed a `w100 `eBlue Gem Locks `winto `bBlack Gem Locks`w!")
			return true
		end
	elseif str:find("/black") then
		if GetItemCount(11550) < 1 then
			OnConsoleMessage("`9You Don't Have Enough `bBlack Gem Locks")
			return true
		else
			LogToConsole("`6/black")
			SendPacket(2,"action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_black_gem_lock")
			OnConsoleMessage("`bBlack Gem Lock `9into a `w100 `eBlue Gem Locks `0[ `4Done `0]")
			return true
		end
	end
	
	if str:find("fcbgl|1") then
		cbgl = true
		OnTextOverlay("`2Saved")
	else if str:find("fcbgl|0") then
		cbgl = false
		OnTextOverlay("`2Saved")
	end
	end
	if str:find("notifad|1") then
		notif = true
		OnTextOverlay("`2Saved")
	else if str:find("notifad|0") then
		notif = false
		OnTextOverlay("`2Saved")
	end
	end
	if str:find("sdbb|1") then
		sdb = true
		OnTextOverlay("`2Saved")
	else if str:find("sdbb|0") then
		sdb = false
		OnTextOverlay("`2Saved")
	end
	end
	if str:find("ap|1") then
		autopull = true
		OnTextOverlay("`2Saved")
	else if str:find("ap|0") then
		autopull = false
		OnTextOverlay("`2Saved")
	end
	end
	if str:find("taiwl|1") then
		cvwl = true
		OnTextOverlay("`2Saved")
	else if str:find("taiwl|0") then
		cvwl = false
		OnTextOverlay("`2Saved")
	end
	end
	if str:find("fts|1") then
		fasttrash = true
		OnTextOverlay("`2Saved")
	else if str:find("fts|0") then
		fasttrash = false
		OnTextOverlay("`2Saved")
	end
	end
	
	if str:find("/reme") then
	LogToConsole("`6/reme")
		if reme == false then
			reme = true
			qeme = false
			OnTextOverlay("`2Enabled `9Reme Spin")
			return true
		else
			reme = false
			qeme = false
			OnTextOverlay("`4Disabled `9Reme Spin")
			return true
		end
	end
	if str:find("/qeme") then
	LogToConsole("`6/qeme")
		if qeme == false then
			qeme = true
			reme = false
			OnTextOverlay("`2Enabled `9Qeme Spin")
			return true
		else
			qeme = false
			reme = false
			OnTextOverlay("`4Disabled `9Qeme Spin")
			return true
		end
	end
	
	if str:find("/tp") then
	LogToConsole("`6/tp")
		if tpdisplay == false then
			tpdisplay = true
			OnTextOverlay("`2Enabled `9FindPath To Display")
			return true
		else
			tpdisplay = false
			OnTextOverlay("`4Disabled `9FindPath To Display")
			return true
		end
	end
	
	if str:find("join_request") then
		tablelogspin = {}
	end
	
	if str:find("/options") then
	LogToConsole("`6/options")
        fastcbgl = OnBoxUpdated(cbgl)
        notifblock = OnBoxUpdated(notif)
        sdbblock = OnBoxUpdated(sdb)
        apull = OnBoxUpdated(autopull)
        cvwlon = OnBoxUpdated(cvwl)
        trashon = OnBoxUpdated(fasttrash)
        SendVariant({
            v0 = "OnDialogRequest",
            v1 = [[
add_label_with_icon|big|`bOptions Page``  |left|828|
add_spacer|small|
add_checkbox|fcbgl|`2Enabled `9Fast Change BGL|]]..fastcbgl..[[|
add_checkbox|notifad|`2Enabled `9Block Adventure Notifications|]]..notifblock..[[|
add_checkbox|sdbb|`2Enabled `9Block SDB|]]..sdbblock..[[|
add_checkbox|ap|`2Enabled `9Auto Pull|]]..apull..[[|
add_checkbox|taiwl|`2Enabled `9Auto Sharttered World Lock Into Diamond Locks|]]..cvwlon..[[|
add_checkbox|fts|`2Enabled `9Fast Trash|]]..trashon..[[|
add_spacer|small|
end_dialog|op|Close|Apply|
            ]]
        })
        return true
	end
	
	if str:find("/depo (%d+)") or str:find("/dp (%d+)") then
	count = str:match("/depo (%d+)") or str:match("/dp (%d+)")
	LogToConsole("`6/"..str:gsub("action|input\n|text|/", ""))
		SendPacket(2,"action|dialog_return\ndialog_name|bank_deposit\nbgl_count|"..count)
		OnTextOverlay("`9Deposit `2"..count.." `9Blue Gem Lock")
		return true
	elseif str:find("/dw (%d+)") or str:find("/draw (%d+)") then
	count = str:match("/dw (%d+)") or str:match("/draw (%d+)")
	LogToConsole("`6/"..str:gsub("action|input\n|text|/", ""))
		SendPacket(2,"action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|"..count)
		OnTextOverlay("`9Withdraw `2"..count.." `9Blue Gem Lock")
		return true
	elseif str:find("/depoall") or str:find("/dpall") then
	LogToConsole("`6/"..str:gsub("action|input\n|text|/", ""))
		SendPacket(2,"action|dialog_return\ndialog_name|bank_deposit\nbgl_count|"..GetItemCount(7188))
		OnTextOverlay("`9Deposit `2"..GetItemCount(7188).." `9Blue Gem Lock")
		return true
	elseif str:find("/drawall") or str:find("/dwall") then
	LogToConsole("`6/"..str:gsub("action|input\n|text|/", ""))
		SendPacket(2,"action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|250")
		return true
	end
	
	if str:find("buttonClicked|(%d+)") then
		netid = str:match("buttonClicked|(%d+)")
		pelerspin(tonumber(netid))
		return true
	end
	return false
end
AddHook(cmd, "OnSendPacket")

function var(var)
	if var.v1:find("OnConsoleMessage") and var.v2:find("`4Unknown command.") then
		OnConsoleMessage("`2Please type `9/help `2to get the available commands")
		return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("spun the wheel") and var.v2:find("<") and var.v2:find(">") then
		OnConsoleMessage(var.v2.." `w[`4FAKE`w]")
		return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("spun the wheel") then
		OnConsoleMessage("`w[`2REAL`w] "..var.v2)
		return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("Collected") and var.v2:find("(%d+) World Lock") then
		count = var.v2:match("(%d+) World Lock")
		if cvwl == true then
		s = tonumber(count)
			if GetItemCount(242) >= 100 or s >= 99 then
				OnWear(242)
			end
		end
		logcollect = logcollect.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Collected `2"..count.." `9World Lock|left|242|\n"
		OnConsoleMessage("`9Collected `2"..count.." `9World Lock")
		OnTextOverlay("`9Collected `2"..count.." `9World Lock")
		return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("Collected") and var.v2:find("(%d+) Diamond Lock") then
		count = var.v2:match("(%d+) Diamond Lock")
			s = tonumber(count)
			for _, tile in pairs(GetTiles()) do
				if tile.fg == 3898 then
					if GetItemCount(1796) >= 100 or s >= 99 then
						SendPacket(2,"action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..tile.x.."|\ny|"..tile.y.."|\nbuttonClicked|bglconvert")
					end
				end
			end
			OnConsoleMessage("`9Collected `2"..count.." `9Diamond Lock")
			OnTextOverlay("`9Collected `2"..count.." `9Diamond Lock")
			logcollect = logcollect.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Collected `2"..count.." `9Diamond Lock|left|1796|\n"
			return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("Collected") and var.v2:find("(%d+) Blue Gem Lock") then
		count = var.v2:match("(%d+) Blue Gem Lock")
			s = tonumber(count)
			if GetItemCount(7188) >= 100 or s >= 99 then
				SendPacket(2,"action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
			end
			logcollect = logcollect.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Collected `2"..count.." `9Blue Gem Lock|left|7188|\n"
			OnConsoleMessage("`9Collected `2"..count.." `9Blue Gem Lock")
			OnTextOverlay("`9Collected `2"..count.." `9Blue Gem Lock")
			return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("Collected") and var.v2:find("(%d+) Black Gem Lock") then
		count = var.v2:match("(%d+) Black Gem Lock")
		logcollect = logcollect.."\nadd_label_with_icon|small|`w[`7"..os.date("%H:%M").."`w] `9You've Collected `2"..count.." `9Black Gem Lock|left|11550|\n"
		OnConsoleMessage("`9Collected `2"..count.." `9Black Gem Lock")
		OnTextOverlay("`9Collected `2"..count.." `9Black Gem Lock")
		return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("CT:") and var.v2:find("from") then
		sbtext = var.v2:match("from(.+)")
		LogToConsole("`w[`^PROXY-SB`w] "..sbtext)
		return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("World Locked") then
		wlcheck = GetItemCount(242)
		dlcheck = GetItemCount(1796) * 100
		bglcheck = GetItemCount(7188) * 10000
		irengcheck = GetItemCount(11550) * 1000000
		resultscheck = wlcheck + dlcheck + bglcheck + irengcheck
		OnConsoleMessage("`9Entered The World")
		OnConsoleMessage("`9Checking Balance: `2Succeed")
		OnConsoleMessage("`9Balance: `2"..resultscheck.." `9World Lock")
		return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find("`4WARNING:") then
		return true
	elseif var.v1:find("OnConsoleMessage") and var.v2:find(">> You've earnt") then
		LogToConsole("`b=====================================")
		LogToConsole("`4                    WARNING FROM PROXY")
		LogToConsole("`9         Make Sure To Always Check System")
		LogToConsole("`b=====================================")
		return true
	elseif var.v1:find("OnConsoleMessage") then
		OnConsoleMessage(var.v2)
		return true
	end
	
	if var.v1:find("OnAddNotification") then
		if notif == true then
			OnConsoleMessage("`4Detected Notification Adventure. `2Auto Blocks Notifications")
			OnConsoleMessage("`9With Notifications: "..var.v3)
			return true
		end
	end
	
	if var.v1:find("OnSDBroadcast") then
		if sdb == true then
			return true
		end
	end
	
	if var.v1:find("OnTalkBubble") and var.v3:find("spun the wheel") and var.v3:find("<") and var.v3:find(">") then
		SendVariant({ v0 = var.v1, v1 = var.v2, v2 = ""..var.v3.." `w[`4FAKE`w]", v3 = var.v4})
		table.insert(tablelogspin,{spin = "\nadd_label_with_icon_button|small|`w[`7"..os.date("%H:%M").."`w] `w[`4FAKE`w] "..var.v3.."|left|758|"..var.v2.."|\n",netid = var.v2})
		SendVariant({ v0 = "OnTextOverlay", v1 = "`9Detected `4FAKE `9Spin\n`9Player: "..GetPlayerName(var.v2) })
		return true
	end
	
	if var.v1:find("OnTalkBubble") and var.v3:find("spun the wheel") then 
		if reme or qeme then
			local num = string.gsub(string.gsub(var.v3:match("and got (.+)"), "!%]", ""), "`", "")
			local onlynumber = string.sub(num, 2)
			local clearspace = string.gsub(onlynumber, " ", "")
			local h = string.gsub(string.gsub(clearspace, "!7", ""), "]", "")
			SendVariant({ v0 = var.v1, v1 = var.v2, v2 = "`w[`2REAL`w] "..var.v3.." "..getGame(tonumber(h)), v3 = var.v4})
			table.insert(tablelogspin,{spin = "\nadd_label_with_icon_button|small|`w[`7"..os.date("%H:%M").."`w] `w[`2REAL`w] "..var.v3.."|left|758|"..var.v2.."|\n",netid = var.v2})
			return true
		end
	end
	
	if var.v1:find("OnTalkBubble") and var.v3:find("spun the wheel") then
		SendVariant({ v0 = var.v1, v1 = var.v2, v2 = "`w[`2REAL`w] "..var.v3.."", v3 = var.v4})
		table.insert(tablelogspin,{spin = "\nadd_label_with_icon_button|small|`w[`7"..os.date("%H:%M").."`w] `w[`2REAL`w] "..var.v3.."|left|758|"..var.v2.."|\n",netid = var.v2})
		return true
	end
	
	if var.v1:find("OnDialogRequest") and var.v2:find("`4Recycle") then
		itemid = var.v2:match("item_trash|(%d+)")
		itemcount = var.v2:match("you have (%d+)")
		if fasttrash == true then
			SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|"..itemid.."|\nitem_count|"..itemcount)
			return true
		end
	end
	
	if var.v1:find("OnDialogRequest") and var.v2:find("Wow, that's fast delivery.") then
		return true
	end
	
	if var.v1:find("OnDialogRequest") and var.v2:find("`wTelephone") then
		if cbgl == true then
			x = var.v2:match("embed_data|x|(%d+)")
			y = var.v2:match("embed_data|y|(%d+)")
			SendPacket(2,"action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..x.."|\ny|"..y.."|\nbuttonClicked|bglconvert")
			OnTextOverlay("`2Successfully `9Change Blue Gem Lock")
			return true
		end
	end

	if var.v1:find("OnTalkBubble") and var.v3:find("entered,") then
	    if autopull == true then
			SendPacket(2,"action|dialog_return\ndialog_name|popup\nnetID|"..var.v2.."|\nbuttonClicked|pull")
		end
	end
	
	if var.v1:find("OnRequestWorldSelectMenu") then
		tablelogspin = {}
		wlcheck = GetItemCount(242)
		dlcheck = GetItemCount(1796) * 100
		bglcheck = GetItemCount(7188) * 10000
		irengcheck = GetItemCount(11550) * 1000000
		resultscheck = wlcheck + dlcheck + bglcheck + irengcheck
		OnConsoleMessage("`9Exiting The World")
		OnConsoleMessage("`9Checking Balance: `2Succeed")
		OnConsoleMessage("`9Balance: `2"..resultscheck.." `9World Lock")
	end
	return false
end
AddHook(var, "OnVariant")

function raw(a)
	if tpdisplay == true then
		if a.type == 3 and a.value == 18 then
			for _, tile in pairs(GetTiles()) do
				if tile.fg == 1422 or tile.fg == 2488 then
					if tile.x == a.px then
						FindPath(math.floor(a.px),math.floor(a.py))
						OnTextOverlay("`9Travelling `w(`2"..a.px.."`w,`2"..a.py.."`w)")
					end
				end
			end
		end
	end
	return false
end
AddHook(raw, "OnSendPacketRaw")