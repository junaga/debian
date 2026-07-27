local utils = require("core.utils")
local stateModule = "state.column-widths"
local statePath = os.getenv("HOME") .. "/.config/hypr/state/column-widths.lua"

local loaded, savedWidths = pcall(require, stateModule)
if not loaded or type(savedWidths) ~= "table" then
    savedWidths = {}
end

local columns = {}

local function regexEscape(value)
    return value:gsub("([\\.^$|?*+()%[%]{}])", "\\%1")
end

local function serialize()
    local classes = {}
    for class in pairs(savedWidths) do
        table.insert(classes, class)
    end
    table.sort(classes)

    local lines = { "return {" }
    for _, class in ipairs(classes) do
        table.insert(lines, ("    [%q] = %.3f,"):format(class, savedWidths[class]))
    end
    table.insert(lines, "}")

    return table.concat(lines, "\n") .. "\n"
end

for class, width in pairs(savedWidths) do
    if type(class) == "string" and type(width) == "number" then
        hl.window_rule({
            match = { initial_class = "^" .. regexEscape(class) .. "$" },
            scrolling_width = width
        })
    end
end

function columns.saveWidth()
    local window = hl.get_active_window()
    local layout = window and window.layout
    local column = layout and layout.name == "scrolling" and layout.column

    if not column then
        return
    end

    savedWidths[window.initial_class] = column.width
    utils.writeFile(statePath, serialize())
    hl.exec_cmd("hyprctl reload")
end

local function edgeWindow(workspace, last)
    local target
    local targetIndex

    for _, window in ipairs(hl.get_workspace_windows(workspace)) do
        local layout = window.layout
        local column = layout and layout.name == "scrolling" and layout.column

        if column and (
            targetIndex == nil or
            (last and column.index > targetIndex) or
            (not last and column.index < targetIndex)
        ) then
            target = window
            targetIndex = column.index
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
