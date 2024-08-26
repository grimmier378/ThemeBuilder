---@type Mq
local mq = require('mq')
---@type ImGui
local ImGui = require 'ImGui'
local guiOpen = false
local defaults = require('themes')
local theme = {}
local settingsFile = string.format('%s/MyThemeZ.lua', mq.configDir)
local themeName = 'Default'
local tmpName = 'Default'
-- local StyleCount = 0
-- local ColorCount = 0
local themeID = 0
local LoadTheme = require('lib.theme_loader')
local tFlags = bit32.bor(ImGuiTableFlags.NoBorders, ImGuiTableFlags.NoBordersInBody)
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
        mq.pickle(settingsFile, defaults)
        loadSettings()
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
    local styleFlag = false
    for tID, tData in pairs(tempSettings.Theme) do
        if tData['Style'] == nil or next(tData['Style']) == nil then
            tempSettings.Theme[tID].Style = {}
            tempSettings.Theme[tID].Style = defaults['Theme'][1]['Style']
            styleFlag = true
        end
    end
    for tID, tData in pairs(tempSettings.Theme) do
        if tData['Color'] == nil or next(tData['Color']) == nil then
            tempSettings.Theme[tID].Color = {}
            tempSettings.Theme[tID].Color = defaults['Theme'][1]['Color']
            styleFlag = true
        end
    end
    if styleFlag then writeSettings(settingsFile, tempSettings) end

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

local function exportRGMercs(table)
    if table == nil then return end
    local rgThemeFile = mq.configDir..'/rgmercs/rgmercs_theme.lua'
        local f = io.open(rgThemeFile, "w")
        if f== nil then
            error("Error opening file for writing: " .. rgThemeFile)
            return
        end
        local line = 'return {'
        f:write(line .. "\n")
        for tID, tData in pairs(theme.Theme) do
            themeID = tID
            line = "\t['"..tData.Name.."'] = {"
            f:write(line .. "\n")
            for pID, cData in pairs(theme.Theme[tID].Color) do
                line = string.format("\t\t{ element = ImGuiCol.%s, color = {r = %.2f, g = %.2f,b = %.2f,a = %.2f}, },", cData.PropertyName, cData.Color[1], cData.Color[2], cData.Color[3], cData.Color[4])
                f:write(line .. "\n")
            end
            line = "\t},"
            f:write(line .. "\n")
        end
        f:write("}")
        f:close()
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
                for sID, sData in pairs(theme.Theme[tID].Style) do
                    if not BM[tData.Name][sData.PropertyName] then BM[tData.Name][sData.PropertyName] = {} end
                    if sData.Size ~= nil then
                        BM[tData.Name][sData.PropertyName] = {sData.Size}
                    elseif sData.X ~= nil then
                        BM[tData.Name][sData.PropertyName] = {sData.X, sData.Y}
                    end
                end
        end
    end
    writeSettings(bmThemeFile, BM)
end

local function DrawStyles()
    local style = {}
    tempSettings.Theme[themeID] = theme.Theme[themeID]
    if tempSettings.Theme[themeID]['Style'] == nil then
        tempSettings.Theme[themeID]['Style'] = defaults['Theme'][2]['Style']
    end
    style = tempSettings.Theme[themeID]['Style']

    ImGui.SeparatorText('Borders')
    local tmpBorder = false
    local borderPressed = false
    if style[ImGuiStyleVar.WindowBorderSize].Size == 1 then
        tmpBorder = true
    end
    tmpBorder, borderPressed = ImGui.Checkbox('WindowBorder##', tmpBorder)
    if borderPressed then
        if tmpBorder then
            style[ImGuiStyleVar.WindowBorderSize].Size = 1
        else
            style[ImGuiStyleVar.WindowBorderSize].Size = 0
        end
    end
    ImGui.SameLine()
    local tmpFBorder = false
    local borderFPressed = false
    if style[ImGuiStyleVar.FrameBorderSize].Size == 1 then
        tmpFBorder = true
    end
    tmpFBorder, borderFPressed = ImGui.Checkbox('FrameBorder##', tmpFBorder)
    if borderFPressed then
        if tmpFBorder then
            style[ImGuiStyleVar.FrameBorderSize].Size = 1
        else
            style[ImGuiStyleVar.FrameBorderSize].Size = 0
        end
    end
    ImGui.SameLine()
    local tmpCBorder = false
    local borderCPressed = false
    if style[ImGuiStyleVar.ChildBorderSize].Size == 1 then
        tmpCBorder = true
    end
    tmpCBorder, borderCPressed = ImGui.Checkbox('ChildBorder##', tmpCBorder)
    if borderCPressed then
        if tmpCBorder then
            style[ImGuiStyleVar.ChildBorderSize].Size = 1
        else
            style[ImGuiStyleVar.ChildBorderSize].Size = 0
        end
    end

    local tmpPBorder = false
    local borderPPressed = false
    if style[ImGuiStyleVar.PopupBorderSize].Size == 1 then
        tmpPBorder = true
    end
    tmpPBorder, borderPPressed = ImGui.Checkbox('PopupBorder##', tmpPBorder)
    if borderPPressed then
        if tmpPBorder then
            style[ImGuiStyleVar.PopupBorderSize].Size = 1
        else
            style[ImGuiStyleVar.PopupBorderSize].Size = 0
        end
    end
    ImGui.SameLine()
    local tmpTBorder = false
    local borderTPressed = false
    if style[ImGuiStyleVar.TabBarBorderSize].Size == 1 then
        tmpTBorder = true
    end
    tmpTBorder, borderTPressed = ImGui.Checkbox('TabBorder##', tmpTBorder)
    if borderTPressed then
        if tmpTBorder then
            style[ImGuiStyleVar.TabBarBorderSize].Size = 1
        else
            style[ImGuiStyleVar.TabBarBorderSize].Size = 0
        end
    end

    ImGui.SeparatorText('Main Sizing')
    ImGui.BeginTable('##StylesMain', 3, tFlags)
    ImGui.TableSetupColumn('##min', ImGuiTableColumnFlags.None)
    ImGui.TableSetupColumn('##max', ImGuiTableColumnFlags.None)
    ImGui.TableSetupColumn('##name', ImGuiTableColumnFlags.None)
    ImGui.TableNextRow()
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.WindowPadding].X = ImGui.InputInt('##WindowPadding_X', style[ImGuiStyleVar.WindowPadding].X, 1, 2)
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.WindowPadding].Y = ImGui.InputInt(' ##WindowPadding_Y', style[ImGuiStyleVar.WindowPadding].Y, 1, 2)
    ImGui.TableNextColumn()
    ImGui.Text(style[ImGuiStyleVar.WindowPadding].PropertyName)

    ImGui.TableNextRow()
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.CellPadding].X = ImGui.InputInt('##CellPadding_X', style[ImGuiStyleVar.CellPadding].X, 1, 2)
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.CellPadding].Y = ImGui.InputInt(' ##CellPadding_Y', style[ImGuiStyleVar.CellPadding].Y, 1, 2)
    ImGui.TableNextColumn()
    ImGui.Text(style[ImGuiStyleVar.CellPadding].PropertyName)

    ImGui.TableNextRow()
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.FramePadding].X = ImGui.InputInt('##FramePadding_X', style[ImGuiStyleVar.FramePadding].X, 1, 2)
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.FramePadding].Y = ImGui.InputInt(' ##FramePadding_Y', style[ImGuiStyleVar.FramePadding].Y, 1, 2)
    ImGui.TableNextColumn()
    ImGui.Text(style[ImGuiStyleVar.FramePadding].PropertyName)

    ImGui.TableNextRow()
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.ItemSpacing].X = ImGui.InputInt('##ItemSpacing_X', style[ImGuiStyleVar.ItemSpacing].X, 1, 2)
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.ItemSpacing].Y = ImGui.InputInt(' ##ItemSpacing_Y', style[ImGuiStyleVar.ItemSpacing].Y, 1, 2)
    ImGui.TableNextColumn()
    ImGui.Text(style[ImGuiStyleVar.ItemSpacing].PropertyName)

    ImGui.TableNextRow()
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.ItemInnerSpacing].X = ImGui.InputInt('##ItemInnerSpacing_X', style[ImGuiStyleVar.ItemInnerSpacing].X, 1, 2)
    ImGui.TableNextColumn()
    ImGui.SetNextItemWidth(100)
    style[ImGuiStyleVar.ItemInnerSpacing].Y = ImGui.InputInt(' ##ItemInnerSpacing_Y', style[ImGuiStyleVar.ItemInnerSpacing].Y, 1, 2)
    ImGui.TableNextColumn()
    ImGui.Text(style[ImGuiStyleVar.ItemInnerSpacing].PropertyName)

    ImGui.EndTable()

    style[ImGuiStyleVar.IndentSpacing].Size = ImGui.SliderInt('IndentSpacing##', style[ImGuiStyleVar.IndentSpacing].Size, 0, 30)
    style[ImGuiStyleVar.ScrollbarSize].Size = ImGui.SliderInt('ScrollbarSize##', style[ImGuiStyleVar.ScrollbarSize].Size, 0,20)
    style[ImGuiStyleVar.GrabMinSize].Size = ImGui.SliderInt('GrabSize##', style[ImGuiStyleVar.GrabMinSize].Size, 0, 20)

    ImGui.SeparatorText('Rounding')
    style[ImGuiStyleVar.WindowRounding].Size = ImGui.SliderInt('Window##Rounding', style[ImGuiStyleVar.WindowRounding].Size, 0, 12)
    style[ImGuiStyleVar.FrameRounding].Size = ImGui.SliderInt('Frame##Rounding', style[ImGuiStyleVar.FrameRounding].Size, 0,12)
    style[ImGuiStyleVar.ChildRounding].Size = ImGui.SliderInt('Child##Rounding', style[ImGuiStyleVar.ChildRounding].Size, 0, 12)
    style[ImGuiStyleVar.PopupRounding].Size = ImGui.SliderInt('Popup##Rounding', style[ImGuiStyleVar.PopupRounding].Size, 0,12)
    style[ImGuiStyleVar.ScrollbarRounding].Size = ImGui.SliderInt('Scrollbar##Rounding', style[ImGuiStyleVar.ScrollbarRounding].Size, 0, 12)
    style[ImGuiStyleVar.GrabRounding].Size = ImGui.SliderInt('Grab##Rounding', style[ImGuiStyleVar.GrabRounding].Size, 0,12)
    style[ImGuiStyleVar.TabRounding].Size = ImGui.SliderInt('Tab##Rounding', style[ImGuiStyleVar.TabRounding].Size, 0, 12)

end

-- GUI
local cFlag = false
ImGui.SetWindowSize("ThemeZ Builder##", 450, 300, ImGuiCond.FirstUseEver)
ImGui.SetWindowSize("ThemeZ Builder##", 450, 300, ImGuiCond.Always)
function ThemeBuilder(open)
    if guiOpen then
        local show = false
        local ColorCount, StyleCount = 0,0
        -- -- Apply Theme to Window
        if theme and theme.Theme then
            for tID, tData in pairs(theme.Theme) do
                if tData['Name'] == themeName then
                    themeID = tID
                    -- for pID, cData in pairs(theme.Theme[tID].Color) do
                    --     ImGui.PushStyleColor(pID, ImVec4(cData.Color[1], cData.Color[2], cData.Color[3], cData.Color[4]))
                    --     ColorCount = ColorCount +1
                    -- end
                    -- for sID, sData in pairs (theme.Theme[tID].Style) do
                    --     if sData.Size ~= nil then
                    --         ImGui.PushStyleVar(sID, sData.Size)
                    --         StyleCount = StyleCount + 1
                    --     elseif sData.X ~= nil then
                    --         ImGui.PushStyleVar(sID, sData.X, sData.Y)
                    --         StyleCount = StyleCount + 1
                    --     end
                    -- end
                    ColorCount, StyleCount = LoadTheme.StartTheme(theme.Theme[tID])
                end
            end
        end
        
        -- Begin GUI
        open, show = ImGui.Begin("ThemeZ Builder##", open, bit32.bor(ImGuiWindowFlags.NoCollapse, ImGuiWindowFlags.NoScrollbar))
        if not show then
            -- ImGui.PopStyleColor(ColorCount)
            -- ImGui.PopStyleVar(StyleCount)
            LoadTheme.EndTheme(ColorCount, StyleCount)
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

        local pressed = ImGui.Button("Export RGMercs Theme")
        if pressed then
            exportRGMercs(tempSettings)
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
        ImGui.BeginChild("ThemeZ##", cWidth - 5, xHeight - 15)
        local collapsed, _ = ImGui.CollapsingHeader("Colors##")
        
        if collapsed then
            if ImGui.Button('Defaults##Color') then
                tempSettings.Theme[themeID]['Color'] = defaults.Theme[1].Color
            end
            cWidth, xHeight = ImGui.GetContentRegionAvail()
            if cFlag then
                ImGui.BeginChild('Colors', cWidth,xHeight * 0.5 ,  ImGuiChildFlags.Border )
            else
                ImGui.BeginChild('Colors', cWidth,xHeight ,  ImGuiChildFlags.Border )
            end
            for pID, pData in pairs(tempSettings.Theme[themeID]['Color']) do
                if pID ~= nil then 
                    local propertyName = pData.PropertyName
                    if propertyName ~= nil then
                        pData.Color =	ImGui.ColorEdit4(pData.PropertyName.."##" ,pData.Color)
                    end
                end
            end
            ImGui.EndChild()
        end
        cWidth, xHeight = ImGui.GetContentRegionAvail()
        local collapsed2, _ = ImGui.CollapsingHeader("Styles##")
        if collapsed2 then
            cFlag = true
            if not collapsed then
                ImGui.BeginChild('Styles', cWidth,xHeight ,ImGuiChildFlags.Border )
            else
                ImGui.BeginChild('Styles', cWidth,xHeight * 0.5 ,ImGuiChildFlags.Border )
            end
            if ImGui.Button('Defaults##Style') then
                tempSettings.Theme[themeID]['Style'] = defaults.Theme[1].Style
            end
            DrawStyles()
            ImGui.EndChild()
        else
            cFlag = false
        end

        ImGui.EndChild()
        -- ImGui.PopStyleVar(StyleCount)
        -- ImGui.PopStyleColor(ColorCount)
        LoadTheme.EndTheme(ColorCount, StyleCount)
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
