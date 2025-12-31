-- 🎯 Fast Booth Finder - بحث سريع
-- loadstring(game:HttpGet("رابط_هذا_الكود"))()

local player = game.Players.LocalPlayer
local currentListings = {}

-- ⚡ بحث سريع في مناطق معينة فقط
local function fastBoothScan()
    currentListings = {}
    print("⚡ بحث سريع عن Booths...")
    
    -- ابحث في المناطق المهمة فقط
    local searchLocations = {
        game:GetService("Workspace"),
        game:GetService("Players").LocalPlayer.PlayerGui,
        game:GetService("ReplicatedStorage")
    }
    
    local boothCount = 0
    
    for _, location in ipairs(searchLocations) do
        pcall(function()
            -- ابحث فقط في أول 50 عنصر (سريع)
            local children = location:GetChildren()
            for i = 1, math.min(50, #children) do
                local obj = children[i]
                
                -- تحقق بسرعة
                if obj and obj.Name then
                    local lowerName = obj.Name:lower()
                    
                    -- إذا كان Booth أو Shop
                    if lowerName:find("booth") or 
                       lowerName:find("trade") or 
                       lowerName:find("shop") or
                       lowerName:find("stand") then
                        
                        boothCount = boothCount + 1
                        
                        -- معلومات أساسية فقط
                        local listingInfo = {
                            name = obj.Name,
                            type = "Booth",
                            location = location.Name
                        }
                        
                        -- حاول تجيب ID بسرعة
                        if obj:FindFirstChild("ID") then
                            listingInfo.listingId = obj.ID.Value
                        elseif obj:FindFirstChild("Id") then
                            listingInfo.listingId = obj.Id.Value
                        elseif obj:FindFirstChild("ListingId") then
                            listingInfo.listingId = obj.ListingId.Value
                        else
                            -- أنشئ ID تلقائي
                            listingInfo.listingId = "booth_" .. obj.Name .. "_" .. math.random(1000,9999)
                        end
                        
                        table.insert(currentListings, listingInfo)
                    end
                end
            end
        end)
    end
    
    -- ابحث في RemoteEvents للـ Trading (سريع)
    pcall(function()
        local buyRemote = game:GetService("ReplicatedStorage"):FindFirstChild("GameEvents")
        if buyRemote then
            local tradeEvents = buyRemote:FindFirstChild("TradeEvents")
            if tradeEvents then
                local booths = tradeEvents:FindFirstChild("Booths")
                if booths then
                    table.insert(currentListings, {
                        name = "BuyListing Remote",
                        type = "RemoteFunction",
                        listingId = "booth_system_main",
                        path = "ReplicatedStorage.GameEvents.TradeEvents.Booths.BuyListing"
                    })
                end
            end
        end
    end)
    
    print("✅ اكتمل البحث السريع!")
    return currentListings
end

-- 📱 واجهة سريعة للموبايل
local function createFastUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FastBoothFinder"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Text = "⚡ FAST BOOTH FINDER"
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    
    -- زر البحث السريع
    local fastScanBtn = Instance.new("TextButton")
    fastScanBtn.Text = "⚡ بحث سريع (3 ثواني)"
    fastScanBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
    fastScanBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
    fastScanBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    fastScanBtn.TextColor3 = Color3.new(1, 1, 1)
    fastScanBtn.Font = Enum.Font.SourceSansBold
    
    -- نتائج سريعة
    local results = Instance.new("TextLabel")
    results.Text = "اضغط ⚡ للبحث السريع"
    results.Size = UDim2.new(0.9, 0, 0.45, 0)
    results.Position = UDim2.new(0.05, 0, 0.4, 0)
    results.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    results.TextColor3 = Color3.new(1, 1, 1)
    results.TextWrapped = true
    
    -- زر النسخ
    local copyBtn = Instance.new("TextButton")
    copyBtn.Text = "📋 نسخ IDs"
    copyBtn.Size = UDim2.new(0.9, 0, 0.12, 0)
    copyBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
    copyBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
    copyBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBtn.Visible = false
    
    -- ⚡ البحث السريع
    fastScanBtn.MouseButton1Click:Connect(function()
        fastScanBtn.Text = "⏳ جاري البحث..."
        results.Text = "⚡ يبحث في مناطق محددة..."
        
        task.spawn(function()
            local listings = fastBoothScan()
            
            if #listings == 0 then
                results.Text = "❌ ما لقيت Booths\n\n" ..
                              "جرب:\n" ..
                              "1. اروح لمنطقة التداول\n" ..
                              "2. بعدين اضغط بحث"
                copyBtn.Visible = false
            else
                local text = "✅ وجد " .. #listings .. " Booth:\n\n"
                
                for i, listing in ipairs(listings) do
                    text = text .. i .. ". " .. listing.listingId .. "\n"
                    if i >= 5 then -- خليها قصيرة
                        text = text .. "... والمزيد\n"
                        break
                    end
                end
                
                results.Text = text
                copyBtn.Visible = true
            end
            
            fastScanBtn.Text = "⚡ بحث سريع (3 ثواني)"
        end)
    end)
    
    -- 📋 نسخ IDs
    copyBtn.MouseButton1Click:Connect(function()
        if #currentListings == 0 then return end
        
        local text = ""
        for i, listing in ipairs(currentListings) do
            text = text .. listing.listingId .. "\n"
        end
        
        -- نسخ للموبايل
        pcall(function()
            if setclipboard then
                setclipboard(text)
                results.Text = "✅ نسخت " .. #currentListings .. " ID"
            else
                results.Text = "📋 انسخ من الكونسول"
                print("\n📋 IDs:\n" .. text)
            end
        end)
    end)
    
    -- التجميع
    title.Parent = mainFrame
    fastScanBtn.Parent = mainFrame
    results.Parent = mainFrame
    copyBtn.Parent = mainFrame
    mainFrame.Parent = screenGui
    screenGui.Parent = player.PlayerGui
end

-- أوامر سريعة من الكونسول
_G.FastScan = function()
    return fastBoothScan()
end

_G.GetBoothIDs = function()
    if #currentListings == 0 then
        fastBoothScan()
    end
    
    local ids = {}
    for _, listing in ipairs(currentListings) do
        table.insert(ids, listing.listingId)
    end
    
    -- نسخ تلقائي
    pcall(function()
        if setclipboard then
            setclipboard(table.concat(ids, "\n"))
        end
    end)
    
    return ids
end

-- تشغيل سريع
print([[
    
⚡ FAST BOOTH FINDER
🎯 بحث سريع عن Booths نشطة

ملاحظة: البحث في Workspace كامل ياخد وقت!
هذا السكربت يبحث في مناطق محددة فقط.

الأوامر:
_G.FastScan() - بحث سريع
_G.GetBoothIDs() - جلب IDs ونسخها

]])

-- إنشاء الواجهة
createFastUI()

print("✅ Fast Booth Finder جاهز!")
