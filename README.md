<p align="center">
  <img src="assets/ProjectDock-logo.svg" width="150" alt="ProjectDock icon">
</p>

<h1 align="center">ProjectDock</h1>

<p align="center"><strong>Your development projects, one click away.</strong></p>

<p align="center">
  A lightweight native macOS app for launching editors, terminals, repositories and local dev servers from one place.
</p>

<p align="center">
  <a href="https://github.com/JayyBG/ProjectDock/releases/latest"><strong>Download the latest release</strong></a>
  ·
  <a href="#features">Features</a>
  ·
  <a href="#build-from-source">Build from source</a>
</p>

## Preview

### Menu bar

<img src="assets/screenshots/menu-bar.jpg" width="760" alt="ProjectDock menu bar window">

### Project manager

<img src="assets/screenshots/manager.jpg" width="1100" alt="ProjectDock project manager">

## Features

- Native SwiftUI macOS app with a menu-bar companion
- Add and remove local project folders
- Automatically detects project names from `package.json`
- Detects Xcode projects and workspaces
- Detects the Git `origin` repository URL
- Detects common `npm run dev` / `npm start` commands
- Opens projects in Visual Studio Code, Xcode, Cursor, Zed, Finder, or Terminal
- Starts and stops a per-project development command
- Monitors a configured localhost port and opens it directly
- Recently opened projects float to the top
- Stores everything locally — no account, backend, analytics, or telemetry

## Install

1. Open the [latest release](https://github.com/JayyBG/ProjectDock/releases/latest).
2. Download `ProjectDock-v0.1.0.dmg` (or the newest `.dmg`).
3. Open the disk image.
4. Drag **ProjectDock** onto the **Applications** shortcut.
5. Eject the ProjectDock disk image and launch ProjectDock from Applications.

The downloadable build is ad-hoc signed but is not Apple-notarized yet. If macOS blocks the first launch, right-click **ProjectDock** in Applications and choose **Open**.

## Project detection

When you add a folder, ProjectDock performs lightweight local detection and pre-fills what it can. Everything can still be changed from **Manage**.

Each project can contain:

- Display name
- Local folder path
- Preferred editor
- Start command
- Repository URL
- Optional localhost port

Start commands run with `/bin/zsh -lc` from the project's root folder.

## Requirements

- macOS 13 Ventura or newer
- Apple Silicon or Intel Mac

## Build from source

Clone the repository and open `Package.swift` in Xcode:

```bash
git clone https://github.com/JayyBG/ProjectDock.git
cd ProjectDock
open Package.swift
```

Select the **ProjectDock** scheme, choose **My Mac**, and press **Run**.

You can also run it directly with Swift Package Manager:

```bash
swift run ProjectDock
```

## Releases

GitHub Actions builds both Apple Silicon and Intel versions, combines them into a universal macOS binary, creates `ProjectDock.app`, ad-hoc signs it, and packages it into a drag-to-Applications `.dmg`. A new release is published whenever `VERSION` is changed to a version that does not already have a GitHub release.

## Roadmap

- [ ] Search / command palette
- [ ] Auto-discover projects in chosen folders
- [ ] Custom actions per project
- [ ] Workspace groups
- [ ] Git branch + dirty state
- [ ] Built-in terminal output panel
- [ ] Better package-manager detection (`pnpm`, `yarn`, `bun`)
- [ ] Launch at login
- [ ] Import/export configuration
- [ ] `.projectdock.yml` support
- [ ] Docker service controls
- [ ] Keyboard shortcuts

## Privacy

ProjectDock has no account, analytics, cloud backend, or telemetry. Project metadata stays on your Mac in:

```text
~/Library/Application Support/ProjectDock/projects.json
```

## Contributing

Contributions and ideas are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

ProjectDock is available under the [MIT License](LICENSE).
