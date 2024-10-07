//
//  ChangePasswodViewModel.swift
//  Outread
//
//  Created by iosware on 06/09/2024.
//

import SwiftUI
import Combine
import Supabase
import Dependencies

@MainActor
class ChangePasswodViewModel: ObservableObject {
    @Dependency(\.authManager) var authManager
    
    @Published var isSignedIn: Bool = false
    @Published var currentUser: User?
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        authManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAuthState()
            }
            .store(in: &cancellables)
    }
    
    private func updateAuthState() {
        isSignedIn = authManager.isSignedIn
        currentUser = authManager.currentUser
        if isSignedIn {
            clearFields()
        }
    }
    
    private func clearFields() {
        password = ""
        confirmPassword = ""
        errorMessage = nil
    }

    func checkAndRefreshSession() async {
        _ = await authManager.checkAndRefreshSession()
        updateAuthState()
    }
    
    func changePasswordWithValidation(completion: @escaping AuthCompletion) async {
        if validate() {
            await changePassword(completion: completion)
        } else {
            completion(false)
        }
    }
    
    private func changePassword(completion: @escaping AuthCompletion) async {
        isLoading = true
        _ = await authManager.changePassword(password: password)
        completion(true)
        isLoading = false
    }
    

    func validate() -> Bool {
        errorMessage = nil
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            return false
        }
        guard !confirmPassword.isEmpty && confirmPassword == password else {
            errorMessage = "Passwords don't match"
            return false
        }
        return true
    }
}
