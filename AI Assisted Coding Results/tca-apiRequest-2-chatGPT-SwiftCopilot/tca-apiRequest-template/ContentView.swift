import SwiftUI
import ComposableArchitecture
import Combine

// MARK: - State
struct QuestionState: Equatable {
    var topic: String = ""
    var questions: [String] = []
    var isLoading: Bool = false
    var hasResults: Bool = true
}

// MARK: - Action
enum QuestionAction: Equatable {
    case topicChanged(String)
    case fetchQuestions
    case questionsResponse(Result<[String], Error>)
}

// MARK: - Environment
struct QuestionEnvironment {
    var fetchQuestions: (String) -> Effect<[String], Error>
    
    static let live = QuestionEnvironment { topic in
        // Mock API with delay
        Effect.future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if topic.isEmpty {
                    promise(.success([]))
                } else {
                    promise(.success([
                        "What is \(topic)?",
                        "How does \(topic) work?",
                        "Explain \(topic) with examples."
                    ]))
                }
            }
        }
    }
}

// MARK: - Reducer
let questionReducer = Reducer<QuestionState, QuestionAction, QuestionEnvironment> { state, action, environment in
    switch action {
    case let .topicChanged(topic):
        state.topic = topic
        return .none
    
    case .fetchQuestions:
        state.isLoading = true
        state.hasResults = true
        return environment.fetchQuestions(state.topic)
            .catchToEffect(QuestionAction.questionsResponse)
    
    case let .questionsResponse(.success(questions)):
        state.isLoading = false
        state.questions = questions
        state.hasResults = !questions.isEmpty
        return .none
    
    case .questionsResponse(.failure):
        state.isLoading = false
        state.questions = []
        state.hasResults = false
        return .none
    }
}

// MARK: - View
struct QuestionView: View {
    let store: Store<QuestionState, QuestionAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TextField(
                    "Enter a topic",
                    text: viewStore.binding(
                        get: \.topic,
                        send: QuestionAction.topicChanged
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Button(action: {
                    viewStore.send(.fetchQuestions)
                }) {
                    Text("Load Questions")
                }
                .padding()

                if viewStore.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    if viewStore.hasResults {
                        List(viewStore.questions, id: \.self) { question in
                            Text(question)
                        }
                    } else {
                        Text("No questions found.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
        }
    }
}

// MARK: - App Entry Point
@main
struct TCAQuestionApp: App {
    var body: some Scene {
        WindowGroup {
            QuestionView(
                store: Store(
                    initialState: QuestionState(),
                    reducer: questionReducer,
                    environment: .live
                )
            )
        }
    }
}

