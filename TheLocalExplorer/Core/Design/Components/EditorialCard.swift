import SwiftUI

struct EditorialCard: View {
    let title: String
    let category: String
    let imageURL: String
    let height: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(AppColors.skeleton)
                case .empty:
                    Rectangle()
                        .fill(AppColors.skeleton)
                        .overlay(
                            ProgressView()
                                .tint(AppColors.mushroom)
                        )
                @unknown default:
                    Rectangle()
                        .fill(AppColors.skeleton)
                }
            }
            .frame(height: height)
            .clipped()

            LinearGradient(
                colors: [
                    AppColors.espresso.opacity(0.9),
                    AppColors.espresso.opacity(0.2),
                    .clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(category.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.white.opacity(0.2))
                    .background(.ultraThinMaterial.opacity(0.5))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )

                Text(title)
                    .font(AppFonts.heading(size: 26))
                    .foregroundStyle(.white)
                    .lineLimit(3)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.white)
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .floatShadow()
    }
}

struct HeroEditorialCard: View {
    let title: String
    let subtitle: String
    let category: String
    let imageURL: String

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(AppColors.skeleton)
                case .empty:
                    Rectangle()
                        .fill(AppColors.skeleton)
                        .overlay(
                            ProgressView()
                                .tint(AppColors.mushroom)
                        )
                @unknown default:
                    Rectangle()
                        .fill(AppColors.skeleton)
                }
            }
            .frame(height: 574)
            .clipped()

            LinearGradient(
                colors: [
                    AppColors.espresso.opacity(0.95),
                    AppColors.espresso.opacity(0.4),
                    .clear
                ],
                startPoint: .bottom,
                endPoint: .top
            )

            VStack(alignment: .leading, spacing: 12) {
                Text(category.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.tomatoRed)
                    .clipShape(Capsule())
                    .shadow(radius: 4)

                Text(title)
                    .font(AppFonts.heading(size: 36))
                    .foregroundStyle(.white)
                    .tracking(-0.5)
                    .lineLimit(3)

                Text(subtitle)
                    .font(AppFonts.body(size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.8))
                    .lineLimit(2)
                    .frame(maxWidth: 280, alignment: .leading)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.white)
        .frame(height: 574)
    }
}
