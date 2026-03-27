import SwiftUI

struct DailyDropView: View {
    @StateObject private var viewModel = DailyDropViewModel()
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var locationService: LocationService

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else if let drop = viewModel.dailyDrop {
                    contentView(drop: drop)
                }
            }
        }
        .background(AppColors.oatmeal)
        .ignoresSafeArea(edges: .top)
        .refreshable {
            let loc = locationService.effectiveLocation
            await viewModel.loadDrops(apiService: apiService, lat: loc.latitude, lng: loc.longitude)
        }
        .task {
            locationService.requestPermission()
            let loc = locationService.effectiveLocation
            await viewModel.loadDrops(apiService: apiService, lat: loc.latitude, lng: loc.longitude)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("The Local Explorer")
                    .font(AppFonts.heading(size: 22))
                    .foregroundStyle(AppColors.espresso)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Search action
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColors.espresso)
                }
            }
        }
    }

    // MARK: - Content

    private func contentView(drop: DailyDropResponse) -> some View {
        VStack(spacing: 0) {
            // Hero
            NavigationLink(value: drop.nearbySpots.first) {
                HeroEditorialCard(
                    title: drop.hero.title,
                    subtitle: drop.hero.subtitle,
                    category: drop.hero.category,
                    imageURL: drop.hero.imageURL
                )
            }
            .buttonStyle(.plain)

            // Vibe Pills
            vibeFilterBar

            // Near You Section
            nearYouSection

            // Editorial Drops
            editorialDropsSection(drops: drop.drops)
        }
    }

    private var vibeFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.vibeFilters, id: \.self) { vibe in
                    VibePill(
                        label: vibe,
                        isSelected: viewModel.selectedVibe == vibe,
                        style: .filter
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectVibe(vibe)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
        .background(
            AppColors.oatmeal.opacity(0.95)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .bottom) {
            Divider().background(Color.black.opacity(0.05))
        }
    }

    private var nearYouSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Near You")
                    .font(AppFonts.heading(size: 26))
                    .foregroundStyle(AppColors.espresso)

                Spacer()

                HStack(spacing: 4) {
                    Text("MAP")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1.5)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(AppColors.tomatoRed)
            }
            .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.filteredNearbySpots) { spot in
                        NavigationLink(value: spot) {
                            NearbySpotCard(spot: spot)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 32)
    }

    private func editorialDropsSection(drops: [Drop]) -> some View {
        VStack(spacing: 24) {
            ForEach(drops) { drop in
                EditorialCard(
                    title: drop.title,
                    category: drop.category,
                    imageURL: drop.imageURL,
                    height: 400
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    // MARK: - Loading & Error

    private var loadingView: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.skeleton)
                    .frame(height: 200)
                    .padding(.horizontal, 24)
            }
        }
        .padding(.top, 100)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.mushroom)

            Text(message)
                .font(AppFonts.body())
                .foregroundStyle(AppColors.mushroom)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 200)
    }
}
