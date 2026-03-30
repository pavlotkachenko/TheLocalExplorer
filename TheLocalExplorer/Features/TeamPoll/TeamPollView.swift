import SwiftUI

struct TeamPollView: View {
    @StateObject private var viewModel = TeamPollViewModel()
    @EnvironmentObject var apiService: APIService

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        loadingView
                    } else if let poll = viewModel.activePoll {
                        pollContent(poll: poll)
                    } else {
                        noPollView
                    }
                }
                .padding(.bottom, 120)
            }
            .background(AppColors.oatmeal)

            if viewModel.activePoll != nil {
                stickyButton
            }
        }
        .navigationTitle("Team Poll")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.isShowingCreateSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppColors.tomatoRed)
                        .font(.system(size: 24))
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingCreateSheet) {
            CreatePollView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadActivePoll(apiService: apiService)
        }
    }

    // MARK: - Poll Content

    private func pollContent(poll: Poll) -> some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text(poll.title)
                    .font(AppFonts.heading(size: 36))
                    .foregroundStyle(AppColors.espresso)
                    .multilineTextAlignment(.center)
                    .tracking(-0.5)

                Text("CLOSES IN \(poll.minutesRemaining) MINS")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(AppColors.mushroom)
            }
            .padding(.top, 40)
            .padding(.bottom, 8)

            // Options
            VStack(spacing: 16) {
                ForEach(poll.options) { option in
                    PollOptionCard(
                        option: option,
                        isSelected: viewModel.selectedOptionId == option.id,
                        isWinning: viewModel.winningOptionId == option.id,
                        onTap: {
                            Task {
                                await viewModel.vote(optionId: option.id, apiService: apiService)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 20)

            // Voters section
            if !poll.voters.isEmpty {
                VStack(spacing: 12) {
                    Text("\(poll.totalVotes) VOTED")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(AppColors.mushroom)

                    HStack(spacing: -12) {
                        ForEach(poll.voters.prefix(5)) { voter in
                            AsyncImage(url: URL(string: voter.avatarURL)) { phase in
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
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(AppColors.oatmeal, lineWidth: 2)
                            )
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Sticky Button

    private var stickyButton: some View {
        Button {
            viewModel.shareToTelegram()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16))
                Text("Share via Telegram")
                    .font(AppFonts.button())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppColors.tomatoRed)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: AppColors.tomatoRed.opacity(0.3), radius: 12, y: 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
        .padding(.top, 12)
        .background(
            LinearGradient(
                colors: [AppColors.oatmeal, AppColors.oatmeal.opacity(0)],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 120)
            .allowsHitTesting(false)
        )
    }

    // MARK: - States

    private var noPollView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "chart.bar.xaxis.ascending")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.mushroom.opacity(0.4))

            Text("No Active Polls")
                .font(AppFonts.heading(size: 24))
                .foregroundStyle(AppColors.espresso)

            Text("Start a poll to coordinate lunch with your team.")
                .font(AppFonts.body())
                .foregroundStyle(AppColors.mushroom)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                viewModel.isShowingCreateSheet = true
            } label: {
                Text("Create Poll")
                    .font(AppFonts.button())
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AppColors.tomatoRed)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Spacer()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.skeleton)
                    .frame(height: 100)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 100)
    }
}

// MARK: - Poll Option Card

struct PollOptionCard: View {
    let option: PollOption
    let isSelected: Bool
    let isWinning: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: option.spotImageURL)) { phase in
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
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 6) {
                    Text(option.spotName)
                        .font(AppFonts.subheading(size: 20))
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.espresso)

                    HStack(spacing: 8) {
                        Text("\(Int(option.votePercentage))%")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(isWinning ? AppColors.oliveGreen : AppColors.mushroom)

                        HStack(spacing: 4) {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 12))
                            Text("\(option.walkingTimeMinutes) min")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(AppColors.mushroom)
                    }

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(AppColors.skeleton)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 3)
                                .fill(isWinning ? AppColors.oliveGreen : AppColors.mushroom.opacity(0.5))
                                .frame(width: geo.size.width * option.votePercentage / 100, height: 6)
                        }
                    }
                    .frame(height: 6)
                }

                Spacer()

                // Radio button
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? AppColors.oliveGreen : AppColors.mushroom.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(AppColors.oliveGreen)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(AppColors.pureWhite)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isWinning ? AppColors.oliveGreen : Color.clear,
                        lineWidth: 2
                    )
            )
            .softShadow()
        }
        .buttonStyle(.plain)
    }
}
