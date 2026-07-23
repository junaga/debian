local strings = import("strings")
local util = import("micro/util")

local function isWhitespace(line, index)
    local rune = util.RuneAt(line, index)
    return rune ~= "" and strings.TrimSpace(rune) == ""
end

local function deleteSelection(bp)
    if not bp.Cursor:HasSelection() then
        return false
    end

    bp.Cursor:DeleteSelection()
    bp.Cursor:ResetSelection()
    bp:Relocate()
    return true
end

function deleteWordLeft(bp)
    if deleteSelection(bp) then
        return true
    end

    if bp.Cursor.X > 0 and isWhitespace(bp.Buf:Line(bp.Cursor.Y), bp.Cursor.X - 1) then
        return bp:DeleteSubWordLeft()
    end

    return bp:DeleteWordLeft()
end

function deleteWordRight(bp)
    if deleteSelection(bp) then
        return true
    end

    if isWhitespace(bp.Buf:Line(bp.Cursor.Y), bp.Cursor.X) then
        return bp:DeleteSubWordRight()
    end

    return bp:DeleteWordRight()
end
