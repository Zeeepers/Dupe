## Clicker Simulator (Roblox) - Starter Kit

This is a ready-to-import starter for a simple Clicker/Simulator game in Roblox. It includes:

- Player data with DataStore (Strength, Coins, Rebirths, Click Power, Capacity)
- Click handling via RemoteEvent
- Sell Pad interaction (touch to convert Strength -> Coins)
- Upgrade Shop (ProximityPrompts: upgrade Click Power and Capacity)
- Rebirth Altar (ProximityPrompt: rebirth for multiplier; resets stats)
- Simple client GUI (click button + stat HUD)
- Rojo project file for optional live-sync

### Folder Structure

```
src/
  ReplicatedStorage/
    Shared/Config.lua
  ServerScriptService/
    Bootstrap.server.lua
    PlayerData.lua
    ClickHandler.server.lua
    InteractionHandlers.server.lua
  StarterPlayer/
    StarterPlayerScripts/
      Client.client.lua
default.project.json
```

### How to Use (Option A: Copy scripts into Roblox Studio)

1. Open Roblox Studio and your place.
2. Create the following objects in the Explorer if they don't exist:
   - ReplicatedStorage
   - ServerScriptService
   - StarterPlayer > StarterPlayerScripts
3. For each file in `src/` place it in the matching service and paste the script content.
   - `ReplicatedStorage/Shared/Config.lua` -> ReplicatedStorage > create Folder `Shared` and a ModuleScript `Config`
   - `ServerScriptService/*.lua` -> ServerScriptService (Scripts/ModuleScripts as named)
   - `StarterPlayer/StarterPlayerScripts/Client.client.lua` -> StarterPlayerScripts (LocalScript)
4. Create world interactables (optional but recommended):
   - Sell Pad: In Workspace, create Model `SellPad` with a Part named `SellPart` (anchored). Players touching it will sell Strength.
   - Shop: In Workspace, create Model `Shop` with one or more Parts. Add ProximityPrompts named `UpgradeClick` and `UpgradeCapacity` to any of those Parts.
   - Rebirth Altar: In Workspace, create Model `RebirthAltar` with a Part that has a ProximityPrompt named `RebirthPrompt`.
5. Press Play. Click the on-screen button to gain Strength, touch the SellPad to convert to Coins, use the shop prompts to upgrade, and rebirth at the altar.

### How to Use (Option B: Rojo live-sync)

1. Install Rojo (see Roblox docs) and run in this folder:
   - `rojo serve default.project.json`
2. In Roblox Studio, connect to Rojo via the Rojo plugin.
3. The scripts will sync to the correct services.

### Notes

- DataStore API works in published games. In Studio, use test mode; API access must be enabled for actual persistence.
- All costs and scaling are adjustable in `ReplicatedStorage/Shared/Config.lua`.
- If a world model (SellPad/Shop/RebirthAltar) is missing, related logic simply won't run.

