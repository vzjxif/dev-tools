import SwiftUI

struct ToolSectionHeader<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .bold)) // 稍微小一点，更精致
                .foregroundColor(.secondary)
            
            Spacer()
            
            content()
                .controlSize(.small) // 让所有按钮变小，显得更专业
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor)) // 使用 window 背景色，稍微有点区分
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
}
