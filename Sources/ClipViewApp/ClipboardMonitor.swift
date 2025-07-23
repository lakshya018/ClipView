import AppKit
import Foundation

class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = NSPasteboard.general.changeCount;
    private let manager: ClipboardManager

    init(manager: ClipboardManager) {
        self.manager = manager
        startMonitoring()
    }

    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if let types = pasteboard.types, types.contains(.string),
           let text = pasteboard.string(forType: .string)
        {
            let item = ClipboardItem(text: text)
            manager.addItem(item)
        } else if let types = pasteboard.types, types.contains(.tiff),
           let data = pasteboard.data(forType: .tiff)
        {
            let item = ClipboardItem(imageData: data)
            manager.addItem(item)
        }
    }

}
