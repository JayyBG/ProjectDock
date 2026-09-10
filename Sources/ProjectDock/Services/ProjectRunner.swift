import Foundation

@MainActor
final class ProjectRunner: ObservableObject {
    @Published private(set) var runningProjectIDs: Set<UUID> = []
    @Published private(set) var lastErrors: [UUID: String] = [:]

    private var processes: [UUID: Process] = [:]

    func isRunning(_ project: DevProject) -> Bool {
        runningProjectIDs.contains(project.id)
    }

    func start(_ project: DevProject) {
        guard project.hasStartCommand, !isRunning(project) else { return }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-lc", project.startCommand]
        process.currentDirectoryURL = project.folderURL

        var environment = ProcessInfo.processInfo.environment
        let commonPaths = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin"
        ]
        let existingPath = environment["PATH"] ?? ""
        environment["PATH"] = (commonPaths + [existingPath]).joined(separator: ":")
        process.environment = environment

        let projectID = project.id
        process.terminationHandler = { [weak self] finishedProcess in
            Task { @MainActor in
                guard let self else { return }
                self.processes[projectID] = nil
                self.runningProjectIDs.remove(projectID)
                if finishedProcess.terminationStatus != 0 {
                    self.lastErrors[projectID] = "Command exited with status \(finishedProcess.terminationStatus)."
                }
            }
        }

        do {
            try process.run()
            processes[project.id] = process
            runningProjectIDs.insert(project.id)
            lastErrors[project.id] = nil
        } catch {
            lastErrors[project.id] = error.localizedDescription
        }
    }

    func stop(_ project: DevProject) {
        guard let process = processes[project.id] else { return }
        process.terminate()
    }

    func toggle(_ project: DevProject) {
        isRunning(project) ? stop(project) : start(project)
    }

    func stopAll() {
        for process in processes.values {
            process.terminate()
        }
    }
}
