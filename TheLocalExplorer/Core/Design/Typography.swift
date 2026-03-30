import SwiftUI

enum AppFonts {
    static func heading(size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }

    static func subheading(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .medium, design: .serif)
    }

    static func body(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    static func small() -> Font {
        .system(size: 13, weight: .medium, design: .default)
    }

    static func button() -> Font {
        .system(size: 15, weight: .semibold, design: .default)
    }

    static func caption() -> Font {
        .system(size: 11, weight: .bold, design: .default)
    }
}

struct SmallCapsStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFonts.small())
            .textCase(.uppercase)
            .tracking(0.8)
    }
}

extension View {
    func smallCapsStyle() -> some View {
        modifier(SmallCapsStyle())
    }
}
