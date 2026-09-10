import AppKit
import SwiftUI

struct ProjectManagerView: View {
    @ObservedObject var store: ProjectStore
    @ObservedObject var runner: ProjectRunner
    @ObservedObject var portMonitor: PortMonitor
    @State private var selectedProjectID: UUID?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProjectID) {
                ForEach(store.projects) { project in
                    Label(project.name, systemImage: project.editor.symbolName)
                        .tag(project.id)
                        .contextMenu {
                            Button("Open in \(project.editor.displayName)") {
                                ProjectLauncher.openEditor(for: project)
                                store.markOpened(id: project.id)
                            }
                            Button("Show in Finder") {
                                ProjectLauncher.openFinder(for: project)
                            }
                            Divider()
                            Button("Remove", role: .destructive) {
                                remove(project)
                            }
                        }
                }
            }
            .navigationTitle("Projects")
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Button {
                        chooseProjectFolder()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help("Add project")

                    Button {
                        if let selectedProjectID,
                           let project = store.projects.first(where: { $0.id == selectedProjectID }) {
                            remove(project)
                        }
                    } label: {
                        Image(systemName: "minus")
                    }
                    .disabled(selectedProjectID == nil)
                    .help("Remove selected project")

                    Spacer()
                }
                .padding(8)
                .background(.bar)
            }
        } detail: {
            if let selectedProjectID,
               let index = store.projects.firstIndex(where: { $0.id == selectedProjectID }) {
                ProjectEditorView(project: $store.projects[index])
                    .toolbar {
                        ToolbarItemGroup {
                            Button {
                                ProjectLauncher.openEditor(for: store.projects[index])
                                store.markOpened(id: store.projects[index].id)
                            } label: {
                                Label("Open", systemImage: store.projects[index].editor.symbolName)
                            }

                            if store.projects[index].hasStartCommand {
                                Button {
                                    runner.toggle(store.projects[index])
                                } label: {
                                    Label(
                                        runner.isRunning(store.projects[index]) ? "Stop" : "Start",
                                        systemImage: runner.isRunning(store.projects[index]) ? "stop.fill" : "play.fill"
                                    )
                                }
                            }
                        }
                    }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "folder")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("Select a Project")
                        .font(.title3.bold())
                    Text("Choose a project to edit its shortcuts and dev command.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(minWidth: 760, minHeight: 480)
        .onAppear {
            if selectedProjectID == nil {
                selectedProjectID = store.projects.first?.id
            }
        }
        .onChange(of: store.projects.count) { _ in
            if let selectedProjectID,
               !store.projects.contains(where: { $0.id == selectedProjectID }) {
                self.selectedProjectID = store.projects.first?.id
            } else if selectedProjectID == nil {
                selectedProjectID = store.projects.first?.id
            }
            portMonitor.refresh()
        }
    }

    private func remove(_ project: DevProject) {
        if runner.isRunning(project) {
            runner.stop(project)
        }
        store.removeProject(id: project.id)
    }

    private func chooseProjectFolder() {
        let panel = NSOpenPanel()
        panel.title = "Add a project"
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            store.addProject(at: url)
            selectedProjectID = store.projects.first(where: {
                $0.folderURL.standardizedFileURL == url.standardizedFileURL
            })?.id
        }
    }
}
