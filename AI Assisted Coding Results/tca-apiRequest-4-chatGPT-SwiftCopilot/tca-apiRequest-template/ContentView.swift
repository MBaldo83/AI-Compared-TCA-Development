import SwiftUI
import ComposableArchitecture
import Combine

// MARK: - Feature: Reducer Logic, State, and Actions
struct QuestionsFeature: Reducer {
    // State holds the topic input, loading status, fetched questions, and empty results.
    struct State: Equatable {
        var topic: String = ""
        var isLoading: Bool = false
        var questions: [String] = []
        var isEmpty: Bool {
            return !isLoading && questions.isEmpty && !topic.isEmpty
        }
    }
    
    // Action defines the actions the view can dispatch, including UI events and API handling.
    enum Action: Equatable {
        case topicChanged(String)        // Triggered when the topic text changes
        case loadQuestions               // Triggered when the button is pressed
        case questionsResponse([String]) // Triggered when the API call finishes with questions
        case setLoading(Bool)            // Used to toggle the loading state
    }
    
    // Dependencies
    @Dependency(\.apiClient) var apiClient  // Inject the APIClient
    
    // Reducer: Handles actions and modifies state accordingly.
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case let .topicChanged(newTopic):
            state.topic = newTopic
            return .none  // No further side-effects, just update the state
            
        case .loadQuestions:
            guard !state.topic.isEmpty else { return .none }  // Do nothing if topic is empty
            state.isLoading = true  // Set loading state
            state.questions = []    // Clear previous questions
            return .run { [state] send in
                let questions = try await apiClient.fetchQuestions(state.topic)
                await send(.questionsResponse(questions))
            }
            
        case let .questionsResponse(fetchedQuestions):
            state.isLoading = false
            state.questions = fetchedQuestions
            return .none
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return .none
        }
    }
}

// MARK: - API Client Simulation
struct APIClient {
    var fetchQuestions: (String) async throws -> [String]
}

// Dependency key to inject the APIClient in the environment
extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
    
    private struct APIClientKey: DependencyKey {
        static let liveValue = APIClient(fetchQuestions: { topic in
            // Mock API delay to simulate loading
            try await Task.sleep(for: .seconds(1))
            // Simulate API returning questions for some topics
            return topic.lowercased() == "swift" ? ["What is Swift?", "What are Optionals?", "How to use TCA?"] : []
        })
    }
}

// MARK: - View: SwiftUI UI Layer
struct QuestionsView: View {
    let store: StoreOf<QuestionsFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                // TextField for topic input
                TextField("Enter a topic", text: viewStore.binding(
                    get: \.topic,
                    send: QuestionsFeature.Action.topicChanged
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                // Button to trigger loading questions
                Button(action: { viewStore.send(.loadQuestions) }) {
                    Text("Load Questions")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                // Loading spinner while fetching data
                if viewStore.isLoading {
                    ProgressView("Loading Questions...")
                        .padding()
                } else {
                    // List of fetched questions
                    List {
                        if viewStore.isEmpty {
                            Text("No questions found.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewStore.questions, id: \.self) { question in
                                Text(question)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - SwiftUI App Entry Point
@main
struct QuestionsApp: App {
    var body: some Scene {
        WindowGroup {
            QuestionsView(
                store: Store(initialState: QuestionsFeature.State()) {
                    QuestionsFeature()
                })
        }
    }
}
