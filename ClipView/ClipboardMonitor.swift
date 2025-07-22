import Foundation
import AppKit
import SwiftData

class ClipboardMonitor {
    static let shared = ClipboardMonitor()
    private var lastChangeCount: Int = NSPasteboard.general.changeCount
    private var timer: Timer?

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }

        lastChangeCount = pasteboard.changeCount

        guard let context = try? ModelContext(ClipboardMonitor.modelContainer) else { return }

        if let text = pasteboard.string(forType: .string), !text.isEmpty {
            // Check if the same text already exists
            let existingItems = try? context.fetch(FetchDescriptor<ClipboardItem>())
            let isDuplicate = existingItems?.contains {
                $0.type == "text" && $0.contentText == text
            } ?? false

            if !isDuplicate {
                let item = ClipboardItem(text: text)
                context.insert(item)
                try? context.save()
            }
        } else if let image = NSImage(pasteboard: pasteboard),
                  let imageData = image.tiffRepresentation {

            let existingItems = try? context.fetch(FetchDescriptor<ClipboardItem>())
            let isDuplicate = existingItems?.contains {
                $0.type == "image" && $0.contentImageData == imageData
            } ?? false

            if !isDuplicate {
                let item = ClipboardItem(image: image)
                context.insert(item)
                try? context.save()
            }
        }
    }

    // For SwiftData saving
    static var modelContainer: ModelContainer = {
        let schema = Schema([ClipboardItem.self])
        let config = ModelConfiguration("ClipboardData")
        return try! ModelContainer(for: schema, configurations: [config])
    }()
}
