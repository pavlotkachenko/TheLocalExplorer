import SwiftUI

extension View {
    func cardStyle(radius: CGFloat = 12) -> some View {
        self
            .background(AppColors.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: AppColors.cardShadow, radius: 12, x: 0, y: 8)
    }

    func floatShadow() -> some View {
        self.shadow(color: AppColors.cardShadow, radius: 12, x: 0, y: 8)
    }

    func softShadow() -> some View {
        self.shadow(color: AppColors.softShadow, radius: 6, x: 0, y: 4)
    }
}
