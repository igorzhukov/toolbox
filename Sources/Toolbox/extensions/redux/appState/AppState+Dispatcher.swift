//
//  Dispatcher.swift
//  
//
//  Created .
//  Copyright© All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

public extension Driver where Element: AppStateT {
    
    func changesOf<T: Equatable>(_ mapper: @escaping (Element) -> T) -> SharedSequence<SharedSequence.SharingStrategy, T> {
        return map(mapper).distinctUntilChanged()
    }
    
    func changesOfFull<T: Equatable>(_ mapper: @escaping (Element) -> T) -> SharedSequence<SharedSequence.SharingStrategy, Element> {
        return distinctUntilChanged { lhs, rhs in
            mapper(lhs) == mapper(rhs)
        }
    }
    
    func changesOf<T: Equatable, U: Equatable>(_ mapperT: @escaping (Element) -> T,
                                               _ mapperU: @escaping (Element) -> U) -> Self {
        return distinctUntilChanged { lhs, rhs in
            mapperT(lhs) == mapperT(rhs) &&
            mapperU(lhs) == mapperU(rhs)
        }
    }
    
    func changesOf<T: Equatable, U: Equatable, V: Equatable>
    (_ mapperT: @escaping (Element) -> T,
     _ mapperU: @escaping (Element) -> U,
     _ mapperV: @escaping (Element) -> V) -> Self {
        return distinctUntilChanged { lhs, rhs in
            mapperT(lhs) == mapperT(rhs) &&
            mapperU(lhs) == mapperU(rhs) &&
            mapperV(lhs) == mapperV(rhs)
        }
    }
    
}

