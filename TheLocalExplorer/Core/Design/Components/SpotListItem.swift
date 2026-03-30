import SwiftUI

struct SpotListItem: View {
    let spot: Spot
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: spot.photoURLs.first ?? "")) { phase in
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
                @unknown default:
                    Rectangle()
                        .fill(AppColors.skeleton)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .softShadow()

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(AppFonts.subheading(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.espresso)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let firstVibe = spot.vibes.first {
                        Text(firstVibe.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(AppColors.mustard)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .overlay(
                                Capsule()
                                    .stroke(AppColors.mustard, lineWidth: 1)
                            )
                            .clipShape(Capsule())
                    }

                    Text(spot.priceLevelString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.mushroom)
                }

                Text("\(String(format: "%.1f", spot.distanceMiles)) mi \u{2022} \(spot.walkingTimeMinutes) min walk")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.mushroom)
            }

            Spacer()
        }
        .padding(16)
        .background(AppColors.oatmeal)
    }
}

struct NearbySpotCard: View {
    let spot: Spot

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: spot.photoURLs.first ?? "")) { phase in
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
                @unknown default:
                    Rectangle()
                        .fill(AppColors.skeleton)
                }
            }
            .frame(width: 120, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .softShadow()

            Text(spot.name)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppColors.espresso)
                .lineLimit(1)

            HStack(spacing: 6) {
                Circle()
                    .fill(AppColors.tomatoRed.opacity(0.8))
                    .frame(width: 6, height: 6)

                Text("\(spot.walkingTimeMinutes) min walk")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.espresso.opacity(0.6))
            }
        }
        .frame(width: 120)
    }
}
