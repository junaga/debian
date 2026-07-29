local tape = {}

local function column(window)
    local layout = window and window.layout
    return layout and layout.name == "scrolling" and layout.column
end

local function visibleWorkspaces()
    local monitors = hl.get_monitors()
    local workspaces = {}

    table.sort(monitors, function(left, right)
        return left.y == right.y and left.x < right.x or left.y < right.y
    end)

    for _, monitor in ipairs(monitors) do
        local workspace = monitor.active_workspace
        if workspace and not workspace.special and workspace.id > 0 then
            table.insert(workspaces, workspace)
        end
    end

    return workspaces
end

local function existingWorkspaces()
    local workspaces = {}

    for _, workspace in ipairs(hl.get_workspaces()) do
        if not workspace.special and not workspace.is_empty and workspace.id > 0 then
            table.insert(workspaces, workspace)
        end
    end

    table.sort(workspaces, function(left, right)
        return left.id < right.id
    end)

    return workspaces
end

local function workspaceIndex(workspaces, workspace)
    for index, candidate in ipairs(workspaces) do
        if candidate.id == workspace.id then
            return index
        end
    end
end

local function adjacent(workspaces, workspace, step)
    local index = workspaceIndex(workspaces, workspace)
    if not index or #workspaces == 0 then
        return
    end

    return workspaces[(index - 1 + step) % #workspaces + 1]
end

local function edgeWindow(workspace, last)
    local edge
    local edgeIndex

    for _, window in ipairs(hl.get_workspace_windows(workspace)) do
        local candidate = column(window)
        if candidate and (
            not edgeIndex or
            (last and candidate.index > edgeIndex) or
            (not last and candidate.index < edgeIndex)
        ) then
            edge = window
            edgeIndex = candidate.index
        end
    end

    return edge
end

local function populated(workspaces)
    local result = {}

    for _, workspace in ipairs(workspaces) do
        if edgeWindow(workspace, false) then
            table.insert(result, workspace)
        end
    end

    return result
end

local function focus(window)
    if window then
        hl.dispatch(hl.dsp.focus({ window = window }))
    end
end

local function atEdge(last)
    local active = hl.get_active_window()
    local current = column(active)
    local edge = active and active.workspace and column(edgeWindow(active.workspace, last))

    return current and edge and current.index == edge.index
end

local function moveToEdge(last)
    local active = hl.get_active_window()
    local current = column(active)
    local edge = active and active.workspace and column(edgeWindow(active.workspace, last))

    if not current or not edge then
        return
    end

    local direction = last and "swapcol r" or "swapcol l"
    for _ = 1, math.abs(edge.index - current.index) do
        hl.dispatch(hl.dsp.layout(direction))
    end
end

local function stepFocus(step)
    local active = hl.get_active_window()
    if not active then
        return
    end

    local forward = step > 0
    if not atEdge(forward) then
        hl.dispatch(hl.dsp.layout(forward and "focus r" or "focus l"))
        return
    end

    local workspaces = populated(visibleWorkspaces())
    local workspace = adjacent(workspaces, active.workspace, step)
    focus(workspace and edgeWindow(workspace, not forward))
end

local function moveWindow(window, workspace, follow)
    hl.dispatch(hl.dsp.window.move({
        window = window,
        workspace = workspace,
        follow = follow
    }))
end

local function resize(width)
    if width then
        hl.dispatch(hl.dsp.layout(("colresize %.3f"):format(width)))
    end
end

local function stepWindow(step)
    local active = hl.get_active_window()
    if not active then
        return
    end

    local activeColumn = column(active)
    local forward = step > 0
    if not atEdge(forward) then
        hl.dispatch(hl.dsp.layout(forward and "swapcol r" or "swapcol l"))
        return
    end

    local workspace = adjacent(visibleWorkspaces(), active.workspace, step)
    if not workspace or workspace.id == active.workspace.id then
        moveToEdge(not forward)
        return
    end

    moveWindow(active, workspace, true)
    resize(activeColumn.width)
    moveToEdge(not forward)
end

local function globalEdge(last)
    local workspaces = populated(visibleWorkspaces())
    local workspace = workspaces[last and #workspaces or 1]
    return workspace and edgeWindow(workspace, last)
end

local function nearestWindow(active)
    local current = column(active)
    local nearest
    local nearestDistance

    for _, window in ipairs(hl.get_workspace_windows(active.workspace)) do
        if window.address ~= active.address then
            local candidate = column(window)
            local distance = current and candidate and math.abs(candidate.index - current.index) or 0

            if not nearestDistance or distance < nearestDistance then
                nearest = window
                nearestDistance = distance
            end
        end
    end

    return nearest
end

local function sendTo(workspace, last)
    local active = hl.get_active_window()
    if not active or not workspace then
        return
    end

    if active.workspace.id == workspace.id then
        moveToEdge(last)
        return
    end

    local activeColumn = column(active)
    local fallback = nearestWindow(active)

    moveWindow(active, workspace, true)
    resize(activeColumn and activeColumn.width)
    moveToEdge(last)
    focus(fallback)
end

function tape.previous()
    stepFocus(-1)
end

function tape.next()
    stepFocus(1)
end

function tape.movePrevious()
    stepWindow(-1)
end

function tape.moveNext()
    stepWindow(1)
end

function tape.first()
    focus(globalEdge(false))
end

function tape.last()
    focus(globalEdge(true))
end

function tape.sendFirst()
    sendTo(visibleWorkspaces()[1], false)
end

function tape.sendLast()
    local workspaces = visibleWorkspaces()
    sendTo(workspaces[#workspaces], true)
end

local function sendWorkspace(step)
    local active = hl.get_active_window()
    if active then
        sendTo(adjacent(existingWorkspaces(), active.workspace, step), step < 0)
    end
end

function tape.sendPreviousWorkspace()
    sendWorkspace(-1)
end

function tape.sendNextWorkspace()
    sendWorkspace(1)
end

return tape
