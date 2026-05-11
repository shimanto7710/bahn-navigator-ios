//
//  SearchJourney.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 8/5/26.
//

import SwiftUI
import SwiftData


struct SearchJourneyView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SearchJourneyViewModel()
    @State private var isShowingLocationPicker = false


    var body: some View {
        VStack(alignment: .leading) {
            header

            routeFields

            settingsRow(
                iconName: "calendar",
                title: "Date",
                value: viewModel.uiState.date,
                action: {
                    viewModel.onDateClick()
                }
            )

            Divider()

            settingsRow(
                iconName: "person",
                title: "Passengers, bicycles",
                value: viewModel.uiState.passengers,
                action: {
                    viewModel.onPassengersClick()
                }
            )

            Divider()

            settingsRow(
                iconName: "slider.horizontal.3",
                title: "Options",
                value: viewModel.uiState.options,
                action: {
                    viewModel.onOptionsClick()
                }
            )

            Divider()

            settingsRow(
                iconName: "figure.walk",
                title: "Type Of Connection",
                value: viewModel.uiState.connectionType,
                action: {
                    viewModel.onConnectionTypeClick()
                }
            )

            let canSearch = !viewModel.uiState.from.isEmpty && !viewModel.uiState.to.isEmpty
            Button {
                viewModel.onSearchClick()
            } label: {
                Text("Search")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.appDark.opacity(canSearch ? 1 : 0.45))
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 20)
            }
            .disabled(!canSearch)

            Spacer()
        }
        .padding()
        .contentShape(Rectangle())
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToResults) {
            if let params = viewModel.journeySearchParams {
                JourneyResultsView(params: params)
            }
        }
        .sheet(isPresented: $isShowingLocationPicker) {
            LocationPickerSheet(
                searchText: Binding(
                    get: { viewModel.uiState.locationPicker.searchText },
                    set: { viewModel.onLocationSearchChange($0) }
                ),
                locations: viewModel.uiState.locationPicker.results,
                favoriteLocationIDs: viewModel.uiState.locationPicker.favoriteLocationIDs,
                isLoading: viewModel.uiState.locationPicker.isLoading,
                errorMessage: viewModel.uiState.locationPicker.errorMessage,
                onSelectLocation: { location in
                    viewModel.onLocationSelected(location)
                    isShowingLocationPicker = false
                },
                onSaveLocation: { location in
                    viewModel.onSaveLocationClick(location)
                },
                title: viewModel.uiState.locationPicker.title,
                onCurrentPositionSelected: {
                    viewModel.onClickCurrentPosition()
                }
            )
            .presentationDetents([.large])
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Bahn Navigator")
                .bold()

            Rectangle()
                .fill(Color.appRed)
                .frame(width: 122, height: 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }

    private var routeFields: some View {
        ZStack(alignment: .trailing) {
            VStack {
                routeFieldButton(
                    "From",
                    value: viewModel.uiState.from
                ) {
                    viewModel.onLocationPickerOpened(for: .origin)
                    isShowingLocationPicker = true
                }
                routeFieldButton(
                    "To",
                    value: viewModel.uiState.to
                ) {
                    viewModel.onLocationPickerOpened(for: .destination)
                    isShowingLocationPicker = true
                }
            }

            Button {
                viewModel.onSwapRouteClick()
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
                    .shadow(radius: 1)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 10)
        }
        .padding(.bottom, 15)
    }

    private func routeFieldButton(
        _ placeholder: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(value.isEmpty ? placeholder : value)
                .foregroundColor(value.isEmpty ? Color(.placeholderText) : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(5)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray6))
                )
        }
        .buttonStyle(.plain)
    }

    private func settingsRow(
        iconName: String,
        title: String,
        value: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 14))
                    .foregroundColor(.black)

                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.darkGray))

                Spacer()

                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .padding(10)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .padding(.leading, 4)
        }
        .buttonStyle(.plain)
    }
}



#Preview("iPhone 16 Pro") {
    SearchJourneyView()
}
