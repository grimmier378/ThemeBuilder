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
    Theme = {
        [themeName] = {
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
    -- Deep copy theme into tempSettings
    tempSettings = deepcopy(theme)
end

-- GUI
function ThemeBuilder(open)
    if guiOpen then
        local show = false
        if theme and theme.Theme then
            for propertyName, cData in pairs(theme.Theme[themeName].Color) do
                ImGui.PushStyleColor(propertyName, ImVec4(cData[1], cData[2], cData[3], cData[4]))
            end
        end
        open, show = ImGui.Begin("Theme##", open, bit32.bor(ImGuiWindowFlags.NoSavedSettings))
        if not show then
            ImGui.End()
            return open
        end

        local newName = deepcopy(themeName)
        local StyleCount = 0
        local ColorCount = 0
        for _ in pairs(theme.Theme[themeName].Color) do
            ColorCount = ColorCount + 1
        end
        -- for _ in pairs(theme.Theme[themeName]['Style']) do
        --     StyleCount = StyleCountt + 1
        -- end

        local pressed = ImGui.Button("Save")
        if pressed then
            if not tempSettings.Theme[newName] then
                tempSettings.Theme[newName] = {}
            end
            tempSettings.Theme[newName] = tempSettings.Theme[themeName]
            writeSettings(settingsFile,tempSettings)
            -- guiOpen = false
            theme = deepcopy(tempSettings)
        end

        -- Edit Name
        local tmpName = ''
        if tmpName == '' then
            tmpName = tostring(newName)
        end
        tmpName, _ = ImGui.InputText("Theme Name##",tmpName )
        if newName ~= tmpName then newName = tmpName end

        


        ImGui.Separator()
        local cWidth, xHeight = ImGui.GetContentRegionAvail()

        ImGui.BeginChild("Colors##", ImGui.GetWindowWidth() - 5, xHeight - 5, ImGuiChildFlags.AutoResizeX)
        local collapsed, _ = ImGui.CollapsingHeader("Colors##")
        if not collapsed then
        tempSettings.Theme[themeName]['Color'][ImGuiCol.WindowBg]               = ImGui.ColorEdit4("WindowBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.WindowBg]             )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ChildBg]                = ImGui.ColorEdit4("ChildBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ChildBg]               )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.PopupBg]                = ImGui.ColorEdit4("PopupBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.PopupBg]               )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.Border]                 = ImGui.ColorEdit4("Border##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.Border]                )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.FrameBg]                = ImGui.ColorEdit4("FrameBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.FrameBg]               )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.FrameBgHovered]         = ImGui.ColorEdit4("FrameBgHovered##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.FrameBgHovered]        )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.FrameBgActive]          = ImGui.ColorEdit4("FrameBgActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.FrameBgActive]          )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TitleBg]                = ImGui.ColorEdit4("TitleBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TitleBg]                )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TitleBgActive]          = ImGui.ColorEdit4("TitleBgActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TitleBgActive]          )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TitleBgCollapsed]       = ImGui.ColorEdit4("TitleBgCollapsed##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TitleBgCollapsed]       )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.MenuBarBg]              = ImGui.ColorEdit4("MenuBarBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.MenuBarBg]              )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ScrollbarBg]            = ImGui.ColorEdit4("ScrollbarBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ScrollbarBg]            )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ScrollbarGrab]          = ImGui.ColorEdit4("ScrollarGrab##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ScrollbarGrab]          )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ScrollbarGrabHovered]   = ImGui.ColorEdit4("ScrollbarGrabHovered##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ScrollbarGrabHovered]   )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ScrollbarGrabActive]    = ImGui.ColorEdit4("ScrollbarGrabActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ScrollbarGrabActive]    )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.SliderGrab]             = ImGui.ColorEdit4("SilderGrab##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.SliderGrab]             )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.SliderGrabActive]       = ImGui.ColorEdit4("SliderGrabActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.SliderGrabActive]       )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.Button]                 = ImGui.ColorEdit4("Button##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.Button]                 )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ButtonHovered]          = ImGui.ColorEdit4("ButtonHovered##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ButtonHovered]          )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ButtonActive]           = ImGui.ColorEdit4("ButtonActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ButtonActive]           )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.Header]                 = ImGui.ColorEdit4("Header##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.Header]                 )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.HeaderHovered]          = ImGui.ColorEdit4("HeaderHovered##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.HeaderHovered]          )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.HeaderActive]           = ImGui.ColorEdit4("HeaderActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.HeaderActive]           )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.Separator]              = ImGui.ColorEdit4("Separator##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.Separator]              )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.SeparatorHovered]       = ImGui.ColorEdit4("SeparatorHovered##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.SeparatorHovered]       )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.SeparatorActive]        = ImGui.ColorEdit4("SeparatorActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.SeparatorActive]        )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ResizeGrip]             = ImGui.ColorEdit4("ResizeGrip##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ResizeGrip]             )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ResizeGripHovered]      = ImGui.ColorEdit4("ResizeGripHovered##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ResizeGripHovered]      )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.ResizeGripActive]       = ImGui.ColorEdit4("ResizeGripActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.ResizeGripActive]       )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.Tab]                    = ImGui.ColorEdit4("Tab##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.Tab]                    )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TabHovered]             = ImGui.ColorEdit4("TabHovered##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TabHovered]             )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TabActive]              = ImGui.ColorEdit4("TabActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TabActive]              )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TabUnfocused]           = ImGui.ColorEdit4("TabUnfocused##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TabUnfocused]           )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TabUnfocusedActive]     = ImGui.ColorEdit4("TabUnfocusedActive##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TabUnfocusedActive]     )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TableHeaderBg]          = ImGui.ColorEdit4("TableHeaderBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TableHeaderBg]          )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TableBorderStrong]      = ImGui.ColorEdit4("TableBorderStrong##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TableBorderStrong]      )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TableBorderLight]       = ImGui.ColorEdit4("TableBorderLight##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TableBorderLight]       )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TableRowBg]             = ImGui.ColorEdit4("TableRowBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TableRowBg]             )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TableRowBgAlt]          = ImGui.ColorEdit4("TableRodBgAlt##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TableRowBgAlt]        )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.TextSelectedBg]         = ImGui.ColorEdit4("TextSelectedBg##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.TextSelectedBg]       )
        tempSettings.Theme[themeName]['Color'][ImGuiCol.NavHighlight]           = ImGui.ColorEdit4("NavHighlight##" , tempSettings.Theme[themeName]['Color'][ImGuiCol.NavHighlight])
    end
        ImGui.EndChild()
        ImGui.PopStyleColor(ColorCount)
        ImGui.End()
    end

end
local function startup()
            --check for MQ2EQBC plugin
            loadSettings()
            mq.imgui.init('Theme Builder', ThemeBuilder)
            guiOpen = true
end

local function loop()
    while guiOpen do

            guiOpen = true
                -- print(tostring(theme))
        mq.delay(1)
    end
end


startup()
loop()    
