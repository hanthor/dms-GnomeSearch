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

## Protocol for Changes

1.  **Analyze:** Before making changes, the agent must read the relevant files to understand the existing patterns.
2.  **Implement:** The agent should apply changes idiomatically, following the established code style.
3.  **Verify:** If a testing framework is available, the agent is expected to write and run tests to validate its changes.
