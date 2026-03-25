import SwiftUI

struct OnboardingChecklist: View {
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Getting Started")
                .font(.headline)

            if let status = viewModel.onboarding {
                ChecklistRow(title: "Complete your profile", done: status.profileComplete)
                ChecklistRow(title: "Set up payout details", done: status.payoutComplete)
                ChecklistRow(title: "Create your first listing", done: status.firstListing)

                if status.allComplete {
                    Label("You're all set!", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.callout)
                }
            } else {
                ProgressView()
            }
        }
        .padding()
        .task { await viewModel.loadOnboarding() }
    }
}

struct ChecklistRow: View {
    let title: String
    let done: Bool

    var body: some View {
        HStack {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : .secondary)
            Text(title)
                .strikethrough(done)
                .foregroundStyle(done ? .secondary : .primary)
        }
    }
}
