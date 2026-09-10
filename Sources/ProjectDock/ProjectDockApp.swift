import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

@main
struct ProjectDockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store: ProjectStore
    @StateObject private var runner: ProjectRunner
    @StateObject private var portMonitor: PortMonitor

    init() {
        let store = ProjectStore()
        _store = StateObject(wrappedValue: store)
        _runner = StateObject(wrappedValue: ProjectRunner())
        _portMonitor = StateObject(wrappedValue: PortMonitor())
    }

    var body: some Scene {
        WindowGroup("ProjectDock", id: "manager") {
            ProjectManagerView(store: store, runner: runner, portMonitor: portMonitor)
                .onAppear {
                    NSApp.activate(ignoringOtherApps: true)
                    portMonitor.start(store: store)
                }
        }
        .defaultSize(width: 820, height: 520)

        MenuBarExtra("ProjectDock", systemImage: "dock.rectangle") {
            MenuBarView(store: store, runner: runner, portMonitor: portMonitor)
                .task {
                    portMonitor.start(store: store)
                }
        }
        .menuBarExtraStyle(.window)
    }
}
