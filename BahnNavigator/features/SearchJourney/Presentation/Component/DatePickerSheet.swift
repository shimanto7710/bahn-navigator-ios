//
//  DatePickerSheet.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 15/5/26.
//

import SwiftUI

struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedDate: Date
    @Binding var dateType: DateTimeType

    @State private var monthOffset: Int = 0
    @State private var slideFromTrailing: Bool = true
    @State private var referenceMonth: Date

    private let calendar = Calendar.current

    init(selectedDate: Binding<Date>, dateType: Binding<DateTimeType>) {
        _selectedDate = selectedDate
        _dateType = dateType
        let comps = Calendar.current.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        _referenceMonth = State(initialValue: Calendar.current.date(from: comps) ?? Date())
    }

    private var displayedMonth: Date {
        calendar.date(byAdding: .month, value: monthOffset, to: referenceMonth) ?? referenceMonth
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            calendarSection
            Divider()
            bottomSection
            Spacer()
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Date / time")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .foregroundColor(.primary)
            }
        }
        .padding()
    }

    // MARK: - Calendar

    private var calendarSection: some View {
        monthView(for: displayedMonth)
            .id(monthOffset)
            .transition(.asymmetric(
                insertion: .move(edge: slideFromTrailing ? .trailing : .leading),
                removal:   .move(edge: slideFromTrailing ? .leading  : .trailing)
            ))
            .frame(height: 340)
            .clipped()
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        // Ignore mostly-vertical drags
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        if value.translation.width < 0 {
                            slideFromTrailing = true
                            withAnimation(.easeInOut(duration: 0.25)) { monthOffset += 1 }
                        } else if monthOffset > -1 {
                            slideFromTrailing = false
                            withAnimation(.easeInOut(duration: 0.25)) { monthOffset -= 1 }
                        }
                    }
            )
    }

    private func monthView(for month: Date) -> some View {
        VStack(spacing: 8) {
            Text(month.formatted(.dateTime.month(.wide).year()))
                .font(.body.weight(.medium))
                .padding(.top, 8)

            HStack {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { label in
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)

            let days = daysInMonth(month)
            let leadingOffset = firstWeekdayOffset(for: month)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 6) {
                ForEach(0..<leadingOffset, id: \.self) { _ in Color.clear.frame(height: 40) }
                ForEach(days, id: \.self) { date in dayCell(for: date) }
            }
            .padding(.horizontal, 8)
        }
    }

    private func dayCell(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        let isPast = date < calendar.startOfDay(for: Date()) && !isToday

        return Button {
            guard !isPast else { return }
            let h = calendar.component(.hour, from: selectedDate)
            let m = calendar.component(.minute, from: selectedDate)
            if let newDate = calendar.date(bySettingHour: h, minute: m, second: 0, of: date) {
                selectedDate = newDate
            }
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(.body)
                .foregroundColor(isSelected ? .white : isPast ? Color(.systemGray3) : .primary)
                .frame(width: 40, height: 40)
                .background(Circle().fill(isSelected ? Color.appRed : .clear))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom section

    private var bottomSection: some View {
        VStack(spacing: 16) {
            tabRow
            quickButtons
        }
        .padding()
    }

    private var tabRow: some View {
        HStack(alignment: .bottom, spacing: 0) {
            tabButton("Departure", type: .departure)
            tabButton("Arrival", type: .arrival)
            Spacer()
            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
        }
    }

    private func tabButton(_ title: String, type: DateTimeType) -> some View {
        let isSelected = dateType == type
        return VStack(spacing: 6) {
            Button(title) { dateType = type }
                .font(.body.weight(isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .primary : .secondary)
            Rectangle()
                .fill(isSelected ? Color.appRed : .clear)
                .frame(height: 2)
        }
        .padding(.trailing, 20)
    }

    private var quickButtons: some View {
        HStack(spacing: 12) {
            quickButton("Now")       { selectedDate = Date() }
            quickButton("in 15min")  { selectedDate = Date().addingTimeInterval(15 * 60) }
            quickButton("in 1h")     { selectedDate = Date().addingTimeInterval(60 * 60) }
        }
    }

    private func quickButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func daysInMonth(_ month: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }
        return range.compactMap { day in calendar.date(byAdding: .day, value: day - 1, to: start) }
    }

    /// Returns how many empty leading cells are needed so the grid starts on Monday.
    /// Calendar.weekday: 1 = Sun, 2 = Mon … 7 = Sat → Monday-based offset: 0 = Mon … 6 = Sun
    private func firstWeekdayOffset(for month: Date) -> Int {
        guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return 0 }
        let weekday = calendar.component(.weekday, from: start)
        return (weekday + 5) % 7
    }
}

#Preview {
    DatePickerSheet(
        selectedDate: .constant(Date()),
        dateType: .constant(.departure)
    )
}
