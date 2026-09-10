import Foundation

@MainActor
final class ProjectStore: ObservableObject {
    @Published var projects: [DevProject] = [] {
        didSet {
            guard hasFinishedLoading else { return }
            save()
        }
    }

    private let detector = ProjectDetector()
    private let storageURL: URL
    private var hasFinishedLoading = false

    init() {
        let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appURL = baseURL.appendingPathComponent("ProjectDock", isDirectory: true)
        try? FileManager.default.createDirectory(at: appURL, withIntermediateDirectories: true)
        storageURL = appURL.appendingPathComponent("projects.json")

        load()
        hasFinishedLoading = true
    }

    func addProject(at folderURL: URL) {
        let normalizedPath = folderURL.standardizedFileURL.path

        guard !projects.contains(where: { $0.folderURL.standardizedFileURL.path == normalizedPath }) else {
            return
        }

        projects.append(detector.detect(at: folderURL))
        sortProjects()
    }

    func removeProject(id: UUID) {
        projects.removeAll { $0.id == id }
    }

    func markOpened(id: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == id }) else { return }
        projects[index].lastOpened = Date()
        sortProjects()
    }

    private func sortProjects() {
        projects.sort {
            switch ($0.lastOpened, $1.lastOpened) {
            case let (left?, right?): return left > right
            case (.some, .none): return true
            case (.none, .some): return false
            case (.none, .none): return $0.dateAdded > $1.dateAdded
            }
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL) else {
            projects = []
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let decoded = try? decoder.decode([DevProject].self, from: data) else {
            projects = []
            return
        }

        projects = decoded
        sortProjects()
    }

    private func save() {
        guard let data = try? JSONEncoder.pretty.encode(projects) else { return }
        try? data.write(to: storageURL, options: [.atomic])
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
