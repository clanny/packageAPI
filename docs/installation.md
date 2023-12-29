---
sidebar_position: 3
---

# Installation

In the document we will explain all the way to install the API package.  For how to use it see the [Package Usage](packageusage) page.

## VS Code
VS Code or Visual Studio Code is a code editor used by many devs and is just one way to program.  Many Roblox groups use this editor for game development, then connect to Roblox through a service like [Rojo](https://rojo.space).

:::info Rojo
Rojo is a program for Roblox with multiple usages.  Including, connecting directly to Roblox Studio so you can see changes immediately, and building a game file from your terminal.
:::

### Installation

## External IDE
1. Install your favorite Toolchain manager, personally I use [Foreman](https://github.com/Roblox/foreman).
2. Next setup your toolchain manager with the tools needed.  If you're using Foreman, create a file named `foreman.toml`, the code should look something like this.
    1. Make sure to run install on your manager to get the files you need.
```lua
[tools]
rojo = { source = "rojo-rbx/rojo", version = "7.3.0" }
wally = { source = "UpliftGames/wally", version = "0.3.1" }
```
3. Next, create or find your `wally.toml` file.  Inside of it crete a new line with `[server-dependencies]`.  And add `Clanny = "minecraft2fun/clanny@^01.2"` underneath of it.
```lua
[server-dependencies]
Clanny = "minecraft2fun/clanny@^0.1.2"
```
4. Run `wally install` to install your new package.
5. All set, you may need to shuffle around your `package.default.json` file to make sure your server packages are noticed and being put into the game.

## Roblox Studio
You can get the code from the Roblox Marketplace [here](https://create.roblox.com/marketplace/asset/15092265219)

## Roblox-TS
A TS types file is available from the Wally download or the github