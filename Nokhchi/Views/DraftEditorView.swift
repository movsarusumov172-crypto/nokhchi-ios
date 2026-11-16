import SwiftUI

struct DraftEditorView: View {
    @State var draft: OrganizationDraft
    @State private var original: OrganizationDraft?
    @State private var step = 2
    @State private var showingDiscard = false
    @State private var loadingMedia = false
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(step), total: 7)
                    .padding(.horizontal)
                content
            }
            .navigationTitle("\(stepTitle) · \(step)/7")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        if draft != original { showingDiscard = true } else { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { saveDraft() }
                        .disabled(draft.validationMessage != nil || loadingMedia)
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    if step > 2 {
                        Button("Назад") { step -= 1 }.buttonStyle(.bordered)
                    }
                    Spacer()
                    if step < 7 {
                        Button("Далее") { step += 1 }.buttonStyle(.borderedProminent)
                            .disabled(loadingMedia)
                    } else {
                        Button("Сохранить черновик") { saveDraft() }
                            .buttonStyle(.borderedProminent)
                            .disabled(draft.validationMessage != nil)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .confirmationDialog(
                "Не сохранять изменения?", isPresented: $showingDiscard,
                titleVisibility: .visible
            ) {
                Button("Не сохранять", role: .destructive) {
                    removeUnsavedVideo()
                    dismiss()
                }
                Button("Продолжить редактирование", role: .cancel) { showingDiscard = false }
            }
            .alert(
                "Не удалось сохранить",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.errorMessage = nil } }
                )
            ) {
                Button("Понятно", role: .cancel) { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
        .onAppear { if original == nil { original = draft } }
        .interactiveDismissDisabled(draft != original)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case 2: DraftInformationView(draft: $draft)
        case 3: DraftPhotosView(draft: $draft, loading: $loadingMedia)
        case 4:
            DraftVideoView(
                draft: $draft, originalVideo: original?.videoFile,
                loading: $loadingMedia)
        case 5: DraftAddressView(draft: $draft)
        case 6: DraftScheduleView(draft: $draft)
        default: DraftPreviewView(draft: draft)
        }
    }

    private var stepTitle: String {
        switch step {
        case 2: "Информация"
        case 3: "Фотографии"
        case 4: "Видео"
        case 5: "Адрес"
        case 6: "Часы работы"
        default: "Предпросмотр"
        }
    }

    private func saveDraft() {
        if store.saveDraft(draft) { dismiss() }
    }

    private func removeUnsavedVideo() {
        if let video = draft.videoFile, video != original?.videoFile { store.removeVideo(video) }
    }
}
