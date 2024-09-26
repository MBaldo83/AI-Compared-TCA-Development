import SwiftUI
import ComposableArchitecture

// MARK: - Feature
struct TopicInputFeature {
    // MARK: - State
    struct State: Equatable {
        var topic: String = ""
        var isLoading: Bool = false
        var questions: [String] = []
        var isEmpty: Bool = false
    }

    // MARK: - Action
    enum Action: Equatable {
        case topicChanged(String)
        case fetchQuestions
        case questionsResponse(Result<[String], APIError>)
    }

    // MARK: - Environment
    struct Environment {
        var apiClient: TriviaAPIClient
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }

    // MARK: - Reducer
    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case let .topicChanged(topic):
            state.topic = topic
            return .none
            
        case .fetchQuestions:
            state.isLoading = true
            state.isEmpty = false
            return environment.apiClient
                .fetchQuestions(for: state.topic)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map(Action.questionsResponse)
            
        case let .questionsResponse(.success(questions)):
            state.isLoading = false
            state.questions = questions
            state.isEmpty = questions.isEmpty
            return .none
            
        case .questionsResponse(.failure):
            state.isLoading = false
            state.questions = []
            state.isEmpty = true
            return .none
        }
    }
}

// MARK: - API Client
struct TriviaAPIClient {
    var fetchQuestions: (String) -> Effect<[String], APIError>
    
    static let live = TriviaAPIClient { topic in
        Effect.future { callback in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                let questions = topic.isEmpty ? [] : ["Question 1", "Question 2", "Question 3"]
                callback(.success(questions))
            }
        }
    }
}

enum APIError: Error, Equatable {
    case unknown
}

// MARK: - View
struct TopicInputView: View {
    let store: Store<TopicInputFeature.State, TopicInputFeature.Action>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                TextField(
                    "Enter topic",
                    text: viewStore.binding(
                        get: \.topic,
                        send: TopicInputFeature.Action.topicChanged
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Button("Load Questions") {
                    viewStore.send(.fetchQuestions)
                }
                .padding()
                
                if viewStore.isLoading {
                    ProgressView()
                        .padding()
                } else {
                    List {
                        if viewStore.isEmpty {
                            Text("No questions found")
                        } else {
                            ForEach(viewStore.questions, id: \.self) { question in
                                Text(question)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

//// MARK: - Preview
//struct TopicInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopicInputView(
//            store: Store(
//                initialState: TopicInputFeature.State(),
//                reducer: TopicInputFeature.reducer,
//                environment: TopicInputFeature.Environment(
//                    apiClient: .live,
//                    mainQueue: DispatchQueue.main.eraseToAnyScheduler()
//                )
//            )
//        )
//    }
//}
