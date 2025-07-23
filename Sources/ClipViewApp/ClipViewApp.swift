import SwiftUI
import AppKit

@main
struct ClipViewCLIApp: App {
    @StateObject private var clipboardManager = ClipboardManager()
    private var monitor: ClipboardMonitor!

    init() {
        // ✅ Use the @StateObject one, not a new one
        let manager = ClipboardManager()
        self._clipboardManager = StateObject(wrappedValue: manager)
        self.monitor = ClipboardMonitor(manager: manager)
    }

    var body: some Scene {
        MenuBarExtra("\u{1F4CB} ClipView", systemImage: "doc.on.clipboard") {
            ClipboardHistoryView(items: $clipboardManager.items) {
                clipboardManager.clearAllItems()
            }
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var clipboardManager: ClipboardManager?

    func applicationDidFinishLaunching(_ notification: Notification) {}
}