//
//  PinCodeView.swift
//  Assembla
//
//  Created by Brian Beversdorf on 11/22/20.
//

import SwiftUI
import UIKit

struct AlertId: Identifiable {
    var id = Int.random(in: 1..<5)

    let message: String
}

struct PinCodeView: View {
    @State private var showingAlert: AlertId?
    @State private var pin: String = ""

    func GoToWork() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: MainView().environment(\.managedObjectContext, context))
            sceneDelegate.window = window
            window.makeKeyAndVisible()
        }
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Button("Get a pin", action: {
                guard let url = URL(string: "https://api.assembla.com/authorization?client_id=\(AuthOperation.clientId)&response_type=pin_code") else {
                    return
                }
                UIApplication.shared.open(url)
            })
            TextField("Enter your pin", text: $pin)
            Button("Log me in", action: {
                guard let operation = AuthOperation.postPin(pin: self.pin) else {
                    return
                }
                operation.completionBlock = {
                    guard operation.error == nil else {
                        let message = operation.error?.localizedDescription ?? ""
                        self.showingAlert = AlertId(message: message)
                        operation.completionBlock = nil
                        return
                    }
                    DispatchQueue.main.async {
                        GoToWork()
                        UNUserNotificationCenter.current().requestAuthorization(options: .badge) { (granted, error) in
                            if error != nil {
                                // success!
                            }
                        }
                        operation.completionBlock = nil
                    }
                }
                RequestOperationQueue.shared.addOperation(operation)
            })
            .alert(item: $showingAlert) { (alert) -> Alert in
                Alert(title: Text("Error"), message: Text(alert.message), dismissButton: .default(Text("Ok")))
            }
        }.padding()
    }
}

struct PinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        PinCodeView()
    }
}
