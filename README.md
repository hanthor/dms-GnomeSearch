# Bazaar Search Provider Plugin

A DankMaterialShell launcher plugin that integrates with [Bazaar](https://github.com/kolunmi/bazaar), allowing you to search and install Flatpak applications directly from the DMS launcher.

## Purpose

This plugin connects DMS to Bazaar's GNOME Shell search provider via DBus, bringing Flathub's extensive application catalog into your DMS launcher workflow. Search for Flatpaks and jump directly to their install page in Bazaar - similar to the existing [KRunner integration](https://github.com/ublue-os/krunner-bazaar) for KDE Plasma.

## Features

### Bazaar Integration

- **DBus Search Provider**: Uses Bazaar's `org.gnome.Shell.SearchProvider2` interface with `gdbus`
- **Real-time Search**: Query Flathub's application catalog as you type
- **Direct Install**: Opens apps directly in Bazaar for one-click installation
- **Service Detection**: Automatically detects if Bazaar is running
- **Seamless Workflow**: Search → Select → Install, all from the launcher

### Trigger System

- **Default**: No trigger required - searches Bazaar alongside other apps
- **Optional Trigger**: Can set a custom trigger (e.g., `b`) in settings
- **Usage Examples**:
  - `firefox` - Search for Firefox (with no trigger)
  - `b firefox` - Search for Firefox (with `b` trigger configured)

  - `b video editor` - Search for video editing apps  - `g wifi` - Search for WiFi settings

  - `g 2+2` - Calculate mathematical expressions

## About Bazaar  - `g smile` - Find emoji characters

  - `g documents` - Search for files

[Bazaar](https://github.com/kolunmi/bazaar) is a modern Flatpak store for GNOME with:

### Action Types

- Fast, multi-threaded application browsing

- Curated application discovery- `open:command` - Launch GNOME applications

- Support for developers through donation links- `copy:text` - Copy results to clipboard

- Background service for system-wide integration- `toast:message` - Show notifications

- GNOME Shell search provider (which this plugin uses)

## File Structure

## How It Works

```

1. **DBus Communication**: Plugin queries Bazaar via `org.gnome.Shell.SearchProvider2`GnomeSearchProvider/

2. **GetInitialResultSet**: Sends search terms to Bazaar├── plugin.json                           # Plugin manifest

3. **GetResultMetas**: Retrieves app names, descriptions, and icons├── GnomeSearchProviderLauncher.qml       # Main launcher component

4. **ActivateResult**: Opens selected app in Bazaar for installation├── GnomeSearchProviderSettings.qml       # Settings interface

└── README.md                             # This documentation

``````

User types "b firefox"

    ↓## Installation

DMS Plugin → Bazaar (DBus)

    ↓1. **Plugin Directory**: Copy to `~/.config/DankMaterialShell/plugins/GnomeSearchProvider`

Bazaar returns search results   ```bash

    ↓   mkdir -p ~/.config/DankMaterialShell/plugins

User selects Firefox   cp -r GnomeSearchProvider ~/.config/DankMaterialShell/plugins/

    ↓   ```

Plugin calls ActivateResult

    ↓2. **Enable Plugin**: 

Bazaar opens Firefox detail page   - Open DMS Settings → Plugins

```   - Click "Scan for Plugins" if needed

   - Enable "GNOME Search"

## File Structure

3. **Configure**: Set your preferred trigger and enabled providers in plugin settings

```

BazaarSearch/## Usage

├── plugin.json                           # Plugin manifest

├── BazaarSearchProviderLauncher.qml      # Main launcher component### With Trigger (Default)

├── BazaarSearchProviderSettings.qml      # Settings interface

└── README.md                             # This documentation1. Open launcher (Ctrl+Space or launcher button)

```2. Type `g` to activate the plugin trigger

3. Add your search query: `g calculator`

## Installation4. Browse available results

5. Press Enter to execute selected item

### Prerequisites

### Without Trigger (Empty Trigger Mode)

1. **Install Bazaar**:

   ```bash1. Enable "No trigger (always show)" in plugin settings

   flatpak install flathub io.github.kolunmi.Bazaar2. Open launcher - GNOME search results appear alongside apps

   ```3. Search works normally with all results included

4. Press Enter to execute selected item

2. **Ensure Bazaar is running**:

   ```bash### Search Examples

   flatpak run io.github.kolunmi.Bazaar

   ```- `g wifi` - Find WiFi settings

   (Bazaar runs as a background service and stays active after closing windows)- `g 25*4` - Calculate: 100

- `g heart` - Find heart emoji ❤️

3. **Verify DBus service**:- `g downloads` - Open Downloads folder

   ```bash- `g bluetooth` - Open Bluetooth settings

   dbus-send --session --print-reply \

     --dest=io.github.kolunmi.Bazaar \## Developer Guide

     /io/github/kolunmi/Bazaar/SearchProvider \

     org.gnome.Shell.SearchProvider2.GetInitialResultSet \### Plugin Architecture

     array:string:firefox

   ```This plugin implements the DMS launcher plugin contract:



### Plugin Installation**Required Properties:**

- `pluginService` - Injected by DMS for settings persistence

1. **Copy to plugins directory**:- `trigger` - Trigger string for activation

   ```bash

   mkdir -p ~/.config/DankMaterialShell/plugins**Required Functions:**

   cp -r BazaarSearch ~/.config/DankMaterialShell/plugins/- `getItems(query)` - Returns array of search results

   ```- `executeItem(item)` - Executes the selected item's action



2. **Enable in DMS**:### Search Provider Integration

   - Open DMS Settings → Plugins

   - Click "Scan for Plugins" if neededThe plugin discovers and queries GNOME search providers through a mock implementation. For production use, this should be extended to use DBus communication with the `org.gnome.Shell.SearchProvider2` interface.

   - Enable "Bazaar Search"

#### DBus Interface

3. **Configure trigger** (optional):

   - Open plugin settingsGNOME search providers implement the following DBus interface:

   - Set custom trigger or enable "no trigger" mode

```

## UsageService: <provider-specific, e.g., org.gnome.Calculator.SearchProvider>

Object Path: <provider-specific, e.g., /org/gnome/Calculator/SearchProvider>

### With Trigger (Default)Interface: org.gnome.Shell.SearchProvider2



1. Open DMS Launcher (`Ctrl+Space`)Methods:

2. Type `b` followed by your search: `b firefox`- GetInitialResultSet(terms: array of strings) → (results: array of strings)

3. Browse Bazaar search results- GetSubsearchResultSet(previous_results: array, terms: array) → (results: array)

4. Press `Enter` to open in Bazaar- GetResultMetas(identifiers: array) → (metas: array of dicts)

5. Install from Bazaar's app detail page- ActivateResult(identifier: string, terms: array, timestamp: uint)

- LaunchSearch(terms: array, timestamp: uint)

### Without Trigger (Empty Trigger Mode)```



1. Enable "No trigger (always search Bazaar)" in settings### Item Structure

2. Open DMS Launcher

3. Type any search queryEach search result follows the launcher item structure:

4. Bazaar results appear alongside system apps

5. Press `Enter` to open selected app in Bazaar```javascript

{

### Search Examples    name: "Result Name",           // Display name

    icon: "icon_name",            // Material icon name

- `b firefox` - Mozilla Firefox browser    comment: "Description • Source", // Subtitle with provider info

- `b gimp` - GIMP image editor      action: "type:data",          // Action to execute

- `b blender` - Blender 3D creation suite    categories: ["GNOME Search"]  // Category for filtering

- `b libreoffice` - LibreOffice productivity suite}

- `b vlc` - VLC media player```

- `b video editor` - Find video editing applications

- `b music player` - Discover music applications### Extending the Plugin



## Developer Guide#### Adding Real DBus Communication



### DBus InterfaceTo implement actual GNOME search provider queries:



This plugin communicates with Bazaar using the GNOME Shell SearchProvider2 interface:1. Use `Quickshell.DBus.DBusServiceWatcher` to detect available providers

2. Call `GetInitialResultSet` or `GetSubsearchResultSet` via DBus

**Service**: `io.github.kolunmi.Bazaar`  3. Fetch result metadata with `GetResultMetas`

**Object Path**: `/io/github/kolunmi/Bazaar/SearchProvider`  4. Execute results with `ActivateResult`

**Interface**: `org.gnome.Shell.SearchProvider2`

Example DBus call structure:

#### Methods Used

```qml

```javascriptimport Quickshell.DBus

// Search for applications

GetInitialResultSet(terms: array of strings) → (results: array of strings)DBusConnection {

    id: sessionBus

// Get metadata for results    bus: DBus.Session

GetResultMetas(identifiers: array of strings) → (metas: array of dicts)}



// Open app in Bazaar// Query search provider

ActivateResult(identifier: string, terms: array, timestamp: uint32)function searchProvider(busName, objectPath, terms) {

```    sessionBus.call(

        busName,

### Implementation Details        objectPath,

        "org.gnome.Shell.SearchProvider2",

#### Search Flow        "GetInitialResultSet",

        [terms]

```qml    )

function performBazaarSearch(query) {}

    // 1. Split query into search terms```

    const terms = query.trim().split(/\s+/)

    #### Adding Custom Providers

    // 2. Call GetInitialResultSet via dbus-send

    const appIds = callDbusMethod("GetInitialResultSet", terms)Add new search providers to the `searchProviders` array:

    

    // 3. Get metadata for each result```javascript

    const results = appIds.map(id => getResultMeta(id)){

        id: "org.gnome.MyApp.desktop",

    return results    name: "My App",

}    busName: "org.gnome.MyApp.SearchProvider",

```    objectPath: "/org/gnome/MyApp/SearchProvider",

    icon: "custom_icon"

#### Activation Flow}

```

```qml

function executeItem(item) {### Settings Integration

    // Extract app ID from action

    const appId = item.action.split(":")[1]The plugin saves configuration using `PluginService`:

    

    // Call ActivateResult to open in Bazaar```javascript

    callDbusMethod("ActivateResult", [appId, [], 0])// Save setting

}pluginService.savePluginData("gnomeSearchProvider", "trigger", "g")

```

// Load setting

### Item StructurepluginService.loadPluginData("gnomeSearchProvider", "trigger", "g")

```

Each search result follows the DMS launcher item format:

### Manifest Configuration

```javascript

{```json

    name: "Firefox",                    // App name from Bazaar{

    icon: "material:apps",              // Material icon    "id": "gnomeSearchProvider",

    comment: "Fast web browser • Install from Bazaar",    "name": "GNOME Search",

    action: "activate:org.mozilla.firefox",  // Action with app ID    "type": "launcher",

    categories: ["Bazaar Search"],    "capabilities": ["launcher"],

    __appId: "org.mozilla.firefox"     // Internal app identifier    "component": "./GnomeSearchProviderLauncher.qml",

}    "settings": "./GnomeSearchProviderSettings.qml",

```    "requires": ["dbus-send"]

}

### Error Handling```



The plugin gracefully handles:## Best Practices



- **Bazaar not running**: Shows "Start Bazaar" message1. **Fast Response**: Cache search results when possible

- **DBus timeouts**: Returns empty results after timeout2. **Error Handling**: Gracefully handle unavailable search providers

- **Parse failures**: Skips invalid results3. **User Feedback**: Show loading states for async searches

- **Activation failures**: Logs error and shows toast notification4. **Privacy**: Respect user's search provider selections

5. **Performance**: Limit result counts to avoid UI lag

### Configuration6. **Cleanup**: Destroy temporary DBus objects after use



Settings are persisted via `PluginService`:## Testing



```javascriptTest the plugin by:

// Save trigger

pluginService.savePluginData("bazaarSearchProvider", "trigger", "b")1. Installing and enabling in DMS

2. Testing with trigger enabled (`g query`)

// Load trigger3. Testing with empty trigger (no prefix needed)

pluginService.loadPluginData("bazaarSearchProvider", "trigger", "b")4. Trying different search providers

5. Testing calculator expressions

// Enable/disable trigger6. Verifying clipboard operations

pluginService.savePluginData("bazaarSearchProvider", "noTrigger", true)7. Checking settings persistence across restarts

```

## Known Limitations

## Comparison with KRunner Plugin

- **Mock Results**: Current implementation uses mock data for demonstration

| Feature | KRunner Plugin | DMS Plugin |- **DBus Integration**: Full DBus communication needs to be implemented

|---------|---------------|------------|- **Provider Discovery**: Static provider list (should be dynamic)

| Platform | KDE Plasma | DankMaterialShell |- **Real-time Updates**: No live provider monitoring

| Interface | KRunner API | DMS Launcher API |

| Communication | DBus SearchProvider2 | DBus SearchProvider2 |## Future Enhancements

| Search | Type prefix in KRunner | Type trigger in DMS |

| Activation | Opens in Bazaar | Opens in Bazaar |- [ ] Implement actual DBus communication with GNOME search providers

| Implementation | C++ | QML/JavaScript |- [ ] Dynamic discovery of installed search providers

- [ ] Cache frequently searched results

Both plugins use the same Bazaar DBus interface, providing consistent functionality across desktop environments.- [ ] Add search provider icons from desktop files

- [ ] Support for provider-specific result actions

## Troubleshooting- [ ] Real-time provider availability checking

- [ ] Search history and suggestions

### Bazaar Service Not Found- [ ] Configurable result ranking



**Problem**: "Bazaar not running" appears in search results## Contributing



**Solutions**:Contributions are welcome! Areas for improvement:

1. Start Bazaar: `flatpak run io.github.kolunmi.Bazaar`

2. Check if service is running:- Full DBus SearchProvider2 interface implementation

   ```bash- Additional GNOME app integrations

   busctl --user list | grep bazaar- Performance optimizations

   ```- UI/UX enhancements

3. Restart Bazaar service- Documentation improvements



### No Search Results## Resources



**Problem**: Search returns empty results- [GNOME Search Provider Specification](https://developer.gnome.org/SearchProvider/)

- [DMS Plugin Documentation](../README.md)

**Solutions**:- [Quickshell DBus Documentation](https://quickshell.outfoxxed.me/)

1. Verify Bazaar can search:- [DankMaterialShell Repository](https://github.com/avengemedia/dankmaterialshell)

   ```bash

   dbus-send --session --print-reply \## License

     --dest=io.github.kolunmi.Bazaar \

     /io/github/kolunmi/Bazaar/SearchProvider \This plugin follows the DankMaterialShell project license.

     org.gnome.Shell.SearchProvider2.GetInitialResultSet \

     array:string:firefox## Credits

   ```

2. Check Bazaar has loaded Flathub data (open Bazaar GUI once)Created as an example integration between GNOME Shell search providers and DankMaterialShell launcher system.

3. Ensure internet connection for Flathub metadata

### Plugin Not Working

**Problem**: Plugin doesn't appear in launcher

**Solutions**:
1. Verify installation path: `~/.config/DankMaterialShell/plugins/BazaarSearch/`
2. Check plugin.json syntax
3. Scan for plugins in DMS Settings
4. Check DMS logs for errors

## Technical Notes

### Why dbus-send?

This plugin uses `dbus-send` command-line tool for DBus communication because:

1. **Simplicity**: Easier than implementing full DBus bindings in QML
2. **Reliability**: Well-tested system tool
3. **Compatibility**: Works across all Linux distributions
4. **Synchronous**: Provides blocking behavior for search operations

For production, this could be replaced with native Quickshell DBus support.

### Performance Considerations

- **Blocking I/O**: `dbus-send` calls block briefly (typically <100ms)
- **Result Limiting**: Fetches metadata for max 10 results
- **Caching**: Bazaar caches search results internally
- **Debouncing**: Use DMS launcher's built-in search debouncing

## Development

This plugin includes a `justfile` for streamlined development. Install [just](https://github.com/casey/just) to use these commands.

### Quick Start

```bash
# Restart DMS and watch logs (recommended for development)
just dev

# Show all available commands
just --list

# Debug plugin issues
just debug
```

### Common Commands

- **`just logs`** - Watch filtered logs for this plugin
- **`just restart`** - Restart DMS to reload changes
- **`just test-all`** - Test if all search providers are available
- **`just validate-json`** - Validate plugin.json syntax

### Development Workflow

1. Make changes to QML or JSON files
2. Run `just dev` to restart and watch logs
3. Test the changes in the DMS launcher
4. Check `just errors` if issues occur

For detailed development instructions, see [AGENTS.md](./AGENTS.md).

## Future Enhancements

- [ ] Native Quickshell DBus integration (non-blocking)
- [ ] Result caching for faster repeated searches
- [ ] App icons from Bazaar metadata
- [ ] Quick install action (install without opening Bazaar)
- [ ] Filter by app categories
- [ ] Show install status for already-installed apps
- [ ] Support for Bazaar's "launch search" action

## Contributing

Contributions welcome! Areas for improvement:

- Native DBus implementation using Quickshell.DBus
- Performance optimizations
- Better error handling and user feedback
- Additional Bazaar integration features

## Resources

- **Bazaar Project**: https://github.com/kolunmi/bazaar
- **KRunner Plugin**: https://github.com/ublue-os/krunner-bazaar
- **GNOME SearchProvider Spec**: https://developer.gnome.org/SearchProvider/
- **DMS Plugin Docs**: ../PLUGINS/README.md
- **Quickshell Docs**: https://quickshell.outfoxxed.me/

## Credits

- **Bazaar**: Created by [kolunmi](https://github.com/kolunmi)
- **KRunner Integration**: By [ublue-os](https://github.com/ublue-os)
- **DMS Plugin**: Community contribution

## License

This plugin follows the DankMaterialShell project license.

---

**Enjoy seamless Flatpak discovery and installation from your DMS launcher!** 🛍️✨
