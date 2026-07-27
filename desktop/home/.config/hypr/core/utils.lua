local utils = {}

function utils.writeFile(path, contents)
    local directory = path:match("^(.*)/[^/]+$")
    if directory then
        assert(os.execute(("mkdir -p %q"):format(directory)))
    end

    local temporary = path .. ".tmp"
    local file = assert(io.open(temporary, "w"))

    local written, writeError = file:write(contents)
    if not written then
        file:close()
        os.remove(temporary)
        error(writeError)
    end

    assert(file:close())

    local renamed, renameError = os.rename(temporary, path)
    if not renamed then
        os.remove(temporary)
        error(renameError)
    end
end

return utils
