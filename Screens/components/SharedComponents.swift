import SwiftUI

// Shared view components
struct MetadataRowView: View {
    let icon: String
    let title: String
    let value: String
    var showChevron: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .font(.system(size: 22))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .medium))
                Text(value)
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
    }
} 
