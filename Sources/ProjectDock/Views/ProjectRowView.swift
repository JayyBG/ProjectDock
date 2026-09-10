import SwiftUI

struct ProjectRowView: View {
    let project: DevProject
    @ObservedObject var runner: ProjectRunner
    @ObservedObject var portMonitor: PortMonitor
    let onOpened: () -> Void

    private var isRunning: Bool { runner.isRunning(project) }
    private var portIsReachable: Bool { portMonitor.isReachable(project) }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Circle()
                    .fill(portIsReachable || isRunning ? Color.green : Color.secondary.opacity(0.35))
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: 1) {
                    Text(project.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(project.folderURL.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if let port = project.port {
                    Button("\(port)") {
                        ProjectLauncher.openLocalhost(for: project)
                        onOpened()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption.monospacedDigit())
                    .disabled(!portIsReachable)
                    .help(portIsReachable ? "Open localhost:\(port)" : "Port \(port) is not responding")
                }
            }

            HStack(spacing: 6) {
                actionButton(project.editor.symbolName, help: "Open in \(project.editor.displayName)") {
                    ProjectLauncher.openEditor(for: project)
                    onOpened()
                }

                actionButton("terminal", help: "Open Terminal") {
                    ProjectLauncher.openTerminal(for: project)
                    onOpened()
                }

                actionButton("folder", help: "Show in Finder") {
                    ProjectLauncher.openFinder(for: project)
                    onOpened()
                }

                if project.hasRepositoryURL {
                    actionButton("arrow.up.right.square", help: "Open repository") {
                        ProjectLauncher.openRepository(for: project)
                        onOpened()
                    }
                }

                Spacer()

                if project.hasStartCommand {
                    Button {
                        runner.toggle(project)
                    } label: {
                        Label(isRunning ? "Stop" : "Start", systemImage: isRunning ? "stop.fill" : "play.fill")
                    }
                    .controlSize(.small)
                    .buttonStyle(.borderedProminent)
                    .tint(isRunning ? .red : .accentColor)
                    .help(project.startCommand)
                }
            }

            if let error = runner.lastErrors[project.id] {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(.quaternary.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func actionButton(_ systemImage: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 18, height: 18)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
        .help(help)
    }
}
