local Studio = settings().Studio

export type ThemeColors = {
    backgroundColor: Color3,
    textColor: Color3,
    subTextColor: Color3,
    borderColor: Color3,
    buttonColor: Color3,
    buttonHoverColor: Color3,
    buttonSelectedColor: Color3,
    inputBackgroundColor: Color3,
    scrollbarColor: Color3,
    warningColor: Color3,
    errorColor: Color3,
    successColor: Color3,
}

local COLOR_MAP = {
    backgroundColor = {Enum.StudioStyleGuideColor.MainBackground, Enum.StudioStyleGuideModifier.Default},
    textColor = {Enum.StudioStyleGuideColor.MainText, Enum.StudioStyleGuideModifier.Default},
    subTextColor = {Enum.StudioStyleGuideColor.SubText, Enum.StudioStyleGuideModifier.Default},
    borderColor = {Enum.StudioStyleGuideColor.Border, Enum.StudioStyleGuideModifier.Default},
    buttonColor = {Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Default},
    buttonHoverColor = {Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Hover},
    buttonSelectedColor = {Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Selected},
    inputBackgroundColor = {Enum.StudioStyleGuideColor.MainBackground, Enum.StudioStyleGuideModifier.Default},
    scrollbarColor = {Enum.StudioStyleGuideColor.ScrollBar, Enum.StudioStyleGuideModifier.Default},
    warningColor = {Enum.StudioStyleGuideColor.WarningText, Enum.StudioStyleGuideModifier.Default},
    errorColor = {Enum.StudioStyleGuideColor.ErrorText, Enum.StudioStyleGuideModifier.Default},
    successColor = {Enum.StudioStyleGuideColor.InfoText, Enum.StudioStyleGuideModifier.Default},
}

local ThemeManager = {}
ThemeManager.Colors = {} :: ThemeColors
ThemeManager.ThemeChanged = Studio.ThemeChanged

local function updateColors()
    local currentTheme = Studio.Theme
    
    for token, config in pairs(COLOR_MAP) do
        local success, color = pcall(function()
            return currentTheme:GetColor(config[1], config[2])
        end)
        
        if success then
            (ThemeManager.Colors :: any)[token] = color
        else
            warn("[ThemeManager] Failed to fetch color for: " .. tostring(token))
        end
    end
end

updateColors()
Studio.ThemeChanged:Connect(updateColors)

return ThemeManager