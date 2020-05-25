//
//  Segment.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/24.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

struct Segment: NSViewRepresentable {

    var labels: [String]

    @Binding var selection: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSSegmentedControl {
        let control = NSSegmentedControl(
            labels: labels,
            trackingMode: .selectOne,
            target: context.coordinator,
            action: #selector(Coordinator.segmentDidChanged(_:))
        )
        control.segmentStyle = .texturedSquare
        control.selectedSegment = 0
        return control
    }

    func updateNSView(_ nsView: NSSegmentedControl, context: Context) {

    }

    class Coordinator {

        let parent: Segment

        init(_ parent: Segment) {
            self.parent = parent
        }

        @objc func segmentDidChanged(_ control: NSSegmentedControl) {
            parent.selection = control.selectedSegment
        }

    }

}

// MARK: - Preview

struct Segment_Previews: PreviewProvider {
    static var previews: some View {
        Segment(labels: ["Segment1", "Segment2"], selection: .constant(0))
    }
}
