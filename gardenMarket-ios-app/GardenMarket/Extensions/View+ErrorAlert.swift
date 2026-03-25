import SwiftUI

extension View {
    func errorAlert(_ error: Binding<String?>) -> some View {
        self.alert("Error", isPresented: .init(
            get: { error.wrappedValue != nil },
            set: { if !$0 { error.wrappedValue = nil } }
        )) {
            Button("OK") { error.wrappedValue = nil }
        } message: {
            Text(error.wrappedValue ?? "")
        }
    }
}
