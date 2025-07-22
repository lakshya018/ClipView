import SwiftUI
import SwiftData
import AppKit

@main
struct ClipViewApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ClipboardItem.self])
        let config = ModelConfiguration("ClipboardData")
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    init() {
        ClipboardMonitor.shared.startMonitoring()
    }

    var body: some Scene {
        MenuBarExtra("📋 ClipView", systemImage: "doc.on.clipboard") {
            // ✅ Inject model context so @Query can work
            ClipboardHistoryView()
                .modelContext(sharedModelContainer.mainContext)
        }
        .menuBarExtraStyle(.window)
        .modelContainer(sharedModelContainer)
    }
}
