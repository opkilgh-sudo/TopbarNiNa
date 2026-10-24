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

        local screenGui = playerGui:WaitForChild("TopbarStandard")
        container[screenGui.Name] = screenGui
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGui.DisplayOrder = Icon.baseDisplayOrder
        end)

        local holders = screenGui:WaitForChild("Holders")
        insetChanged:Connect(function()
                local holderY = if isUsingVR then 36 else 56
                local holderSize = if isConsoleScreen then UDim2.new(1, 0, 0, holderY) else UDim2.new(1, 0, 1, ySizeOffset)
                holders.Position = UDim2.new(0, 0, 0, yDownOffset)
                holders.Size = holderSize
        end)

        local screenGuiCenter = playerGui:WaitForChild("TopbarCentered")
        local holdersCenter = screenGuiCenter:WaitForChild("Holders")
        local function updateCenteredHoldersHeight()
                holdersCenter.Size = UDim2.new(1, 0, 0, GuiService.TopbarInset.Height+ySizeOffset)
        end
        container[screenGuiCenter.Name] = screenGuiCenter
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiCenter.DisplayOrder = Icon.baseDisplayOrder
        end)

        insetChanged:Connect(updateCenteredHoldersHeight)
        updateCenteredHoldersHeight()

        local screenGuiClipped = playerGui:WaitForChild("TopbarStandardClipped")
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
        end)
        container[screenGuiClipped.Name] = screenGuiClipped

        local screenGuiCenterClipped = playerGui:WaitForChild("TopbarCenteredClipped")
        Icon.baseDisplayOrderChanged:Connect(function()
                screenGuiCenterClipped.DisplayOrder = (Icon.baseDisplayOrder + 1)
        end)
        container[screenGuiCenterClipped.Name] = screenGuiCenterClipped

        local left = holders:WaitForChild("Left")
        insetChanged:Connect(function()
                left.Position = UDim2.fromOffset(startInset, 0)
        end)

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

        local center = holdersCenter:WaitForChild("Center")
        insetChanged:Connect(function()
                if center:FindFirstChildOfClass("UIListLayout") then
                        center:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, startInset)
                end
        end)

        local right = holders:WaitForChild("Right")
        insetChanged:Connect(function()
                if right:FindFirstChildOfClass("UIListLayout") then
                        right:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, startInset)
                end
        end)

        insetChanged:Fire(guiInset)

        return container
end
end
