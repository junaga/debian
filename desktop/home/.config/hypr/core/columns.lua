local utils = require("core.utils")
local statePath = os.getenv("HOME") .. "/.config/hypr/state/column-widths.lua"

local loaded, savedWidths = pcall(require, "state.column-widths")
if not loaded or type(savedWidths) ~= "table" then
    savedWidths = {}
end

local columns = {}
local widthsBeforeResize = {}

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

local function activeColumnWindows()
    local active = hl.get_active_window()
    local activeColumn = column(active)
    local windows = {}

    if not activeColumn then
        return windows
    end

    for _, window in ipairs(hl.get_workspace_windows(active.workspace)) do
        local candidate = column(window)
        if candidate and candidate.index == activeColumn.index then
            table.insert(windows, window)
        end
    end

    return windows
end

local function resize(message)
    hl.dispatch(hl.dsp.layout(message))
    remember(activeColumnWindows())
end

function columns.widen()
    resize("colresize +conf")
end

function columns.narrow()
    resize("colresize -conf")
end

function columns.beginResize()
    widthsBeforeResize = {}

    for _, window in ipairs(hl.get_windows()) do
        local currentWidth = width(window)
        if currentWidth then
            widthsBeforeResize[window.address] = currentWidth
        end
    end
end

function columns.endResize()
    local resized = {}

    for _, window in ipairs(hl.get_windows()) do
        local currentWidth = width(window)
        local previous = widthsBeforeResize[window.address]

        if currentWidth and previous and currentWidth ~= previous then
            table.insert(resized, window)
        end
    end

    widthsBeforeResize = {}
    remember(resized)
end

local function edgeWindow(workspace, last)
    local target
    local targetIndex

    for _, window in ipairs(hl.get_workspace_windows(workspace)) do
        local current = column(window)

        if current and (
            targetIndex == nil or
            (last and current.index > targetIndex) or
            (not last and current.index < targetIndex)
        ) then
            target = window
            targetIndex = current.index
        end
    end

    return target
end

local function focusEdge(last)
    local active = hl.get_active_window()
    local target = active and active.workspace and edgeWindow(active.workspace, last)

    if target then
        hl.dispatch(hl.dsp.focus({ window = target }))
    end
end

function columns.focusFirst()
    focusEdge(false)
end

function columns.focusLast()
    focusEdge(true)
end

return columns
