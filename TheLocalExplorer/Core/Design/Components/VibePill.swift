import SwiftUI

struct VibePill: View {
    let label: String
    var isSelected: Bool = false
    var style: VibePillStyle = .filter

    var body: some View {
        Text(label)
            .font(AppFonts.small())
            .fontWeight(isSelected ? .semibold : .medium)
            .tracking(0.5)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: 1)
            )
            .shadow(color: AppColors.softShadow, radius: 4, y: 2)
    }

    private var backgroundColor: Color {
        switch style {
        case .filter:
            return isSelected ? AppColors.tomatoRed : AppColors.pureWhite
        case .tag:
            return isSelected ? AppColors.tomatoRed.opacity(0.05) : .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .filter:
            return isSelected ? .white : AppColors.espresso
        case .tag:
            return isSelected ? AppColors.tomatoRed : AppColors.espresso
        }
    }

    private var borderColor: Color {
        switch style {
        case .filter:
            return isSelected ? AppColors.tomatoRed : Color.black.opacity(0.1)
        case .tag:
            return isSelected ? AppColors.tomatoRed : AppColors.espresso.opacity(0.2)
        }
    }
}

enum VibePillStyle {
    case filter
    case tag
}
