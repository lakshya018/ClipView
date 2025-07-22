import SwiftUI
import SwiftData
import AppKit

struct ClipboardHistoryView: View {
    @Query(sort: \ClipboardItem.timestamp, order: .reverse)
    var items: [ClipboardItem]

    @State private var hoveredItemID: UUID?
    @State private var clickedItemID: UUID?
    @State private var showCopiedToast: Bool = false
    @Environment(\.modelContext) private var context
    @State private var isHoveringClearButton = false
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: clearAllItems) {
                    Label("Clear All", systemImage: "trash")
                        .labelStyle(.titleAndIcon)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isHoveringClearButton ? Color.gray.opacity(0.15) : Color(NSColor.controlBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if (hovering){
                        isHoveringClearButton = hovering
                        NSCursor.pointingHand.set()
                    }
                    else{
                        isHoveringClearButton = false;
                        NSCursor.arrow.set();
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items) { item in
                        Group {
                            if item.type == "text", let text = item.contentText {
                                clipboardTextItemView(item: item, text: text)
                            }
                            else if item.type == "image", let image = item.image {
                                clipboardImageItemView(item: item, image: image)
                            }
                        }
                        Divider()
                    }
                }
                .padding()
            }
            .frame(width: 320, height: 500)
            .overlay(
                VStack {
                    Spacer()
                    if showCopiedToast {
                        Text("✅ Copied!")
                            .font(.caption)
                            .padding(8)
                            .background(Color.black.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: showCopiedToast)
                    }
                }
                    .padding(.bottom, 16)
            )
            .onAppear {
                NSApp.setActivationPolicy(.accessory) // Hides from Dock and App Switcher
            }
            
        }
    }

    private func copyToClipboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        showCopiedToast = true
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
               showCopiedToast = false
           }
        print("📋 Text copied to clipboard: \(text)")
    }

    private func copyToClipboard(image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
        showCopiedToast = true
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
               showCopiedToast = false
           }
        print("🖼️ Image copied to clipboard")
    }
    
    private func truncated(_ text: String, maxLength: Int = 100) -> String {
        if text.count <= maxLength {
            return text
        }
        let index = text.index(text.startIndex, offsetBy: maxLength)
        return String(text[..<index]) + "..."
    }
    
    @ViewBuilder
    private func clipboardTextItemView(item: ClipboardItem, text: String) -> some View {
        Text(truncated(text))
            .font(.body)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                hoveredItemID == item.id ?
                    Color.blue.opacity(0.1) :
                    Color.gray.opacity(0.15)
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(clickedItemID == item.id ? Color.blue : Color.clear, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .contentShape(Rectangle()) // Makes whole area tappable
            .onTapGesture {
                clickedItemID = item.id
                copyToClipboard(text: text)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    clickedItemID = nil
                }
            }
            .onHover { hovering in
                hoveredItemID = hovering ? item.id : nil
                if hovering {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: hoveredItemID)
    }
    
    @ViewBuilder
    private func clipboardImageItemView(item: ClipboardItem, image: NSImage) -> some View {
        Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .frame(height: 150)
            .cornerRadius(8)
            .background(
                hoveredItemID == item.id ?
                    Color.blue.opacity(0.1) :
                    Color.gray.opacity(0.15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(clickedItemID == item.id ? Color.blue : Color.clear, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .contentShape(Rectangle())
            .onTapGesture {
                clickedItemID = item.id
                copyToClipboard(image: image)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    clickedItemID = nil
                }
            }
            .onHover { hovering in
                hoveredItemID = hovering ? item.id : nil
                if hovering {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: hoveredItemID)
    }


    private func clearAllItems() {
        for item in items {
            context.delete(item)
        }
        try? context.save()
    }

    
}
