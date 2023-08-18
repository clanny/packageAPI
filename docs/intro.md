---
sidebar_position: 1
---

# Intro

A easy to use package for the Clanny Systems API that makes sure you know what you're doing.

See the [Creating your API Key](creatingkeys) page for your first steps.

## Difference in API packages/modules

Clanny currently has two API packages available for use.

### API module
This [API Module](https://create.roblox.com/marketplace/asset/6167383557) is very easy to understand for beginner programmers because of all the checks it runs on startup and API key data can be set in Roblox studio itself.
Currently all Free Assets use this to run, unless you switch the code to use another module/package.
But its major downfall is needing a new module for every API key you need to use in your game.

** Startup Checks: **
- HTTP enabled
- The code is up-to-date + give you information about your current version
- Check that the API data is in a secure location to prevent hackers from getting it
- Logs everything that happens to the Dev Console

### Modern Package
[This package](https://wally.run/package/minecraft2fun/clanny) is our newest way of using the API.
It allows programmers the ability to never leave the script they are working in by giving them all information needed while they code.
It is made to handle the modern version of Roblox codding and allows quick API usage.
The package is great for groups needing two or more API keys to be used at a time and follows all rate limits.

### Self-Made
These packages are made by individuals but still get a spot here.  These are great for groups who know exactly what they want for their groups and only need to code in those tools.  None of the extra stuff we add in to be special.  But with one major downfall, upon the announcement of every API update a developer has to figure out how to use the API update, update the code, check it, and release it.  All Clanny-made assets are updated by those why created the update and sometimes we can update our assets before we even release the API update to public.