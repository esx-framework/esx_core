# fivem-appearance

A flexible player customization script for FiveM.

This resource was designed to manage all GTA V player/ped customization in only one place, with an opinionated way to handle the data.

## Features

- Freemode ped full customization (Head blend, Face features, Head overlays, Components, Props).
- Exports API to get and set every part of player/ped appearance.
- [Built-in customization feature](https://streamable.com/t59gdt "Preview").

## Preview

![Customization Preview](https://imgur.com/VgNAvgC.png "Customization Preview")
![Customization Preview](https://i.imgur.com/wzY7XNu.png "Customization Preview")
![Customization Preview](https://imgur.com/B0m6g6q.png "Customization Preview")

## Installation

**Download**

Go to releases and get the latest version.

**Build yourself**

1. Clone the repository into your `resources/[local]` folder.
2. Execute the build script.

   ```bash
   yarn build
   ```

3. Start development.

**Disclaimer**

This is a development resource, if you don't use the exports the resource itself will do nothing.

## ConVars

Since this is a client script, you will need to use **setr** to set these convars.

- **fivem-appearance:locale**: the name of one file inside `locales/`, default **en**, choose the locale file for the customization interface.
- **fivem-appearance:automaticFade**: If set to 0, hair fade could be selected by the player, otherwise it will be automatic. default **1**.
config.cfg example:

```cfg
setr fivem-appearance:locale "en"
setr fivem-appearance:automaticFade 1
ensure fivem-appearance
```

## Client Exports

### Appearance

| Export              | Parameters                                     | Return            |
| ------------------- | ---------------------------------------------- | ----------------- |
| getPedModel         | ped: _number_                                  | _string_          |
| getPedComponents    | ped: _number_                                  | _PedComponent[]_  |
| getPedProps         | ped: _number_                                  | _PedProp[]_       |
| getPedHeadBlend     | ped: _number_                                  | _PedHeadBlend_    |
| getPedFaceFeatures  | ped: _number_                                  | _PedFaceFeatures_ |
| getPedHeadOverlays  | ped: _number_                                  | _PedHeadOverlays_ |
| getPedHair          | ped: _number_                                  | _PedHair_         |
| getPedTattoos       |                                                | _TattooList_      |
| getPedAppearance    | ped: _number_                                  | _PedAppearance_   |
| setPlayerModel      | model: _string_                                | _Promise\<void\>_ |
| setPedComponent     | ped: _number_, component: _PedComponent_       | _void_            |
| setPedComponents    | ped: _number_, components: _PedComponent[]_    | _void_            |
| setPedProp          | ped: _number_, prop: _PedProp_                 | _void_            |
| setPedProps         | ped: _number_, props: _PedProp[]_              | _void_            |
| setPedFaceFeatures  | ped: _number_, faceFeatures: _PedFaceFeatures_ | _void_            |
| setPedHeadOverlays  | ped: _number_, headOverlays: _PedHeadOverlays_ | _void_            |
| setPedHair          | ped: _number_, hair: _PedHair_                 | _void_            |
| setPedEyeColor      | ped: _number_, eyeColor: _number_              | _void_            |
| setPedTattoos       | ped: _number_, tattoos: _TattooList_           | _void_            |
| setPlayerAppearance | appearance: _PedAppearance_                    | _void_            |
| setPedAppearance    | ped: _number_, appearance: _PedAppearance_     | _void_            |

### Customization

This export is only available if **fivem-appearance:customization** is set to 1.

| Export                   | Parameters                                                                                    | Return |
| ------------------------ | --------------------------------------------------------------------------------------------- | ------ |
| startPlayerCustomization | callback: _((appearance: PedAppearance \| undefined) => void)_, config? _CustomizationConfig_ | _void_ |

## Examples

**Customization command (Lua)**

```lua
RegisterCommand('customization', function()
  local config = {
    ped = true,
    headBlend = true,
    faceFeatures = true,
    headOverlays = true,
    components = true,
    props = true,
    tattoos = true
  }

  exports['fivem-appearance']:startPlayerCustomization(function (appearance)
    if (appearance) then
      print('Saved')
    else
      print('Canceled')
    end
  end, config)
end, false)
```

**Start player customization with callback (TypeScript)**

```typescript
const exp = (global as any).exports;

exp["fivem-appearance"].startPlayerCustomization((appearance) => {
  if (appearance) {
    console.log("Customization saved");
    emitNet("genericSaveAppearanceDataServerEvent", JSON.stringify(appearance));
  } else {
    console.log("Customization canceled");
  }
});
```

**Set player appearance (TypeScript)**

```typescript
const exp = (global as any).exports;

onNet("genericPlayerAppearanceLoadedServerEvent", (appearance) => {
  exp["fivem-appearance"].setPlayerAppearance(appearance);
});
```

## Data

Scripts used to generate some of the resource's data.

[Peds](https://gist.github.com/snakewiz/b37a18e92cc0b112ce0fa57b1096b96b "Gist")

## Credits

- [TomGrobbe](https://github.com/TomGrobbe) for the customization camera behavior
- [root-cause](https://github.com/root-cause) for some of the game data
- [xIAlexanderIx](https://github.com/xIAlexanderIx) for general inspiration
