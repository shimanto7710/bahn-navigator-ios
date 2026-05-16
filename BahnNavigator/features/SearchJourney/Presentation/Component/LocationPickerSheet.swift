//
//  LocationPickerSheet.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 9/5/26.
//

import SwiftUI
struct LocationPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool

    let searchText: Binding<String>
    let locations: [SearchStationModelElement]
    let favoriteLocationIDs: Set<String>
    let isLoading: Bool
    let errorMessage: String?
    let onSelectLocation: (SearchStationModelElement) -> Void
    let onSaveLocation: (SearchStationModelElement) -> Void
    let title: String
    let onCurrentPositionSelected: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            searchField

            VStack(spacing: 0) {
                locationOptionRow(
                    iconName: "location",
                    title: "Current position",
                    action: onCurrentPositionSelected
                )

                Divider()

                locationOptionRow(
                    iconName: "location",
                    title: "Stops nearby",
                    action: onCurrentPositionSelected
                )

                Divider()
            }

            if isLoading {
                ProgressView()
                    .padding()
            }

            if let errorMessage {
                messageRow(
                    iconName: "wifi.exclamationmark",
                    message: errorMessage,
                    color: .red
                )
            }

            List {
                if locations.isEmpty && !isLoading && errorMessage == nil {
                    messageRow(
                        iconName: "magnifyingglass",
                        message: "No locations found",
                        color: .gray
                    )
                } else {
                    ForEach(locations, id: \.displayID) { location in
                        HStack(spacing: 14) {
                            Button {
                                onSelectLocation(location)
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: iconName(for: location))
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.18))
                                        .frame(width: 28)

                                    Text(location.name)
                                        .font(.system(size: 17))
                                        .foregroundColor(.black)

                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            Button {
                                onSaveLocation(location)
                            } label: {
                                let isFavorite = favoriteLocationIDs.contains(location.displayID)

                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(isFavorite ? .orange : Color(.darkGray))
                                    .frame(width: 40, height: 40)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear {
            isSearchFocused = true
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Text("Cancel")
                    .font(.system(size: 18))
                    .foregroundColor(Color(.darkGray))
            }

            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.18))

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .padding(.bottom, 28)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle.circle")
                .font(.system(size: 22))
                .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.18))

            TextField("Station, search address", text: searchText)
                .font(.system(size: 20))
                .foregroundColor(.black)
                .tint(.blue)
                .focused($isSearchFocused)
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background(Color(.systemGray6))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.18)),
            alignment: .bottom
        )
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    private func locationOptionRow(
        iconName: String,
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.18))
                    .frame(width: 28)

                Text(title)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.15, green: 0.16, blue: 0.18))

                Spacer()
            }
            .frame(height: 64)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func messageRow(
        iconName: String,
        message: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(color)

            Text(message)
                .font(.system(size: 15))
                .foregroundColor(color)

            Spacer()
        }
        .padding()
    }

    private func iconName(for location: SearchStationModelElement) -> String {
        switch location.type {
        case .location:
            return location.poi == true ? "mappin.circle" : "mappin"
        case .station, .stop:
            return "tram.fill"
        }
    }
}

#Preview {
    let stations: [SearchStationModelElement] = [
        SearchStationModelElement(
            id: "8011160", name: "Berlin Hbf", type: .station,
            location: nil, products: nil, weight: nil, ril100IDS: nil,
            ifoptID: nil, priceCategory: nil, transitAuthority: nil,
            stadaID: nil, station: nil
        ),
        SearchStationModelElement(
            id: "8000261", name: "München Hbf", type: .station,
            location: nil, products: nil, weight: nil, ril100IDS: nil,
            ifoptID: nil, priceCategory: nil, transitAuthority: nil,
            stadaID: nil, station: nil
        ),
        SearchStationModelElement(
            id: "8002549", name: "Hamburg Hbf", type: .station,
            location: nil, products: nil, weight: nil, ril100IDS: nil,
            ifoptID: nil, priceCategory: nil, transitAuthority: nil,
            stadaID: nil, station: nil
        ),
    ]
    LocationPickerSheet(
        searchText: .constant("Berlin"),
        locations: stations,
        favoriteLocationIDs: Set(["8011160"]),
        isLoading: false,
        errorMessage: nil,
        onSelectLocation: { _ in },
        onSaveLocation: { _ in },
        title: "Select point of departure",
        onCurrentPositionSelected: { }
    )
}
