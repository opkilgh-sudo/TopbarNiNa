return function(_M)
local hasBecomeOldTheme = false
local previousInsetHeight = 0
        return function(Icon)

        local GuiService = game:GetService("GuiService")
        local Players =  game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local container = {}
        local Signal = _M.Signal
        local insetChanged = Signal.new()
        local guiInset = GuiService:GetGuiInset()
        local startInset = 0
        local yDownOffset = 0
        local ySizeOffset = 0
        local checkCount = 0
        local isConsoleScreen = false
        local isUsingVR = false
        local function checkInset(status)
                local currentHeight = GuiService.TopbarInset.Height
                local isOldTopbar = currentHeight <= 36

                isConsoleScreen = GuiService:IsTenFootInterface()
                isUsingVR = UserInputService.VREnabled
                Icon.isOldTopbar = isOldTopbar
                checkCount += 1
                if currentHeight == 0 and status == nil then
                        task.defer(function()
                                task.wait(8)
                                checkInset("ForceConvertToOld")
                        end)
                elseif checkCount == 1 then
                        task.delay(5, function()
                                local localPlayer = Players.LocalPlayer
                                localPlayer:WaitForChild("PlayerGui")
                                if checkCount == 1 then
                                        checkInset()
                                end
                        end)
                end

                if Icon.isOldTopbar and not isConsoleScreen and not isUsingVR and hasBecomeOldTheme == false and (currentHeight ~= 0 or status == "ForceConvertToOld") then
                        hasBecomeOldTheme = true
                        task.defer(function()
                                local Classic = _M.ThemesClassic
                                Icon.modifyBaseTheme(Classic)

                                local function decideToHideTopbar()
                                        if GuiService.MenuIsOpen then
                                                Icon.setTopbarEnabled(false, true)
                                        else
                                                Icon.setTopbarEnabled()
                                        end
                                end
                                GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(decideToHideTopbar)
                                decideToHideTopbar()
                        end)
                end

                guiInset = GuiService:GetGuiInset()
                startInset = if isOldTopbar then 12 else guiInset.Y - 50
                yDownOffset = if isOldTopbar then 2 else 0 
                ySizeOffset = -2
                if isConsoleScreen then
                        startInset = 10
                        yDownOffset = 0 
                end
                if GuiService.TopbarInset.Height == 0 and not hasBecomeOldTheme then
                        yDownOffset += 13
                        ySizeOffset = 50
                end

                insetChanged:Fire(guiInset)
                local insetHeight = guiInset.Y
                if insetHeight ~= previousInsetHeight then
                        previousInsetHeight = insetHeight
                        task.defer(function()
                                Icon.insetHeightChanged:Fire(insetHeight)
                        end)
                end

        end
        GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(checkInset)
        checkInset("FirstTime")

        local localPlayer = Players.LocalPlayer
        local playerGui = localPlayer:WaitForChild("PlayerGui")

        -- ระบบเคลียร์ตัวซ้ำ: สแกนหาและทำลายตัวที่ซ้ำกันทิ้งให้เหลือแค่อันเดียวอันแรกสุด
        for _, name in ipairs({"TopbarStandard", "TopbarCentered", "TopbarStandardClipped", "TopbarCenteredClipped"}) do
                local first = true
                for _, child in ipairs(playerGui:GetChildren()) do
                        if child.Name == name then
                                if first then
                                        first = false
                                else
                                        pcall(function() child:Destroy() end)
                                end
                        end
                end
        end

        local screenGui = playerGui:FindFirstChild("TopbarStandard")
        if not screenGui then
                screenGui = Instance.new("ScreenGui")
                screenGui.Name = "TopbarStandard"
                screenGui.Enabled = true
                screenGui.DisplayOrder = Icon.baseDisplayOrder
                screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                screenGui.IgnoreGuiInset = true
                screenGui.ResetOnSpawn = false
                screenGui.ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets
                screenGui.Parent = playerGui
        end
        container[screenGui.Name] = screenGui
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGui.DisplayOrder = Icon.baseDisplayOrder
        end)

        local holders = screenGui:FindFirstChild("Holders")
        if not holders then
                holders = Instance.new("Frame")
                holders.Name = "Holders"
                holders.BackgroundTransparency = 1
                holders.Visible = true
                holders.ZIndex = 1
                holders.Parent = screenGui
        end
        insetChanged:Connect(function()
                local holderY = if isUsingVR then 36 else 56
                local holderSize = if isConsoleScreen then UDim2.new(1, 0, 0, holderY) else UDim2.new(1, 0, 1, ySizeOffset)
                holders.Position = UDim2.new(0, 0, 0, yDownOffset)
                holders.Size = holderSize
        end)

        local screenGuiCenter = playerGui:FindFirstChild("TopbarCentered")
        if not screenGuiCenter then
                screenGuiCenter = screenGui:Clone()
                screenGuiCenter.Name = "TopbarCentered"
                screenGuiCenter.DisplayOrder = Icon.baseDisplayOrder
                screenGuiCenter.ScreenInsets = Enum.ScreenInsets.None
                screenGuiCenter.Parent = playerGui
        end
        local holdersCenter = screenGuiCenter:FindFirstChild("Holders") or screenGuiCenter.Holders
        local function updateCenteredHoldersHeight()
                holdersCenter.Size = UDim2.new(1, 0, 0, GuiService.TopbarInset.Height+ySizeOffset)
        end
        container[screenGuiCenter.Name] = screenGuiCenter
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiCenter.DisplayOrder = Icon.baseDisplayOrder
        end)

        insetChanged:Connect(updateCenteredHoldersHeight)
        updateCenteredHoldersHeight()

        local screenGuiClipped = playerGui:FindFirstChild("TopbarStandardClipped")
        if not screenGuiClipped then
                screenGuiClipped = screenGui:Clone()
                screenGuiClipped.Name = "TopbarStandardClipped"
                screenGuiClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
                screenGuiClipped.Parent = playerGui
        end
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
        end)
        container[screenGuiClipped.Name] = screenGuiClipped

        local screenGuiCenterClipped = playerGui:FindFirstChild("TopbarCenteredClipped")
        if not screenGuiCenterClipped then
                screenGuiCenterClipped = screenGuiCenter:Clone()
                screenGuiCenterClipped.Name = "TopbarCenteredClipped"
                screenGuiCenterClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
                screenGuiCenterClipped.Parent = playerGui
        end
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiCenterClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
        end)
        container[screenGuiCenterClipped.Name] = screenGuiCenterClipped

        local holderReduction = -24
        local left = holders:FindFirstChild("Left")
        if not left then
                left = Instance.new("ScrollingFrame")
                left:SetAttribute("IsAHolder", true)
                left.Name = "Left"
                insetChanged:Connect(function()
                        left.Position = UDim2.fromOffset(startInset, 0)
                end)
                left.Size = UDim2.new(1, holderReduction, 1, 0)
                left.BackgroundTransparency = 1
                left.Visible = true
                left.ZIndex = 1
                left.Active = false
                left.ClipsDescendants = true
                left.HorizontalScrollBarInset = Enum.ScrollBarInset.None
                left.CanvasSize = UDim2.new(0, 0, 1, -1)
                left.AutomaticCanvasSize = Enum.AutomaticSize.X
                left.ScrollingDirection = Enum.ScrollingDirection.X
                left.ScrollBarThickness = 0
                left.BorderSizePixel = 0
                left.Selectable = false
                left.ScrollingEnabled = false
                left.ElasticBehavior = Enum.ElasticBehavior.Never
                left.Parent = holders
        else
                left:SetAttribute("IsAHolder", true)
        end

        local UIListLayout = left:FindFirstChildOfClass("UIListLayout")
        if not UIListLayout then
                UIListLayout = Instance.new("UIListLayout")
                insetChanged:Connect(function()
                        UIListLayout.Padding = UDim.new(0, startInset)
                end)
                UIListLayout.FillDirection = Enum.FillDirection.Horizontal
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                UIListLayout.Parent = left
        end

        local center = holdersCenter:FindFirstChild("Center")
        if not center then
                center = left:Clone()
                center.Name = "Center"
                center.Parent = holdersCenter
        end
        insetChanged:Connect(function()
                if center:FindFirstChildOfClass("UIListLayout") then
                        center:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, startInset)
                end
        end)
        center.ScrollingEnabled = false
        if center:FindFirstChildOfClass("UIListLayout") then
                center:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Center
        end

        local right = holders:FindFirstChild("Right")
        if not right then
                right = left:Clone()
                right.Name = "Right"
                right.AnchorPoint = Vector2.new(1, 0)
                right.Position = UDim2.new(1, -12, 0, 0)
                right.Parent = holders
        end
        insetChanged:Connect(function()
                if right:FindFirstChildOfClass("UIListLayout") then
                        right:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, startInset)
                end
        end)
        if right:FindFirstChildOfClass("UIListLayout") then
                right:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Right
        end

        insetChanged:Fire(guiInset)

        return container
end
end
