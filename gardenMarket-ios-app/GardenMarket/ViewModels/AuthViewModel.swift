import Foundation
import Observation

@Observable
final class AuthViewModel {
    var currentUser: User?
    var isAuthenticated = false
    var isLoading = false
    var error: String?

    private let authService = AuthService()

    init() {
        if KeychainService.shared.accessToken != nil {
            isAuthenticated = true
            Task { await restoreSession() }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            currentUser = try await authService.login(email: email, password: password)
            isAuthenticated = true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func register(email: String, password: String, role: String) async {
        isLoading = true
        error = nil
        do {
            currentUser = try await authService.register(email: email, password: password, role: role)
            isAuthenticated = true
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        authService.logout()
        currentUser = nil
        isAuthenticated = false
    }

    func restoreSession() async {
        do {
            currentUser = try await authService.fetchCurrentUser()
            isAuthenticated = true
        } catch {
            logout()
        }
    }

    func refreshUser() async {
        do {
            currentUser = try await authService.fetchCurrentUser()
        } catch {
            // ignore refresh failures
        }
    }
}
