import AppKit
import SwiftUI

class ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: String
    let contentText: String?
    let contentImageData: Data?
    let timestamp: Date

    init(text: String) {
        self.id = UUID()
        self.type = "text"
        self.contentText = text
        self.contentImageData = nil
        self.timestamp = Date()
    }

    init(imageData: Data) {
        self.id = UUID()
        self.type = "image"
        self.contentText = nil
        self.contentImageData = imageData
        self.timestamp = Date()
    }

    var contentImage: NSImage? {
        guard let data = contentImageData else { return nil }
        return NSImage(data: data)
    }

    private func normalizedImageData() -> Data? {
        guard type == "image",
              let imageData = contentImageData,
              let image = NSImage(data: imageData),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .png, properties: [:])
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        // Compare types first
        guard lhs.type == rhs.type else { return false }
        
        if lhs.type == "text" {
            return lhs.contentText == rhs.contentText
        } else if lhs.type == "image" {
            // Convert both images to PNG format for consistent comparison
            guard let lhsData = lhs.normalizedImageData(),
                  let rhsData = rhs.normalizedImageData() else {
                return false
            }
            return lhsData == rhsData
        }
        return false
    }
}
