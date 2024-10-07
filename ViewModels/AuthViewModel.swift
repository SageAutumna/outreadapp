//
//  AuthViewModel.swift
//  Outread
//
//  Created by iosware on 28/08/2024.
//

import SwiftUI
import Combine
import Supabase
import Dependencies

typealias AuthCompletion = (Bool) -> Void

@MainActor
class AuthViewModel: ObservableObject {
    @Dependency(\.authManager) var authManager
    @Dependency(\.dataManager) var dataManager
    @Preference(\.isPremiumUser) var isPremiumUser
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var rememberMe: Bool = false
    @Published var fullName = ""
    @Published var phone = ""
    @Published var city = ""
    @Published var state = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
//        updateAuthState()
    }
    
    private func setupObservers() {
//        authManager.objectWillChange
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                Task {
//                     await self?.updateAuthState()
//                }
//            }
//            .store(in: &cancellables)
    }
    
    private func updateAuthState() async {
        currentUser = authManager.currentUser
        if currentUser != nil {
            await checkUserRole()
        }
        isSignedIn = authManager.isSignedIn
        if isSignedIn {
            clearFields()
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        fullName = ""
        phone = ""
        city = ""
        state = ""
        errorMessage = nil
    }

    func checkAndRefreshSession() async {
        _ = await authManager.checkAndRefreshSession()
        await updateAuthState()
    }
    
    func signupWithValidation(completion: @escaping AuthCompletion) async {
        if validateAndSignup() {
            await signUp(completion: completion)
        } else {
            completion(false)
        }
    }
    
    func signUp(completion: @escaping AuthCompletion) async {
        isLoading = true
        do {
            try await authManager.signUp(email: email, password: password, fullName: fullName, phone: phone, city: city, state: state)
            await updateAuthState()
            completion(true)
        } catch {
            errorMessage = error.localizedDescription
            completion(false)
        }
        isLoading = false
    }
    
    func signinWithValidation(completion: @escaping AuthCompletion) async {
        isLoading = true
        if validateAndSignin() {
            await signIn(completion: completion)
        } else {
            completion(false)
        }
        isLoading = false
    }
    
    func signIn(completion: @escaping AuthCompletion) async {
        isLoading = true
        do {
            try await authManager.signIn(email: email, password: password)
            await updateAuthState()
            completion(true)
        } catch {
            errorMessage = error.localizedDescription
            completion(false)
        }
        isLoading = false
    }
    
    func signInWithGoogle(presentingViewController: UIViewController) async {
        isLoading = true
        do {
            try await authManager.signInWithGoogle(presentingViewController: presentingViewController)
            await updateAuthState()
            await authManager.handlePostSocialLogin()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
        
    func signInWithApple() async {
        isLoading = true
        let signInResult = await authManager.signInWithApple()
        if signInResult {
            // Successfully signed in
            await updateAuthState()
            await authManager.handlePostSocialLogin()
        } else {
            // Handle sign-in failure
            debugPrint("Sign in with Apple failed")
        }
        isLoading = false
    }
    
    func signInWithFacebook(presentingViewController: UIViewController) async {
        do {
            try await authManager.signInWithFacebook(presentingViewController: presentingViewController)
            await updateAuthState()
            await authManager.handlePostSocialLogin()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword() async -> Bool {
        guard validateEmail() else {
            return false
        }

        isLoading = true

        let result = await authManager.resetPassword(email: email)
        
        if !result {
            errorMessage = "Password reset email sent. Please check your inbox."
        }
        isLoading = false
        return result
    }
    
    func signOut() async {
        await authManager.signOut()
        await updateAuthState()
    }
    
    func validateAndSignin() -> Bool {
        errorMessage = nil
        
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty"
            return false
        }
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            return false
        }
        
        return true
    }
    
    func validateEmail() -> Bool {
        errorMessage = nil
        
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty"
            return false
        }
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return false
        }
                
        return true
    }
    
    
    func validateAndSignup() -> Bool {
        errorMessage = nil

        guard !fullName.isEmpty else {
            errorMessage = "Full name cannot be empty"
            return false
        }

        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty"
            return false
        }
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return false
        }

        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            return false
        }
        
        guard !confirmPassword.isEmpty else {
            errorMessage = "Confirmation password cannot be empty"
            return false
        }
        guard confirmPassword == password else {
            errorMessage = "Passwords don't match"
            return false
        }
        
        return true
    }
    
    private func checkUserRole() async {
        if let id = currentUser?.id.uuidString {
            let role = await dataManager.checkUser(userId: id)
            if role {
                isPremiumUser = true
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
