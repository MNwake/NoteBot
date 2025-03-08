//
//  CallTypePickerView.swift
//  HR Notes
//
//  Created by Theo Koester on 9/14/24.
//

import SwiftUI

// Category wrapper to handle different enum types
private enum Category: Equatable {
    case business(BusinessCategory.Type)
    case education(EducationCategory.Type)
    case personal(PersonalCategory.Type)
    case general(GeneralCategory.Type)
    
    var title: String {
        switch self {
        case .business: return "Business"
        case .education: return "Education"
        case .personal: return "Personal"
        case .general: return "General"
        }
    }
    
    var items: [String] {
        switch self {
        case .business:
            return BusinessCategory.allCases.map { $0.rawValue }
        case .education:
            return EducationCategory.allCases.map { $0.rawValue }
        case .personal:
            return PersonalCategory.allCases.map { $0.rawValue }
        case .general:
            return GeneralCategory.allCases.map { $0.rawValue }
        }
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        switch (lhs, rhs) {
        case (.business, .business): return true
        case (.education, .education): return true
        case (.personal, .personal): return true
        case (.general, .general): return true
        default: return false
        }
    }
}

struct EditCallTypeView: View {
    @Binding var selectedCallType: String
    @Environment(\.presentationMode) var presentationMode
    @State private var expandedSection: Category? = nil
    @State private var showingCustomInput = false
    @State private var customInputCategory: Category? = nil
    @State private var customInput = ""
    
    // Available categories
    private let categories = [
        Category.business(BusinessCategory.self),
        Category.education(EducationCategory.self),
        Category.personal(PersonalCategory.self),
        Category.general(GeneralCategory.self)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Selected preview
                selectedPreviewSection
                
                // Categories list
                categoriesList
            }
            .navigationTitle("Audio Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var selectedPreviewSection: some View {
        Group {
            if !selectedCallType.isEmpty {
                HStack {
                    Text("Selected: ")
                        .foregroundColor(.secondary)
                    Text(selectedCallType)
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
            }
        }
    }
    
    private var categoriesList: some View {
        List {
            ForEach(categories, id: \.title) { category in
                Section {
                    CategoryRowView(
                        title: category.title,
                        isExpanded: expandedSection == category,
                        onToggle: { toggleSection(category) }
                    )
                    
                    if expandedSection == category {
                        ForEach(category.items, id: \.self) { item in
                            ItemRowView(
                                title: item,
                                isSelected: isSelected(item),
                                action: { selectItem(item) }
                            )
                        }
                        
                        // Custom input option
                        Button(action: {
                            customInputCategory = category
                            showingCustomInput = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                                Text("Add Custom Option")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .sheet(isPresented: $showingCustomInput) {
            NavigationView {
                Form {
                    Section {
                        TextField("Enter custom option", text: $customInput)
                    } footer: {
                        Text("Add a custom option to the \(customInputCategory?.title ?? "") category")
                            .foregroundColor(.secondary)
                    }
                }
                .navigationTitle("Custom Option")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingCustomInput = false
                            customInput = ""
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Add") {
                            if !customInput.isEmpty {
                                selectItem(customInput)
                            }
                            showingCustomInput = false
                            customInput = ""
                        }
                        .fontWeight(.semibold)
                        .disabled(customInput.isEmpty)
                    }
                }
            }
        }
    }
    
    // Helper methods
    private func toggleSection(_ category: Category) {
        withAnimation {
            expandedSection = expandedSection == category ? nil : category
        }
    }
    
    private func isSelected(_ item: String) -> Bool {
        return selectedCallType == item
    }
    
    private func selectItem(_ item: String) {
        selectedCallType = item
        presentationMode.wrappedValue.dismiss()
    }
}

// Local components
private struct CategoryRowView: View {
    let title: String
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .foregroundColor(.primary)
    }
}

private struct ItemRowView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

#Preview {
    EditCallTypeView(selectedCallType: .constant(""))
}

