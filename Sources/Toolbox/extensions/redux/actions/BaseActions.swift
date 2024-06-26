//
//  Base.swift
//
//  Created .
//  Copyright ©
//

import Foundation

public protocol AppStateT: Equatable, Codable, UserDefaultsStorable {
    
    static var `default`: Self { get }
    
}

///Syncrhonous action
public protocol ReduxAction {
    associatedtype T: AppStateT
    
    func apply(to state: inout T )
}

public extension ReduxAction {
    
    // Synchronous dispatch method
    func dispatch(into store: App.Store<T>) {
        store.dispatch(action: self)
    }
    
    // Asynchronous dispatch method
    func dispatch(into store: App.Store<T>) async {
        await store.dispatch(action: self)
    }
    
}
