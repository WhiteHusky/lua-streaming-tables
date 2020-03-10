-- Lua 5.3 Required
-- If a file name is given it will use it to write and read from
-- otherwise it will use a temp file and discard it after execution
local streamingTables = require("streaming-tables")
local tempFile = arg[1] or os.tmpname()
local testTable = {
    [2]=50,
    [3]=60,
    [6]=90.23,
    [true]="booleans!",
    y=function() return "unsupported types are dropped" end,
    "hello!",
    ["nested table"]={
        60,50,40,20,10
    }
}
local fd = io.open(tempFile,"wb")

-- code from https://gist.github.com/hashmal/874792
-- edits made for corrections and displaying types
local function tprint (tbl, indent)
    if not indent then indent = 0 end
    local formatting
    local keyType
    local valueType
    for k, v in pairs(tbl) do
        keyType = type(k)
        if keyType == "number" then
            keyType = math.type(k)
        end
        valueType = type(v)
        if valueType == "number" then
            valueType = math.type(v)
        end
        formatting = string.rep("\t", indent) .. keyType .. "\t" .. tostring(k) .. ":\t"
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent+1)
        else
            print(formatting .. valueType .. "\t" .. tostring(v))
        end
    end
end

print("Table Before:")
tprint(testTable)
streamingTables.pack(fd, testTable)
fd:close()
fd = io.open(tempFile, "rb")
print("\n\nTable After:")
tprint(streamingTables.unpack(fd))
fd:close()
if not arg[1] then
    os.remove(tempFile)
end