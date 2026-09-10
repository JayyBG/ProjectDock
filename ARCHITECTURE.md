# ProjectDock Architecture

ProjectDock is intentionally small and dependency-free.

## Models

- `DevProject.swift` — persisted representation of a development project and editor choice.

## Services

- `ProjectStore.swift` — local JSON persistence and project ordering.
- `ProjectDetector.swift` — lightweight detection for package metadata, Git remotes, Xcode projects, dev commands, and explicit ports.
- `ProjectLauncher.swift` — opens editors, Finder, Terminal, repositories, and localhost.
- `ProjectRunner.swift` — starts/stops project commands as child `zsh` processes.
- `PortMonitor.swift` — checks configured localhost TCP ports every few seconds.

## Views

- `MenuBarView.swift` — compact daily-use interface.
- `ProjectRowView.swift` — quick actions for one project.
- `ProjectManagerView.swift` — project list and configuration window.
- `ProjectEditorView.swift` — editable project settings.

## Persistence

Project metadata is stored at:

`~/Library/Application Support/ProjectDock/projects.json`

No project files are modified by ProjectDock.
