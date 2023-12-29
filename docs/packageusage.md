---
sidebar_position: 4
---

# Using our modern API Package
We will explain how to use this package now.
:::danger
Make sure all API calls, and API keys can only be seen by the server.  An easy way of doing this is by using only Server scripts, or putting all API related code inside `ServerScriptService` or `ServerStorage`.
:::
In these examples the script will be in `ServerStorage` and named `Clanny`.

If you need assistance at any time, join our [Support Server](https://discord.gg/AgQuFj4qV3).

## Calling the module
To call the module simply `require()` the script, it may look something like this.
```lua
local Clanny = require(game.ServerStorage.Clanny)
```

## Putting in your API keys.
API keys can be put in whenever you want, but if you try to call an endpoint before creating the key your code will error.  If you're expecting to use the API from the same script running `.CreateToken` make sure to make it a variable so save time later since you need the variable to call API Endpoints.
```lua
local Clanny = require(game.ServerStorage.Clanny)
local token = Clanny.CreateToken({
	Name="",--optional
	ApiKey="",
	KeyId="",
	GroupId=0
})
```
### `.CreateToken` variables
- **Name:** An optional field so you can name your tokens, tokens can be used later to get your APIendpoints, or delete your API Key from the scripts.  Will default to "Primary" and then "Secondary" if no name is given.  If you make more than two Tokens without a name, the third will return an error.
- **ApiKey:** A Required field that is the long ID you received from creating your API.
- **KeyId:** A Required field that is the short ID you received from creating your API.
- **GroupId:** A Required field that is you Roblox group's ID, can be found in the group page URL.

## Using Token Name to get API Endpoints
As stated above, you either need a variable tied to a `.CreateToken` or this `.GetToken` function to be able to call the API.
- This function can be called from a different script than where `.CreateToken` was called so `.CreateToken` only has to be called once per API Key.
```lua
local Clanny = require(game.ServerStorage.Clanny)
local token = Clanny.GetToken(TokenName)
```
- **TokenName** is either the `Name` field used in `.CreateToken` or the default value of "Primary", "Secondary".

## Calling API endpoints
Remember, API endpoints can only be called from the two functions below
### From `.CreateToken`
```lua
local Clanny = require(game.ServerStorage.Clanny)
local token = Clanny.CreateToken({
	Name="",--optional
	ApiKey="",
	KeyId="",
	GroupId=0
})
print(token.XP.GetXp(UserId))
```

### From `.GetToken`
```lua
local Clanny = require(game.ServerStorage.Clanny)
local token = Clanny.GetToken(TokenName)
print(token.XP.GetXp(UserId))
```
Or, if you want to make it dynamic.
```lua
local Clanny = require(game.ServerStorage.Clanny)
local function GetXp(TokenName:string, UserId:number | string)
    return Clanny.GetToken(TokenName).XP.GetXp(UserId)
end
print(GetXp("Primary", 1), GetXp("Secondary", 5))
```

## Deleting API Keys
This will cause any API calls from the deleted token to error.
```lua
local Clanny = require(game.ServerStorage.Clanny)
Clanny.DeleteToken(TokenName)
```
- **TokenName** is either the `Name` field used in `.CreateToken` or the default value of "Primary", "Secondary".

## Quick Clean
Quickly deletes all API Keys and Token data
```lua
local Clanny = require(game.ServerStorage.Clanny)
Clanny.QuickClean()
```