local API = {}
API.__index = API

local Services = {
    Players = game:GetService("Players"),
    HttpService = game:GetService("HttpService"),
}

local API_Link = "https://moonscriptsapi-production.up.railway.app/api/boosting?key="

function API.new(...)
    local self = setmetatable({}, API)
   
    self:Start(...)

    return self
end

function API:Start(...)
    local args = {...}

    self.Arguments = args
    self.Link = API_Link.. args[3]

    self:Register()
end

function API:Update(Object, Object2)
    local Body = {
        Topic = "Update",
        AccountType = self.Arguments[1],
        Username = self.Arguments[2],
        Object = Object,
        Value = Object == "Rounds" and Values.Rounds or nil,
        Object2 = Object2 or nil,
    }

    self:SendRequest("POST", Body)
end 

function API:ClearData()
    local Body = {
        Topic = "ClearData",
        Username = self.Arguments[2],
    }

    self:SendRequest("POST", Body)
end

function API:Get(Name)
    local Body = {
        Topic = "Get",
        AccountType = self.Arguments[1],
        Username = self.Arguments[2],
        Data = Name,
    }

    local Response = self:SendRequest("POST", Body)

    if not Response.Success then
        warn("Request failed")
        return nil
    end

    local Decoded = Services.HttpService:JSONDecode(Response.Body)

    if Name == "Rounds" then
        return Decoded.RoundCount
    end

    return Decoded
end

function API:Register()
    local Body = self.Arguments[1] == "Alt" and {
        Topic = "Register",
        AccountType = self.Arguments[1],
        Username = self.Arguments[2],
        MainAccount = self.Arguments[4]
    } or {
        Topic = "Register",
        AccountType = self.Arguments[1],
        MainAccount = self.Arguments[2],
        AltsList = self.Arguments[4]
    }

    self:SendRequest("POST", Body)
end

function API:SendRequest(Method, Body)
    local Response = request({
            Url = self.Link,
            Method = Method,
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = Services.HttpService:JSONEncode(Body)
        })

    if Response.Success then
        print("Successfully sent request.")
    else
        warn("Failed to send request.")
    end

    return Response
end

return API