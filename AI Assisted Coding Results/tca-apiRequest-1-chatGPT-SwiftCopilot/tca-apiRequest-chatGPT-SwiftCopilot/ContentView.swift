//
//  ContentView.swift
//  tca-apiRequest-chatGPT-SwiftCopilot
//
//  Created by Michael Baldock on 12/09/2024.
//

import SwiftUI
import ComposableArchitecture

struct QuestionLoaderEnvironment: DependencyKey {
    
    var fetchQuestions: (String) -> Effect<Result<[String], QuestionLoaderFeature.QuestionLoaderError>>
    
    static let liveValue = QuestionLoaderEnvironment(
        fetchQuestions: { topic in
            // Simulating network call with a delay
            Effect<Result<[String], QuestionLoaderFeature.QuestionLoaderError>>.future { callback in
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    if topic.isEmpty {
                        callback(.failure(.networkError("No topic provided.")))
                    } else {
                        callback(.success([
                            "What is \(topic)?",
                            "How does \(topic) work?",
                            "Why is \(topic) important?"
                        ]))
                    }
                }
            }
        }
    )
}

@Reducer
struct QuestionLoaderFeature {
    
    @ObservableState
    struct State: Equatable {
        var topic: String = ""  // Stores the user-inputted topic
        var questions: [String] = []  // Questions loaded from a data source
        var isLoading: Bool = false  // Tracks loading state
        var errorMessage: String? = nil  // Optional error message
    }

    enum Action: Equatable {
        case topicChanged(String)
        case loadQuestions
        case questionsLoaded(Result<[String], QuestionLoaderError>)
    }

    enum QuestionLoaderError: Error, Equatable {
        case networkError(String)
    }
    
    @Dependency(\.environment) var environment
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .topicChanged(topic):
                state.topic = topic
                return .none
                
            case .loadQuestions:
                state.isLoading = true
                return environment.fetchQuestions(state.topic)
                    .receive(on: DispatchQueue.main)
                    .catchToEffect(Action.questionsLoaded)
                
            case let .questionsLoaded(.success(questions)):
                state.isLoading = false
                state.questions = questions
                state.errorMessage = nil
                return .none
                
            case let .questionsLoaded(.failure(error)):
                state.isLoading = false
                state.questions = []
                state.errorMessage = "Failed to load questions: \(error)"
                return .none
            }
        }
    }
}

extension DependencyValues {
    var environment: QuestionLoaderEnvironment {
        get { self[QuestionLoaderEnvironment.self] }
        set { self[QuestionLoaderEnvironment.self] = newValue }
    }
}

struct QuestionLoaderView: View {
    let store: Store<QuestionLoaderState, QuestionLoaderAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TextField("Enter a topic", text: viewStore.binding(
                    get: \.topic,
                    send: QuestionLoaderAction.topicChanged
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Button(action: {
                    viewStore.send(.loadQuestions)
                }) {
                    if viewStore.isLoading {
                        ProgressView()
                    } else {
                        Text("Load Questions")
                    }
                }
                .padding()
                .disabled(viewStore.isLoading)
                
                if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                List(viewStore.questions, id: \.self) { question in
                    Text(question)
                }
            }
            .navigationTitle("Question Loader")
            .padding()
        }
    }
}
