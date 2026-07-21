//
//  CorrectionLevelPickerView.swift
//  QRCodeGenerator
//

import SwiftUI

struct CorrectionLevelPickerView: View {
    @Binding var correctionLevel: QRCodeCorrectionLevel
    let onCorrectionLevelChanged: () -> Void

    var body: some View {
        Picker("Error Correction", selection: $correctionLevel) {
            ForEach(QRCodeCorrectionLevel.allCases, id: \.self) { level in
                Text(level.title).tag(level)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: correctionLevel) { _, _ in
            onCorrectionLevelChanged()
        }
    }
}

#Preview {
    @Previewable @State var correctionLevel = QRCodeCorrectionLevel.medium

    CorrectionLevelPickerView(correctionLevel: $correctionLevel) {}
        .padding()
}
