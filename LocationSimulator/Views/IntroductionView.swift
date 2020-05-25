//
//  IntroductionView.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

struct IntroductionView : View {

    @ObservedObject var viewModel: IntroductionViewModel

    var overlay: some View {
        Rectangle()
            .foregroundColor(.black)
            .opacity(0.3)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(true)
    }

    var guidance: some View {
        GeometryReader { proxy in
            VStack {
                Spacer()
                VStack {
                    Image("Connect")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)

                    Text("Connect the device to the Mac\nand tap the Start button.")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: self.viewModel.startPressed) {
                        Text("Start")
                    }
                    .padding()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                Spacer()
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
        }
    }

    var body: some View {
        ZStack {
            overlay

            guidance
        }
        .alert(item: $viewModel.alert, content: self.alert(errorAlert:))
    }

    // MARK: - UI modifications

    private func alert(errorAlert: ErrorAlert) -> Alert {
        return Alert(title: Text(errorAlert.title),
                     message: Text(errorAlert.message),
                     dismissButton: .default(Text("Close")))
    }

}
