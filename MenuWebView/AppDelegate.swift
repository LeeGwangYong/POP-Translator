//
//  AppDelegate.swift
//  MenuWebView
//
//  Created by United Merchant Services.inc on 1/17/19.
//  Copyright © 2019 GY. All rights reserved.
//

import Cocoa
import ServiceManagement



@NSApplicationMain


class AppDelegate: NSObject, NSApplicationDelegate {
    var eventMonitor: EventMonitor?
    
    func acquirePrivileges() -> Bool {
        let accessEnabled = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
        if accessEnabled != true {
            print("You need to enable the keylogger in the System Prefrences")
        }
        return accessEnabled == true;
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        acquirePrivileges()
        
        let _ = PopOverManageController.shared
        NSApp.setActivationPolicy(.prohibited)
        
        let launchAtLogIn = NSWorkspace.shared.runningApplications.contains{ $0.bundleIdentifier == Bundle.launchHelperBundleIdentifier }

        if launchAtLogIn {
            DistributedNotificationCenter.default().postNotificationName(.killMe,
                                                                         object: Bundle.main.bundleIdentifier,
                                                                         userInfo: nil,
                                                                         deliverImmediately: true)
        }
        
        eventMonitor = EventMonitor(mask: .keyDown) { (event) in
            guard let event = event else { return }
            
            switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
            case [.control, .command] where event.keyCode == 0x11:
                    PopOverManageController.shared.togglePopover(nil)
            default:
                break
            }
        }

        eventMonitor?.start()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}



extension Bundle {
    static var launchHelperBundleIdentifier: String {
        return "com.gy.AutoLaunchHelper"
    }
}

extension NSNotification.Name {
    static var killMe: NSNotification.Name {
        return NSNotification.Name("KILLME")
    }
}
