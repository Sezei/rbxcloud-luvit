--[[lit-meta
	name = "Sezei/rbxcloud-messagingservice"
	version = "1.0.0"
	dependencies = {
		'creationix/coro-http@3.2.3'
	}
	description = "A Roblox Open Cloud API client wrapper made for easy use with Luvit; Specifically for MessagingService."
	tags = {"wrapper", "roblox"}
	author = "Sezei"
]]

local coro = require('coro-http');
local json = require('json');

return function(token,universeid)
    local wrapper = {}
	local url = 'https://apis.roblox.com/messaging-service/v1/universes/'..universeid..'/topics/';
	local headers = {
    		{'x-api-key',token};
		{'Content-Type','application/json'};
	}

    function wrapper:PublishMessage(topic,message)
        local body = json.stringify({
            message = message;
        })
        local res, body = coro.request('POST',url..topic,body,headers);
        if res.code == 200 then
            return true;
        else
            return false;
        end
    end
end;
