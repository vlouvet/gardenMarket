import Foundation
import Observation

@Observable
final class ProfileViewModel {
    var profile: Profile?
    var onboarding: OnboardingStatus?
    var isLoading = false
    var error: String?
    var successMessage: String?

    private let service = ProfileService()

    func loadProfile() async {
        isLoading = true
        error = nil
        do {
            profile = try await service.getProfile()
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func saveProfile(_ update: ProfileUpdate) async {
        isLoading = true
        error = nil
        do {
            profile = try await service.updateProfile(update)
            successMessage = "Profile updated."
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func upgrade() async -> User? {
        isLoading = true
        error = nil
        do {
            let user = try await service.upgrade()
            isLoading = false
            return user
        } catch let err as APIError {
            error = err.errorDescription
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
        return nil
    }

    func loadOnboarding() async {
        do {
            onboarding = try await service.getOnboardingStatus()
        } catch {
            // non-critical
        }
    }
}
