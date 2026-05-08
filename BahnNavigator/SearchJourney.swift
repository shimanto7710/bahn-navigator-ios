//
//  SearchJourney.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 8/5/26.
//

import SwiftUI

struct SearchJourney: View {
    // Better practice: use @StateObject when this view creates and owns the view model.
    @StateObject private var viewModel = SearchJourneyViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            header

            routeFields

            settingsRow(
                iconName: "calendar",
                title: "Date",
                value: viewModel.dateText,
                action: {
                    viewModel.onDateTapped()
                }
            )

            Divider()

            settingsRow(
                iconName: "person",
                title: "Passengers, bicycles",
                value: viewModel.passengersText,
                action: {
                    viewModel.onPassengersTapped()
                }
            )

            Divider()

            settingsRow(
                iconName: "slider.horizontal.3",
                title: "Options",
                value: viewModel.optionsText,
                action: {
                    viewModel.onOptionsTapped()
                }
            )

            Divider()

            settingsRow(
                iconName: "figure.walk",
                title: "Type Of Connection",
                value: viewModel.connectionTypeText,
                action: {
                    viewModel.onFastestConnectionsTapped()
                }
            )

            Button {
                viewModel.onSearchTapped()
            } label: {
                Text("Search")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.15, green: 0.16, blue: 0.18))
                    )
                    .padding(.horizontal, 12)
                    .padding(.top, 20)
            }

            Spacer()
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Bahn Navigator")
                .bold()

            Rectangle()
                .fill(Color.red)
                .frame(width: 122, height: 3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }

    private var routeFields: some View {
        ZStack(alignment: .trailing) {
            VStack {
                routeTextField("From", text: $viewModel.fromText)
                routeTextField("To", text: $viewModel.toText)
            }

            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
                .padding(10)
                .background(
                    Circle()
                        .fill(Color.white)
                )
                .shadow(radius: 1)
                .padding(.trailing, 10)
        }
        .padding(.bottom, 15)
    }

    private func routeTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding(5)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(.systemGray6))
            )
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
            // Better practice: make Spacer's empty area tappable inside a custom Button row.
            .contentShape(Rectangle())
            .padding(.leading, 4)
        }

        // Better practice: .plain keeps the row from turning blue like a default text button.
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchJourney()
}
