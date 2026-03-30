import SwiftUI

struct MiniProfileCard: View {
    let spot: Spot

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

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(spot.name)
                        .font(AppFonts.subheading(size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.espresso)
                        .lineLimit(1)

                    Spacer()

                    Text(spot.priceLevelString)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColors.mushroom)
                }

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 12))
                        Text("\(spot.walkingTimeMinutes) min")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(AppColors.oliveGreen)

                    Text("\u{2022}")
                        .foregroundStyle(AppColors.mushroom)

                    Text(spot.cuisine)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.mushroom)
                }

                Text("\"\(spot.editorialQuote)\"")
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(AppColors.espresso)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(AppColors.pureWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .floatShadow()
    }
}
