-- 🎯 Active Booth Finder + ID Copier
-- loadstring(game:HttpGet("رابط_هذا_الكود"))()

local player = game.Players.LocalPlayer
local currentListings = {}

-- 📡 البحث عن Booths نشطة
local function scanActiveBooths()
    currentListings = {}
    
    print("🔍 يمسح الـ Workspace...")
    
    -- ابحث في كل مكان
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        local lowerName = obj.Name:lower()
        
        -- إذا كان Booth أو Shop
        if lowerName:find("booth") or 
           lowerName:find("trade") or 
           lowerName:find("shop") or
           lowerName:find("stand") or
           lowerName:find("stall") then
            
            local listingInfo = {
                name = obj.Name,
                model = obj,
                position = obj.Position,
                parts = {}
            }
            
            -- جمع معلومات الـ Booth
            for _, part in pairs(obj:GetDescendants()) do
                -- مالك الـ Booth
                if part.Name:find("Owner") or part.Name:find("Seller") then
                    listingInfo.owner = part.Value or part.Text or tostring(part)
                end
                
                -- سعر الـ Item
                if part.Name:find("Price") or part.Name:find("Cost") or part.Name:find("Value") then
                    listingInfo.price = part.Value or tonumber(part.Text) or 0
                end
                
                -- نوع الـ Item
                if part.Name:find("Item") or part.Name:find("Pet") or part.Name:find("Product") then
                    listingInfo.item = part.Value or part.Text or part.Name
                end
                
                -- الـ ID
                if part.Name:find("ID") or part.Name:find("Id") or part.Name:find("Listing") then
                    listingInfo.listingId = part.Value or part.Text or part.Name
                end
                
                -- وصف
                if part.Name:find("Desc") or part.Name:find("Info") or part.Name:find("Detail") then
                    listingInfo.description = part.Value or part.Text
                end
            end
            
            -- إذا عندنا معلومات كافية
            if listingInfo.owner then
                -- أنشئ ID إذا مافيه
                if not listingInfo.listingId then
                    listingInfo.listingId = string.format("booth_%s_%s_%d",
                        listingInfo.owner,
                        listingInfo.item or "item",
                        math.random(1000, 9999)
                    )
                end
                
                -- أضف للقائمة
                table.insert(currentListings, listingInfo)
            end
        end
    end
    
    -- ابحث في ReplicatedStorage
    print("🔍 يمسح ReplicatedStorage...")
    local repStorage = game:GetService("ReplicatedStorage")
    
    -- ابحث عن RemoteEvents للـ Trading
    for _, obj in pairs(repStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local lowerName = obj.Name:lower()
            if lowerName:find("trade") or lowerName:find("booth") or lowerName:find("listing") then
                table.insert(currentListings, {
                    name = obj.Name,
                    type = "RemoteEvent",
                    path = obj:GetFullName(),
                    listingId = "remote_" .. obj.Name
                })
            end
        end
    end
    
    -- ابحث عن Folders للـ Trading
    for _, obj in pairs(repStorage:GetDescendants()) do
        if obj:IsA("Folder") then
            local lowerName = obj.Name:lower()
            if lowerName:find("trade") or lowerName:find("booth") or lowerName:find("market") then
                -- ابحث عن Listings داخل الفولدر
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("StringValue") or child:IsA("NumberValue") then
                        table.insert(currentListings, {
                            name = child.Name,
                            type = "ListingValue",
                            parent = obj.Name,
                            value = child.Value,
                            listingId = child.Name
                        })
                    end
                end
            end
        end
    end
    
    return currentListings
end

-- 📋 نسخ للحافظة
local function copyToClipboard(text)
    pcall(function()
        if setclipboard then
            setclipboard(text)
            return true
        end
        
        -- للموبايل: اطبع في الكونسول للنسخ اليدوي
        print("\n📋 انسخ النص التالي:\n")
        print("=" .. string.rep("=", 50))
        print(text)
        print("=" .. string.rep("=", 50))
        return false
    end)
end

-- 📱 واجهة الموبايل
local function createMobileUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BoothFinderUI"
    screenGui.ResetOnSpawn = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.98, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.01, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    
    -- العنوان
    local title = Instance.new("TextLabel")
    title.Text = "🎯 ACTIVE BOOTH FINDER"
    title.Size = UDim2.new(1, 0, 0.08, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    
    -- زر المسح
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 مسح Listings نشطة"
    scanBtn.Size = UDim2.new(0.9, 0, 0.1, 0)
    scanBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.SourceSansBold
    
    -- زر نسخ الكل
    local copyAllBtn = Instance.new("TextButton")
    copyAllBtn.Text = "📋 نسخ كل IDs"
    copyAllBtn.Size = UDim2.new(0.44, 0, 0.08, 0)
    copyAllBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
    copyAllBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
    copyAllBtn.TextColor3 = Color3.new(1, 1, 1)
    copyAllBtn.Visible = false
    
    -- زر نسخ الـ Booths فقط
    local copyBoothsBtn = Instance.new("TextButton")
    copyBoothsBtn.Text = "🏪 نسخ Booths فقط"
    copyBoothsBtn.Size = UDim2.new(0.44, 0, 0.08, 0)
    copyBoothsBtn.Position = UDim2.new(0.51, 0, 0.22, 0)
    copyBoothsBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    copyBoothsBtn.TextColor3 = Color3.new(1, 1, 1)
    copyBoothsBtn.Visible = false
    
    -- النتائج
    local resultsFrame = Instance.new("ScrollingFrame")
    resultsFrame.Size = UDim2.new(0.9, 0, 0.6, 0)
    resultsFrame.Position = UDim2.new(0.05, 0, 0.32, 0)
    resultsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    resultsFrame.BorderSizePixel = 1
    resultsFrame.ScrollBarThickness = 8
    resultsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local resultsLayout = Instance.new("UIListLayout")
    resultsLayout.Parent = resultsFrame
    resultsLayout.Padding = UDim.new(0, 5)
    
    -- العداد
    local counter = Instance.new("TextLabel")
    counter.Text = "🔍 اضغط لبدء المسح"
    counter.Size = UDim2.new(1, 0, 0.08, 0)
    counter.Position = UDim2.new(0, 0, 0.94, 0)
    counter.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    counter.TextColor3 = Color3.new(1, 1, 1)
    counter.TextWrapped = true
    
    -- 🔍 دالة المسح وعرض النتائج
    local function performScan()
        scanBtn.Text = "⏳ جاري المسح..."
        counter.Text = "🔍 يبحث عن Booths نشطة..."
        
        -- مسح المحتوى القديم
        for _, child in ipairs(resultsFrame:GetChildren()) do
            if not child:IsA("UIListLayout") then
                child:Destroy()
            end
        end
        
        task.spawn(function()
            local listings = scanActiveBooths()
            
            -- إظهار أزرار النسخ إذا وجدنا نتائج
            copyAllBtn.Visible = (#listings > 0)
            copyBoothsBtn.Visible = (#listings > 0)
            
            if #listings == 0 then
                counter.Text = "❌ ما لقيت أي Listings نشطة"
                return
            end
            
            -- عرض كل Listing
            local boothCount = 0
            local remoteCount = 0
            
            for i, listing in ipairs(listings) do
                local itemFrame = Instance.new("Frame")
                itemFrame.Size = UDim2.new(1, 0, 0, 70)
                itemFrame.BackgroundColor3 = listing.type and Color3.fromRGB(50, 30, 60) or Color3.fromRGB(40, 40, 50)
                itemFrame.BorderSizePixel = 1
                
                -- رقم واسم
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = i .. ". " .. listing.name
                nameLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
                nameLabel.Position = UDim2.new(0, 0, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = listing.type and Color3.new(1, 0.8, 1) or Color3.new(1, 1, 1)
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.PaddingLeft = UDim.new(0, 10)
                nameLabel.Font = Enum.Font.SourceSansBold
                
                -- الـ ID
                local idLabel = Instance.new("TextLabel")
                idLabel.Text = "ID: " .. listing.listingId
                idLabel.Size = UDim2.new(0.7, 0, 0.5, 0)
                idLabel.Position = UDim2.new(0, 0, 0.5, 0)
                idLabel.BackgroundTransparency = 1
                idLabel.TextColor3 = Color3.new(0.5, 1, 1)
                idLabel.TextXAlignment = Enum.TextXAlignment.Left
                idLabel.PaddingLeft = UDim.new(0, 10)
                idLabel.Font = Enum.Font.SourceSans
                
                -- زر نسخ هذا الـ ID
                local copyBtn = Instance.new("TextButton")
                copyBtn.Text = "📋"
                copyBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
                copyBtn.Position = UDim2.new(0.73, 0, 0.15, 0)
                copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
                copyBtn.TextColor3 = Color3.new(1, 1, 1)
                copyBtn.Font = Enum.Font.SourceSansBold
                
                -- حدث النسخ
                copyBtn.MouseButton1Click:Connect(function()
                    copyToClipboard(listing.listingId)
                    counter.Text = "✅ نسخت: " .. listing.listingId
                end)
                
                -- عد الأنواع
                if listing.type then
                    remoteCount = remoteCount + 1
                else
                    boothCount = boothCount + 1
                end
                
                nameLabel.Parent = itemFrame
                idLabel.Parent = itemFrame
                copyBtn.Parent = itemFrame
                itemFrame.Parent = resultsFrame
            end
            
            -- تحديث العداد
            counter.Text = string.format("✅ وجد %d Listings (%d Booths, %d Remotes)", 
                #listings, boothCount, remoteCount)
            
            scanBtn.Text = "🔍 مسح Listings نشطة"
        end)
    end
    
    -- 📋 نسخ كل IDs
    local function copyAllIDs()
        if #currentListings == 0 then
            counter.Text = "❌ لا توجد IDs للنسخ"
            return
        end
        
        local text = "-- جميع Listings IDs --\n\n"
        for i, listing in ipairs(currentListings) do
            text = text .. i .. ". " .. listing.listingId .. "\n"
            if listing.owner then
                text = text .. "   المالك: " .. listing.owner .. "\n"
            end
            if listing.item then
                text = text .. "   المنتج: " .. listing.item .. "\n"
            end
            text = text .. "\n"
        end
        
        if copyToClipboard(text) then
            counter.Text = "✅ نسخت " .. #currentListings .. " ID"
        else
            counter.Text = "📋 اذهب للكونسول وانسخ النص"
        end
    end
    
    -- 🏪 نسخ Booths فقط
    local function copyBoothsOnly()
        local boothListings = {}
        for _, listing in ipairs(currentListings) do
            if not listing.type then -- Boths مش Remotes
                table.insert(boothListings, listing)
            end
        end
        
        if #boothListings == 0 then
            counter.Text = "❌ لا توجد Booths للنسخ"
            return
        end
        
        local text = "-- Booths IDs فقط --\n\n"
        for i, listing in ipairs(boothListings) do
            text = text .. i .. ". " .. listing.listingId .. "\n"
            text = text .. "   المالك: " .. (listing.owner or "غير معروف") .. "\n"
            text = text .. "   المنتج: " .. (listing.item or "غير معروف") .. "\n"
            if listing.price then
                text = text .. "   السعر: " .. listing.price .. "\n"
            end
            text = text .. "\n"
        end
        
        if copyToClipboard(text) then
            counter.Text = "✅ نسخت " .. #boothListings .. " Booth"
        else
            counter.Text = "📋 اذهب للكونسول وانسخ النص"
        end
    end
    
    -- أحداث الأزرار
    scanBtn.MouseButton1Click:Connect(performScan)
    copyAllBtn.MouseButton1Click:Connect(copyAllIDs)
    copyBoothsBtn.MouseButton1Click:Connect(copyBoothsOnly)
    
    -- التجميع
    title.Parent = mainFrame
    scanBtn.Parent = mainFrame
    copyAllBtn.Parent = mainFrame
    copyBoothsBtn.Parent = mainFrame
    resultsFrame.Parent = mainFrame
    counter.Parent = mainFrame
    mainFrame.Parent = screenGui
    screenGui.Parent = player.PlayerGui
    
    return screenGui
end

-- أوامر الكونسول
_G.ScanBooths = function()
    return scanActiveBooths()
end

_G.CopyAllIDs = function()
    if #currentListings == 0 then
        scanActiveBooths()
    end
    
    local text = ""
    for i, listing in ipairs(currentListings) do
        text = text .. i .. ". " .. listing.listingId .. "\n"
    end
    
    copyToClipboard(text)
    return "نسخت " .. #currentListings .. " ID"
end

_G.CopyBoothIDs = function()
    if #currentListings == 0 then
        scanActiveBooths()
    end
    
    local boothCount = 0
    local text = ""
    for i, listing in ipairs(currentListings) do
        if not listing.type then
            boothCount = boothCount + 1
            text = text .. i .. ". " .. listing.listingId .. "\n"
        end
    end
    
    copyToClipboard(text)
    return "نسخت " .. boothCount .. " Booth ID"
end

-- بدء التشغيل
print([[
    
🎯 ACTIVE BOOTH FINDER v1.0
🔍 يبحث عن Listings نشطة للشراء

مميزات:
1. 🔍 يمسح Workspace عن Booths
2. 📋 ينسخ IDs للحافظة
3. 🏪 يفصل بين Booths و Remotes
4. 📱 واجهة موبايل سهلة

الأوامر:
_G.ScanBooths() - البحث
_G.CopyAllIDs() - نسخ كل IDs
_G.CopyBoothIDs() - نسخ Booths فقط

]])

-- إنشاء الواجهة
createMobileUI()

print("✅ Booth Finder جاهز للعمل!")
