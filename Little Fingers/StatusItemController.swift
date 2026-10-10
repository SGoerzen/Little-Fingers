//
//  StatusItemController.swift
//  Little Fingers
//
//  Created by Shaun Inman on 2/3/17.
//  Copyright © 2017 Shaun Inman. All rights reserved.
//

import Cocoa

class StatusItemController: NSObject {
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
	var isAccessibilityEnabled = false
	var accessibilityTimer:Timer?
	var dimWindows:[NSWindow] = []
	
	let aboutWindowController = AboutWindowController(windowNibName: "AboutWindow")
	let creditsWindowController = CreditsWindowController()
	
	override init() {
		super.init()
		
		checkAccessibility()
		
		buildMenu()
		
		if let button = statusItem.button {
			if let image = NSImage(named: "off") {
				image.isTemplate = true
				button.image = image
			}
		}
		
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(lockChanged),
		                                       name: NSNotification.Name(rawValue: SINotificationLockChanged),
		                                       object: nil)
	}
	
	func checkAccessibility() {
		isAccessibilityEnabled = TapController.isAccessibilityEnabled()
		if isAccessibilityEnabled {
			// delay allows about window to be repsonsive on launch, not sure why...
			Timer.scheduledTimer(timeInterval: 0.1,
			                     target: self,
			                     selector: #selector(showAbout),
			                     userInfo: nil,
			                     repeats: false)
		}
		else {
			showSecurityPrivacy()
		}
		accessibilityTimer = Timer.scheduledTimer(timeInterval: 0.5,
		                                          target: self,
		                                          selector: #selector(updateAccessibility),
		                                          userInfo: nil,
		                                          repeats: true)
	}
	
	@objc func updateAccessibility() {
		let wasAccessibilityEnabled = isAccessibilityEnabled
		isAccessibilityEnabled = TapController.isAccessibilityEnabled()
		if isAccessibilityEnabled {
			accessibilityTimer?.invalidate()
			if !wasAccessibilityEnabled {
				restartApp()
			}
		}
	}
	
	func restartApp() {
		// TODO: also quit System Preferences since they lose focus on restart?
		let url = URL(fileURLWithPath: Bundle.main.resourcePath!)
		let path = url.deletingLastPathComponent().deletingLastPathComponent().absoluteString
		let task = Process()
		task.launchPath = "/usr/bin/open"
		task.arguments = [path]
		task.launch()
		NSApp.terminate(self)
	}
	
	func buildMenu() {
		let menu = NSMenu()
		menu.delegate = self
		
		let item = NSMenuItem()
		item.title = "About Little Fingers"
		item.action = #selector(showAbout)
		item.target = self
		menu.addItem(item)
		
		let creditsItem = NSMenuItem(title: "Credits…", action: #selector(showCredits), keyEquivalent: "")
		creditsItem.target = self
		menu.addItem(creditsItem)
		
		menu.addItem(NSMenuItem.separator())
		
		menu.addItem(NSMenuItem(title: "Quit Little Fingers", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
		
		statusItem.menu = menu
	}
	
	func showSecurityPrivacy() {
		// shows the system's accessibility prompt, which links to System Settings
		let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
		AXIsProcessTrustedWithOptions(options)
	}
	
	@objc func showAbout() {
		NSApp.activate(ignoringOtherApps: true)
		aboutWindowController.showWindow(NSApp.delegate)
	}
	
	@objc func showCredits() {
		NSApp.activate(ignoringOtherApps: true)
		creditsWindowController.showWindow(nil)
	}
	
	@objc func lockChanged() {
		updateIcon()
		updateDim()
	}
	
	func updateDim() {
		if TapController.isLocked() && UserDefaults.standard.bool(forKey: "dimWhenLocked") {
			showDim()
		}
		else {
			hideDim()
		}
	}
	
	// covers every screen (menu bar included) in black, e.g. for cleaning the display
	func showDim() {
		if !dimWindows.isEmpty {
			return
		}
		for screen in NSScreen.screens {
			let window = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
			window.backgroundColor = .black
			window.isOpaque = false
			window.alphaValue = 0
			window.level = .screenSaver
			window.ignoresMouseEvents = true
			window.canHide = false
			window.isReleasedWhenClosed = false
			window.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary]
			window.setFrame(screen.frame, display: false)
			window.orderFrontRegardless()
			dimWindows.append(window)
		}
		// the cursor can only be hidden while the app is active
		NSApp.activate(ignoringOtherApps: true)
		NSCursor.hide()
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.3
			for window in dimWindows {
				window.animator().alphaValue = 1
			}
		}, completionHandler: nil)
	}
	
	func hideDim() {
		if dimWindows.isEmpty {
			return
		}
		let windows = dimWindows
		dimWindows = []
		NSCursor.unhide()
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.3
			for window in windows {
				window.animator().alphaValue = 0
			}
		}, completionHandler: {
			for window in windows {
				window.orderOut(nil)
			}
			(NSApp.delegate as! AppDelegate).hideApp()
		})
	}
	
	@objc func updateIcon() {
		if let button = statusItem.button {
			if TapController.isLocked() {
				if let image = NSImage(named: "on") {
					image.isTemplate = true
					button.image = image
				}
			}
			else {
				if let image = NSImage(named: "off") {
					image.isTemplate = true
					button.image = image
				}
			}
		}
	}
}

extension StatusItemController : NSMenuDelegate {
	func menuWillOpen(_ menu: NSMenu) {
		(NSApp.delegate as! AppDelegate).hideWindows()
	}
	
	func menuDidClose(_ menu: NSMenu) {
		Timer.scheduledTimer(timeInterval: 0,
		                     target: NSApp.delegate as! AppDelegate,
		                     selector: #selector(AppDelegate.hideApp),
		                     userInfo: nil,
		                     repeats: false)
	}
}
