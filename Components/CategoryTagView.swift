//
//  CategoryTagView.swift
//  Outread
//
//  Created by iosware on 15/08/2024.
//

import SwiftUI

struct CategoryTagView: View {
    let category: Category
    @Binding var selectedCategoryId: String?
    
    var body: some View {
        Text(category.name)
            .font(.customFont(font: .poppins, style: .medium, size: .s14))
            .padding(10)
            .background(selectedCategoryId ?? "0" == category.id ? Color(.select) : .clear)
            .foregroundColor(Color(.white100))
            .cornerRadius(8)
            .id(category.id)
    }
}

#Preview {
    CategoryTagView(category: TempData.shared.categories[0], selectedCategoryId: .constant("1"))
}
