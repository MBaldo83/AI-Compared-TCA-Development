import SwiftUI
import ComposableArchitecture
import Combine

// MARK: - APIClient

// Simulates an API client for fetching questions
struct APIClient {
    var fetchQuestions: (String) async throws -> [String]
    
    // Mock implementation
    static let mock = Self(
        fetchQuestions: { topic in
            try await Task.sleep(for: .seconds(1))
            return ["Question 1 about \(topic)", "Question 2 about \(topic)", "Question 3 about \(topic)"]
        }
    )
}

// MARK: - TopicInputFeature

struct TopicInputFeature: Reducer {
    struct State: Equatable {
        var topic: String = ""
        var questions: [String] = []
        var isLoading: Bool = false
    }
    
    enum Action: Equatable {
        case topicChanged(String)
        case loadButtonTapped
        case questionsResponse([String])
    }
    
    @Dependency(\.apiClient) var apiClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .topicChanged(newTopic):
                state.topic = newTopic
                return .none
                
            case .loadButtonTapped:
                state.isLoading = true
                return .run { [topic = state.topic] send in
                    let questions = try await apiClient.fetchQuestions(topic)
                    await send(.questionsResponse(questions))
                }
                
            case let .questionsResponse(questions):
                state.questions = questions
                state.isLoading = false
                return .none
            }
        }
    }
}

// MARK: - TopicInputView

struct TopicInputView: View {
    let store: StoreOf<TopicInputFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                TextField("Enter a topic", text: viewStore.binding(
                    get: \.topic,
                    send: TopicInputFeature.Action.topicChanged
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Button("Load Questions") {
                    viewStore.send(.loadButtonTapped)
                }
                .disabled(viewStore.topic.isEmpty)
                
                if viewStore.isLoading {
                    ProgressView()
                } else {
                    List(viewStore.questions, id: \.self) { question in
                        Text(question)
                    }
                }
            }
        }
    }
}

// MARK: - DependencyValues Extension

private enum APIClientKey: DependencyKey {
    static let liveValue = APIClient.mock
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TopicInputView(
            store: Store(initialState: TopicInputFeature.State()) {
                TopicInputFeature()
            }
        )
    }
}
