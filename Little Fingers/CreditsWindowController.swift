//
//  CreditsWindowController.swift
//  Little Fingers
//
//  Created by Sergej Görzen on 10/10/26.
//

import Cocoa

class CreditsWindowController: NSWindowController {

	let contributors = [
		(name: "Shaun Inman",
		 role: "Original author, versions up to 1.1",
		 url: "https://github.com/shauninman"),
		(name: "Dr.-Ing. Sergej Görzen",
		 role: "Version 1.2",
		 url: "https://github.com/SGoerzen"),
	]

	convenience init() {
		let panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 300, height: 100),
		                    styleMask: [.titled, .closable],
		                    backing: .buffered,
		                    defer: false)
		panel.title = "Credits"
		panel.hidesOnDeactivate = true
		panel.isReleasedWhenClosed = false
		self.init(window: panel)
		buildContent()
		panel.center()
	}

	func buildContent() {
		let stack = NSStackView()
		stack.orientation = .vertical
		stack.alignment = .leading
		stack.spacing = 16
		stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
		stack.translatesAutoresizingMaskIntoConstraints = false

		for contributor in contributors {
			let name = NSTextField(labelWithString: contributor.name)
			name.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)

			let role = NSTextField(labelWithString: contributor.role)
			role.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
			role.textColor = .secondaryLabelColor

			// selectable label with a link attribute, so the link is clickable
			let link = NSTextField(labelWithAttributedString: NSAttributedString(
				string: contributor.url.replacingOccurrences(of: "https://", with: ""),
				attributes: [.link: URL(string: contributor.url)!,
				             .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)]))
			link.isSelectable = true
			link.allowsEditingTextAttributes = true

			let entry = NSStackView(views: [name, role, link])
			entry.orientation = .vertical
			entry.alignment = .leading
			entry.spacing = 2
			stack.addArrangedSubview(entry)
		}

		let contentView = window!.contentView!
		contentView.addSubview(stack)
		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: contentView.topAnchor),
			stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			stack.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
		])
	}
}
