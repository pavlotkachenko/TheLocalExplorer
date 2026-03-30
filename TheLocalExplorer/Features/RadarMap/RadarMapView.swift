import SwiftUI
import MapKit

struct RadarMapView: View {
    @StateObject private var viewModel = RadarMapViewModel()
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var locationService: LocationService

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: LocationService.defaultLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
        )
    )

    var body: some View {
        ZStack {
            mapView

            VStack {
                searchBar
                Spacer()

                if viewModel.showMiniCard, let spot = viewModel.selectedSpot {
                    NavigationLink(value: spot) {
                        MiniProfileCard(spot: spot)
                            .padding(.horizontal, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .buttonStyle(.plain)
                }

                filterBar
            }
        }
        .navigationBarHidden(true)
        .task {
            locationService.requestPermission()
            let loc = locationService.effectiveLocation
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: loc,
                    span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                )
            )
            await viewModel.loadSpots(apiService: apiService, lat: loc.latitude, lng: loc.longitude)
        }
    }

    // MARK: - Map

    private var mapView: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            // User location
            UserAnnotation()

            // Walking radius rings
            MapCircle(center: locationService.effectiveLocation, radius: 400)
                .stroke(AppColors.tomatoRed.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                .foregroundStyle(.clear)

            MapCircle(center: locationService.effectiveLocation, radius: 800)
                .stroke(AppColors.tomatoRed.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                .foregroundStyle(.clear)

            MapCircle(center: locationService.effectiveLocation, radius: 1200)
                .stroke(AppColors.tomatoRed.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [8, 4]))
                .foregroundStyle(.clear)

            // Spot markers
            ForEach(viewModel.filteredSpots) { spot in
                Annotation(spot.name, coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude)) {
                    SpotMarker(spot: spot, isSelected: viewModel.selectedSpot?.id == spot.id)
                        .onTapGesture {
                            viewModel.selectSpot(spot)
                        }
                }
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .onTapGesture {
            viewModel.dismissMiniCard()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.mushroom)

            TextField("Search areas, cuisines...", text: $viewModel.searchText)
                .font(AppFonts.body(size: 15))
                .foregroundStyle(AppColors.espresso)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.mushroom)
                }
            }

            Divider()
                .frame(height: 24)

            Button {
                // Filter options
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundStyle(AppColors.espresso)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppColors.pureWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .floatShadow()
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(RadarMapViewModel.MapFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.toggleFilter(filter)
                    } label: {
                        HStack(spacing: 4) {
                            Text(filter.rawValue)
                                .font(.system(size: 13, weight: .semibold))

                            if filter == .price || filter == .cuisine {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.selectedFilter == filter
                            ? AppColors.espresso
                            : AppColors.pureWhite
                        )
                        .foregroundStyle(
                            viewModel.selectedFilter == filter
                            ? .white
                            : AppColors.espresso
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 12)
        .background(
            AppColors.pureWhite
                .shadow(color: AppColors.softShadow, radius: 8, y: -4)
        )
    }
}

// MARK: - Spot Marker

struct SpotMarker: View {
    let spot: Spot
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(markerColor)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: markerColor.opacity(0.4), radius: isSelected ? 8 : 4, y: 4)

                Text(spot.priceLevelString)
                    .font(.system(size: isSelected ? 14 : 12, weight: .bold))
                    .foregroundStyle(.white)
            }

            Triangle()
                .fill(markerColor)
                .frame(width: 14, height: 8)
                .offset(y: -2)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }

    private var markerColor: Color {
        spot.cuisine.localizedCaseInsensitiveContains("cafe") || spot.cuisine.localizedCaseInsensitiveContains("coffee")
        ? AppColors.mustard
        : AppColors.tomatoRed
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
