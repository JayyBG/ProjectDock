import Foundation

struct DevProject: Identifiable, Codable, Equatable, Hashable {
    enum Editor: String, Codable, CaseIterable, Identifiable {
        case visualStudioCode
        case xcode
        case cursor
        case zed
        case none

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .visualStudioCode: return "Visual Studio Code"
            case .xcode: return "Xcode"
            case .cursor: return "Cursor"
            case .zed: return "Zed"
            case .none: return "Default app"
            }
        }

        var applicationName: String? {
            switch self {
            case .visualStudioCode: return "Visual Studio Code"
            case .xcode: return "Xcode"
            case .cursor: return "Cursor"
            case .zed: return "Zed"
            case .none: return nil
            }
        }

        var symbolName: String {
            switch self {
            case .visualStudioCode: return "chevron.left.forwardslash.chevron.right"
            case .xcode: return "hammer"
            case .cursor: return "cursorarrow"
            case .zed: return "bolt"
            case .none: return "macwindow"
            }
        }
    }

    var id: UUID
    var name: String
    var path: String
    var editor: Editor
    var startCommand: String
    var repositoryURL: String
    var port: Int?
    var dateAdded: Date
    var lastOpened: Date?

    init(
        id: UUID = UUID(),
        name: String,
        path: String,
        editor: Editor = .visualStudioCode,
        startCommand: String = "",
        repositoryURL: String = "",
        port: Int? = nil,
        dateAdded: Date = Date(),
        lastOpened: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.path = path
        self.editor = editor
        self.startCommand = startCommand
        self.repositoryURL = repositoryURL
        self.port = port
        self.dateAdded = dateAdded
        self.lastOpened = lastOpened
    }

    var folderURL: URL {
        URL(fileURLWithPath: NSString(string: path).expandingTildeInPath)
    }

    var hasRepositoryURL: Bool {
        !repositoryURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasStartCommand: Bool {
        !startCommand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
