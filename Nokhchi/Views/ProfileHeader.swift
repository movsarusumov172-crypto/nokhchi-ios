import SwiftUI

struct ProfileHeader: View {
    let name: String
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: 16) {
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.title2.bold())
                Text("Участник").font(.subheadline).foregroundStyle(.secondary)
                Text("Локальный профиль").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 8)
    }
}
