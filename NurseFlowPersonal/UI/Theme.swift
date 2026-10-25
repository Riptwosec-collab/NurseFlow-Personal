import SwiftUI

enum Palette {
    static let ink = Color(red: 0.14, green: 0.24, blue: 0.38)
    static let muted = Color(red: 0.44, green: 0.52, blue: 0.64)
    static let blue = Color(red: 0.32, green: 0.55, blue: 0.84)
    static let canvas = Color(red: 0.985, green: 0.990, blue: 1.0)
    static let border = Color(red: 0.90, green: 0.93, blue: 0.97)
    static let pink = Color(red: 1.0, green: 0.90, blue: 0.94)
    static let mint = Color(red: 0.88, green: 0.97, blue: 0.93)
    static let violet = Color(red: 0.93, green: 0.90, blue: 1.0)
    static let peach = Color(red: 1.0, green: 0.94, blue: 0.86)
}

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0; Scanner(string: cleaned).scanHexInt64(&value)
        self.init(.sRGB, red: Double((value >> 16) & 0xff) / 255,
                  green: Double((value >> 8) & 0xff) / 255, blue: Double(value & 0xff) / 255, opacity: 1)
    }
}

struct PastelCard<Content: View>: View {
    var background: Color = .white
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Palette.border.opacity(0.8), lineWidth: background == .white ? 1 : 0))
    }
}

struct ShiftPill: View {
    var kind: ShiftKind
    var body: some View {
        Text(kind.code).font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(Palette.ink).frame(minWidth: 28)
            .padding(.horizontal, 6).padding(.vertical, 5)
            .background(Color(hex: kind.color), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct ScreenTitle: View {
    var title: String
    var subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 29, weight: .bold, design: .rounded)).foregroundStyle(Palette.ink)
            Text(subtitle).font(.subheadline).foregroundStyle(Palette.muted)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}
