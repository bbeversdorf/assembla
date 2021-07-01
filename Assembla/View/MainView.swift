//
//  MainView.swift
//  Assembla
//
//  Created by Brian Beversdorf on 11/22/20.
//

import Foundation
import SwiftUI
import CoreData

struct MainView: View {
    @State var selection: Int? = 0
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var currentDate = Date()

    func GoToLogin() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: PinCodeView())
            sceneDelegate.window = window
            window.makeKeyAndVisible()
        }
    }

    var body: some View {
        NavigationView {
            List {
                NavigationLink("My Priorities", destination: PrioritiesListView()
                                .navigationTitle("Priorities"), tag: 0, selection: $selection)
                NavigationLink("Mentions", destination: MentionsListView()
                                .navigationTitle("Mentions"), tag: 1, selection: $selection)
                NavigationLink("Tickets", destination: TicketsListView()
                                .navigationTitle("Tickets"), tag: 2, selection: $selection)
                Button(action: {
                    Auth.clear()
                    GoToLogin()
                }) {
                    Text("Logout")
                }
            }
            .navigationTitle("Menu")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        return MainView()
    }
}

struct SpacerView: View {
    var body: some View {
        Rectangle()
            .stroke(Color.purple, lineWidth: 1.0)
            .frame(width: 1, height: 10)
    }
}

extension View {
    func inExpandingRectangle() -> some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
            self
        }
    }
}
