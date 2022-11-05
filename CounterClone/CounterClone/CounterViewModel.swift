//
//  CounterViewModel.swift
//  CounterClone
//
//  Created by 장선영 on 2022/11/05.
//

import Foundation

import ReactorKit

class CounterViewModel: Reactor {
    
    var initialState: State = State()
    
    enum Action {
        case tapIncreaseButton
        case tapDecreaseButton
    }
    
    enum Mutation {
        case increaseValue
        case decreaseValue
        case startLoading(Bool)
        case presentAlertMessage(String)
    }
    
    struct State {
        var count = 0
        var isLoading = false
        var alertMessage: String? = nil
    }
}

extension CounterViewModel {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapIncreaseButton :
            return Observable.concat([
                .just(.startLoading(true)),
                .just(.increaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.startLoading(false)),
                .just(.presentAlertMessage("increased!"))
            ])
        case .tapDecreaseButton :
            return Observable.concat([
                .just(.startLoading(true)),
                .just(.decreaseValue).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                .just(.startLoading(false)),
                .just(.presentAlertMessage("decreased!"))
            ])
        }
    }
    
    func reduce(state: State, mutation: CounterViewModel.Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .increaseValue:
            newState.count += 1
        case .decreaseValue:
            newState.count -= 1
        case .startLoading(let isLoading):
            newState.isLoading = isLoading
        case .presentAlertMessage(let message):
            newState.alertMessage = message
        }
        return newState
    }
}
