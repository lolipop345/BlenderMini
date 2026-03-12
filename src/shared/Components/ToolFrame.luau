type Properties = {
    DockLocation: "Top" | "Left" | "Right" | "Bottom",
    Size: UDim2?,
    IsResizeable: boolean?,
    MaxSizeStep: number?,
    [any]: any
}

local UserInputService = game:GetService("UserInputService")
local Shared = script.Parent.Parent
local Library = Shared.Library
local Theme = require(Library.Theme)

return function(Scope, Properties: Properties)
    local IsResizeable = if Properties.IsResizeable ~= nil then Properties.IsResizeable else false
    local MaxSizeStep = Properties.MaxSizeStep or 2
    local BaseSize = Properties.Size or UDim2.new(0, 40, 0, 40)
    local DockLocation = Properties.DockLocation or "Top"

    local CurrentStep = Scope:Value(1)

    local CalculatedSize = Scope:Computed(function(Use)
        local step = Use(CurrentStep)
        if DockLocation == "Top" or DockLocation == "Bottom" then
            return UDim2.new(BaseSize.X.Scale, BaseSize.X.Offset, BaseSize.Y.Scale * step, BaseSize.Y.Offset * step)
        else
            return UDim2.new(BaseSize.X.Scale * step, BaseSize.X.Offset * step, BaseSize.Y.Scale, BaseSize.Y.Offset)
        end
    end)

    local AnchorPoint
    local Position
    local DragHandleSize
    local DragHandlePosition
    local FillDirection
    local AutoCanvas

    if DockLocation == "Top" then
        AnchorPoint = Vector2.new(0.5, 0)
        Position = UDim2.new(0.5, 0, 0, 0)
        DragHandleSize = UDim2.new(1, 0, 0, 6)
        DragHandlePosition = UDim2.new(0, 0, 1, -3)
        FillDirection = Enum.FillDirection.Horizontal
        AutoCanvas = Enum.AutomaticSize.Y
    elseif DockLocation == "Bottom" then
        AnchorPoint = Vector2.new(0.5, 1)
        Position = UDim2.new(0.5, 0, 1, 0)
        DragHandleSize = UDim2.new(1, 0, 0, 6)
        DragHandlePosition = UDim2.new(0, 0, 0, -3)
        FillDirection = Enum.FillDirection.Horizontal
        AutoCanvas = Enum.AutomaticSize.Y
    elseif DockLocation == "Left" then
        AnchorPoint = Vector2.new(0, 0.5)
        Position = UDim2.new(0, 0, 0.5, 0)
        DragHandleSize = UDim2.new(0, 6, 1, 0)
        DragHandlePosition = UDim2.new(1, -3, 0, 0)
        FillDirection = Enum.FillDirection.Vertical
        AutoCanvas = Enum.AutomaticSize.X
    elseif DockLocation == "Right" then
        AnchorPoint = Vector2.new(1, 0.5)
        Position = UDim2.new(1, 0, 0.5, 0)
        DragHandleSize = UDim2.new(0, 6, 1, 0)
        DragHandlePosition = UDim2.new(0, -3, 0, 0)
        FillDirection = Enum.FillDirection.Vertical
        AutoCanvas = Enum.AutomaticSize.X
    end

    local Elements = {}

    table.insert(Elements, Scope:New "UIGridLayout" {
        CellSize = UDim2.new(0, 32, 0, 32),
        CellPadding = UDim2.new(0, 4, 0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = FillDirection,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    })

    table.insert(Elements, Scope:New "UIPadding" {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    })

    if IsResizeable then
        local DragHandle = Scope:New "Frame" {
            Size = DragHandleSize,
            Position = DragHandlePosition,
            BackgroundTransparency = 1,
            ZIndex = 10,

            [Scope:OnEvent("InputBegan")] = function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local startPos = input.Position
                    local startStep = CurrentStep:get()
                    local connection
                    local endConnection

                    connection = UserInputService.InputChanged:Connect(function(moveInput)
                        if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
                            local delta = moveInput.Position - startPos
                            local deltaValue = 0
                            local baseValue = 0

                            if DockLocation == "Top" then
                                deltaValue = delta.Y
                                baseValue = BaseSize.Y.Offset
                            elseif DockLocation == "Bottom" then
                                deltaValue = -delta.Y
                                baseValue = BaseSize.Y.Offset
                            elseif DockLocation == "Left" then
                                deltaValue = delta.X
                                baseValue = BaseSize.X.Offset
                            elseif DockLocation == "Right" then
                                deltaValue = -delta.X
                                baseValue = BaseSize.X.Offset
                            end

                            if baseValue > 0 then
                                local stepChange = math.floor((deltaValue + (baseValue / 2)) / baseValue)
                                local newStep = math.clamp(startStep + stepChange, 1, MaxSizeStep)
                                CurrentStep:set(newStep)
                            end
                        end
                    end)

                    endConnection = UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                            if connection then
                                connection:Disconnect()
                            end
                            if endConnection then
                                endConnection:Disconnect()
                            end
                        end
                    end)
                end
            end,
        }

        table.insert(Elements, DragHandle)
    end

    local ChildrenProp = Properties[Scope.Children]
    if type(ChildrenProp) == "table" then
        for _, child in pairs(ChildrenProp) do
            table.insert(Elements, child)
        end
    elseif ChildrenProp ~= nil then
        table.insert(Elements, ChildrenProp)
    end

    return Scope:New "ScrollingFrame" {
        Size = CalculatedSize,
        AnchorPoint = AnchorPoint,
        Position = Position,
        BackgroundColor3 = Theme.Colors.backgroundColor,
        BorderColor3 = Theme.Colors.borderColor,
        BorderSizePixel = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Colors.scrollbarColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = AutoCanvas,
        ClipsDescendants = true,

        [Scope.Children] = Elements
    }
end