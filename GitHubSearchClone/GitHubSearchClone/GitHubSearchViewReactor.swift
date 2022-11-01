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
import RxCocoa

final class GitHubSearchViewReactor: Reactor {
    
    let initialState: State = State()
    
    enum Action {
        case updateQuery(String?)
        case loadNextPage
    }
    
    enum Mutation {
        case setQuery(String?)
        case setRepos([String], nextPage: Int?)
    }
    
    struct State {
        var repos: [String] = []
    }
}

extension GitHubSearchViewReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateQuery(let query):
            
            return Observable.concat([
                // 1) State의 query 업데이트
                Observable.just(.setQuery(query)),
                // 2) search API 호출
                self.search(query: query, page: 1)
                    .take(until: self.action.filter(Action.isUpdateQueryAction(_:)))
                    .map { .setRepos($0.repos, nextPage: $0.nextPage)}
            ])
            return .empty()
        case .loadNextPage:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}

extension GitHubSearchViewReactor {
    func url(for query: String?, page: Int) -> URL? {
        guard let query = query else { return nil }
        return URL(string: "https://api.github.com/search/repositories?q=\(query)&page=\(page)")
    }
    func search(query: String?, page: Int) -> Observable<(repos: [String], nextPage: Int?)> {
        let emptyResult: ([String], Int?) = ([], nil)
        
        guard let url = self.url(for: query, page: page) else { return .just(emptyResult)}
        
        return URLSession.shared.rx.json(url: url)
            .map { json -> ([String], Int?) in
                guard let dict = json as? [String : Any] else { return emptyResult }
                guard let items = dict["items"] as? [[String: Any]] else { return emptyResult }
                let repos = items.compactMap { $0["full_name"] as? String }
                let nextPage = repos.isEmpty ? nil : page + 1
                return (repos, nextPage)
            }
            .do(onError: { error in
                if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
                  print("⚠️ GitHub API rate limit exceeded. Wait for 60 seconds and try again.")
                }
            })
            .catchAndReturn(emptyResult)
    }
}

extension GitHubSearchViewReactor.Action {
  static func isUpdateQueryAction(_ action: GitHubSearchViewReactor.Action) -> Bool {
    if case .updateQuery = action {
      return true
    } else {
      return false
    }
  }
}
