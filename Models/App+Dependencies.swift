//
//  DependencyValues.swift
//  Outread
//
//  Created by iosware on 31/08/2024.
//

import Dependencies

extension DependencyValues {
    var dataManager: DataManager {
        get { self[DataManager.self] }
        set { self[DataManager.self] = newValue }
    }

    var syncManager: SyncManager {
        get { self[SyncManager.self] }
        set { self[SyncManager.self] = newValue }
    }
    
    var authManager: AuthManager {
        get { self[AuthManager.self] }
        set { self[AuthManager.self] = newValue }
    }
    
//    var authViewModel: AuthViewModel {
//        get { self[AuthViewModel.self] }
//        set { self[AuthViewModel.self] = newValue }
//    }
}

extension AuthManager: DependencyKey {
  public static let liveValue: AuthManager = AuthManager()
}

extension DataManager: DependencyKey {
  public static let liveValue: DataManager = DataManager()
}

extension SyncManager: DependencyKey {
  public static let liveValue: SyncManager = SyncManager()
}

//extension AuthViewModel: DependencyKey {
//  public static let liveValue: AuthViewModel = AuthViewModel()
//}

//extension RestApi: DependencyKey {
//  public static var liveValue: RestApi {
//    @Dependency(\.buildConfiguration) var buildConfiguration
//    @Dependency(\.accessTokenProvider) var accessTokenProvider
//    return RestApi(baseURL: buildConfiguration.apiBaseURL, accessTokenSource: accessTokenProvider)
//  }
//}
