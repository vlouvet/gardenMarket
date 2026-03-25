import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 8) {
                    Text("GardenMarket")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.accentColor)

                    Text("Fresh from local growers")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("Sign In") {
                TextField("Email", text: $email)
                    .focused($focusedField, equals: .email)
                    .textContentType(.emailAddress)
                    #if os(iOS)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    #endif
                    .onSubmit { focusedField = .password }

                SecureField("Password", text: $password)
                    .focused($focusedField, equals: .password)
                    .textContentType(.password)
                    .onSubmit {
                        if !email.isEmpty && !password.isEmpty {
                            Task { await authVM.login(email: email, password: password) }
                        }
                    }
            }

            if let error = authVM.error {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await authVM.login(email: email, password: password) }
                } label: {
                    if authVM.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)

                Button("Create an account") {
                    showRegister = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .formStyle(.grouped)
        .onAppear { focusedField = .email }
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }
}
