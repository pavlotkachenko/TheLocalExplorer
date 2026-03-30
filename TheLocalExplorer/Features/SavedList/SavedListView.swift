import SwiftUI

struct SavedListView: View {
    @StateObject private var viewModel = SavedListViewModel()
    @EnvironmentObject var apiService: APIService

    var body: some View {
        VStack(spacing: 0) {
            // Category Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(CollectionCategory.allCases, id: \.self) { category in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedCategory = category
                            }
                        } label: {
                            Text(category.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    viewModel.selectedCategory == category
                                    ? AppColors.tomatoRed
                                    : AppColors.pureWhite
                                )
                                .foregroundStyle(
                                    viewModel.selectedCategory == category
                                    ? .white
                                    : AppColors.mushroom
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            viewModel.selectedCategory == category
                                            ? Color.clear
                                            : Color.gray.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                                .softShadow()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)

            // List Content
            if viewModel.isLoading {
                loadingView
            } else if viewModel.displayedSpots.isEmpty {
                emptyView
            } else {
                spotsList
            }
        }
        .background(AppColors.oatmeal)
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Toggle map view
                } label: {
                    Image(systemName: "map")
                        .foregroundStyle(AppColors.espresso)
                        .frame(width: 40, height: 40)
                        .background(AppColors.pureWhite)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .softShadow()
                }
            }
        }
        .task {
            await viewModel.loadCollections(apiService: apiService)
        }
    }

    private var spotsList: some View {
        List {
            ForEach(viewModel.displayedSpots) { spot in
                NavigationLink(value: spot) {
                    SpotListItem(spot: spot)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteSpot(spot: spot, apiService: apiService)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(AppColors.tomatoRed)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "fork.knife.circle")
                .font(.system(size: 64))
                .foregroundStyle(AppColors.mushroom.opacity(0.5))

            Text("Nothing saved yet.")
                .font(AppFonts.heading(size: 22))
                .foregroundStyle(AppColors.espresso)

            Text("Go find your new favorite spot.")
                .font(AppFonts.body())
                .foregroundStyle(AppColors.mushroom)

            Spacer()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.skeleton)
                    .frame(height: 96)
                    .padding(.horizontal, 16)
            }
            Spacer()
        }
        .padding(.top, 8)
    }
}
