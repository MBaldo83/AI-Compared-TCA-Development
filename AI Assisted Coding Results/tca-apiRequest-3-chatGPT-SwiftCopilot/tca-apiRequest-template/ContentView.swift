import SwiftUI
import ComposableArchitecture

// MARK: - State
struct TopicInputFeature: Reducer {
    struct State: Equatable {
        var topic: String = ""
        var isLoading: Bool = false
        var questions: [String] = []
        var errorMessage: String?
    }
    
    enum Action: Equatable {
        case topicChanged(String)
        case loadQuestionsButtonTapped
        case questionsLoaded(Result<[String], TriviaAPIClient.Error>)
    }
    
    @Dependency(\.triviaAPIClient) var triviaAPIClient
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .topicChanged(topic):
            state.topic = topic
            return .none
            
        case .loadQuestionsButtonTapped:
            state.isLoading = true
            state.errorMessage = nil
            return .run { [state] send in
                await send(.questionsLoaded(await self.triviaAPIClient.fetchQuestions(state.topic)))
            }
            
        case let .questionsLoaded(.success(questions)):
            state.isLoading = false
            state.questions = questions
            return .none
            
        case let .questionsLoaded(.failure(error)):
            state.isLoading = false
            state.errorMessage = error.localizedDescription
            return .none
        }
    }
}

// MARK: - TriviaAPIClient
struct TriviaAPIClient {
    var fetchQuestions: (String) async -> Result<[String], Error>
    
    struct Error: Swift.Error, Equatable {
        let message: String
        
        var localizedDescription: String {
            return message
        }
    }
}

// MARK: - Dependency key for TriviaAPIClient
extension TriviaAPIClient: DependencyKey {
    static let liveValue = TriviaAPIClient(fetchQuestions: { topic in
        // Simulated network request
        try? await Task.sleep(nanoseconds: 1_000_000_000) // Simulate a delay
        if topic.isEmpty {
            return .failure(Error(message: "Topic cannot be empty"))
        }
        // Mock questions based on topic
        return .success([
            "\(topic) Question 1",
            "\(topic) Question 2",
            "\(topic) Question 3"
        ])
    })
}

extension DependencyValues {
    var triviaAPIClient: TriviaAPIClient {
        get { self[TriviaAPIClient.self] }
        set { self[TriviaAPIClient.self] = newValue }
    }
}

// MARK: - TopicInputView
struct TopicInputView: View {
    let store: StoreOf<TopicInputFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                TextField(
                    "Enter topic",
                    text: viewStore.binding(
                        get: \.topic,
                        send: TopicInputFeature.Action.topicChanged
                    )
                )
                .textFieldStyle(.roundedBorder)
                .padding()
                
                Button(action: {
                    viewStore.send(.loadQuestionsButtonTapped)
                }) {
                    if viewStore.isLoading {
                        ProgressView()
                    } else {
                        Text("Load Questions")
                    }
                }
                .disabled(viewStore.isLoading || viewStore.topic.isEmpty)
                .padding()
                
                if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                List(viewStore.questions, id: \.self) { question in
                    Text(question)
                }
            }
            .padding()
        }
    }
}

// MARK: - Preview
//struct TopicInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        TopicInputView(
//            store: Store(
//                initialState: TopicInputFeature.State(),
//                reducer: TopicInputFeature()
//            )
//        )
//    }
//}
