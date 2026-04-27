local API = {}
API.__index = API

local Services = {
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService"),
}

local API_Link = "https://moonscripts.live/api/"

function API.new(...)
    local self = setmetatable({}, API)
   
    self:Start(...)

    return self
end

function API:Start(...)
    local args = {...}
    print("API Started with arguments:", unpack(args))

    self.Arguments = args

    if args[1] == "Main" then
        if #args[4] ~= 7 then
            warn("Expected 7 alts, but got " .. #args[4])
        end

        for _, alt in pairs(args[4]) do
            print("Alt:", alt)
        end
    end
end

return API