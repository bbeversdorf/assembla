//
//  PrioritiesListView.swift
//  Assembla
//
//  Created by Brian Beversdorf on 6/26/21.
//

import SwiftUI

struct PrioritiesListView: View {

    var body: some View {
        SwiftUIViewController(storyboard: "Priorities")
    }
}

struct SwiftUIViewController: UIViewControllerRepresentable {
    let storyboard: String
    let initialViewController: String?

    init(storyboard: String, initialViewController: String? = nil) {
        self.storyboard = storyboard
        self.initialViewController = initialViewController
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<SwiftUIViewController>) -> UIViewController {
        //Load the storyboard
        let loadedStoryboard = UIStoryboard(name: storyboard, bundle: nil)
        guard let initialViewController = initialViewController else {
            return loadedStoryboard.instantiateInitialViewController()!
        }

        //Load the ViewController
        return loadedStoryboard.instantiateViewController(withIdentifier: initialViewController)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<SwiftUIViewController>) {
    }
}

struct PrioritiesListView_Previews: PreviewProvider {
    static var previews: some View {
        PrioritiesListView()
    }
}
