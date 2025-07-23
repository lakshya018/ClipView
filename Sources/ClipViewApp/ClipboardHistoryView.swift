import AppKit
import SwiftUI

struct ClipboardHistoryView: View {
    @Binding var items: [ClipboardItem]
    var onClear: () -> Void
    @State private var copiedID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView {
                ForEach(items) { item in
                    ClipboardRowView(item: item, copiedID: $copiedID)
                }
            }

            Divider()

            Button("Clear All") {
                onClear()
            }
            .padding(.top, 4)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(10)
        .frame(width: 320, height: 500)
    }
}

struct ClipboardRowView: View {
    let item: ClipboardItem
    @Binding var copiedID: UUID?

    var body: some View {
        Button(action: {
            if let text = item.contentText {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            } else if let image = item.contentImage {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.writeObjects([image])
            }
            copiedID = item.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                copiedID = nil
            }
        }) {
            HStack(alignment: .center, spacing: 8) {
                if let image = item.contentImage {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .cornerRadius(8)
                } else if let text = item.contentText {
                    Text(text)
                        .font(.system(size: 12))
                        .lineLimit(4)
                        .truncationMode(.tail)
                }

                Spacer()

                if copiedID == item.id {
                    Text("Copied!")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
            )
            .contentShape(RoundedRectangle(cornerRadius: 8))
            .hoverEffect()

        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension View {
    func hoverEffect() -> some View {
        modifier(HoverHighlight())
    }
}

struct HoverHighlight: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .background(isHovered ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
