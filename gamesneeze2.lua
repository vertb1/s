local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local startTime = tick() -- Record start time

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()


local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false -- Forces AddToggle to AddCheckbox
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)

-- Detect executor
local function getExecutorName()
    local knownExecutors = {
        ["Velocity"] = identifyexecutor and identifyexecutor():find("Velocity"),
        ["Luna"] = identifyexecutor and identifyexecutor():find("Luna"),
        ["Xeno"] = identifyexecutor and identifyexecutor():find("Xeno"),
        ["Solara"] = identifyexecutor and identifyexecutor():find("Solara"),
        ["Wave"] = identifyexecutor and identifyexecutor():find("Wave"),
        ["AWP"] = identifyexecutor and identifyexecutor():find("AWP")
    }
    
    for name, found in pairs(knownExecutors) do
        if found then
            return name
        end
    end
    
    -- If identifyexecutor exists but no match in our list
    if identifyexecutor then
        return identifyexecutor()
    end
    
    -- Fallback if identifyexecutor isn't available
    return "Unknown"
end

local executorName = getExecutorName()

local Window = Library:CreateWindow({
	Title = "Ethrin hub | " .. executorName,
	Footer = "1.0.00.0 | Game Name",
	Icon = 127791977553442,
	NotifySide = "Right",
	ShowCustomCursor = false,
	Center = true,
	AutoShow = true,
})

local Tabs = {
	Main = Window:AddTab("Main", "swords"),
	Misc = Window:AddTab("Misc", "dumbbell"),
	Visuals = Window:AddTab("Visuals", "eye"),
	["Configuration"] = Window:AddTab("Configuration", "wrench"),
}

-- Main Tab
local MainLeftGroupBox = Tabs.Main:AddLeftGroupbox("Main Features")
local MainRightGroupBox = Tabs.Main:AddRightGroupbox("Other Features")

-- Auto Time Shoot function was removed

-- Misc Tab
local MiscLeftGroupBox = Tabs.Misc:AddLeftGroupbox("Miscellaneous")
local MiscRightGroupBox = Tabs.Misc:AddRightGroupbox("Utilities")

-- Visuals Tab
local VisualsLeftGroupBox = Tabs.Visuals:AddLeftGroupbox("ESP")
local VisualsRightGroupBox = Tabs.Visuals:AddRightGroupbox("World")



-- UI Settings
local MenuGroup = Tabs["Configuration"]:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})

MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "UI Size",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddDivider()

MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

-- Server Functions
local function serverHop()
    local servers = {}
    local req = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    local data = game:GetService("HttpService"):JSONDecode(req)
    
    if data and data.data then
        for i, v in ipairs(data.data) do
            if v.playing and type(v.playing) == "number" and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
        
        if #servers > 0 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
        else
            Library:Notify("No servers found", 3)
        end
    else
        Library:Notify("Failed to retrieve server data", 3)
    end
end

local function joinLowestServer()
    local servers = {}
    local req = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    local data = game:GetService("HttpService"):JSONDecode(req)
    
    if data and data.data then
        local lowestPlayers = math.huge
        local lowestServerId = nil
        
        for i, v in ipairs(data.data) do
            if v.playing and type(v.playing) == "number" and v.playing < lowestPlayers and v.id ~= game.JobId then
                lowestPlayers = v.playing
                lowestServerId = v.id
            end
        end
        
        if lowestServerId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, lowestServerId)
        else
            Library:Notify("No servers found", 3)
        end
    else
        Library:Notify("Failed to retrieve server data", 3)
    end
end

-- Server Section
local ServerGroup = Tabs["Configuration"]:AddRightGroupbox("Server")

ServerGroup:AddButton("Server Hop", function()
    serverHop()
end)

ServerGroup:AddButton("Rejoin Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)

ServerGroup:AddButton("Join Lowest Server", function()
    joinLowestServer()
end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("EthrinHub")
SaveManager:SetFolder("EthrinHub/configs")
SaveManager:SetSubFolder("game_" .. tostring(game.PlaceId)) -- Organize configs by game
SaveManager:BuildConfigSection(Tabs["Configuration"])
ThemeManager:ApplyToTab(Tabs["Configuration"])

SaveManager:LoadAutoloadConfig()

-- Calculate and display load time
local loadTime = tick() - startTime
local success = true -- Assume success, change this if you have error detection

-- Display the notification about load time
local function formatTime(seconds)
    return string.format("%.2f", seconds)
end

if success then
    Library:Notify("Ethrin hub loaded successfully in " .. formatTime(loadTime) .. " seconds", 5) -- 5 seconds display time
else
    Library:Notify("Ethrin hub encountered issues while loading (" .. formatTime(loadTime) .. " seconds)", 5)
end
