import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var store: ProjectStore
    @ObservedObject var runner: ProjectRunner
    @ObservedObject var portMonitor: PortMonitor
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text("ProjectDock")
                        .font(.headline)
                    Text("Your projects, one click away")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    portMonitor.refresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .help("Refresh status")
            }

            Divider()

            if store.projects.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "dock.rectangle")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("No Projects Yet")
                        .font(.headline)
                    Text("Add a folder and ProjectDock will detect what it can.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 190)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(store.projects) { project in
                            ProjectRowView(
                                project: project,
                                runner: runner,
                                portMonitor: portMonitor,
                                onOpened: { store.markOpened(id: project.id) }
                            )
                        }
                    }
                }
                .frame(maxHeight: 430)
            }

            Divider()

            HStack {
                Button {
                    chooseProjectFolder()
                } label: {
                    Label("Add Project", systemImage: "plus")
                }

                Spacer()

                Button("Manage") {
                    openWindow(id: "manager")
                    NSApp.activate(ignoringOtherApps: true)
                }

                Button {
                    runner.stopAll()
                    NSApplication.shared.terminate(nil)
                } label: {
                    Image(systemName: "power")
                }
                .help("Quit ProjectDock")
            }
        }
        .padding(12)
        .frame(width: 390)
    }

    private func chooseProjectFolder() {
        let panel = NSOpenPanel()
        panel.title = "Add a project"
        panel.message = "Choose the root folder of your project."
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            store.addProject(at: url)
            portMonitor.refresh()
        }
    }
}
