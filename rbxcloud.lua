--[[lit-meta
	name = "Sezei/rbxcloud"
	version = "1.1.0"
	dependencies = {
		'creationix/coro-http@3.2.3'
	}
	description = "A Roblox Open Cloud API client wrapper made for easy use with Luvit."
	tags = {"wrapper", "roblox"}
	author = "Sezei"
]]

local coro = require('coro-http');
local json = require('json');

local function toheaders(tbl)
    local headers = {};
    for k,v in pairs(tbl) do
        headers[#headers+1] = {k,v};
    end
    return headers;
end

-- Create a new wrapper client
return function(token,universeid)
	local wrapper = {}
	local url = 'https://apis.roblox.com/datastores/v1/universes/'..universeid;
	local headers = {
    	['x-api-key'] = token;
		['Content-Type'] = 'application/json';
	}

	function wrapper.ListDataStoresAsync(prefix,limit,cursor)
		local sendingto = url..'/standard-datastores';
		if prefix then
			sendingto = sendingto..'?prefix='..prefix;
		end
		if prefix and limit then
			sendingto = sendingto..'&limit='..limit;
		elseif not prefix and limit then
			sendingto = sendingto..'?limit='..limit;
		end
		if (prefix or limit) and cursor then
			sendingto = sendingto..'&cursor='..cursor;
		elseif not (prefix or limit) and cursor then
			sendingto = sendingto..'?cursor='..cursor;
		end
		local res, body = coro.request('GET', sendingto, toheaders(headers));
		if res.code == 200 then
			return json.parse(body);
		else
			return res.code;
		end
	end

    function wrapper:PublishMessage(topic,message)
        local sendingto = 'https://apis.roblox.com/messaging-service/v1/universes/'..universeid..'/topics/'..topic;
        local res, body = coro.request('POST', sendingto, toheaders(headers), json.stringify({message = message}));
        if res.code == 200 then
            return json.parse(body);
        else
            return res.code;
        end
    end

    function wrapper:PushNewVersion(placeId,versionXML,pushmethod)
        if pushmethod ~= "Published" and pushmethod ~= "Saved" then
            return "Invalid push method; View https://create.roblox.com/docs/open-cloud/place-publishing-api#request for more information.";
        end
        local sendingto = 'https://version-controller.roblox.com/v1/universes/'..universeid..'/versions';
        headers['Content-Type'] = 'application/xml';
        local res, body = coro.request('POST', sendingto, toheaders(headers), versionXML);
        headers['Content-Type'] = 'application/json'; -- reset the header type
        if res.code == 200 then
            return json.parse(body);
        else
            return res.code;
        end
    end

    function wrapper:GetOrderedDataStores(name)
        if not name then return false; end
        local url = 'https://apis.roblox.com/ordered-data-stores';
        local ordereddatastore = {};

        function ordereddatastore:List(scope,parameters)
            local sendingto = url..'/v1/universes/'..universeid..'/orderedDataStores/'..name..'/scopes/'..scope..'/entries'
            if parameters and type(parameters)=='table' then
                sendingto = sendingto..'?';
                for k,v in pairs(parameters) do
                    sendingto = sendingto..'&'..k..'='..v;
                end
            end
            local res, body = coro.request('GET', sendingto, toheaders(headers));
            if res.code == 200 then
                return json.parse(body);
            else
                return res.code;
            end
        end;

        function ordereddatastore:Create(scope,id,data)
            local sendingto = url..'/v1/universes/'..universeid..'/orderedDataStores/'..name..'/scopes/'..scope..'/entries?id='..id;
            local res, body = coro.request('POST', sendingto, toheaders(headers), json.stringify(data));
            if res.code == 200 then
                return json.parse(body);
            else
                return res.code;
            end
        end;

        function ordereddatastore:Get(scope,entry)
            local sendingto = url..'/v1/universes/'..universeid..'/orderedDataStores/'..name..'/scopes/'..scope..'/entries/'..entry;
            local res, body = coro.request('GET', sendingto, toheaders(headers));
            if res.code == 200 then
                return json.parse(body);
            else
                return res.code;
            end
        end;

        function ordereddatastore:Delete(scope,entry)
            local sendingto = url..'/v1/universes/'..universeid..'/orderedDataStores/'..name..'/scopes/'..scope..'/entries/'..entry;
            local res, body = coro.request('DELETE', sendingto, toheaders(headers));
            if res.code == 200 then
                return json.parse(body);
            else
                return res.code;
            end
        end;

        function ordereddatastore:Update(scope,entry,data)
            local sendingto = url..'/v1/universes/'..universeid..'/orderedDataStores/'..name..'/scopes/'..scope..'/entries/'..entry;
            local res, body = coro.request('PATCH', sendingto, toheaders(headers), json.stringify(data));
            if res.code == 200 then
                return json.parse(body);
            else
                return res.code;
            end
        end;

        function ordereddatastore:Increment(scope,entry,increment)
            local sendingto = url..'/v1/universes/'..universeid..'/orderedDataStores/'..name..'/scopes/'..scope..'/entries/'..entry..':increment';
            local res, body = coro.request('POST', sendingto, toheaders(headers), json.stringify({amount = increment}));
            if res.code == 200 then
                return json.parse(body);
            else
                return res.code;
            end
        end;

        function ordereddatastore:Decrement(scope,entry,decrement)
            local sendingto = url..'/v1/universes/'..universeid..'/orderedDataStores/'..name..'/scopes/'..scope..'/entries/'..entry..':increment';
            local res, body = coro.request('POST', sendingto, toheaders(headers), json.stringify({amount = (-decrement)}));
            if res.code == 200 then
                return json.parse(body);
            else
                return res.code;
            end
        end;

        return ordereddatastore;
    end;

	function wrapper:GetDataStore(datastoreName)
		if not datastoreName then return false; end
		local datastore = {}

		function datastore:ListKeysAsync(parameters)
			local sendingto = url..'/standard-datastores/datastore/entries?datastoreName='..datastoreName;
			if parameters and type(parameters)=='table' then
                for k,v in pairs(parameters) do
                    sendingto = sendingto..'&'..k..'='..v;
                end
            end
			local res, body = coro.request('GET', sendingto, toheaders(headers));
			if res.code == 200 then
				return json.parse(body);
			else
				return res.code;
			end
		end

		function datastore:GetAsync(entryKey,scope)
			if not entryKey then return false; end -- EntryKey is required
			if not scope then scope = 'global'; end

			local sendingto = url..'/standard-datastores/datastore/entries/entry?datastoreName='..datastoreName..'&entryKey='..entryKey..'&scope='..scope;
			local res, body = coro.request('GET', sendingto, toheaders(headers));
			if res.code == 200 then
				return json.parse(body);
			else
				return res.code;
			end
		end

		function datastore:SetAsync(entryKey,entryValue,scope)
			if not entryKey then return false; end -- EntryKey is required
			if not entryValue then print("If you want to remove a datastore entry, use datastore:RemoveAsync()"); return false; end
			if not scope then scope = 'global'; end

			local sendingto = url..'/standard-datastores/datastore/entries/entry?datastoreName='..datastoreName..'&entryKey='..entryKey..'&scope='..scope;
			local res, body = coro.request('POST', sendingto, toheaders(headers), json.stringify(entryValue));
			if res.code == 200 then
				return json.parse(body);
			else
				return res.code;
			end
		end

		function datastore:IncrementAsync(entryKey,IncrementBy,scope)
			if not entryKey then return false; end -- EntryKey is required
			if not IncrementBy then IncrementBy = 1; end -- IncrementBy is optional, so we just default it to 1.
			if not scope then scope = 'global'; end

			local sendingto = url..'/standard-datastores/datastore/entries/entry/increment?datastoreName='..datastoreName..'&entryKey='..entryKey..'&scope='..scope..'&incrementBy='..IncrementBy;
			local res, body = coro.request('POST', sendingto, toheaders(headers));
			if res.code == 200 then
				return json.parse(body);
			else
				return res.code;
			end
		end

		function datastore:RemoveAsync(entryKey,scope)
			if not entryKey then return false; end -- EntryKey is required
			if not scope then scope = 'global'; end

			local sendingto = url..'/standard-datastores/datastore/entries/entry?datastoreName='..datastoreName..'&entryKey='..entryKey..'&scope='..scope;
			local res, body = coro.request('DELETE', sendingto, toheaders(headers));
			if res.code == 204 then
				return true;
			else
				return res.code;
			end
		end

		function datastore:ListVersionsAsync(entryKey,scope,limit,cursor,sortOrder,startTime,endTime)
			if not entryKey then return false; end -- EntryKey is required
			if not scope then scope = 'global'; end -- Scope is optional, so we just default it to global.
			local sendingto = url..'/standard-datastores/datastore/entries/entry/versions?datastoreName='..datastoreName..'&entryKey='..entryKey..'&scope='..scope;
			if startTime then
				sendingto = sendingto..'&startTime='..startTime;
			end
			if endTime then
				sendingto = sendingto..'&endTime='..endTime;
			end
			if sortOrder then
				sendingto = sendingto..'&sortOrder='..sortOrder;
			end
			if limit then
				sendingto = sendingto..'&limit='..limit;
			end
			if cursor then
				sendingto = sendingto..'&cursor='..cursor;
			end
			local res, body = coro.request('GET', sendingto, toheaders(headers));
			if res.code == 200 then
				return json.parse(body);
			else
				return res.code;
			end
		end

		function datastore:GetVersionAsync(entryKey,scope,versionId)
			if not entryKey then return false; end -- EntryKey is required
			if not versionId then return false; end -- VersionId is required
			if not scope then scope = 'global'; end -- Scope is optional, so we just default it to global.
			local sendingto = url..'/standard-datastores/datastore/entries/entry/versions/version?datastoreName='..datastoreName..'&entryKey='..entryKey..'&scope='..scope..'&versionId='..versionId;
			local res, body = coro.request('GET', sendingto, toheaders(headers));
			if res.code == 200 then
				return json.parse(body);
			else
				return res.code;
			end
		end
		return datastore
	end

	return wrapper
end
