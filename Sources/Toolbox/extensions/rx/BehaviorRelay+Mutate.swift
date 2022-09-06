//
//  File.swift
//  
//
//  Created  on 26.09.2022.
//

import Foundation
import RxCocoa

public extension BehaviorRelay {
    
    func mutate( _ mutator: (inout Element) -> Void ) {
        var x = self.value
        mutator(&x)
        self.accept(x)
    }
    
    func mutateCommand<T>( _ mutator: @escaping (inout Element, T) -> Void ) -> CommandWith<T> {
        return CommandWith { t in
            var x = self.value
            mutator(&x, t)
            self.accept(x)
        }
    }
    
    func mutateCommand( _ mutator: @escaping (inout Element) -> Void ) -> Command {
        return Command {
            var x = self.value
            mutator(&x)
            self.accept(x)
        }
    }
    
}
