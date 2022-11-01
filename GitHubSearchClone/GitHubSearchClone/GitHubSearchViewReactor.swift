//
//  GitHubSearchViewReactor.swift
//  GitHubSearchClone
//
//  Created by 장선영 on 2022/11/01.
//

import Foundation
import UIKit

import ReactorKit
import RxSwift

final class GitHubSearchViewReactor: Reactor {
    
    let initialState: State = State()
    
    enum Action {
        case updateQuery(String?)
        case loadNextPage
    }
    
    enum Mutation {
        
    }
    
    struct State {
        var repos: [String] = []
    }
}

extension GitHubSearchViewReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateQuery(let query):
            return .empty()
        case .loadNextPage:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
