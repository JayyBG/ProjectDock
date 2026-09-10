import Foundation
import Network

private final class PortCheckGate: @unchecked Sendable {
    private let lock = NSLock()
    private var completed = false

    func claim() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard !completed else { return false }
        completed = true
        return true
    }
}

@MainActor
final class PortMonitor: ObservableObject {
    @Published private(set) var reachableProjectIDs: Set<UUID> = []

    private var timer: Timer?
    private weak var store: ProjectStore?

    func start(store: ProjectStore) {
        self.store = store
        refresh()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func isReachable(_ project: DevProject) -> Bool {
        reachableProjectIDs.contains(project.id)
    }

    func refresh() {
        guard let projects = store?.projects else { return }
        let monitored = projects.compactMap { project -> (UUID, UInt16)? in
            guard let port = project.port, (1...65535).contains(port) else { return nil }
            return (project.id, UInt16(port))
        }

        if monitored.isEmpty {
            reachableProjectIDs = []
            return
        }

        for (id, port) in monitored {
            check(port: port) { [weak self] reachable in
                Task { @MainActor in
                    guard let self else { return }
                    if reachable {
                        self.reachableProjectIDs.insert(id)
                    } else {
                        self.reachableProjectIDs.remove(id)
                    }
                }
            }
        }
    }

    private nonisolated func check(
        port: UInt16,
        completion: @escaping @Sendable (Bool) -> Void
    ) {
        guard let nwPort = NWEndpoint.Port(rawValue: port) else {
            completion(false)
            return
        }

        let connection = NWConnection(host: "127.0.0.1", port: nwPort, using: .tcp)
        let queue = DispatchQueue(label: "ProjectDock.PortCheck.\(port)")
        let gate = PortCheckGate()

        let finish: @Sendable (Bool) -> Void = { result in
            guard gate.claim() else { return }
            completion(result)
            connection.cancel()
        }

        connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                finish(true)
            case .failed, .cancelled:
                finish(false)
            default:
                break
            }
        }

        connection.start(queue: queue)
        queue.asyncAfter(deadline: .now() + 0.8) {
            finish(false)
        }
    }
}
