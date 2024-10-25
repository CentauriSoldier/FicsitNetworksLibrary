--list all keywords
local tKeyWords = {	"and", 		"break", 	"do", 		"else", 	"elseif", 	"end",
                    "false", 	"for", 		"function", "if", 		"in", 		"local",
                    "nil", 		"not", 		"or", 		"repeat", 	"return", 	"then",
                    "true", 	"until", 	"while",
                    --LuaEx keywords/types
                    "constant", 	"enum", "enumfactory",
                    "event", "eventrix",
                    "struct",	"null",	"class",	"interface",
                    "array", "arrayfactory", "classfactory", "structfactory", "structfactorybuilder"
};

--create the 'protected' table used by LuaEx
local tLuaEx = {--TODO fix inconsistency in naming and underscores
        __isbooting = type(_bUseBootDirectives) == "boolean" and _bUseBootDirectives or false,
        --__config, --set below
        --these metatables are protected from modification and general access
        __metaguard  = {"class", "classfactory", "enum", "enumfactory",
                        "eventrix", "eventrixfactory", "struct", "structfactory"},
        __keywords__	= setmetatable({}, {
            __index 	= tKeyWords,
            __newindex 	= function(t, k)
                error("Attempt to perform illegal operation: adding keyword to __keywords__ table.");
            end,
            __pairs		= function (t)
                return next, tKeyWords, nil;
            end,
            __metatable = false,
        }),
        __keywords__count__ = #tKeyWords,
        _VERSION = "LuaEx 0.90",
        --_SOURCE_PATH = getsourcepath(),
};

--_G.luaex = setmetatable({},
_ENV.luaex = setmetatable({},
{
    __index 		= tLuaEx,
    __newindex 		= function(t, k, v)

        if tLuaEx[k] then
            error("Attempt to overwrite luaex value in key '"..tostring(k).."' ("..type(k)..") with value "..tostring(v).." ("..type(v)..") .");
        end

        rawset(tLuaEx, k, v);
    end,
    __metatable 	= false,
});

local tLoaders = {};
local tRet = {};

local function loader(nIndex, sName)

    if (type(tLoaders[nIndex]) ~= "function") then
        computer.panic("Error loading file: '"..sName.."'. No loader function found.");
    end

    local bSuccess, vRetOrError = pcall(tLoaders[nIndex]);

    if not (bSuccess) then
        computer.panic("Error loading file: '"..sName.."'.\n"..vRetOrError);
    end

    return vRetOrError;
end

local fs = filesystem;

local sMainDir = "FicsitNetworksEx/LuaEx";

local tRequired = {
	sMainDir.."/typehook.lua",
    sMainDir.."/null.lua",
	sMainDir.."/constant.lua",
	sMainDir.."/array.lua",
	sMainDir.."/enum.lua",
    sMainDir.."/metahook.lua",
	sMainDir.."/cloner.lua",
	sMainDir.."/serializer.lua",
    sMainDir.."/class.lua",
    sMainDir.."/base64.lua",
};

--create the loaders
for nIndex, pFile in ipairs(tRequired) do

    if not (fs.isFile(pFile)) then
        computer.panic("File does not exist: '"..pFile.."'");
    end

    local fLoader = fs.loadFile(pFile);

    if (type(fLoader) ~= "function") then
        computer.panic("Could not load file: '"..pFile.."'");
    end

    tLoaders[nIndex] = fLoader;
end

--load the files
type                                = loader(1,     "typehook");
null                                = loader(2,     "null");
constant                            = loader(3,     "constant");
array                               = loader(4,     "array");
enum                                = loader(5,     "enum");
rawsetmetatable, rawgetmetatable    = loader(6,     "metahook");
cloner                              = loader(7,     "cloner");
serializer                          = loader(8,     "serializer");
class                               = loader(9,     "class");
base64                              = loader(10,    "base64");


--[[
HOW TO
-- Shorten name
fs = filesystem
-- Initialize /dev
if fs.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end
-- List all the drives
for _, drive in pairs(fs.children("/dev")) do
    print("drive "..drive)
end


-- Let say UUID of the drive is 7A4324704A53821154104A87BE5688AC
disk_uuid = "0000000000000000CED197BBC86D573B"
--0000000000000000CED197BBC86D573B ACTUAL
-- Mount our drive to root
fs.mount("/dev/"..disk_uuid, "/")


local fRequired = fs.loadFile("FicsitNetworksEx/init.lua");
--local fRequired = fs.loadFile("LuaEx/init.lua");


if type(fRequired) ~= "function" then
	computer.panic("Cannot initialize LuaEx.")
end

fRequired();

print(type(null))

]]
