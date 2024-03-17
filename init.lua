---@type Mq
local mq = require('mq')
---@type ImGui
local ImGui = require 'ImGui'
local guiOpen = false

local theme = require('themes')
Icons = require('mq.ICONS')
local settingsFile = string.format('%s/MyThemeZ_.lua', mq.configDir)
local themeName = 'Default'

local tempSettings = {
    ['LoadTheme'] = 'Default',
    Theme = {
        [1] = {
            ['Name'] = "Default",
            ['Color'] = {},
            ['Style'] = {},
        },
    },
}

ImGui.SetWindowSize('Theme##', 0.0, 200, ImGuiCond.Once)

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
    writeSettings(settingsFile,theme)
    -- Deep copy theme into tempSettings
    tempSettings = deepcopy(theme)
end

        -- GUI
        function ThemeBuilder(open)
            if guiOpen then
                local themeID = 0
                local show = false
                local once = false
     
                if theme and theme.Theme then
                    for tID, tData in pairs(theme.Theme) do
                        if tData['Name'] == themeName then
                            themeID = tID
                            for propertyName, cData in pairs(theme.Theme[tID].Color) do
                                ImGui.PushStyleColor(propertyName, ImVec4(cData[1], cData[2], cData[3], cData[4]))
                            end
                        end
                    end
                end
                open, show = ImGui.Begin("Theme##", open, bit32.bor(ImGuiWindowFlags.NoSavedSettings))
                if not show then
                    ImGui.End()
                    return open
                end
        
                local newName = tempSettings.Theme[themeID]['Name'] -- Store the current name for comparison later
                local StyleCount = 0
                local ColorCount = 0

                for _ in pairs(theme.Theme[themeID].Color) do
                    ColorCount = ColorCount + 1
                end

                local pressed = ImGui.Button("Save")
                if pressed then
                    writeSettings(settingsFile, tempSettings)
                    theme = deepcopy(tempSettings)
                end

                if not once then
                    -- Edit Name
                    newName = ImGui.InputText("Theme Name##_"..themeID, newName)
                    if newName ~= theme.Theme[themeID]['Name'] then
                        local i = #tempSettings.Theme + 1 -- Increment ID by 1
                        tempSettings.Theme[i] = deepcopy(tempSettings.Theme[themeID]) -- Create a new entry
                        tempSettings.Theme[i]['Name'] = newName -- Assign the new name
                        themeID = i -- Update themeID to point to the new entry
                    end
                    once = true
                end

                -- Update tempSettings with the edited name
                tempSettings.Theme[themeID]['Name'] = newName

                ImGui.Separator()
                local cWidth, xHeight = ImGui.GetContentRegionAvail()

                ImGui.BeginChild("Colors##", ImGui.GetWindowWidth() - 5, xHeight - 5, ImGuiChildFlags.AutoResizeX)
                local collapsed, _ = ImGui.CollapsingHeader("Colors##")
                if not collapsed then
        tempSettings.Theme[themeID]['Color'][ImGuiCol.WindowBg]               = ImGui.ColorEdit4("WindowBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.WindowBg]             )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ChildBg]                = ImGui.ColorEdit4("ChildBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ChildBg]               )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.PopupBg]                = ImGui.ColorEdit4("PopupBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.PopupBg]               )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.Border]                 = ImGui.ColorEdit4("Border##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.Border]                )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.FrameBg]                = ImGui.ColorEdit4("FrameBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.FrameBg]               )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.FrameBgHovered]         = ImGui.ColorEdit4("FrameBgHovered##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.FrameBgHovered]        )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.FrameBgActive]          = ImGui.ColorEdit4("FrameBgActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.FrameBgActive]          )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TitleBg]                = ImGui.ColorEdit4("TitleBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TitleBg]                )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TitleBgActive]          = ImGui.ColorEdit4("TitleBgActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TitleBgActive]          )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TitleBgCollapsed]       = ImGui.ColorEdit4("TitleBgCollapsed##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TitleBgCollapsed]       )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.MenuBarBg]              = ImGui.ColorEdit4("MenuBarBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.MenuBarBg]              )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ScrollbarBg]            = ImGui.ColorEdit4("ScrollbarBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ScrollbarBg]            )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ScrollbarGrab]          = ImGui.ColorEdit4("ScrollarGrab##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ScrollbarGrab]          )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ScrollbarGrabHovered]   = ImGui.ColorEdit4("ScrollbarGrabHovered##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ScrollbarGrabHovered]   )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ScrollbarGrabActive]    = ImGui.ColorEdit4("ScrollbarGrabActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ScrollbarGrabActive]    )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.SliderGrab]             = ImGui.ColorEdit4("SilderGrab##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.SliderGrab]             )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.SliderGrabActive]       = ImGui.ColorEdit4("SliderGrabActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.SliderGrabActive]       )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.Button]                 = ImGui.ColorEdit4("Button##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.Button]                 )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ButtonHovered]          = ImGui.ColorEdit4("ButtonHovered##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ButtonHovered]          )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ButtonActive]           = ImGui.ColorEdit4("ButtonActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ButtonActive]           )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.Header]                 = ImGui.ColorEdit4("Header##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.Header]                 )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.HeaderHovered]          = ImGui.ColorEdit4("HeaderHovered##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.HeaderHovered]          )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.HeaderActive]           = ImGui.ColorEdit4("HeaderActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.HeaderActive]           )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.Separator]              = ImGui.ColorEdit4("Separator##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.Separator]              )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.SeparatorHovered]       = ImGui.ColorEdit4("SeparatorHovered##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.SeparatorHovered]       )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.SeparatorActive]        = ImGui.ColorEdit4("SeparatorActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.SeparatorActive]        )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ResizeGrip]             = ImGui.ColorEdit4("ResizeGrip##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ResizeGrip]             )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ResizeGripHovered]      = ImGui.ColorEdit4("ResizeGripHovered##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ResizeGripHovered]      )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.ResizeGripActive]       = ImGui.ColorEdit4("ResizeGripActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.ResizeGripActive]       )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.Tab]                    = ImGui.ColorEdit4("Tab##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.Tab]                    )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TabHovered]             = ImGui.ColorEdit4("TabHovered##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TabHovered]             )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TabActive]              = ImGui.ColorEdit4("TabActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TabActive]              )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TabUnfocused]           = ImGui.ColorEdit4("TabUnfocused##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TabUnfocused]           )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TabUnfocusedActive]     = ImGui.ColorEdit4("TabUnfocusedActive##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TabUnfocusedActive]     )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TableHeaderBg]          = ImGui.ColorEdit4("TableHeaderBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TableHeaderBg]          )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TableBorderStrong]      = ImGui.ColorEdit4("TableBorderStrong##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TableBorderStrong]      )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TableBorderLight]       = ImGui.ColorEdit4("TableBorderLight##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TableBorderLight]       )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TableRowBg]             = ImGui.ColorEdit4("TableRowBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TableRowBg]             )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TableRowBgAlt]          = ImGui.ColorEdit4("TableRodBgAlt##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TableRowBgAlt]        )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.TextSelectedBg]         = ImGui.ColorEdit4("TextSelectedBg##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.TextSelectedBg]       )
        tempSettings.Theme[themeID]['Color'][ImGuiCol.NavHighlight]           = ImGui.ColorEdit4("NavHighlight##" , tempSettings.Theme[themeID]['Color'][ImGuiCol.NavHighlight])
    end
    ImGui.EndChild()
    ImGui.PopStyleColor(ColorCount)
    ImGui.End()
end
end

local function startup()
loadSettings()
mq.imgui.init('Theme Builder', ThemeBuilder)
guiOpen = true
end

local function loop()
while guiOpen do
    mq.delay(1)
end
end

startup()
loop()