//
//  SelectableTextView.swift
//  NoteBot
//
//  Created by Theo Koester on 10/3/24.
//

import SwiftUI
import UIKit

struct SelectableTextView: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.text = text
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textColor = UIColor.label
        textView.isSelectable = true
        textView.translatesAutoresizingMaskIntoConstraints = false  // Allow auto layout
        textView.textContainer.lineBreakMode = .byWordWrapping  // Ensure text wraps
        textView.textContainerInset = .zero  // Adjust for cleaner look
        textView.textContainer.lineFragmentPadding = 0  // Remove padding inside text container
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}

#Preview {
    SelectableTextView(text: "Test Text goes here")
}
