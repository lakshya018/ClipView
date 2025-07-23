import AppKit
import SwiftUI

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = [] {
        didSet { saveItems() }
    }
    private let maxItems = 20
    private let storageKey = "clipboard_items"

    private var fileURL: URL {
        let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = folder.appendingPathComponent("ClipViewCLI", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("history.json")
    }


    init() {
        loadItems()
    }

    func addItem(_ item: ClipboardItem) {
        if items.contains(item) { return }  // ✅ Skip if duplicate
        items.insert(item, at: 0)
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
    }

    func clearAllItems() {
        items.removeAll()
    }

    private func saveItems() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL)
    }

    private func loadItems() {
        guard let data = try? Data(contentsOf: fileURL),
              let saved = try? JSONDecoder().decode([ClipboardItem].self, from: data) else { return }
        items = saved
    }
}
