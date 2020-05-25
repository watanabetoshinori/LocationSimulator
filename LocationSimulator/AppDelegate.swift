//
//  AppDelegate.swift
//  LocationSimulator
//
//  Created by Watanabe Toshinori on 2020/05/22.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let location = Location()

        // Create the SwiftUI view that provides the title bar accessory contents.
        let accessoryHostingView = NSHostingView(rootView: AccessoryView(viewModel: .init(location)))
        accessoryHostingView.frame.size = accessoryHostingView.fittingSize

        let titlebarAccessoryViewController = NSTitlebarAccessoryViewController()
        titlebarAccessoryViewController.view = accessoryHostingView
        titlebarAccessoryViewController.layoutAttribute = .top

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(viewModel: .init(location))

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 480),
            styleMask: [.titled,
                        .closable,
                        .miniaturizable,
                        .resizable,
                        .fullSizeContentView,
                        .unifiedTitleAndToolbar],
            backing: .buffered, defer: false)
        window.title = "Location Simulator"
        window.titleVisibility = .hidden
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.toolbar = NSToolbar()
        window.addTitlebarAccessoryViewController(titlebarAccessoryViewController)
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
