local utils = require("core.utils")
local statePath = os.getenv("HOME") .. "/.config/hypr/state/column-widths.lua"

local loaded, savedWidths = pcall(require, "state.column-widths")
if not loaded or type(savedWidths) ~= "table" then
    savedWidths = {}
end

local columns = {}
local pointerSnapshot = {}
local dragSnapshot

local function column(window)
    local layout = window and window.layout
    return layout and layout.name == "scrolling" and layout.column
end

local function width(window)
    local current = column(window)
    return current and math.floor(current.width * 1000 + 0.5) / 1000
end

local function regexEscape(value)
    return value:gsub("([\\.^$|?*+()%[%]{}])", "\\%1")
end

local function sortedKeys(values)
    local keys = {}
    for key in pairs(values) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function serialize()
    local lines = { "return {" }
    for _, class in ipairs(sortedKeys(savedWidths)) do
        local profile = savedWidths[class]
        table.insert(lines, ("    [%q] = {"):format(class))
        table.insert(lines, ("        width = %.3f,"):format(profile.width))
        table.insert(lines, "        titles = {")
        for _, title in ipairs(sortedKeys(profile.titles)) do
            table.insert(lines, ("            [%q] = %.3f,"):format(title, profile.titles[title]))
        end
        table.insert(lines, "        },")
        table.insert(lines, "    },")
    end
    table.insert(lines, "}")

    return table.concat(lines, "\n") .. "\n"
end

for class, profile in pairs(savedWidths) do
    hl.window_rule({
        match = { initial_class = "^" .. regexEscape(class) .. "$" },
        scrolling_width = profile.width
    })

    for title, savedWidth in pairs(profile.titles) do
        hl.window_rule({
            match = {
                initial_class = "^" .. regexEscape(class) .. "$",
                initial_title = "^" .. regexEscape(title) .. "$"
            },
            scrolling_width = savedWidth
        })
    end
end

local function remember(windows)
    local changed = false

    for _, window in ipairs(windows) do
        local currentWidth = width(window)
        local class = window.initial_class
        local title = window.initial_title

        if currentWidth and type(class) == "string" and class ~= "" then
            local profile = savedWidths[class] or { titles = {} }
            local validTitle = type(title) == "string" and title ~= "" and title or nil
            local titleChanged = validTitle and profile.titles[validTitle] ~= currentWidth

            if profile.width ~= currentWidth or titleChanged then
                profile.width = currentWidth
                if validTitle then
                    profile.titles[validTitle] = currentWidth
                end
                savedWidths[class] = profile
                changed = true
            end
        end
    end

    if changed then
        utils.writeFile(statePath, serialize())
        hl.exec_cmd("hyprctl reload config-only")
    end
end

local function columnWindows(window)
    local current = column(window)
    return current and current.windows or {}
end

local function resizeColumn(message)
    hl.dispatch(hl.dsp.layout(message))
    remember(columnWindows(hl.get_active_window()))
end

function columns.widen()
    resizeColumn("colresize +conf")
end

function columns.narrow()
    resizeColumn("colresize -conf")
end

function columns.beginResize()
    pointerSnapshot = {}
    dragSnapshot = nil

    for _, window in ipairs(hl.get_windows()) do
        local currentWidth = width(window)
        if currentWidth then
            pointerSnapshot[window.address] = {
                size = window.size,
                width = currentWidth
            }
        end
    end
end

function columns.endResize()
    if dragSnapshot then
        pointerSnapshot = {}
        return
    end

    local resized = {}

    for _, window in ipairs(hl.get_windows()) do
        local currentWidth = width(window)
        local previous = pointerSnapshot[window.address]

        if currentWidth and previous and currentWidth ~= previous.width then
            table.insert(resized, window)
        end
    end

    pointerSnapshot = {}
    remember(resized)
end

function columns.beginDrag()
    local active = hl.get_active_window()
    dragSnapshot = active and pointerSnapshot[active.address]

    if dragSnapshot then
        -- Hyprland shrinks a tiled window when it becomes floating for a drag.
        -- Undo that before the terminal's resize debounce expires.
        hl.dispatch(hl.dsp.window.resize({
            x = dragSnapshot.size.x,
            y = dragSnapshot.size.y,
            window = active
        }))
    end
end

function columns.endDrag()
    local previous = dragSnapshot
    local active = hl.get_active_window()
    local windows = columnWindows(active)
    dragSnapshot = nil

    if #windows > 1 then
        local cursor = hl.get_cursor_pos()
        local target

        for _, window in ipairs(windows) do
            if window.address ~= active.address then
                target = window
                break
            end
        end

        local dropLeft = target and cursor.x < target.at.x + target.size.x / 2
        hl.dispatch(hl.dsp.layout("promote"))

        if dropLeft then
            hl.dispatch(hl.dsp.layout("swapcol l"))
        end
    end

    if previous then
        resizeColumn(("colresize %.3f"):format(previous.width))
    end
end

return columns
