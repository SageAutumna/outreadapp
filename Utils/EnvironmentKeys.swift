//
//  EnvironmentKeys.swift
//  Outread
//
//  Created by iosware on 16/08/2024.
//

import SwiftUI

private struct NamespaceKey: EnvironmentKey {
    static var defaultValue: Namespace.ID? = nil
}

// Custom EnvironmentKey for GeometryProxy
private struct GeometryKey: EnvironmentKey {
    static let defaultValue: GeometryProxy? = nil
}

private struct NavigationBarHiddenKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct DataManagerKey: EnvironmentKey {
    static let defaultValue: DataManager = DataManager()
}

extension EnvironmentValues {
    var dataManager: DataManager {
        get { self[DataManagerKey.self] }
        set { self[DataManagerKey.self] = newValue }
    }

    var geometry: GeometryProxy? {
        get { self[GeometryKey.self] }
        set { self[GeometryKey.self] = newValue }
    }
    
    var navigationBarHidden: Bool {
        get { self[NavigationBarHiddenKey.self] }
        set { self[NavigationBarHiddenKey.self] = newValue }
    }
    
    var animationNamespace: Namespace.ID? {
        get { self[NamespaceKey.self] }
        set { self[NamespaceKey.self] = newValue }
    }
}
