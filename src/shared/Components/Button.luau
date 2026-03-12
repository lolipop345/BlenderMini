type Properties = {
    Icon : string?,
    IconColor : Color3?, -- Automaticly syncs with Studio colors
    Title : string?,
    Callback : () -> (),
}

local Shared = script.Parent.Parent
local Library = Shared.Library

local Theme = require(Library.Theme)

return function (Scope, Properties : Properties)
    local Elements = {}
    local IsHovering = Scope:Value(false)

    -- Icon
    if (typeof(Properties.Icon) == "string" or typeof(Properties.Icon) == "number") then
        local IconId = typeof(Properties.Icon) == "number" and `rbxassetid://{Properties.Icon}` or Properties.Icon
        local Icon = Scope:New "ImageLabel" {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Image = IconId,
            ImageColor3 = Properties.IconColor or Theme.Colors.textColor,
            LayoutOrder = -1,

            [Scope.Children] = {
                Scope:New "UIAspectRatioConstraint" {}
            }
        }

        table.insert(Elements, Icon)
    end

    -- Title
    if (typeof(Properties.Title) == "string") then
        local Title = Scope:New "TextLabel" {
            Size = UDim2.new(0, 10, 1, 0),
            BackgroundTransparency = 1,
            Text = Properties.Title,
            AutomaticSize = Enum.AutomaticSize.X,
            TextColor3 = Theme.Colors.textColor,
        }

        table.insert(Elements, Title)
    end

    return Scope:New "TextBox" {
        Size = UDim2.new(0, 40, 0, 40),
        Text = "",
        BackgroundColor3 = Scope:Computed(function(Use)
            if Use(IsHovering) then
                return Theme.Colors.buttonHoverColor
            else
                return Theme.Colors.buttonColor
            end
        end),

        -- Stylizing
        [Scope.Children] = {
            Scope:New "UICorner" {
                CornerRadius = UDim.new(0, 6),
            },
            Scope:New "UIPadding" {
                PaddingTop = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
            },
            Scope:New "UIListLayout" {
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                Padding = UDim.new(0, 7)
            },
            table.unpack(Elements)
        },

        [Scope:OnEvent("MouseEnter")] = function()
            IsHovering:set(true)
        end,
        
        [Scope:OnEvent("MouseLeave")] = function()
            IsHovering:set(false)
        end,

        -- Action
        [Scope:OnEvent("Activated")] = function()
            local Callback = typeof(Properties.Callback) == "function" and Properties.Callback or function() end
            local Success, Body = pcall(Callback)
            if (not Success) then
                warn(`Error occured on button callback: {Body}`)
            end
        end,
    }
end