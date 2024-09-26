//
//  TopicInputFeature.swift
//  tca test 2
//
//  Created by Michael Baldock on 16/08/2024.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct TopicInputView: View {
    @Bindable var store: StoreOf<TopicInputFeature>
    
    var body: some View {
        VStack {
            TextField("Enter Topic", text: $store.topic.sending(\.topicChanged))
            Button("Load Questions") {
                store.send(.loadQuestionsTapped)
            }
            
            if store.isLoading {
                ProgressView()
            } else if let fact = store.question {
                Text(fact)
            }
        }
    }
}

#Preview {
    TopicInputView(
        store: Store(initialState: TopicInputFeature.State()) {
            TopicInputFeature()
        }
    )
}

@Reducer
struct TopicInputFeature {
    
    @ObservableState
    struct State: Equatable {
        var question: String?
        var isLoading = false
        var topic: String = ""
    }
    
    enum Action {
        case loadQuestionsTapped
        case loadQuestionsResponse(String)
        case topicChanged(String)
    }
    
    @Dependency(\.numberFact) var numberFact
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .loadQuestionsTapped:
                state.question = nil
                state.isLoading = true
                return .run { send in
                    try await send(
                        .loadQuestionsResponse(
                            self.numberFact.fetch("text").results?.first?.question ?? "no question"
                        )
                    )
                }
                
            case let .loadQuestionsResponse(question):
                state.question = question
                state.isLoading = false
                return .none
                
            case let .topicChanged(newTopic):
                state.topic = newTopic
                return .none
            }
        }
    }
}

struct TriviaAPIClient {
    var fetch: (String) async throws -> TriviaAPIClient.Response
}

extension TriviaAPIClient: DependencyKey {
    
    struct Response : Codable {
        let results : [Results]?
        
        enum CodingKeys: String, CodingKey {
            case results = "results"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            results = try values.decodeIfPresent([Results].self, forKey: .results)
        }
        
        struct Results : Codable {
            let question : String?
            let correct_answer : String?
            
            enum CodingKeys: String, CodingKey {
                
                case question = "question"
                case correct_answer = "correct_answer"
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                question = try values.decodeIfPresent(String.self, forKey: .question)
                correct_answer = try values.decodeIfPresent(String.self, forKey: .correct_answer)
            }
        }
    }
    
    static let liveValue = Self(
        fetch: { number in
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "https://opentdb.com/api.php?amount=10&category=9")!)
            let jsonDecoder = JSONDecoder()
            let responseModel = try jsonDecoder.decode(Response.self, from: data)
            return responseModel
        }
    )
}

extension DependencyValues {
    var numberFact: TriviaAPIClient {
        get { self[TriviaAPIClient.self] }
        set { self[TriviaAPIClient.self] = newValue }
    }
}
