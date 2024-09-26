//
//  tca_apiRequestFeature_aApp.swift
//  tca-apiRequestFeature-a
//
//  Created by Michael Baldock on 11/09/2024.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCA_APIRequestTestApp: App {
    
    static let store = Store(initialState: TopicInputFeature.State()) {
        TopicInputFeature()._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            TopicInputView(store: TCA_APIRequestTestApp.store)
        }
    }
}
