--[=[
	@class UtilServer
	@server
	Everything that runs on the server.  Every function yields.
]=]

--[=[
	@interface NewToken
	@within UtilServer
	.Name? "Name" -- The name of the new token.
	.ApiKey "ApiKey" -- The long ID when generating your API key.
	.KeyId "KeyId" -- the short ID when generating your API key.
	.GroupId "GroupId" -- Your [Roblox](https://roblox.com) group's ID.

	:::info Name field
	Although the "Name" field is not required, is is highly suggested to have it.  Especially when having two or more instances running.  Without the name field the first token created will receive the name "Primary", and the second to be made will receive "Secondary".  **Any after that will error.**
	:::
]=]

type NewToken = {
	Name: string?,
	KeyId: string,
	ApiKey: string,
	GroupId: number | string,
	UseCache: boolean?,
}

type XpReturn = {
	Code: "Success" | "NotSetup" | "Failed",
	OldAmount: number,
	NewAmount: number,
}

--[=[
@within UtilServer
@interface XpReturn
.Code "Success" | "NotSetup" | "Failed",
.OldAmount number,
.NewAmount number,
]=]

type RankReturn = {
	id: number,
	locked: boolean,
	name: string,
	perm: number,
	rank: number,
	xp: number,
	prefix: string,
	prefixEnabled: boolean,
	role: string,
	roleEnabled: boolean,
}

--[=[
@within UtilServer
@interface RankReturn
.id number,
.locked boolean,
.name string,
.perm number,
.rank number,
.xp number,
.prefix string,
.prefixEnabled boolean,
.role string,
.roleEnabled: boolean,
]=]

type RoleReturn = {
	id: number,
	name: string,
	rank: number,
	memberCount: number,
	ID: number,
}

--[=[
@within UtilServer
@interface RoleReturn
.id number,
.name string,
.rank number,
.memberCount number,
.ID number,
]=]

type MedalReturn = {
	Description: string,
	Name: string,
	Emoji: string,
	Id: number,
}

--[=[
@within UtilServer
@interface MedalReturn
.Description string,
.Name string,
.Emoji string,
.Id number,
]=]

type UserMedalReturn = {
	amount: number,
	id: string | number,
}

--[=[
@within UtilServer
@interface UserMedalReturn
.amount number
.id string | number,
]=]

type UtilServerReturn = {
	CreateToken: (NewToken) -> APIpoints,
	GetToken: (TokenName: string) -> APIpoints,
	DeleteToken: (TokenName: string) -> boolean,
	QuickClean: () -> boolean,
}

type APIpoints = {
	XP: {
		GetXp: (userId: number | string) -> number,
		IncrementXp: (userId: number | string, amount: number | string) -> XpReturn,
		SetXp: (userId: number | string, amount: number | string) -> XpReturn,
	},
	RANK: {
		GetUserRank: (
			userId: number | string
		) -> { Previous: RankReturn | nil, Current: RankReturn | nil, Next: RankReturn | nil },
		GetAllRanks: () -> { RankReturn },
		PromoteUser: (userId: number | string) -> { newRole: RoleReturn | nil, oldRole: RoleReturn | nil },
		DemoteUser: (userId: number | string) -> { newRole: RoleReturn | nil, oldRole: RoleReturn | nil },
		SetUserRank: (
			userId: number | string,
			rank: number | string
		) -> { newRole: RoleReturn | nil, oldRole: RoleReturn | nil },
	},
	MEDALS: {
		GetAllMedals: () -> { MedalReturn },
		GetUserMedals: (userId: number | string) -> { MedalReturn & UserMedalReturn },
		GetUserMedalCount: (userId: number | string, medalId: number | string) -> { UserMedalReturn | "nomedal" },
		AddUserMedal: (userId: number | string, medalId: number | string) -> "added1" | "createdStore",
		RemoveUserMedal: (
			userId: number | string,
			medalId: number | string
		) -> "removed1" | "deletedStore" | "doesntHaveMedal",
	},
	PENDING: {
		AcceptUser: (userId: number | string) -> boolean,
		DeclineUser: (userId: number | string) -> boolean,
	},
}

--[=[
	@within UtilServer
	@type APIpoints { XPendpoints & RANKendpoints &  MEDALSendpoints & PENDINGendpoints}
]=]

--[=[
	@within UtilServer
	@interface 	XPendpoints
	.GetXp (userId: number | string) -> number
	.IncrementXp (userId: number | string, amount: number | string) -> XpReturn,
	.SetXp (userId: number | string, amount: number | string) -> XpReturn,
]=]

--[=[
	@within UtilServer
	@interface 	RANKendpoints
	.GetUserRank (userId: number | string) -> { Previous: RankReturn | nil, Current: RankReturn | nil, Next: RankReturn | nil },
	.GetAllRanks () -> { <RankReturn> },
	.PromoteUser (userId: number | string) -> { newRole: RoleReturn | nil, oldRole: RoleReturn | nil },
	.DemoteUser (userId: number | string) -> { newRole: RoleReturn | nil, oldRole: RoleReturn | nil },
	.SetUserRank (userId number | string, rank number | string) -> { newRole: RoleReturn | nil, oldRole: RoleReturn | nil }
]=]

--[=[
	@within UtilServer
	@interface 	MEDALSendpoints
	.GetAllMedals () -> { <MedalReturn> },
	.GetUserMedals (userId: number | string) -> { MedalReturn & UserMedalReturn },
	.GetUserMedalCount (userId: number | string, medalId: number | string) -> { UserMedalReturn | "nomedal" },
	.AddUserMedal (userId: number | string, medalId: number | string) -> "added1" | "createdStore",
	.RemoveUserMedal (userId: number | string, medalId: number | string) -> "removed1" | "deletedStore" | "doesntHaveMedal",
]=]

--[=[
	@within UtilServer
	@interface 	PENDINGendpoints
	.AcceptUser (userId: number | string) -> boolean,
	.DeclineUser (userId: number | string) -> boolean,
	Used to accept or decline pending users into your group.
]=]

local HttpService = game:GetService("HttpService")

local Tokens = {}

local function DoesTokenExist(tokenName: string): boolean
	local token: NewToken = Tokens[tokenName]
	return token ~= nil
end

local ErrorBlock = {}
local OnHold = {}

local function SendRequest(url: string, method: string, tokenName: string, body: table?)
	assert(DoesTokenExist(tokenName), `Token does not appear to exist; Name given: {tokenName}`)
	local hold = table.insert(OnHold, {})
	repeat
		wait()
	until #OnHold <= 5
	local TokenData = Tokens[tokenName]
	local Success, Response = pcall(function()
		return HttpService:RequestAsync({
			Url = `https://api.clanny.systems/api/rv4/{url}`,
			Method = string.upper(method),
			Headers = {
				["group-id"] = tostring(TokenData.GroupId),
				["key-id"] = tostring(TokenData.KeyId),
				["authorization"] = tostring(TokenData.ApiKey),
			},
			Body = body and HttpService:JSONEncode(body) or nil,
		})
	end)
	table.remove(OnHold, hold)
	local decode = HttpService:JSONDecode(Response.Body)
	if Success and decode.status == 200 then
		return decode
	else
		warn("[ClannyAPI] HTTP ERROR: ", `{decode.statusMessage}.  Request: https://api.clanny.systems/api/rv4/{url}`)
		if (decode.automaticRetry ~= nil) and decode.automaticRetry == true then
			if ErrorBlock[url] then
				ErrorBlock[url] += 1
			else
				ErrorBlock[url] = 1
			end
			if ErrorBlock[url] >= 3 then
				ErrorBlock[url] = nil
				return nil
			else
				return SendRequest(url, method, tokenName, body)
			end
		end
		return nil
	end
end

local EndPoints = function()
	local tokenName = nil
	local XP = {
		GetXp = function(userId: number | string)
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			local request = SendRequest(`exp/{userId}`, "get", tokenName)
			return request and request.data or false
		end,
		IncrementXp = function(userId: number | string, amount: number | string): XpReturn
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			assert(
				(type(amount) == "string" or type(amount) == "number") and tonumber(amount),
				"amount must be a integer only string or number"
			)
			local request = SendRequest(`exp/{userId}`, "post", tokenName, { operation = "add", amount = amount })
			return request and request.data or false
		end,
		SetXp = function(userId: number | string, amount: number | string): XpReturn
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			assert(
				(type(amount) == "string" or type(amount) == "number") and tonumber(amount),
				"amount must be a integer only string or number"
			)
			local request = SendRequest(`exp/{userId}`, "post", tokenName, { operation = "set", amount = amount })
			return request and request.data or false
		end,
		AddXp = function(userId)
			local request = SendRequest("exp/")
		end,
	}
	local RANK = {
		GetUserRank = function(
			userId: number | string
		): { Previous: RankReturn | nil, Current: RankReturn | nil, Next: RankReturn | nil }
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			local request = SendRequest(`rank/{userId}`, "get", tokenName)
			return request and request.data or false
		end,
		GetAllRanks = function(): { RankReturn }
			local request = SendRequest(`rank/`, "get", tokenName)
			return request and request.data or false
		end,
		PromoteUser = function(userId: number | string): { newRole: RoleReturn | nil, oldRole: RoleReturn | nil }
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			local request = SendRequest(`rank/{userId}`, "post", tokenName, { action = "promote" })
			return request and request.data or false
		end,
		DemoteUser = function(userId: number | string): { newRole: RoleReturn | nil, oldRole: RoleReturn | nil }
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			local request = SendRequest(`rank/{userId}`, "post", tokenName, { action = "demote" })
			return request and request.data or false
		end,
		SetUserRank = function(
			userId: number | string,
			rank: number | string
		): { newRole: RoleReturn | nil, oldRole: RoleReturn | nil }
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			assert(
				(type(rank) == "string" or type(rank) == "number") and tonumber(rank),
				"rank must be a integer only string or number"
			)
			local request = SendRequest(`rank/{userId}`, "post", tokenName, { action = "set" })
			return request and request.data or false
		end,
	}
	local MEDALS = {
		GetAllMedals = function(): { MedalReturn }
			local request = SendRequest(`medal/`, "get", tokenName)
			return request and request.data or false
		end,
		GetUserMedals = function(userId: number | string): { MedalReturn & UserMedalReturn }
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			local request = SendRequest(`medal/{userId}`, "get", tokenName)
			return request and request.data or false
		end,
		GetUserMedalCount = function(
			userId: number | string,
			medalId: number | string
		): { UserMedalReturn } | "nomedal"
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			assert(
				(type(medalId) == "string" or type(medalId) == "number") and tonumber(medalId),
				"medalId must be a integer only string or number"
			)
			local request = SendRequest(`medal/{userId}/{medalId}`, "get", tokenName)
			return request and request.data or false
		end,
		AddUserMedal = function(userId: number | string, medalId: number | string): "added1" | "createdStore"
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			assert(
				(type(medalId) == "string" or type(medalId) == "number") and tonumber(medalId),
				"medalId must be a integer only string or number"
			)
			local request = SendRequest(`medal/{userId}/{medalId}`, "post", tokenName)
			return request and request.data or false
		end,
		RemoveUserMedal = function(
			userId: number | string,
			medalId: number | string
		): "removed1" | "deletedStore" | "doesntHaveMedal"
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			assert(
				(type(medalId) == "string" or type(medalId) == "number") and tonumber(medalId),
				"medalId must be a integer only string or number"
			)
			local request = SendRequest(`medal/{userId}/{medalId}`, "delete", tokenName)
			return request and request.data or false
		end,
	}
	local PENDING = {
		AcceptUser = function(userId: number | string): boolean
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			local request = SendRequest(`pendingjoin/{userId}/accept`, "post", tokenName)
			return request and request.data or false
		end,
		DeclineUser = function(userId: number | string): boolean
			assert(
				(type(userId) == "string" or type(userId) == "number") and tonumber(userId),
				"userId must be a integer only string or number"
			)
			local request = SendRequest(`pendingjoin/{userId}/decline`, "post", tokenName)
			return request and request.data or false
		end,
	}
	local function __setName(value)
		tokenName = value
	end
	return {
		__setName = __setName,
		XP = XP,
		RANK = RANK,
		MEDALS = MEDALS,
		PENDING = PENDING,
	}
end

local UtilServer: UtilServerReturn = {}

--[=[
	@function CreateToken
	@within UtilServer
	@param {TokenData} NewToken
	@return APIpoints
	Initiating your new API.  You can start calling API endpoints directly after from the table that gets returned.
]=]

function UtilServer.CreateToken(tokenData: NewToken): APIpoints
	assert(type(tokenData) == "table", `Token must be a table; got {type(tokenData)}`)

	assert(not DoesTokenExist(tokenData.Name), `Token "{tokenData.Name}" already exists`)
	assert(
		(type(tokenData.Name) == "string") or ((not DoesTokenExist("Primary")) or not DoesTokenExist("Secondary")),
		"Token preset names filled.  Pass a name into CreateToken"
	)

	assert(type(tokenData.KeyId) == "string", `Token.KeyId must be a string, got {type(tokenData.KeyId)}`)
	assert(#tokenData.KeyId > 0, "Token.KeyId must be a non-empty string")

	assert(type(tokenData.ApiKey) == "string", `Token.ApiKey must be a string, got {type(tokenData.ApiKey)}`)
	assert(#tokenData.ApiKey > 0, "Token.ApiKey must be a non-empty string")

	assert(
		type(tokenData.GroupId) == "string" or type(tokenData.GroupId) == "number",
		`Token.ApiKey must be a string or number, got {type(tokenData.ApiKey)}`
	)
	assert(
		(type(tokenData.GroupId) == "string" and #tokenData.GroupId > 0)
			or (type(tokenData.GroupId) == "number" and tokenData.GroupId > 0),
		"Service.GroupId must be a non-empty string"
	)

	tokenData.Name = tokenData.Name
		or not DoesTokenExist("Primary") and "Primary"
		or not DoesTokenExist("Secondary") and "Secondary"
	tokenData.UseCache = tokenData.UseCache or false

	Tokens[tokenData.Name] = tokenData
	local new = EndPoints()
	new.__setName(tokenData.Name)
	return new
end

--[=[
	@function GetToken
	@within UtilServer
	A way to get your APIpoints through the Token name.
	@param TokenName string
	@return APIpoints
]=]

function UtilServer.GetToken(tokenName: string): APIpoints | false
	if not DoesTokenExist(tokenName) then
		return false
	else
		local new = EndPoints()
		new.__setName(tokenName)
		return new
	end
end

--[=[
	@function DeleteToken
	@within UtilServer
	A way to delete your API key data from the code.
	@param TokenName string
	@return boolean
	:::note 💀
	*if you actually find a use for this, please tell me.  minecraft2fun on Discord.*
	:::
]=]

function UtilServer.DeleteToken(tokenName: string): boolean
	if DoesTokenExist(tokenName) then
		Tokens[tokenName] = nil
		return true
	else
		return false
	end
end

--[=[
	@function QuickClean
	@within UtilServer
	@tag Unreleased
	Deletes all API Key data immediately, great if you really want to be careful.
	@return boolean
]=]

function UtilServer.QuickClean(): boolean
	pcall(function()
		Tokens = nil
		Tokens = {}
		return true
	end)
	return false
end

return UtilServer
