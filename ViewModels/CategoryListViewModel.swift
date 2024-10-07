//
//  CategoryListViewModel.swift
//  Outread
//
//  Created by iosware on 30/08/2024.
//

import SwiftUI
import Combine
import Dependencies

class CategoryListViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Dependency(\.dataManager) var dataManager
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadCategories()
    }
    
    func loadCategories() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let fetchedCategories = dataManager.fetchAllCategories()
            
            DispatchQueue.main.async {
                self.categories = fetchedCategories
                self.isLoading = false
            }
        }
    }
}
