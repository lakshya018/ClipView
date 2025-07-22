import Foundation
import SwiftData
import AppKit

@Model
class ClipboardItem {
    var id: UUID
    var type: String // "text" or "image"
    var contentText: String?
    var contentImageData: Data?
    var timestamp: Date

    init(text: String) {
        self.id = UUID()
        self.type = "text"
        self.contentText = text
        self.timestamp = Date()
    }

    init(image: NSImage) {
        self.id = UUID()
        self.type = "image"
        self.contentImageData = image.tiffRepresentation
        self.timestamp = Date()
    }

    var image: NSImage? {
        guard let data = contentImageData else { return nil }
        return NSImage(data: data)
    }
}
