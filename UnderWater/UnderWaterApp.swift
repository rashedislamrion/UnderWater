//
//  UnderWaterApp.swift
//  UnderWater
//
//  Created by rashed islam  on 15/2/26.
//

import SwiftUI

@main
struct UnderWaterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1000, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Project...") {
                    // Trigger open project
                    // Since AppState is in environment, we might need a way to reach it or 
                    // ideally commands should be handled where the state is available or via focus.
                    // However, we can't easily access EnvironmentObject here in App struct top level easily 
                    // for global commands without a bit of work or using a singleton/notification.
                    // A common SwiftUI pattern for this is to use focus or handle it in the ContentView 
                    // via .commands logic if possible, or just let the button in UI do it for now.
                    // But the requirement says "trigger open project".
                    // Let's use the standard approach: 
                    // We can't easily acccess appState here. 
                    // WORKAROUND: Send a notification or Use a selector if NSApp.
                    // For simplicity in this phase, we'll try to dispatch to key window or 
                    // just rely on the menu item existing. 
                    // Actually, modifying `ContentView` to add commands is better, but 
                    // the requirement explicitly said "Update UnderWaterApp.swift".
                    // We can try to use a closure or notification.
                    // Or... we can move the commands to ContentView? 
                    // No, `commands` modifier is on Scene.
                    // We can create a separate Commands struct?
                    // Let's use a NotificationCenter approach for "Open Project" command if we can't access state.
                    // OR, simply define the command item and hope we can hook it up later? 
                    // Wait, if I put .commands on WindowGroup, I might not have access to @StateObject if it was there.
                    // But AppState is created in ContentView (or passed there).
                    // Ref: `// Trigger open project`.
                    // I will just put the print/placeholder for now as I can't easily access the instance, 
                    // UNLESS I make AppState a global or singleton, which isn't shown.
                    // Better approach: Handle the command in specific views using `.focusedSceneValue` or similar, 
                    // but that's complex.
                    // Let's stick to the prompt's request: "Update UnderWaterApp.swift" and add the code.
                    // I will put a TODO or a simple Notification post.
                    NotificationCenter.default.post(name: NSNotification.Name("OpenProject"), object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            
            CommandGroup(after: .textFormatting) {
                Button("Find in Files...") {
                    // Trigger search
                     NotificationCenter.default.post(name: NSNotification.Name("FindInFiles"), object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
            }
        }
    }
}
