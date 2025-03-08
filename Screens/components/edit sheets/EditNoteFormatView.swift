//
//  NoteTypeListView.swift
//  HR Notes
//
//  Created by Theo Koester on 9/20/24.
//
import SwiftUI

struct EditNoteFormatView: View {
    @Binding var selectedFormats: [String]
    @Environment(\.presentationMode) var presentationMode
    @State private var expandedSection: NoteCategory? = nil
    @State private var selectedFormatsSet: Set<String>
    @State private var showingCustomInput = false
    @State private var customInputCategory: NoteCategory? = nil
    @State private var customInput = ""
    
    init(selectedFormats: Binding<[String]>) {
        self._selectedFormats = selectedFormats
        self._selectedFormatsSet = State(initialValue: Set(selectedFormats.wrappedValue))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Selected formats preview
                if !selectedFormatsSet.isEmpty {
                    HStack {
                        Text("Selected: ")
                            .foregroundColor(.secondary)
                        Text(selectedFormatsSet.joined(separator: ", "))
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                }
                
                List {
                    ForEach(NoteCategory.allCases, id: \.self) { category in
                        Section {
                            CategoryRowView(
                                category: category,
                                isExpanded: expandedSection == category,
                                onToggle: { toggleSection(category) }
                            )
                            
                            if expandedSection == category {
                                ForEach(categoryItems(for: category), id: \.self) { item in
                                    ItemRowView(
                                        title: item.rawValue,
                                        isSelected: selectedFormatsSet.contains(item.rawValue),
                                        action: { toggleItem(item.rawValue) }
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
                                        Text("Add Custom Format")
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
                                TextField("Enter custom format", text: $customInput)
                            } footer: {
                                Text("Add a custom format to the \(customInputCategory?.rawValue ?? "") category")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .navigationTitle("Custom Format")
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
                                        toggleItem(customInput)
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
            .navigationTitle("Note Format")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedFormats = Array(selectedFormatsSet)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // Helper methods
    private func toggleSection(_ category: NoteCategory) {
        withAnimation {
            expandedSection = expandedSection == category ? nil : category
        }
    }
    
    private func toggleItem(_ item: String) {
        if selectedFormatsSet.contains(item) {
            selectedFormatsSet.remove(item)
        } else {
            selectedFormatsSet.insert(item)
        }
    }
    
    private func categoryItems(for category: NoteCategory) -> [NoteType] {
        switch category {
        case .business:
            return NoteType.businessRelated()
        case .education:
            return NoteType.educationRelated()
        case .personal:
            return NoteType.personalRelated()
        case .general:
            return NoteType.generalRelated()
        }
    }
}

// Local components
private struct CategoryRowView: View {
    let category: NoteCategory
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(category.rawValue)
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
    EditNoteFormatView(selectedFormats: .constant([]))
}
