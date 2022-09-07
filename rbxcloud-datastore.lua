--[[lit-meta
	name = "Sezei/rbxcloud-datastore"
	version = "1.0.0"
	dependencies = {
		'creationix/coro-http@3.2.3'
	}
	description = "A Roblox Open Cloud API client wrapper made for easy use with Luvit; Specifically for Datastores."
	tags = {"wrapper", "roblox"}
	author = "Sezei"
]]

local coro = require('coro-http');
local json = require('json');

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
		local res, body = coro.request('GET', sendingto, headers);
		if res.code == 200 then
			return json.parse(body);
		else
			return res.code;
		end
	end

	function wrapper:GetDataStore(datastoreName)
		if not datastoreName then return false; end
		local datastore = {}

		function datastore:ListKeysAsync(scope,AllScopes,prefix,limit,cursor)
			local sendingto = url..'/standard-datastores/datastore/entries?datastoreName='..datastoreName;
			if scope then
				sendingto = sendingto..'&scope='..scope;
			end
			if AllScopes then
				sendingto = sendingto..'&allScopes=true';
			end
			if prefix then
				sendingto = sendingto..'&prefix='..prefix;
			end
			if limit then
				sendingto = sendingto..'&limit='..limit;
			end
			if cursor then
				sendingto = sendingto..'&cursor='..cursor;
			end
			local res, body = coro.request('GET', sendingto, headers);
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
			local res, body = coro.request('GET', sendingto, headers);
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
			local res, body = coro.request('POST', sendingto, headers, json.stringify(entryValue));
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
			local res, body = coro.request('POST', sendingto, headers);
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
			local res, body = coro.request('DELETE', sendingto, headers);
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
			local res, body = coro.request('GET', sendingto, headers);
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
			local res, body = coro.request('GET', sendingto, headers);
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
