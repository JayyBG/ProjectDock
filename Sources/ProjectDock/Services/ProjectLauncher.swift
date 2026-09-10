import AppKit
import Foundation

@MainActor
enum ProjectLauncher {
    static func openEditor(for project: DevProject) {
        if let appName = project.editor.applicationName {
            runOpen(arguments: ["-a", appName, bestEditorTarget(for: project).path])
        } else {
            NSWorkspace.shared.open(project.folderURL)
        }
    }

    static func openFinder(for project: DevProject) {
        NSWorkspace.shared.activateFileViewerSelecting([project.folderURL])
    }

    static func openTerminal(for project: DevProject) {
        runOpen(arguments: ["-a", "Terminal", project.folderURL.path])
    }

    static func openRepository(for project: DevProject) {
        guard project.hasRepositoryURL, let url = URL(string: project.repositoryURL) else { return }
        NSWorkspace.shared.open(url)
    }

    static func openLocalhost(for project: DevProject) {
        guard let port = project.port,
              let url = URL(string: "http://localhost:\(port)") else { return }
        NSWorkspace.shared.open(url)
    }

    private static func bestEditorTarget(for project: DevProject) -> URL {
        guard project.editor == .xcode else { return project.folderURL }

        let contents = (try? FileManager.default.contentsOfDirectory(
            at: project.folderURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []

        if let workspace = contents.first(where: { $0.pathExtension == "xcworkspace" }) {
            return workspace
        }
        if let xcodeProject = contents.first(where: { $0.pathExtension == "xcodeproj" }) {
            return xcodeProject
        }
        return project.folderURL
    }

    private static func runOpen(arguments: [String]) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = arguments
        try? process.run()
    }
}
