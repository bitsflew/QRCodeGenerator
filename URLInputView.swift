//
//  URLInputView.swift
//  QRCodeGenerator
//

import SwiftUI

struct URLInputView: View {
    @Binding var urlText: String
    let isValidURL: Bool
    let onURLChanged: () -> Void

    var body: some View {
        Text("URL")
            .font(.headline)

        TextField("https://example.com", text: $urlText)
            .textFieldStyle(.roundedBorder)
            .onChange(of: urlText) { _, newValue in
                urlText = newValue.filter { !$0.isWhitespace }
                onURLChanged()
            }

        if !urlText.isEmpty && !isValidURL {
            Text("Enter a valid http or https URL.")
                .font(.caption)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    @Previewable @State var urlText = "https://example.com"

    URLInputView(urlText: $urlText, isValidURL: true) {}
        .padding()
}
