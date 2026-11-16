import SwiftUI

struct BusinessRow: View {
    let business: Business
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if !dynamicTypeSize.isAccessibilitySize {
                if business.photo.isEmpty {
                    Image(systemName: business.category.symbol)
                        .font(.title2)
                        .frame(width: 64, height: 64)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityHidden(true)
                } else {
                    Image(business.photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .accessibilityHidden(true)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(business.name).font(.headline)
                Text(business.category.title).font(.subheadline).foregroundStyle(.secondary)
                ViewThatFits(in: .horizontal) {
                    HStack {
                        location
                        Spacer(minLength: 8)
                        rating
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        location
                        rating
                    }
                }
                .font(.caption)
            }
            .padding(.vertical, 4)
        }
    }

    private var location: some View {
        Text(business.city ?? "Город не виден на снимке")
            .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private var rating: some View {
        if let rating = business.rating {
            Label(rating.formatted(.number.precision(.fractionLength(1))), systemImage: "star.fill")
                .foregroundStyle(.secondary)
                .accessibilityLabel("Рейтинг со снимка: \(rating.formatted()) из 5")
        }
    }
}

struct DemoNotice: View {
    var body: some View {
        Text("Локальные демоданные со скриншотов. Рейтинги не обновляются.")
            .font(.footnote)
            .foregroundStyle(.secondary)
    }
}
