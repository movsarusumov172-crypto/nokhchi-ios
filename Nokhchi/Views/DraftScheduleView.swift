import SwiftUI

struct DraftScheduleView: View {
    @Binding var draft: OrganizationDraft
    @State private var opening = Calendar.current.date(from: DateComponents(hour: 9)) ?? Date()
    @State private var closing = Calendar.current.date(from: DateComponents(hour: 18)) ?? Date()

    var body: some View {
        Form {
            Section("Часы работы") {
                Toggle("Круглосуточно", isOn: Binding(
                    get: { draft.alwaysOpen == true }, set: { draft.alwaysOpen = $0 }
                ))
                if draft.alwaysOpen != true {
                    DatePicker("Открытие", selection: $opening, displayedComponents: .hourAndMinute)
                    DatePicker("Закрытие", selection: $closing, displayedComponents: .hourAndMinute)
                }
            } footer: {
                Text("Одинаковое расписание на все дни. Можно указать закрытие после полуночи.")
            }
        }
        .onAppear {
            opening = parseTime(draft.openingTime) ?? opening
            closing = parseTime(draft.closingTime) ?? closing
            updateTimes()
        }
        .onChange(of: opening) { _, _ in updateTimes() }
        .onChange(of: closing) { _, _ in updateTimes() }
    }

    private func updateTimes() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        draft.openingTime = formatter.string(from: opening)
        draft.closingTime = formatter.string(from: closing)
    }

    private func parseTime(_ time: String?) -> Date? {
        guard let time else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: time)
    }
}
