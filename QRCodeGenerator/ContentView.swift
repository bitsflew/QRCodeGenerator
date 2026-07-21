//
//  ContentView.swift
//  QRCodeGenerator
//
//  Created by Henk on 17/07/2026.
//

import AppKit
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var urlText = ""
    @State private var qrCodeImage: NSImage?
    @State private var didCopyQRCode = false
    @State private var correctionLevel = QRCodeCorrectionLevel.medium

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    private var trimmedURLText: String {
        urlText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isValidURL: Bool {
        guard let url = URL(string: trimmedURLText),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host() != nil else {
            return false
        }

        return true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("URL")
                .font(.headline)

            TextField("https://example.com", text: $urlText)
                .textFieldStyle(.roundedBorder)
                .onChange(of: urlText) { _, newValue in
                    urlText = newValue.filter { !$0.isWhitespace }
                    qrCodeImage = nil
                    didCopyQRCode = false
                }

            if !urlText.isEmpty && !isValidURL {
                Text("Enter a valid http or https URL.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Picker("Error Correction", selection: $correctionLevel) {
                ForEach(QRCodeCorrectionLevel.allCases, id: \.self) { level in
                    Text(level.title).tag(level)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: correctionLevel) { _, _ in
                regenerateQRCode()
            }

            HStack {
                Button("Create QR Code") {
                    regenerateQRCode()
                }
                .disabled(!isValidURL)

                Button {
                    copyQRCode()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .accessibilityLabel("Copy QR Code")
                .disabled(qrCodeImage == nil)

                Button {
                    shareQRCode()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share QR Code")
                .disabled(qrCodeImage == nil)
            }

            if didCopyQRCode {
                Text("QR code copied.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let qrCodeImage {
                Image(nsImage: qrCodeImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .accessibilityLabel("QR code for \(trimmedURLText)")
            }
        }
        .padding()
    }

    private func regenerateQRCode() {
        didCopyQRCode = false

        guard isValidURL else {
            qrCodeImage = nil
            return
        }

        qrCodeImage = makeQRCode(from: trimmedURLText)
    }

    private func makeQRCode(from text: String) -> NSImage? {
        filter.message = Data(text.utf8)
        filter.correctionLevel = correctionLevel.rawValue

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 12, y: 12))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: NSSize(width: 220, height: 220))
    }

    private func copyQRCode() {
        guard let qrCodeImage else {
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([qrCodeImage])
        didCopyQRCode = true
    }

    private func shareQRCode() {
        guard let qrCodeImage,
              let contentView = NSApplication.shared.keyWindow?.contentView ?? NSApplication.shared.windows.first?.contentView else {
            return
        }

        let picker = NSSharingServicePicker(items: [qrCodeImage])
        picker.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .minY)
    }
}

private enum QRCodeCorrectionLevel: String, CaseIterable {
    case low = "L"
    case medium = "M"
    case quartile = "Q"
    case high = "H"

    var title: LocalizedStringKey {
        switch self {
        case .low:
            return "Low (7%)"
        case .medium:
            return "Medium (15%)"
        case .quartile:
            return "Quartile (25%)"
        case .high:
            return "High (30%)"
        }
    }
}

#Preview {
    ContentView()
}
