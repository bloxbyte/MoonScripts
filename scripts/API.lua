local API = {}
API.__index = API

local Services = {
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService"),
}

local API_Link = "https://moonscripts.live/api/booster?key="

function API.new(...)
    local self = setmetatable({}, API)
   
    self:Start(...)

    return self
end

function API:Start(...)
    local args = {...}
    print("API Started with arguments:", unpack(args))

    self.Arguments = args
    self.Link = API_Link.. args[3]

    if args[1] == "Main" then
        if #args[4] ~= 7 then
            warn("Expected 7 alts, but got " .. #args[4])
        end

        for _, alt in pairs(args[4]) do
            print("Alt:", alt)
        end
    elseif args[1] == "Alt" then
        self:Register()
    end
end

function API:Update()

end 

function API:Register()
    local Response = request({
        Url = self.Link,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = Services.HttpService:JSONEncode({
            Username = self.Arguments[2],
            MainAccount = self.Arguments[4]
        })
    })

    
end

return API