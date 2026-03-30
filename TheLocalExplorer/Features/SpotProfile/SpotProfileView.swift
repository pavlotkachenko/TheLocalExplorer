import SwiftUI

struct SpotProfileView: View {
    @StateObject private var viewModel: SpotProfileViewModel
    @EnvironmentObject var apiService: APIService
    @Environment(\.dismiss) private var dismiss

    init(spot: Spot) {
        _viewModel = StateObject(wrappedValue: SpotProfileViewModel(spot: spot))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    photoGrid
                    spotDetails
                }
                .padding(.bottom, 100)
            }
            .ignoresSafeArea(edges: .top)

            stickyFooter
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.espresso)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 8) {
                    Button {
                        shareSpot()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AppColors.espresso)
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    Button {
                        Task {
                            await viewModel.toggleSave(apiService: apiService)
                        }
                    } label: {
                        Image(systemName: viewModel.isSaved ? "heart.fill" : "heart")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(viewModel.isSaved ? AppColors.tomatoRed : AppColors.espresso)
                            .frame(width: 40, height: 40)
                            .background(.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .background(AppColors.oatmeal)
        .fullScreenCover(isPresented: $viewModel.isShowingLightbox) {
            PhotoLightbox(
                photoURLs: viewModel.spot.photoURLs,
                selectedIndex: $viewModel.selectedPhotoIndex
            )
        }
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        GeometryReader { geo in
            let width = geo.size.width
            HStack(spacing: 2) {
                photoCell(url: viewModel.spot.photoURLs.first ?? "", index: 0)
                    .frame(width: width * 2 / 3)

                VStack(spacing: 2) {
                    if viewModel.spot.photoURLs.count > 1 {
                        photoCell(url: viewModel.spot.photoURLs[1], index: 1)
                    }
                    if viewModel.spot.photoURLs.count > 2 {
                        photoCell(url: viewModel.spot.photoURLs[2], index: 2)
                    }
                }
                .frame(width: width / 3 - 2)
            }
        }
        .frame(height: 400)
    }

    private func photoCell(url: String, index: Int) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
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
                    .overlay(ProgressView().tint(AppColors.mushroom))
            @unknown default:
                Rectangle()
                    .fill(AppColors.skeleton)
            }
        }
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectedPhotoIndex = index
            viewModel.isShowingLightbox = true
        }
    }

    // MARK: - Spot Details

    private var spotDetails: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.spot.name)
                    .font(AppFonts.heading(size: 32))
                    .foregroundStyle(AppColors.espresso)
                    .tracking(-0.5)

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 14))
                        Text("\(viewModel.spot.walkingTimeMinutes) min walk")
                    }
                    .foregroundStyle(AppColors.tomatoRed)

                    Text("\u{2022}")
                        .foregroundStyle(AppColors.espresso.opacity(0.3))

                    Text(viewModel.spot.priceLevelString)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.espresso)

                    Text("\u{2022}")
                        .foregroundStyle(AppColors.espresso.opacity(0.3))

                    Text(viewModel.spot.cuisine.uppercased())
                        .foregroundStyle(AppColors.espresso.opacity(0.7))
                }
                .font(.system(size: 14, weight: .medium))
                .textCase(.uppercase)
                .tracking(1)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Vibe Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.spot.vibes, id: \.self) { vibe in
                        VibePill(
                            label: vibe,
                            isSelected: vibe == viewModel.spot.vibes.first,
                            style: .tag
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)

            // Editorial Quote
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 32))
                    .foregroundStyle(AppColors.tomatoRed.opacity(0.4))

                Text(viewModel.spot.editorialQuote)
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(AppColors.espresso)
                    .lineSpacing(6)

                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: viewModel.spot.editorAvatarURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Circle()
                                .fill(AppColors.skeleton)
                        }
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())

                    Text(viewModel.spot.editorName.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(AppColors.espresso.opacity(0.6))
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(AppColors.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(AppColors.tomatoRed.opacity(0.15), lineWidth: 1)
            )
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(AppColors.tomatoRed)
                    .frame(width: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            // The Vibe
            VStack(alignment: .leading, spacing: 12) {
                Text("The Vibe")
                    .font(AppFonts.heading(size: 22))
                    .foregroundStyle(AppColors.espresso)

                Text(viewModel.spot.description)
                    .font(AppFonts.body(size: 15))
                    .foregroundStyle(AppColors.espresso.opacity(0.8))
                    .lineSpacing(6)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            // Top Dishes
            VStack(alignment: .leading, spacing: 16) {
                Text("Top Dishes")
                    .font(AppFonts.heading(size: 22))
                    .foregroundStyle(AppColors.espresso)

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.spot.topDishes.enumerated()), id: \.element.id) { index, dish in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dish.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(AppColors.espresso)

                                Text(dish.description)
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppColors.espresso.opacity(0.6))
                            }

                            Spacer()

                            Text(dish.priceString)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(AppColors.espresso)
                        }
                        .padding(.vertical, 12)

                        if index < viewModel.spot.topDishes.count - 1 {
                            Divider()
                                .background(AppColors.espresso.opacity(0.1))
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Sticky Footer

    private var stickyFooter: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.openDirections()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 16))
                    Text("Directions")
                        .font(AppFonts.button())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.pureWhite)
                .foregroundStyle(AppColors.espresso)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.espresso.opacity(0.1), lineWidth: 2)
                )
            }

            Button {
                viewModel.isShowingPollSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "megaphone.fill")
                        .font(.system(size: 16))
                    Text("Propose to Team")
                        .font(AppFonts.button())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppColors.tomatoRed)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: AppColors.tomatoRed.opacity(0.25), radius: 8, y: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .padding(.bottom, 4)
        .background(
            AppColors.pureWhite.opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .top) {
            Divider().background(AppColors.espresso.opacity(0.05))
        }
    }

    private func shareSpot() {
        let text = "Check out \(viewModel.spot.name) - \(viewModel.spot.cuisine) \(viewModel.spot.priceLevelString)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
}

// MARK: - Photo Lightbox

struct PhotoLightbox: View {
    let photoURLs: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            TabView(selection: $selectedIndex) {
                ForEach(Array(photoURLs.enumerated()), id: \.offset) { index, url in
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            ProgressView()
                                .tint(.white)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.top, 60)
            .padding(.trailing, 20)
        }
    }
}
