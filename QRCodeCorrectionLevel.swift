//
//  QRCodeCorrectionLevel.swift
//  QRCodeGenerator
//

import SwiftUI

enum QRCodeCorrectionLevel: String, CaseIterable {
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
