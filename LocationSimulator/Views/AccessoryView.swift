//
//  AccessoryView.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI
import MapKit

struct AccessoryView: View {

    @ObservedObject var viewModel: AccessoryViewModel

    var currentLocationButton: some View {
        Button(action: viewModel.currentLocationPressed) {
            Image(currentLocationImageName())
                .offset(x: 0, y: -16)
                .foregroundColor(currentLocationColor())
        }
        .disabled(!viewModel.isCurrentLocationExists)
    }

    var transportationTypeSegment: some View {
        Segment(labels: viewModel.transportationLabels,
                selection: $viewModel.selectedType)
            .frame(maxWidth: 240)
            .disabled(!viewModel.isCurrentLocationExists)
    }

    var resetButton: some View {
        Button(action: viewModel.resetPressed) {
            Text("Reset")
                .frame(width: 60)
        }
        .disabled(!viewModel.isCurrentLocationExists)
    }

    var body: some View {
        HStack {
            currentLocationButton
            Spacer()
            transportationTypeSegment
            Spacer()
            resetButton
        }
        .padding(.top, -34)
    }

    // UI modifications

    private func currentLocationImageName() -> String {
        if viewModel.isAutoFocusEnabled {
            return "CurrentLocationAuto"
        }

        return "CurrentLocation"
    }

    private func currentLocationColor() -> Color {
        if viewModel.isCurrentLocationExists {
            return Color("TintColor")
        }

        return .gray
    }

}

// MARK: - Preview

struct AccessoryView_Previews: PreviewProvider {
    static var previews: some View {
        AccessoryView(viewModel: .init(Location()))
    }
}
