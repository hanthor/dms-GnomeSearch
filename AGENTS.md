# Agent Interaction Protocol

This document outlines how AI agents and automated tools can interact with the `GnomeSearch` plugin project.

## Scope of Interaction

Agents are permitted to perform the following actions:

- **Read Files:** Analyze existing code in `.qml`, `.js`, and `.json` files to understand the project structure and conventions.
- **Write Files:** Create new files (e.g., new search providers, tests) or modify existing ones to add features, fix bugs, or improve documentation.
- **Run Commands:** Execute shell commands to perform tasks like testing, linting, or building the project, once those procedures are established.

## Development Tasks

Common tasks for an agent include:

- **Adding New Search Providers:** Create new QML files that implement the search provider interface.
- **Modifying UI:** Update `GnomeSearchProvidersLauncher.qml` and `GnomeSearchProvidersSettings.qml` to improve the user interface and experience.
- **Updating Configuration:** Modify `plugin.json` to reflect changes in providers or metadata.
- **Documentation:** Generate or update documentation, including this `AGENTS.md` file and the `README.md`.

## Development Workflow with Justfile

The project includes a `justfile` that provides commands for development, debugging, and testing. All agents should use these commands for common development tasks.

### Essential Commands

- **`just logs`** - Watch real-time logs filtered for this plugin (use this while developing)
- **`just restart`** - Restart DMS to reload the plugin after making changes
- **`just dev`** - Restart DMS and immediately start watching logs (recommended for development)
- **`just debug`** - Show comprehensive debug information about the plugin and environment

### Testing Commands

- **`just test-all`** - Test if all search providers (Bazaar, Files, Calculator, Characters) are available
- **`just test-bazaar`** - Test if Bazaar search provider is available
- **`just test-files`** - Test if Files (Nautilus) search provider is available
- **`just validate-json`** - Validate the plugin.json file syntax

### Log Management

- **`just logs`** - Filtered logs for GnomeSearch plugin activity
- **`just logs-all`** - All DMS/Quickshell logs (unfiltered)
- **`just errors`** - Show only recent errors
- **`just warnings`** - Show recent warnings and errors

### Service Control

- **`just start`** - Start DMS service
- **`just stop`** - Stop DMS service
- **`just status`** - Show DMS service status

### Discovery Commands

- **`just list-dbus`** - List all available DBus services (useful for finding new search providers)

## Protocol for Changes

1.  **Analyze:** Before making changes, the agent must read the relevant files to understand the existing patterns.
2.  **Implement:** The agent should apply changes idiomatically, following the established code style.
3.  **Test:** After making changes, run `just test-all` to ensure search providers are accessible.
4.  **Validate:** Run `just validate-json` to ensure configuration files are valid.
5.  **Reload & Monitor:** Run `just dev` to restart DMS and watch logs in real-time.
6.  **Debug:** If issues occur, run `just debug` to gather comprehensive diagnostic information.

## Debugging Workflow

When investigating issues or developing new features:

1. Start with `just debug` to understand the current state
2. Make your changes to the QML or JSON files
3. Run `just dev` to reload and watch logs
4. If errors occur, check `just errors` for specific error messages
5. Use `just test-all` to verify search provider availability
6. Use `just list-dbus` to discover new search providers to integrate

## Common Scenarios

### Adding a New Search Provider

1. Run `just list-dbus` to find the DBus service name
2. Test connectivity with a specific test command (e.g., `just test-bazaar`)
3. Add the provider configuration to `GnomeSearchProvidersLauncher.qml`
4. Run `just dev` to test the integration
5. Monitor `just logs` for any errors

### Fixing a Bug

1. Run `just debug` to gather initial state
2. Check `just errors` and `just warnings` for recent issues
3. Make code changes
4. Run `just validate-json` if configuration was changed
5. Run `just dev` to test the fix
6. Verify the fix resolves the issue in the logs

### Testing Without Installation

- Use `just test-all` to verify all search providers are available before testing the full plugin
- Use `just list-dbus` to explore what search providers are available on the system
