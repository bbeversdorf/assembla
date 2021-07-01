//
//  SceneDelegate.swift
//  Assembla
//
//  Created by Brian Beversdorf on 11/22/20.
//

import CoreData
import UIKit
import SwiftUI
import KeychainSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath.
        // Add `@Environment(\.managedObjectContext)` in the views that will need the context.

        let accessToken = Auth.getAccessToken()
        let isUserLoggedIn = accessToken != nil

        if isUserLoggedIn {
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: .NSManagedObjectContextObjectsDidChange, object: context)
            Mention.updateMentionsBadge(context: context)
        }

        let view = !isUserLoggedIn ?
            UIHostingController(rootView: PinCodeView()) :
            UIHostingController(rootView: MainView().environment(\.managedObjectContext, context))

        let allPriorities = (try? context.count(for: NSFetchRequest<PrioritySection>(entityName: String(describing: PrioritySection.self)))) ?? 0
        if allPriorities == 0 {
            let backlog = PrioritySection(context: context)
            backlog.id = -9999
            backlog.name = "Backlog"
            let myPriority = PrioritySection(context: context)
            myPriority.id = 0
            myPriority.name = "My Priorities"
            try? context.save()
        }

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = view
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    @objc func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let context = notification.object as? NSManagedObjectContext else {
            return
        }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.contains(where: { $0 is Mention }) {
            Mention.updateMentionsBadge(context: context)
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.contains(where: { $0 is Mention }) {
            Mention.updateMentionsBadge(context: context)
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.contains(where: { $0 is Mention }) {
            Mention.updateMentionsBadge(context: context)
        }
    }
}

