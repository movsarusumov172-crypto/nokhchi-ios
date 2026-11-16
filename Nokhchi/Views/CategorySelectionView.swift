import SwiftUI

struct CategorySelectionView: View {
    @State private var selection: BusinessCategory?
    @State private var draft: OrganizationDraft?
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), alignment: .top),
            count: dynamicTypeSize.isAccessibilitySize ? 1 : 2
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Выберите категорию").font(.title2.bold())
                Text("Сначала категория, затем локальный черновик организации.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(BusinessCategory.allCases) { category in
                        categoryButton(category)
                    }
                }
                Text("Далее: информация, фото, видео, адрес, часы работы и предпросмотр.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Добавить")
        .safeAreaInset(edge: .bottom) {
            Button {
                if let selection { draft = OrganizationDraft(category: selection) }
            } label: {
                Text("Далее").frame(maxWidth: .infinity, minHeight: 32)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selection == nil)
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .sensoryFeedback(.selection, trigger: selection)
        .sheet(item: $draft) { draft in DraftEditorView(draft: draft) }
    }

    private func categoryButton(_ category: BusinessCategory) -> some View {
        Button {
            selection = category
        } label: {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: category.symbol).font(.title2)
                    Spacer()
                    if selection == category {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                Text(category.title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
            .background(
                Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(selection == category ? Color.accentColor : Color.primary)
        .accessibilityLabel(category.title)
        .accessibilityAddTraits(selection == category ? .isSelected : [])
    }
}
