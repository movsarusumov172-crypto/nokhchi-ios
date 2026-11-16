import SwiftUI

struct CategoryStrip: View {
    @Binding var selection: BusinessCategory?

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                categoryButton(title: "Все", symbol: "square.grid.2x2", category: nil)
                ForEach(BusinessCategory.allCases) { category in
                    categoryButton(
                        title: category.title, symbol: category.symbol, category: category
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .sensoryFeedback(.selection, trigger: selection)
    }

    private func categoryButton(
        title: String, symbol: String, category: BusinessCategory?
    ) -> some View {
        Button {
            selection = category
        } label: {
            Label(title, systemImage: symbol)
                .font(.subheadline)
                .padding(.vertical, 4)
                .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.bordered)
        .tint(selection == category ? .accentColor : .secondary)
        .accessibilityAddTraits(selection == category ? .isSelected : [])
    }
}
