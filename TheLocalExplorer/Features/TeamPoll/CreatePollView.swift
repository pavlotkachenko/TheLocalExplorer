import SwiftUI

struct CreatePollView: View {
    @ObservedObject var viewModel: TeamPollViewModel
    @EnvironmentObject var apiService: APIService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("POLL QUESTION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(AppColors.mushroom)

                            TextField("Lunch today? Pick one.", text: $viewModel.pollTitle)
                                .font(AppFonts.body())
                                .padding(16)
                                .background(AppColors.pureWhite)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }

                        // Duration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("VOTING DURATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(AppColors.mushroom)

                            Picker("Duration", selection: $viewModel.pollDuration) {
                                Text("15 min").tag(15)
                                Text("30 min").tag(30)
                                Text("45 min").tag(45)
                                Text("1 hour").tag(60)
                            }
                            .pickerStyle(.segmented)
                        }

                        // Spot Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SELECT SPOTS (2-3)")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(AppColors.mushroom)

                            ForEach(viewModel.availableSpots) { spot in
                                spotSelectionRow(spot: spot)
                            }
                        }
                    }
                    .padding(20)
                }

                // Create Button
                Button {
                    Task {
                        await viewModel.createPoll(apiService: apiService)
                    }
                } label: {
                    Text("Create Poll")
                        .font(AppFonts.button())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            viewModel.selectedSpotIds.count >= 2
                            ? AppColors.tomatoRed
                            : AppColors.mushroom.opacity(0.3)
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(viewModel.selectedSpotIds.count < 2)
                .padding(20)
            }
            .background(AppColors.oatmeal)
            .navigationTitle("New Poll")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.espresso)
                }
            }
        }
        .task {
            await viewModel.loadAvailableSpots(apiService: apiService)
        }
    }

    private func spotSelectionRow(spot: Spot) -> some View {
        Button {
            if viewModel.selectedSpotIds.contains(spot.id) {
                viewModel.selectedSpotIds.remove(spot.id)
            } else if viewModel.selectedSpotIds.count < 3 {
                viewModel.selectedSpotIds.insert(spot.id)
            }
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: spot.photoURLs.first ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(AppColors.skeleton)
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.espresso)

                    HStack(spacing: 4) {
                        Text(spot.cuisine)
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.mushroom)

                        Text("\u{2022}")
                            .foregroundStyle(AppColors.mushroom)

                        Text("\(spot.walkingTimeMinutes) min")
                            .font(.system(size: 13))
                            .foregroundStyle(AppColors.mushroom)
                    }
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            viewModel.selectedSpotIds.contains(spot.id)
                            ? AppColors.oliveGreen
                            : AppColors.mushroom.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if viewModel.selectedSpotIds.contains(spot.id) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.oliveGreen)
                    }
                }
            }
            .padding(12)
            .background(AppColors.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        viewModel.selectedSpotIds.contains(spot.id)
                        ? AppColors.oliveGreen
                        : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
