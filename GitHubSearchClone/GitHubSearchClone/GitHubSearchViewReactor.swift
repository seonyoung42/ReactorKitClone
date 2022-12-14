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
        case setLoadingNextPage(Bool)
        case appendRepos([String], nextPage: Int?)
    }
    
    struct State {
        var query: String?
        var repos: [String] = []
        var nextPage: Int?
        var isLoadingNextPage: Bool = false
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
        case .loadNextPage:
            // isLoadingNextPage가 false인 경우 실행하지 않음
            guard self.currentState.isLoadingNextPage else { return Observable.empty() }
            guard let page = self.currentState.nextPage else { return Observable.empty()}
            
            return Observable.concat([
                // 1) State의 LoadinNextPage true로
                Observable.just(.setLoadingNextPage(true)),
                
                // 2) repos 배열 append
                self.search(query: self.currentState.query, page: page)
                    .take(until: self.action.filter(Action.isUpdateQueryAction(_:)))
                    .map { .appendRepos($0.repos, nextPage: $0.nextPage)},
                
                // 3) State의 LoadinNextPage 다시 false로
                Observable.just(.setLoadingNextPage(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .setQuery(let query):
            newState.query = query
        case .setRepos(let repos, let nextPage):
            newState.repos = repos
            newState.nextPage = nextPage
        case .setLoadingNextPage(let isLoadingNextPage):
            newState.isLoadingNextPage = isLoadingNextPage
        case .appendRepos(let repos, nextPage: let nextPage):
            newState.repos.append(contentsOf: repos)
            newState.nextPage = nextPage
        }
        
        return newState
    }
}

private extension GitHubSearchViewReactor {
    
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

