import SwiftUI

@main
@MainActor
struct NokhchiApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(colorScheme)
                .alert("Не удалось выполнить действие", isPresented: hasError) {
                    Button("Понятно", role: .cancel) { store.errorMessage = nil }
                } message: {
                    Text(store.errorMessage ?? "")
                }
        }
    }

    private var colorScheme: ColorScheme? {
        switch store.state.appearance {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    private var hasError: Binding<Bool> {
        Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )
    }
}
