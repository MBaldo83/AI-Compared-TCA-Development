//
//  tca_apiRequest_chatGPT_SwiftCopilotApp.swift
//  tca-apiRequest-chatGPT-SwiftCopilot
//
//  Created by Michael Baldock on 12/09/2024.
//

import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            QuestionLoaderView(
                store: Store(
                    initialState: QuestionLoaderState(),
                    reducer: questionLoaderReducer,
                    environment: .live
                )
            )
        }
    }
}
