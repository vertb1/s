local UILib = {}
UILib.__index = UILib

-- Configuration
local config = {
    defaultTheme = {
        background = Color3.fromRGB(30, 30, 30),
        accent = Color3.fromRGB(0, 120, 255),
        text = Color3.fromRGB(255, 255, 255),
        secondaryBackground = Color3.fromRGB(40, 40, 40),
        border = Color3.fromRGB(60, 60, 60)
    },
    cornerRadius = UDim.new(0, 8),
    tabSize = UDim2.new(0, 150, 0, 40),
    defaultSize = UDim2.new(0, 600, 0, 400),
}

-- Create new UI instance
function UILib.new(title)
    local self = setmetatable({}, UILib)
    self.title = title or "UI Library"
    self.tabs = {}
    self.activeTab = nil
    self.theme = config.defaultTheme
    self.visible = true
    
    -- Initialize the UI
    self:_init()
    
    return self
end

-- Initialize UI components
function UILib:_init()
    -- Create ScreenGui
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "UILibrary"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = config.defaultSize
    self.mainFrame.Position = UDim2.new(0.5, -config.defaultSize.X.Offset/2, 0.5, -config.defaultSize.Y.Offset/2)
    self.mainFrame.BackgroundColor3 = self.theme.background
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Parent = self.gui
    
    -- Rounded corners
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = config.cornerRadius
    cornerRadius.Parent = self.mainFrame
    
    -- Title Bar
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(1, 0, 0, 30)
    self.titleBar.BackgroundColor3 = self.theme.accent
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.mainFrame
    
    -- Round the top corners of title bar
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = config.cornerRadius
    titleCorner.Parent = self.titleBar
    
    -- Fix the bottom corners of title bar (make them square)
    local titleCornerFix = Instance.new("Frame")
    titleCornerFix.Name = "CornerFix"
    titleCornerFix.Size = UDim2.new(1, 0, 0.5, 0)
    titleCornerFix.Position = UDim2.new(0, 0, 0.5, 0)
    titleCornerFix.BackgroundColor3 = self.theme.accent
    titleCornerFix.BorderSizePixel = 0
    titleCornerFix.Parent = self.titleBar
    
    -- Title Text
    self.titleText = Instance.new("TextLabel")
    self.titleText.Name = "TitleText"
    self.titleText.Size = UDim2.new(1, -40, 1, 0)
    self.titleText.Position = UDim2.new(0, 10, 0, 0)
    self.titleText.BackgroundTransparency = 1
    self.titleText.TextColor3 = self.theme.text
    self.titleText.TextSize = 16
    self.titleText.Font = Enum.Font.SourceSansBold
    self.titleText.Text = self.title
    self.titleText.TextXAlignment = Enum.TextXAlignment.Left
    self.titleText.Parent = self.titleBar
    
    -- Close Button
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 30, 0, 30)
    self.closeButton.Position = UDim2.new(1, -30, 0, 0)
    self.closeButton.BackgroundTransparency = 1
    self.closeButton.TextColor3 = self.theme.text
    self.closeButton.TextSize = 18
    self.closeButton.Font = Enum.Font.SourceSansBold
    self.closeButton.Text = "×"
    self.closeButton.Parent = self.titleBar
    
    -- Tab Container (left side)
    self.tabContainer = Instance.new("Frame")
    self.tabContainer.Name = "TabContainer"
    self.tabContainer.Size = UDim2.new(0, 150, 1, -30)
    self.tabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.tabContainer.BackgroundColor3 = self.theme.secondaryBackground
    self.tabContainer.BorderSizePixel = 0
    self.tabContainer.Parent = self.mainFrame
    
    -- Tab Content Area
    self.contentArea = Instance.new("Frame")
    self.contentArea.Name = "ContentArea"
    self.contentArea.Size = UDim2.new(1, -150, 1, -30)
    self.contentArea.Position = UDim2.new(0, 150, 0, 30)
    self.contentArea.BackgroundColor3 = self.theme.background
    self.contentArea.BorderSizePixel = 0
    self.contentArea.Parent = self.mainFrame
    
    -- Connect events
    self.closeButton.MouseButton1Click:Connect(function()
        self:toggle()
    end)
    
    -- Make the frame draggable
    self:_makeDraggable()
    
    -- Add the settings tab by default
    self:addSettingsTab()
    
    -- Add the UI to game
    self.gui.Parent = game:GetService("CoreGui")
end

-- Make the frame draggable
function UILib:_makeDraggable()
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
        end
    end)
    
    self.titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create a new tab
function UILib:createTab(name, icon)
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name.."Tab"
    tabButton.Size = config.tabSize
    tabButton.Position = UDim2.new(0, 0, 0, #self.tabs * config.tabSize.Y.Offset)
    tabButton.BackgroundColor3 = self.theme.secondaryBackground
    tabButton.BorderSizePixel = 0
    tabButton.TextColor3 = self.theme.text
    tabButton.TextSize = 14
    tabButton.Font = Enum.Font.SourceSans
    tabButton.Text = name
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.tabContainer
    
    -- Add padding to the text
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = tabButton
    
    -- Create tab content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = name.."Content"
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 4
    contentFrame.Visible = false
    contentFrame.Parent = self.contentArea
    
    -- Add padding to the content
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = contentFrame
    
    -- Auto layout content vertically
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = contentFrame
    
    -- Tab selection logic
    tabButton.MouseButton1Click:Connect(function()
        self:selectTab(name)
    end)
    
    -- Store the tab information
    local tab = {
        name = name,
        button = tabButton,
        content = contentFrame
    }
    
    table.insert(self.tabs, tab)
    
    -- If this is the first tab, select it by default
    if #self.tabs == 1 then
        self:selectTab(name)
    end
    
    return tab
end

-- Select a tab to display
function UILib:selectTab(name)
    for _, tab in pairs(self.tabs) do
        if tab.name == name then
            tab.button.BackgroundColor3 = self.theme.accent
            tab.content.Visible = true
            self.activeTab = tab
        else
            tab.button.BackgroundColor3 = self.theme.secondaryBackground
            tab.content.Visible = false
        end
    end
end

-- Toggle the UI visibility
function UILib:toggle()
    self.visible = not self.visible
    self.gui.Enabled = self.visible
end

-- Create a settings tab with themes and configurations
function UILib:addSettingsTab()
    local settingsTab = self:createTab("Settings", nil)
    
    -- Theme Selection Section
    local themeSection = self:_createSection(settingsTab.content, "Theme")
    
    -- Default theme button
    self:_createButton(themeSection, "Default Theme", function()
        self:setTheme(config.defaultTheme)
    end)
    
    -- Dark theme button
    self:_createButton(themeSection, "Dark Theme", function()
        self:setTheme({
            background = Color3.fromRGB(20, 20, 20),
            accent = Color3.fromRGB(0, 100, 200),
            text = Color3.fromRGB(255, 255, 255),
            secondaryBackground = Color3.fromRGB(30, 30, 30),
            border = Color3.fromRGB(50, 50, 50)
        })
    end)
    
    -- Light theme button
    self:_createButton(themeSection, "Light Theme", function()
        self:setTheme({
            background = Color3.fromRGB(240, 240, 240),
            accent = Color3.fromRGB(0, 120, 215),
            text = Color3.fromRGB(0, 0, 0),
            secondaryBackground = Color3.fromRGB(225, 225, 225),
            border = Color3.fromRGB(200, 200, 200)
        })
    end)
    
    -- Configuration Section
    local configSection = self:_createSection(settingsTab.content, "Configuration")
    
    -- Toggle UI button
    self:_createButton(configSection, "Toggle UI", function()
        self:toggle()
    end)
    
    -- Toggle keybind
    local keybindSection = self:_createSection(settingsTab.content, "Keybind")
    self:_createLabel(keybindSection, "Press RightShift to toggle UI")
    
    -- Register the keybind
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightShift then
            self:toggle()
        end
    end)
    
    return settingsTab
end

-- Helper function to create a section
function UILib:_createSection(parent, name)
    local section = Instance.new("Frame")
    section.Name = name.."Section"
    section.Size = UDim2.new(1, 0, 0, 0)
    section.BackgroundTransparency = 1
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Parent = parent
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.TextColor3 = self.theme.text
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Text = name
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section
    
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 25)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Parent = section
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = content
    
    return content
end

-- Helper function to create a button
function UILib:_createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Name = text.."Button"
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = self.theme.secondaryBackground
    button.BorderSizePixel = 0
    button.TextColor3 = self.theme.text
    button.TextSize = 14
    button.Font = Enum.Font.SourceSans
    button.Text = text
    button.Parent = parent
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Button click logic
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Helper function to create a label
function UILib:_createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = self.theme.text
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    
    return label
end

-- Apply a new theme
function UILib:setTheme(theme)
    self.theme = theme
    
    -- Update UI elements with new theme
    self.mainFrame.BackgroundColor3 = theme.background
    self.titleBar.BackgroundColor3 = theme.accent
    self.titleCornerFix.BackgroundColor3 = theme.accent
    self.titleText.TextColor3 = theme.text
    self.closeButton.TextColor3 = theme.text
    self.tabContainer.BackgroundColor3 = theme.secondaryBackground
    self.contentArea.BackgroundColor3 = theme.background
    
    -- Update tabs
    for _, tab in pairs(self.tabs) do
        if self.activeTab and tab.name == self.activeTab.name then
            tab.button.BackgroundColor3 = theme.accent
        else
            tab.button.BackgroundColor3 = theme.secondaryBackground
        end
        
        -- Update all buttons in this tab
        for _, child in pairs(tab.content:GetDescendants()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = theme.secondaryBackground
                child.TextColor3 = theme.text
            elseif child:IsA("TextLabel") then
                child.TextColor3 = theme.text
            end
        end
    end
end

-- Create a new tab with custom content
function UILib:addTab(name)
    return self:createTab(name)
end

-- Add a button to a specific tab
function UILib:addButton(tab, text, callback)
    return self:_createButton(tab.content, text, callback)
end

-- Add a label to a specific tab
function UILib:addLabel(tab, text)
    return self:_createLabel(tab.content, text)
end

-- Add a section to a specific tab
function UILib:addSection(tab, name)
    return self:_createSection(tab.content, name)
end

return UILib
