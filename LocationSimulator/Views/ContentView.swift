//
//  ContentView.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: ContentViewModel

    @State var angle: Angle = .zero

    var headingButton: some View {
        Image("Circle")
            .frame(width: 54, height: 54)
            .shadow(radius: 1, x: 0, y: 0.5)
            .rotationEffect(angle, anchor: .center)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged(headingPressed)
            )
    }

    var moveButton: some View {
        RoundedRectangle(cornerRadius: 14)
            .foregroundColor(self.viewModel.isAutoMoveEnabled ? .blue : Color("CircleBackground"))
            .overlay(
                Image(self.viewModel.transportationImage)
                    .frame(width: 21, height: 21)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(self.viewModel.isAutoMoveEnabled ? .white : Color("TintColor"))
            )
            .frame(width: 28, height: 28)
            .shadow(radius: 1, x: 0, y: 0.5)
            .offset(x: -0.5, y: -0.5)
            .onTapGesture(perform: self.viewModel.movePressed)
            .onLongPressGesture(minimumDuration: 0.75, perform: self.viewModel.moveLongPresed)
    }

    var body: some View {
        ZStack {
            MapView(location: viewModel.location)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    GeometryReader { proxy in
                        ZStack(alignment: .center) {
                            self.headingButton
                            self.moveButton
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomLeading)
                        .opacity(self.viewModel.isCurrentLocationExists ? 1 : 0)
                        .offset(x: 16, y: -70)
                    }
                )

            if viewModel.showIntroduction {
                IntroductionView(viewModel: .init(viewModel.location))
            }
        }
    }

    // MARK: - Actions

    private func headingPressed(_ value: DragGesture.Value) {
        let locationX = value.location.x - 27 /* as (headingButton.width / 2) */
        let locationY = value.location.y - 27 /* as (headingButton.width / 2) */
        self.angle = Angle(radians: Double(atan2(locationX, -locationY)))

        self.viewModel.radians = self.angle.radians
    }

}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(Location()))
    }
}
