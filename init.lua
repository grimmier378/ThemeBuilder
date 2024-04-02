---@type Mq
local mq = require('mq')
---@type ImGui
local ImGui = require 'ImGui'
local guiOpen = false
local theme = require('themes')
local settingsFile = string.format('%s/MyThemeZ.lua', mq.configDir)
local themeName = 'Default'
local tmpName = 'Default'
local StyleCount = 0
local ColorCount = 0
local themeID = 0

local tempSettings = {
    ['LoadTheme'] = 'Default',
    Theme = {
        [1] = {
            ['Name'] = "Default",
            ['Color'] = {
                Color = {},
                PropertyName = ''
            },
            ['Style'] = {},
        },
    },
}

--Helper Functioons
function File_Exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

local function writeSettings(file, settings)
    mq.pickle(file, settings)
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
        else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function loadSettings()
    if not File_Exists(settingsFile) then
        mq.pickle(settingsFile, theme)
        else
        -- Load settings from the Lua config file
        theme = dofile(settingsFile)
    end
    themeName = theme.LoadTheme or themeName
    tmpName = themeName
    writeSettings(settingsFile,theme)
    -- Deep copy theme into tempSettings
    -- tempSettings = deepcopy(theme)
    tempSettings = theme
end

local function getNextID(table)
    local maxID = 0
    for k, _ in pairs(table) do
        local numericId = tonumber(k)
        if numericId and numericId > maxID then
            maxID = numericId
        end
    end
    return maxID +1
end

local function exportButtonMaster(table)
    local BM = {}
    local bmThemeFile = mq.configDir..'/button_master_theme.lua'
    if theme and theme.Theme then
        for tID, tData in pairs(theme.Theme) do
            if not BM[tData.Name] then BM[tData.Name] = {} end
                themeID = tID
                for pID, cData in pairs(theme.Theme[tID].Color) do
                    if not BM[tData.Name][cData.PropertyName] then BM[tData.Name][cData.PropertyName] = {} end
                    BM[tData.Name][cData.PropertyName] = {cData.Color[1], cData.Color[2], cData.Color[3], cData.Color[4]}
                end
        end
    end
    writeSettings(bmThemeFile, BM)
end

-- GUI
ImGui.SetWindowSize("ThemeZ Builder##", 450, 300, ImGuiCond.FirstUseEver)
ImGui.SetWindowSize("ThemeZ Builder##", 450, 300, ImGuiCond.Always)
function ThemeBuilder(open)
    ColorCount = 0
    if guiOpen then
        local show = false

        -- Apply Theme to Window
        if theme and theme.Theme then
            for tID, tData in pairs(theme.Theme) do
                if tData['Name'] == themeName then
                    themeID = tID
                    for pID, cData in pairs(theme.Theme[tID].Color) do
                        ImGui.PushStyleColor(pID, ImVec4(cData.Color[1], cData.Color[2], cData.Color[3], cData.Color[4]))
                        ColorCount = ColorCount +1
                    end
                end
            end
        end
        -- Begin GUI
        open, show = ImGui.Begin("ThemeZ Builder##", open, bit32.bor(ImGuiWindowFlags.NoCollapse))
        if not show then
            ImGui.PopStyleColor(ColorCount)
            ImGui.End()
            return open
        end
        -- create table entry for themeID if missing.
        if not tempSettings.Theme[themeID] then
            local i = themeID + 1
            tempSettings.Theme = {
                [i] = {
                    ['Name'] = '',
                    ['Color'] = {
                        Color = {},
                        PropertyName = ''
                    },
                    ['Style'] = {},
                },
            }
        end
        local newName = tempSettings.Theme[themeID]['Name']
        -- Save Current Theme to Config
        local pressed = ImGui.Button("Save")
        if pressed then
            if tmpName == '' then tmpName = themeName end
            if tempSettings.Theme[themeID]['Name'] ~= tmpName then
                local nID = getNextID(tempSettings.Theme)
                tempSettings.Theme[nID]= {
                    ['Name'] = tmpName,
                    ['Color'] = tempSettings.Theme[themeID]['Color'],
                }
                themeID = nID
            end
            writeSettings(settingsFile, tempSettings)
            theme = deepcopy(tempSettings)
        end
        
        ImGui.SameLine()

        local pressed = ImGui.Button("Export BM Theme")
        if pressed then
            exportButtonMaster(tempSettings)
        end

        ImGui.SameLine()
        -- Make New Theme
        local newPressed = ImGui.Button("New")
        if newPressed then
            local nID = getNextID(tempSettings.Theme)
                tempSettings.Theme[nID]= {
                    ['Name'] = tmpName,
                    ['Color'] = theme.Theme[themeID]['Color'],
                }
            themeName = tmpName
            themeID = nID
            for k, data in pairs(tempSettings.Theme) do
                if data.Name == themeName then
                    tempSettings['LoadTheme'] = data['Name']
                    themeName = tempSettings['LoadTheme']
                    tmpName = themeName
                end
            end
            writeSettings(settingsFile, tempSettings)
            -- theme = deepcopy(tempSettings)
            theme = tempSettings
        end

        ImGui.SameLine()
        -- Exit/Close
        local ePressed = ImGui.Button("Exit")
        if ePressed then
            guiOpen = false
        end
        -- Edit Name
        ImGui.Text("Cur Theme: %s", themeName )
        tmpName =ImGui.InputText("Theme Name", tmpName)
        -- Combo Box Load Theme
        if ImGui.BeginCombo("Load Theme", themeName) then
            for k, data in pairs(tempSettings.Theme) do
                local isSelected = (data['Name'] == themeName)
                if ImGui.Selectable(data['Name'], isSelected) then
                    tempSettings['LoadTheme'] = data['Name']
                    themeName = tempSettings['LoadTheme']
                    tmpName = themeName
                end
            end
            ImGui.EndCombo()
        end
        ImGui.Separator()
        local cWidth, xHeight = ImGui.GetContentRegionAvail()
        ImGui.BeginChild("Colors##", ImGui.GetWindowWidth() - 5, xHeight - 5, ImGuiChildFlags.AutoResizeX)
        local collapsed, _ = ImGui.CollapsingHeader("Colors##")
        if not collapsed then
            for pID, pData in pairs(tempSettings.Theme[themeID]['Color']) do
                if pID ~= nil then 
                    local propertyName = pData.PropertyName
                    if propertyName ~= nil then
                        pData.Color =	ImGui.ColorEdit4(pData.PropertyName.."##" ,pData.Color)
                    end
                end
            end
        end
        ImGui.EndChild()
        ImGui.PopStyleColor(ColorCount)
        ImGui.End()
    end
end
--
local function startup()
    loadSettings()
    mq.imgui.init("ThemeZ Builder##", ThemeBuilder)
    guiOpen = true
end
--
local function loop()
    while guiOpen do
        mq.delay(1)
    end
end
--
startup()
loop()