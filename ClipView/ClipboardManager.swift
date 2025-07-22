import AppKit
import SwiftData

class ClipboardManager {
    private var lastChangeCount = NSPasteboard.general.changeCount
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        startMonitoring()
    }

    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }

        lastChangeCount = pasteboard.changeCount

        if let image = NSImage(pasteboard: pasteboard) {
            let item = ClipboardItem(image: image)
            addItem(item)
        } else if let text = pasteboard.string(forType: .string) {
            let item = ClipboardItem(text: text)
            addItem(item)
        }
    }

    private func addItem(_ item: ClipboardItem) {
        Task { @MainActor in
            context.insert(item)

            // Keep only latest 20
            let fetchDescriptor = FetchDescriptor<ClipboardItem>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
            if let items = try? context.fetch(fetchDescriptor), items.count > 20 {
                for extra in items.dropFirst(20) {
                    context.delete(extra)
                }
            }
        }
    }
}
