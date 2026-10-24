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

        local screenGui = playerGui:FindFirstChild("TopbarStandard") or Instance.new("ScreenGui")
        if not screenGui.Parent then
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

        local holders = screenGui:FindFirstChild("Holders") or Instance.new("Frame")
        if not holders.Parent then
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

        local screenGuiCenter = playerGui:FindFirstChild("TopbarCentered") or screenGui:Clone()
        local holdersCenter = screenGuiCenter:FindFirstChild("Holders") or screenGuiCenter.Holders
        local function updateCenteredHoldersHeight()
                holdersCenter.Size = UDim2.new(1, 0, 0, GuiService.TopbarInset.Height+ySizeOffset)
        end
        if not screenGuiCenter.Parent then
                screenGuiCenter.Name = "TopbarCentered"
                screenGuiCenter.DisplayOrder = Icon.baseDisplayOrder
                screenGuiCenter.ScreenInsets = Enum.ScreenInsets.None
                screenGuiCenter.Parent = playerGui
        end
        container[screenGuiCenter.Name] = screenGuiCenter
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiCenter.DisplayOrder = Icon.baseDisplayOrder
        end)

        insetChanged:Connect(updateCenteredHoldersHeight)
        updateCenteredHoldersHeight()

        local screenGuiClipped = playerGui:FindFirstChild("TopbarStandardClipped") or screenGui:Clone()
        if not screenGuiClipped.Parent then
                screenGuiClipped.Name = "TopbarStandardClipped"
                screenGuiClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
                screenGuiClipped.Parent = playerGui
        end
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
        end)
        container[screenGuiClipped.Name] = screenGuiClipped

        local screenGuiCenterClipped = playerGui:FindFirstChild("TopbarCenteredClipped") or screenGuiCenter:Clone()
        if not screenGuiCenterClipped.Parent then
                screenGuiCenterClipped.Name = "TopbarCenteredClipped"
                screenGuiCenterClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
                screenGuiCenterClipped.Parent = playerGui
        end
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiCenterClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
        end)
        container[screenGuiCenterClipped.Name] = screenGuiCenterClipped

        local customHolderInstance = nil
        if Icon._getCustomHolder then
                customHolderInstance = Icon._getCustomHolder()
        end

        local holderReduction = -24
        local left = customHolderInstance or holders:FindFirstChild("Left") or Instance.new("ScrollingFrame")
        if not customHolderInstance and not left.Parent then
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
                left.Name = "Left"
                left:SetAttribute("IsAHolder", true)
        end

        local UIListLayout = left:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
        if not left:FindFirstChildOfClass("UIListLayout") then
                insetChanged:Connect(function()
                        UIListLayout.Padding = UDim.new(0, startInset)
                end)
                UIListLayout.FillDirection = Enum.FillDirection.Horizontal
                UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
                UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                UIListLayout.Parent = left
        end

        local center = holdersCenter:FindFirstChild("Center") or left:Clone()
        insetChanged:Connect(function()
                if not customHolderInstance then
                        if center:FindFirstChildOfClass("UIListLayout") then
                                center:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, startInset)
                        end
                end
        end)
        center.ScrollingEnabled = false
        if center:FindFirstChildOfClass("UIListLayout") then
                center:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Center
        end
        center.Name = "Center"
        if not center.Parent then
                center.Parent = holdersCenter
        end

        local right = holders:FindFirstChild("Right") or left:Clone()
        insetChanged:Connect(function()
                if not customHolderInstance then
                        if right:FindFirstChildOfClass("UIListLayout") then
                                right:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, startInset)
                        end
                end
        end)
        if right:FindFirstChildOfClass("UIListLayout") then
                right:FindFirstChildOfClass("UIListLayout").HorizontalAlignment = Enum.HorizontalAlignment.Right
        end
        right.Name = "Right"
        right.AnchorPoint = Vector2.new(1, 0)
        right.Position = UDim2.new(1, -12, 0, 0)
        if not right.Parent then
                right.Parent = holders
        end

        insetChanged:Fire(guiInset)

        return container
end
end
