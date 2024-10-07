//
//  AuthManager.swift
//  Outread
//
//  Created by iosware on 28/08/2024.
//

import Foundation
import Supabase
import Combine
import GoogleSignIn
import AuthenticationServices
//import FacebookLogin

//@MainActor
class AuthManager: NSObject, ObservableObject {
    @Published private(set) var session: Session?
    
    var currentUserId: String? {
        return session?.user.id.uuidString
    }
    
    var isSignedIn: Bool {
        session != nil
    }
    
    var currentUser: User? {
        session?.user
    }
    
    var name: String {
        if let anyJSON = currentUser?.userMetadata["full_name"] as? AnyJSON,
           let fullName = anyJSON.stringValue {
            return fullName
        } else {
            return currentUser?.email ?? ""
        }
    }
    
    var isSocialLogin: Bool {
        return session?.user.identities?.first(where: {$0.provider == "email"}) == nil
    }
    
    private var continuation: CheckedContinuation<Bool, Never>?
    private let supabase: SupabaseClient
    private var authStateChangesTask: Task<Void, Never>?
    
    override init() {
        self.supabase = SupabaseManager.shared.client
        super.init()
        setupAuthStateListener()
        Task {
            await checkAndRefreshSession()
        }
    }
    
    private func setupAuthStateListener() {
        authStateChangesTask = Task { [weak self] in
            guard let self = self else { return }
            for await (event, session) in self.supabase.auth.authStateChanges {
                guard [.initialSession, .signedIn, .signedOut].contains(event) else { continue }
                await MainActor.run {
                    self.session = session
                }
            }
        }
    }
    
    deinit {
        authStateChangesTask?.cancel()
    }
    
    func checkAndRefreshSession() async -> Bool {
        do {
            let currentSession = try await supabase.auth.session
            if currentSession.expiresAt + 60 < Date().timeIntervalSince1970 {
                let refreshedSession = try await supabase.auth.refreshSession()
                session = refreshedSession
            } else {
                session = currentSession
            }
            return true
        } catch {
            debugPrint("Error refreshing session: \(error)")
            session = nil
            return false
        }
    }
    
    func retrieveUser() async throws -> User {
        return try await supabase.auth.user()
    }
    
    func updateUser(email: String) async throws {
        try await supabase.auth.update(user: UserAttributes(email: email))
        if let updatedUser = try? await retrieveUser() {
            session?.user = updatedUser
        }
    }
    
    func signUp(email: String, password: String, fullName: String, phone: String, city: String, state: String) async throws {
        let signUpResult = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: [
                "full_name": .string(fullName),
                "phone": .string(phone),
                "city": .string(city),
                "state": .string(state)
            ]
        )
        if let user = signUpResult.session?.user {
            let newUser = AppUser(supabaseUser: user)//, fullName: fullName, phone: phone, state: state, city: city)
            do {
                try await supabase
                    .from("User")
                    .insert(newUser)
                    .execute()
            } catch {
                debugPrint("Error inserting supabase user: \(error)")
            }
        }
        session = signUpResult.session
    }
    
    func signIn(email: String, password: String) async throws {
        let newSession = try await supabase.auth.signIn(email: email, password: password)
        session = newSession
    }
    
    @MainActor
    func signInWithGoogle(presentingViewController: UIViewController) async throws {
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            throw AuthError.missingClientID
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingToken
        }
        
        let newSession = try await supabase.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken))
        session = newSession
    }
    
    func signInWithApple() async -> Bool {
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    func signInWithFacebook(presentingViewController: UIViewController) async throws {
//        let manager = LoginManager()        
//        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<LoginManagerLoginResult, Error>) in
//            //TODO: When Facebook app has business verified
//            //manager.logIn(permissions: ["public_profile", "email"], from: presentingViewController) { result, error in
//            manager.logIn(permissions: ["public_profile"], from: presentingViewController) { result, error in
//                if let error = error {
//                    continuation.resume(throwing: error)
//                } else if let result = result {
//                    continuation.resume(returning: result)
//                } else {
//                    continuation.resume(throwing: AuthError.cancelled)
//                }
//            }
//        }
//        
//        if result.isCancelled {
//            throw AuthError.cancelled
//        }
//        
////        guard let accessToken = result.token?.tokenString else {
////            throw AuthError.missingToken
////        }
//        guard let accessToken = AccessToken.current?.tokenString else {
//            throw AuthError.missingToken
//        }
//        
//        let newSession = try await supabase.auth.signInWithIdToken(credentials: OpenIDConnectCredentials(provider: .facebook, idToken: accessToken))
//        session = newSession
    }
    
    func resetPassword(email: String) async -> Bool {
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            return true
        } catch {
            debugPrint("Error changing password: \(error)")
            return false
        }
    }
    
    func changePassword(password: String) async -> Bool {
        do {
            try await supabase.auth.update(
                user: UserAttributes(
                    password: password
                )
            )
            return true
        } catch {
            debugPrint("Error changing password: \(error)")
            return false
        }
    }
    
    func signOut() async {
        try? await supabase.auth.signOut()
        session = nil
    }
    
    func handlePostSocialLogin() async {
        guard let user = currentUser else {
            return
        }
        if await checkUserExists(supabaseUserId: user.id.uuidString) == false {
            await createNewUser(from: user)
        }
    }
    
    private func checkUserExists(supabaseUserId: String) async -> Bool {
        do {
            let response = try await supabase
                .from("User")
                .select()
                .eq("supabaseUserId", value: supabaseUserId)
                .execute()
            
            return (response.count ?? 0 > 0)
        } catch {
            debugPrint("Error checkUserExists: \(error)")
            return false
        }
    }
    
    private func createNewUser(from supabaseUser: User) async {
        do {
            let newUser = AppUser(supabaseUser: supabaseUser)
            
            try await supabase
                .from("User")
                .insert(newUser)
                .execute()
        } catch {
            debugPrint("Error creating new user: \(error)")
        }
    }
    
    func deleteUser() async {
        guard let userId = currentUserId else { return }
        do {
            try await supabase
                .from("User")
                .update([ "isDeleted": true ])
                .eq("supabaseUserId", value: userId)
                .execute()
        } catch {
            debugPrint("Error deleting user: \(error)")
        }
    }
}

extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let identityTokenData = appleIDCredential.identityToken,
                  let identityTokenString = String(data: identityTokenData, encoding: .utf8) else {
                debugPrint("Unable to fetch identity token")
                return
            }

            Task {
                do {
                    let session = try await supabase.auth.signInWithIdToken(credentials:
                            .init(provider: .apple,
                                  idToken: identityTokenString))
                    await MainActor.run {
                        self.session = session
                        self.continuation?.resume(returning: true) // Success
                    }
                } catch {
                    debugPrint("Sign in with Apple failed: \(error)")
                    self.continuation?.resume(returning: false) // Failure
                }
            }
        } else {
            self.continuation?.resume(returning: false) // Failure
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        debugPrint("Authorization failed: \(error)")
        continuation?.resume(returning: false) // Failure
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Find the first active window scene
        guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return ASPresentationAnchor()
        }
        // Return the first window from the active window scene
        return windowScene.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

enum AuthError: Error {
    case missingClientID
    case missingToken
    case cancelled
}
